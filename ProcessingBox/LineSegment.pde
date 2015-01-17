class LineSegment {
  public Point p1, p2;
  public float slope;
  public float yIntercept;
  
  public LineSegment(Point p1_, Point p2_) { p1 = p1_; p2 = p2_; }
  public LineSegment(float slope_, float yIntercept_) {
    slope = slope_;
    yIntercept = yIntercept_;
    
    float x1 = -10;
    float x2 = (SCREEN_WIDTH + 10);
    float y1 = (slope * x1) + yIntercept;
    float y2 = (slope * x2) + yIntercept;
    
    p1 = new Point(x1, y1);
    p2 = new Point(x2, y2);
  }
  
  
  
  float lengthSquared(){
    return p1.squareDistanceTo(p2);
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
  
  float dotProductWith(LineSegment v){
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    
    float dx2 = v.p2.x - v.p1.x;
    float dy2 = v.p2.y - v.p1.y;
    
    return ((dx * dx2) + (dy * dy2));
  }
  
  void calculateSlopeAndIntercept(){
    slope = ((p1.y - p2.y)/(p1.x - p2.x));
    // y/(m*x)
    yIntercept = (p1.y / (slope * p1.x));
  }
  
  // point can be on line, but not on line segment
  boolean isPointOnLine(Point p){
    float epsilon = 0.00000001; // 0.000027 squared is ideal?
    
    LineSegment seg = new LineSegment(p1, p);
    
    float result = this.dotProductWith(seg);
    
    if (abs((result * result) - this.lengthSquared()) < epsilon){
      return true;
    }
    
    print(abs((result * result) - this.lengthSquared()));
    return false;
  }
  
  // point must be on line and between the two coordinates
  boolean isPointOnSegment(Point p){
    float xSmall;
    float xBig;
    
    if (p1.x < p2.x){
      xSmall = p1.x;
      xBig = p2.x;
    } else {
      xSmall = p2.x;
      xBig = p1.x;
    }
    
    print(xSmall, p.x, xBig, "\n");
    
    if (p.x < xSmall || p.x > xBig){
      print("Not in range!\n");
      return false;
    } 
    
    return isPointOnLine(p);
  }
}
