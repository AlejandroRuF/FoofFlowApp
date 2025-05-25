import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../products_viewmodel/product_form_view_model.dart';

class ProductFormScreen extends StatelessWidget {
  final int? productoId;

  const ProductFormScreen({Key? key, this.productoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ProductFormViewModel();
        if (productoId != null) {
          viewModel.cargarProducto(productoId!);
        }
        return viewModel;
      },
      child: Consumer<ProductFormViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: productoId == null ? 'Nuevo Producto' : 'Editar Producto',
            body: _buildBody(context, viewModel),
            showBackButton: true,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductFormViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/app_icon.png', width: 100, height: 100),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    if (viewModel.error != null &&
        viewModel.producto == null &&
        productoId != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${viewModel.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.cargarProducto(productoId!),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context, viewModel),
          const SizedBox(height: 16),
          _buildFormFields(context, viewModel),
          const SizedBox(height: 32),
          _buildFormActions(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    ProductFormViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Imagen del Producto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        viewModel.imagenSeleccionada != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                viewModel.imagenSeleccionada!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : viewModel.producto?.getImagenUrlCompleta() != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                viewModel.producto!.getImagenUrlCompleta()!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            )
                            : const Center(
                              child: Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                  ),
                  if (viewModel.imagenSeleccionada != null ||
                      viewModel.producto?.getImagenUrlCompleta() != null)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () => viewModel.eliminarImagen(),
                          constraints: const BoxConstraints(
                            minWidth: 30,
                            minHeight: 30,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed:
                      () => viewModel.seleccionarImagen(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed:
                      () => viewModel.seleccionarImagen(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(
    BuildContext context,
    ProductFormViewModel viewModel,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Producto',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField(
              decoration: const InputDecoration(
                labelText: 'Cocina Central *',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              value: viewModel.cocinaCentralSeleccionada,
              items:
                  viewModel.cocinasCentrales.map((cocina) {
                    return DropdownMenuItem(
                      value: cocina,
                      child: Text(cocina.nombre),
                    );
                  }).toList(),
              onChanged: (value) {
                viewModel.cocinaCentralSeleccionada = value;
                viewModel.notifyListeners();
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: viewModel.precioController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      border: OutlineInputBorder(),
                      prefixText: '€ ',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: viewModel.impuestosController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Impuestos (%)',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.unidadMedidaController,
              decoration: const InputDecoration(
                labelText: 'Unidad de medida',
                border: OutlineInputBorder(),
                hintText: 'ej. kg, unidad, litro',
              ),
            ),
            const SizedBox(height: 16),
            if (productoId != null)
              Row(
                children: [
                  const Text('Estado del producto:'),
                  const SizedBox(width: 16),
                  Switch(
                    value: viewModel.productoActivo,
                    onChanged: (value) {
                      viewModel.productoActivo = value;
                      viewModel.notifyListeners();
                    },
                  ),
                  Text(viewModel.productoActivo ? 'Activo' : 'Inactivo'),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormActions(
    BuildContext context,
    ProductFormViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed:
              viewModel.isSaving
                  ? null
                  : () async {
                    final result = await viewModel.guardarProducto();
                    if (result) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              productoId == null
                                  ? 'Producto creado correctamente'
                                  : 'Producto actualizado correctamente',
                            ),
                          ),
                        );
                        context.pop();
                      }
                    } else if (context.mounted && viewModel.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(viewModel.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
          child:
              viewModel.isSaving
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/app_icon.png',
                          width: 100,
                          height: 100,
                        ),
                        SizedBox(height: 24),
                        CircularProgressIndicator(),
                      ],
                    ),
                  )
                  : Text(
                    productoId == null ? 'Crear Producto' : 'Guardar Cambios',
                  ),
        ),
      ],
    );
  }
}
