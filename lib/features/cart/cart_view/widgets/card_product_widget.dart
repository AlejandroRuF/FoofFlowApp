import 'package:flutter/material.dart';
import 'package:foodflow_app/models/pedido_producto_model.dart';
import 'package:foodflow_app/models/producto_model.dart';

class CartProductWidget extends StatelessWidget {
  final PedidoProducto pedidoProducto;
  final Producto? producto;
  final bool editable;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onDelete;

  const CartProductWidget({
    super.key,
    required this.pedidoProducto,
    this.producto,
    this.editable = false,
    this.onAdd,
    this.onRemove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imagenUrl = producto?.imagen ?? '';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (imagenUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imagenUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.image_not_supported),
                ),
              )
            else
              const Icon(Icons.image, size: 48, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto?.nombre ?? pedidoProducto.productoNombre,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (producto?.descripcion != null)
                    Text(
                      producto!.descripcion!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    'Precio: €${pedidoProducto.precioUnitario.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Subtotal: €${(pedidoProducto.precioUnitario * pedidoProducto.cantidad).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (editable)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: onRemove,
                    tooltip: 'Restar cantidad',
                  ),
                  Text(
                    '${pedidoProducto.cantidad}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onAdd,
                    tooltip: 'Sumar cantidad',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    tooltip: 'Eliminar producto',
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'x${pedidoProducto.cantidad}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
