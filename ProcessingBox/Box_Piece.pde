class Box_Piece {
  Poly poly;
  Point startMouse; // For transformation, where the mouse was
  boolean isDragged;
  
  public Box_Piece(Poly poly_, Point startMouse_) { 
    poly = poly_; 
    startMouse = startMouse_; 
    isDragged = true;
  }
  
  public void drawMe(){
    float x, y;
    
    Point offset = startMouse;
    
    if (isDragged){
      Point mouseP = new Point(mouseX, mouseY);
      offset = startMouse.subtractFrom(mouseP);
    }
    
    print(offset.x, offset.y, "\n");
    
    pushMatrix();
    translate(offset.x, offset.y);
    poly.drawMe();
    popMatrix();
  }
  
  public void stopDrag(){
    isDragged = false;
  }
}
