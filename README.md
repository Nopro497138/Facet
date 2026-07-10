# Facet — Face Intelligence

A privacy-first iOS app that analyses a face **entirely on-device** using Apple's
Vision framework, then presents beautiful, cautious insights and user-controlled
organization features. Facet never claims to identify unknown people and never
searches the open internet — it works with your own photos and only the services
you explicitly connect.

Built with **SwiftUI · MVVM · Swift Concurrency · Vision · Core Image · PhotosUI**.
No third-party dependencies.

---

## What it does

- **Scan** a photo you choose → a futuristic scan sequence runs while Vision
  detects the face, maps landmarks, reads head pose and scores capture quality.
- **Insights** — image-quality gauge, lighting, pose, sharpness/blur, duplicate
  detection, smart tags (Vision scene classification) and an AI description.
  Age & emotion are shown as **clearly-labelled estimates with uncertainty**.
- **Sources (Orbit)** — a 3D orbit of the services you connect (read-only).
- **Search** — a staged, animated search across **authorized sources only**.
- **Results** — provenance/confidence-labelled result cards.
- **Settings** — appearance, on-device AI, privacy, performance, model management.

### Privacy model
- Photos enter only through an explicit `PhotosPicker` choice.
- All analysis runs on-device; nothing is uploaded.
- Age/emotion are estimates (the shipped `HeuristicInsightModel` derives cues from
  real facial geometry). Swap in a Core ML model by implementing `FaceInsightModel`.

---

## Project structure

```
Facet/
├─ Facet.xcodeproj/            # Xcode 16 project (file-system synchronized group)
└─ Facet/
   ├─ App/                     # FacetApp, RootView, AppRouter
   ├─ DesignSystem/            # Theme (palette/gradients), Typography, Motion, Haptics
   ├─ Components/              # Glass cards, buttons, orb, particle field, gauges, chips…
   ├─ Models/                  # FaceAnalysis, Sources, AppSettings
   ├─ Managers/                # SettingsStore, LibraryStore, PhotoImporter
   ├─ AI/                      # FaceAnalysisService (Vision), ImageMetrics, FaceInsightModel
   ├─ Services/                # SourceSearchService (authorized-source search)
   ├─ ViewModels/              # ScanViewModel, SearchViewModel
   ├─ Navigation/              # TabBar
   ├─ Views/                   # Home, Scan, Orbit, Insights, Search, Results, Settings
   ├─ Utilities/               # Extensions, Geometry
   └─ Resources/Assets.xcassets# AppIcon (1024), AccentColor, 11 brand logos (vector)
```

---

## Requirements

- **macOS** with **Xcode 16 or newer** (the project uses a file-system
  synchronized group, `objectVersion = 77`).
- **iOS 17.0+** simulator or device.
- An Apple ID (a free one is enough to run on your own device).

> The project has **no Swift packages or CocoaPods** — just open and build.

---

## 1) Open the project in Xcode

1. Copy the `Facet` folder to your Mac.
2. Double-click **`Facet/Facet.xcodeproj`** (or `File ▸ Open…` in Xcode).
3. In the toolbar scheme selector, choose **Facet** and a simulator (e.g.
   *iPhone 16 Pro*). Press **⌘R** to build & run in the simulator.

> **If Xcode can't open the project** (older Xcode), create a fresh project and
> drop the sources in — see *Common issues ▸ "Project won't open"* below.

---

## 2) Dependencies

None to install. Facet uses only Apple frameworks (SwiftUI, Vision, CoreImage,
PhotosUI, UIKit), all linked automatically via `import`.

---

## 3) Configure signing

1. Select the **Facet** project in the navigator → **Facet** target → **Signing
   & Capabilities**.
