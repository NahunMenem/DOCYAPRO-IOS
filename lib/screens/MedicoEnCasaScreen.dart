import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

/// Pantalla principal del médico cuando acepta una consulta
class MedicoEnCasaScreen extends StatefulWidget {
  final VoidCallback? onFinalizar; // 👈 nuevo
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;
  final String pacienteNombre;
  final String direccion;
  final String motivo;
  final double lat;
  final double lng;


  const MedicoEnCasaScreen({
    super.key,
    this.onFinalizar, // 👈 ahora sí
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
    required this.pacienteNombre,
    required this.direccion,
    required this.motivo,
    required this.lat,
    required this.lng,
  });

  @override
  State<MedicoEnCasaScreen> createState() => _MedicoEnCasaScreenState();
}

class _MedicoEnCasaScreenState extends State<MedicoEnCasaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> marcarEnCamino() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}/encamino");
    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"medico_id": widget.medicoId}));
    if (resp.statusCode == 200) {
      print("🚗 Estado cambiado a en_camino");
    } else {
      print("⚠️ Error al marcar en_camino: ${resp.body}");
    }
  }

  Future<void> finalizarConsulta() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}/finalizar");
    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"medico_id": widget.medicoId}));
    if (resp.statusCode == 200 && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Consulta finalizada")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Error: ${resp.body}")));
    }
  }

  Future<void> _abrirEnGoogleMaps(String direccion) async {
    final query = Uri.encodeComponent(direccion);
    final url = "https://www.google.com/maps/search/?api=1&query=$query";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Consulta en curso"),
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 🔹 Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.pacienteNombre,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on, color: Color(0xFF14B8A6)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(widget.direccion)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.healing, color: Color(0xFF14B8A6)),
                  const SizedBox(width: 6),
                  Expanded(child: Text("Motivo: ${widget.motivo}")),
                ]),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await marcarEnCamino();
                    _abrirEnGoogleMaps(widget.direccion);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 45)),
                  icon: const Icon(Icons.navigation, color: Colors.white),
                  label: const Text("Iniciar viaje",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),

          // 🔹 Tabs
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF14B8A6),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF14B8A6),
            tabs: const [
              Tab(icon: Icon(Icons.assignment), text: "Certificado"),
              Tab(icon: Icon(Icons.medication), text: "Receta"),
              Tab(icon: Icon(Icons.note_alt), text: "Historia Clínica"),
            ],
          ),

          // 🔹 Contenido
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CertificadoForm(
                  consultaId: widget.consultaId,
                  medicoId: widget.medicoId,
                  pacienteUuid: widget.pacienteUuid,
                ),
                RecetaForm(
                  consultaId: widget.consultaId,
                  medicoId: widget.medicoId,
                  pacienteUuid: widget.pacienteUuid,
                ),
                HistoriaClinicaForm(
                  consultaId: widget.consultaId,
                  medicoId: widget.medicoId,
                  pacienteUuid: widget.pacienteUuid,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: finalizarConsulta,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50)),
            child: const Text("Finalizar Consulta",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

//
// --------------------------- FORMULARIOS ---------------------------
//

/// 📄 Formulario Certificado
class CertificadoForm extends StatefulWidget {
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;

  const CertificadoForm({
    super.key,
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
  });

  @override
  State<CertificadoForm> createState() => _CertificadoFormState();
}

class _CertificadoFormState extends State<CertificadoForm> {
  final _contenidoCtrl = TextEditingController();

  Future<void> _guardarCertificado() async {
    final url = Uri.parse(
        "https://docya-railway-production.up.railway.app/consultas/${widget.consultaId}/certificado");
    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "medico_id": widget.medicoId,
          "paciente_uuid": widget.pacienteUuid,
          "contenido": _contenidoCtrl.text
        }));
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Certificado guardado")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Error: ${resp.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Generar Certificado Médico",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _contenidoCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Ej: Paciente en reposo 48hs por cuadro febril",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _guardarCertificado,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.save),
            label: const Text("Guardar Certificado"),
          ),
        ],
      ),
    );
  }
}

/// 💊 Formulario Receta
class RecetaForm extends StatefulWidget {
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;

  const RecetaForm({
    super.key,
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
  });

  @override
  State<RecetaForm> createState() => _RecetaFormState();
}

