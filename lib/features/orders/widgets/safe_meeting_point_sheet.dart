import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/safe_meeting_point_model.dart';

class SafeMeetingPointSheet extends StatefulWidget {
  final SafeMeetingPointModel? initialSelected;

  const SafeMeetingPointSheet({
    super.key,
    this.initialSelected,
  });

  static Future<SafeMeetingPointModel?> show(
      BuildContext context, {
        SafeMeetingPointModel? currentSelection,
      }) {
    return showModalBottomSheet<SafeMeetingPointModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeMeetingPointSheet(
        initialSelected: currentSelection,
      ),
    );
  }

  @override
  State<SafeMeetingPointSheet> createState() => _SafeMeetingPointSheetState();
}

class _SafeMeetingPointSheetState extends State<SafeMeetingPointSheet> {
  SafeMeetingPointModel? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = _selectedPoint != null;
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.75;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                width: 56,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),

              // Judul tetap di atas
              const Text(
                'Silahkan pilih safe meeting point',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),

              // Area Grid yang bisa di-scroll
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: SafeMeetingPointModel.campusPoints.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.84,
                  ),
                  itemBuilder: (context, index) {
                    final point = SafeMeetingPointModel.campusPoints[index];
                    final bool isSelected = _selectedPoint?.id == point.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPoint = point;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.25),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Image.asset(
                                        point.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.primaryLight,
                                          child: const Icon(
                                            Icons.location_city_rounded,
                                            size: 36,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        point.name,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: CustomPaint(
                                    size: const Size(36, 36),
                                    painter: _CornerRibbonPainter(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Tetapkan Titik Temu tetap di bawah
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: hasSelection
                      ? () => Navigator.of(context).pop(_selectedPoint)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.rentalBadgeBg,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Tetapkan Titik Temu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerRibbonPainter extends CustomPainter {
  final Color color;

  _CornerRibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}