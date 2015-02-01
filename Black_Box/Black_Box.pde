Box box;
Tendrils tendrils;
ArrayList<ParticleSystem> particleSystems;
MusicPlayer song1;
MusicPlayer song2;
MusicPlayer screamControls;

boolean DEBUG_SKIP_INTRO = true;

boolean isMouseDown;

static int maxTendrilLength;

static float cameraShakeOverride = 0.0;
static float cameraShakeDecayFactor = 1.0;

static float targetTextBrightness = 2;
static float textBrightness = 2;
static float textFadeEase = 0.02;

static int ticksWaited = 0; 
static int textFadeWait = 60;

static int outroWaitTime = 11000;
static int timeOfDeath;

static int MAX_NUM_BREAKS = 7;

static Point boxCenter;

static float[] maxScreenShake;
static float[] defaultPlaybackRates;

static PFont mainTitleFont;

int finalTendrilsLeftCount;

void setupAudio(){
  song1 = new MusicPlayer("coltrane.aif");
  song1.pause();
  
  song2 = new MusicPlayer("coltrane.aif");
  song2.pause();
  song2.shouldAdjustRate = false;
  
  screamControls = new MusicPlayer("scream2.aif");
//  screamControls.shouldAdjustRate = false;
  screamControls.pause();
//  screamControls.setShouldLoop(false);
//  screamControls.setVolume(0.24);
}

public int sketchWidth() {
  return displayWidth;
}

public int sketchHeight() {
  return displayHeight;
}

boolean sketchFullScreen() {
  return true;
}

void initMaxScreenShake(){
  int numItems = MAX_NUM_BREAKS + 2;
  
  maxScreenShake = new float[numItems];
  
  for (int i = 0; i < numItems; ++i){
    maxScreenShake[i] = min(abs(5 - abs(i - 0.75 * numItems)) * (9.0 / 6.0), 7.5)/7.5 + 0.1;
  }
}

void initDefaultPlaybackRates(){
  int numItems = MAX_NUM_BREAKS + 2;
  
  defaultPlaybackRates = new float[numItems];
  
  for (int i = 0; i < numItems; ++i){
    defaultPlaybackRates[i] = (abs(5 - abs(i - 0.75 * numItems)) * (2.0/11.0));
    
    if (defaultPlaybackRates[i] > 0.9){
      defaultPlaybackRates[i] += 0.3;
    }
    else if (defaultPlaybackRates[i] < 0.5){
      defaultPlaybackRates[i] = 1.0 - defaultPlaybackRates[i];
    }
  }
}

// The statements in the setup() function 
// execute once when the program begins
void setup() {
  randomSeed(1);
  
  mainTitleFont = createFont("Avenir", 10);
  
  textAlign(CENTER, CENTER);
  
  maxTendrilLength = (int)floor(0.375 * sketchHeight());
  
  initMaxScreenShake();
  initDefaultPlaybackRates();
  
//  size(SCREEN_WIDTH, SCREEN_HEIGHT);  // Size must be the first statement
  stroke(255);     // Set line drawing color to white
  frameRate(30);
  background(0,0,0);
  
  boxCenter = new Point(sketchWidth()/2.0, sketchHeight()/2.0);
  
  box = new Box(this, boxCenter.x, boxCenter.y, 0.0625 * sketchHeight());
  tendrils = new Tendrils(10, 
                          2f, 7f, 0.1f, 2f,
                          1000f, 10000f, 0.97f, 1f,
                          maxTendrilLength);
                          
  setupAudio();

  particleSystems = new ArrayList<ParticleSystem>();
  finalTendrilsLeftCount = 10;

  targetTextBrightness = 280;
  
  if (DEBUG_SKIP_INTRO){
    box.disabled = false;
    box.fillColor = color(255);
  }

}

void shakeCamera(float amount){  
  if (cameraShakeOverride < 0.1) cameraShakeOverride = 0;
  
  amount = max(amount, cameraShakeOverride);
  
  float x = random(-9 * amount, 9 * amount);
  float y = random(-9 * amount, 9 * amount);
  
  translate(x, y);
  
  cameraShakeOverride = cameraShakeOverride * (1 - cameraShakeDecayFactor);
}

void setCameraShake(float amount, float decayFactor){
  cameraShakeOverride = amount;
  cameraShakeDecayFactor = decayFactor;
}

void startInteraction(){
  box.disabled = false;
  println("START INTERACTION");
}

float outroProgress(){
  if (!box.isDead) return 0.0;
  
  return max(0, min((float)textBrightness / 255.0, 1));
}

