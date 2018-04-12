Library "v30/bslCore.brs"

function Main(args as Dynamic) as void
?"_________________________________________________________"
?"     ____                  _                             "
?"    |  _ \ ___   __ _  ___| |_                           "
?"    | |_) / _ \ / _` |/ __| __|                          "
?"    |  _ < (_) | (_| | (__| |_                           "
?"    |_| \_\___/ \__,_|\___|\__|                          "
?"_________________________________________________________"
    showHomeScreen(args)
end function

sub showHomeScreen(args as dynamic)
    'Create the main screen, port, and scene
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.setMessagePort(port)
    scene = screen.CreateScene("RootScene")

    'Read args
    reset = args.reset
    proxy = args.proxy
    mediaType = args.mediaType
    contentId = args.contentId

    'Allow manual reset of app from deep link
    if reset <> invalid
        ResetStorage()
        ?"APP STATE RESET"
    end if

    if proxy <> invalid
        ?"NOTE: Requests will be proxied through " + proxy
    end if

    'Read manifest values
    appInfo = CreateObject("roAppInfo")
    appVersion = appInfo.getVersion()

    initialState = {
        all: {
            items: []
            filter: "ALL"
        }
    }

    RedokuSetInitialState(initialState, screen)

    'Show the main scene.
    'NOTE: try to do as little work as possible before this line
    'you want to show the app as fast as possible and funnel any changes through the normal state-changed mechanism.
    'the only things you should do before this line are things that are absolutely required in order to render the initial view
    '(examples *might* include reading manifest values or device info. try *not* to do network calls or heavy processing)
    screen.show()

    'everything else can be done after the initial scene is shown.

    while(true)
        msg = wait(10, port)
        if msg <> invalid
            msgType = type(msg)
            if msgType = "roSGScreenEvent"
                'If the screen has been closed, shutdown and exit the app
                if msg.isScreenClosed()
                    return
                end if
            end if
        end if
    end while
end sub
