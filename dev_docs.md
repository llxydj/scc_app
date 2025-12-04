();
    super.dispose();
  }
}
```

#### **Hash Signature Generation**

**Implementation:**
```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String generateQuizHash(String userId, String quizId, int score, DateTime timestamp, String deviceId) {
  final input = '$userId:$quizId:${timestamp.millisecondsSinceEpoch}:$score:$deviceId';
  final bytes = utf8.encode(input);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

Future<void> submitQuiz(QuizResult result) async {
  final deviceId = await DeviceInfo().getId();
  final hash = generateQuizHash(
    result.userId,
    result.quizId,
    result.score,
    DateTime.now(),
    deviceId
  );
  
  await db.insert('student_progress', {
    'id': Uuid().v4(),
    'user_id': result.userId,
    'quiz_id': result.quizId,
    'score': result.score,
    'total_questions': result.totalQuestions,
    'time_taken': result.elapsedSeconds,
    'completed_at': DateTime.now().toIso8601String(),
    'hash_signature': hash,
    'device_id': deviceId,
    'is_synced': 0
  });
  
  // Add to sync queue
  await syncService.enqueue('student_progress', result.id);
}
```

#### **Activity Logging**

**Logged Metadata:**
- Time per question (array of seconds)
- App pause/resume events
- Answer change events (if student modifies answer before submitting)
- Device info (model, OS version, screen size)
- Geolocation (optional, if enabled by school)

**Storage:**
```dart
class ActivityLog {
  String id;
  String userId;
  String quizId;
  List<int> timePerQuestion;
  int totalPauses;
  List<String> events; // ["paused_at_q3", "resumed_at_q3", "changed_q2_answer"]
  String deviceModel;
  String osVersion;
}
```

#### **Teacher Validation Dashboard**

**UI Requirements:**
- Student list with verification badges:
  - ✅ Green: Verified (hash matches, no suspicious activity)
  - ⚠️ Yellow: Flagged (suspicious patterns detected)
  - ❌ Red: Failed revalidation
- Click student → Detailed activity view:
  - Time per question chart (bar chart)
  - Session timeline (pause/resume events)
  - Comparison to class average
- "Request Revalidation" button:
  - Generates 5 random questions from same module
  - Student must pass (≥60%) to verify original score

**Implementation:**
```dart
class TeacherValidationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
        .collection('student_progress')
        .where('class_code', isEqualTo: teacherClassCode)
        .snapshots(),
      builder: (context, snapshot) {
        final results = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index].data() as Map<String, dynamic>;
            final status = _getVerificationStatus(result);
            return ListTile(
              leading: _getStatusIcon(status),
              title: Text(result['student_name']),
              subtitle: Text('Score: ${result['score']}/${result['total_questions']}'),
              trailing: status == 'flagged' ? ElevatedButton(
                onPressed: () => _requestRevalidation(result['user_id'], result['quiz_id']),
                child: Text('Revalidate')
              ) : null,
            );
          }
        );
      }
    );
  }
  
  String _getVerificationStatus(Map<String, dynamic> result) {
    // Check hash validity
    final expectedHash = generateQuizHash(/*...*/);
    if (result['hash_signature'] != expectedHash) return 'failed';
    
    // Check for suspicious activity
    if (result['total_pauses'] > 3) return 'flagged';
    if (result['time_taken'] < result['total_questions'] * 10) return 'flagged'; // Less than 10s per question
    
    return 'verified';
  }
}
```

---

### **4.5 UI/UX Components**

#### **Design System**

**Color Palette:**
- Primary: `#4CAF50` (Green) - Academic, growth
- Secondary: `#2196F3` (Blue) - Trust, intelligence
- Accent: `#FFC107` (Amber) - Gamification, rewards
- Error: `#F44336` (Red)
- Success: `#8BC34A` (Light Green)
- Warning: `#FF9800` (Orange)

**Typography:**
- Headings: `Poppins` (Bold, 24-32sp)
- Body: `Roboto` (Regular, 16sp)
- Captions: `Roboto` (Light, 12sp)

**Icons:**
- Use `lucide_icons` package for consistency
- Subject icons: Custom illustrations (Math: 🔢, Science: 🔬, English: 📚, Filipino: 🇵🇭)

#### **Screen Layouts**

