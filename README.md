# NeqSim Mobile – Flow Assurance

Flutter app for flow assurance: pipeline (length/elevation), fluid (T, P, flow, black oil or compositional), and two modes:

1. **Engineering (correlation)** – Calls the NeqSim FA API for starting pressure and EVR.
2. **Chat with AI** – Sends the scenario as context to an OpenAI-compatible chat API.

No login. Configure backend URL and AI API key in **Settings**.

---

## Setup (local)

1. Install [Flutter](https://flutter.dev/docs/get-started/install).
2. In this directory: `flutter pub get`.
3. If Android/iOS are missing: `flutter create .` (in this folder; may overwrite some files – re-add deps if needed).

---

## Run

- **Android**: `flutter run` (device or emulator).
- **iOS**: `flutter run` (Mac only).
- **Web**: `flutter run -d chrome`.

---

## Backend (Engineering mode)

Run the NeqSim Process API (with flow-assurance) on your PC or server, e.g.:

```bash
# On your machine where the Python API lives
python -m uvicorn examples.process_api:app --host 0.0.0.0 --port 8000
```

In the app **Settings**, set **Base URL** (e.g. `http://192.168.1.x:8000`). Use `http://10.0.2.2:8000` for Android emulator pointing to host PC.

---

## AI (Chat mode)

In **Settings**, set **AI API base URL** (e.g. `https://api.openai.com` or Groq) and your **API key**.  
Get a key from [OpenAI](https://platform.openai.com/) or [Groq](https://console.groq.com/).

---

## Build on Codemagic (Android)

Codemagic runs the same as terminal: `flutter pub get` then `flutter build apk --release`. Terminal uses `android/local.properties`; Codemagic uses `FLUTTER_ROOT` when that file is missing.

1. **Push to Git**  
   Commit and push this folder as your repo (e.g. GitHub, GitLab, Bitbucket).

2. **Connect on Codemagic**  
   - Go to [codemagic.io](https://codemagic.io) and sign in.  
   - **Add application** → choose your Git provider and select **this repository** (the neqsim_mobile repo).  
   - Codemagic will detect `codemagic.yaml` at the repo root.

3. **Start a build**  
   - **Workflows** → **Android Build** → **Start new build** (branch: `main` or `master`).  
   - Use **only** the workflow defined in `codemagic.yaml`. Do **not** add a separate “Build for Android” or “Build Android App Bundle” step in the workflow editor, or Gradle may run without `android/local.properties` and fail.  
   - Wait for the pipeline to finish.

4. **Get the APK/AAB**  
   - Build page → **Artifacts** tab.  
   - Download the **APK** for sideloading or the **AAB** for Play Store.

**Optional:** For Play Store, add [Android code signing](https://docs.codemagic.io/flutter-code-signing/android-code-signing/) in Codemagic and add `flutter build appbundle --release` in `codemagic.yaml`.

---

## App flow

1. **Home** → **Engineering** or **Chat with AI**.
2. **Pipeline** → add/edit points (length m, elevation m) → Next.
3. **Fluid** → T (°C), P (bara), flow rate + unit, fluid type, preset, diameter, roughness → Next.
4. **Engineering**: **Calculate** → **Results** (starting pressure, EVR).  
   **Chat**: type a message → AI reply with scenario as context.
