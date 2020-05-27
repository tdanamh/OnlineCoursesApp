import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddAnswerViewController: UIViewController {

    @IBOutlet weak var answerContent: UITextField!
    
    var answer: Answer?
    
    let ref = Database.database().reference()
    
    var questionIndex: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        let postRef = self.ref.child("answers")
        let key = postRef.childByAutoId().key!
        
        let content = answerContent.text ?? ""
        let user = Auth.auth().currentUser?.email ?? ""
        
        answer = Answer(answerContent: content, index: key, user: user, questionIndex: questionIndex ?? "")
    }
}
