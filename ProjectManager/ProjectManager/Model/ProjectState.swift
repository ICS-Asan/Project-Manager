import Foundation

enum ProjectState: String {
    case todo = "TODO"
    case doing = "DOING"
    case done = "DONE"
    
    init?(title: String) {
        self.init(rawValue: title)
    }
    
    var title: String {
        return self.rawValue
    }
}
