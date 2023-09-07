/*
 * File: gnk_editor.dart
 * Project: src
 * -----
 * Created Date: Wednesday September 6th 2023
 * Author: Sony Sum
 * -----
 * Copyright (c) 2023 ERROR-DEV All rights reserved.
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';
import 'package:mention_popup/mentionable_text_field.dart';
import 'package:mention_popup/src/keep_popup/with_keep_keyboard_popup_menu.dart';

/// Home page.
class GnkEditor extends StatefulWidget {
  /// default constructor.
  const GnkEditor({
    super.key,
    required this.mentionList,
    required this.onControllerReady,
    this.onDetectMention,
    this.decoration,
    this.focusNode,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.maxLines,
    this.minLines,
    this.autocorrect = true,
    this.obscureText = false,
  });

  /// Page title.
  final FutureOr<List<Mentionable>> Function(String) mentionList;

  /// The focus node used by the [TextField].
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final bool autocorrect;

  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;

  final ValueChanged<MentionTextEditingController>? onControllerReady;
  final void Function(String)? onDetectMention;

  @override
  State<GnkEditor> createState() => _GnkEditorState();
}

class _GnkEditorState extends State<GnkEditor>
    with SingleTickerProviderStateMixin {
  late MentionTextEditingController _textFieldController;

  var _mentionList = List<Mentionable>.empty().obs;

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
      title: Text(mention.displayTitle),
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
            return Obx(
              () => MentionPopup(
                closePopup: closePopup,
                list: _mentionList.value,
                builder: (p0, index, mention) =>
                    _mentionCell(mention, closePopup),
              ),
            );
          },
          childBuilder: ((context, openPopup) {
            _openPopup = openPopup;
            return MentionableTextField(
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              decoration: widget.decoration,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              autocorrect: widget.autocorrect,
              obscureText: widget.obscureText,
              onControllerReady: (value) {
                _textFieldController = value;
                widget.onControllerReady!(value);
                _textFieldController.onTextChange = widget.onChanged;
              },
              onSubmitted: print,
              mentionables: _mentionList,
              onMentionablesChanged: (mention) async {
                if (widget.onDetectMention != null) {
                  widget.onDetectMention!(mention);
                }
                _mentionList(await widget.mentionList(mention));
                if (mention.trim().isEmpty || _mentionList.isEmpty) {
                  _closePopup!.call();
                } else {
                  _openPopup!.call();
                }
              },
            );
          }),
        ),
      ),
    );
  }
}
