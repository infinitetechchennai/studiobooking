import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  RangeValues _priceRange = const RangeValues(20, 100);
  String _selectedCategory = 'Sports';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Sports', 'icon': Icons.sports_basketball, 'color': Colors.red},
    {'name': 'Music', 'icon': Icons.music_note, 'color': Colors.orange},
    {'name': 'Art', 'icon': Icons.palette, 'color': Colors.blue},
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['name']),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.grey3),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.primary.withAlpha(76), blurRadius: 10, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Icon(cat['icon'], color: isSelected ? Colors.white : AppColors.grey2),
                        ),
                        const SizedBox(height: 8),
                        Text(cat['name'], style: TextStyle(color: isSelected ? AppColors.primary : AppColors.grey2, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text('Time & Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDateChip('Today', false),
                const SizedBox(width: 12),
                _buildDateChip('Tomorrow', true),
                const SizedBox(width: 12),
                _buildDateChip('This Week', false),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text('Choose from calendar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey2),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Text('New York, USA', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Price Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 200,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.grey3,
              onChanged: (values) => setState(() => _priceRange = values),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _priceRange = const RangeValues(20, 100);
                  _selectedCategory = 'Sports';
                }),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 58),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('RESET', style: TextStyle(color: AppColors.grey1)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('APPLY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey3),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : AppColors.grey2, fontWeight: FontWeight.w500),
      ),
    );
  }
}
