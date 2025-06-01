import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/features/warehouse/warehouse_view/widgets/inventory_product_widget.dart';
import 'package:foodflow_app/features/warehouse/warehouse_view/widgets/inventory_filters_widget.dart';
import 'package:foodflow_app/models/user_model.dart';
import '../../../models/producto_model.dart';
import '../warehouse_viewmodel/inventory_viewmodel.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryViewModel(),
      child: Consumer<InventoryViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Inventario',
            body: _buildBody(context, viewModel),
            showBackButton: true,
            floatingActionButton:
                viewModel.tienePermisoModificarInventario
                    ? FloatingActionButton(
                      onPressed: () {
                        _iniciarFlujoAgregarProducto(context, viewModel);
                      },
                      child: const Icon(Icons.add),
                    )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, InventoryViewModel viewModel) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    Widget filtersWidget = InventoryFiltersWidget(
      busqueda: viewModel.state.busqueda,
      mostrarStockBajo: viewModel.state.mostrarStockBajo,
      stockMinimo: viewModel.state.stockMinimo,
      stockMaximo: viewModel.state.stockMaximo,
      categoriaIdSeleccionada: viewModel.state.categoriaIdSeleccionada,
      soloActivos: viewModel.state.soloActivos,
      categorias: viewModel.state.categorias,
      onBusquedaChanged: viewModel.buscar,
      onMostrarStockBajoChanged: viewModel.toggleMostrarStockBajo,
      onStockMinimoChanged: viewModel.establecerStockMinimo,
      onStockMaximoChanged: viewModel.establecerStockMaximo,
      onCategoriaChanged: viewModel.establecerCategoria,
      onSoloActivosChanged: viewModel.toggleSoloActivos,
      onLimpiarFiltros: viewModel.limpiarFiltros,
      onAplicarFiltros: viewModel.aplicarFiltros,
    );

    if (viewModel.state.isLoading) {
      return Column(
        children: [
          filtersWidget,
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/app_icon.png',
                    width: isSmallScreen ? 80 : 100,
                    height: isSmallScreen ? 80 : 100,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (viewModel.state.error != null) {
      return Column(
        children: [
          filtersWidget,
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isSmallScreen ? 60 : 80,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.state.error!,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.tienePermisoVerInventario)
                      ElevatedButton(
                        onPressed: () => viewModel.cargarInventario(),
                        child: const Text('Reintentar'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final inventario = viewModel.inventarioFiltrado;

    if (inventario.isEmpty) {
      return Column(
        children: [
          filtersWidget,
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory,
                      size: isSmallScreen ? 60 : 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay productos en el inventario',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (viewModel.tienePermisoModificarInventario) ...[
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          _iniciarFlujoAgregarProducto(context, viewModel);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir Producto'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        filtersWidget,
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.cargarInventario,
            child: ListView.builder(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              itemCount: inventario.length,
              itemBuilder: (context, index) {
                final item = inventario[index];
                return InventoryProductWidget(
                  inventarioItem: item,
                  puedeModificar: viewModel.tienePermisoModificarInventario,
                  onStockChanged:
                      (nuevoStock) => viewModel.actualizarStockProducto(
                        item.id,
                        nuevoStock,
                      ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _iniciarFlujoAgregarProducto(
    BuildContext context,
    InventoryViewModel viewModel,
  ) async {
    if (viewModel.esAdmin) {
      await _mostrarSeleccionUsuarios(context, viewModel);
    } else if (viewModel.esRestauranteOCocina) {
      final usuarioActual = viewModel.usuarioActual;
      if (usuarioActual != null) {
        await _mostrarSeleccionCocinas(context, viewModel, usuarioActual);
      }
    } else if (viewModel.esEmpleado) {
      final usuarioId = viewModel.idUsuarioParaInventario;
      if (usuarioId != null) {
        await _mostrarSeleccionProductos(
          context,
          viewModel,
          usuarioId,
          viewModel.usuarioActual?.nombre ?? 'Mi inventario',
        );
      }
    }
  }

  Future<void> _mostrarSeleccionUsuarios(
    BuildContext context,
    InventoryViewModel viewModel,
  ) async {
    try {
      final usuarios = await viewModel.obtenerTodosLosUsuarios();
      final usuariosDisponibles =
          usuarios
              .where(
                (user) =>
                    user.tipoUsuario == 'restaurante' ||
                    user.tipoUsuario == 'cocina_central',
              )
              .toList();

      if (usuariosDisponibles.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron usuarios disponibles'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        context.pushNamed('userSelection', extra: usuariosDisponibles);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar usuarios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _mostrarSeleccionCocinas(
    BuildContext context,
    InventoryViewModel viewModel,
    User usuario,
  ) async {
    try {
      final cocinas = await viewModel.obtenerCocinasDeUsuario(usuario.id);

      if (cocinas.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron cocinas para este usuario'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        context.pushNamed(
          'kitchenSelection',
          extra: {'cocinas': cocinas, 'userName': usuario.nombre},
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar cocinas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _mostrarSeleccionProductos(
    BuildContext context,
    InventoryViewModel viewModel,
    int usuarioId,
    String nombreCocina,
  ) async {
    try {
      List<Producto> productos;
      if (viewModel.esEmpleado) {
        productos = await viewModel.obtenerProductosParaEmpleado();
      } else {
        await viewModel.cargarProductosDisponibles();
        productos = viewModel.state.productosDisponibles;
      }

      if (productos.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se encontraron productos disponibles'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        context.pushNamed(
          'productSelection',
          extra: {
            'productos': productos,
            'kitchenName': nombreCocina,
            'kitchenId': usuarioId,
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar productos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
