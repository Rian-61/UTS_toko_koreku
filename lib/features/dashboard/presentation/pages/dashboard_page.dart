import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/constants/app_colors.dart';
 
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
 
class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Koreku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, product, _) {
          if (product.status == ProductStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (product.status == ProductStatus.error) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(product.errorMessage ?? 'Error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => product.loadProducts(), child: const Text('Coba Lagi')),
            ]));
          }
          return Column(
            children: [
              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: product.setSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              // CATEGORY FILTER
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: product.categories.length,
                  itemBuilder: (_, i) {
                    final cat = product.categories[i];
                    final isSelected = (cat == 'Semua' && product.selectedCategory.isEmpty) ||
                        cat == product.selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => product.setCategory(cat == 'Semua' ? '' : cat),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // PRODUCT GRID
              Expanded(
                child: product.products.isEmpty
                    ? const Center(child: Text('Produk tidak ditemukan'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: product.products.length,
                        itemBuilder: (_, i) {
                          final p = product.products[i];
                          final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // GAMBAR
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)
                                    ),
                                    child: Image.network(
                                      p.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // TEKS
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          fmt.format(p.price),
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12
                                          ),
                                        ),
                                        Text(
                                          'Stok: ${p.stock}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
