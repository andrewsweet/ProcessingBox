import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.*; 
import beads.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Black_Box extends PApplet {

Box box;
Tendrils tendrils;
ArrayList<ParticleSystem> particleSystems;
MusicPlayer song1;
MusicPlayer song2;
MusicPlayer screamControls;
MusicPlayer introSound;

boolean DEBUG_SKIP_INTRO = false;
boolean DEBUG_MUTE_SOUND = false;

boolean isMouseDown;
boolean introDone = false;

static int[] maxTendrilLengths;
static int maxTendrilLength;

static float cameraShakeOverride = 0.0f;
static float cameraShakeDecayFactor = 1.0f;

static float targetTextBrightness = 2;
static float textBrightness = 2;
static float textFadeEase = 0.02f;

static int ticksWaited = 0; 
static int textFadeWait = 60;

static int outroWaitTime = 11000;
static int timeOfDeath;

static int MAX_NUM_BREAKS = 7;
static int DEFAULT_MAX_TENDRIL_LENGTH;

static Point boxCenter;

static float[] maxScreenShake;
static float[] defaultPlaybackRates;

static PFont mainTitleFont;

int finalTendrilsLeftCount;

// for splitting particle systems during retraction
float twoFifthPI = 2*(float)(Math.PI)/5f;

public void setupAudio(){
  song1 = new MusicPlayer("coltrane.aif");
  song1.pause();
  
  song2 = new MusicPlayer("coltrane.aif");
  song2.pause();
  song2.shouldAdjustRate = false;
  
  screamControls = new MusicPlayer("scream.aif");
//  screamControls.shouldAdjustRate = false;
  screamControls.pause();
  screamControls.setShouldLoop(true);

  introSound = new MusicPlayer("intro.aif");
  introSound.pause();
  introSound.shouldAdjustRate = false;
  introSound.setShouldLoop(false);
  introSound.setTargetVolume(1,1);
}

public int sketchWidth() {
  return displayWidth;
}

public int sketchHeight() {
  return displayHeight;
}

public boolean sketchFullScreen() {
  return true;
}

public void initMaxScreenShake(){
  int numItems = MAX_NUM_BREAKS + 2;
  
  maxScreenShake = new float[numItems];
  
  for (int i = 0; i < numItems; ++i){
    maxScreenShake[i] = min(abs(5 - abs(i - 0.75f * numItems)) * (9.0f / 6.0f), 7.5f)/7.5f + 0.1f;
  }
}

public void initDefaultPlaybackRates(){
  int numItems = MAX_NUM_BREAKS + 2;
  
  defaultPlaybackRates = new float[numItems];
  
  for (int i = 0; i < numItems; ++i){
    defaultPlaybackRates[i] = (abs(5 - abs(i - 0.75f * numItems)) * (2.0f/11.0f));
    
    if (defaultPlaybackRates[i] > 0.9f){
      defaultPlaybackRates[i] += 0.3f;
    }
    else if (defaultPlaybackRates[i] < 0.5f){
      defaultPlaybackRates[i] = 1.0f - defaultPlaybackRates[i];
    }
  }
}

public void setupMaxTendrilLengths(){
  int len = MAX_NUM_BREAKS + 1;

  DEFAULT_MAX_TENDRIL_LENGTH = (int)floor(0.375f * sketchHeight());
  int baseLength = DEFAULT_MAX_TENDRIL_LENGTH;

  maxTendrilLengths = new int[len];

  if (MAX_NUM_BREAKS > 6){
    maxTendrilLengths[0] = 0;
    maxTendrilLengths[1] = ceil(baseLength * 1.16f);
    maxTendrilLengths[2] = ceil(baseLength * 1.82f);
    maxTendrilLengths[3] = ceil(baseLength * 0.87f);
    maxTendrilLengths[4] = ceil(baseLength * 1.1f);
    maxTendrilLengths[5] = ceil(baseLength * 0.6f);
    maxTendrilLengths[6] = ceil(baseLength * 1.3f);

    for (int i = 7; i < len; ++i){
      maxTendrilLengths[i] = baseLength;
    }
  }
}

public void updateTendrilLength(){
  float easeFactor = 0.1f;

  // float factor = (float)box.numBreaks/(MAX_NUM_BREAKS-2);

  if (box.numBreaks >= 5){
    maxTendrilLength = ceil(maxTendrilLength * (1.0f + (box.numBreaks/2040.0f)));
  } else if (box.numBreaks == 4){
    maxTendrilLength = floor(maxTendrilLength * (0.99999f - (box.numBreaks/640.0f)));
  } else if (box.numBreaks == 1) {
    // do nothing
  } else {
    maxTendrilLength = ceil(maxTendrilLength * (0.99999f - (box.numBreaks/140.0f)));
  }

  maxTendrilLength = max(maxTendrilLength, 60);
}

// The statements in the setup() function 
// execute once when the program begins
public void setup() {
  randomSeed(1);
  
  mainTitleFont = createFont("Avenir", 10);
  
  textAlign(CENTER, CENTER);
  
  setupMaxTendrilLengths();
  
  initMaxScreenShake();
  initDefaultPlaybackRates();
  
//  size(SCREEN_WIDTH, SCREEN_HEIGHT);  // Size must be the first statement
  stroke(255);     // Set line drawing color to white
  frameRate(30);
  background(0,0,0);
  
  boxCenter = new Point(sketchWidth()/2.0f, sketchHeight()/2.0f);
  
  box = new Box(this, boxCenter.x, boxCenter.y, 0.0625f * sketchHeight());
  tendrils = new Tendrils(10, 
                          2f, 7f, 0.1f, 2f,
                          1000f, 10000f, 0.97f, 1f);
                          
  setupAudio();

  particleSystems = new ArrayList<ParticleSystem>();
  finalTendrilsLeftCount = 10;

  targetTextBrightness = 280;
  
  if (DEBUG_SKIP_INTRO){
    box.disabled = false;
    box.fillColor = color(255);
    introDone = true;
  } else {
    if (!DEBUG_MUTE_SOUND){
      introSound.play();
    }
  }
}

public void shakeCamera(float amount){  
  if (cameraShakeOverride < 0.1f) cameraShakeOverride = 0;
  
  amount = max(amount, cameraShakeOverride);
  
  float x = random(-9 * amount, 9 * amount);
  float y = random(-9 * amount, 9 * amount);
  
  translate(x, y);
  
  cameraShakeOverride = cameraShakeOverride * (1 - cameraShakeDecayFactor);
}

public void setCameraShake(float amount, float decayFactor){
  cameraShakeOverride = amount;
  cameraShakeDecayFactor = decayFactor;
}

public void startInteraction(){
  box.disabled = false;
  println("START INTERACTION");
}

public float outroProgress(){
  if (!box.isDead) return 0.0f;
  
  return max(0, min((float)textBrightness / 255.0f, 1));
}

public void drawOutro(){
  if (millis() - timeOfDeath > outroWaitTime){
    
    textBrightness = ceil((textBrightness * (1 - textFadeEase)) + (targetTextBrightness * textFadeEase));
  
    textBrightness = min(255, max(0, textBrightness));
  
    fill(255, 255, 255, textBrightness);
    textFont(mainTitleFont);
    
    float x = sketchWidth()/2.0f;
    float h = sketchHeight();
    
    textSize(0.0875f * h);
    text("black box", x, h/6.2f);
    
    float textHeight = 0.0875f * h * 0.28f;
    
    textSize(textHeight);
    textLeading(textHeight * 1.4f);
    text("- animation -\nandrew sweet\ndave yan\n\n- music -\nthe father and the son and the holy ghost\nby john coltrane\n\n\ncreated for experimental animation\nat carnegie mellon, 2015",
          x, (8.0f * h)/15.0f);
  }
}

public void drawIntro(){
  if (textBrightness > 3){
    fill(textBrightness);
    textFont(mainTitleFont);
    
    textSize(0.0875f * sketchHeight());
    text("black box", sketchWidth()/2.0f, sketchHeight()/2.05f);
  }
  
  textBrightness = ceil((textBrightness * (1 - textFadeEase)) + (targetTextBrightness * textFadeEase));

  textBrightness = min(255, max(0, textBrightness));

  if (textBrightness > 250){
    if (ticksWaited > textFadeWait){
      targetTextBrightness = -52;
      introSound.setTargetVolume(-52/255.0f, textFadeEase);
    } else {
      ticksWaited++;
    }
  } else if (textBrightness < 3) {
    textBrightness = 0;
    float targetFill = 300;
    
    float fill = ceil(((float)brightness(box.fillColor) * (1 - textFadeEase)) + (targetFill * textFadeEase));
    fill = min(255, max(0, fill));
    box.fillColor = color(fill);
    
    if (box.disabled && fill > 110){
      startInteraction();
    }
    
    if (fill > 252){
      box.fillColor = color(255);
      introDone = true;
    }
  }
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
public void draw() {
  background(box.numBreaks * (40.0f / (MAX_NUM_BREAKS+1)), 0, 0); 

  pushMatrix();
  
  // shake the camera
  if (!box.isDead){
    float shakeAmount = tendrils.currentLengthSquared()/(maxTendrilLength * maxTendrilLength);
    shakeAmount *= shakeAmount;
    
    shakeAmount *= maxScreenShake[box.numBreaks];
    
    shakeCamera(shakeAmount);
  }
  
  // update the particle system
  updateParticlesPosition();
  noStroke();
  rectMode(CENTER);
  colorMode(HSB, 100);
  for(int i = 0; i < particleSystems.size(); i++)
      particleSystems.get(i).draw();
  colorMode(RGB, 255);
  rectMode(CORNER);

  if (box.broken){    
    if(finalTendrilsLeftCount == 2 && 
       0f < box.velocity() && box.velocity() < 2f)
    {
      tendrils.deleteTendrils(1);
      finalTendrilsLeftCount--;
    }
    if(finalTendrilsLeftCount == 1 &&
       0f < box.velocity() && box.velocity() < 0.1f)
    {
      tendrils.deleteTendrils(1); 
      finalTendrilsLeftCount--;
      
      screamControls.setTargetVolume(-0.4f, 0.1f);
    }

    tendrils.draw();
  }
  
  
  box.draw();
  song1.update();
  song2.update();
  
  updateTendrilLength();

  screamControls.update();
  
  song2.setTargetPlaybackRate(defaultPlaybackRates[box.numBreaks], 0.3f);
  popMatrix();
  
  if (!introDone){
    introSound.updateVolume();
//    println();
    drawIntro();
  }
  
  if (box.isDead){
    drawOutro();
  }
}

public void onBreakBox(){
  if (!DEBUG_MUTE_SOUND){
    song1.play();
    song2.play();
  }
  
  float denominator = 7.0f + box.numBreaks;
  
  if (box.numBreaks == 5 && !DEBUG_MUTE_SOUND) {
    denominator *= 7.8f;
    screamControls.play();
  }
  
  if (box.numBreaks > 5 && !DEBUG_MUTE_SOUND){
    screamControls.play();
  }

  maxTendrilLength = maxTendrilLengths[box.numBreaks];
  
  setCameraShake(1.0f, 1.0f/denominator);
}

public void onReconnectBox(){
  song1.pause();
  song2.pause();
  screamControls.pause();
}

public void onDeath(){
  song1.kill();
  song2.pause();
  
  if (!DEBUG_MUTE_SOUND){
    screamControls.play();
  }
  
  timeOfDeath = millis();
  
  textBrightness = 0.0f;
  targetTextBrightness = 258;
}

public void mousePressed(){
  if (!box.isDead){
    box.mousePressed(); 
  }
  isMouseDown = true;
}

public void mouseDragged(){
  if (!box.isDead){
    box.mouseDragged();
  }
}

public void mouseReleased(){
  if (!box.isDead){
    box.mouseReleased();
  }
  isMouseDown = false;
}

public void moveTendrils(Point p)
{
  tendrils.setEndPoint(p);
}



public void updateParticlesPosition()
{
  if(particleSystems.size() > 1)
  {
    ParticleSystem p1 = particleSystems.get(particleSystems.size()-1);
    ParticleSystem p2 = particleSystems.get(particleSystems.size()-2);
    Point bp = box.pieceCoords();

    // start splitting at 10% (0.1f) time left
    float len = DEFAULT_MAX_TENDRIL_LENGTH - 80;

    float sqD = len * len;
    float angle = twoFifthPI * (1.1f - Math.min((tendrils.currentLengthSquared()/sqD)/0.1f, 1f));

    // apply rotation matrix
    Point v = new Point(bp.x-boxCenter.x, bp.y-boxCenter.y);
    Point m1 = new Point(boxCenter.x + cos(angle)*v.x - sin(angle)*v.y, 
                         boxCenter.y + sin(angle)*v.x + cos(angle)*v.y);
    Point m2 = new Point(boxCenter.x + cos(-angle)*v.x - sin(-angle)*v.y, 
                         boxCenter.y + sin(-angle)*v.x + cos(-angle)*v.y);

    if(p1.isAlive())
    {
      p1.setTarget(m1.x, m1.y);
    }
    if(p2.isAlive())
    {
      p2.setTarget(m2.x, m2.y);
    }

    // stop particle emission once box is no longer broken
    if(!box.broken)
    {
      p1.setLeftToGenCount(0);
      p2.setLeftToGenCount(0);
    }
  }
}

// super hax fast sqrt function
// source: http://forum.processing.org/one/topic/super-fast-square-root.html
public float fastSqrt(float x) {
  int i = Float.floatToRawIntBits(x);
  i = 532676608 + (i >> 1);
  return Float.intBitsToFloat(i);
}


// increase the pulled count
public void increasePullCount() {
  updateTendrilState();
  updateParticlesState();
}


// Greater values increase disparity between split pieces
float MAX_CRACK_VARIATION = 1.4f;

static int MAX_HOLD_TIME = 12000;

// Smaller values lead to more jagged edges, 
// larger values lead to better performance, simplified polygons
float MIN_CRACK_VERTEX_DveISTANCE = 10;

float TEAR_DISTANCE_SQUARED = 400.0f;

/*
 The class inherit all the fields, constructors and functions 
 of the java.awt.Polygon class, including contains(), xpoint,ypoint,npoint
*/
 
 // Call .invalidate() any time the points change
class Poly extends java.awt.Polygon{
  private Point center;
  
  public Poly(){
    super();
  }
  
  public Poly(int[] x,int[] y, int n){
    //call the java.awt.Polygon constructor
    super(x,y,n);
  }
  
  public void forceCenter(Point p){
    center = p;
  }
  
  public Point center(){
    if (center != null) return center;
    
    // Centroid of a Polygon (wikipedia)
    float result = 0.0f;
    
    for (int i = 0; i < npoints; i++){
      result += (xpoints[i] * ypoints[(i+1) % npoints]) - (xpoints[(i+1) % npoints] * ypoints[i]);
    }
    
    float signedArea = 0.5f * result;
    
    float x = 0.0f;
    float y = 0.0f;
    
    for (int i = 0; i < npoints; i++){
      float temp = (xpoints[i] * ypoints[(i+1) % npoints]) - (xpoints[(i+1) % npoints] * ypoints[i]);
      
      x += (xpoints[i] + xpoints[(i+1) % npoints]) * temp;
      y += (ypoints[i] + ypoints[(i+1) % npoints]) * temp;
    }
    
    x = 1.0f/(6.0f * signedArea) * x;
    y = 1.0f/(6.0f * signedArea) * y;

    center = new Point(x, y);
    
    return center;
  }
 
  public void drawMe(){
    beginShape();
    
    Point center = this.center();
    
    for(int i=0; i<npoints; i++){
      vertex(xpoints[i] - center.x, ypoints[i] - center.y);
    }
    endShape(CLOSE);
  }
}

public Poly createPoly(ArrayList<Point>points){
  int n = points.size();
  
  int[] x = new int[n];
  int[] y = new int[n];
  
  for (int i = 0; i < n; ++i){
    Point p = points.get(i);
    
    x[i] = (int)p.x;
    y[i] = (int)p.y;
  }
  
  return new Poly(x,y,n);
}

public class Box {
  public int numBreaks = 0;
  
  boolean disabled = true;
  
  PApplet parent;
  Point center;
  float radius;
  int fillColor;
  
  int startHoldTime;
  
  float lastAngle;
  
  boolean didStartDrag;
  boolean startInsideShape;
  boolean broken = false;
  Point startDragPoint;
  boolean isDead = false;
  boolean adjustedStartPoint = false;
  
  float pieceShake;
  
  ArrayList<Point> coords;
  Poly poly;
  Point crackPoint;
  ArrayList<Point> endPoints;
  
  Poly shape1;
  Poly shape2;
  
  // Used to reconnect the pieces;
  Poly border, hitTest;
  
  Box_Piece piece;
  
  // From coords, update poly
  public void updatePoly(){
    int n = coords.size();
    
    int[] xs = new int[n];
    int[] ys = new int[n];
    
    for (int i = 0; i < n; ++i){
      Point p = coords.get(i);
      
      xs[i] = PApplet.parseInt(p.x);
      ys[i] = PApplet.parseInt(p.y);
    }
    
    poly = new Poly(xs, ys, n);
  }

  public void updatePiece(Point p){
    if (piece != null){
      piece.update(p);
    }
  }
  
  public float angle(){
    if (piece != null){
      return piece.angle;
    }
    
    float delta = 0.0f;
    
    for(int i = 0; i < 4; ++i){
      if (abs((lastAngle) % (2 * PI) - delta) < PI){
        return lastAngle/2.0f + delta;
      }
      
      if (abs(lastAngle - delta) < 0.001f) return 0;
      
      delta += PI/2.0f;
    }
    
    return lastAngle/2.0f;
  }
  
  public Point pieceCoords(){
    if (piece != null){
      return piece.coords();
    }
    
    return new Point(0, 0);
  }

  // From poly, update coords
  public void updateCoords(){
    int n = poly.npoints;
    int[] x = poly.xpoints;
    int[] y = poly.ypoints;
    
    ArrayList<Point>toUpdate = new ArrayList<Point>();
    
    for (int i = 0; i < n; ++i){
      Point p = new Point(x[i], y[i]);
      toUpdate.add(p);
    }
    
    coords = toUpdate;
  }
  
  public void setupCoordinates(){
    coords = new ArrayList<Point>();
    
    coords.add(new Point(this.center.x - radius, 
                         this.center.y - radius));
                         
    coords.add(new Point(this.center.x + radius, 
                         this.center.y - radius));
                         
    coords.add(new Point(this.center.x + radius,
                         this.center.y + radius));
    
    coords.add(new Point(this.center.x - radius,
                         this.center.y + radius));
                         
    updatePoly();
  }
  
  public Box(PApplet parent, float x, float y, float size) {
    this.parent = parent;
    this.center = new Point(x, y);
    this.radius = size/2.0f;
    
    coords = new ArrayList<Point>();
    
    setupCoordinates();
    
    didStartDrag = false;
    startInsideShape = false;
    broken = false;
    
    fillColor = color(2);
  }
  
  // based on psuedo-code from http://geomalgorithms.com/a13-_intersect-4.html
  public ArrayList<Point> pointsOfIntersectionWithLineSegment(LineSegment seg, Point mouseP){
    Point p0 = seg.p1;
    Point p1 = seg.p2;
    
    int t_entering = 0; // max entering segment param
    int t_leaving = 1; // min leaving seg param
    
    LineSegment dS = new LineSegment(new Point (0, 0), p0.subtractFrom(p1)); // segment direction vector
    
    Point v0 = coords.get(coords.size() - 1);
    Point v1;
    
    ArrayList<Point> intersections = new ArrayList<Point>();
    
    seg.calculateSlopeAndIntercept();
    
    Point intercept = null;
    
    int numCoords = coords.size();
    
    for (int i = 0; i < numCoords; ++i){
      v1 = coords.get(i);
      LineSegment c_seg = new LineSegment(v0, v1);
      
      intercept = seg.intersection(c_seg);
      
      if (c_seg.isPointOnSegment(intercept)){
        intersections.add(intercept);
      }
      
      v0 = v1;
    }
    
    
    
//    intersections = randomlyMovePoints(intersections, 1.0);
    ArrayList<Point> c_coords = coords;//randomlyMovePoints(coords, 0);
    
    boolean shouldAddToShape1 = true;
    intercept = null;
    v0 = c_coords.get(c_coords.size() - 1);
    
    ArrayList<Point> shape1Points = new ArrayList<Point>();
    ArrayList<Point> shape2Points = new ArrayList<Point>();
    
    ArrayList<Point> borderPoints = new ArrayList<Point>();
    
    HashSet<Integer> seenIntersectionPairs = new HashSet<Integer>();
    
    ArrayList<Point> hitTestPoints = new ArrayList<Point>();
    
    for (int i = 0; i < numCoords; ++i){
      v1 = c_coords.get(i);
      LineSegment c_seg = new LineSegment(v0, v1);
      
      if (intercept != null){
        int pairNum = 0;
        
        if (intersections != null){
          for (int j = 0; j < intersections.size(); ++j){
            
            Point p = intersections.get(j);
            
            if (p.isAlmostEqual(intercept)){
              if (!seenIntersectionPairs.contains(pairNum)){
                seenIntersectionPairs.add(pairNum);
                
                int next = pairNum+1;
                
                if (next < intersections.size()){
                  Point a = intersections.get(pairNum);
                  Point b = intersections.get(next);
                  
                  LineSegment crackLine = new LineSegment(a, b);
                  
                  ArrayList<Point> randomPoints = crackLine.getRandomPointsOffsetFromLine(3, 6.0f);
                  
                  int numRandomPts = randomPoints.size();
                  
                  for (int k = 0; k < numRandomPts; ++k){
                    Point pt1 = randomPoints.get(k);
                    Point pt2 = randomPoints.get(numRandomPts - (k + 1));
                    
                    if (!shouldAddToShape1){
                      shape1Points.add(pt1);
                      shape2Points.add(pt2);
                    } else {
                      shape1Points.add(pt2);
                      shape2Points.add(pt1);
                    }
                  }
                } else {
                  print("\n\nTHIS IS BAD EDGE NOT PAIRWISE MATCHED\n\n");
                }
              }
              
              // You can do something for inside vs outside edges if need be
              // if (j % 2 == 0)
              break;
            }
            if (j % 2 == 1) pairNum++;
          }
        }
        
        if (shouldAddToShape1){
          shape1Points.add(intercept);
        } else {
          shape2Points.add(intercept);
          hitTestPoints.add(intercept);
        }
      }
      
      intercept = seg.intersection(c_seg);
      
      if (shouldAddToShape1){
        shape1Points.add(v0);
      } else {
        shape2Points.add(v0);
        hitTestPoints.add(v0);
      }
      
      borderPoints.add(v0);
      
      
      if (c_seg.isPointOnSegment(intercept)){
        if (shouldAddToShape1){
          shape1Points.add(intercept);
        } else {
          shape2Points.add(intercept);
          hitTestPoints.add(intercept);
        }
        
        borderPoints.add(intercept);
        
        shouldAddToShape1 = !shouldAddToShape1;
      } else {
        intercept = null;
      }
      
      // After everything is done
      v0 = v1;
    }
    
    if (intercept != null){
      if (shouldAddToShape1){
        shape1Points.add(intercept);
      } else {
        shape2Points.add(intercept);
      }
    }
    
    shape1 = createPoly(shape1Points);
    hitTest = createPoly(hitTestPoints);
    
//    shape2 = createPoly(shape2Points);
    
    // Ensures shape 2 is the one interacting with the mouse
    if (hitTest.contains(startDragPoint.x, startDragPoint.y)){
      shape2 = createPoly(shape2Points);
    } else {
      shape2 = shape1;
      shape1 = createPoly(shape2Points);
    }
    
    border = createPoly(borderPoints);
    
    return intersections;
  }
  
  // BAD POINT HIT DETECTION, CONSIDER CONVEX HULL
  public boolean isPointInsideShape(Point p){
    return poly.contains(p.x, p.y);
  }
  
  public LineSegment generatePerpendicularLine(Point mouseP){
//    float x1 = center.x;
//    float y1 = center.y;
//    float x2 = mouseP.x;
//    float y2 = mouseP.y;
    
    LineSegment seg = new LineSegment(center, mouseP);
    
    if (abs(center.y - mouseP.y) < 0.001f){
      return new LineSegment(3f/0, crackPoint);
    }
    
    seg.calculateSlopeAndIntercept();
    
    float slope = seg.slope;
    
    slope = - (1.0f / slope);
    
    float yIntercept = seg.yIntercept;
    
    return new LineSegment(slope, crackPoint);
  }
  
  public void generateCrack(Point mouseP){
    /* 1) Generate a crack point at a random point between 
     * the center of the square and where the mouse is */
    float x1 = center.x;
    float y1 = center.y;
    float x2 = mouseP.x;
    float y2 = mouseP.y;
    
    float r = random(0.2f, 0.55f);
    
    crackPoint = new Point(x1+(x2-x1)*r, y1+(y2-y1)*r);
    
    /* 2) Find the line perpendicular to the line segment 
     * from crackPoint to the center of the polygon */
    LineSegment crackLine = this.generatePerpendicularLine(mouseP);
    
    /* 3) Generate the crack based on the given line, 
     * with variation on the crack for both pieces */
    //ArrayList<Point> 
    endPoints = this.pointsOfIntersectionWithLineSegment(crackLine, mouseP);
//    endPoints = new ArrayList<Point>();
//    endPoints.add(crackLine.p1);
//    endPoints.add(crackLine.p2);
    
    // Simplify crackPoint to nearest existing point within 
    // radius if possible to reduce polygon complexity
    
//    mouseP.
  }
  
  public void mousePressed(){
    if (!disabled && !isDead){
      didStartDrag = true;
      
      Point p = new Point(mouseX, mouseY);
      startDragPoint = p;
      adjustedStartPoint = false;
      
      startInsideShape = isPointInsideShape(p);
      
      if (startInsideShape){
        generateCrack(p);
      }
    }
  }
  
  public float velocity(){
    if (piece == null || piece.lastPosition == null) return -1;
    return fastSqrt(piece.offset.squareDistanceTo(piece.lastPosition));
  }
  
  public void killBox(){
    isDead = true;
    piece.stopDrag();
    piece.launch();
    onDeath();
  }
  
  public void breakPieceOff(){
    numBreaks++;  
    
    increasePullCount();

    broken = true;
    
//    if (!shape2.contains(startDragPoint.x, startDragPoint.y)){
//      Poly temp = shape1;
//      shape1 = shape2;
//      shape2 = temp;
//    }
    
    poly = shape1;
    shape1.forceCenter(boxCenter);
    updateCoords();
    
    piece = new Box_Piece(shape2, startDragPoint);
    
    shape1 = null;
    shape2 = null;
    
    float brightness = brightness(fillColor);
    
    brightness = max(brightness - (255.0f/(MAX_NUM_BREAKS + 1)), 0);
    
    fillColor = color(brightness);
    
    lastAngle = angle();
    onBreakBox();
    
    if (numBreaks >= MAX_NUM_BREAKS){
      killBox();
    }
  }
  
  public void mouseDragged(){
    if (startInsideShape && !isDead){
      // Dragging only works if the drag started inside the shape
      Point p = new Point(mouseX, mouseY);
      
      if (!broken){
        if (startDragPoint.squareDistanceTo(boxCenter) < 60){
          startDragPoint = p;
          adjustedStartPoint = true;
        } else {
          if (adjustedStartPoint){
            generateCrack(startDragPoint);
          }
          
          float squareDist = p.squareDistanceTo(startDragPoint);
          
          if (squareDist > TEAR_DISTANCE_SQUARED){
            setCameraShake(0, 1.0f/5.0f);
            breakPieceOff();
            
            startHoldTime = millis();
          } else {
            setCameraShake((squareDist/TEAR_DISTANCE_SQUARED)/6.0f, 1.0f/5.0f);
            pieceShake = (squareDist/TEAR_DISTANCE_SQUARED)/6.0f;
          }
        }
      }
    }
  }
  
  public void mouseReleased(){
    startHoldTime = -2;
    didStartDrag = false;
    startInsideShape = false;
    
    if (piece != null){
      piece.stopDrag();
    } else {
      setCameraShake(0.0f, 0.5f);
      shape2 = null;
    }
  }
  
  public void reconnect(){
    setupCoordinates();
    
    border = null;
    piece = null;
    shape1 = null;
    shape2 = null;
    broken = false;
    crackPoint = null;
    endPoints = null;
    startDragPoint = this.center;
    
    onReconnectBox();
  }
  
  public void draw(){  
    if (startHoldTime > -1 && millis() - startHoldTime > MAX_HOLD_TIME){
      mouseReleased();
      // return;
    }
    
    pushMatrix();
    translate(boxCenter.x, boxCenter.y);
    
    float angle = angle();
    
    if (abs(angle - lastAngle) > (PI/2.0f)){
      angle = (angle+lastAngle)/2.0f + PI;
    } else {
      float delayFactor = 0.27f;
      angle = ((delayFactor * angle) + ((1 - delayFactor) * lastAngle));//(angle + lastAngle) / 2.0;
    }
    
    rotate(angle);
    
    lastAngle = angle;
    
    parent.fill(fillColor);
    parent.noStroke();
    
    poly.drawMe();
    
    // Draw the crack line
//    if (crackPoint != null){
//      parent.fill(255, 0, 0);
//      ellipse(crackPoint.x, crackPoint.y, 3, 3);
//      
//      if (endPoints.size() > 1){
//        
//        Point p1 = endPoints.get(0);
//        Point p2 = endPoints.get(1);
//        
//        line(p1.x, p1.y, p2.x, p2.y);
//      }
//    }
    
    if (shape2 != null){
      
      int n = shape2.npoints;
      int[] x = shape2.xpoints;
      int[] y = shape2.ypoints;

      int c = max(0, min((int)brightness(fillColor)+3, 252));
      
      parent.stroke(c);
      parent.noFill();
      
      beginShape();
      for(int i=0; i<n; i++){
        vertex(x[i]-boxCenter.x, y[i]-boxCenter.y);
      }
      endShape(CLOSE);
    }
    
    popMatrix();
    
    if (piece != null){
      piece.drawMe();
      
      if (piece.shouldReconnect && !box.isDead){
        reconnect();
      }
    }
  }
}
class Box_Piece {
  Poly poly;
  Point startMouse; // For transformation, where the mouse was
  boolean isDragged;
  boolean shouldReconnect;

  float angle;
  float angleOffset = 0;
  
  float acceleration = 1.2f;
  Point velocityVector;

  float catchDistance;

  Point pt;
  Point offset;
  
  Point killedTarget;
  Point lastPosition;
  
  Point rotatePoint;
  
  public Box_Piece(Poly poly_, Point startMouse_) { 
    poly = poly_; 
    startMouse = startMouse_; 
    isDragged = true;
    
    offset = new Point(0, 0);
    shouldReconnect = false;
    
    Point t = new Point(offset.x + startMouse.x, offset.y + startMouse.y);
    
    angle = boxCenter.getAngle(t) + angleOffset;
    angleOffset = -90 * angle/(360.0f/4.0f);

    rotatePoint = new Point(0, 0);
    
    catchDistance = 2;
  }
  
  public void update(Point p){
    fill(box.fillColor);
    
    LineSegment lineSeg = new LineSegment(boxCenter, p);
    
    float len = fastSqrt(lineSeg.lengthSquared());
    
    float tendrilLen = fastSqrt(maxTendrilLength * maxTendrilLength);
    
    if (len == 0) len = 1;
    
    float progress = max(0.0f, min(((float)tendrilLen)/len, 1.0f));
    
    p = lineSeg.pointAtProgress(progress);
    
    pt = p;

    float x, y;
    
    if (isDragged){;
      offset = new Point(0, 0);
      offset = startMouse.subtractFrom(pt);
    } else {
      Point target;
      
      if (!box.isDead){
        target = new Point(0, 0);
      } else {
        target = killedTarget;
      }
        
      lastPosition = new Point(offset.x, offset.y);
      
      // Makes reconnect is FAST rather than a slow crawl
//      offset.x += velocityVector.x;
//      offset.y += velocityVector.y;
        
      velocityVector.x *= acceleration;
      velocityVector.y *= acceleration;

      offset.x = (0.96f * offset.x + 0.04f * target.x);
      offset.y = (0.96f * offset.y + 0.04f * target.y);
      
      if (offset.squareDistanceTo(target) < (catchDistance * catchDistance) && !box.isDead){
        shouldReconnect = true;
      }
    }

    rotatePoint = poly.center();
  
    float a = boxCenter.getAngle(rotatePoint.addTo(offset)) + angleOffset;
    angle = (a * PI)/180.0f ;

    pushMatrix();
    translate(offset.x, offset.y);
    pushMatrix();
    translate(rotatePoint.x, rotatePoint.y);
    rotate(angle);
    poly.drawMe();
    popMatrix();
    popMatrix();
    
    moveTendrils(this.coords());
  }
  
  public Point coords(){
    return this.rotatePoint.addTo(this.offset);
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
    
    LineSegment seg = new LineSegment(new Point(0,0), offset);
    
    velocityVector = seg.pointAtProgress(-0.04f + (box.numBreaks * 0.005f));
    
    float lenSq = seg.lengthSquared();
    
    float len = fastSqrt(lenSq);
    
    // Used for if reconnect is FAST rather than a slow crawl
//    catchDistance = len / 10.0;
  }
  
  public void launch(){
    Point pieceCenter = coords();
    
    LineSegment seg = new LineSegment(boxCenter, pieceCenter);
    
    float progress = 1.27f + random(0.11f);
    
    Point targetLocation = seg.pointAtProgress(progress);
    
    killedTarget = targetLocation;
  }
}
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
      y2 = sketchHeight() + 10;
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
  
  
  
  public float lengthSquared(){
    return p1.squareDistanceTo(p2);
  }
  
  // progress is a float between 0.0 and 1.0 inclusive which states
  // how far between the points you'd like the new point to be
  public Point pointAtProgress(float progress){
    if (p1 == null || p2 == null) return null;
    
    float x1 = p1.x;
    float y1 = p1.y;
    float x2 = p2.x;
    float y2 = p2.y;
    
    return new Point(x1+(x2-x1)*progress, y1+(y2-y1)*progress);
  }
  
  public float dotProductWith(LineSegment v){
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    
    float dx2 = v.p2.x - v.p1.x;
    float dy2 = v.p2.y - v.p1.y;
    
    return ((dx * dx2) + (dy * dy2));
  }
  
  public void calculateSlopeAndIntercept(){
    slope = ((p1.y - p2.y)/(p1.x - p2.x));
    
    // y = (m*x) + b
    // y - (m*x)
    yIntercept = (p1.y - (slope * p1.x));
  }
  
  public ArrayList<Point> getRandomPointsOffsetFromLine(int numPoints, float maxDistance){
    float progressLeft = 1.0f;
    float progressSoFar = 0.0f;
    float expectedProgress;
    
    calculateSlopeAndIntercept();
    
    // The higher, the less uniform
    // 0.0 is fully uniform, higher than 1.0 is disallowed
    float variance = 0.12f;
    float r;
    
    ArrayList<Point> results = new ArrayList<Point>();
    
    for (int i = 0; i < numPoints; ++i){
      expectedProgress = (progressLeft/(numPoints-i + 1));
      
      r = random(1.0f - variance, 1.0f + variance);
      
      float progress = (expectedProgress * r) + progressSoFar;
      
      if (progress > 1.0f) progress = 1.0f;
      
      progressLeft -= progress;
      progressSoFar = 1.0f - progressLeft;
      
      Point p = this.pointAtProgress(progress);
      
      float c_slope = -(1.0f/slope);
      
      float r2 = random(-maxDistance, maxDistance);
      
      float infinity = 3f/0;
      
      float dx, dy;
      
      if (c_slope == infinity){
        dx = 0;
        dy = r2;
      } else {
        
        // asin(x) where x > abs(1.0) will return NaN
        if (c_slope < -1.0f) c_slope = -1.0f;
        if (c_slope > 1.0f) c_slope = 1.0f;
        
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
  public boolean isPointOnLine(Point p){
    float epsilon = 0.001f; // 0.000027 squared is ideal?
    
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
  public boolean isPointOnSegment(Point p){
    if (p == null) return false;
    
    float xSmall, xBig, ySmall, yBig;
    
    float epsilon = 0.01f;
    
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
class MusicPlayer {
  SoundControls sc;
  float targetPlaybackRate = 0.0f;
  float targetVolume = 0.0f;
  
  float playbackEaseFactor = 0.6f;
  float volumeEaseFactor = 0.6f;
  
  float killRate = 0;
  
  boolean shouldAdjustRate = true;
  
  Point prev;
  
  public MusicPlayer(String fileName) {
    sc = new SoundControls(fileName);
  }
  
  public void pause(){
    sc.pause(true);
  }
  
  public void play(){
    sc.pause(false);
  }

  public void reset(){
    sc.reset();
  }
  
  public void update(){
    Point p2 = box.pieceCoords();
    
    if (!box.isDead){
      float currentLenSq = tendrils.currentLengthSquared();
      float distanceProgress = currentLenSq/(maxTendrilLength*maxTendrilLength);
      
      float minVolUncovered = 0.7f;
      
      if (shouldAdjustRate){
        distanceProgress = max(distanceProgress, minVolUncovered);
        
        if (prev != null){
          float lenSq = prev.squareDistanceTo(p2);
          
          float deltaProgress = lenSq / 90000.0f;
          
          if (deltaProgress > 2.2f){
            deltaProgress = 1.0f / deltaProgress;
          }
          
          targetPlaybackRate = deltaProgress + 0.8f;
        }
      }
      
      float maxLenSqForVolumeCap = 4200.0f;
      
      if (currentLenSq < maxLenSqForVolumeCap) {
        distanceProgress = minVolUncovered * (currentLenSq/maxLenSqForVolumeCap);
      };
      
      distanceProgress = max(min(distanceProgress, 1), 0);
      
      float distanceCap = 0.1f;
      
      if (distanceProgress < distanceCap){
        distanceProgress = sin(((distanceProgress - 0.04f)/distanceCap) * (PI/2.0f)) * minVolUncovered;
      } else {
        distanceProgress = minVolUncovered;
      }
      
      targetVolume = distanceProgress;
    } else {
      if (sc.getVolume() > 0.9f){
        setTargetVolume(0.0f, 0.01f);
      } 
//      else if (sc.getRate() > 0.7){
//        setTargetPlaybackRate(0.0, 0.6);
//        setTargetVolume(0.9, 0.6);
//      }
    }
    
    updateVolume();
    updatePlaybackRate();
    
    prev = p2;
  }
  
  public void setTargetVolume(float progress, float easeFactor){
    targetVolume = progress;
    volumeEaseFactor = easeFactor;
  }
  
  public void setTargetPlaybackRate(float progress, float easeFactor){
    targetPlaybackRate = progress;
    playbackEaseFactor = easeFactor;
  }
  
  public void updateVolume(){
    float currentVolume = sc.getVolume();
    
    float cVolume;
    float easeFactor = volumeEaseFactor;
    
    if (abs(targetVolume - currentVolume) < 0.01f) {
      cVolume = targetVolume;
    } else {
      cVolume = (targetVolume * easeFactor) + (currentVolume * (1.0f - easeFactor));
    }
    
    sc.setVolume(cVolume);
  }
  
  public void updatePlaybackRate(){
    float currentRate = sc.getRate();
    
    float cVolume;
    float easeFactor = playbackEaseFactor;
    
    float volume = sc.getVolume();
    
    if (shouldAdjustRate){
      float sine, sine2;
      
      if (volume == 0.0f || box.isDead){
        sine = 0.0f;
        sine2 = 0.0f;
      } else {
        sine = sin(millis()/(600.0f * volume));
        sine2 = sin(millis()/(81.0f * volume));
      }
      float sineFactor = 0.8f * volume;
      float sineFactor2 = 0.4f * volume;
      
      if (abs(targetPlaybackRate - currentRate) < 0.01f) {
        cVolume = targetPlaybackRate;
      } else {
        cVolume = ((targetPlaybackRate + (sine2 * sineFactor2)) * easeFactor) + ((currentRate + (sine * sineFactor)) * (1.0f - easeFactor));
      }
    } else {
      if (abs(targetPlaybackRate - currentRate) < 0.01f) {
        cVolume = targetPlaybackRate;
      } else {
        cVolume = (targetPlaybackRate * easeFactor) + (currentRate * (1.0f - easeFactor));
      }
    }
    
    sc.setPlaybackRate(cVolume);
  }
  
  public void setShouldLoop(boolean shouldLoop){
    sc.setShouldLoop(shouldLoop);
  }
  
  public void kill(){
    setTargetPlaybackRate(killRate, 0.1f);
    setTargetVolume(1.0f, 0.8f);
  }
}
class Point {
  public float x, y;
  public Point(float x_, float y_) { x = x_; y = y_; }
  
  public String toString() {
        return "(" + this.x + ", " + this.y + ")";
  }   
  
  public float squareDistanceTo(Point p){
    if (p == null) return 0;
    
  	float dx = p.x - x;
  	float dy = p.y - y;
    return dx*dx + dy*dy;
  }
  
  public float getAngle(Point p2) {
    float deltaY = p2.y - this.y;
    float deltaX = p2.x - this.x;
    return atan2(deltaY, deltaX) * 180 / PI;
  }
  
  public boolean isAlmostEqual(Point p){
    float epsilon = 0.1f;
    
    if ((abs(p.x - x) > epsilon) || (abs(p.y - y) > epsilon)){
      return false;
    }
    
    return true;
  }
  
  public Point addTo(Point p){
    return new Point(p.x + this.x, p.y + this.y);
  }
  
  public Point subtractFrom(Point p){
    return new Point(p.x - this.x, p.y - this.y);
  }
}

public Point randomizeMovePoint(Point p, float maxDistance){
  float angle = random(0.0f, 2 * PI);
  float distance = random(0.0f, maxDistance);
  
  return new Point(p.x + (cos(angle)*distance), p.y + (sin(angle)*distance));
}

public ArrayList<Point>randomlyMovePoints(ArrayList<Point>points, float maxDistance){
  ArrayList<Point> result = new ArrayList<Point>();
  
  for (int i = 0; i < points.size(); ++i){
    Point p = points.get(i);
    
    p = randomizeMovePoint(p, maxDistance);
    
    result.add(p);
  }
  
  //print(points, "\n");
  //print(result, "\n\n");
  
  return result;
}

 

class SoundControls {
  
  AudioContext ac;
  
  UGen rateUGen;
  SamplePlayer sp;
  Gain gain;
  
  public void initialize(String fileName) {
    ac = new AudioContext();
    
    String sourceFile = dataPath(fileName);
    
    println(sourceFile);
    
    try{
      Sample sample = new Sample(sourceFile);
      
      sp = new SamplePlayer(ac, sample);
      
      rateUGen = new Glide(ac, 1.0f);
    
      sp.setRate(rateUGen);
//      sp.setRateEnvelope(rateEnvelope);

      //loop the sample at its end points
      sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
      sp.getLoopStartEnvelope().setValue(0);
      sp.getLoopEndEnvelope().setValue((float)sample.getLength());
    
      gain = new Gain(ac, 1, 0.1f);
      gain.addInput(sp);
      ac.out.addInput(gain);
      ac.start();
      
      setPlaybackRate(1.0f);
      setVolume(1.0f);
    } catch (Exception e) {
      //do anything you want to handle the exception
      println("DONE GOOFED");
    } 
  }
  
  public void setShouldLoop(boolean shouldLoop){
    if (shouldLoop){
      sp.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    } else {
      sp.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
    }
  }
  
  public float x, y;
  public SoundControls(String fileName) {
    this.initialize(fileName);
  }
  
  public void setPlaybackRate(float speed){
    rateUGen.setValue(speed);
  }
  
  public void setVolume(float volume){
    gain.setGain(max(min(volume, 1.0f), 0.0f));
  }
  
  public void update(){
//    float speed = 4.0 * ((float)mouseX - (width/2.0))/width;
//    float volume = (float)mouseY / (height * 1.0);
//    
//    setPlaybackRate(speed);
//    setVolume(volume);
    
    //println(speed, gain.getGain());
  }
  
  public void pause(boolean shouldPause){
    sp.pause(shouldPause);
  }
  
  public float getRate(){
     return rateUGen.getValue();
  }
  
  public float getVolume(){
    return gain.getGain();
  }

  public void reset(){
    sp.reset();
  }
}
public void updateTendrilState()
{
	float screenRatio = (float)sketchHeight()/768f;

	switch(box.numBreaks)
	{
		case 1:
			tendrils.setAmplitude(2f*screenRatio, 7f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 2f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.97f, 1f);
			tendrils.setColor(255, 255, 255);
			break;	
		case 2:
			//TODO
			tendrils.setAmplitude(2f*screenRatio, 9f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 4f);
			tendrils.setFrequency(900f,5000f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(255, 230, 230);
			break;
		case 3:
			//TODO
			tendrils.setAmplitude(2f*screenRatio, 7f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 2f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.97f, 1f);
			tendrils.setColor(230, 190, 190);
			break;
		case 4:
			tendrils.setAmplitude(1f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(0.5f, 1.5f);
			tendrils.setFrequency(1000f,200f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(175, 75, 75);
			break;
		case 5:
			tendrils.setAmplitude(1f*screenRatio, 13f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 6f);
			tendrils.setFrequency(1000f,5000f);
			tendrils.setFrequencyPercentage(0.1f, 1.9f);
			tendrils.setColor(100, 0, 0);
			break;	
		case 6:
			tendrils.deleteTendrils(4);
			tendrils.setAmplitude(1f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(0.9f, 1.1f);
			tendrils.setFrequency(500f,1500f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(50, 0, 0);
			break;
		case 7:
			tendrils.deleteTendrils(4);
			finalTendrilsLeftCount = 2;
			tendrils.setAmplitude(5f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(1f, 1f);
			tendrils.setFrequency(1500f,1500f);
			tendrils.setFrequencyPercentage(1f, 1f);
			tendrils.setColor(25, 0, 0);
		default:
			break;
	}
}


public void updateParticlesState()
{
	ParticleSystem p1 = null;
	ParticleSystem p2 = null;

	// cos (45 degrees) == 0.707
  float b = 0.707f;
  Point v = new Point(mouseX-boxCenter.x, mouseY-boxCenter.y);
  Point m1 = new Point(boxCenter.x + b*v.x - b*v.y, boxCenter.y + b*v.x + b*v.y);
  Point m2 = new Point(boxCenter.x + b*v.x + b*v.y, boxCenter.y - b*v.x + b*v.y);


	float screenRatio = (float)sketchHeight()/768f;

	float speed = 0f;
	float width = 0f;
	int emitCount = 0;
	float percentRed = 0f;
	int particlePerSpew = 0;
	int lifespan = 0;

	switch(box.numBreaks)
	{
		case 1:
			speed = 5f*screenRatio;
			width = 15f*screenRatio;
			emitCount = 150;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 3;
			lifespan = 130;
	 		break;
		case 2:
			speed = 7f*screenRatio;
			width = 12f*screenRatio;
			emitCount = 200;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 5;
			lifespan = 100;
	 		break;
		case 3:
			speed = 4f*screenRatio;
			width = 15f*screenRatio;
			emitCount = 125;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 2;
			lifespan = 130;
	 		break;
		case 4:
			speed = 1.5f*screenRatio;
			width = 12f*screenRatio;
			emitCount = 100;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 1;
			lifespan = 100;
	 		break;
 		case 5:
 			speed = 20f*screenRatio;
			width = 10f*screenRatio;
			emitCount = 200;
			percentRed = 1f;
			particlePerSpew = 30;
			lifespan = 40;
			break;
		case 6:
			speed = 3f*screenRatio;
			width = 15f*screenRatio;
			emitCount = 150;
			percentRed = 0.8f;
			particlePerSpew = 10;
			lifespan = 70;
			break;
		case 7:
			speed = 1f*screenRatio;
			width = 12f*screenRatio;
			emitCount = 150;
			percentRed = 1f;
			particlePerSpew = 1;
			lifespan = 100;
			break;
	 	default:
	 		break;
 	}

 		p1 = new ParticleSystem(boxCenter, m1, speed, width, 
 													 	emitCount, percentRed, particlePerSpew, lifespan);
		p2 = new ParticleSystem(boxCenter, m2, speed, width, 
 													 	emitCount, percentRed, particlePerSpew, lifespan);
		particleSystems.add(p1);
		particleSystems.add(p2);
}
class Tendril
{
	// start and end point
	private Point p1, p2;

	// how crazy the tendril is
	private float amplitude, frequency;

	// 
	private float lowAmpPercent, highAmpPercent, lowFreqPercent, highFreqPercent;

	// color of tendril
	private int r, g, b;

	public boolean shouldDraw;

	// point, end point, amplitude
	public Tendril(Point p1, Point p2,
								 float a, float lap, float hap, 
								 float f, float lfp, float hfp)
	{
		this.p1	= p1;
		this.p2	= p2;
		this.amplitude = a;
		this.lowAmpPercent = lap;
		this.highAmpPercent = hap;
		this.lowFreqPercent = lfp;
		this.highFreqPercent = hfp;
		this.frequency = f;
		this.shouldDraw = true;

		this.r = 255;
		this.g = 255;
		this.b = 255;
	}

	// for changing tendril properties
	public void setStartPoint(Point p) { p1 = p; }
	public void setEndPoint(Point p) { p2 = p; }
	public void setAmplitude(float a) { amplitude = a; }
	public void setAmplitudePercentage(float lowPercent, float highPercent)
	{ lowAmpPercent = lowPercent; highAmpPercent = highPercent; }
	public void setFrequency(float f) { frequency = f; }
	public void setFrequencyPercentage(float lowPercent, float highPercent)
	{ lowFreqPercent = lowPercent; highFreqPercent = highPercent; }
	public void setColor(int r, int g, int b)
	{
		this.r = r; this.g = g; this.b = b;
	}
	public void setShouldDraw(boolean b) { shouldDraw = b; }

	

	public Point endpoint(){
		return p2;
	}

	// draws the tendril
	public void draw()
	{
		if(!shouldDraw)
			return;

		float randomPercentage = 0.2f;
		stroke(r*random(1-randomPercentage,1+randomPercentage),
					 g*random(1-randomPercentage,1+randomPercentage),
					 b*random(1-randomPercentage,1+randomPercentage),
					 200);
		noFill();

		// source: http://forum.processing.org/one/topic/draw-a-sine-curve-between-any-two-points.html
	  float d = p1.squareDistanceTo(p2);

	  float a = atan2(p2.y-p1.y,p2.x-p1.x);
	  pushMatrix();
	    translate(p1.x,p1.y);
	    rotate(a);
	    beginShape();
	      for (float i = 0f; i*i <= d; i += 1f) {
	      	float ra = random(lowAmpPercent,highAmpPercent);
	      	float rf = random(lowFreqPercent,highFreqPercent);

	      	// when tendril retracts, it gets smaller by this ratio
	      	float rad = Math.min(d/(TEAR_DISTANCE_SQUARED*30f), 1f);

	        vertex(i,sin(i*TWO_PI*frequency/d+rf)*ra*amplitude*rad);
	      }
	    endShape();
	  popMatrix();
	}
}
class Tendrils
{
	private Tendril[] tendrils;
  Point pt1;
  Point pt2;

	/*
	 c: number of tendrils
	 la: amplitude min
	 ha: amplitude max
	 lap: low amplitude percentage (for random movement)
	 hap: high amplitude percentage (for random movement)
	 lf: frequency mino
	 hf: frequency max
	 lfp: low frequency percentage (for random movement)
	 hfp: high frequency percentage (for random movement)
	*/
	public Tendrils(int c, 
									float la, float ha, float lap, float hap,
									float lf, float hf, float lfp, float hfp)
	{

          float centerX = sketchWidth()/2.0f;
          float centerY = sketchHeight()/2.0f;
          
          pt1 = new Point(centerX, centerY);
          pt2 = pt1;
  
	  tendrils = new Tendril[c];
	  for(int i = 0; i < tendrils.length; i++)
	  {
	    float x = centerX + random(-20,20);
	    float y = centerY + random(-20,20);
	    Point p = new Point(x,y);

	    float pa = random(la,ha);
	    float pf = random(lf,hf);

	    tendrils[i] = new Tendril(p, p, pa, lap, hap, pf, lfp, hfp);
	  }
	}

	// for setting frequency
	public void setFrequency(float lowFreq, float highFreq)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setFrequency(random(lowFreq,highFreq));
	}

	// for setting randomness in frequency
	public void setFrequencyPercentage(float lowPercent, float highPercent)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setFrequencyPercentage(lowPercent, highPercent);
	}

	// for setting amplitude
	public void setAmplitude(float lowAmp, float highAmp)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setAmplitude(random(lowAmp,highAmp));
	}

	// for setting randomness in amplitude
	public void setAmplitudePercentage(float lowPercent, float highPercent)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setAmplitudePercentage(lowPercent, highPercent);
	}

	// set color of the tendril
	public void setColor(int r, int g, int b)
	{
		for(int i = 0; i < tendrils.length; i++)
	  {
	  	tendrils[i].setColor(r,g,b);
	  }
	}

	// set where the end point is (start point is always center of box)
	public void setEndPoint(Point p)
	{
    pt2 = p;
  
	  for(int i = 0; i < tendrils.length; i++)
	  {
	    float x = p.x + random(-5,5);
	    float y = p.y + random(-5,5);
	    tendrils[i].setEndPoint(new Point(x, y));
	  }
	}

	// delete numToDelete number of tendrils
	// if there are more than available, all of them will disappear
	public void deleteTendrils(int numToDelete)
	{
  	for(int i = 0; i < tendrils.length; i++)
  	{
  		if(numToDelete <= 0)
  			break;
  		if(!(tendrils[i].shouldDraw))
    		continue;
    	tendrils[i].setShouldDraw(false);
    	numToDelete--;
    }
	}

	// draw the tendrils
	public void draw()
	{
  	for(int i = 0; i < tendrils.length; i++)
  	{
  		if(tendrils[i].shouldDraw)
    		tendrils[i].draw();
    }
	}


  public float currentLengthSquared()
  {
    return pt1.squareDistanceTo(pt2);
  }
}
class Particle {
  private Point position, velocity, acceleration;
  private float particleWidth;
  private int lifespan;
  private float h, s, v, origS, origV;
  private float angle, deltaAngle;

  Particle(Point p, Point v, Point a, float w, int l, float redPercentage) {
    // record property
    this.position = p;
    this.velocity = v;
    this.acceleration = a;
    this.particleWidth = w;
    this.lifespan = l;
      
    // set rotation
    this.angle = random(0f,3.14f);
    this.deltaAngle = random(-0.05f, 0.05f);

    // determine if this is red or not
    if(random(0,1) < redPercentage)
    { 
      this.h = 0; 
      this.s = 100;
      this.v = random(70, 100); 
    } 
    else
    {
      this.h = random(100); 
      this.s = Math.max(random(75, 100) - 20*(box.numBreaks - 3), 0); 
      this.v = random(75, 100) - Math.min(25, Math.max(10*(box.numBreaks - 3), 0));
    }

    this.origS = this.s;
    this.origV = this.v;
  }

  public boolean isAlive() { return lifespan != 0; }

  // Method to update location
  public void update() 
  {
    // euler integration
    velocity.x += acceleration.x; 
    velocity.y += acceleration.y;
    position.x += velocity.x;
    position.y += velocity.y;
    angle += deltaAngle;

    lifespan -= 1;
    if(lifespan == 0)
      particleWidth *= 1.1f;
  }

  // Method to display
  public void draw() {

    if(this.isAlive())
      this.update();
    
    // decrease saturation and value as time goes on
    if(h != 0f)
    {
      float tempS = Math.max(origS - 40*(box.numBreaks - 2), 0f);
      if(tempS >= 0f && s >= tempS)
        s -= 1f;
      float tempV = origV - 10*(box.numBreaks - 3);
      if(tempV >= 50f && v >= tempV)
        v -= 1f;

      fill(h, s, v*(1f-(outroProgress() * 0.3f)));
    }
    else
      fill(h, s, v);

    pushMatrix();
      translate(position.x,position.y);
      rotate(angle);
      rect(0f, 0f, particleWidth, particleWidth);
    popMatrix();
    
  }
}



// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  public Point source, target;
  float particleWidth, speed;
  int leftToGenCount, lifespan;
  float percentRed;
  int particlePerSpew;
  boolean isDead;
  
  /*
    source: source of target 
    target: target point of the particle
    speed: speed of particle
    w: width of each particle
    c: number of particles of emit
    percentRed: proability of this being red (0f - 1f)
    particlePerSpew: for each step in lifespan, how many particles to emit
    lifespan: how long the particle lasts before splattering
  */
  ParticleSystem(Point source, Point target, float speed, float w, int c, float percentRed, int particlePerSpew, int lifespan) {
    this.source = source;
    this.target = target;
    this.speed = speed;
    this.particleWidth = w;
    this.leftToGenCount = c;
    this.percentRed = percentRed;
    this.particlePerSpew = particlePerSpew;
    this.lifespan = lifespan;

    particles = new ArrayList<Particle>();
    particleWidth = w;

    this.isDead = false;
  }


  public void setTarget(float x, float y)
  {
    target.x = x;
    target.y = y;
  }

  public void setLeftToGenCount(int l)
  {
    leftToGenCount = l;
  }
  
  public boolean isAlive()
  {
    return !isDead;
  }
  
  public void update()
  {
    // add a point
    if(leftToGenCount > 0)
    {
      for(int i = 0; i < particlePerSpew; i++)
      {
        // distance and direction
        float dx = target.x - source.x;
        float dy = target.y - source.y;
        float sqrtDistance = fastSqrt(dx*dx + dy*dy);
        dx = dx/sqrtDistance + random(-0.1f,0.1f);
        dy = dy/sqrtDistance + random(-0.1f,0.1f);

        // acceleration
        float ax = random(-0.01f, 0.01f);
        float ay = random(-0.01f, 0.01f);

        particles.add(new Particle(new Point(source.x, source.y), 
                                   new Point(speed*random(0.7f,1.3f)*dx,
                                             speed*random(0.7f,1.3f)*dy), 
                                   new Point(ax, ay), 
                                   particleWidth + random(-particleWidth/3f, particleWidth/3f), 
                                   lifespan+(int)random(-95*lifespan/100,lifespan/2), 
                                   percentRed));
      }
      leftToGenCount--;
    } else if (!isDead){
      
      isDead = true;

      onDeath();
    }
  }

  public void onDeath(){
    box.mouseReleased();
  }

  public void draw() {

    this.update();
    

    for (int i = 0; i < particles.size(); i++) 
    {
      particles.get(i).draw();
    }
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "Black_Box" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
