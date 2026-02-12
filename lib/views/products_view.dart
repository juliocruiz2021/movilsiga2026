import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/debug_tools.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';
import 'settings_view.dart';
import 'product_detail_view.dart';
import 'login_view.dart';
import 'widgets/app_themed_background.dart';
import 'widgets/main_navigation_drawer.dart';
import 'widgets/offline_cloud_icon.dart';

class ProductsView extends StatelessWidget {
  const ProductsView({super.key, this.homeBuilder});

  final Widget Function(int sectionIndex)? homeBuilder;

  @override
  Widget build(BuildContext context) {
    return _ProductsScaffold(homeBuilder: homeBuilder);
  }
}

class _ProductsScaffold extends StatelessWidget {
  const _ProductsScaffold({this.homeBuilder});

  final Widget Function(int sectionIndex)? homeBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: homeBuilder == null
          ? null
          : MainNavigationDrawer(
              selectedIndex: MainMenuIndex.products,
              onDestinationSelected: (index) {
                debugTrace(
                  'NAV',
                  'Drawer tap from Products. target=$index current=${MainMenuIndex.products}',
                );
                Navigator.of(context).pop();
                if (index == MainMenuIndex.products) return;
                _goToHomeSection(context, index);
              },
              onOpenSettings: () {
                debugTrace('NAV', 'Open settings from Products');
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsView()));
              },
              onLogout: () {
                debugTrace('NAV', 'Logout from Products');
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          const OfflineCloudIcon(padding: EdgeInsets.only(right: 2)),
          Consumer<ProductsViewModel>(
            builder: (context, vm, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: vm.isSyncing
                        ? null
                        : () async {
                            await vm.syncCatalog(incremental: false);
                            if (!context.mounted) return;
                            final message =
                                vm.lastSyncError ?? 'Catálogo descargado.';
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          },
                    icon: const Icon(Icons.cloud_download_outlined),
                  ),
                  IconButton(
                    onPressed: vm.isSyncing
                        ? null
                        : () async {
                            await vm.syncCatalog(incremental: true);
                            if (!context.mounted) return;
                            final message =
                                vm.lastSyncError ?? 'Sincronización completa.';
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          },
                    icon: const Icon(Icons.sync),
                  ),
                  IconButton(
                    onPressed: vm.isDownloadingPhotos
                        ? null
                        : () async {
                            await vm.downloadAllPhotos();
                            if (!context.mounted) return;
                            final message =
                                vm.lastSyncError ?? 'Fotos descargadas.';
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(message)));
                          },
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AppThemedBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const _Toolbar(),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _ProductGrid(isWide: isWide),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                const _Toolbar(),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProductGrid(isWide: isWide),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SafeArea(
                    top: false,
                    child: _CheckoutBar(theme: theme),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _goToHomeSection(BuildContext context, int index) {
    final builder = homeBuilder;
    if (builder == null) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => builder(index)));
  }

  Future<void> _logout(BuildContext context) async {
    final productsVm = context.read<ProductsViewModel>();
    productsVm.resetFilters(reload: false);
    productsVm.resetSession();
    await context.read<AuthViewModel>().clearToken();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginView()));
  }
}

class _Toolbar extends StatefulWidget {
  const _Toolbar();

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsViewModel>(
      builder: (context, vm, _) {
        final palette = context.palette;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        setState(() {});
                        vm.updateSearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar producto',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {});
                                  vm.updateSearch('');
                                },
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: palette.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => vm.updateViewMode(ProductViewMode.grid),
                    icon: Icon(
                      Icons.grid_view,
                      color: vm.viewMode == ProductViewMode.grid
                          ? palette.primary
                          : palette.textMuted,
                    ),
                  ),
                  IconButton(
                    onPressed: () => vm.updateViewMode(ProductViewMode.list),
                    icon: Icon(
                      Icons.view_list,
                      color: vm.viewMode == ProductViewMode.list
                          ? palette.primary
                          : palette.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.categories.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final selected = vm.selectedCategoryId == null;
                      return ChoiceChip(
                        label: const Text('Todas'),
                        selected: selected,
                        onSelected: (_) => vm.updateCategory(null),
                        selectedColor: palette.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? palette.onPrimary
                              : palette.textStrong,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      );
                    }
                    final category = vm.categories[index - 1];
                    final selected = vm.selectedCategoryId == category.id;
                    return ChoiceChip(
                      label: Text(category.nombre),
                      selected: selected,
                      onSelected: (_) => vm.updateCategory(category.id),
                      selectedColor: palette.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? palette.onPrimary
                            : palette.textStrong,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductGrid extends StatefulWidget {
  const _ProductGrid({required this.isWide});

  final bool isWide;

  @override
  State<_ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<_ProductGrid> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 240) {
          context.read<ProductsViewModel>().loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading && vm.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage != null && vm.products.isEmpty) {
          return Center(
            child: Text(
              vm.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        if (vm.viewMode == ProductViewMode.list) {
          final itemCount = vm.products.length + (vm.isLoadingMore ? 1 : 0);
          return ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= vm.products.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final product = vm.products[index];
              return _ProductListTile(product: product);
            },
          );
        }

        final crossAxisCount = widget.isWide ? 4 : 2;
        final itemCount = vm.products.length + (vm.isLoadingMore ? 1 : 0);

        return GridView.builder(
          controller: _controller,
          padding: const EdgeInsets.only(bottom: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.87,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (index >= vm.products.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final product = vm.products[index];
            return _ProductCard(product: product);
          },
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final color = Color(product.colorHex);

    return Consumer<ProductsViewModel>(
      builder: (context, vm, _) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailView(product: product),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child:
                          product.fotoThumbUrl != null &&
                              product.fotoThumbUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _CachedNetworkImage(
                                url: vm.resolveImageUrl(product.fotoThumbUrl),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorWidget: _NoImage(color: color),
                              ),
                            )
                          : _NoImage(color: color),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.textStrong,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${product.precio.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stock ${product.stock.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductListTile extends StatelessWidget {
  const _ProductListTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailView(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.textStrong,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${product.precio.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock ${product.stock.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: color.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 6),
        Text(
          'Sin imagen',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: palette.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CachedNetworkImage extends StatelessWidget {
  const _CachedNetworkImage({
    required this.url,
    required this.fit,
    this.width,
    this.height,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return errorWidget ?? const SizedBox.shrink();
    }

    final cache = DefaultCacheManager();
    return FutureBuilder<FileInfo?>(
      future: cache.getFileFromCache(url),
      builder: (context, snapshot) {
        final cached = snapshot.data?.file;
        if (cached != null) {
          return Image.file(cached, fit: fit, width: width, height: height);
        }
        return Image.network(
          url,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => errorWidget ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.textStrong,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<ProductsViewModel>(
              builder: (context, vm, _) {
                if (vm.cartItems.isEmpty) {
                  return Center(
                    child: Text(
                      'Sin productos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: vm.cartItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = vm.cartItems.entries.elementAt(index);
                    final product = vm.products.firstWhere(
                      (item) => item.id == entry.key,
                    );
                    return _CartItemRow(product: product, qty: entry.value);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Consumer<ProductsViewModel>(
            builder: (context, vm, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items: ${vm.cartCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subtotal: \$${vm.subtotal.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: vm.cartItems.isEmpty ? null : () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Ir al pago'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.product, required this.qty});

  final Product product;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Consumer<ProductsViewModel>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(product.colorHex).withValues(alpha: 0.4),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product.nombre,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text('x$qty'),
              IconButton(
                onPressed: () => vm.removeFromCart(product),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<ProductsViewModel>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: palette.shadow.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${vm.products.length} items mostrados',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
