import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/widgets/lotex_modal.dart';
import '../providers/create_auction_controller.dart';

Future<void> showCreateLotModal({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final lang = ref.read(lotexLanguageProvider);

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final startCtrl = TextEditingController();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  XFile? image;

  await showLotexModal<void>(
    context: context,
    title: LotexI18n.tr(lang, 'createLot'),
    child: Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(createAuctionControllerProvider);

        ref.listen<AsyncValue<void>>(createAuctionControllerProvider, (prev, next) {
          next.whenOrNull(
            data: (_) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
            },
          );
        });

        Future<void> pickImage() async {
          final picker = ImagePicker();
          final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600);
          if (picked != null) {
            image = picked;
          }
        }

        Future<void> pickEndDate() async {
          final now = DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: endDate,
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
          );
          if (!context.mounted) return;
          if (date == null) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(endDate),
          );
          if (!context.mounted) return;
          if (time == null) return;
          endDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label(LotexI18n.tr(lang, 'productName')),
                _field(titleCtrl, hint: ''),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'description')),
                _field(descCtrl, maxLines: 4, hint: ''),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'startingBid')),
                _field(startCtrl, keyboardType: TextInputType.number, hint: LotexI18n.tr(lang, 'currency')),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'endDate')),
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: () async {
                      await pickEndDate();
                      if (!context.mounted) return;
                      setState(() {});
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha((0.06 * 255).round()),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.white,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        endDate.toLocal().toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () async {
                      await pickImage();
                      if (!context.mounted) return;
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withAlpha((0.12 * 255).round())),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      image == null ? LotexI18n.tr(lang, 'uploadImage') : '✓ ${LotexI18n.tr(lang, 'uploadImage')}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (state.hasError)
                  Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
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
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              final title = titleCtrl.text.trim();
                              final desc = descCtrl.text.trim();
                              final start = double.tryParse(startCtrl.text.trim().replaceAll(' ', ''));
                              if (title.isEmpty || start == null || image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Заповніть поля і додайте фото')),
                                );
                                return;
                              }
                              await ref.read(createAuctionControllerProvider.notifier).create(
                                    title: title,
                                    description: desc,
                                    startPrice: start,
                                    endDate: endDate,
                                    image: image!,
                                  );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              LotexI18n.tr(lang, 'createLot'),
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
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

Widget _field(
  TextEditingController controller, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
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
