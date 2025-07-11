import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodflow_app/models/user_model.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final User usuario;
  final String? imageTempPath;
  final VoidCallback? onTap;
  final bool isEditable;
  final bool isLoading;

  const ProfileAvatarWidget({
    super.key,
    required this.usuario,
    this.imageTempPath,
    this.onTap,
    this.isEditable = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final double size = 120;
    final bool hasTempImage = imageTempPath != null;
    final bool hasUserImage =
        usuario.imagen != null && usuario.imagen!.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: ClipOval(
            child:
                isLoading
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
                    : hasTempImage
                    ? Image.file(
                      File(imageTempPath!),
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    )
                    : hasUserImage
                    ? Image.network(
                      usuario.imagen!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, _, __) => _buildInitials(),
                    )
                    : _buildInitials(),
          ),
        ),
        if (isEditable && onTap != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials =
        usuario.nombre.isNotEmpty
            ? usuario.nombre
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0] : '')
                .join('')
            : usuario.email[0].toUpperCase();

    return Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
      ),
    );
  }
}
