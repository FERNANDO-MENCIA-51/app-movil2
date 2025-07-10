import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/producto_model.dart';

class ProductoCard extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback? onTap;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductoCard({
    super.key,
    required this.producto,
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
          color: producto.isActivo
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
                _buildProductInfo(),
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
              colors: producto.isActivo
                  ? [AppColors.primary, AppColors.secondary]
                  : [AppColors.error, AppColors.warning],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.inventory_2,
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
                producto.nombreCompleto,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              if (producto.categoria != null)
                Text(
                  'Categoría: ${producto.categoria}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: producto.isActivo
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                producto.isActivo ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: producto.isActivo
                      ? AppColors.success
                      : AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (producto.isStockBajo && producto.isActivo)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Stock Bajo',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, color: AppColors.textHint, size: 14),
            const SizedBox(width: 6),
            Text(
              producto.precioFormateado,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.inventory, color: AppColors.textHint, size: 14),
            const SizedBox(width: 6),
            Text(
              'Stock: ${producto.stock}',
              style: TextStyle(
                color: producto.isStockBajo
                    ? AppColors.warning
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: producto.isStockBajo
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.textHint,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Ingreso: ${producto.fechaFormateada}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (producto.hasCodeBarra)
              Row(
                children: [
                  const Icon(
                    Icons.qr_code,
                    color: AppColors.textHint,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    producto.codeBarra!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.business, color: AppColors.textHint, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Proveedor: ${producto.supplier.name}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        if (onEdit != null)
          _ActionButton(
            icon: Icons.edit,
            color: AppColors.primary,
            onPressed: onEdit!,
          ),
        if (onEdit != null) const SizedBox(width: 8),
        if (onDelete != null)
          _ActionButton(
            icon: producto.isActivo ? Icons.delete : Icons.restore,
            color: producto.isActivo ? AppColors.error : AppColors.success,
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
