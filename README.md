# EAS Tester

Local-only iOS app: tap a SAME event code and a local notification fires with the
two-tone attention signal. Nothing is transmitted.

## Build the .ipa with GitHub Actions (no Mac needed)

1. Create a GitHub repo (public = free Mac build minutes).
2. Upload **everything in this folder**, keeping the folder structure:
   `project.yml`, `README.md`, the `EASTester/` folder, and `.github/workflows/build.yml`.
   - If the web uploader skips the `.github` folder (Windows hides dot-folders sometimes):
     in the repo click **Add file > Create new file**, type the name
     `.github/workflows/build.yml`, paste the contents of that file, and commit.
3. Go to the **Actions** tab. The "Build IPA" run starts on its own after you commit
   (or click **Build IPA > Run workflow**). It takes about 5 minutes.
4. When it's green, open the run, scroll to **Artifacts**, and download **EASTester-ipa**.
   That download is a .zip. Unzip it to get `EASTester.ipa`.

## Install on the iPhone (Windows)

1. Open Sideloadly (or your sideloading tool), plug in the phone, drag in `EASTester.ipa`.
2. Sign in with your Apple ID (a throwaway one is safer) and start.
3. On the phone: **Settings > General > VPN & Device Management** > trust your Apple ID.
4. Open EAS Tester and allow notifications.

Free Apple ID: the app expires after 7 days. Re-sideload the same .ipa to renew.

## Using it

- **Preview attention tone** plays the tone right away in the app.
- Set the delay, tap an event code, then lock the phone. The notification arrives with the tone.
- Silent mode mutes it like any normal notification.

## If the build fails

Open the failed run, click the red step, copy the error lines, and send them over.
