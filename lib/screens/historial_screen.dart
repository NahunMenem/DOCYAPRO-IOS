import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ConsultaDetalleScreen.dart';

class HistorialScreen extends StatefulWidget {
  final int medicoId;

  const HistorialScreen({super.key, required this.medicoId});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<dynamic> _consultas = [];
  bool _loading = true;

  Future<void> _cargarHistorial() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://docya-railway-production.up.railway.app/consultas/historial_medico/${widget.medicoId}",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _consultas = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        throw Exception("Error al cargar historial");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: $e")),
      );
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case "finalizada":
        return Colors.green.shade600;
      case "rechazada":
        return Colors.red.shade600;
      case "en_camino":
        return Colors.orange.shade700;
      case "en_domicilio":
        return Colors.blue.shade700;
      case "aceptada":
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📋 Historial de consultas"),
        backgroundColor: const Color(0xFF14B8A6),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _consultas.isEmpty
              ? const Center(
                  child: Text(
                    "No hay consultas registradas",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  itemCount: _consultas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final consulta = _consultas[i];
                    final estado = consulta["estado"] ?? "desconocido";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _colorEstado(estado),
                        child: const Icon(Icons.medical_services,
                            color: Colors.white),
                      ),
                      title: Text(
                        consulta["motivo"] ?? "Sin motivo",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Paciente: ${consulta["paciente_nombre"]}"),
                          Text("Dirección: ${consulta["direccion"]}"),
                          Text(
                            "Estado: $estado",
                            style: TextStyle(color: _colorEstado(estado)),
                          ),
                          Text("Fecha: ${consulta["creado_en"]}"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConsultaDetalleScreen(consulta: consulta),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
