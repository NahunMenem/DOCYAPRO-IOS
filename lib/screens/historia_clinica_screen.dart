import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoriaClinicaScreen extends StatefulWidget {
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;

  const HistoriaClinicaScreen({
    super.key,
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
  });

  @override
  State<HistoriaClinicaScreen> createState() => _HistoriaClinicaScreenState();
}

class _HistoriaClinicaScreenState extends State<HistoriaClinicaScreen> {
  final _motivoCtrl = TextEditingController();
  final _taCtrl = TextEditingController();
  final _satCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _fcCtrl = TextEditingController();
  final _respiratorioCtrl = TextEditingController();
  final _cardioCtrl = TextEditingController();
  final _abdomenCtrl = TextEditingController();
  final _sncCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();
  final _diagnosticoCtrl = TextEditingController();

  Future<void> _guardarHistoria() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}/nota");
    final resp = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "medico_id": widget.medicoId,
        "paciente_uuid": widget.pacienteUuid,
        "contenido": jsonEncode({
          "motivo": _motivoCtrl.text,
          "signos_vitales": {
            "ta": _taCtrl.text,
            "sat": _satCtrl.text,
            "temp": _tempCtrl.text,
            "fc": _fcCtrl.text,
          },
          "respiratorio": _respiratorioCtrl.text,
          "cardio": _cardioCtrl.text,
          "abdomen": _abdomenCtrl.text,
          "snc": _sncCtrl.text,
          "observacion": _observacionCtrl.text,
          "diagnostico": _diagnosticoCtrl.text,
        }),
      }),
    );

    if (mounted) {
      if (resp.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Historia clínica guardada")),
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
      appBar: AppBar(title: const Text("Historia Clínica")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _motivoCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Motivo de consulta", "Ej: fiebre de 48hs"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("TA", "120/80"),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _satCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Sat%", "98%"),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _tempCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("T°", "37.5"),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _fcCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("FC", "80 lpm"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _respiratorioCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Aparato respiratorio", "Ej: MVB+ sin ruidos"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cardioCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Cardiovascular", "Ej: R1 R2 normofonético"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _abdomenCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Abdomen", "Ej: blando, depresible, indoloro"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sncCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Sistema nervioso", "Ej: lúcido, orientado"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _observacionCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Observación", "Opcional"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _diagnosticoCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle("Diagnóstico", "Síndrome febril"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _guardarHistoria,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
                minimumSize: const Size(double.infinity, 50),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Guardar Historia Clínica",
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
