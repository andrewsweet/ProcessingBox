Box box;
Tendrils tendrils;
ArrayList<ParticleSystem> particleSystems;
SoundControls sc;
int numberOfTimesPulled;

boolean isMouseDown;

static int SCREEN_WIDTH = 1024;
static int SCREEN_HEIGHT = 768;

boolean shouldPause = true;

// The statements in the setup() function 
// execute once when the program begins
void setup() {
  randomSeed(1);
  
  size(SCREEN_WIDTH, SCREEN_HEIGHT);  // Size must be the first statement
  stroke(255);     // Set line drawing color to white
  frameRate(30);
  background(0,0,0);
  
  box = new Box(this, SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0, 50);
  tendrils = new Tendrils(10, 
                          2f, 7f, 0.1f, 2f,
                          1000f, 10000f, 0.97f, 1f);
                          
  sc = new SoundControls();

  particleSystems = new ArrayList<ParticleSystem>();
  numberOfTimesPulled = 0;
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(0); 

  for(int i = 0; i < particleSystems.size(); i++)
    particleSystems.get(i).draw();

  tendrils.draw();
  box.draw();
  sc.update();
}

void mousePressed(){
  box.mousePressed();
  
  sc.pause(shouldPause);
  shouldPause = !shouldPause;
  
  isMouseDown = true;
}

void mouseDragged(){
  box.mouseDragged();
  tendrils.setEndPoint(new Point(mouseX, mouseY));
}

void mouseReleased(){
  box.mouseReleased();
  isMouseDown = false;
}

void moveTendrils()
{
  tendrils.setEndPoint(new Point(mouseX, mouseY));
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