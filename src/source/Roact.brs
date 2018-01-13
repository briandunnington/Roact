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
?"CREATED:", vNode.type
    el = CreateObject("roSGNode", vNode.type)
    el.setFields(vNode.props)
    for i=0 to vNode.children.count() - 1
        el.appendChild(createElement(vNode.children[i]))
    end for
    return el
end function

sub updateElement(parent, oldVNode, newVNode, index = 0)
    if oldVNode = invalid                       '1. Node did not previous exist
        parent.appendChild(createElement(newVNode))
    else if newVNode = invalid                  '2. Node no longer exists
        parent.removeChildIndex(index)
    else if newVNode.type <> oldVNode.type      '3. Node type changed
        parent.replaceChild(createElement(newVNode), index)
    else                                        '4. Node is the same - compare children
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
?"CHANGED prop:", propName, newValue
        el.setField(propName, newValue)
    else
?"unchanged prop:", propName, oldValue
    end if
end sub
