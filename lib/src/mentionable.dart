part of 'mentionable_text_field.dart';

/// A mentionable object.
@immutable
abstract class Mentionable {
  /// default constructor.
  const Mentionable();

  String get displayTitle;

  /// Text that will be input after @ character in
  /// [TextField] to show mention.
  String get mentionLabel;

  String get avatar;

  /// Way to render mention as a String in
  /// the TextField final result.
  String buildMention() => mentionLabel;

  /// Return true when [search] match the mentionable.
  bool match(String search) =>
      mentionLabel.toLowerCase().contains(search.toLowerCase());
}
