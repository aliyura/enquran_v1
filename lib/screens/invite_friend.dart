import 'package:enquran/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class InviteFriend extends StatefulWidget {
  @override
  _InviteFriendState createState() => _InviteFriendState();
}

class _InviteFriendState extends State<InviteFriend> {
  @override
  void initState() {
     AppTheme.initilizeTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text('Invite Friend', style: TextStyle(color: AppTheme.white)),
      ),
      body: Container(
        color: AppTheme.nearlyWhite,
        child: SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppTheme.nearlyWhite,
            body: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                      left: 16,
                      right: 16),
                  child: Image.asset('assets/images/inviteImage.png'),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Invite Your Friends',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  child: const Text(
                    'Are you one of those who makes everything\n at the last moment?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.6),
                                offset: const Offset(4, 4),
                                blurRadius: 8.0),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Share.share(
                                  "Hi There!\n\nDownload enQuran app  v1.0.0\n\nStart your Quran study in English language.\n\nThe Quran is believed to be a continuation of the Old Testament and the New Testament of the Holy Bible. The Quran is the Islamic sacred book, believed to be the word of God as dictated to Prophet Muhammad by the angel Gabriel and written down in Arabic. The Quran consists of 114 units of varying lengths, known as suras; the first sura is said as part of the ritual prayer. These touch upon all aspects of human existence, including matters of doctrine, social organization, and legislation.\n\nhttps://play.google.com/store/apps/details?id=com.aliyura.enquran");
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.share,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      'Share',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
