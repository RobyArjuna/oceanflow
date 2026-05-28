import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/ai_assistant_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage([String? presetText]) async {
    if (_isSending) return;

    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    if (presetText == null) {
      _textController.clear();
    }

    // Delay scroll to bottom so the message is rendered first
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);

    try {
      await ref.read(aiAssistantProvider.notifier).sendMessage(text);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
    
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiAssistantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ASISTEN LOGISTIK AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Hapus riwayat obrolan',
            onPressed: () {
              ref.read(aiAssistantProvider.notifier).clearHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dynamic Message Area
          Expanded(
            child: chatState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (messages) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.role == 'user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? OceanColors.primary : OceanColors.grey100,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                          ),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: OceanColors.grey200,
                                  width: 1,
                                ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : OceanColors.grey800,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Suggestion Chips Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _SuggestionChip(
                    label: 'Cek risiko Atlantic Pioneer',
                    onTap: _isSending ? null : () => _sendMessage('Apakah ada risiko cuaca pada kapal Atlantic Pioneer?'),
                  ),
                  const SizedBox(width: 8),
                  _SuggestionChip(
                    label: 'Buat draf laporan bea cukai',
                    onTap: _isSending ? null : () => _sendMessage('Bisa buatkan draf laporan bea cukai?'),
                  ),
                  const SizedBox(width: 8),
                  _SuggestionChip(
                    label: 'Tampilkan daftar ETA aktif',
                    onTap: _isSending ? null : () => _sendMessage('Tampilkan perkiraan waktu tiba (ETA) pengiriman'),
                  ),
                ],
              ),
            ),
          ),

          // Input controls board
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: OceanColors.grey200,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isSending ? OceanColors.grey100 : OceanColors.grey50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: OceanColors.grey200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              enabled: !_isSending,
                              style: TextStyle(
                                fontSize: 14,
                                color: _isSending ? OceanColors.grey400 : OceanColors.grey900,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tanya risiko kargo, jadwal rute...',
                                hintStyle: TextStyle(
                                  color: _isSending ? OceanColors.grey400.withOpacity(0.5) : OceanColors.grey400,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isSending ? OceanColors.grey400 : OceanColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _isSending ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: onTap == null ? OceanColors.grey400 : OceanColors.primary, // Sapphire Blue
        ),
      ),
      backgroundColor: OceanColors.grey100, // Light Gray
      side: BorderSide(
        color: onTap == null ? OceanColors.grey200.withOpacity(0.5) : OceanColors.grey200,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded Capsule
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: onTap,
    );
  }
}
