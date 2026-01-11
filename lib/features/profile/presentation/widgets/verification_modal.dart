import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/widgets/lotex_modal.dart';

Future<void> showVerificationModal({
  required BuildContext context,
  required WidgetRef ref,
  required bool isPhone,
}) async {
  final rootContext = context;
  final lang = ref.read(lotexLanguageProvider);
  final codeCtrl = TextEditingController();
  bool sent = false;

  await showLotexModal<void>(
    context: context,
    title: isPhone ? LotexI18n.tr(lang, 'verifyPhone') : LotexI18n.tr(lang, 'verifyEmail'),
    child: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => sent = true);
                  final messenger = ScaffoldMessenger.maybeOf(rootContext);
                  messenger?.showSnackBar(
                    SnackBar(content: Text(LotexI18n.tr(lang, 'codeSent'))),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withAlpha((0.12 * 255).round())),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  LotexI18n.tr(lang, sent ? 'resend' : 'sendCode'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _label(LotexI18n.tr(lang, 'enterCode')),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withAlpha((0.06 * 255).round()),
                hintText: '123456',
                hintStyle: const TextStyle(color: LotexUiColors.slate500),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withAlpha((0.08 * 255).round())),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: LotexUiColors.violet500),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [LotexUiColors.violet600, LotexUiColors.blue600]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final messenger = ScaffoldMessenger.maybeOf(rootContext);
                      messenger?.showSnackBar(
                        SnackBar(content: Text(LotexI18n.tr(lang, 'verified'))),
                      );
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    LotexI18n.tr(lang, 'verify'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: LotexUiColors.slate400),
    ),
  );
}
