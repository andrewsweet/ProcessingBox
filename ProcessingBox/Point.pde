class Point {
  public float x, y;
  public Point(float x_, float y_) { x = x_; y = y_; }
  
  float squareDistanceTo(Point p){
  	float dx = p.x - x;
  	float dy = p.y - y;
    return dx*dx + dy*dy;
  }
}
