import 'package:flutter/material.dart';
import '../../profile_model/Profile_management_model.dart';

class EmployeeCardWidget extends StatelessWidget {
  final EmployeeItem employee;
  final bool expanded;
  final VoidCallback onToggle;
  final Map<String, bool> permissions;
  final Function(String, bool) onPermissionChanged;
  final List<PermissionCategory> permissionCategories;

  const EmployeeCardWidget({
    Key? key,
    required this.employee,
    required this.expanded,
    required this.onToggle,
    required this.permissions,
    required this.onPermissionChanged,
    required this.permissionCategories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: _buildAvatar(),
            title: Text(
              employee.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(employee.email),
            trailing: IconButton(
              icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: onToggle,
            ),
            onTap: onToggle,
          ),
          if (expanded) _buildPermissionsPanel(context),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: Colors.blue.shade100,
      foregroundImage:
          employee.imagen != null && employee.imagen!.isNotEmpty
              ? NetworkImage(employee.imagen!)
              : null,
      child:
          employee.imagen == null || employee.imagen!.isEmpty
              ? Text(
                employee.nombre.isNotEmpty
                    ? employee.nombre[0].toUpperCase()
                    : 'E',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
              : null,
    );
  }

  Widget _buildPermissionsPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permisos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...permissionCategories.map(
            (category) => _buildCategorySection(context, category),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    PermissionCategory category,
  ) {
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
        Wrap(
          spacing: 8,
          runSpacing: 0,
          children:
              category.permissions.map((permission) {
                final isChecked = permissions[permission.key] ?? false;
                return SizedBox(
                  width: 220,
                  child: CheckboxListTile(
                    title: Text(
                      permission.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      permission.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: isChecked,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onPermissionChanged(permission.key, newValue);
                      }
                    },
                  ),
                );
              }).toList(),
        ),
        const Divider(height: 32),
      ],
    );
  }
}
