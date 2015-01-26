Box box;

//TODO just a demo, remove for final
Tendril[] tendrils;
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

  //TODO just a demo, remove for final
  tendrils = new Tendril[10];

  for(int i = 0; i < tendrils.length; i++)
  {
    float x = SCREEN_WIDTH/2.0 + random(-20,20);
    float y = SCREEN_HEIGHT/2.0 + random(-20,20);
    float a = random(2f,7f);
    float f = random(1000,10000);
    tendrils[i] = new Tendril(new Point(x,y), new Point(600f, 400f), a, f, 80000);
  }

  tendrils[0].setBaseTendril(true);
}
// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  background(0); 
  
  //TODO just a demo, remove for final
  for(int i = 0; i < tendrils.length; i++)
    tendrils[i].draw();
  
  box.draw();
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

public void moveTendrils(){
  if (tendrils.length > 0){
    tendrils[0].setEndPoint(new Point(mouseX, mouseY));

    for(int i = 1; i < tendrils.length; i++)
    {
      float x = mouseX + random(-5,5);
      float y = mouseY + random(-5,5);
      tendrils[i].setEndPoint(new Point(x, y));
    }
  }
}