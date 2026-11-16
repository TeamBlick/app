import 'package:blick/core/config/student_repositories.dart';
import 'package:blick/features/bus/data/repositories/bus_repository.dart';
import 'package:blick/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('오프라인 학생은 미탑승을 신청하고 버스를 신청·변경하고 공지를 읽는다', (tester) async {
    final repositories = StudentRepositories.fake(delay: Duration.zero);
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repositories: repositories)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('미탑승').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '동아리 행사');
    await tester.tap(find.text('신청'));
    await tester.pumpAndSettle();
    expect(find.text('미탑승을 신청했습니다.'), findsOneWidget);
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      '미탑승',
    );

    Future<void> selectTab(int index) async {
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .onTap!(index);
      await tester.pumpAndSettle();
    }

    Future<void> selectBus(String label) async {
      await tester.tap(find.byType(DropdownButton<BusOption>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    await selectTab(1);
    await selectBus('1호차 용산역');
    await tester.tap(find.widgetWithText(FilledButton, '버스 신청'));
    await tester.pumpAndSettle();
    expect(find.text('신청한 버스: 1호차 용산역'), findsOneWidget);

    await selectBus('2호차 대곡역');
    await tester.tap(find.widgetWithText(FilledButton, '버스 변경'));
    await tester.pumpAndSettle();
    expect(find.text('신청한 버스: 2호차 대곡역'), findsOneWidget);

    await selectTab(3);
    expect(find.text('안 읽음'), findsNWidgets(2));
    await tester.tap(find.text('귀가버스 운행 안내'));
    await tester.pumpAndSettle();
    expect(find.textContaining('학교 정문 앞에 모여주세요'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('안 읽음'), findsOneWidget);

    await selectTab(0);
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      '미탑승',
    );
    await tester.tap(find.text('탑승').first);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      '탑승',
    );
  });
}
