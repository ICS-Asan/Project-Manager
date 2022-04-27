import Foundation
import CoreData


extension ProjectData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectData> {
        return NSFetchRequest<ProjectData>(entityName: "ProjectData")
    }

    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var date: Double
    @NSManaged public var id: UUID?
    @NSManaged public var state: String?

}

extension ProjectData : Identifiable {

}
