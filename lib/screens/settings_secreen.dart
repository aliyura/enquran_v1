import 'package:enquran/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enquran/localizations/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:toast/toast.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Color pickerColor = AppTheme.background;
  Color currentColor = AppTheme.background;
  Color currentLanguageColor = AppTheme.background;
  Color arabicColor, englishColor, bothColor;

  @override
  void initState() {
    AppTheme.initilizeTheme();
    arabicColor =
        englishColor = bothColor = AppTheme.nearlyBlack.withOpacity(0.7);

    if (AppTheme.language == "English") {
      englishColor = AppTheme.background;
    } else if (AppTheme.language == "Arabic") {
      arabicColor = AppTheme.background;
    } else {
      bothColor = AppTheme.background;
    }

    super.initState();
  }

  _onColorChange(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('background', color.toString());
    setState(() {
      pickerColor = color;
      AppTheme.background = color;
      currentLanguageColor = color;
    });
  }

  _onLanguageChange(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    Toast.show("Language switched to " + language, context);
    arabicColor =
        englishColor = bothColor = AppTheme.nearlyBlack.withOpacity(0.7);
    setState(() {
      if (language == "English") {
        englishColor = AppTheme.background;
      } else if (language == "Arabic") {
        arabicColor = AppTheme.background;
      } else {
        bothColor = AppTheme.background;
      }
    });
  }

  void alert(message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).appName),
          content: Text(message),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text('Settings', style: TextStyle(color: AppTheme.white)),
      ),
      body: Container(
        color: AppTheme.nearlyWhite,
        child: ListView(
          children: <Widget>[
            Container(
              color: AppTheme.white,
              width: MediaQuery.of(context).size.width / 2,
              child: ListTile(
                contentPadding: EdgeInsets.only(top: 15, left: 15),
                title: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Change Theme',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                subtitle: FlatButton(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: <Widget>[
                        Container(
                          color: AppTheme.background,
                          height: 15,
                          width: 15,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Browse Colors",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ]),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        child: AlertDialog(
                          title: const Text('Pick a color!'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: _onColorChange,
                              enableLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                         
                        ),
                      );
                    }),
              ),
            ),
            Divider(),
            Container(
              color: AppTheme.white,
              width: MediaQuery.of(context).size.width / 2,
              child: ListTile(
                  contentPadding: EdgeInsets.only(top: 15, left: 15),
                  title: Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text('Languages',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                  subtitle: Column(children: <Widget>[
                    FlatButton(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(children: <Widget>[
                            Container(
                              color: arabicColor,
                              height: 15,
                              width: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Arabic",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          _onLanguageChange("Arabic");
                        }),
                    FlatButton(
                        highlightColor: AppTheme.grey,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(children: <Widget>[
                            Container(
                              color: englishColor,
                              height: 15,
                              width: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "English",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          _onLanguageChange("English");
                        }),
                    FlatButton(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(children: <Widget>[
                            Container(
                              color: bothColor,
                              height: 15,
                              width: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Both",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ]),
                        ),
                        onPressed: () {
                          _onLanguageChange("Both");
                        }),
                  ])),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
