import 'package:flutter/material.dart';
import '../models/government_scheme.dart';
import '../utils/app_colors.dart';

class SchemeCard extends StatelessWidget {
  final GovernmentScheme scheme;
  final VoidCallback? onTap;

  const SchemeCard({Key? key, required this.scheme, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(scheme.category),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      scheme.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                scheme.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                scheme.fullName,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                scheme.description,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: AppColors.primaryGreen,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scheme.benefits,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Financial Support':
        return AppColors.primaryGreen;
      case 'Insurance':
        return AppColors.accentBlue;
      case 'Credit':
        return AppColors.accentOrange;
      case 'Infrastructure':
        return Colors.purple;
      case 'Market Access':
        return Colors.teal;
      default:
        return AppColors.primaryGreen;
    }
  }
}
