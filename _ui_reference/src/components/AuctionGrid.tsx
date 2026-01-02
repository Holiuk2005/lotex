import React from 'react';
import { AuctionCard } from './AuctionCard';
interface AuctionGridProps {
  items: any[];
  onSelect?: (item: any) => void;
}
export function AuctionGrid({
  items,
  onSelect
}: AuctionGridProps) {
  return <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      {items.map(item => <div key={item.id} onClick={() => onSelect && onSelect(item)} className={onSelect ? 'cursor-pointer' : ''}>
          <AuctionCard {...item} />
        </div>)}
    </div>;
}