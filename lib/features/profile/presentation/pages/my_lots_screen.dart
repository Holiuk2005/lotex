/*
Розумію проблему. Коли AI-асистенту даєш завдання маленькими шматочками, іноді він губиться або генерує код, який важко інтегрувати, і здається, що "нічого не змінилось".

Давай спробуємо інший підхід. Я дам тобі один великий, комплексний промт. Він змусить AI написати повний код для двох ключових файлів: екрану Дашборду та віджета Картки Поїздки, разом із тестовими даними, щоб ти одразу побачив результат.

Інструкція:
Відкрий свій проєкт у VS Code.

Переконайся, що у тебе встановлені пакети google_fonts та flutter_svg (для іконок, якщо знадобляться) у pubspec.yaml.

Створи (або очисти) два файли:

lib/features/home/dashboard_screen.dart

lib/features/trips/widgets/trip_card.dart (створи папку widgets, якщо немає).

Відкрий чат свого AI-асистента (Copilot/Cursor) і встав туди весь текст нижче.

🚀 ПРОМТ ДЛЯ AI (Встав цей текст у чат):
Я хочу повністю реалізувати UI мобільного Дашборду та Картки поїздки для додатку "Lotex Trip Manager", базуючись на затвердженому дизайні.

Контекст Дизайну:

Тема: Використовуємо Material 3.

Primary колір: Глибокий Індиго (Color(0xFF2A226B)) - для заголовків, тексту.

Accent колір: Яскравий Бурштин (Color(0xFFF5A623)) - для кнопок дії, статусів "в процесі".

Фон: Світло-сірий (Color(0xFFF4F5F9)).

Картки: Білі (#FFFFFF) з радіусом 16px та дуже легкою тінню.

Шрифти: Використовуй GoogleFonts.inter.

Завдання 1: Створити модель даних та заглушки. Створи просту модель TripModel (id, origin, destination, time, date, status, price, clientName) і список із 3-х тестових поїздок прямо у файлі дашборду для демонстрації.

Завдання 2: Реалізувати віджет TripCard (файл lib/features/trips/widgets/trip_card.dart). Це має бути віджет, схожий на сучасний квиток.

Основа: Card (біла, радіус 16px, легка тінь), margin: EdgeInsets.only(bottom: 16). Внутрішній padding: 16.

Вміст розділений на 3 частини через Row:

Ліва (Час): Колонка. Час (великий, жирний, Індиго), Дата (сірий).

Центр (Маршрут): Візуалізація. Зверху іконка пін-дропа та місто відправлення. Знизу іконка пін-дропа та місто призначення. Між ними - вертикальна пунктирна або суцільна лінія кольору Індиго.

Права (Статус/Ціна): Колонка, вирівняна вправо. Зверху бейдж статусу (наприклад, якщо статус "В дорозі" - бурштиновий фон, білий текст). Знизу ціна (жирний текст).

Завдання 3: Реалізувати екран DashboardScreen (файл lib/features/home/dashboard_screen.dart). Використовуй SingleChildScrollView з Padding(all: 16). Структура колонки:

Кнопка швидкої дії: На всю ширину. Бурштиновий колір, висота ~56px, заокруглені кути. Текст: "Створити нову поїздку" з іконкою add.

SizedBox(height: 24).

Аналітичні картки: Row з двома картками.

Картка 1: Іконка авто (Індиго), текст "Активні поїздки", значення "3" (велике, Індиго).

Картка 2: Іконка грошей (Зелена), текст "Зароблено сьогодні", значення "₴ 4,500".

SizedBox(height: 24).

Секція "Поточні поїздки":

Заголовок "Поточні поїздки" (жирний, Індиго, H2 size).

Список карток TripCard, використовуючи тестові дані з Завдання 1. Використовуй ListView.builder з shrinkWrap: true та physics: NeverScrollableScrollPhysics().

Результат: Надай мені ПОВНИЙ код для двох файлів:

lib/features/trips/widgets/trip_card.dart

lib/features/home/dashboard_screen.dart (включно з моделлю даних та dummy даними всередині). Код має бути готовим до копіювання та запуску.
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';

class MyLotsScreen extends StatelessWidget {
  const MyLotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final muted = Theme.of(context).brightness == Brightness.dark
      ? LotexUiColors.darkMuted
      : LotexUiColors.lightMuted;

    return Scaffold(
      appBar: const LotexAppBar(
        showBack: true,
        showDesktopSearch: false,
        titleText: 'Мої лоти',
      ),
      body: uid == null
          ? Center(child: Text('Увійдіть в акаунт', style: LotexUiTextStyles.bodyRegular))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('auctions')
                  .where('sellerId', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Помилка: ${humanError(snapshot.error ?? Exception('Unknown error'))}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: LotexUiColors.violet600));
                }

                final sorted = snapshot.data!.docs.toList(growable: false);
                sorted.sort((a, b) {
                  DateTime at = DateTime.fromMillisecondsSinceEpoch(0);
                  DateTime bt = DateTime.fromMillisecondsSinceEpoch(0);

                  final aRaw = a.data()['createdAt'];
                  final bRaw = b.data()['createdAt'];
                  if (aRaw is Timestamp) at = aRaw.toDate();
                  if (bRaw is Timestamp) bt = bRaw.toDate();
                  return bt.compareTo(at);
                });

                final docs = sorted;
                if (docs.isEmpty) {
                  return Center(child: Text('У вас ще немає створених лотів', style: LotexUiTextStyles.bodyRegular));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final auction = AuctionEntity.fromDocument(doc);

                    return Material(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/auction', extra: auction),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: LotexUiColors.violet500.withAlpha((0.15 * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.gavel_rounded, color: LotexUiColors.violet600),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auction.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${auction.currentPrice.toStringAsFixed(0)} ₴',
                                      style: LotexUiTextStyles.bodyRegular.copyWith(color: muted),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: muted),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
