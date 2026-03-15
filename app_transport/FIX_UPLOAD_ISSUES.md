# 🔧 حل مشكلة عدم رفع الرحلات والصور

## ✅ المشكلة الرئيسية

**قواعس Firebase لم تُحدّث بشكل صحيح!**

التطبيق لا يستطيع الكتابة لأن الصلاحيات غير مفعلة.

---

## 🛠️ الحل الفوري (5 دقائق)

### الخطوة 1: ادخل Firebase Console

```
https://console.firebase.google.com/
```

تحقق من أن المشروع هو: **transitapp-7717f** أو **app_transport**

---

### الخطوة 2: حدّث Realtime Database Rules

1. اذهب إلى: **Realtime Database** → **Rules**
2. **احذف** جميع الأكواد القديمة
3. **انسخ والصق** هذا الكود الكامل:

```json
{
  "rules": {
    "trips": {
      ".read": true,
      "$tripId": {
        ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true",
        ".validate": "newData.hasChildren(['id', 'name', 'type', 'priceUsd'])",
        "isActive": {
          ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true"
        },
        "imageUrl": {
          ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true"
        },
        "galleryImageUrls": {
          ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true"
        }
      }
    },
    
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('isAdmin').val === true",
        ".write": "$uid === auth.uid"
      }
    },
    
    "bookings": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('isAdmin').val === true",
        ".write": "$uid === auth.uid"
      }
    },
    
    "favorites": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    
    "system": {
      ".read": true,
      ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true"
    }
  }
}
```

4. اضغط **Publish**

---

### الخطوة 3: حدّث Storage Rules

1. اذهب إلى: **Storage** → **Rules**
2. **احذف** جميع القواعس القديمة
3. **انسخ والصق** هذا الكود:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow admins to upload and read all trip files
    match /trips/{tripId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(project_id)/documents/users/$(request.auth.uid)).data.get('isAdmin', false) == true;
    }
    
    // Fallback for development
    match /trips/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

4. اضغط **Publish**

---

## 🧪 اختبار الآن

### خطوة 1: امسح Browser Cache

اضغط `Ctrl+Shift+Delete` واختر:
- ✅ Cookies and other site data
- ✅ Cached images and files
- اختر "All time"

### خطوة 2: أعد تشغيل الكمبيوتر (اختياري لكن موصى به)

### خطوة 3: شغّل التطبيق

```bash
flutter run -d chrome
```

### خطوة 4: اختبر الرفع

1. سجّل دخول كـ **Admin**
2. ادخل إلى **Admin Dashboard**
3. ادهب إلى **Trips** tab
4. اضغط **Add Trip**
5. أدخل معلومات الرحلة
6. اضغط **Select** على صورة الغلاف
7. اختر صورة من جهازك
8. اضغط **Save Trip**

---

## 🔍 التحقق من النجاح

### في Firebase Console:

**Realtime Database:**
- اذهب إلى **Data** tab
- تحقق من وجود مستند جديد تحت `trips/`
- يجب أن تظهر جميع معلومات الرحلة

**Storage:**
- اذهب إلى **Files**
- تحقق من وجود مجلد جديد باسم `trips/`
- داخله يجب أن يكون `cover.jpg`

### في Browser Console:

اضغط `F12` وادهب إلى **Console**:
- إذا رأيت أي أخطاء حمراء، شيرها معي
- يجب أن ترى رسائل نجاح (green checkmarks)

---

## ❌ إذا استمرت المشكلة

### فحص 1: تحقق من صلاحيات Admin

```bash
في مربع البحث في Firebase Console:
Search "Firestore Users" أو "Authentication"
انقر على المستخدم الحالي
تحقق من أن isAdmin = true
```

### فحص 2: شاهد رسائل الخطأ الدقيقة

1. افتح DevTools (`F12`)
2. ادهب إلى **Console**
3. ابحث عن أي رسائل حمراء
4. شيرها معي

### فحص 3: تحقق من CORS

في terminal، نفّذ هذا الأمر (إذا كنت على Windows):

```bash
gsutil cors set cors.json gs://transitapp-7717f.appspot.com
```

أو على Google Cloud Shell:
1. اذهب إلى: https://console.cloud.google.com/
2. افتح Cloud Shell (الأيقونة في الأعلى)
3. نسّخ الأمر أعلاه وألصقه

---

## 📝 ملخص سريع

| الخطوة | ماذا نعمل | متى ينجح |
|--------|---------|---------|
| 1 | تحديث Realtime DB Rules | الرحلات بتظهر في database |
| 2 | تحديث Storage Rules | الصور تترفع بنجاح |
| 3 | مسح Browser Cache | التطبيق يشتغل صح |
| 4 | اختبار | الرحلات والصور موجودة! ✅ |

---

## 🚀 بعد النجاح

بعد ما تعمل الرحلات والصور، الخطوة الجاية هي:
- عرض الرحلات للمستخدمين العاديين
- السماح بـ Booking (الحجز)
- تصفية الرحلات حسب النوع

---

## 📞 للمساعدة

إذا استمرت المشكلة بعد كل هذا:
1. انسخ رسائل الخطأ من Console
2. شاهد ما إذا كانت في Storage أو Database
3. قل لي الرسالة الدقيقة
