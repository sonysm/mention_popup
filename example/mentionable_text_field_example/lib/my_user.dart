import 'package:mention_popup/mentionable_text_field.dart';

/// Example implementation of [Mentionable].
class MyUser extends Mentionable {
  /// default constructor.
  const MyUser(this.mentionLabel, this.avatar);

  /// Label of user.
  @override
  final String mentionLabel;

  @override
  final String avatar;

  @override
  String buildMention() => '<my-custom-tag>$mentionLabel</my-custom-tag>';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyUser &&
          runtimeType == other.runtimeType &&
          mentionLabel == other.mentionLabel;

  @override
  int get hashCode => mentionLabel.hashCode;

  @override
  String get displayTitle => 'my user name';
}
