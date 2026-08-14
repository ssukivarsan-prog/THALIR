import 'package:flutter/material.dart';
import '../models/dropout_prediction.dart';
import '../app_theme.dart';

class ShapFactorCard extends StatelessWidget {
  final ShapFactor factor;

  const ShapFactorCard({
    super.key,
    required this.factor,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor;
    String impactBadge;

    switch (factor.impactLevel) {
      case 'high_negative':
        barColor = AppTheme.riskHighText;
        impactBadge = 'High Negative Impact';
        break;
      case 'moderate_negative':
        barColor = AppTheme.riskMediumText;
        impactBadge = 'Moderate Negative Impact';
        break;
      case 'slight_negative':
        barColor = AppTheme.riskMediumText.withOpacity(0.7);
        impactBadge = 'Slight Negative Impact';
        break;
      case 'positive':
      default:
        barColor = AppTheme.riskLowText;
        impactBadge = 'Positive Factor';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                factor.factorName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  impactBadge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            factor.plainTextDescription,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor.weight,
              minHeight: 6,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
