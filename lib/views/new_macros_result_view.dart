import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import '../controllers/water_controller.dart';

class NewMacrosResultView extends StatelessWidget {
  const NewMacrosResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final waterController = Provider.of<WaterController>(context);
    final waterIntakeGoal = 3500; // Meta fixa de água

    if (userController.user == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    Map<String, dynamic>? macros;

    try {
      macros = userController.calculateMacros();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao calcular os macros: ${e.toString()}')),
        );
      });
      macros = null;
    }

    final mealMacros = macros != null ? _divideMacrosByMeal(macros) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados dos Macros'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.6),
                child: const Text(
                  'Cálculo dos Macros',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: macros == null
                      ? const Center(
                          child: Text(
                            'Erro ao calcular macros. Verifique seus dados!',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildWaterIntake(waterController, waterIntakeGoal),
                            const SizedBox(height: 20),
                            ...mealMacros.map((meal) {
                              return _buildMacroSection(
                                meal['mealName'],
                                meal['macros'],
                                meal['iconPath'],
                              );
                            }).toList(),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _divideMacrosByMeal(Map<String, dynamic> macros) {
    final meals = ['Café da Manhã', 'Almoço', 'Café da Tarde', 'Jantar'];
    final icons = [
      'assets/images/icons8-bitten-apple-40.png',
      'assets/images/icons8-lunch-80.png',
      'assets/images/icons8-breakfast-64.png',
      'assets/images/icons8-green-salad-48.png'
    ];

    return List.generate(4, (index) {
      return {
        'mealName': meals[index],
        'iconPath': icons[index],
        'macros': {
          'calories': (macros['calories'] / 4),
          'protein': (macros['protein'] / 4),
          'fat': (macros['fat'] / 4),
          'carbs': (macros['carbs'] / 4),
        },
      };
    });
  }

  Widget _buildWaterIntake(WaterController waterController, int waterGoal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade100.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_drink,
                color: Colors.blue.shade700,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                '${waterController.waterCounter} / $waterGoal ml',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: waterController.waterCounter / waterGoal,
            backgroundColor: Colors.blue.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: waterController.removeWater,
                icon: const Icon(
                  Icons.remove_circle,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Quantidade de Água',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: waterController.addWater,
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSection(
      String meal, Map<String, dynamic> macros, String iconPath) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade100.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  meal,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: Colors.teal.shade900,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Image.asset(
                iconPath,
                width: 30,
                height: 30,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.teal.shade300),
          _buildMacroRow('Calorias',
              macros['calories']?.toStringAsFixed(0) ?? '0', 'kcal'),
          Divider(color: Colors.teal.shade300),
          _buildMacroRow(
              'Proteínas', macros['protein']?.toStringAsFixed(1) ?? '0', 'g'),
          Divider(color: Colors.teal.shade300),
          _buildMacroRow(
              'Gorduras', macros['fat']?.toStringAsFixed(1) ?? '0', 'g'),
          Divider(color: Colors.teal.shade300),
          _buildMacroRow(
              'Carboidratos', macros['carbs']?.toStringAsFixed(1) ?? '0', 'g'),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.teal.shade800,
              ),
            ),
          ),
          Flexible(
            child: Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 16,
                color: Colors.teal.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
