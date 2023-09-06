/*
 * File: gnk_editor.dart
 * Project: src
 * -----
 * Created Date: Wednesday September 6th 2023
 * Author: Sony Sum
 * -----
 * Copyright (c) 2023 ERROR-DEV All rights reserved.
 */
import 'package:flutter/material.dart';
import 'package:mention_popup/mentionable_text_field.dart';
import 'package:mention_popup/src/keep_popup/with_keep_keyboard_popup_menu.dart';

/// Home page.
class GnkEditor extends StatefulWidget {
  /// default constructor.
  const GnkEditor({super.key, required this.mentionList});

  /// Page title.
  final List<Mentionable> mentionList;

  @override
  State<GnkEditor> createState() => _GnkEditorState();
}

class _GnkEditorState extends State<GnkEditor>
    with SingleTickerProviderStateMixin {
  late MentionTextEditingController _textFieldController;
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Offset _updateCaretOffset(String text) {
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text),
    );
    painter.layout();

    var cursorTextPosition = _textFieldController.selection.base;
    var caretPrototype = Rect.fromLTWH(0.0, 0.0, 0, 0);
    var caretOffset =
        painter.getOffsetForCaret(cursorTextPosition, caretPrototype);

    var xCaret = caretOffset.dx;
    var yCaret = caretOffset.dy;

    return Offset(xCaret, yCaret);
  }

  Future<void> Function()? _openPopup;
  Future<void> Function()? _closePopup;

  Widget _mentionCell(Mentionable mention, Future<void> Function() closePopup) {
    return ListTile(
      dense: true,
      horizontalTitleGap: 8,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(mention.avatar),
      ),
      title: Text(mention.mentionLabel),
      onTap: () {
        _textFieldController.pickMentionable(mention);
        closePopup.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(13),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: WithKeepKeyboardPopupMenu(
          calculatePopupPosition: (menuSize, overlayRect, buttonRect) {
            var bottomCenter = buttonRect.bottomCenter;
            return Offset((buttonRect.width / 2) - 125, bottomCenter.dy);
          },
          backgroundBuilder: (context, child) => Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
          menuBuilder: (context, closePopup) {
            _closePopup = closePopup;
            return MentionPopup(
              closePopup: closePopup,
              list: widget.mentionList,
              builder: (p0, index, mention) =>
                  _mentionCell(mention, closePopup),
            );
          },
          childBuilder: ((context, openPopup) {
            _openPopup = openPopup;
            return MentionableTextField(
              focusNode: _node,
              onControllerReady: (value) => _textFieldController = value,
              onSubmitted: print,
              mentionables: widget.mentionList,
              onMentionablesChanged: (mentionables) {
                if (mentionables.isEmpty) {
                  _closePopup!.call();
                } else {
                  _openPopup!.call();
                }
              },
              decoration: const InputDecoration(
                // icon: Icon(Icons.alternate_email),
                hintText: 'Type @ to trigger mention',
                border: InputBorder.none,
              ),
            );
          }),
        ),
      ),
    );
  }
}
