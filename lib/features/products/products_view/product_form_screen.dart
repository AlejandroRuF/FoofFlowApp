import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';

import '../../../models/user_model.dart';
import '../products_viewmodel/product_form_view_model.dart';

class ProductFormScreen extends StatelessWidget {
  final int? productoId;

  const ProductFormScreen({super.key, this.productoId});

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
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
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
    final puedeEditarImagen = viewModel.puedeEditarImagen;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      color:
                          puedeEditarImagen
                              ? (isDark ? Colors.grey[800] : Colors.grey[100])
                              : (isDark ? Colors.grey[850] : Colors.grey[50]),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          !puedeEditarImagen
                              ? Border.all(
                                color:
                                    isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                style: BorderStyle.solid,
                              )
                              : null,
                    ),
                    child: _buildImageWidget(viewModel),
                  ),
                  if (puedeEditarImagen &&
                      (viewModel.imagenSeleccionada != null ||
                          (viewModel.producto?.getImagenUrlCompleta() != null)))
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        decoration: const BoxDecoration(
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
            if (puedeEditarImagen)
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
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3)
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No tienes permisos para modificar la imagen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.visibility_off,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(ProductFormViewModel viewModel) {
    if (viewModel.imagenSeleccionada != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          viewModel.imagenSeleccionada!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (viewModel.producto?.getImagenUrlCompleta() != null) {
      final imagenUrl = viewModel.producto!.getImagenUrlCompleta()!;
      final imagenUrlConTimestamp =
          '$imagenUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imagenUrlConTimestamp,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder:
              (context, url) =>
                  const Center(child: CircularProgressIndicator()),
          errorWidget:
              (context, url, error) => const Center(
                child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
        ),
      );
    }

    return const Center(child: Icon(Icons.image, size: 50, color: Colors.grey));
  }

  Widget _buildFormFields(
    BuildContext context,
    ProductFormViewModel viewModel,
  ) {
    final puedeEditarDatosBasicos = viewModel.puedeEditarDatosBasicos;
    final puedeEditarEstado = viewModel.puedeEditarEstado;
    final puedeSeleccionarCocinaCentral =
        viewModel.puedeSeleccionarCocinaCentral;

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
            puedeSeleccionarCocinaCentral
                ? _buildEditableDropdown(
                  context: context,
                  label: 'Cocina Central *',
                  value: viewModel.cocinaCentralSeleccionada,
                  items: viewModel.cocinasCentrales,
                  onChanged: (User? value) {
                    viewModel.cocinaCentralSeleccionada = value;
                    viewModel.notifyListeners();
                  },
                  itemBuilder: (cocina) => cocina.nombre,
                )
                : _buildReadOnlyField(
                  context,
                  'Cocina Central *',
                  viewModel.cocinaCentralSeleccionada?.nombre ??
                      'No seleccionada',
                ),

            const SizedBox(height: 16),
            puedeEditarDatosBasicos
                ? _buildEditableTextField(
                  context: context,
                  controller: viewModel.nombreController,
                  label: 'Nombre del producto *',
                )
                : _buildReadOnlyField(
                  context,
                  'Nombre del producto *',
                  viewModel.nombreController.text,
                ),

            const SizedBox(height: 16),
            puedeEditarDatosBasicos
                ? _buildEditableTextField(
                  context: context,
                  controller: viewModel.descripcionController,
                  label: 'Descripción',
                  maxLines: 3,
                )
                : _buildReadOnlyField(
                  context,
                  'Descripción',
                  viewModel.descripcionController.text.isEmpty
                      ? 'Sin descripción'
                      : viewModel.descripcionController.text,
                ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child:
                      puedeEditarDatosBasicos
                          ? _buildEditableTextField(
                            context: context,
                            controller: viewModel.precioController,
                            label: 'Precio *',
                            keyboardType: TextInputType.number,
                            prefixText: '€ ',
                          )
                          : _buildReadOnlyField(
                            context,
                            'Precio *',
                            '€ ${viewModel.precioController.text}',
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      puedeEditarDatosBasicos
                          ? _buildEditableTextField(
                            context: context,
                            controller: viewModel.impuestosController,
                            label: 'Impuestos (%)',
                            keyboardType: TextInputType.number,
                            suffixText: '%',
                          )
                          : _buildReadOnlyField(
                            context,
                            'Impuestos (%)',
                            '${viewModel.impuestosController.text}%',
                          ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            puedeEditarDatosBasicos
                ? _buildEditableTextField(
                  context: context,
                  controller: viewModel.unidadMedidaController,
                  label: 'Unidad de medida',
                  hint: 'ej. kg, unidad, litro',
                )
                : _buildReadOnlyField(
                  context,
                  'Unidad de medida',
                  viewModel.unidadMedidaController.text.isEmpty
                      ? 'No especificada'
                      : viewModel.unidadMedidaController.text,
                ),

            const SizedBox(height: 16),

            if (productoId != null)
              puedeEditarEstado
                  ? _buildEditableSwitch(
                    context: context,
                    label: 'Estado del producto',
                    subtitle: 'Activar o desactivar el producto',
                    value: viewModel.productoActivo,
                    onChanged: (value) {
                      viewModel.productoActivo = value;
                      viewModel.notifyListeners();
                    },
                  )
                  : _buildReadOnlyField(
                    context,
                    'Estado del producto',
                    viewModel.productoActivo ? 'Activo' : 'Inactivo',
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lock_outline,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3)
                    : Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Icon(
                Icons.visibility_off,
                size: 16,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? prefixText,
    String? suffixText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.edit,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'EDITABLE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            suffixText: suffixText,
            filled: true,
            fillColor:
                isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            ),
            prefixIcon: Icon(
              Icons.edit_note,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildEditableDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.edit,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'EDITABLE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            ),
            prefixIcon: Icon(
              Icons.arrow_drop_down_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    itemBuilder(item),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEditableSwitch({
    required BuildContext context,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'EDITABLE',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
                    viewModel.limpiarError();

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
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
