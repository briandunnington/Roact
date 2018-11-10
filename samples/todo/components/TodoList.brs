sub init()
    m.top.observeField("focusedChild", "focusChanged")

    mapState(function(state, prevState)
        showAll = state.all.filter = "ALL"
        items = state.all.items
        content = CreateObject("roSGNode", "ContentNode")
        for i=0 to items.count() - 1
            item = items[i]
            if NOT item.completed or showAll
                child = content.createChild("ContentNode")
                prefix = "   "
                if item.completed then prefix = "X "
                child.id = item.id
                child.title = Chr(160) + prefix + item.text
            end if
        end for

        return {
            content: content
        }
    end function)
end sub

sub focusChanged()
    if m.top.hasFocus()
        m.list.setFocus(true)
    end if
end sub

sub componentDidMount()
    m.list = m.top.findNode("list")
    m.list.observeField("itemSelected", "itemSelected")
end sub

sub itemSelected()
    ToggleTodo(m.list.content.getChild(m.list.itemSelected).id)
end sub

function render()
    m.isStale = false
    m.top.translation = m.top.props.translation
    state = m.top.state
    focusIndex = 0
    if m.list <> invalid then focusIndex = m.list.itemFocused
    return h("LabelList", {id: "list", itemSize: [870, 60], content: state.content, jumpToItem: focusIndex})
end function
