function generateLineSegment(slope, intersection) {
  var result = {
    slope : slope,
    yIntercept : intersection.y,
  };

  var x1, x2, y1, y2;
  if (slope == Number.POSITIVE_INFINITY) {
    x1 = x2 = 0;
    y1 = -10;
    y2 = TODO.sketchHeight() + 10;
  } else {
    x1 = -180;
    x2 = 180;
    y1 = (slope * x1) + yIntercept;
    y2 = (slope * x2) + yIntercept;
  }

  x1 += intersection.x;
  x2 += intersection.x;
  
  result.p1 = {x1, y1};
  result.p2 = {x2, y2};

  return result;
}

function lengthSquared(lineSegment) {
  return squareDistanceTo(lineSegment.p1, lineSegment.p2);
}

// progress is a float between 0.0 and 1.0 inclusive which states
// how far between the points you'd like the new point to be
function pointAtProgress(lineSegment, progress) {
  if (lineSegment.p1 == null || lineSegment.p2 == null) return null;

  var x1, y1, x2, y2;
  x1 = lineSegment.p1.x;
  y1 = lineSegment.p1.y;
  x2 = lineSegment.p2.x;
  y2 = lineSegment.p2.y;

  return {x1+(x2-x1)*progress, y1+(y2-y1)*progress};
}

function dotProductWith(l1, l2) {
  var dx = l1.p2.x - l1.p1.x;
  var dy = l1.p2.y - l1.p1.y;

  var dx2 = l2.p2.x - l2.p1.x;
  var dy2 = l2.p2.y - l2.p1.y;

  return ((dx * dx2) + (dy * dy2));
}

function calculateSlopeAndIntercept(l) {
  var slope = ((l.p1.y - l.p2.y)/(l.p1.x - l.p2.x));
  var yIntercept = (l.p1.y - (slope * l.p1.x));
  
  return {
    slope : slope,
    yIntercept : yIntercept
  };
}

function getRandomPointsOffsetFromLine(lineSegment, numPoints, maxDistance) {
  var progressLeft = 1.0;
  var progressSoFar = 0.0;
  var expectedProgress;

  var o = calculateSlopeAndIntercept(lineSegment);
  var slope = o.slope;
  var yIntercept = o.yIntercept;

  // The higher, the less uniform
  // 0.0 is fully uniform, higher than 1.0 is disallowed
  var variance = 0.12;
  var r;

  var results = [];

  for (var i = 0; i < numPoints; ++i) {
    expectedProgress = progressLeft/(numPoints - i + 1);
    r = random(1.0 - variance, 1.0 + variance);
    progress = (expectedProgress * r) + progressSoFar;

    if (progress > 1.0) {
      progress = 1.0;
    }

    progressLeft -= progress;
    progressSoFar = 1.0 - progressLeft;

    var p = pointAtProgress(lineSegment, progress);
    var c_slope = -(1.0 / slope);

    var r2 = random(-maxDistance, maxDistance);

    var dx, dy;

    if (c_slope == Number.POSITIVE_INFINITY) {
      dx = 0;
      dy = r2;
    } else {
      // asin(x) where x > abs(1.0) will return NaN
      if (c_slope < -1.0) {
        c_slope = -1.0 
      } else if (c_slope > 1.0) {
        c_slope = 1.0
      }
      
      var angle = asin(c_slope);
      
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
function isPointOnLine(line, p) {
  var epsilon = 0.001; // 0.000027 squared is ideal?
  var p1 = lineSegment.p1;
  var p2 = lineSegment.p2;
    
  if (abs(p1.x - p2.x) < epsilon) { // Vertical line.
    if (abs(p.x - p1.x) < epsilon){
      return true;
    } else {
      return false;
    }
  }

  float a = (p2.y - p1.y) / (p2.x - p1.x);
  float b = p1.y - (a * p1.x);
   
  return (abs(p.y - ((a * p.x) + b)) < epsilon);
}

function intersection(line1, line2) {
  var x1 = line1.p1.x;
  var y1 = line1.p1.y;
  var x2 = line1.p2.x;
  var y2 = line1.p2.y;
  var x3 = line2.p1.x;
  var y3 = line2.p1.y;
  var x4 = line2.p2.x;
  var y4 = line2.p2.y;

  var d = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
  if (d == 0) return null;
  
  var xi = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/d;
  var yi = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/d;
  
  return {xi, yi};
}

// point must be on line and between the two coordinates
function isPointOnSegment(lineSegment, p) {
  var p1 = lineSegment.p1;
  var p2 = lineSegment.p2;

  if (p == null) return false;
    
  var xSmall, xBig, ySmall, yBig;
  
  var epsilon = 0.01;
  
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

  return isPointOnLine(lineSegment, p);
}