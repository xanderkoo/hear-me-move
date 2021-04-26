/**
 * Adapted from "Simple continuously-controlled drum machine" example: http://www.wekinator.org/examples/#Processing_animation_audio
 *
 * Requires Minim: https://github.com/ddf/Minim
 * Follow the instructions given in the README
 */

import processing.opengl.*;

/**
  * This is a modification of an example from Minim package
  * Modified by Rebecca Fiebrink to work with Wekinator
  * This version takes 3 continuous outputs from Wekinator, each expected in range 0-1
  * Listens on port 12000
  * Original header:
  * This sketch is a more involved use of AudioSamples to create a simple drum machine. 
  * Click on the buttons to toggle them on and off. The buttons that are on will trigger 
  * samples when the beat marker passes over their column. You can change the tempo by 
  * clicking in the BPM box and dragging the mouse up and down.
  * <p>
  * We achieve the timing by using AudioOutput's playNote method and a cleverly written Instrument.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */


import ddf.minim.*;
import ddf.minim.ugens.*;

//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

Minim       minim;
AudioOutput out;

Sampler     bass1;
Sampler     bass2;
Sampler     clap;
Sampler     hat1;
Sampler     hat2;
Sampler     kick1;
Sampler     kick2;
Sampler     ohat;
Sampler     rim1;
Sampler     rim2;
Sampler     snare1;
Sampler     snare2;

boolean[] bass1Row = new boolean[16];
boolean[] bass2Row = new boolean[16];
boolean[] clapRow = new boolean[16];
boolean[] hat1Row = new boolean[16];
boolean[] hat2Row = new boolean[16];
boolean[] kick1Row = new boolean[16];
boolean[] kick2Row = new boolean[16];
boolean[] ohatRow = new boolean[16];
boolean[] rim1Row = new boolean[16];
boolean[] rim2Row = new boolean[16];
boolean[] snare1Row = new boolean[16];
boolean[] snare2Row = new boolean[16];

float[] bass1Thresholds = new float[16];
float[] bass2Thresholds = new float[16];
float[] clapThresholds = new float[16];
float[] hat1Thresholds = new float[16];
float[] hat2Thresholds = new float[16];
float[] kick1Thresholds = new float[16];
float[] kick2Thresholds = new float[16];
float[] ohatThresholds = new float[16];
float[] rim1Thresholds = new float[16];
float[] rim2Thresholds = new float[16];
float[] snare1Thresholds = new float[16];
float[] snare2Thresholds = new float[16];

ArrayList<Rect> buttons = new ArrayList<Rect>();
ArrayList<SampleTag> sampleTags = new ArrayList<SampleTag>();

int bpm = 60;

int beat; // which beat we're on

int instructionsXOffset = 5;
int instructionsYOffset = 15;
int beatXOffset = 60;
int beatYOffset = 100 + instructionsYOffset;

// here's an Instrument implementation that we use 
// to trigger Samplers every sixteenth note. 
// Notice how we get away with using only one instance
// of this class to have endless beat making by 
// having the class schedule itself to be played
// at the end of its noteOff method. 
class Tick implements Instrument
{
  void noteOn( float dur )
  {
    if ( bass1Row[beat] ) bass1.trigger();
    if ( bass2Row[beat] ) bass2.trigger();
    if ( clapRow[beat] ) clap.trigger();
    if ( hat1Row[beat] ) hat1.trigger();
    if ( hat2Row[beat] ) hat2.trigger();
    if ( kick1Row[beat] ) kick1.trigger();
    if ( kick2Row[beat] ) kick2.trigger();
    if ( ohatRow[beat] ) ohat.trigger();
    if ( rim1Row[beat] ) rim1.trigger();
    if ( rim2Row[beat] ) rim2.trigger();
    if ( snare1Row[beat] ) snare1.trigger();
    if ( snare2Row[beat] ) snare2.trigger();
  }
  
  void noteOff()
  {
    // next beat
    beat = (beat+1)%16;
    // set the new tempo
    out.setTempo( bpm );
    // play this again right now, with a sixteenth note duration
    out.playNote( 0, 0.25f, this );
  }
}

