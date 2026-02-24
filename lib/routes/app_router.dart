import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smk_product_app/pages/cart_page.dart';
import 'package:smk_product_app/pages/checkout_page.dart';
import 'package:smk_product_app/pages/data_product.dart';
import 'package:smk_product_app/pages/detail_page.dart';
import 'package:smk_product_app/pages/form_product.dart';
import 'package:smk_product_app/pages/home_page.dart';
import 'package:smk_product_app/pages/login_page.dart';
import 'package:smk_product_app/pages/profile_page.dart';
import 'package:smk_product_app/pages/register_page.dart';
import 'package:smk_product_app/providers/auth_provider.dart';
import 'package:smk_product_app/routes/app_routes.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      initialLocation: authProvider.isLoggedIn ? AppRoutes.productsPath : AppRoutes.loginPath,
      // initialLocation: AppRoutes.productsPath,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLoggedIn = authProvider.isLoggedIn;
        final isGoingToLogin = state.matchedLocation == AppRoutes.loginPath;
        final isGoingToRegister = state.matchedLocation == AppRoutes.registerPath;
      
        // If not logged in and not going to login/register, redirect to login
        if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
          return AppRoutes.loginPath;
        }

        // If logged in and going to login/register, redirect to home
        if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
          return AppRoutes.productsPath;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.loginPath,
          name: AppRoutes.loginPage,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.registerPath,
          name: AppRoutes.registerPage,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.productsPath,
          name: AppRoutes.productName,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: AppRoutes.productDetailPath,
              name: AppRoutes.productDetailName,
              builder: (context, state) {
                final productId = state.pathParameters['id']!;
                return DetailPage(productId: productId);
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.profilePath,
          name: AppRoutes.profilePage,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.cartPath,
          name: AppRoutes.cartPage,
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: AppRoutes.checkoutPath,
          name: AppRoutes.checkoutPage,
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: AppRoutes.dataProductPath,
          name: AppRoutes.dataProductPage,
          builder: (context, state) => const DataProductPage(),
          routes: [
            GoRoute(
              path: AppRoutes.addProductDataPath,
              name: AppRoutes.addProductData,
              builder: (context, state) => formProductPage(),
            ),
            GoRoute(
              path: AppRoutes.editProductPath,
              name: AppRoutes.editProduct,
              builder: (context, state) {
                final productId = state.pathParameters['id']!;
                return formProductPage(productId: productId);
              },
            ),
          ],
        ),
      ],
    );
  }
}