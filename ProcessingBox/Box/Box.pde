public class Box {
  PApplet parent;
  float x1 = 10;
  float y1 = 10;
  float x2 = 10;
  float y2 = 20;
  float x3 = 20;
  float y3 = 20;
  float x4 = 20;
  float y4 = 10;
  
  public Box(PApplet parent) {
    this.parent = parent;
  }
  
  public void draw(){
    parent.beginShape();
    parent.vertex(x1,y1);
    parent.vertex(x2,y2);
    parent.vertex(x3,y3);
    parent.vertex(x4,y4);
    // etc;
    parent.endShape();
  }
}
