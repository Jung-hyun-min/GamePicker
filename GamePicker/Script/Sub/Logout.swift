import UIKit
import CoreImage

class Logout: UIViewController {
    @IBOutlet var register: UIButton!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var bg: UIImageView!

    var check : CChar = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        blurEffect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 회원가입 직후 바로 로그인 화면 전환
        let chk = UIApplication.shared.delegate as? AppDelegate
        if chk!.check == 1 {
            chk!.check = 0
            self.performSegue(withIdentifier: "Login", sender: self)
        }
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
