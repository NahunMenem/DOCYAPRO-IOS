import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editar_alias_screen.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreUsuario;
  final String medicoId;

  const PerfilScreen({
    super.key,
    required this.nombreUsuario,
    required this.medicoId,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String? alias;
  String? fotoUrl;
  String? nombreCompleto;
  String? matricula;
  String? email;
  String? telefono;
  String? especialidad;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    try {
      final res = await http.get(
        Uri.parse("https://docya-railway-production.up.railway.app/medicos/${widget.medicoId}"),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          alias = data["alias_cbu"];
          fotoUrl = data["foto_perfil"];
          nombreCompleto = data["full_name"];
          matricula = data["matricula"];
          email = data["email"];
          telefono = data["telefono"];
          especialidad = data["especialidad"];
          _loading = false;
        });
      } else {
        print("❌ Error backend al cargar perfil: ${res.body}");
        setState(() => _loading = false);
      }
    } catch (e) {
      print("❌ Error cargando perfil: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _cambiarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("https://docya-railway-production.up.railway.app/medicos/${widget.medicoId}/foto"),
    );
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        setState(() {
          fotoUrl = data["foto_url"];
        });
      } else {
        print("❌ Error subiendo foto: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error en la subida de foto: $e");
    }
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Encabezado con foto y nombre
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.shade200,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _cambiarFoto,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                              ? NetworkImage(fotoUrl!)
                              : null,
                          backgroundColor: const Color(0xFF14B8A6),
                          child: (fotoUrl == null || fotoUrl!.isEmpty)
                              ? const Icon(Icons.person, color: Colors.white, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          nombreCompleto ?? widget.nombreUsuario,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const Divider(),

                // Datos del médico
                ListTile(
                  leading: const Icon(Icons.badge, color: Color(0xFF14B8A6)),
                  title: const Text("Matrícula"),
                  subtitle: Text(matricula ?? "No configurada"),
                ),
                ListTile(
                  leading: const Icon(Icons.local_hospital, color: Color(0xFF14B8A6)),
                  title: const Text("Especialidad"),
                  subtitle: Text(especialidad ?? "No configurada"),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Color(0xFF14B8A6)),
                  title: const Text("Email"),
                  subtitle: Text(email ?? "No configurado"),
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF14B8A6)),
                  title: const Text("Teléfono"),
                  subtitle: Text(telefono ?? "No configurado"),
                ),

                const Divider(),

                // Alias bancario
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet,
                      color: Color(0xFF14B8A6)),
                  title: const Text("Alias / CBU"),
                  subtitle: Text(alias == null || alias!.isEmpty
                      ? "No configurado"
                      : alias!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final nuevoAlias = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditarAliasScreen(
                          medicoId: widget.medicoId,
                          aliasActual: alias ?? "",
                        ),
                      ),
                    );

                    if (nuevoAlias != null) {
                      setState(() {
                        alias = nuevoAlias;
                      });
                    }
                  },
                ),

                const Divider(),

                // Cerrar sesión
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text("Cerrar sesión"),
                  onTap: _cerrarSesion,
                ),
              ],
            ),
    );
  }
}
