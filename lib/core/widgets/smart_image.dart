import 'package:flutter/material.dart';

import '../config/supabase_config.dart';
import '../constants/app_colors.dart';

/// Mengubah nilai gambar dari database menjadi sumber yang valid.
///
/// Nilai di database bisa berupa:
///  1. URL lengkap              -> https://xxxx.supabase.co/storage/v1/object/public/...
///  2. Path asset lokal         -> assets/images/kemeja_putih.png
///  3. Path di Supabase Storage -> products/abc123.jpg (tanpa domain)
class ImageSourceResolver {
  ImageSourceResolver._();

  /// GANTI jika bucket Supabase Storage foto produk/titik temu bernama lain.
  /// Hanya dipakai kalau nilai di database berupa path tanpa domain.
  static const String storageBucket = 'product-images';

  static bool isNetwork(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  static bool isAsset(String value) => value.startsWith('assets/');

  /// Mengembalikan string kosong jika tidak ada gambar yang bisa dipakai.
  static String resolve(String? raw) {
    var value = (raw ?? '').trim();

    if (value.isEmpty || value == 'null') return '';
    if (isNetwork(value) || isAsset(value)) return value;

    if (value.startsWith('/')) value = value.substring(1);
    if (value.startsWith('$storageBucket/')) {
      value = value.substring(storageBucket.length + 1);
    }

    try {
      return SupabaseConfig.client.storage
          .from(storageBucket)
          .getPublicUrl(value);
    } catch (e) {
      debugPrint('[ImageSourceResolver] gagal membuat public URL: $e');
      return '';
    }
  }

  /// Untuk widget yang butuh ImageProvider (CircleAvatar.backgroundImage,
  /// DecorationImage, dll). Mengembalikan null jika tidak ada gambar.
  static ImageProvider? provider(String? raw) {
    final resolved = resolve(raw);

    if (resolved.isEmpty) return null;
    if (isNetwork(resolved)) return NetworkImage(resolved);
    return AssetImage(resolved);
  }
}

/// Pengganti `Image.asset(...)` / `Image.network(...)`.
/// Otomatis memilih sumber yang tepat dan selalu jatuh ke placeholder
/// jika gagal (tidak pernah merusak layout).
class SmartImage extends StatelessWidget {
  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  /// Widget pengganti jika gambar kosong / gagal dimuat
  /// (mis. huruf inisial untuk avatar). Jika null, dipakai ikon.
  final Widget? placeholder;

  const SmartImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.image_outlined,
    this.placeholder,
  });

  Widget _placeholder({bool loading = false}) {
    if (!loading && placeholder != null) {
      return Container(
        width: width,
        height: height,
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: placeholder,
      );
    }

    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      )
          : Icon(
        placeholderIcon,
        color: AppColors.textSecondary,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = ImageSourceResolver.resolve(source);

    Widget image;

    if (resolved.isEmpty) {
      image = _placeholder();
    } else if (ImageSourceResolver.isNetwork(resolved)) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final int? cacheWidth =
      (width != null && width!.isFinite) ? (width! * dpr).round() : null;

      image = Image.network(
        resolved,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholder(loading: true);
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[SmartImage] gagal load network: $resolved -> $error');
          return _placeholder();
        },
      );
    } else {
      image = Image.asset(
        resolved,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('[SmartImage] gagal load asset: $resolved -> $error');
          return _placeholder();
        },
      );
    }

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}