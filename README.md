# hear me move

by [Cassie Wang](https://github.com/caswang0117), [Eric](https://github.com/ericgarcia35), [Omari Matthews](https://github.com/omarim), & [Xander Koo](https://github.com/xanderkoo) for MS38 ML for Artists taught by [Professor Doug "Dougie Fresh" Goodwin](https://github.com/douglasgoodwin).

Connects MediaPipe PoseNet to Wekinator input.

TODO: Add PoseNet skeleton to the visual webcam feed, make a new beat machine for Wekinator

Credit: We used code from @noisyneuron's [repo](https://github.com/noisyneuron/wekOsc) to sent data from the browser to Wekinator.

## Getting Started

```
git clone https://github.com/xanderkoo/hear-me-move
cd hear-me-move
npm install
node server.js
```

## PoseNet

Go to http://localhost:3000

## Wekinator

Open Wekinator, set it to listen to port 3333 for 51 inputs and 3 outputs going to port 12000 (you should change this depending on the desired output widget).

Open up one of these: http://www.wekinator.org/examples/#Processing_animation_audio or something

Go to View>Inputs to verify that it is working

Hit Values>Randomize (or choose values with the sliders), then press "Start Recording" and do a pose that you want to associate with those values. Press "Stop Recording" and repeat this step for as many times as you like.

Press Train, then hit Run after it's done.