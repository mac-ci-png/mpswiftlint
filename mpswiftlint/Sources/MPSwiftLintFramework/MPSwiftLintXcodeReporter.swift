import Foundation

class MPSwiftLintXcodeReporter {
    static var printedErrorIssues = false

    class func reportIssue(_ message: String, isError: Bool, filepath: String, line: Int, column: Int) {
        var prefix = "warning"
        if (isError) {
            prefix = "error"
            printedErrorIssues = true
        }
        let issueMessage = "\(filepath):\(line):\(column): \(prefix): \(message)"
        print("\(issueMessage)\n")
    }
    
    class func didReportAnyErrors() -> Bool {
        return printedErrorIssues
    }
}
