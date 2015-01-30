Box box;
Tendrils tendrils;
ParticleSystem[] particleSystems;
MusicPlayer song1;
MusicPlayer song2;

boolean isMouseDown;

static int SCREEN_WIDTH = 1024;
static int SCREEN_HEIGHT = 768;

static int tendrilLength = 300;

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
                          tendrilLength);
                          
  setupAudio();

  particleSystems = new ParticleSystem[1];
  for(int i = 0; i < particleSystems.length; i++)
    particleSystems[i] = new ParticleSystem(new Point(SCREEN_WIDTH/2f,SCREEN_HEIGHT/2f), new Point(300f,300f),20f,1000);
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(0); 

  for(int i = 0; i < particleSystems.length; i++)
    particleSystems[i].draw();

  if (box.broken){
    tendrils.draw();
  }
  
  box.draw();
  song1.update();
  
  Point p = box.pieceCoords();
  
  ellipse(p.x, p.y, 5, 5);
}

void onBreakBox(){
  song1.play();
  song2.play();
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