**1. Student Home Screen**
```
┌─────────────────────────────────────┐
│  👤 Hi, Juan!          🔥 7 days    │
│  ⭐ 450 points                       │
├─────────────────────────────────────┤
│  Continue Learning                  │
│  ┌─────────────┐  ┌─────────────┐  │
│  │  📐 Math    │  │  🔬 Science │  │
│  │  75% done   │  │  60% done   │  │
│  └─────────────┘  └─────────────┘  │
│  ┌─────────────┐  ┌─────────────┐  │
│  │  📚 English │  │  🇵🇭 Filipino│  │
│  │  50% done   │  │  80% done   │  │
│  └─────────────┘  └─────────────┘  │
├─────────────────────────────────────┤
│  📋 Assigned Tasks (3)              │
│  • Fractions Quiz (Due: Dec 5)      │
│  • Flashcards: Verbs (Due: Dec 6)   │
├─────────────────────────────────────┤
│  🏆 Achievements   📊 Progress      │
└─────────────────────────────────────┘
```

**2. Quiz Screen**
```
┌─────────────────────────────────────┐
│  ← Fractions Quiz        ⏱️ 03:24   │
│  Question 5 of 10       [━━━━━━---] │
├─────────────────────────────────────┤
│                                     │
│  What is 3/4 + 1/4?                 │
│                                     │
│  ○ 4/4                              │
│  ○ 4/8                              │
│  ○ 1/2                              │
│  ○ 2/4                              │
│                                     │
│           [Next Question]           │
└─────────────────────────────────────┘
```

**3. Teacher Dashboard**
```
┌─────────────────────────────────────┐
│  📊 Class: Grade 4-A                │
│  👥 32 students  ✅ 28 active today │
├─────────────────────────────────────┤
│  Performance Overview               │
│  ┌───────────────────────────────┐ │
│  │  📈 Avg Score: 85%            │ │
│  │  Bar chart: Math>Sci>Eng>Fil  │ │
│  └───────────────────────────────┘ │
├─────────────────────────────────────┤
│  Quick Actions                      │
│  [➕ Create Content]  [📂 Upload]   │
│  [📝 Assign Module]   [📊 Reports]  │
├─────────────────────────────────────┤
│  Recent Activity                    │
│  • Maria completed "Photosynthesis" │
│  • Juan earned "Scholar" badge      │
│  ⚠️ Pedro: No activity (7 days)     │
└─────────────────────────────────────┘
```

#### **Animations**

**Required Animations:**
- Points earned: Counter animates from 0 to earned amount (duration: 1s)
- Badge unlock: Badge scales from 0 to 1.2x to 1.0x, with confetti particles
- Correct answer: Green checkmark fades in + haptic feedback (vibration)
- Incorrect answer: Red X shakes left-right + softer haptic
- Streak flame: Flickers using `AnimatedOpacity`
- Progress bars: Smooth fill using `AnimatedContainer`
- Page transitions: Slide from right (forward) or left (back)

**Implementation Example:**
```dart
class PointsAnimation extends StatefulWidget {
  final int points;
  
  @override
  _PointsAnimationState createState() => _PointsAnimationState();
}

class _PointsAnimationState extends State<PointsAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _animation = IntTween(begin: 0, end: widget.points).animate(_controller);
    _controller.forward();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '+${_animation.value}',
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber)
        );
      }
    );
  }
}
```

#### **Accessibility**

**Text Scaling:**
- Implement using `MediaQuery.of(context).textScaleFactor`
- All text widgets must respect scale factor (min: 0.8, max: 1.5)
- Test at 1.0x, 1.2x, 1.5x scales

**High-Contrast Mode:**
- Detect system preference: `MediaQuery.of(context).highContrast`
- Alternative color scheme: Black/White with bright accent colors
- Minimum contrast ratio: 7:1 for text

**Screen Reader Support:**
- All interactive elements must have `Semantics` labels
- Example:
  ```dart
  Semantics(
    label: 'Option A: 3/4',
    button: true,
    child: RadioButton(...)
  )
  ```

**Audio Narration (Future Enhancement):**
- Use `flutter_tts` package
- "Speak" button on quiz questions
- Auto-read feedback messages

**Alt Text for Images:**
- All `Image` widgets must have `semanticLabel`
- Example:
  ```dart
  Image.asset(
    'assets/images/fraction_diagram.png',
    semanticLabel: 'Diagram showing 3 out of 4 parts shaded'
  )
  ```

---

### **4.6 Notifications & Reminders**

#### **In-App Alerts**

