import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/supplier_model.dart';

class SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardDark, AppColors.surfaceDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: supplier.isActivo
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildContactInfo(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: supplier.isActivo
                  ? [AppColors.primary, AppColors.secondary]
                  : [AppColors.error, AppColors.warning],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.business,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supplier.nombre,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              if (supplier.contacto != null)
                Text(
                  'Contacto: ${supplier.contacto}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: supplier.isActivo
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            supplier.isActivo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: supplier.isActivo ? AppColors.success : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    final List<Widget> contactWidgets = [];

    if (supplier.email != null && supplier.email!.isNotEmpty) {
      contactWidgets.add(
        Row(
          children: [
            const Icon(Icons.email, color: AppColors.textHint, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                supplier.email!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (supplier.telefono != null && supplier.telefono!.isNotEmpty) {
      if (contactWidgets.isNotEmpty) {
        contactWidgets.add(const SizedBox(height: 4));
      }
      contactWidgets.add(
        Row(
          children: [
            const Icon(Icons.phone, color: AppColors.textHint, size: 14),
            const SizedBox(width: 6),
            Text(
              supplier.telefono!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (supplier.direccion != null && supplier.direccion!.isNotEmpty) {
      if (contactWidgets.isNotEmpty) {
        contactWidgets.add(const SizedBox(height: 4));
      }
      contactWidgets.add(
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.textHint, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                supplier.direccion!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (contactWidgets.isNotEmpty) {
      contactWidgets.add(const SizedBox(height: 12));
    }

    return Column(children: contactWidgets);
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onView != null)
          _ActionButton(
            icon: Icons.visibility,
            color: AppColors.info,
            onPressed: onView!,
          ),
        if (onView != null) const SizedBox(width: 8),
        if (onEdit != null)
          _ActionButton(
            icon: Icons.edit,
            color: AppColors.primary,
            onPressed: onEdit!,
          ),
        if (onEdit != null) const SizedBox(width: 8),
        if (onDelete != null)
          _ActionButton(
            icon: supplier.isActivo ? Icons.delete : Icons.restore,
            color: supplier.isActivo ? AppColors.error : AppColors.success,
            onPressed: onDelete!,
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
