class MusicPlayer {
  SoundControls sc;
  
  public MusicPlayer() {
    sc = new SoundControls();
  }
  
  public void pause(){
    sc.pause(true);
  }
  
  public void play(){
    sc.pause(false);
  }
  
  public void update(){
//    boxCenter
//    box.p2;
  }
}
