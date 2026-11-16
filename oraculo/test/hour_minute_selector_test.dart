import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oraculo/widgets/hour_minute_picker.dart';

void main() {
  Widget buildTestableWidget({
    String? initialTime,
    required ValueChanged<String?> onTimeChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: HourMinuteSelector(
            initialTime: initialTime,
            onTimeChanged: onTimeChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('HourMinuteSelector inicializa sem horário quando initialTime é nulo',
      (WidgetTester tester) async {
    String? changedTime;

    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: null,
        onTimeChanged: (val) => changedTime = val,
      ),
    );

    expect(find.text('Horário (Hora e Minuto):'), findsOneWidget);
    expect(find.text('Hora (--)'), findsOneWidget);
    expect(find.text('Minuto (--)'), findsOneWidget);
    expect(find.byKey(const Key('clock_picker_button')), findsOneWidget);
    expect(find.byKey(const Key('clear_time_button')), findsNothing);
    expect(changedTime, isNull);
  });

  testWidgets('HourMinuteSelector inicializa com horário quando initialTime é fornecido',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: '15:45',
        onTimeChanged: (_) {},
      ),
    );

    expect(find.text('Horário: 15:45'), findsOneWidget);
    expect(find.text('15 h'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.byKey(const Key('clear_time_button')), findsOneWidget);
  });

  testWidgets('Selecionar hora no dropdown atualiza horário e notifica callback',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: null,
        onTimeChanged: (val) => selected = val,
      ),
    );

    // Toca no dropdown de hora
    await tester.tap(find.byKey(const Key('hour_picker_dropdown')));
    await tester.pumpAndSettle();

    // Seleciona a hora 02 h (visível no topo do menu)
    await tester.tap(find.text('02 h').last);
    await tester.pumpAndSettle();

    expect(selected, '02:00');
    expect(find.text('Horário: 02:00'), findsOneWidget);
    expect(find.text('02 h'), findsOneWidget);
    expect(find.text('00 min'), findsOneWidget);
  });

  testWidgets('Selecionar minuto no dropdown atualiza horário e notifica callback',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: '14:00',
        onTimeChanged: (val) => selected = val,
      ),
    );

    // Toca no dropdown de minuto
    await tester.tap(find.byKey(const Key('minute_picker_dropdown')));
    await tester.pumpAndSettle();

    // Seleciona o minuto 02 min (visível no topo do menu)
    await tester.tap(find.text('02 min').last);
    await tester.pumpAndSettle();

    expect(selected, '14:02');
    expect(find.text('Horário: 14:02'), findsOneWidget);
  });

  testWidgets('Atalhos de minutos (:00, :15, :30, :45) atualizam o minuto',
      (WidgetTester tester) async {
    String? selected;

    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: '09:00',
        onTimeChanged: (val) => selected = val,
      ),
    );

    // Clica no atalho :30
    await tester.tap(find.byKey(const Key('quick_minute_30')));
    await tester.pumpAndSettle();

    expect(selected, '09:30');
    expect(find.text('Horário: 09:30'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);

    // Clica no atalho :45
    await tester.tap(find.byKey(const Key('quick_minute_45')));
    await tester.pumpAndSettle();

    expect(selected, '09:45');
    expect(find.text('Horário: 09:45'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
  });

  testWidgets('Botão Limpar (X) reseta o horário para nulo',
      (WidgetTester tester) async {
    String? selected = '20:15';

    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: '20:15',
        onTimeChanged: (val) => selected = val,
      ),
    );

    expect(find.byKey(const Key('clear_time_button')), findsOneWidget);

    // Toca no botão de limpar
    await tester.tap(find.byKey(const Key('clear_time_button')));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text('Horário (Hora e Minuto):'), findsOneWidget);
    expect(find.byKey(const Key('clear_time_button')), findsNothing);
  });

  testWidgets('Botão Relógio abre o TimePicker dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        initialTime: '11:20',
        onTimeChanged: (_) {},
      ),
    );

    await tester.tap(find.byKey(const Key('clock_picker_button')));
    await tester.pumpAndSettle();

    // Dialog do TimePicker aberto
    expect(find.text('SELECIONE O HORÁRIO DO EVENTO'), findsOneWidget);
    expect(find.text('CONFIRMAR'), findsOneWidget);
    expect(find.text('CANCELAR'), findsOneWidget);

    // Fecha clicando em CANCELAR
    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();

    expect(find.text('SELECIONE O HORÁRIO DO EVENTO'), findsNothing);
  });
}
