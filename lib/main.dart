import 'package:flutter/material.dart';

void main() {
  runApp(const LeoXShopApp());
}

class LeoXShopApp extends StatelessWidget {
  const LeoXShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LEOX Premium Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        primaryColor: const Color(0xFF00FFA3),
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ LEOX Premium Shop', style: TextStyle(color: Color(0xFF00FFA3), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: const Center(
        child: Text('Welcome to LEOX Premium Shop', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
