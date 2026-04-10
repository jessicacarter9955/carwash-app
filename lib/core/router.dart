import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/items/items_screen.dart';
import '../screens/service/service_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/searching/searching_screen.dart';
import '../screens/tracking/tracking_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/rating/rating_screen.dart';
import '../screens/location/address_input_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/login';
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/items', builder: (_, __) => const ItemsScreen()),
      GoRoute(path: '/service', builder: (_, __) => const ServiceScreen()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutScreen()),
      GoRoute(path: '/searching', builder: (_, __) => const SearchingScreen()),
      GoRoute(path: '/tracking', builder: (_, __) => const TrackingScreen()),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/rating', builder: (_, __) => const RatingScreen()),
      GoRoute(path: '/address', builder: (_, __) => const AddressInputScreen()),
    ],
  );
});
