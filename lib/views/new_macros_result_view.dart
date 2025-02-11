import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/user_controller.dart';
import '../controllers/water_controller.dart';

class NewMacrosResultView extends StatefulWidget {
  const NewMacrosResultView({super.key});

  @override
  State<NewMacrosResultView> createState() => _NewMacrosResultViewState();
}

class _NewMacrosResultViewState extends State<NewMacrosResultView> {
  String? _scannedResult;
  Map<String, dynamic>? _nutritionData;

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        setState(() {
          _scannedResult = result.rawContent;
          _nutritionData = null;
        });
        await fetchNutritionData(result.rawContent);
      } else {
        setState(() {
          _scannedResult = "Nenhum código escaneado.";
        });
      }
    } catch (e) {
      setState(() {
        _scannedResult = "Erro ao escanear: $e";
      });
    }
  }

  Future<void> fetchNutritionData(String barcode) async {
    final url = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          setState(() {
            _nutritionData = data['product']['nutriments'];
          });
          openNutritionScreen(_nutritionData!);
        } else {
          throw "Produto não encontrado.";
        }
      } else {
        throw "Erro na requisição: Código ${response.statusCode}";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao buscar dados nutricionais: $e")),
      );
    }
  }

  void openNutritionScreen(Map<String, dynamic> nutritionData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NutritionDetailsScreen(nutritionData: nutritionData),
      ),
    );
  }

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (macros == null)
                        const Center(
                          child: Text(
                            'Erro ao calcular macros. Verifique seus dados!',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        Column(
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
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Escanear Código de Barras"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                        ),
                      ),
                      if (_scannedResult != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          "Código Escaneado: $_scannedResult",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
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

class NutritionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> nutritionData;

  const NutritionDetailsScreen({Key? key, required this.nutritionData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tabela Nutricional"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informações Nutricionais",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: nutritionData.entries.map((entry) {
                  String label = entry.key;
                  String value = entry.value.toString();

                  // Transformação para português e melhoria da exibição
                  label = label.replaceAll('_', ' ').toUpperCase();
                  label = label == 'ENERGY' ? 'Energia (kJ)' : label;
                  label = label == 'PROTEINS' ? 'Proteínas' : label;
                  label = label == 'FAT' ? 'Gorduras' : label;
                  label = label == 'CARBOHYDRATES' ? 'Carboidratos' : label;
                  label = label == 'SUGARS' ? 'Açúcares' : label;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
