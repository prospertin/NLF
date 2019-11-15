//
//  NLFDataManager
//  NLF
//
//  Created by Thinh Nguyen on 10/5/19.
//  Copyright © 2019 Prospertin. All rights reserved.
//

import Foundation
import ObjectMapper

class NLFDataManager {
    
    func getAllLaureates() -> [LaureateModel] {
        var models:[LaureateModel] = []
        let url = Bundle.main.url(forResource: "nobel-prize-laureates", withExtension: "json")!
        do {
            let jsonData = try Data(contentsOf: url)
            let json:AnyObject! = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            models = Mapper<LaureateModel>().mapArray(JSONArray: json as! [[String : Any]])
        }
        catch {
            print(error)
        }
        
        return models
    }
}
