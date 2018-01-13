function h(elementTypeOrComponent, props = invalid, children = invalid)
    elementType = invalid
    component = invalid
    if type(elementTypeOrComponent) = "Function"
        component = elementTypeOrComponent
        elementType = component().type
    else
        elementType = elementTypeOrComponent
    end if
    if props = invalid then props = {}
    if children = invalid then children = []
    return {
        type: elementType,
        component: component,
        props: props,
        children: children
    }
end function

function createElement(vNode)
    if vNode.component <> invalid
?"FROM COMPONENT"
        component = vNode.component()
        id = component.type + Str(Rnd(0))
        m[id] = component
        component.props = vNode.props
        component.children = vNode.children
        vNode = component.render()
        component.oldVNode = vNode
        el = CreateObject("roSGNode", "RoactComponent")' component.type)
        el.id = id
        el.observeField("setProps", m.port)
        el.appendChild(createElement(vNode))
        'el.getChild(0).setFocus(true)
        return el
    else
?"CREATED:", vNode.type
        el = CreateObject("roSGNode", vNode.type)
        el.setFields(vNode.props)
        for i=0 to vNode.children.count() - 1
            el.appendChild(createElement(vNode.children[i]))
        end for
        return el
    end if
end function

sub updateElement(parent, oldVNode, newVNode, index = 0)
    if oldVNode = invalid                       '1. Node did not previously exist
?"1111111111111"
        parent.appendChild(createElement(newVNode))
    else if newVNode = invalid                  '2. Node no longer exists
?"2222222222222"
        parent.removeChildIndex(index)
    else if newVNode.type <> oldVNode.type      '3. Node type changed
        parent.replaceChild(createElement(newVNode), index)
'TODO: component to component comparison
'ALSO: update component.children
?"3333333333333"
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
