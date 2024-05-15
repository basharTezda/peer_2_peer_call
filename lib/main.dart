import 'package:chat/call.dart';
import 'package:flutter/material.dart';


final navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Setting a global key for navigator

      initialRoute: "/",
      routes: {
        "/": (context) => const CallExample(),
        // '/dataConnectionExample': (context) => const DataConnectionExample(),
      },
    );
  }
}
