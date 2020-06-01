import 'dart:async';
import 'package:enquran/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:enquran/controls/my_draggable_scrollbar.dart';
import 'package:enquran/dialogs/quran_navigator_dialog.dart';
import 'package:enquran/events/font_size_event.dart';
import 'package:enquran/helpers/colors_settings.dart';
import 'package:enquran/helpers/my_event_bus.dart';
import 'package:enquran/helpers/settings_helpers.dart';
import 'package:enquran/helpers/shimmer_helpers.dart';
import 'package:enquran/screens/app.dart';
import 'package:enquran/models/bookmarks_model.dart';
import 'package:enquran/models/chapters_models.dart';
import 'package:enquran/models/quran_data_model.dart';
import 'package:enquran/models/translation_quran_model.dart';
import 'package:enquran/services/bookmarks_data_service.dart';
import 'package:enquran/services/quran_data_services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:after_layout/after_layout.dart';
import 'package:quiver/strings.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_tts/flutter_tts.dart';

class QuranAyaScreen extends StatefulWidget {
  final Chapter chapter;

  QuranAyaScreen({
    @required this.chapter,
  });

  @override
  State<StatefulWidget> createState() {
    return _QuranAyaScreenState();
  }
}

class _QuranAyaScreenState extends State<QuranAyaScreen>
    with AfterLayoutMixin<QuranAyaScreen> {
  QuranAyaScreenScopedModel quranAyaScreenScopedModel =
      QuranAyaScreenScopedModel();

  ScrollController scrollController;

  MyEventBus _myEventBus = MyEventBus.instance;
  bool showArabic = false;

  @override
  void initState() {
    AppTheme.initilizeTheme();
    quranAyaScreenScopedModel.currentChapter = widget.chapter;
    scrollController = ScrollController();
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await quranAyaScreenScopedModel.getAya(
      quranAyaScreenScopedModel.currentChapter,
    );
  }

  @override
  void dispose() {
    quranAyaScreenScopedModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<QuranAyaScreenScopedModel>(
      model: quranAyaScreenScopedModel,
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            child: Container(
              alignment: Alignment.centerLeft,
              child: ScopedModelDescendant<QuranAyaScreenScopedModel>(
                builder: (
                  BuildContext context,
                  Widget child,
                  QuranAyaScreenScopedModel model,
                ) {
                  return Row(
                    children: <Widget>[
                      Text(
                        '${model.currentChapter.chapterNumber}. ${model.currentChapter.nameSimple}',
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                      ),
                    ],
                  );
                },
              ),
            ),
            onTap: () async {
              await showQuranDialogNavigator();
            },
          ),
          actions: <Widget>[
            SizedBox(width: 15),
            IconButton(
              onPressed: () async {
                await showSettingsDialog();
              },
              icon: Icon(Icons.text_format),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            ScopedModelDescendant<QuranAyaScreenScopedModel>(
              builder: (BuildContext context, Widget child,
                  QuranAyaScreenScopedModel model) {
                return MyDraggableScrollBar.create(
                  context: context,
                  scrollController: scrollController,
                  heightScrollThumb: model.isGettingAya ? 0 : 45,
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount:
                        model.isGettingAya ? 5 : (model?.listAya?.length ?? 0),
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      if (model.isGettingAya) {
                        return createAyaItemCellShimmer();
                      }

                      Aya aya = quranAyaScreenScopedModel?.listAya?.elementAt(
                        index,
                      );
                      var listTranslationAya = quranAyaScreenScopedModel
                          ?.translations?.entries
                          ?.toList();
                      listTranslationAya
                          .sort((a, b) => a.key.name.compareTo(b.key.name));
                      return createAyaItemCell(aya, listTranslationAya.map(
                        (v) {
                          return Tuple2<TranslationDataKey, TranslationAya>(
                            v.key,
                            v.value.elementAt(index),
                          );
                        },
                      ), model);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget createAyaItemCell(
    Aya aya,
    Iterable<Tuple2<TranslationDataKey, TranslationAya>> listTranslationsAya,
    QuranAyaScreenScopedModel model,
  ) {
    return AyaItemCell(
        aya: aya,
        listTranslationsAya: listTranslationsAya.toList(),
        model: model);
  }

  Widget createAyaItemCellShimmer() {
    return ShimmerHelpers.createShimmer(
      child: Container(
        padding: EdgeInsets.only(
          left: 15,
          top: 15,
          right: 20,
          bottom: 25,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 16,
                    color: ColorsSettings.shimmerColor,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
            // 2
            Container(
              height: 18,
              color: ColorsSettings.shimmerColor,
            ),
          ],
        ),
      ),
    );
  }

  Future showQuranDialogNavigator() async {
    if (quranAyaScreenScopedModel.chapters.length <= 0) {
      return;
    }

    var dialog = QuranNavigatorDialog(
      chapters: quranAyaScreenScopedModel.chapters,
      currentChapter: quranAyaScreenScopedModel.currentChapter,
    );
    var chapter = await showDialog<Chapter>(
      context: context,
      builder: (context) {
        return dialog;
      },
    );
    if (chapter != null) {
      await quranAyaScreenScopedModel.getAya(chapter);
    }
  }

  Future showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return SettingsDialogWidget();
      },
    );
  }
}

class SettingsDialogWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SettingsDialogWidgetState();
  }
}

