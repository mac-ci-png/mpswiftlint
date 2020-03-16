# MPSwiftLint

<img src="https://github.com/mParticle/mpswiftlint/raw/master/mpswiftlint.gif"></img>


The mParticle Swift Linter allows you to do compile-time verification of the data that your app is collecting.

The linter integrates with Xcode and provides feedback that pinpoints exactly where your code needs to be adjusted based on your organization's Data Plan.

### How to configure your project to use the mParticle Linter

#### 1. Setup prerequisites

> You will need to be running macOS Catalina (10.15) or later.

First, install [node][1] if you don't have it, then install the mParticle command line interface, which is used internally by the linter.

```sh
sudo npm install -g @mparticle/cli
```

#### 2. Install the linter

Download and install the latest `pkg` file from this repository's [releases][2] page.

#### 3. Specify your Data Plan

Next, download your data plan from the mParticle platform and save it to a file in your source repository. 

You will also need to create a file `mp.config.json` in your repository root to tell the linter where to find the data plan file:

> Note: the example below assumes you saved the downloaded file as `plan.json` in the root of your repository. If you used a different path or filename, adjust the `baseDir` and `dataPlanVersion` fields accordingly.

```js
{
    "planningConfig": {
        "baseDir": ".",
        "dataPlanVersionFile": "plan.json"
    }
}
```

#### 4. Configure your Xcode project and SDK options

To allow linting to take place automatically each time you build, add a new `Run Script` Build Phase to your project.

In the source editor for the new phase, you just need to invoke the Swift linter binary: `/usr/local/bin/mpswiftlint`

Optionally, you may want to reorder the build step near the top and/or rename the build step to something that will be easier to spot in build logs (e.g. `mParticle Linter`).

Finally, If you're not already doing so, you should specify your data plan id and version in MParticleOptions at time of SDK initialization.

```swift
let options = MParticleOptions(key: "REPLACE WITH APP KEY", secret:@"REPLACE WITH APP SECRET")
options.dataPlanId = "my-org-data-plan"
options.dataPlanVersion = 1 as NSNumber
MParticle.sharedInstance().start(with: options))
```

### Using the linter

You are now ready to begin linting your code--simply build your project using Xcode and if the linter detects that your implementation doesn't match the data plan, messages will appear inline and in Xcode's issue navigator.

### Data point implementation status

- [x] Event names
- [x] Event types
- [ ] Event attributes

### Contributing

We built this linter to be a powerful but unobtrusive tool to help your organization achieve consistent and reliable data collection.

If you have any ideas for ways we can improve the effectiveness of the tool, or you find a bug or false positive, please reach out to us at support@mparticle.com or open an issue (or pull request) against the repository.

### License

Apache License 2.0

[1]: https://nodejs.org/en/download/
[2]: https://github.com/mParticle/mpswiftlint/releases
