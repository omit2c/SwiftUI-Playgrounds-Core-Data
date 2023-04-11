---

Swift Playgrounds - Use Core Data
When developing a small app in Swift Playgrounds for the Apple Swift Student Challenge 2023, I wanted to use Core Data as the database to store data.
As I have to use Swift Playgrounds to develop the app I quickly noticed that there is no easy way to create a Core Data Store as you are used to in XCode. This means you have to code all entities, attributes and relationships by hand.

---

What is Core Data?
First what is Core Data? I am sure some of you might now the concept and functions of Core Data, but I will quickly sum up the core features and use cases of Core Data for those who don't know.
Core Data is a framework provided by Apple for macOS, iOS, watchOS, and tvOS platforms. It is used for managing the model layer of an application's data, including data persistence, data caching, and data modeling. Core Data allows you to represent an application's data in an object-oriented way, using entities, attributes, and relationships, and provides a range of features such as automatic validation, automatic versioning, and support for undo and redo operations.

---

Set up your playground
Download the Playgrounds app (available for iPad and Mac):
‎Swift Playgrounds
‎Mit Swift Playgrounds macht es Spaß, Programmieren zu lernen und echte Apps zu entwickeln. In der geführten Lektion…apps.apple.com
When opening the app, press ⌘⇧N to create a new Playground. Choose a name for your project and open it by double clicking on it
A new playgrounds projectThat's it, you just set up your new Swift playground in the Playgrounds app.

---

Create entities
First of all I start with creating a folder with a new file in it.
In the "DataModels.swift" file I now can create my entities. In this example I will create a team (e.g. a sports team) with some players. Let's start with the team:
Import the Core Data framework
Create a class for the team
Add all wanted attributes
Make the class identifiable

import SwiftUI
// 1
import CoreData

// 2
@objc(Team)
class Team: NSManagedObject {
    // 3
    @NSManaged var identifier: UUID
    @NSManaged var teamName: String
    @NSManaged var members : NSSet
}

// 4
extension Team: Identifiable {
    var id : UUID {
        identifier
    }
}
Notice that you have to use a NSSet to make One-to-many or Many-to-many relationships later on.
Then do the same for the player class:
// Create a class for the player
@objc(Player)
class Player: NSManagedObject {
    // Add all wanted attributes
    @NSManaged var identifier: UUID
    @NSManaged var name: String
    @NSManaged var teams : NSSet
    @NSManaged var category: Int
    @NSManaged var picture: Data?
    @NSManaged var position: String
    @NSManaged var birthdate: Date
    @NSManaged var phoneNumber: String
}

// Make the class identifiable
extension Player: Identifiable {
    var id : UUID {
        identifier
    }
}
As the player can play in different teams (e.g. a hobby team and a sports team) I will use a many-to-many relation between the two entities.
Now you have two entities, but they aren't in any relation.
Create a persistence container
Before you can start linking the two created models you have to create persistence controller. The controller will keep the data and manages it for your app automatically.
Unfortunately you have to create the controller by yourself. If you are using XCode this will be automatically will be created when ticking the "Use Core Data" checkbox while creating a new project.
In Playgrounds you can just use a standard controller like this:
import SwiftUI
import CoreData

/// The persistence controller for Core Data
class Persistence {
    static let shared = Persistence()
    
    let container : NSPersistentContainer
    /// Load the used container with the database
    init(inMemory: Bool = false) {
        
        let container = NSPersistentContainer(name: "TeamModel", managedObjectModel: // We will add this later)
        
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
Please notice the "We will add this later" comment. This is the place for the creation of the relation of the model. Currently you only created the models, but you need to create the models too.

---

Create the Models and Relationships
First you have to create an extension for your persistence controller, like this:
extension Persistence {
  // Here we will create the model descriptions
}
Let's start with creating the model by simply creating an entity description:
let teamEntity = NSEntityDescription()
teamEntity.name = "Team"
teamEntity.managedObjectClassName = "Team"
Then add the attributes to the entity:
let teamNameAttribute = NSAttributeDescription()
teamNameAttribute.name = "teamName"
teamNameAttribute.type = .string
teamEntity.properties.append(teamNameAttribute)

let teamIDAttribute = NSAttributeDescription()
teamIDAttribute.name = "identifier"
teamIDAttribute.type = .uuid
teamEntity.properties.append(teamIDAttribute)
If you have done that, we can do the same for the persons model:
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
After that you can focus on the relations, which are a little bit trickier, but nothing you should be afraid of.
First you need an empty model / a new model:
let model = NSManagedObjectModel()
Then use the previously created person description:
let person = Persistence.createPersonEntity()
Now you have to create two relations: One for the team - member relation and one for the member - team relation:
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
With the "minCount" and "maxCount" you can choose the minimum and maximum amount of related objects. If you let the "maxCount" be 0. you have a 0 to n relation.
After that you have to add the inverse relation to each model:
memberRelation.inverseRelationship = teamRelation
teamRelation.inverseRelationship = memberRelation
Then you can add the final relationships to the entities itself:
teamEntity.properties.append(memberRelation)
person.properties.append(teamRelation)
Finally you just have to add the entities to your model like this:
model.entities = [teamEntity, person]

---

Summary
Creating a working Core Data database in Swift Playgrounds isn't as easy and intuitive as in Xcode, but I think the little effort you have to take is worth as Core Data makes working with data very easy.
After you created the Persistence Controller you can use Core Data as usual. You can also add as much attributes and relationships as you want.

---

I hope you liked my first little tutorial about Core Data in Swift Playgrounds. If you do so, also check my own app on the AppStore, which also relies on Core Data:
‎Memoly - Your diary
‎Memoly is your diary through and through. Customize Memoly to your needs so you never forget your memories. Now you're…apps.apple.com
If you want to check out my socials check these:
Memoly
Your personal diary for iOS, iPadOS and watchOS. Soon coming for Mac...bento.me
Timo
Hey, I'm Timo. Developer of @memoly_app.bento.me
The whole source code can be found here:
