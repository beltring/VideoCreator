//
//  EffectsViewController.swift
//  VideoCreator
//
//  Created by Pavel Boltromyuk on 26.01.23.
//

import UIKit
import AVFoundation

class EffectsViewController: UIViewController {

    var selectedPhotos = [Photo]()

    private let presenter = EffectsPresenter()
    private var effects = [Effect]()
    private var selectedEffect = "" {
        didSet {
            title = selectedEffect.isEmpty ? "Effects" : "Select 1 effect"
            nextButton.isEnabled = !selectedEffect.isEmpty
            nextButton.backgroundColor = selectedEffect.isEmpty ? .black.withAlphaComponent(0.4) : .black
        }
    }
    private var fullSizeImages = [UIImage]() {
        didSet {
            if fullSizeImages.count == selectedPhotos.count {
                buildVideo()
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.setViewDelegate(delegate: self)
        presenter.obtainEffects()
    }

    // MARK: - SetupUI

    private func setupUI() {
        title = "Effects"
        view.backgroundColor = .white
        view.addSubview(effectsCollectionView)
        view.addSubview(nextButton)
        configureConstraints()
    }

    private func configureConstraints() {
        effectsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.leading.trailing.equalTo(view).inset(16)
        }

        nextButton.snp.makeConstraints { make in
            make.top.equalTo(effectsCollectionView.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(22)
            make.leading.trailing.equalTo(view).inset(16)
            make.height.equalTo(52)
        }
    }

    private func showLoaderView() {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        window?.addSubview(loaderView)
        loaderView.configure(title: "Video Processing", description: "Wait a little bit")
        loaderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Functions

    private func presentResultAlert(success: Bool) {
        loaderView.hideLoaderAlert()
        if success {
            presentAlert(title: Constants.successTitle,
                         message: Constants.successDescription,
                         preferredStyle: .alert,
                         cancelTitle: Constants.okButtonTitle,
                         cancelStyle: .default,
                         cancelHandler: popViewController(action:),
                         animated: true
            )
        } else {
            presentAlert(title: Constants.errorTitle,
                         titleColor: .red,
                         message: Constants.errorDescription,
                         preferredStyle: .alert,
                         cancelTitle: Constants.okButtonTitle,
                         cancelStyle: .default,
                         cancelHandler: popViewController(action:),
                         animated: true
            )
        }
    }

    private func popViewController(action: UIAlertAction) {
        loaderView.removeFromSuperview()
        navigationController?.popViewController(animated: true)
    }

    private func buildVideo() {
        let effect = effects.first { $0.title == selectedEffect } ?? .none
        let maker = VideoEditorService(images: fullSizeImages, effect: effect)
        maker.buildVideo(completed: { [weak self] success, _ in
            self?.presentResultAlert(success: success)
        })
    }

    // MARK: - Actions

    @objc func tappedNextButton(sender: UIButton!) {
        showLoaderView()
        selectedPhotos.forEach { presenter.downloadImage(photo: $0) }
    }

    @objc func tappedBackButton() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UIComponents

    private lazy var effectsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 32, height: view.frame.width - 32)
        layout.minimumLineSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setContentOffset(.zero, animated: false)
        collectionView.register(EffectCell.self, forCellWithReuseIdentifier: EffectCell.reuseIdentifer)
        return collectionView
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.layer.cornerRadius = 12
        button.backgroundColor = .black.withAlphaComponent(0.4)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = .white
        button.isEnabled = false
        button.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)

        return button
    }()

    private lazy var loaderView = LoaderView()
}

// MARK: - UICollectionViewDataSource

extension EffectsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        effects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EffectCell.reuseIdentifer, for: indexPath) as! EffectCell
        let effect = effects[indexPath.row]
        cell.configure(effect: effect, isSelected: selectedEffect == effect.title)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension EffectsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let effect = effects[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath) as! EffectCell
        let isSelected = selectedEffect == effect.title

        if selectedEffect.isEmpty && !isSelected {
            selectedEffect = effect.title
            cell.configure(isSelected: true)
        } else {
            selectedEffect = isSelected ? "" : selectedEffect
            cell.configure(isSelected: false)
        }
    }
}

// MARK: - EffectsViewDelegate

extension EffectsViewController: EffectsViewDelegate {
    func didObtainEffects(effects: [Effect]) {
        self.effects = effects
        effectsCollectionView.reloadData()
    }

    func didDownloadPhoto(image: UIImage) {
        fullSizeImages.append(image)
    }

    func showErrorAlert(description: String) {
        presentAlert(title: Constants.errorTitle,
                     message: description,
                     preferredStyle: .alert,
                     cancelTitle: Constants.okButtonTitle,
                     cancelStyle: .default,
                     animated: true
         )
    }
}
