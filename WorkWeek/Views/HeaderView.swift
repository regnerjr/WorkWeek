import UIKit

@IBDesignable
class HeaderView: UIView {

    @IBInspectable
    var hoursInWeek: Int = 40
    @IBInspectable
    var hoursWorked: Int = 20

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        //draw some stuff here based on

        //draw some graph here base on hours worked compared to length of work week
        let context = UIGraphicsGetCurrentContext()

        let viewRect = self.bounds
        println("ViewRect: \(viewRect)")
        let viewOutline = CGPathCreateWithRect(viewRect, nil)
        CGContextAddPath(context, viewOutline)

        UIColor.redColor().setStroke()
        CGContextStrokePath(context)

        let percentage = CGRect(origin: viewRect.origin, size: CGSize(width: viewRect.width * (CGFloat(hoursWorked) / CGFloat(hoursInWeek)), height: viewRect.height))
        let percentRect = CGPathCreateWithRect(percentage, nil)
        println("PercentRect : \(percentage)")
        CGContextAddPath(context, percentRect)

        UIColor.blueColor().setFill()
        CGContextFillPath(context)
    }

}
