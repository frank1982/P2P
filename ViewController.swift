

import UIKit

class ViewController: UIViewController,CenterViewControllerDelegate {
    
    var leftController=LeftViewController()
    //var centerController=CenterViewController()
    var centerController=ContentTableViewController()
    var menuController=LeftMenuViewController()
    var leftView=UIView()
    var centerView=UIView()
    var _constant=_Constant()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerController.delegate=self
        
        leftView=leftController.view
        centerView=centerController.view
        var _color=_constant.getRandomColor()
        centerView.backgroundColor=_color

        self.view.addSubview(centerView)
        self.view.addSubview(leftView)
        self.view.bringSubviewToFront(centerView)
        leftView.addSubview(menuController.view)
        
  
    }
    func changeScale(scale:CGFloat) {
        
        //print("scale is: \(scale)")
        self.menuController.view.layer.setAffineTransform(CGAffineTransformMakeScale(scale,scale))
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

