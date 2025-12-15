import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_text_styles.dart'; // unused
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
        image: File(_pickedImage!.path),
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
      appBar: AppBar(title: const Text("Створити лот")),
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
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                        )
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
              ),
              const SizedBox(height: 16),
              LotexInput(
                label: "Стартова ціна",
                hint: "₴ 0",
                keyboardType: TextInputType.number,
                controller: _startPriceController,
                validator: (v) => v!.isEmpty ? "Вкажіть ціну" : null,
              ),
              const SizedBox(height: 16),
              LotexInput(
                label: "Дата завершення",
                hint: "Оберіть...",
                readOnly: true,
                controller: _dateController,
                onTap: _pickDateTime,
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) 
                  : const Text("ОПУБЛІКУВАТИ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}