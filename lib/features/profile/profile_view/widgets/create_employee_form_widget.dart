import 'package:flutter/material.dart';
import '../../../profile/profile_view/widgets/profile_field_widget.dart';
import '../../../profile/profile_viewmodel/profile_viewmodel.dart';

class CreateEmployeeFormWidget extends StatelessWidget {
  final ProfileViewModel viewModel;
  final VoidCallback onCancel;
  final VoidCallback onCreate;

  const CreateEmployeeFormWidget({
    super.key,
    required this.viewModel,
    required this.onCancel,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 768;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 24 : 16),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(context),
                const SizedBox(height: 24),
                isWideScreen
                    ? _buildWideLayout(context)
                    : _buildNarrowLayout(context),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear nuevo empleado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Complete la información del empleado y configure sus permisos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Cancelar',
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _buildInformacionPersonalCard(context)),
        const SizedBox(width: 24),
        Expanded(flex: 1, child: _buildPermisosCard(context)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      children: [
        _buildInformacionPersonalCard(context),
        const SizedBox(height: 16),
        _buildPermisosCard(context),
      ],
    );
  }

  Widget _buildModernCard({
    required BuildContext context,
    required String title,
    required Widget child,
    required IconData icon,
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
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
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

  Widget _buildInformacionPersonalCard(BuildContext context) {
    return _buildModernCard(
      context: context,
      title: 'Información Personal',
      icon: Icons.person_outline,
      child: Column(
        children: [
          _buildEditableTextField(
            context: context,
            controller: viewModel.nombreController,
            label: 'Nombre completo',
            hint: 'Ingrese el nombre completo del empleado',
            icon: Icons.person,
            required: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildEditableTextField(
            context: context,
            controller: viewModel.emailController,
            label: 'Email',
            hint: 'empleado@empresa.com',
            icon: Icons.email,
            required: true,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El email es requerido';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Email no válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildEditableTextField(
            context: context,
            controller: viewModel.passwordController,
            label: 'Contraseña',
            hint: 'Mínimo 6 caracteres',
            icon: Icons.lock,
            required: true,
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildEditableTextField(
            context: context,
            controller: viewModel.telefonoController,
            label: 'Teléfono',
            hint: '+34 123 456 789',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildEditableTextField(
            context: context,
            controller: viewModel.direccionController,
            label: 'Dirección',
            hint: 'Dirección completa del empleado',
            icon: Icons.location_on,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPermisosCard(BuildContext context) {
    return _buildModernCard(
      context: context,
      title: 'Permisos del Empleado',
      icon: Icons.security,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure los permisos que tendrá el empleado en el sistema',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...viewModel.categoriasPermisos.map(
            (categoria) => _buildPermissionSection(categoria, context),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    bool required = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2.5,
              ),
            ),
            prefixIcon: Icon(
              icon,
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

  Widget _buildPermissionSection(categoria, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(categoria.name),
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                categoria.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            categoria.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...categoria.permissions.map((permiso) {
            final isChecked =
                viewModel.newEmployeePermissions[permiso.key] ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color:
                    isChecked
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isChecked
                          ? Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3)
                          : Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: CheckboxListTile(
                title: Text(
                  permiso.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        isChecked
                            ? Theme.of(context).colorScheme.primary
                            : null,
                  ),
                ),
                subtitle: Text(
                  permiso.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                value: isChecked,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  if (value != null) {
                    viewModel.cambiarPermisoNuevoEmpleado(permiso.key, value);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'productos':
        return Icons.inventory_2_outlined;
      case 'usuarios':
        return Icons.people_outline;
      case 'almacenes':
        return Icons.warehouse_outlined;
      case 'pedidos':
        return Icons.shopping_cart_outlined;
      case 'incidencias':
        return Icons.report_problem_outlined;
      case 'métricas y previsiones':
        return Icons.analytics_outlined;
      default:
        return Icons.security;
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child:
              isSmallScreen
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: viewModel.state.isSaving ? null : onCreate,
                        icon:
                            viewModel.state.isSaving
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.person_add),
                        label: Text(
                          viewModel.state.isSaving
                              ? 'Creando...'
                              : 'Crear empleado',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: viewModel.state.isSaving ? null : onCancel,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: viewModel.state.isSaving ? null : onCancel,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: viewModel.state.isSaving ? null : onCreate,
                        icon:
                            viewModel.state.isSaving
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.person_add),
                        label: Text(
                          viewModel.state.isSaving
                              ? 'Creando...'
                              : 'Crear empleado',
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
