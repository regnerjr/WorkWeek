import UIKit

@IBDesignable
class HeaderView: UIView {

    var hoursInWeek: Int = 40 //default for testing
    var hoursWorked: Int = 20 //default for testing

    var ratioOfHoursWorked: CGFloat {
        return CGFloat(hoursWorked) / CGFloat(hoursInWeek)
    }

    var minWidthOrHeight: CGFloat {
        return min(self.bounds.width, self.bounds.height)
    }

    @IBOutlet weak var hoursLabel: UILabel!

    override func draw(_ rect: CGRect) {

        //draw some graph here base on hours worked compared to length of work week
        let context = UIGraphicsGetCurrentContext()

        //set darked green Pen
        UIColor(red:0.18, green:0.71, blue:0.73, alpha:1).setStroke()
        let lineWidth: CGFloat = 6.0
        context?.setLineWidth(lineWidth)

        //draw a larger circle based on the smaller of the width or height
        let outerRect = getOuterRectfromBounds(bounds, accountingForLineWitdth: lineWidth)
        context?.strokeEllipse(in: outerRect)

        //draw a smaller inner circle to be 1/4 the size of the bounding box of the large circle
        let innerRect = getOneFourthRectFromBounds(bounds)
        context?.strokeEllipse(in: innerRect)

        //draw a vertical line connnecting the 2 circles
        let x = bounds.width / 2.0
        let y: CGFloat = bounds.width > bounds.height ? 0.0 : outerRect.origin.y
        context?.move(to: CGPoint(x: x, y: y))
        context?.addLine(to: CGPoint(x: x, y: innerRect.origin.y))
        context?.strokePath()

        //prepare to draw the inner circle with a wider line an lighter pen
        context?.setLineWidth(innerRect.origin.y - outerRect.origin.y)
        UIColor(red:0.18, green:0.71, blue:0.73, alpha:0.6).setStroke()

        //center is just the center of the inner rect
        let centerX = innerRect.origin.x + innerRect.width / 2.0
        let centerY = innerRect.origin.y + innerRect.width / 2.0
        //draw a circle all the way around the circle, - Pi/2 since we start at the top
        let endAngle = ratioOfHoursWorked * CGFloat(2 * M_PI) - CGFloat(M_PI_2)
        context?.addArc(center: CGPoint(x:centerX, y: centerY),
                        radius:CGFloat(3 / 8.0) * minWidthOrHeight,
                        startAngle: CGFloat(-M_PI_2), endAngle:endAngle,
                        clockwise: true)
        context?.strokePath()
    }

    func getOuterRectfromBounds(_ bounds: CGRect,
                                accountingForLineWitdth lineWidth: CGFloat) -> CGRect {
        let x = bounds.width > bounds.height ? bounds.width / 2.0 - bounds.height / 2.0 : 0
        let y = bounds.height > bounds.width ? bounds.height / 2.0 - bounds.width / 2.0 : 0
        //must account for the linewidth when calulating bounding box
        //or the circle will be clipped at the edges
        let center = CGPoint(x: x + lineWidth / 2, y: y + lineWidth / 2 )
        let size = CGSize(width: minWidthOrHeight - lineWidth, height: minWidthOrHeight - lineWidth)
        let outerRect = CGRect(origin: center, size: size)
        return outerRect
    }

    func getOneFourthRectFromBounds(_ bounds: CGRect) -> CGRect {
        let x = bounds.width > bounds.height ? bounds.width / 2.0 - bounds.height / 2.0 : 0
        let y = bounds.height > bounds.width ? bounds.height / 2.0 - bounds.width / 2.0 : 0

        let oneFourthLength = minWidthOrHeight / 4
        let oneHalfLength = oneFourthLength * 2
        let origin = CGPoint(x: x + oneFourthLength, y: y + oneFourthLength)
        let innerRect = CGRect(origin: origin,
            size: CGSize(width: oneHalfLength, height: oneHalfLength))
        return innerRect
    }
}
