'These functions all access the registry and as such can only be called
'from BrightScript context or a Task node.

function GetHasWatchedFirstRunVideo()
    return _GetValueFromStorage("hasWatchedFirstRunVideo")
end function

sub SaveHasWatchedFirstRunVideo()
    _SaveValueToStorage("hasWatchedFirstRunVideo", "true")
end sub

sub ClearHasWatchedFirstRunVideo()
    _ClearValueFromStorage("hasWatchedFirstRunVideo")
end sub

sub ResetStorage()
    _ClearAllFromStorage()
end sub

'-------------------------------------------------------------------------------

function _GetValueFromStorage(key)
    sec = CreateObject("roRegistrySection", "default")
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return invalid
end function

sub _SaveValueToStorage(key, value)
    sec = CreateObject("roRegistrySection", "default")
    sec.Write(key, value)
    sec.Flush()
end sub

sub _ClearValueFromStorage(key)
    sec = CreateObject("roRegistrySection", "default")
    if sec.Exists(key)
        sec.Delete(key)
        sec.Flush()
    end if
end sub

sub _ClearAllFromStorage()
    reg = CreateObject("roRegistry")
    reg.Delete("default")
    reg.Flush()
end sub
