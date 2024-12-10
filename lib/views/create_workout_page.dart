import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/treino_controller.dart';
import '../controllers/user_controller.dart';

class CreateWorkoutPage extends StatefulWidget {
  const CreateWorkoutPage({super.key});

  @override
  _CreateWorkoutPageState createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final List<TextEditingController> _exercicioControllers = [];
  int _duracaoSelecionada = 30;

  void _adicionarExercicio() {
    setState(() {
      _exercicioControllers.add(TextEditingController());
    });
  }

  Future<void> _salvarTreino(BuildContext context) async {
    final treinoController =
        Provider.of<TreinoController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);

    final userId = userController.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado.')),
      );
      return;
    }

    final nome = _nomeController.text.trim();
    final data = _dataController.text.trim();
    final duracao = _duracaoSelecionada;

    final exercicios = _exercicioControllers
        .where((controller) => controller.text.isNotEmpty)
        .map((controller) => controller.text.trim())
        .toList();

    if (nome.isEmpty || data.isEmpty || exercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await treinoController.addTreino(userId, nome, data, duracao, exercicios);
      Navigator.of(context).pop(); // Fecha o indicador de progresso
      Navigator.of(context).pop(); // Fecha a tela de criação

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Treino salvo com sucesso!')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Fecha o indicador de progresso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar treino: $e')),
      );
    }
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (dataSelecionada != null) {
      setState(() {
        _dataController.text = DateFormat('yyyy-MM-dd').format(dataSelecionada);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Treino'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                  'Nome do Treino', Icons.fitness_center, _nomeController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selecionarData,
                      child: AbsorbPointer(
                        child: _buildTextField(
                            'Data', Icons.calendar_today, _dataController),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDurationSelector()),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Exercícios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildExerciseList(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _adicionarExercicio,
                child: const Text('Adicionar Exercício'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _salvarTreino(context),
                child: const Text('Salvar Treino'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Duração (minutos)',
        prefixIcon: Icon(Icons.timer),
        border: OutlineInputBorder(),
      ),
      value: _duracaoSelecionada,
      onChanged: (newValue) {
        setState(() {
          _duracaoSelecionada = newValue!;
        });
      },
      items: List.generate(
        120,
        (index) => DropdownMenuItem(
          value: index + 1,
          child: Text('${index + 1} min'),
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _exercicioControllers.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: TextField(
            controller: _exercicioControllers[index],
            decoration: InputDecoration(
              labelText: 'Exercício ${index + 1}',
              prefixIcon: const Icon(Icons.fitness_center),
              border: const OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }
}
