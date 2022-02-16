import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_test/src/core/injection_container.dart' as getit_instance;
import 'package:tracker_test/src/features/devices/presentation/blue_listing_screen.dart';
import 'package:tracker_test/src/features/devices/presentation/session_export_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getit_instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arythm',
      theme: ThemeData(
        fontFamily: 'Monserrat',
        visualDensity: VisualDensity.adaptivePlatformDensity, colorScheme: ColorScheme.fromSwatch(primaryColorDark: Colors.blue[900]).copyWith(secondary: Colors.cyan[600], brightness: Brightness.dark ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          
        ),
      ),
      
      home: const BlueListingScreen(),//const EsportSessionForm()
    );
  }
}

