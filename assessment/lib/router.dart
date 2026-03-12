import 'package:go_router/go_router.dart';
import 'screens/product_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.productListing,
  routes: [
    GoRoute(
      path: AppRoutes.productListing,
      builder: (context, state) => const ProductListScreen(),
    ),
  ],
);

// Define route names for better maintainability
class AppRoutes {
  static const String productListing = '/';
}
