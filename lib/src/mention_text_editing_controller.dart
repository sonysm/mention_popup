part of 'mentionable_text_field.dart';

///
/// A [TextEditingController] that displays the mentions
/// with a specific style using [_mentionStyle].
/// Mentions are stored in controller
/// as an unique character [escapingMentionCharacter].
/// Internally, [value] contains only [escapingMentionCharacter],
/// but the user will see mentions.
/// To get the real content of the text field
/// use [buildMentionedValue].
///
class MentionTextEditingController extends TextEditingController {
  /// default constructor.
  MentionTextEditingController({
    required MentionablesChangedCallback onMentionablesChanged,
    this.escapingMentionCharacter = Constants.escapingMentionCharacter,
    this.onTextChange,
    TextStyle? mentionStyle,
  })  : _onMentionablesChanged = onMentionablesChanged,
        _storedMentionables = [],
        _mentionStyle = mentionStyle ??
            const TextStyle(
              color: Color.fromRGBO(22, 74, 159, 1),
              fontWeight: FontWeight.w500,
            );

  /// Character that is excluded from keyboard
  /// to replace the mentions (not visible to users).
  final String escapingMentionCharacter;

  /// [TextStyle] applied to mentionables in Text Field.
  final TextStyle _mentionStyle;

  /// List of [Mentionable] present in the [TextField].
  /// Order of elements is the same as in the [TextField].
  final List<Mentionable> _storedMentionables;
  final MentionablesChangedCallback _onMentionablesChanged;

  ValueChanged<String>? onTextChange;

  List<Mentionable> get mentionList => _storedMentionables;

  @override
  set text(newValue) {
    var p1 = "<span>";
    var p2 = "</span>";
    var replace = RegExp('(?=$p1\\S+)|(?<=$p2)');
    var content = newValue;
    content = content.split(replace).map((e) {
      if (e.startsWith('<span>') && e.endsWith('</span>')) {
        return escapingMentionCharacter;
      }
      return e;
    }).join();
    super.text = content;
  }

  set mentionList(List<Mentionable> list) {
    _storedMentionables.addAll(list);
  }

  String? _getMentionCandidate(String value) {
    const mentionCharacter = Constants.mentionCharacter;
    final indexCursor = selection.base.offset;
    var indexAt =
        value.substring(0, indexCursor).reversed.indexOf(mentionCharacter);
    if (indexAt != -1) {
      if (value.length == 1) return mentionCharacter;
      indexAt = indexCursor - indexAt;
      if (indexAt != -1 && indexAt >= 0 && indexAt <= indexCursor) {
        return value.substring(indexAt - 1, indexCursor);
      }
    }
    return null;
  }

  Queue<Mentionable> _mentionQueue() =>
      Queue<Mentionable>.from(_storedMentionables);

  void _addMention(String candidate, Mentionable mentionable) {
    final indexSelection = selection.base.offset;
    final textPart = text.substring(0, indexSelection);
    final indexInsertion = textPart.countChar(escapingMentionCharacter);
    _storedMentionables.insert(indexInsertion, mentionable);
    text = '${text.replaceAll(candidate, escapingMentionCharacter)} ';
    selection =
        TextSelection.collapsed(offset: indexSelection - candidate.length + 2);

    /// just make trigger to on change text field
    if (onTextChange != null) {
      onTextChange!(text);
    }
  }

  void onFieldChanged(
    String value,
    List<Mentionable> mentionables,
  ) {
    final candidate = _getMentionCandidate(value);
    if (candidate != null) {
      final isMentioningRegexp = RegExp(r'^@[a-zA-Z ]*$');
      final mention = isMentioningRegexp.stringMatch(candidate)?.substring(1);
      if (mention != null) {
        _onMentionablesChanged(mention);
      }
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final regexp = RegExp(
        '(?=$escapingMentionCharacter)|(?<=$escapingMentionCharacter)|(?=#\\S+)|(?<=\\s+)');
    // split result on "Hello ∞ where is ∞?" is: [Hello,∞, where is ,∞,?]
    final res = text.split(regexp);
    final mentionQueue = _mentionQueue();
    return TextSpan(
      style: style,
      children: res.map((e) {
        if (e == escapingMentionCharacter && mentionQueue.isNotEmpty) {
          final mention = mentionQueue.removeFirst();
          // Mandatory WidgetSpan so that it takes the appropriate char number.
          return WidgetSpan(
            child: Text(
              mention.mentionLabel,
              style: _mentionStyle.copyWith(fontSize: 16),
            ),
          );
        }

        if (e.startsWith('#')) {
          return WidgetSpan(child: Text(e, style: _mentionStyle));
        }

        return SocialTextSpanBuilder(
          regularExpressions: {
            DetectedType.hashtag: hashTagRegExp,
            DetectedType.url: urlRegex,
          },
          detectionTextStyles: {
            DetectedType.hashtag: _mentionStyle,
            DetectedType.url: _mentionStyle,
          },
          defaultTextStyle: null,
        ).build(e);
      }).toList(),
    );
  }

  /// Add the mention to this controller.
  /// [_onMentionablesChanged] is called with empty list,
  /// yet there are no candidates anymore.
  void pickMentionable(Mentionable mentionable) {
    final candidate = _getMentionCandidate(text);
    if (candidate != null) {
      _addMention(candidate, mentionable);
    }
  }

  /// Get the real value of the field with the mentions transformed
  /// thanks to [Mentionable.buildMention].
  String buildMentionedValue() {
    final mentionQueue = _mentionQueue();
    return text.replaceAllMapped(
      escapingMentionCharacter,
      (_) => mentionQueue.removeFirst().buildMention(),
    );
  }
}
