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
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('⚡ LEOX Premium Shop'),
          backgroundColor: const Color(0xFF1A1A2E),
        ),
        body: const Center(
          child: Text('Welcome to LEOX Premium Shop', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }
}
