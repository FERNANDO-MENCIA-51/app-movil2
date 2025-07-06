import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/compra_model.dart';

class CompraCard extends StatelessWidget {
  final CompraModel compra;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;

  const CompraCard({
    super.key,
    required this.compra,
    this.onTap,
    this.onView,
    this.onDelete,
    this.onRestore,
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
          color: compra.isActivo
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
                _buildCompraInfo(),
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
              colors: compra.isActivo
                  ? [AppColors.primary, AppColors.secondary]
                  : [AppColors.error, AppColors.warning],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.shopping_cart,
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
                compra.supplier.nombre,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fecha: ${compra.fechaFormateada}',
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
            color: compra.isActivo
                ? AppColors.success.withValues(alpha: 0.2)
                : AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            compra.isActivo ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: compra.isActivo ? AppColors.success : AppColors.error,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompraInfo() {
    return Row(
      children: [
        const Icon(Icons.attach_money, color: AppColors.textHint, size: 14),
        const SizedBox(width: 6),
        Text(
          'Total: S/ ${compra.totalCompra.toStringAsFixed(2)}',
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const Icon(Icons.info_outline, color: AppColors.textHint, size: 14),
        const SizedBox(width: 6),
        Text(
          compra.estado,
          style: TextStyle(
            color: compra.isActivo ? AppColors.success : AppColors.error,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
        if (compra.isActivo && onDelete != null)
          _ActionButton(
            icon: Icons.delete,
            color: AppColors.error,
            onPressed: onDelete!,
          ),
        if (!compra.isActivo && onRestore != null)
          _ActionButton(
            icon: Icons.restore,
            color: AppColors.success,
            onPressed: onRestore!,
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
