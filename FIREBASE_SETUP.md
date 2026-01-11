# Firebase setup steps (manual)

> Я не можу “зайти в Firebase Console” замість тебе (немає доступу до акаунта/браузера),
> але можу підготувати все в репозиторії і дати точні кроки/команди для застосування.
# Firebase setup steps (manual)

> Я не можу “зайти в Firebase Console” замість тебе (немає доступу до акаунта/браузера),
> але можу підготувати все в репозиторії і дати точні кроки/команди для застосування.

## 0) Перевір, що проєкт існує

У цьому репозиторії вже є конфіг під проєкт `lotex-4890a` (див. `firebase.json` / `.firebaserc`).
Якщо ти працюєш з іншим Firebase проєктом — просто перегенеруй опції через FlutterFire CLI.

## 1) Локальна робота без консолі (Firebase Emulator Suite)

Ти можеш тестувати **Auth/Firestore/Storage/Functions** локально.

1) Встанови Firebase CLI (потрібен Node.js):

```bash
npm i -g firebase-tools
```

2) Один раз встанови залежності для Functions:

```bash
npm --prefix functions install
```

3) Запусти емулятори в корені проєкту:

```bash
firebase emulators:start --only auth,firestore,storage,functions
```

UI емуляторів відкриється на `http://localhost:4000`.

4) Запускай Flutter з прапорцем:

```bash
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

Примітки:
- На Android емуляторі хост буде `10.0.2.2` (в коді вже враховано).
- У цьому режимі дані НЕ зʼявляться у Firebase Console, бо це локальна база.

## 2) Згенерувати `firebase_options.dart`

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project "YOUR_FIREBASE_PROJECT_ID"
```

Це оновить `lib/firebase_options.dart` для потрібних платформ.

## 3) Увімкнути Firebase Authentication

У Firebase Console:

1. **Authentication → Sign-in method**
2. Увімкни мінімум:
	- **Email/Password** (для входу поштою)
	- **Google** (якщо хочеш Google Sign-In)
3. Для Web:
	- **Authentication → Settings → Authorized domains**
	- Додай домен, з якого запускаєш веб (для dev часто `localhost`).

Якщо Google Sign-In для Web не працює:
1. Переконайся, що в **Project settings → General → Your apps** створено **Web app**.
2. Перевір коректність OAuth Client ID.

## 4) Увімкнути Firestore та Storage

У Firebase Console:

- **Firestore Database** → Create database (Production або Test, але краще Production + rules)
- **Storage** → Get started

## 5) Задеплоїти правила та індекси з репозиторію

У репозиторії вже є:
- `firestore.rules`
- `storage.rules`
- `firestore.indexes.json`

Виконай:

```bash
firebase login
firebase use lotex-4890a
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## 6) Задеплоїти Cloud Functions (лотереї: покупка квитка/розіграш)

1) Встанови залежності функцій:

```bash
npm --prefix functions install
```

2) Деплой:

```bash
firebase deploy --only functions
```

Примітки:
- Локально callable функції доступні через Emulator Suite (порт 5001).
- У Flutter, коли `USE_FIREBASE_EMULATORS=true`, виклики `FirebaseFunctions` підуть в емулятор.

## 7) Admin доступ для `drawWinner`

Функція `drawWinner` вимагає custom claim `admin: true` у користувача.

У репозиторії є helper-скрипт (див. `scripts`):

```bash
npm --prefix scripts install

# Емулятор (без service account):
npm --prefix scripts run set:admin -- --uid YOUR_UID --emulator --project lotex-4890a

# Прод (потрібен GOOGLE_APPLICATION_CREDENTIALS до service account json):
npm --prefix scripts run set:admin -- --uid YOUR_UID --project lotex-4890a
```

## 8) CORS для Storage (потрібно для web upload)

Замінити `YOUR_BUCKET` на ім'я bucket'а (зазвичай `PROJECT_ID.appspot.com`).

```bash
gcloud auth login
gsutil cors set cors.json gs://YOUR_BUCKET
```

## 9) Що треба “створити” в Firestore

Колекції зазвичай створюються автоматично під час роботи застосунку.

Мінімально очікувано (старі фічі Lotex):
- `users/{uid}` — приватний профіль (owner-only)
- `public_profiles/{uid}` — публічний профіль (читання для всіх)
- `auctions/{auctionId}` — лоти

Lottery-модуль додатково:
- `lotteries/{lotteryId}` — лотереї (public read, admin write)
- `tickets/{ticketId}` — квитки (створюються тільки бекендом)
- `users/{uid}/tickets/{ticketId}` — mirror квитків для читання користувачем
- `users/{uid}/transactions/{txId}` — ledger (створюється бекендом)
- `bids/{bidId}` — ставки/бід (якщо використовуєш bidding-механіку)

Мінімальний приклад lottery-документа:
- `title`: string
- `description`: string
- `status`: 'active' | 'ended'
- `ticketPrice`: int (minor units)
- `currency`: string (наприклад 'UAH')
- `ticketsSold`: int
- `maxTickets`: int | null
- `endsAt`: Timestamp
- `createdAt`, `updatedAt`: Timestamp

## 10) Перевірка

1) Запусти: `flutter run -d chrome --web-port 5000`
2) Зареєструйся/увійди.
3) Перевір у Firebase Console:
	- Firestore: зʼявилися `users` / `public_profiles`
	- Storage: при створенні лоту з фото — зʼявився файл у відповідній папці

## Нотатки / troubleshooting

- Якщо ловиш CORS у браузері: звір `cors.json` з фактичним origin (протокол+порт).
- Для продакшну не використовуй "*" у CORS — додай конкретні домени.

## Швидкий локальний тест лотерей (емулятор)

1) `firebase emulators:start --only auth,firestore,storage,functions`
2) `flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true`
3) Створи lottery документ (поки що вручну через Emulator UI або адмін-клієнт)
4) Поповни `users/{uid}.balance` (через Emulator UI або через адмін-скрипт)
5) Виклич покупку квитка через Flutter (callable `purchaseTicket`)