class _RecetaFormState extends State<RecetaForm> {
  final List<Map<String, String>> _medicamentos = [];
  final _nombreCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _frecuenciaCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();

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
    final resp = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "medico_id": widget.medicoId,
          "paciente_uuid": widget.pacienteUuid,
          "medicamentos": _medicamentos
        }));
    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Receta guardada")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Error: ${resp.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Generar Receta Digital",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: "Medicamento", hintText: "Ej: Ibuprofeno", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _dosisCtrl, decoration: const InputDecoration(labelText: "Dosis", hintText: "Ej: 500mg", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _frecuenciaCtrl, decoration: const InputDecoration(labelText: "Frecuencia", hintText: "Ej: cada 8 hs", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _duracionCtrl, decoration: const InputDecoration(labelText: "Duración", hintText: "Ej: por 5 días", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _agregarMedicamento,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Agregar medicamento"),
          ),
          const SizedBox(height: 15),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medicamentos.length,
            itemBuilder: (context, index) {
              final med = _medicamentos[index];
              return Card(
                child: ListTile(
                  title: Text(med["nombre"]!),
                  subtitle: Text("${med["dosis"]}, ${med["frecuencia"]}, por ${med["duracion"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _medicamentos.removeAt(index));
                    },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _guardarReceta,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.save),
            label: const Text("Guardar Receta"),
          ),
        ],
      ),
    );
  }
}

/// 🩺 Formulario Historia Clínica
class HistoriaClinicaForm extends StatefulWidget {
  final int consultaId;
  final int medicoId;
  final String pacienteUuid;

  const HistoriaClinicaForm({
    super.key,
    required this.consultaId,
    required this.medicoId,
    required this.pacienteUuid,
  });

  @override
  State<HistoriaClinicaForm> createState() => _HistoriaClinicaFormState();
}

class _HistoriaClinicaFormState extends State<HistoriaClinicaForm> {
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
    final resp = await http.post(url,
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
          })
        }));

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Historia clínica guardada")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Error: ${resp.body}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Historia Clínica",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          TextField(
            controller: _motivoCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: "Motivo de consulta",
              hintText: "Ej: fiebre de 48hs de evolución",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Signos vitales
          Row(
            children: [
              Expanded(child: TextField(controller: _taCtrl, decoration: const InputDecoration(labelText: "TA", hintText: "Ej: 120/80", border: OutlineInputBorder()))),
              const SizedBox(width: 6),
              Expanded(child: TextField(controller: _satCtrl, decoration: const InputDecoration(labelText: "Sat%", hintText: "Ej: 98%", border: OutlineInputBorder()))),
              const SizedBox(width: 6),
              Expanded(child: TextField(controller: _tempCtrl, decoration: const InputDecoration(labelText: "T°", hintText: "Ej: 37.5°C", border: OutlineInputBorder()))),
              const SizedBox(width: 6),
              Expanded(child: TextField(controller: _fcCtrl, decoration: const InputDecoration(labelText: "FC", hintText: "Ej: 80 lpm", border: OutlineInputBorder()))),
            ],
          ),
          const SizedBox(height: 12),

          TextField(controller: _respiratorioCtrl, decoration: const InputDecoration(labelText: "Aparato respiratorio", hintText: "Ej: MVB+ sin ruidos patológicos agregados", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _cardioCtrl, decoration: const InputDecoration(labelText: "Aparato cardiovascular", hintText: "Ej: R1 R2 normofonético, sin soplos ni edemas", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _abdomenCtrl, decoration: const InputDecoration(labelText: "Abdomen / Genito urinario", hintText: "Ej: blando, depresible, no doloroso, RHA positivos", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _sncCtrl, decoration: const InputDecoration(labelText: "Sistema nervioso central", hintText: "Ej: lúcido, orientado, sin signos de irritación meníngea", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _observacionCtrl, decoration: const InputDecoration(labelText: "Observación", hintText: "Ej: opcional", border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _diagnosticoCtrl, decoration: const InputDecoration(labelText: "Diagnóstico", hintText: "Ej: síndrome febril en estudio", border: OutlineInputBorder())),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _guardarHistoria,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.save),
            label: const Text("Guardar Historia Clínica"),
          ),
        ],
      ),
    );
  }
}
