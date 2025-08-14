//
//  SelfieShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class SelfieShareView: UIView {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.isScrollEnabled = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(SelfieCell.self, forCellWithReuseIdentifier: SelfieCell.identifier)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) have not been implemented")
    }
    
    var currentSelfieWithFilter = UIImage(systemName: "person.fill")
    var currentFilterImage = UIImage()
    var currentFilter  = Filters.specs
    var currentSelfie = UIImage()

    private func setupView(){
        backgroundColor = .green
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 150),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
        ])
    }
    
    func changeCurrentSelfie(with newSelfie: UIImage){
        currentSelfieWithFilter = newSelfie
        collectionView.reloadData()
    }
    
    func changeCurrentSelfie(with selfie: UIImage, withFilter filter: Filters){
        
        currentFilter = filter
        guard let filterImage = filter.getImage() else { return }
        currentFilterImage = filterImage
        currentSelfie = selfie
        createImage()
        collectionView.reloadData()
    }
    
    func createImage(){
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        var resultImage = renderer.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        let selfieSize = CGSize(width: resultImage.size.width * currentSelfie.size.width / currentSelfie.size.height, height: resultImage.size.height)
        resultImage = resultImage.overlayWith(overlayImage: currentSelfie,
                                              in: CGRect(
                                                x: size.width / 2 - (selfieSize.width) / 2,
                                                y: 0,
                                                width: selfieSize.width,
                                                height: selfieSize.height ))
        currentSelfieWithFilter = resultImage.overlayWith(overlayImage: currentFilterImage,
                                                          in: CGRect(x: size.width / 2 - (selfieSize.width * 1.25) / 2 ,
                                                                     y: size.height / 2 - (selfieSize.height * 1.25) / 2,
                                                                     width: selfieSize.width * 1.25,
                                                                     height: selfieSize.height * 1.25))
    }

    func changeFilter(){
        currentFilter.toNextState()
        guard let filterImage = currentFilter.getImage() else { return }
        currentFilterImage = filterImage
        createImage()
        collectionView.reloadData()
    }
}


class SelfieCell: UICollectionViewCell {
    static let identifier = "SelfieCell"

    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    func configure(){
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            imageView.widthAnchor.constraint(equalToConstant: 100)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
