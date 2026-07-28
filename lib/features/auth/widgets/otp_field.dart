import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class OtpField extends StatefulWidget {
  final ValueChanged<String>? onCompleted;

  const OtpField({
    super.key,
    this.onCompleted,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final List<TextEditingController> controllers;
  late final List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();

    controllers =
        List.generate(6, (_) => TextEditingController());

    focusNodes =
        List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }

    for (final f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  void _checkCompleted() {
    final otp = controllers.map((e) => e.text).join();

    if (otp.length == 6) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 48,
          height: 60,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppTextStyles.title,

            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],

            decoration: InputDecoration(
              counterText: "",

              filled: true,
              fillColor: Colors.white,

              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),

            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                focusNodes[index + 1].requestFocus();
              }

              if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }

              _checkCompleted();
            },
          ),
        ),
      ),
    );
  }
}