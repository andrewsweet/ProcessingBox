import beads.*;
import java.util.Arrays; 

AudioContext ac;

UGen rateUGen;

class SoundControls {
  
  void initialize() {
    ac = new AudioContext();
    
    String sourceFile = dataPath("test.wav");
    
    print(dataPath("test.wav"));
    
    try{
      GranularSamplePlayer sp = new GranularSamplePlayer(ac, new Sample(sourceFile));
      
      rateUGen = new Glide(ac, 1.0);
    
      sp.setRate(rateUGen);
//      sp.setRateEnvelope(rateEnvelope);
    
      Gain g = new Gain(ac, 1, 0.1);
      g.addInput(sp);
      ac.out.addInput(g);
      ac.start();
    } catch (Exception e) {
      //do anything you want to handle the exception
      println("DONE GOOFED");
    } 
  }
  
  public float x, y;
  public SoundControls() {
    this.initialize();
  }
  
  void updateSound(){//updateSound(float speed, float distortion, float pitch) {
  //  loadPixels();
  //  //set the background
  //  Arrays.fill(pixels, back);
  //  //scan across the pixels
  //  for(int i = 0; i < width; i++) {
  //    //for each pixel work out where in the current audio buffer we are
  //    int buffIndex = i * ac.getBufferSize() / width;
  //    //then work out the pixel height of the audio data at that point
  //    int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * height / 2);
  //    //draw into Processing's convenient 1-D array of pixels
  //    vOffset = min(vOffset, height);
  //    pixels[vOffset * height + i] = fore;
  //  }
  //  updatePixels();
    //mouse listening code here
    
    rateUGen.setValue((float)mouseX / width);
//    grainIntervalEnvelope.setValue((float)mouseY / height);
//    if (distortion){
//    }
    
  //  playbackSpeed.setValue((float)mouseX / width * 1000 + 50);
  //  modFreqRatio.setValue((1 - (float)mouseY / height) * 10 + 0.1);
  }
}
