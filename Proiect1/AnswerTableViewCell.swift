import UIKit

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var answerContent: UILabel!
    
    @IBOutlet weak var user: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
