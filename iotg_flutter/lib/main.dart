import 'package:iotg_client/iotg_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'providers/observability_provider.dart';
import 'screens/observability_screen.dart';

late final Client client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final serverUrl = await getServerUrl();

  client = Client(
    serverUrl,
    connectionTimeout: const Duration(minutes: 3),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ObservabilityProvider(client),
      child: const IoTGApp(),
    ),
  );
}

class IoTGApp extends StatelessWidget {
  const IoTGApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoTG Observability',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D4FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF060F1E),
        fontFamily: 'Roboto',
        useMaterial3: true,
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFF00D4FF),
          inactiveTrackColor: Colors.white12,
          thumbColor: Color(0xFF00D4FF),
          overlayColor: Color(0x2200D4FF),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1E2D40),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const ObservabilityScreen(),
    );
  }
}
