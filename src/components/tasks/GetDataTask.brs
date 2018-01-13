sub init()
    m.top.functionName = "execute"
end sub

sub execute()
    'read all input variables in one go (avoid multiple reads from m.top)
    input = m.top.input

    qsBuilder = QueryStringBuilder()
    qsBuilder.add("country", input.country)
    qsBuilder.add("locale", input.locale)
    qsBuilder.add("applicationId", input.applicationId)
    qs = qsBuilder.toStr("?")
    url = input.url + qs
?"URL:", url
    options = {
        proxy: input.proxy
        timeout: 10 * 1000
        url: url
        headers: {
            "accept": "application/json",
            "x-access-token": input.accessToken,
            "cache-control": "no-cache"
        }
    }
    data = fetch(options)

    output = invalid
    fields = {}
    if data <> invalid AND data.error = invalid
        if data.application <> invalid
            app = data.application
            if app.firstRunVideo <> invalid
                firstRunVideo = parseItem(app.firstRunVideo)
                if firstRunVideo.videoManifestFilename <> invalid
                    fields.firstRunVideo = firstRunVideo
                end if
            end if
        end if

        sections = data.sections
        for s=0 to sections.count() - 1
            section = sections[s]
            if section.name = "tcl-home-section"
                fields.home = parseHomeSection(section)
            else if section.name = "tcl-where-to-find-section"
                fields.where = parseWhereSection(section)
            else if section.name = "tcl-privacy-section"
                fields.privacy = parseSection(section)
            else if section.name = "tcl-tos-section"
                fields.tos = parseSection(section)
            else if section.name = "tcl-notifications-section"
                fields.notifications = parseSection(section)
            end if
        end for
    else
        fields.error = data.error
    end if

    output = CreateObject("roSGNode", "ContentNode")
    output.addFields(fields)

    'set all results in a single call (avoid multiple writes to m.top)
    m.top.output = output
end sub


function parseHomeSection(section)
    node = CreateObject("roSGNode", "ContentNode")
    if section.carousel <> invalid
        carouselRowNode = parseCarousel(section.carousel)
        ' since carousel has no title, setting app header title to this
        carouselRowNode.title = section.title
        carouselRowNode.addFields({
            rowConfig: {
                rowItemSize: [1147,645],
                rowItemSpacing: [0,0],
                rowSpacings: 120,
                rowHeights: 645,
                rowLabelOffset: [90,0],
                focusXOffset: (1920-1170)/2,
                showRowLabel: true
            }
        })
        node.appendChild(carouselRowNode)
    end if

    if section.rows <> invalid
        for i=0 to section.rows.count() - 1
            row = section.rows[i]
            rowNode = parseRow(row)
            rowItemSize = [554,312]
            rowHeights = 363
            if row.isPortrait then
                rowItemSize = [406,609]
                rowHeights = 660
            end if
            rowNode.addFields({
                rowConfig: {
                    rowItemSize: rowItemSize,
                    rowItemSpacing: [6,0],
                    rowSpacings: 92,
                    rowHeights: rowHeights,
                    rowLabelOffset: [90,23],
                    focusXOffset: 90,
                    showRowLabel: true
                }
            })
            node.appendChild(rowNode)
        end for
    end if

    bannerIndex = invalid
    if section.banners <> invalid AND section.banners.count() > 0
        bannerNode = parseBanner(section.banners[0])
        bannerRowNode = CreateObject("roSGNode", "ContentNode")
        bannerRowNode.appendChild(bannerNode)
        bannerRowNode.addFields({
            rowConfig: {
                rowItemSize: [1740,334],
                rowItemSpacing: [0,0],
                rowSpacings: 92,
                rowHeights: 400,
                rowLabelOffset: [90,23],
                focusXOffset: 90,
                showRowLabel: true
            }
        })
        node.appendChild(bannerRowNode)
        bannerIndex = node.getChildCount() - 1
    end if

    buttonsIndex = invalid
    if section.buttons <> invalid AND section.buttons.count() > 0
        buttonsNode = parseButtons(section.buttons)
        buttonsRowNode = CreateObject("roSGNode", "ContentNode")
        buttonsRowNode.appendChild(buttonsNode)
        buttonsRowNode.addFields({
            rowConfig: {
                rowItemSize: [1740,334],
                rowItemSpacing: [0,0],
                rowSpacings: 92,
                rowHeights: 400,
                rowLabelOffset: [90,23],
                focusXOffset: 90,
                showRowLabel: true
            }
        })
        node.appendChild(buttonsRowNode)
        buttonsIndex = node.getChildCount() - 1
    end if

    rowItemSize = []
    rowItemSpacing = []
    rowSpacings = []
    rowHeights = []
    rowLabelOffset = []
    focusXOffset = []
    showRowLabel = []
    for i=0 to node.getChildCount() - 1
        childNode = node.getChild(i)
        rowConfig = childNode.rowConfig
        rowItemSize.push(rowConfig.rowItemSize)
        rowItemSpacing.push(rowConfig.rowItemSpacing)
        rowSpacings.push(rowConfig.rowSpacings)
        rowHeights.push(rowConfig.rowHeights)
        rowLabelOffset.push(rowConfig.rowLabelOffset)
        focusXOffset.push(rowConfig.focusXOffset)
        showRowLabel.push(rowConfig.showRowLabel)
    end for

    node.addFields({
        rowlistConfig: {
            rowItemSize: rowItemSize,
            rowItemSpacing: rowItemSpacing,
            rowSpacings: rowSpacings,
            rowHeights: rowHeights,
            rowLabelOffset: rowLabelOffset,
            focusXOffset: focusXOffset,
            showRowLabel: showRowLabel
        },
        bannerIndex: bannerIndex,
        buttonsIndex: buttonsIndex
    })

    return node
