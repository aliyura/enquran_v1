import 'package:flutter/material.dart';
import 'package:enquran/app_themes.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:enquran/screens/app.dart';
import 'package:enquran/screens/choose_language.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new App());

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool initialized = false;
  @override
  void initState() {
    AppTheme.initilizeTheme();
    getAppState();
    
    super.initState();
  }

  void getAppState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String init = prefs.getString('init');
    setState(() {
      if (init != null && init != '') {
        initialized = true;
      } else {
        initialized = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'en Quran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      color: AppTheme.background,
      home: SplashScreen(
        image: Image.asset('assets/images/launcher.png'),
        seconds: 5,
        backgroundColor: AppTheme.background,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.white,
        navigateAfterSeconds:
          initialized != true ? ChooseLanguage() : MyApp(),
      ),
    );
  }
}
