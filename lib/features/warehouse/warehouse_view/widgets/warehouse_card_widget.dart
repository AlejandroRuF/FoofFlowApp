import 'package:flutter/material.dart';

class WarehouseCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final bool isEnabled;
  final VoidCallback? onTap;
  final bool isDarkMode;

  const WarehouseCardWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    required this.isEnabled,
    this.onTap,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ?? (isDarkMode ? Colors.amber : Colors.blue);

    final disabledColor =
        isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isEnabled
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isEnabled ? effectiveIconColor : disabledColor)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isEnabled ? effectiveIconColor : disabledColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? null : disabledColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isEnabled
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : disabledColor,
                ),
              ),
              if (!isEnabled) ...[
                const SizedBox(height: 16),
                Text(
                  'No tienes permiso para esta operación',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