end function

function parseWhereSection(section)
    whereSection = parseSection(section)
    whereSection.addFields({
        subtitle: section.subtitle
    })
    whereSection.appendChild(whereSection.contentProviders)
    return whereSection
end function

function parseSections(sections)
    if sections = invalid then return invalid

    sectionsNode = CreateObject("roSGNode", "ContentNode")
    for s=0 to sections.count() - 1
        section = sections[s]
        sectionNode = parseSection(section)
        if sectionNode <> invalid
            sectionsNode.appendChild(sectionNode)
            sectionsNode.addField(section.name, "node", false)
            sectionsNode[section.name] = sectionNode
        end if
    end for
    return sectionsNode
end function

function parseSection(section)
    if section = invalid then return invalid

    sectionNode = CreateObject("roSGNode", "ContentNode")
    sectionNode.setFields({
        id: section.id,
        title: section.title
    })
    sectionNode.addFields({
        name: section.name,
        menuPrompt: section.menuPrompt,
        backgroundImage: section.backgroundImage,
        body: section.body,
        carousel: parseCarousel(section.carousel),
        rows: parseRows(section.rows),
        buttons: parseButtons(section.buttons),
        banners: parseBanners(section.banners),
        contentProviders: parseContentProviders(section.contentproviders)
    })
    return sectionNode
end function

function parseCarousel(carousel)
    return parseRow(carousel, "carousel")
end function

function parseRows(rows)
    if rows = invalid then return invalid

    rowsNode = CreateObject("roSGNode", "ContentNode")
    for r=0 to rows.count() - 1
        row = rows[r]
        rowNode = parseRow(row)
        if rowNode <> invalid
            rowsNode.appendChild(rowNode)
        end if
    end for
    return rowsNode
end function

