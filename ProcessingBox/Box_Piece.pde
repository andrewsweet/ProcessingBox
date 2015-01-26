class Box_Piece {
  Poly poly;
  Point startMouse; // For transformation, where the mouse was
  boolean isDragged;

  Point pt;
  
  public Box_Piece(Poly poly_, Point startMouse_) { 
    poly = poly_; 
    startMouse = startMouse_; 
    isDragged = true;
  }
  
  public void update(Point p){
    pt = p;

    float x, y;
    
    Point offset = new Point(0, 0);
    
    if (isDragged){;
      offset = startMouse.subtractFrom(pt);
    }

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
