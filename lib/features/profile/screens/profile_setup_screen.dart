import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/supabase_config.dart';
import '../../auth/models/campus.dart';
import '../../auth/repositories/campus_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final ProfileController _controller = ProfileController();

  final namaController = TextEditingController();
  final nimController = TextEditingController();
  final kampusController = TextEditingController();
  final fakultasController = TextEditingController();
  final prodiController = TextEditingController();

  Campus? campus;

  bool isLoading = false;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    loadCampus();
  }

  Future<void> loadCampus() async {
  try {
    final user = SupabaseConfig.client.auth.currentUser;

    print("===== LOAD CAMPUS =====");
    print("Current User : ${user?.email}");

    if (user == null) {
      print("User NULL");

      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
      return;
    }

    namaController.text =
        user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        '';

    final email = user.email;

    if (email != null) {
      campus = await CampusRepository.getCampusByEmail(email);

      print("Campus Object : $campus");

      if (campus != null) {
        print("Campus ID : ${campus!.id}");
        print("Campus Name : ${campus!.name}");

        kampusController.text = campus!.name;
      }
    }
  } catch (e, stack) {
    print("===== LOAD CAMPUS ERROR =====");
    print(e);
    print(stack);
  } finally {
    if (mounted) {
      setState(() {
        isInitializing = false;
      });
    }
  }
}

  Future<void> saveProfile() async {
    if (campus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Domain email kampus tidak terdaftar.")),
      );
      return;
    }

    if (namaController.text.trim().isEmpty ||
        nimController.text.trim().isEmpty ||
        fakultasController.text.trim().isEmpty ||
        prodiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi.")));
      return;
    }

    try {
      setState(() => isLoading = true);

      await _controller.saveProfile(
        nama: namaController.text.trim(),
        nim: nimController.text.trim(),
        campusId: campus!.id,
        fakultas: fakultasController.text.trim(),
        programStudi: prodiController.text.trim(),
      );

      if (!mounted) return;

      context.go('/home');
    } catch (e, stack) {
      debugPrint("===== SAVE PROFILE ERROR =====");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    nimController.dispose();
    kampusController.dispose();
    fakultasController.dispose();
    prodiController.dispose();
    super.dispose();
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseConfig.client.auth.currentUser;

    if (isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Lengkapi Profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildField(controller: namaController, label: "Nama"),

            TextFormField(
              initialValue: user?.email ?? "",
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            buildField(
              controller: nimController,
              label: "NIM",
              keyboardType: TextInputType.number,
            ),

            buildField(
              controller: kampusController,
              label: "Kampus",
              enabled: false,
            ),

            buildField(controller: fakultasController, label: "Fakultas"),

            buildField(controller: prodiController, label: "Program Studi"),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,
                child: Text(isLoading ? "Menyimpan..." : "Simpan Profil"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
