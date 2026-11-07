import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'maba_products_screen.dart';
import '../widgets/category_menu.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/information_card.dart';
import '../widgets/product_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/bundling_card.dart';
import '../widgets/location_permission_modal.dart';
import 'all_products_screen.dart';
import '../../community/screens/community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLocationDetected = false;
  final Geocoding _geocoding = Geocoding();

  final GlobalKey<ProductSectionState> _productSectionKey =
      GlobalKey<ProductSectionState>();

  String _locationName = 'Aktifkan Lokasi';
  bool _isLoadingLocation = false;
  bool _isUpdatingLocation = false;

  StreamSubscription<Position>? _positionSubscription;

  double? _lastLatitude;
  double? _lastLongitude;

  @override
  void initState() {
    super.initState();
    _checkExistingLocationPermission();
  }

  Future<void> _refreshHome() async {
    try {
      await _productSectionKey.currentState?.refresh();
    } catch (e) {
      debugPrint('ERROR REFRESH HOME: $e');
    }
  }

  Future<void> _checkExistingLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (!mounted) return;

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await _requestLocationPermission();
      }
    } catch (e) {
      debugPrint('ERROR MEMERIKSA IZIN: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    if (!mounted || _isLoadingLocation) return;

    String stage = 'Memulai proses lokasi';

    setState(() {
      _isLoadingLocation = true;
      _locationName = 'Mencari lokasi...';
    });

    try {
      stage = 'Memeriksa GPS';

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      debugPrint('GPS AKTIF: $serviceEnabled');

      if (!serviceEnabled) {
        throw Exception('GPS perangkat belum aktif');
      }

      stage = 'Memeriksa izin lokasi';

      LocationPermission permission = await Geolocator.checkPermission();

      debugPrint('STATUS IZIN: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!mounted) return;

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (permission == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }

        throw Exception('Izin lokasi tidak diberikan');
      }

      stage = 'Mengambil koordinat GPS';

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );

      debugPrint('LATITUDE: ${position.latitude}');
      debugPrint('LONGITUDE: ${position.longitude}');

      if (!mounted) return;

      stage = 'Mengubah koordinat menjadi alamat';

      await _updateLocationName(position, force: true);

      if (!mounted) return;

      await _positionSubscription?.cancel();

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 100,
            ),
          ).listen(
            (Position newPosition) async {
              try {
                await _updateLocationName(newPosition);
              } catch (e) {
                debugPrint('ERROR UPDATE LOKASI: $e');
              }
            },
            onError: (error) {
              debugPrint('ERROR LOCATION STREAM: $error');
            },
          );

      debugPrint('LOCATION TRACKING AKTIF');
    } catch (e, stackTrace) {
      debugPrint('================================');
      debugPrint('TAHAP GAGAL: $stage');
      debugPrint('DETAIL ERROR: $e');
      debugPrint('================================');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _locationName = 'Lokasi Gagal';
        _isLoadingLocation = false;
        _isLocationDetected = false;
      });
    }
  }

  Future<void> _updateLocationName(
    Position position, {
    bool force = false,
  }) async {
    if (!mounted || _isUpdatingLocation) return;

    if (!force && _lastLatitude != null && _lastLongitude != null) {
      final distance = Geolocator.distanceBetween(
        _lastLatitude!,
        _lastLongitude!,
        position.latitude,
        position.longitude,
      );

      if (distance < 100) return;
    }

    _isUpdatingLocation = true;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isEmpty) {
        throw Exception('Alamat tidak ditemukan');
      }

      final place = placemarks.first;

      final kelurahan = place.subLocality?.trim() ?? '';
      final kecamatan = place.subAdministrativeArea?.trim() ?? '';

      final locationParts = [kelurahan, kecamatan];

      final location = locationParts
          .where((item) => item.isNotEmpty)
          .toSet()
          .join(', ');

      if (location.isEmpty) {
        throw Exception('Nama kelurahan dan kecamatan tidak tersedia');
      }

      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;

      setState(() {
        _locationName = location;
        _isLoadingLocation = false;
        _isLocationDetected = true;
      });

      debugPrint('KELURAHAN: $kelurahan');
      debugPrint('KECAMATAN: $kecamatan');
      debugPrint('LOKASI BERHASIL: $location');
    } catch (e) {
      debugPrint('ERROR GEOCODING: $e');

      if (mounted) {
        setState(() {
          _isLoadingLocation = false;

          if (_lastLatitude == null) {
            _locationName = 'Lokasi Gagal';
            _isLocationDetected = false;
          }
        });
      }

      rethrow;
    } finally {
      _isUpdatingLocation = false;
    }
  }

  void _showLocationModal() {
    if (_isLocationDetected || _isLoadingLocation) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return LocationPermissionModal(
          onAllowLocation: () async {
            Navigator.of(dialogContext).pop();
            await _requestLocationPermission();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF9F283A),
          backgroundColor: Colors.white,
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  onLocationTap: _showLocationModal,
                  locationName: _locationName,
                  isLoadingLocation: _isLoadingLocation,
                  isLocationDetected: _isLocationDetected,
                ),
              ),

              const SliverToBoxAdapter(child: HomeSearchBar()),

              SliverToBoxAdapter(
                child: CategoryMenu(
                  onCategoryTap: (categoryName) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllProductsScreen(
                          categoryName: categoryName.isEmpty
                              ? null
                              : categoryName,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: InformationSection(
                  onRentalTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AllProductsScreen(rentalOnly: true),
                      ),
                    );
                  },
                  onCommunityTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CommunityScreen(),
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: PromoBanner(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MabaProductsScreen(),
                      ),
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(child: _buildBundlingSection()),

              SliverToBoxAdapter(
                child: ProductSection(
                  key: _productSectionKey,
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllProductsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBundlingSection() {
    const bundles = [
      BundleItem(
        title: 'Paket Ospek Lengkap',
        description: 'Kemeja + Celana + Dasi',
        price: 'Rp 120.000',
        oldPrice: 'Rp 150.000',
        badge: 'Lebih Hemat',
      ),
      BundleItem(
        title: 'Paket Kamar Kos',
        description: 'Kasur Lipat + Kipas',
        price: 'Rp 200.000',
        oldPrice: 'Rp 250.000',
        badge: 'Lebih Hemat',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF9F283A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Paket Bundling Hemat Mahasiswa Kos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 106,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 16),
              itemCount: bundles.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 14);
              },
              itemBuilder: (context, index) {
                return BundlingCard(bundle: bundles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
