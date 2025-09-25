import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CertificadoScreen extends StatefulWidget {
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;

  const CertificadoScreen({
    super.key,
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
  });

  @override
  State<CertificadoScreen> createState() => _CertificadoScreenState();
}

class _CertificadoScreenState extends State<CertificadoScreen> {
  final _contenidoCtrl = TextEditingController();

  Future<void> _guardarCertificado() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}/certificado");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "medico_id": widget.medicoId,
        "paciente_uuid": widget.pacienteUuid,
        "contenido": _contenidoCtrl.text,
      }),
    );

    if (mounted) {
      if (resp.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Certificado guardado")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Error: ${resp.body}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Certificado")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _contenidoCtrl,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Contenido", "Ej: Reposo 48hs por cuadro febril"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardarCertificado,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Guardar Certificado",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputStyle(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white54),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
    ),
  );
}
