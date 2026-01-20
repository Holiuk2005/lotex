import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/i18n/category_i18n.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/lotex_modal.dart';
import '../providers/create_auction_controller.dart';
import 'package:lotex/services/category_seed_service.dart';

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
  String? selectedTypeId;
  Set<String> selectedSubtypeIds = <String>{};
  String currency = LotexCurrency.uah;

  await showLotexModal<void>(
    context: context,
    title: LotexI18n.tr(lang, 'createLot'),
    child: Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(createAuctionControllerProvider);

        ref.listen<AsyncValue<void>>(createAuctionControllerProvider, (prev, next) {
          final wasLoading = prev?.isLoading ?? false;
          if (!wasLoading) return;
          next.whenOrNull(
            data: (_) {
              if (!context.mounted) return;
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
            final categories = CategorySeedService.categories;
            final roots = CategoryI18n.roots(categories);
            selectedTypeId ??= roots.isNotEmpty ? roots.first.id : null;

            final typeId = selectedTypeId;
            final subtypes = typeId == null ? const <CategoryModel>[] : CategoryI18n.childrenOf(categories, typeId);
            if (selectedSubtypeIds.isEmpty && subtypes.isNotEmpty) {
              selectedSubtypeIds = <String>{subtypes.first.id};
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label(LotexI18n.tr(lang, 'productName')),
                _field(titleCtrl, hint: ''),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'description')),
                _field(descCtrl, maxLines: 4, hint: ''),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'currencyLabel')),
                SizedBox(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.06 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currency,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF111827),
                          iconEnabledColor: Colors.white,
                          items: [
                            DropdownMenuItem<String>(
                              value: LotexCurrency.uah,
                              child: Text(
                                LotexI18n.tr(lang, 'currencyUAH'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: LotexCurrency.usd,
                              child: Text(
                                LotexI18n.tr(lang, 'currencyUSD'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: LotexCurrency.eur,
                              child: Text(
                                LotexI18n.tr(lang, 'currencyEUR'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                          onChanged: state.isLoading
                              ? null
                              : (v) {
                                  if (v == null) return;
                                  setState(() => currency = v);
                                },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'startingBid')),
                _field(startCtrl, keyboardType: TextInputType.number, hint: '0.0'),
                const SizedBox(height: 12),

                _label(LotexI18n.tr(lang, 'category')),
                SizedBox(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.06 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedTypeId,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF111827),
                              iconEnabledColor: Colors.white,
                              items: [
                                for (final c in roots)
                                  DropdownMenuItem<String>(
                                    value: c.id,
                                    child: Text(
                                      CategoryI18n.label(lang, c.id, fallback: c.name),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: state.isLoading
                                  ? null
                                  : (v) {
                                      setState(() {
                                        selectedTypeId = v;
                                        selectedSubtypeIds = <String>{};
                                      });
                                    },
                            ),
                          ),
                          if (typeId != null && subtypes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final c in subtypes)
                                  FilterChip(
                                    label: Text(
                                      CategoryI18n.label(lang, c.id, fallback: c.name),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                    ),
                                    selected: selectedSubtypeIds.contains(c.id),
                                    onSelected: state.isLoading
                                        ? null
                                        : (on) {
                                            setState(() {
                                              final next = Set<String>.from(selectedSubtypeIds);
                                              if (on) {
                                                next.add(c.id);
                                              } else {
                                                next.remove(c.id);
                                              }
                                              selectedSubtypeIds = next;
                                            });
                                          },
                                  ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
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
                              final typeId = (selectedTypeId ?? '').trim();
                              final subtypes = selectedSubtypeIds.toList(growable: false);
                              final category = subtypes.isNotEmpty ? subtypes.first : '';
                              if (title.isEmpty || start == null || image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Заповніть поля і додайте фото')),
                                );
                                return;
                              }
                              if (typeId.isEmpty || subtypes.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(LotexI18n.tr(lang, 'selectCategoryRequired'))),
                                );
                                return;
                              }
                              await ref.read(createAuctionControllerProvider.notifier).create(
                                    title: title,
                                    description: desc,
                                    category: category,
                                    categoryType: typeId,
                                    categoryIds: subtypes,
                                currency: currency,
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
