

import UIKit
import CoreData

class MainCell: UITableViewCell {
    
    var startPoint : CGPoint!
    var _constant:_Constant!
    var _cellHeight:CGFloat!
    var _cellWidth:CGFloat!
    
    //init(cellID:String,info:Dictionary<String,String>,myHeight:CGFloat,myWidth:CGFloat){
    init(cellID:String,_product:Product,myHeight:CGFloat,myWidth:CGFloat){
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        
        _constant=_Constant()
        _cellHeight=myHeight//long...
        _cellWidth=myWidth//short...
        
        self.selectionStyle = UITableViewCellSelectionStyle.None//选中无效果...
        self.backgroundColor=UIColor.clearColor()
        
        var bkRect=UIView(frame:CGRectMake(0,5,_cellHeight,_cellWidth-10))
        bkRect.backgroundColor=UIColor.whiteColor()
        bkRect.layer.cornerRadius=5
        self.addSubview(bkRect)
        
        
        var pic=UIImageView()
        pic=UIImageView(frame:CGRectMake(
            bkRect.frame.width*0.7-bkRect.frame.height/2,
            bkRect.frame.height/2-bkRect.frame.width*0.18,
            bkRect.frame.height,
            bkRect.frame.width*0.36)
        )
        pic.backgroundColor=UIColor.grayColor()
        //pic.image=UIImage(named:info["detailHead"]!)
        pic.image=UIImage(data: _product.head!)
        pic.contentMode=UIViewContentMode.ScaleToFill//填满预定大小...
        bkRect.addSubview(pic)
        pic.transform=CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        
        //需要旋转...
        var name=UILabel()
        //name.text=info["name"]
        name.text=_product.name
        name.font=UIFont(name: _constant._textFont, size: 24)
        name.sizeToFit()
        name.frame=CGRectMake(
            _cellHeight-name.frame.width/2-name.frame.height/2,
            name.frame.width/2-name.frame.height/2,
            name.frame.width,
            name.frame.height
        )
        bkRect.addSubview(name)
        name.transform=CGAffineTransformMakeRotation(CGFloat(M_PI/2))

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


