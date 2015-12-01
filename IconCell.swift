
import UIKit

class IconCell: UITableViewCell {

    //init(cellID:String,info:String,myHeight:CGFloat,myWidth:CGFloat){
    init(cellID:String,_icon:NSData,myHeight:CGFloat,myWidth:CGFloat){
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None//选中无效果...
        self.backgroundColor=UIColor.clearColor()
        
        var bkRect1=UIView(frame:CGRectMake(0,1,myHeight-12,myHeight-2))
        bkRect1.backgroundColor=UIColor.whiteColor()
        bkRect1.layer.cornerRadius=9
        self.addSubview(bkRect1)
        
        var bkRect2=UIImageView(frame:CGRectMake(0,1,myHeight-2,myHeight-2))
        bkRect2.image=UIImage(data: _icon)
        bkRect2.contentMode=UIViewContentMode.ScaleToFill
        bkRect2.tag=1001
        self.addSubview(bkRect2)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
