import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/orders/orders_viewmodel/order_form_viewmodel.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/core/services/event_bus_service.dart';

class OrderFormScreen extends StatefulWidget {
  final int pedidoId;

  const OrderFormScreen({super.key, required this.pedidoId});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notasController = TextEditingController();
  final _motivoCancelacionController = TextEditingController();
  final _tipoPedidoController = TextEditingController();

  bool _urgente = false;
  String? _estado;
  DateTime? _fechaEntregaEstimada;
  DateTime? _fechaEntregaReal;
  String? _tipoPedido;

  final EventBusService _eventBus = EventBusService();
  bool _datosInicializados = false;

  @override
  void dispose() {
    _notasController.dispose();
    _motivoCancelacionController.dispose();
    _tipoPedidoController.dispose();
    super.dispose();
  }

  void _inicializarDatos(OrderFormViewModel viewModel) {
    if (_datosInicializados || viewModel.pedido == null) return;

    final pedido = viewModel.pedido!;
    setState(() {
      _notasController.text = pedido.notas ?? '';
      _motivoCancelacionController.text = pedido.motivoCancelacion ?? '';
      _tipoPedidoController.text = pedido.tipoPedido;
      _urgente = pedido.urgente;
      _estado = pedido.estado;
      _tipoPedido = pedido.tipoPedido;

      if (pedido.fechaEntregaEstimada != null) {
        _fechaEntregaEstimada = DateTime.parse(pedido.fechaEntregaEstimada!);
      }
      if (pedido.fechaEntregaReal != null) {
        _fechaEntregaReal = DateTime.parse(pedido.fechaEntregaReal!);
      }

      _datosInicializados = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = OrderFormViewModel();
        viewModel.cargarPedido(widget.pedidoId);
        return viewModel;
      },
      child: Consumer<OrderFormViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.pedido != null && !_datosInicializados) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _inicializarDatos(viewModel);
            });
          }

          return ResponsiveScaffold(
            title: 'Editar Pedido #${widget.pedidoId}',
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrderFormViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset('assets/icons/app_icon.png'),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              strokeWidth: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando información del pedido...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                viewModel.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => viewModel.cargarPedido(widget.pedidoId),
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pedido = viewModel.pedido;
    if (pedido == null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontró el pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 24 : 16),
          child: Form(
            key: _formKey,
            child:
                isWideScreen
                    ? _buildWideLayout(context, viewModel, pedido)
                    : _buildNarrowLayout(context, viewModel, pedido),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    OrderFormViewModel viewModel,
    pedido,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(context, pedido),
        const SizedBox(height: 24),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildInfoGeneralCard(context, viewModel, pedido),
                  const SizedBox(height: 16),
                  _buildEstadoCard(context, viewModel, pedido),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  _buildFechasCard(context, viewModel, pedido),
                  const SizedBox(height: 16),
                  _buildDetallesCard(context, viewModel, pedido),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _buildActionButtons(context, viewModel),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    OrderFormViewModel viewModel,
    pedido,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSection(context, pedido),
        const SizedBox(height: 16),
        _buildInfoGeneralCard(context, viewModel, pedido),
        const SizedBox(height: 16),
        _buildEstadoCard(context, viewModel, pedido),
        const SizedBox(height: 16),
        _buildFechasCard(context, viewModel, pedido),
        const SizedBox(height: 16),
        _buildDetallesCard(context, viewModel, pedido),
        const SizedBox(height: 24),
        _buildActionButtons(context, viewModel),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context, pedido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.id}',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pedido.restauranteNombre,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              _buildEstadoBadge(context, pedido.estado),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                context,
                'Total',
                '€${pedido.montoTotal.toStringAsFixed(2)}',
              ),
              _buildInfoChip(
                context,
                'Tipo',
                _getTipoPedidoLabel(pedido.tipoPedido),
              ),
              if (pedido.urgente)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.priority_high,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'URGENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoBadge(BuildContext context, String estado) {
    Color backgroundColor;
    String estadoText;

    switch (estado) {
      case 'pendiente':
        backgroundColor = Colors.orange;
        estadoText = 'Pendiente';
        break;
      case 'en_proceso':
        backgroundColor = Colors.blue;
        estadoText = 'En Proceso';
        break;
      case 'enviado':
        backgroundColor = Colors.purple;
        estadoText = 'Enviado';
        break;
      case 'completado':
        backgroundColor = Colors.green;
        estadoText = 'Completado';
        break;
      case 'cancelado':
        backgroundColor = Colors.red;
        estadoText = 'Cancelado';
        break;
      default:
        backgroundColor = Colors.grey;
        estadoText = estado.replaceAll('_', ' ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        estadoText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildModernCard({
    required BuildContext context,
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildInfoGeneralCard(
    BuildContext context,
    OrderFormViewModel viewModel,
    pedido,
  ) {
    return _buildModernCard(
      context: context,
      title: 'Información General',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildReadOnlyField(context, 'ID del Pedido', pedido.id.toString()),
          const SizedBox(height: 16),
          _buildReadOnlyField(context, 'Restaurante', pedido.restauranteNombre),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            context,
            'Cocina Central',
            pedido.cocinaCentralNombre,
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            context,
            'Fecha del Pedido',
            _formatDate(pedido.fechaPedido),
          ),
          const SizedBox(height: 16),
          _buildReadOnlyField(
            context,
            'Monto Total',
            '€${pedido.montoTotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          if (viewModel.puedeEditarTipoPedido)
            _buildEditableDropdown(
              context: context,
              label: 'Tipo de Pedido',
              value: _tipoPedido,
              items: ['normal', 'urgente', 'especial'],
              onChanged: (value) {
                setState(() {
                  _tipoPedido = value;
                });
              },
              itemBuilder: (tipo) => tipo.toUpperCase(),
            )
          else
            _buildReadOnlyField(
              context,
              'Tipo de Pedido',
              pedido.tipoPedido.toUpperCase(),
            ),
        ],
      ),
    );
  }

  Widget _buildEstadoCard(
    BuildContext context,
    OrderFormViewModel viewModel,
    pedido,
  ) {
    return _buildModernCard(
      context: context,
      title: 'Estado del Pedido',
      icon: Icons.assignment_turned_in_outlined,
      child: Column(
        children: [
          if (viewModel.puedeEditarEstado)
            _buildEditableDropdown(
              context: context,
              label: 'Estado',
              value: _estado,
              items: [
                'pendiente',
                'en_proceso',
                'enviado',
                'completado',
                'cancelado',
              ],
              onChanged: (value) {
                setState(() {
                  _estado = value;
                });
              },
              itemBuilder: (estado) => _getEstadoLabel(estado),
            )
          else
            _buildReadOnlyField(
              context,
              'Estado',
              _getEstadoLabel(pedido.estado),
            ),
          const SizedBox(height: 16),
          if (viewModel.puedeEditarUrgente)
            _buildEditableSwitch(
              context: context,
              label: 'Pedido Urgente',
              subtitle: 'Marca este pedido como prioritario',
              value: _urgente,
              onChanged: (value) {
                setState(() {
                  _urgente = value;
                });
              },
            )
          else
            _buildReadOnlyField(
              context,
              'Urgente',
              pedido.urgente ? 'Sí' : 'No',
            ),
        ],
      ),
    );
  }

  Widget _buildFechasCard(
    BuildContext context,
    OrderFormViewModel viewModel,
    pedido,
  ) {
    return _buildModernCard(
      context: context,
      title: 'Fechas',
      icon: Icons.event_outlined,
      child: Column(
        children: [
          if (viewModel.puedeEditarFechaEntregaEstimada)
            _buildEditableDateField(
              context: context,
              label: 'Fecha Entrega Estimada',
              value: _fechaEntregaEstimada,
              onChanged: (date) {
                setState(() {
                  _fechaEntregaEstimada = date;
                });
              },
            )
          else
            _buildReadOnlyField(
              context,
              'Fecha Entrega Estimada',
              pedido.fechaEntregaEstimada != null
                  ? _formatDate(pedido.fechaEntregaEstimada!)
                  : 'No establecida',
            ),
          const SizedBox(height: 16),
          if (viewModel.puedeEditarFechaEntregaReal)
            _buildEditableDateField(
              context: context,
              label: 'Fecha Entrega Real',
              value: _fechaEntregaReal,
              onChanged: (date) {
                setState(() {
                  _fechaEntregaReal = date;
                });
              },
            )
          else
            _buildReadOnlyField(
              context,
              'Fecha Entrega Real',
              pedido.fechaEntregaReal != null
                  ? _formatDate(pedido.fechaEntregaReal!)
                  : 'No establecida',
            ),
        ],
      ),
    );
  }

  Widget _buildDetallesCard(
    BuildContext context,
    OrderFormViewModel viewModel,
    pedido,
  ) {
    return _buildModernCard(
      context: context,
      title: 'Detalles Adicionales',
      icon: Icons.notes_outlined,
      child: Column(
        children: [
          if (viewModel.puedeEditarNotas)
            _buildEditableTextField(
              context: context,
              controller: _notasController,
              label: 'Notas',
              maxLines: 3,
              hint: 'Agregar notas adicionales sobre el pedido...',
            )
          else
            _buildReadOnlyField(context, 'Notas', pedido.notas ?? 'Sin notas'),
          const SizedBox(height: 16),
          if (viewModel.puedeEditarMotivoCancelacion)
            _buildEditableTextField(
              context: context,
              controller: _motivoCancelacionController,
              label: 'Motivo de Cancelación',
              maxLines: 2,
              hint: 'Especificar motivo de cancelación...',
            )
          else if (pedido.motivoCancelacion != null &&
              pedido.motivoCancelacion!.isNotEmpty)
            _buildReadOnlyField(
              context,
              'Motivo de Cancelación',
              pedido.motivoCancelacion!,
            ),
        ],
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
          decoration: InputDecoration(
            hintText: hint,
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

  Widget _buildEditableDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark ? Theme.of(context).colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_calendar,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? _formatDate(value.toIso8601String())
                        : 'Seleccionar fecha',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          value != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    OrderFormViewModel viewModel,
  ) {
    if (!viewModel.tieneAlgunCampoEditable) {
      return _buildSoloLecturaMessage(context);
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                viewModel.isLoading ? null : () => _guardarCambios(viewModel),
            icon:
                viewModel.isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.save),
            label: Text(
              viewModel.isLoading ? 'Guardando...' : 'Guardar Cambios',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoloLecturaMessage(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formulario de Solo Lectura',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'No tienes permisos para editar ningún campo de este pedido.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'enviado':
        return 'Enviado';
      case 'completado':
        return 'Completado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return estado;
    }
  }

  String _getTipoPedidoLabel(String tipo) {
    switch (tipo) {
      case 'normal':
        return 'Normal';
      case 'urgente':
        return 'Urgente';
      case 'especial':
        return 'Especial';
      default:
        return tipo;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _guardarCambios(OrderFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    final cambios = <String, dynamic>{};

    if (viewModel.puedeEditarNotas) {
      cambios['notas'] = _notasController.text;
    }

    if (viewModel.puedeEditarUrgente) {
      cambios['urgente'] = _urgente;
    }

    if (viewModel.puedeEditarEstado && _estado != null) {
      cambios['estado'] = _estado;
    }

    if (viewModel.puedeEditarTipoPedido && _tipoPedido != null) {
      cambios['tipoPedido'] = _tipoPedido;
    }

    if (viewModel.puedeEditarFechaEntregaEstimada &&
        _fechaEntregaEstimada != null) {
      cambios['fechaEntregaEstimada'] =
          _fechaEntregaEstimada!.toIso8601String();
    }

    if (viewModel.puedeEditarFechaEntregaReal && _fechaEntregaReal != null) {
      cambios['fechaEntregaReal'] = _fechaEntregaReal!.toIso8601String();
    }

    if (viewModel.puedeEditarMotivoCancelacion) {
      cambios['motivoCancelacion'] = _motivoCancelacionController.text;
    }

    final resultado = await viewModel.guardarCambios(cambios);

    if (mounted) {
      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Cambios guardados exitosamente'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        _eventBus.publishRefresh(
          RefreshEventType.orders,
          data: {'pedidoId': widget.pedidoId},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Error: ${viewModel.error ?? "No se pudieron guardar los cambios"}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
