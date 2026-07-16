import 'package:flutter_test/flutter_test.dart';
import 'package:wicara_application_1/core/utils/card_arrangement.dart';

void main() {
  group('arrangeCardInSlots', () {
    test('inserts a new card into an open slot', () {
      final result = arrangeCardInSlots(
        current: ['Selamat'],
        card: 'pagi',
        slotIndex: 1,
        capacity: 3,
      );

      expect(result, ['Selamat', 'pagi']);
    });

    test('swaps two cards already placed on the board', () {
      final result = arrangeCardInSlots(
        current: ['pagi', 'Selamat', 'Pak'],
        card: 'Selamat',
        slotIndex: 0,
        capacity: 3,
      );

      expect(result, ['Selamat', 'pagi', 'Pak']);
    });

    test('rejects a pool card when every slot is full', () {
      final result = arrangeCardInSlots(
        current: ['Selamat', 'pagi', 'Pak'],
        card: 'Besok',
        slotIndex: 0,
        capacity: 3,
      );

      expect(result, isNull);
    });
  });

  test('answer is ready only when every slot is filled', () {
    expect(isCardArrangementReady(cardCount: 2, capacity: 3), isFalse);
    expect(isCardArrangementReady(cardCount: 3, capacity: 3), isTrue);
    expect(isCardArrangementReady(cardCount: 4, capacity: 3), isFalse);
  });
}
