//
//  ViewController.swift
//  WordScramble
//
//  Created by Kostya Lee on 14/12/21.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var randomChar = ""
    
    var alphabet = [String]()
    
    fileprivate func insertWords() {
        if let wordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let words = try? String(contentsOf: wordsURL) {
                allWords = words.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["words"]
        }
    }
    
    fileprivate func insertAlphabet() {
        for char in "abcdefghijklmnopqrstuvwxyz" {
            alphabet.append("\(char)")
        }
    }

    @objc func startGame() {
        insertAlphabet()
        let randomLetter = alphabet.randomElement()
        guard let randomLetter = randomLetter else {
            return
        }
        self.randomChar = randomLetter
        let instruction = "Type a word starting with '\(randomChar)'"
        let ac = UIAlertController(title: instruction, message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Go", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.insertWord(word: answer)
        })

        ac.addTextField()
    
        present(ac, animated: true) {
            ac.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        }
    }
    
    func insertWord(word: String) {
        let Lword = word.lowercased()
        if isCorrect(word: Lword) && isNotUsed(Lword) && isValid(word: Lword){
            usedWords.insert(word, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    func isCorrect(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isValid(word: String) -> Bool {
        let Lchar = "\(word.lowercased().first!)"
        return Lchar == randomChar
    }
    
    func isNotUsed(_ word: String) -> Bool {
        let Lword = word.lowercased()
        for w in usedWords {
            if w.lowercased() == Lword {
                return false
            }
        }
        return true
    }

    
    @objc func dismissOnTapOutside() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        insertWords()
        title = "game"
        let barBtnItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))
        
        navigationItem.rightBarButtonItem = barBtnItem
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        usedWords.remove(at: indexPath.row)
        let path = IndexPath(row: indexPath.row, section: 0)
        tableView.deleteRows(at: [path], with: .automatic)
    }
}
