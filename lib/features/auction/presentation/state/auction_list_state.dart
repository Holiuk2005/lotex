import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auction_entity.dart';

part 'auction_list_state.freezed.dart';

@freezed
class AuctionListState with _$AuctionListState {
  const factory AuctionListState.initial() = AuctionListInitial;
  const factory AuctionListState.loading() = AuctionListLoading;
  const factory AuctionListState.success({
    required List<AuctionEntity> items,
    required bool hasMore,
    @Default(false) bool isFetchingMore,
  }) = AuctionListSuccess;
  const factory AuctionListState.error({required Object error}) =
      AuctionListError;
}
