import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/lotex_app_bar.dart';
import '../../../../core/widgets/lotex_background.dart';
import '../../../../core/i18n/language_provider.dart';
import '../../../../core/i18n/lotex_i18n.dart';
import '../../../../core/i18n/category_i18n.dart';
import '../../../../services/category_seed_service.dart';
import '../../../../core/utils/human_error.dart';
import '../providers/create_marketplace_item_controller.dart';
import '../../../../core/utils/currency.dart';

class CreateMarketplaceItemScreen extends ConsumerStatefulWidget {
  const CreateMarketplaceItemScreen({super.key});

  @override
  ConsumerState<CreateMarketplaceItemScreen> createState() => _CreateMarketplaceItemScreenState();
}

class _CreateMarketplaceItemScreenState extends ConsumerState<CreateMarketplaceItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedTypeId;
  Set<String> _selectedSubtypeIds = <String>{};
  final String _currency = LotexCurrency.uah;
  XFile? _pickedImage;

  late final ProviderSubscription<AsyncValue<void>> _createSub;

  @override
  void initState() {
    super.initState();
    _createSub = ref.listenManual<AsyncValue<void>>(
      createMarketplaceItemControllerProvider,
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
                    LotexI18n.tr(lang, 'errorWithDetails').replaceFirst('{details}', humanError(e)),
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _pickedImage = image);
    }
  }

  Widget _buildPickedImage() {
    final picked = _pickedImage;
    if (picked == null) return const SizedBox.shrink();
    if (kIsWeb) return Image.network(picked.path, fit: BoxFit.cover);
    return FutureBuilder<ImageProvider>(
      future: picked.readAsBytes().then((b) => MemoryImage(b)),
      builder: (context, snapshot) {
        final provider = snapshot.data;
        if (provider == null) return const Center(child: CircularProgressIndicator());
        return Image(image: provider, fit: BoxFit.cover);
      },
    );
  }

  void _submit() {
    if (_pickedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вам необхідно додати фото')),
      );
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      final typeId = (_selectedTypeId ?? '').trim();
      final subtypes = _selectedSubtypeIds.toList(growable: false);
      if (typeId.isEmpty || subtypes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оберіть категорію та підкатегорію')),
        );
        return;
      }

      final category = subtypes.first;
      final price = double.parse(_priceController.text.replaceAll(',', '.'));

      ref.read(createMarketplaceItemControllerProvider.notifier).create(
            title: _titleController.text,
            description: _descController.text,
            category: category,
            currency: _currency,
            price: price,
            image: _pickedImage!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);
    final isLoading = ref.watch(createMarketplaceItemControllerProvider).isLoading;

    final categories = CategorySeedService.categories;
    final roots = CategoryI18n.roots(categories);
    _selectedTypeId ??= roots.isNotEmpty ? roots.first.id : null;
    final subtypes = _selectedTypeId == null
        ? const <CategoryModel>[]
        : CategoryI18n.childrenOf(categories, _selectedTypeId!);
    if (_selectedSubtypeIds.isEmpty && subtypes.isNotEmpty) {
      _selectedSubtypeIds = <String>{subtypes.first.id};
    }

    return Scaffold(
      appBar: const LotexAppBar(titleText: 'Створити товар', showDefaultActions: false),
      body: Stack(
        children: [
          const LotexBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildPickedImage())
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.white70),
                                SizedBox(height: 8),
                                Text('Додати фото', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppInput(
                    label: LotexI18n.tr(lang, 'productName'),
                    controller: _titleController,
                    validator: (v) => (v == null || v.isEmpty) ? 'Введіть назву' : null,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: LotexI18n.tr(lang, 'description'),
                    controller: _descController,
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty) ? 'Введіть опис' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTypeId,
                      isExpanded: true,
                      items: roots.map((c) => DropdownMenuItem(value: c.id, child: Text(CategoryI18n.label(lang, c.id, fallback: c.name)))).toList(),
                      onChanged: (v) => setState(() { _selectedTypeId = v; _selectedSubtypeIds.clear(); }),
                    ),
                  ),
                  if (_selectedTypeId != null && subtypes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: subtypes.map((c) => FilterChip(
                        label: Text(CategoryI18n.label(lang, c.id, fallback: c.name)),
                        selected: _selectedSubtypeIds.contains(c.id),
                        onSelected: (on) => setState(() { on ? _selectedSubtypeIds.add(c.id) : _selectedSubtypeIds.remove(c.id); }),
                      )).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Ціна',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || double.tryParse(v.replaceAll(',', '.')) == null) ? 'Хибна ціна' : null,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: AppButton.primary(
          label: isLoading ? 'Створення...' : 'Виставити на продаж',
          onPressed: isLoading ? null : _submit,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _createSub.close();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
