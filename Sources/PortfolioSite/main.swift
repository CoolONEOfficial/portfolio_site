import Foundation
import Publish
import Ink
import Plot
import SplashPublishPlugin
import DarkImagePublishPlugin
import TinySliderPublishPlugin
import Files

// This type acts as the configuration for your website.
public struct PortfolioSite: MultiLanguageWebsite {
    public enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case projects
        case books
        case events
        case career
        case achievements
    }

    public struct ItemMetadata: MultiLanguageWebsiteItemMetadata {
        var project: ProjectMetadata?
        var event: EventMetadata?
        var career: CareerMetadata?
        var book: BookMetadata?
        var achievement: AchievementMetadata?
        
        var videos: [String]?
        var logo: String?
        var singleImage: String?
        var endDate: String?
        public var alternateLinkIdentifier: String?
    }

    public var url = URL(string: "https://coolone.ru")!
    public var name = "Nikolai Trukhin's website"
    public var description = "Here is all the information about projects, events, books, and more"
    public var languages: [Language] { [ .english, .russian ] }
    public var imagePath: Path? { "/avatar.jpg" }
    public var favicon: Favicon? { .init(path: "/avatar.jpg", type: "image/jpg") }
}

extension PortfolioSite.ItemMetadata {
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }()
    
    var parsedEndDate: Date? {
        if let endDate = endDate {
            return PortfolioSite.ItemMetadata.dateFormatter.date(from: endDate)
        }
        return nil
    }
}

//let file = try File(path: #file)
//guard let ftpConnection = try FTPConnection(file: file) else {
//    throw FilesError(path: file.path, reason: LocationErrorReason.missing)
//}

try PortfolioSite().publish(
    withTheme: .portfolio,
    //deployedUsing: .ftp(connection: ftpConnection, useSSL: false),
    additionalSteps: [
        .addItemPages()
    ],
    plugins: [
        .splash(withClassPrefix: ""),
        .darkImage(),
        .tinySlider(jsPath: "/modules/tiny-slider/src/tiny-slider.js", defaultConfig: [
            "mouseDrag": true,
            "swipeAngle": false,
            "controls": false,
            "nav": false,
            "loop": false,
            "lazyload": true,
            "responsive": [
                "350": [
                    "items": 2
                ],
                "500": [
                    "items": 3
                ]
            ],
        ])
    ]
)

extension Section where Site == PortfolioSite {
    public func title(in language: Language) -> String {
        switch language {
        case .russian:
            switch id {
            case .projects:
                return "Проекты"
            case .books:
                return "Книги"
            case .events:
                return "Мероприятия"
            case .career:
                return "Карьера"
            case .achievements:
                return "Достижения"
            }

        default:
            switch id {
            case .projects:
                return "Projects"
            case .books:
                return "Books"
            case .events:
                return "Events"
            case .career:
                return "Career"
            case .achievements:
                return "Achievements"
            }
        }
    }
}

extension PublishingStep where Site == PortfolioSite {
    static func addItemPages() -> Self {
        .step(named: "Add items pages") { context in
            for language in context.site.languages {
                let chunks = context.allItems(
                    sortedBy: \.date,
                    in: language,
                    order: .descending
                ).chunked(into: 10)
                for (index, chunk) in chunks.enumerated() {
                    let index = index + 1
                    context.addPage(.init(path: "/items/\(index)", content: .init(
                        title: context.site.language == .russian ? "Все посты" : "All posts",
                        description: context.site.language == .russian ? "Список всех постов" : "List of all posts",
                        body: .init(node: .makeItemsPageContent(
                            context: context,
                            items: chunk,
                            pageIndex: index,
                            lastPage: chunks.count == index
                        )),
                        language: language
                    )))
                }
            }
        }
    }
}

extension Item {
    var id: String {
        let path = self.path.absoluteString
        return String(path[path.lastIndex(of: "/")!..<path.endIndex])
    }
}
