//
//  LoaderView.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit

final class LoaderView: UIView {

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
        addSubview(backgroundView)
        addSubview(loaderAlert)
        configureConstraints()
    }

    private func configureConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loaderAlert.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(200)
        }
    }

    // MARK: - Configure

    func configure(title: String, description: String) {
        loaderAlert.configure(title: title, description: description)
    }

    func hideLoaderAlert() {
        loaderAlert.isHidden = true
    }

    // MARK: - UIComponents

    private lazy var backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    private lazy var loaderAlert = LoaderAlert()
}
