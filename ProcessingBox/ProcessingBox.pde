Box box;
Tendrils tendrils;
ArrayList<ParticleSystem> particleSystems;
MusicPlayer song1;
MusicPlayer song2;

boolean isMouseDown;

static int SCREEN_WIDTH = 1024;
static int SCREEN_HEIGHT = 768;

static int maxTendrilLength = 300;

static float cameraShakeOverride = 0.0;
static float cameraShakeDecayFactor = 1.0;

static int MAX_NUM_BREAKS = 6;

static Point boxCenter;

static float[] maxScreenShake;
static float[] defaultPlaybackRates;

void setupAudio(){
  song1 = new MusicPlayer();
  song1.pause();
  
  song2 = new MusicPlayer();
  song2.pause();
  song2.shouldAdjustRate = false;
}

void initMaxScreenShake(){
  int numItems = MAX_NUM_BREAKS + 2;
  
  maxScreenShake = new float[numItems];
  
  for (int i = 0; i < numItems; ++i){
    maxScreenShake[i] = min(abs(5 - abs(i - 0.75 * numItems)) * (9.0 / 6.0), 7.5)/7.5 + 0.1;
    println(i, maxScreenShake[i]);
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
  
  initMaxScreenShake();
  initDefaultPlaybackRates();
  
  size(SCREEN_WIDTH, SCREEN_HEIGHT);  // Size must be the first statement
  stroke(255);     // Set line drawing color to white
  frameRate(30);
  background(0,0,0);
  
  boxCenter = new Point(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
  
  box = new Box(this, boxCenter.x, boxCenter.y, 50);
  tendrils = new Tendrils(10, 
                          2f, 7f, 0.1f, 2f,
                          1000f, 10000f, 0.97f, 1f,
                          maxTendrilLength);
                          
  setupAudio();

  particleSystems = new ArrayList<ParticleSystem>();
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

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(box.numBreaks * (40.0 / (MAX_NUM_BREAKS+1)), 0, 0); 

  pushMatrix();
  
  if (!box.isDead){
    float shakeAmount = tendrils.currentLengthSquared()/(maxTendrilLength * maxTendrilLength);
    shakeAmount *= shakeAmount;
    
    shakeAmount *= maxScreenShake[box.numBreaks];
    
    shakeCamera(shakeAmount);
  }
  
  updateParticlesPosition();
  for(int i = 0; i < particleSystems.size(); i++)
      particleSystems.get(i).draw();

  if (box.broken && !box.isDead){
    tendrils.draw();
  }
  
  box.draw();
  song1.update();
  song2.update();
  
  song2.setTargetPlaybackRate(defaultPlaybackRates[box.numBreaks], 0.3);
  
  Point p = box.pieceCoords();
  
  ellipse(p.x, p.y, 5, 5);
  popMatrix();
}

void onBreakBox(){
  song1.play();
  song2.play();
  
  float denominator = 7.0 + box.numBreaks;
  
  if (box.numBreaks == 5) {
    denominator *= 7.8;
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
