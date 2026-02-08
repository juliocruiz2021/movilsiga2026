import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../viewmodels/products_viewmodel.dart';

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = context.read<ProductsViewModel>().resolveImageUrl(
          product.fotoUrlWeb?.isNotEmpty == true
              ? product.fotoUrlWeb
              : product.fotoUrl,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight =
                (constraints.maxHeight - 24).clamp(0, double.infinity);
            final imageHeight = (availableHeight * 0.72)
                .clamp(180.0, availableHeight)
                .toDouble();
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: imageUrl.isNotEmpty
                            ? InteractiveViewer(
                                minScale: 1,
                                maxScale: 4,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _ImageFallback(color: product.colorHex),
                                ),
                              )
                            : _ImageFallback(color: product.colorHex),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Text(
                            '\$${product.precio.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1B9CFF),
                                ) ??
                                const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B9CFF),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A2B3C),
                        ) ??
                        const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A2B3C),
                        );
                    final lineHeight =
                        (titleStyle.fontSize ?? 20) * (titleStyle.height ?? 1.2);
                    final maxHeight = lineHeight * 2;
                    final scrollController = ScrollController();
                    return SizedBox(
                      height: maxHeight,
                      child: Scrollbar(
                        controller: scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Text(
                            product.nombre,
                            style: titleStyle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.codigo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4C6F8A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          product.brandNombre ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4C6F8A),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                if (product.stockBySucursal.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          'Stock:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A2B3C),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: product.stockBySucursal
                              .map(
                                (entry) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.nombre.isNotEmpty
                                              ? entry.nombre
                                              : entry.codigo,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0A2B3C),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        entry.stockTotal
                                            .toStringAsFixed(0),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: const Color(0xFF4C6F8A),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.color});

  final int color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(color).withOpacity(0.2),
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 56, color: Colors.white),
      ),
    );
  }
}
