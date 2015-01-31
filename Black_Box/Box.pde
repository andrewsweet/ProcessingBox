import java.util.*;

// Greater values increase disparity between split pieces
float MAX_CRACK_VARIATION = 1.4;

// Smaller values lead to more jagged edges, 
// larger values lead to better performance, simplified polygons
float MIN_CRACK_VERTEX_DISTANCE = 10;

float TEAR_DISTANCE_SQUARED = 400.0;

/*
 The class inherit all the fields, constructors and functions 
 of the java.awt.Polygon class, including contains(), xpoint,ypoint,npoint
*/
 
 // Call .invalidate() any time the points change
class Poly extends java.awt.Polygon{
  private Point center;
  
  public Poly(){
    super();
  }
  
  public Poly(int[] x,int[] y, int n){
    //call the java.awt.Polygon constructor
    super(x,y,n);
  }
  
  void forceCenter(Point p){
    center = p;
  }
  
  Point center(){
    if (center != null) return center;
    
    // Centroid of a Polygon (wikipedia)
    float result = 0.0;
    
    for (int i = 0; i < npoints; i++){
      result += (xpoints[i] * ypoints[(i+1) % npoints]) - (xpoints[(i+1) % npoints] * ypoints[i]);
    }
    
    float signedArea = 0.5 * result;
    
    float x = 0.0;
    float y = 0.0;
    
    for (int i = 0; i < npoints; i++){
      float temp = (xpoints[i] * ypoints[(i+1) % npoints]) - (xpoints[(i+1) % npoints] * ypoints[i]);
      
      x += (xpoints[i] + xpoints[(i+1) % npoints]) * temp;
      y += (ypoints[i] + ypoints[(i+1) % npoints]) * temp;
    }
    
    x = 1.0/(6.0 * signedArea) * x;
    y = 1.0/(6.0 * signedArea) * y;

    center = new Point(x, y);
    
    return center;
  }
 
  void drawMe(){
    beginShape();
    
    Point center = this.center();
    
    for(int i=0; i<npoints; i++){
      vertex(xpoints[i] - center.x, ypoints[i] - center.y);
    }
    endShape(CLOSE);
  }
}

public Poly createPoly(ArrayList<Point>points){
  int n = points.size();
  
  int[] x = new int[n];
  int[] y = new int[n];
  
  for (int i = 0; i < n; ++i){
    Point p = points.get(i);
    
    x[i] = (int)p.x;
    y[i] = (int)p.y;
  }
  
  return new Poly(x,y,n);
}

public class Box {
  public int numBreaks = 0;
  
  PApplet parent;
  Point center;
  float radius;
  color fillColor;
  
  float lastAngle;
  
  boolean didStartDrag;
  boolean startInsideShape;
  boolean broken = false;
  Point startDragPoint;
  boolean isDead = false;
  boolean adjustedStartPoint = false;
  
  float pieceShake;
  
  ArrayList<Point> coords;
  Poly poly;
  Point crackPoint;
  ArrayList<Point> endPoints;
  
  Poly shape1;
  Poly shape2;
  
  // Used to reconnect the pieces;
  Poly border, hitTest;
  
  Box_Piece piece;
  
  // From coords, update poly
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

  public void updatePiece(Point p){
    if (piece != null){
      piece.update(p);
    }
  }
  
  public float angle(){
    if (piece != null){
      return piece.angle;
    }
    
    float delta = 0.0;
    
    for(int i = 0; i < 4; ++i){
      if (abs((lastAngle) % (2 * PI) - delta) < PI){
        return lastAngle/2.0 + delta;
      }
      
      if (abs(lastAngle - delta) < 0.001) return 0;
      
      delta += PI/2.0;
    }
    
    return lastAngle/2.0;
  }
  
  public Point pieceCoords(){
    if (piece != null){
      return piece.coords();
    }
    
    return new Point(0, 0);
  }

