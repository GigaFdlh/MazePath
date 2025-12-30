import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/visualizer_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  runApp(const MazePathApp());
}

class MazePathApp extends StatelessWidget {
  const MazePathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VisualizerProvider()),
      ],
      child: MaterialApp(
        title: 'MazePath',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        
        home: const SplashScreen(),
      ),
    );
  }
}