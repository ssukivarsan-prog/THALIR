import 'package:flutter/material.dart';
import '../app_theme.dart';

class RiskBadge extends StatelessWidget {
  final String riskLabel; // "high", "medium", "low"
  final double? riskScore;
  final bool showScore;

  const RiskBadge({
    super.key,
    required this.riskLabel,
    this.riskScore,
    this.showScore = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    IconData icon;

    switch (riskLabel.toLowerCase()) {
      case 'high':
        bg = AppTheme.riskHighBg;
        text = AppTheme.riskHighText;
        border = AppTheme.riskHighBorder;
        icon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        bg = AppTheme.riskMediumBg;
        text = AppTheme.riskMediumText;
        border = AppTheme.riskMediumBorder;
        icon = Icons.info_outline_rounded;
        break;
      case 'low':
      default:
        bg = AppTheme.riskLowBg;
        text = AppTheme.riskLowText;
        border = AppTheme.riskLowBorder;
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    final labelText = riskLabel.toUpperCase();
    final scoreStr = riskScore != null ? ' (${(riskScore! * 100).toStringAsFixed(0)}%)' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 5),
          Text(
            showScore ? '$labelText RISK$scoreStr' : '$labelText RISK',
            style: TextStyle(
              color: text,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
