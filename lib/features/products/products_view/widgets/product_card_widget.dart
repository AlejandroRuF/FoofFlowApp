import 'package:flutter/material.dart';
import 'package:foodflow_app/models/producto_model.dart';

class ProductCardWidget extends StatelessWidget {
  final Producto product;
  final VoidCallback? onTap;
  final String tipoUsuario;

  const ProductCardWidget({
    Key? key,
    required this.product,
    this.onTap,
    required this.tipoUsuario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
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
                    if (product.getImagenUrlCompleta() != null)
                      Image.network(
                        product.getImagenUrlCompleta()!,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: imageHeight,
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: imageHeight,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 40,
                              ),
                            ),
                      )
                    else
                      Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
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
                            Container(
                              margin: const EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.amber,
                                size: constraints.maxWidth < 200 ? 16 : 20,
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
}
