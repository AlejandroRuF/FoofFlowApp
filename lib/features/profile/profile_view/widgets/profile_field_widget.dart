import 'package:flutter/material.dart';

class ProfileFieldWidget extends StatelessWidget {
  final String label;
  final String value;
  final String? hintText;
  final TextEditingController? controller;
  final bool isEditable;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? icon;

  const ProfileFieldWidget({
    super.key,
    required this.label,
    required this.value,
    this.hintText,
    this.controller,
    this.isEditable = false,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          if (isEditable && controller != null)
            TextFormField(
              controller: controller,
              obscureText: isPassword,
              validator: validator,
              keyboardType: keyboardType,
              maxLines: isPassword ? 1 : maxLines,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: icon != null ? Icon(icon) : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.grey.shade600, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      isPassword ? '••••••••' : value,
                      style: TextStyle(
                        fontSize: 16,
                        color: isPassword ? Colors.grey : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
