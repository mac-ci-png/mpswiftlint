import Foundation
import SourceKittenFramework

class MPSwiftLintSyntax {
    
    class func parse(contents: String) -> [String: Any]? {
        guard let obj = createSyntaxTree(contents: contents) else { return nil }
        let changedObj = transformTree(tree: obj, contents: contents)
        return changedObj
    }
    
    class func createSyntaxTree(contents: String) -> [String: Any]? {
        var result: Structure? = nil
        let file = File(contents: contents)
        do {
            try result = Structure(file: file)
        } catch {
            print("Failed to create syntax tree: \(error)")
        }
        if let result = result {
            let syntaxString = result.description
            let obj = convertSyntaxString(syntaxString)
            return obj
        }
        return nil
    }
    
    class func convertSyntaxString(_ syntaxString: String) -> [String: Any]? {
        let data = syntaxString.data(using: .utf8)
        if let data = data {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any] {
                return dictionary
            }
        }
        return nil
    }
    
    class func transformTree(tree: [String: Any], contents: String) -> [String: Any]? {
        if let value = transformTreeHelper(tree: tree, contents: contents, depth:0, path:"") as? [String: Any] {
            return value
        }
        return nil
    }
    
    class func transformTreeHelper(tree: Any, contents: String, depth: Int, path: String) -> Any {
        if let tree = tree as? [String: Any] {
            var transformedTree: [String: Any] = tree
            var bodyoffset: Int? = nil
            var bodylength: Int? = nil
            for (key, node) in tree {
                if key == "key.bodyoffset" {
                    if let intNode = node as? Int {
                        bodyoffset = intNode
                    }
                } else if key == "key.bodylength" {
                    if let intNode = node as? Int {
                        bodylength = intNode
                    }
                }
                if let offset = bodyoffset, let length = bodylength {
                    let offsetIndex = String.Index(encodedOffset: offset)
                    let newStr = contents[offsetIndex...]
                    if newStr.count > length {
                        let lengthIndex = newStr.index(newStr.startIndex, offsetBy: length)
                        let body = newStr[..<lengthIndex]
                        transformedTree.updateValue(body, forKey: "key.body")
                    }
                    
                    bodyoffset = nil
                    bodylength = nil
                }
                let newPath = path + "/" + key
                let result = transformTreeHelper(tree: node, contents: contents, depth: depth + 1, path: newPath)
                transformedTree.updateValue(result, forKey: key)
            }
            return transformedTree
        }
        if let tree = tree as? [Any] {
            var transformedTree: [Any] = []
            var i = 0
            for node in tree {
                let newPath = path + "/array" + String(i)
                let result = transformTreeHelper(tree: node, contents: contents, depth: depth + 1, path: newPath)
                transformedTree.append(result)
                i += 1
            }
            return transformedTree
        }
        
        return tree
    }
}
