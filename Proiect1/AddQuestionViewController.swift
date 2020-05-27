import UIKit
import FirebaseAuth
import Firebase

class AddQuestionViewController: UIViewController {

    @IBOutlet weak var questionContent: UITextField!
    
    var courseIndex: String?
    
    var question: Question?
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        let postRef = self.ref.child("questions")
        let key = postRef.childByAutoId().key! 
        
        let content = questionContent.text ?? ""
        let user = Auth.auth().currentUser?.email ?? ""
        
        question = Question(questionContent: content, index: key, user: user, courseIndex: courseIndex ?? "")
    }

}
