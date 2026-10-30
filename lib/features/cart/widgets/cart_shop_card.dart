import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/cart_model.dart';
import 'cart_item_tile.dart';

class CartShopCard extends StatelessWidget {
  final CartShopGroup shopGroup;
  final ValueChanged<bool> onShopCheckChanged;
  final VoidCallback onShopHeaderTap;
  final void Function(String itemId, bool value) onItemCheckChanged;
  final void Function(String itemId) onItemDelete;
  final void Function(String itemId, int delta) onItemQuantityDelta;
  final void Function(String itemId, int days) onItemRentalDurationChanged;

  const CartShopCard({
    super.key,
    required this.shopGroup,
    required this.onShopCheckChanged,
    required this.onShopHeaderTap,
    required this.onItemCheckChanged,
    required this.onItemDelete,
    required this.onItemQuantityDelta,
    required this.onItemRentalDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllShopSelected = shopGroup.isAllSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          // Header Toko (Checkbox Toko + Avatar Inisial + Nama Seller & Kota tanpa icon centang + '>')
          Row(
            children: [
              InkWell(
                onTap: () => onShopCheckChanged(!isAllShopSelected),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isAllShopSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isAllShopSelected
                          ? AppColors.primary
                          : const Color(0xFFD0C4C4),
                      width: 1.5,
                    ),
                  ),
                  child: isAllShopSelected
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  shopGroup.shopInitial,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onShopHeaderTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopGroup.shopName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shopGroup.sellerCity,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onShopHeaderTap,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider, height: 1),

          // Daftar Produk dalam Toko
          ...List.generate(shopGroup.items.length, (index) {
            final item = shopGroup.items[index];
            return Column(
              children: [
                CartItemTile(
                  item: item,
                  onCheckChanged: (val) => onItemCheckChanged(item.id, val),
                  onDeleteTap: () => onItemDelete(item.id),
                  onQuantityDelta: (delta) =>
                      onItemQuantityDelta(item.id, delta),
                  onRentalDurationSelected: (days) =>
                      onItemRentalDurationChanged(item.id, days),
                ),
                if (index < shopGroup.items.length - 1)
                  const Divider(color: AppColors.divider, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}