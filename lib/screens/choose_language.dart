import 'package:enquran/localizations/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enquran/app_themes.dart';
import 'package:toast/toast.dart';
import 'package:enquran/main.dart';

class ChooseLanguage extends StatefulWidget {
  @override
  _CountryState createState() => _CountryState();
}

class _CountryState extends State<ChooseLanguage> {
  String selectedLanguage;
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
    _onInit();
    super.initState();
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
  _onInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('init', 'yes');
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
      backgroundColor: AppTheme.background,
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: AppTheme.white,
            width: MediaQuery.of(context).size.width / 1.5,
            child: ListTile(
                contentPadding: EdgeInsets.only(top: 15, left: 15),
                title: Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Choose Language',
                      style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                subtitle: Column(children: <Widget>[
                  Text(
                      'Note: You can change the language letter in the seetings'),
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
                            "Only Arabic",
                            style: TextStyle(color: Colors.black, fontSize: 20),
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
                            "Only English",
                            style: TextStyle(color: Colors.black, fontSize: 20),
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
                            "Both Arabic & English",
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
          GestureDetector(
              onTap: () {
                _onInit();
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              child: Container(
                width: 150,
                height: 40,
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.only(top: 40),
                padding:
                    EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppTheme.white,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_forward,
                      size: 15,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Continue',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))
                  ],
                ),
              )),
        ],
      )),
    );
  }
}