**Types:**
- New assignment available
- Badge unlocked
- Streak warning (no activity today, 2 hours before midnight)
- Quiz graded by teacher

**Display:**
- Banner notification at top of screen (auto-dismiss after 5s)
- Persistent dot badge on "Tasks" tab icon

**Implementation:**
```dart
class NotificationService {
  void showInAppAlert(String title, String message, {String? action}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      mainButton: action != null ? TextButton(
        onPressed: () => _handleAction(action),
        child: Text('View', style: TextStyle(color: Colors.white))
      ) : null
    );
  }
}
```

#### **Push Notifications**

**Setup:**
- Use Firebase Cloud Messaging (FCM)
- Request permission on first app launch
- Store device token in Firestore

**Triggers:**
- Teacher assigns new module → "📝 New assignment: Fractions Quiz"
- Quiz due in 24 hours → "⏰ Reminder: Quiz due tomorrow"
- Streak about to break → "🔥 Don't break your 7-day streak!"
- Parent: child completes quiz → "✅ Maria scored 9/10 on Science quiz"

**Implementation:**
```dart
class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    await _fcm.requestPermission();
    String? token = await _fcm.getToken();
    
    // Save token to Firestore
    await firestore.collection('users').doc(currentUserId).update({'fcm_token': token});
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      notificationService.showInAppAlert(
        message.notification?.title ?? '',
        message.notification?.body ?? ''
      );
    });
  }
}
```

---

## **5. TECHNICAL ARCHITECTURE & IMPLEMENTATION**

### **5.1 Tech Stack**

| Component | Technology |
|-----------|-----------|
| **Framework** | Flutter 3.24+ |
| **Language** | Dart 3.5+ |
| **State Management** | Riverpod 2.5+ |
| **Local Database** | sqflite 2.3+ |
| **Cloud Backend** | Firebase (Auth, Firestore, Storage, FCM, Analytics) |
| **File Parsing** | csv 5.1+, excel 4.0+ |
| **Encryption** | encrypt 5.0+, flutter_secure_storage 9.0+ |
| **Networking** | connectivity_plus 6.0+ |
| **Charts** | fl_chart 0.68+ |
| **PDF Generation** | pdf 3.11+ |
| **Image Handling** | image_picker 1.1+, cached_network_image 3.3+ |
| **Testing** | flutter_test, mockito 5.4+, integration_test |

### **5.2 Project Structure**

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_routes.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── device_info.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── sync_service.dart
│   │   ├── notification_service.dart
│   │   ├── points_service.dart
│   │   └── analytics_service.dart
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── quiz_model.dart
│   │   ├── flashcard_model.dart
│   │   └── progress_model.dart
│   ├── repositories/
│   │   ├── user_repository.dart
│   │   ├── content_repository.dart
│   │   └── progress_repository.dart
│   └── datasources/
│       ├── local/
│       │   ├── database_helper.dart
│       │   └── sqflite_datasource.dart
│       └── remote/
│           └── firebase_datasource.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── quiz.dart
│   │   └── flashcard.dart
│   └── usecases/
│       ├── take_quiz_usecase.dart
│       ├── submit_quiz_usecase.dart
│       └── upload_content_usecase.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── quiz_provider.dart
│   │   └── progress_provider.dart
│   ├── screens/
│   │   ├── student/
│   │   │   ├── home_screen.dart
│   │   │   ├── quiz_screen.dart
│   │   │   ├── flashcard_screen.dart
│   │   │   └── achievements_screen.dart
│   │   ├── teacher/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── create_content_screen.dart
│   │   │   ├── upload_file_screen.dart
│   │   │   └── validation_screen.dart
│   │   └── shared/
│   │       ├── login_screen.dart
│   │       └── settings_screen.dart
│   └── widgets/
│       ├── subject_card.dart
│       ├── progress_bar.dart
│       ├── badge_icon.dart
│       └── custom_button.dart
└── assets/
    ├── images/
    ├── icons/
    ├── data/
    │   └── quiz_data.json
    └── i18n/
        ├── en.json
        └── fil.json
```

### **5.3 Database Schema (SQLite)**

**Full Schema:**
```sql
-- Users table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT,
  role TEXT CHECK(role IN ('student', 'teacher', 'parent')),
  grade_level INTEGER,
  class_code TEXT,
  points INTEGER DEFAULT 0,
  streak INTEGER DEFAULT 0,
  last_active_date TEXT,
  language_preference TEXT DEFAULT 'en',
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT
);

