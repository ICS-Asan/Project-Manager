import Foundation
import CoreData


extension ProjectData {
    static let entityName = "ProjectData"

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectData> {
        return NSFetchRequest<ProjectData>(entityName: entityName)
    }

    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var date: Double
    @NSManaged public var id: UUID
    @NSManaged public var state: String

}

extension ProjectData : Identifiable {

}

extension ProjectData {
    func translateToModelType() -> Project {
        let projectState = ProjectState(title: self.state) ?? ProjectState.todo
        return Project(title: self.title, body: self.body, date: self.date, state: projectState, id: self.id)
    }
}
