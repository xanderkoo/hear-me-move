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

ArrayList<Rect> buttons = new ArrayList<Rect>();

// randomSeed(4206);

int bpm = 120;

int beat; // which beat we're on

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
    /*if ( mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h )
    {
      steps[stepId] = !steps[stepId];
    } */
  }
  
 /* public void turnOn() {
    steps[stepId] = true;
  }
  
  public void turnOff() {
    steps[stepId] = false;
  } */
}

void setup()
{
  size(395, 625);
  
    //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  minim = new Minim(this);
  out   = minim.getLineOut();
  
  // load all of our samples, using 4 voices for each.
  // this will help ensure we have enough voices to handle even
  // very fast tempos.
  bass1  = new Sampler( "808 1.wav", 4, minim );
  bass2 = new Sampler( "808 2.wav", 4, minim );
  clap   = new Sampler( "Clap.wav", 4, minim );
  hat1  = new Sampler( "Hat.wav", 4, minim );
  hat2 = new Sampler( "Hat 2.wav", 4, minim );
  kick1   = new Sampler( "Kick 1.wav", 4, minim );
  kick2  = new Sampler( "Kick 2.wav", 4, minim );
  ohat = new Sampler( "Open Hat.wav", 4, minim );
  rim1   = new Sampler( "Rimshot 1.wav", 4, minim );
  rim2  = new Sampler( "Rimshot 2.wav", 4, minim );
  snare1 = new Sampler( "Snare 1.wav", 4, minim );
  snare2   = new Sampler( "Snare 2.wav", 4, minim );
  
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
  
  for (int i = 0; i < 16; i++)
  {
    buttons.add( new Rect(10+i*24, 50, bass1Row, i ) );
    buttons.add( new Rect(10+i*24, 100, bass2Row, i ) );
    buttons.add( new Rect(10+i*24, 150, clapRow, i ) );
    buttons.add( new Rect(10+i*24, 200, hat1Row, i ) );
    buttons.add( new Rect(10+i*24, 250, hat2Row, i ) );
    buttons.add( new Rect(10+i*24, 300, kick1Row, i ) );
    buttons.add( new Rect(10+i*24, 350, kick2Row, i ) );
    buttons.add( new Rect(10+i*24, 400, ohatRow, i ) );
    buttons.add( new Rect(10+i*24, 450, rim1Row, i ) );
    buttons.add( new Rect(10+i*24, 500, rim2Row, i ) );
    buttons.add( new Rect(10+i*24, 550, snare1Row, i ) );
    buttons.add( new Rect(10+i*24, 600, snare2Row, i ) );
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
  rect(10+beat*24, 35, 14, 9);
  
  fill(0, 255, 0);
  text( "Use 12 continuous Wekinator outputs between 0 and 1", 5, 15 );
  text( "Listening for /wek/outputs on port 12000", 5, 30 );
  text("Use sliders in Wekinator to control density of each track", 5, 45 );
}

void mousePressed()
{
  for(int i = 0; i < buttons.size(); ++i)
  {
    buttons.get(i).mousePressed();
  }
}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 if (theOscMessage.checkAddrPattern("/wek/outputs")==true) {
     if(theOscMessage.checkTypetag("fff")) { //Now looking for 2 parameters
        float p1 = theOscMessage.get(0).floatValue(); //get 1st parameter
        float p2 = theOscMessage.get(1).floatValue(); //get 2nd parameter
        float p3 = theOscMessage.get(2).floatValue(); //get 3rd parameters
        float p4 = theOscMessage.get(3).floatValue(); //get 4th parameter
        float p5 = theOscMessage.get(4).floatValue(); //get 5th parameter
        float p6 = theOscMessage.get(5).floatValue(); //get 6th parameters
        float p7 = theOscMessage.get(6).floatValue(); //get 7th parameter
        float p8 = theOscMessage.get(7).floatValue(); //get 8th parameter
        float p9 = theOscMessage.get(8).floatValue(); //get 9th parameters
        float p10 = theOscMessage.get(9).floatValue(); //get 10th parameter
        float p11 = theOscMessage.get(10).floatValue(); //get 11th parameter
        float p12 = theOscMessage.get(11).floatValue(); //get 12th parameters
        // lmao idk how this works yolo
        
        updateDrums(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12);
        
        println("Received new params value from Wekinator");  
      } else {
        println("Error: unexpected params type tag received by Processing");
      }
 }
}

