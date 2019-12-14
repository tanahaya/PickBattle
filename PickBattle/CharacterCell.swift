//
//  CharacterCell.swift
//  PickBattle
//
//  Created by 田中 颯 on 2019/12/14.
//  Copyright © 2019 tanahaya. All rights reserved.
//

import UIKit

class CharacterCell: UITableViewCell {

    var nameLabel = UILabel(frame: CGRect(x: 240, y: 10, width: 200, height: 20))
    var experieneceLevelLabel = UILabel(frame: CGRect(x: 220, y: 60, width: 100, height: 20))
    var developLevelLabel = UILabel(frame: CGRect(x: 330, y: 60, width: 100, height: 20))
    var characterImageview = UIImageView(frame: CGRect(x: 40, y: 20, width: 80, height: 80))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameLabel.text = ""
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        self.addSubview(nameLabel)
        
        experieneceLevelLabel.text = ""
        experieneceLevelLabel.font = UIFont.systemFont(ofSize: 11)
        self.addSubview(experieneceLevelLabel)
        
        developLevelLabel.text = ""
        developLevelLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(developLevelLabel)
        
        self.addSubview(characterImageview)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


