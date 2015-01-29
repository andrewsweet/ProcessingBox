class Particle {
  private Point position, velocity, acceleration;
  private float particleWidth;
  private int lifespan;
  private float h, s, v;
  private float angle, deltaAngle;

  Particle(Point p, Point v, Point a, float w, int l, float redPercentage) {
    this.position = p;
    this.velocity = v;
    this.acceleration = a;
    this.particleWidth = w;
    this.lifespan = l;
    
    this.angle = random(0f,3.14f);
    this.deltaAngle = random(-0.05f, 0.05f);

    if(random(0,1) < redPercentage)
    {
      this.h = 0;
      this.s = 100;
      this.v = random(70, 100);
    }
    else
    {
      this.h = random(100);
      this.s = random(75, 100);
      this.v = random(75, 100);
    }
    
    

    
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
  float particleWidth;
  int leftToGenCount;
  float percentRed;
  
  /*
    source: source of target 
    target: target point of the particle
    w: width of each particle
    c: number of particles of emit
    
  */
  ParticleSystem(Point source, Point target, float w, int c, float percentRed, ) {
    this.source = source;
    this.target = target;
    this.particleWidth = w;
    this.leftToGenCount = c;
    this.percentRed = percentRed;

    particles = new ArrayList<Particle>();
    particleWidth = w;
  }


  public void setTarget(Point t)
  {
    target = t;
  }


  public void update()
  {
    if(leftToGenCount > 0)
    {
      float dx = target.x - source.x;
      float dy = target.y - source.y;
      float sqrtDistance = fastSqrt(dx*dx + dy*dy);
      dx = dx/sqrtDistance + random(-0.1,0.1);
      dy = dy/sqrtDistance + random(-0.1,0.1);
      float dvx = random(-0.01f, 0.01f);
      float dvy = random(-0.01f, 0.01f);
      particles.add(new Particle(new Point(source.x, source.y), 
                                 new Point(2f*dx,2f*dy), 
                                 new Point(dvx, dvy), 
                                 particleWidth + random(-particleWidth/30f, particleWidth/30f), 
                                 100+(int)random(-50,200),0.7f));
      leftToGenCount--;
    }
  }

  public void draw() {

    this.update();
    noStroke();
    rectMode(CENTER);

    colorMode(HSB, 100);
    for (int i = 0; i < particles.size(); i++) 
    {
      particles.get(i).draw();
    }
    colorMode(RGB, 255);
    rectMode(CORNER);
  }
}