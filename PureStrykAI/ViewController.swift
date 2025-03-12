import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Simple Firestore write example:
        db.collection("testCollection").document("testDocument").setData([
            "exampleKey": "exampleValue",
            "timestamp": Date()
        ]) { error in
            if let error = error {
                print("Firestore Error: \(error.localizedDescription)")
            } else {
                print("Firestore write successful!")
            }
        }
    }
}