void updateDrums(float p1,
                 float p2,
                 float p3,
                 float p4,
                 float p5,
                 float p6,
                 float p7,
                 float p8,
                 float p9,
                 float p10,
                 float p11,
                 float p12) {

  bass1Row[0] = drumRowGenerator(p1);
  bass1Row[1] = drumRowGenerator(p1);
  bass1Row[2] = drumRowGenerator(p1);
  bass1Row[3] = drumRowGenerator(p1);
  bass1Row[4] = drumRowGenerator(p1);
  bass1Row[5] = drumRowGenerator(p1);
  bass1Row[6] = drumRowGenerator(p1);
  bass1Row[7] = drumRowGenerator(p1);
  bass1Row[8] = drumRowGenerator(p1);
  bass1Row[9] = drumRowGenerator(p1);
  bass1Row[10] = drumRowGenerator(p1);
  bass1Row[11] = drumRowGenerator(p1);
  bass1Row[12] = drumRowGenerator(p1);
  bass1Row[13] = drumRowGenerator(p1);
  bass1Row[14] = drumRowGenerator(p1);
  bass1Row[15] = drumRowGenerator(p1);
  
  bass2Row[0] = drumRowGenerator(p2);
  bass2Row[1] = drumRowGenerator(p2);
  bass2Row[2] = drumRowGenerator(p2);
  bass2Row[3] = drumRowGenerator(p2);
  bass2Row[4] = drumRowGenerator(p2);
  bass2Row[5] = drumRowGenerator(p2);
  bass2Row[6] = drumRowGenerator(p2);
  bass2Row[7] = drumRowGenerator(p2);
  bass2Row[8] = drumRowGenerator(p2);
  bass2Row[9] = drumRowGenerator(p2);
  bass2Row[10] = drumRowGenerator(p2);
  bass2Row[11] = drumRowGenerator(p2);
  bass2Row[12] = drumRowGenerator(p2);
  bass2Row[13] = drumRowGenerator(p2);
  bass2Row[14] = drumRowGenerator(p2);
  bass2Row[15] = drumRowGenerator(p2);;
  
  clapRow[0] = drumRowGenerator(p3);
  clapRow[1] = drumRowGenerator(p3);
  clapRow[2] = drumRowGenerator(p3);
  clapRow[3] = drumRowGenerator(p3);
  clapRow[4] = drumRowGenerator(p3);
  clapRow[5] = drumRowGenerator(p3);
  clapRow[6] = drumRowGenerator(p3);
  clapRow[7] = drumRowGenerator(p3);
  clapRow[8] = drumRowGenerator(p3);
  clapRow[9] = drumRowGenerator(p3);
  clapRow[10] = drumRowGenerator(p3);
  clapRow[11] = drumRowGenerator(p3);
  clapRow[12] = drumRowGenerator(p3);
  clapRow[13] = drumRowGenerator(p3);
  clapRow[14] = drumRowGenerator(p3);
  clapRow[15] = drumRowGenerator(p3);
   
  hat1Row[0] = drumRowGenerator(p4);
  hat1Row[1] = drumRowGenerator(p4);
  hat1Row[2] = drumRowGenerator(p4);
  hat1Row[3] = drumRowGenerator(p4);
  hat1Row[4] = drumRowGenerator(p4);
  hat1Row[5] = drumRowGenerator(p4);
  hat1Row[6] = drumRowGenerator(p4);
  hat1Row[7] = drumRowGenerator(p4);
  hat1Row[8] = drumRowGenerator(p4);
  hat1Row[9] = drumRowGenerator(p4);
  hat1Row[10] = drumRowGenerator(p4);
  hat1Row[11] = drumRowGenerator(p4);
  hat1Row[12] = drumRowGenerator(p4);
  hat1Row[13] = drumRowGenerator(p4);
  hat1Row[14] = drumRowGenerator(p4);
  hat1Row[15] = drumRowGenerator(p4);
   
  hat2Row[0] = drumRowGenerator(p5);
  hat2Row[1] = drumRowGenerator(p5);
  hat2Row[2] = drumRowGenerator(p5);
  hat2Row[3] = drumRowGenerator(p5);
  hat2Row[4] = drumRowGenerator(p5);
  hat2Row[5] = drumRowGenerator(p5);
  hat2Row[6] = drumRowGenerator(p5);
  hat2Row[7] = drumRowGenerator(p5);
  hat2Row[8] = drumRowGenerator(p5);
  hat2Row[9] = drumRowGenerator(p5);
  hat2Row[10] = drumRowGenerator(p5);
  hat2Row[11] = drumRowGenerator(p5);
  hat2Row[12] = drumRowGenerator(p5);
  hat2Row[13] = drumRowGenerator(p5);
  hat2Row[14] = drumRowGenerator(p5);
  hat2Row[15] = drumRowGenerator(p5);
  
  kick1Row[0] = drumRowGenerator(p6);
  kick1Row[1] = drumRowGenerator(p6);
  kick1Row[2] = drumRowGenerator(p6);
  kick1Row[3] = drumRowGenerator(p6);
  kick1Row[4] = drumRowGenerator(p6);
  kick1Row[5] = drumRowGenerator(p6);
  kick1Row[6] = drumRowGenerator(p6);
  kick1Row[7] = drumRowGenerator(p6);
  kick1Row[8] = drumRowGenerator(p6);
  kick1Row[9] = drumRowGenerator(p6);
  kick1Row[10] = drumRowGenerator(p6);
  kick1Row[11] = drumRowGenerator(p6);
  kick1Row[12] = drumRowGenerator(p6);
  kick1Row[13] = drumRowGenerator(p6);
  kick1Row[14] = drumRowGenerator(p6);
  kick1Row[15] = drumRowGenerator(p6);
  
  kick2Row[0] = drumRowGenerator(p7);
  kick2Row[1] = drumRowGenerator(p7);
  kick2Row[2] = drumRowGenerator(p7);
  kick2Row[3] = drumRowGenerator(p7);
  kick2Row[4] = drumRowGenerator(p7);
  kick2Row[5] = drumRowGenerator(p7);
  kick2Row[6] = drumRowGenerator(p7);
  kick2Row[7] = drumRowGenerator(p7);
  kick2Row[8] = drumRowGenerator(p7);
  kick2Row[9] = drumRowGenerator(p7);
  kick2Row[10] = drumRowGenerator(p7);
  kick2Row[11] = drumRowGenerator(p7);
  kick2Row[12] = drumRowGenerator(p7);
  kick2Row[13] = drumRowGenerator(p7);
  kick2Row[14] = drumRowGenerator(p7);
  kick2Row[15] = drumRowGenerator(p7);
   
  ohatRow[0] = drumRowGenerator(p8);
  ohatRow[1] = drumRowGenerator(p8);
  ohatRow[2] = drumRowGenerator(p8);
  ohatRow[3] = drumRowGenerator(p8);
  ohatRow[4] = drumRowGenerator(p8);
  ohatRow[5] = drumRowGenerator(p8);
  ohatRow[6] = drumRowGenerator(p8);
  ohatRow[7] = drumRowGenerator(p8);
  ohatRow[8] = drumRowGenerator(p8);
  ohatRow[9] = drumRowGenerator(p8);
  ohatRow[10] = drumRowGenerator(p8);
  ohatRow[11] = drumRowGenerator(p8);
  ohatRow[12] = drumRowGenerator(p8);
  ohatRow[13] = drumRowGenerator(p8);
  ohatRow[14] = drumRowGenerator(p8);
  ohatRow[15] = drumRowGenerator(p8);
  
  rim1Row[0] = drumRowGenerator(p9);
  rim1Row[1] = drumRowGenerator(p9);
  rim1Row[2] = drumRowGenerator(p9);
  rim1Row[3] = drumRowGenerator(p9);
  rim1Row[4] = drumRowGenerator(p9);
  rim1Row[5] = drumRowGenerator(p9);
  rim1Row[6] = drumRowGenerator(p9);
  rim1Row[7] = drumRowGenerator(p9);
  rim1Row[8] = drumRowGenerator(p9);
  rim1Row[9] = drumRowGenerator(p9);
  rim1Row[10] = drumRowGenerator(p9);
  rim1Row[11] = drumRowGenerator(p9);
  rim1Row[12] = drumRowGenerator(p9);
  rim1Row[13] = drumRowGenerator(p9);
  rim1Row[14] = drumRowGenerator(p9);
  rim1Row[15] = drumRowGenerator(p9);
   
  rim2Row[0] = drumRowGenerator(p10);
  rim2Row[1] = drumRowGenerator(p10);
  rim2Row[2] = drumRowGenerator(p10);
  rim2Row[3] = drumRowGenerator(p10);
  rim2Row[4] = drumRowGenerator(p10);
  rim2Row[5] = drumRowGenerator(p10);
  rim2Row[6] = drumRowGenerator(p10);
  rim2Row[7] = drumRowGenerator(p10);
  rim2Row[8] = drumRowGenerator(p10);
  rim2Row[9] = drumRowGenerator(p10);
  rim2Row[10] = drumRowGenerator(p10);
  rim2Row[11] = drumRowGenerator(p10);
  rim2Row[12] = drumRowGenerator(p10);
  rim2Row[13] = drumRowGenerator(p10);
  rim2Row[14] = drumRowGenerator(p10);
  rim2Row[15] = drumRowGenerator(p10);
   
  snare1Row[0] = drumRowGenerator(p11);
  snare1Row[1] = drumRowGenerator(p11);
  snare1Row[2] = drumRowGenerator(p11);
  snare1Row[3] = drumRowGenerator(p11);
  snare1Row[4] = drumRowGenerator(p11);
  snare1Row[5] = drumRowGenerator(p11);
  snare1Row[6] = drumRowGenerator(p11);
  snare1Row[7] = drumRowGenerator(p11);
  snare1Row[8] = drumRowGenerator(p11);
  snare1Row[9] = drumRowGenerator(p11);
  snare1Row[10] = drumRowGenerator(p11);
  snare1Row[11] = drumRowGenerator(p11);
  snare1Row[12] = drumRowGenerator(p11);
  snare1Row[13] = drumRowGenerator(p11);
  snare1Row[14] = drumRowGenerator(p11);
  snare1Row[15] = drumRowGenerator(p11);
   
  snare2Row[0] = drumRowGenerator(p12);
  snare2Row[1] = drumRowGenerator(p12);
  snare2Row[2] = drumRowGenerator(p12);
  snare2Row[3] = drumRowGenerator(p12);
  snare2Row[4] = drumRowGenerator(p12);
  snare2Row[5] = drumRowGenerator(p12);
  snare2Row[6] = drumRowGenerator(p12);
  snare2Row[7] = drumRowGenerator(p12);
  snare2Row[8] = drumRowGenerator(p12);
  snare2Row[9] = drumRowGenerator(p12);
  snare2Row[10] = drumRowGenerator(p12);
  snare2Row[11] = drumRowGenerator(p12);
  snare2Row[12] = drumRowGenerator(p12);
  snare2Row[13] = drumRowGenerator(p12);
  snare2Row[14] = drumRowGenerator(p12);
  snare2Row[15] = drumRowGenerator(p12);

}

boolean drumRowGenerator(float p) {
  float r1 = random(1);
  float r2 = random(1);
  if (r1 < .4) return false;
  return r2 > p;
}
