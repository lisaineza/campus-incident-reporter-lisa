import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final File? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final file = photo;
    if (file == null) {
      return GestureDetector(
        onTap: onPick,
        child: CustomPaint(
          painter: _DashedBorderPainter(),
          child: Container(
            height: 110,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.textSecondary, size: 28),
                SizedBox(height: 8),
                Text(
                  'Tap to add a photo',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.file(file, height: 190, width: double.infinity, fit: BoxFit.cover),
          Positioned(
            top: 8,
            right: 8,
            child: _RoundAction(icon: Icons.close_rounded, onTap: onRemove),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: _RoundAction(icon: Icons.edit_outlined, onTap: onPick),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  static const _dash = 6.0;
  static const _gap = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dash),
          paint,
        );
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