  // From poly, update coords
  public void updateCoords(){
    int n = poly.npoints;
    int[] x = poly.xpoints;
    int[] y = poly.ypoints;
    
    ArrayList<Point>toUpdate = new ArrayList<Point>();
    
    for (int i = 0; i < n; ++i){
      Point p = new Point(x[i], y[i]);
      toUpdate.add(p);
    }
    
    coords = toUpdate;
  }
  
  public void setupCoordinates(){
    coords = new ArrayList<Point>();
    
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
    broken = false;
    
    fillColor = color(255, 255, 255);
  }
  
  // based on psuedo-code from http://geomalgorithms.com/a13-_intersect-4.html
  ArrayList<Point> pointsOfIntersectionWithLineSegment(LineSegment seg, Point mouseP){
    Point p0 = seg.p1;
    Point p1 = seg.p2;
    
    int t_entering = 0; // max entering segment param
    int t_leaving = 1; // min leaving seg param
    
    LineSegment dS = new LineSegment(new Point (0, 0), p0.subtractFrom(p1)); // segment direction vector
    
    Point v0 = coords.get(coords.size() - 1);
    Point v1;
    
    ArrayList<Point> intersections = new ArrayList<Point>();
    
    seg.calculateSlopeAndIntercept();
    
    Point intercept = null;
    
    int numCoords = coords.size();
    
    for (int i = 0; i < numCoords; ++i){
      v1 = coords.get(i);
      LineSegment c_seg = new LineSegment(v0, v1);
      
      intercept = seg.intersection(c_seg);
      
      if (c_seg.isPointOnSegment(intercept)){
        intersections.add(intercept);
      }
      
      v0 = v1;
    }
    
    
    
//    intersections = randomlyMovePoints(intersections, 1.0);
    ArrayList<Point> c_coords = coords;//randomlyMovePoints(coords, 0);
    
    boolean shouldAddToShape1 = true;
    intercept = null;
    v0 = c_coords.get(c_coords.size() - 1);
    
    ArrayList<Point> shape1Points = new ArrayList<Point>();
    ArrayList<Point> shape2Points = new ArrayList<Point>();
    
    ArrayList<Point> borderPoints = new ArrayList<Point>();
    
    HashSet<Integer> seenIntersectionPairs = new HashSet<Integer>();
    
    ArrayList<Point> hitTestPoints = new ArrayList<Point>();
    
    for (int i = 0; i < numCoords; ++i){
      v1 = c_coords.get(i);
      LineSegment c_seg = new LineSegment(v0, v1);
      
      if (intercept != null){
        int pairNum = 0;
        
        if (intersections != null){
          for (int j = 0; j < intersections.size(); ++j){
            
            Point p = intersections.get(j);
            
            if (p.isAlmostEqual(intercept)){
              if (!seenIntersectionPairs.contains(pairNum)){
                seenIntersectionPairs.add(pairNum);
                
                int next = pairNum+1;
                
                if (next < intersections.size()){
                  Point a = intersections.get(pairNum);
                  Point b = intersections.get(next);
                  
                  LineSegment crackLine = new LineSegment(a, b);
                  
                  ArrayList<Point> randomPoints = crackLine.getRandomPointsOffsetFromLine(3, 6.0);
                  
                  int numRandomPts = randomPoints.size();
                  
                  for (int k = 0; k < numRandomPts; ++k){
                    Point pt1 = randomPoints.get(k);
                    Point pt2 = randomPoints.get(numRandomPts - (k + 1));
                    
                    if (!shouldAddToShape1){
                      shape1Points.add(pt1);
                      shape2Points.add(pt2);
                    } else {
                      shape1Points.add(pt2);
                      shape2Points.add(pt1);
                    }
                  }
                } else {
                  print("\n\nTHIS IS BAD EDGE NOT PAIRWISE MATCHED\n\n");
                }
              }
              
              // You can do something for inside vs outside edges if need be
              // if (j % 2 == 0)
              break;
            }
            if (j % 2 == 1) pairNum++;
          }
        }
        
        if (shouldAddToShape1){
          shape1Points.add(intercept);
        } else {
          shape2Points.add(intercept);
          hitTestPoints.add(intercept);
        }
      }
      
      intercept = seg.intersection(c_seg);
      
      if (shouldAddToShape1){
        shape1Points.add(v0);
      } else {
        shape2Points.add(v0);
        hitTestPoints.add(v0);
      }
      
      borderPoints.add(v0);
      
      
      if (c_seg.isPointOnSegment(intercept)){
        if (shouldAddToShape1){
          shape1Points.add(intercept);
        } else {
          shape2Points.add(intercept);
          hitTestPoints.add(intercept);
        }
        
        borderPoints.add(intercept);
        
        shouldAddToShape1 = !shouldAddToShape1;
      } else {
        intercept = null;
      }
      
      // After everything is done
      v0 = v1;
    }
    
    if (intercept != null){
      if (shouldAddToShape1){
        shape1Points.add(intercept);
      } else {
        shape2Points.add(intercept);
      }
    }
    
    shape1 = createPoly(shape1Points);
    hitTest = createPoly(hitTestPoints);
    
//    shape2 = createPoly(shape2Points);
    
    // Ensures shape 2 is the one interacting with the mouse
    if (hitTest.contains(startDragPoint.x, startDragPoint.y)){
      shape2 = createPoly(shape2Points);
    } else {
      shape2 = shape1;
      shape1 = createPoly(shape2Points);
    }
    
    border = createPoly(borderPoints);
    
    return intersections;
  }
  
