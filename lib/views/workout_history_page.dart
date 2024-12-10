import 'package:flutter/material.dart';
import '../models/treino.dart';

class WorkoutHistoryPage extends StatelessWidget {
  final List<Treino>? historicoTreinos;

  const WorkoutHistoryPage({super.key, this.historicoTreinos});

  @override
  Widget build(BuildContext context) {
    // Filtra os treinos que já foram feitos
    final treinosFeitos =
        historicoTreinos?.where((treino) => treino.treinoFeito).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Treinos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: treinosFeitos.isEmpty
          ? const Center(
              child: Text(
                'Nenhum treino concluído encontrado',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: treinosFeitos.length,
              itemBuilder: (context, index) {
                final treino = treinosFeitos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(
                      treino.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${treino.duracao} • ${treino.intensidade}'),
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
