import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smk_product_app/pages/profile_page.dart';
import 'package:smk_product_app/providers/cart_provider.dart';
import 'package:smk_product_app/providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchC = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<ProductProvider>().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = context
        .watch<ProductProvider>()
        .products; // Menggunakan ProductProvider untuk mendapatkan produk yang difilter (Ini juga diubah)

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            title: const Text("SMK Product App"),
            actions: [
              IconButton(
                onPressed: () {
                  context.goNamed(AppRoutes.cartPage);
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart_outlined),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            return Text(
                              cartProvider.totalQty
                                  .toString(), // Ganti dengan jumlah item di keranjang
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  context.pushNamed(AppRoutes.profilePage);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Katalog Produk",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Cari produk dan lihat detailnya. Ini pondasi untuk Provider, API, dan Firebase.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: TextField(
                controller: _searchC,
                onChanged: (v) {
                  context.read<ProductProvider>().setQuery(
                    v,
                  ); // Memperbarui query di ProductProvider (Ini juga diubah)
                },
                decoration: InputDecoration(
                  hintText: "Cari nama, kategori, atau deskripsi",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = filtered[index];
                return ProductCard(
                  product: item,
                  onTap: () {
                    context.goNamed(
                      // Awalnya pushNamed
                      AppRoutes.productDetailName,
                      pathParameters: {'id': item.id.toString()},
                    );
                  },
                );
              }, childCount: filtered.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.74,
              ),
            ),
          ),
        ],
      ),
    );
  }
}