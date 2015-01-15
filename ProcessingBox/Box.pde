float MAX_CRACK_VARIATION = 1.4;

public class Box {
  PApplet parent;
  Point center;
  float size;
  
  boolean didStartDrag;
  boolean startInsideShape;
  
  ArrayList<Point> coords;
  Point crackPoint;
  
  public void setupCoordinates(){
    coords.add(new Point(this.center.x - (size/2.0), 
                         this.center.y - (size/2.0)));
                         
    coords.add(new Point(this.center.x + (size/2.0), 
                         this.center.y - (size/2.0)));
                         
    coords.add(new Point(this.center.x + (size/2.0),
                         this.center.y + (size/2.0)));
    
    coords.add(new Point(this.center.x - (size/2.0),
                         this.center.y + (size/2.0)));
  }
  
  public Box(PApplet parent, float x, float y, float size) {
    this.parent = parent;
    this.center = new Point(x, y);
    this.size = size;
    
    coords = new ArrayList<Point>();
    
    setupCoordinates();
    
    didStartDrag = false;
    startInsideShape = false;
  }
  
  public void draw(){
    parent.beginShape();
    
    for (int i = 0; i < coords.size(); i++){
      Point p = coords.get(i);
      
      parent.vertex(p.x, p.y);
    }
    
    parent.endShape();
  }
  
  // BAD POINT HIT DETECTION, CONSIDER CONVEX HULL
  boolean isPointInsideShape(Point p){
    return p.distanceTo(center) < size;
  }
  
  void generateCrack(Point mouseP){
    crackPoint = new Point(x1+(x2-x1)*r, y1+(y2-y1)*r);
    
    mouseP.
  }
  
  void mouseDragged(){
    if (!didStartDrag){
      didStartDrag = true;
      Point p = new Point(mouseX, mouseY);
      
      startInsideShape = isPointInsideShape(p);
      
      generateCrack(p);
    }
    
    // Dragging only works if the drag started inside the shape
    if (startInsideShape){
      print("drag");
    }
  }
  
  void mouseReleased(){
    didStartDrag = false;
    startInsideShape = false;
  }
}
