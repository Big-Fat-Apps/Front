// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:trading/layout/adaptive.dart';

import '../../layout/text_scale.dart';
import '../colors.dart';
import '../data.dart';
import '../formatters.dart';

/// A page that shows a status overview.
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final localizations = TradingLocalizations.of(context)!;
    if (isDisplayDesktop(context)) {
      const sortKeyName = 'Balance';
      return SingleChildScrollView(
        restorationId: 'balance_scroll_view',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 3,
                    child: Semantics(
                        sortKey: const OrdinalSortKey(1, name: sortKeyName),
                        child: Column(
                          children: [
                            Image.asset(
                                'packages/flutter_gallery_assets/crane/destinations/sleep_10.jpg'),
                          ],
                        )
                        //const _BalanceGrid(spacing: 24),
                        ),
                  ),
                  const SizedBox(width: 24),
                  Flexible(
                    flex: 7,
                    child: Column(
                      children: [
                        Semantics(
                          sortKey: const OrdinalSortKey(2, name: sortKeyName),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                localizations.rallyNickname,
                                style: const TextStyle(fontSize: 18.0),
                              )),
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(
                            height: 80,
                            child: _TextView(title: 'Vasiliy', order: 1)),
                        const SizedBox(height: 30),
                        Semantics(
                          sortKey: const OrdinalSortKey(3, name: sortKeyName),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                localizations.rallyBalanceSmallLetters,
                                style: const TextStyle(fontSize: 18.0),
                              )),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                            height: 80,
                            child: _BalanceView(
                                onTap: () {
                                  _popUpBalance(context);
                                },
                                total: 1337,
                                order: 2)),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        restorationId: 'profile_scroll_view',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                    'packages/flutter_gallery_assets/crane/destinations/sleep_10.jpg', fit: BoxFit.cover,),
              ),
              const SizedBox(height: 10),
              Semantics(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      localizations.rallyNickname,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: TradingColors.gray60),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                  height: 80, child: _TextView(title: 'Vasiliy', order: 1)),
              const SizedBox(height: 30),
              Semantics(
                child: Row(children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    localizations.rallyBalanceSmallLetters,
                    style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: TradingColors.gray60),
                  )
                ]),
              ),
              const SizedBox(height: 10),
              SizedBox(
                  height: 80,
                  child: _BalanceView(
                      onTap: () {
                        _popUpBalance(context);
                      },
                      total: 1337,
                      order: 2)),
              const SizedBox(height: 30),
              Semantics(
                child: Row(children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    localizations.rallyGameHistory,
                    style: const TextStyle(fontSize: 18.0),
                  )
                ]),
              ),
              Column(
                children: [
                  for (GameHistoryData gameHistoryData
                      in DummyDataService.getGameHistory(context))
                    _GameHistoryCard(
                      date: gameHistoryData.gameDate ?? '13:13:1337',
                      numberOfParticipants:
                          gameHistoryData.numberOfParticipants ?? 0,
                      place: gameHistoryData.place ?? 0,
                      income: gameHistoryData.income ?? 0.0,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  void _popUpBalance(BuildContext context) {}
}

class _GameHistoryCard extends StatelessWidget {
  const _GameHistoryCard({
    required this.date,
    required this.numberOfParticipants,
    required this.place,
    required this.income,
  });

  final String date;
  final int numberOfParticipants;
  final int place;
  final double income;

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    return Container(
        padding: const EdgeInsets.all(10),
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
                    child: _IncomeData(income: income),
                  ),
                  _GameDate(date: date),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        '$place/$numberOfParticipants',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 16),
                      ),
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
                      _IncomeData(income: income),
                      _GameDate(date: date),
                    ],
                  ),
                  Text(
                    '$place/$numberOfParticipants',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 16),
                  ),
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
        )
    );
  }
}

class _GameDate extends StatelessWidget {
  const _GameDate({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Text(
      date,
      style: Theme.of(context)
          .textTheme
          .bodyMedium!
          .copyWith(color: TradingColors.gray60),
    );
  }
}

class _IncomeData extends StatelessWidget {
  const _IncomeData({this.income});

  final double? income;

  @override
  Widget build(BuildContext context) {
    if (income! > 0) {
      return Text(
        '+$income%',
          style: const TextStyle(color: Colors.green)
      );
    } else {
      return Text(
        '$income%',
          style: const TextStyle(color: Colors.red)
      );
    }
  }
}

class _PopUpBalanceButton extends StatelessWidget {
  const _PopUpBalanceButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: TradingColors.buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: const Icon(Icons.add),
    );
  }
}

class _BalanceView extends StatelessWidget {
  const _BalanceView({
    required this.onTap,
    this.total,
    this.order,
  });

  final VoidCallback? onTap;
  final double? total;
  final double? order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusTraversalOrder(
      order: NumericFocusOrder(order!),
      child: Container(
        color: TradingColors.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        children: [
                          SelectableText(
                            usdWithSignFormat(context).format(total),
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontSize: 44 / reducedTextScale(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          _PopUpBalanceButton(onTap: onTap!),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextView extends StatelessWidget {
  const _TextView({
    this.title,
    this.order,
  });

  final String? title;
  final double? order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FocusTraversalOrder(
      order: NumericFocusOrder(order!),
      child: Container(
        color: TradingColors.cardBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: SelectableText(
                      title!,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: 44 / reducedTextScale(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
