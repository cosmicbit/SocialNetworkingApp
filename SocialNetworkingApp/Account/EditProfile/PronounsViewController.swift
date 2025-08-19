//
//  PronounsViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/08/25.
//

import UIKit

class PronounsViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    
    var userProfile: UserProfile!
    private let userProfileManager = UserProfileManager()
    private var numberOfPronouns = 0
    private let tableView: UITableView = UITableView()
    private let pronounsFileName = "pronouns"
    private let pronounsFileType = "txt"
    private let NO_PRONOUN_FOUND = "No matches found. You can add additional pronouns to your bio."
    private let PRONOUNS_LIMIT = 4
    private var pronounsTotal: [String] = []
    private var pronounsAvailable: [String] = []
    private var pronounsMatched: [String] = []{
        didSet{
            tableView.reloadData()
        }
    }
    private var selectedPronouns: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPronounsFromFile()
        view.addSubview(tableView)
        setupUserProfile()
        saveButton.setTitleColor(.lightGray, for: .disabled)
        saveButton.setTitleColor(.black, for: .normal)
        textField.borderStyle = .none
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        textField.delegate = self
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let yPosTableView = stackView.frame.maxY + 30
        tableView.frame = CGRect(
            x: 0, y: yPosTableView,
            width: view.frame.width,
            height: view.bounds.height - yPosTableView - view.safeAreaInsets.bottom)
    }
    
    func setupUserProfile(){
        saveButton.isEnabled = false
        guard let pronounsAsString = userProfile.pronouns,
              !pronounsAsString.isEmpty
        else {
            return
        }
        let pronouns = pronounsAsString.components(separatedBy: "/")
        for pronoun in pronouns {
            pronounsAvailable.removeAll { $0==pronoun }
            let optionButton = PronounsOptionButton()
            optionButton.setTitle(with: pronoun)
            optionButton.addTarget(self, action: #selector(handleOptionTapped), for: .touchUpInside)
            selectedPronouns.append(optionButton)
            stackView.insertArrangedSubview(optionButton, at: numberOfPronouns)
            numberOfPronouns += 1
        }
    }
    
    func getPronounsFromFile(){
        guard let filePath = Bundle.main.path(forResource: pronounsFileName, ofType: pronounsFileType) else{
            print("File not found in the main bundle.")
            return
        }
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            pronounsTotal = fileContents.components(separatedBy: "\n")
            pronounsAvailable = fileContents.components(separatedBy: "\n")
        } catch {
            print("Error reading the file: \(error)")
        }
    }
    
    @objc func handleOptionTapped(_ sender: UIButton){
        sender.removeFromSuperview()
        selectedPronouns.removeAll{$0 == sender}
        numberOfPronouns -= 1
        if let option = sender.titleLabel?.text{
            pronounsAvailable.append(option)
        }
        saveButton.isEnabled = true
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        userProfile.pronouns = ""
        var pronouns: [String] = []
        for pronounButton in selectedPronouns {
            if let pronoun = pronounButton.titleLabel?.text{
                pronouns.append(pronoun)
            }
        }
        userProfile.pronouns = pronouns.joined(separator: "/")
        userProfileManager.updateUserProfile(userProfile: userProfile) { result in
            self.saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            if result, let userProfile = self.userProfile{
                let userInfo: [String: Any] = ["userProfile": userProfile]
                NotificationCenter.default.post(name: NSNotification.Name("UserProfileDidUpdate"), object: nil, userInfo: userInfo)
                self.dismiss(animated: true)
            }else{
                self.showToast(message: "Something went wrong. Try again")
            }
        }
    }
}

extension PronounsViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let newText = textField.text {
            pronounsMatched = []
            tableView.allowsSelection = true
            if newText.isEmpty{ return }
            for pronoun in pronounsAvailable{
                if pronoun.starts(with: newText){
                    pronounsMatched.append(pronoun)
                }
            }
            if pronounsMatched.isEmpty{
                pronounsMatched.append(NO_PRONOUN_FOUND)
                tableView.allowsSelection = false
            }
        }
    }
}

extension PronounsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pronounsMatched.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel()
        label.text = pronounsMatched[indexPath.row]
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        cell.contentView.addSubview(label)
        cell.selectionStyle = .none
        let padding: CGFloat = 10
        label.frame = CGRect(x: padding, y: padding,
                             width: cell.contentView.bounds.width - padding,
                             height: cell.contentView.bounds.height - padding)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionButton = PronounsOptionButton()
        if selectedPronouns.count >= PRONOUNS_LIMIT{
            showToast(message: "You can add upto 4 pronouns", bottomConstraintConstant: -400)
            return
        }
        pronounsAvailable.removeAll{$0 == pronounsMatched[indexPath.row]}
        optionButton.setTitle(with: pronounsMatched[indexPath.row])
        optionButton.addTarget(self, action: #selector(handleOptionTapped), for: .touchUpInside)
        selectedPronouns.append(optionButton)
        stackView.insertArrangedSubview(optionButton, at: numberOfPronouns)
        numberOfPronouns += 1
        textField.text = ""
        saveButton.isEnabled = true
    }
}
