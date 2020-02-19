import Foundation

public class MPSwiftLint {
    
    public class func lint() -> Bool {
        let dir = MPSwiftLintHelpers.workingDirectory()
        lint(dir: dir)
        return !(MPSwiftLintXcodeReporter.didReportAnyErrors())
    }
    
    class func lint(dir: String) {
        let files = MPSwiftLintHelpers.findSwiftFiles(dir: dir)
        lint(files: files)
    }
    
    class func lint(files: [String]) {
        for file in files {
            MPSwiftLintCore.lint(file:file, files: files)
        }
    }
    
}

