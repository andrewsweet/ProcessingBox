// Greater values increase disparity between split pieces
float MAX_CRACK_VARIATION = 1.4;

// Smaller values lead to more jagged edges, 
// larger values lead to better performance, simplified polygons
float MIN_CRACK_VERTEX_DISTANCE = 10;

/*
 The class inherit all the fields, constructors and functions 
 of the java.awt.Polygon class, including contains(), xpoint,ypoint,npoint
*/
 
 // Call .invalidate() any time the points change
class Poly extends java.awt.Polygon{
  public Poly(){
    super();
  }
  
  public Poly(int[] x,int[] y, int n){
    //call the java.awt.Polygon constructor
    super(x,y,n);
  }
 
  void drawMe(){
    beginShape();
    for(int i=0; i<npoints; i++){
      vertex(xpoints[i],ypoints[i]);
    }
    endShape(CLOSE);
  }
}

public class Box {
  PApplet parent;
  Point center;
  float radius;
  color fillColor;
  
  boolean didStartDrag;
  boolean startInsideShape;
  
  ArrayList<Point> coords;
  Poly poly;
  Point crackPoint;
  
  public void updatePoly(){
    int n = coords.size();
    
    int[] xs = new int[n];
    int[] ys = new int[n];
    
    for (int i = 0; i < n; ++i){
      Point p = coords.get(i);
      
      xs[i] = int(p.x);
      ys[i] = int(p.y);
    }
    
    poly = new Poly(xs, ys, n);
  }
  
  public void setupCoordinates(){
    coords.add(new Point(this.center.x - radius, 
                         this.center.y - radius));
                         
    coords.add(new Point(this.center.x + radius, 
                         this.center.y - radius));
                         
    coords.add(new Point(this.center.x + radius,
                         this.center.y + radius));
    
    coords.add(new Point(this.center.x - radius,
                         this.center.y + radius));
                         
    updatePoly();
  }
  
  public Box(PApplet parent, float x, float y, float size) {
    this.parent = parent;
    this.center = new Point(x, y);
    this.radius = size/2.0;
    
    coords = new ArrayList<Point>();
    
    setupCoordinates();
    
    didStartDrag = false;
    startInsideShape = false;
    
    fillColor = color(255, 255, 255);
  }
  
  public void draw(){
    parent.fill(fillColor);
    parent.noStroke();
    
    poly.drawMe();
    
    if (crackPoint != null){
      parent.fill(255, 0, 0);
      ellipse(crackPoint.x, crackPoint.y, 3, 3);
    }
  }
  
  // BAD POINT HIT DETECTION, CONSIDER CONVEX HULL
  boolean isPointInsideShape(Point p){
    return poly.contains(p.x, p.y);
  }
  
  void generateCrack(Point mouseP){
    
    /* 1) Generate a crack point at a random point between 
     * the center of the square and where the mouse is */
    float x1 = center.x;
    float y1 = center.y;
    float x2 = mouseP.x;
    float y2 = mouseP.y;
    
    float r = random(0.3, 0.95);
    
    crackPoint = new Point(x1+(x2-x1)*r, y1+(y2-y1)*r);
    
    /* 2) Find the line perpendicular to the line segment 
     * from crackPoint to the center of the polygon */
    
    /* 3) Generate the crack based on the given line, 
     * with variation on the crack for both pieces */
     
    
    // Simplify crackPoint to nearest existing point within 
    // radius if possible to reduce polygon complexity
    
//    mouseP.
  }
  
  void mousePressed(){
    didStartDrag = true;
    
    Point p = new Point(mouseX, mouseY);
    
    startInsideShape = isPointInsideShape(p);
    
    if (startInsideShape){
      generateCrack(p);
    }
  }
  
  void mouseDragged(){
    if (startInsideShape){
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