-- Quiz questions table
CREATE TABLE quiz_questions (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL,
  grade_level INTEGER NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT CHECK(question_type IN ('mcq', 'true_false', 'image_based')),
  options TEXT, -- JSON array: ["Option1", "Option2", "Option3", "Option4"]
  correct_answer TEXT NOT NULL,
  image_url TEXT,
  explanation TEXT,
  difficulty INTEGER CHECK(difficulty BETWEEN 1 AND 3),
  tags TEXT, -- JSON array: ["fractions", "addition"]
  created_by TEXT, -- teacher_id
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT
);

-- Flashcards table
CREATE TABLE flashcards (
  id TEXT PRIMARY KEY,
  subject TEXT NOT NULL,
  grade_level INTEGER NOT NULL,
  front TEXT NOT NULL,
  back TEXT NOT NULL,
  front_image_url TEXT,
  back_image_url TEXT,
  tags TEXT, -- JSON array
  created_by TEXT,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  synced_at TEXT
);

-- Student progress table
CREATE TABLE student_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  quiz_id TEXT NOT NULL,
  score INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  time_taken INTEGER, -- seconds
  time_per_question TEXT, -- JSON array: [12, 15, 8, ...]
  completed_at TEXT DEFAULT CURRENT_TIMESTAMP,
  hash_signature TEXT NOT NULL,
  device_id TEXT NOT NULL,
  is_verified INTEGER DEFAULT 0, -- 0 = pending, 1 = verified, -1 = flagged
  is_synced INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (quiz_id) REFERENCES quiz_questions(id)
);

