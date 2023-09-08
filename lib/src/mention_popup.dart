/*
 * File: mention_popup.dart
 * Project: src
 * -----
 * Created Date: Wednesday September 6th 2023
 * Author: Sony Sum
 * -----
 * Copyright (c) 2023 ERROR-DEV All rights reserved.
 */
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mention_popup/mentionable_text_field.dart';

class MentionPopup extends StatelessWidget {
  const MentionPopup(
      {this.list = const [],
      required this.builder,
      required this.closePopup,
      super.key});

  final Future<void> Function() closePopup;
  final List<Mentionable> list;
  final Widget Function(BuildContext, int index, Mentionable user) builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: min(45.0 * list.length, 200),
      constraints: BoxConstraints(maxHeight: 200, maxWidth: 320),
      decoration: BoxDecoration(),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: list.length,
        separatorBuilder: (context, index) => Material(
          child: Divider(height: 0.0, color: Colors.grey.shade100),
        ),
        itemBuilder: (context, index) => builder(context, index, list[index]),
      ),
    );
  }
}
