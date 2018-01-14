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

    'Get any necessary device info
    di = CreateObject("roDeviceInfo")
    ' setting port for device info events
    di.SetMessagePort(port)
    ' turning on event for network connectivity
    di.EnableLinkStatusEvent(true)

    clientId = di.GetClientTrackingId()
    country = di.getCountryCode()
    locale = di.getCurrentLocale().replace("_", "-")

    ' 'Register the initial app state
    ' initialState = {
    '     settings: {
    '         proxy: proxy,
    '         apiBaseUrl: apiBaseUrl,
    '         apiAccessToken: apiAccessToken,
    '         country: country,
    '         locale: locale,
    '         applicationId: apiApplicationId
    '     },
    '     data: {
    '         noNetwork: false,
    '         showLegal: false,
    '         legalSection: "privacy",
    '         showWhereToFind: false,
    '         hasWatchedFirstRunVideo: hasWatchedFirstRunVideo
    '     },
    '     deeplink: {
    '         mediaType: mediaType,
    '         contentId: contentId
    '     }
    ' }
    ' RedokuSetInitialState(initialState, screen)

    'Show the main scene.
    'NOTE: try to do as little work as possible before this line
    'you want to show the app as fast as possible and funnel any changes through the normal state-changed mechanism.
    'the only things you should do before this line are things that are absolutely required in order to render the initial view
    '(examples *might* include reading manifest values or device info. try *not* to do network calls or heavy processing)
    screen.show()

'     GetGlobalAA().apple = function(key, press)
' ?"APPLE"
' return false
'     end function

'     ?GetGlobalAA()

    ' x = h("App", {prop1: "prop one"}, [
    '         h("Rectangle", {id: "rect", color: "0xff0000", width: 600, height: 400}, [
    '             h(C1, {proppy: "proppy"})
    '         ])
    '     ])
    x = h("App", {id: "app", lblText: "INITIAL ROACT TEXT"})
    RoactRenderScene(scene, x)

    'everything else can be done after the initial scene is shown.


    while(true)
        msg = wait(10, port)
        if msg <> invalid
            msgType = type(msg)

            ' checking for internet connectivity
            if msgType = "roDeviceInfoEvent"
                if msg.isStatusMessage()
                    msgInfo = msg.GetInfo()
                    if msgInfo.linkStatus = false
                        ShowNetworkError()
                    end if
                end if
            end if
            
            if msgType = "roSGScreenEvent"
                'If the screen has been closed, shutdown and exit the app
                if msg.isScreenClosed()
                    return
                end if
            else
                ProcessAnalytics(msg, port, defaultAnalyticsValues, proxy)
            end if
        end if
    end while
end sub
