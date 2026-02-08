import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late Product _product;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _uploadPhoto(BuildContext context) async {
    if (_isUploading) return;
    final picker = ImagePicker();
    final picked = await _pickImage(context, picker);
    if (picked == null) return;

    setState(() => _isUploading = true);
    final vm = context.read<ProductsViewModel>();
    final updated = await vm.uploadProductPhoto(
      product: _product,
      filePath: picked.path,
    );
    if (!mounted) return;
    setState(() => _isUploading = false);

    if (updated != null) {
      setState(() => _product = updated);
      vm.replaceProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen actualizada.')),
      );
      return;
    }

    final message = vm.lastUploadError ?? 'No se pudo subir la imagen.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<XFile?> _pickImage(BuildContext context, ImagePicker picker) async {
    return showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    final photo = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop(photo);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Elegir de galería'),
                  onTap: () async {
                    final photo = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop(photo);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = context.read<ProductsViewModel>().resolveImageUrl(
          _product.fotoUrlWeb?.isNotEmpty == true
              ? _product.fotoUrlWeb
              : _product.fotoUrl,
        );
    final canUpload = context.select<AuthViewModel, bool>(
      (auth) => auth.hasPermission('productos.update'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_product.nombre),
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
                                      _ImageFallback(color: _product.colorHex),
                                ),
                              )
                            : _ImageFallback(color: _product.colorHex),
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
                            '\$${_product.precio.toStringAsFixed(2)}',
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
                      if (canUpload)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Material(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _isUploading
                                  ? null
                                  : () => _uploadPhoto(context),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.photo_camera_outlined,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
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
                            _product.nombre,
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
                        _product.codigo,
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
                          _product.brandNombre ?? '',
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
                if (_product.stockBySucursal.isNotEmpty) ...[
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
                          children: _product.stockBySucursal
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
