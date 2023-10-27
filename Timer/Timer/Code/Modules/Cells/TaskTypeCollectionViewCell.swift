//
//  TaskTypeCollectionViewCell.swift
//  Timer
//
//  Created by Ziya on 8/4/23.
//

import UIKit

class TaskTypeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var typeName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imageContainerView.layer.cornerRadius = self.imageContainerView.bounds.height / 2
        }
    }

    override class func description () -> String {
       return "TaskTypeCollectionViewCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
        self.imageView.image = nil
    }
    
    func setupCell(taskType: TaskType, isSelected: Bool) {
        self.typeName.text = taskType.typeName
        
        if isSelected {
            self.imageContainerView.backgroundColor = .systemGray5
            self.typeName.textColor = .label
            self.imageView.tintColor = .label
            self.imageView.image = UIImage(systemName: taskType.symbolName,withConfiguration: UIImage.SymbolConfiguration(pointSize: 26,weight: .bold))
        } else {
            self.imageView.image = UIImage(systemName: taskType.symbolName,withConfiguration: UIImage.SymbolConfiguration(pointSize: 22 ,weight: .regular))
            reset()
        }
    }
    
    func reset() {
        self.imageContainerView.backgroundColor = .clear
        self.typeName.textColor = .black
        self.imageView.tintColor = .black
    }
}
