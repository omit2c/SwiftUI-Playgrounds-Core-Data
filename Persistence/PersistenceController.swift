import SwiftUI
import CoreData

/// The persistence controller for Core Data
class Persistence {
    static let shared = Persistence()
    
    let container : NSPersistentContainer
    /// Load the used container with the database
    init(inMemory: Bool = false) {
        
        let container = NSPersistentContainer(name: "TeamModel", managedObjectModel: Persistence.createTeamModel())
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("failed with \(error.localizedDescription)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        self.container = container
    }
}

extension Persistence {
    static func createTeamModel() -> NSManagedObjectModel {
        let teamEntity = NSEntityDescription()
        teamEntity.name = "Team"
        teamEntity.managedObjectClassName = "Team"
        
        let teamNameAttribute = NSAttributeDescription()
        teamNameAttribute.name = "teamName"
        teamNameAttribute.type = .string
        teamEntity.properties.append(teamNameAttribute)
        
        let teamIDAttribute = NSAttributeDescription()
        teamIDAttribute.name = "identifier"
        teamIDAttribute.type = .uuid
        teamEntity.properties.append(teamIDAttribute)
        
        let model = NSManagedObjectModel()
        let person = Persistence.createPersonEntity() 
        
        let memberRelation = NSRelationshipDescription()
        memberRelation.destinationEntity = person
        memberRelation.name = "members"
        memberRelation.minCount = 0
        memberRelation.maxCount = 0
        memberRelation.isOptional = true
        memberRelation.deleteRule = .nullifyDeleteRule
        
        let teamRelation = NSRelationshipDescription()
        teamRelation.destinationEntity = teamEntity
        teamRelation.name = "teams"
        teamRelation.minCount = 0
        teamRelation.maxCount = 0
        teamRelation.isOptional = true
        teamRelation.deleteRule = .nullifyDeleteRule
        
        memberRelation.inverseRelationship = teamRelation
        teamRelation.inverseRelationship = memberRelation
        
        teamEntity.properties.append(memberRelation)
        person.properties.append(teamRelation)
        
        model.entities = [teamEntity, person]
        
        return model
    }
    
    static func createPersonEntity() -> NSEntityDescription {
        let personEntity = NSEntityDescription()
        personEntity.name = "Person"
        personEntity.managedObjectClassName = "Person"
        
        let personNameAttribute = NSAttributeDescription()
        personNameAttribute.name = "name"
        personNameAttribute.type = .string
        personEntity.properties.append(personNameAttribute)
        
        let personIDAttribute = NSAttributeDescription()
        personIDAttribute.name = "identifier"
        personIDAttribute.type = .uuid
        personEntity.properties.append(personIDAttribute)
        
        return personEntity
    }
}
