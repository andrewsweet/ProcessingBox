int y = 100;
Box box;

// The statements in the setup() function 
// execute once when the program begins
void setup() {
  int screenWidth = 700;
  int screenHeight = 500;
  
  size(screenWidth, screenHeight);  // Size must be the first statement
  stroke(255);     // Set line drawing color to white
  frameRate(30);
  background(0,0,0);
  
  box = new Box(this, screenWidth/2.0, screenHeight/2.0, 50);
}
// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() { 
  box.draw(); 
}

void mouseDragged(){
  box.mouseDragged();
}

void mouseReleased(){
  box.mouseReleased();
}
