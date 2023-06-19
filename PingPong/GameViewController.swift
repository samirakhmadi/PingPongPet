//
//  GameViewController.swift
//  PingPong
//
//  Created by Samir Akhmadi on 18.09.2022.
//

import UIKit
import SpriteKit
import GameplayKit
import Combine

class GameViewController: UIViewController {
    
    private var store = [AnyCancellable]()
    @Published private var highSpeed = false
    @Published private var strongEnemy = false
    
    private var hardModeButtonSubscriver: AnyCancellable?
    private var mediumModeButtonSubscriver: AnyCancellable?
    private var easyModeButtonSubscriver: AnyCancellable?
    
    private var hardMode: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($highSpeed, $strongEnemy)
            .map { highSpeed, strongEnemy in
                return highSpeed && strongEnemy
            } .eraseToAnyPublisher()
    }
    
    private var mediumMode: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($highSpeed, $strongEnemy)
            .map { highSpeed, strongEnemy in
                if highSpeed && strongEnemy { return false }
                return highSpeed || strongEnemy
            } .eraseToAnyPublisher()
    }
    private var easyMode: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($highSpeed, $strongEnemy)
            .map { highSpeed, strongEnemy in
                return !highSpeed && !strongEnemy
            } .eraseToAnyPublisher()
    }
    
    private var speed: Int = -1
    private var enemyLevel: Int = -1
    
    private lazy var background: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "menu")
        imageView.image = image
        imageView.contentMode = .redraw
        return imageView
    }()
    
    private lazy var easyModeButton: UIButton = {
       let button = ButtonModel()
        button.setTitle("Простая игра", for: .normal)
        button.backgroundColor = UIColor(named: "orange")
        return button
    }()
    
    private lazy var mediumModeButton: UIButton = {
       let button = ButtonModel()
        button.setTitle("Средняя игра", for: .normal)
        button.alpha = 0.4
        return button
    }()
    
    private lazy var hardModeButton: UIButton = {
       let button = ButtonModel()
        button.setTitle("Сложная игра", for: .normal)
        button.alpha = 0.4
        return button
    }()
    
    private lazy var highSpeedButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = UIColor(named: "lightBlue")
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isSelected = false
        return button
    }()
    
    private lazy var strongEnemyButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = UIColor(named: "lightBlue")
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.isSelected = false
        return button
    }()
    
    private lazy var backButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Назад", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.alpha = 0
        return button
    }()
    
    private lazy var againButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Заново", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.alpha = 0
        return button
    }()
    
    private lazy var highSpeedLabel: UILabel = {
        let label = LabelModel()
        label.text = "Супер-скорость"
        return label
    }()
    
    private lazy var topEnemyLabel: UILabel = {
        let label = LabelModel()
        label.text = "Топ-соперник"
        return label
    }()
    
    private lazy var optionsLabel: UILabel = {
        let label = LabelModel()
        label.text = "Опции:"
        return label
    }()
    
    private lazy var levelsLabel: UILabel = {
        let label = LabelModel()
        label.text = "Уровни:"
        return label
    }()
    
    private lazy var countStartTimeLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Avenir", size: 150)
        label.backgroundColor = UIColor(named: "orange")
        label.textAlignment = .center
        label.textColor = .white
        label.text = "3"
        label.clipsToBounds = true
        label.layer.cornerRadius = 150
        label.alpha = 0
        return label
    }()
    
    private lazy var circle: CircleModel! = {
        let circle = CircleModel(frame: CGRect(x: (view.frame.size.width / 2) - 150, y: (view.frame.size.height / 2) - 150, width: 300, height: 300))
        circle.trackColor = .gray
        circle.progressColor = .systemMint
        circle.applyShadow(cornerRadius: 150)
        circle.alpha = 0
        return circle
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(background)
        view.addSubview(easyModeButton)
        view.addSubview(backButton)
        view.addSubview(againButton)
        view.addSubview(countStartTimeLabel)
        view.addSubview(circle)
        view.addSubview(hardModeButton)
        view.addSubview(highSpeedLabel)
        view.addSubview(highSpeedButton)
        view.addSubview(strongEnemyButton)
        view.addSubview(topEnemyLabel)
        view.addSubview(mediumModeButton)
        view.addSubview(optionsLabel)
        view.addSubview(levelsLabel)
        setupConstraints()
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        againButton.addTarget(self, action: #selector(didTapAgainButton), for: .touchUpInside)
        hardModeButton.addTarget(self, action: #selector(didTapHardModeButton), for: .touchUpInside)
        mediumModeButton.addTarget(self, action: #selector(didTapMediumModeButton), for: .touchUpInside)
        easyModeButton.addTarget(self, action: #selector(didTapEasyModeButton), for: .touchUpInside)
        highSpeedButton.addAction(UIAction(handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.speed += 1
                    self.didTapHighSpeedButton()
                }), for: .touchUpInside)
        strongEnemyButton.addAction(UIAction(handler: { [weak self] _ in
                    guard let self = self else { return }
                    self.enemyLevel += 1
                    self.didTapStrongEnemyButton()
                }), for: .touchUpInside)
        
        hardModeButtonSubscriver = hardMode
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: hardModeButton)
        
        mediumModeButtonSubscriver = mediumMode
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: mediumModeButton)
        
        easyModeButtonSubscriver = easyMode
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: easyModeButton)
        
        if let view = self.view as! SKView? {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                scene.size = view.bounds.size
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @objc private func didTapBackButton() {
        let buttons = [easyModeButton, mediumModeButton, hardModeButton, easyModeButton, highSpeedButton, strongEnemyButton]
        let menuElements = [background, levelsLabel, optionsLabel, topEnemyLabel, levelsLabel, highSpeedLabel]
        let gameElements = [backButton, againButton, circle, countStartTimeLabel]
        for button in buttons {
            if button.isEnabled {
                button.alpha = 1
            } else {
                button.alpha = 0.4
            }
        }
        for element in menuElements {
            element.alpha = 1
        }
        for element in gameElements {
            element?.alpha = 0
        }
        UserSettings.shared.reset = true
    }
    
    @objc private func didTapAgainButton() {
        UserSettings.shared.reset = true
        startCount()
    }
    
    @objc private func didTapHighSpeedButton() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            switch self.speed {
            case 0:
                self.highSpeedButton.isSelected = true
                self.highSpeed = true
            case 1:
                self.highSpeedButton.isSelected = false
                self.highSpeed = false
                self.speed -= 2
            default:
                self.highSpeedButton.isSelected = false
                self.highSpeed = false
                self.speed = -1
            }
        }
        updateView()
    }
    
    @objc private func didTapStrongEnemyButton() {
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            switch self.enemyLevel {
            case 0:
                self.strongEnemyButton.isSelected = true
                self.strongEnemy = true
            case 1:
                self.strongEnemyButton.isSelected = false
                self.strongEnemy = false
                self.enemyLevel -= 2
            default:
                self.strongEnemyButton.isSelected = false
                self.strongEnemy = false
                self.enemyLevel = -1
            }
        }
        updateView()
    }
    
    @objc private func didTapHardModeButton() {
        currentSpeedLevel = .high
        currentEnemyLevel = .topPlayer
        proceedToGameView()
        startCount()
    }
    
    @objc private func didTapMediumModeButton() {
        if highSpeed == true {
            currentEnemyLevel = .slowRider
           currentSpeedLevel = .high
        } else if strongEnemy == true {
            currentEnemyLevel = .topPlayer
            currentSpeedLevel = .low
        }
        proceedToGameView()
        startCount()
    }
    
    @objc private func didTapEasyModeButton() {
        currentSpeedLevel = .low
        currentEnemyLevel = .slowRider
        proceedToGameView()
        startCount()
    }
    
    private func proceedToGameView() {
        let disableElements = [background, easyModeButton, mediumModeButton, hardModeButton, highSpeedButton, strongEnemyButton, levelsLabel, optionsLabel, topEnemyLabel, levelsLabel, highSpeedLabel]
        self.backButton.alpha = 1
        self.againButton.alpha = 1
        for element in disableElements {
            element.alpha = 0
        }
    }
    
    private func updateView() {
        if strongEnemyButton.isSelected && highSpeedButton.isSelected {
            hardModeButton.backgroundColor = UIColor(named: "orange")
            hardModeButton.alpha = 1
            mediumModeButton.backgroundColor = .systemGray3
            mediumModeButton.alpha = 0.4
            easyModeButton.backgroundColor = .systemGray3
            easyModeButton.alpha = 0.4
        } else if strongEnemyButton.isSelected {
            mediumModeButton.backgroundColor = UIColor(named: "orange")
            mediumModeButton.alpha = 1
            hardModeButton.backgroundColor = .systemGray3
            hardModeButton.alpha = 0.4
            easyModeButton.backgroundColor = .systemGray3
            easyModeButton.alpha = 0.4
        } else if highSpeedButton.isSelected {
            mediumModeButton.backgroundColor = UIColor(named: "orange")
            mediumModeButton.alpha = 1
            hardModeButton.backgroundColor = .systemGray3
            hardModeButton.alpha = 0.4
            easyModeButton.backgroundColor = .systemGray3
            easyModeButton.alpha = 0.4
        } else {
            mediumModeButton.backgroundColor = .systemGray3
            mediumModeButton.alpha = 0.4
            hardModeButton.backgroundColor = .systemGray3
            hardModeButton.alpha = 0.4
            easyModeButton.backgroundColor = UIColor(named: "orange")
            easyModeButton.alpha = 1
        }
    }
    
    private func startCount() {
        self.countStartTimeLabel.alpha = 1
        self.circle.alpha = 1
        self.circle.setProgressWithAnimation(duration: 5.1, value: 2)
        let colors: [UIColor] = [.systemIndigo, .systemPink, .systemGreen, .cyan, .systemBlue, .systemRed, .systemBrown, .systemTeal]
        let stopPoint = -1
        Timer.publish(every: 0.7, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .scan(3) { i, _ in i - 1 }
            .prefix(while: { stopPoint <= $0 })
            .sink { [weak self] value in
                self?.countStartTimeLabel.backgroundColor = colors.randomElement()
                let stringValue = String(value)
                if value >= 0 {
                    self?.countStartTimeLabel.text = stringValue
                } else {
                    self?.countStartTimeLabel.alpha = 0
                    self?.circle.alpha = 0
                    self?.countStartTimeLabel.backgroundColor = .orange
                    self?.countStartTimeLabel.text = "3"
                    self?.againButton.setTitle("Заново", for: .normal)
                    UserSettings.shared.reset = true
                }
            }.store(in: &store)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            optionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            optionsLabel.bottomAnchor.constraint(equalTo: strongEnemyButton.topAnchor, constant: -10),
            optionsLabel.widthAnchor.constraint(equalToConstant: 70),
            optionsLabel.heightAnchor.constraint(equalToConstant: 40),
            
            strongEnemyButton.trailingAnchor.constraint(equalTo: highSpeedButton.trailingAnchor),
            strongEnemyButton.bottomAnchor.constraint(equalTo: highSpeedButton.topAnchor, constant: -20),
            strongEnemyButton.widthAnchor.constraint(equalToConstant: 40),
            strongEnemyButton.heightAnchor.constraint(equalToConstant: 40),
            
            topEnemyLabel.trailingAnchor.constraint(equalTo: highSpeedLabel.trailingAnchor),
            topEnemyLabel.centerYAnchor.constraint(equalTo: strongEnemyButton.centerYAnchor),
            topEnemyLabel.widthAnchor.constraint(equalToConstant: 140),
            topEnemyLabel.heightAnchor.constraint(equalToConstant: 40),
            
            highSpeedButton.trailingAnchor.constraint(equalTo: easyModeButton.trailingAnchor, constant: 10),
            highSpeedButton.bottomAnchor.constraint(equalTo: hardModeButton.topAnchor, constant: -90),
            highSpeedButton.widthAnchor.constraint(equalToConstant: 40),
            highSpeedButton.heightAnchor.constraint(equalToConstant: 40),
            
            highSpeedLabel.leadingAnchor.constraint(equalTo: easyModeButton.leadingAnchor, constant: -10),
            highSpeedLabel.centerYAnchor.constraint(equalTo: highSpeedButton.centerYAnchor),
            highSpeedLabel.widthAnchor.constraint(equalToConstant: 140),
            highSpeedLabel.heightAnchor.constraint(equalToConstant: 40),
            
            levelsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelsLabel.bottomAnchor.constraint(equalTo: hardModeButton.topAnchor, constant: -10),
            levelsLabel.widthAnchor.constraint(equalToConstant: 70),
            levelsLabel.heightAnchor.constraint(equalToConstant: 40),
            
            hardModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hardModeButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            hardModeButton.widthAnchor.constraint(equalToConstant: 170),
            hardModeButton.heightAnchor.constraint(equalToConstant: 40),
            
            mediumModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mediumModeButton.topAnchor.constraint(equalTo: hardModeButton.bottomAnchor, constant: 20),
            mediumModeButton.widthAnchor.constraint(equalToConstant: 170),
            mediumModeButton.heightAnchor.constraint(equalToConstant: 40),
            
            easyModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            easyModeButton.topAnchor.constraint(equalTo: mediumModeButton.bottomAnchor, constant: 20),
            easyModeButton.widthAnchor.constraint(equalToConstant: 170),
            easyModeButton.heightAnchor.constraint(equalToConstant: 40),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 150),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            againButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            againButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            againButton.widthAnchor.constraint(equalToConstant: 150),
            againButton.heightAnchor.constraint(equalToConstant: 40),
            
            countStartTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countStartTimeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            countStartTimeLabel.widthAnchor.constraint(equalToConstant: 300),
            countStartTimeLabel.heightAnchor.constraint(equalToConstant: 300)
            
        ])
    }
}
