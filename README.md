# hear me move

by [Cassie Wang](https://github.com/caswang0117), [Eric Garcia](https://github.com/ericgarcia35), [Omari Matthews](https://github.com/omarim), & [Xander Koo](https://github.com/xanderkoo) for MS38 ML for Artists taught by [Professor Doug "Dougie Fresh" Goodwin](https://github.com/douglasgoodwin).

Connects MediaPipe PoseNet to Wekinator, which routes to a beat machine. The sound will influence your movement, and your movement will influence the sound, and the sound will influence your movement...

Credit:
- `server.js` is adapted from @noisyneuron's [repo](https://github.com/noisyneuron/wekOsc) to sent data from the browser to Wekinator
- `sketch.js` is adapted from the [Google Creative Lab PoseNet Sketchbook](https://github.com/googlecreativelab/posenet-sketchbook) by [Maya Man](https://github.com/mayaman) (chirp chirp!)
- The code for showing the webcam feed in `poses.js` is adapted from this [Stack Overflow answer](https://stackoverflow.com/a/32108930)
- The beat machine code was adapted from the ["Simple continuously-controlled drum machine" example](http://www.wekinator.org/examples/#Processing_animation_audio) on the Wekinator website
- The audio samples for the beat machine come from the [Genius Home Studio beat pack](https://homestudio.genius.com/)

## Required Tools
- Google Chrome
- [Wekinator](http://www.wekinator.org/downloads/)
- [Processing](https://processing.org/download/)
- [Minim](https://github.com/ddf/Minim) to be installed as a Processing library.

## Getting Started

```
git clone https://github.com/xanderkoo/hear-me-move
cd hear-me-move
npm install
node server.js
```
This will set up the server that routes PoseNet data to Wekinator.

## PoseNet

Go to http://localhost:3000. Google Chrome works for sure, but you may have to test other browsers to see if they work. You should see a webcam feed and a wireframe skeleton on your body.

## Beat Machine

Open up `Processing_Drum_12ContinuousOutputs/Processing_Drum_12ContinuousOutputs.pde` in Processing. Make sure you have [Minim](https://github.com/ddf/Minim) installed as `./libraries/minim` in your Processing sketchbook directory. Run the beat machine, and a window with red squares should appear.

## Wekinator

Open Wekinator, set it to listen to port 3333 for 34 inputs, and 12 outputs going to port 12000.

Go to View>Inputs to verify that it is working

Hit Values>randomize (or choose values with the sliders), then press "Start Recording" and do a pose(s) that you want to associate with those values. Press "Stop Recording" and repeat this step for as many times as you like.

Press Train, then hit Run after it's done.

Go back to http://localhost:3000 and hear yourself move!
