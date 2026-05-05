import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia API App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TriviaPage(),
    );
  }
}

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  State<TriviaPage> createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  String _category = "";
  List<dynamic> _options = [];
  String _question = "Press the button below to fetch trivia!";
  String _answer = "";
  bool _isLoading = false;

  // Function to fetch data from Open Trivia DB
  Future<void> fetchTrivia() async {
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=1&category=28&type=multiple',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // results is a list, so we take the first item [0]
        final result = data['results'][0];

        setState(() {
          _category = result['category'];
          _question = result['question'];
          _answer = result['correct_answer'];
          _options = result["incorrect_answers"];
          _options.add(_answer);
          _options.shuffle();
        });
      } else {
        setState(() => _question = "Failed to load data.");
      }
    } catch (e) {
      setState(() => _question = "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trivia Database"), centerTitle: true),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Display category if it exists
                    if (_category.isNotEmpty)
                      Text(
                        "CATEGORY: $_category",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Display the question
                    Text(
                      _question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _options.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_options[index]),
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            onTap: () {
                              setState(() {
                                _category = (_options[index] == _answer)
                                    ? "correct answer"
                                    : "wrong answer";
                              });
                            },
                          );
                        },
                      ),
                    ),

                    ElevatedButton.icon(
                      onPressed: () {
                        fetchTrivia();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("new question"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
