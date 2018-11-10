'Call this from your Scene's init()
sub RoactRenderScene(scene, vNode)
    RoactUpdateElement(scene, invalid, invalid, vNode, 0)
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
        vNode = el.callFunc("roactConditionalRender", invalid)
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
            el.callFunc("roactComponentDidMount", invalid)
        end for
    end if
    m.mounting = invalid
end sub

sub RoactUpdateElement(node, newState = invalid, oldVNode = invalid, newVNode = invalid, index = 0)
    prevPropsAndState = invalid
    didUpdate = false
    if node.hasField("roact")
        prevPropsAndState = {
            props: node.props
            state: node.state
        }
        newProps = node.props
        if newVNode <> invalid then newProps = newVNode.props
        if newState = invalid then newState = node.state
        nextPropsAndState = {
            props: newProps
            state: newState
        }

        oldVNode = node.lastRender
        newVNode = node.callFunc("roactConditionalRender", nextPropsAndState)
        didUpdate = (oldVNode <> invalid AND oldVNode.__instance <> newVNode.__instance)
        if NOT didUpdate then return
    end if

    'Reconcile virtual nodes into actual SG components
    if oldVNode = invalid                       '1. Node did not previously exist
        child = RoactCreateElement(newVNode)
        if child <> invalid
            node.appendChild(child)
            RoactFireComponentDidMount()
        end if
    else if newVNode = invalid                  '2. Node no longer exists
        node.removeChildIndex(index)
    else if newVNode.type <> oldVNode.type      '3. Node type changed
        child = RoactCreateElement(newVNode)
        if child <> invalid
            node.replaceChild(child, index)
            RoactFireComponentDidMount()
        end if
    else
        child = node.getChild(index)
        if child.hasField("roact")              '4. Node is the same type and is a Roact component
            RoactUpdateElement(child, invalid, invalid, newVNode)
        else                                    '5. Node is the same type and is a plain SG component
            child = node.getChild(index)
            offset = 0
            if child._intrinsicChildCount <> invalid then offset = child._intrinsicChildCount
            RoactUpdateProps(child, oldVNode.props, newVNode.props)
            newLength = newVNode.children.count()
            oldLength = oldVNode.children.count()
            length = newLength
            if oldLength > length then length = oldLength
            for i=0 to length - 1
                RoactUpdateElement(child, invalid, oldVNode.children[i], newVNode.children[i], offset + i)
            end for
            if newLength < oldLength
                child.removeChildrenIndex(oldLength-newLength, newLength)
            end if
        end if
    end if

    'If this is a Roact component that updated, trigger componentDidUpdate
    if didUpdate
        node.callFunc("roactComponentDidUpdate", prevPropsAndState)
    end if
end sub

sub RoactUpdateProps(el, oldProps, newProps)
    el.setFields(newProps)
end sub
