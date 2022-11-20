// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trading/app/app.dart';
import 'package:trading/app/colors.dart';
import 'package:trading/app/models.dart';
import 'package:trading/data/gallery_options.dart';
import 'package:trading/layout/adaptive.dart';
import 'package:trading/layout/image_placeholder.dart';
import 'package:trading/layout/text_scale.dart';
import 'package:trading/log.dart';
import 'package:trading/pages/registration.dart' as registration;
import 'package:trading/web.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with RestorationMixin {
  final RestorableTextEditingController _usernameController =
      RestorableTextEditingController();
  final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();

  @override
  String get restorationId => 'login_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_usernameController, restorationId);
    registerForRestoration(_passwordController, restorationId);
  }

  @override
  Widget build(BuildContext context) {
    return ApplyTextOptions(
      child: Scaffold(
        body: SafeArea(
          child: _MainView(
            usernameController: _usernameController.value,
            passwordController: _passwordController.value,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MainView extends StatelessWidget {
  const _MainView({
    this.usernameController,
    this.passwordController,
  });

  final TextEditingController? usernameController;
  final TextEditingController? passwordController;

  void _login(BuildContext context) {
    apiPost('login', {
      'login': usernameController?.text ?? '',
      'passwordHash': passwordController?.text ?? ''
    }).then((result) {
      switch (result.statusCode) {
        case 200:
          {
            log('Id: ${result.body}');
            context
                .read<UserModel>()
                .logIn(
                    int.parse(jsonDecode(result.body)['id'].toString()),
                    jsonDecode(result.body)['_admin'].toString() == 'true'
                );
            Navigator.of(context).restorablePushNamed(TradingApp.homeRoute);
          }
          break;

        case 400:
          {
            log('Wrong credentials!');
          }
          break;

        default:
          {
            log('Unexpected error: ${result.statusCode}! ${result.body}');
          }
      }
    }).catchError((dynamic error) {
      log(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDisplayDesktop(context);
    List<Widget> listViewChildren;

    if (isDesktop) {
      final desktopMaxWidth = 400.0 + 100.0 * (cappedTextScale(context) - 1);
      listViewChildren = [
        _UsernameInput(
          maxWidth: desktopMaxWidth,
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          maxWidth: desktopMaxWidth,
          passwordController: passwordController,
        ),
        _LoginButton(
          maxWidth: desktopMaxWidth,
          onTap: () {
            _login(context);
          },
        ),
      ];
    } else {
      listViewChildren = [
        const _SmallLogo(),
        _UsernameInput(
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          passwordController: passwordController,
        ),
        _ThumbButton(
          onTap: () {
            _login(context);
          },
        ),
      ];
    }

    return Column(
      children: [
        if (isDesktop) const _TopBar(),
        Expanded(
          child: Align(
            alignment: isDesktop ? Alignment.center : Alignment.topCenter,
            child: ListView(
              restorationId: 'login_list_view',
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: listViewChildren,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(width: 30);
    final localizations = TradingLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: SizedBox(
                  height: 80,
                  child: FadeInImagePlaceholder(
                    image: const AssetImage('assets/icon.png'),
                    placeholder: LayoutBuilder(builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxHeight,
                      );
                    }),
                  ),
                ),
              ),
              spacing,
              Text(
                localizations.rallyLoginLoginToRally,
                style: TextStyle(
                  fontSize: 35 / reducedTextScale(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.rallyLoginNoAccount,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              spacing,
              _BorderButton(
                text: localizations.rallyLoginSignUp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallLogo extends StatelessWidget {
  const _SmallLogo();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: SizedBox(
        height: 160,
        child: ExcludeSemantics(
          child: FadeInImagePlaceholder(
            image: AssetImage('logo.png', package: 'rally_assets'),
            placeholder: SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({
    this.maxWidth,
    this.usernameController,
  });

  final double? maxWidth;
  final TextEditingController? usernameController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          textInputAction: TextInputAction.next,
          controller: usernameController,
          decoration: InputDecoration(
            labelText: TradingLocalizations.of(context)!.rallyLoginUsername,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    this.maxWidth,
    this.passwordController,
  });

  final double? maxWidth;
  final TextEditingController? passwordController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        child: TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: TradingLocalizations.of(context)!.rallyLoginPassword,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.0),
            ),
          ),
          style: const TextStyle(color: Colors.black),
          obscureText: true,
        ),
      ),
    );
  }
}

class _ThumbButton extends StatefulWidget {
  const _ThumbButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  _ThumbButtonState createState() => _ThumbButtonState();
}

class _ThumbButtonState extends State<_ThumbButton> {
  BoxDecoration? borderDecoration;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: true,
      label: TradingLocalizations.of(context)!.rallyLoginLabelLogin,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Focus(
            onKey: (node, event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.space) {
                  widget.onTap();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() {
                  borderDecoration = BoxDecoration(
                    border: Border.all(
                      color: Colors.black.withOpacity(0.5),
                      width: 2,
                    ),
                  );
                });
              } else {
                setState(() {
                  borderDecoration = null;
                });
              }
            },
            child: Container(
              decoration: borderDecoration,
              height: 120,
              child: ExcludeSemantics(
                child: Image.asset(
                  'thumb.png',
                  package: 'rally_assets',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.onTap,
    this.maxWidth,
  });

  final double? maxWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: TradingColors.buttonColor),
            const SizedBox(width: 12),
            Text.rich(TextSpan(
                text: TradingLocalizations.of(context)!.rallyLoginRememberMe,
                style: const TextStyle(color: Colors.black))),
            const Expanded(child: SizedBox.shrink()),
            _FilledButton(
              text: TradingLocalizations.of(context)!.rallyLoginButtonLogin,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _BorderButton extends StatelessWidget {
  const _BorderButton({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.black),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        registration.showRegistrationDialog(context: context);
      },
      child: Text(text),
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: TradingColors.buttonColor,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          const Icon(Icons.lock),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}
