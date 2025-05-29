import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodflow_app/models/producto_model.dart';

class ProductCardWidget extends StatelessWidget {
  final Producto product;
  final VoidCallback? onTap;
  final String tipoUsuario;
  final int cantidadEnCarrito;
  final Function(int, int)? onAgregarAlCarrito;
  final bool actualizandoCarrito;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    required this.tipoUsuario,
    this.cantidadEnCarrito = 0,
    this.onAgregarAlCarrito,
    this.actualizandoCarrito = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: tipoUsuario == 'restaurante' ? null : onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double imageHeight = constraints.maxWidth < 200 ? 100 : 120;
            double titleFontSize = constraints.maxWidth < 200 ? 13 : 15;
            double categoryFontSize = constraints.maxWidth < 200 ? 11 : 13;
            double priceFontSize = constraints.maxWidth < 200 ? 15 : 17;
            double basePriceFontSize = constraints.maxWidth < 200 ? 9 : 11;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildProductImage(imageHeight),
                    if (!product.isActive)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: Colors.red,
                          child: const Text(
                            'Inactivo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth < 200 ? 6.0 : 10.0,
                    vertical: constraints.maxWidth < 200 ? 6.0 : 8.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product.categoriaNombre != null)
                        Text(
                          product.categoriaNombre!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: categoryFontSize,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '€${product.precioFinal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: priceFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tipoUsuario == 'restaurante')
                            _buildCartControls(context, constraints),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Base: €${product.precio.toStringAsFixed(2)} + ${product.impuestos}% IVA',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: basePriceFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductImage(double imageHeight) {
    final imagenUrl = product.getImagenUrlCompleta();

    if (imagenUrl != null && imagenUrl.isNotEmpty) {
      // Añadir timestamp para evitar caché
      final imagenUrlConTimestamp =
          '$imagenUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      return CachedNetworkImage(
        imageUrl: imagenUrlConTimestamp,
        height: imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              height: imageHeight,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: imageHeight,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 40),
            ),
      );
    } else {
      return Container(
        height: imageHeight,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 40),
      );
    }
  }

  Widget _buildCartControls(BuildContext context, BoxConstraints constraints) {
    if (actualizandoCarrito) {
      return SizedBox(
        width: constraints.maxWidth < 200 ? 20 : 24,
        height: constraints.maxWidth < 200 ? 20 : 24,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
        ),
      );
    }

    if (cantidadEnCarrito > 0) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                size: constraints.maxWidth < 200 ? 14 : 18,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth < 200 ? 24 : 30,
                minHeight: constraints.maxWidth < 200 ? 24 : 30,
              ),
              onPressed: () {
                if (onAgregarAlCarrito != null) {
                  onAgregarAlCarrito!(product.id, cantidadEnCarrito - 1);
                }
              },
            ),
            Text(
              '$cantidadEnCarrito',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth < 200 ? 14 : 16,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, size: constraints.maxWidth < 200 ? 14 : 18),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth < 200 ? 24 : 30,
                minHeight: constraints.maxWidth < 200 ? 24 : 30,
              ),
              onPressed: () {
                if (onAgregarAlCarrito != null) {
                  onAgregarAlCarrito!(product.id, cantidadEnCarrito + 1);
                }
              },
            ),
          ],
        ),
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.add_shopping_cart,
          color: Colors.amber,
          size: constraints.maxWidth < 200 ? 16 : 20,
        ),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: constraints.maxWidth < 200 ? 24 : 30,
          minHeight: constraints.maxWidth < 200 ? 24 : 30,
        ),
        onPressed: () {
          if (onAgregarAlCarrito != null) {
            onAgregarAlCarrito!(product.id, 1);
          }
        },
      );
    }
  }
}
