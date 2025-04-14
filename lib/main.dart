import 'package:apple_passkit/apple_passkit.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Apple Pass'),
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
  final passKit = ApplePassKit();

  @override
  void initState() {
    super.initState();
    _passFuture = _fetchPass();
    _passFuture.then((_) async {
      passkit();
    });
  }

  Future<void> passkit() async {
    bool isAvailable = await passKit.isPassLibraryAvailable();
    bool canAddPasses = await passKit.canAddPasses();

    if (isAvailable && canAddPasses) {
      // PassKit is available and can add passes
      debugPrint('PassKit is available and can add passes');
    } else {
      // PassKit is not available or cannot add passes
      debugPrint('PassKit is not available or cannot add passes');
    }
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
                  return ElevatedButton(
                    onPressed: () async {
                      try {
                        await passKit.addPass(snapshot.data!);
                      } catch (e) {
                        debugPrint('Error adding pass: $e');
                      }
                    },
                    child: const Text('Add to Wallet'),
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
