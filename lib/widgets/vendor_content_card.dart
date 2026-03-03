// lib/widgets/vendor_content_card.dart
import 'package:flutter/material.dart';

import '../../core/models/vendor_content.dart';
import '../../core/theme/app_colors.dart';

class VendorContentTile extends StatelessWidget {
  final VendorContent content;
  final VoidCallback? onTap;

  const VendorContentTile({super.key, required this.content, this.onTap});

  // Helper function to determine the icon based on content type
  IconData _getIconForContentType(String type) {
    switch (type) {
      case 'studio':
        // You might want a different icon for studios if 'category' is the focus
        return Icons.camera_indoor; // Example icon for studio
      case 'shop':
        return Icons.shopping_cart;
      case 'rate':
        return Icons.attach_money;
      case 'staff':
        return Icons.person;
      case 'schedule':
        return Icons.calendar_today;
      default:
        return Icons.category; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForContentType(content.type),
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display the category from subtitle for studio type
                  if (content.type == 'studio' && content.subtitle != null)
                    Text(
                      content.subtitle!
                          .toUpperCase(), // Displaying "CAMERA SHOP" or "EQUIPMENT"
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  // Fallback for other types or if studio subtitle is null
                  if (content.type != 'studio' || content.subtitle == null)
                    Text(
                      content.type.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    content.title, // Displaying "name" or "hike"
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Display price if available
                  if (content.price != null)
                    Text(
                      "₹ ${content.price}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  // Display subtitle if available and not a studio category
                  if (content.subtitle != null &&
                      content.price == null &&
                      content.type != 'studio')
                    Text(
                      content.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
