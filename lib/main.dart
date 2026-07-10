import 'package:flutter/material.dart';
import 'package:connect/core/router/app_router.dart';

void main() {
  runApp(const AnzaConnect());
}

class AnzaConnect extends StatelessWidget {
  const AnzaConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      routerConfig: appRouter,
    );
  }
}
