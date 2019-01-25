import UIKit
import CoreImage
import Kingfisher

class Logout: UIViewController {
    @IBOutlet var register: UIButton!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var bg: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 뒷 배경 블러 처리
        blurEffect()
    }
    
    func direct_login() {
        let vc = self.instanceMainVC(name: "login")
        self.present(vc!, animated: true)
    }
    
    func blurEffect() {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: bg.image!)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(3, forKey: kCIInputRadiusKey)
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        bg.image = processedImage
    }
    
    // Status bar 제거
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
