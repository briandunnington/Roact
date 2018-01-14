function h(elementType, props = invalid, children = invalid)
    if props = invalid then props = {}
    if children = invalid then children = []
    return {
        type: elementType,
        props: props,
        children: children
    }
end function

'Call this from your Main() method as soon as your show your main Scene
sub RoactRenderScene(scene, vNode)
    RoactUpdateElement(scene, invalid, vNode, 0)
end sub

'-----------------------------------------------------------------
'Everything below here is a 'private' function only used by Roact
'internally. Do not call these functions directly.
'-----------------------------------------------------------------

function RoactCreateElement(vNode)
    if vNode = invalid then return invalid

    if m.mounting = invalid then m.mounting = []

    ?"CREATED NODE:", vNode.type
    el = CreateObject("roSGNode", vNode.type)
    if el.hasField("roact")
        m.mounting.push(el)
        if vNode.props.id <> invalid then el.id = vNode.props.id
        el.props = vNode.props
        el.children = vNode.children
        child = RoactCreateElement(el.callFunc("conditionalRender", invalid))
        if child <> invalid then el.appendChild(child)
    else
        el.setFields(vNode.props)
        for i=0 to vNode.children.count() - 1
            child = RoactCreateElement(vNode.children[i])
            if child <> invalid then el.appendChild(child)
        end for
    end if
    return el
end function

sub RoactFireComponentDidMount()
    if m.mounting <> invalid
        for i=0 to m.mounting.count() -1
            el = m.mounting[i]
            el.callFunc("componentDidMount", invalid)
        end for
    end if
    m.mounting = invalid
end sub

sub RoactUpdateElement(parent, oldVNode = invalid, newVNode = invalid, index = 0)
    'If this is a Roact component, re-render if required
    if parent.hasField("roact")
        oldVNode = parent.lastRender
        newVNode = parent.callFunc("conditionalRender", invalid)
    end if

    if oldVNode = invalid                       '1. Node did not previously exist
        child = RoactCreateElement(newVNode)
        if child <> invalid
            parent.appendChild(child)
            RoactFireComponentDidMount()
        end if
    else if newVNode = invalid                  '2. Node no longer exists
        parent.removeChildIndex(index)
    else if newVNode.type <> oldVNode.type      '3. Node type changed
        child = RoactCreateElement(newVNode)
        if child <> invalid
            parent.replaceChild(child, index)
            RoactFireComponentDidMount()
        end if
    else
        child = parent.getChild(index)
        if child.hasField("roact")              '4. Node is the same type and is a Roact component
            child.props = newVNode.props
            child.children = newVNode.children
            oldVNode = child.oldVNode
            x = parent.callFunc("conditionalRender", invalid)
            RoactUpdateElement(child)
        else                                    '5. Node is the same type and is a plain SG component
            child = parent.getChild(index)
            RoactUpdateProps(child, oldVNode.props, newVNode.props)
            newLength = newVNode.children.count()
            oldLength = oldVNode.children.count()
            length = newLength
            if oldLength > length then length = oldLength
            for i=0 to length - 1
                RoactUpdateElement(child, oldVNode.children[i], newVNode.children[i], i)
            end for
        end if
    end if
end sub

sub RoactUpdateProps(el, oldProps, newProps)
    el.setFields(newProps)
    ' combined = {}
    ' combined.append(oldProps)
    ' combined.append(newProps)
    ' for each prop in combined
    '     RoactUpdateProp(el, prop, oldProps[prop], newProps[prop])
    ' end for
end sub

sub RoactUpdateProp(el, propName, oldValue, newValue)
    'if newValue <> oldValue
'?"CHANGED prop:", propName, newValue, oldValue
        el.setField(propName, newValue)
'    else
'?"unchanged prop:", propName, oldValue
'    end if
end sub
