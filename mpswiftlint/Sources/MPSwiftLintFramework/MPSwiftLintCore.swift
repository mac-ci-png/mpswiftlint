import Foundation

class MPSwiftLintCore {
    
    static var filePath: String? = nil
    static var contents: String? = nil
    static var obj: [String: Any]? = nil
    static var offset: Int? = nil
    static var config: [String: Any]? = nil
    
    class func lint(file: String, files: [String]) {
        filePath = file
        contents = MPSwiftLintHelpers.readFile(file)
        if let contents = contents {
            obj = MPSwiftLintSyntax.parse(contents: contents)
            if let obj = obj {
                MPSwiftLintHelpers.verboseLog("Processing file: \(file)")
                handleParseResult(obj: obj)
            }
            
        }
    }
    
    class func handleParseResult(obj: [String: Any]) {
        traverseTree(tree: obj)
    }
    
    class func invokeCatalyst(commandJson: String) -> String? {
        guard let home = MPSwiftLintHelpers.getEnvironmentVar("HOME") else {
            print("'HOME' enviroment variable must be set")
            return nil
        }
        
        let dir = "\(home)/Library/Containers/maccatalyst.com.mparticle.MPSwiftLintAdapter/Data"
        let filename = "\(dir)/mpswiftlint.json"
        
        let _ = MPSwiftLintHelpers.executeBash(expression: "mkdir -p \(dir)")
        
        let binary = "/usr/local/bin/MPSwiftLintAdapter.app/Contents/MacOS/MPSwiftLintAdapter"
        MPSwiftLintHelpers.writeFile(filename, content: commandJson)
        let expression = "\(binary) 2>/dev/null"
        return MPSwiftLintHelpers.executeBash(expression: expression)
    }
    
    class func invokeNode(arguments: String) -> String? {
        let binary = "/usr/local/bin/mp 2>/dev/null"
        MPSwiftLintHelpers.verboseLog("CLI arguments: \(arguments)")
        return MPSwiftLintHelpers.executeBash(expression: "\(binary) \(arguments)")
    }
    
    class func handleSDKJson(_ json: String?) {
        guard let json = json else { return }
        guard let _ = MPSwiftLintHelpers.jsonParse(json) else { return }
        MPSwiftLintHelpers.verboseLog("CLI input json: \(json.replacingOccurrences(of: "\n", with: ""))")
        if (config == nil) {
            config = MPSwiftLintHelpers.jsonConfig()
            if (config == nil) {
                return
            }
        }
        
        guard let planningConfig = config!["planningConfig"] as? [String: Any] else {
            return
        }
        guard let dataPlanVersionFile = planningConfig["dataPlanVersionFile"] else {
            return
        }
        var encodedJson = json.replacingOccurrences(of: "'", with: "'\\''")
        encodedJson = encodedJson.replacingOccurrences(of: "\n", with: "")
        let nodeOutput = invokeNode(arguments: "planning:events:validate --dataPlanVersionFile=\"\(dataPlanVersionFile)\" --event='\(encodedJson)' --translateEvents")
        handleNodeJson(nodeOutput)
    }
    
    class func handleNodeJson(_ json: String?) {
        guard var json = json else { return }
        MPSwiftLintHelpers.verboseLog("CLI validation results: \(json)")
        guard let obj = MPSwiftLintHelpers.jsonParse(json) as? [String: Any] else { return }
        var foundErrors = false
        if let results = obj["results"] as? [Any] {
            guard let result = results[0] as? [String: Any] else { return }
            if let data = result["data"] as? [String: Any] {
                guard let errors = data["validation_errors"] as? [Any] else { return }
                foundErrors = true
                guard let modifiedJson = MPSwiftLintHelpers.jsonStringifyNoSpaces(errors) else { return }
                json = modifiedJson
            }
        }
        
        let message = "\(json)"
        if (!foundErrors) {
            return
        }
        var reportAsErrors = true
        if let _ = MPSwiftLintHelpers.getEnvironmentVar("MPSWIFTLINT_WARN"){
            reportAsErrors = false
        }
        if let offset = offset, let contents = contents, let filePath = filePath {
            let lineInfo = calculateLineInfo(offset: offset, contents: contents)
            MPSwiftLintXcodeReporter.reportIssue(message, isError: reportAsErrors, filepath: filePath, line: lineInfo.0, column: lineInfo.1)
        }
    }
    
    class func calculateLineInfo(offset: Int, contents: String) -> (Int, Int) {
        let offsetIndex = String.Index(utf16Offset: offset+1, in: contents)
        let contentsPart = contents[..<offsetIndex]
        let lines = contentsPart.components(separatedBy: "\n")
        let lineNo = lines.count
        let line = lines[lines.count-1]
        var colNo = line.count-1
        let index = String.Index(utf16Offset: colNo, in: line)
        let part = line[index...]
        if (part == "M") {
            colNo += 1
        }
        return (lineNo, colNo)
    }
    
    class func traverseTree(tree: [String: Any]) {
        traverseTreeHelper(tree: tree, depth:0, path:"", parent: nil, grandparent: nil)
    }
    
    class func traverseTreeHelper(tree: Any, depth: Int, path: String, parent: Any?, grandparent: Any?)  {
        if let tree = tree as? [String: Any] {
            var name: Substring? = nil
            var type: Substring? = nil
            for (key, node) in tree {
                if key == "key.kind" && node as? String == "source.lang.swift.expr.call" {
                    if tree["key.name"] as? NSString == "MPEvent" {
                        offset = tree["key.bodyoffset"] as? Int
                        if let off = offset {
                            offset = off - "MPEvent(".count
                        }
                        
                        if let sub = tree["key.substructure"] as? [Any] {
                            var i=0
                            for item in sub {
                                i += 1
                                if let item = item as? [String: Any] {
                                    if item["key.kind"] as? String == "source.lang.swift.expr.argument" {
                                        if let body = item["key.body"] {
                                            if let item = body as? Substring {
                                                if i == 1 {
                                                    name = item
                                                }
                                                if i == 2 {
                                                    type = item
                                                }
                                            }
                                            if let name = name {
                                                if var type = type {
                                                    type = Substring(type.replacingOccurrences(of: "MPEventType", with: ""))
                                                    let json = "{\"type\":\"custom\", \"subtype\":\"\(type)\", \"name\":\(name) }"
                                                    let result = invokeCatalyst(commandJson: json)
                                                    handleSDKJson(result)
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                }
                
                let newPath = path + "/" + key
                traverseTreeHelper(tree: node, depth: depth + 1, path: newPath, parent: tree, grandparent: parent)
            }
            return
        }
        if let tree = tree as? [Any] {
            var i = 0
            for node in tree {
                let newPath = path + "/array" + String(i)
                traverseTreeHelper(tree: node, depth: depth + 1, path: newPath, parent: tree, grandparent: parent)
                i += 1
            }
            return
        }
        
        return
    }
    
}
