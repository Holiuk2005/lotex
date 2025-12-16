import 'dart:io'; // Потрібен для File
import 'package:flutter/foundation.dart'; // Потрібен для kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/widgets/theme_toggle.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/create_auction_controller.dart';
import '../widgets/lotex_input.dart';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() => _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _dateController = TextEditingController();
  
  DateTime? _selectedDate;
  XFile? _pickedImage;
  // Ми прибрали _pickedImageBytes, бо він тут не потрібен для відображення

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
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateController.text = DateFormat('dd.MM.yyyy HH:mm').format(_selectedDate!);
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Додайте фото')));
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оберіть дату')));
        return;
      }

      ref.read(createAuctionControllerProvider.notifier).create(
        title: _titleController.text,
        description: _descController.text,
        startPrice: double.parse(_startPriceController.text),
        endDate: _selectedDate!,
        image: _pickedImage!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(createAuctionControllerProvider, (prev, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Лот створено!'), backgroundColor: AppColors.success),
          );
          context.go('/home');
        },
        error: (e, st) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Помилка: $e'), backgroundColor: AppColors.error),
        ),
        loading: () {},
      );
    });

    final isLoading = ref.watch(createAuctionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text("Створити лот"), actions: const [ThemeToggle()]),
      body: SingleChildScrollView(
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
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // --- ОСЬ ТУТ ГОЛОВНЕ ВИПРАВЛЕННЯ ---
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.network(
                                  _pickedImage!.path, // На Web path працює як посилання
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_pickedImage!.path), // На телефоні це шлях до файлу
                                  fit: BoxFit.cover,
                                ),
                        )
                  // ------------------------------------
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary600),
                            Text("Додати фото"),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              LotexInput(
                label: "Назва",
                hint: "iPhone 15...",
                controller: _titleController,
                validator: (v) => v!.isEmpty ? "Введіть назву" : null,
              ),
              const SizedBox(height: 16),
              LotexInput(
                label: "Опис",
                hint: "Деталі...",
                maxLines: 4,
                controller: _descController,
                validator: (v) => v!.isEmpty ? "Введіть опис" : null,
              ),
              const SizedBox(height: 16),
              LotexInput(
                label: "Початкова ціна",
                hint: "0.0",
                controller: _startPriceController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Введіть початкову ціну';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null) return 'Некоректна ціна';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                    labelText: 'Дата завершення',
                    suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDateTime,
                validator: (v) => v == null || v.isEmpty ? 'Оберіть дату' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Text('СТВОРИТИ ЛОТ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startPriceController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}