class ProfileModel {
  final bool isLoading;
  final String? error;
  final bool isEditMode;
  final bool isPasswordChangeMode;
  final bool isImagePickerActive;
  final String? imagePath;
  final bool isSaving;
  final bool hasPermissionEmployees;
  final List<EmployeeItem> employees;
  final Map<int, Map<String, bool>> employeePermissions;
  final bool permissionsChanged;
  final bool isCreatingEmployee;
  final Map<String, bool> newEmployeePermissions;

  ProfileModel({
    this.isLoading = false,
    this.error,
    this.isEditMode = false,
    this.isPasswordChangeMode = false,
    this.isImagePickerActive = false,
    this.imagePath,
    this.isSaving = false,
    this.hasPermissionEmployees = false,
    this.employees = const [],
    this.employeePermissions = const {},
    this.permissionsChanged = false,
    this.isCreatingEmployee = false,
    this.newEmployeePermissions = const {},
  });

  ProfileModel copyWith({
    bool? isLoading,
    String? error,
    bool? isEditMode,
    bool? isPasswordChangeMode,
    bool? isImagePickerActive,
    String? imagePath,
    bool? isSaving,
    bool? hasPermissionEmployees,
    List<EmployeeItem>? employees,
    Map<int, Map<String, bool>>? employeePermissions,
    bool? permissionsChanged,
    bool? isCreatingEmployee,
    Map<String, bool>? newEmployeePermissions,
  }) {
    return ProfileModel(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditMode: isEditMode ?? this.isEditMode,
      isPasswordChangeMode: isPasswordChangeMode ?? this.isPasswordChangeMode,
      isImagePickerActive: isImagePickerActive ?? this.isImagePickerActive,
      imagePath: imagePath ?? this.imagePath,
      isSaving: isSaving ?? this.isSaving,
      hasPermissionEmployees:
          hasPermissionEmployees ?? this.hasPermissionEmployees,
      employees: employees ?? this.employees,
      employeePermissions: employeePermissions ?? this.employeePermissions,
      permissionsChanged: permissionsChanged ?? this.permissionsChanged,
      isCreatingEmployee: isCreatingEmployee ?? this.isCreatingEmployee,
      newEmployeePermissions:
          newEmployeePermissions ?? this.newEmployeePermissions,
    );
  }
}

class EmployeeItem {
  final int id;
  final String nombre;
  final String email;
  final String? imagen;
  final int? permisosId;

  EmployeeItem({
    required this.id,
    required this.nombre,
    required this.email,
    this.imagen,
    this.permisosId,
  });
}

class PermissionCategory {
  final String name;
  final String description;
  final List<PermissionItem> permissions;

  PermissionCategory({
    required this.name,
    required this.description,
    required this.permissions,
  });
}

class PermissionItem {
  final String key;
  final String name;
  final String description;

  PermissionItem({
    required this.key,
    required this.name,
    required this.description,
  });
}
