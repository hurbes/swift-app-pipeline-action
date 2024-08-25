# 🚀 Swift App Pipeline Action

Hey there, fellow Swift developer! 👋 Tired of setting up the same old CI/CD pipeline for every Swift project? Say hello to the Swift App Pipeline Action! This nifty little GitHub Action takes care of everything from linting to releasing your Swift app. It's like having a personal assistant for your development pipeline! 🧑‍💻✨

## 📚 Table of Contents
- [What's This All About?](#-whats-this-all-about)
- [Getting Started](#-getting-started)
- [Customization](#️-customization)
- [The Nitty-Gritty Details](#-the-nitty-gritty-details)
- [Troubleshooting](#-troubleshooting)
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
    steps:
    - uses: actions/checkout@v4
    - uses: your-username/swift-app-pipeline-action@v1
      with:
        project-name: 'MyAwesomeApp'
        scheme-name: 'MyAwesomeApp'
        github-token: ${{ secrets.GITHUB_TOKEN }}
```

3. Replace `your-username` with your actual GitHub username
4. Commit, push, and watch the magic happen! ✨

## 🛠️ Customization

This action is more customizable than your favorite ice cream sundae. Here are all the toppings you can add:

```yaml
- uses: your-username/swift-app-pipeline-action@v1
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
```

## 🧠 The Nitty-Gritty Details

Let's dive deep into each step of our Swift app pipeline. Each of these steps can be customized or disabled based on your needs. Here's the lowdown:

### 1. Linting 🧹

SwiftLint keeps your code squeaky clean. It'll check your code style, flag potential errors, and even fix some issues automatically!

**Usage:**
```yaml
- uses: your-username/swift-app-pipeline-action@v1
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
- uses: your-username/swift-app-pipeline-action@v1
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
- uses: your-username/swift-app-pipeline-action@v1
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
- uses: your-username/swift-app-pipeline-action@v1
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
- uses: your-username/swift-app-pipeline-action@v1
  with:
    sign-app: 'true'
    code-signing-identity: '${{ secrets.SIGNING_IDENTITY }}'
    provisioning-profile: '${{ secrets.PROVISIONING_PROFILE }}'
```

**What it does:**
- Signs the app using the provided code signing identity
- Embeds the provisioning profile into the app bundle
- Verifies the signature after signing

**Pro tip:** Store your signing identity and provisioning profile as secrets in your GitHub repo for security!

### 6. DMG Creation 📀

Packages your app into a shiny DMG file, perfect for distribution outside the App Store. Make your app look pro with a custom background!

**Usage:**
```yaml
- uses: your-username/swift-app-pipeline-action@v1
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
- uses: your-username/swift-app-pipeline-action@v1
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
- uses: your-username/swift-app-pipeline-action@v1
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

## 🚑 Troubleshooting

Uh-oh, something went wrong? Don't panic! Here are some common issues and how to fix them:

- **"Xcode version not found"**: Make sure you're specifying a valid Xcode version. Check available versions in the GitHub Actions macOS environments.

- **"Code signing failed"**: Double-check your code signing identity and provisioning profile. Make sure they're correctly set up in your repo secrets.

- **"SwiftLint not found"**: If you're using a custom macOS runner, make sure SwiftLint is installed. The action tries to install it, but it might fail in some cases.

- **"DMG creation failed"**: Ensure you have the necessary permissions for the background image file if you're using a custom one.

- **"Test scheme not found"**: Make sure your test scheme is shared in Xcode. Go to Manage Schemes and check the "Shared" box for your test scheme.

- **"Build failed due to code signing"**: If you're not distributing your app, try setting `CODE_SIGNING_REQUIRED=NO` in your build step.

Still stuck? Feel free to open an issue. We're here to help! 🤗

## 🙏 Credits

This action stands on the shoulders of giants. We'd like to give a shout-out to these awesome actions that help make our pipeline possible:

- [actions/checkout@v4](https://github.com/actions/checkout) - Checks-out your repository so our action can access it.
- [maxim-lobanov/setup-xcode@v1](https://github.com/maxim-lobanov/setup-xcode) - Sets up our Xcode environment.
- [actions/upload-artifact@v3](https://github.com/actions/upload-artifact) - Uploads our built app as an artifact.
- [actions/download-artifact@v3](https://github.com/actions/download-artifact) - Downloads our app artifact for release.
- [softprops/action-gh-release@v1](https://github.com/softprops/action-gh-release) - Creates GitHub releases for our app.
- [actions/github-script@v6](https://github.com/actions/github-script) - Allows us to use GitHub's API to comment on PRs.

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

Happy coding, and may your builds always be green! 🍀
