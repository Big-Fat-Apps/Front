// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:trading/app/charts/line_chart.dart';
import 'package:trading/app/colors.dart';
import 'package:trading/app/data.dart';
import 'package:trading/app/formatters.dart';
import 'package:trading/app/tabs/sidebar.dart';
import 'package:trading/data/gallery_options.dart';
import 'package:trading/layout/adaptive.dart';

import '../app.dart';

/// A page that shows a summary of accounts.
class TradingView extends StatelessWidget {
  const TradingView({super.key});

  @override
  Widget build(BuildContext context) {
    final detailItems = DummyDataService.getAccountDetailList(context);

    return TabWithSidebar(
      restorationId: 'trading_view',
      mainView: TradingEntityCategoryDetailsPage(),
      sidebarItems: [
        for (UserDetailData item in detailItems)
          SidebarItem(title: item.title, value: item.value)
      ],
    );
  }
}

class TradingEntityCategoryDetailsPage extends StatelessWidget {
  TradingEntityCategoryDetailsPage({super.key});

  final List<DetailedEventData> items =
      DummyDataService.getDetailedEventItems();

  void _doSomethingPressBuyButton(BuildContext context) {
    Navigator.of(context).restorablePushNamed(TradingApp.homeRoute);
  }

  void _doSomethingPressSellButton(BuildContext context) {
    Navigator.of(context).restorablePushNamed(TradingApp.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);

    if (isDisplayDesktop(context)) {
      return ApplyTextOptions(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text(
              TradingLocalizations.of(context)!.rallyGraphName,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 18),
            ),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: TradingLineChart(events: items),
              ),
              const SizedBox(
                height: 20,
              ),
              _TradingBuySellButtons(
                spacing: 24,
                onTapBuyButton: () {
                  _doSomethingPressBuyButton(context);
                },
                onTapSellButton: () {
                  _doSomethingPressSellButton(context);
                },
              ),
              Expanded(
                child: Padding(
                  padding:
                      isDesktop ? const EdgeInsets.all(40) : EdgeInsets.zero,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (DetailedEventData detailedEventData in items)
                        _DetailedEventCard(
                          title: detailedEventData.title,
                          date: detailedEventData.date,
                          amount: detailedEventData.amount,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text(TradingLocalizations.of(context)!.rallyGraphName),
              ),
              SizedBox(
                height: 300,
                width: double.infinity,
                child: TradingLineChart(events: items),
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  const SizedBox(width: 10,),
                  Flexible(
                      flex: 1,
                      child: _OperationButton(
                        text: TradingLocalizations.of(context)!.rallySellButton,
                        onTap: () {
                          _doSomethingPressBuyButton(context);
                        },
                      )),
                  const SizedBox(width: 12),
                  Flexible(
                      flex: 1,
                      child: _OperationButton(
                        text: TradingLocalizations.of(context)!.rallyBuyButton,
                        onTap: () {
                          _doSomethingPressBuyButton(context);
                        },
                      )),
                  const SizedBox(width: 10,)
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  for (DetailedEventData detailedEventData in items)
                    _DetailedEventCard(
                      title: detailedEventData.title,
                      date: detailedEventData.date,
                      amount: detailedEventData.amount,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _TradingBuySellButtons extends StatelessWidget {
  const _TradingBuySellButtons(
      {required this.spacing,
      required this.onTapBuyButton,
      required this.onTapSellButton});

  final double spacing;
  final VoidCallback onTapBuyButton;
  final VoidCallback onTapSellButton;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final textScaleFactor =
          GalleryOptions.of(context).textScaleFactor(context);

      // Only display multiple columns when the constraints allow it and we
      // have a regular text scale factor.
      const minWidthForTwoColumns = 600;
      final hasMultipleColumns = isDisplayDesktop(context) &&
          constraints.maxWidth > minWidthForTwoColumns &&
          textScaleFactor <= 2;
      final boxWidth = hasMultipleColumns
          ? constraints.maxWidth / 2 - spacing / 2
          : double.infinity;

      return Column(
        children: [
          Wrap(
            runSpacing: spacing,
            children: [
              SizedBox(
                width: boxWidth,
                child: _OperationButton(
                    text: TradingLocalizations.of(context)!.rallyBuyButton,
                    onTap: onTapBuyButton),
              ),
              if (hasMultipleColumns) SizedBox(width: spacing),
              SizedBox(
                width: boxWidth,
                child: _OperationButton(
                    text: TradingLocalizations.of(context)!.rallySellButton,
                    onTap: onTapSellButton),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _OperationButton extends StatelessWidget {
  const _OperationButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: TradingColors.buttonColor,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(text),
          )
        ],
      ),
    );
  }
}

class _DetailedEventCard extends StatelessWidget {
  const _DetailedEventCard({
    required this.title,
    required this.date,
    required this.amount,
  });

  final String title;
  final DateTime date;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () {},
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: double.infinity,
            child: isDesktop
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _EventTitle(title: title),
                      ),
                      _EventDate(date: date),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: _EventAmount(amount: amount),
                        ),
                      ),
                    ],
                  )
                : Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EventTitle(title: title),
                          _EventDate(date: date),
                        ],
                      ),
                      _EventAmount(amount: amount),
                    ],
                  ),
          ),
          SizedBox(
            height: 1,
            child: Container(
              color: TradingColors.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventAmount extends StatelessWidget {
  const _EventAmount({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      usdWithSignFormat(context).format(amount),
      style: textTheme.bodyLarge!.copyWith(
        fontSize: 20,
        color: TradingColors.gray,
      ),
    );
  }
}

class _EventDate extends StatelessWidget {
  const _EventDate({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      shortDateFormat(context).format(date),
      semanticsLabel: longDateFormat(context).format(date),
      style: textTheme.bodyMedium!.copyWith(color: TradingColors.gray60),
    );
  }
}

class _EventTitle extends StatelessWidget {
  const _EventTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.bodyMedium!.copyWith(fontSize: 16),
    );
  }
}
