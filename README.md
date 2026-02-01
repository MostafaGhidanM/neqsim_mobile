# Flow Assurance (NeqSim Mobile)

Simple Flutter app for flow assurance: pipeline (length/elevation table), fluid (T, P, flow, black oil or compositional), and two modes:

1. **Engineering (correlation)** – Calls the NeqSim FA API to compute starting pressure and EVR.
2. **Chat with AI** – Sends the same scenario as context to an OpenAI-compatible chat API for advice.

No login. Configure backend URL and AI API key in Settings.

## Setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install).
2. In this directory: `flutter pub get`.
3. If Android/iOS platform files are missing or broken, from the **parent** directory run:  
   `flutter create neqsim_mobile`  
   (This may overwrite `pubspec.yaml` and `lib/main.dart`; re-add dependencies and routes if needed.)

## Run

- **Android**: `flutter run` (device or emulator).
- **iOS**: `flutter run` (Mac only).
- **Web**: `flutter run -d chrome`.

## Backend (Engineering mode)

Run the NeqSim Process API (with flow-assurance) on your PC or server, e.g.:

```bash
cd path/to/neqsim-python-master
.venv\Scripts\python.exe -m uvicorn examples.process_api:app --host 0.0.0.0 --port 8000
```

In the app **Settings**, set **Base URL** to your backend (e.g. `http://192.168.1.x:8000`). Use `10.0.2.2:8000` for Android emulator pointing to host PC.

## AI (Chat mode)

In **Settings**, set **AI API base URL** (e.g. `https://api.openai.com` or Groq) and your **API key**.  
Get a free-tier key from [OpenAI](https://platform.openai.com/) or [Groq](https://console.groq.com/).

## Build on Codemagic (Android)

The repo root contains `codemagic.yaml` so you can build the Android app on [Codemagic](https://codemagic.io).

1. **Push code to Git**  
   Commit and push this repo to GitHub, GitLab, or Bitbucket.

2. **Connect on Codemagic**  
   - Go to [codemagic.io](https://codemagic.io) and sign in.  
   - **Add application** → choose your Git provider and select this repository.  
   - Codemagic will detect `codemagic.yaml` in the repo root.

3. **Start a build**  
   - Open the app → **Workflows** → select **Android Build**.  
   - Click **Start new build** (branch: e.g. `main` or `master`).  
   - Wait for the pipeline to finish.

4. **Get the APK/AAB**  
   - In the build page, open the **Artifacts** tab.  
   - Download the **APK** (`*.apk`) for sideloading or the **AAB** (`*.aab`) for Play Store.

**Optional:** For Play Store release, add [Android code signing](https://docs.codemagic.io/flutter-code-signing/android-code-signing/) in Codemagic (keystore + env vars) and reference it in `codemagic.yaml` under `environment.android_signing`.

## Flow

1. **Home** → choose **Engineering** or **Chat with AI**.
2. **Pipeline** → add/edit points (length m, elevation m). Next.
3. **Fluid** → T (°C), P (bara), flow rate + unit, fluid type, preset, diameter, roughness. Next.
4. **Engineering**: **Calculate** → **Results** (starting pressure, EVR).  
   **Chat**: type a message → AI reply with scenario as context.
