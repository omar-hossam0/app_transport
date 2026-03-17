# تحسين الانيمشنات والتنقل بين الصفحات

تم تطبيق نظام انيمشن محسّن لتوفير انتقالات سلسة وجميلة بين الصفحات.

## الملفات المضافة

### 1. **lib/services/page_transition.dart**

يحتوي على فئة `PageTransition` بعدة خيارات للانيمشن:

- `slideInUp`: انيمشن من الأسفل مع fade
- `zoomIn`: تكبير مع fade
- `slideInRight`: من اليمين مع fade
- `rotateIn`: دوران مع تكبير و fade

ويحتوي أيضاً على `AnimatedPageSwitcher` للتبديل السلس بين الصفحات.

### 2. **lib/services/smooth_navigation.dart**

فئة helper للتنقل بين الصفحات:

- `slideUp()`: للتنقل مع انيمشن slide up
- `zoomIn()`: للتنقل مع انيمشن zoom
- `slideRight()`: للتنقل مع انيمشن slide from right
- `rotateIn()`: للتنقل مع انيمشن rotate

### 3. **lib/widgets/smooth_page_wrapper.dart**

- `SmoothPageWrapper`: wrapper للصفحات يطبق الانيمشن تلقائياً
- `OptimizedPage`: صفحة محسنة مع انيمشنات أفضل

## التحسينات المطبقة في home_page.dart

1. استبدال `AnimatedSwitcher` القديم بـ `AnimatedPageSwitcher` المحسّن
2. تحسين مدة الانيمشن من 500ms إلى 400ms
3. استخدام `SmoothNavigation` للتنقل بين صفحات التفاصيل

## كيفية الاستخدام

### مثال 1: التنقل إلى صفحة جديدة

```dart
import 'package:app_transport/services/smooth_navigation.dart';

// التنقل مع انيمشن slide up
SmoothNavigation.slideUp(
  context,
  (context) => const YourPage(),
  routeName: 'your_page',
);

// التنقل مع انيمشن zoom
SmoothNavigation.zoomIn(
  context,
  (context) => const YourPage(),
);

// التنقل مع انيمشن slide من اليمين
SmoothNavigation.slideRight(
  context,
  (context) => const YourPage(),
);
```

### مثال 2: استخدام SmoothPageWrapper

```dart
import 'package:app_transport/widgets/smooth_page_wrapper.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SmoothPageWrapper(
      backgroundColor: Colors.white,
      child: Scaffold(
        // محتوى الصفحة
      ),
    );
  }
}
```

### مثال 3: استخدام PageTransition مباشرة

```dart
import 'package:app_transport/services/page_transition.dart';

Navigator.of(context).push(
  PageTransition.slideInUp(
    builder: (context) => const YourPage(),
    settings: 'your_page',
  ),
);
```

## خيارات الانيمشن المتاحة

| الانيمشن       | الوصف                           | المدة الافتراضية |
| -------------- | ------------------------------- | ---------------- |
| `slideInUp`    | انزلاق من الأسفل مع fade تدريجي | 450ms            |
| `zoomIn`       | تكبير من صغير إلى طبيعي مع fade | 400ms            |
| `slideInRight` | انزلاق من اليمين مع fade        | 450ms            |
| `rotateIn`     | دوران مع تكبير و fade           | 500ms            |

## نصائح الأداء

1. **استخدم `AnimatedPageSwitcher` للصفحات المتكررة** مثل الـ bottom navigation
2. **استخدم `SmoothNavigation` للصفحات البديلة** (الموارد، الإعدادات، إلخ)
3. **تجنب الانيمشنات الطويلة جداً** - استخدم 300-500ms للأداء الأفضل
4. **استخدم `SmoothPageWrapper` في الصفحات الثقيلة** للتحسين تلقائي

## ملاحظات مهمة

- تم تحسين مدة الانيمشن لـ `AnimatedPageSwitcher` من 500ms إلى 400ms
- جميع الانيمشنات تستخدم `Curves.easeOutCubic` للسلاسة
- الانيمشن المعكوس أسرع من الأمامي (300-350ms) للشعور بالاستجابة السريعة

## التحديثات المستقبلية

قد تحتاج إلى تطبيق هذه التحسينات على الصفحات الأخرى:

- [x] home_page.dart (تم)
- [ ] flying_taxi_page.dart
- [ ] transit_trips_page.dart
- [ ] my_bookings_page.dart
- [ ] chatbot_page.dart
- [ ] profile_page.dart
- [ ] flying_taxi_detail.dart (إن وجدت)
