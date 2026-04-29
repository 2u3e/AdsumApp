import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/epm_models.dart';
import '../services/epm_permit_client.dart';

/// Saha ekiplerinin BMS work içinden açtığı kazı ruhsatı detay ekranı.
/// EPM iş tipi (Keşif/Denetim/Geçici Kabul/Kesin Kabul) ile açılmış
/// BMS work'ten permitId ile çağrılır.
class EpmPermitDetailScreen extends ConsumerWidget {
  const EpmPermitDetailScreen({super.key, required this.permitId, required this.inspectionType});

  final String permitId;
  final int inspectionType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.read(epmPermitClientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kazı Ruhsatı')),
      body: FutureBuilder<EpmPermitDetail>(
        future: client.getPermit(permitId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final permit = snapshot.data!;
          return _PermitDetailContent(permit: permit, inspectionType: inspectionType);
        },
      ),
    );
  }
}

class _PermitDetailContent extends StatelessWidget {
  const _PermitDetailContent({required this.permit, required this.inspectionType});

  final EpmPermitDetail permit;
  final int inspectionType;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(permit.permitCode,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(permit.agencyName ?? '—', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _Row(label: 'Başlık', value: permit.title),
          if (permit.description != null) _Row(label: 'Açıklama', value: permit.description!),
          if (permit.streetNote != null) _Row(label: 'Adres', value: permit.streetNote!),
          _Row(label: 'Planlanan', value: '${_fmt(permit.plannedStartDate)} → ${_fmt(permit.plannedEndDate)}'),
          _Row(label: 'Beyan Alan', value: '${permit.declaredAreaSqM.toStringAsFixed(2)} m²'),
          _Row(label: 'Statü', value: 'StatusId=${permit.statusId}'),
          if (permit.isEmergency)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Chip(
                label: Text('ACİL KAZI'),
                backgroundColor: Color(0xFFFEE2E2),
                labelStyle: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold),
              ),
            ),
          const Divider(height: 32),
          // Denetim ekranına geçiş
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              '/epm-inspection',
              arguments: {
                'permitId': permit.id,
                'inspectionType': inspectionType,
              },
            ),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Denetim Tutanağı Doldur'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saha denetim ekranı (dinamik checklist + foto + GPS + ölçüm + imza pad) '
            'gelecek sohbette tamamlanacak. REST endpoint /Epm/Inspections çalışır durumda.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
