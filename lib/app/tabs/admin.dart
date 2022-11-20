// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trading/app/colors.dart';
import 'package:trading/app/models.dart';
import 'package:trading/layout/adaptive.dart';
import 'package:trading/log.dart';
import 'package:trading/pages/about.dart' as about;

import '../../web.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  @override
  Widget build(BuildContext context) {
    final localizations = TradingLocalizations.of(context)!;
    Future<String> notConfirmed = apiGet('notConfirmed').then((result) {
      print(result.body.toString());
      return result.body;
    });
    return FutureBuilder(
      future: notConfirmed,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // List userList =  as List;
          log(snapshot.data.toString());
          List<UserRecord> users = json.decode(snapshot.data.toString()).map((dynamic item) =>
              UserRecord(id: int.parse(item['id'].toString()), login: item['login'].toString())
          ) as List<UserRecord>;
          return FocusTraversalGroup(
            child: Container(
              padding: EdgeInsets.only(top: isDisplayDesktop(context) ? 24 : 0),
              child: ListView(
                restorationId: 'admin_list_view',
                shrinkWrap: true,
                children: users.map((user) {
                  return _AdminItem(
                    user.login, () {}
                  );
                }).toList(),
              ),
            ),
          );
        }
        else {
          return FocusTraversalGroup(
            child: Container(
              padding: EdgeInsets.only(top: isDisplayDesktop(context) ? 24 : 0),
              child: ListView(
                restorationId: 'admin_list_view',
                shrinkWrap: true,
                children: const [],
              ),
            ),
          );
        }
        //List<UserRecord>
      }
    );
  }
}

class UserRecord {
  const UserRecord({
    required this.id,
    required this.login
  });

  final int id;
  final String login;
}

class _AdminItem extends StatelessWidget {
  const _AdminItem(this.title, this.function);

  final String title;
  final VoidCallback function;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.zero,
      ),
      onPressed: function,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
        child: Text(title),
      ),
    );
  }
}
