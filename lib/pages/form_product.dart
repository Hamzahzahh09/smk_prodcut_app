import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smk_product_app/models/product.dart';
import 'package:smk_product_app/providers/product_provider.dart';

class formProductPage extends StatefulWidget {
  final String? productId;
  const formProductPage({this.productId, super.key});

  @override
  State<formProductPage> createState() => _formProductPageState();
}

class _formProductPageState extends State<formProductPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController ratingController = TextEditingController();

  bool get isEditMode => widget.productId != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isEditMode) {
      final product = context.read<ProductProvider>().getById(
        widget.productId!,
      );

      // ignore: avoid_print
      print("==========================================");
      print(widget.productId!.length);
      print(product);
      print("==========================================");
      if (product != null) {
        nameController.text = product.name;
        priceController.text = product.price.toString();
        descriptionController.text = product.description ?? '';
        categoryController.text = product.category;
        imageUrlController.text = product.imageUrl;
        ratingController.text = product.rating.toString();
      }
    }
  }

  saveProduct() {
    final provider = context.read<ProductProvider>();

    final newProduct = Product(
      id: isEditMode ? int.parse(widget.productId!) : 0,
      name: nameController.text,
      price: int.tryParse(priceController.text) ?? 0,
      description: descriptionController.text,
      category: categoryController.text,
      imageUrl: imageUrlController.text,
      rating: double.tryParse(ratingController.text) ?? 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    if (isEditMode) {
      provider.updateProduct(newProduct);
    } else {
      provider.addProduct(newProduct);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Product Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ratingController,
              decoration: const InputDecoration(
                labelText: 'Rating',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => saveProduct(),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
