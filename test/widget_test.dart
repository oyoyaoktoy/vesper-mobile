import 'package:flutter_test/flutter_test.dart';

import 'package:vesper_mobile/app/app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const VesperApp());
  });
}