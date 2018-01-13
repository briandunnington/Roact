sub init()
    m.videoItem = m.top.findNode("videoItem")
    m.bannerItem = m.top.findNode("bannerItem")
    m.buttonsItem = m.top.findNode("buttonsItem")

    m.top.observeField("itemContent", "contentChanged")
    m.top.observeField("rowHasFocus", "rowHasFocusChanged")
    m.top.observeField("focusPercent", "focusPercentChanged")
end sub

sub contentChanged()
    content = m.top.itemContent

    if content.type = "banner"
        m.videoItem.visible = false
        m.buttonsItem.visible = false
        m.bannerItem.width = m.top.width
        m.bannerItem.height = m.top.height
        m.bannerItem.itemContent = content
        m.bannerItem.visible = true
    else if content.type = "buttons"
        m.videoItem.visible = false
        m.bannerItem.visible = false
        m.buttonsItem.width = m.top.width
        m.buttonsItem.height = m.top.height
        m.buttonsItem.itemContent = content
        m.buttonsItem.visible = true
    else
        m.bannerItem.visible = false
        m.buttonsItem.visible = false
        m.videoItem.width = m.top.width
        m.videoItem.height = m.top.height
        m.videoItem.itemContent = content
        m.videoItem.visible = true
    end if
end sub

sub rowHasFocusChanged()
    m.videoItem.rowHasFocus = m.top.rowHasFocus
    m.bannerItem.rowHasFocus = m.top.rowHasFocus
    m.buttonsItem.rowHasFocus = m.top.rowHasFocus
end sub

sub focusPercentChanged()
    m.videoItem.focusPercent = m.top.focusPercent
end sub
