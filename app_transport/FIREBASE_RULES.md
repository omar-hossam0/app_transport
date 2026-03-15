# Firebase Rules Configuration

## Realtime Database Rules

استخدم هذه القواعس في Firebase Console → Realtime Database → Rules

```json
{
  "rules": {
    // Public read for trips and bookings
    "trips": {
      ".read": true,
      "$tripId": {
        ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true",
        "isActive": {
          ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true"
        }
      }
    },
    
    // User data - private
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('isAdmin').val === true",
        ".write": "$uid === auth.uid"
      }
    },
    
    // Bookings
    "bookings": {
      "$uid": {
        ".read": "$uid === auth.uid || root.child('users').child(auth.uid).child('isAdmin').val === true",
        ".write": "$uid === auth.uid || root.child('users').child(auth.uid).child('isAdmin').val === true"
      }
    },
    
    // Favorites
    "favorites": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    
    // System settings
    "system": {
      ".read": true,
      ".write": "root.child('users').child(auth.uid).child('isAdmin').val === true"
    }
  }
}
```

---

## Firebase Storage Rules

استخدم هذه القواعس في Firebase Console → Storage → Rules

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Admin uploads only
    match /trips/{tripId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(project_id)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // User uploads
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth.uid == userId || get(/databases/$(project_id)/documents/users/$(request.auth.uid)).data.isAdmin == true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

---

## CORS Configuration

تم بالفعل إعداده في `cors.json`:

```json
[
  {
    "origin": ["*"],
    "method": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    "responseHeader": [
      "Content-Type",
      "Authorization",
      "x-goog-resumable",
      "x-goog-meta-*"
    ],
    "maxAgeSeconds": 3600
  }
]
```

لتطبيقها على Cloud Storage:

```bash
gsutil cors set cors.json gs://YOUR_BUCKET_NAME
```

---

## خطوات التطبيق

### 1. Realtime Database Rules

1. ادخل [Firebase Console](https://console.firebase.google.com)
2. اختر المشروع: `app_transport`
3. اذهب إلى: Realtime Database → Rules
4. انسخ الكود من الأعلى والصقه
5. اضغط Publish

### 2. Storage Rules

1. اذهب إلى: Storage → Rules
2. استبدل الكود الحالي بـ:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /trips/{tripId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

3. اضغط Publish

### 3. التحقق

- ✅ اذهب إلى Admin Dashboard
- ✅ أضف رحلة جديدة
- ✅ حاول رفع صورة
- ✅ تحقق من Storage Console لمعرفة إذا تم تحميل الصورة
