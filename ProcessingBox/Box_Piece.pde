class Box_Piece {
  Poly poly;
  Point startMouse; // For transformation, where the mouse was
  boolean isDragged;
  boolean shouldReconnect;

  Point pt;
  Point offset;
  
  public Box_Piece(Poly poly_, Point startMouse_) { 
    poly = poly_; 
    startMouse = startMouse_; 
    isDragged = true;
    
    offset = new Point(0, 0);
    shouldReconnect = false;
  }
  
  public void update(Point p){
    LineSegment lineSeg = new LineSegment(boxCenter, p);
    
    float len = sqrt(lineSeg.lengthSquared());
    
    float tendrilLen = sqrt(tendrilLength * tendrilLength);
    
    if (len == 0) len = 1;
    
    float progress = max(0.0, min(((float)tendrilLen)/len, 1.0));
    
    p = lineSeg.pointAtProgress(progress);
    
    pt = p;

    float x, y;
    
    if (isDragged){;
      offset = new Point(0, 0);
      offset = startMouse.subtractFrom(pt);
    } else {
      Point origin = new Point(0, 0);
      
      offset.x = (0.96 * offset.x + 0.04 * origin.x);
      offset.y = (0.96 * offset.y + 0.04 * origin.y);
      
      if (offset.squareDistanceTo(origin) < 14){
        shouldReconnect = true;
      }
    }

    moveTendrils(offset.addTo(startMouse));

    pushMatrix();
    translate(offset.x, offset.y);
    poly.drawMe();
    popMatrix();
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
  }
}
