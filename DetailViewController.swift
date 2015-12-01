

import UIKit

class DetailViewController: UIViewController,UIScrollViewDelegate{

    var scrollView:UIScrollView!
    var head:UIImageView!
    var headTitle:UIView!
    var _headViewWidth:CGFloat!
    var _headViewHeight:CGFloat!
    var _width:CGFloat!
    var _height:CGFloat!
    //var _strHead:String!
    //var _strScroll:String!
    var _strHead:UIImage!
    var _strScroll:UIImage!
    var _startPoint:CGPoint!
    var _startOffset:CGFloat!
    var _tmpOffset:CGFloat!
    var _tmpPoint:CGPoint!
    var _endPoint:CGPoint!
    var _moveDirection:Int!
    var _canMove:Bool=true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor=UIColor.whiteColor()
        _width=self.view.frame.width
        _height=self.view.frame.height
        _moveDirection=0
        var _constant=_Constant()
        
        self.view.clipsToBounds=true
        scrollView=UIScrollView(frame:CGRectMake(0,20,_width,_height))
        scrollView.backgroundColor=UIColor.grayColor()
        scrollView.clipsToBounds=true//裁掉多出的图片...
        //scrollView.bounces=false
        self.view.addSubview(scrollView)
        scrollView.delegate=self
        
        head=UIImageView(frame:CGRectMake(0,0,_width,_height*0.2))
        //head.backgroundColor=UIColor.redColor()
        
        //head.image=UIImage(named:_strHead)
        head.image=_strHead
        
        //head.contentMode=UIViewContentMode.ScaleToFill//填满imagview...
        head.contentMode=UIViewContentMode.ScaleAspectFill//保持长宽比...
        _headViewWidth=head.frame.width
        _headViewHeight=head.frame.height
        scrollView.addSubview(head)
    
        headTitle=UIView(frame:CGRectMake(0,head.frame.origin.y+head.frame.height,_width,head.frame.height/2))
        headTitle.backgroundColor=UIColor.whiteColor()
        scrollView.addSubview(headTitle)
        
        //var image=UIImage(named: _strScroll)
        var image=_strScroll
        
        var _yToX=image!.size.height/image!.size.width
        var imageView=UIImageView(frame:CGRectMake(0,headTitle.frame.origin.y+headTitle.frame.size.height,_width,_width*_yToX))
  
        imageView.image=image
        imageView.contentMode=UIViewContentMode.ScaleAspectFill
        imageView.backgroundColor=UIColor.whiteColor()
        scrollView.addSubview(imageView)
        scrollView.contentSize=CGSizeMake(_width, imageView.frame.height+headTitle.frame.height+head.frame.height)
        scrollView.userInteractionEnabled=false
        
        //增加操作按钮区域...
        var menuView=UIView(frame:CGRectMake(0, _height-44, _width, 44))
        menuView.backgroundColor=UIColor.whiteColor()
        self.view.addSubview(menuView)
        var back=UIButton(frame:CGRectMake(6,6,40,32))
        back.setBackgroundImage(UIImage(named:"back"), forState: UIControlState.Normal)
        back.setBackgroundImage(UIImage(named:"back"), forState: UIControlState.Selected)
        back.contentMode=UIViewContentMode.ScaleToFill
        //点击事件....
        back.addTarget(self, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        menuView.addSubview(back)
        
    }
    func back(){
        
        print("click back btn...")
        //移除...
        self.view.removeFromSuperview()
        //self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.removeFromParentViewController()
        self._canMove=true

    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        _startPoint=(touches as NSSet).anyObject()?.locationInView(self.view)
        _startOffset=self.scrollView.contentOffset.y
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

        _tmpPoint=(touches as NSSet).anyObject()?.locationInView(self.view)
        _tmpOffset=self.scrollView.contentOffset.y
       
        var dx=_tmpPoint.x-_startPoint.x
        var dy=_tmpPoint.y-_startPoint.y
        
        if(dx > 0&&_moveDirection != 2){
            _moveDirection=1//横向移动...
        }else if(_moveDirection != 1){
            _moveDirection=2//垂直移动...
            
           
        }
        if(_canMove&&_moveDirection == 1){
            
            //print("now dx is:\(dx)")
            dx=max(-self.view.frame.origin.x,dx)
            dx=min(_width,dx)
            self.view.frame.origin.x += dx
        }else if(_canMove&&_moveDirection == 2){//垂直移动...
            
            var H=dy/2
            H=min(H,120+_startOffset)//向下移动的最大距离...
            //H=max(H,_startOffset-self.head.frame.height)//向上移动的最大距离...
            H=max(H,_startOffset-(self.scrollView.contentSize.height-_height))
            self.scrollView.setContentOffset(CGPoint(x: 0, y:_startOffset-H), animated: false)
            
            //向下移动...
            if(_tmpOffset < 0){
                
                var centerPoint=CGPoint(x:_width/2,y:20+(_headViewHeight-_startOffset+H)/2)
                //坐标转换...
                var midPoint = self.view.convertPoint(centerPoint, toView: self.scrollView)
                //需要向上移动图片中心位置...
                head.center.y = midPoint.y
                //放大图片...
                head.layer.setAffineTransform(CGAffineTransformMakeScale((_headViewHeight-_startOffset+H)/_headViewHeight,(_headViewHeight-_startOffset+H)/_headViewHeight))
            }else{
                
                var centerPoint=CGPoint(x:_width/2,y:20+_headViewHeight/2)
                //坐标转换...
                var midPoint = self.view.convertPoint(centerPoint, toView: self.scrollView)
                
                //图片位置不动...
                head.center.y = midPoint.y
            }
        }
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        var _endPoint=(touches as NSSet).anyObject()?.locationInView(self.view)
        
        if(self.view.frame.origin.x >= 60){
            _canMove=false

            UIView.animateWithDuration(1,
                animations: {
                    self.view.frame.origin.x = self._width
                },
                completion: {
                    (finished) in
                    
                    //移除...
                    self.view.removeFromSuperview()
                    //self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
                    self.removeFromParentViewController()
                    self._canMove=true
                    
                    //需要锁定table的click...
                   
                })

        }
        self._moveDirection=0
        print(_moveDirection)

    }

        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
