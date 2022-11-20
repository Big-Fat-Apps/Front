import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:provider/provider.dart';
import 'package:trading/log.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app.dart';
import '../app/colors.dart';
import '../app/models.dart';
import '../layout/adaptive.dart';
import '../layout/text_scale.dart';
import '../web.dart';

void showRegistrationDialog({
  required BuildContext context,
}) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return const _RegistrationDialog();
    },
  );
}

class _RegistrationDialog extends StatelessWidget {
  const _RegistrationDialog({
    this.usernameController,
    this.passwordController,
    this.repeatPasswordController,
  });

  final TextEditingController? usernameController;
  final TextEditingController? passwordController;
  final TextEditingController? repeatPasswordController;

  void _register(BuildContext context) {
    if (passwordController?.text != repeatPasswordController?.text) {
      log('Passwords don\'t match!');
      return;
    }

    apiPost(
        'reg',
        {
          'login': usernameController?.text ?? '',
          'passwordHash': passwordController?.text ?? '',
        }
    ).then((result) {
      switch (result.statusCode) {
        case 200: {
          log('User: ${result.body}');
          context.read<UserModel>().logIn(
            int.parse(jsonDecode(result.body)['id'].toString()),
            jsonDecode(result.body)['is_admin'].toString() == 'true'
          );
          Navigator.of(context).restorablePushNamed(TradingApp.homeRoute);
        }
        break;

        case 400: {
          log('Wrong credentials!');
        }
        break;

        default: {
          log('Unexpected error: ${result.statusCode}! ${result.body}');
        }
      }
    }).catchError((dynamic error) {
      log(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bodyTextStyle = textTheme.bodyMedium!.apply(color: colorScheme.onPrimary);
    final localizations = TradingLocalizations.of(context)!;

    List<Widget> listViewChildren;

    if (isDisplayDesktop(context)) {
      final desktopMaxWidth = 400.0 + 100.0 * (cappedTextScale(context) - 1);
      listViewChildren = [
        Text.rich(
          TextSpan(
            text: localizations.backToGallery,
            style: bodyTextStyle
          )
        ),
        _UsernameInput(
          maxWidth: desktopMaxWidth,
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          maxWidth: desktopMaxWidth,
          passwordController: passwordController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          maxWidth: desktopMaxWidth,
          passwordController: repeatPasswordController,
        ),
        _RegisterButton(
          maxWidth: desktopMaxWidth,
          onTap: () {
            _register(context);
          },
        ),
      ];
    } else {
      listViewChildren = [
        Text.rich(
            TextSpan(
                text: localizations.backToGallery,
                style: bodyTextStyle
            )
        ),
        _UsernameInput(
          usernameController: usernameController,
        ),
        const SizedBox(height: 12),
        _PasswordInput(
          passwordController: passwordController,
        ),
        _PasswordInput(
          passwordController: repeatPasswordController,
        ),
        _RegisterButton(
          onTap: () {
            _register(context);
          },
        ),
      ];
    }

    return AlertDialog(
      backgroundColor: colorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: listViewChildren,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
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
          ),
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
          ),
          obscureText: true,
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({
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
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(
          children: [
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

class _FilledButton extends StatelessWidget {
  const _FilledButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: TradingColors.buttonColor,
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
