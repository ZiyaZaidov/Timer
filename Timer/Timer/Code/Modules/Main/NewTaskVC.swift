//
//  NewTaskVC.swift
//  Timer
//
//  Created by Ziya on 8/4/23.
//

import UIKit

class NewTaskVC : UIViewController {
    
    @IBOutlet weak var clouseButton: UIButton!
    @IBOutlet weak var taskNameTf: UITextField!
    @IBOutlet weak var taskDescriptionTF: UITextField!
    @IBOutlet weak var minutesTF: UITextField!
    @IBOutlet weak var secondsTf: UITextField!
    @IBOutlet weak var hourTF: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var newTaaskTopConstant: NSLayoutConstraint!
    
    var taskViewModel: TaskViewModel!
    var keyboardStatus = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.taskViewModel = TaskViewModel()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: TaskTypeCollectionViewCell.description(), bundle: .main), forCellWithReuseIdentifier: TaskTypeCollectionViewCell.description())

        self.disableButton()
        
        [self.hourTF,self.minutesTF,self.secondsTf].forEach {
            $0?.attributedPlaceholder = NSAttributedString(string: "00")
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(self.textFieldinput(_:)), for: .editingChanged)
        }
        
        self.taskNameTf.attributedPlaceholder = NSAttributedString(string: "Task Name")
        self.taskNameTf.addTarget(self, action: #selector(self.textFieldinput(_:)), for: .editingChanged)
        
        self.taskDescriptionTF.attributedPlaceholder =  NSAttributedString(string: "Task Description")
        self.taskDescriptionTF.addTarget(self, action: #selector(self.textFieldinput(_:)), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.viewTapped(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.taskViewModel.getHours().bind { hour in
            self.hourTF.text = hour.appendZeroes()
        }
        
        self.taskViewModel.getMinutes().bind { minute in
            self.minutesTF.text = minute.appendZeroes()
        }
        
        self.taskViewModel.getSeconds().bind { second in
            self.secondsTf.text = second.appendZeroes()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    
    @objc func kbWillShow(_ notification: Notification) {
        if !Constants.hastopNotch,!keyboardStatus {
            self.keyboardStatus.toggle()
            self.newTaaskTopConstant.constant -= self.view.frame.height * 0.1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func kbWillHide(_ notification: Notification) {
        self.keyboardStatus = false
        self.newTaaskTopConstant.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @objc func textFieldinput(_ textfield: UITextField) {
        
        guard let text = textfield.text else {return}
        
        if textfield == taskNameTf {
            self.taskViewModel.setTaskName(to: text)
            
        } else if  textfield == taskDescriptionTF {
            self.taskViewModel.setTaskDescription(to: text)
            
        } else if textfield == hourTF {
            guard let hour = Int(text) else {return}
            self.taskViewModel.setHours(to: hour)
            
        } else if textfield == minutesTF {
            guard let minute = Int(text) else {return}
            self.taskViewModel.setMinutes(to: minute)
        } else {
            guard let second = Int(text) else {return}
                self.taskViewModel.setSeconds(to: second)
        }
       checkButton()
        
    }
    
    
    override class func description() -> String {
         return "NewTaskVC"
    }
    
    func enableButton() {
        if self.startButton.isUserInteractionEnabled == false {
            UIView.animate(withDuration: 0.30, delay: 0) {
                self.startButton.layer.opacity = 1
            } completion: { _ in
                self.startButton.isUserInteractionEnabled.toggle()
            }
        }
    }
    
    func disableButton() {
        if self.startButton.isUserInteractionEnabled {
            UIView.animate(withDuration: 0.30, delay: 0) {
                self.startButton.layer.opacity = 0.3
            } completion: { _ in
                self.startButton.isUserInteractionEnabled.toggle()
            }
        }
    }
    
    func checkButton() {
        if taskViewModel.isTaskNotEmpty() {
            enableButton()
        } else  {
            disableButton()
        }
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    
    
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.taskNameTf.text = ""
        self.taskDescriptionTF.text = ""
        self.minutesTF.text = ""
        self.hourTF.text = ""
        self.secondsTf.text = ""
    }
    
    @IBAction func startBtnTapped(_ sender: UIButton) {
        guard let timerVC = self.storyboard?.instantiateViewController(withIdentifier: TimerVC.description()) as? TimerVC else { return }

        taskViewModel.computeSeconds()
        timerVC.taskViewModel = taskViewModel
        timerVC.modalPresentationStyle = .fullScreen
        self.present(timerVC, animated: true)
    }
    
}

extension NewTaskVC : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskViewModel.getTaskTypes().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: TaskTypeCollectionViewCell.description(), for: indexPath) as! TaskTypeCollectionViewCell
        cell.setupCell(taskType:  self.taskViewModel.getTaskTypes()[indexPath.item], isSelected: taskViewModel.getSelectedIndex() == indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columms: CGFloat = 3.75
        let width: CGFloat = collectionView.frame.width
        
        let flowLayout =  collectionViewLayout as! UICollectionViewFlowLayout
        
        let adjustedWidth = width - (flowLayout.minimumLineSpacing * (columms - 1))
        return CGSize(width: adjustedWidth / columms , height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.taskViewModel.setSelectedIndex(to: indexPath.item)
        self.collectionView.reloadSections(IndexSet(0..<1))
        checkButton()
    }
}

extension NewTaskVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        
        guard let text = textField.text else { return false }
        if text.count == 2 && text.starts(with: "0") {
            textField.text?.removeFirst()
            textField.text? += string
            self.textFieldinput(textField)
        }
        return newString.length <= maxLength
    }
}



