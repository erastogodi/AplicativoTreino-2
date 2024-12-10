import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/user_controller.dart';
import 'login_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _weight;
  int? _height;
  int? _age;
  String? _activityLevel;
  String? _gender;
  String? _email;
  String? _password;

  bool _isDataChanged = false;
  bool _isAnonymous = false;

  final List<String> _activityLevels = ['Baixo', 'Médio', 'Alto'];
  final List<String> _genders = ['Masculino', 'Feminino'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userController =
          Provider.of<UserController>(context, listen: false);

      await userController.readUser();
      final user = userController.user;

      if (mounted && user != null) {
        setState(() {
          _weight = user.weight.toInt();
          _height = user.height.toInt();
          _age = user.age;
          _activityLevel = user.activityLevel;
          _gender = user.gender;
          _isAnonymous = user.email == "Anônimo";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await userController.logout(context);
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _isAnonymous
            ? [
                const Center(
                  child: Text(
                    'Para editar seus dados, registre-se com um e-mail e senha.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Email',
                  onChanged: (value) => _email = value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Senha',
                  onChanged: (value) => _password = value,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_email != null && _password != null) {
                      await userController.convertAnonymousToNormalAccount(
                        email: _email!,
                        password: _password!,
                        context: context,
                      );
                      setState(() {
                        _isAnonymous = false; // Atualiza o estado após registro
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conta registrada com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Preencha todos os campos!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text('Registrar-se'),
                ),
              ]
            : [
                _buildPickerField(
                  label: 'Peso (kg)',
                  value: _weight,
                  onTap: () => _showCupertinoPicker(
                    title: 'Selecione o Peso',
                    value: _weight ?? 30,
                    min: 30,
                    max: 500,
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                        _isDataChanged = true;
                      });
                    },
                  ),
                  icon: Icons.monitor_weight,
                ),
                const SizedBox(height: 16),
                _buildPickerField(
                  label: 'Altura (cm)',
                  value: _height,
                  onTap: () => _showCupertinoPicker(
                    title: 'Selecione a Altura',
                    value: _height ?? 100,
                    min: 100,
                    max: 250,
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                        _isDataChanged = true;
                      });
                    },
                  ),
                  icon: Icons.height,
                ),
                const SizedBox(height: 16),
                _buildPickerField(
                  label: 'Idade',
                  value: _age,
                  onTap: () => _showCupertinoPicker(
                    title: 'Selecione a Idade',
                    value: _age ?? 0,
                    min: 0,
                    max: 150,
                    onChanged: (value) {
                      setState(() {
                        _age = value;
                        _isDataChanged = true;
                      });
                    },
                  ),
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 24),
                _buildDropdown(
                  label: 'Nível de Atividade',
                  value: _activityLevel,
                  items: _activityLevels,
                  onChanged: (value) {
                    setState(() {
                      _activityLevel = value!;
                      _isDataChanged = true;
                    });
                  },
                  icon: Icons.fitness_center,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Gênero',
                  value: _gender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                      _isDataChanged = true;
                    });
                  },
                  icon: Icons.person,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isDataChanged
                      ? () async {
                          await userController.updateUser(
                            weight: _weight?.toDouble(),
                            height: _height?.toDouble(),
                            age: _age,
                            activityLevel: _activityLevel,
                            gender: _gender,
                          );
                          if (mounted) {
                            setState(() => _isDataChanged = false);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil salvo com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text('Salvar'),
                ),
              ],
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required int? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      value?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
            underline: Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: label,
          ),
          obscureText: obscureText,
          onChanged: onChanged,
        ),
      ],
    );
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
      builder: (context) => SizedBox(
        height: 250,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                children: List<Widget>.generate(
                  max - min + 1,
                  (index) => Center(
                    child: Text('${index + min}'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
