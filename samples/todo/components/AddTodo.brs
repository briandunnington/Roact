sub init()
    m.top.observeField("focusedChild", "focusChanged")
end sub

sub focusChanged()
    if m.top.hasFocus()
        m.input.setFocus(true)
    end if

    m.input.active = m.input.hasFocus()
end sub

sub componentDidMount(p)
    m.input = m.top.findNode("input")
end sub

function render(p)
    return h("TextEditBox", {id: "input", hintText: "add todo..."})
end function

function onKeyEvent(key, press)
    if press
        if key = "OK" AND m.input.text <> ""
            AddTodo(m.input.text)
            m.input.text = ""
        else if key =  "play"
            autoFillRandomTodo()
        end if
    end if
    return false
end function


















































function getRandomTodo()
    list = []
    list.push("Go to the grocery store")
    'list.push("Get milk")
    list.push("Walk the dog")
    list.push("Solve world hunger")
    list.push("Demo Roact to the team")
    list.push("Get a haircut")
    'list.push("Send flowers")
    list.push("Schedule secret meeting")
    list.push("Catch the train")
    list.push("File my taxes")
    list.push("Learn something new")
    list.push("Get a hug from Miles")
    'if m.r = invalid then m.r = Rnd(list.count()) - 1 else m.r = m.r + 1
    if m.r = invalid then m.r = 0 else m.r = m.r + 1
    if m.r >= list.count() then m.r = 0
    return list[m.r]
end function

sub autoFillRandomTodo()
    m.input.text = ""
    m.text = getRandomTodo()
    if m.timer = invalid
        m.timer = CreateObject("roSGNode", "Timer")
        m.timer.duration = 0.1
        m.timer.observeField("fire", "appendLetter")
    end if
    m.timer.control = "start"
end sub

sub appendLetter()
    m.input.text = m.input.text + m.text.left(1)
    if m.text.len() > 1
        m.text = m.text.mid(1)
        m.timer.control = "start"
    end if
end sub