// simple class for drawing the gui
class Rect 
{
  int x, y, w, h;
  boolean[] steps;
  int stepId;
  
  public Rect(int _x, int _y, boolean[] _steps, int _id)
  {
    x = _x;
    y = _y;
    w = 14;
    h = 30;
    steps = _steps;
    stepId = _id;
  }
  
  public void draw()
  {
    if ( steps[stepId] )
    {
      fill(0,255,0);
    }
    else
    {
      fill(255,0,0);
    }
    
    rect(x,y,w,h);
  }
  
  public void mousePressed()
  {
    if ( mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h )
    {
      steps[stepId] = !steps[stepId];
    }
  }
}


class SampleTag {
  String displayName;
  Sampler sample;
  float x, y, w, h;
  boolean textRed = false;

  public SampleTag(int _x, int _y, String _displayName, Sampler _sample) {
    displayName = _displayName;
    sample = _sample;
    x = _x;
    y = _y;
    h = 10;
    w = textWidth(displayName);
  }

  public void draw() {
    fill(255, 0, 0);
    text(displayName, x, y);
  }

  public void mousePressed() {
    if ( mouseX >= x && mouseX <= x+w && mouseY >= y-2*h && mouseY <= y+h ) {
      sample.trigger();
    }
  }
}

void setup()
{
  size(450, 700);
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  minim = new Minim(this);
  out   = minim.getLineOut();
  
  // load all of our samples, using 4 voices for each.
  // this will help ensure we have enough voices to handle even
  // very fast tempos.
  bass1  = new Sampler( "808 1.wav", 4, minim );
  bass2  = new Sampler( "808 2.wav", 4, minim );
  clap   = new Sampler( "Clap.wav", 4, minim );
  hat1   = new Sampler( "Hat.wav", 4, minim );
  hat2   = new Sampler( "Hat 2.wav", 4, minim );
  kick1  = new Sampler( "Kick 1.wav", 4, minim );
  kick2  = new Sampler( "Kick 2.wav", 4, minim );
  ohat   = new Sampler( "Open Hat.wav", 4, minim );
  rim1   = new Sampler( "Rimshot 1.wav", 4, minim );
  rim2   = new Sampler( "Rimshot 2.wav", 4, minim );
  snare1 = new Sampler( "Snare 1.wav", 4, minim );
  snare2 = new Sampler( "Snare 2.wav", 4, minim );
  
  // patch samplers to the outputbass1  = new Sampler( "BD.wav", 4, minim );
  bass1.patch( out );
  bass2.patch( out );
  clap.patch( out );
  hat1.patch( out );
  hat2.patch( out );
  kick1.patch( out );
  kick2.patch( out );
  ohat.patch( out );
  rim1.patch( out );
  rim2.patch( out );
  snare1.patch( out );
  snare2.patch( out );

  // initialize the pattern for each sample
  initDrums();

  // initialize all of the tags for each sample
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20,     "BASS1",  bass1));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+50,  "BASS2",  bass2));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+100, "CLAP",   clap));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+150, "HAT1",   hat1));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+200, "HAT2",   hat2));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+250, "KICK1",  kick1));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+300, "KICK2",  kick2));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+350, "OHAT",   ohat));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+400, "RIM1",   rim1));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+450, "RIM2",   rim2));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+500, "SNARE1", snare1));
  sampleTags.add(new SampleTag(beatXOffset-50, beatYOffset+20+550, "SNARE2", snare2));
  
  for (int i = 0; i < 16; i++)
  {
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset,     bass1Row,  i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+50,  bass2Row,  i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+100, clapRow,   i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+150, hat1Row,   i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+200, hat2Row,   i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+250, kick1Row,  i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+300, kick2Row,  i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+350, ohatRow,   i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+400, rim1Row,   i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+450, rim2Row,   i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+500, snare1Row, i ) );
    buttons.add( new Rect(beatXOffset+i*24, beatYOffset+550, snare2Row, i ) );
  }
  
  beat = 0;
  
  // start the sequencer
  out.setTempo( bpm );
  out.playNote( 0, 0.25f, new Tick() );
}

