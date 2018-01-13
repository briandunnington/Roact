sub LoadData()
    state = m.global.state
    settings = state.settings
    createPromiseFromTask("GetDataTask", {
        input: {
            proxy: settings.proxy,
            url: settings.apiBaseUrl,
            accessToken: settings.apiAccessToken,
            country: settings.country,
            locale: settings.locale,
            applicationId: settings.applicationId
        }
    }, "output").then(function(task)
        RedokuDispatch({
            type: "DATA_LOADED",
            data: task.output
        })
    end function)
end sub

sub ShowFirstRunVideo(videoItem)
    ShowPlayer(videoItem)
    createPromiseFromTask("HasWatchedFirstRunVideoTask", invalid, "output").then(function(task)
    end function)
end sub

sub ShowPlayer(videoItem)
    RedokuDispatch({
        type: "TOGGLE_PLAYER",
        videoItem: videoItem
    })
end sub

sub HidePlayer()
    RedokuDispatch({
        type: "TOGGLE_PLAYER",
        videoItem: invalid
    })
end sub

sub ShowLegal()
    RedokuDispatch({
        type: "TOGGLE_LEGAL"
        showLegal: true
    })
end sub

sub ShowNetworkError()
    RedokuDispatch({
        type: "NETWORK_ERROR"
    })
end sub

sub HideLegal()
    RedokuDispatch({
        type: "TOGGLE_LEGAL",
        showLegal: false
    })
end sub

sub ChangeLegalSection(legalSection)
    RedokuDispatch({
        type: "CHANGE_LEGAL_SECTION",
        legalSection: legalSection
    })
end sub

sub ShowWhereToFind()
    RedokuDispatch({
        type: "TOGGLE_WHERETOFIND"
        showWhereToFind: true
    })
end sub

sub HideWhereToFind()
    RedokuDispatch({
        type: "TOGGLE_WHERETOFIND",
        showWhereToFind: false
    })
end sub
