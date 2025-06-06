import 'package:flutter/material.dart';
import 'package:foodflow_app/models/user_model.dart';

class KitchenCardWidget extends StatelessWidget {
  final User kitchen;
  final VoidCallback? onTap;

  const KitchenCardWidget({super.key, required this.kitchen, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child:
              kitchen.imagen != null
                  ? ClipOval(
                    child: Image.network(
                      kitchen.imagen!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.business),
                    ),
                  )
                  : const Icon(Icons.business),
        ),
        title: Text(
          kitchen.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kitchen.email),
            if (kitchen.empresaAsociada != null)
              Text('Empresa: ${kitchen.empresaAsociada}'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
