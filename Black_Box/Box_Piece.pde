class Box_Piece {
  Poly poly;
  Point startMouse; // For transformation, where the mouse was
  boolean isDragged;
  boolean shouldReconnect;

  float angle;
  float angleOffset = 0;
  
  float acceleration = 1.2;
  Point velocityVector;

  Point pt;
  Point offset;
  
  Point killedTarget;
  Point lastPosition;
  
  Point rotatePoint;
  
  public Box_Piece(Poly poly_, Point startMouse_) { 
    poly = poly_; 
    startMouse = startMouse_; 
    isDragged = true;
    
    offset = new Point(0, 0);
    shouldReconnect = false;
    
    Point t = new Point(offset.x + startMouse.x, offset.y + startMouse.y);
    
    angle = boxCenter.getAngle(t) + angleOffset;
    angleOffset = -90 * angle/(360.0/4.0);

    rotatePoint = new Point(0, 0);
  }
  
  public void update(Point p){
    fill(box.fillColor);
    
    LineSegment lineSeg = new LineSegment(boxCenter, p);
    
    float len = fastSqrt(lineSeg.lengthSquared());
    
    float tendrilLen = fastSqrt(maxTendrilLength * maxTendrilLength);
    
    if (len == 0) len = 1;
    
    float progress = max(0.0, min(((float)tendrilLen)/len, 1.0));
    
    p = lineSeg.pointAtProgress(progress);
    
    pt = p;

    float x, y;
    
    if (isDragged){;
      offset = new Point(0, 0);
      offset = startMouse.subtractFrom(pt);
    } else {
      Point target;
      
      if (!box.isDead){
        target = new Point(0, 0);
      } else {
        target = killedTarget;
      }
        
      lastPosition = new Point(offset.x, offset.y);
        
      offset.x += velocityVector.x;
      offset.y += velocityVector.y;
        
      velocityVector.x *= acceleration;
      velocityVector.y *= acceleration;
//      offset.x = (0.96 * offset.x + 0.04 * target.x);
//      offset.y = (0.96 * offset.y + 0.04 * target.y);
      
      if (offset.squareDistanceTo(target) < 400 && !box.isDead){
        shouldReconnect = true;
      }
    }

    rotatePoint = poly.center(); //new Point(offset.x + boxCenter.x, offset.y + boxCenter.y);
  
    float a = boxCenter.getAngle(rotatePoint.addTo(offset)) + angleOffset;
    angle = (a * PI)/180.0 ;

    pushMatrix();
    translate(offset.x, offset.y);
    pushMatrix();
    translate(rotatePoint.x, rotatePoint.y);
    rotate(angle);
    poly.drawMe();
    popMatrix();
    popMatrix();
    
    moveTendrils(this.coords());
  }
  
  public Point coords(){
    return this.rotatePoint.addTo(this.offset);
  }

  public void drawMe(){
    if (isDragged){
      update(new Point(mouseX, mouseY));
    } else {
      update(pt);
    }
  }
  
  public void stopDrag(){
    isDragged = false;
    
    LineSegment seg = new LineSegment(new Point(0,0), offset);
    
    velocityVector = seg.pointAtProgress(-0.04 + (box.numBreaks * 0.005));
  }
  
  void launch(){
    Point pieceCenter = coords();
    
    LineSegment seg = new LineSegment(boxCenter, pieceCenter);
    
    float progress = 1.27 + random(0.11);
    
    Point targetLocation = seg.pointAtProgress(progress);
    
    killedTarget = targetLocation;
  }
}