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
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    // Delay scroll to bottom so the message is rendered first
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);

    await ref.read(aiAssistantProvider.notifier).sendMessage(text);
    
    Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiAssistantProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI LOGISTICS SCHEDULER'),
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
                          color: isUser ? OceanColors.primary : OceanColors.surfaceElevated,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                          ),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: isUser ? Colors.white : null,
                            fontSize: 13.5,
                            height: 1.4,
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
                    label: 'Check Atlantic Pioneer risks',
                    onTap: () => _sendMessage('Are there weather risks on Atlantic Pioneer?'),
                  ),
                  const SizedBox(width: 8),
                  _SuggestionChip(
                    label: 'Draft customs clearance report',
                    onTap: () => _sendMessage('Can you draft a clearance report?'),
                  ),
                  const SizedBox(width: 8),
                  _SuggestionChip(
                    label: 'Show active ETAs list',
                    onTap: () => _sendMessage('Show shipment ETAs'),
                  ),
                ],
              ),
            ),
          ),

          // Input controls board
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Ask cargo risks, route schedules...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: OceanColors.primary),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 11, color: OceanColors.teal),
      ),
      backgroundColor: OceanColors.surfaceElevated,
      side: BorderSide(
        color: OceanColors.teal.withOpacity(0.3),
      ),
      onPressed: onTap,
    );
  }
}
