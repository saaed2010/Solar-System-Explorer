import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/screens/intro_screen.dart';

void main() {
  tearDown(IntroSession.reset);

  test('cinematic intro is consumed once per app process', () {
    IntroSession.reset();

    expect(IntroSession.consume(), isTrue);
    expect(IntroSession.consume(), isFalse);
    expect(IntroSession.consume(), isFalse);
  });

  test('a new process session is eligible for the intro again', () {
    IntroSession.consume();
    IntroSession.reset();

    expect(IntroSession.consume(), isTrue);
  });
}
