'Call this from your Scene's init()
sub RoactRenderScene(scene, vNode)
    RoactUpdateElement(scene, invalid, vNode, 0)
end sub

function h(elementType, props = invalid, children = invalid)
    if props = invalid then props = {}
    if children = invalid then children = []
    return {
        type: elementType,
        props: props,
        children: children
    }
end function

'----------------------------------------------------------------------------
'Everything below here is a 'private' function only used by Roact internally. 
'Do not call these functions directly.
'----------------------------------------------------------------------------

function RoactCreateElement(vNode)
    if vNode = invalid then return invalid
    if m.mounting = invalid then m.mounting = []
    el = CreateObject("roSGNode", vNode.type)
    if el.hasField("roact")
        m.mounting.push(el)
        el.setFields({
            id: vNode.props.id
            props: vNode.props
            children: vNode.children
        })
        vNode = el.callFunc("conditionalRender", invalid)
        child = RoactCreateElement(vNode)
        if child <> invalid then el.appendChild(child)
    else
        el.addFields({
            _intrinsicChildCount: el.getChildCount()
        })
        if vNode.props.count() > 0 then el.setFields(vNode.props)
        for i=0 to vNode.children.count() - 1
            child = RoactCreateElement(vNode.children[i])
            if child <> invalid then el.appendChild(child)
        end for
    end if
    return el
end function

sub RoactFireComponentDidMount()
    if m.mounting <> invalid
        for i=(m.mounting.count() - 1) to 0 step -1
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

    'Reconcile virtual nodes into actual SG components
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
            child.setFields({
                props: newVNode.props
                children: newVNode.children
            })
            RoactUpdateElement(child)
        else                                    '5. Node is the same type and is a plain SG component
            child = parent.getChild(index)
            offset = 0
            if child._intrinsicChildCount <> invalid then offset = child._intrinsicChildCount
            RoactUpdateProps(child, oldVNode.props, newVNode.props)
            newLength = newVNode.children.count()
            oldLength = oldVNode.children.count()
            length = newLength
            if oldLength > length then length = oldLength
            for i=0 to length - 1
                RoactUpdateElement(child, oldVNode.children[i], newVNode.children[i], offset + i)
            end for
        end if
    end if
end sub

sub RoactUpdateProps(el, oldProps, newProps)
    el.setFields(newProps)
end sub
