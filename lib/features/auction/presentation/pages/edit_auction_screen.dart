import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/lotex_ui_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/lotex_app_bar.dart';
import '../../../../core/widgets/lotex_background.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../data/repositories/auction_repository.dart';
import '../../domain/entities/auction_entity.dart';

class EditAuctionScreen extends ConsumerStatefulWidget {
  final AuctionEntity auction;

  const EditAuctionScreen({super.key, required this.auction});

  @override
  ConsumerState<EditAuctionScreen> createState() => _EditAuctionScreenState();
}

class _EditAuctionScreenState extends ConsumerState<EditAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _buyoutPriceController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _buyoutEnabled = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.auction.title;
    _descController.text = widget.auction.description;

    final buyout = widget.auction.buyoutPrice;
    _buyoutEnabled = buyout != null && buyout > 0;
    _buyoutPriceController.text = _buyoutEnabled ? buyout!.toStringAsFixed(0) : '';

    _selectedDate = widget.auction.endDate;
    _dateController.text = DateFormat('dd.MM.yyyy HH:mm').format(widget.auction.endDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _buyoutPriceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: (_selectedDate ?? now).isAfter(now) ? (_selectedDate ?? now) : now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime(now.year, now.month, now.day, 12, 0)),
    );
    if (time == null) return;
    if (!mounted) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateController.text = DateFormat('dd.MM.yyyy HH:mm').format(_selectedDate!);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    final lang = ref.read(lotexLanguageProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'authRequired'))),
      );
      return;
    }

    double? buyoutPrice;
    if (_buyoutEnabled) {
      final raw = _buyoutPriceController.text.trim();
      if (raw.isNotEmpty) {
        buyoutPrice = double.tryParse(raw.replaceAll(',', '.'));
      }
    }

    final endDate = _selectedDate;
    if (endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'selectDateRequired'))),
      );
      return;
    }

    // Fast client-side guard to avoid confusing web errors.
    if (widget.auction.bidCount > 0) {
      final originalBuyout = widget.auction.buyoutPrice;
      final buyoutChanged = (_buyoutEnabled ? (buyoutPrice ?? 0) : 0) != (originalBuyout ?? 0);
      final endChanged = endDate.toIso8601String() != widget.auction.endDate.toIso8601String();
      if (buyoutChanged || endChanged) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Неможливо змінювати ціну викупу або дату завершення після появи ставок.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await ref.read(auctionRepositoryProvider).updateAuction(
            auctionId: widget.auction.id,
            sellerId: user.uid,
            title: _titleController.text,
            description: _descController.text,
            endDate: endDate,
            buyoutPrice: buyoutPrice,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LotexI18n.tr(lang, 'lotUpdated')), backgroundColor: AppColors.success),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;

      String details;
      if (e is AsyncError) {
        details = e.error.toString();
      } else if (e is FirebaseException) {
        details = e.message ?? e.toString();
      } else {
        details = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', details)),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);

    return Scaffold(
      appBar: LotexAppBar(titleText: LotexI18n.tr(lang, 'editLot'), showDefaultActions: false),
      body: Stack(
        children: [
          const LotexBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppInput(
                    label: LotexI18n.tr(lang, 'productName'),
                    hint: LotexI18n.tr(lang, 'productName'),
                    controller: _titleController,
                    validator: (v) => (v == null || v.trim().isEmpty) ? LotexI18n.tr(lang, 'requiredField') : null,
                  ),
                  const SizedBox(height: 14),
                  AppInput(
                    label: LotexI18n.tr(lang, 'description'),
                    hint: LotexI18n.tr(lang, 'description'),
                    controller: _descController,
                    maxLines: 5,
                    validator: (v) => (v == null || v.trim().isEmpty) ? LotexI18n.tr(lang, 'requiredField') : null,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _pickDateTime,
                    child: AbsorbPointer(
                      child: AppInput(
                        label: LotexI18n.tr(lang, 'endDate'),
                        hint: LotexI18n.tr(lang, 'endDate'),
                        controller: _dateController,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.05 * 255).round()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            LotexI18n.tr(lang, 'buyoutAvailable'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Switch(
                          value: _buyoutEnabled,
                          onChanged: _saving
                              ? null
                              : (v) {
                                  setState(() {
                                    _buyoutEnabled = v;
                                    if (!v) _buyoutPriceController.clear();
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                  if (_buyoutEnabled) ...[
                    const SizedBox(height: 12),
                    AppInput(
                      label: LotexI18n.tr(lang, 'buyoutPrice'),
                      hint: LotexI18n.tr(lang, 'buyoutPrice'),
                      controller: _buyoutPriceController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (!_buyoutEnabled) return null;
                        final raw = (v ?? '').trim();
                        if (raw.isEmpty) return LotexI18n.tr(lang, 'requiredField');
                        final parsed = double.tryParse(raw.replaceAll(',', '.'));
                        if (parsed == null || parsed <= 0) return LotexI18n.tr(lang, 'invalidNumber');
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 18),
                  AppButton.primary(
                    label: _saving ? LotexI18n.tr(lang, 'pleaseWait') : LotexI18n.tr(lang, 'saveChanges'),
                    onPressed: _saving ? null : _submit,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    LotexI18n.tr(lang, 'editLotNote'),
                    style: const TextStyle(color: LotexUiColors.slate400, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
