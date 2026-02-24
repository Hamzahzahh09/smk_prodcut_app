import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:smk_product_app/providers/checkout_provider.dart';
import 'package:smk_product_app/routes/app_routes.dart';
import '../data/dummy_kurir.dart';
import '../data/dummy_metode.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _addressC = TextEditingController();

  String? _selectedKurir;
  String? _selectedMetode;
  bool _isProcessing = false;

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _addressC.dispose();
    super.dispose();
  }

  int get _shippingCost {
    if (_selectedKurir == null) return 0;
    final kurir = dummyKurirs.firstWhere(
      (k) => k.id == _selectedKurir,
      orElse: () => dummyKurirs[0],
    );
    return kurir.harga;
  }

  _handleSaveTransaction(int subtotal) async {
    // var data = {
    //   "recipient_name": _nameC.text,
    //   "recipient_address": _addressC.text,
    //   "recipient_phone": _phoneC.text,
    //   "subtotal": subtotal,
    //   "total_amount": subtotal + _shippingCost,
    //   "details": Provider.of<CartProvider>(context, listen: false).items
    //       .map((cartItem) {
    //         final product = Provider.of<ProductProvider>(
    //           context,
    //           listen: false,
    //         ).getById(cartItem.productId);
    //         final price = product?.price ?? 0;
    //         return {
    //           "product_id": cartItem.productId,
    //           "quantity": cartItem.quantity,
    //           "price": price,
    //           "subtotal": price * cartItem.quantity,
    //         };
    //       })
    //       .toList(),
    // };

    // print(data);

    List<Map<String, dynamic>> dataCart = Provider.of<CartProvider>(context, listen: false).items.map(
      (cartItem) {
        final product = Provider.of<ProductProvider>(
          context,
          listen: false,
        ).getById(cartItem.productId);
        final price = product?.price ?? 0;
        return {
          "product_id": int.parse(cartItem.productId),
          "quantity": cartItem.quantity,
          "price": price,
          "subtotal": price * cartItem.quantity,
        };
      },
    ).toList();

    final simpan = await context.read<CheckoutProvider>().simpanPembayaran(
      _nameC.text,
      _addressC.text,
      _phoneC.text,
      subtotal,
      subtotal + _shippingCost,
      dataCart,
    );

    if (simpan) {
      context.read<CartProvider>().clearCart();
      print("Berhasil Menyimpan");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction Berhasil di Simpan'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      context.goNamed(AppRoutes.productDetailName);
    } else {
      print("Failed Save");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Menyimpan'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final totalGoodsPrice = cartProvider.totalPrice(productProvider);
    final totalPrice = totalGoodsPrice + _shippingCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Information Section
                  _buildSectionCard(
                    theme: theme,
                    title: 'Shipping Information',
                    icon: Icons.local_shipping_outlined,
                    child: _buildShippingForm(theme),
                  ),
                  const SizedBox(height: 16),

                  // Courier Selection Section
                  _buildSectionCard(
                    theme: theme,
                    title: 'Select Courier',
                    icon: Icons.local_shipping_outlined,
                    child: _buildCourierSelection(theme),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Section
                  _buildSectionCard(
                    theme: theme,
                    title: 'Payment Method',
                    icon: Icons.credit_card_outlined,
                    child: _buildPaymentMethodSelection(theme),
                  ),
                  const SizedBox(height: 16),

                  // Order Summary Section
                  _buildSectionCard(
                    theme: theme,
                    title: 'Order Summary',
                    icon: Icons.shopping_cart_outlined,
                    child: _buildOrderSummary(
                      theme,
                      totalGoodsPrice,
                      totalPrice,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Transaction Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleSaveTransaction(totalPrice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: theme.colorScheme.primary
                            .withOpacity(0.5),
                      ),
                      icon: _isProcessing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Save Transaction',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildShippingForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          _buildTextFieldWithLabel(
            theme: theme,
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameC,
            icon: Icons.person_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Full name is required';
              }
              if (value!.length < 3) {
                return 'Name must be at least 3 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Phone Number Field
          _buildTextFieldWithLabel(
            theme: theme,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            controller: _phoneC,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Phone number is required';
              }
              if (!RegExp(r'^[\d\s\-\+\(\)]{10,}$').hasMatch(value!)) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Address Field
          _buildTextFieldWithLabel(
            theme: theme,
            label: 'Address',
            hint: 'Enter your complete address',
            controller: _addressC,
            icon: Icons.map_outlined,
            maxLines: 3,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Address is required';
              }
              if (value!.length < 10) {
                return 'Address must be at least 10 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel({
    required ThemeData theme,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 18),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildCourierSelection(ThemeData theme) {
    return Column(
      children: dummyKurirs.map((kurir) {
        final isSelected = _selectedKurir == kurir.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedKurir = kurir.id),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.05)
                    : Colors.white,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: kurir.id,
                    groupValue: _selectedKurir,
                    onChanged: (value) {
                      setState(() => _selectedKurir = value);
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kurir.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Est. ${kurir.estimasi}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp${kurir.harga.toStringAsFixed(0)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodSelection(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: dummyMetode.length,
      itemBuilder: (context, index) {
        final metode = dummyMetode[index];
        final isSelected = _selectedMetode == metode.id;

        return GestureDetector(
          onTap: () => setState(() => _selectedMetode = metode.id),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.05)
                  : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: Image.network(
                    metode.gambar,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  metode.nama,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(
    ThemeData theme,
    int totalGoodsPrice,
    int totalPrice,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Goods Price',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Rp${totalGoodsPrice.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Shipping Cost',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            Text(
              'Rp${_shippingCost.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Divider(height: 16, thickness: 1, color: Colors.grey[200]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Price',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Rp${totalPrice.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}