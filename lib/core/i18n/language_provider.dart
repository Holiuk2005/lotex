import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'lotex_i18n.dart';

final lotexLanguageProvider = NotifierProvider<LotexLanguageController, LotexLanguage>(
	LotexLanguageController.new,
);

class LotexLanguageController extends Notifier<LotexLanguage> {
	@override
	LotexLanguage build() => LotexLanguage.uk;

	void set(LotexLanguage lang) => state = lang;
}
