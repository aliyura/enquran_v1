import 'dart:convert';
import 'dart:io';

import 'package:enquran/app_themes.dart';
import 'package:enquran/screens/choose_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:enquran/app_settings.dart';
import 'package:enquran/helpers/settings_helpers.dart';
import 'package:enquran/localizations/app_localizations.dart';
import 'package:enquran/models/theme_model.dart';
import 'package:enquran/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:enquran/services/bookmarks_data_service.dart';
import 'package:enquran/services/database_file_service.dart';
import 'package:enquran/services/quran_data_services.dart';
import 'package:enquran/services/translations_list_service.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:kiwi/kiwi.dart' as kiwi;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

void registerDependencies() {
  Application.container
      .registerSingleton<IBookmarksDataService, BookmarksDataService>(
          (c) => BookmarksDataService());
  Application.container
      .registerSingleton<ITranslationsListService, TranslationsListService>(
    (c) => TranslationsListService(),
  );
  Application.container.registerSingleton<IQuranDataService, QuranDataService>(
    (c) => QuranDataService(),
  );
  Application.container
      .registerSingleton<IDatabaseFileService, DatabaseFileService>(
          (c) => DatabaseFileService());
}

typedef void ChangeLocaleCallback(Locale locale);
typedef void ChangeThemeCallback(ThemeModel themeMpdel);

class Application {
  static ChangeLocaleCallback changeLocale;

  static ChangeThemeCallback changeThemeCallback;

  static kiwi.Container container = kiwi.Container();
}

class MyAppModel extends Model {
  AppLocalizationsDelegate appLocalizationsDelegate;
  Locale locale;

  List<Locale> supportedLocales = [
    Locale('en'),
  ];

  MyAppModel({
    @required this.locale,
  }) {
    appLocalizationsDelegate = AppLocalizationsDelegate(
      locale: locale,
      supportedLocales: supportedLocales,
    );
  }

  void changeLocale(Locale locale) {
    this.locale = locale;
    notifyListeners();
  }
}

class _MyAppState extends State<MyApp> {
  MyAppModel myAppModel;
  ThemeData currentTheme;

  @override
  void initState() {
    AppTheme.initilizeTheme();
    myAppModel = MyAppModel(
      locale: Locale(
        'en',
      ),
    );

    Application.changeLocale = null;
    Application.changeLocale = changeLocale;

    Application.changeThemeCallback = null;

    var locale = SettingsHelpers.instance.getLocale();
    myAppModel.changeLocale(locale);

    registerDependencies();
    start();
    super.initState();
  }

  void start() async {
    // Load secrets file, ignore if the secrets.json is not exists
    // This is meant to use in development only
    try {
      var json = await rootBundle.loadString('assets/data/secrets.json');
      var a = jsonDecode(json);
      AppSettings.secrets = a;

      if (AppSettings.secrets.containsKey('key')) {
        AppSettings.key = AppSettings.secrets['key'];
      }
      if (AppSettings.secrets.containsKey('iv')) {
        AppSettings.iv = AppSettings.secrets['iv'];
      }
    } catch (error) {
      print('No secrets.json file');
    }

    await SettingsHelpers.instance.init();

    // Make sure /database directory created
    var databasePath = await getDatabasesPath();
    var f = Directory(databasePath);
    if (!f.existsSync()) {
      f.createSync();
    }
  }

  void changeLocale(Locale locale) {
    myAppModel.changeLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MyAppModel>(
        model: myAppModel,
        child: ScopedModelDescendant<MyAppModel>(
          builder: (
            BuildContext context,
            Widget child,
            MyAppModel model,
          ) {
            return MaterialApp(
              localizationsDelegates: [
                myAppModel.appLocalizationsDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: model.supportedLocales,
              locale: model.locale,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,
              theme: new ThemeData(
                primaryColor: AppTheme.background,
                textTheme: Theme.of(context).textTheme.apply(
                      displayColor: AppTheme.nearlyBlack,
                    ),
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                }),
              ),
              color: AppTheme.background,
              routes: Routes.routes,
            );
          },
        ));
  }
}
