class MusicPlayer {
  SoundControls sc;
  float targetPlaybackRate = 0.0;
  float targetVolume = 0.0;
  
  Point prev;
  
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
    float currentLenSq = tendrils.currentLengthSquared();
    float distanceProgress = currentLenSq/(maxTendrilLength*maxTendrilLength);
    
    float minVolUncovered = 0.7;
    
    distanceProgress = max(distanceProgress, minVolUncovered);
    
    Point p2 = box.pieceCoords();
    
    if (prev != null){
      float lenSq = prev.squareDistanceTo(p2);
      
      float deltaProgress = lenSq / 90000.0;
      
      if (deltaProgress > 2.2){
        deltaProgress = 1.0 / deltaProgress;
      }
      
      targetPlaybackRate = deltaProgress + 0.8;
    }
    
    float maxLenSqForVolumeCap = 4200.0;
    
    if (currentLenSq < maxLenSqForVolumeCap) {
      distanceProgress = minVolUncovered * (currentLenSq/maxLenSqForVolumeCap);
    };
    
    targetVolume = distanceProgress;
    
    updateVolume();
    updatePlaybackRate();
    
    prev = p2;
  }
  
  void setTargetVolume(float progress){
    targetVolume = progress;
  }
  
  void setTargetPlaybackRate(float progress){
    targetPlaybackRate = progress;
  }
  
  void updateVolume(){
    float currentVolume = sc.getVolume();
    
    float cVolume;
    float easeFactor = 0.6;
    
    if (abs(targetVolume - currentVolume) < 0.01) {
      cVolume = targetVolume;
    } else {
      cVolume = (targetVolume * easeFactor) + (currentVolume * (1.0 - easeFactor));
    }
    
    sc.setVolume(cVolume);
  }
  
  void updatePlaybackRate(){
    float currentRate = sc.getRate();
    
    float cVolume;
    float easeFactor = 0.4;
    
    float volume = sc.getVolume();
    
    float sine;
    
    if (volume == 0.0){
      sine = 0.0;
    } else {
      sine = sin(millis()/(20.0 * volume));
    }
    float sineFactor = 0.8 * volume;
    
    if (abs(targetPlaybackRate - currentRate) < 0.01) {
      cVolume = targetPlaybackRate;
    } else {
      cVolume = (targetPlaybackRate * easeFactor) + ((currentRate + (sine * sineFactor)) * (1.0 - easeFactor));
    }
    
    sc.setPlaybackRate(cVolume);
  }
}
