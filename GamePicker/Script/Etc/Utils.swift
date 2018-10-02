import UIKit

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    var MainSB: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    func instanceMainVC(name: String) -> UIViewController? {
        return self.MainSB.instantiateViewController(withIdentifier: name)
    }
}
