# Firebase Setup Guide for PawPal

## ⚠️ CRITICAL: You Must Create Your Own Firebase Project

This repository has been prepared for handoff with all sensitive Firebase credentials removed. **You cannot run this app without setting up your own Firebase project first.**

## Why You Need Your Own Firebase Project

- **Security**: Sharing Firebase credentials is a security risk
- **Data Isolation**: Your data should be separate from the original project
- **Cost Control**: You need to manage your own Firebase billing and quotas
- **Access Control**: You need full admin access to your Firebase console

---

## Complete Setup Instructions

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"** or **"Create a project"**
3. Enter a project name (e.g., `pawpal-yourteamname`)
4. Choose whether to enable Google Analytics (recommended for production)
5. Click **"Create project"** and wait for it to finish

### Step 2: Add an iOS App to Your Firebase Project

1. In your Firebase project dashboard, click the **iOS icon** (or **"Add app"** → **iOS**)
2. Register your app with these details:
   - **iOS bundle ID**: `com.yourcompany.PawPal` (or your preferred bundle ID)
     - ⚠️ **Important**: You'll need to update this in Xcode later to match
   - **App nickname** (optional): `PawPal iOS`
   - **App Store ID** (optional): Leave blank for now

3. Click **"Register app"**

### Step 3: Download GoogleService-Info.plist

1. After registering, Firebase will prompt you to download **GoogleService-Info.plist**
2. Click **"Download GoogleService-Info.plist"**
3. Save this file - you'll need it in the next step

   > 💡 **Tip**: If you missed this step, you can always download it later:
   > - Go to Project Settings (gear icon) → Your apps → iOS app
   > - Scroll down and click "Download GoogleService-Info.plist"

### Step 4: Add GoogleService-Info.plist to Xcode

1. Open Xcode and open the **PawPal.xcodeproj** file
2. In the Project Navigator (left sidebar), right-click on the **PawPal** folder
3. Select **"Add Files to 'PawPal'..."**
4. Navigate to your downloaded **GoogleService-Info.plist** file
5. **IMPORTANT**: Make sure these options are checked:
   - ✅ **"Copy items if needed"**
   - ✅ **"Add to targets: PawPal"**
6. Click **"Add"**

7. **Verify the file was added correctly**:
   - Select the GoogleService-Info.plist in Project Navigator
   - In the File Inspector (right sidebar), under "Target Membership"
   - Ensure **PawPal** is checked

### Step 5: Update Info.plist with OAuth Client ID

Your Firebase project created OAuth credentials for Google Sign-In. You need to add them to Info.plist:

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **"Your apps"** section
3. Find your iOS app and expand it
4. Look for **"Client ID"** - it looks like: `123456789-abcdefg.apps.googleusercontent.com`
5. Copy the **full Client ID**

6. In Xcode, open **`PawPal/Resources/Info.plist`**
7. Find the `GIDClientID` key and replace `YOUR-FIREBASE-WEB-CLIENT-ID-HERE` with your **full Client ID**
8. Find `CFBundleURLSchemes` → `Item 0` and replace `com.googleusercontent.apps.YOUR-CLIENT-ID-HERE` with the **reversed Client ID**
   - The reversed Client ID is in your GoogleService-Info.plist as `REVERSED_CLIENT_ID`
   - Or format it as: `com.googleusercontent.apps.123456789-abcdefg`

**Example Info.plist after updates:**
```xml
<key>GIDClientID</key>
<string>123456789-abcdefg.apps.googleusercontent.com</string>

<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.123456789-abcdefg</string>
</array>
```

### Step 6: Update Bundle Identifier in Xcode (If Changed)

If you used a different bundle ID than the original, update it in Xcode:

1. Select the **PawPal project** in Project Navigator (blue icon at top)
2. Select the **PawPal target** under TARGETS
3. Go to the **"General"** tab
4. Under **"Identity"**, update the **Bundle Identifier** to match what you entered in Firebase

---

## Firebase Services Configuration

### Enable Authentication

PawPal uses **Email/Password** and **Google Sign-In** authentication.

1. In Firebase Console, go to **Authentication** (left menu)
2. Click **"Get started"** (if first time)
3. Go to **"Sign-in method"** tab
4. Enable these providers:

   **Email/Password:**
   - Click on "Email/Password"
   - Toggle **"Enable"** to ON
   - Click **"Save"**

   **Google:**
   - Click on "Google"
   - Toggle **"Enable"** to ON
   - Enter a **"Project support email"** (your email)
   - Click **"Save"**

### Create Firestore Database

PawPal uses Firestore for storing user profiles, posts, and lost pet reports.

1. In Firebase Console, go to **Firestore Database** (left menu)
2. Click **"Create database"**
3. Choose **"Start in test mode"** for development
   - ⚠️ **Important**: Test mode allows open access - see Security Rules below
