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
        const msg = "Welcome to OceanFlow AI Assistant. I can help resolve container routing risks, check vessel ETA forecasts, draft custom port clearance reports, or answer details on active shipments.";
        
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
    var assistantContent = "";
    final tempAssistantMessage = ChatMessage(
      id: assistantMsgId,
      role: 'assistant',
      content: "Thinking...",
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
    if (lower.contains('risk') || lower.contains('atlantic pioneer')) {
      return "ANALYSIS: Vessel 'Atlantic Pioneer' (TRK-2026-N897A) is crossing high-winds zone in North Atlantic. Heavy swells up to 4.5m detected. Minor delay of 4 hours expected at Newark Harbor terminal gate, but cargo remains fully secure within locked temperature buffers.";
    }
    if (lower.contains('eta') || lower.contains('when')) {
      return "SCHEDULE REPORT: Atlantic Pioneer (Newark) ETA: June 05, 18:00 UTC. Pacific Empress (Hamburg) ETA: May 28, 06:30 UTC. Both arrivals are within planned variance margins. No supply chain line stoppage risks identified.";
    }
    if (lower.contains('clearance') || lower.contains('custom')) {
      return "TEMPLATE DRAFT: 'Port Authority Clearance Report - TRK-2026-N897A. We hereby declare Container Seals CONT-4008 / CONT-9023 fully intact. Bilge sensors operational. Requesting slot allocation for urgent discharge.'";
    }
    return "LOGISTICS INTELLIGENCE: Query acknowledged. You can inquire about Atlantic Pioneer weather risk delays, ETA reports, container barcodes, or ask to draft automated customs declaration logs.";
  }
}
