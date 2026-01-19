import 'package:flutter/foundation.dart'; // Потрібен для kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/widgets/app_input.dart';
import 'package:lotex/core/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import '../providers/create_auction_controller.dart';
import '../widgets/lotex_input.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/utils/human_error.dart';
import '../providers/create_submit_provider.dart';
import 'package:lotex/services/category_seed_service.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() =>
      _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _buyoutPriceController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedCategoryId;

  DateTime? _selectedDate;
  XFile? _pickedImage;
  bool _buyoutEnabled = false;
  // Ми прибрали _pickedImageBytes, бо він тут не потрібен для відображення

  late final ProviderSubscription<AsyncValue<void>> _createSub;

  @override
  void initState() {
    super.initState();
    // Don't update providers synchronously during init/build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(createSubmitCallbackProvider.notifier).state = _submit;
    });
    _createSub = ref.listenManual<AsyncValue<void>>(
      createAuctionControllerProvider,
      (prev, next) {
        final wasLoading = prev?.isLoading ?? false;
        if (!wasLoading) return;

        final lang = ref.read(lotexLanguageProvider);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          next.when(
            data: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LotexI18n.tr(lang, 'lotCreated')),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/home');
            },
            error: (e, st) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    LotexI18n.tr(lang, 'errorWithDetails')
                        .replaceFirst('{details}', humanError(e)),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            loading: () {},
          );
        });
      },
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _selectedDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateController.text =
          DateFormat('dd.MM.yyyy HH:mm').format(_selectedDate!);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Тут ми просто зберігаємо файл, не читаючи байти (швидше)
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Widget _buildPickedImage() {
    final picked = _pickedImage;
    if (picked == null) {
      return const SizedBox.shrink();
    }

    // On web, XFile.path is typically an object URL, so Image.network works.
    if (kIsWeb) {
      return Image.network(picked.path, fit: BoxFit.cover);
    }

    // Avoid dart:io import (web-incompatible) by using ImageProvider via XFile.
    return FutureBuilder<ImageProvider>(
      future: picked.readAsBytes().then((b) => MemoryImage(b)),
      builder: (context, snapshot) {
        final provider = snapshot.data;
        if (provider == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Image(image: provider, fit: BoxFit.cover);
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_pickedImage == null) {
        final lang = ref.read(lotexLanguageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LotexI18n.tr(lang, 'addPhotoRequired'))),
        );
        return;
      }
      if (_selectedDate == null) {
        final lang = ref.read(lotexLanguageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LotexI18n.tr(lang, 'selectDateRequired'))),
        );
        return;
      }

      final category = (_selectedCategoryId ?? '').trim();
      if (category.isEmpty) {
        final lang = ref.read(lotexLanguageProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LotexI18n.tr(lang, 'selectCategoryRequired'))),
        );
        return;
      }

      final startPrice =
          double.parse(_startPriceController.text.replaceAll(',', '.'));

      double? buyoutPrice;
      if (_buyoutEnabled) {
        final raw = _buyoutPriceController.text.trim();
        if (raw.isNotEmpty) {
          buyoutPrice = double.tryParse(raw.replaceAll(',', '.'));
        }
      }

      ref.read(createAuctionControllerProvider.notifier).create(
            title: _titleController.text,
            description: _descController.text,
        category: category,
            startPrice: startPrice,
            buyoutPrice: buyoutPrice,
            endDate: _selectedDate!,
            image: _pickedImage!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);

    final isLoading = ref.watch(createAuctionControllerProvider).isLoading;

    bool canSubmit() {
      if (isLoading) return false;
      if (_pickedImage == null) return false;
      if (_selectedDate == null) return false;
      if ((_selectedCategoryId ?? '').trim().isEmpty) return false;

      if (_titleController.text.trim().isEmpty) return false;
      if (_descController.text.trim().isEmpty) return false;

      final startRaw = _startPriceController.text.trim();
      final startPrice = double.tryParse(startRaw.replaceAll(',', '.'));
      if (startPrice == null || startPrice <= 0) return false;

      if (_buyoutEnabled) {
        final raw = _buyoutPriceController.text.trim();
        final buyout = double.tryParse(raw.replaceAll(',', '.'));
        if (buyout == null || buyout <= startPrice) return false;
      }

      return true;
    }

    final categories = CategorySeedService.categories;
    final categoryItems = <DropdownMenuItem<String>>[
      for (final c in categories)
        DropdownMenuItem<String>(
          value: c.id,
          child: Text(
            c.parentId == null ? c.name : '— ${c.name}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ];

    _selectedCategoryId ??= categories.isNotEmpty ? categories.first.id : null;

    // Reserve space at the bottom so content never hides behind the pinned action bar.
    const double actionBarHeight = 72;
    final scrollBottomPadding =
        actionBarHeight + MediaQuery.viewPaddingOf(context).bottom + 32;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: LotexAppBar(
          titleText: LotexI18n.tr(lang, 'createLot'),
          showDefaultActions: false),
      body: Stack(
        children: [
          const LotexBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, scrollBottomPadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 18),
                    child: Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          elevation: 12,
                          shadowColor: LotexUiColors.violet500
                              .withAlpha((0.35 * 255).round()),
                          shape: const CircleBorder(),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  LotexUiColors.violet600,
                                  LotexUiColors.blue600
                                ],
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '✨',
                              style: TextStyle(fontSize: 34, height: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          LotexI18n.tr(lang, 'createListingTitle'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Text(
                            LotexI18n.tr(lang, 'createListingSubtitle'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: LotexUiColors.slate400,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                Colors.white.withAlpha((0.10 * 255).round())),
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildPickedImage(),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_outlined,
                                    size: 48, color: Colors.white70),
                                const SizedBox(height: 8),
                                Text(LotexI18n.tr(lang, 'uploadImage'),
                                    style:
                                        const TextStyle(color: Colors.white70)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LotexInput(
                    label: LotexI18n.tr(lang, 'productName'),
                    hint: 'iPhone 15...',
                    controller: _titleController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? LotexI18n.tr(lang, 'enterTitle')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  LotexInput(
                    label: LotexI18n.tr(lang, 'description'),
                    hint: 'Деталі...',
                    maxLines: 4,
                    controller: _descController,
                    validator: (v) => (v == null || v.isEmpty)
                        ? LotexI18n.tr(lang, 'enterDescription')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LotexI18n.tr(lang, 'category'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ) ??
                            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: FormField<String>(
                          initialValue: _selectedCategoryId,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return LotexI18n.tr(lang, 'selectCategoryRequired');
                            }
                            return null;
                          },
                          builder: (field) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                errorText: field.errorText,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: (_selectedCategoryId ?? '').isNotEmpty ? _selectedCategoryId : field.value,
                                  isExpanded: true,
                                  items: categoryItems,
                                  onChanged: isLoading
                                      ? null
                                      : (v) {
                                          setState(() {
                                            _selectedCategoryId = v;
                                          });
                                          field.didChange(v);
                                        },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LotexInput(
                    label: LotexI18n.tr(lang, 'startingBid'),
                    hint: '0.0',
                    controller: _startPriceController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return LotexI18n.tr(lang, 'enterAmount');
                      }
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null) {
                        return LotexI18n.tr(lang, 'invalidPrice');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.05 * 255).round()),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withAlpha((0.10 * 255).round())),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LotexI18n.tr(lang, 'buyoutAvailable'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    LotexI18n.tr(lang, 'buyoutPrice'),
                                    style: const TextStyle(
                                      color: LotexUiColors.slate400,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _buyoutEnabled,
                              activeThumbColor: LotexUiColors.violet500,
                              onChanged: (v) {
                                setState(() {
                                  _buyoutEnabled = v;
                                  if (!v) _buyoutPriceController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                        if (_buyoutEnabled) ...[
                          const SizedBox(height: 12),
                          LotexInput(
                            label: LotexI18n.tr(lang, 'buyoutPrice'),
                            hint: '0.0',
                            controller: _buyoutPriceController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (!_buyoutEnabled) return null;
                              if (v == null || v.trim().isEmpty) {
                                return LotexI18n.tr(lang, 'enterAmount');
                              }
                              final parsed =
                                  double.tryParse(v.replaceAll(',', '.'));
                              if (parsed == null) {
                                return LotexI18n.tr(lang, 'invalidPrice');
                              }
                              final startRaw =
                                  _startPriceController.text.trim();
                              final startParsed = startRaw.isEmpty
                                  ? null
                                  : double.tryParse(
                                      startRaw.replaceAll(',', '.'));
                              if (startParsed != null &&
                                  parsed <= startParsed) {
                                return '${LotexI18n.tr(lang, 'amountMustBeGreaterThan')} ${startParsed.toString()}';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: LotexI18n.tr(lang, 'endDate'),
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDateTime,
                    suffixIcon: const Icon(Icons.calendar_today),
                    validator: (v) => v == null || v.isEmpty
                        ? LotexI18n.tr(lang, 'selectDateRequired')
                        : null,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _titleController,
            _descController,
            _startPriceController,
            _buyoutPriceController,
            _dateController,
          ]),
          builder: (context, _) {
            final enabled = canSubmit();
            return AppButton.primary(
              label: isLoading
                  ? LotexI18n.tr(lang, 'pleaseWait')
                  : LotexI18n.tr(lang, 'createLotAction'),
              onPressed: enabled ? _submit : null,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clear submit callback from provider to avoid stale callbacks after dispose.
    ref.read(createSubmitCallbackProvider.notifier).state = null;

    _createSub.close();
    _titleController.dispose();
    _descController.dispose();
    _startPriceController.dispose();
    _buyoutPriceController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
