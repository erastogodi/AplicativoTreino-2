import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/user_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/water_controller.dart';
import 'controllers/treino_controller.dart';
import 'views/login_view.dart';
import 'views/main_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(
          create: (context) => UserController(),
        ),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(),
        ),
        ChangeNotifierProvider<WaterController>(
          create: (context) => WaterController(),
        ),
        ChangeNotifierProvider<TreinoController>(
          create: (context) => TreinoController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, _) {
        return MaterialApp(
          title: 'Treino App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          // Exibe o `MainNavBar` quando o usuário está logado
          home: userController.user != null
              ? const MainNavBar()
              : const LoginView(),
        );
      },
    );
  }
}
