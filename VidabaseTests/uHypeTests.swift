//
//  VidabaseTests.swift
//  VidabaseTests
//
//  Created by Carlos Martinez on 4/8/16.
//  Copyright © 2016 Carlos Martinez. All rights reserved.
//

import XCTest
import CoreData
@testable import Pods_uHype
@testable import uHype

class VidabaseTests: XCTestCase {
    
    // MARK: - Properties
    var managedObjectContext:NSManagedObjectContext?
    var fetchRequest = NSFetchRequest<NSFetchRequestResult>.init()
    var retrievedUser:User?
    var newUser:User?
    
    // MARK: - Setup Methods
    /* setUp executes methods in preparation for the Unit tests
     * The test has eight parts:
     * 1. Creates and NSDictionary with test information; checks for Not Nil.
     * 2. Creates a NSPersistentStoreCoordinator and adds to it an In-Memory Store. checks for success adding store.
     * 3. Initialize and NSManagedObjectContext and adds PersistentStoreCoordinator to it; checks for Not Nil.
     * 4. Adds a Contact object to the In-Memory Store.
     * 5. Creates a Fetch Request; checks for Not Nil.
     * 6. Get an Entity Description from In-Memory Store; checks for Not Nil.
     * 7. Fetch Object from In-Memory Store; checks for Not Nil and no Errors.
     * 8. Add Fetched Object to test method property (contact).
     */
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator:NSPersistentStoreCoordinator  = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel.mergedModel(from: nil)! )
        
        // Verify if Persistent Store was added to the Coordinator
        var persistentStore:NSPersistentStore! = nil
        do {
            persistentStore = try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            XCTAssertNotNil(persistentStore, "Should be able to add in-memory store")
        }
        
        // Initialize Managed Object Context
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext!.persistentStoreCoordinator = persistentStoreCoordinator
        XCTAssertNotNil(self.managedObjectContext, "Cannot create NSManagedObjectContext instance");
        
        //Add Object to In-Memory Store
        testAddContact()
        
        // Get Entity Description from Store and add to Fetch Request
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: Constant.Entity.User, in: self.managedObjectContext!)!
        
        // Set entiry on Fetch Request
        self.fetchRequest.entity = entity
        XCTAssertNotNil(entity, "Cannot get Entity In-Memory Store");
        
        var fetchedObjects = [Any]()
        // Fetch objects from In-memory store
        do{
            fetchedObjects = try self.managedObjectContext!.fetch(self.fetchRequest)
            
            // Get Contact from FetchObjects Array at index 0
            self.retrievedUser = fetchedObjects[0] as? User
        } catch {
            XCTAssertNotNil(fetchedObjects, "Cannot get Objects from In-Memory Store");
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Tests
    /* testAddContact attempts to Add a contact to the In-Memory Store, from an NSDictionary object
     * The test has two parts:
     * 1. Check that saveContext:error returns 'True' after saving context.
     * 2. Check that the Error object is nil after saving context.
     */
    func testAddContact() {
        
        // No User in Local Database - Construct Dictionary for New User
        let testUserdictionary: [String : String] = [
            User.Keys.Uid :"ABCDEFG!@#$%23456",
            User.Keys.Email : "johndoe@domain.com"
        ]
        
        // We Create a new user in local database and assign to property.
        self.newUser = User(dictionary: testUserdictionary as [String : AnyObject], context: self.managedObjectContext!)
        XCTAssertNotNil(self.newUser, "Did not initialize a new user");
        
        // Save added or modified data to MySQL database
        testSaveContext()
    
    }
    
    // MARK: - Core Data Saving support
    func testSaveContext () {
        if self.managedObjectContext!.hasChanges {
            do {
                // Try saving the User
                try self.managedObjectContext!.save()
                
            } catch {
                
                // Error Saving User Throw Assertion
                let nserror = error as NSError
                XCTAssertNil(nserror, "Unable to save new User in Context")
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
