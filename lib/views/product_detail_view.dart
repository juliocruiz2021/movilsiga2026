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
    final imageUrl =
        context.read<ProductsViewModel>().resolveImageUrl(product.fotoUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.nombre),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = constraints.maxHeight * 0.65;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(
                height: imageHeight,
                child: ClipRRect(
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
              ),
              const SizedBox(height: 20),
              Text(
                product.nombre,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A2B3C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Codigo: ${product.codigo}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4C6F8A),
                ),
              ),
              if (product.categoryNombre != null &&
                  product.categoryNombre!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Categoria: ${product.categoryNombre}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4C6F8A),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
          Text(
            '\$${product.precio.toStringAsFixed(2)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B9CFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stock: ${product.stock.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF4C6F8A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver a productos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B9CFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          );
        },
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
