import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'new_macros_result_view.dart';
import 'profile.dart';
import '../controllers/user_controller.dart';

class MainNavBar extends StatefulWidget {
  final int initialPage;

  const MainNavBar({super.key, this.initialPage = 0});

  @override
  _MainNavBarState createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Valida a página inicial
    _selectedIndex = widget.initialPage.clamp(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    // Exibe mensagem enquanto os dados do usuário estão sendo carregados
    if (userController.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> pages = [
      const HomePage(),
      const NewMacrosResultView(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
            tooltip: 'Voltar para a página inicial',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: 'Macros',
            tooltip: 'Veja suas metas de macros',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Perfil',
            tooltip: 'Gerencie seu perfil',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
