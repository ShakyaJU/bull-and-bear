import 'package:go_router/go_router.dart';

import '../../features/splash/splash_page.dart';
import '../shell/home_shell.dart';

/// GoRouter maps URL-like paths to screens. '/home' now points at the
/// HomeShell, which internally manages the bottom nav bar and its 3 tabs
/// — GoRouter itself only needs to know about the shell as a whole.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeShell(),
    ),
  ],
);
