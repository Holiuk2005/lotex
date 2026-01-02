import 'package:flutter/material.dart';
import '../theme/lotex_ui_tokens.dart';

class AuctionTimerBadge extends StatelessWidget {
  final DateTime endDate;
  final bool compact;

  const AuctionTimerBadge({
    super.key,
    required this.endDate,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeLeft = endDate.difference(now);
    final isFinished = timeLeft.isNegative;
    final isUrgent = !isFinished && timeLeft.inMinutes < 5;

    String text;
    if (isFinished) {
      text = 'Завершено';
    } else if (timeLeft.inDays > 0) {
      text = '${timeLeft.inDays} дн.';
    } else {
      final hh = timeLeft.inHours;
      final mm = (timeLeft.inMinutes % 60).toString().padLeft(2, '0');
      text = '$hh:$mm';
    }

    final Color fg = isUrgent ? LotexUiColors.error : LotexUiColors.neonOrange;
    final Color bg = fg.withAlpha((0.12 * 255).round());

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withAlpha((0.25 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded,
              size: compact ? 14 : 16, color: fg),
          SizedBox(width: compact ? 4 : 6),
          Text(
            text,
            style: LotexUiTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
