class AppRoutes {
  // Nama route (untuk goNamed/pushNamed)
  static const String productName = 'products';
  static const String productDetailName = 'product-detail';

  // Path route (hindari hardcode di banyak tempat)
  static const String productsPath = '/products';
  static const String productDetailPath = ':id'; // nested dibawah /products

  // Nama route (untuk goNamed/pushNamed)
  static const String profilePage = 'profile';

  // Path route (hindari hardcode di banyak tempat)
  static const String profilePath = '/profile';

  static const String dataProductPage = 'data-product';
  static const String dataProductPath = '/data-product';

  static const String addProductData = 'add';
  static const String addProductDataPath = 'add';

  static const String editProduct = 'edit';
  static const String editProductPath = 'edit/:id';

  static const String cartPage = 'cart';
  static const String cartPath = '/cart';

  static const String checkoutPage = 'checkout';
  static const String checkoutPath = '/checkout';

  static const String loginPage = 'login';
  static const String loginPath = '/login';

  static const String registerPage = 'register';
  static const String registerPath = '/register';
}
