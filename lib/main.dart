import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 📌 Importá tu nueva pantalla de login
import 'screens/login_screen_pro.dart';

// 🔔 Handler para notificaciones en segundo plano
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Notificación en background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Registrar handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const DocYaApp());
}

class DocYaApp extends StatelessWidget {
  const DocYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocYa',
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
      print("📨 Notificación foreground: ${message.notification?.title}");
    });
  }
}
