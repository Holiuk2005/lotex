import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';

import '../trips/widgets/trip_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  List<TripModel> _dummyTrips() {
    return const [
      TripModel(
        id: 't1',
        origin: 'Київ',
        destination: 'Львів',
        time: '14:30',
        date: '25 Жовт',
        status: 'В дорозі',
        price: 3200,
        clientName: 'Олександр К.',
      ),
      TripModel(
        id: 't2',
        origin: 'Одеса',
        destination: 'Дніпро',
        time: '09:10',
        date: '26 Жовт',
        status: 'Заплановано',
        price: 2800,
        clientName: 'Марія С.',
      ),
      TripModel(
        id: 't3',
        origin: 'Харків',
        destination: 'Полтава',
        time: '18:05',
        date: '26 Жовт',
        status: 'В дорозі',
        price: 1500,
        clientName: 'Іван П.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trips = _dummyTrips();
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        title: Text(
          'Дашборд',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: primary),
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _QuickActionButton(
                onPressed: () {
                  // Заглушка: тут буде створення поїздки
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Створення поїздки — в розробці')),
                  );
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      icon: Icons.directions_car_rounded,
                      iconColor: primary,
                      label: 'Активні поїздки',
                      value: '3',
                      valueColor: primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _AnalyticsCard(
                      icon: Icons.payments_rounded,
                      iconColor: Color(0xFF16A34A),
                      label: 'Зароблено сьогодні',
                      value: '₴ 4,500',
                      valueColor: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Поточні поїздки',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  return TripCard(
                    trip: trips[index],
                    onTap: () {
                      // Заглушка
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Деталі: ${trips[index].origin} → ${trips[index].destination}')),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _QuickActionButton({required this.onPressed});

  static const Color _accent = Color(0xFFF5A623);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Створити нову поїздку',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 1,
        ),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;

  const _AnalyticsCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final tileBg = Theme.of(context).scaffoldBackgroundColor;
    final muted = Theme.of(context).brightness == Brightness.dark
        ? LotexUiColors.darkMuted
        : LotexUiColors.lightMuted;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: valueColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
