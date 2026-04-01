class S {
  S._();

  static String tr(String key, bool isAr) {
    final map = _strings[key];
    if (map == null) return key;
    return isAr ? (map['ar'] ?? map['en'] ?? key) : (map['en'] ?? key);
  }

  static final Map<String, Map<String, String>> _strings = {
    // ── Home Page ──
    'hi': {'en': 'Hi', 'ar': 'أهلاً'},
    'lets_enjoy': {
      'en': "Let's Enjoy\nYour Vacation!",
      'ar': 'استمتع\nبإجازتك!'
    },
    'search_trips': {'en': 'Search for trips...', 'ar': 'ابحث عن رحلات...'},
    'ai_suggestions': {'en': 'AI Suggestions', 'ar': 'اقتراحات ذكية'},
    'popular_trips': {'en': 'Popular Trips', 'ar': 'رحلات مميزة'},
    'see_all': {'en': 'See All', 'ar': 'عرض الكل'},
    'search_results': {'en': 'Search Results', 'ar': 'نتائج البحث'},
    'no_trips_matched': {
      'en': 'No trips matched your search',
      'ar': 'لا توجد رحلات مطابقة للبحث'
    },
    'no_trips_available': {
      'en': 'No trips available yet',
      'ar': 'لا توجد رحلات متاحة حالياً'
    },
    'results_for': {'en': 'Results for', 'ar': 'نتائج البحث عن'},

    // ── AI Suggestion titles ──
    'find_best_trip': {
      'en': 'Find the best trip for my time',
      'ar': 'اكتشف أفضل رحلة لوقتك'
    },
    'set_hours': {'en': 'Set hours', 'ar': 'حدد الساعات'},
    'giza_tour_3h': {'en': '3-hour Giza Tour', 'ar': 'جولة الجيزة ٣ ساعات'},
    'flying_taxi_cairo': {
      'en': 'Flying Taxi over Cairo',
      'ar': 'تاكسي طائر فوق القاهرة'
    },
    'old_cairo_walking': {
      'en': 'Old Cairo Walking',
      'ar': 'جولة القاهرة القديمة'
    },
    'short_nile_cruise': {
      'en': 'Short Nile Cruise',
      'ar': 'رحلة نيلية قصيرة'
    },
    'transit_day_cairo': {
      'en': 'Transit day in Cairo',
      'ar': 'يوم ترانزيت في القاهرة'
    },

    // ── AI Suggestion durations ──
    '3_hrs': {'en': '3 hrs', 'ar': '٣ ساعات'},
    '30_min': {'en': '30 min', 'ar': '٣٠ دقيقة'},
    '1.5_hrs': {'en': '1.5 hrs', 'ar': 'ساعة ونصف'},
    '2_hrs': {'en': '2 hrs', 'ar': 'ساعتين'},
    '5_hrs': {'en': '5 hrs', 'ar': '٥ ساعات'},

    // ── Categories ──
    'flying_taxi': {'en': 'Flying Taxi', 'ar': 'تاكسي طائر'},
    'transit_trips': {'en': 'Transit Trips', 'ar': 'رحلات ترانزيت'},
    'services': {'en': 'Services', 'ar': 'خدمات'},
    'places': {'en': 'Places', 'ar': 'أماكن'},

    // ── Bottom nav ──
    'home': {'en': 'Home', 'ar': 'الرئيسية'},
    'flying': {'en': 'Flying', 'ar': 'طيران'},
    'transit': {'en': 'Transit', 'ar': 'ترانزيت'},
    'bookings': {'en': 'Bookings', 'ar': 'الحجوزات'},
    'ai_chat': {'en': 'AI Chat', 'ar': 'المحادثة'},
    'profile': {'en': 'Profile', 'ar': 'الحساب'},

    // ── Profile Page ──
    'account_settings': {'en': 'Account Settings', 'ar': 'إعدادات الحساب'},
    'change_password': {'en': 'Change Password', 'ar': 'تغيير كلمة المرور'},
    'switch_account': {'en': 'Switch Account', 'ar': 'تبديل الحساب'},
    'log_out': {'en': 'Log Out', 'ar': 'تسجيل خروج'},
    'language': {'en': 'Language', 'ar': 'اللغة'},
    'payment_methods': {'en': 'Payment Methods', 'ar': 'طرق الدفع'},
    'add_card': {'en': 'Add Card', 'ar': 'إضافة بطاقة'},
    'preferences': {'en': 'Preferences', 'ar': 'التفضيلات'},
    'trip_notifications': {
      'en': 'Trip Notifications',
      'ar': 'إشعارات الرحلات'
    },
    'deals_discounts': {'en': 'Deals & Discounts', 'ar': 'عروض وخصومات'},
    'trip_reminder': {'en': 'Trip Reminder', 'ar': 'تذكير بالرحلات'},
    'support': {'en': 'Support', 'ar': 'الدعم'},
    'help_center': {'en': 'Help Center', 'ar': 'مركز المساعدة'},
    'contact_us': {'en': 'Contact Us', 'ar': 'تواصل معنا'},
    'faqs': {'en': 'FAQs', 'ar': 'الأسئلة الشائعة'},
    'legal': {'en': 'Legal', 'ar': 'قانوني'},
    'privacy_policy': {'en': 'Privacy Policy', 'ar': 'سياسة الخصوصية'},
    'terms_conditions': {
      'en': 'Terms & Conditions',
      'ar': 'الشروط والأحكام'
    },
    'trips_count': {'en': '12 Trips', 'ar': '١٢ رحلة'},
    'rating': {'en': '4.8 Rating', 'ar': '٤.٨ تقييم'},
    'since': {'en': 'Since 2024', 'ar': 'منذ ٢٠٢٤'},
    'full_name': {'en': 'Full Name', 'ar': 'الاسم الكامل'},
    'phone_number': {'en': 'Phone Number', 'ar': 'رقم الهاتف'},
    'save_changes': {'en': 'Save Changes', 'ar': 'حفظ التغييرات'},
    'current_password': {
      'en': 'Current Password',
      'ar': 'كلمة المرور الحالية'
    },
    'new_password': {'en': 'New Password', 'ar': 'كلمة المرور الجديدة'},
    'confirm_new_password': {
      'en': 'Confirm New Password',
      'ar': 'تأكيد كلمة المرور'
    },
    'update_password': {'en': 'Update Password', 'ar': 'تحديث كلمة المرور'},
    'updating': {'en': 'Updating...', 'ar': 'جاري التحديث...'},
    'card_number': {'en': 'Card Number', 'ar': 'رقم البطاقة'},
    'card_holder': {'en': 'Card Holder Name', 'ar': 'اسم حامل البطاقة'},
    'save_card': {'en': 'Save Card', 'ar': 'حفظ البطاقة'},
    'language_set_to': {
      'en': 'Language set to',
      'ar': 'تم تغيير اللغة إلى'
    },
    'confirm_switch': {
      'en':
          'You will be signed out and redirected to the sign-in page. Continue?',
      'ar': 'سيتم تسجيل خروجك والانتقال لصفحة الدخول. متأكد؟'
    },
    'confirm_logout': {
      'en': 'Are you sure you want to log out?',
      'ar': 'متأكد إنك عايز تسجل خروج؟'
    },
    'switch': {'en': 'Switch', 'ar': 'تبديل'},
    'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'default_label': {'en': 'Default', 'ar': 'الافتراضية'},
    'set_default': {'en': 'Set as default', 'ar': 'تعيين كافتراضية'},
    'remove': {'en': 'Remove', 'ar': 'إزالة'},
    'edit_profile': {'en': 'Edit Profile', 'ar': 'تعديل الملف'},

    // ── My Bookings ──
    'my_bookings': {'en': 'My Bookings', 'ar': 'حجوزاتي'},
    'upcoming': {'en': 'Upcoming', 'ar': 'القادمة'},
    'past': {'en': 'Past', 'ar': 'السابقة'},
    'no_upcoming': {
      'en': 'No upcoming bookings',
      'ar': 'لا توجد حجوزات قادمة'
    },
    'no_past': {'en': 'No past bookings', 'ar': 'لا توجد حجوزات سابقة'},

    // ── Services Page ──
    'airport_wifi': {'en': 'Airport WiFi', 'ar': 'واي فاي المطار'},
    'airport_wifi_desc': {
      'en': 'Free high-speed internet at Cairo Airport',
      'ar': 'إنترنت مجاني عالي السرعة في مطار القاهرة'
    },
    'private_car': {'en': 'Private Car Hire', 'ar': 'تأجير سيارة خاصة'},
    'private_car_desc': {
      'en': 'Comfortable private transfers around Cairo',
      'ar': 'تنقلات خاصة ومريحة في القاهرة'
    },
    'tour_guide': {'en': 'Tour Guide', 'ar': 'مرشد سياحي'},
    'tour_guide_desc': {
      'en': 'Certified multilingual guides for your tour',
      'ar': 'مرشدين معتمدين متعددي اللغات'
    },
    'photography_tour': {'en': 'Photography Tour', 'ar': 'جولة تصوير'},
    'photography_desc': {
      'en': 'Professional photo sessions at landmarks',
      'ar': 'جلسات تصوير احترافية عند المعالم'
    },
    'luggage_storage': {'en': 'Luggage Storage', 'ar': 'حفظ الأمتعة'},
    'luggage_desc': {
      'en': 'Safe storage at the airport during your tour',
      'ar': 'تخزين آمن في المطار أثناء جولتك'
    },
    'egyptian_dining': {'en': 'Egyptian Dining', 'ar': 'مطبخ مصري'},
    'dining_desc': {
      'en': 'Traditional meal experiences included',
      'ar': 'تجارب طعام مصري تقليدي'
    },
    'sim_card': {'en': 'SIM Card', 'ar': 'شريحة اتصال'},
    'sim_card_desc': {
      'en': 'Local Egyptian SIM with data package',
      'ar': 'شريحة مصرية محلية مع باقة بيانات'
    },
    'travel_insurance': {'en': 'Travel Insurance', 'ar': 'تأمين السفر'},
    'travel_insurance_desc': {
      'en': 'Full coverage for all our tour packages',
      'ar': 'تغطية كاملة لجميع باقاتنا'
    },

    // ── Places Page ──
    'giza_pyramids': {
      'en': 'Giza Pyramids & Sphinx',
      'ar': 'أهرامات الجيزة وأبو الهول'
    },
    'giza_pyramids_loc': {'en': 'Giza, Cairo', 'ar': 'الجيزة، القاهرة'},
    'giza_pyramids_desc': {
      'en':
          'The last remaining wonder of the ancient world — a must-see landmark in Egypt.',
      'ar': 'آخر عجائب الدنيا القديمة — معلم لا يُفوّت في مصر.'
    },
    'khan_khalili': {
      'en': 'Khan El-Khalili Bazaar',
      'ar': 'خان الخليلي'
    },
    'khan_khalili_loc': {'en': 'Islamic Cairo', 'ar': 'القاهرة الإسلامية'},
    'khan_khalili_desc': {
      'en':
          'A medieval bazaar full of spices, crafts, jewellery, and authentic Egyptian culture.',
      'ar': 'سوق عريق مليء بالتوابل والحرف والمجوهرات والثقافة المصرية.'
    },
    'egyptian_museum': {'en': 'Egyptian Museum', 'ar': 'المتحف المصري'},
    'egyptian_museum_loc': {
      'en': 'Tahrir Square, Cairo',
      'ar': 'ميدان التحرير، القاهرة'
    },
    'egyptian_museum_desc': {
      'en':
          'Home to the largest collection of ancient Egyptian antiquities, including Tutankhamun\'s treasures.',
      'ar':
          'يضم أكبر مجموعة آثار مصرية قديمة، بما فيها كنوز توت عنخ آمون.'
    },
    'nile_cruise': {'en': 'Nile River Cruise', 'ar': 'رحلة نيلية'},
    'nile_cruise_loc': {'en': 'Downtown Cairo', 'ar': 'وسط القاهرة'},
    'nile_cruise_desc': {
      'en':
          'A relaxing felucca sail along the world\'s longest river with stunning Cairo skyline views.',
      'ar': 'رحلة فلوكة مريحة على النيل مع مناظر خلابة لأفق القاهرة.'
    },
    'saladin_citadel': {'en': 'Saladin Citadel', 'ar': 'قلعة صلاح الدين'},
    'saladin_citadel_loc': {
      'en': 'Mokattam Hill, Cairo',
      'ar': 'تلة المقطم، القاهرة'
    },
    'saladin_citadel_desc': {
      'en':
          'A medieval Islamic fortress overlooking Cairo with the stunning Mohamed Ali Mosque inside.',
      'ar':
          'قلعة إسلامية تطل على القاهرة وتضم مسجد محمد علي الرائع.'
    },
    'grand_museum': {
      'en': 'Grand Egyptian Museum',
      'ar': 'المتحف المصري الكبير'
    },
    'grand_museum_loc': {'en': 'Giza', 'ar': 'الجيزة'},
    'grand_museum_desc': {
      'en':
          'The world\'s largest archaeological museum, home to over 100,000 ancient Egyptian artifacts.',
      'ar': 'أكبر متحف أثري في العالم، يضم أكثر من ١٠٠ ألف قطعة أثرية.'
    },
    'memphis_saqqara': {'en': 'Memphis & Saqqara', 'ar': 'ممفيس وسقارة'},
    'memphis_saqqara_loc': {'en': 'South of Cairo', 'ar': 'جنوب القاهرة'},
    'memphis_saqqara_desc': {
      'en':
          'Ancient capital of Egypt with the Step Pyramid — one of the earliest stone structures ever built.',
      'ar':
          'العاصمة القديمة لمصر مع الهرم المدرج — من أقدم المباني الحجرية.'
    },
    'cairo_tower': {'en': 'Cairo Tower', 'ar': 'برج القاهرة'},
    'cairo_tower_loc': {
      'en': 'Gezira Island, Cairo',
      'ar': 'جزيرة الزمالك، القاهرة'
    },
    'cairo_tower_desc': {
      'en':
          'A 187-metre concrete tower offering a panoramic 360° view of Cairo and the Nile.',
      'ar': 'برج بارتفاع ١٨٧ متر يوفر إطلالة بانورامية ٣٦٠° على القاهرة والنيل.'
    },

    // ── Flying Taxi Page ──
    'flying_taxi_title': {
      'en': 'Flying Taxi Tours',
      'ar': 'جولات التاكسي الطائر'
    },
    'book_now': {'en': 'Book Now', 'ar': 'احجز الآن'},
    'reviews': {'en': 'Reviews', 'ar': 'التقييمات'},
    'route': {'en': 'Route', 'ar': 'المسار'},
    'duration': {'en': 'Duration', 'ar': 'المدة'},
    'price': {'en': 'Price', 'ar': 'السعر'},
    'flight_time': {'en': 'Flight Time', 'ar': 'وقت الطيران'},
    'included': {'en': 'Included', 'ar': 'يشمل'},

    // ── Transit Page ──
    'transit_trips_title': {
      'en': 'Transit Trips',
      'ar': 'رحلات الترانزيت'
    },
    'itinerary': {'en': 'Itinerary', 'ar': 'خط السير'},

    // ── Common ──
    'how_many_hours': {
      'en': 'How many hours do you have?',
      'ar': 'عندك كام ساعة؟'
    },
    'example_4': {'en': 'Example: 4', 'ar': 'مثال: ٤'},
    'get_suggestion': {'en': 'Get Suggestion', 'ar': 'اقترح لي'},
    'loading': {'en': 'Loading...', 'ar': 'جاري التحميل...'},
    'error': {'en': 'Error', 'ar': 'خطأ'},
    'close': {'en': 'Close', 'ar': 'إغلاق'},
    'confirm': {'en': 'Confirm', 'ar': 'تأكيد'},

    // ── Splash ──
    'start_trip': {'en': 'Start Your Trip', 'ar': 'ابدأ رحلتك'},
    'cairo_transit': {
      'en': 'Cairo Transit Tours',
      'ar': 'جولات ترانزيت القاهرة'
    },

    // ── Sign In ──
    'sign_in': {'en': 'Sign In', 'ar': 'تسجيل الدخول'},
    'sign_up': {'en': 'Sign Up', 'ar': 'إنشاء حساب'},
    'email': {'en': 'Email', 'ar': 'البريد الإلكتروني'},
    'password': {'en': 'Password', 'ar': 'كلمة المرور'},
    'forgot_password': {
      'en': 'Forgot Password?',
      'ar': 'نسيت كلمة المرور؟'
    },
    'dont_have_account': {
      'en': "Don't have an account?",
      'ar': 'ليس لديك حساب؟'
    },
    'already_have_account': {
      'en': 'Already have an account?',
      'ar': 'لديك حساب بالفعل؟'
    },

    // ── Chatbot ──
    'ai_assistant': {'en': 'AI Travel Assistant', 'ar': 'مساعد السفر الذكي'},
    'type_message': {
      'en': 'Type your message...',
      'ar': 'اكتب رسالتك...'
    },

    // ── Detail Pages ──
    'cairo_intl_airport': {
      'en': 'Cairo International Airport',
      'ar': 'مطار القاهرة الدولي'
    },
    'cairo_intl_airport_egypt': {
      'en': 'Cairo International Airport, Egypt',
      'ar': 'مطار القاهرة الدولي، مصر'
    },
    'flight_route': {'en': 'Flight Route', 'ar': 'مسار الرحلة'},
    'trip_highlights': {'en': 'Trip Highlights', 'ar': 'أبرز المحطات'},
    'scenic_views': {'en': 'Scenic Views', 'ar': 'مناظر خلابة'},
    'ai_audio_guide': {'en': 'AI Audio Guide', 'ar': 'دليل صوتي ذكي'},
    'photo_spots': {'en': 'Photo Spots', 'ar': 'نقاط تصوير'},
    'book_this_flight': {
      'en': 'Book This Flight',
      'ar': 'احجز هذه الرحلة'
    },
    'book_flight': {'en': 'Book Flight', 'ar': 'حجز الرحلة'},
    'flight_date': {'en': 'Flight Date', 'ar': 'تاريخ الرحلة'},
    'passengers': {'en': 'Passengers', 'ar': 'الركاب'},
    'payment': {'en': 'Payment', 'ar': 'الدفع'},
    'select_date': {'en': 'Select a date', 'ar': 'اختر تاريخ'},
    'select_date_first': {
      'en': 'Select a date first',
      'ar': 'اختر تاريخ أولاً'
    },
    'confirm_booking_btn': {
      'en': 'Confirm Booking',
      'ar': 'تأكيد الحجز'
    },
    'write_review': {'en': 'Write a Review', 'ar': 'اكتب تقييم'},
    'write_your_review': {'en': 'Write Your Review', 'ar': 'اكتب تقييمك'},
    'rating_label': {'en': 'Rating', 'ar': 'التقييم'},
    'your_comment': {'en': 'Your Comment', 'ar': 'تعليقك'},
    'comment_label': {'en': 'Comment', 'ar': 'تعليق'},
    'share_experience': {
      'en': 'Share your experience...',
      'ar': 'شارك تجربتك...'
    },
    'submit': {'en': 'Submit', 'ar': 'إرسال'},
    'thank_review': {
      'en': 'Thank you for your review!',
      'ar': 'شكراً لتقييمك!'
    },
    'sign_in_to_book_flight': {
      'en': 'Please sign in to book a flight.',
      'ar': 'سجل دخولك لحجز الرحلة.'
    },
    'sign_in_to_book_trip': {
      'en': 'Please sign in to book a trip.',
      'ar': 'سجل دخولك لحجز الرحلة.'
    },
    'flight_booked': {'en': 'Flight booked!', 'ar': 'تم حجز الرحلة!'},
    'booking_confirmed_msg': {
      'en': 'Booking confirmed!',
      'ar': 'تم تأكيد الحجز!'
    },
    'booking_failed': {
      'en': 'Failed to save booking. Check your connection.',
      'ar': 'فشل الحجز. تحقق من الاتصال.'
    },
    'total_label': {'en': 'Total:', 'ar': 'الإجمالي:'},
    'total_price': {'en': 'Total Price', 'ar': 'السعر الإجمالي'},

    // ── Transit Detail ──
    'full_itinerary': {'en': 'Full Itinerary', 'ar': 'خط السير الكامل'},
    'gallery': {'en': 'Gallery', 'ar': 'معرض الصور'},
    'stops_label': {'en': 'stops', 'ar': 'محطات'},
    'route_map': {'en': 'Route Map', 'ar': 'خريطة المسار'},
    'whats_included': {'en': "What's Included", 'ar': 'الخدمات المشمولة'},
    'book_this_trip': {'en': 'Book This Trip', 'ar': 'احجز هذه الرحلة'},
    'book_trip': {'en': 'Book Trip', 'ar': 'حجز الرحلة'},
    'travel_date': {'en': 'Travel Date', 'ar': 'تاريخ السفر'},
    'travelers': {'en': 'Travelers', 'ar': 'المسافرين'},
    'private_tour': {'en': 'Private Tour', 'ar': 'جولة خاصة'},
    'hours_label': {'en': 'Hours', 'ar': 'ساعات'},
    'cairo_airport': {'en': 'Cairo Airport', 'ar': 'مطار القاهرة'},
    'usd_label': {'en': 'USD', 'ar': 'دولار'},
    'ai_guide': {'en': 'AI Guide', 'ar': 'دليل ذكي'},
    'failed_save_booking': {
      'en': 'Failed to save booking. Check your connection.',
      'ar': 'فشل حفظ الحجز. تحقق من الاتصال.'
    },
    'n_reviews': {'en': 'reviews', 'ar': 'تقييم'},

    // ── Flying Page ──
    'flying_taxi_page_title': {'en': 'Flying Taxi', 'ar': 'التاكسي الطائر'},
    'flying_taxi_subtitle': {
      'en':
          'Flights from Cairo International Airport — depart & return',
      'ar': 'رحلات داخل القاهرة – الانطلاق والعودة لمطار القاهرة الدولي'
    },

    // ── Transit Page ──
    'transit_page_title': {'en': 'Transit Trips', 'ar': 'رحلات الترانزيت'},
    'transit_subtitle': {
      'en': 'Trips that start & end at Cairo International Airport',
      'ar': 'رحلات تبدأ وتنتهي من مطار القاهرة الدولي'
    },
    'no_filter_trips': {
      'en': 'No trips for this filter',
      'ar': 'لا توجد رحلات لهذا الفلتر'
    },
    'find_best_trip_banner': {
      'en': 'Find the best trip for my time',
      'ar': 'اكتشف أفضل رحلة لوقتك'
    },
    'ai_recommendations': {
      'en': 'AI-powered layover trip recommendations',
      'ar': 'توصيات رحلات ذكية للترانزيت'
    },
    'all_filter': {'en': 'All', 'ar': 'الكل'},

    // ── Included Items ──
    'incl_airport_transfer': {
      'en': 'Airport Transfer',
      'ar': 'توصيل من وإلى المطار'
    },
    'incl_tour_guide': {'en': 'Tour Guide', 'ar': 'مرشد سياحي'},
    'incl_entry_tickets': {'en': 'Entry Tickets', 'ar': 'تذاكر الدخول'},
    'incl_light_meal': {'en': 'Light Meal', 'ar': 'وجبة خفيفة'},
    'incl_lunch': {'en': 'Lunch', 'ar': 'غداء'},
    'incl_drink': {'en': 'Drink', 'ar': 'مشروب'},
    'incl_light_snack': {'en': 'Light Snack', 'ar': 'وجبة خفيفة'},
    'incl_citadel_tickets': {'en': 'Citadel Tickets', 'ar': 'تذاكر القلعة'},

    // ── Details Button ──
    'details_button': {'en': 'Details', 'ar': 'التفاصيل'},

    // ── Payment Methods ──
    'cash_on_pickup': {'en': 'Cash on pickup', 'ar': 'نقداً عند الاستلام'},

    // ── Splash Screen ──
    'explore_destinations': {
      'en': 'Explore Egyptian Destinations',
      'ar': 'استكشف وجهات مصر السياحية'
    },
    'splash_description': {
      'en':
          'Plan your journey with transit apps and\nexplore the land of pharaohs at your fingertips.',
      'ar':
          'خطط لرحلتك مع تطبيق الترانزيت\nواستكشف أرض الفراعنة بين يديك.'
    },

    // ── Sign In Page ──
    'welcome_back': {'en': 'Welcome Back', 'ar': 'أهلاً بعودتك'},
    'enter_details': {
      'en': 'Enter your details below',
      'ar': 'أدخل بياناتك أدناه'
    },
    'email_address': {'en': 'Email Address', 'ar': 'البريد الإلكتروني'},
    'forgot_password_link': {
      'en': 'Forgot your password?',
      'ar': 'نسيت كلمة المرور؟'
    },
    'or_sign_in_with': {'en': 'Or sign in with', 'ar': 'أو سجل دخول بـ'},
    'sign_in_loading': {'en': 'Sign In...', 'ar': 'جاري الدخول...'},

    // ── Sign Up Page ──
    'get_started_free': {'en': 'Get started free.', 'ar': 'ابدأ مجاناً.'},
    'no_credit_card': {
      'en': 'Free forever. No credit card needed.',
      'ar': 'مجاني للأبد. بدون بطاقة ائتمان.'
    },
    'your_name': {'en': 'Your name', 'ar': 'اسمك'},
    'or_sign_up_with': {'en': 'Or sign up with', 'ar': 'أو سجل بـ'},
    'weak': {'en': 'Weak', 'ar': 'ضعيفة'},
    'fair': {'en': 'Fair', 'ar': 'متوسطة'},
    'good': {'en': 'Good', 'ar': 'جيدة'},
    'strong': {'en': 'Strong', 'ar': 'قوية'},
    'sign_up_loading': {'en': 'Creating...', 'ar': 'جاري الإنشاء...'},
    'dont_have_account_header': {
      'en': "Don't have an account?",
      'ar': 'ليس لديك حساب؟'
    },
    'already_have_account_header': {
      'en': 'Already have an account?',
      'ar': 'لديك حساب بالفعل؟'
    },
    'fill_all_fields': {
      'en': 'Please fill in all fields',
      'ar': 'يرجى ملء جميع الحقول'
    },
    'password_min_6': {
      'en': 'Password must be at least 6 characters',
      'ar': 'كلمة المرور يجب أن تكون ٦ أحرف على الأقل'
    },
    'email_pass_required': {
      'en': 'Email and password are required',
      'ar': 'البريد وكلمة المرور مطلوبين'
    },
    'welcome_back_msg': {'en': 'Welcome back!', 'ar': 'أهلاً بعودتك!'},
    'sign_in_failed': {'en': 'Sign in failed', 'ar': 'فشل تسجيل الدخول'},
    'google_sign_in_success': {
      'en': 'Signed in with Google successfully',
      'ar': 'تم الدخول بحساب جوجل بنجاح'
    },
    'google_sign_in_failed': {
      'en': 'Google sign in failed',
      'ar': 'فشل الدخول بجوجل'
    },
    'account_created': {'en': 'Account created!', 'ar': 'تم إنشاء الحساب!'},
    'create_account_failed': {
      'en': 'Failed to create account',
      'ar': 'فشل إنشاء الحساب'
    },
    'google_sign_up_success': {
      'en': 'Signed up with Google successfully',
      'ar': 'تم التسجيل بجوجل بنجاح'
    },
    'google_sign_up_failed': {
      'en': 'Google sign up failed',
      'ar': 'فشل التسجيل بجوجل'
    },
    'reset_email_sent': {
      'en': 'Reset email sent successfully.',
      'ar': 'تم إرسال إيميل إعادة التعيين.'
    },
    'reset_email_failed': {
      'en': 'Failed to send reset email.',
      'ar': 'فشل إرسال إيميل إعادة التعيين.'
    },

    // ── Chatbot ──
    'app_assistant': {'en': 'App Assistant', 'ar': 'المساعد الذكي'},
    'online_ai_guide': {
      'en': 'Online — AI Travel Guide',
      'ar': 'متصل — مرشد سفر ذكي'
    },
    'chat_here': {'en': 'Chat here...', 'ar': 'اكتب هنا...'},
    'chatbot_welcome': {
      'en':
          'Hello! 👋 Welcome to App Transport, your Egypt travel companion.\nAsk me about tours, landmarks, transportation, or bookings across Egypt!',
      'ar':
          'أهلاً! 👋 مرحباً بك في App Transport، رفيقك للسفر في مصر.\nاسألني عن الجولات أو المعالم أو المواصلات أو الحجوزات!'
    },
    'chip_flying_taxi': {'en': 'Flying Taxi', 'ar': 'تاكسي طائر'},
    'chip_transit_trips': {'en': 'Transit Trips', 'ar': 'رحلات ترانزيت'},
    'chip_my_bookings': {'en': 'My Bookings', 'ar': 'حجوزاتي'},
    'chip_popular_places': {'en': 'Popular Places', 'ar': 'أماكن مشهورة'},
    'chip_prices': {'en': 'Prices', 'ar': 'الأسعار'},

    // ── Profile extras ──
    'profile_title': {'en': 'Profile', 'ar': 'الحساب'},
    'no_saved_cards': {
      'en': 'No saved cards yet',
      'ar': 'لا توجد بطاقات محفوظة'
    },
    'switch_account_body': {
      'en': 'You will be logged out of your current account. Continue?',
      'ar': 'سيتم تسجيل خروجك من الحساب الحالي. متأكد؟'
    },
    'logout_body': {
      'en': 'Are you sure you want to log out of App Transport?',
      'ar': 'متأكد إنك عايز تسجل خروج من App Transport؟'
    },
    'profile_updated': {
      'en': 'Profile updated successfully',
      'ar': 'تم تحديث الملف بنجاح'
    },
    'failed_update_profile': {
      'en': 'Failed to update profile',
      'ar': 'فشل تحديث الملف'
    },
    'card_added': {
      'en': 'Card added successfully',
      'ar': 'تمت إضافة البطاقة بنجاح'
    },
    'settings_coming_soon': {
      'en': 'Settings page coming soon',
      'ar': 'صفحة الإعدادات قريباً'
    },
    'help_coming_soon': {
      'en': 'Help Center coming soon',
      'ar': 'مركز المساعدة قريباً'
    },
    'opening_mail': {'en': 'Opening mail...', 'ar': 'جاري فتح البريد...'},
    'faqs_coming_soon': {'en': 'FAQs coming soon', 'ar': 'الأسئلة الشائعة قريباً'},
    'opening_privacy': {
      'en': 'Opening Privacy Policy...',
      'ar': 'جاري فتح سياسة الخصوصية...'
    },
    'opening_terms': {
      'en': 'Opening Terms...',
      'ar': 'جاري فتح الشروط...'
    },
    'expiry_label': {'en': 'Expiry', 'ar': 'انتهاء'},

    // ── My Bookings extras ──
    'cancel_booking_q': {'en': 'Cancel Booking?', 'ar': 'إلغاء الحجز؟'},
    'cancel_booking_body': {
      'en': 'Are you sure you want to cancel\n',
      'ar': 'هل أنت متأكد من إلغاء\n'
    },
    'free_cancellation_note': {
      'en': 'Free cancellation up to 2 hours before departure.',
      'ar': 'إلغاء مجاني حتى ساعتين قبل الموعد.'
    },
    'keep_booking': {'en': 'Keep Booking', 'ar': 'إبقاء الحجز'},
    'confirm_cancel': {'en': 'Confirm Cancel', 'ar': 'تأكيد الإلغاء'},
    'booking_cancelled': {
      'en': 'Booking cancelled.',
      'ar': 'تم إلغاء الحجز.'
    },
    'modify_booking': {'en': 'Modify Booking', 'ar': 'تعديل الحجز'},
    'departure_time': {'en': 'Departure Time', 'ar': 'وقت المغادرة'},
    'number_of_travelers': {
      'en': 'Number of Travelers',
      'ar': 'عدد المسافرين'
    },
    'updated_total': {'en': 'Updated total: ', 'ar': 'الإجمالي المحدث: '},
    'booking_updated': {
      'en': 'Booking updated successfully!',
      'ar': 'تم تعديل الحجز بنجاح!'
    },
    'leave_review': {'en': 'Leave a Review', 'ar': 'اترك تقييم'},
    'your_rating': {'en': 'Your Rating', 'ar': 'تقييمك'},
    'per_person': {'en': 'per person', 'ar': 'للفرد'},
    'details': {'en': 'Details', 'ar': 'التفاصيل'},

    // ── Month abbreviations ──
    'month_jan': {'en': 'Jan', 'ar': 'يناير'},
    'month_feb': {'en': 'Feb', 'ar': 'فبراير'},
    'month_mar': {'en': 'Mar', 'ar': 'مارس'},
    'month_apr': {'en': 'Apr', 'ar': 'أبريل'},
    'month_may': {'en': 'May', 'ar': 'مايو'},
    'month_jun': {'en': 'Jun', 'ar': 'يونيو'},
    'month_jul': {'en': 'Jul', 'ar': 'يوليو'},
    'month_aug': {'en': 'Aug', 'ar': 'أغسطس'},
    'month_sep': {'en': 'Sep', 'ar': 'سبتمبر'},
    'month_oct': {'en': 'Oct', 'ar': 'أكتوبر'},
    'month_nov': {'en': 'Nov', 'ar': 'نوفمبر'},
    'month_dec': {'en': 'Dec', 'ar': 'ديسمبر'},
  };
}
