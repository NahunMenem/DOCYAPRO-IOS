import 'package:flutter/material.dart';

class TerminosScreen extends StatelessWidget {
  const TerminosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Términos y Condiciones"),
        centerTitle: true,
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Términos y Condiciones – DocYa Pro",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Bienvenido a DocYa Pro. Antes de comenzar a utilizar la aplicación, "
              "te pedimos que leas atentamente los siguientes términos y condiciones:",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 20),

            Text(
              "1. Registro y veracidad de datos",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Al registrarte en DocYa Pro confirmás que los datos brindados son reales, "
              "incluyendo matrícula profesional y especialidad.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 15),

            Text(
              "2. Disponibilidad y penalizaciones",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Debés marcar tu estado como 'Disponible' al menos 2 horas por día. "
              "En caso contrario, la plataforma podrá aplicar penalizaciones en tu perfil.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 15),

            Text(
              "3. Conducta profesional",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Los médicos deben brindar atención respetuosa, ética y ajustada a la normativa vigente. "
              "Cualquier conducta inapropiada podrá derivar en la suspensión de la cuenta.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 15),

            Text(
              "4. Confidencialidad",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "La información de los pacientes es confidencial y debe resguardarse en todo momento. "
              "El mal uso de la misma será considerado falta grave.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 15),

            Text(
              "5. Pagos y comisiones",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "DocYa Pro retiene una comisión del 20% por cada consulta realizada. "
              "Los pagos a médicos se acreditan semanalmente en la cuenta bancaria registrada.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 15),

            Text(
              "6. Aceptación",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Al registrarte y usar DocYa Pro confirmás que aceptás estos términos y condiciones.",
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 30),

            Center(
              child: Text(
                "© 2025 DocYa Pro – Salud a tu puerta",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
