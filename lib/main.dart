import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;

void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Age Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: windowWidth,
        height: windowHeight,
      ));
    });
  }
}

class Counter with ChangeNotifier {
  int value = 0;

  void increment() {
    if (value < 99) {
      value += 1;
      notifyListeners();
    }
  }

  void decrement() {
    if (value > 0) {
      value -= 1;
      notifyListeners();
    }
  }
  
  //  set the age directly (used by the slider)
  void setAge(int newAge) {
    if (newAge != value) {
      value = newAge;
      notifyListeners();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  
  // milestone data based on age
  Map<String, dynamic> getMilestoneData(int age) {
    if (age >= 0 && age <= 12) {
      return {
        'message': "You're a child!",
        'backgroundColor': Colors.lightBlue[100],
      };
    } else if (age >= 13 && age <= 19) {
      return {
        'message': "Teenager time!",
        'backgroundColor': Colors.lightGreen[100],
      };
    } else if (age >= 20 && age <= 30) {
      return {
        'message': "You're a young adult!",
        'backgroundColor': Colors.yellow[100],
      };
    } else if (age >= 31 && age <= 50) {
      return {
        'message': "You're an adult now!",
        'backgroundColor': Colors.orange[200],
      };
    } else {
      return {
        'message': "Golden years!",
        'backgroundColor': Colors.grey[300],
      };
    }
  }

  
  Color getProgressBarColor(int age) {
    if (age <= 33) {
      return Colors.green;
    } else if (age <= 67) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final counter = context.watch<Counter>();
    final milestoneData = getMilestoneData(counter.value);
    
    return Scaffold(
      backgroundColor: milestoneData['backgroundColor'],
      appBar: AppBar(
        title: const Text('Age Counter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Age: ${counter.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              milestoneData['message'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Slider to set age from 0 to 99
            Slider(
              value: counter.value.toDouble(),
              min: 0,
              max: 99,
              divisions: 99,
              label: '${counter.value}',
              onChanged: (double newValue) {
                context.read<Counter>().setAge(newValue.toInt());
              },
            ),
            const SizedBox(height: 16),
            // Progress bar that reflects the age value
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: counter.value / 99,
                child: Container(
                  decoration: BoxDecoration(
                    color: getProgressBarColor(counter.value),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Row with decrement and increment buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<Counter>().decrement();
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<Counter>().increment();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
