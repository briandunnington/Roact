function h(elementType, props = invalid, children = invalid)
    if props = invalid then props = {}
    if children = invalid then children = []
    return {
        type: elementType,
        props: props,
        children: children
    }
end function

function createElement(vNode)
    if vNode = invalid then return invalid

    if m.mounting = invalid then m.mounting = []

    el = CreateObject("roSGNode", vNode.type)
    if el.hasField("roact")
        m.mounting.push(el)
        if vNode.props.id <> invalid then el.id = vNode.props.id
        el.props = vNode.props
        el.children = vNode.children
        child = createElement(el.callFunc("conditionalRender", invalid))
        if child <> invalid then el.appendChild(child)
    else
        el.setFields(vNode.props)
        for i=0 to vNode.children.count() - 1
            child = createElement(vNode.children[i])
            if child <> invalid then el.appendChild(child)
        end for
    end if
    return el
end function

sub fireComponentDidMount()
    if m.mounting <> invalid
        for i=0 to m.mounting.count() -1
            el = m.mounting[i]
?"@@@@@@@@@@@@@@@@", el.id, el.roact
            el.callFunc("componentDidMount", invalid)
        end for
    end if
    m.mounting = invalid
end sub

sub updateElement(parent, oldVNode, newVNode, index = 0)
    if oldVNode = invalid                       '1. Node did not previously exist
?"1111111111111"
        child = createElement(newVNode)
        if child <> invalid
            parent.appendChild(child)
            fireComponentDidMount()
        end if
    else if newVNode = invalid                  '2. Node no longer exists
?"2222222222222"
        parent.removeChildIndex(index)
    else if newVNode.type <> oldVNode.type      '3. Node type changed
?"3333333333333"
        child = createElement(newVNode)
        if child <> invalid
            parent.replaceChild(child, index)
            fireComponentDidMount()
        end if
    else                                        '4. Node is the same - compare children
?"4444444444444", newVNode.type
        child = parent.getChild(index)
        updateProps(child, oldVNode.props, newVNode.props)
        newLength = newVNode.children.count()
        oldLength = oldVNode.children.count()
        length = newLength
        if oldLength > length then length = oldLength
        for i=0 to oldLength - 1
            updateElement(child, oldVNode.children[i], newVNode.children[i], i)
        end for
    end if
end sub

sub updateProps(el, oldProps, newProps)
    'el.setFields(newProps)
    combined = {}
    combined.append(oldProps)
    combined.append(newProps)
    for each prop in combined
        updateProp(el, prop, oldProps[prop], newProps[prop])
    end for
end sub

sub updateProp(el, propName, oldValue, newValue)
    if newValue <> oldValue
?"CHANGED prop:", propName, newValue, oldValue
        el.setField(propName, newValue)
    else
?"unchanged prop:", propName, oldValue
    end if
end sub

sub renderSGOM(scene, vNode)
    m.port = CreateObject("roMessagePort")
    updateElement(scene, invalid, vNode, 0)

    while(true)
        msg = wait(10, m.port)
        if msg <> invalid
            msgType = type(msg)
            if msgType = "roSGNodeEvent"
                element = msg.getRoSGNode()
                id = element.id
                component = m[id]
                component.props.append(msg.getData())
                oldVNode = component.oldVNode
                vNode = component.render()
                component.oldVNode = vNode
                updateElement(element, oldVNode, vNode, 0)
            end if
        end if
    end while
end sub
