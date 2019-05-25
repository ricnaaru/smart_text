import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final RegExp emojiRegex = RegExp(
    r"(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])");

final _urlRegex = RegExp(
  r"^((?:.|\n)*?)((?:https?):\/\/[^\s/$.?#].[^\s]*)",
  caseSensitive: false,
);

class TextElement {
  final String text;
  final bool isUrl;

  TextElement(this.text, {bool isUrl}) : this.isUrl = isUrl ?? false;
}

List<TextElement> checkUrl(String text) {
  final List<TextElement> list = [];

  final urlMatch = _urlRegex.firstMatch(text);

  if (urlMatch == null) {
    list.add(TextElement(text));
  } else {
    if (urlMatch != null) {
      text = text.replaceFirst(urlMatch.group(0), "");

      if (urlMatch.group(1).isNotEmpty) {
        list.add(TextElement(urlMatch.group(1)));
      }

      if (urlMatch.group(2).isNotEmpty) {
        list.add(TextElement(urlMatch.group(2), isUrl: true));
      }
    }

    list.addAll(checkUrl(text));
  }

  return list;
}

class SmartTextConfig {
  static String readMoreText = "Read More";
  static String readLessText = "Show Less";
  static int maxLines;
}

class SmartText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final String readMoreText;
  final String readLessText;

  SmartText(this.text, {this.style, int maxLines, String readMoreText, String readLessText})
      : this.maxLines = maxLines ?? SmartTextConfig.maxLines,
        this.readMoreText = readMoreText ?? SmartTextConfig.readMoreText,
        this.readLessText = readLessText ?? SmartTextConfig.readLessText;

  @override
  _SmartTextState createState() => _SmartTextState();
}

class _SmartTextState extends State<SmartText> {
  TextStyle textStyle;
  TextStyle emojiTextStyle;
  TextStyle linkTextStyle;
  bool expandable = true;

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    if (textStyle == null) {
      textStyle = defaultTextStyle.style.merge(widget.style);
      emojiTextStyle = defaultTextStyle.style.merge(widget.style);
      emojiTextStyle = emojiTextStyle.copyWith(fontSize: emojiTextStyle.fontSize * 0.85);
      linkTextStyle = defaultTextStyle.style.merge(widget.style).copyWith(color: Colors.blue);
    }

    return handleEmoji(context, widget.text);
  }

  Widget handleEmoji(BuildContext context, String input) {
    List<TextSpan> textSpans = [];

    List<TextElement> searchedTextSpans = checkUrl(input);

    for (var x in searchedTextSpans) {
      String tempInput = x.text;

      if (x.isUrl) {
        textSpans.add(_buildLinkTextSpan(tempInput));
        continue;
      }

      List<TextSpan> tempTextSpans = [];
      int lastEmojiIndex = 0;
      int emojiIndex = tempInput.indexOf(emojiRegex);

      while (emojiIndex >= 0) {
        tempTextSpans
            .add(TextSpan(text: tempInput.substring(lastEmojiIndex, emojiIndex), style: textStyle));

        String emojis = "";

        for (int i = emojiIndex; i < tempInput.length; i++) {
          String currentLetter = tempInput.substring(i, i + 1);

          //check for surrogates emoji
          if (RegExp(r"[\ud800-\udbff]|[\udc00-\udfff]").hasMatch(currentLetter)) {
            String currentLetter2 =
            i == tempInput.length - 1 ? "" : tempInput.substring(i + 1, i + 2);
            if (RegExp(r"[\ud800-\udbff]|[\udc00-\udfff]").hasMatch(currentLetter2)) {
              emojis = "$emojis$currentLetter$currentLetter2";
              i++;
            }
          } else {
            if (!emojiRegex.hasMatch(currentLetter)) {
              lastEmojiIndex = i;
              emojiIndex = i;
              break;
            } else {
              emojis = "$emojis${tempInput.substring(i, i + 1)}";
            }
          }
        }

        tempTextSpans.add(TextSpan(text: emojis, style: emojiTextStyle));

        emojiIndex = tempInput.indexOf(emojiRegex, emojiIndex);
      }

      tempTextSpans.add(
          TextSpan(text: tempInput.substring(lastEmojiIndex, tempInput.length), style: textStyle));

      textSpans.addAll(tempTextSpans);
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        List<Widget> stackChildren = [];
        int maxLines = expandable ? widget.maxLines : null;
        String linkText = expandable ? widget.readMoreText : widget.readLessText;
        var tx = TextPainter(
            text: TextSpan(children: textSpans),
            maxLines: maxLines,
            textDirection: ui.TextDirection.ltr);
        tx.layout(maxWidth: constraints.maxWidth);

        if (tx.didExceedMaxLines) {}

        var txr = TextPainter(
            text: TextSpan(text: "\u2026  $linkText", style: linkTextStyle),
            maxLines: maxLines,
            textDirection: ui.TextDirection.ltr);

        txr.layout();

        double readMoreWidth = txr.width;
        double readMoreHeight = txr.height;
        
        if (tx.didExceedMaxLines) {
          stackChildren.add(ClipPath(
            clipper: ReadMoreClipper(width: readMoreWidth, height: readMoreHeight),
            child: Column(children: [
              RichText(
                text: TextSpan(children: textSpans),
                maxLines: maxLines,
              ),
              Container(height: expandable ? 0.0 : readMoreHeight)
            ]),
          ));
        } else {
          if (widget.maxLines == null) {
            stackChildren.add(RichText(
              text: TextSpan(children: textSpans),
              maxLines: maxLines,
            ));
          } else {
            stackChildren.add(Column(children: [
              RichText(
                text: TextSpan(children: textSpans),
                maxLines: maxLines,
              ),
              Container(height: expandable ? 0.0 : readMoreHeight)
            ]),);
          }
        }

        if ((tx.didExceedMaxLines || !expandable) && widget.maxLines != null) {
          stackChildren.add(Positioned(
              child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${expandable ? "\u2026" : ""}", style: textStyle),
                      InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          child: Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              "  $linkText",
                              style: linkTextStyle,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              expandable = !expandable;
                            });
                          })
                    ],
                  ),
                  color: Colors.transparent),
              bottom: 0.0,
              right: 0.0));
        }

        return Stack(children: stackChildren);
      },
    );
  }

  TextSpan _buildLinkTextSpan(String text) {
    return TextSpan(
        text: text,
        style: linkTextStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launch(text);
          });
  }
}

class ReadMoreClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  ReadMoreClipper({this.width, this.height});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height - this.height);
    path.lineTo(size.width - this.width, size.height - this.height);
    path.lineTo(size.width - this.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ReadMoreClipper oldClipper) => false;
}
