import MPSwiftLintFramework
import Darwin

let success = MPSwiftLint.lint()
let exitCode: Int32 = success ? 0 : 1
exit(exitCode)
