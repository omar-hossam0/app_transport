import 'package:flutter/material.dart';

class UiTranslation {
  static bool containsArabic(String value) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(value);

  static String toArabic(String text) {
    if (text.trim().isEmpty || containsArabic(text)) return text;

    String value = text;

    const exact = {
      'Flying Taxi': 'التاكسي الطائر',
      'Transit Trips': 'رحلات الترانزيت',
      'Services': 'الخدمات',
      'Places': 'الاماكن',
      'Profile': 'الملف الشخصي',
      'AI Chat': 'محادثة الذكاء الاصطناعي',
      'Bookings': 'الحجوزات',
      'Home': 'الرئيسية',
      'Cairo Airport': 'مطار القاهرة',
      'Recently': 'مؤخرا',
      'Default': 'افتراضي',
      'Remove': 'حذف',
      'Set as Default': 'تعيين كافتراضي',
      'Free cancellation up to 2 hours before departure.':
          'الغاء مجاني حتى ساعتين قبل موعد الانطلاق.',
      'No trips for this filter': 'لا توجد رحلات لهذا الفلتر',
      'Find the best trip for my time': 'ابحث عن افضل رحلة حسب وقتي',
      'AI-powered layover trip recommendations':
          'اقتراحات رحلات ترانزيت مدعومة بالذكاء الاصطناعي',
      'Trips that start & end at Cairo International Airport':
          'رحلات تبدأ وتنتهي في مطار القاهرة الدولي',
      'Trips inside Cairo with airport pickup and return.':
          'رحلات داخل القاهرة مع استقبال وعودة للمطار.',
      'Our Services': 'خدماتنا',
      'Everything you need for the perfect Egypt tour':
          'كل ما تحتاجه لرحلة مثالية في مصر',
      'Popular Places': 'اماكن مشهورة',
      'Top tourist landmarks across Egypt': 'ابرز المعالم السياحية في مصر',
      'Details': 'التفاصيل',
      'Full Itinerary': 'البرنامج الكامل',
      'Total Price': 'السعر الاجمالي',
      'Book This Trip': 'احجز هذه الرحلة',
      'Book This Flight': 'احجز هذه الرحلة الجوية',
      'Reviews': 'التقييمات',
      'Write a Review': 'اكتب تقييما',
      'Write Your Review': 'اكتب تقييمك',
      'Rating': 'التقييم',
      'Comment': 'التعليق',
      'Your Comment': 'تعليقك',
      'Cancel': 'الغاء',
      'Submit': 'ارسال',
      'Gallery': 'المعرض',
      'Route Map': 'خريطة المسار',
      'What\'s Included': 'ما يشمله الحجز',
      'Private Tour': 'جولة خاصة',
      'Cairo International Airport': 'مطار القاهرة الدولي',
      'Cairo International Airport, Egypt': 'مطار القاهرة الدولي، مصر',
      'Select a date': 'اختر تاريخا',
      'Select a date first': 'اختر التاريخ اولا',
      'Travel Date': 'تاريخ الرحلة',
      'Travelers': 'المسافرون',
      'Passengers': 'الركاب',
      'Payment': 'طريقة الدفع',
      'Book Trip': 'احجز الرحلة',
      'Book Flight': 'احجز الرحلة الجوية',
      'Trip Highlights': 'ابرز مميزات الرحلة',
      'Flight Route': 'مسار الرحلة الجوية',
      'App Assistant': 'مساعد التطبيق',
      'Online - AI Travel Guide': 'متصل - دليل سفر ذكي',
      'My Bookings': 'حجوزاتي',
      'Prices': 'الاسعار',
      'Chat here...': 'اكتب رسالتك هنا...',
      'Hello! 👋 Welcome to App Transport, your Egypt travel companion.\nAsk me about tours, landmarks, transportation, or bookings across Egypt!':
          'اهلا! 👋 مرحبا بك في App Transport، رفيقك للسفر في مصر.\nاسألني عن الجولات والمعالم والمواصلات او الحجوزات داخل مصر!',
      'Connection error. Please check your internet and try again. 🔌':
          'خطأ في الاتصال. يرجى التحقق من الانترنت ثم المحاولة مرة اخرى. 🔌',
      'View Details': 'عرض التفاصيل',
      'Pickup': 'الاستلام',
      'Pickup: ': 'الاستلام: ',
      'Drop-off': 'التوصيل',
      'Pickup & Drop-off': 'الاستلام والتوصيل',
      'Confirm Booking': 'تأكيد الحجز',
      'Total': 'الاجمالي',
    };

    if (exact.containsKey(value)) {
      return exact[value]!;
    }

    const phraseMap = {
      'Airport Transfer': 'انتقال من والى المطار',
      'Tour Guide': 'مرشد سياحي',
      'Entry Tickets': 'تذاكر دخول',
      'Light Meal': 'وجبة خفيفة',
      'Drink': 'مشروب',
      'Transit Experience': 'تجربة ترانزيت',
      'Cairo Aerial Tour': 'جولة جوية في القاهرة',
      'Scenic flying taxi experience over Cairo landmarks with airport pickup and return.':
          'تجربة تاكسي طائر بانورامية فوق معالم القاهرة مع استقبال وعودة للمطار.',
      'Cairo Airport route with key aerial landmarks and return transfer.':
          'مسار من مطار القاهرة عبر اهم المعالم الجوية مع عودة للمطار.',
      'Scheduled activity during your transit journey.':
          'محطة نشاط ضمن برنامج رحلة الترانزيت.',
      'Very enjoyable transit experience with smooth planning.':
          'تجربة ترانزيت ممتعة وتنظيم سلس.',
      'Great experience with amazing city views.':
          'تجربة رائعة مع مشاهد مدهشة للمدينة.',
      'Traveler': 'مسافر',
      'Airport': 'المطار',
      'Takeoff': 'الاقلاع',
      'Landing': 'الهبوط',
      'Citadel': 'القلعة',
      'Nile': 'النيل',
      'Corniche': 'الكورنيش',
      'Pyramids': 'الاهرامات',
      'Sphinx': 'ابو الهول',
      'Cairo Tower': 'برج القاهرة',
      'Old Cairo': 'القاهرة القديمة',
      'Khan El-Khalili': 'خان الخليلي',
      'Egyptian Museum': 'المتحف المصري',
      'Grand Egyptian Museum': 'المتحف المصري الكبير',
      'Saladin Citadel': 'قلعة صلاح الدين',
      'Nile River Cruise': 'رحلة نيلية',
      'Baron Palace': 'قصر البارون',
      'Pharaonic Village': 'القرية الفرعونية',
      'Airport WiFi': 'واي فاي المطار',
      'Private Car Hire': 'سيارة خاصة',
      'Photography Tour': 'جولة تصوير',
      'Luggage Storage': 'حفظ الامتعة',
      'Egyptian Dining': 'تجربة طعام مصري',
      'SIM Card': 'شريحة اتصال',
      'Travel Insurance': 'تأمين السفر',
      'Giza': 'الجيزة',
      'Cairo': 'القاهرة',
      'Downtown': 'وسط البلد',
      'South of Cairo': 'جنوب القاهرة',
      'Islamic Cairo': 'القاهرة الاسلامية',
    };

    phraseMap.forEach((en, ar) {
      value = value.replaceAll(en, ar);
    });

    value = value
        .replaceAllMapped(
          RegExp(r'\b(\d+(?:\.\d+)?)h\b', caseSensitive: false),
          (m) => '${m.group(1)} ساعة',
        )
        .replaceAllMapped(
          RegExp(r'\b(\d+)\s*hours?\b', caseSensitive: false),
          (m) => '${m.group(1)} ساعة',
        )
        .replaceAllMapped(
          RegExp(r'\b(\d+(?:\.\d+)?)\s*hrs?\b', caseSensitive: false),
          (m) => '${m.group(1)} ساعة',
        )
        .replaceAllMapped(
          RegExp(r'\b(\d+)\s*min(?:ute)?s?\b', caseSensitive: false),
          (m) => '${m.group(1)} دقيقة',
        )
        .replaceAll(' ago', ' مضت')
        .replaceAll(' -> ', ' ← ')
        .replaceAll('&', 'و');

    return value;
  }

  static String display(BuildContext context, String text) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? toArabic(text) : text;
  }
}
