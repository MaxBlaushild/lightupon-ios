//
//  PostService.swift
//  trip-advisori-iOS
//
//  Created by Blaushild, Max on 11/3/16.
//  Copyright © 2016 Blaushild, Max. All rights reserved.
//

import UIKit

class PostService: Service {
    fileprivate let _awsService: AwsService
    
    init(awsService: AwsService){
        _awsService = awsService
    }
    
    func sendPicture(name: String, type: String, callback: () -> Void) {
//        _awsService.sendPicture(name: name, type: type, callback: self.uploadSelfie(image: <#T##UIImage#>));
    }
    
    func uploadSelfie(image: UIImage) {
        let imageData = UIImagePNGRepresentation(image)!;
//        let string = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
}
