//
//  PrimarySegmentedControl.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//

import UIKit

// MARK: - Delegate Protocol (Option 1: Delegate Pattern)
protocol PrimarySegmentedControlDelegate: AnyObject {
    func segmentedControl(_ segmentedControl: PrimarySegmentedControl, didSelectSegmentAt index: Int)
}

class PrimarySegmentedControl: UIView {

    // MARK: - Public Properties

    var segments: [String] = [] {
        didSet {
            setupSegments()
        }
    }

    var selectedSegmentIndex: Int = 3 {
        didSet {
             //If the index was set externally, update UI
            if oldValue != selectedSegmentIndex {
                selectSegment(at: selectedSegmentIndex, animated: true)
                delegate?.segmentedControl(self, didSelectSegmentAt: selectedSegmentIndex)
            }
        }
    }

    weak var delegate: PrimarySegmentedControlDelegate? // For delegate pattern

    // MARK: - UI Components

    private var buttons: [UIButton] = []
    private let stackView = UIStackView()
    private let selectionIndicatorView = UIView() // The moving bar/indicator
    private let dividerLine = UIView()
    private var leadingConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint?

    // MARK: - Appearance Properties (Customizable)

    var selectedSegmentColor: UIColor = .white
    var normalSegmentColor: UIColor = .white
    var selectedTextColor: UIColor = .black
    var normalTextColor: UIColor = .lightGray
    var segmentFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    var selectedSegmentFont: UIFont = .systemFont(ofSize: 15, weight: .regular) // Potentially bolder when selected
    var indicatorColor: UIColor = .black
    var indicatorHeight: CGFloat = 0.75
    var animationDuration: TimeInterval = 0.1
    var height: CGFloat = 50

    // MARK: - Initialization

    // Designated Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    // Convenience Initializer for programmatic use without frame initially
    init(segments: [String]) {
        super.init(frame: .zero) // Use .zero initially, let Auto Layout handle size
        self.segments = segments
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        DispatchQueue.main.async {
            self.setupDividerLineView()
            self.setupStackView()
            self.setupSegments()
            self.setupSelectionIndicator()
            
            // Set initial selection
            if !self.segments.isEmpty {
                self.selectSegment(at: 0, animated: false)
            }
            
        }
        
    }

    // MARK: - UI Setup Methods

    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // Make all segments equal width
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: dividerLine.topAnchor)
        ])
    }

    private func setupSegments() {
        
        // Remove existing buttons from stack view and array
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        for (index, title) in self.segments.enumerated() {
            
            let button = UIButton(type: .system) // .system gives default button behaviors
            button.setTitle(title, for: .normal)
            button.tag = index // Use tag to identify which segment was tapped
            button.addTarget(self, action: #selector(self.segmentTapped(_:)), for: .touchUpInside)
            // Apply initial text attributes
            button.setTitleColor(self.normalTextColor, for: .normal)
            button.titleLabel?.font = self.segmentFont
            
            self.stackView.addArrangedSubview(button)
            self.buttons.append(button)
            
            
        }
        
    }

    private func setupSelectionIndicator() {
        selectionIndicatorView.backgroundColor = indicatorColor
        selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        selectionIndicatorView.layer.cornerRadius = 1
        addSubview(selectionIndicatorView)

        // Initialize these constraints as properties
        leadingConstraint = selectionIndicatorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0)
        widthConstraint = selectionIndicatorView.widthAnchor.constraint(equalToConstant: 0) // Initial width can be 0 or placeholder

        NSLayoutConstraint.activate([
            leadingConstraint!, // Activate them
            widthConstraint!,
            selectionIndicatorView.bottomAnchor.constraint(equalTo: dividerLine.topAnchor),
            selectionIndicatorView.heightAnchor.constraint(equalToConstant: indicatorHeight)
        ])
    }
    
    
    private func setupDividerLineView(){
        let thickness: CGFloat = 0.5
        dividerLine.translatesAutoresizingMaskIntoConstraints = false
        dividerLine.backgroundColor = .black
        addSubview(dividerLine)
        
        NSLayoutConstraint.activate([
            dividerLine.heightAnchor.constraint(equalToConstant: thickness),
            dividerLine.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerLine.leftAnchor.constraint(equalTo: leftAnchor),
            dividerLine.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    // MARK: - Segment Selection Logic

    @objc private func segmentTapped(_ sender: UIButton) {
        let index = sender.tag
        if index != selectedSegmentIndex {
            selectedSegmentIndex = index // This will trigger didSet and update UI
             // Notify delegate
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func selectSegment(at index: Int, animated: Bool) {
        guard index >= 0 && index < buttons.count else { return }

        selectedSegmentIndex = index

        // Update button text colors and fonts
        for (i, button) in buttons.enumerated() {
            if i == index {
                button.setTitleColor(selectedTextColor, for: .normal)
                button.titleLabel?.font = selectedSegmentFont
            } else {
                button.setTitleColor(normalTextColor, for: .normal)
                button.titleLabel?.font = segmentFont
            }
        }
        
        // Animate indicator movement
        if animated {
            UIView.animate(withDuration: animationDuration, animations: {
                self.updateIndicatorPosition(for: index)
                self.layoutIfNeeded() // Forces immediate layout update for animation
            })
        } else {
            updateIndicatorPosition(for: index)
            
        }
    }

    private func updateIndicatorPosition(for index: Int) {
        guard index < buttons.count else { return }

        let selectedButton = buttons[index]
        
        guard selectedButton.frame.width > 0 else {
            DispatchQueue.main.async {
                self.updateIndicatorPosition(for: index)
            }
            return
        }
        let targetIndicatorLeading = selectedButton.frame.origin.x
        let targetIndicatorWidth = selectedButton.frame.width
        

        // Update the constants of the *existing* constraints
        leadingConstraint?.constant = targetIndicatorLeading
        widthConstraint?.constant = targetIndicatorWidth
        

    }
}
