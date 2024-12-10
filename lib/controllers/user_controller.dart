import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserController extends ChangeNotifier {
  UserModel? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get user => _user;
  String? get userId => _auth.currentUser?.uid;

  // Adicionar um novo usuário
  Future<void> addUser(UserModel userModel) async {
    try {
      if (userId == null) throw Exception("Usuário não autenticado.");
      await _firestore.collection('users').doc(userId).set(userModel.toJson());
      _user = userModel.copyWith(id: userId);
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao adicionar usuário: ${e.toString()}");
    }
  }

  // Ler dados do usuário
  Future<void> readUser() async {
    try {
      if (userId == null) throw Exception("Usuário não autenticado.");
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        _user = UserModel.fromJson(doc.data()!);
        notifyListeners();
      } else {
        throw Exception("Usuário não encontrado.");
      }
    } catch (e) {
      throw Exception("Erro ao buscar dados do usuário: ${e.toString()}");
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUser({
    double? weight,
    double? height,
    int? age,
    String? activityLevel,
    String? gender,
  }) async {
    try {
      if (_user == null || userId == null) {
        throw Exception("Usuário não autenticado.");
      }
      _user = _user!.copyWith(
        weight: weight ?? _user!.weight,
        height: height ?? _user!.height,
        age: age ?? _user!.age,
        activityLevel: activityLevel ?? _user!.activityLevel,
        gender: gender ?? _user!.gender,
      );
      await _firestore.collection('users').doc(userId).update(_user!.toJson());
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao atualizar os dados do usuário: ${e.toString()}");
    }
  }

  // Excluir usuário
  Future<void> deleteUser() async {
    try {
      if (userId == null) throw Exception("Usuário não autenticado.");
      await _firestore.collection('users').doc(userId).delete();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception("Erro ao excluir usuário: ${e.toString()}");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await readUser(); // Carrega os dados do usuário após o login
    } catch (e) {
      throw Exception("Erro no login: ${e.toString()}");
    }
  }

  // Cadastro do usuário
  Future<void> signUp(
      String email, String password, UserModel userModel) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await addUser(userModel.copyWith(id: userCredential.user!.uid));
    } catch (e) {
      throw Exception("Erro no cadastro: ${e.toString()}");
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer logout: $e')),
      );
    }
  }

  // Login anônimo
  Future<void> anonymousLogin() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      _user = UserModel(
        id: userCredential.user!.uid,
        weight: 0,
        height: 0,
        age: 0,
        activityLevel: "Baixo",
        gender: "Masculino",
        email: "Anônimo",
      );
      await addUser(_user!);
    } catch (e) {
      throw Exception("Erro no login anônimo: ${e.toString()}");
    }
  }

  Future<void> convertAnonymousToNormalAccount({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('O usuário atual não é anônimo.');
      }

      // Criar credenciais de email e senha
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Vincular credenciais ao usuário anônimo
      final userCredential = await currentUser.linkWithCredential(credential);

      // Atualizar as informações do usuário local
      _user = _user?.copyWith(
        email: email,
        id: userCredential.user!.uid,
      );

      // Atualizar as informações no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(
            _user!.toJson(),
          );

      notifyListeners();

      // Mostra uma mensagem de sucesso após a conversão
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta convertida com sucesso!')),
        );
      });
    } catch (e) {
      // Mostra a mensagem de erro
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao converter conta: $e')),
        );
      });
      throw Exception('Erro ao converter conta anônima: $e');
    }
  }

  // Cálculo de macros
  Map<String, dynamic> calculateMacros() {
    if (_user == null) {
      throw Exception("Dados do usuário não carregados.");
    }

    double baseCalories = _calculateBaseCalories();
    double multiplier = _getActivityMultiplier();
    double totalCalories = baseCalories * multiplier;

    return {
      'calories': totalCalories,
      'protein': _calculateProtein(),
      'fat': _calculateFat(totalCalories),
      'carbs': _calculateCarbs(totalCalories),
      'water': _calculateWaterIntake(),
    };
  }

  double _calculateBaseCalories() {
    double base = (10 * (_user?.weight ?? 0)) +
        (6.25 * (_user?.height ?? 0)) -
        (5 * (_user?.age ?? 0));

    return _user?.gender == 'Masculino' ? base + 5 : base - 161;
  }

  double _getActivityMultiplier() {
    switch (_user?.activityLevel) {
      case "Médio":
        return 1.55; // Moderadamente ativo
      case "Alto":
        return 1.9; // Muito ativo
      default:
        return 1.2; // Sedentário
    }
  }

  double _calculateProtein() {
    return (_user?.weight ?? 0) * 1.8; // 1.8g de proteína por kg de peso
  }

  double _calculateFat(double totalCalories) {
    return (totalCalories * 0.25) / 9; // Gorduras: 25% das calorias
  }

  double _calculateCarbs(double totalCalories) {
    double proteinCalories = _calculateProtein() * 4; // 4 kcal por grama
    double fatCalories = _calculateFat(totalCalories) * 9; // 9 kcal por grama
    return (totalCalories - proteinCalories - fatCalories) / 4; // Restante
  }

  double _calculateWaterIntake() {
    return (_user?.weight ?? 0) * 35; // 35 ml de água por kg de peso
  }
}
