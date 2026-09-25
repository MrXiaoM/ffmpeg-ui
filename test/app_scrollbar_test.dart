import 'package:ffmpeg_ui/shared/ui/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('layoutAppScrollbar', () {
    test('thumb sits at the top of the track at min extent', () {
      final metrics = layoutAppScrollbar(
        size: const Size(appScrollbarGutter, 400),
        pixels: 0,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
        viewportDimension: 400,
        thickness: appScrollbarThickness,
      );
      expect(metrics.thumbRect.top, metrics.trackRect.top);
      expect(
        metrics.hitTest(Offset(appScrollbarGutter / 2, metrics.trackRect.top)),
        AppScrollbarHit.thumb,
      );
      expect(
        metrics.hitTest(const Offset(appScrollbarGutter / 2, 0)),
        AppScrollbarHit.none,
      );
    });

    test('top track click maps to min extent instead of paging down', () {
      final metrics = layoutAppScrollbar(
        size: const Size(appScrollbarGutter, 400),
        pixels: 600,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
        viewportDimension: 400,
        thickness: appScrollbarThickness,
      );
      expect(
        metrics.hitTest(Offset(appScrollbarGutter / 2, metrics.trackRect.top + 2)),
        AppScrollbarHit.track,
      );
      expect(
        metrics.pixelsForTrackOffset(metrics.trackRect.top),
        0,
      );
    });

    test('track click near the bottom maps to max extent', () {
      final metrics = layoutAppScrollbar(
        size: const Size(appScrollbarGutter, 400),
        pixels: 0,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
        viewportDimension: 400,
        thickness: appScrollbarThickness,
      );
      expect(
        metrics.pixelsForTrackOffset(metrics.trackRect.bottom),
        1000,
      );
    });
  });

  test('wheel deltas accumulate from the pending target', () {
    expect(
      accumulateSmoothScrollTarget(
        pixels: 0,
        pendingTarget: null,
        delta: 120,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
      ),
      120,
    );
    expect(
      accumulateSmoothScrollTarget(
        pixels: 40,
        pendingTarget: 120,
        delta: 120,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
      ),
      240,
    );
    expect(
      accumulateSmoothScrollTarget(
        pixels: 900,
        pendingTarget: 980,
        delta: 120,
        minScrollExtent: 0,
        maxScrollExtent: 1000,
      ),
      1000,
    );
  });

  testWidgets('mouse wheel animates instead of jumping a whole notch', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(
        ListView(
          controller: controller,
          children: [
            for (var i = 0; i < 40; i++)
              SizedBox(height: 48, child: Text('item $i')),
          ],
        ),
      ),
    );
    await tester.sendEventToBinding(
      PointerScrollEvent(
        kind: PointerDeviceKind.mouse,
        position: tester.getCenter(find.byType(ListView)),
        scrollDelta: const Offset(0, 240),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(controller.offset, greaterThan(0));
    expect(controller.offset, lessThan(240));
    await tester.pump(appSmoothScrollDuration);
    expect(controller.offset, 240);
  });

  testWidgets('nested lists give the wheel to the inner scroller first', (
    tester,
  ) async {
    final outer = ScrollController();
    final inner = ScrollController();
    addTearDown(outer.dispose);
    addTearDown(inner.dispose);
    await tester.pumpWidget(
      _wrap(
        ListView(
          controller: outer,
          children: [
            SizedBox(
              height: 180,
              child: ListView(
                controller: inner,
                children: [
                  for (var i = 0; i < 30; i++)
                    SizedBox(height: 40, child: Text('inner $i')),
                ],
              ),
            ),
            for (var i = 0; i < 30; i++)
              SizedBox(height: 80, child: Text('outer $i')),
          ],
        ),
      ),
    );
    expect(find.byType(AppScrollbar), findsNWidgets(2));
    expect(inner.position.maxScrollExtent, greaterThan(0));
    await tester.sendEventToBinding(
      PointerScrollEvent(
        kind: PointerDeviceKind.mouse,
        position: tester.getCenter(find.text('inner 0')),
        scrollDelta: const Offset(0, 120),
      ),
    );
    await tester.pump();
    await tester.pump(appSmoothScrollDuration);
    expect(
      (inner: inner.offset, outer: outer.offset),
      (inner: 120, outer: 0),
    );
  });

  testWidgets('track click near the top scrolls to min extent', (tester) async {
    final controller = ScrollController(initialScrollOffset: 600);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(
        ListView(
          controller: controller,
          children: [
            for (var i = 0; i < 40; i++)
              SizedBox(height: 80, child: Text('item $i')),
          ],
        ),
      ),
    );
    expect(controller.offset, 600);
    await tester.pump();
    await tester.tapAt(const Offset(313, 6));
    await tester.pump();
    await tester.pump(appSmoothScrollDuration);
    expect(controller.offset, 0);
  });

  testWidgets('hides the bar when content does not overflow', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: const [SizedBox(height: 40, child: Text('only'))],
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(ListView)).width, 320);
  });

  testWidgets('non-scrollable wrap content does not create extra bars', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: const [
            Wrap(
              children: [
                SizedBox(width: 80, height: 80, child: Text('a')),
                SizedBox(width: 80, height: 80, child: Text('b')),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(AppScrollbar), findsOneWidget);
  });

  testWidgets('hides the bar for never-scrollable nested grids', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListView(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: const [
                SizedBox(height: 40, child: Text('a')),
                SizedBox(height: 40, child: Text('b')),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(find.text('a'), findsOneWidget);
    expect(tester.getSize(find.byType(GridView)).width, 320);
  });

  test('metrics report not scrollable when content fits', () {
    final metrics = layoutAppScrollbar(
      size: const Size(appScrollbarGutter, 400),
      pixels: 0,
      minScrollExtent: 0,
      maxScrollExtent: 0,
      viewportDimension: 400,
      thickness: appScrollbarThickness,
    );
    expect(metrics.canScroll, isFalse);
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    scrollBehavior: const AppScrollBehavior(),
    home: Scaffold(
      body: SizedBox(width: 320, height: 240, child: child),
    ),
  );
}
