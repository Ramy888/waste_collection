import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'config/routes/router.dart';
import 'config/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/collection/providers/collection_provider.dart';
import 'features/team_management/providers/team_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase here when implementing
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
      ],
      child: MaterialApp.router(
        title: 'Waste Collection App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}