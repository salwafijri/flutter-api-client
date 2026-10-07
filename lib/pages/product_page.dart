import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() =>
      _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ApiService apiService = ApiService();

  late Future<List<Product>> products;

  @override
  void initState() {
    super.initState();
    refreshProducts();
  }

  void refreshProducts() {
    setState(() {
      products = apiService.getProducts();
    });
  }

  // ==============================
  // FORM TAMBAH / EDIT PRODUK
  // ==============================
  void showProductForm({Product? product}) {
    final nameController = TextEditingController(
      text: product?.name ?? '',
    );

    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    final stockController = TextEditingController(
      text: product?.stock.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            product == null
                ? 'Tambah Produk'
                : 'Edit Produk',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                ),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                ),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name =
                    nameController.text.trim();

                final price =
                    int.tryParse(priceController.text);

                final stock =
                    int.tryParse(stockController.text);

                if (name.isEmpty ||
                    price == null ||
                    stock == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Semua data harus diisi dengan benar',
                      ),
                    ),
                  );
                  return;
                }

                try {
                  if (product == null) {
                    await apiService.addProduct(
                      name,
                      price,
                      stock,
                    );
                  } else {
                    await apiService.updateProduct(
                      product.id,
                      name,
                      price,
                      stock,
                    );
                  }

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  refreshProducts();

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        product == null
                            ? 'Produk berhasil ditambahkan'
                            : 'Produk berhasil diedit',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: $error',
                      ),
                    ),
                  );
                }
              },
              child: Text(
                product == null
                    ? 'Tambah'
                    : 'Simpan',
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // HAPUS PRODUK
  // ==============================
  void deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: Text(
            'Yakin ingin menghapus ${product.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.deleteProduct(
                    product.id,
                  );

                  if (!mounted) return;

                  Navigator.pop(dialogContext);

                  refreshProducts();

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Produk berhasil dihapus',
                      ),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: $error',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        actions: [
          IconButton(
            onPressed: refreshProducts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada produk',
              ),
            );
          }

          final data = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final product = data[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      product.id.toString(),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Harga: Rp ${product.price}\n'
                    'Stok: ${product.stock}',
                  ),
                  isThreeLine: true,

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                        ),
                        tooltip: 'Edit',
                        onPressed: () {
                          showProductForm(
                            product: product,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                        ),
                        tooltip: 'Hapus',
                        onPressed: () {
                          deleteProduct(product);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showProductForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }
}