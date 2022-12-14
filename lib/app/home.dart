// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trading/app/tabs/admin.dart';
import 'package:trading/app/tabs/balance.dart';
import 'package:trading/app/tabs/profile.dart';
import 'package:trading/app/tabs/settings.dart';
import 'package:trading/app/tabs/trading.dart';
import 'package:trading/data/gallery_options.dart';
import 'package:trading/layout/adaptive.dart';
import 'package:trading/layout/text_scale.dart';

import 'models.dart';

const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.user});

  final UserModel user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RestorationMixin {
  late TabController _tabController;
  RestorableInt tabIndex = RestorableInt(0);
  late int tabCount = widget.user.isAdmin ? 5 : 4;

  @override
  String get restorationId => 'home_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController.index = tabIndex.value;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabCount, vsync: this)
      ..addListener(() {
        // Set state to make sure that the [_RallyTab] widgets get updated when changing tabs.
        setState(() {
          tabIndex.value = _tabController.index;
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = isDisplayDesktop(context);
    Widget tabBarView;
    if (isDesktop) {
      final isTextDirectionRtl =
          GalleryOptions.of(context).resolvedTextDirection() ==
              TextDirection.rtl;
      final verticalRotation =
          isTextDirectionRtl ? turnsToRotateLeft : turnsToRotateRight;
      final revertVerticalRotation =
          isTextDirectionRtl ? turnsToRotateRight : turnsToRotateLeft;
      tabBarView = Row(
        children: [
          Container(
            width: 150 + 50 * (cappedTextScale(context) - 1),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 24),
                ExcludeSemantics(
                  child: SizedBox(
                    height: 80,
                    child: Image.asset(
                      'icon.png',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Rotate the tab bar, so the animation is vertical for desktops.
                RotatedBox(
                  quarterTurns: verticalRotation,
                  child: _TradingTabBar(
                    tabs: _buildTabs(context: context, theme: theme, isVertical: true, isAdmin: widget.user.isAdmin)
                        .map(
                      (widget) {
                        // Revert the rotation on the tabs.
                        return RotatedBox(
                          quarterTurns: revertVerticalRotation,
                          child: widget,
                        );
                      },
                    ).toList(),
                    tabController: _tabController,
                    tabCount: tabCount,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            // Rotate the tab views so we can swipe up and down.
            child: RotatedBox(
              quarterTurns: verticalRotation,
              child: TabBarView(
                controller: _tabController,
                children: _buildTabViews().map(
                  (widget) {
                    // Revert the rotation on the tab views.
                    return RotatedBox(
                      quarterTurns: revertVerticalRotation,
                      child: widget,
                    );
                  },
                ).toList(),
              ),
            ),
          ),
        ],
      );
    } else {
      tabBarView = Column(
        children: [
          _TradingTabBar(
            tabs: _buildTabs(context: context, theme: theme, isAdmin: false),
            tabController: _tabController,
            tabCount: tabCount,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _buildTabViews(),
            ),
          ),
        ],
      );
    }
    return ApplyTextOptions(
      child: Scaffold(
        body: SafeArea(
          // For desktop layout we do not want to have SafeArea at the top and
          // bottom to display 100% height content on the accounts view.
          top: !isDesktop,
          bottom: !isDesktop,
          child: Theme(
            // This theme effectively removes the default visual touch
            // feedback for tapping a tab, which is replaced with a custom
            // animation.
            data: theme.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: tabBarView,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs(
      {required BuildContext context,
      required ThemeData theme,
      bool isVertical = false,
      bool isAdmin = false}) {
    final localizations = TradingLocalizations.of(context)!;
    final tabs = [
      _TradingTab(
        theme: theme,
        iconData: Icons.attach_money,
        title: localizations.rallyBalance,
        tabIndex: 0,
        tabController: _tabController,
        isVertical: isVertical,
        tabCount: tabCount,
      ),
      _TradingTab(
        theme: theme,
        iconData: Icons.trending_up,
        title: localizations.rallyTrading,
        tabIndex: 1,
        tabController: _tabController,
        isVertical: isVertical,
        tabCount: tabCount,
      ),
      _TradingTab(
        theme: theme,
        iconData: Icons.person,
        title: localizations.rallyProfile,
        tabIndex: 2,
        tabController: _tabController,
        isVertical: isVertical,
        tabCount: tabCount,
      ),
      _TradingTab(
        theme: theme,
        iconData: Icons.settings,
        title: localizations.rallyTitleSettings,
        tabIndex: 3,
        tabController: _tabController,
        isVertical: isVertical,
        tabCount: tabCount,
      ),
    ];
    if (isAdmin) {
      tabs.add(
        _TradingTab(
          theme: theme,
          iconData: Icons.admin_panel_settings_outlined,
          title: localizations.rallyTitleSettings,
          tabIndex: 4,
          tabController: _tabController,
          isVertical: isVertical,
          tabCount: tabCount,
        ),
      );
    }
    return tabs;
  }

  List<Widget> _buildTabViews() {
    return const [
      BalanceView(),
      TradingView(),
      ProfileView(),
      SettingsView(),
      AdminView(),
    ];
  }
}

class _TradingTabBar extends StatelessWidget {
  const _TradingTabBar({
    required this.tabs,
    this.tabController,
    required this.tabCount,
  });

  final List<Widget> tabs;
  final TabController? tabController;
  final int tabCount;

  @override
  Widget build(BuildContext context) {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(0),
      child: TabBar(
        // Setting isScrollable to true prevents the tabs from being
        // wrapped in [Expanded] widgets, which allows for more
        // flexible sizes and size animations among tabs.
        isScrollable: true,
        labelPadding: EdgeInsets.zero,
        tabs: tabs,
        controller: tabController,
        // This hides the tab indicator.
        indicatorColor: Colors.transparent,
      ),
    );
  }
}

class _TradingTab extends StatefulWidget {
  _TradingTab({
    required ThemeData theme,
    IconData? iconData,
    required String title,
    int? tabIndex,
    required TabController tabController,
    required this.isVertical,
    required this.tabCount,
  })  : titleText = Text(title, style: theme.textTheme.labelLarge),
        isExpanded = tabController.index == tabIndex,
        icon = Icon(iconData, semanticLabel: title, color: Colors.black);

  final Text titleText;
  final Icon icon;
  final bool isExpanded;
  final bool isVertical;
  final int tabCount;

  @override
  _TradingTabState createState() => _TradingTabState();
}

class _TradingTabState extends State<_TradingTab>
    with SingleTickerProviderStateMixin {
  late Animation<double> _titleSizeAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _iconFadeAnimation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _titleSizeAnimation = _controller.view;
    _titleFadeAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
    _iconFadeAnimation = _controller.drive(Tween<double>(begin: 0.6, end: 1));
    if (widget.isExpanded) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(_TradingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Column(
        children: [
          const SizedBox(height: 18),
          FadeTransition(
            opacity: _iconFadeAnimation,
            child: widget.icon,
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _titleFadeAnimation,
            child: SizeTransition(
              axis: Axis.vertical,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
              child: Center(child: ExcludeSemantics(child: widget.titleText)),
            ),
          ),
          const SizedBox(height: 18),
        ],
      );
    }

    // Calculate the width of each unexpanded tab by counting the number of
    // units and dividing it into the screen width. Each unexpanded tab is 1
    // unit, and there is always 1 expanded tab which is 1 unit + any extra
    // space determined by the multiplier.
    final width = MediaQuery.of(context).size.width;
    const expandedTitleWidthMultiplier = 2;
    final unitWidth = width / (widget.tabCount + expandedTitleWidthMultiplier);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          FadeTransition(
            opacity: _iconFadeAnimation,
            child: SizedBox(
              width: unitWidth,
              child: widget.icon,
            ),
          ),
          FadeTransition(
            opacity: _titleFadeAnimation,
            child: SizeTransition(
              axis: Axis.horizontal,
              axisAlignment: -1,
              sizeFactor: _titleSizeAnimation,
              child: SizedBox(
                width: unitWidth * expandedTitleWidthMultiplier,
                child: Center(
                  child: ExcludeSemantics(child: widget.titleText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
