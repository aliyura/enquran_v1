import 'package:flutter/material.dart';
import 'package:enquran/helpers/colors_settings.dart';
import 'package:enquran/helpers/settings_helpers.dart';
import 'package:enquran/helpers/shimmer_helpers.dart';
import 'package:enquran/models/chapters_models.dart';
import 'package:enquran/models/quran_data_model.dart';
import 'package:enquran/screens/quran_aya_screen.dart';
import 'package:enquran/services/quran_data_services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:enquran/app_themes.dart';

class QuranSuraScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuranSuraScreenState();
  }
}

class _QuranSuraScreenState extends State<QuranSuraScreen>
    with SingleTickerProviderStateMixin {
  QuranScreenScopedModel quranScreenScopedModel = QuranScreenScopedModel();

  @override
  void initState() {
    AppTheme.initilizeTheme();
    super.initState();

    (() async {
      await quranScreenScopedModel.getChapters();
    })();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ScopedModel<QuranScreenScopedModel>(
            model: quranScreenScopedModel,
            child: ScopedModelDescendant<QuranScreenScopedModel>(
              builder: (
                BuildContext context,
                Widget child,
                QuranScreenScopedModel model,
              ) {
                return Container(
                    color: AppTheme.nearlyWhite,
                    padding: EdgeInsets.only(top: 0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: model.isGettingChapters
                          ? 5
                          : (model.chaptersModel?.chapters?.length ?? 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (model.isGettingChapters) {
                          return chapterDataCellShimmer();
                        }

                        var chapter =
                            model.chaptersModel?.chapters?.elementAt(index);
                        return chapterDataCell(chapter);
                      },
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget chapterDataCell(Chapter chapter) {
    if (chapter == null) {
      return Container();
    }
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) {
            return QuranAyaScreen(
              chapter: chapter,
            );
          },
        ));
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 10, top: 10),
        width: double.infinity,
        margin: EdgeInsets.only(left: 10.0, bottom: 15, right: 10, top: 0),
        decoration: BoxDecoration(
          color: AppTheme.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15.0,
              offset: Offset(0.0, 5.0),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${chapter.chapterNumber}',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppTheme.language == "English" || AppTheme.language == "Both"
                      ? Text(
                          chapter.translatedName.name,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        )
                      : SizedBox(),
                  AppTheme.language == "Arabic" || AppTheme.language == "Both"
                      ? Text(chapter.nameSimple)
                      : SizedBox(),
                ],
              ),
            ),
            AppTheme.language == "Arabic" || AppTheme.language == "Both"
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Text(
                      chapter.nameArabic,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget chapterDataCellShimmer() {
    return ShimmerHelpers.createShimmer(
      child: InkWell(
        onTap: () {},
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 10.0, bottom: 15, right: 10),
          decoration: BoxDecoration(
            color: AppTheme.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15.0,
                offset: Offset(0.0, 5.0),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: 18,
                  height: 5,
                  color: ColorsSettings.shimmerColor,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 20,
                      color: ColorsSettings.shimmerColor,
                    ),
                    SizedBox.fromSize(
                      size: Size.fromHeight(5),
                    ),
                    Container(
                      height: 16,
                      color: ColorsSettings.shimmerColor,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Container(
                  height: 24,
                  width: 75,
                  color: ColorsSettings.shimmerColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranScreenScopedModel extends Model {
  QuranDataService _quranDataService = QuranDataService.instance;

  QuranDataModel quranDataModel = QuranDataModel();
  ChaptersModel chaptersModel = ChaptersModel();

  bool isGettingChapters = true;

  Future getChapters() async {
    try {
      isGettingChapters = true;

      var locale = SettingsHelpers.instance.getLocale();
      chaptersModel = await _quranDataService.getChapters(locale);
      notifyListeners();
    } finally {
      isGettingChapters = false;
      notifyListeners();
    }
  }
}