function parseRow(row, t = "row")
    if row = invalid then return invalid

    rowNode = CreateObject("roSGNode", "ContentNode")
    rowNode.setFields({
        id: row.id,
        title: row.title
    })
    rowNode.addFields({
        type: t,
        name: row.name,
        isPortrait: row.isPortrait,
        isContinuousPlayback: row.isContinuousPlayback
    })
    for i=0 to row.items.count() - 1
        item = row.items[i]
        if row.isPortrait = true
            t = "portrait"
        end if

        itemNode = parseItem(item, t)
        if itemNode <> invalid
            rowNode.appendChild(itemNode)
        end if
    end for
    return rowNode
end function

function parseItem(item, t = "")
    if item = invalid then return invalid

    itemNode = CreateObject("roSGNode", "ContentNode")
    itemNode.setFields({
        id: item.id,
        title: item.title,
    })
    itemNode.addFields({
        type: t + "item",
        shortDescription: item.shortDescription,
        longDescription: item.longDescription,
        videoManifestFilename: item.videoManifestFilename,
        ' thumbnail: item.thumbnail.replace("////", "//"),
        thumbnail: item.thumbnail,
        runtimeSeconds: item.runtimeSeconds,
        isAtmos: (item.isAtmos <> invalid AND item.isAtmos),
        isVision: item.isVision,
        isAudio: item.isAudio
    })
itemNode.videoManifestFilename = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    return itemNode
end function

function parseBanners(banners)
    if banners = invalid then return invalid

    bannersNode = CreateObject("roSGNode", "ContentNode")
    for b=0 to banners.count() - 1
        banner = banners[b]
        bannerNode = parseBanner(banner)
        if bannerNode <> invalid
            bannersNode.appendChild(bannerNode)
        end if
    end for
    return bannersNode
end function

function parseBanner(banner)
    if banner = invalid then return invalid

    bannerNode = CreateObject("roSGNode", "ContentNode")
    bannerNode.setFields({
        id: banner.id,
        title: banner.title
    })
    bannerNode.addFields({
        type: "banner",
        name: replaceHyphen(banner.name),
        subtitle: banner.subtitle,
        body: banner.body,
        backgroundImage: banner.backgroundImage,
        buttonTitle: parseButtons(banner.buttons).tclhomebannerbutton.prompt
    })
    return bannerNode
end function

function parseButtons(buttons)
    if buttons = invalid then return invalid

    buttonsNode = CreateObject("roSGNode", "ContentNode")
    buttonsNode.addFields({
        type: "buttons"
    })
    for b=0 to buttons.count() - 1
        button = buttons[b]
        buttonNode = parseButton(button)
        if buttonNode <> invalid
            buttonsNode.appendChild(buttonNode)
            buttonsNode.addField(replaceHyphen(buttonNode.name), "node", false)
            buttonsNode[replaceHyphen(buttonNode.name)] = buttonNode
        end if
    end for
    return buttonsNode
end function

function parseButton(button)
    if button = invalid then return invalid

    buttonNode = CreateObject("roSGNode", "ContentNode")
    buttonNode.setFields({
        id: button.id
    })
    buttonNode.addFields({
        type: "button",
        name: replaceHyphen(button.name),
        prompt: button.prompt,
        tagline: button.tagline
    })
    return buttonNode
end function

function replaceHyphen(string as String)
    return string.replace("-", "")
end function

function parseContentProviders(contentProviders)
    if contentProviders = invalid then return invalid

    contentProvidersNode = CreateObject("roSGNode", "ContentNode")
    for c=0 to contentProviders.count() - 1
        contentProvider = contentProviders[c]
        contentProviderNode = parseContentProvider(contentProvider)
        if contentProviderNode <> invalid
            contentProvidersNode.appendChild(contentProviderNode)
        end if
    end for
    return contentProvidersNode
end function

function parseContentProvider(contentProvider)
    if contentProvider = invalid then return invalid

    contentProviderNode = CreateObject("roSGNode", "ContentNode")
    contentProviderNode.setFields({
        id: contentProvider.id
    })
    contentProviderNode.addFields({
        type: "contentprovider",
        body: contentProvider.body,
        logoImage: contentProvider.logoImage
    })
    return contentProviderNode
end function
