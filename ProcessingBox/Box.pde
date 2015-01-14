public class Box {
  PApplet parent;
  float centerX;
  float centerY;
  float size;
  
  ArrayList<Float> xs;
  ArrayList<Float> ys;
  
  float x1;
  float x2;
  float x3;
  float x4;
  
  float y1;
  float y2;
  float y3;
  float y4;
  
  public void setupCoordinates(){
    xs.add(this.centerX - (size/2.0));
    xs.add(this.centerX + (size/2.0));
    xs.add(this.centerX + (size/2.0));
    xs.add(this.centerX - (size/2.0));
    
    ys.add(this.centerY - (size/2.0));
    ys.add(this.centerY - (size/2.0));
    ys.add(this.centerY + (size/2.0));
    ys.add(this.centerY + (size/2.0));
  }
  
  public Box(PApplet parent, float x, float y, float size) {
    this.parent = parent;
    this.centerX = x;
    this.centerY = y;
    this.size = size;
    
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
    
    setupCoordinates();
  }
  
  public void draw(){
    parent.beginShape();
    
    for (int i = 0; i < xs.size() && i < ys.size(); i++){
      float x = xs.get(i);
      float y = ys.get(i);
      
      parent.vertex(x, y);
    }
    
    parent.endShape();
  }
}
