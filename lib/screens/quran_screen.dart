import 'dart:async';

import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:enquran/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:function_types/function_types.dart';
import 'package:enquran/events/change_language_event.dart';
import 'package:enquran/helpers/my_event_bus.dart';
import 'package:enquran/localizations/app_localizations.dart';
import 'package:enquran/screens/quran_bookmarks_screen.dart';
import 'package:enquran/screens/quran_list_screen.dart';

class QuranScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _QuranQuranScreenState();
  }
}

class _QuranQuranScreenState extends State<QuranScreen>
    with TickerProviderStateMixin {
  TabController tabController;

  double sliverAppBarChildrenHeight = 100;
  int currentTabBarChildren = 0;
  CustomTabBar customTabBar;

  TabController quranListTabController;
  int quranListCurrentTabIndex = 0;
  bool loadedQuranListScreen = false;

  StreamSubscription changeLocaleSubsciption;

  @override
  void initState() {
    AppTheme.initilizeTheme();
    tabController = TabController(
      vsync: this,
      length: 2,
    );
    tabController.addListener(() {
      void c() {
        sliverAppBarChildrenHeight =
            customTabBar.tabBarHeight[tabController.index];
        currentTabBarChildren = tabController.index;
      }

      if (tabController.indexIsChanging) {
        c();
      } else {
        c();
      }
      setState(() {});
    });

    quranListTabController = TabController(
      vsync: this,
      length: 2,
    );
    quranListTabController.addListener(() {
      if (quranListTabController.indexIsChanging) {
        setState(() {
          quranListCurrentTabIndex = quranListTabController.index;
        });
      }
    });

    changeLocaleSubsciption =
        MyEventBus.instance.eventBus.on<ChangeLanguageEvent>().listen(
      (v) async {
        // Refresh current
        setState(() {
          loadedQuranListScreen = true;
        });
        await Future.delayed(Duration(milliseconds: 400));
        setState(() {
          loadedQuranListScreen = false;
        });
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    quranListTabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This should be moves to initState
    customTabBar = CustomTabBar(
      tabBar: <Widget>[
        Tab(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesomeIcons.book, size: 20),
              SizedBox(width: 10),
              Text('Quran')
            ],
          ),
        ),
        Tab(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Icon(FontAwesomeIcons.solidBookmark, size: 20),
              SizedBox(width: 10),
              Text('Bookmark')
            ])),
      ],
      tabBarChildrens: () {
        return <Widget>[
          Container(
            color: AppTheme.white,
            height: 45,
            child: Container(
              child: Scaffold(
                backgroundColor: AppTheme.white,
                body: TabBar(
                  controller: quranListTabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BubbleTabIndicator(
                    indicatorHeight: 25.0,
                    indicatorColor: AppTheme.background,
                    tabBarIndicatorSize: TabBarIndicatorSize.tab,
                  ),
                  labelColor: AppTheme.white,
                  unselectedLabelColor:
                      Theme.of(context).textTheme.display1.color,
                  tabs: <Widget>[
                    Tab(
                      text: AppLocalizations.of(context).suraText,
                    ),
                    Tab(
                      text: AppLocalizations.of(context).juzText,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(),
        ];
      },
      tabBarHeight: <double>[
        100,
        50,
      ],
    );

    return Container(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text(AppLocalizations.of(context).appName),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              backgroundColor: AppTheme.background,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(sliverAppBarChildrenHeight),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      TabBar(
                        controller: tabController,
                        tabs: customTabBar.tabBar,
                      ),
                      customTabBar.tabBarChildrens()[currentTabBarChildren],
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: <Widget>[
            loadedQuranListScreen == false
                ? Container(
                    child: QuranListScreen(
                    currentTabIndex: quranListCurrentTabIndex,
                  ))
                : Container(),
            QuranBookmarksScreen(),
          ],
        ),
      ),
    );
  }
}

class CustomTabBar {
  List<Widget> tabBar;
  Func0<List<Widget>> tabBarChildrens;
  List<double> tabBarHeight;
  CustomTabBar({
    @required this.tabBarChildrens,
    @required this.tabBar,
    @required this.tabBarHeight,
  });
}
