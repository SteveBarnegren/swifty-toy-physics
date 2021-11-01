# Swifty Toy Physics

## What is this?

This is a macOS application featuring a toy physics simulation that you can play around in. I created it just to learn a little more about physics. It's been sitting around doing nothing for a while, so I thought I'd open source it.

This isn't a library or any type of system that's designed to be used in another application, and only simulates some very basic physics interactions.

*Disclaimer: I'm not a physics expert. There may be much better techniques to create a physics simulation than the ones that I've used!*

## Just show me what it can do!

**Physics Scene:**

![Physics scene](https://user-images.githubusercontent.com/6288713/139735667-6a310f2f-f8a7-4781-918f-09fbf8e05065.gif)

**Golf:**

![Golf](https://user-images.githubusercontent.com/6288713/139735714-4d6526fa-6e93-4f94-b357-05f79c4713d0.gif)

**Snooker:**

![Snooker](https://user-images.githubusercontent.com/6288713/139735735-eaa0c439-c30f-4bbf-8e3a-3e9f7bf5dd49.gif)

**Anti-gravity Balls:**

![Anti-gravity balls](https://user-images.githubusercontent.com/6288713/139735761-50c472fd-13d7-4b1b-b032-7815c0f10b33.gif)

## How to run

### Option 1: Download Built App

Download the application from [here](https://github.com/SteveBarnegren/PhysicsDemo/releases).

### Option 2: Compile from source

1. Clone the repository
2. Open in Xcode
3. Build and run the application

## Quick Start Instructions

The app allows you to build a 'physics scene'. A scene is an environment of static physical objects that you can insert dynamic ones into.

The quickest way to try the app is to use the bundled example scenes.

1. Run the app.
2. From the `Scene -> Example` menu, select an example scene.
3. Click in the scene window to add balls to the scene.
4. On the right hand side you can select `Drop` to drop balls into the scene with no momentum, or `Fling` to use an 'Angry Birds' flinging approach.
5. Adjust ball size, elasticity on the side pane.


## Full Instructions

### Building a scene

Use the 'Add Lines', 'Add Circles', and 'Add Polyline` buttons on the side panel to enter each mode. Input usually just requires simple clicking / dragging. Each mode displays a basic instructions at the top.

Press Escape to cancel an operation or to go back to the standard interactive mode.

### Edit a scene

Press the 'Edit' button in the side panel to enter Edit mode. Grabbable handles are displayed over the scene. You can perform operations by dragging such as moving line ends, moving objects, and adjusting circle radii.

Each scene boundary wall can be enabled and disabled.

You can also temporarily enter edit mode at any other time by holding the option key.

### Grid

Use the 'Grid' checkbox in the side panel to enable the grid. the plus and minus buttons can be used to alter the number of grid divisions across the scene.

When the grid is enabled, all edits and placement of objects will snap to the closest grid position.

Whilst the grid is enabled, it can be temporarily disabled during any operation by holding the control key.

### Timestep

There are multiple options for calculating the timestep. If you are unfamiliar with the concept of a timestep, then I recommend [this awesome blog post](https://gafferongames.com/post/fix_your_timestep/).

**Variable**

Variable locks the timestep to the display rate. This means that the timestep may waver slightly, producing less deterministic results.

**Semi-Fixed**

Semi-fixed consumes the available time in specified time slices. If there is time left over then this is consumed in a smaller 'remainder' slice.

This approach results in fewer errors such as tunneling.

The frame rate can be specified. There is no protection against the 'spiral of death', so setting the frame rate to a value higher than your computer is able to compute in time each frame will result in the application beach-balling.

**Fixed**

Fixed uses a fixed time slice for each step of the simulation. Any remainder is carried over to the next frame.

This results in a completely deterministic and reproducible simulation (unless of course you change the time step!). The downside is that the amount of time consumed may not match the frame rate, as the remainder is carried over. This can produce some jitter.

Enabling 'interpolation' will render objects at the position that they would be assumed to be at based on having continued to travel on their current trajectory for the amount of the remainder time.

Similar to Semi-Fixed, it's possible to hang by configuring high frame rates.

### Starting Over

Use the `🗑 Balls` and `🗑 Scene` buttons to remove all of the balls from the scene, or to clear the scene geometry entirely

### Save / Load Scenes

Load one of the example scenes using `Scene -> Example` and selecting a scene.

Save a custom scene using `Scene -> Save`.

Load a custom saved scene file using `Scene -> Load`.

## Author

Created by Steve Barnegren

[@SteveBarnegren](https://twitter.com/stevebarnegren)






















