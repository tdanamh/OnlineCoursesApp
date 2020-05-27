import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

    
    @IBOutlet weak var signInToggle: UISegmentedControl!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var teacherKeyField: UITextField!
    
    var isLogIn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logInToggleChanged(_ sender: UISegmentedControl) {
        isLogIn = !isLogIn
        if isLogIn {
            logInButton.setTitle("Log In", for: .normal)
        } else {
            logInButton.setTitle("Register", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Set the teacher key for verifying in CourseTableViewController unwind method
        let courseTableViewController = (segue.destination as! CourseTableViewController)
        courseTableViewController.teacherKey = teacherKeyField.text ?? ""
    }
    
    @IBAction func logInButtonTapped(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        if isLogIn {
            Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
                if let u = user {
                    //user found, go to home screen
                    self.performSegue(withIdentifier: "goToCourses", sender: self)
                } else {
                    print(error as Any)
                }
            }
        } else {
            Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                if let u = user {
                    self.performSegue(withIdentifier: "goToCourses", sender: self)
                } else {
                    print(error as Any)
                }
            }
        }
    }
    
}
