import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class FaqScreen extends StatelessWidget {
  Future<List> listFaq(BuildContext context) async {
    final coreApi = GlobalConfiguration().getString('coreApi');
    final refreshDateTime = DateTime.now();
    Response response;
    response = await Client().get(
      Uri.parse(coreApi + 'faq'),
      headers: {
        'App-Version': (await PackageInfo.fromPlatform()).version,
        'App-Platform': UniversalPlatform.value.toString().split('.').last,
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw 'Bad response';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                BackButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List>(
                future: listFaq(context),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasData) {
                    var faq;
                    return ListView(
                      children: [
                        for (faq in snapshot.data!)
                          ListTile(
                            title: Text(faq['head']),
                            subtitle: Text(faq['body']),
                          ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
