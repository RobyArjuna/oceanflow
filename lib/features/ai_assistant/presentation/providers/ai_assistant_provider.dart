import 'package:meta/meta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/constants/db_constants.dart';

@immutable
class ChatMessage {
  final String id;
  final String role; // user | assistant
  final String content;
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });
}

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  return AiAssistantNotifier(ref.watch(appDatabaseProvider));
});

class AiAssistantNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final AppDatabase _dbHelper;
  final _uuid = const Uuid();

  AiAssistantNotifier(this._dbHelper) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DbConstants.tableAiConversations,
        orderBy: '${DbConstants.colCreatedAt} ASC',
      );

      final list = maps.map((map) {
        return ChatMessage(
          id: map[DbConstants.colId] as String,
          role: map[DbConstants.colRole] as String,
          content: map[DbConstants.colContent] as String,
          createdAt: map[DbConstants.colCreatedAt] as String,
        );
      }).toList();

      if (list.isEmpty) {
        // Welcoming starter message from AI assistant
        final starterId = _uuid.v4();
        final now = DateTime.now().toIso8601String();
        const msg = "Selamat datang di Asisten AI OceanFlow. Saya dapat membantu mendeteksi risiko rute kontainer, memeriksa perkiraan ETA kapal, membuat draf laporan bea cukai pelabuhan, atau menjawab informasi mengenai pengiriman aktif Anda.";
        
        await db.insert(DbConstants.tableAiConversations, {
          DbConstants.colId: starterId,
          DbConstants.colRole: 'assistant',
          DbConstants.colContent: msg,
          DbConstants.colCreatedAt: now,
        });

        state = AsyncValue.data([
          ChatMessage(id: starterId, role: 'assistant', content: msg, createdAt: now)
        ]);
        return;
      }

      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearHistory() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(DbConstants.tableAiConversations);
      await loadHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String text) async {
    final list = state.valueOrNull ?? [];
    final userMsgId = _uuid.v4();
    final userNow = DateTime.now().toIso8601String();
    
    final userMessage = ChatMessage(
      id: userMsgId,
      role: 'user',
      content: text,
      createdAt: userNow,
    );

    // Update state & persist locally
    state = AsyncValue.data([...list, userMessage]);
    
    final db = await _dbHelper.database;
    await db.insert(DbConstants.tableAiConversations, {
      DbConstants.colId: userMsgId,
      DbConstants.colRole: 'user',
      DbConstants.colContent: text,
      DbConstants.colCreatedAt: userNow,
    });

    // Simulate Streaming assistant response
    final assistantMsgId = _uuid.v4();
    final assistantNow = DateTime.now().toIso8601String();
    
    // Setup temporary typing placeholder
    final tempAssistantMessage = ChatMessage(
      id: assistantMsgId,
      role: 'assistant',
      content: "Sedang berpikir...",
      createdAt: assistantNow,
    );

    state = AsyncValue.data([...list, userMessage, tempAssistantMessage]);

    final reply = _getMockReply(text);
    
    // Stream characters chunked to simulate natural response pacing
    var currentString = "";
    final words = reply.split(" ");
    
    for (var i = 0; i < words.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      currentString += (i == 0 ? "" : " ") + words[i];
      
      if (!mounted) return;

      final updatedMessage = ChatMessage(
        id: assistantMsgId,
        role: 'assistant',
        content: currentString,
        createdAt: assistantNow,
      );
      
      state = AsyncValue.data([...list, userMessage, updatedMessage]);
    }

    // Persist final fully streamed assistant reply in db
    await db.insert(DbConstants.tableAiConversations, {
      DbConstants.colId: assistantMsgId,
      DbConstants.colRole: 'assistant',
      DbConstants.colContent: reply,
      DbConstants.colCreatedAt: assistantNow,
    });
  }

  String _getMockReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('risiko') || lower.contains('risk') || lower.contains('atlantic pioneer')) {
      return "ANALISIS: Kapal 'Atlantic Pioneer' (TRK-2026-N897A) sedang melintasi zona angin kencang di Atlantik Utara. Terdeteksi gelombang tinggi hingga 4.5m. Diperkirakan ada keterlambatan kecil sekitar 4 jam di gerbang terminal Newark Harbor, namun kargo tetap sepenuhnya aman dalam wadah buffer suhu yang terkunci.";
    }
    if (lower.contains('eta') || lower.contains('kapan') || lower.contains('when') || lower.contains('tiba')) {
      return "LAPORAN JADWAL: ETA Atlantic Pioneer (Newark): 5 Juni, 18:00 UTC. ETA Pacific Empress (Hamburg): 28 Mei, 06:30 UTC. Kedua kedatangan masih dalam batas toleransi yang direncanakan. Tidak ada risiko hambatan rantai pasok.";
    }
    if (lower.contains('clearance') || lower.contains('bea cukai') || lower.contains('custom') || lower.contains('draf')) {
      return "DRAF TEMPLATE: 'Laporan Izin Otoritas Pelabuhan - TRK-2026-N897A. Dengan ini kami menyatakan Segel Kontainer CONT-4008 / CONT-9023 sepenuhnya utuh. Sensor lambung kapal berfungsi normal. Memohon alokasi slot untuk pembongkaran muatan darurat.'";
    }
    return "LOGISTIK INTELEGENSI: Pertanyaan diterima. Anda dapat bertanya tentang penundaan risiko cuaca Atlantic Pioneer, laporan ETA, barcode kontainer, atau meminta pembuatan draf log deklarasi bea cukai otomatis.";
  }
}
