import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import '../products_viewmodel/product_detail_view_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productoId;

  const ProductDetailScreen({super.key, required this.productoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ProductDetailViewModel();
        viewModel.cargarProducto(productoId);
        return viewModel;
      },
      child: Consumer<ProductDetailViewModel>(
        builder: (context, viewModel, _) {
          return ResponsiveScaffold(
            title: 'Detalle del Producto',
            body: _buildBody(context, viewModel),
            showBackButton: true,
            actions: _buildActions(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductDetailViewModel viewModel) {
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

    if (viewModel.error != null) {
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
              onPressed: () => viewModel.cargarProducto(productoId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final producto = viewModel.producto;
    if (producto == null) {
      return const Center(child: Text('No se encontró el producto'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: _buildProductImage(viewModel),
                ),
              ),
              if (producto.imagenQrUrl != null)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Código QR',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                _buildDownloadButton(context, viewModel),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildQrImage(viewModel),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (producto.categoriaNombre != null)
                    Chip(
                      label: Text(
                        producto.categoriaNombre!,
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.amber.shade100,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Precio Final',
                          '€${producto.precioFinal.toStringAsFixed(2)}',
                          Colors.green.shade100,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Estado',
                          producto.isActive ? 'Activo' : 'Inactivo',
                          producto.isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Precio Base',
                          '€${producto.precio.toStringAsFixed(2)}',
                          Colors.blue.shade50,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoItem(
                          context,
                          'Impuestos',
                          '${producto.impuestos.toStringAsFixed(2)}%',
                          Colors.blue.shade50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    context,
                    'Unidad de Medida',
                    producto.unidadMedida,
                    Colors.amber.shade50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    producto.descripcion ?? 'Sin descripción',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.puedeEditarProducto)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/products/edit/${producto.id}');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Editar Producto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductImage(ProductDetailViewModel viewModel) {
    final imagenUrl = viewModel.obtenerImagenUrlConTimestamp();

    if (imagenUrl != null && imagenUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imagenUrl,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              height: 250,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
      );
    } else {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50),
      );
    }
  }

  Widget _buildQrImage(ProductDetailViewModel viewModel) {
    final qrUrl = viewModel.obtenerImagenQrUrlConTimestamp();

    if (qrUrl != null && qrUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: qrUrl,
        height: 150,
        fit: BoxFit.contain,
        placeholder:
            (context, url) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: 150,
              color: Colors.grey[300],
              child: const Icon(Icons.qr_code_2, size: 50),
            ),
      );
    } else {
      return Container(
        height: 150,
        color: Colors.grey[300],
        child: const Icon(Icons.qr_code_2, size: 50),
      );
    }
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) {
    if (!viewModel.puedeEditarProducto || viewModel.producto == null) {
      return [];
    }

    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          context.push('/products/edit/${viewModel.producto!.id}');
        },
      ),
    ];
  }

  Widget _buildDownloadButton(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.download),
        tooltip: 'Opciones de descarga',
        onSelected:
            (value) => _manejarDescargarEscritorio(context, viewModel, value),
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'descargas',
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined),
                    SizedBox(width: 8),
                    Text('Carpeta Descargas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'documentos',
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined),
                    SizedBox(width: 8),
                    Text('Carpeta Documentos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'escritorio',
                child: Row(
                  children: [
                    Icon(Icons.desktop_windows),
                    SizedBox(width: 8),
                    Text('Escritorio'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'personalizado',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder),
                    SizedBox(width: 8),
                    Text('Ubicación personalizada'),
                  ],
                ),
              ),
            ],
      );
    } else {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.download),
        tooltip: 'Opciones de QR',
        onSelected: (value) => _manejarAccionMovil(context, viewModel, value),
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: 'descargar',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Descargar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'compartir',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Compartir'),
                  ],
                ),
              ),
            ],
      );
    }
  }

  void _manejarDescargarEscritorio(
    BuildContext context,
    ProductDetailViewModel viewModel,
    String opcion,
  ) {
    switch (opcion) {
      case 'descargas':
        _descargarImagenQrEscritorio(
          context,
          viewModel,
          TipoDirectorioEscritorio.descargas,
        );
        break;
      case 'documentos':
        _descargarImagenQrEscritorio(
          context,
          viewModel,
          TipoDirectorioEscritorio.documentos,
        );
        break;
      case 'escritorio':
        _descargarImagenQrEscritorio(
          context,
          viewModel,
          TipoDirectorioEscritorio.escritorio,
        );
        break;
      case 'personalizado':
        _mostrarDialogoRutaPersonalizada(context, viewModel);
        break;
    }
  }

  void _manejarAccionMovil(
    BuildContext context,
    ProductDetailViewModel viewModel,
    String accion,
  ) {
    switch (accion) {
      case 'descargar':
        _descargarImagenQrMovil(context, viewModel);
        break;
      case 'compartir':
        _compartirImagenQr(context, viewModel);
        break;
    }
  }

  void _mostrarDialogoRutaPersonalizada(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ubicación personalizada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Introduce la ruta completa donde deseas guardar el archivo:',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText:
                        Platform.isWindows
                            ? 'C:\\Users\\usuario\\Desktop'
                            : '/home/usuario/Escritorio',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _descargarImagenQrEscritorio(
                    context,
                    viewModel,
                    TipoDirectorioEscritorio.personalizado,
                    controller.text,
                  );
                },
                child: const Text('Descargar'),
              ),
            ],
          ),
    );
  }

  Future<void> _descargarImagenQrEscritorio(
    BuildContext context,
    ProductDetailViewModel viewModel,
    TipoDirectorioEscritorio tipo, [
    String? rutaPersonalizada,
  ]) async {
    final qrUrl = viewModel.obtenerImagenQrUrlConTimestamp();
    if (qrUrl == null || qrUrl.isEmpty) {
      _mostrarMensaje(context, 'No hay imagen QR disponible', isError: true);
      return;
    }

    try {
      _mostrarMensaje(context, 'Descargando imagen QR...');

      final dio = Dio();
      final response = await dio.get(
        qrUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      Directory? directory = await _obtenerDirectorioEscritorio(
        tipo,
        rutaPersonalizada,
      );

      if (directory == null) {
        _mostrarMensaje(
          context,
          'No se pudo acceder al directorio especificado',
          isError: true,
        );
        return;
      }

      final producto = viewModel.producto!;
      final fileName =
          'QR_${producto.nombre.replaceAll(RegExp(r'[^\w\s-]'), '')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(response.data);

      _mostrarMensaje(context, 'Imagen QR guardada en: ${file.path}');
    } catch (e) {
      _mostrarMensaje(
        context,
        'Error al descargar la imagen: $e',
        isError: true,
      );
    }
  }

  Future<void> _descargarImagenQrMovil(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) async {
    final qrUrl = viewModel.obtenerImagenQrUrlConTimestamp();
    if (qrUrl == null || qrUrl.isEmpty) {
      _mostrarMensaje(context, 'No hay imagen QR disponible', isError: true);
      return;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        bool permisoOtorgado = false;

        if (androidInfo.version.sdkInt >= 33) {
          permisoOtorgado = true;
        } else if (androidInfo.version.sdkInt >= 30) {
          final status = await Permission.manageExternalStorage.request();
          permisoOtorgado = status.isGranted;

          if (!permisoOtorgado) {
            final storageStatus = await Permission.storage.request();
            permisoOtorgado = storageStatus.isGranted;
          }
        } else {
          final status = await Permission.storage.request();
          permisoOtorgado = status.isGranted;
        }

        if (!permisoOtorgado) {
          _mostrarMensaje(
            context,
            'Se requieren permisos de almacenamiento para descargar',
            isError: true,
          );
          return;
        }
      }

      _mostrarMensaje(context, 'Descargando imagen QR...');

      final dio = Dio();
      final response = await dio.get(
        qrUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        _mostrarMensaje(
          context,
          'No se pudo acceder al directorio de descarga',
          isError: true,
        );
        return;
      }

      final producto = viewModel.producto!;
      final fileName =
          'QR_${producto.nombre.replaceAll(RegExp(r'[^\w\s-]'), '')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(response.data);

      _mostrarMensaje(context, 'Imagen QR descargada en: ${file.path}');
    } catch (e) {
      _mostrarMensaje(
        context,
        'Error al descargar la imagen: $e',
        isError: true,
      );
    }
  }

  Future<void> _compartirImagenQr(
    BuildContext context,
    ProductDetailViewModel viewModel,
  ) async {
    final qrUrl = viewModel.obtenerImagenQrUrlConTimestamp();
    if (qrUrl == null || qrUrl.isEmpty) {
      _mostrarMensaje(context, 'No hay imagen QR disponible', isError: true);
      return;
    }

    try {
      _mostrarMensaje(context, 'Preparando imagen para compartir...');

      final dio = Dio();
      final response = await dio.get(
        qrUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final tempDir = await getTemporaryDirectory();
      final producto = viewModel.producto!;
      final fileName =
          'QR_${producto.nombre.replaceAll(RegExp(r'[^\w\s-]'), '')}.png';
      final file = File('${tempDir.path}${Platform.pathSeparator}$fileName');

      await file.writeAsBytes(response.data);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Código QR del producto: ${producto.nombre}');
    } catch (e) {
      _mostrarMensaje(
        context,
        'Error al compartir la imagen: $e',
        isError: true,
      );
    }
  }

  Future<Directory?> _obtenerDirectorioEscritorio(
    TipoDirectorioEscritorio tipo, [
    String? rutaPersonalizada,
  ]) async {
    try {
      switch (tipo) {
        case TipoDirectorioEscritorio.descargas:
          if (Platform.isWindows) {
            final userProfile = Platform.environment['USERPROFILE'];
            if (userProfile != null) {
              final downloadsDir = Directory('$userProfile\\Downloads');
              if (await downloadsDir.exists()) return downloadsDir;
            }
          } else if (Platform.isMacOS || Platform.isLinux) {
            final home = Platform.environment['HOME'];
            if (home != null) {
              final downloadsDir = Directory('$home/Downloads');
              if (await downloadsDir.exists()) return downloadsDir;
            }
          }
          return await getApplicationDocumentsDirectory();

        case TipoDirectorioEscritorio.documentos:
          return await getApplicationDocumentsDirectory();

        case TipoDirectorioEscritorio.escritorio:
          if (Platform.isWindows) {
            final userProfile = Platform.environment['USERPROFILE'];
            if (userProfile != null) {
              final desktopDir = Directory('$userProfile\\Desktop');
              if (await desktopDir.exists()) return desktopDir;
            }
          } else if (Platform.isMacOS || Platform.isLinux) {
            final home = Platform.environment['HOME'];
            if (home != null) {
              final desktopDir = Directory('$home/Desktop');
              if (await desktopDir.exists()) return desktopDir;
            }
          }
          return await getApplicationDocumentsDirectory();

        case TipoDirectorioEscritorio.personalizado:
          if (rutaPersonalizada != null && rutaPersonalizada.isNotEmpty) {
            final dir = Directory(rutaPersonalizada);
            if (await dir.exists()) {
              return dir;
            } else {
              throw Exception('La ruta especificada no existe');
            }
          }
          return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      return await getApplicationDocumentsDirectory();
    }
  }

  void _mostrarMensaje(
    BuildContext context,
    String mensaje, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}

enum TipoDirectorioEscritorio {
  descargas,
  documentos,
  escritorio,
  personalizado,
}
