class LineSegment {
  public Point p1, p2;
  public float slope;
  public float yIntercept;
  
  public LineSegment(Point p1_, Point p2_) { p1 = p1_; p2 = p2_; }
  public LineSegment(float slope_, Point intersection_) {
    slope = slope_;
    yIntercept = intersection_.y;
    
    float x1, x2, y1, y2;
    
    if (slope_ == 3f/0){
      x1 = 0;
      x2 = 0;
      y1 = -10;
      y2 = SCREEN_HEIGHT + 10;
    } else {
      x1 = -180;
      x2 = 180;
      y1 = (slope * x1) + yIntercept;
      y2 = (slope * x2) + yIntercept;
    }
    
    x1 += intersection_.x;
    x2 += intersection_.x;
    
    p1 = new Point(x1, y1);
    p2 = new Point(x2, y2);
  }
  
  
  
  float lengthSquared(){
    return p1.squareDistanceTo(p2);
  }
  
  // progress is a float between 0.0 and 1.0 inclusive which states
  // how far between the points you'd like the new point to be
  Point pointAtProgress(float progress){
    if (p1 == null || p2 == null) return null;
    
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
    
    // y = (m*x) + b
    // y - (m*x)
    yIntercept = (p1.y - (slope * p1.x));
  }
  
  ArrayList<Point> getRandomPointsOffsetFromLine(int numPoints, float maxDistance){
    float progressLeft = 1.0;
    float progressSoFar = 0.0;
    float expectedProgress;
    
    calculateSlopeAndIntercept();
    
    // The higher, the less uniform
    // 0.0 is fully uniform, higher than 1.0 is disallowed
    float variance = 0.12;
    float r;
    
    ArrayList<Point> results = new ArrayList<Point>();
    
    for (int i = 0; i < numPoints; ++i){
      expectedProgress = (progressLeft/(numPoints-i + 1));
      
      r = random(1.0 - variance, 1.0 + variance);
      
      float progress = (expectedProgress * r) + progressSoFar;
      
      if (progress > 1.0) progress = 1.0;
      
      progressLeft -= progress;
      progressSoFar = 1.0 - progressLeft;
      
      Point p = this.pointAtProgress(progress);
      
      float c_slope = -(1.0/slope);
      
      float r2 = random(-maxDistance, maxDistance);
      
      float infinity = 3f/0;
      
      float dx, dy;
      
      if (c_slope == infinity){
        dx = 0;
        dy = r2;
      } else {
        
        // asin(x) where x > abs(1.0) will return NaN
        if (c_slope < -1.0) c_slope = -1.0;
        if (c_slope > 1.0) c_slope = 1.0;
        
        float angle = asin(c_slope);
        
        dx = cos(angle) * r2;
        dy = sin(angle) * r2;
      }
      
      p.x += dx;
      p.y += dy;
      
      results.add(p);
    }
    
    return results;
  }
  
  // point can be on line, but not on line segment
  boolean isPointOnLine(Point p){
    float epsilon = 0.001; // 0.000027 squared is ideal?
    
    if (abs(p1.x - p2.x) < epsilon) // Vertical line.
     {
       if (abs(p.x - p1.x) < epsilon){
         return true;
       } else {
         return false;
       }
     }

     float a = (p2.y - p1.y) / (p2.x - p1.x);
     float b = p1.y - (a * p1.x);
     
     if (abs(p.y - ((a * p.x) + b)) < epsilon){
       return true;
     }
     
     return false;
  }
  
  public Point intersection(LineSegment line2) {
    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    float x3 = line2.p1.x;
    float y3 = line2.p1.y;
    float x4 = line2.p2.x;
    float y4 = line2.p2.y;
      
    float d = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
    if (d == 0) return null;
    
    float xi = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/d;
    float yi = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/d;
    
    return new Point(xi,yi);
  }
  
  // point must be on line and between the two coordinates
  boolean isPointOnSegment(Point p){
    if (p == null) return false;
    
    float xSmall, xBig, ySmall, yBig;
    
    float epsilon = 0.01;
    
    if (p1.x < p2.x){
      xSmall = p1.x;
      xBig = p2.x;
    } else {
      xSmall = p2.x;
      xBig = p1.x;
    }
    
    if (p1.y < p2.y){
      ySmall = p1.y;
      yBig = p2.y;
    } else {
      ySmall = p2.y;
      yBig = p1.y;
    }
    
    if (abs(xBig - xSmall) < epsilon){
      if (abs(p.x - xSmall) > epsilon){
        return false;
      }
    } else if (p.x < xSmall || p.x > xBig) {
      return false;
    }
    
    if (abs(yBig - ySmall) < epsilon){
      if (abs(p.y - ySmall) > epsilon){
        return false;
      }
    } else if (p.y < ySmall || p.y > yBig) {
      return false;
    }
    
    return isPointOnLine(p);
  }
}
