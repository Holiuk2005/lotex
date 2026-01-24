# Copilot / AI агент — быстрый вход в проект

Коротко: это Flutter-приложение с backend'ом на Firebase (Auth, Firestore, Storage, Functions). Ниже — сжатые, практичные указания для AI-ассистента, чтобы быстро стать продуктивным в кодовой базе.

1) Большая картина
- Frontend: Flutter (Riverpod, собственный роутер) — точка входа: [lib/main.dart](lib/main.dart#L1-L40). UI/фичи организованы под каталогом `lib/features` и `lib/services`.
- Backend: Firebase — клиентская и серверная логика: Firestore, Auth, Storage и Cloud Functions. Серверные функции — в [functions/index.js](functions/index.js#L1-L40) (используется firebase-functions v2, `onCall`, `onSchedule`, `onDocument*`).
- Конфиг и правила: `firebase.json`, `firebase.flutter.json`, `firestore.rules`, `storage.rules`, `firestore.indexes.json`.

2) Как проект интегрируется (важно)
- Firebase опции генерируются в `lib/firebase_options.dart` (FlutterFire) — не редактировать вручную.
- В `lib/main.dart` при старте вызывается `Firebase.initializeApp` и явно отключена локальная persistence для Firestore: `Settings(persistenceEnabled: false)` — это намеренное поведение при хотрестартах/мультивкладках.
- Для локальной разработки есть поддержка эмуляторов (Auth/Firestore/Storage/Functions). Код использует compile-time флаги: `USE_FIREBASE_EMULATORS` и `USE_AUTH_EMULATOR` (см. `lib/main.dart`).

3) Основные команды (конкретные примеры)
- Запуск локальных Firebase-эмуляторов (есть VSCode task):
  - `firebase emulators:start --only 'auth,firestore,storage,functions'`
- Запуск Flutter в браузере с эмуляторами:
  - `flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=USE_AUTH_EMULATOR=true`
  (в проекте VSCode task `Flutter: Run Chrome (use emulators)` уже задаёт `CHROME_EXECUTABLE` и флаги)
- Деплой правил/индексов/сторедж: `firebase deploy --only firestore:rules,firestore:indexes,storage`
- Деплой функций: `firebase deploy --only functions`
- Тесты (юнит/виджеты): `flutter test`
- Интеграционные тесты: `flutter test integration_test` (папка: `integration_test/`)

4) Особенности кода и конвенции
- State management: `flutter_riverpod` — приложение запускается внутри `ProviderScope` (см. `lib/main.dart`). Ищите провайдеры в `lib/core` и `lib/features`.
- Маршрутизация: собственный роутер в `lib/core/router/app_router.dart` — изменение навигации там повлияет глобально.
- i18n: используется `intl` + локальные провайдеры в `lib/core/i18n`.
- Backend patterns: функции используют `admin.firestore()` и транзакции (см. `functions/index.js` — пример `purchaseTicket` и `createOrderPayment`). Функции часто валидируют вход и бросают `HttpsError`.
- Секреты: в `functions/index.js` используются `defineSecret('NAME')` — секреты нужно настраивать через Firebase console / `firebase functions:secrets`.

5) Что важно для патчей/PR
- Не менять `lib/firebase_options.dart` вручную — регенерируется FlutterFire.
- Изменения в `firestore.rules`/`storage.rules` тестировать на эмуляторе перед деплоем.
- Cloud Functions: следите за используемыми API (v2) и объявленными секретами; локальное тестирование — через эмуляторы.

6) Быстрые ориентиры (файлы для поиска)
- Точка входа: [lib/main.dart](lib/main.dart#L1-L40)
- Firebase клиентские опции: [lib/firebase_options.dart](lib/firebase_options.dart#L1-L40)
- Cloud Functions: [functions/index.js](functions/index.js#L1-L40)
- Правила/индексы: `firestore.rules`, `firestore.indexes.json`, `storage.rules`
- CI / задачи запуска: посмотреть VSCode tasks в рабочей папке (задачи с метками `Firebase` / `Flutter`).

7) Частые места для изменений/исследований
- Добавление новой серверной логики → `functions/index.js` (+ `functions/package.json`).
- Добавление экранов или фич → `lib/features/<feature>` и подключение провайдера/роутера.
- Изменения безопасности → `firestore.rules` и проверка в эмуляторе.

8) Ограничения и заметки
- Offline-поведение Firestore глобально отключено (см. main). Не предполагать кеширование на клиенте.
- Сгенерированные файлы находятся в `build/` — их редактировать не нужно.

Если что-то в этой инструкции неполно или нужно добавить примеры кода для конкретной задачи — скажите, добавлю и уточню.

9) Примеры паттернов (из кода)
- Проверка аутентификации во `functions`: используйте `requireAuth(request)` или `requireAdmin(request)` перед выполнением логики. См. [functions/index.js](functions/index.js#L1-L40).
- Обработка ошибок в функциях: бросайте `new HttpsError('<code>', 'message')` для корректных client-side сообщений и кода ошибки.
- Транзакции: серверные операции с несколькими документами выполняются через `db.runTransaction(async (tx) => { ... })` (пример: `purchaseTicket`).
- Работа с секретами: объявлены через `defineSecret('NAME')` и подключаются к вызову `onCall(..., { secrets: [STRIPE_SECRET_KEY] })`.
- Утилиты: в `functions/index.js` есть маленькие вспомогательные функции `toNumber`, `toMinorUnits`, `pickUserCityRef` — используйте аналогичный стиль (небольшие чистые функции, видно в коде).
- Клиентский bootstrap: в `lib/main.dart` — `ProviderScope`, `Firebase.initializeApp`, и принудительное отключение offline persistence: `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);`.

10) PR / Deploy checklist (коротко)
- Локально: запустите эмуляторы перед изменением правил/функций:
```powershell
firebase emulators:start --only 'auth,firestore,storage,functions'
```
- UI / feature: запускать `flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=USE_AUTH_EMULATOR=true` для интеграции с эмуляторами.
- Тесты: `flutter test` и, при необходимости, `flutter test integration_test`.
- Правила Firestore/Storage: тестировать изменения на эмуляторе, затем деплоить `firebase deploy --only firestore:rules,firestore:indexes,storage`.
- Функции: для деплоя `firebase deploy --only functions`. Убедитесь, что секреты объявлены в коде и настроены в Firebase (`firebase functions:secrets` / консоль).
- PR description: укажите затронутые части — `functions`, `firestore.rules`, `lib/features/<feature>`, и тестовую инструкцию для ревьюера (как поднять эмуляторы + какие сценарии проверить).

11) Часто задаваемые уточнения для AI-ассистента
- Никогда не менять `lib/firebase_options.dart` вручную.
- Dev-опыт ожидает, что эмуляторы включают Auth — иначе многие запросы будут получать `permission-denied`.
- UI-локализация использует `intl` — изменения в строках нужно синхронизировать с i18n-провайдерами в `lib/core/i18n`.

Спасибо — дайте знать, какие конкретные участки кода добавить в примеры (функция/экран/роут), и я расширю инструкцию.
