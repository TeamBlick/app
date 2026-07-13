import 'package:flutter/foundation.dart';

@immutable
class FallingSpeki {
  const FallingSpeki({
    required this.id,
    required this.column,
    required this.row,
    required this.fallDuration,
    required this.rotation,
  });

  final int id;
  final int column;
  final int row;
  final Duration fallDuration;
  final double rotation;
}
