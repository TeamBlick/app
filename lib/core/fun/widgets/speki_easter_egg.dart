import 'dart:async';
import 'dart:math' as math;

import 'package:blick/core/fun/controllers/speki_easter_egg_controller.dart';
import 'package:blick/core/fun/models/falling_speki.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 화면 위에 Speki가 떨어져 쌓이는 로그인 이스터에그 레이어입니다.
class SpekiEasterEgg extends StatefulWidget {
  const SpekiEasterEgg({
    required this.controller,
    required this.child,
    super.key,
  });

  final SpekiEasterEggController controller;
  final Widget child;

  @override
  State<SpekiEasterEgg> createState() => _SpekiEasterEggState();
}

class _SpekiEasterEggState extends State<SpekiEasterEgg>
    with SingleTickerProviderStateMixin {
  static const _assetPath = 'assets/images/speki.webp';
  static const _explosionDuration = Duration(milliseconds: 720);

  final _random = math.Random();
  final List<FallingSpeki> _pieces = [];
  late final AnimationController _explosionController;

  List<int> _columnHeights = [];
  Timer? _explosionTimer;
  int _handledDropSequence = 0;
  int _nextId = 0;
  bool _isExploding = false;
  double _width = 0;
  double _height = 0;

  double get _pieceSize => (_width / 5.4).clamp(54.0, 74.0);
  int get _columnCount => math.max(1, (_width / _pieceSize).floor());
  int get _rowCount => math.max(1, (_height / _pieceSize).floor());

  @override
  void initState() {
    super.initState();
    _handledDropSequence = widget.controller.dropSequence;
    widget.controller.addListener(_handleControllerChange);
    _explosionController =
        AnimationController(vsync: this, duration: _explosionDuration)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _resetPile();
            }
          });
  }

  @override
  void didUpdateWidget(covariant SpekiEasterEgg oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_handleControllerChange);
    _handledDropSequence = widget.controller.dropSequence;
    widget.controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (!mounted || _isExploding) return;

    final requestedDrops =
        widget.controller.dropSequence - _handledDropSequence;
    if (requestedDrops <= 0) return;

    _handledDropSequence = widget.controller.dropSequence;
    for (var index = 0; index < requestedDrops; index += 1) {
      _dropSpeki();
    }
  }

  void _syncLayout(double width, double height) {
    if (_width == width && _height == height) return;

    _width = width;
    _height = height;
    if (_pieces.isEmpty) {
      _columnHeights = List.filled(_columnCount, 0);
    }
  }

  void _dropSpeki() {
    if (_width <= 0 || _height <= 0) return;
    if (_columnHeights.length != _columnCount) {
      _columnHeights = List.filled(_columnCount, 0);
    }

    final availableColumns = <int>[];
    final lowestHeight = _columnHeights.reduce(math.min);
    for (var column = 0; column < _columnHeights.length; column += 1) {
      if (_columnHeights[column] == lowestHeight) {
        availableColumns.add(column);
      }
    }

    final column = availableColumns[_random.nextInt(availableColumns.length)];
    final row = _columnHeights[column];
    if (row >= _rowCount) {
      _startExplosion();
      return;
    }

    _columnHeights[column] += 1;
    final duration = Duration(milliseconds: 620 + _random.nextInt(260));
    setState(() {
      _pieces.add(
        FallingSpeki(
          id: _nextId++,
          column: column,
          row: row,
          fallDuration: duration,
          rotation: (_random.nextDouble() - 0.5) * 0.24,
        ),
      );
    });
    HapticFeedback.selectionClick();

    if (_pieces.length >= _columnCount * _rowCount) {
      _explosionTimer?.cancel();
      _explosionTimer = Timer(
        duration + const Duration(milliseconds: 180),
        _startExplosion,
      );
    }
  }

  void _startExplosion() {
    if (!mounted || _isExploding || _pieces.isEmpty) return;
    _explosionTimer?.cancel();
    setState(() => _isExploding = true);
    HapticFeedback.heavyImpact();
    _explosionController.forward(from: 0);
  }

  void _resetPile() {
    if (!mounted) return;
    setState(() {
      _pieces.clear();
      _columnHeights = List.filled(_columnCount, 0);
      _isExploding = false;
    });
    _explosionController.reset();
  }

  @override
  void dispose() {
    _explosionTimer?.cancel();
    widget.controller.removeListener(_handleControllerChange);
    _explosionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _syncLayout(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _explosionController,
                builder: (context, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [for (final piece in _pieces) _buildPiece(piece)],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPiece(FallingSpeki piece) {
    final horizontalGap = (_width - (_columnCount * _pieceSize)) / 2;
    final left = horizontalGap + (piece.column * _pieceSize);
    final restingTop = _height - ((piece.row + 1) * _pieceSize);
    final explosion = Curves.easeIn.transform(_explosionController.value);
    final centerX = left + (_pieceSize / 2);
    final centerY = restingTop + (_pieceSize / 2);
    var directionX = centerX - (_width / 2);
    var directionY = centerY - (_height / 2);
    final distance = math.sqrt(
      (directionX * directionX) + (directionY * directionY),
    );
    if (distance > 0) {
      directionX /= distance;
      directionY /= distance;
    }

    return Positioned(
      left: left,
      top: 0,
      width: _pieceSize,
      height: _pieceSize,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(piece.id),
        duration: piece.fallDuration,
        curve: Curves.bounceOut,
        tween: Tween(begin: -_pieceSize, end: restingTop),
        builder: (context, top, child) {
          return Transform.translate(
            offset: Offset(
              directionX * _width * explosion,
              top + (directionY * _height * explosion),
            ),
            child: Transform.rotate(
              angle: piece.rotation + (explosion * piece.rotation * 12),
              child: Opacity(
                opacity: 1 - explosion,
                child: Transform.scale(
                  scale: 1 + (explosion * 0.45),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Image.asset(_assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
