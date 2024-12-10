import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'main_nav_bar.dart';

class MacrosFormView extends StatefulWidget {
  const MacrosFormView({super.key});

  @override
  _MacrosFormViewState createState() => _MacrosFormViewState();
}

class _MacrosFormViewState extends State<MacrosFormView> {
  int _weight = 60;
  int _height = 170;
  int _age = 25;
  String _selectedGender = 'Masculino';
  String _selectedActivityLevel = 'Baixo';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFE5F6F5), // Padrão de cor atualizado
        appBar: AppBar(
          title: const Text(
            'Inserir Dados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF00897B), // Padrão de cor atualizado
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Complete seus Dados',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101518),
                ),
              ),
              const SizedBox(height: 24),
              _buildPickerField(
                label: 'Peso (kg)',
                value: _weight,
                onTap: () => _showCupertinoPicker(
                  title: 'Selecione o Peso',
                  value: _weight,
                  min: 30,
                  max: 300,
                  onChanged: (value) {
                    setState(() => _weight = value);
                  },
                ),
                icon: Icons.monitor_weight,
              ),
              const SizedBox(height: 24),
              _buildPickerField(
                label: 'Altura (cm)',
                value: _height,
                onTap: () => _showCupertinoPicker(
                  title: 'Selecione a Altura',
                  value: _height,
                  min: 100,
                  max: 250,
                  onChanged: (value) {
                    setState(() => _height = value);
                  },
                ),
                icon: Icons.height,
              ),
              const SizedBox(height: 24),
              _buildPickerField(
                label: 'Idade',
                value: _age,
                onTap: () => _showCupertinoPicker(
                  title: 'Selecione a Idade',
                  value: _age,
                  min: 1,
                  max: 120,
                  onChanged: (value) {
                    setState(() => _age = value);
                  },
                ),
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Gênero',
                value: _selectedGender,
                items: const ['Masculino', 'Feminino'],
                onChanged: (newValue) {
                  setState(() => _selectedGender = newValue!);
                },
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                label: 'Nível de Atividade',
                value: _selectedActivityLevel,
                items: const ['Baixo', 'Médio', 'Alto'],
                onChanged: (newValue) {
                  setState(() => _selectedActivityLevel = newValue!);
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B), // Padrão
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shadowColor: Colors.black26,
                        elevation: 3,
                      ),
                      child: const Text(
                        'Salvar e Continuar',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required int value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF00897B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18, // Aumentado para maior destaque
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDFEDEC)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF101518),
          fontSize: 18, // Aumentado para maior destaque
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: const Color(0xFFE5F6F5), // Fundo atualizado
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userController =
          Provider.of<UserController>(context, listen: false);

      await userController.updateUser(
        weight: _weight.toDouble(),
        height: _height.toDouble(),
        age: _age,
        activityLevel: _selectedActivityLevel,
        gender: _selectedGender,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavBar()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar dados: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showCupertinoPicker({
    required String title,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200, // Reduzido para menor altura
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: value - min),
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    onChanged(index + min);
                  },
                  children: List.generate(
                    max - min + 1,
                    (index) => Center(child: Text('${index + min}')),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
