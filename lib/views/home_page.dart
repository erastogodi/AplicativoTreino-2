import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/treino_controller.dart';
import '../controllers/user_controller.dart';
import 'create_workout_page.dart';
import 'workout_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final treinoController =
          Provider.of<TreinoController>(context, listen: false);
      final userController =
          Provider.of<UserController>(context, listen: false);

      if (userController.userId != null) {
        treinoController.fetchTreinos(userController.userId!);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPauseTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
      } else {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _seconds++;
          });
        });
      }
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _seconds = 0;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final treinoController = Provider.of<TreinoController>(context);
    final userController = Provider.of<UserController>(context, listen: false);
    final userId = userController.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro: Usuário não autenticado'),
        ),
        body: const Center(
          child: Text('Erro ao carregar a página. Faça login novamente.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5F6F5), // Fundo atualizado
      appBar: AppBar(
        title: const Text("FitnessFusion - Bem-vindo"), // Alteração no título
        backgroundColor: const Color(0xFF00897B), // Cor do banner superior
        centerTitle: true,
      ),
      body: treinoController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildWorkoutOfTheDay(treinoController, userId),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildCardButton(
                        title: "Novo Treino",
                        icon: Icons.add,
                        color: const Color(0xFFFFF3E0), // Original
                        iconColor: const Color(0xFFFF6F00), // Original
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateWorkoutPage()),
                          );
                        },
                      ),
                      buildCardButton(
                        title: "Histórico",
                        icon: Icons.history,
                        color: const Color(0xFFE8F5E9), // Original
                        iconColor: const Color(0xFF2E7D32), // Original
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkoutHistoryPage(
                                historicoTreinos: treinoController.treinos,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildSection(
                    title: "Cronômetro",
                    content: buildCronometro(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildSection({required String title, required Widget content}) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget buildWorkoutOfTheDay(
      TreinoController treinoController, String userId) {
    final treinoDoDia = treinoController.treinos.isNotEmpty
        ? treinoController.treinos.first
        : null;

    return treinoDoDia != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Treino do Dia",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: treinoDoDia.treinoFeito
                          ? const Color(0xFFE8F5E9) // Original
                          : const Color(0xFFFFF3E0), // Original
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      treinoDoDia.treinoFeito ? "Concluído" : "Não Concluído",
                      style: TextStyle(
                        color: treinoDoDia.treinoFeito
                            ? const Color(0xFF2E7D32) // Original
                            : const Color(0xFFFFA000), // Original
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // Original
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Color(0xFF1565C0), // Original
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treinoDoDia.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "${treinoDoDia.duracao} minutos • ${treinoDoDia.intensidade}",
                        style: const TextStyle(color: Color(0xFF57636C)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    treinoDoDia.treinoFeito = !treinoDoDia.treinoFeito;
                  });
                  await treinoController.updateTreinoStatus(
                    userId,
                    treinoDoDia.id,
                    treinoDoDia.treinoFeito,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B), // Cor do banner
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  treinoDoDia.treinoFeito ? "Desmarcar" : "Marcar Treino Feito",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        : const Text("Nenhum treino cadastrado. Adicione um treino!");
  }

  Widget buildCardButton({
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(30)),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(height: 12),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCronometro() {
    return Center(
      child: Column(
        children: [
          Text(
            _formatTime(_seconds),
            style: const TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildIconButton(
                  icon: Icons.play_arrow,
                  color: Colors.blue,
                  onPressed: _startPauseTimer),
              const SizedBox(width: 16),
              buildIconButton(
                  icon: Icons.stop, color: Colors.red, onPressed: _resetTimer),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30)),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}
