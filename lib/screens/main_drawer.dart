import 'package:flutter/material.dart';
import 'package:enquran/dialogs/quran_navigator_dialog.dart';
import 'package:enquran/helpers/settings_helpers.dart';
import 'package:enquran/localizations/app_localizations.dart';
import 'package:enquran/models/chapters_models.dart';
import 'package:enquran/models/quran_data_model.dart';
import 'package:enquran/screens/quran_aya_screen.dart';
import 'package:enquran/services/quran_data_services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:enquran/screens/about.dart';
import 'package:enquran/screens/feedback.dart';
import 'package:enquran/screens/invite_friend.dart';
import 'package:enquran/screens/rate_app.dart';

class MainDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  MainDrawerModel mainDrawerModel;

  @override
  void initState() {
    mainDrawerModel = MainDrawerModel();
    (() async {
      await mainDrawerModel.getChaptersForNavigator();
    })();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedbackScreen()));
                    },
                    child: ListTile(
                      leading: Icon(Icons.comment),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).feebackText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ScopedModel<MainDrawerModel>(
                    model: mainDrawerModel,
                    child: ScopedModelDescendant<MainDrawerModel>(
                      builder: (
                        BuildContext context,
                        Widget child,
                        MainDrawerModel model,
                      ) {
                        return ListTile(
                          onTap: () async {
                            var dialog = QuranNavigatorDialog(
                              chapters: model.chapters,
                              currentChapter: model.chapters.keys.first,
                            );
                            var chapter = await showDialog<Chapter>(
                              context: context,
                              builder: (context) {
                                return dialog;
                              },
                            );
                            if (chapter == null) {
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (
                                  BuildContext context,
                                ) {
                                  return QuranAyaScreen(
                                    chapter: chapter,
                                  );
                                },
                              ),
                            );
                          },
                          title: Text(
                            AppLocalizations.of(context).jumpToVerseText,
                          ),
                          leading: Icon(Icons.arrow_drop_down_circle),
                        );
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutScreen()));
                    },
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).aboutAppText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RateAppScreen()));
                    },
                    child: ListTile(
                      leading: Icon(Icons.thumb_up),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).reateAppText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InviteFriend()));
                    },
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).inviteFriendText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainDrawerModel extends Model {
  Map<Chapter, List<Aya>> chapters = {};

  Future getChaptersForNavigator() async {
    var locale = SettingsHelpers.instance.getLocale();
    var chapters = await QuranDataService.instance.getChaptersNavigator(
      locale,
    );
    this.chapters = chapters;
    notifyListeners();
  }
}
