.quickshell_docs_raw/content/docs/_index.md
+++
title = 'Docs'
+++

{{< cards >}}
  {{< card link="./configuration" title="Configuration" >}}
  {{< card link="./types" title="Type Reference" >}}
{{< /cards >}}
.quickshell_docs_raw/content/docs/configuration/_index.md
+++
title = "Configuration"
+++

You should start with the [Introduction](./intro) which will guide you
through the basics of QML by creating a simple topbar with a clock.

From there you can read the [QML Overview](./qml-overview) to get an overview of
the QML language, or jump right into the [Type Reference](/docs/types) to find
types you can use in your shell.

The [quickshell-examples](https://git.outfoxxed.me/outfoxxed/quickshell-examples) repo contains
fully working example configurations you can read and modify.
.quickshell_docs_raw/content/docs/configuration/intro.md
+++
title = "Introduction"
+++

This page will walk you through the process of creating a simple bar/panel, and
introduce you to all the basic concepts involved.

There are many links to the [QML Overview](../qml-overview)
and [Type Reference](/docs/types) which you should follow if you don't
fully understand the concepts involved.

## Shell Files

Every quickshell instance starts from a shell root file, conventionally named `shell.qml`.
The default path is `~/.config/quickshell/shell.qml`.
(where `~/.config` can be substituted with `$XDG_CONFIG_HOME` if present.)

Each shell file starts with the shell root object. Only one may exist per configuration.

```qml {filename="~/.config/quickshell/shell.qml"}
import Quickshell

ShellRoot {
  // ...
}
```

The shell root is not a visual element but instead contains all of the visual
and non visual objects in your shell. You can have multiple different shells
with shared components and different shell roots.

{{% details title="Shell search paths and manifests" closed="true" %}}

Quickshell can be launched with configurations in locations other than the default one.

The `-p` or `--path` option will launch the shell root at the given path.
It will also accept folders with a `shell.qml` file in them.
It can also be specified via the `QS_CONFIG_PATH` environment variable.

The `-c` or `--config` option will launch a configuration from the current manifest,
or if no manifest is specified, a subfolder of quickshell's base path.
It can also be specified via the `QS_CONFIG_NAME` environment variable.

The base path defaults to `~/.config/quickshell`, but can be changed using
the `QS_BASE_PATH` environment variable.

The `-m` or `--manifest` option specifies the quickshell manifest to read configs
from. When used with `-c`, the config will be chosen by name from the manifest.
It can also be specified via the `QS_MANIFEST` environment variable.

The manifest path defaults to `~/.config/quickshell/manifest.conf` and is a list
of `name = path` pairs where path can be relative or absolute.
Lines starting with `#` are comments.

```properties
# ~/.config/quickshell/manifest.conf
myconf1 = myconf
myconf2 = ./myconf
myconf3 = myconf/shell.nix
myconf4 = ~/.config/quickshell/myconf
```

You can use `quickshell --current` to print the current values of any of these
options and what set them.

{{% /details %}}

## Creating Windows

Quickshell has two main window types available,
[PanelWindow](/docs/types/quickshell/panelwindow) for bars and widgets, and
[FloatingWindow](/docs/types/quickshell/floatingwindow) for standard desktop windows.

We'll start with an example:
```qml
import Quickshell // for ShellRoot and PanelWindow
import QtQuick // for Text

ShellRoot {
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }

    height: 30

    Text {
      // center the bar in its parent component (the window)
      anchors.centerIn: parent

      text: "hello world"
    }
  }
}
```

The above example creates a bar/panel on your currently focused monitor with
a centered piece of [text](https://doc.qt.io/qt-6/qml-qtquick-text.html). It will also reserve space for itself on your monitor.

More information about available properties is available in the [type reference](/docs/types/quickshell/panelwindow).

## Running a process

Now that we have a piece of text, what if it did something useful?
To start with lets make a clock. To get the time we'll use the `date` command.

We can use a [Process](/docs/types/quickshell.io/process) object to run commands
and return their results.

We'll listen to the [DataStreamParser.read](/docs/types/quickshell.io/datastreamparser/#signal.read)
[signal](/docs/configuration/qml-overview/#signals) emitted by
[SplitParser](/docs/types/quickshell.io/splitparser/) using a
[signal handler](/docs/configuration/qml-overview/#signal-handlers)
to update the text on the clock.

{{< callout type="info" >}}
Note: Quickshell live-reloads your code. You can leave it open and edit the
original file. The panel will reload when you save it.
{{< /callout >}}

```qml
import Quickshell
import Quickshell.Io // for Process
import QtQuick

ShellRoot {
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }

    height: 30

    Text {
      // give the text an ID we can refer to elsewhere in the file
      id: clock

      anchors.centerIn: parent

      // create a process management object
      Process {
        // the command it will run, every argument is its own string
        command: ["date"]

        // run the command immediately
        running: true

        // process the stdout stream using a SplitParser
        // which returns chunks of output after a delimiter
        stdout: SplitParser {
          // listen for the read signal, which returns the data that was read
          // from stdout, then write that data to the clock's text property
          onRead: data => clock.text = data
        }
      }
    }
  }
}
```

## Running code at an interval
With the above example, your bar should now display the time, but it isn't updating!
Let's use a [Timer](https://doc.qt.io/qt-6/qml-qtqml-timer.html) fix that.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }

    height: 30

    Text {
      id: clock
      anchors.centerIn: parent

      Process {
        // give the process object an id so we can talk
        // about it from the timer
        id: dateProc

        command: ["date"]
        running: true

        stdout: SplitParser {
          onRead: data => clock.text = data
        }
      }

      // use a timer to rerun the process at an interval
      Timer {
        // 1000 milliseconds is 1 second
        interval: 1000

        // start the timer immediately
        running: true

        // run the timer again when it ends
        repeat: true

        // when the timer is triggered, set the running property of the
        // process to true, which reruns it if stopped.
        onTriggered: dateProc.running = true
      }
    }
  }
}
```

## Reuseable components

If you have multiple monitors you might have noticed that your bar
is only on one of them. If not, you'll still want to **follow this section
to make sure your bar dosen't disappear if your monitor disconnects**.

We can use a [Variants](/docs/types/quickshell/variants)
object to create instances of *non widget items*.
(See [Repeater](https://doc.qt.io/qt-6/qml-qtquick-repeater.html) for doing
something similar with visual items.)

The `Variants` type creates instances of a
[Component](https://doc.qt.io/qt-6/qml-qtqml-component.html) based on a data model
you supply. (A component is a re-usable tree of objects.)

The most common use of `Variants` in a shell is to create instances of
a window (your bar) based on your monitor list (the data model).

Variants will inject the values in the data model into each new
component's `modelData` property, which means we can easily pass each screen
to its own component.
(See [Window.screen](/docs/types/quickshell/qswindow/#prop.screen).)

```qml
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens;

    delegate: Component {
      PanelWindow {
        // the screen from the screens list will be injected into this
        // property
        property var modelData

        // we can then set the window's screen to the injected property
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        height: 30

        Text {
          id: clock
          anchors.centerIn: parent

          Process {
            id: dateProc
            command: ["date"]
            running: true

            stdout: SplitParser {
              onRead: data => clock.text = data
            }
          }

          Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: dateProc.running = true
          }
        }
      }
    }
  }
}
```

<span class="small">See also:
[Property Bindings](/docs/configuration/qml-overview/#property-bindings),
[Variants.component](/docs/types/quickshell/variants/#prop.component),
[Quickshell.screens](/docs/types/quickshell/quickshell/#prop.screens),
[Array.map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map)
</span>

With this example, bars will be created and destroyed as you plug and unplug them,
due to the reactive nature of the
[Quickshell.screens](/docs/types/quickshell/quickshell/#prop.screens) property.
(See: [Reactive Bindings](/docs/configuration/qml-overview/#reactive-bindings).)

Now there's an important problem you might have noticed: when the window
is created multiple times we also make a new Process and Timer. We can fix
this by moving the Process and Timer outside of the window.

{{< callout type="error" >}}
This code will not work correctly.
{{< /callout >}}

```qml
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        property var modelData
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        height: 30

        Text {
          id: clock
          anchors.centerIn: parent
        }
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      onRead: data => clock.text = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

