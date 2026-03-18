// ═══════════════════════════════════════════════════════════════════════════════
// دليل التطبيق - أمثلة عملية للانيمشنات
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:app_transport/services/smooth_navigation.dart';
import 'package:app_transport/services/page_transition.dart';
import 'package:app_transport/widgets/smooth_page_wrapper.dart';

// مثال 1: استخدام SmoothNavigation في صفحة
// ══════════════════════════════════════════════════════════════════════════════

class ExamplePage1 extends StatelessWidget {
  const ExamplePage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 1')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // التنقل مع انيمشن Slide Up
            SmoothNavigation.slideUp(
              context,
              (context) => const NextPage(),
              routeName: 'next_page_1',
            );
          },
          child: const Text('Navigate with Slide Up'),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

// مثال 2: استخدام أنواع مختلفة من الانيمشنات
// ══════════════════════════════════════════════════════════════════════════════

class ExamplePage2 extends StatelessWidget {
  const ExamplePage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 2')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                SmoothNavigation.slideUp(
                  context,
                  (context) => const NextPage(),
                  routeName: 'next_slide_up',
                );
              },
              child: const Text('Slide Up'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SmoothNavigation.zoomIn(
                  context,
                  (context) => const NextPage(),
                  routeName: 'next_zoom_in',
                );
              },
              child: const Text('Zoom In'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SmoothNavigation.slideRight(
                  context,
                  (context) => const NextPage(),
                  routeName: 'next_slide_right',
                );
              },
              child: const Text('Slide Right'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SmoothNavigation.rotateIn(
                  context,
                  (context) => const NextPage(),
                  routeName: 'next_rotate_in',
                );
              },
              child: const Text('Rotate In'),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

// مثال 3: استخدام في قائمة (List)
// ══════════════════════════════════════════════════════════════════════════════

class ExamplePage3 extends StatelessWidget {
  const ExamplePage3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = ['Item 1', 'Item 2', 'Item 3', 'Item 4'];

    return Scaffold(
      appBar: AppBar(title: const Text('Example 3')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            onTap: () {
              // التنقل مع انيمشن Zoom In
              SmoothNavigation.zoomIn(
                context,
                (context) => DetailPage(item: items[index]),
                routeName: 'detail_${items[index]}',
              );
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

// مثال 4: استخدام في Grid
// ══════════════════════════════════════════════════════════════════════════════

class ExamplePage4 extends StatelessWidget {
  const ExamplePage4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(12, (i) => 'Item ${i + 1}');

    return Scaffold(
      appBar: AppBar(title: const Text('Example 4')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              SmoothNavigation.slideRight(
                context,
                (context) => DetailPage(item: items[index]),
                routeName: 'detail_${items[index]}',
                duration: const Duration(milliseconds: 400),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(items[index])),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

// مثال 5: استخدام PageTransition مباشرة (متقدم)
// ══════════════════════════════════════════════════════════════════════════════

class ExamplePage5 extends StatelessWidget {
  const ExamplePage5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example 5')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              PageTransition.rotateIn(
                builder: (context) => const NextPage(),
                settings: 'next_page_rotate',
                duration: const Duration(milliseconds: 500),
              ),
            );
          },
          child: const Text('Advanced Rotate Animation'),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

// مثال 6: استخدام SmoothPageWrapper
// ══════════════════════════════════════════════════════════════════════════════

class ExamplePage6 extends StatelessWidget {
  const ExamplePage6({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmoothPageWrapper(
      backgroundColor: Colors.white,
      child: Scaffold(
        appBar: AppBar(title: const Text('Example 6')),
        body: Center(child: const Text('Page content here')),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════

// الصفحات المساعدة
// ══════════════════════════════════════════════════════════════════════════════

class NextPage extends StatelessWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => SmoothNavigation.pop(context),
        ),
      ),
      body: const Center(child: Text('Next Page Content')),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String item;

  const DetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: $item'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => SmoothNavigation.pop(context),
        ),
      ),
      body: Center(child: Text('Details for $item')),
    );
  }
}
