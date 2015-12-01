
import UIKit
import CoreData

class ContentTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var _width:CGFloat!
    var _height:CGFloat!
    //test data
    var _myData:[Product]!
    var _data:[Dictionary<String,String>]!
    var _icons:[String]!
    var _canClick:Bool=true//能否点击，当DetailViewController的结束动画未完成时，要锁定...

    var delegate:CenterViewControllerDelegate?
    
    var startPoint : CGPoint!
    var tmpPoint0 : CGPoint!
    var tmpPoint1 : CGPoint!
    var tmpPoint2 : CGPoint!
    //var startOffset:CGFloat!
    var beginOffset:CGFloat!
    var tableView:UITableView!
    var iconTableView:UITableView!
    var _iconCellWidth:CGFloat!
    var _iconCellHeight:CGFloat!
    var _pageNum:Int!
    var _startTime:NSDate!
    var _endTime:NSDate!
    var _oldPageNum:Int!//之前被选中的iconCell row...
    var _contains:Bool=false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _pageNum=0
        //初始化本地测试数据...
        
        _myData=[]        
        let app=UIApplication.sharedApplication().delegate as! AppDelegate
        let context=app.managedObjectContext
        var error:NSError?
        var fetchRequest:NSFetchRequest=NSFetchRequest()
        //fetchRequest.fetchLimit=100
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
                    
                   _myData.append(_product)
                }
            }
        }catch(let error){
            
            print("content中读取数据失败...")
        }
        
        _data=[]
        for(var i=0;i<12;i++){
            var name:String="名称"+String(i)
            var title:String="标题"+String(i)
            var content:String="这里是产品说明"
            var detailHead:String="Head"
            var detailScroll:String="detail"
            var author:String="老西"
            var tmpDict=["name":name,"title":title,"content":content,"author":author,"detailHead":detailHead,"detailScroll":detailScroll]
            _data.append(tmpDict)
        }
        _icons=[]
        for(var i=0;i<12;i++){
            var iconName:String="IconDemo"
            _icons.append(iconName)
        }
        
        _width=self.view.frame.width
        _height=self.view.frame.height
        
        //tableView=UITableView(frame:CGRectMake(0,0,_height-132,_width))
        tableView=UITableView(frame:CGRectMake(-(_height-132-_width)/2,(_height-_width)/2,_height-132,_width))
        tableView.backgroundColor=UIColor.clearColor()
        tableView.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        self.tableView.showsVerticalScrollIndicator = false//隐藏滚动条...
        self.tableView.separatorStyle=UITableViewCellSeparatorStyle.None//去掉分割线...
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        tableView.delegate=self
        tableView.dataSource=self
        self.view.addSubview(tableView)

        self.tableView.userInteractionEnabled=false
 
        //增加iconCell...
        _iconCellWidth=60
        _iconCellHeight=(_width-50)/8
        iconTableView=UITableView(frame:CGRectMake(_width/2-_iconCellWidth/2,_height-4.5*_iconCellHeight-15,_iconCellWidth,_iconCellHeight*8))
        iconTableView.backgroundColor=UIColor.clearColor()
        iconTableView.transform=CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        self.iconTableView.showsVerticalScrollIndicator = false//隐藏滚动条...
        self.iconTableView.separatorStyle=UITableViewCellSeparatorStyle.None//去掉分割线...
        self.iconTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "iconCellIdentifier")
        iconTableView.delegate=self
        iconTableView.dataSource=self
        self.view.addSubview(iconTableView)
        
        /*
        var maskView=UIView(frame:CGRectMake(0,66,self.view.frame.width,self.view.frame.height-132))
        self.view.addSubview(maskView)
        maskView.backgroundColor=UIColor.grayColor()
        maskView.alpha=0.1
        self.view.bringSubviewToFront(maskView)
        var tapGesture=UITapGestureRecognizer(target: self, action: "tapGesture:")
        maskView.addGestureRecognizer(tapGesture)
        */
        
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if(tableView == iconTableView){return 1}
        else{return 1}
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == iconTableView){return _data.count}
        else{return _data.count}
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(tableView == iconTableView){
            
            let cellID:String="iconCellIdentifier"
            //var cell=iconTableView.dequeueReusableCellWithIdentifier(cellID)
            var cell=IconCell(cellID: cellID,_icon:_myData[indexPath.row].icon!,myHeight:_iconCellHeight,myWidth:_iconCellWidth)
            return cell
            
        }else{

            let cellID:String="cellIdentifier"
            //var cell = tableView.dequeueReusableCellWithIdentifier(cellID)
            //var cell=MainCell(cellID: cellID,info:_data[indexPath.row],myHeight:_height-132,myWidth:_width)
            var cell=MainCell(cellID: cellID,_product:_myData[indexPath.row],myHeight:_height-132,myWidth:_width)
            return cell
        }
        
    }
    //设置cell高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(tableView == iconTableView){
            
            return _iconCellHeight
        }else{
            
            return _width
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        tmpPoint0=(touches as NSSet).anyObject()?.locationInView(self.view)//用于点击比较位置...
        tmpPoint1=(touches as NSSet).anyObject()?.locationInView(self.view)
        var _hRect=CGRectMake(0,0,_width,self.tableView.frame.origin.y)
        _contains=CGRectContainsPoint(_hRect, tmpPoint1!)
        beginOffset=self.tableView.contentOffset.y//计算划动速度...
        _startTime=NSDate()
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(_contains){
            var tmpPoint=(touches as NSSet).anyObject()?.locationInView(self.view)
            var dx=tmpPoint!.x-tmpPoint1.x
            dx = max(-self.view.frame.origin.x,dx)//左边界...
            dx = min(_width*3/4-self.view.frame.origin.x,dx)//右边界...
            self.view.frame.origin.x += dx
            var scale=self.view.frame.origin.x/(_width*3/4)
            delegate!.changeScale(CGFloat(scale))
        }else{
            
            tmpPoint2=(touches as NSSet).anyObject()?.locationInView(self.view)
            //取得变化的速度....
            var dx=tmpPoint2!.x-tmpPoint1!.x
            tmpPoint1=tmpPoint2
            self.tableView.setContentOffset(CGPoint(x:0,y:beginOffset-dx), animated:false)
            //更新offset数据...
            beginOffset=self.tableView.contentOffset.y
        }
        
        

    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        var tmpPointEnd=(touches as NSSet).anyObject()?.locationInView(self.view)
        
        if(_contains){
            
            if(self.view.frame.origin.x >= _width/2){
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(0.5)
                self.view.frame.origin = CGPointMake(_width*3/4, 0)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
                UIView.commitAnimations()
            }else{
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(0.5)
                self.view.frame.origin = CGPointMake(0, 0)
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut) //设置动画相对速度
                UIView.commitAnimations()
            }
        }else{
            

            //是否为原地点击事件...
            if(tmpPointEnd!.x-tmpPoint0.x >= -5 && tmpPointEnd!.x-tmpPoint0.x <= 5 && tmpPointEnd!.y-tmpPoint0.y >= -5 && tmpPointEnd!.y-tmpPoint0.y <= 5){
                
                tapGesture()
                
            }
            
            var endOffset=self.tableView.contentOffset.y
            _endTime=NSDate()
            var second = CGFloat(_endTime.timeIntervalSinceDate(_startTime))
            var _v=(endOffset-beginOffset)/second
            
            if(_v >= 1000){
                
                self.tableView.setContentOffset(CGPoint(x:0,y:endOffset+(_width-endOffset%_width)), animated:true)
                
            }else if(_v <= -1000){
                
                self.tableView.setContentOffset(CGPoint(x:0,y:endOffset-endOffset%_width), animated:true)
            }
            else{
                
                if(endOffset%_width<_width/2){
                    
                    self.tableView.setContentOffset(CGPoint(x:0,y:endOffset-endOffset%_width), animated:true)
                }else if(endOffset%_width>=_width/2){
                    
                    self.tableView.setContentOffset(CGPoint(x:0,y:endOffset+(_width-endOffset%_width)), animated:true)
                }
            }

        }        
        
    }
   
    //滚动结束...
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        
        _pageNum=Int(self.tableView.contentOffset.y/_width)
        
        //iconTable滚动...
        //var indexPath=NSIndexPath(forRow: _pageNum, inSection: 0)
        //self.iconTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        //self.iconTableView.setContentOffset(CGPoint(x:0,y:CGFloat(_pageNum)*_iconCellHeight), animated:true)
        
        //iconCell跳动...
        
        //不是首次...
        if(_oldPageNum != nil){
            
            if(_pageNum != _oldPageNum){
                
                if(_pageNum > 4 && _pageNum <= _data.count-1){
                    
                    //iconTable滚动,后面的保持在第五个...
                    print("here is: \(_pageNum)")
                    self.iconTableView.setContentOffset(CGPoint(x:0,y:CGFloat(_pageNum-4)*_iconCellHeight), animated:true)
                    
                    var indexPath1=NSIndexPath(forRow: _pageNum, inSection: 0)
                    var iconCell=self.iconTableView.cellForRowAtIndexPath(indexPath1)
                    iconCell!.viewWithTag(1001)!.frame.origin.x += 10
                    
                    //原来位置的icon缩回...
                    var indexPath2=NSIndexPath(forRow: _oldPageNum, inSection: 0)
                    var cellView2=self.iconTableView.cellForRowAtIndexPath(indexPath2)
                    cellView2?.viewWithTag(1001)!.frame.origin.x -= 10
                    
                }else if(_pageNum <= 4){
                    
                    var indexPath1=NSIndexPath(forRow: _pageNum, inSection: 0)
                    var iconCell=self.iconTableView.cellForRowAtIndexPath(indexPath1)
                    iconCell!.viewWithTag(1001)!.frame.origin.x += 10
                    
                    //原来位置的icon缩回...
                    var indexPath2=NSIndexPath(forRow: _oldPageNum, inSection: 0)
                    var cellView2=self.iconTableView.cellForRowAtIndexPath(indexPath2)
                    cellView2?.viewWithTag(1001)!.frame.origin.x -= 10
                    
                }else if(_pageNum > _data.count-1){
                    
                    loadMore()
                }
            }
            
        }else{//首次...
            
            var indexPath=NSIndexPath(forRow: _pageNum, inSection: 0)
            var iconCell=self.iconTableView.cellForRowAtIndexPath(indexPath)
            iconCell!.viewWithTag(1001)!.frame.origin.x += 10
        }
        
        _oldPageNum=_pageNum
        
    }
    
    func loadMore(){
        
        print("load more...")
        var _count=_data.count
        print("_count")
        for(var i=_count;i<_count+12;i++){
            print("add 1...")
            var name:String="名称"+String(i)
            var title:String="标题"+String(i)
            var content:String="这里是产品说明"
            var author:String="老西"
            var detailHead:String="Head"
            var detailScroll:String="detail"
            var tmpDict=["name":name,"title":title,"content":content,"author":author,"detailHead":detailHead,"detailScroll":detailScroll]
            _data.append(tmpDict)

        }
        for(var i=_count;i<_count+12;i++){
            var iconName:String="IconDemo"
            _icons.append(iconName)
        }
        print("finish load more...")
        self.tableView.reloadData()
        self.iconTableView.reloadData()
        
        //需要把最后一个cell弹出....
        var indexPath1=NSIndexPath(forRow: _pageNum, inSection: 0)
        var iconCell=self.iconTableView.cellForRowAtIndexPath(indexPath1)
        iconCell!.viewWithTag(1001)!.frame.origin.x += 10

    }
    
    //maskView的tap事件响应...
    func tapGesture(){
        
        //跳转detail页面...
        print("tap...")
        if(_canClick){
            var detailViewController=DetailViewController()
            //detailViewController._strScroll=_data[_pageNum]["detailScroll"]
            //detailViewController._strHead=_data[_pageNum]["detailHead"]
            detailViewController._strScroll=UIImage(data:_myData[_pageNum].detail!)
            detailViewController._strHead=UIImage(data:_myData[_pageNum].head!)
            //UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(detailViewController, animated: false, completion:nil)
            UIApplication.sharedApplication().keyWindow?.rootViewController!.addChildViewController(detailViewController)
            
            UIApplication.sharedApplication().keyWindow?.rootViewController!.view.addSubview(detailViewController.view)
            

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
}
protocol CenterViewControllerDelegate{
    
    func changeScale(scale:CGFloat)
}