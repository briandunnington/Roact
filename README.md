# Roact - React for Roku
Like React.js, but for Roku

# Usage

Call `RoactRenderScene()` from your main.brs
(your scene really shouldnt do much of anything)


The key thing to know about this vs. normal React is:
In React, there are React Components and they eventually render DOM elements.
In Roact, the Roact Components contain the equivalent 'React Component' code *and* the equivalent DOM (SG component) code in the same file.




To create Roact Components:
-create SG component as normal, but extend `RoactComponent`
-dont add any children or fields via xml markup
-in your .brs file, you can implement any of these methods:

componentDidMount - will be called after your component has been fully created (including all children) and added to the visual tree. you can use `findNode` at this point if necessary

shouldComponentUpdate - can return false to short-circuit rendering. if you do not implement this, it will always return true

render - must return a single virtual node (h)

You can also handle the onKeyEvent() method as usual. In reaction to user input or any time you want to modify the state of a component, set the setState field with the updated fields:

m.top.setState = {changedProperty: newValue}

Just like with React, you only have to specify the state properties that changed.


# Lifecycle method mapping

Roact provides a subset of the full React lifecycle methods. In most cases, the methods that are provided are the same, but there are a few differences:

constructor > `init()`
componentWillMount > NOT SUPPORTED
render > `render()`
componentDidMount > `componentDidMount()`
componentWillReceiveProps > NOT SUPPORTED
shouldComponentUpdate > `shouldComponentUpdate()`
componentWillUpdate > NOT SUPPORTED
componentDidUpdate > NOT SUPPORTED
componentWillUnmount > NOT SUPPORTED
componentDidCatch > NOT SUPPORTED

# Files

source/Roact.brs - contains all of the Roact runtime functions
components/RoactComponent.xml & components/RoactComponent.brs - base class for Roact components

# What about JSX

Since BrightScript does not have a large community of tools, there is nothing similar to Babel or other JSX transpilers. While it would theoretically be possible to write such a tool, it is outside the scope of this framework.

Essentially, Roact is like [using React without JSX](https://reactjs.org/docs/react-without-jsx.html)

