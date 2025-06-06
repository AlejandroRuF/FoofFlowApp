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
  final bool esRestaurante;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    required this.tipoUsuario,
    this.cantidadEnCarrito = 0,
    this.onAgregarAlCarrito,
    this.actualizandoCarrito = false,
    required this.esRestaurante,
  });

  bool get _muestraVistaRestaurante {
    return esRestaurante || (tipoUsuario == 'empleado' && esRestaurante);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: _muestraVistaRestaurante ? null : onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double imageHeight = constraints.maxWidth < 200 ? 100 : 120;
            double titleFontSize = constraints.maxWidth < 200 ? 13 : 15;
            double categoryFontSize = constraints.maxWidth < 200 ? 11 : 13;
            double priceFontSize = constraints.maxWidth < 200 ? 15 : 17;
            double basePriceFontSize = constraints.maxWidth < 200 ? 9 : 11;
            double unitFontSize = constraints.maxWidth < 200 ? 10 : 12;

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
                      Row(
                        children: [
                          if (product.categoriaNombre != null)
                            Expanded(
                              child: Text(
                                product.categoriaNombre!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: categoryFontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade500,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              product.unidadMedida,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: unitFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_muestraVistaRestaurante)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '€${product.precioFinal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: priceFontSize,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            _buildCartControls(context, constraints),
                          ],
                        )
                      else
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallDevice = constraints.maxWidth < 200;

    if (actualizandoCarrito) {
      return Center(
        child: SizedBox(
          width: isSmallDevice ? 18 : 24,
          height: isSmallDevice ? 18 : 24,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
      );
    }

    if (cantidadEnCarrito > 0) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              isDark
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(isSmallDevice ? 6 : 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (onAgregarAlCarrito != null) {
                  onAgregarAlCarrito!(product.id, cantidadEnCarrito - 1);
                }
              },
              child: Container(
                width: isSmallDevice ? 28 : 32,
                height: isSmallDevice ? 28 : 32,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(isSmallDevice ? 4 : 6),
                ),
                child: Icon(
                  Icons.remove,
                  size: isSmallDevice ? 12 : 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            Container(
              constraints: BoxConstraints(minWidth: isSmallDevice ? 24 : 32),
              child: Text(
                '$cantidadEnCarrito',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallDevice ? 12 : 14,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (onAgregarAlCarrito != null) {
                  onAgregarAlCarrito!(product.id, cantidadEnCarrito + 1);
                }
              },
              child: Container(
                width: isSmallDevice ? 28 : 32,
                height: isSmallDevice ? 28 : 32,
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(isSmallDevice ? 4 : 6),
                ),
                child: Icon(
                  Icons.add,
                  size: isSmallDevice ? 12 : 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: GestureDetector(
          onTap: () {
            if (onAgregarAlCarrito != null) {
              onAgregarAlCarrito!(product.id, 1);
            }
          },
          child: Container(
            width: isSmallDevice ? 28 : 32,
            height: isSmallDevice ? 28 : 32,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3)
                      : Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isSmallDevice ? 6 : 8),
              border: Border.all(
                color:
                    isDark
                        ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                        : Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.add_shopping_cart,
              color:
                  isDark
                      ? Theme.of(context).colorScheme.primary
                      : Colors.amber.shade700,
              size: isSmallDevice ? 14 : 18,
            ),
          ),
        ),
      );
    }
  }
}
