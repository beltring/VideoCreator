//
//  LoaderAlert.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit

final class LoaderAlert: UIView {

    private var timer: Timer?

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - SetupUI

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        addSubview(titleStackView)
        addSubview(spinnerImage)
        configureConstraints()
    }

    private func configureConstraints() {
        titleStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        spinnerImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleStackView.snp.bottom).offset(41)
            make.bottom.equalToSuperview().inset(32)
            make.width.height.equalTo(44)
        }
    }

    private func startAnimation() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval:0.0, target: self, selector: #selector(self.animateView), userInfo: nil, repeats: false)
        }
    }

    @objc private func animateView() {
        UIView.animate(withDuration: 0.8, delay: 0.0, options: .curveLinear, animations: {
            self.spinnerImage.transform = self.spinnerImage.transform.rotated(by: CGFloat(Double.pi))
        }, completion: { (finished) in
            if self.timer != nil {
                self.timer = Timer.scheduledTimer(timeInterval:0.0, target: self, selector: #selector(self.animateView), userInfo: nil, repeats: false)
            }
        })
    }

    // MARK: - Configure

    func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        startAnimation()
    }

    // MARK: - UIComponents

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    private lazy var spinnerImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spinner")
        return imageView
    }()
}
