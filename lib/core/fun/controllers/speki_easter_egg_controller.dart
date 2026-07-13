import 'package:flutter/foundation.dart';

/// 로그인 로고의 숨겨진 Speki 이스터에그를 제어합니다.
class SpekiEasterEggController extends ChangeNotifier {
  SpekiEasterEggController({this.unlockTapCount = 5});

  final int unlockTapCount;

  int _logoTapCount = 0;
  int _dropSequence = 0;

  bool get isUnlocked => _logoTapCount >= unlockTapCount;
  int get dropSequence => _dropSequence;

  /// 잠금 해제 전에는 탭 횟수를 세고, 해제 후에는 낙하를 요청합니다.
  void handleLogoTap() {
    if (!isUnlocked) {
      _logoTapCount += 1;
      notifyListeners();
      return;
    }

    _dropSequence += 1;
    notifyListeners();
  }
}
