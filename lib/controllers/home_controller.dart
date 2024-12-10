import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/treino.dart';

class HomeController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Treino> historicoTreinos = [];
  Treino? treinoDoDia;
  bool checkInFeito = false;
  int seconds = 0;
  bool isRunning = false;

  Future<void> carregarTreinoDoDia(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .doc('treinoDoDia')
          .get();

      if (doc.exists) {
        treinoDoDia = Treino.fromJson(doc.data()!);
      } else {
        treinoDoDia = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar treino do dia: $e');
    }
  }

  Future<void> carregarHistorico(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .get();

      historicoTreinos =
          querySnapshot.docs.map((doc) => Treino.fromJson(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
    }
  }

  Future<void> adicionarTreino(String userId, Treino novoTreino) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .doc(novoTreino.data)
          .set(novoTreino.toJson());
      historicoTreinos.add(novoTreino); // Atualiza a lista local
      notifyListeners(); // Notifica as telas sobre a atualização
    } catch (e) {
      debugPrint('Erro ao adicionar treino: $e');
      throw Exception('Erro ao adicionar o treino.');
    }
  }

  Future<void> alternarCheckIn(String userId) async {
    if (treinoDoDia == null) return;

    try {
      final treinoRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .doc(treinoDoDia!.data);

      if (checkInFeito) {
        await treinoRef.delete();
        checkInFeito = false;
      } else {
        await treinoRef.set(treinoDoDia!.toJson());
        checkInFeito = true;
      }
      await carregarHistorico(userId);
    } catch (e) {
      debugPrint('Erro ao alternar check-in: $e');
    }
  }

  Future<void> editarTreinoDoDia({
    required String userId,
    required String nome,
    required String duracao,
    required String intensidade,
  }) async {
    if (treinoDoDia == null) return;

    try {
      treinoDoDia = treinoDoDia!.copyWith(
        nome: nome,
        duracao: duracao,
        intensidade: intensidade,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .doc('treinoDoDia')
          .update(treinoDoDia!.toJson());

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao editar treino do dia: $e');
      throw Exception('Erro ao editar treino do dia.');
    }
  }

  void startPauseTimer() {
    isRunning = !isRunning;
    notifyListeners();
  }

  void resetTimer() {
    seconds = 0;
    isRunning = false;
    notifyListeners();
  }
}
