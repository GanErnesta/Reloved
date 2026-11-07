
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_text_styles.dart';

class OtpField extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const OtpField({
    super.key,
    this.onChanged,
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

    controllers = List.generate(6, (_) => TextEditingController());
    focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _checkCompleted() {
    final value = controllers.map((e) => e.text).join();

    widget.onChanged?.call(value);

    if (value.length == 6) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalPadding = 40.0;
    const spacing = 8.0;

    final fieldWidth =
        (screenWidth - horizontalPadding - (spacing * 5)) / 6;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: fieldWidth.clamp(35.0, 52.0),
          height: 60,
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppTextStyles.title.copyWith(fontSize: 20),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
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
