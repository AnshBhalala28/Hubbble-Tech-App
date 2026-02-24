import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wavee/utils/colors.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/inAppWebView.dart';

class ExpandableClickableText extends StatefulWidget {
  final String text;
  final int trimLength;
  final TextStyle? style;

  const ExpandableClickableText({
    super.key,
    required this.text,
    this.trimLength = 150,
    this.style,
  });

  @override
  State<ExpandableClickableText> createState() =>
      _ExpandableClickableTextState();
}

class _ExpandableClickableTextState extends State<ExpandableClickableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleText =
        widget.text.length > widget.trimLength && !isExpanded
            ? "${widget.text.substring(0, widget.trimLength)}..."
            : widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClickableText(visibleText),

        if (widget.text.length > widget.trimLength)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Text(
              isExpanded ? "Show less" : "Show more",
              style: const TextStyle(
                color: AppColors.maincolor,
                fontFamily: AppConstants.manrope,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClickableText(String text) {
    final urlRegex = RegExp(
      r"((https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}([\/\w\-\?\=\&\.]*)*)",
    );

    final words = text.split(" ");

    return Text.rich(
      TextSpan(
        children:
            words.map((word) {
              if (urlRegex.hasMatch(word)) {
                String finalUrl = word;

                // Add scheme if missing
                if (!finalUrl.startsWith("http://") &&
                    !finalUrl.startsWith("https://")) {
                  finalUrl = "https://$finalUrl".replaceAll(
                    " ",
                    "",
                  ); // remove any accidental spaces
                }

                return TextSpan(
                  text: "$word ",
                  style: widget.style?.copyWith(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WebViewScreen(url: finalUrl),
                            ),
                          );
                        },
                );
              } else {
                return TextSpan(text: "$word ", style: widget.style);
              }
            }).toList(),
      ),
    );
  }
}

class ClickableTrimmedText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle style;

  const ClickableTrimmedText({
    super.key,
    required this.text,
    required this.maxLines,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final urlRegex = RegExp(
      r"((https?:\/\/)?(www\.)?[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}([\/\w\-\?\=\&\.]*)*)",
    );

    final words = text.split(" ");

    return LayoutBuilder(
      builder: (context, constraints) {
        return RichText(
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            children:
                words.map((word) {
                  if (urlRegex.hasMatch(word)) {
                    String finalUrl = word;

                    // Auto add https if missing
                    if (!finalUrl.startsWith("http")) {
                      finalUrl = "https://$finalUrl";
                    }

                    finalUrl = finalUrl.trim();

                    return TextSpan(
                      text: "$word ",
                      style: style.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => WebViewScreen(url: finalUrl),
                                ),
                              );
                            },
                    );
                  } else {
                    return TextSpan(text: "$word ", style: style);
                  }
                }).toList(),
          ),
        );
      },
    );
  }
}
