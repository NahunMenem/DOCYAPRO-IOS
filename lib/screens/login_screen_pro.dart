import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/auth_service.dart';
import 'register_screen_pro.dart';
import 'home_screen.dart'; // este es tu HomeScreenPro
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_menu.dart';

class LoginScreenPro extends StatefulWidget {
  const LoginScreenPro({super.key});

  @override
  State<LoginScreenPro> createState() => _LoginScreenProState();
}

class _LoginScreenProState extends State<LoginScreenPro> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  final _auth = AuthService();

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token_medico", token);
  }

  // 👉 Nuevo: guardar FCM token en backend
  Future<void> _enviarFcmTokenAlBackend(String medicoId) async {
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print("🔑 Token FCM obtenido: $fcmToken");

    if (fcmToken != null) {
      try {
        final url = Uri.parse(
          "https://docya-railway-production.up.railway.app/medicos/$medicoId/fcm_token",
        );

        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"fcm_token": fcmToken}),
        );

        if (response.statusCode == 200) {
          print("✅ Token FCM registrado en backend");
        } else {
          print("❌ Error registrando token: ${response.body}");
        }
      } catch (e) {
        print("⚠️ Error enviando token al backend: $e");
      }
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    // loginMedico devuelve { access_token, medico_id, full_name }
    final loginData = await _auth.loginMedico(
      _email.text.trim(),
      _password.text.trim(),
    );

    setState(() => _loading = false);

    if (loginData != null) {
      await _saveToken(loginData["access_token"]);

      // 🔔 Guardar FCM token en backend
      await _enviarFcmTokenAlBackend(loginData["medico_id"].toString());

      _goHome(loginData["full_name"], loginData["medico_id"].toString());
    } else {
      setState(() => _error = 'Email o contraseña inválidos.');
    }
  }

  void _goHome(String nombreMedico, String medicoId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeMenu(
          userId: medicoId,
          nombreUsuario: nombreMedico,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF14B8A6);
    const dark = Color(0xFF111827);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/docyapro.png', height: 200),
                const SizedBox(height: 16),
                const Text(
                  "DocYa Pro – Médicos",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresá tu email';
                              }
                              if (!v.contains('@')) return 'Email inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (v) =>
                                (v == null || v.length < 6)
                                    ? 'Mínimo 6 caracteres'
                                    : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Text(_error!,
                                style: const TextStyle(color: Colors.red)),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Text('Ingresar',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('¿No tenés cuenta?'),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreenPro()));
                                },
                                child: const Text('Registrate'),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Al continuar aceptás nuestros Términos y Política de Privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
