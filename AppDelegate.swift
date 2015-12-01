

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var thread:NSThread!
    var isFinishAni:Bool!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        isFinishAni=false
        //首先起一个异步程序...
        //NSThread.detachNewThreadSelector("searchLocalData", toTarget: self, withObject: nil)
        thread=NSThread(target: self, selector: "newThread", object: nil)
        thread.start()
        
        let storyBoard=UIStoryboard(name: "LaunchScreen", bundle: nil)
        var myRootViewController:UIViewController
        myRootViewController=storyBoard.instantiateInitialViewController()!
        self.window?.rootViewController=myRootViewController

        var label=myRootViewController.view.subviews[0]
        //var destinationVew=ViewController()
        UIView.animateWithDuration(0.3,
            animations: {
                label.layer.position.y -= 5
            },
            completion: {
                (finished) in
                    UIView.animateWithDuration(0.3, delay: 0,usingSpringWithDamping: 0.2,initialSpringVelocity: 5.0,options: UIViewAnimationOptions.CurveEaseOut,
                        animations: {
                            label.layer.position.y += 5
                        }, completion: {
                            (finished:Bool)->Void in
                            sleep(2)
                            self.isFinishAni=true
                            print("动画结束...")
                    })})

        return true
    }
    func newThread(){
        
        if(searchLocalNewestID() != nil){
            
            if(searchLocalNewestID() >= searchNetNewestID()){//本地数据最新...
                
                print("本地数据已经是最新...")
                //刷新主线程...
                self.performSelectorOnMainThread("jumpToMainView", withObject: nil, waitUntilDone: true)
                
            }else if(searchLocalNewestID() < searchNetNewestID()){//本地数据不是最新...
                
                print("本地数据不是最新...")
                delLocalData()
                downAndSaveData()
                //下载并保存网络数据...
            }
        }else{//本地没有数据...
            
            print("本地没有数据...")
            downAndSaveData()
            //下载并保存网络数据...
            
        }
        thread.cancel()
        print("thread结束...")
        
    }
   
    
    func jumpToMainView(){
        
        let timmer:NSTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkAni:", userInfo: nil, repeats: true)
        
    }
    func checkAni(timer:NSTimer){

        if(self.isFinishAni == true){
            
            var destinationVew=ViewController()
            self.window!.rootViewController=destinationVew

            timer.invalidate()
        }
        
    }
    
    //查找本地最新编号...
    func searchLocalNewestID()->Int32?{
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context=app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        fetchRequest.sortDescriptors = [sortDescrpitor]
        var _existID:Int32?
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                for _product:Product in fetchObjects as! [Product]{
                    
                    _existID=_product.id!.intValue
                }
                
            }
        }catch(let error){
            
            print("查找本地最新编号失败...")
            print(error)
        }
        return _existID
        
    }
    //查找服务器最新编号...
    func searchNetNewestID()->Int32?{
        
        var address1="http://120.26.215.42:8080/touWhat/getNewestInfo.action"
        var address2="http://127.0.0.1:8080/touWhat/getNewestInfo.action"
        var url:NSURL=NSURL(string:address2)!
        var urlRequest:NSURLRequest=NSURLRequest(URL: url)
        var response:NSURLResponse?
        var error:NSError?
        var jsonResult:NSArray?
        var newestID:Int32?
        
        do {
            let data = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: &response)
            var numberStr=NSString(data:data,encoding:NSUTF8StringEncoding)
            newestID=(numberStr?.intValue)!
            
        }catch(let error){
            print("查找服务器最新编号失败...")
            print(error)
        }
        return newestID
    }
    
    func  delLocalData(){
        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context=app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        fetchRequest.fetchLimit=100
        fetchRequest.fetchOffset=0
        var entity:NSEntityDescription = NSEntityDescription.entityForName("Product", inManagedObjectContext: context)!
        fetchRequest.entity=entity
        //降序排序...
        var sortDescrpitor = NSSortDescriptor(key: "id", ascending: false,selector: Selector("localizedStandardCompare:"))
        fetchRequest.sortDescriptors = [sortDescrpitor]
        do{
            var fetchObjects:[AnyObject] = try context.executeFetchRequest(fetchRequest)
            if(fetchObjects.count > 0){
                for _product:Product in fetchObjects as! [Product]{
                    
                    context.deleteObject(_product)
                    do{
                        try context.save()
                    }catch(let error){
                        print("本地数据删除失败...")
                        print("error")
                    }
                }
            }
        }catch(let error){
            
            print("在执行删除本地数据时，查询本地数据失败...")
            print("error")
        }
        print("本地数据已经删除...")
    }
    
    //下载并保存网络数据...
    func downAndSaveData(){
        
        var address1="http://120.26.215.42:8080/touWhat/getWords.action"
        var address2="http://127.0.0.1:8080/touWhat/getWords.action"
        var url:NSURL=NSURL(string:address2)!
        var urlRequest:NSURLRequest=NSURLRequest(URL: url)
        var response:NSURLResponse?
        var error:NSError?
        var jsonArray:NSArray!
        do {
            let data = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: &response)
            //var jsonArray=NSString(data:data,encoding:NSUTF8StringEncoding)
            jsonArray = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            let app=UIApplication.sharedApplication().delegate as! AppDelegate
            let context=app.managedObjectContext
            var error:NSError?

            for(var i=0;i < jsonArray!.count;i++){
                
                print(i)
                var product=NSEntityDescription.insertNewObjectForEntityForName("Product", inManagedObjectContext: context) as! Product
                product.id=jsonArray[i]["id"] as! NSNumber
                product.name=jsonArray[i]["name"] as! String
                product.title=jsonArray[i]["title"] as! String
                product.author=jsonArray[i]["author"] as! String
                
                //var URL:NSURL = NSURL(string: imgStr)!
                var imgStrHead=jsonArray[i]["head"] as! String
                var data:NSData?=NSData(contentsOfURL: NSURL(string: imgStrHead)!)
                product.head=data
  
                var imgStrDetail=jsonArray[i]["detail"] as! String
                var dataDetail:NSData?=NSData(contentsOfURL: NSURL(string: imgStrDetail)!)
                product.detail=dataDetail

                var imgStrIcon=jsonArray[i]["icon"] as! String
                var dataIcon:NSData?=NSData(contentsOfURL: NSURL(string: imgStrIcon)!)
                product.icon=dataIcon

                var imgStrContent=jsonArray[i]["content"] as! String
                var dataContent:NSData?=NSData(contentsOfURL:
                    NSURL(string: imgStrContent)!)
                product.content=dataContent
                
                do{
                    try context.save()
                }catch{
                    print(error)
                }
            }
            
        } catch (let error) {
            
            print("下载并保存网络数据失败...")
            print(error)

        }
    }
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "lemontree.P2PSelected" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("P2PSelected", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

