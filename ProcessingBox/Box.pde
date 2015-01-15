// Greater values increase disparity between split pieces
float MAX_CRACK_VARIATION = 1.4;

// Smaller values lead to more jagged edges, 
// larger values lead to better performance, simplified polygons
float MIN_CRACK_VERTEX_DISTANCE = 10;

public class Box {
  PApplet parent;
  Point center;
  float size;
  color fillColor;
  
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
    
    fillColor = color(255,255,255);
  }
  
  public void draw(){
    parent.fill(fillColor);
    parent.strokeWeight(0);
    
    parent.beginShape();
    
    for (int i = 0; i < coords.size(); i++){
      Point p = coords.get(i);
      
      parent.vertex(p.x, p.y);
    }
    
    parent.endShape();
    
    if (crackPoint != null){
      parent.fill(255, 0, 0);
      ellipse(crackPoint.x, crackPoint.y, 3, 3);
    }
  }
  
  // BAD POINT HIT DETECTION, CONSIDER CONVEX HULL
  boolean isPointInsideShape(Point p){
    return p.distanceTo(center) < (size/2.0);
  }
  
  void generateCrack(Point mouseP){
    float x1 = center.x;
    float y1 = center.y;
    float x2 = mouseP.x;
    float y2 = mouseP.y;
    
    float r = random(0.3, 0.95);
    
    crackPoint = new Point(x1+(x2-x1)*r, y1+(y2-y1)*r);
    
//    mouseP.
  }
  
  void mouseDragged(){
    
    if (!didStartDrag){
      didStartDrag = true;
      
      Point p = new Point(mouseX, mouseY);
      
      startInsideShape = isPointInsideShape(p);
      
      if (startInsideShape){
        generateCrack(p);
      }
    } else if (startInsideShape){
      // Dragging only works if the drag started inside the shape
      
      
      print("drag");
      
      Point p = new Point(mouseX, mouseY);
    }
  }
  
  void mouseReleased(){
    didStartDrag = false;
    startInsideShape = false;
  }
}