-- Badges table
CREATE TABLE badges (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon_url TEXT,
  requirement_type TEXT, -- 'points', 'streak', 'subject_completion'
  requirement_value INTEGER,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- User badges (junction table)
CREATE TABLE user_badges (
  user_id TEXT NOT NULL,
  badge_id TEXT NOT NULL,
  unlocked_at TEXT DEFAULT CURRENT_TIMESTAMP,
  is_synced INTEGER DEFAULT 0,
  PRIMARY KEY (user_id, badge_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (badge_id) REFERENCES badges(id)
);

-- Activity logs table
CREATE TABLE activity_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  quiz_id TEXT,
  event_type TEXT, -- 'app_paused', 'app_resumed', 'answer_changed'
  event_data TEXT, -- JSON object
  timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
  is_synced INTEGER DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Sync queue table
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_name TEXT NOT NULL,
  record_id TEXT NOT NULL,
  operation TEXT CHECK(operation IN ('INSERT', 'UPDATE', 'DELETE')),
  data TEXT, -- JSON of record
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  retry_count INTEGER DEFAULT 0,
  last_error TEXT
);

-- Assignments table
CREATE TABLE assignments (
  id TEXT PRIMARY KEY,
  teacher_id TEXT NOT NULL,
  class_code TEXT NOT NULL,
  module_id TEXT NOT NULL, -- references quiz_questions.id or flashcards.id
  module_type TEXT CHECK(module_type IN ('quiz', 'flashcard')),
  title TEXT NOT NULL,
  instructions TEXT,
  due_date TEXT,
  assigned_to TEXT, -- JSON array of user_ids, or 'all'
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  is_synced INTEGER DEFAULT 0,
  FOREIGN KEY (teacher_id) REFERENCES users(id)
);

-- Indexes for performance
CREATE INDEX idx_users_class_code ON users(class_code);
CREATE INDEX idx_quiz_subject_grade ON quiz_questions(subject, grade_level);
CREATE INDEX idx_progress_user ON student_progress(user_id);
CREATE INDEX idx_progress_quiz ON student_progress(quiz_id);
CREATE INDEX idx_progress_synced ON student_progress(is_synced);
CREATE INDEX idx_sync_queue_retry ON sync_queue(retry_count);
CREATE INDEX idx_assignments_class ON assignments(class_code);
```

### **5.4 Firebase Firestore Schema**

**Collections:**

1. **users** (mirrors local users table)
   ```
   /users/{userId}
   {
     "name": "Juan Dela Cruz",
     "email": "juan@example.com",
     "role": "student",
     "grade_level": 4,
     "class_code": "GR4-A-2024",
     "points": 450,
     "streak": 7,
     "last_active_date": "2024-12-04T08:00:00Z",
     "language_preference": "fil",
     "fcm_token": "abc123...",
     "created_at": Timestamp,
     "updated_at": Timestamp
   }
   ```

2. **quiz_questions**
   ```
   /quiz_questions/{questionId}
   {
     "subject": "Math",
     "grade_level": 4,
     "question_text": "What is 3/4 + 1/4?",
     "question_type": "mcq",
     "options": ["4/4", "4/8", "1/2", "2/4"],
     "correct_answer": "4/4",
     "image_url": "https://...",
     "explanation": "When adding fractions with same denominator...",
     "difficulty": 2,
     "tags": ["fractions", "addition"],
     "created_by": "teacher123",
     "created_at": Timestamp
   }
   ```

3. **student_progress**
   ```
   /student_progress/{progressId}
   {
     "user_id": "student123",
     "quiz_id": "quiz456",
     "score": 8,
     "total_questions": 10,
     "time_taken": 240,
     "time_per_question": [12, 15, 8, 25, 18, 30, 20, 22, 40, 50],
     "completed_at": Timestamp,
     "hash_signature": "abc123...",
     "device_id": "device789",
     "is_verified": 1
   }
   ```

4. **classes**
   ```
   /classes/{classCode}
   {
     "name": "Grade 4 - Section A",
     "teacher_id": "teacher123",
     "grade_level": 4,
     "student_ids": ["student1", "student2", ...],
     "leaderboard_enabled": true,
     "created_at": Timestamp
   }
   ```

5. **assignments**
   ```
   /assignments/{assignmentId}
   {
     "teacher_id": "teacher123",
     "class_code": "GR4-A-2024",
     "module_id": "quiz456",
     "module_type": "quiz",
     "title": "Fractions Quiz",
     "instructions": "Complete before Friday",
     "due_date": Timestamp,
     "assigned_to": ["student1", "student2"] or "all",
     "created_at": Timestamp
   }
   ```

### **5.5 API Integration (If Backend Required)**

**Note:** Firebase handles most backend needs, but if custom API needed:

**Endpoints:**
- `POST /api/auth/login` - Authenticate user
- `GET /api/content/{subject}/{grade}` - Fetch quiz/flashcard content
- `POST /api/progress/submit` - Submit quiz results
- `GET /api/teacher/dashboard/{classCode}` - Fetch class analytics
- `POST /api/teacher/upload` - Upload CSV/XLSX file (alternative to client-side parsing)

**Authentication:**
- Use Firebase ID tokens as Bearer tokens
- Verify tokens on backend using Firebase Admin SDK

---

## **6. SECURITY & DATA MANAGEMENT**

### **6.1 Authentication**

**Student Login:**
- Username + PIN (4-6 digits)
- No email required (reduces friction for young students)
- Store hashed PIN locally using `bcrypt` or `argon2`

**Teacher Login:**
- Email + Password
- Firebase Auth with email/password provider
- Optional: 2FA via SMS (Firebase Phone Auth)

**Parent Login:**
- Unique access code provided by teacher
- Maps to student_id in database
- Read-only permissions

### **6.2 Data Encryption**

**Local Database Encryption:**
```dart
import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final key = Key.fromSecureRandom(32); // AES-256
  final iv = IV.fromSecureRandom(16);
  final encrypter = Encrypter(AES(key));
  
  String encrypt(String plainText) {
    return encrypter.encrypt(plainText, iv: iv).base64;
  }
  
  String decrypt(String encrypted) {
    return encrypter.decrypt64(encrypted, iv: iv);
  }
}
```

**Secure Storage for Keys:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
await storage.write(key: 'encryption_key', value: encryptionKey);
```

### **6.3 Privacy Compliance**

**Data Minimization:**
- No unnecessary PII collected (no full addresses, phone numbers)
- Student profiles: name, grade, class code only
- Parents opt-in for email summaries

**Consent:**
- First-time setup: Parental consent form (digital signature)
- Privacy policy displayed during onboarding
- "I agree" checkbox required before account creation

**Data Retention:**
- Student progress data retained for 2 academic years
- Deleted accounts anonymized (data retained for analytics, PII removed)

**GDPR/COPPA Compliance:**
- Right to access: Export all user data as JSON
- Right to deletion: Delete account + all associated data
- Age verification: Require parent email for students under 13

### **6.4 Content Moderation**

