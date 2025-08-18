//
//  PronounsViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/08/25.
//

import UIKit

class PronounsViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    
    private var numberOfPronouns = 0
    private let tableView: UITableView = UITableView()
    private let pronounsFileName = "pronouns"
    private let pronounsFileType = "txt"
    private let NO_PRONOUN_FOUND = "No matches found. You can add additional pronouns to your bio."
    private var pronounsAvailable: [String] = []
    private var pronounsMatched: [String] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPronounsFromFile()
        view.addSubview(tableView)
        textField.borderStyle = .none
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 10
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        textField.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let yPosTableView = stackView.frame.maxY + 30
        tableView.frame = CGRect(
            x: 0, y: yPosTableView,
            width: view.frame.width,
            height: view.bounds.height - yPosTableView - view.safeAreaInsets.bottom)
    }
    
    func getPronounsFromFile(){
        guard let filePath = Bundle.main.path(forResource: pronounsFileName, ofType: pronounsFileType) else{
            print("File not found in the main bundle.")
            return
        }
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            pronounsAvailable = fileContents.components(separatedBy: "\n")
        } catch {
            print("Error reading the file: \(error)")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
}

extension PronounsViewController: UITextFieldDelegate{
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let newText = textField.text {
            print("Text field content changed to: \(newText)")
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
        cell.contentView.addSubview(label)
        label.frame = cell.contentView.bounds
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionButton1 = PronounsOptionButton()
        optionButton1.setTitle(with: pronounsMatched[indexPath.row])
        stackView.insertArrangedSubview(optionButton1, at: numberOfPronouns)
        numberOfPronouns += 1
        textField.text = ""
    }
}