void drawOutro(){
  if (millis() - timeOfDeath > outroWaitTime){
    
    textBrightness = ceil((textBrightness * (1 - textFadeEase)) + (targetTextBrightness * textFadeEase));
  
    textBrightness = min(255, max(0, textBrightness));
  
    fill(255, 255, 255, textBrightness);
    textFont(mainTitleFont);
    
    float x = sketchWidth()/2.0;
    float h = sketchHeight();
    
    textSize(0.0875 * h);
    text("black box", x, h/6.2);
    
    float textHeight = 0.0875 * h * 0.28;
    
    textSize(textHeight);
    textLeading(textHeight * 1.4);
    text("- animation -\nandrew sweet\ndave yan\n\n- music -\nthe father and the son and the holy ghost\nby john coltrane\n\n\ncreated for experimental animation\nat carnegie mellon, 2015",
          x, (8.0 * h)/15.0);
  }
}

void drawIntro(){
  if (textBrightness > 3){
    fill(textBrightness);
    textFont(mainTitleFont);
    
    textSize(0.0875 * sketchHeight());
    text("black box", sketchWidth()/2.0, sketchHeight()/2.05);
  }
  
  textBrightness = ceil((textBrightness * (1 - textFadeEase)) + (targetTextBrightness * textFadeEase));

  textBrightness = min(255, max(0, textBrightness));

  if (textBrightness > 250){
    if (ticksWaited > textFadeWait){
      targetTextBrightness = -52;
    } else {
      ticksWaited++;
    }
  } else if (textBrightness < 3) {
    textBrightness = 0;
    float targetFill = 300;
    
    float fill = ceil(((float)brightness(box.fillColor) * (1 - textFadeEase)) + (targetFill * textFadeEase));
    fill = min(255, max(0, fill));
    box.fillColor = color(fill);
    
    if (fill > 252){
      box.fillColor = color(255);
      
      startInteraction();
    }
  }
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(box.numBreaks * (40.0 / (MAX_NUM_BREAKS+1)), 0, 0); 

  pushMatrix();
  
  // shake the camera
  if (!box.isDead){
    float shakeAmount = tendrils.currentLengthSquared()/(maxTendrilLength * maxTendrilLength);
    shakeAmount *= shakeAmount;
    
    shakeAmount *= maxScreenShake[box.numBreaks];
    
    shakeCamera(shakeAmount);
  }
  
  // update the particle system
  updateParticlesPosition();
  noStroke();
  rectMode(CENTER);
  colorMode(HSB, 100);
  for(int i = 0; i < particleSystems.size(); i++)
      particleSystems.get(i).draw();
  colorMode(RGB, 255);
  rectMode(CORNER);

  if (box.broken){

    if(finalTendrilsLeftCount == 2 && 
       0f < box.velocity() && box.velocity() < 2f)
    {
      tendrils.deleteTendrils(1);
      finalTendrilsLeftCount--;
    }
    if(finalTendrilsLeftCount == 1 &&
       0f < box.velocity() && box.velocity() < 0.1f)
    {
      tendrils.deleteTendrils(1); 
      finalTendrilsLeftCount--;
      
      screamControls.pause();
    }

    tendrils.draw();
  }
  
  
  box.draw();
  song1.update();
  song2.update();
  screamControls.update();
  
  song2.setTargetPlaybackRate(defaultPlaybackRates[box.numBreaks], 0.3);
  popMatrix();
  
  if (box.disabled){
    drawIntro();
  }
  
  if (box.isDead){
    drawOutro();
  }
}

void onBreakBox(){
  song1.play();
  song2.play();
  
  float denominator = 7.0 + box.numBreaks;
  
  if (box.numBreaks == 5) {
    denominator *= 7.8;
    screamControls.play();
  }
  
  setCameraShake(1.0, 1.0/denominator);
}

void onReconnectBox(){
  song1.pause();
  song2.pause();
}

void onDeath(){
  song1.kill();
  song2.pause();
  
  timeOfDeath = millis();
  
  textBrightness = 0.0;
  targetTextBrightness = 258;
}

void mousePressed(){
  if (!box.isDead){
    box.mousePressed(); 
  }
  isMouseDown = true;
}

void mouseDragged(){
  if (!box.isDead){
    box.mouseDragged();
  }
}

void mouseReleased(){
  if (!box.isDead){
    box.mouseReleased();
  }
  isMouseDown = false;
}

void moveTendrils(Point p)
{
  tendrils.setEndPoint(p);
}



void updateParticlesPosition()
{
  if(particleSystems.size() > 0)
  {
    ParticleSystem p = particleSystems.get(particleSystems.size()-1);
    Point bp = box.pieceCoords();
    if(p.isAlive())
      p.setTarget(bp.x, bp.y);
  }
}

// super hax fast sqrt function
// source: http://forum.processing.org/one/topic/super-fast-square-root.html
public float fastSqrt(float x) {
  int i = Float.floatToRawIntBits(x);
  i = 532676608 + (i >> 1);
  return Float.intBitsToFloat(i);
}


// increase the pulled count
public void increasePullCount() {
  updateTendrilState();
  updateParticlesState();
}
