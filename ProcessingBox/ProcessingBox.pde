int y = 100;
Box box;

//TODO just a demo, remove for final
Tendril[] tendrils;

// The statements in the setup() function 
// execute once when the program begins
void setup() {
  int screenWidth = 1024;
  int screenHeight = 768;
  
  size(screenWidth, screenHeight);  // Size must be the first statement
  stroke(255);     // Set line drawing color to white
  frameRate(30);
  background(0,0,0);
  
  box = new Box(this, screenWidth/2.0, screenHeight/2.0, 50);

  //TODO just a demo, remove for final
  tendrils = new Tendril[10];
  for(int i = 0; i < tendrils.length; i++)
  {
    float x = screenWidth/2.0 + random(-20,20);
    float y = screenHeight/2.0 + random(-20,20);
    float a = random(2f,7f);
    float f = random(1000,10000);
    tendrils[i] = new Tendril(new Point(x,y), new Point(600f, 400f), a, f);
  }
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
}

void mouseDragged(){
  box.mouseDragged();

  //TODO just a demo, remove for final
  for(int i = 0; i < tendrils.length; i++)
  {
    float x = mouseX + random(-5,5);
    float y = mouseY + random(-5,5);
    tendrils[i].setEndPoint(new Point(x, y));
  }
}

void mouseReleased(){
  box.mouseReleased();
}