**Teacher-Generated Content:**
- Automated profanity filter on all text inputs
- Manual review required for custom modules before publishing to entire school
- Report button for students/parents to flag inappropriate content

**Implementation:**
```dart
class ContentModerationService {
  final List<String> bannedWords = ['list', 'of', 'words'];
  
  bool containsProfanity(String text) {
    return bannedWords.any((word) => text.toLowerCase().contains(word));
  }
  
  Future<void> submitForReview(String contentId) async {
    await firestore.collection('pending_review').add({
      'content_id': contentId,
      'submitted_at': FieldValue.serverTimestamp()
    });
  }
}
```

---

## **7. UI/UX REQUIREMENTS**

### **7.1 Design Principles**

1. **Child-Friendly:**
   - Large tap targets (minimum 48x48 dp)
   - High contrast colors
   - Simple language (avoid jargon)
   - Visual feedback for all interactions

2. **Culturally Appropriate:**
   - Filipino names/scenarios in examples
   - Local imagery (jeepneys, sari-sari stores, etc.)
   - Respect for Filipino values (family, respect for elders)

3. **Performance:**
   - Smooth animations (60 FPS)
   - Fast load times (<2s for quiz screen)
   - Minimal battery drain (optimize background tasks)

### **7.2 Responsive Design**

**Support Multiple Screen Sizes:**
- Phones: 5.5" to 6.7" (most common in PH)
- Tablets: 7" to 10" (for classroom use)
- Landscape orientation for quizzes (optional)

**Implementation:**
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else {
          return tablet;
        }
      }
    );
  }
}
```

### **7.3 Onboarding Flow**

**First-Time User Experience:**
1. Welcome screen (app logo + tagline)
2. Role selection: "I am a Student / Teacher / Parent"
3. Registration form (specific to role)
4. Quick tutorial:
   - Student: How to take quiz, view progress
   - Teacher: How to create content, assign modules
5. Sample content loaded (demo quiz)
6. Redirect to home screen

**Tutorial Implementation:**
- Use `flutter_intro` package for interactive walkthroughs
- Skip option available
- "Show again" toggle in Settings

---

## **8. TESTING & QUALITY ASSURANCE** ENSURE AND CHECK ALWAYS CODEBASE

### **8.1 Test Coverage Requirements**

**Minimum Coverage:** 80% (unit + integration tests)

**Critical Paths to Test:**
- User authentication (login/logout)
- Quiz submission + hash generation
- Offline → Online sync
- Points calculation

+ badge unlock
- File upload + CSV/XLSX parsing
- Teacher validation logic

### **8.2 Unit Tests**

**Example:**
```dart
void main() {
  group('PointsService', () {
    late PointsService pointsService;
    
    setUp(() {
      pointsService = PointsService();
    });
    
    test('should award 10 points per correct answer', () {
      final points = pointsService.calculateQuizPoints(score: 8, total: 10);
      expect(points, 80);
    });
    
    test('should award 100 bonus for perfect score', () {
      final points = pointsService.calculateQuizPoints(score: 10, total: 10);
      expect(points, 200); // 100 (base) + 100 (bonus)
    });
  });
}
```

### **8.3 Integration Tests**

**Example: Take Quiz Flow**
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete quiz flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Login
    await tester.enterText(find.byKey(Key('username_field')), 'test_student');
    await tester.enterText(find.byKey(Key('pin_field')), '1234');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();
    
    // Navigate to Math
    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();
    
    // Take quiz
    await tester.tap(find.text('Fractions Quiz'));
    await tester.pumpAndSettle();
    
    // Answer all questions
    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byType(RadioListTile).first);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    
    // Verify results screen
    expect(find.text('Quiz Complete!'), findsOneWidget);
    expect(find.textContaining('points'), findsOneWidget);
  });
}
```

### **8.4 Manual Testing Checklist** CHECK CODEBASE

**Pre-Release QA:**
- [ ] All screens render correctly on 3 device sizes
- [ ] Offline mode works (disable WiFi/data)
- [ ] Sync completes within 30s of reconnection
- [ ] Animations run smoothly (no jank)
- [ ] Text legible at 1.5x scale
- [ ] High-contrast mode readable
- [ ] Screen reader announces all elements
- [ ] File upload works for CSV/XLSX
- [ ] Invalid files show error messages
- [ ] Teacher dashboard loads class data
- [ ] Leaderboard updates correctly
- [ ] Push notifications arrive promptly
- [ ] Badge unlock animation plays
- [ ] Streak resets after missed day
- [ ] Quiz hash validates correctly
- [ ] Suspicious activity flagged

