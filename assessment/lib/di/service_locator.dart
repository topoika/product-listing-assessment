import 'package:get_it/get_it.dart';
import '../services/html_content_service.dart';
import '../services/product_service.dart';

void setupServiceLocator() {
  final sl = GetIt.instance;

  // Changed from registerFactory to registerLazySingleton to ensure we have a single instance of each service throughout the app
  sl.registerLazySingleton<ProductService>(() => ProductService());
  sl.registerLazySingleton<HtmlContentService>(() => HtmlContentService());
}
