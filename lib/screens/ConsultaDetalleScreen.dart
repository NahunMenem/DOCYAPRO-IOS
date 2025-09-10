import 'package:flutter/material.dart';

class ConsultaDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> consulta;

  const ConsultaDetalleScreen({super.key, required this.consulta});

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
  Widget build(BuildContext context) {
    final estado = consulta["estado"] ?? "desconocido";

    return Scaffold(
      appBar: AppBar(
        title: const Text("📝 Detalle de consulta"),
        backgroundColor: const Color(0xFF14B8A6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Estado
            Card(
              color: _colorEstado(estado).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.info, color: _colorEstado(estado)),
                title: Text(
                  "Estado: $estado",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _colorEstado(estado),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Motivo
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    const Icon(Icons.healing, color: Color(0xFF14B8A6)),
                title: Text(
                  consulta["motivo"] ?? "Sin motivo",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Paciente
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF14B8A6)),
                title: Text(consulta["paciente_nombre"] ?? "Paciente"),
              ),
            ),
            const SizedBox(height: 15),

            // Dirección
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    const Icon(Icons.location_on, color: Color(0xFF14B8A6)),
                title: Text(consulta["direccion"] ?? "Dirección desconocida"),
              ),
            ),
            const SizedBox(height: 15),

            // Fecha
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    const Icon(Icons.calendar_today, color: Color(0xFF14B8A6)),
                title: Text("Fecha: ${consulta["creado_en"]}"),
              ),
            ),
            const SizedBox(height: 25),

            // Recetas / Certificados
            if (estado == "finalizada") ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onPressed: () {
                  // TODO: Navegar a pantalla de receta (usar backend /consultas/{id}/receta)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("📄 Ver receta (próximamente)")),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text("Ver receta"),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onPressed: () {
                  // TODO: Navegar a pantalla de certificado (usar backend /consultas/{id}/certificado)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("🧾 Ver certificado (próximamente)")),
                  );
                },
                icon: const Icon(Icons.description),
                label: const Text("Ver certificado"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
