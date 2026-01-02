import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';

class TripModel {
  final String id;
  final String origin;
  final String destination;
  final String time;
  final String date;
  final String status;
  final int price;
  final String clientName;

  const TripModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.time,
    required this.date,
    required this.status,
    required this.price,
    required this.clientName,
  });
}

class TripCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimeColumn(time: trip.time, date: trip.date),
              const SizedBox(width: 12),
              Expanded(
                child: _RouteColumn(
                  origin: trip.origin,
                  destination: trip.destination,
                  clientName: trip.clientName,
                ),
              ),
              const SizedBox(width: 12),
              _RightColumn(status: trip.status, price: trip.price),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String time;
  final String date;

  const _TimeColumn({required this.time, required this.date});

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).brightness == Brightness.dark
      ? LotexUiColors.darkTitle
      : LotexUiColors.lightTitle;
    final muted = Theme.of(context).brightness == Brightness.dark
      ? LotexUiColors.darkMuted
      : LotexUiColors.lightMuted;

    return SizedBox(
      width: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: title,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteColumn extends StatelessWidget {
  final String origin;
  final String destination;
  final String clientName;

  const _RouteColumn({
    required this.origin,
    required this.destination,
    required this.clientName,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
      ? LotexUiColors.darkMuted
      : LotexUiColors.lightMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RouteVisual(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlaceRow(icon: Icons.location_on_rounded, text: origin),
                  const SizedBox(height: 10),
                  _PlaceRow(icon: Icons.location_on_rounded, text: destination),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          clientName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
      ],
    );
  }
}

class _PlaceRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlaceRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).brightness == Brightness.dark
      ? LotexUiColors.darkTitle
      : LotexUiColors.lightTitle;
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(icon, size: 18, color: primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: title,
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteVisual extends StatelessWidget {
  const _RouteVisual();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 18,
      child: Column(
        children: [
          Icon(Icons.radio_button_checked, size: 10, color: primary),
          const SizedBox(height: 3),
          _DottedLine(height: 22, color: primary),
          const SizedBox(height: 3),
          Icon(Icons.location_on_rounded, size: 12, color: primary),
        ],
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  const _DottedLine({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _DottedLinePainter(color: color),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  const _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dash = 4.0;
    const gap = 3.0;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, (y + dash).clamp(0, size.height)), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) => oldDelegate.color != color;
}

class _RightColumn extends StatelessWidget {
  final String status;
  final int price;

  const _RightColumn({required this.status, required this.price});

  bool get _isInProgress => status.toLowerCase().contains('дороз') || status.toLowerCase().contains('в процес');

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).brightness == Brightness.dark
      ? LotexUiColors.darkTitle
      : LotexUiColors.lightTitle;
    final badgeBg = _isInProgress
      ? Theme.of(context).colorScheme.secondary
      : Theme.of(context).dividerColor.withAlpha((0.35 * 255).round());
    final badgeFg = _isInProgress ? Colors.white : title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeFg,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '₴ ${_formatPrice(price)}',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: title,
          ),
        ),
      ],
    );
  }

  static String _formatPrice(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final reverseIndex = s.length - i;
      buffer.write(s[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }
}