class SettingsDialogWidgetState extends State<SettingsDialogWidget> {
  static const double maxFontSizeArabic = 120;
  double fontSizeArabic = SettingsHelpers.minFontSizeArabic;

  static const double maxFontSizeTranslation = 90;
  double fontSizeTranslation = SettingsHelpers.minFontSizeTranslation;

  MyEventBus _myEventBus = MyEventBus.instance;

  @override
  void initState() {
    AppTheme.initilizeTheme();
    setState(() {
      fontSizeArabic = SettingsHelpers.instance.getFontSizeArabic;
      fontSizeTranslation = SettingsHelpers.instance.getFontSizeTranslation;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      height: 260,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          10,
        ),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Text(
              'Font Size',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Arabic font size
          SizedBox.fromSize(size: Size.fromHeight(5)),
          Container(
            child: Text(
              'Arabic Text',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Slider(
            min: SettingsHelpers.minFontSizeArabic,
            max: maxFontSizeArabic,
            value: fontSizeArabic,
            activeColor: AppTheme.background,
            inactiveColor: Theme.of(context).dividerColor,
            onChanged: (double value) async {
              await SettingsHelpers.instance.fontSizeArabic(value);
              setState(
                () {
                  fontSizeArabic = value;
                },
              );
              _myEventBus.eventBus.fire(
                FontSizeEvent()
                  ..arabicFontSize = value
                  ..translationFontSize = fontSizeTranslation,
              );
            },
          ),
          // Translation font size
          SizedBox.fromSize(size: Size.fromHeight(5)),
          Container(
            child: Text(
              'Translation',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          Slider(
            min: SettingsHelpers.minFontSizeTranslation,
            max: maxFontSizeTranslation,
            value: fontSizeTranslation,
            activeColor: AppTheme.background,
            inactiveColor: Theme.of(context).dividerColor,
            onChanged: (double value) async {
              await SettingsHelpers.instance.fontSizeTranslation(value);
              setState(
                () {
                  fontSizeTranslation = value;
                },
              );
              _myEventBus.eventBus.fire(
                FontSizeEvent()
                  ..arabicFontSize = fontSizeArabic
                  ..translationFontSize = value,
              );
            },
          ),

          SizedBox(height: 20),
          FlatButton(
            color: AppTheme.background,
            child: const Text('Okay', style: TextStyle(color: AppTheme.white)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ));
  }
}

class AyaItemCell extends StatefulWidget {
  final Aya aya;
  final List<Tuple2<TranslationDataKey, TranslationAya>> listTranslationsAya;
  final QuranAyaScreenScopedModel model;

  AyaItemCell(
      {@required this.aya,
      @required this.listTranslationsAya,
      @required this.model});

  @override
  State<StatefulWidget> createState() {
    return AyaItemCellState();
  }
}

class AyaItemCellState extends State<AyaItemCell> {
  Aya aya = Aya();
  List<Tuple2<TranslationDataKey, TranslationAya>> listTranslationsAya = [];
  QuranAyaScreenScopedModel model;
  FlutterTts flutterTts;
  Chapter chapter;

  MyEventBus _myEventBus = MyEventBus.instance;

  StreamSubscription streamEvent;

  static const double maxFontSizeArabic =
      SettingsDialogWidgetState.maxFontSizeArabic;
  double fontSizeArabic = SettingsHelpers.instance.getFontSizeArabic;

  static const double maxFontSizeTranslation =
      SettingsDialogWidgetState.maxFontSizeTranslation;
  double fontSizeTranslation = SettingsHelpers.instance.getFontSizeTranslation;

  @override
  void initState() {
    AppTheme.initilizeTheme();
    setState(() {
      aya = widget.aya;
      listTranslationsAya = widget.listTranslationsAya;
      model = widget.model;
      chapter = model.currentChapter;
    });
    streamEvent = _myEventBus.eventBus.on<FontSizeEvent>().listen((onData) {
      if (streamEvent != null) {
        setState(() {
          fontSizeArabic = onData.arabicFontSize;
          fontSizeTranslation = onData.translationFontSize;
        });
      }
    });

    inializeSpeaker();
    super.initState();
  }

  @override
  void dispose() {
    streamEvent?.cancel();
    streamEvent = null;
    super.dispose();
  }

  void inializeSpeaker() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("hi-IN");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.1);
    await flutterTts.setPitch(0.1);
  }

  void _shareWithFriend(String translation) {
    String body = translation == null
        ? "\"" +
            aya.text +
            "\"\n\nHoly Quran  [${chapter.nameSimple} ${chapter.chapterNumber}:${aya.aya}]"
        : "\"" +
            translation +
            "\"\n\nHoly Quran [${chapter.nameSimple} ${chapter.chapterNumber}:${aya.aya}]";
    Share.share(body +
        "\n\nQuoted from en Quran v1.0.0, download yours via https://play.google.com/store/apps/details?id=com.aliyura.enquran");
  }

  void _playVerse(String verse) async {
    Toast.show("${chapter.nameSimple} ${chapter.chapterNumber}:${aya.aya}", context,duration: Toast.LENGTH_LONG);

   await flutterTts.speak(verse);
  
  }

  @override
  Widget build(BuildContext context) {
    if (aya == null) {
      return Container();
    }

    List<Widget> listTranslationWidget = [];
    for (var translationAya in listTranslationsAya) {
      listTranslationWidget
          .add(AppTheme.language == "English" || AppTheme.language == "Both"
              ? GestureDetector(
                  onLongPress: () {
                    String translation =
                        translationAya.item2.text?.replaceAll('Allah', 'God');
                    _shareWithFriend(translation);
                  },
                  onDoubleTap: () {
                    String translation =
                        translationAya.item2.text?.replaceAll('Allah', 'God');
                    _playVerse(translation);
                  },
                  onTap: () async {
                    await showDialogActionButtons(
                        aya, chapter, translationAya.item2.text);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          translationAya.item2.text?.replaceAll('Allah', 'God'),
                          style: TextStyle(
                            fontSize: fontSizeTranslation,
                          ),
                        ),
                      ),
                    ],
                  ))
              : SizedBox());
    }

    return ScopedModelDescendant<QuranAyaScreenScopedModel>(
      builder: (
        BuildContext context,
        Widget child,
        QuranAyaScreenScopedModel model,
      ) {
        return GestureDetector(
          onTap: () async {
            await showDialogActionButtons(aya, model.currentChapter, null);
          },
          child: Container(
              padding: EdgeInsets.only(
                left: 15,
                top: 5,
                right: 20,
                bottom: 5,
              ),
              child: Column(children: <Widget>[
                Container(
                  child: !isBlank(aya.bismillah)
                      ? AppTheme.language == "Arabic" ||
                              AppTheme.language == "Both"
                          ? Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: 25,
                              ),
                              child: Text(
                                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: 25,
                              ),
                              child: Text(
                                'In the name of God, the Most Gracious, the Most Merciful',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )
                      : Container(),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      // Bismillah
                      AppTheme.language == "Arabic" ||
                              AppTheme.language == "Both"
                          ? Text(
                              aya.text,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: fontSizeArabic,
                                fontFamily: 'KFGQPC Uthman Taha Naskh',
                              ),
                            )
                          : SizedBox()
                    ]..addAll(listTranslationWidget),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: aya.isBookmarked ? 10 : 0,
                            ),
                            aya.isBookmarked
                                ? Icon(
                                    Icons.bookmark,
                                    color: AppTheme.background,
                                  )
                                : Container(),

                            SizedBox(width: 20),

                            FittedBox(
                              child: Container(
                                color: AppTheme.background,
                                padding: EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                child: Text(
                                  aya.aya,
                                  style: TextStyle(
                                      fontSize: 18, color: AppTheme.white),
                                ),
                              ),
                            ),
                            // Icons (e.g bookmarks)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ])),
        );
      },
    );
  }

  Future showDialogActionButtons(
      Aya aya, Chapter chapter, String translation) async {
    var quranAyaScreenScopedModel = ScopedModel.of<QuranAyaScreenScopedModel>(
      context,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          title: chapter != null
              ? Text(
                  '${chapter.nameSimple} ${chapter.chapterNumber}:${aya.aya}')
              : SizedBox(),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                  onPressed: () async {
                    if (!aya.isBookmarked) {
                      var bookmarkModel =
                          await quranAyaScreenScopedModel.addBookmark(
                        aya,
                        chapter,
                      );

                      setState(() {
                        aya.bookmarksModel = bookmarkModel;
                        aya.isBookmarked = true;
                      });
                    } else {
                      await quranAyaScreenScopedModel.removeBookmark(
                        aya.bookmarksModel.id,
                      );
                      setState(() {
                        aya.isBookmarked = false;
                      });
                    }
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        !aya.isBookmarked
                            ? Icons.bookmark_border
                            : MdiIcons.bookmarkOffOutline,
                        color: AppTheme.background,
                      ),
                      SizedBox(width: 10),
                      Text("Bookmark")
                    ],
                  )),
              Divider(height: 10),
              translation != null ? Divider() : SizedBox(),
              translation != null
                  ? FlatButton(
                      onPressed: () async {
                        translation = translation?.replaceAll('Allah', 'God');
                        _playVerse(translation);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.play_circle_outline,
                            color: AppTheme.background,
                          ),
                          SizedBox(width: 10),
                          Text("Listen the Verse")
                        ],
                      ))
                  : SizedBox(),
              Divider(),
              FlatButton(
                  onPressed: () async {
                    _shareWithFriend(translation);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.share,
                        color: AppTheme.background,
                      ),
                      SizedBox(width: 10),
                      Text("Share this Verse")
                    ],
                  )),
              Divider(height: 10),
              FlatButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.content_copy,
                        color: AppTheme.background,
                      ),
                      SizedBox(width: 10),
                      Text("Copy to Clipboard")
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}

