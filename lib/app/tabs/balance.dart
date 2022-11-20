// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:trading/app/colors.dart';
import 'package:trading/app/data.dart';
import 'package:trading/app/formatters.dart';
import 'package:trading/data/gallery_options.dart';
import 'package:trading/layout/adaptive.dart';
import 'package:trading/layout/text_scale.dart';

/// A page that shows a status overview.
class BalanceView extends StatefulWidget {
  const BalanceView({super.key});

  @override
  State<BalanceView> createState() => _BalanceViewState();
}

class _BalanceViewState extends State<BalanceView> {
  @override
  Widget build(BuildContext context) {
    final operationsData = DummyDataService.getOperations(context);

    if (isDisplayDesktop(context)) {
      const sortKeyName = 'Balance';
      return SingleChildScrollView(
        restorationId: 'balance_scroll_view',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 400,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 7,
                          child: Semantics(
                              sortKey: const OrdinalSortKey(1, name: sortKeyName),
                              child: Column (
                                children:[
                                  const _BalanceGrid(spacing: 24),
                                  SizedBox(
                                    child: Semantics(
                                      sortKey: const OrdinalSortKey(3, name: sortKeyName),
                                      child: FocusTraversalGroup(
                                        child: _TradingHistoryView(operations: operationsData),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            //const _BalanceGrid(spacing: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer()
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        restorationId: 'balance_scroll_view',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const _BalanceGrid(spacing: 12),
              _TradingHistoryView(operations: operationsData),
            ],
          ),
        ),
      );
    }
  }
}

class _BalanceGrid extends StatelessWidget {
  const _BalanceGrid({required this.spacing});

  final double spacing;

  @override
  Widget build(BuildContext context) {
    final accountDataList = DummyDataService.getAccountDataList(context);
    final billDataList = DummyDataService.getBillDataList(context);
    final localizations = TradingLocalizations.of(context)!;

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
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            child: const Text('Hello, user!',
              style: TextStyle(fontSize: 48.0),),
          ),
          Wrap(
            runSpacing: spacing,
            children: [
              SizedBox(
                width: boxWidth,
                child: _FinancialView(
                  title: localizations.rallyRubBalance,
                  total: sumAccountDataPrimaryAmount(accountDataList),
                  buttonSemanticsLabel: localizations.rallySeeAllAccounts,
                  order: 1,
                ),
              ),
              if (hasMultipleColumns) SizedBox(width: spacing),
              SizedBox(
                width: boxWidth,
                child: _FinancialView(
                  title: localizations.rallyUsdBalance,
                  total: sumBillDataPrimaryAmount(billDataList),
                  buttonSemanticsLabel: localizations.rallySeeAllBills,
                  order: 2,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _AlertsView extends StatelessWidget {
  const _AlertsView({this.alerts});

  final List<AlertData>? alerts;

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final localizations = TradingLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, top: 4, bottom: 4),
      color: TradingColors.cardBackground,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                isDesktop ? const EdgeInsets.symmetric(vertical: 16) : null,
            child: MergeSemantics(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(localizations.rallyAlerts),
                  if (!isDesktop)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: Text(localizations.rallySeeAll),
                    ),
                ],
              ),
            ),
          ),
          for (AlertData alert in alerts!) ...[
            Container(color: TradingColors.primaryBackground, height: 1),
            _Alert(alert: alert),
          ]
        ],
      ),
    );
  }
}

class _Alert extends StatelessWidget {
  const _Alert({required this.alert});

  final AlertData alert;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: isDisplayDesktop(context)
            ? const EdgeInsets.symmetric(vertical: 8)
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SelectableText(alert.message!),
            ),
            SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(alert.iconData, color: TradingColors.white60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradingHistoryView extends StatelessWidget {
  const _TradingHistoryView({this.operations});

  final List<OperationData>? operations;

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    final localizations = TradingLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, top: 4, bottom: 4),
      color: TradingColors.cardBackground,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
            isDesktop ? const EdgeInsets.symmetric(vertical: 16) : null,
            child: MergeSemantics(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(localizations.rallyOperationHistory),
                  if (!isDesktop)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: Text(localizations.rallySeeAll),
                    ),
                ],
              ),
            ),
          ),
          for (OperationData operation in operations!) ...[
            Container(color: TradingColors.primaryBackground, height: 1),
            _Operation(operation: operation,isBuy: operation.isPurchase),
          ]
        ],
      ),
    );
  }
}

class _Operation extends StatelessWidget {
  const _Operation({required this.operation, required this.isBuy});

  final bool? isBuy;
  final OperationData operation;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: isDisplayDesktop(context)
            ? const EdgeInsets.symmetric(vertical: 8)
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SelectableText('${operation.operationText!} ${operation.sumOfDeal!}'),
            ),
            SizedBox(
              width: 100,
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {},
                  icon: isBuy!? const Icon(Icons.arrow_upward, color: Colors.green):
                  const Icon(Icons.arrow_downward, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialView extends StatelessWidget {
  const _FinancialView({
    this.title,
    this.total,
    this.buttonSemanticsLabel,
    this.order,
  });

  final String? title;
  final String? buttonSemanticsLabel;
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
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: SelectableText(title!),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: SelectableText(
                      usdWithSignFormat(context).format(total),
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
