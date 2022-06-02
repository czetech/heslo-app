import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';

class _Answer extends StatefulWidget {
  @override
  _AnswerState createState() => _AnswerState();
}

class _AnswerState extends State<_Answer> {
  String? phrase = null;
  DateTime lastDateTime = DateTime.fromMicrosecondsSinceEpoch(0);
  DateTime? lastUpdate = null;
  Duration? fromUpdate = null;

  void refresh() async {
    final coreApi = GlobalConfiguration().getString('coreApi');
    final refreshDateTime = DateTime.now();
    Response response;
    response = await Client().get(
      Uri.parse(coreApi + 'answer'),
      headers: {
        'App-Version': (await PackageInfo.fromPlatform()).version,
        'App-Platform': UniversalPlatform.value.toString().split('.').last,
      },
    );
    if (response.statusCode == 200) {
      final answer = jsonDecode(response.body);
      var dateTime = DateTime.parse(answer['datetime']);
      if (dateTime.isAfter(lastDateTime)) {
        lastDateTime = dateTime;
        lastUpdate = DateTime.now();
        setState(() {
          phrase = answer['phrase'];
        });
      }
    } else if (response.statusCode >= 500 && response.statusCode <= 599) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Chyba servera, prosím čakajte…"),
      ));
    } else {
      var action = UniversalPlatform.isWeb
          ? "obnoviť stránku"
          : "aktualizovať aplikáciu";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Neznáma odpoveď, prosím skúste ${action}"),
      ));
    }
  }

  void count() {
    setState(() {
      if (lastUpdate != null) {
        fromUpdate = DateTime.now().difference(lastUpdate!);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
    Timer timerRefresh =
        Timer.periodic(Duration(seconds: 5), (Timer t) => refresh());
    Timer timerCounter =
        Timer.periodic(Duration(seconds: 1), (Timer t) => count());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (phrase == null)
          Text(
            "Aktuálne súťažné heslo nie je vyhlásené",
            style: TextStyle(fontSize: 18),
          ),
        if (phrase != null) ...[
          Text("Aktuálne heslo je:", style: TextStyle(fontSize: 18)),
          Text(
            phrase!.toUpperCase(),
            style: TextStyle(
              color: Colors.red,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ),
        ],
        if (fromUpdate != null)
          Text("(posledné obnovenie pred " +
              (fromUpdate!.inSeconds < 2
                  ? "okamihom"
                  : "${fromUpdate!.inSeconds} sekundami") +
              ")"),
      ],
    );
  }
}

class _Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<_Messages> {
  List<dynamic> messages = [];

  void refresh() async {
    final coreApi = GlobalConfiguration().getString('coreApi');
    final refreshDateTime = DateTime.now();
    Response response;
    response = await Client().get(
      Uri.parse(coreApi + 'messages'),
      headers: {
        'App-Version': (await PackageInfo.fromPlatform()).version,
        'App-Platform': UniversalPlatform.value.toString().split('.').last,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        messages = jsonDecode(response.body);
      });
    } else {
      throw 'Bad response';
    }
  }

  @override
  void initState() {
    super.initState();
    refresh();
    Timer timerRefresh =
        Timer.periodic(Duration(seconds: 60), (Timer t) => refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var message in messages)
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Color(0xfffff3cd),
              border: Border.all(color: Color(0xffffeeba)),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.info_outlined, color: Color(0xff856404)),
                ),
                Expanded(
                  child: Text(
                    message['body'],
                    style: TextStyle(color: Color(0xff856404)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Store extends StatefulWidget {
  final String imageAssetName;
  final String endpoint;

  _Store(this.imageAssetName, this.endpoint);

  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<_Store> {
  String? url;

  void refresh() async {
    final coreApi = GlobalConfiguration().getString('coreApi');
    final refreshDateTime = DateTime.now();
    Response response;
    response = await Client().get(
      Uri.parse(coreApi + widget.endpoint),
      headers: {
        'App-Version': (await PackageInfo.fromPlatform()).version,
        'App-Platform': UniversalPlatform.value.toString().split('.').last,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        url = jsonDecode(response.body)['url'];
      });
    } else {
      throw 'Bad response';
    }
  }

  @override
  void initState() {
    super.initState();
    refresh();
    Timer timerRefresh =
        Timer.periodic(Duration(seconds: 60), (Timer t) => refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (url != null)
          ? InkWell(
              child: Image(
                image: AssetImage(widget.imageAssetName),
                height: 50,
              ),
              onTap: () {
                launch(url!);
              },
            )
          : null,
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: 10,
          top: UniversalPlatform.isWeb ? 10 : 20,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/faq');
                  },
                  child: Text("FAQ"),
                ),
              ],
            ),
            Column(
              children: [
                Text("Heslo do súťaže",
                    style: Theme.of(context).textTheme.headline1),
                Text("„Byť zdravý je výhra“",
                    style: Theme.of(context).textTheme.headline1),
              ],
            ),
            _Answer(),
            Column(
              children: [
                if (UniversalPlatform.isWeb)
                  Row(
                    children: [
                      _Store('icons/google-play-badge.png', 'play-store'),
                      _Store('icons/apple-store-badge.png', 'app-store'),
                    ],
                  ),
                _Messages(),
                TextButton(
                  onPressed: () {
                    launch('https://cze.tech');
                  },
                  child: Text("Sponzoruje Czetech"),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<PackageInfo> snapshot,
                  ) {
                    var text = '';
                    if (snapshot.hasData) {
                      final packageInfo = snapshot.data!;
                      text = ('Heslo v${packageInfo.version}');
                    }
                    return Text(text);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