void draw()
{
  background(0);
  fill(255);
  //text(frameRate, width - 60, 20);
  
  for(int i = 0; i < buttons.size(); ++i)
  {
    buttons.get(i).draw();
  }

  for (int i = 0; i < sampleTags.size(); ++i) {
    sampleTags.get(i).draw();
  }
  
  stroke(128);
  if ( beat % 4 == 0 )
  {
    fill(200, 0, 0);
  }
  else
  {
    fill(0, 200, 0);
  }
    
  // beat marker    
  rect(beatXOffset+beat*24, beatYOffset-15, 14, 9);
  
  fill(0, 255, 0);
  text( "Use 12 continuous Wekinator outputs between 0 and 1", instructionsXOffset, instructionsYOffset );
  text( "Listening for /wek/outputs on port 12000", instructionsXOffset, instructionsYOffset+15 );
  text( "Use sliders in Wekinator to control density of each track", instructionsXOffset, instructionsYOffset+30 );
  text( "Click on the name of each sample to hear what it sounds like", instructionsXOffset, instructionsYOffset+45 );
}

void mousePressed()
{
  for(int i = 0; i < buttons.size(); ++i)
  {
    buttons.get(i).mousePressed();
  }

  for (int i = 0; i < sampleTags.size(); ++i){
    sampleTags.get(i).mousePressed();
  }
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("ffffffffffff")) { //Now looking for 12 parameters
        float[] params = new float[12];
        for (int i = 0; i < 12; i++) {
          params[i] = theOscMessage.get(i).floatValue();
        }
        
        updateDrums(params);
        
        println("Received new params value from Wekinator");  
      } else {
        println("Error: unexpected params type tag received by Processing");
      }
 }
}

void updateDrums(float[] params) {
  for (int i = 0; i < 16; i++) {
    bass1Row[i]  = bass1Thresholds[i]  < params[0];
    bass2Row[i]  = bass2Thresholds[i]  < params[1];
    clapRow[i]   = clapThresholds[i]   < params[2];
    hat1Row[i]   = hat1Thresholds[i]   < params[3];
    hat2Row[i]   = hat2Thresholds[i]   < params[4];
    kick1Row[i]  = kick1Thresholds[i]  < params[5];
    kick2Row[i]  = kick2Thresholds[i]  < params[6];
    ohatRow[i]   = ohatThresholds[i]   < params[7];
    rim1Row[i]   = rim1Thresholds[i]   < params[8];
    rim2Row[i]   = rim2Thresholds[i]   < params[9];
    snare1Row[i] = snare1Thresholds[i] < params[10];
    snare2Row[i] = snare2Thresholds[i] < params[11];
  }
}

void initDrums() {
  randomSeed("Prince Dougie Fresh III".hashCode());
  for (int i = 0; i < 16; i++) {
    bass1Thresholds[i]  = drumRowThresholdGenerator();
    bass2Thresholds[i]  = drumRowThresholdGenerator();
    clapThresholds[i]   = drumRowThresholdGenerator();
    hat1Thresholds[i]   = drumRowThresholdGenerator();
    hat2Thresholds[i]   = drumRowThresholdGenerator();
    kick1Thresholds[i]  = drumRowThresholdGenerator();
    kick2Thresholds[i]  = drumRowThresholdGenerator();
    ohatThresholds[i]   = drumRowThresholdGenerator();
    rim1Thresholds[i]   = drumRowThresholdGenerator();
    rim2Thresholds[i]   = drumRowThresholdGenerator();
    snare1Thresholds[i] = drumRowThresholdGenerator();
    snare2Thresholds[i] = drumRowThresholdGenerator();
  }
}

void initSampleTags() {
}

float drumRowThresholdGenerator() {
  float r1 = random(1);
  float r2 = random(1);
  if (r1 < .3) return 1;
  return r2 ;
}
