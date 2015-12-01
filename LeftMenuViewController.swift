

import UIKit



class LeftMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var _constant=_Constant()
        //head icon...
        var headIcon=UIImageView()
        headIcon.image=UIImage(named:"menuHead")
        headIcon.sizeToFit()
        headIcon.frame.origin=CGPoint(x:25,y:35)
        //headIcon.backgroundColor=UIColor.redColor()
        self.view.addSubview(headIcon)

        //head label
        var headLabel=UILabel()
        headLabel.text="登录"
        headLabel.font=UIFont(name: _constant._textFont, size: 28)
        headLabel.sizeToFit()
        headLabel.textColor=UIColor.whiteColor()
        //headLabel.backgroundColor=UIColor.redColor()
        headLabel.frame.origin.y=headIcon.frame.origin.y+headIcon.frame.height/2-headLabel.frame.height/2
        headLabel.frame.origin.x=headIcon.frame.origin.x+headIcon.frame.width+20
        self.view.addSubview(headLabel)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
