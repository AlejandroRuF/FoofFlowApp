import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodflow_app/features/shared/widgets/responsive_scaffold_widget.dart';
import 'package:foodflow_app/features/profile/profile_view/widgets/profile_avatar_widget.dart';
import 'package:foodflow_app/features/profile/profile_view/widgets/profile_field_widget.dart';
import 'package:foodflow_app/features/profile/profile_view/widgets/employee_card_widget.dart';
import 'package:foodflow_app/features/profile/profile_view/widgets/create_employee_form_widget.dart';
import 'package:image_picker/image_picker.dart';

import '../profile_viewmodel/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<int, bool> _expandedEmployees = {};

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, _) {
          final usuario = viewModel.usuario;

          if (usuario == null) {
            return const ResponsiveScaffold(
              title: 'Perfil',
              body: Center(
                child: Text('No se encontró información del usuario'),
              ),
            );
          }

          return ResponsiveScaffold(
            title: 'Perfil',
            body: _buildBody(context, viewModel),
            floatingActionButton: _buildFloatingActionButton(
              context,
              viewModel,
            ),
          );
        },
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    if (viewModel.state.permissionsChanged) {
      return FloatingActionButton.extended(
        onPressed: () => _guardarPermisosEmpleados(context, viewModel),
        label: const Text('Guardar cambios'),
        icon: const Icon(Icons.save),
      );
    }

    if (viewModel.state.hasPermissionEmployees &&
        !viewModel.state.isCreatingEmployee) {
      return FloatingActionButton.extended(
        onPressed: () => viewModel.iniciarCreacionEmpleado(),
        label: const Text('Crear empleado'),
        icon: const Icon(Icons.person_add),
      );
    }

    return null;
  }

  Widget _buildBody(BuildContext context, ProfileViewModel viewModel) {
    if (viewModel.state.isLoading) {
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

    if (viewModel.state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              viewModel.state.error!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => viewModel.refrescarDatos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final usuario = viewModel.usuario!;

    return RefreshIndicator(
      onRefresh: () async => viewModel.refrescarDatos(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, viewModel, usuario),
            const SizedBox(height: 24),
            _buildProfileInfo(context, viewModel, usuario),
            if (viewModel.state.hasPermissionEmployees) ...[
              const SizedBox(height: 32),
              _buildEmployeeSection(context, viewModel),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ProfileViewModel viewModel,
    dynamic usuario,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatarWidget(
          usuario: usuario,
          imageTempPath: viewModel.state.imagePath,
          onTap: () => _mostrarOpcionesFoto(context, viewModel),
          isLoading:
              viewModel.state.isSaving && viewModel.state.imagePath != null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario.nombre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                usuario.email,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _obtenerNombreTipoUsuario(usuario.tipoUsuario),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (isSmallScreen)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _editarPerfil(context, viewModel),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _cambiarPassword(context, viewModel),
                      icon: const Icon(Icons.lock),
                      label: const Text('Cambiar contraseña'),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _editarPerfil(context, viewModel),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _cambiarPassword(context, viewModel),
                      icon: const Icon(Icons.lock),
                      label: const Text('Cambiar contraseña'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(
    BuildContext context,
    ProfileViewModel viewModel,
    dynamic usuario,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información personal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProfileFieldWidget(
              label: 'Teléfono',
              value: usuario.telefono ?? 'No especificado',
              icon: Icons.phone,
            ),
            ProfileFieldWidget(
              label: 'Dirección',
              value: usuario.direccion ?? 'No especificada',
              icon: Icons.location_on,
            ),
            if (usuario.empresaAsociada != null &&
                usuario.empresaAsociada!.isNotEmpty)
              ProfileFieldWidget(
                label: 'Empresa',
                value: usuario.empresaAsociada!,
                icon: Icons.business,
              ),
            ProfileFieldWidget(
              label: 'Fecha de creación',
              value: usuario.fechaCreacion ?? 'No disponible',
              icon: Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeSection(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gestión de empleados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Administra a los empleados y sus permisos en el sistema',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        if (viewModel.state.isCreatingEmployee)
          CreateEmployeeFormWidget(
            viewModel: viewModel,
            onCancel: () => viewModel.cancelarCreacionEmpleado(),
            onCreate: () => _crearEmpleado(context, viewModel),
          )
        else if (viewModel.state.employees.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay empleados asignados',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Los empleados que añadas aparecerán aquí',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children:
                viewModel.state.employees.map((employee) {
                  _expandedEmployees.putIfAbsent(employee.id, () => false);

                  final permissions =
                      viewModel.state.employeePermissions[employee.id] ?? {};

                  return EmployeeCardWidget(
                    employee: employee,
                    expanded: _expandedEmployees[employee.id] ?? false,
                    onToggle: () {
                      setState(() {
                        _expandedEmployees[employee.id] =
                            !(_expandedEmployees[employee.id] ?? false);
                      });
                    },
                    permissions: permissions,
                    onPermissionChanged: (key, value) {
                      viewModel.cambiarPermisoEmpleado(employee.id, key, value);
                    },
                    permissionCategories: viewModel.categoriasPermisos,
                  );
                }).toList(),
          ),
      ],
    );
  }

  Future<void> _crearEmpleado(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    if (viewModel.formKey.currentState?.validate() ?? false) {
      final success = await viewModel.crearEmpleado();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empleado creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.state.error ?? 'Error al crear empleado'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _mostrarOpcionesFoto(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.seleccionarImagen(ImageSource.camera).then((_) {
                    if (viewModel.state.imagePath != null) {
                      _confirmarImagenPerfil(context, viewModel);
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de la galería'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.seleccionarImagen(ImageSource.gallery).then((_) {
                    if (viewModel.state.imagePath != null) {
                      _confirmarImagenPerfil(context, viewModel);
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarImagenPerfil(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Imagen de perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Quieres usar esta imagen como tu foto de perfil?'),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(viewModel.state.imagePath!),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel.resetImagePath();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel.subirImagenPerfil().then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Imagen de perfil actualizada'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    viewModel.refrescarDatos();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al actualizar la imagen'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _editarPerfil(BuildContext context, ProfileViewModel viewModel) {
    context.push('/profile/edit', extra: viewModel.usuario);
  }

  void _cambiarPassword(BuildContext context, ProfileViewModel viewModel) {
    if (viewModel.usuario == null) return;

    final String userEmail = viewModel.usuario!.email;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambiar contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Se enviará un enlace a tu correo electrónico para restablecer tu contraseña.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Correo electrónico: $userEmail',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await viewModel.solicitarCambioPassword(
                  userEmail,
                );

                if (success) {
                  if (mounted) {
                    context.go('/login');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Se ha enviado un enlace a tu correo electrónico',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error al enviar el enlace'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Enviar enlace'),
            ),
          ],
        );
      },
    );
  }

  void _guardarPermisosEmpleados(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    final resultado = await viewModel.guardarPermisosEmpleados();

    if (resultado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permisos guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.state.error ?? 'Error al guardar permisos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _obtenerNombreTipoUsuario(String tipo) {
    switch (tipo) {
      case 'restaurante':
        return 'Restaurante';
      case 'cocina_central':
        return 'Cocina Central';
      case 'administrador':
        return 'Administrador';
      case 'empleado':
        return 'Empleado';
      default:
        return tipo;
    }
  }
}
