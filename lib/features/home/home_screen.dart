import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lotex/core/utils/human_error.dart';
import 'package:lotex/core/theme/lotex_ui_tokens.dart';
import 'package:lotex/core/widgets/lotex_app_bar.dart';
import 'package:lotex/core/widgets/lotex_background.dart';
import 'package:lotex/features/auction/presentation/providers/auction_list_provider.dart';
import 'package:lotex/features/auction/presentation/widgets/auction_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _filter = 'live';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

    final auctionsAsync = ref.watch(auctionListProvider);

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
              _FilterRow(
                selected: _filter,
                onSelected: (v) => setState(() => _filter = v),
              ),
              const SizedBox(height: 16),
              auctionsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text('Помилка: ${humanError(e)}', style: Theme.of(context).textTheme.bodyMedium),
                ),
                data: (list) {
                  final now = DateTime.now();

                  final filtered = switch (_filter) {
                    'ended' => list.where((a) => a.endDate.isBefore(now)).toList(),
                    'upcoming' => list.where((_) => false).toList(),
                    _ => list.where((a) => a.endDate.isAfter(now)).toList(),
                  };

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        'Немає лотів для цього фільтра',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: LotexUiColors.slate400),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (crossAxisCount == 1) {
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final auction = filtered[index];
                        return AuctionCard(
                          auction: auction,
                          onTap: () => context.push('/auction', extra: auction),
                        );
                      },
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // Taller tiles to fit AuctionCard content without RenderFlex overflow.
                      childAspectRatio: crossAxisCount == 2 ? 0.58 : 0.55,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final auction = filtered[index];
                      return AuctionCard(
                        auction: auction,
                        onTap: () => context.push('/auction', extra: auction),
                      );
                    },
                  );
                },
              ),
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
        Text('Discover Rare', style: titleStyle),
        const SizedBox(height: 2),
        ShaderMask(
          shaderCallback: (rect) => LotexUiGradients.heroText.createShader(rect),
          blendMode: BlendMode.srcIn,
          child: Text('Digital Artifacts', style: titleStyle),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('live', 'Live Auctions'),
      ('upcoming', 'Upcoming'),
      ('ended', 'Ended'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.05 * 255).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((0.10 * 255).round())),
            ),
            child: const Icon(Icons.tune, color: LotexUiColors.slate400, size: 20),
          ),
          const SizedBox(width: 12),
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
