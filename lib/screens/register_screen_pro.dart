import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import 'terminos_screen.dart';

/// 🔹 Tipos de snackbar
enum SnackType { success, error, info, warning }

/// 🔹 Widget reutilizable DocYaSnackbar
class DocYaSnackbar {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    SnackType type = SnackType.success,
  }) {
    Color startColor;
    Color endColor;
    IconData icon;

    switch (type) {
      case SnackType.success:
        startColor = const Color(0xFF14B8A6);
        endColor = const Color(0xFF0F2027);
        icon = Icons.check_circle_rounded;
        break;
      case SnackType.error:
        startColor = Colors.redAccent;
        endColor = const Color(0xFF2C5364);
        icon = Icons.error_rounded;
        break;
      case SnackType.info:
        startColor = Colors.blueAccent;
        endColor = const Color(0xFF2C5364);
        icon = Icons.info_rounded;
        break;
      case SnackType.warning:
        startColor = Colors.amber;
        endColor = const Color(0xFF2C5364);
        icon = Icons.warning_amber_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class RegisterScreenPro extends StatefulWidget {
  const RegisterScreenPro({super.key});

  @override
  State<RegisterScreenPro> createState() => _RegisterScreenProState();
}

class _RegisterScreenProState extends State<RegisterScreenPro> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _matricula = TextEditingController();
  final _especialidad = TextEditingController();
  final _phone = TextEditingController();
  final _dni = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _provincia = "CABA"; // fija
  String? _localidad;
  bool _aceptaCondiciones = false;
  bool _loading = false;
  String? _error;

  // Médico o enfermero
  String _tipo = "medico";

  // Fotos
  String? _fotoPerfil;
  String? _fotoDniFrente;
  String? _fotoDniDorso;
  String? _selfieDni;

  final _auth = AuthService();
  final picker = ImagePicker();

  final List<String> _comunas = [
    "Comuna 1", "Comuna 2", "Comuna 3", "Comuna 4", "Comuna 5",
    "Comuna 6", "Comuna 7", "Comuna 8", "Comuna 9", "Comuna 10",
    "Comuna 11", "Comuna 12", "Comuna 13", "Comuna 14", "Comuna 15",
  ];

  Future<void> _pickAndUpload(Function(String) onUploaded) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final fakeUrl = picked.path; // ⚠️ reemplazar por upload a Cloudinary
      setState(() => onUploaded(fakeUrl));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_localidad == null || !_aceptaCondiciones) {
      setState(() => _error = "Completa todos los campos y acepta los términos");
      return;
    }
    if (_fotoPerfil == null ||
        _fotoDniFrente == null ||
        _fotoDniDorso == null ||
        _selfieDni == null) {
      setState(() => _error = "Debes subir todas las fotos requeridas");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _auth.registerMedico(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
      matricula: _matricula.text.trim(),
      especialidad: _especialidad.text.trim(),
      telefono: _phone.text.trim(),
      provincia: _provincia,
      localidad: _localidad!,
      dni: _dni.text.trim(),
      fotoPerfil: _fotoPerfil,
      fotoDniFrente: _fotoDniFrente,
      fotoDniDorso: _fotoDniDorso,
      selfieDni: _selfieDni,
      tipo: _tipo,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (result["ok"] == true) {
      Navigator.pop(context);
      final mensaje = result["mensaje"] ??
          "Cuenta creada como $_tipo. Revisa tu correo para activar tu cuenta.";
      DocYaSnackbar.show(
        context,
        title: "✅ Registro exitoso",
        message: mensaje,
        type: SnackType.success,
      );
    } else {
      final errorMsg = result["detail"] ?? "No se pudo registrar.";
      DocYaSnackbar.show(
        context,
        title: "⚠️ Error",
        message: errorMsg,
        type: SnackType.error,
      );
    }
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF14B8A6)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Registro Profesional"),
        centerTitle: true,
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/docyapro.png", height: 80),
                      const SizedBox(height: 16),
                      const Text(
                        "Registrate en DocYa Pro",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Radio médico/enfermero
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Médico"),
                              value: "medico",
                              groupValue: _tipo,
                              onChanged: (val) =>
                                  setState(() => _tipo = val ?? "medico"),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text("Enfermero"),
                              value: "enfermero",
                              groupValue: _tipo,
                              onChanged: (val) =>
                                  setState(() => _tipo = val ?? "enfermero"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _name,
                        decoration:
                            _inputStyle("Nombre y apellido", Icons.person),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _dni,
                        decoration: _inputStyle("DNI", Icons.credit_card),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _matricula,
                        decoration: _inputStyle("Matrícula", Icons.badge),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerida' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _especialidad,
                        decoration: _inputStyle("Especialidad", Icons.work),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerida' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phone,
                        decoration: _inputStyle("Teléfono", Icons.phone_android),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Fotos
                      ElevatedButton.icon(
                        onPressed: () =>
                            _pickAndUpload((url) => _fotoPerfil = url),
                        icon: const Icon(Icons.person),
                        label: Text(_fotoPerfil == null
                            ? "Subir foto de perfil"
                            : "✔ Foto de perfil cargada"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _pickAndUpload((url) => _fotoDniFrente = url),
                        icon: const Icon(Icons.credit_card),
                        label: Text(_fotoDniFrente == null
                            ? "Subir DNI frente"
                            : "✔ Frente cargado"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _pickAndUpload((url) => _fotoDniDorso = url),
                        icon: const Icon(Icons.credit_card),
                        label: Text(_fotoDniDorso == null
                            ? "Subir DNI dorso"
                            : "✔ Dorso cargado"),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _pickAndUpload((url) => _selfieDni = url),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_selfieDni == null
                            ? "Subir selfie con DNI"
                            : "✔ Selfie cargada"),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _localidad,
                        decoration: _inputStyle("Comuna", Icons.location_city),
                        items: _comunas
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setState(() => _localidad = val),
                        validator: (v) =>
                            v == null ? "Selecciona una comuna" : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _email,
                        decoration: _inputStyle("Email", Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _password,
                        decoration: _inputStyle("Contraseña", Icons.lock),
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirm,
                        decoration: _inputStyle(
                            "Confirmar contraseña", Icons.check_circle),
                        obscureText: true,
                        validator: (v) =>
                            v != _password.text ? 'No coincide' : null,
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile(
                        value: _aceptaCondiciones,
                        activeColor: const Color(0xFF14B8A6),
                        onChanged: (val) =>
                            setState(() => _aceptaCondiciones = val ?? false),
                        title: Row(
                          children: [
                            const Expanded(
                              child: Text("Acepto los Términos y Condiciones",
                                  style: TextStyle(fontSize: 13)),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TerminosScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Ver",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF14B8A6),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14B8A6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  "Crear cuenta",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("¿Ya tenés cuenta? Inicia sesión"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
