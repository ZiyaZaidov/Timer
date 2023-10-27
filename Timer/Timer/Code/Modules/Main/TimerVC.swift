//
//  TimerVC.swift
//  Timer
//
//  Created by Ziya on 8/8/23.
//

import UIKit

class TimerVC: UIViewController {

    @IBOutlet weak var clouseButton: UIButton!
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timerContainerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var resetView: UIView!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    var taskViewModel: TaskViewModel!
    
    var totalSeconds = 0 {
        didSet {
            timerSeconds = totalSeconds
        }
    }
    
    lazy var timerEndAnimation: CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.toValue = 0
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = true
    return strokeEnd
    }()
    
    lazy var timerResetAnimation: CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.toValue = 1
        strokeEnd.duration = 1
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
    return strokeEnd
    }()
    
    var timerSeconds = 0
    
    let timerAtribute = [NSAttributedString.Key.font:UIFont(name: "AppleSDGothicNeo-Bold", size: 46)]
    let semiBoldAtributs = [NSAttributedString.Key.font:UIFont(name: "AppleSDGothicNeo-Regular", size: 32)]
    
    let timerTrackLayer = CAShapeLayer()
    let timerCircleFillLayer = CAShapeLayer()
    
    var timerState: CountdownState = .suspend
    var countdown = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let task = self.taskViewModel.getTask()
        
        self.totalSeconds = task.seconds
        self.taskTitleLabel.text = task.taskName
        self.descriptionLabel.text = task.taskDescription
        
        self.imageContainerView.layer.cornerRadius = self.imageContainerView.frame.width / 2
        self.imageView.layer.cornerRadius = self.imageView.frame.width / 2
        self.imageView.image = UIImage(systemName: task.taskType.symbolName)
        
        [pauseView,resetView].forEach {
            guard let view = $0 else {return}
            view.layer.opacity = 0
            view.isUserInteractionEnabled = false
        }
        
        [playView,pauseView,resetView].forEach { $0?.layer.cornerRadius = 10 }
        
        timerView.transform = timerView.transform.rotated(by: 270.degreeToRadians())
