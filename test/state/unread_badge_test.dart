import 'package:flutter_test/flutter_test.dart';
import 'package:si_land_client/state/unread_badge.dart';

void main() {
  test('unread badge clamps values and formats large counts', () {
    final badge = UnreadBadge();

    badge.setCount(-1);
    expect(badge.count, 0);

    badge.setCount(100);
    expect(badge.badgeLabel, '99+');
    badge.decrement();
    expect(badge.count, 99);
  });
}
