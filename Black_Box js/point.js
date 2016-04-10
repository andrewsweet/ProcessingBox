function squareDistanceTo(p1, p2) {
  p1 = p1 || 0;
  p2 = p2 || 0;

  var dx = p2.x - p1.x;
  var dy = p2.y - p1.y;

  return dx*dx + dy*dy;
}

function getAngle(p1, p2) {
  var deltaY = p2.y - p1.y;
  var deltaX = p2.x - p1.x;
  return atan2(deltaY, deltaX) * 180 / Math.PI;
}

function isAlmostEqual(p1, p2) {
  var epsilon = 0.1;
    
  return !((abs(p2.x - p1.x) > epsilon) || (abs(p2.y - p1.y) > epsilon));
}

function addTo(p1, p2) {
  return {p1.x + p2.x, p1.y + p2.y};
}

function subtractFrom(p1, p2) {
  return {p2.x - p1.x, p2.y - p2.y};
}

function pointToString(p) {
  return "(" + p.x + ", " + p.y + ")";
}

function randomizeMovePoint(p, maxDistance) {
  var angle = random(0.0, 2 * Math.PI);
  float distance = random(0.0, maxDistance);

  return {p.x + (cos(angle)*distance), p.y + (sin(angle)*distance)};
}

function randomlyMovePoints(points, maxDistance) {
  var result = [];

  for (var i = 0; i < points.size(); ++i){
    var p = points[i];
    p = randomlyMovePoint(p, maxDistance);

    result.push(p);
  }

  return result;
}