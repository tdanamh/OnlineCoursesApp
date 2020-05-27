import UIKit
import FirebaseDatabase

class AnswersTableViewController: UITableViewController {

    var answers = [Answer]()
    
    let ref = Database.database().reference()
    
    var question: Question?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadAnswers()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "AnswerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AnswerTableViewCell else {
            fatalError("The dequeued cell is not an instance of AnswerTableViewCell.")
        }
        
        // Fetches the appropriate course for the data source layout.
        let answer = answers[indexPath.row]
        
        // Configure the cell...
        cell.answerContent.text = answer.answerContent
        cell.user.text = answer.user

        return cell
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let addAnswerViewController = segue.destination as? AddAnswerViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        addAnswerViewController.questionIndex = self.question?.index
    }
    
    
    //MARK: Actions
   @IBAction func unwindToAnswersList(sender: UIStoryboardSegue) {
       
        if let sourceViewController = sender.source as? AddAnswerViewController, let answer = sourceViewController.answer {
           
            let answerContent = answer.answerContent
            let answerIndex = answer.index
            let answerUser = answer.user
            let answerQuestionIndex = answer.questionIndex
           
           // Save a new answer in Firebase
           let postRef = self.ref.child("answers")
           
           postRef.child(answerIndex).setValue(["content": answerContent, "questionIndex": answerQuestionIndex, "index": answerIndex, "user": answerUser])
           
       }
   }

    private func loadAnswers() {
        
        let postRef = self.ref.child("answers")
        
        postRef.observe(.childAdded, with: { (snapshot) -> Void in
            let answerData = snapshot.value as? [String: AnyObject] ?? [:]
            
            let content = answerData["content"] as! String
            let questionIndex = answerData["questionIndex"] as! String
            let index = answerData["index"] as! String
            let user = answerData["user"] as! String
            
            if questionIndex == self.question?.index {
                guard let answer = Answer(answerContent: content, index: index, user: user, questionIndex: questionIndex) else {
                    fatalError("Unable to instantiate answer")
                }
                
                self.answers.append(answer)
                
                self.tableView.insertRows(at: [IndexPath(row: self.answers.count-1, section: 0)], with: UITableView.RowAnimation.automatic)
            }
            
        })
        
    }

}
