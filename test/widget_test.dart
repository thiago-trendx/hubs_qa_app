import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hubs_qa_app/main.dart';

void main() {
  testWidgets('Write-data screen shows all four tabs and the métrica form by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HubsQaApp());
    await tester.pump();

    expect(find.text('Escrever dado de teste'), findsOneWidget);
    expect(find.text('Métrica'), findsWidgets);
    expect(find.text('Sono'), findsOneWidget);
    expect(find.text('Treino'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);

    // Métrica tab (default) content.
    expect(find.text('Valor'), findsOneWidget);
    expect(find.text('Escrever no hub'), findsOneWidget);
    expect(find.byIcon(Icons.save_alt), findsOneWidget);
  });

  testWidgets('Histórico tab shows the empty state before any write', (WidgetTester tester) async {
    await tester.pumpWidget(const HubsQaApp());
    await tester.pump();

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma escrita ainda.'), findsOneWidget);
  });
}
