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

'-----------------------------------------------------------------
'Everything below here is a 'private' function only used by Roact
'internally. Do not call these functions directly.
'-----------------------------------------------------------------

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

















' OLD STUFF - SAVE FOR NOW

' sub RoactUpdateProps(el, oldProps, newProps)
'     combined = {}
'     combined.append(oldProps)
'     combined.append(newProps)
'     for each prop in combined
'         RoactUpdateProp(el, prop, oldProps[prop], newProps[prop])
'     end for
' end sub

' sub RoactUpdateProp(el, propName, oldValue, newValue)
'     if newValue <> oldValue        ' there is no good way to do a value check for non-primitive types (ex: arrays)
'         el.setField(propName, newValue)
'     else
'         ?"unchanged prop:", propName, oldValue
'     end if
' end sub


' sub printit(a, b, u)
'     spaces = "                                                                                                    "
'     pad = spaces.left(u * 4)
'     ?Substitute("{0}{1}: {2}", pad, a), b
' end sub

' function RoactCreateElement(vNode, u=0)
' t = CreateObject("roTimespan")
' printit("---------------------------------", invalid, u)
'     if vNode = invalid then return invalid
' printit("a", t.totalmilliseconds(), u)
'     if m.mounting = invalid then m.mounting = []
' printit("b", t.totalmilliseconds(), u)
' printit(vNode.type, invalid, u)
'     '?"CREATED NODE:", vNode.type
'     el = CreateObject("roSGNode", vNode.type)
' printit("c", t.totalmilliseconds(), u)
'     if el.roact <> invalid 'el.hasField("roact")
' printit("d", t.totalmilliseconds(), u)
'         m.mounting.push(el)
' printit("e", t.totalmilliseconds(), u)
' '         if vNode.props.id <> invalid then el.id = vNode.props.id
' ' ?"f", t.totalmilliseconds()
' '         el.props = vNode.props
' ' ?"g", t.totalmilliseconds()
' '         el.children = vNode.children
' el.setFields({
'     id: vNode.props.id
'     props: vNode.props
'     children: vNode.children
' })
' printit("h", t.totalmilliseconds(), u)
' yy = el.callFunc("conditionalRender", invalid)
' printit("hh", t.totalmilliseconds(), u)
'         child = RoactCreateElement(yy, u+1)
' printit("i", t.totalmilliseconds(), u)
'         if child <> invalid then el.appendChild(child)
' printit("j", t.totalmilliseconds(), u)
'     else
' printit("d0", t.totalmilliseconds(), u)
'         if vNode.props.count() > 0 then el.setFields(vNode.props)
' printit("d1", t.totalmilliseconds(), u)
'         for i=0 to vNode.children.count() - 1
'             child = RoactCreateElement(vNode.children[i], u+1)
' printit("e1", t.totalmilliseconds(), u)
'             if child <> invalid then el.appendChild(child)
' printit("f1", t.totalmilliseconds(), u)
'         end for
'     end if
' printit("x", t.totalmilliseconds(), u)
'     return el
' end function
