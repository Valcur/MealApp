//
//  RecipesSearchPanelVM.swift
//  Meal
//
//  Created by Loic D on 19/07/2023.
//

import Foundation

class RecipesSearchPanelViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = [
        Recipe(name: "erzare"),
        Recipe(name: "eae"),
        Recipe(name: "zrgerg"),
        Recipe(name: "eaz grzg e"),
        Recipe(name: "gzrgzg"),
        Recipe(name: "eazr gzrge"),
        Recipe(name: "z rgzrg"),
        Recipe(name: "zrgrzzrr"),
        Recipe(name: "z rgzrrrg"),
        Recipe(name: "zrslgppfsp"),
        Recipe(name: "zeazzzzzzz")
    ]
    
    @Published var selectedSearchTags: [SearchTag] = []
    
    func removeShowedRecipe() {
        recipes.removeLast()
    }
}

struct Recipe: Equatable {
    let name: String
    let imageUrl: String = "https://edamam-product-images.s3.amazonaws.com/web-img/52f/52f1f9255488e7554700db0102262fa2.jpg?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEDQaCXVzLWVhc3QtMSJIMEYCIQDs4L2hccCsyUy6Ei12pRm5ChArXExXmrDKNHkW4Q4hHAIhAIK1q63ax1TcskmaPOGvk8YzczLmsfbQ7WGqqNPUvdqdKsEFCL3%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQABoMMTg3MDE3MTUwOTg2Igw%2Fs5fqNBkmcJw4C6AqlQX%2FCkJlVF6MedofGchaLgUkTtwp%2FeiIq3taHDflVhJFWv%2FlEAtRbbmkPLQUt5aJRm9iNNjkpQ%2B7w1Zh%2FrbRYEWRb9mgDsG2xoKLRblkWWv8NPNvZx%2B3kY2r7sAGeFyaMZ%2BJYa0V3B8Fn8E3cFmQRi3FoQJEevorbC0Zv1%2FyVsSQXbhuFv7MGMBeteAqmhD2l67vU0kA316NOawOkRw1sbxcfHBrZlFjtUBju2H9u%2BUFudYXhh2oxNTbztiNcARd9Fid1cLY5L0qmBBchwG7O6tEVAdBiqmc8VvDIlAGnD5vXY1tomP1G4HZAh5NGA3%2Fi8JcK9gT2Vn%2BwFWkqJLCEczkcESmhhNzGHvEyPSmXYNf2h9cmTPxW1pevHnUMHNnQwD0i%2FR%2B4vwvgtBxaWE78uXtXbh1e%2BsYi6FGDcWjhfDPILkMPEmDAqVrgrA8yk0sd8U9eayFenwV4YdadbKCW%2B8tt8Qx%2Bx0MkhP22shhChava%2BiQuBUVyyvTqwpPf2DrHZr5hobL8EcR078VyCTpyjKXBGocDJqveH%2Fg2i2TQUdFOFatN9gxlmLGJBZPjZnFNdPKlbV02VXvXnF0wMENcndU99hHJGfAxEx%2FYcHvNZh8suL%2Bky0UCr2%2BkElgCKAnR30JnCz6YbfAoLgXFwbpUxSk3ztjFj73S6bRH3e410TN4zA1ppNhBq4npm8aPAGOE0kqr5uxy37%2BZtGSvJGgbOrIBGAyYjBk4l9JOhW43r4lEmn07EQ4icVxzMoMjDNK0dZsDuO5h1I7hfgV8gktL0ghsp9mhyonLty70nLWg%2FPQ0ihx6%2BnRKDlV96JBkeXqe4C6IGK5vNeP4viQMHB1ijEfmCF4dxkXaPYJ74m04zYHiSanWanCMNDZ6aUGOrABXWZEQYelfNqgrVRP0p22wQv%2BAXyUd5XTNIWOFjqnYYLXSoYZE0pOrw14BWdHxG5Wp0qp3Fw1%2BkC8D0G8eeDgoKn2sXe%2BWD54a57IWd%2FjYKFxrKtVE11UHbnKzcSZXvJWCo7mCK95JGUyabtkbptKFJTm%2BnCfrhCoJdZOhV0os4bYqTGaW9iqMJLafQTZKhyUmVG6FaezodUQ0%2FbAM3jA6%2Bdkgxgh58%2BJ1g8lGEHMvs8%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230721T131208Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3599&X-Amz-Credential=ASIASXCYXIIFNOKFV6NP%2F20230721%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=f55d21ea033d1650d2b1d5aa5d2d681dba6f9265259d0b416e6d3dd96e7e51f6"
    var ingredients: [String] = [
        "1 egg",
        "2 limes cut",
        "1 tablespoon fish sauce"
    ]
    var nutrition: NutritionInfo = NutritionInfo()
    var preparation: String = "rehlejhijetilh"
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.name == rhs.name
    }
    
    static var empty = Recipe(name: "")
    
    struct NutritionInfo {
        let calories: String = "1,106"
        let dailyValue: String = "55%"
        let servings: String = "4"
    }
}

enum SearchTag: String {
    case vegan = "Vegan-Tag"
    case vegeterian = "Vege-Tag"
    
    func title() -> String {
        switch(self) {
        case .vegan:
            return "Vegan".translate()
        case .vegeterian:
            return "Vegeterian".translate()
        default:
            return "FUCK"
        }
    }
}
