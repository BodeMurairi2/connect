import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/core/router/app_router.dart';
import 'package:connect/features/auth/bloc/auth_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connect/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AnzaConnect());
}

class AnzaConnect extends StatelessWidget {
  const AnzaConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        routerConfig: appRouter,
      ),
    );
  }
}
