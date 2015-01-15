class Point {
  public float x, y;
  public Point(float x_, float y_) { x = x_; y = y_; }
  
  float squareDistanceTo(Point p){
    return sq(p.x - x) + sq(p.y - y);
  }
}