---

## **9. DEPLOYMENT & DELIVERY**

### **9.1 Build Configuration**

**Android (build.gradle):**
```gradle
android {
    compileSdkVersion 34
    minSdkVersion 21
    targetSdkVersion 34
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```


### **Deliverables Checklist**

**Code:**
- [ ] GitHub repository (public or private)
- [ ] README with setup instructions
- [ ] LICENSE file (MIT/Apache 2.0)
- [ ] CONTRIBUTING.md (for open-source)
- [ ] .gitignore fully ready configured

**Documentation:**
- [ ] User Manual (PDF, 20-30 pages)
  - Student guide (pages 1-8)
  - Teacher guide (pages 9-22)
  - Parent guide (pages 23-26)
  - FAQ (pages 27-30)
- [ ] Technical Documentation
  - Architecture overview
  - Database schema
  - API reference (if applicable)
  - Deployment guide
- [ ] Video Tutorials (5-10 min each)
  - Student: How to take quiz
  - Student: How to review flashcards
  - Teacher: How to upload content
  - Teacher: How to monitor progress

**Content:**
- [ ] Preloaded quiz questions (1,800 total)
- [ ] Preloaded flashcards (710 total)
- [ ] Badge icon assets (7 images)
- [ ] Subject icon assets (4 images)

**App Binaries:**
- [ ] Android APK (signed, release build)
- [ ] Android AAB (for Play Store)
- [ ] iOS IPA (ad-hoc or App Store distribution)

---

## **10. DEVELOPMENT TIMELINE & MILESTONES**

### **10.1 Phase 1: Foundation (Weeks 1-2)**

**Deliverables:**
- [x] Project setup (Flutter, Firebase)
- [x] Database schema implemented
- [x] Authentication (student/teacher login)
- [x] Basic navigation (bottom nav, routing)
- [x] UI design system (colors, typography)

**Testing:** Unit tests for auth service

---

### **10.2 Phase 2: Core Features (Weeks 3-5)**

**Deliverables:**
- [x] Quiz taking flow (MCQ, T/F)
- [x] Flashcard review
- [x] Points system + badge unlocking
- [x] Offline storage (sqflite)
- [x] Subject modules preloaded

**Testing:** Integration tests for quiz flow

---

### **10.3 Phase 3: Teacher Tools (Weeks 6-7)**


**Deliverables:**
- [x] Teacher dashboard
- [x] Manual content creation
- [x] File upload + parsing (CSV/XLSX)
- [x] Assignment system
- [x] Progress monitoring

**Testing:** CSV parsing unit tests, teacher workflow tests

---

### **10.4 Phase 4: Validation & Sync (Week 8)**

**Deliverables:**
- [x] Progress validation (hash, activity logs)
- [x] Cloud sync service
- [x] Conflict resolution
- [x] Notifications (in-app + push)

**Testing:** Sync stress tests (100+ records)

---

### **10.5 Phase 5: Polish & QA (Week 9)**

**Deliverables:**
- [x] Animations + transitions
- [x] Accessibility features
- [x] Error handling
- [x] Performance optimization
- [x] Bug fixes

**Testing:** Full regression testing, manual QA checklist

---

### **10.6 Phase 6: Deployment (Week 10)**

**Deliverables:**
- [x] App store builds (Android + iOS)
- [x] Documentation completed
- [x] Video tutorials recorded
- [x] Open-source repo prepared
- [x] Submission to app stores

---

## **11. CRITICAL SUCCESS FACTORS**

### **11.1 Must-Have Features (MVP)**

✅ These MUST be fully functional in the first release:

1. Student can take quizzes offline
2. Student can review flashcards offline
3. Student sees points + badges
4. Teacher can upload CSV/XLSX files
5. Teacher can view student progress
6. Progress validation (hash + activity logs)
7. Sync works offline → online
8. Push notifications for assignments

### **11.2 Nice-to-Have Features (Future Enhancements)**

🔮 These can be added in v1.1+:

- Audio narration for questions
- Drag-and-drop question types
- Parent mobile app (separate from student app)
- AI-generated quiz questions
- Video lessons
- Peer-to-peer challenges (student vs student)
- School-wide leaderboard

### **11.3 Known Limitations**

⚠️ Acknowledge these constraints:

