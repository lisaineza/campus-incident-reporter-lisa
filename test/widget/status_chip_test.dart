import 'package:campus_incident_reporter/core/theme/status_style.dart';
import 'package:campus_incident_reporter/models/incident_status.dart';
import 'package:campus_incident_reporter/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final status in IncidentStatus.values) {
    testWidgets('shows the ${status.label} label in its colour', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Center(child: StatusChip(status: status))),
      ));

      final text = tester.widget<Text>(find.text(status.label));
      expect(text.style?.color, StatusStyle.of(status).foreground);
    });
  }
}
