import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 📌 Importá tu nueva pantalla de login
import 'screens/login_screen_pro.dart';
// 📌 Importá el modal
import 'widgets/consulta_entrante_modal.dart';
// 📌 Importá chat
import 'screens/chat_medico_screen.dart';

// 🔔 Handler para notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Notificación en background: ${message.messageId}");
}

// 👇 Clave global para usar Navigator fuera del contexto
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Registrar handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializar notificaciones (listener foreground)
  await NotificationService.init();

  runApp(const DocYaApp());
}

class DocYaApp extends StatelessWidget {
  const DocYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocYa',
      navigatorKey: navigatorKey, // 👈 necesario para abrir modal o chat
      theme: ThemeData(
        primaryColor: const Color(0xFF14B8A6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF14B8A6)),
      ),
      // 👇 Arranca siempre en la pantalla de login
      home: const LoginScreenPro(),
    );
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Inicializa la configuración de notificaciones
  static Future<void> init() async {
    // Pedir permisos (iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("🔔 Permisos: ${settings.authorizationStatus}");

    // Obtener token del dispositivo
    String? token = await _messaging.getToken();
    print("🔑 Token FCM: $token");

    // TODO: acá deberías enviar este token a tu backend
    // await tuApi.guardarFcmToken(token);

    // Listener para notificaciones en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📨 Notificación foreground: ${message.data}");

      // 👇 Si es consulta nueva
      if (message.data["tipo"] == "consulta_nueva") {
        final profesionalId =
            message.data["medico_id"] ?? message.data["enfermero_id"];
        if (profesionalId != null && navigatorKey.currentContext != null) {
          mostrarConsultaEntrante(
            navigatorKey.currentContext!,
            profesionalId.toString(),
          );
        }
      }

      // 👇 Si es un nuevo mensaje en chat
      if (message.data["tipo"] == "nuevo_mensaje") {
        final consultaId = int.tryParse(message.data["consulta_id"] ?? "0");
        final remitenteId = message.data["remitente_id"] ?? "";
        if (consultaId != null && consultaId > 0) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(content: Text("💬 Nuevo mensaje en consulta $consultaId")),
          );

          // Opcional: abrir chat directamente si estás en foreground
          // navigatorKey.currentState!.push(
          //   MaterialPageRoute(
          //     builder: (context) => ChatMedicoScreen(
          //       consultaId: consultaId,
          //       medicoId: int.tryParse(remitenteId) ?? 0,
          //       nombreMedico: "Dr. $remitenteId", // 👈 agregado
          //     ),
          //   ),
          // );
        }
      }
    });

    // Listener cuando el médico toca la notificación en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data["tipo"] == "nuevo_mensaje") {
        final consultaId = int.tryParse(message.data["consulta_id"] ?? "0");
        final remitenteId = message.data["remitente_id"] ?? "";
        if (consultaId != null && consultaId > 0) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (context) => ChatMedicoScreen(
                consultaId: consultaId,
                medicoId: int.tryParse(remitenteId) ?? 0,
                nombreMedico: "Dr. $remitenteId", // 👈 agregado
              ),
            ),
          );
        }
      }
    });
  }
}
