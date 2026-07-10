# Build & install Facet **without a Mac**

You can't avoid macOS entirely — Apple's compiler only runs on macOS — but you
**don't need to own a Mac**. A free cloud service compiles the app for you, and
you install the result on your iPhone straight from **Windows**.

The flow has two halves:

```
[ Cloud Mac builds the .ipa ]  →  [ Windows app signs & installs it on your iPhone ]
     GitHub Actions / Codemagic            Sideloadly  (or AltStore)
     (free)                                (free, uses your Apple ID)
```

No paid Apple Developer account is required just to test on your own device.

---

## Part 1 — Build the `.ipa` on a free cloud Mac

### Option A — GitHub Actions (recommended, fully free)

1. Make a free account at **github.com**.
2. Create a new **empty repository** (e.g. `facet`), Private is fine.
3. Put this project in it. Two easy ways:
   - **Web upload:** on the repo page → *Add file ▸ Upload files* → drag the
     whole contents of the `Facet` folder in → *Commit*. (Make sure the hidden
     `.github` folder is included — if drag-and-drop skips it, see note below.)
   - **Or ask me to push it for you** (I can do this from your PC if your GitHub
     CLI is signed in — just say the word).
4. GitHub automatically runs the build (the workflow in
   `.github/workflows/ios-build.yml`). Open the **Actions** tab to watch it (~3–6 min).
5. When it's green, open the run → scroll to **Artifacts** → download
   **`Facet-unsigned-ipa`**. Unzip it to get **`Facet.ipa`**.

> Note: if the web uploader won't include the `.github` folder, use the
> "ask me to push it" option, or run the workflow manually later via
> *Actions ▸ Build iOS ▸ Run workflow*.

### Option B — Codemagic (nice web UI, free tier)

1. Sign up at **codemagic.io** and connect the same GitHub repo.
2. It detects `codemagic.yaml`; start the **ios-unsigned** workflow.
3. Download the **`Facet.ipa`** artifact when it finishes.

Both options produce an **unsigned** `.ipa` on purpose — signing happens in Part 2
with *your* Apple ID, so you don't have to put any Apple certificates in the cloud.

---

## Part 2 — Install the `.ipa` on your iPhone from Windows

### Easiest: Sideloadly (free)

1. Install **iTunes** (the Apple.com version, not the Microsoft Store one) so
   Windows has Apple's device drivers. Then install **Sideloadly** from
   `sideloadly.io`.
2. Plug your iPhone into the PC with a cable; unlock it and tap **Trust**.
3. Open Sideloadly:
   - Drag **`Facet.ipa`** onto the window.
   - Enter your **Apple ID** (a free one works). Sideloadly re-signs the app with it.
   - (Optional) set a unique **Bundle ID** like `com.yourname.facet`.
   - Click **Start**. Enter your Apple ID password / app-specific password if asked.
4. On the iPhone: **Settings ▸ General ▸ VPN & Device Management** → tap your
   Apple ID → **Trust**.
5. Launch **Facet**. Grant **Photos** access when prompted, and scan a face. 🎉

### Alternative: AltStore / SideStore

`altstore.io` — install **AltServer** on Windows, which sideloads the `.ipa` and
can **auto-refresh** it in the background so it doesn't expire.

---

## Good to know (free Apple ID limits)

- A free Apple ID can sideload up to **3 apps**, and each signature **expires
  after 7 days** — just re-run Sideloadly (or let AltStore auto-refresh) to renew.
- To skip the 7-day limit, distribute via **TestFlight**, which needs a paid
  **Apple Developer Program** membership ($99/yr). CI can upload to TestFlight for
  you, but that's optional and only worth it if you want outside testers.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Build fails: "scheme not found" | The workflow uses `-target Facet` (no scheme needed) — make sure you didn't edit it to `-scheme`. |
| Build fails on an old Xcode | The runner is pinned to `macos-15` (Xcode 16). Codemagic uses `xcode: latest`. This project needs Xcode 16+. |
| Sideloadly: "Could not find Apple device" | Install desktop **iTunes** (Apple version) for the drivers; reconnect and tap Trust on the phone. |
| App opens then closes after 7 days | Signature expired — re-run Sideloadly, or use AltStore auto-refresh. |
| "Unable to install — bundle identifier" | Set a unique Bundle ID in Sideloadly (e.g. `com.yourname.facet`). |