4. Choose a Cloud Firestore location (pick one close to your users)
5. Click **"Enable"**

**Required Collections:**
The app will create these collections automatically:
- `users` - User profiles
- `lost_pets` - Lost pet reports
- `posts` - Community posts

### Enable Firebase Storage

PawPal uses Firebase Storage for user profile images and pet photos.

1. In Firebase Console, go to **Storage** (left menu)
2. Click **"Get started"**
3. Choose **"Start in test mode"** for development
4. Use the default storage location (or change if needed)
5. Click **"Done"**

---

## Security Rules (CRITICAL for Production)

### Firestore Security Rules

⚠️ **Test mode rules expire after 30 days and allow open access. Update them immediately!**

1. Go to **Firestore Database** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profiles - users can read all, but only write their own
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Lost pets - authenticated users can read all, write their own
    match /lost_pets/{petId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                             request.auth.uid == resource.data.userId;
    }
    
    // Community posts - authenticated users can read all, write their own
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                             request.auth.uid == resource.data.userId;
    }
  }
}
```

3. Click **"Publish"**

### Storage Security Rules

1. Go to **Storage** → **Rules** tab
2. Replace the default rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // User images - users can only read/write their own images
    match /user_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Pet images - authenticated users can read all, write to their own
    match /pet_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **"Publish"**

---

## Testing Your Setup

1. **Build the app in Xcode**:
   - Press `Cmd + B` to build
   - Fix any errors related to bundle ID or signing

2. **Run the app**:
   - Press `Cmd + R` or click the Play button
   - Choose a simulator or connect a device

3. **Test authentication**:
   - Try registering a new account with email/password
   - Try signing in with Google (on a real device - simulator has limitations)

4. **Verify Firebase Console**:
   - Check **Authentication** → **Users** - you should see new users
   - Check **Firestore Database** - collections should appear when users create data
   - Check **Storage** - images should appear when users upload photos

---

## Troubleshooting Common Issues

### "No GoogleService-Info.plist found"
- ✅ Make sure the file is in the PawPal target (check Target Membership)
- ✅ Clean build folder: `Product` → `Clean Build Folder` in Xcode
- ✅ Restart Xcode

### "Failed to sign in with Google"
- ✅ Verify `GIDClientID` in Info.plist matches your Firebase Client ID
- ✅ Verify `REVERSED_CLIENT_ID` in CFBundleURLSchemes
- ✅ Google Sign-In doesn't work well in Simulator - test on real device
- ✅ Make sure Google Sign-In is enabled in Firebase Console

### "Permission denied" errors in Firestore/Storage
- ✅ Check that you've published the security rules
- ✅ Verify the user is authenticated before accessing data
- ✅ Check the rules match the userId in your documents

### "App crashes on launch"
- ✅ Verify bundle ID matches between Xcode and Firebase
- ✅ Check that GoogleService-Info.plist is properly added to project
- ✅ Look at the Xcode console for specific Firebase errors

### Build errors about Firebase modules
- ✅ Make sure Firebase packages are properly installed (Swift Package Manager)
- ✅ In Xcode: `File` → `Packages` → `Resolve Package Versions`

---

## Firebase Free Tier Limits (as of 2026)

**Firestore:**
- 50,000 reads/day
- 20,000 writes/day
- 20,000 deletes/day
- 1 GB storage

**Authentication:**
- Unlimited free for Email/Password and Google Sign-In

**Storage:**
- 5 GB storage
- 1 GB/day download
- 20,000 uploads/day

**Tips for staying within limits:**
- Implement pagination for lists
- Cache data locally when possible
- Use Firestore offline persistence
- Compress images before uploading
- Monitor usage in Firebase Console

---

## Next Steps After Setup

1. **Review the source code** to understand the Firebase integration:
   - `Services/AuthService.swift` - Authentication logic
   - `Services/FirestoreService.swift` - Database operations

2. **Customize the app**:
   - Update app icons and branding
   - Modify color schemes in `Extensions/Color+Extensions.swift`
   - Add new features as needed

3. **Prepare for production**:
   - Update security rules to be more restrictive
   - Set up proper iOS code signing
   - Configure Firebase App Distribution for beta testing
   - Enable Firebase Crashlytics for error tracking

4. **Monitor your Firebase project**:
   - Set up budget alerts in Google Cloud Console
   - Monitor usage in Firebase Console
   - Review security rules regularly

---

## Support Resources

- **Firebase Documentation**: https://firebase.google.com/docs
- **Firebase iOS Setup**: https://firebase.google.com/docs/ios/setup
- **Google Sign-In iOS Guide**: https://firebase.google.com/docs/auth/ios/google-signin
- **Firestore Security Rules**: https://firebase.google.com/docs/firestore/security/get-started
- **Firebase Support**: https://firebase.google.com/support

---

**Good luck with your PawPal development! 🐾**
