

import 'package:employee_flutter/constants.dart';
import 'package:employee_flutter/screens/home_screen.dart';
import 'package:employee_flutter/screens/login_screen.dart';
import 'package:employee_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SplcahScreen extends StatefulWidget{
  const SplcahScreen({super.key});

  @override
  State<SplcahScreen> createState()=>_SplashScreen();
}


class _SplashScreen extends State<SplcahScreen> {
   
 

  bool useMaterial3 = true;
   ThemeMode themeMode = ThemeMode.system;
  ColorSeed colorSelected = ColorSeed.baseColor;
  ColorImageProvider imageSelected = ColorImageProvider.leaves;
  ColorScheme? imageColorScheme = const ColorScheme.light();
  ColorSelectionMethod colorSelectionMethod = ColorSelectionMethod.colorSeed;
  
  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return View.of(context).platformDispatcher.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }
  
  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void handleMaterialVersionChange() {
    setState(() {
      useMaterial3 = !useMaterial3;
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelectionMethod = ColorSelectionMethod.colorSeed;
      colorSelected = ColorSeed.values[value];
    });
  }

  void handleImageSelect(int value) {
    final String url = ColorImageProvider.values[value].url;
    ColorScheme.fromImageProvider(provider: NetworkImage(url))
        .then((newScheme) {
      setState(() {
        colorSelectionMethod = ColorSelectionMethod.image;
        imageSelected = ColorImageProvider.values[value];
        imageColorScheme = newScheme;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return authService.currentUser == null
        ? const LoginScreen()
        :  Home(
          useLightMode: useLightMode,
           useMaterial3: useMaterial3,
            colorSelected: colorSelected,
             handleBrightnessChange: handleBrightnessChange,
              handleMaterialVersionChange: handleMaterialVersionChange,
               handleColorSelect: handleColorSelect,
                handleImageSelect: handleImageSelect,
                colorSelectionMethod: colorSelectionMethod,
                 imageSelected: imageSelected);
  }
}
