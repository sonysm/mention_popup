import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:mentionable_text_field/mentionable_text_field.dart';
import 'package:mentionable_text_field_example/my_user.dart';
import 'package:rxdart/subjects.dart';

void main() {
  runApp(const MyApp());
}

/// App widget that shows mentionable_text_field example implementation.
class MyApp extends StatelessWidget {
  ///
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Mentionable text field Demo';
    return const MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      home: Portal(child: MyHomePage(title: title)),
    );
  }
}

/// Home page.
class MyHomePage extends StatefulWidget {
  /// default constructor.
  const MyHomePage({super.key, required this.title});

  /// Page title.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final BehaviorSubject<List<Mentionable>> _mentionableStreamController =
      BehaviorSubject.seeded([]);
  late final _animationController = AnimationController(vsync: this);
  late MentionTextEditingController _textFieldController;
  final _resultStreamController = StreamController<String>();
  final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _mentionableStreamController.stream.listen((mention) {});
  }

  @override
  void dispose() {
    _mentionableStreamController.close();
    _animationController.dispose();
    _resultStreamController.close();
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

  @override
  Widget build(BuildContext context) {
    String image =
        'https://fastly.picsum.photos/id/570/200/200.jpg?hmac=fgqmD9u8TqyXJG9fhqV-EbhIUXYwTIxfsPiNfaD28_Y';
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          child: GnkEditor(
            onControllerReady: (c) {},
            mentionList: [
              MyUser('jonh', image),
              MyUser('doh', image),
              MyUser('albert', image),
              MyUser('devid', image),
            ],
          ),
        ));
  }
}
