import 'package:flutter/material.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/smart_image.dart';
import '../models/safe_meeting_point_model.dart';

class SafeMeetingPointSheet extends StatefulWidget {
  final SafeMeetingPointModel? initialSelected;

  /// Opsional: daftar titik temu yang sudah ada. Jika kosong/null, sheet
  /// mengambil sendiri dari tabel safe_meeting_points (dan jatuh ke daftar
  /// bawaan `campusPoints` jika database kosong atau gagal dihubungi).
  final List<SafeMeetingPointModel>? points;

  const SafeMeetingPointSheet({
    super.key,
    this.initialSelected,
    this.points,
  });

  static Future<SafeMeetingPointModel?> show(
      BuildContext context, {
        SafeMeetingPointModel? currentSelection,
        List<SafeMeetingPointModel>? points,
      }) {
    return showModalBottomSheet<SafeMeetingPointModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeMeetingPointSheet(
        initialSelected: currentSelection,
        points: points,
      ),
    );
  }

  @override
  State<SafeMeetingPointSheet> createState() => _SafeMeetingPointSheetState();
}

class _SafeMeetingPointSheetState extends State<SafeMeetingPointSheet> {
  SafeMeetingPointModel? _selectedPoint;
  List<SafeMeetingPointModel> _points = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialSelected;
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    List<SafeMeetingPointModel> result = widget.points ?? const [];

    if (result.isEmpty) {
      try {
        final response = await SupabaseConfig.client
            .from('safe_meeting_points')
            .select()
            .eq('is_active', true)
            .timeout(const Duration(seconds: 15));

        result = (response as List<dynamic>)
            .map(
              (row) => SafeMeetingPointModel.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
            .toList();
      } catch (e) {
        debugPrint('[SafeMeetingPointSheet] gagal memuat dari database: $e');
      }
    }

    if (result.isEmpty) {
      result = SafeMeetingPointModel.campusPoints;
    }

    if (!mounted) return;

    setState(() {
      _points = result;
      _selectedPoint = _matchSelection(result, _selectedPoint);
      _isLoading = false;
    });
  }

  bool _isSame(SafeMeetingPointModel a, SafeMeetingPointModel b) {
    return a.id == b.id ||
        a.name.trim().toLowerCase() == b.name.trim().toLowerCase();
  }

  /// Menyamakan pilihan awal (mis. dari daftar bawaan "SMP-1") dengan titik
  /// temu di database (UUID) berdasarkan nama, supaya yang dikembalikan
  /// selalu data yang valid di database.
  SafeMeetingPointModel? _matchSelection(
      List<SafeMeetingPointModel> list,
      SafeMeetingPointModel? current,
      ) {
    if (current == null) return null;

    for (final point in list) {
      if (_isSame(point, current)) return point;
    }
    return current;
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
              if (_isLoading)
                const SizedBox(
                  height: 180,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: _points.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.84,
                    ),
                    itemBuilder: (context, index) {
                      final point = _points[index];
                      final bool isSelected = _selectedPoint != null &&
                          _isSame(_selectedPoint!, point);

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
                                        child: SmartImage(
                                          source: point.imagePath,
                                          fit: BoxFit.cover,
                                          placeholderIcon:
                                          Icons.location_city_rounded,
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
                  onPressed: hasSelection && !_isLoading
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