  // BAD POINT HIT DETECTION, CONSIDER CONVEX HULL
  boolean isPointInsideShape(Point p){
    return poly.contains(p.x, p.y);
  }
  
  LineSegment generatePerpendicularLine(Point mouseP){
//    float x1 = center.x;
//    float y1 = center.y;
//    float x2 = mouseP.x;
//    float y2 = mouseP.y;
    
    LineSegment seg = new LineSegment(center, mouseP);
    
    if (abs(center.y - mouseP.y) < 0.001){
      return new LineSegment(3f/0, crackPoint);
    }
    
    seg.calculateSlopeAndIntercept();
    
    float slope = seg.slope;
    
    slope = - (1.0 / slope);
    
    float yIntercept = seg.yIntercept;
    
    return new LineSegment(slope, crackPoint);
  }
  
  void generateCrack(Point mouseP){
    /* 1) Generate a crack point at a random point between 
     * the center of the square and where the mouse is */
    float x1 = center.x;
    float y1 = center.y;
    float x2 = mouseP.x;
    float y2 = mouseP.y;
    
    float r = random(0.3, 0.65);
    
    crackPoint = new Point(x1+(x2-x1)*r, y1+(y2-y1)*r);
    
    /* 2) Find the line perpendicular to the line segment 
     * from crackPoint to the center of the polygon */
    LineSegment crackLine = this.generatePerpendicularLine(mouseP);
    
    /* 3) Generate the crack based on the given line, 
     * with variation on the crack for both pieces */
    //ArrayList<Point> 
    endPoints = this.pointsOfIntersectionWithLineSegment(crackLine, mouseP);
//    endPoints = new ArrayList<Point>();
//    endPoints.add(crackLine.p1);
//    endPoints.add(crackLine.p2);
    
    // Simplify crackPoint to nearest existing point within 
    // radius if possible to reduce polygon complexity
    
//    mouseP.
  }
  
  void mousePressed(){
    if (!isDead){
      didStartDrag = true;
      
      Point p = new Point(mouseX, mouseY);
      startDragPoint = p;
      adjustedStartPoint = false;
      
      startInsideShape = isPointInsideShape(p);
      
      if (startInsideShape){
        generateCrack(p);
      }
    }
  }
  
  public float velocity(){
    if (piece == null || piece.lastPosition == null) return -1;
    
    return sqrt(piece.offset.squareDistanceTo(piece.lastPosition));
  }
  
  void killBox(){
    isDead = true;
    piece.stopDrag();
    piece.launch();
    onDeath();
  }
  
