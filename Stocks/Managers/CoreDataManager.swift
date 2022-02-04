import Foundation
import CoreData
import UIKit


public class CoreDataManager {

public static let shared = CoreDataManager()

let identifier: String  = "tate.Stocks"       //Framework bundle ID
let model: String       = "Model"                      //Model name


lazy var persistentContainer: NSPersistentContainer = {

let messageKitBundle = Bundle(identifier: self.identifier)
let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!

let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)


let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
container.loadPersistentStores { (storeDescription, error) in

if let err = error{
fatalError("❌ Loading of store failed:\(err)")
}
}

return container
}()
   
     func fetchSymbols() -> [SearchResult] {
    let context = persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<WatchList>(entityName: "WatchList")

 
var versions = [SearchResult]()
    do{
        
    let fetchedData = try context.fetch(fetchRequest)
      
        if fetchedData.count > 0 {
            
       
        for index in 0...fetchedData.count  - 1 {
            
            versions.append(SearchResult(description: "", displaySymbol: "", symbol: "", type: ""))
            versions[versions.count - 1].symbol = fetchedData[index].symbol_!
            versions[versions.count - 1].description = fetchedData[index].description_!
            versions[versions.count - 1].type = fetchedData[index].type_!
            versions[versions.count - 1].displaySymbol = fetchedData[index].displaySymbol_!
        }
            
        }
        


    try context.save()

    }catch let fetchErr {

    print("❌ Failed to fetch Person:",fetchErr)
        
    }
    return versions

    }
     func appendSymbol(symbol: SearchResult){

    let context = persistentContainer.viewContext
    let Store = NSEntityDescription.insertNewObject(forEntityName: "WatchList", into: context) as! WatchList
            
        
        Store.displaySymbol_ = symbol.displaySymbol
        Store.type_ = symbol.type
        Store.description_ = symbol.description
        Store.symbol_ = symbol.symbol
        
    do {
    try context.save()


    } catch let error {
    print("❌ Failed to create Person: \(error.localizedDescription)")
    }
    }

         func deleteSymbol(symbol: SearchResult){
    
                      let context = persistentContainer.viewContext
    
               let fetchRequest = NSFetchRequest<WatchList>(entityName: "WatchList")
    
               let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    
                 do{
                            var array = try context.fetch(fetchRequest)
             
                     for object in array {
                         if object.symbol_! == symbol.symbol {
                             context.delete(object)
                         }
                     }
                     try context.save()
    
                        }catch let fetchErr {
                            print("❌ Failed to fetch Person:",fetchErr)
                        }
    
           }
    public func delete_All(){

    let context = persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<WatchList>(entityName: "WatchList")

    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    do {
    try context.execute(batchDeleteRequest)

    } catch {
    // Error Handling
    }
        
    }
}
