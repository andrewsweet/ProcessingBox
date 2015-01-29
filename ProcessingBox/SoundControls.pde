import beads.*;
import java.util.Arrays; 

AudioContext ac;

UGen rateUGen;
SamplePlayer sp;
Gain gain;

class SoundControls {
  
  void initialize() {
    ac = new AudioContext();
    
    String sourceFile = dataPath("test.wav");
    
    print(dataPath("test.wav"));
    
    try{
      Sample sample = new Sample(sourceFile);
      
      sp = new SamplePlayer(ac, sample);
      
      rateUGen = new Glide(ac, 1.0);
    
      sp.setRate(rateUGen);
//      sp.setRateEnvelope(rateEnvelope);

      //loop the sample at its end points
      sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      sp.getLoopStartEnvelope().setValue(0);
      sp.getLoopEndEnvelope().setValue((float)sample.getLength());
    
      gain = new Gain(ac, 1, 0.1);
      gain.addInput(sp);
      ac.out.addInput(gain);
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
  
  void setPlaybackRate(float speed){
    rateUGen.setValue(speed);
  }
  
  void setVolume(float volume){
    gain.setGain(max(min(volume, 1.0), 0.0));
  }
  
  void update(){
    float speed = 4.0 * ((float)mouseX - (width/2.0))/width;
    float volume = (float)mouseY / (height * 1.0);
    
    setPlaybackRate(speed);
    setVolume(volume);
    
    println(speed, gain.getGain());
  }
  
  void pause(boolean shouldPause){
    sp.pause(shouldPause);
  }
}
