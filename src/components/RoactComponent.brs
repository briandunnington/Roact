sub init()
?"init init init"
end sub

function onKeyEvent(key, press)
?key, press

' ?m.global

' gaa = GetGlobalAA()
' ?"GAA", gaa
' return gaa.apple(key, press)

if press and key = "down"
?m.top.id
m.top.setProps = {proppy: "test val"}
end if
    return true
end function
