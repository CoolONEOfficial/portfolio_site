//
//  Item+nodes.swift
//  
//
//  Created by Nickolay Truhin on 10.10.2020.
//

import Foundation
import Plot
import Publish
import Ink

extension Item where Site == PortfolioSite {
    var itemDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: self.language == .russian ? "ru_RU" : "en_US")
        return formatter
    }
    
    func node(on site: PortfolioSite, context: PublishingContext<PortfolioSite>, sectionShow: Bool) -> Node<HTML.ListContext> {
        let html = MarkdownParser().html(from: description)
        return .li(.article(
            .row(justifyConfigs: [.init(type: .center)],
                .col([],
                    header(context: context, sectionShow: sectionShow),
                    .div(
                        .class("item-description"),
                        .contentBody(Content.Body(html: html))
                    ),
                    singleImage(hideOnSm: false),
                    footer(on: site, context: context)
                ),
                .col([.init(size: .auto, breakpoint: .sm)],
                     .div(
                        .class(.spacing([
                            .init(type: .margin, size: 3, side: .left, breakpoint: .sm),
                            .init(type: .margin, size: 0, side: .left)
                        ])),
                        singleImage(hideOnSm: true)
                     )
                )
            )
        ))
    }
    
    private func singleImage(hideOnSm: Bool) -> Node<HTML.BodyContext> {
        .div(
           .class(
               .spacing([
                   .init(type: .margin, size: 3, side: .vertical),
                   .init(type: .margin, size: 0, side: .vertical, breakpoint: .sm)
               ]),
               .display([
                .init(type: hideOnSm ? .block : .none, breakpoint: .sm),
                .init(type: hideOnSm ? .none : .block)
               ])
           ),
           image("singleImage", metadata.singleImage)
        )
    }
    
    func footer(
        on site: PortfolioSite,
        context: PublishingContext<PortfolioSite>
    ) -> Node<HTML.BodyContext> {
        var dateStr = itemDateFormatter.string(from: date)
        if let endDate = metadata.parsedEndDate {
            dateStr += " — " + itemDateFormatter.string(from: endDate)
        } else if sectionID == .career {
            dateStr += language == .russian ? " — по настоящее время" : " - now"
        }
        
        return .row(
            .col([], verticalSpacing: true,
                tagList(on: site)
            ),
            .col([.init(size: .auto)], verticalSpacing: true,
                .span(
                    .text(dateStr),
                    .class("item-date")
                )
            )
        )
    }
    
    func header(
        context: PublishingContext<PortfolioSite>,
        sectionShow: Bool = true
    ) -> Node<HTML.BodyContext> {
        .row(
            .col([.init(size: .auto)],
                 image("logo", metadata.logo)
            ),
            .col([.init(breakpoint: .md)],
                .h1(.a(
                    .href(context.site.pathWithPrefix(path: path, in: language!)),
                    .text(title)
                )),
                subheader(context: context, sectionShow: sectionShow)
            )
        )
    }
    
//    private func iconsRow<Key: Iconic & Hashable>(_ icons: Dictionary<Key, String?>, context: PublishingContext<PortfolioSite>) -> Node<HTML.BodyContext> {
//        .row(
//            classSuffix: .spacing([ .init(type: .margin, size: 1, side: .top) ]),
//            .forEach(icons) { iconEntry in
//                .col([.init(size: .auto)],
//                     .a(
//                        .href(iconEntry.value ?? ""),
//                        .div(
//                            .icon(iconEntry.key.icon, context: context)
//                        )
//                     )
//                )
//            }
//        )
//    }

    func subheader(
        context: PublishingContext<PortfolioSite>,
        sectionShow: Bool = true
    ) -> Node<HTML.BodyContext> {
        let section = context.sections[sectionID]

        var subNodes = [Node<HTML.BodyContext>]()

        switch sectionID {
        case .projects:
            guard let metaProject = metadata.project else { break }
            subNodes.append(.row(
                classSuffix: .spacing([ .init(type: .margin, size: 1, side: .top) ]),
                .forEach(metaProject.platforms.map(\.icon)) { iconUrl in
                    .col([.init(size: .auto)],
                         .icon(iconUrl, context: context)
                    )
                },
                .col([],
                    .h4(
                        .text(metaProject.type.name(in: language!))
                    )
                )
            ))
            
            if let marketplaces = metaProject.marketplacesParsed {
                subNodes.append(.row(
                    classSuffix: .spacing([ .init(type: .margin, size: 1, side: .top) ]),
                    .col([.init(size: .auto)],
                        .h4(
                            .text(language == .russian ? "Доступно на" : "Available on"),
                            .style("margin-right: 5px")
                        )
                    ),
                    .forEach(marketplaces.enumerated().map(\.element)) { (marketplace, url) in
                        .col([.init(size: .auto)],
                             .a(
                                .href(url),
                                .div(.icon(marketplace.icon, context: context))
                             )
                        )
                    }
                ))
            }
        case .books:
            guard let metaBook = metadata.book else { break }
            subNodes.append(.h4(.text(
                metaBook.author
            )))
            
        case .events:
            guard let metaEvent = metadata.event else { break }
            subNodes.append(.h4(.text(
                metaEvent.location?.title ?? ""
            )))
        case .career:
            guard let metaCareer = metadata.career else { break }
            subNodes.append(.h4(.text(
                metaCareer.position + ", " + metaCareer.type.name(in: language!)
            )))
        case .achievements:
            guard let metaAchievement = metadata.achievement else { break }
            subNodes.append(.h4(.text(
                metaAchievement.type.name
            )))
        }
        
        return .div(
            .if(sectionShow,
                .h4(.a(
                    .href(context.site.pathWithPrefix(path: section.path, in: language!)),
                    .text(section.title(in: language!))
                ))
            ),
            .forEach(subNodes) { $0 }
        )
    }

    func tagList(on site: PortfolioSite) -> Node<HTML.BodyContext> {
        .ul(.class("tag-list"), .forEach(tags) { tag in
            .li(.a(
                .href(site.path(for: tag, in: language!)),
                .text(tag.string)
            ))
        })
    }
    
    func image(
        _ name: String,
        _ ext: String?,
        classPrefix: String = "",
        alt: String = "",
        preview: Bool = true
    ) -> Node<HTML.BodyContext> {
        .if(ext != nil,
            .img(
                .src("/\(path)/\(name)\(preview ? "_400x400" : "")\(ext ?? "")"),
                .alt(alt),
                .class("item-\(classPrefix)\(name)"),
                .roundedImage(ext)
            )
        )
    }
}

extension PortfolioSite {
    func pathWithPrefix(path: Path, in language: Language) -> Path {
        Path(pathPrefix(for: language)).appendingComponent(path.string)
    }
}
