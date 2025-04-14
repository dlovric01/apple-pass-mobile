import 'package:add_to_wallet/add_to_wallet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Future<Uint8List> _passFuture;

  @override
  void initState() {
    super.initState();
    _passFuture = _fetchPass();
  }

  Future<Uint8List> _fetchPass() async {
    try {
      // Replace with your machine's IP address if testing on a device
      final response = await http.get(
        Uri.parse('http://localhost:3000/get-buffer'),
      );
      if (response.statusCode == 200) {
        return response.bodyBytes; // Returns Uint8List
      } else {
        throw Exception('Failed to load pass: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching pass: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Add your membership card to Wallet:'),
            FutureBuilder<Uint8List>(
              future: _passFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return AddToWalletButton(
                    pkPass: snapshot.data!,
                    width: 250,
                    height: 50,
                  );
                }
                return const Text('No data');
              },
            ),
          ],
        ),
      ),
    );
  }
}
