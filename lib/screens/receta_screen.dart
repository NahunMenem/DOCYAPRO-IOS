import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecetaScreen extends StatefulWidget {
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;

  const RecetaScreen({
    super.key,
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
  });

  @override
  State<RecetaScreen> createState() => _RecetaScreenState();
}

class _RecetaScreenState extends State<RecetaScreen> {
  final _nombreCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _frecuenciaCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();
  final List<Map<String, String>> _medicamentos = [];

  void _agregarMedicamento() {
    if (_nombreCtrl.text.isNotEmpty &&
        _dosisCtrl.text.isNotEmpty &&
        _frecuenciaCtrl.text.isNotEmpty &&
        _duracionCtrl.text.isNotEmpty) {
      setState(() {
        _medicamentos.add({
          "nombre": _nombreCtrl.text,
          "dosis": _dosisCtrl.text,
          "frecuencia": _frecuenciaCtrl.text,
          "duracion": _duracionCtrl.text,
        });
        _nombreCtrl.clear();
        _dosisCtrl.clear();
        _frecuenciaCtrl.clear();
        _duracionCtrl.clear();
      });
    }
  }

  Future<void> _guardarReceta() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}/receta");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "medico_id": widget.medicoId,
        "paciente_uuid": widget.pacienteUuid,
        "medicamentos": _medicamentos,
      }),
    );

    if (mounted) {
      if (resp.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Receta guardada")),
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
      appBar: AppBar(title: const Text("Receta Médica")),
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
              controller: _nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Medicamento", "Ej: Ibuprofeno 600mg"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dosisCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Dosis", "Ej: 1 comprimido"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _frecuenciaCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Frecuencia", "Ej: cada 8 hs"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _duracionCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Duración", "Ej: por 5 días"),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              onPressed: _agregarMedicamento,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.tealAccent),
                minimumSize: const Size(double.infinity, 45),
              ),
              icon: const Icon(Icons.add, color: Colors.tealAccent),
              label: const Text("Agregar medicamento",
                  style: TextStyle(color: Colors.tealAccent)),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: _medicamentos.map((med) {
                  return Card(
                    color: Colors.white.withOpacity(0.08),
                    child: ListTile(
                      title: Text(med["nombre"]!,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                          "${med["dosis"]}, ${med["frecuencia"]}, ${med["duracion"]}",
                          style: const TextStyle(color: Colors.white70)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          setState(() => _medicamentos.remove(med));
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _guardarReceta,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  minimumSize: const Size(double.infinity, 50)),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Guardar Receta",
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
