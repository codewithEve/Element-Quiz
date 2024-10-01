//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Evelyn Murillo on 9/26/24.
//

import UIKit


enum Mode {
    case flashCard
    case quiz
}

enum State {
    case question
    case answer
    case score
}



class ViewController: UIViewController, UITextFieldDelegate {
    
    // CONSTANTS AND VARIABLES //
    

    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList: [String] = []
    
    var currentElementIndex = 0 //index changes as the user interacts with the app
    
    var mode: Mode = .flashCard {
        didSet { // property observer that will run each time the value of mode is updated
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }

            updateUI()
        }
    }
    var state: State = .question // keep track of the state of the app.
    
    var answerIsCorrect = false // Quiz-specific state
    
    var correctAnswerCount = 0  // Quiz-specific state
    
    
    // OUTLETS //
    
    @IBOutlet weak var imageView: UIImageView! //reference outlet for the image
    @IBOutlet weak var answerLabel: UILabel! //reference outlet for the answer label
    @IBOutlet weak var modeSelector: UISegmentedControl! //outlet for the segmented control
    @IBOutlet weak var textField: UITextField! //outlet for the text field
    @IBOutlet weak var showAnswerButton: UIButton! // outlet for the Show answer button.
    @IBOutlet weak var nextButton: UIButton! //outlet for the Next Element button
    
    // ACTIONS //
    
    @IBAction func showAnswer(_ sender: Any) { //connected to the Show Answer button
        state = .answer
        
        updateUI()
    }
    
    @IBAction func next(_ sender: Any) { //connected to the Next Element button
        currentElementIndex += 1
        
        if currentElementIndex >= elementList.count { //ensures that the index stays in range
            currentElementIndex = 0
            if mode == .quiz { // detects the end of the quiz.
                state = .score
                updateUI()
                return
            }
        }
        
        state = .question
        
        updateUI() //updates and moves through the array.
    }
    
    
    @IBAction func switchModes(_ sender: Any) {//changes the app's mode when the user interacts with the segmented                                              control
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    
    // METHODS //

    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
    }

    func updateFlashCardUI(elementName: String) { // Updates the app's UI in flash card mode.
        
        // Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()
        
        // Answer label
        if state == .answer {
                answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        
        // Segmented control
        modeSelector.selectedSegmentIndex = 0
        
        // Buttons
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        
    }
    
    func updateQuizUI(elementName: String) { // Updates the app's UI in quiz mode.
        
        // Text field and keyboard
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        // Answer Label
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score:
            answerLabel.text = ""
            print("Your score is \(correctAnswerCount) out of \(elementList.count).")
        }
        
        // Score display
        if state == .score {
            displayScoreAlert()
        }
        
        // Segmented control
        modeSelector.selectedSegmentIndex = 1
        
        // Buttons
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        
    }
    

    func updateUI() { // Updates the app's UI based on its mode and state.
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    
    // Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Get the text from the text field
        let textFieldContents = textField.text!

        // Determine whether the user answered correctly and update appropriate quiz
        // state
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }

        // The app should now display the answer to the user
        state = .answer

        updateUI()

        return true
    }
    
    // Shows an iOS alert with the user's quiz score.
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)

        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)

        present(alert, animated: true, completion: nil)
    }

    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    
    // Sets up a new flash card session.
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
        
    }

    // Sets up a new quiz.
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        elementList = fixedElementList.shuffled() // randomize the array
    }
    
}