2. Tick **Automatically manage signing**.
3. Set **Team** to your Apple ID team (add your Apple ID via *Xcode ▸ Settings ▸
   Accounts* if it isn't listed).
4. Change **Bundle Identifier** from `com.example.facet` to something unique to
   you, e.g. `com.yourname.facet`. (Required — `com.example.*` will fail signing.)

Xcode creates the provisioning profile for you.

---

## 4) Run on a real iPhone

1. Connect the iPhone via USB (or set up Wi-Fi debugging).
2. On the device: **Settings ▸ Privacy & Security ▸ Developer Mode ▸ On**, then
   reboot (first time only, iOS 16+).
3. In Xcode's device selector, pick your iPhone. Press **⌘R**.
4. First launch of a self-signed app: on the device, trust the developer via
   **Settings ▸ General ▸ VPN & Device Management ▸ [your Apple ID] ▸ Trust**.
5. When prompted, grant **Photo Library** access so you can pick a photo to scan.

---

## 5) Archive the app

1. In the device selector choose **Any iOS Device (arm64)** (not a simulator).
2. Menu: **Product ▸ Archive**.
3. When it finishes, the **Organizer** opens with your archive.

> If *Archive* is greyed out, make sure the destination is a device/"Any iOS
> Device", not a simulator.

---

## 6) Export an `.ipa`

From the **Organizer** (Window ▸ Organizer ▸ Archives), select the archive →
**Distribute App**, then pick a method:

- **App Store Connect** — for TestFlight / App Store submission.
- **Ad Hoc** — install on registered UDID devices without the App Store.
- **Development** — for your own test devices.
- **Enterprise** — only with an Apple Enterprise account.

Choose one → follow prompts (signing = *Automatically manage signing*) →
**Export** → pick a folder. Xcode writes **`Facet.ipa`** there.

### Command-line alternative
```bash
# Archive
xcodebuild -project Facet.xcodeproj -scheme Facet \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/Facet.xcarchive archive

# Export (needs an ExportOptions.plist — see below)
xcodebuild -exportArchive -archivePath build/Facet.xcarchive \
  -exportOptionsPlist ExportOptions.plist -exportPath build/ipa
```
Minimal `ExportOptions.plist` for development export:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>method</key><string>development</string>
  <key>teamID</key><string>YOUR_TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
</dict></plist>
```

> **Free Apple ID note:** a free account cannot export a distributable `.ipa`
> (no Ad Hoc/App Store). It *can* run the app on your own device via **⌘R**
> (step 4). To produce an `.ipa`, you need a paid **Apple Developer Program**
> membership.

---

## 7) Install the `.ipa` on a device

Any of:

- **TestFlight** (recommended for testers): upload the App Store-signed build via
  Organizer → *Distribute App ▸ App Store Connect ▸ Upload*, then invite testers.
- **Apple Configurator** (Mac): connect the iPhone, drag `Facet.ipa` onto the
  device.
- **Xcode ▸ Window ▸ Devices and Simulators**: select the device → *Installed
  Apps* → **+** → choose `Facet.ipa` (the device's UDID must be in the Ad
  Hoc/Development profile).

---

## 8) Common build issues & fixes

| Symptom | Fix |
|---|---|
| **Project won't open / "damaged"** | You're on Xcode < 16. Create a new *iOS App* project (SwiftUI, iOS 17), delete its starter files, then drag the entire `Facet/Facet/` **source folder** and `Assets.xcassets` into the new project (check *Copy items if needed* and add to the target). Set the Photo Library usage string (below). |
| **"Failed to register bundle identifier"** | Change the bundle ID to something unique (`com.yourname.facet`). |
| **"Signing requires a development team"** | Signing & Capabilities → select your Team; enable *Automatically manage signing*. |
| **App builds but photo picker does nothing / crashes on pick** | Ensure the Photo Library permission string exists. This project sets it via build setting `INFOPLIST_KEY_NSPhotoLibraryUsageDescription`. In a hand-made project add **NSPhotoLibraryUsageDescription** to Info.plist. |
| **App icon is blank** | Confirm `Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` (1024×1024) is present and the target's *App Icon Source* = `AppIcon`. |
| **Brand logos missing in Orbit/Results** | The 11 logos are vector `*.imageset`s in `Assets.xcassets`. Make sure `Assets.xcassets` was added to the **target**. |
| **"Developer Mode required"** | Enable Settings ▸ Privacy & Security ▸ Developer Mode on the device and reboot. |
| **"Untrusted Developer" on launch** | Settings ▸ General ▸ VPN & Device Management ▸ trust your Apple ID. |
| **Archive greyed out** | Destination must be *Any iOS Device*, not a simulator. |
| **120 Hz not observed** | ProMotion only appears on Pro devices; the code already animates transform/opacity for high-FPS rendering. |

---

## Notes on the AI

- **Real, on-device:** face detection, landmarks, head pose, capture quality
  (Vision), feature prints for similarity/duplicate clustering, scene tags
  (`VNClassifyImageRequest`), exposure & sharpness (Core Image).
- **Estimates:** age & emotion are produced by `HeuristicInsightModel`
  (geometry-derived, clearly labelled). It's a protocol — drop in a Core ML model
  by conforming to `FaceInsightModel` and passing it to `FaceAnalysisService`.

Made to feel like a premium, Apple-designed app — dark biometric console,
spectral-aqua accent, glassmorphism, and motion that always respects
*Reduce Motion*.
