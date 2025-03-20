import 'package:go_router/go_router.dart';
import 'package:wastecollection/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/collection/screens/collection_validation_screen.dart';
import '../../features/collection/screens/route_overview_screen.dart';
import '../../features/collection/models/collection_point_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/route-overview',
      builder: (context, state) => const RouteOverviewScreen(),
    ),
    GoRoute(
      path: '/collection-validation',
      builder: (context, state) {
        final collectionPoint = state.extra as CollectionPointModel;
        return CollectionValidationScreen(collectionPoint: collectionPoint);
      },
    ),
  ],
);