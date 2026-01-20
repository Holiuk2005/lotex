import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/core/i18n/language_provider.dart';
import 'package:lotex/core/i18n/lotex_i18n.dart';
import 'package:lotex/core/i18n/category_i18n.dart';
import 'package:lotex/features/auction/domain/entities/auction_entity.dart';
import 'package:lotex/features/auction/presentation/widgets/auction_card.dart';
import 'package:lotex/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:lotex/features/notifications/presentation/providers/notifications_providers.dart';
import 'package:lotex/features/home/models/filter_state.dart';
import 'package:lotex/features/home/widgets/filter_bottom_sheet.dart';
import 'package:lotex/services/category_seed_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _filter = 'live';
  FilterState _filters = const FilterState();

  static const double _minPrice = 0;
  static const double _maxPrice = 100000;

  List<String> _effectiveCategoryIds() {
    final selectedType = _filters.selectedType;
    final selectedSubtypes = _filters.selectedSubtypes;

    if (selectedType == null) {
      return selectedSubtypes;
    }

    if (selectedSubtypes.isNotEmpty) {
      return selectedSubtypes;
    }

    final children = CategoryI18n.childrenOf(CategorySeedService.categories, selectedType);
    return children.map((c) => c.id).toList(growable: false);
  }

  Query<Map<String, dynamic>> getFilteredQuery() {
    final hasPriceFilter = _filters.priceRange.start > _minPrice || _filters.priceRange.end < _maxPrice;

    Query<Map<String, dynamic>> q = FirebaseFirestore.instance.collection('auctions');

    final categoryIds = _effectiveCategoryIds();
    if (categoryIds.isNotEmpty) {
      final ids = categoryIds.take(10).toList(growable: false);
      if (ids.length == 1) {
        final id = ids.first;
        q = q.where(
          Filter.or(
            Filter('category', isEqualTo: id),
            Filter('categoryIds', arrayContains: id),
          ),
        );
      } else {
        q = q.where(
          Filter.or(
            Filter('category', whereIn: ids),
            Filter('categoryIds', arrayContainsAny: ids),
          ),
        );
      }
    }

    if (hasPriceFilter) {
      q = q
          .where('currentPrice', isGreaterThanOrEqualTo: _filters.priceRange.start)
          .where('currentPrice', isLessThanOrEqualTo: _filters.priceRange.end);
    }

    // Firestore constraint: if you use range filters (>= / <=) on a field,
    // the first orderBy must be on that same field.
    switch (_filters.sortBy) {
      case 'price_asc':
        q = q.orderBy('currentPrice').orderBy('createdAt', descending: true);
        break;
      case 'price_desc':
        q = q.orderBy('currentPrice', descending: true).orderBy('createdAt', descending: true);
        break;
      case 'newest':
      default:
        q = hasPriceFilter
            ? q.orderBy('currentPrice').orderBy('createdAt', descending: true)
            : q.orderBy('createdAt', descending: true);
        break;
    }

    return q;
  }

  String? _selectedCategoryLabel(LotexLanguage lang) {
    final ids = _effectiveCategoryIds();
    if (ids.isEmpty) return null;

    if (ids.length == 1) {
      return CategoryI18n.label(lang, ids.first);
    }

    return '${CategoryI18n.label(lang, ids.first)} +${ids.length - 1}';
  }

  Future<void> _openFilterSheet() async {
    final selected = await showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark
            ? LotexUiColors.slate950.withAlpha((0.92 * 255).round())
            : Theme.of(context).colorScheme.surface;

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
          ),
          child: FilterBottomSheet(
            initial: _filters,
            categories: CategorySeedService.categories,
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    setState(() => _filters = selected);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(lotexLanguageProvider);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

    final categoryLabel = _selectedCategoryLabel(lang);

    return Scaffold(
      appBar: const LotexAppBar(showDesktopSearch: true, showThemeToggle: false),
      body: Stack(
        children: [
          const LotexBackground(),
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
            children: [
              const _HeroBlock(),
              const SizedBox(height: 18),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getFilteredQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Помилка: ${humanError(snapshot.error ?? Exception('Unknown error'))}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final list = snapshot.data!.docs
                      .map((d) => AuctionEntity.fromDocument(d))
                      .toList(growable: false);

                  final now = DateTime.now();
                  final filteredByTime = switch (_filter) {
                    'ended' => list.where((a) => a.endDate.isBefore(now)).toList(growable: false),
                    'upcoming' => list.where((_) => false).toList(growable: false),
                    _ => list.where((a) => a.endDate.isAfter(now)).toList(growable: false),
                  };

                  final user = ref.watch(currentUserProvider);
                  final subs = ref.watch(subscribedCategoriesProvider).valueOrNull ?? <String>{};
                  final effectiveIds = _effectiveCategoryIds();
                  final selectedCategoryId = effectiveIds.length == 1 ? effectiveIds.first : null;
                  final isSubscribed = selectedCategoryId != null && subs.contains(selectedCategoryId);

                  final filterRow = _FilterRow(
                    lang: lang,
                    selected: _filter,
                    onSelected: (v) => setState(() => _filter = v),
                    onOpenFilters: _openFilterSheet,
                    categoryLabel: categoryLabel,
                    categoryAction: (selectedCategoryId == null || user == null)
                        ? null
                        : IconButton(
                            tooltip: isSubscribed
                                ? 'Вимкнути сповіщення по категорії'
                                : 'Увімкнути сповіщення по категорії',
                            onPressed: () async {
                              final repo = ref.read(notificationsRepositoryProvider);
                              await repo.setCategorySubscription(
                                uid: user.uid,
                                category: selectedCategoryId,
                                subscribed: !isSubscribed,
                              );
                            },
                            icon: Icon(
                              isSubscribed
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                              color: Colors.white.withAlpha((0.80 * 255).round()),
                            ),
                          ),
                  );

                  final content = filteredByTime.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Text(
                            LotexI18n.tr(lang, 'noAuctionsFound'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: LotexUiColors.slate400),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : (crossAxisCount == 1
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredByTime.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final auction = filteredByTime[index];
                                return AuctionCard(
                                  auction: auction,
                                  onTap: () => context.push('/auction', extra: auction),
                                );
                              },
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: crossAxisCount == 2 ? 0.58 : 0.55,
                              ),
                              itemCount: filteredByTime.length,
                              itemBuilder: (context, index) {
                                final auction = filteredByTime[index];
                                return AuctionCard(
                                  auction: auction,
                                  onTap: () => context.push('/auction', extra: auction),
                                );
                              },
                            ));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filterRow,
                      const SizedBox(height: 16),
                      content,
                    ],
                  );
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock();

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode == 'uk'
        ? LotexLanguage.uk
        : LotexLanguage.en;
    final titleStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          height: 1.05,
          color: Colors.white,
        ) ??
        const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          height: 1.05,
          color: Colors.white,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LotexI18n.tr(lang, 'discoverRare'), style: titleStyle),
        const SizedBox(height: 2),
        ShaderMask(
          shaderCallback: (rect) => LotexUiGradients.heroText.createShader(rect),
          blendMode: BlendMode.srcIn,
          child: Text(LotexI18n.tr(lang, 'digitalArtifacts'), style: titleStyle),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final LotexLanguage lang;
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onOpenFilters;
  final String? categoryLabel;
  final Widget? categoryAction;

  const _FilterRow({
    required this.lang,
    required this.selected,
    required this.onSelected,
    this.onOpenFilters,
    this.categoryLabel,
    this.categoryAction,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('live', LotexI18n.tr(lang, 'liveAuctions')),
      ('upcoming', LotexI18n.tr(lang, 'upcoming')),
      ('ended', LotexI18n.tr(lang, 'ended')),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onOpenFilters,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.05 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(Icons.tune, color: LotexUiColors.slate400, size: 20),
                  ),
                  if (categoryLabel != null)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: LotexUiColors.violet500,
                          shape: BoxShape.circle,
                          border: Border.all(color: LotexUiColors.slate950, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (categoryLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      categoryLabel!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: LotexUiColors.slate950,
                      ),
                    ),
                  ),
                  if (categoryAction != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.05 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha((0.10 * 255).round()),
                        ),
                      ),
                      child: Center(child: categoryAction!),
                    ),
                  ],
                ],
              ),
            ),
          ...tabs.map((t) {
            final isSelected = selected == t.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onSelected(t.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.white.withAlpha((0.05 * 255).round()),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withAlpha((0.10 * 255).round()),
                    ),
                  ),
                  child: Text(
                    t.$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isSelected ? LotexUiColors.slate950 : LotexUiColors.slate400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