- File upload limited to 5MB per file
- Maximum 50 students per class (Firestore query limit)
- Image storage limited by Firebase free tier (1GB)
- No real-time collaboration (e.g., live quiz competitions)

---

## **12. SUPPORT & MAINTENANCE**

### **12.1 Post-Launch Support**

**Bug Fixes:**
- Critical bugs: 24-hour response
- Major bugs: 1-week patch release
- Minor bugs: Next version release

**User Support:**
- In-app help center
- Email support: support@klasroom.app
- FAQ section in settings

### **12.2 Updates & Versioning**

**Versioning Scheme:** MAJOR.MINOR.PATCH
- Example: 1.0.0 (initial release)
- 1.1.0 (new features)
- 1.0.1 (bug fixes)

**Update Frequency:**
- Monthly minor updates (new content, features)
- Weekly patches (critical bugs)

---

## **13. CONTACT & ESCALATION**

**Project Lead:** [Your Name]  
**Email:** [Your Email]  
**Phone:** [Your Phone]

**For Critical Issues:**
- Production bugs: Escalate immediately
- Security vulnerabilities: Contact within 1 hour
- Data loss incidents: Emergency protocol

---

## **APPENDIX A: Package Dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  
  # Local Database
  sqflite: ^2.3.3+1
  path_provider: ^2.1.3
  
  # Firebase
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
  firebase_analytics: ^11.0.0
  
  # File Handling
  file_picker: ^8.0.0+1
  csv: ^5.1.1
  excel: ^4.0.2
  image_picker: ^1.1.1
  
  # Encryption & Security
  encrypt: ^5.0.3
  flutter_secure_storage: ^9.2.2
  crypto: ^3.0.3
  
  # UI Components
  fl_chart: ^0.68.0
  cached_network_image: ^3.3.1
  lottie: ^3.1.2
  flutter_svg: ^2.0.10+1
  
  # Utilities
  connectivity_plus: ^6.0.3
  device_info_plus: ^10.1.0
  url_launcher: ^6.3.0
  share_plus: ^9.0.0
  intl: ^0.19.0
  uuid: ^4.4.0
  
  # PDF Generation
  pdf: ^3.11.0
  
  # Testing (dev_dependencies)
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

---

## **APPENDIX B: Sample CSV Template**

**quiz_template.csv:**
```csv
Question,Option1,Option2,Option3,Option4,CorrectAnswer,Subject,GradeLevel,Difficulty
"What is 3 + 5?","6","7","8","9","8","Math","1","1"
"The capital of the Philippines is...","Manila","Cebu","Davao","Quezon City","Manila","Filipino","2","1"
```

**flashcard_template.csv:**
```csv
Front,Back,Subject,GradeLevel
"Photosynthesis","Process by which plants make food using sunlight","Science","4"
"Noun","A word that names a person, place, or thing","English","3"
```

---

## **APPENDIX C: User Stories Summary**

| ID | As a... | I want to... | So that... |
|----|---------|--------------|------------|
| US-1 | Student | Create my profile | I can track my progress |
| US-2 | Student | Take quizzes offline | I'm not blocked by connectivity |
| US-3 | Student | See my points and badges | I feel motivated |
| US-4 | Teacher | Upload CSV files | I save time creating content |
| US-5 | Teacher | Monitor student progress | I identify struggling students |
| US-6 | Teacher | Assign modules | Students know what to study |
| US-7 | Parent | View my child's report | I support their learning |
| US-8 | Admin | Generate class reports | I share performance with school |

---

## **FINAL CHECKLIST FOR DEVELOPERS**

Before starting development, ensure:

- [ ] All requirements in sections 1-10 are understood
- [ ] Firebase project created and configured
- [ ] Flutter development environment set up
- [ ] Access to design assets (icons, images)
- [ ] Sample content data available (quiz questions)
- [ ] Database schema script ready
- [ ] Git repository initialized
- [ ] Team roles assigned (if team project)
- [ ] Communication channels established (Slack, Discord)
- [ ] Weekly sprint planning scheduled

---

## **APPROVAL & SIGN-OFF**

**Student Developer:** _____________________ Date: _______

**Professor:** _____________________ Date: _______

**Stakeholder:** _____________________ Date: _______

---

**END OF DOCUMENT**

*This specification is production-ready and fully bulletproof. All features are clearly defined, technically feasible, and aligned with the project's educational mission. Time to build! 🚀*