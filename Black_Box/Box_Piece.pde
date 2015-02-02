class Box_Piece {
  Poly poly;
  Point startMouse; // For transformation, where the mouse was
  boolean isDragged;
  boolean shouldReconnect;

  float angle;
  float angleOffset = 0;
  
  float acceleration = 1.2;
  Point velocityVector;

  float catchDistance;

  Point pt;
  Point offset;
  
  Point killedTarget;
  Point lastPosition;
  
  Point rotatePoint;

  Point lastMouse;
  Point lastLastMouse;
  
  boolean isLaunching = false;

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
    
    catchDistance = 2;
  }
  
  public void update(Point p){
    if (isLaunching){
      launch();
    }

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
      
      // Makes reconnect is FAST rather than a slow crawl
//      offset.x += velocityVector.x;
//      offset.y += velocityVector.y;
        
      velocityVector.x *= acceleration;
      velocityVector.y *= acceleration;

      if (target != null){
        offset.x = (0.96 * offset.x + 0.04 * target.x);
        offset.y = (0.96 * offset.y + 0.04 * target.y);
      }
      
      if (offset.squareDistanceTo(target) < (catchDistance * catchDistance) && !box.isDead){
        shouldReconnect = true;
      }
    }

    rotatePoint = poly.center();
  
    float a = boxCenter.getAngle(rotatePoint.addTo(offset)) + angleOffset;
    angle = (a * PI)/180.0;
    
    moveTendrils(this.coords());
  }
  
  public Point coords(){
    return this.rotatePoint.addTo(this.offset);
  }
  
  public void update(){
    if (isDragged){
      update(new Point(mouseX, mouseY));
    } else {
      update(pt);
    }
  }

  public void drawMe(){
    pushMatrix();
    translate(offset.x, offset.y);
    pushMatrix();
    translate(rotatePoint.x, rotatePoint.y);
    rotate(angle);
    poly.drawMe();
    popMatrix();
    popMatrix();
  }
  
  public void stopDrag(){
    isDragged = false;
    
    LineSegment seg = new LineSegment(new Point(0,0), offset);
    
    velocityVector = seg.pointAtProgress(-0.04 + (box.numBreaks * 0.005));
    
    float lenSq = seg.lengthSquared();
    
    float len = fastSqrt(lenSq);
    
    // Used for if reconnect is FAST rather than a slow crawl
//    catchDistance = len / 10.0;
  }
  
  void launch(){
    isLaunching = true;

    Point mouse = new Point(mouseX, mouseY);

    if (lastLastMouse != null){
      isLaunching = false;
      stopDrag();

      Point pieceCenter = coords();
      
      LineSegment seg = new LineSegment(lastLastMouse, mouse);
      
      float lenSq = seg.lengthSquared();

      if (lenSq > 80){

        float progress;

        if (lenSq > 20000){
          progress = 20000.0/lenSq;
        } else {
          progress = 1.01 + min((30.0/lenSq), 0.3);
        }

        Point targetLocation = seg.pointAtProgress(progress);
        
        targetLocation.x -= boxCenter.x;
        targetLocation.y -= boxCenter.y;

        killedTarget = targetLocation;
      } else {
        float progress = 1.5; //1.27 + random(0.11);
        
        Point targetLocation = seg.pointAtProgress(progress);
        
        targetLocation.x -= boxCenter.x;
        targetLocation.y -= boxCenter.y;

        killedTarget = targetLocation;
      }
    }

    lastLastMouse = lastMouse;
    lastMouse = mouse;
  }
}
