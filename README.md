<h1><img src="./src/assets/roact-logo2.png" width=40/> Roact - React for Roku</h1>

Like React.js, but for Roku

# Usage

Call `RoactRenderScene()` from your Scene's `init()` method
(your scene really shouldnt do much of anything else)


The key thing to know about this vs. normal React is:
- In React, there are React Components and they eventually render DOM elements.
- In Roact, the Roact Components contain the equivalent 'React Component' code *and* the equivalent DOM (SG component) code in the same file.

To create Roact Components:
- create SG component as normal, but extend `RoactComponent`
- dont add any children or fields via xml markup
- in your .brs file, you can implement any of these methods:

`componentDidMount` - will be called after your component has been fully created (including all children) and added to the visual tree. you can use `findNode` at this point if necessary

`shouldComponentUpdate` - can return false to short-circuit rendering. if you do not implement this, it will always return true

`render` - must return a single virtual node (h)

You can also handle the `onKeyEvent()` method as usual. In reaction to user input or any time you want to modify the state of a component, call the `setState()` field with the updated fields:

`setState({changedProperty: newValue})`

Just like with React, you only have to specify the state properties that changed.

# Passing functions as props

Components should be self-contained and not have intrinsic knowledge about their parents. However, there is often a need for an action in a child component to trigger something in the parent. In React, this is done by passing functions as part of the props that get sent to the child. Since Scene Graph components do not allow setting function fields, functions cannot be passed directly in the same way. However, there is an equivalent mechanism:

In your parent component define a function field:

    <interface>
        <function name="handleSquareClick"/>
    </interface>

To pass this to a child component:

    clickHandler = createHandler("handleSquareClick")
    return h("Square", {onClick: clickHandler})

To execute the function from the child component:

    sub buttonClicked()
        props = m.top.props
        executeHandler(props.onClick, {index: props.index})
    end sub

Since the function is a normal SG node function field, it can take one arbitrary argument.


# Lifecycle method mapping

Roact provides a subset of the full React lifecycle methods. In most cases, the methods that are provided are the same, but there are a few differences:

    constructor > `init()`
    componentDidMount > `componentDidMount()`
    shouldComponentUpdate > `shouldComponentUpdate()`
    render > `render()`

The other React lifecycle methods have either been deprecated by React in recent versions, or are generally not applicable to Roku development.

# Mixing-and-matching normal SG nodes

Roact lets you mix and match Roact components with normal SG components, just like you can mix and match React components and normal DOM components. Simply specify the normal component name as the `type` passed to `h()` and specify the field values as the `props`. NOTE: some normal SG components intrinsicly create their own children. Roact can handle this and allows you to specify additional Roact-style children as well, but if the SG component dynamically changes the number or order of its children, you may encounter issues.

    'Button is a normal SG component that intrinsicly creates its own children
    h("Button", {
        text: "button text"
        textColor: "0xff0000"
    }, [
        'CustomComponent can still be added as an _additional_ child to Button
        h("CustomComponent", {
            blink: true
        })
    ])

# Roact + Redoku = 💖

Just like Redux works great with React, [Redoku](https://github.com/briandunnington/Redoku) works great with Roact. The easiest way to use them together is to make your Roact components inherit from `ConnectedComponent` instead of `RoactComponent`. That provides two benefits:

1. It provides a `mapState()` function that you can use to map Redoku global state to your component's local state (similar to `mapStateToProps` in Redux, but the global state is mapped to `state` instead of `props`). `mapState()` takes a single argument, which is a function with this signature: `function(state, prevState)` - use the incoming Redoku `state` (and `prevState`, if desired) and return an associative array that will be used to update your component's local state.
When you use `mapState()`, it takes care of observing the Redoku state for you so you do not need to do:
`m.global.observeField("state", "stateChanged")`
2. Provides an optimized default implementation of `shouldComponentUpdate()` - this will cause your component to only re-render when when `mapState()` has updated your state. 

# Files

- `source/Roact.brs` - contains all of the Roact runtime functions
- `components/RoactComponent.xml` & `components/RoactComponent.brs` - base class for Roact components
- `components/ConnectedComponent.xml` & `components/ConnectedComponent.brs` - base class for Redoku-aware Roact components

# What about JSX

Since BrightScript does not have a large community of tools, there is nothing similar to Babel or other JSX transpilers. While it would theoretically be possible to write such a tool, it is outside the scope of this framework.

Essentially, Roact is like [using React without JSX](https://reactjs.org/docs/react-without-jsx.html)
