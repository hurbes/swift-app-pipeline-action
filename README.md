# 🚀 Swift App Pipeline Action

Hey there, fellow Swift developer! 👋 Tired of setting up the same old CI/CD pipeline for every Swift project? Say hello to the Swift App Pipeline Action! This nifty little GitHub Action takes care of everything from linting to releasing your Swift app. It's like having a personal assistant for your development pipeline! 🧑‍💻✨

## 📚 Table of Contents
- [What's This All About?](#-whats-this-all-about)
- [Getting Started](#-getting-started)
- [Customization](#️-customization)
- [The Nitty-Gritty Details](#-the-nitty-gritty-details)
- [Apple Developer Certificates and Provisioning Profiles](#-apple-developer-certificates-and-provisioning-profiles)
- [Debugging and Troubleshooting](#-debugging-and-troubleshooting)
- [Credits](#-credits)
- [Contributing](#-contributing)
- [License](#-license)

## 🎯 What's This All About?

This action is your one-stop shop for automating your Swift app's development pipeline. Here's what it can do for you:

- 🧹 Lint your code (because clean code is happy code)
- 🧪 Run your tests (no bugs shall pass!)
- 🏗️ Build your app (obviously, right?)
- 📦 Package it up (ZIP or DMG, your choice)
- 🔏 Sign your app (if you're into that)
- 🚢 Create a shiny new release
- 💬 Comment on your PRs (to keep everyone in the loop)

And the best part? You can toggle each of these steps on or off. It's like a buffet, but for your pipeline!

## 🚀 Getting Started

Ready to take this baby for a spin? Here's how:

1. Create a new file in your repo at `.github/workflows/swift-app-pipeline.yml`
2. Copy this yaml into that file:

```yaml
name: Swift App Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-release:
    runs-on: macos-latest
    permissions:
      contents: write  # This gives permission to create releases
    steps:
    - uses: actions/checkout@v4
    - uses: hurbes/swift-app-pipeline-action@v0.0.15
      with:
        project-name: 'MyAwesomeApp'
        scheme-name: 'MyAwesomeApp'
        github-token: ${{ secrets.GITHUB_TOKEN }}
        create-release: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' }}
```

3. Replace `MyAwesomeApp` with your actual project and scheme name
4. Commit, push, and watch the magic happen! ✨

## 🛠️ Customization

This action is more customizable than your favorite ice cream sundae. Here are all the toppings you can add:

```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    # Required inputs
    project-name: 'MyAwesomeApp'
    scheme-name: 'MyAwesomeApp'
    github-token: ${{ secrets.GITHUB_TOKEN }}

    # Optional inputs (showing default values)
    xcode-version: 'latest'
    macos-version: 'latest'
    app-name: ${{ inputs.project-name }}
    run-lint: 'true'
    run-tests: 'true'
    run-build: 'true'
    create-release: 'false'
    sign-app: 'false'
    ignore-step-failure: 'false'
    increment-build-version: 'true'
    build-version-increment: ''
    custom-version: ''
    remove-quarantine: 'true'
    comment-on-pr: 'false'
    pr-comment-template: 'New build available: {release-url}'
    create-dmg: 'false'
    dmg-background: ''
    dmg-window-size: '600x400'
    dmg-icon-size: '128'
    code-signing-identity: ''
    provisioning-profile: ''
    team-id: ''
    enable-notarization: 'false'
    apple-id: ''
    apple-password: ''
    keychain-profile: 'notary'
    staple: 'true'
```

## 🧠 The Nitty-Gritty Details

Let's dive deep into each step of our Swift app pipeline. Each of these steps can be customized or disabled based on your needs. Here's the lowdown:

### 1. Linting 🧹

SwiftLint keeps your code squeaky clean. It'll check your code style, flag potential errors, and even fix some issues automatically!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    run-lint: 'true'  # Set to 'false' to skip linting
```

**What it does:**
- Installs SwiftLint if it's not already available
- Runs SwiftLint on your project
- Fails the build if there are any linting errors (unless you've set `ignore-step-failure: 'true'`)

**Pro tip:** Add a `.swiftlint.yml` file to your repo to customize SwiftLint rules!

### 2. Testing 🧪

Runs your test suite to catch bugs before they sneak into production. Because nobody likes buggy apps, right?

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    run-tests: 'true'  # Set to 'false' to skip testing
    scheme-name: 'MyAppTests'  # Specify your test scheme
```

**What it does:**
- Runs `xcodebuild test` with your specified scheme
- Uses a macOS destination by default
- Outputs test results in a GitHub-friendly format

**Pro tip:** Make sure your test scheme is shared in Xcode, or the action won't be able to find it!

### 3. Version Incrementing 🔢

Automatically bumps your build number, so you don't have to remember to do it manually. It's like having a tiny, diligent version manager!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    increment-build-version: 'true'
    build-version-increment: '2'  # Optional: Specify which part of the version to increment
    custom-version: '2.0.0'  # Optional: Set a specific version
```

**What it does:**
- Increments the build number in your Info.plist
- Can increment major, minor, or patch version
- Allows setting a custom version string

**Pro tip:** Use `build-version-increment: '3'` to increment the patch version, '2' for minor, '1' for major.

### 4. Building 🏗️

Compiles your app and gets it ready for testing or release. This is where your code transforms into a real, tangible app!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    run-build: 'true'
    project-name: 'MyAwesomeApp'
    scheme-name: 'MyAwesomeApp'
    remove-quarantine: 'true'  # Removes quarantine attribute on macOS
```

**What it does:**
- Runs `xcodebuild build` with your specified project and scheme
- Builds for both Intel and Apple Silicon architectures
- Optionally removes the quarantine attribute (useful for notarization)

**Pro tip:** If your build is failing, try setting `ignore-step-failure: 'true'` to continue the pipeline and debug later.

### 5. Signing 🔏

Signs your app so it can be distributed through the App Store or notarized for direct distribution. It's like giving your app an official seal of approval!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    sign-app: 'true'
    team-id: '${{ secrets.TEAM_ID }}'
```

**What it does:**
- Signs the app using the provided code signing identity
- Embeds the provisioning profile into the app bundle
- Verifies the signature after signing

**Pro tip:** Store your team ID as a secret in your GitHub repo for security!

### 6. DMG Creation 📀

Packages your app into a shiny DMG file, perfect for distribution outside the App Store. Make your app look pro with a custom background!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    create-dmg: 'true'
    dmg-background: 'path/to/background.png'
    dmg-window-size: '600x400'
    dmg-icon-size: '128'
```

**What it does:**
- Creates a DMG file containing your app
- Allows customization of the DMG window size and icon size
- Supports adding a custom background image

**Pro tip:** Design a slick background image to give your DMG some extra flair!

### 7. Releasing 🚢

Creates a new GitHub release and attaches your app (as a ZIP or DMG). It's like throwing a launch party for your app, but automated!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    create-release: 'true'
    github-token: ${{ secrets.GITHUB_TOKEN }}
```

**What it does:**
- Creates a new GitHub release tagged with the build number
- Attaches the ZIP or DMG file to the release
- Generates release notes (customizable with the `release-notes` input)

**Pro tip:** Use this in combination with `increment-build-version` to have semantically versioned releases!

### 8. PR Commenting 💬

Leaves a comment on your PR with details about the new build. Keep your team in the loop without any extra effort!

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    comment-on-pr: 'true'
    pr-comment-template: 'New build {build-number} is ready! Download: {release-url}'
```

**What it does:**
- Detects if the action is running on a PR
- Fetches information about the latest build and release
- Posts a comment on the PR with customizable content

**Pro tip:** Customize the comment template to include the info that's most important to your team!

Remember, you can mix and match these steps however you like. Use only what you need, and customize to your heart's content. That's the beauty of this pipeline - it's as flexible as you need it to be! 🚀

## 🍎 Apple Developer Certificates and Provisioning Profiles

To sign and distribute your macOS app, you'll need an Apple Developer account and the necessary certificates and provisioning profiles. Here's a step-by-step guide to set these up:

1. **Enroll in the Apple Developer Program**: If you haven't already, enroll in the [Apple Developer Program](https://developer.apple.com/programs/). This is required for code signing and distribution.

2. **Create a Certificate Signing Request (CSR)**:
   - On your Mac, open Keychain Access (Applications > Utilities > Keychain Access).
   - Go to Keychain Access > Certificate Assistant > Request a Certificate from a Certificate Authority.
   - Fill in your email address and name, select "Saved to disk", and click Continue.
   - Save the CSR file to your computer.

3. **Create a Distribution Certificate**:
   - Log in to your [Apple Developer account](https://developer.apple.com/).
   - Navigate to Certificates, Identifiers & Profiles > Certificates.
   - Click the '+' button to create a new certificate.
   - Select "Mac App Distribution" and click Continue.
   - Upload the CSR file you created earlier and click Continue.
   - Download the certificate and double-click to install it in your Keychain.

4. **Create an App ID**:
   - In your Apple Developer account, go to Certificates, Identifiers & Profiles > Identifiers.
   - Click the '+' button to create a new identifier.
   - Select "App IDs" and click Continue.
   - Choose "App" as the type and click Continue.
   - Enter a description and your app's bundle ID (e.g., com.yourcompany.yourapp).
   - Select the capabilities your app needs and click Continue, then Register.

5. **Create a Provisioning Profile**:
   - Go to Certificates, Identifiers & Profiles > Profiles.
   - Click the '+' button to create a new profile.
   - Select "Mac App Store" under Distribution and click Continue.
   - Select the App ID you created earlier and click Continue.
   - Select the distribution certificate you created and click Continue.
   - Enter a name for your profile and click Generate.
   - Download the provisioning profile and double-click to install it.

6. **Find Your Team ID**:
   - In your Apple Developer account, go to Membership.
   - Your Team ID is listed in the Membership Information section.

Now that you have your certificates, provisioning profile, and Team ID, you can use them in your GitHub Actions workflow:

```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.15
  with:
    sign-app: 'true'
    team-id: ${{ secrets.TEAM_ID }}
```

Make sure to add your Team ID as a secret in your GitHub repository settings.

### 9. Notarization 🔐

Notarizes your app with Apple's notary service, ensuring it can be run on macOS without security warnings.

**Usage:**
```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.16
  with:
    sign-app: 'true'
    enable-notarization: 'true'
    apple-id: ${{ secrets.APPLE_ID }}
    apple-password: ${{ secrets.APPLE_APP_SPECIFIC_PASSWORD }}
    team-id: ${{ secrets.TEAM_ID }}
```

**What it does:**
- Submits your app to Apple's notary service
- Waits for the notarization to complete
- Optionally staples the notarization ticket to your app

**Pro tip:** Create an app-specific password for your Apple ID to use in this action for enhanced security.

10. **Create an App-Specific Password for Notarization**:
   - Go to [appleid.apple.com](https://appleid.apple.com/) and sign in.
   - In the Security section, click "Generate Password" under App-Specific Passwords.
   - Give your password a label (e.g., "GitHub Actions Notarization") and click Create.
   - Save this password securely - you'll need it for the `apple-password` input in the action.

Now that you have your certificates, provisioning profile, Team ID, and app-specific password, you can use them in your GitHub Actions workflow:

```yaml
- uses: hurbes/swift-app-pipeline-action@v0.0.16
  with:
    sign-app: 'true'
    enable-notarization: 'true'
    team-id: ${{ secrets.TEAM_ID }}
    apple-id: ${{ secrets.APPLE_ID }}
    apple-password: ${{ secrets.APPLE_APP_SPECIFIC_PASSWORD }}
```

Make sure to add your Team ID, Apple ID, and app-specific password as secrets in your GitHub repository settings.


## 🔍 Debugging and Troubleshooting

When working with code signing and Apple's certification process, you might encounter some issues. Here are some common problems and their solutions:

### 1. "No provisioning profiles found"

This error occurs when Xcode can't find a valid provisioning profile for your app.

**Solution:**
- Make sure you've created and downloaded the provisioning profile as described in the previous section.
- Check that the provisioning profile is installed on your local machine.
- Verify that the bundle identifier in your Xcode project matches the one in your provisioning profile.

### 2. "Code Sign error: Code signing is required for product type 'Application' in SDK 'macOS'"

This error appears when code signing is required but not properly configured.

**Solution:**
- In Xcode, go to your target's Build Settings.
- Set "Code Signing Style" to "Manual".
- Set "Development Team" to your team ID.
- Set "Code Signing Identity" to "Mac App Distribution".
- Set "Provisioning Profile" to the profile you created earlier.

### 3. "Invalid code signing entitlements"

This error occurs when your app's entitlements don't match those specified in your provisioning profile.

**Solution:**
- Review your app's entitlements in Xcode (Capabilities tab).
- Make sure these entitlements match those in your provisioning profile.
- If necessary, update your provisioning profile in the Apple Developer portal to include the required entitlements.

### 4. "The operation couldn't be completed. (OSStatus error -67062.)"

This cryptic error often means there's a problem with your signing certificate.

**Solution:**
- Check that your signing certificate is valid and not expired.
- Try revoking your current certificate and creating a new one.
- Make sure the certificate is properly installed in your Keychain.

### 5. Debugging Code Signing in GitHub Actions

When running this action in GitHub Actions, you might need more information to debug code signing issues. Here are some steps you can take:

1. **Enable verbose output**: Add the following step before the Swift App Pipeline Action to get more detailed logs:

   ```yaml
   - name: Enable verbose output
     run: echo "ACTIONS_STEP_DEBUG=true" >> $GITHUB_ENV
   ```

2. **Check certificate and provisioning profile**: Add a step to list the available certificates and provisioning profiles:

   ```yaml
   - name: List certificates and provisioning profiles
     run: |
       security find-identity -v -p codesigning
       ls -la ~/Library/M

Still stuck? Feel free to open an issue. We're here to help! 🤗

## 🙏 Credits

This action stands on the shoulders of giants. We'd like to give a shout-out to these awesome actions that help make our pipeline possible:

- [actions/checkout@v4](https://github.com/actions/checkout) - Checks-out your repository so our action can access it.
- [maxim-lobanov/setup-xcode@v1](https://github.com/maxim-lobanov/setup-xcode) - Sets up our Xcode environment.
- [softprops/action-gh-release@v1](https://github.com/softprops/action-gh-release) - Creates GitHub releases for our app.

We're incredibly grateful to the maintainers and contributors of these actions. They've significantly simplified our workflow and allowed us to focus on building a great pipeline for Swift apps.

Want to dive deeper into these actions? Click on the links above to check out their repositories. You might find some cool features we haven't even tapped into yet! 

Remember, open source is all about standing on each other's shoulders. If you find this action useful, consider starring or contributing to these projects too! 🌟

## 🎉 Contributing

Found a bug? Have an idea for an improvement? Contributions are welcome! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Let's make this action awesome together! 🤝

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details. Basically, use it however you want!

---