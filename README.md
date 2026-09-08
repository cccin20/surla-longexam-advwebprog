# Surla — Long Exam 1

Flutter Facebook-style lab application using https://dummyjson.com as the API host.

## Run

```sh
flutter pub get
flutter run -d chrome
```

Demo credentials: **emilys** / **emilyspass**. Enter these credentials on the login screen, then select Log in.

For a connected Android/iOS device, use `flutter devices` followed by `flutter run -d <device-id>`.
Android release builds require a compatible JDK (17–24 for the generated Gradle 8.14 configuration); this workspace sets `org.gradle.java.home` in `android/gradle.properties` to the installed Java 24. Update or remove that machine-specific path on another computer. iOS requires Xcode signing for physical devices.

## Lab source alignment

The PDF provides source screenshots for `lib/models/post.dart` and `lib/services/post_service.dart`. The Post model retains every supplied field, camelCase/snake_case fallbacks, nested reactions, and JSON serialization, and adds title/tags. PostService retains `getPosts({limit = 30, skip = 0})`, the host endpoint, and mapping into Post; HTTP decoding/error handling is factored into ApiService. Models, providers, screens, services, and widgets follow the lab's separation.

The starting workspace was empty, so the prior Facebook Replication Application was recreated. The PDF's custom fonts and image assets were not supplied; system fonts, Material icons, and API avatars with placeholders are used. Unused sample packages, missing asset declarations, and unrelated placeholder screens were not added.

## Enhancements

1. Authentication: POST `/auth/login`, user identity and tokens in shared_preferences (never passwords), splash session check with `/auth/me`, token refresh, retry on connection failure, and sign-in routing.
2. Profile: `/posts/user/{userId}?limit=0`, signed-in user's information, settings for persistent dark mode and compact previews, and Sign Out removing the session.
3. Comments: `/comments/post/{postId}?limit=0`, all comments displayed in post detail, clickable like/unlike with updated counts, and POST `/comments/add`. Local likes and added comments persist per account and stay consistent between profile/feed/detail.

DummyJSON simulates writes; new comments are not stored remotely. Added comments and likes are retained on this device for the account, including after sign-out; they are not synchronized to other devices. Theme preferences are device-wide. shared_preferences token storage is used for this lab; production authentication should use secure platform storage.

## Verification

```sh
flutter analyze
flutter test
flutter build web
```

Manual checks: log in; open a post and add a comment; like/unlike; visit Profile and verify the author; change preferences; reload and verify session/preferences/local interactions; sign out and reload; test invalid credentials and disconnected-network retries.

`build/web` is the compiled web output. The lab's HOST LINK refers to the DummyJSON backend, not a published app URL. No public deployment is configured.

Validation result: analyzer passed and all six automated tests passed. A direct live API login probe returned HTTP 403 from this environment, so live end-to-end connectivity remains unverified.
