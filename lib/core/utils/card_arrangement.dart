List<T>? arrangeCardInSlots<T>({
  required List<T> current,
  required T card,
  required int slotIndex,
  required int capacity,
}) {
  if (capacity <= 0 || slotIndex < 0 || slotIndex >= capacity) return null;

  final next = List<T>.of(current);
  final sourceIndex = next.indexOf(card);

  if (sourceIndex >= 0) {
    if (sourceIndex == slotIndex) return next;
    if (slotIndex < next.length) {
      final replaced = next[slotIndex];
      next[slotIndex] = card;
      next[sourceIndex] = replaced;
      return next;
    }

    next.removeAt(sourceIndex);
    next.add(card);
    return next;
  }

  if (next.length >= capacity) return null;
  final insertionIndex = slotIndex.clamp(0, next.length);
  next.insert(insertionIndex, card);
  return next;
}

bool isCardArrangementReady({required int cardCount, required int capacity}) =>
    capacity > 0 && cardCount == capacity;
