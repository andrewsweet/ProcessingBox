class LineSegment {
  public Point p1, p2;
  public LineSegment(Point p1_, Point p2_) { p1 = p1_; p2 = p2_; }
  
  float length(){
    return sqrt(sq(p1.x - p2.x) + sq(p1.y - p2.y));
  }
  
  // progress is a float between 0.0 and 1.0 inclusive which states
  // how far between the points you'd like the new point to be
  Point pointAtProgress(float progress){
    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    
    return new Point(x1+(x2-x1)*progress, y1+(y2-y1)*progress);
  }
}
