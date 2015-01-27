Box box;
Tendrils tendrils;

boolean isMouseDown;

static int SCREEN_WIDTH = 1024;
static int SCREEN_HEIGHT = 768;

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
                          1000f, 10000f, 0.97f, 1f,
                          300);
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(0); 

  tendrils.draw();
  box.draw();
}

void mousePressed(){
  box.mousePressed();
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