However there is a problem with naively moving the Process and Timer
out of the component.
*What about the `clock` that the process references?*

If you run the above example you'll see something like this in the console every second:

```
file:///home/name/.config/quickshell/shell.qml:33: ReferenceError: clock is not defined
file:///home/name/.config/quickshell/shell.qml:33: ReferenceError: clock is not defined
file:///home/name/.config/quickshell/shell.qml:33: ReferenceError: clock is not defined
file:///home/name/.config/quickshell/shell.qml:33: ReferenceError: clock is not defined
file:///home/name/.config/quickshell/shell.qml:33: ReferenceError: clock is not defined
```

This is because the `clock` object, even though it has an ID, cannot be referenced
outside of its component. Remember, components can be created *any number of times*,
including zero, so `clock` may not exist or there may be more than one, meaning
there isn't an object to refer to from here.

We can fix it with a [Property Definition](/docs/configuration/qml-overview/#property-definitions).

We can define a property inside of the ShellRoot and reference it from the clock
text instead. Due to QML's [Reactive Bindings](/docs/configuration/qml-overview/#reactive-bindings),
the clock text will be updated when we update the property for every clock that
currently exists.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
  id: root

  // add a property in the root
  property string time;

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        property var modelData
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        height: 30

        Text {
          // remove the id as we don't need it anymore

          anchors.centerIn: parent

          // bind the text to the root's time property
          text: root.time
        }
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      // update the property instead of the clock directly
      onRead: data => root.time = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

Now we've fixed the problem so there's nothing actually wrong with the
above code, but we can make it more concise:

1. `Component`s can be defined implicitly, meaning we can remove the
component wrapping the window and place the window directly into the
`delegate` property.
2. The [Variants.delegate](/docs/types/quickshell/variants/#prop.delegate)
property is a [Default Property](/docs/configuration/qml-overview/#the-default-property),
which means we can skip the `delegate: ` part of the assignment.
We're already using [ShellRoot](/docs/types/quickshell/shellroot/)'s
default property to store our Variants, Process, and Timer components
among other things.
3. The ShellRoot dosen't actually need an `id` property to talk about
the time property, as it is the outermost object in the file which
has [special scoping rules](/docs/configuration/qml-overview/#property-access-scopes).

This is what our shell looks like with the above (optional) cleanup:

```qml
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
  property string time;

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      height: 30

      Text {
        anchors.centerIn: parent

        // now just time instead of root.time
        text: time
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      // now just time instead of root.time
      onRead: data => time = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

## Multiple files

In an example as small as this, it isn't a problem, but as the shell
grows it might be prefferable to separate it into multiple files.

To start with, let's move the entire bar into a new file.
```qml {filename="shell.qml"}
import Quickshell

ShellRoot {
  Bar {}
}
```

```qml {filename="Bar.qml"}
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  property string time;

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      height: 30

      Text {
        anchors.centerIn: parent

        // now just time instead of root.time
        text: time
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      // now just time instead of root.time
      onRead: data => time = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```
<span class="small">See also: [Scope](/docs/types/quickshell/scope/)</span>

Any qml file that starts with an uppercase letter can be referenced this way.
We can bring in other folders as well using
[import statements](/docs/configuration/qml-overview/#explicit-imports).

Now what about breaking out the clock? This is a bit more complex because
the clock component in the bar, as well as the process and timer that
make up the actual clock, need to be dealt with.

To start with, we can move the clock widget to a new file. For now it's just a
single `Text` object but the same concepts apply regardless of complexity.

```qml {filename="ClockWidget.qml"}
import QtQuick

Text {
  // A property the creator of this type is required to set.
  // Note that we could just set `text` instead, but don't because your
  // clock probably will not be this simple.
  required property string time

  text: time
}
```

```qml {filename="Bar.qml"}
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string time;

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      height: 30

      // the ClockWidget type we just created
      ClockWidget {
        anchors.centerIn: parent
        // Warning: setting `time: time` will bind time to itself which is not what we want
        time: root.time
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      onRead: data => time = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

While this example is larger than what we had before, we can now expand
on the clock widget without cluttering the bar file.

Let's deal with the clock's update logic now:

```qml {filename="Time.qml"}
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  property string time;

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      onRead: data => time = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

```qml {filename="Bar.qml"}
import Quickshell

Scope {
  // the Time type we just created
  Time { id: timeSource }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      height: 30

      ClockWidget {
        anchors.centerIn: parent
        // now using the time from timeSource
        time: timeSource.time
      }
    }
  }
}
```

## Singletons

Now you might be thinking, why do we need the `Time` type in
our bar file, and the answer is we don't. We can make `Time`
a [Singleton](/docs/configuration/qml-overview/#singletons).

A singleton object has only one instance, and is accessible from
any scope.

```qml {filename="Time.qml"}
// with this line our type becomes a singleton
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
  property string time

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: SplitParser {
      onRead: data => time = data
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

```qml {filename="ClockWidget.qml"}
import QtQuick

Text {
  // we no longer need time as an input

  // directly access the time property from the Time singleton
  text: Time.time
}
```

```qml {filename="Bar.qml"}
import Quickshell

Scope {
  // no more time object

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      height: 30

      ClockWidget {
        anchors.centerIn: parent

        // no more time binding
      }
    }
  }
}
```

## JavaScript APIs

In addition to calling external processes, a [limited set of javascript interfaces] is available.
We can use this to improve our clock by using the [Date API] instead of calling `date`.

[limited set of javascript interfaces]: https://doc.qt.io/qt-6/qtqml-javascript-functionlist.html
[Date API]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date

```qml {filename="Time.qml"}
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  property var date: new Date()
  property string time: date.toLocaleString(Qt.locale())

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: date = new Date()
  }
}
```
.quickshell_docs_raw/content/docs/configuration/positioning.md
+++
title = "Positioning"
+++

QtQuick has multiple ways to position components. This page has instructions for where and how
to use them.

## Anchors
Anchors can be used to position components relative to another neighboring component.
It is faster than [manual positioning](#manual-positioning) and covers a lot of simple
use cases.

The [Qt Documentation: Positioning with Anchors](https://doc.qt.io/qt-6/qtquick-positioning-anchors.html)
page has comprehensive documentation of anchors.

## Layouts
Layouts are useful when you have many components that need to be positioned relative to
eachother such as a list.

The [Qt Documentation: Layouts Overview](https://doc.qt.io/qt-6/qtquicklayouts-overview.html)
page has good documentation of the basic layout types and how to use them.

Note: layouts by default have a nonzero spacing.

## Manual Positioning
If layouts and anchors can't easily fulfill your usecase, you can also manually position and size
components by setting their `x`, `y`, `width` and `height` properties, which are relative to
the parent component.

This example puts a 100x100px blue rectangle at x=20,y=40 in the parent item. Ensure the size
of the parent is large enough for its content or positioning based on them will break.
```qml
Item {
  // make sure the component is large enough to fit its children
  implicitWidth: childrenRect.width
  implicitHeight: childrenRect.height
  
  Rectangle {
    color: "blue"
    x: 20
    y: 40
    width: 100
    height: 100
  }
}
```

## Notes
### Component Size
The [Item.implicitHeight] and [Item.implicitWidth] properties control the *base size* of a
component, before layouts are applied. These properties are *not* the same as
[Item.height] and [Item.width] which are the final size of the component.
You should nearly always use the implicit size properties when creating a component,
however using the normal width and height properties is fine if you know an
item will never go in a layout.

[Item.height]: https://doc.qt.io/qt-6/qml-qtquick-item.html#height-prop
[Item.width]: https://doc.qt.io/qt-6/qml-qtquick-item.html#width-prop
[Item.implicitHeight]: https://doc.qt.io/qt-6/qml-qtquick-item.html#implicitHeight-prop
[Item.implicitWidth]: https://doc.qt.io/qt-6/qml-qtquick-item.html#implicitWidth-prop

This example component puts a colored rectangle behind some text, and will act the same
way in a layout as the text by itself.
```qml {filename="TextWithBkgColor.qml"}
Rectangle {
  implicitWidth: text.implicitWidth
  implicitHeight: text.implicitHeight
  
  Text {
    id: text
    text: "hello!"
  }
}
```

If you want to size your component based on multiple others or use any other math you can.
```qml {filename="PaddedTexts.qml"}
Item {
  // width of both texts plus 5
  implicitWidth: text1.implicitWidth + text2.implicitWidth + 5
  // max height of both texts plus 5
  implicitHeight: Math.min(text1.implicitHeight, text2.implicitHeight) + 5

  Text {
    id: text1
    text: "text1"
  }
  
  Text {
    id: text2
    anchors.left: text1.left
    text: "text2"
  }
}
```

### Coordinate space
You should always position or size components relative to the closest possible
parent. Often this is just the `parent` property.

Refrain from using things like the size of your screen to size a component,
as this will break as soon as anything up the component hierarchy changes, such
as adding padding to a bar.
.quickshell_docs_raw/content/docs/configuration/qml-overview.md
+++
title = "QML Overview"
+++

Quickshell is configured using the Qt Modeling Language, or QML.
This page explains what you need to know about QML to start using quickshell.

<span class="small">See also: [Qt Documentation: QML Tutorial](https://doc.qt.io/qt-6/qml-tutorial.html)</span>

## Structure
Below is a QML document showing most of the syntax.
Keep it in mind as you read the detailed descriptions below.

Notes:
- Semicolons are permitted basically everywhere, and recommended in
functions and expressions.
- While types can often be elided, we recommend you use them where
possible to catch problems early instead of running into them unexpectedly later on.

```qml
// QML Import statement
import QtQuick 6.0

// Javascript import statement
import "myjs.js" as MyJs

// Root Object
Item {
  // Id assignment

  id: root
  // Property declaration
  property int myProp: 5;

  // Property binding
  width: 100

  // Property binding
  height: width

  // Multiline property binding
  prop: {
    // ...
    5
  }

  // Object assigned to a property
  objProp: Object {
    // ...
  }

  // Object assigned to the parent's default property
  AnotherObject {
    // ...
  }

  // Signal declaration
  signal foo(bar: int)

  // Signal handler
  onSignal: console.log("received signal!")

  // Property change signal handler
  onWidthChanged: console.log(`width is now ${width}!`)

  // Multiline signal handler
  onOtherSignal: {
    console.log("received other signal!");
    console.log(`5 * 2 is ${dub(5)}`);
    // ...
  }

  // Attached property signal handler
  Component.onCompleted: MyJs.myfunction()

  // Function
  function dub(x: int): int {
    return x * 2
  }
}
```
### Imports

#### Explicit imports
Every QML File begins with a list of imports.
Import statements tell the QML engine where
to look for types you can create [objects](#objects) from.

A module import statement looks like this:
```qml
import <Module> [Major.Minor] [as <Namespace>]
```

- `Module` is the name of the module you want to import, such as `QtQuick`.
- `Major.Minor` is the version of the module you want to import.
- `Namespace` is an optional namespace to import types from the module under.

A subfolder import statement looks like this:
```qml
import "<directory>" [as <Namespace>]
```

- `directory` is the directory to import, relative to the current file.
- `Namespace` is an optional namespace to import types from the folder under.

A javascript import statement looks like this:
```qml
import "<filename>" as <Namespace>
```

- `filename` is the name of the javascript file to import.
- `Namespace` is the namespace functions and variables from the javascript
file will be made available under.

Note: All *Module* and *Namespace* names must start with an uppercase letter.
Attempting to use a lowercase namespace is an error.

##### Examples
```qml
import QtQuick
import QtQuick.Controls 6.0
import Quickshell as QS
import QtQuick.Layouts 6.0 as L
import "jsfile.js" as JsFile
```

{{% details title="When to use versions" closed="true" %}}

By default, when no module version is requested, the QML engine will pick
the latest available version of the module. Requesting a specific version
can help ensure you get a specific version of the module's types, and as a
result your code dosen't break across Qt or quickshell updates.

While Qt's types usually don't majorly change across versions, quickshell's
are much more likely to break. To put off dealing with the breakage we suggest
specifying a version at least when importing quickshell modules.

{{% /details %}}

<span class="small">[Qt Documentation: Import syntax](https://doc.qt.io/qt-6/qtqml-syntax-imports.html)</span>

#### Implicit imports

The QML engine will automatically import any [types](#creating-types) in neighboring files
with names that start with an uppercase letter.

```
root
|-MyButton.qml
|-shell.qml
```

In this example, `MyButton` will automatically be imported as a type usable from shell.qml
or any other neighboring files.

### Objects

Objects are instances of a type from an imported module.
The name of an object must start with an uppercase letter.
This will always distinguish an object from a property.

An object looks like this:
```qml
Name {
  id: foo
  // properties, functions, signals, etc...
}
```

Every object can contain [properties](#properties), [functions](#functions),
and [signals](#signals). You can find out what properties are available for a type
by looking it up in the [Type Reference](/docs/types/).

#### Properties

Every object may have any number of property assignments (only one per specific property).
Each assignment binds the named property to the given expression.

##### Property bindings

Expressions are snippets of javascript code assigned to a property. The last (or only) line
can be the return value, or an explicit return statement (multiline expressions only) can be used.

```qml
Item {
  // simple expression
  property: 5

  // complex expression
  property: 5 * 20 + this.otherProperty

  // multiline expression
  property: {
    const foo = 5;
    const bar = 10;
    foo * bar
  }

  // multiline expression with return
  property: {
    // ...
    return 5;
  }
}
```

Semicolons are optional and allowed on any line of a single or multiline expression,
including the last line.

All property bindings are [*reactive*](#reactive-bindings), which means when any property the expression depends
on is updated, the expression is re-evaluated and the property is updated.

<span class="small">See: [Reactive bindings](#reactive-bindings)</span>

Note that it is an error to try to assign to a property that does not exist.
(See: [property definitions](#property-definitions))

##### Property definitions

Properties can be defined inside of objects with the following syntax:
```qml
[required] [readonly] [default] property <type> <name>[: binding]
```

- `required` forces users of this type to assign this property. See [Creating Types](#creating-types) for details.
- `readonly` makes the property not assignable. Its binding will still be [reactive](#reactive-bindings).
- `default` makes the property the [default property](#the-default-property) of this type.
- `type` is the type of the property. You can use `var` if you don't know or don't care but be aware that `var` will
allow any value type.
- `name` is the name that the property is known as. It cannot start with an uppercase letter.
- `binding` is the property binding. See [Property bindings](#property-bindings) for details.

```qml
Item {
  // normal property
  property int foo: 3

  // readonly property
  readonly property string bar: "hi!"

  // bound property
  property var things: [ "foo", "bar" ]
}
```

Defining a property with the same name as one provided by the current object will override
the property of the type it is derived from in the current context.

##### The default property

Types can have a *default property* which must accept either an object or a list of objects.

The default property will allow you to assign a value to it without using the name of the property:
```qml
Item {
  // normal property
  foo: 3

  // this item is assigned to the outer object's default property
  Item {
  }
}
```

If the default property is a list, you can put multiple objects into it the same way as you
would put a single object in:
```qml
Item {
  // normal property
  foo: 3

  // this item is assigned to the outer object's default property
  Item {
  }

  // this one is too
  Item {
  }
}
```

##### The `id` property

Every object has a special property called `id` that can be assigned to give
the object a name it can be referred to throughout the current file. The id must be lowercase.

```qml
ColumnLayout {
  Text {
    id: text
    text: "Hello World!"
  }

  Button {
    text: "Make the text red";
    onClicked: text.color = "red";
  }
}
```

{{% details title="The `id` property compared to normal properties" closed="true" %}}

The `id` property isn't really a property, and dosen't do anything other than
expose the object to the current file. It is only called a property because it
uses very similar syntax to one, and is the only exception to standard property
definition rules. The name `id` is always reserved for the id property.

{{% /details %}}

##### Property access scopes

Properties are "in scope" and usable in two cases.
1. They are defined for current type.
2. They are defined for the root type in the current file.

You can access the properties of any object by setting its [id property](#the-id-property),
or make sure the property you are accessing is from the current object using `this`.

The `parent` property is also defined for all objects, but may not always point to what it
looks like it should. Use the `id` property if `parent` does not do what you want.

```qml
Item {
  property string rootDefinition

  Item {
    id: mid
    property string midDefinition

    Text {
      property string innerDefinition

      // legal - innerDefinition is defined on the current object
      text: innerDefinition

      // legal - innerDefinition is accessed via `this` to refer to the current object
      text: this.innerDefinition

      // legal - width is defined for Text
      text: width

      // legal - rootDefinition is defined on the root object
      text: rootDefinition

      // illegal - midDefinition is not defined on the root or current object
      text: midDefinition

      // legal - midDefinition is accessed via `mid`'s id.
      text: mid.midDefinition

      // legal - midDefinition is accessed via `parent`
      text: parent.midDefinition
    }
  }
}
```

<span class="small">[Qt Documentation: Scope and Naming Resolution](https://doc.qt.io/qt-6/qtqml-documents-scope.html)</span>

#### Functions

Functions in QML can be declared everywhere [properties](#properties) can, and follow
the same [scoping rules](#property-access-scopes).

Function definition syntax:
```qml
function <name>(<paramname>[: <type>][, ...])[: returntype] {
  // multiline expression (note that `return` is required)
}
```

Functions can be invoked in expressions. Expression reactivity carries through
functions, meaning if one of the properties a function depends on is re-evaluated,
every expression depending on the function is also re-evaluated.

```qml
ColumnLayout {
  property int clicks: 0

  function makeClicksLabel(): string {
    return "the button has been clicked " + clicks + " times!";
  }

  Button {
    text: "click me"
    onClicked: clicks += 1
  }

  Text {
    text: makeClicksLabel()
  }
}
```

In this example, every time the button is clicked, the label's count increases
by one, as `clicks` is changed, which triggers a re-evaluation of `text` through
`makeClicksLabel`.

##### Lambdas

Functions can also be values, and you can assign them to properties or pass them to
other functions (callbacks). There is a shorter way to write these functions, known
as lambdas.

Lambda syntax:
```qml
<params> => <expression>

// params can take the following forms:
() => ... // 0 parameters
<name> => ... // 1 parameter
(<name>[, ...]) => ... // 1+ parameters

// the expression can be either a single or multiline expression.
... => <result>
... => {
  return <result>;
}
```

Assigning functions to properties:
```qml
Item {
  // using functions
  function dub(number: int): int { return number * 2; }
  property var operation: dub

  // using lambdas
  property var operation: number => number * 2
}
```

An overcomplicated click counter using a lambda callback:
```qml
ColumnLayout {
  property int clicks: 0

  function incrementAndCall(callback) {
    clicks += 1;
    callback(clicks);
  }

  Button {
    text: "click me"
    onClicked: incrementAndCall(clicks => {
        label.text = `the button was clicked ${clicks} time(s)!`;
    })
  }

  Text {
    id: label
    text: "the button has not been clicked"
  }
}
```

#### Signals
A signal is basically an event emitter you can connect to and receive updates from.
They can be declared everywhere [properties](#properties) and [functions](#functions)
can, and follow the same [scoping rules](#property-access-scopes).

<span class="small">[Qt Documentation: Signal and Handler Event System](https://doc.qt.io/qt-6/qtqml-syntax-signals.html)</span>

##### Signal definitions

A signal can be explicitly defined with the following syntax:
```qml
signal <name>(<paramname>: <type>[, ...])
```

##### Making connections
Signals all have a `connect(<function>)` method which invokes the given function
or signal when the signal is emitted.

```qml
ColumnLayout {
  property int clicks: 0

  function updateText() {
    clicks += 1;
    label.text = `the button has been clicked ${clicks} times!`;
  }

  Button {
    id: button
    text: "click me"
  }

  Text {
    id: label
    text: "the button has not been clicked"
  }

  Component.onCompleted: {
    button.clicked.connect(updateText)
  }
}
```

<span class="small">`Component.onCompleted` will be addressed later
in [Attached Properties](#attached-properties) but for now just know that
it runs immediately once the object is fully initialized.</span>

When the button is clicked, the button emits the `clicked` signal which we connected to
`updateText`. The signal then invokes `updateText` which updates the counter and the
text on the label.

##### Signal handlers
Signal handlers are a more concise way to make a connections, and prior examples have used them.

When creating an object, for every signal present on its type there is a corrosponding `on<Signal>`
property implicitly defined which can be set to a function. (Note that the first letter of the
signal's name it capitalized.)

Below is the same example as in [Making Connections](#making-connections),
this time using the implicit signal handler property to handle `button.clicked`.

```qml
ColumnLayout {
  property int clicks: 0

  function updateText() {
    clicks += 1;
    label.text = `the button has been clicked ${clicks} times!`;
  }

  Button {
    text: "click me"
    onClicked: updateText()
  }

  Text {
    id: label
    text: "the button has not been clicked"
  }
}
```

##### Indirect signal handlers
When it is not possible or not convenient to directly define a signal handler, before resorting
to `.connect`ing the properties, a [Connections] object can be used to access them.

This is especially useful to connect to signals of singletons.

```qml
Item {
  Button {
    id: myButton
    text "click me"
  }

  Connections {
    target: myButton

    function onClicked() {
      // ...
    }
  }
}
```

##### Property change signals
Every property has an associated signal, which powers QML's [reactive bindings](#reactive-bindings).
The signal is named `<propertyname>Changed` and works exactly the same as any other signal.

Whenever the property is re-evaluated, its change signal is emitted. This is used internally
to update dependent properties, but can be directly used, usually with a signal handler.

```qml
ColumnLayout {
  CheckBox {
    text: "check me"

    onCheckStateChanged: {
      label.text = labelText(checkState == Qt.Checked);
    }
  }

  Text {
    id: label
    text: labelText(false)
  }

  function labelText(checked): string {
    return `the checkbox is checked: ${checked}`;
  }
}
```

In this example we listen for the `checkState` property of the CheckBox changing
using its change signal, `checkStateChanged` with the signal handler `onCheckStateChanged`.

Since text is also a property we can do the same thing more concisely:
```qml
ColumnLayout {
  CheckBox {
    id: checkbox
    text: "check me"
  }

  Text {
    id: label
    text: labelText(checkbox.checkState == Qt.Checked)
  }

  function labelText(checked): string {
    return `the checkbox is checked: ${checked}`;
  }
}
```

And the function can also be inlined to an expression:
```qml
ColumnLayout {
  CheckBox {
    id: checkbox
    text: "check me"
  }

  Text {
    id: label
    text: {
      const checked = checkbox.checkState == Qt.Checked;
      return `the checkbox is checked: ${checked}`;
    }
  }
}
```

You can also remove the return statement if you wish.

##### Attached objects

Attached objects are additional objects that can be associated with an object
as decided by internal library code. The documentation for a type will
tell you if it can be used as an attached object and how.

Attached objects are acccessed in the form `<Typename>.<member>` and can have
properties, functions and signals.

A good example is the [Component](https://doc.qt.io/qt-6/qml-qtqml-component.html) type,
which is attached to every object and often used to run code when an object initializes.

```qml
Text {
  Component.onCompleted: {
    text = "hello!"
  }
}
```

In this example, the text property is set inside the `Component.onCompleted` attached signal handler.

#### Creating types

Every QML file with an uppercase name is implicitly a type, and can be used from
neighboring files or imported (See [Imports](#imports).)

A type definition is just a normal object. All properties defined for the root object
are visible to the consumer of the type. Objects identified by [id properties](#the-id-property)
are not visible outside the file.

```qml
// MyText.qml
Rectangle {
  required property string text

  color: "red"
  implicitWidth: textObj.implicitWidth
  implicitHeight: textObj.implicitHeight

  Text {
    id: textObj
    anchors.fill: parent
    text: parent.text
  }
}

// AnotherComponent.qml
Item {
  MyText {
    // The `text` property of `MyText` is required, so we must set it.
    text: "Hello World!"

    // `anchors` is a property of `Item` which `Rectangle` subclasses,
    // so it is available on MyText.
    anchors.centerIn: parent

    // `color` is a property of `Rectangle`. Even though MyText sets it
    // to "red", we can override it here.
    color: "blue"

    // `textObj` is has an `id` within MyText.qml but is not a property
    // so we cannot access it.
    textObj.color: "red" // illegal
  }
}
```

##### Singletons
QML Types can be easily made into a singleton, meaning there is only one instance
of the type.

To make a type a singleton, put `pragma Singleton` at the top of the file.
To ensure it behaves correctly with quickshell you should also make
[Singleton](/docs/types/quickshell/singleton) the root item of your type.

```qml
pragma Singleton
import ...

Singleton { ... }
```

once a type is a singleton, its members can be accessed by name from neighboring
files.

## Concepts

### Reactive bindings
<span class="small">This section assumes knowledge of:
[Properties](#properties), [Signals](#signals), and [Functions](#functions).
See also the [Qt documentation](https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html).
</span>

Reactivity is when a property is updated based on updates to another property.
Every time one of the properties in a binding change, the binding is re-evaluated
and the bound property takes the new result. Any bindings that depend on that property
are then re-evaluated and so forth.

Bindings can be created in two different ways:

##### Automatic bindings
A reactive binding occurs automatically when you use one or more properties in the definition
of another property. .

```qml
Item {
  property int clicks: 0

  Button {
    text: `clicks: ${clicks}`
    onClicked: clicks += 1
  }
}
```

In this example, the button's `text` property is re-evaluated every time the button is clicked, because
the `clicks` property has changed.

###### Avoiding creation
To avoid creating a binding, do not use any other properties in the definition of a property.

You can use the `Component.onCompleted` signal to set a value using a property without creating a binding,
as assignments to properties do not create binding.
```qml
Item {
  property string theProperty: "initial value"

  Text {
    // text: "Right now, theProperty is: " + theProperty
    Component.onCompleted: text = "At creation time, theProperty is: " + theProperty
  }
}
```

##### Manual bindings
Sometimes (not often) you need to create a binding inside of a function, signal, or expression.
If you need to change or attach a binding at runtime, the `Qt.binding` function can be used to
create one.

The `Qt.binding` function takes another function as an argument, and when assigned to a property,
the property will use that function as its binding expression.

```qml
Item {
  Text {
    id: boundText
    text: "not bound to anything"
  }

  Button {
    text: "bind the above text"
    onClicked: {
      if (boundText.text == "not bound to anything") {
        text = "press me";
        boundText.text = Qt.binding(() => `button is pressed: ${this.pressed}`);
      }
    }
  }
}
```

In this example, `boundText`'s `text` property is bound to the button's pressed state
when the button is first clicked. When you press or unpress the button the text will
be updated.

##### Removing bindings
To remove a binding, just assign a new value to the property without using `Qt.binding`.

```qml
Item {
  Text {
    id: boundText
    text: `button is pressed: ${theButton.pressed}`
  }

  Button {
    id: theButton
    text: "break the binding"
    onClicked: boundText.text = `button was pressed at the time the binding was broken: ${pressed}`
  }
}
```

When the button is first pressed, the text will be updated, but once `onClicked` fires
the text will be unbound, and even though it contains a reference to the `pressed` property,
it will not be updated further by the binding.

### Lazy loading

Often not all of your interface needs to load immediately. By default the QML
engine initializes every object in the scene before showing anything onscreen.
For parts of the interface you don't need to be immediately visible, load them
asynchronously using a [LazyLoader](/docs/types/quickshell/lazyloader).
See its documentation for more information.

#### Components

Another delayed loading mechanism is the [Component](https://doc.qt.io/qt-6/qml-qtqml-component.html) type.
This type can be used to create multiple instances of objects or lazily load them. It's used by types such
as [Repeater](https://doc.qt.io/qt-6/qml-qtquick-repeater.html)
and [Quickshell.Variants](/docs/types/quickshell/variants)
to create instances of a component at runtime.
.quickshell_docs_raw/content/docs/types/_index.md
+++
title = "Type Reference"
+++

Index of all Quickshell types. See [the QtQuick type reference](https://doc.qt.io/qt-6/qtquick-qmlmodule.html) for builtin Qt types.

{{< qmlmodulelisting >}}
