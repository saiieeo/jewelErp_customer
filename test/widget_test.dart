import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jewel_app/main.dart';

void main() {
  test('JewelApp widget can be instantiated', () {
    const app = JewelApp();
    expect(app, isA<StatelessWidget>());
  });
}
