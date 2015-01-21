class Point {
  public float x, y;
  public Point(float x_, float y_) { x = x_; y = y_; }
  
  public String toString() {
        return "(" + this.x + ", " + this.y + ")";
  }   
  
  float squareDistanceTo(Point p){
  	float dx = p.x - x;
  	float dy = p.y - y;
    return dx*dx + dy*dy;
  }
  
  boolean isAlmostEqual(Point p){
    float epsilon = 0.1;
    
    if ((abs(p.x - x) > epsilon) || (abs(p.y - y) > epsilon)){
      return false;
    }
    
    return true;
  }
  
  Point addTo(Point p){
    return new Point(p.x + this.x, p.y + this.y);
  }
  
  Point subtractFrom(Point p){
    return new Point(p.x - this.x, p.y - this.y);
  }
}

Point randomizeMovePoint(Point p, float maxDistance){
  float angle = random(0.0, 2 * PI);
  float distance = random(0.0, maxDistance);
  
  return new Point(p.x + (cos(angle)*distance), p.y + (sin(angle)*distance));
}

ArrayList<Point>randomlyMovePoints(ArrayList<Point>points, float maxDistance){
  ArrayList<Point> result = new ArrayList<Point>();
  
  for (int i = 0; i < points.size(); ++i){
    Point p = points.get(i);
    
    p = randomizeMovePoint(p, maxDistance);
    
    result.add(p);
  }
  
  print(points, "\n");
  print(result, "\n\n");
  
  return result;
}
