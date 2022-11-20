// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:trading/constants.dart';
import 'package:trading/data/gallery_options.dart';
import 'package:trading/layout/adaptive.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: EdgeInsets.only(
          top: isDisplayDesktop(context) ? 63 : 15,
          bottom: isDisplayDesktop(context) ? 21 : 11,
        ),
        child: SelectableText(
          text,
          style: Theme.of(context).textTheme.headlineMedium!.apply(
                color: color,
                fontSizeDelta:
                    isDisplayDesktop(context) ? desktopDisplay1FontDelta : 0,
              ),
        ),
      ),
    );
  }
}

/// Wrap the studies with this to display a back button and allow the user to
/// exit them at any time.
class StudyWrapper extends StatefulWidget {
  const StudyWrapper({
    super.key,
    required this.study,
    this.alignment = AlignmentDirectional.bottomStart,
    this.hasBottomNavBar = false,
  });

  final Widget study;
  final bool hasBottomNavBar;
  final AlignmentDirectional alignment;

  @override
  State<StudyWrapper> createState() => _StudyWrapperState();
}

class _StudyWrapperState extends State<StudyWrapper> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ApplyTextOptions(
      child: Stack(
        children: [
          Semantics(
            sortKey: const OrdinalSortKey(1),
            child: RestorationScope(
              restorationId: 'study_wrapper',
              child: widget.study,
            ),
          ),
          if (!isDisplayFoldable(context))
            SafeArea(
              child: Align(
                alignment: widget.alignment,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: widget.hasBottomNavBar
                          ? kBottomNavigationBarHeight + 16.0
                          : 16.0),
                  child: Semantics(
                    sortKey: const OrdinalSortKey(0),
                    label: TradingLocalizations.of(context)!.backToGallery,
                    button: true,
                    enabled: true,
                    excludeSemantics: true,
                    child: FloatingActionButton.extended(
                      heroTag: _BackButtonHeroTag(),
                      key: const ValueKey('Back'),
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.settings.name == '/');
                      },
                      icon: IconTheme(
                        data: IconThemeData(color: colorScheme.onPrimary),
                        child: const BackButtonIcon(),
                      ),
                      label: Text(
                        MaterialLocalizations.of(context).backButtonTooltip,
                        style: textTheme.labelLarge!
                            .apply(color: colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BackButtonHeroTag {}
