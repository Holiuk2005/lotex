import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/formatters/card_number_input_formatter.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/widgets/lotex_modal.dart';

Future<void> showLinkCardModal({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final rootContext = context;
  final lang = ref.read(lotexLanguageProvider);

  final numberCtrl = TextEditingController();
  final holderCtrl = TextEditingController();
  final expCtrl = TextEditingController();
  final cvvCtrl = TextEditingController();

  await showLotexModal<void>(
    context: context,
    title: LotexI18n.tr(lang, 'linkCard'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(LotexI18n.tr(lang, 'cardNumber')),
        TextField(
          controller: numberCtrl,
          keyboardType: TextInputType.number,
          maxLength: 19,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withAlpha((0.06 * 255).round()),
            hintText: '0000 0000 0000 0000',
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
        const SizedBox(height: 12),
        _label(LotexI18n.tr(lang, 'cardHolder')),
        _field(holderCtrl, hint: 'NAME SURNAME'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label(LotexI18n.tr(lang, 'expiryDate')),
                  _field(expCtrl, hint: LotexI18n.tr(lang, 'expiryDate'), keyboardType: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label(LotexI18n.tr(lang, 'cvv')),
                  _field(cvvCtrl, hint: '***', keyboardType: TextInputType.number),
                ],
              ),
            ),
          ],
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
                    SnackBar(content: Text(LotexI18n.tr(lang, 'saveCard'))),
                  );
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                LotexI18n.tr(lang, 'saveCard'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
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

Widget _field(
  TextEditingController controller, {
  String? hint,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha((0.06 * 255).round()),
      hintText: hint,
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
  );
}
