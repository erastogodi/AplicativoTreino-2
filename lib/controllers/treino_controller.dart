import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/treino.dart';

class TreinoController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Treino> _treinos = [];
  List<Treino> get treinos => _treinos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Carrega os treinos do Firestore
  Future<void> fetchTreinos(String userId) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .get();

      _treinos = querySnapshot.docs
          .map((doc) => Treino.fromJson(doc.data() as Map<String, dynamic>)
              .copyWith(id: doc.id))
          .toList();
    } catch (e) {
      _setErrorMessage('Erro ao buscar treinos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Adiciona um novo treino
  Future<void> addTreino(String userId, String nome, String data, int duracao,
      List<String> exercicios) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .doc(); // Gera um ID único automaticamente

      final novoTreino = Treino(
        id: docRef.id,
        nome: nome,
        data: data,
        duracao: '$duracao minutos',
        intensidade: 'Alta', // Pode ser ajustado conforme necessário
      );

      await docRef.set(novoTreino.toJson());

      // Atualiza localmente com o ID gerado
      _treinos.add(novoTreino);
      notifyListeners();
    } catch (e) {
      throw Exception('Erro ao adicionar treino: $e');
    }
  }

  // Adiciona a funcionalidade de definir o treino do dia
  void setTreinoDoDia(Treino treino) {
    // Primeiro verifica se o treino já existe na lista de treinos
    final index = _treinos.indexWhere((t) => t.id == treino.id);
    if (index != -1) {
      // Atualiza o treino como treino do dia
      _treinos[index] = treino;
      notifyListeners();
    }
  }

  // Métodos auxiliares para controle de estado
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearState() {
    _treinos = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateTreinoStatus(
      String userId, String treinoId, bool treinoFeito) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('treinos')
          .doc(treinoId)
          .update({'treinoFeito': treinoFeito});

      // Atualiza localmente
      final index = _treinos.indexWhere((t) => t.id == treinoId);
      if (index != -1) {
        _treinos[index] = _treinos[index].copyWith(treinoFeito: treinoFeito);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao atualizar status do treino: $e');
    }
  }
}
