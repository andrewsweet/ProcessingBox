Box box;
Tendrils tendrils;
ArrayList<ParticleSystem> particleSystems;
MusicPlayer song1;
MusicPlayer song2;
int numberOfTimesPulled;

boolean isMouseDown;

static int SCREEN_WIDTH = 1024;
static int SCREEN_HEIGHT = 768;

static int maxTendrilLength = 300;

static float cameraShakeOverride = 0.0;

static Point boxCenter;

void setupAudio(){
  song1 = new MusicPlayer();
  song1.pause();
  
  song2 = new MusicPlayer();
  song2.pause();
}

// The statements in the setup() function 
// execute once when the program begins
void setup() {
  randomSeed(1);
  
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
  
  float x = random(-8 * amount, 8 * amount);
  float y = random(-8 * amount, 8 * amount);
  
  translate(x, y);
  
  cameraShakeOverride = (cameraShakeOverride * 7.0)/8.0;
}

void setCameraShake(float amount){
  cameraShakeOverride = amount;
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(0); 

  pushMatrix();
  
  float shakeAmount = tendrils.currentLengthSquared()/(maxTendrilLength * maxTendrilLength);
  shakeAmount *= shakeAmount;
  
  shakeCamera(shakeAmount);
  
  for(int i = 0; i < particleSystems.size(); i++)
    particleSystems.get(i).draw();

  if (box.broken){
    tendrils.draw();
  }
  
  box.draw();
  song1.update();
  
  Point p = box.pieceCoords();
  
  ellipse(p.x, p.y, 5, 5);
  popMatrix();
}

void onBreakBox(){
  song1.play();
  song2.play();
  
  setCameraShake(1.0);
}

void onReconnectBox(){
  song1.pause();
  song2.pause();
}

void mousePressed(){
  box.mousePressed(); 
  isMouseDown = true;
}

void mouseDragged(){
  box.mouseDragged();
}

void mouseReleased(){
  box.mouseReleased();
  isMouseDown = false;
}

void moveTendrils(Point p)
{
  tendrils.setEndPoint(p);
}

// super hax fast sqrt function
// source: http://forum.processing.org/one/topic/super-fast-square-root.html
public float fastSqrt(float x) {
  int i = Float.floatToRawIntBits(x);
  i = 532676608 + (i >> 1);
  return Float.intBitsToFloat(i);
}


// increase the pulled count
public void increasePullCount()
{
  updateTendril();
  updateParticles();
  numberOfTimesPulled++;
}