//        timerLabel.transform = timerLabel.transform.rotated(by: 0.degreeToRadians())
        timerContainerView.transform = timerContainerView.transform.rotated(by: 90.degreeToRadians())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.setupLayers()
        }
    }
    
    func setupLayers() {
        let radius = self.timerView.frame.width < self.timerView.frame.height ? self.timerView.frame.width / 2 : self.timerView.frame.height / 2
        
        let arcPath = UIBezierPath.init(arcCenter: CGPoint(x: timerView.frame.height / 2, y: timerView.frame.width / 2), radius: radius, startAngle: 0 , endAngle: 360.degreeToRadians(), clockwise: true)
        
        self.timerTrackLayer.path = arcPath.cgPath
        self.timerTrackLayer.strokeColor = UIColor.label.cgColor
        self.timerTrackLayer.fillColor = UIColor.clear.cgColor
        self.timerTrackLayer.lineWidth = 20
        self.timerTrackLayer.lineCap = .round
        
        self.timerCircleFillLayer.path = arcPath.cgPath
        self.timerCircleFillLayer.strokeColor = UIColor.orange.cgColor
        self.timerCircleFillLayer.fillColor = UIColor.clear.cgColor
        self.timerCircleFillLayer.lineWidth = 21
        self.timerCircleFillLayer.lineCap = .round
        self.timerCircleFillLayer.strokeEnd = 1
        
        self.timerView.layer.addSublayer(timerTrackLayer)
        self.timerView.layer.addSublayer(timerCircleFillLayer)
        
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveEaseInOut) {
            self.timerContainerView.layer.cornerRadius = self.timerContainerView.frame.width / 2
            
        }
    }
    
    override class func description() -> String {
        return "TimerVC"
    }

  
    @IBAction func clouseBtnTapped(_ sender: UIButton) {
        self.timerTrackLayer.removeFromSuperlayer()
        self.timerCircleFillLayer.removeFromSuperlayer()
        countdown.invalidate()
        self.dismiss(animated: true)
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        guard  timerState == .suspend else {return}
        
        self.timerEndAnimation.duration = Double(self.timerSeconds)
        animatePauseButton(symbolName: "pause.fill")
        animatePlayPauseResetViews(timerPlaying: false)
        startTimer()
        }
    
    @IBAction func pauseButtonPressed(_ sender: UIButton) {
        switch timerState {
        case .pause:
            self.timerState = .running
            self.timerEndAnimation.duration = Double(self.timerSeconds) + 1
            self.startTimer()
            animatePauseButton(symbolName: "pause.fill")
        case .running:
            self.timerState = .pause
            self.timerCircleFillLayer.strokeEnd = CGFloat(timerSeconds) / CGFloat (totalSeconds)
            self.resetTimer()
            animatePauseButton(symbolName: "play.fill")
        default : break
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        self.timerState = .suspend
        self.timerSeconds = self.totalSeconds
        resetTimer()
        self.timerCircleFillLayer.add(timerResetAnimation, forKey: "reset")
        animatePauseButton(symbolName: "play.fill")
        animatePlayPauseResetViews(timerPlaying: true)
    }
    
    func animatePauseButton(symbolName: String) {
        UIView.transition(with: pauseButton, duration: 0.3,options: .transitionCrossDissolve) {
            self.pauseButton.setImage(UIImage(systemName: symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)),for: .normal)

        }
    }
    
    
    func startTimer() {
        updatelabel()
        countdown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            self.timerSeconds -= 1
            self.updatelabel()
            if self.timerSeconds == 0 {
                timer.invalidate()
                self.timerState = .suspend
                self.animatePlayPauseResetViews(timerPlaying: true)
                self.timerSeconds = self.totalSeconds
                self.resetTimer()
            }
        })
        self.timerState = .running
        self.timerCircleFillLayer.add(self.timerEndAnimation, forKey: "timerEnd")
    }
    
    func resetTimer() {
        self.countdown.invalidate()
        self.timerCircleFillLayer.removeAllAnimations()
        updatelabel()
    }
    
    func updatelabel() {
        let seconds = self.timerSeconds % 60
        let minutes = self.timerSeconds / 60 % 60
        let hours = self.timerSeconds / 3600
        
        if hours > 0 {
            let hourseCount = String(hours).count
            let minutesCount = String(minutes).count
            let secondsCount = String(seconds.appendZeroes()).count
            
            let timeString = "\(hours)h \(minutes)m  \(seconds.appendZeroes())s"
            let atributedString = NSMutableAttributedString(string: timeString,attributes: semiBoldAtributs as [NSAttributedString.Key : Any])
            
            atributedString.addAttributes(timerAtribute as [NSAttributedString.Key : Any], range: NSRange(location: 0, length: hourseCount))
            atributedString.addAttributes(timerAtribute as [NSAttributedString.Key : Any], range: NSRange(location: hours + 2, length: minutesCount))
            atributedString.addAttributes(timerAtribute as [NSAttributedString.Key : Any], range: NSRange(location: hours + 2 + minutesCount + 3 , length: secondsCount))
            self.timerLabel.attributedText = atributedString
            
        } else {
            let minutesCount = String(minutes).count
            let secondsCount = String(seconds.appendZeroes()).count
            
            let timeString = "\(minutes)m  \(seconds.appendZeroes())s"
            let atributedString = NSMutableAttributedString(string: timeString,attributes: semiBoldAtributs as [NSAttributedString.Key : Any])
            
            atributedString.addAttributes(timerAtribute as [NSAttributedString.Key : Any], range: NSRange(location: 0, length: minutesCount))
            atributedString.addAttributes(timerAtribute as [NSAttributedString.Key : Any], range: NSRange(location: minutesCount + 3 , length: secondsCount))
            self.timerLabel.attributedText = atributedString
        }
    }
    
    func animatePlayPauseResetViews(timerPlaying: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0,options: .curveEaseInOut) {
            self.playView.layer.opacity = timerPlaying ? 1 : 0
            self.pauseView.layer.opacity = timerPlaying ? 0 : 1
            self.resetView.layer.opacity = timerPlaying ? 0 : 1
        } completion: { [weak self] _  in
            [self?.pauseView,self?.resetView].forEach {
                guard let view = $0 else {return}
                view.isUserInteractionEnabled = timerPlaying ? false : true
            }
        }
    }

}
