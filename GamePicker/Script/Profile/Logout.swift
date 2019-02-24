import UIKit
import CoreImage
import Kingfisher

class Logout: UIViewController {
    @IBOutlet var register: UIButton!
    @IBOutlet var facebook: UIButton!
    @IBOutlet var bg: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurEffect()
        delete_userdefaults()
    }
    
    
    // 상태바 hide
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func login(_ sender: Any) {
        self.performSegue(withIdentifier: "login", sender: self)
    }
    
    
    // 뒷배경 블러 처리
    func blurEffect() {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: bg.image!)
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        bg.image = processedImage
    }
    
    func delete_userdefaults() {
        let ud = UserDefaults.standard
        
        ud.removeObject(forKey: data.user.birthday)
        ud.removeObject(forKey: data.user.email)
        ud.removeObject(forKey: data.user.gender)
        ud.removeObject(forKey: data.user.id)
        ud.removeObject(forKey: data.user.introduce)
        ud.removeObject(forKey: data.user.name)
        ud.removeObject(forKey: data.user.password)
        ud.removeObject(forKey: data.user.points)
    }
    
}
