import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

enum MessageStatus { sent, delivered, read, failed }

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final Widget? avatar;
  final bool showAvatar;
  final bool isTyping;
  final String? imageUrl;
  final VoidCallback? onImageTap;
  final MessageStatus? messageStatus;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.avatar,
    this.showAvatar = true,
    this.isTyping = false,
    this.imageUrl,
    this.onImageTap,
    this.messageStatus,
  });

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
    return DateFormat('hh:mm a').format(time);
  }

  Widget _buildAvatar() {
    if (!showAvatar) return const SizedBox(width: 40);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: avatar ??
          CircleAvatar(
            radius: 18,
            backgroundColor: isUser ? Colors.green : Colors.grey.shade400,
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
    );
  }

  Widget _buildMessageStatus() {
    if (!isUser || messageStatus == null) return const SizedBox.shrink();

    final status = messageStatus!;
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(icon, size: 14, color: color),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
              (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              height: 6,
              width: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    if (isTyping) return _buildTypingIndicator();

    final bubbleColor = isUser ? Colors.green.shade400 : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
      bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
    );

    Widget messageContent;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      messageContent = GestureDetector(
        onTap: onImageTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 200,
              height: 200,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      );
    } else {
      messageContent = SelectableText.rich(
        TextSpan(
          children: _parseMessageText(message, textColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: alignment,
      children: [
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: message));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message copied')),
            );
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: imageUrl != null
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
            ),
            child: messageContent,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              _formatTimestamp(timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
            if (isUser) _buildMessageStatus(),
          ],
        ),
      ],
    );
  }

  List<TextSpan> _parseMessageText(String text, Color color) {
    final regex = RegExp(
        r'((https?://)?([\w\-]+\.)+[a-zA-Z]{2,}(/\S*)?)',
        caseSensitive: false);
    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return [TextSpan(text: text, style: TextStyle(color: color))];
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: color),
        ));
      }
      final url = text.substring(match.start, match.end);
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          color: Colors.blue.shade700,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: color),
      ));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final alignment =
    isUser ? MainAxisAlignment.end : MainAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: alignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(),
          Flexible(child: _buildMessageBubble(context)),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }
}