class QuranAyaScreenScopedModel extends Model {
  QuranDataService _quranDataService = QuranDataService.instance;

  bool isGettingAya = true;

  List<Aya> listAya = [];

  Map<TranslationDataKey, List<TranslationAya>> translations = {};

  Map<Chapter, List<Aya>> chapters = {};

  Chapter currentChapter;

  IBookmarksDataService _bookmarksDataService;

  QuranAyaScreenScopedModel({
    IBookmarksDataService bookmarksDataService,
  }) {
    _bookmarksDataService = bookmarksDataService ??
        Application.container.resolve<IBookmarksDataService>();
  }

  Future getAya(Chapter chapter) async {
    try {
      isGettingAya = true;
      notifyListeners();

      currentChapter = chapter;
      await _bookmarksDataService.init();
      listAya = await _quranDataService.getQuranListAya(chapter.chapterNumber);
      translations = await _quranDataService.getTranslations(chapter);

      var locale = SettingsHelpers.instance.getLocale();
      _quranDataService.getChaptersNavigator(locale).then(
        (v) {
          chapters = v;
        },
      );

      notifyListeners();
    } finally {
      isGettingAya = false;
      notifyListeners();
    }
  }

  void dispose() {
    _quranDataService.dispose();
    _bookmarksDataService.dispose();
  }

  Future<BookmarksModel> addBookmark(
    Aya aya,
    Chapter chapter,
  ) async {
    var bookmarkModel = BookmarksModel()
      ..aya = int.tryParse(aya.aya)
      ..insertTime = DateTime.now()
      ..sura = chapter.chapterNumber
      ..suraName = chapter.nameSimple;
    int id = await _bookmarksDataService.add(bookmarkModel);
    notifyListeners();
    bookmarkModel.id = id;
    return bookmarkModel;
  }

  Future removeBookmark(
    int bookmarksModelId,
  ) async {
    await _bookmarksDataService.delete(bookmarksModelId);
    notifyListeners();
  }
}
