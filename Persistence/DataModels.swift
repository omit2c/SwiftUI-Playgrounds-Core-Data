import SwiftUI
// Import the Core Data framework
import CoreData

// Create a class for the team
@objc(Team)
class Team: NSManagedObject {
    // Add all wanted attributes
    @NSManaged var identifier: UUID
    @NSManaged var teamName: String
    @NSManaged var members : NSSet
}

// Make the class identifiable
extension Team: Identifiable {
    var id : UUID {
        identifier
    }
}

// Create a class for the player
@objc(Player)
class Player: NSManagedObject {
    // Add all wanted attributes
    @NSManaged var identifier: UUID
    @NSManaged var name: String
    @NSManaged var teams : NSSet
}

// Make the class identifiable
extension Player: Identifiable {
    var id : UUID {
        identifier
    }
}
    
