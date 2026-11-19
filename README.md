# BoomChat Talent

> **The extra ordinary Untold**  
> *Aluta Continua*  
> *"Living rightly with God and fellow people"*

**Lead Developer:** TALENT BRUICE  
**Co-Developer:** MYSTERY NKORE  
**App Version:** 1.0.0 (Release)

---

## 🌟 Overview

**BoomChat Talent** is an All-in-One native Android ecosystem engineered to provide:
1. **Instant Secure Communication** (WhatsApp-style text messaging, voice notes recording, WebRTC audio/video calls, 24-hour status stories, file sharing, and granular privacy settings).
2. **Universal Storage File Explorer & Multi-Format In-App Viewer** (Explore full internal storage `/storage/emulated/0`, with native rendering for PDF, Word documents, PowerPoint presentations, Excel spreadsheets, all image formats, all video codecs, and all audio types).
3. **Christian Spiritual Growth Sanctuary** (Inspired by *Lectio Divina*, *Pray As You Go*, *Devote Study Bible*, and *Faithlife*):
   - **Lectio Divina & Guided Prayer**: 5-step prayer cycle (*Silencio*, *Lectio*, *Meditatio*, *Oratio*, *Contemplatio*) with countdown bells and journaling.
   - **Dramatized Audio Bible**: Multi-character spoken audio synchronized with real-time scrolling scripture text.
   - **Daily Guided Audio Prayer Portal**: Upload and stream daily prayers with matching prayer text transcripts.
   - **Daily Guided Audio Scripture Portal**: Upload and listen to audio scripture with corresponding verses.
   - **GraceReels (Godly Short Videos)**: TikTok-style vertical scrolling feed of Christian videos, testimonies, and gospel messages with community upload.
   - **Spiritual Growth Videos**: Full-length sermon and expository video library.
   - **Christian Music Sanctuary**: Pure audio Christian music, worship, hymns, and praise with dedicated waveform player and zero text clutter.
   - **Live Bible Study Classroom**: Teach and study the Bible in bite-sized chunks alongside the scripture text with interactive commentary.
   - **Guided Daily Devotionals**: Daily reading with scripture of the day, practical application, and prayer points.
4. **Email Verification & Mandatory User Profile Setup**: Clean initial template state ready for first-time use without pre-existing mock clutter.

---

## 📱 Architecture & Folder Layout

```
boomchat_talent/
├── android/                             # Native Android configuration
│   └── app/
│       ├── build.gradle                 # compileSdkVersion 34, Android 14+
│       └── src/main/AndroidManifest.xml # All phone & storage permissions
├── lib/
│   ├── main.dart                        # Initialization, permissions, AuthGate & main tabs
│   ├── core/
│   │   ├── constants/app_credentials.dart # Talent Bruice, Mystery Nkore & mottos
│   │   ├── theme/app_theme.dart          # Elegant dark theme with Gold & Teal accents
│   │   └── permissions/permission_handler_service.dart
│   └── features/
│       ├── auth/                        # Email sign in, sign up, verification & profile setup
│       ├── file_explorer/               # Internal storage explorer & Universal File Viewer
│       ├── chat/                        # Messaging, voice notes, calls, stories & settings
│       ├── spiritual/                   # Lectio Divina, Audio Bible, Prayers, Music, Reels
│       └── developer/                   # Developer Credentials & Manifesto
├── .github/workflows/build_apk.yml       # Cloud compilation to downloadable .apk
├── firestore.rules                      # Production security rules
├── storage.rules                        # Media & audio/video storage rules
├── firebase.json                        # Firebase config
└── pubspec.yaml                         # Dependencies
```

---

## 🚀 How to Build & Download the `.apk` File

### Option 1: Instant 1-Click Cloud Build via GitHub Actions (Recommended)
1. Push this folder to a GitHub repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for BoomChat Talent"
   git remote add origin https://github.com/YOUR_USERNAME/boomchat_talent.git
   git push -u origin main
   ```
2. Navigate to your repository on GitHub and click on the **Actions** tab.
3. The **"Build BoomChat Talent APK"** workflow will compile the release APK automatically.
4. Once finished (2-3 minutes), download `BoomChat_Talent_v1.0.apk` directly onto your phone and tap **Install**!

### Option 2: Local Compilation on PC / Laptop
Run the following in the project root:
```bash
flutter pub get
flutter build apk --release
```
The compiled APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`
