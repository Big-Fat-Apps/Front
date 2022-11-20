// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trading/app/colors.dart';
import 'package:trading/app/models.dart';
import 'package:trading/layout/adaptive.dart';
import 'package:trading/pages/about.dart' as about;

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final localizations = TradingLocalizations.of(context)!;
    return FocusTraversalGroup(
      child: Container(
        padding: EdgeInsets.only(top: isDisplayDesktop(context) ? 24 : 0),
        child: ListView(
          restorationId: 'settings_list_view',
          shrinkWrap: true,
          children: [
            _SettingsItem(
                localizations.rallySettingsTheme.toString(),
                    () {

                }
            ),
            const Divider(color: TradingColors.dividerColor, height: 1),
            _SettingsItem(
                localizations.rallySettingsTextScale.toString(),
                    () {

                }
            ),
            const Divider(color: TradingColors.dividerColor, height: 1),
            _SettingsItem(
                localizations.rallySettingsTextDirection.toString(),
                    () {

                }
            ),
            const Divider(color: TradingColors.dividerColor, height: 1),
            _SettingsItem(
                localizations.rallySettingsLocale.toString(),
                    () {

                }
            ),
            const Divider(color: TradingColors.dividerColor, height: 1),
            _SettingsItem(
                localizations.rallySettingsAbout.toString(),
                    () {
                      about.showAboutDialog(context: context);
                }
            ),
            const Divider(color: TradingColors.dividerColor, height: 1),
            _SettingsItem(
                localizations.rallySettingsFeedback.toString(),
                    () {

                }
            ),
            const Divider(color: TradingColors.dividerColor, height: 1),
            _SettingsItem(
                localizations.rallySettingsSignOut.toString(),
                    () {
                      context.read<UserModel>().logOut(context);
                }
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem(this.title, this.function);

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
