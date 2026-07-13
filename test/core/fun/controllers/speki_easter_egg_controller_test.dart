import 'package:blick/core/fun/controllers/speki_easter_egg_controller.dart';
import 'package:blick/core/fun/widgets/speki_easter_egg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('다섯 번 탭하면 잠금 해제되고 다음 탭부터 낙하를 요청한다', () {
    final controller = SpekiEasterEggController();

    for (var index = 0; index < 5; index += 1) {
      controller.handleLogoTap();
    }

    expect(controller.isUnlocked, isTrue);
    expect(controller.dropSequence, 0);

    controller.handleLogoTap();
    expect(controller.dropSequence, 1);
  });

  testWidgets('여섯 번째 로고 탭에 Speki가 화면에 생성된다', (tester) async {
    final controller = SpekiEasterEggController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpekiEasterEgg(
            controller: controller,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    for (var index = 0; index < 6; index += 1) {
      controller.handleLogoTap();
    }
    await tester.pump();

    expect(find.byKey(const ValueKey(0)), findsOneWidget);
  });

  testWidgets('화면을 다 채우면 폭발 후 모두 사라진다', (tester) async {
    final controller = SpekiEasterEggController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 216,
              height: 216,
              child: SpekiEasterEgg(
                controller: controller,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );

    for (var index = 0; index < 5; index += 1) {
      controller.handleLogoTap();
    }
    for (var index = 0; index < 16; index += 1) {
      controller.handleLogoTap();
    }
    await tester.pump();
    expect(find.byType(Image), findsNWidgets(16));

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(Image), findsNothing);
  });
}
