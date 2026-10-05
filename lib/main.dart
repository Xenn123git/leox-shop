import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ⚙️ Backend URL (အဆုံးတွင် /api ထည့်ရန် လိုအပ်သည်)
const String apiBaseUrl = "http://9.41.10.173:5000/api"; 

void main() {
  runApp(const LeoXShopApp());
}

class LeoXShopApp extends StatelessWidget {
  const LeoXShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeoX All in One Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D18),
        primaryColor: const Color(0xFF00FFA3),
        cardColor: const Color(0xFF161626),
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
  Map<String, dynamic>? currentUser; // null ဖြစ်နေလျှင် Guest
  List<dynamic> products = [];
  bool isLoading = true;

  // Payment Details Configuration
  final Map<String, Map<String, String>> paymentInfo = {
    'KPay': {'no': '09687512062', 'name': 'Ma Chit su'},
    'Wave Pay': {'no': '09687512062', 'name': 'Ye Htet Aung'},
    'UAB Pay': {'no': '09973141351', 'name': 'Ye Htet Aung'},
    'Binance (TRC20)': {'no': 'TRC20_ADDRESS_HERE', 'name': 'LeoX Store'},
    'Leo Wallet': {'no': 'In-App Balance', 'name': 'Automatic Deduction'}
  };

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final res = await http.get(Uri.parse('$apiBaseUrl/products'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          products = data['products'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _showAuthModal(bool isLogin) {
    final accController = TextEditingController();
    final passController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161626),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20, left: 20, right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin ? '🔑 Account Login' : '📝 Register Account',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00FFA3)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: accController,
                decoration: const InputDecoration(
                  labelText: 'Phone / Email / Telegram Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFA3),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  String endpoint = isLogin ? '/login' : '/register';
                  final res = await http.post(
                    Uri.parse('$apiBaseUrl$endpoint'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'account_id': accController.text.trim(),
                      'password': passController.text.trim(),
                    }),
                  );
                  final data = jsonDecode(res.body);
                  if (res.statusCode == 200 && isLogin) {
                    setState(() => currentUser = data['user']);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(data['message'] ?? 'Error')),
                    );
                    if (!isLogin && res.statusCode == 200) Navigator.pop(context);
                  }
                },
                child: Text(isLogin ? 'Login' : 'Register', style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      },
    );
  }

  void _showCheckoutModal(Map<String, dynamic> product) {
    if (currentUser == null) {
      _showAuthModal(true);
      return;
    }

    String selectedPayment = 'KPay';
    final gameIdController = TextEditingController();
    final tranLast5Controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161626),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulWidget(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🛒 Buying: ${product['name']}', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00FFA3))),
                    const SizedBox(height: 10),
                    TextField(
                      controller: gameIdController,
                      decoration: const InputDecoration(labelText: 'Game ID / Account ID', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 15),
                    const Text('Select Payment Method:'),
                    DropdownButton<String>(
                      value: selectedPayment,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF161626),
                      items: paymentInfo.keys.map((String key) {
                        return DropdownMenuItem<String>(value: key, child: Text(key));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => selectedPayment = val!);
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pay No: ${paymentInfo[selectedPayment]!['no']}', style: const TextStyle(color: Color(0xFF00FFA3))),
                          Text('Name: ${paymentInfo[selectedPayment]!['name']}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (selectedPayment != 'Leo Wallet')
                      TextField(
                        controller: tranLast5Controller,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: const InputDecoration(
                          labelText: 'Transaction ID (နောက်ဆုံး ၅ လုံး)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFA3),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () async {
                        if (selectedPayment != 'Leo Wallet' && tranLast5Controller.text.length < 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction ID နောက်ဆုံး ၅ လုံး ဖြည့်ပါ')),
                          );
                          return;
                        }

                        final res = await http.post(
                          Uri.parse('$apiBaseUrl/orders'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            'account_id': currentUser!['account_id'],
                            'product_name': product['name'],
                            'game_id': gameIdController.text.trim(),
                            'amount': product['price'],
                            'payment_method': selectedPayment,
                            'tran_last5': tranLast5Controller.text.trim(),
                          }),
                        );

                        final data = jsonDecode(res.body);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data['message'])),
                        );
                      },
                      child: const Text('Confirm Order', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡ LeoX Shop', style: TextStyle(color: Color(0xFF00FFA3), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF161626),
        actions: [
          if (currentUser == null) ...[
            TextButton(onPressed: () => _showAuthModal(true), child: const Text('Login')),
            TextButton(onPressed: () => _showAuthModal(false), child: const Text('Register')),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Text('💰 ${currentUser!['wallet_balance']} MMK', 
                  style: const TextStyle(color: Color(0xFF00FFA3), fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item['category']} • ${item['price']} MMK'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFA3), foregroundColor: Colors.black),
                    onPressed: () => _showCheckoutModal(item),
                    child: const Text('Buy Now'),
                  ),
                ),
              );
            },
          ),
    );
  }
}
