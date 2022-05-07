//
//  Node+nodes.swift
//  
//
//  Created by Nickolay Truhin on 10.10.2020.
//

import Foundation
import Publish
import Plot

extension Node where Context == HTML.BodyContext {
    static func makeItemsPageContent(context: PublishingContext<PortfolioSite>, items: [Item<PortfolioSite>], pageIndex: Int, lastPage: Bool) -> Node {
        let navNode: Node<HTML.BodyContext> = .div(
            .style("margin: 10px"),
            .table(
                .tr(
                    .th(
                        .if(pageIndex > 1, .a(
                            .text(context.site.language == .russian ? "Назад" : "Back"),
                            .href("/\(context.site.pathPrefix(for: context.site.language))/items/\(pageIndex - 1)")
                        )),
                        .class("pagination-prev")
                    ),
                    .th(
                        .h4(.text("\(context.site.language == .russian ? "Страница" : "Page") \(pageIndex)")),
                        .class("pagination-title")
                    ),
                    .th(
                        .if(!lastPage, .a(
                            .text(context.site.language == .russian ? "Вперед" : "Next"),
                            .href("/\(context.site.pathPrefix(for: context.site.language))/items/\(pageIndex + 1)")
                        )),
                        .class("pagination-next")
                    )
                )
            )
        )
        return .div(
            .h1(.text(context.site.language == .russian ? "Последние посты" : "Latest posts")),
            
            navNode,
            .itemList(
                for: items,
                on: context.site,
                context: context
            ),
            navNode
        )
    }

    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }

    static func header(
        for context: PublishingContext<PortfolioSite>,
        selectedSection: PortfolioSite.SectionID?,
        in language: Language?
    ) -> Node {
        var sectionIDs: [PortfolioSite.SectionID?] = PortfolioSite.SectionID.allCases
        sectionIDs.insert(nil, at: sectionIDs.count / 2 + 1)
        return .header(
            .wrapper(
                .row(justifyConfigs: [
                        .init(type: .between, breakpoint: .md),
                        .init(type: .center)
                    ],
                    .col([.init(size: .auto)],
                         .row(gutters: true,
                            .col([.init(size: .auto, breakpoint: .md)],
                                .img(
                                    .src("/avatar.jpg"),
                                    .class("logo")
                                )
                            ),
                            .col([],
                                .div(
                                    .a(
                                        .href("/\(context.site.pathPrefix(for: language!))/"),
                                        .p(
                                            .class("logo-title"),
                                            .text(language == .russian ? "Николай Трухин" : "Nikolai Trukhin")
                                        ),
                                        .p(
                                            .class("logo-subtitle"),
                                            .text(language == .russian ? "iOS разработчик" : "iOS developer")
                                        )
                                    )
                                )
                            )
                        )
                    ),
                    .col([.init(size: .auto, breakpoint: .md)],
                        .row(justifyConfigs: [
                                .init(type: .end, breakpoint: .md),
                                .init(type: .center)
                            ],
                            .forEach(sectionIDs) { section in
                                if let section = section {
                                    return .col([.init(size: .auto)],
                                        .a(
                                            .class(
                                                section == selectedSection ? "selected" : "",
                                                .spacing([ .init(type: .margin, size: 2, side: .horizontal) ])
                                            ),
                                            .href(Path(context.site.pathPrefix(for: language!)).appendingComponent(context.sections[section].path.string)),
                                            .text(context.sections[section].title(in: language!))
                                        )
                                    )
                                } else {
                                    return .element(named: "div", nodes: [ .class("header-wrap") ])
                                }
                            }
                        )
                    )
                )
                
            )
        )
    }

    static func itemList(
        for items: [Item<PortfolioSite>],
        on site: PortfolioSite,
        context: PublishingContext<PortfolioSite>,
        sectionShow: Bool = true
    ) -> Node {
        .ul(
            .class("item-list"),
            .forEach(items) { $0.node(on: site, context: context, sectionShow: sectionShow)}
        )
    }

    static func footer(
        for site: PortfolioSite,
        in language: Language?
    ) -> Node {
        return .footer(
            .p(
                .text(language == .russian ? "Сгенерировано с помощью " : "Generated using "),
                .a(
                    .text("Publish"),
                    .href("https://github.com/johnsundell/publish")
                )
            ),
            .p(.a(
                .text(language == .russian ? "RSS лента" : "RSS channel"),
                .href("/\(site.pathPrefix(for: language!))/feed.rss")
            ))
        )
    }
    
    static func adaptiveImage(_ path: String, _ altText: String, context: PublishingContext<PortfolioSite>) -> Node {
        let html = context.markdownParser.html(from: "![\(altText)](\(path))")
        return .contentBody(Content.Body(html: html))
    }
    
    static func icon(_ path: String, context: PublishingContext<PortfolioSite>) -> Node {
        .adaptiveImage(path, "icon", context: context)
    }
    
    static func video(_ id: String) -> Node {
        .div(
            .class("item-youtube"),
            .iframe(
                .class("item-youtube-iframe"),
                .src("https://www.youtube.com/embed/\(id)?rel=0"),
                Attribute(name: "allowfullscreen", value: nil, ignoreIfValueIsEmpty: false),
                .attribute(named: "frameborder", value: "0")
            )
        )
    }
}

public extension Node where Context: HTMLContext {
    /// Assign a class name to the current element. May also be a list of
    /// space-separated class names.
    static func `class`(_ classNames: String...) -> Node {
        .class(classNames.joined(separator: " "))
    }
    
    static func `class`(_ classNames: [String]) -> Node {
        .class(classNames.joined(separator: " "))
    }
}
