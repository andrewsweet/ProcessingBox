class MusicPlayer {
  SoundControls sc;
  float targetPlaybackRate = 0.0;
  float targetVolume = 0.0;
  
  float playbackEaseFactor = 0.6;
  float volumeEaseFactor = 0.6;
  
  float killRate = 0;
  
  boolean shouldAdjustRate = false;
  
  Point prev;
  
  public MusicPlayer(String fileName) {
    sc = new SoundControls(fileName);
  }
  
  public void pause(){
    sc.pause(true);
  }
  
  public void play(){
    sc.pause(false);
  }
  
  public void update(){
    Point p2 = box.pieceCoords();
    
    if (!box.isDead){
      float currentLenSq = tendrils.currentLengthSquared();
      float distanceProgress = currentLenSq/(maxTendrilLength*maxTendrilLength);
      
      float minVolUncovered = 0.7;
      
      if (shouldAdjustRate){
        distanceProgress = max(distanceProgress, minVolUncovered);
        
        if (prev != null){
          float lenSq = prev.squareDistanceTo(p2);
          
          float deltaProgress = lenSq / 90000.0;
          
          if (deltaProgress > 2.2){
            deltaProgress = 1.0 / deltaProgress;
          }
          
          targetPlaybackRate = deltaProgress + 0.8;
        }
      }
      
      float maxLenSqForVolumeCap = 4200.0;
      
      if (currentLenSq < maxLenSqForVolumeCap) {
        distanceProgress = minVolUncovered * (currentLenSq/maxLenSqForVolumeCap);
      };
      
      targetVolume = distanceProgress;
    } else {
      if (sc.getVolume() > 0.9){
        setTargetVolume(0.0, 0.01);
      } 
//      else if (sc.getRate() > 0.7){
//        setTargetPlaybackRate(0.0, 0.6);
//        setTargetVolume(0.9, 0.6);
//      }
    }
    
    updateVolume();
    updatePlaybackRate();
    
    prev = p2;
  }
  
  void setTargetVolume(float progress, float easeFactor){
    targetVolume = progress;
    volumeEaseFactor = easeFactor;
  }
  
  void setTargetPlaybackRate(float progress, float easeFactor){
    targetPlaybackRate = progress;
    playbackEaseFactor = easeFactor;
  }
  
  void updateVolume(){
    float currentVolume = sc.getVolume();
    
    float cVolume;
    float easeFactor = volumeEaseFactor;
    
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
    float easeFactor = playbackEaseFactor;
    
    float volume = sc.getVolume();
    
    if (shouldAdjustRate){
      float sine, sine2;
      
      if (volume == 0.0 || box.isDead){
        sine = 0.0;
        sine2 = 0.0;
      } else {
        sine = sin(millis()/(600.0 * volume));
        sine2 = sin(millis()/(81.0 * volume));
      }
      float sineFactor = 0.8 * volume;
      float sineFactor2 = 0.4 * volume;
      
      if (abs(targetPlaybackRate - currentRate) < 0.01) {
        cVolume = targetPlaybackRate;
      } else {
        cVolume = ((targetPlaybackRate + (sine2 * sineFactor2)) * easeFactor) + ((currentRate + (sine * sineFactor)) * (1.0 - easeFactor));
      }
    } else {
      if (abs(targetPlaybackRate - currentRate) < 0.01) {
        cVolume = targetPlaybackRate;
      } else {
        cVolume = (targetPlaybackRate * easeFactor) + (currentRate * (1.0 - easeFactor));
      }
    }
    
    sc.setPlaybackRate(cVolume);
  }
  
  public void setShouldLoop(boolean shouldLoop){
    sc.setShouldLoop(shouldLoop);
  }
  
  void kill(){
    setTargetPlaybackRate(killRate, 0.1);
    setTargetVolume(1.0, 0.8);
  }
}
