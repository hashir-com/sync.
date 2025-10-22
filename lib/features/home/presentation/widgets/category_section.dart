// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final int selectedCategory;
  final Function(int) onCategoryTap;

  const CategorySection({
    super.key,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildCategoryChip(
                'Sports',
                0,
                Icons.ac_unit,
                const Color(0xFFFF6B6B),
              ),
              const SizedBox(width: 12),
              _buildCategoryChip(
                'Music',
                1,
                Icons.music_note,
                const Color(0xFFFF9066),
              ),
              const SizedBox(width: 12),
              _buildCategoryChip(
                'Food',
                2,
                Icons.restaurant,
                const Color(0xFF00D9A5),
              ),
              const SizedBox(width: 12),
              _buildCategoryChip(
                'Tech',
                3,
                Icons.computer,
                const Color(0xFF2196F3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    int index,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => onCategoryTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
