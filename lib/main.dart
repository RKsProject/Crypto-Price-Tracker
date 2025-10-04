import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Price Tracker',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CryptoPage(),
    );
  }
}

class CryptoPage extends StatefulWidget {
  const CryptoPage({super.key});

  @override
  State<CryptoPage> createState() => _CryptoPageState();
}

class _CryptoPageState extends State<CryptoPage> {
  Map<String, dynamic>? cryptoData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchCryptoPrices();
  }

  Future<void> fetchCryptoPrices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final url = Uri.parse(
        "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,dogecoin&vs_currencies=usd");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          cryptoData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data. Error ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "No internet or server error.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💰 Crypto Price Tracker"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.red)
            : errorMessage != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchCryptoPrices,
              child: const Text("Retry"),
            )
          ],
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: cryptoData!.entries.map((entry) {
            final coin = entry.key.toUpperCase();
            final price = entry.value["usd"];
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.currency_bitcoin,
                    color: Colors.red, size: 30),
                title: Text(
                  coin,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white),
                ),
                trailing: Text(
                  "\$${price.toString()}",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchCryptoPrices,
        backgroundColor: Colors.red,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}