  void breakPieceOff(){
    numBreaks++;  
    
    increasePullCount();

    broken = true;
    
//    if (!shape2.contains(startDragPoint.x, startDragPoint.y)){
//      Poly temp = shape1;
//      shape1 = shape2;
//      shape2 = temp;
//    }
    
    poly = shape1;
    shape1.forceCenter(boxCenter);
    updateCoords();
    
    piece = new Box_Piece(shape2, startDragPoint);
    
    shape1 = null;
    shape2 = null;
    
    float brightness = brightness(fillColor);
    
    brightness = max(brightness - (255.0/(MAX_NUM_BREAKS + 1)), 0);
    
    fillColor = color(brightness);
    
    lastAngle = angle();
    onBreakBox();
    
    if (numBreaks >= MAX_NUM_BREAKS){
      killBox();
    }
  }
  
  void mouseDragged(){
    if (startInsideShape && !isDead){
      // Dragging only works if the drag started inside the shape
      Point p = new Point(mouseX, mouseY);
      
      if (!broken){
        if (startDragPoint.squareDistanceTo(boxCenter) < 60){
          startDragPoint = p;
          adjustedStartPoint = true;
        } else {
          if (adjustedStartPoint){
            generateCrack(startDragPoint);
          }
          
          float squareDist = p.squareDistanceTo(startDragPoint);
          
          if (squareDist > TEAR_DISTANCE_SQUARED){
            setCameraShake(0, 1.0/5.0);
            breakPieceOff();
          } else {
            setCameraShake((squareDist/TEAR_DISTANCE_SQUARED)/6.0, 1.0/5.0);
            pieceShake = (squareDist/TEAR_DISTANCE_SQUARED)/6.0;
          }
        }
      }
    }
  }
  
  void mouseReleased(){
    didStartDrag = false;
    startInsideShape = false;
    
    if (piece != null){
      piece.stopDrag();
    } else {
      setCameraShake(0.0, 0.5);
      shape2 = null;
    }
  }
  
  public void reconnect(){
    setupCoordinates();
    
    border = null;
    piece = null;
    shape1 = null;
    shape2 = null;
    broken = false;
    crackPoint = null;
    endPoints = null;
    startDragPoint = this.center;
    
    onReconnectBox();
  }
  
  public void draw(){  
    pushMatrix();
    translate(boxCenter.x, boxCenter.y);
    
    float angle = angle();
    
    if (abs(angle - lastAngle) > (PI/2.0)){
      angle = (angle+lastAngle)/2.0 + PI;
    } else {
      float delayFactor = 0.27;
      angle = ((delayFactor * angle) + ((1 - delayFactor) * lastAngle));//(angle + lastAngle) / 2.0;
    }
    
    rotate(angle);
    
    lastAngle = angle;
    
    parent.fill(fillColor);
    parent.noStroke();
    
    poly.drawMe();
    
    // Draw the crack line
//    if (crackPoint != null){
//      parent.fill(255, 0, 0);
//      ellipse(crackPoint.x, crackPoint.y, 3, 3);
//      
//      if (endPoints.size() > 1){
//        
//        Point p1 = endPoints.get(0);
//        Point p2 = endPoints.get(1);
//        
//        line(p1.x, p1.y, p2.x, p2.y);
//      }
//    }
    
    if (shape2 != null){
      
      int n = shape2.npoints;
      int[] x = shape2.xpoints;
      int[] y = shape2.ypoints;

      int c = max(0, min((int)brightness(fillColor)+3, 252));
      
      parent.stroke(c);
      parent.noFill();
      
      beginShape();
      for(int i=0; i<n; i++){
        vertex(x[i]-boxCenter.x, y[i]-boxCenter.y);
      }
      endShape(CLOSE);
    }
    
    popMatrix();
    
    if (piece != null){
      piece.drawMe();
      
      if (piece.shouldReconnect && !box.isDead){
        reconnect();
      }
    }
  }
}
