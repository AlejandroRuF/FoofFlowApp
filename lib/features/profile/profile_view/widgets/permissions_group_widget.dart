import 'package:flutter/material.dart';
import '../../profile_model/Profile_management_model.dart';

class PermissionsGroupWidget extends StatelessWidget {
  final PermissionCategory category;
  final Map<String, bool> permissions;
  final Function(String, bool) onPermissionChanged;

  const PermissionsGroupWidget({
    Key? key,
    required this.category,
    required this.permissions,
    required this.onPermissionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          category.description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        ...category.permissions.map((permission) {
          final isChecked = permissions[permission.key] ?? false;
          return CheckboxListTile(
            title: Text(permission.name),
            subtitle: Text(permission.description),
            value: isChecked,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (newValue) {
              if (newValue != null) {
                onPermissionChanged(permission.key, newValue);
              }
            },
          );
        }).toList(),
        const Divider(height: 32),
      ],
    );
  }
}
