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
    }

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
  }


  public void setTarget(float x, float y)
  {
    target.x = x;
    target.y = y;
  }

  public boolean isAlive()
  {
    return leftToGenCount > 0;
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
        dx = dx/sqrtDistance + random(-0.1,0.1);
        dy = dy/sqrtDistance + random(-0.1,0.1);

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
    }
  }

  public void draw() {

    this.update();
    

    for (int i = 0; i < particles.size(); i++) 
    {
      particles.get(i).draw();
    }
  }
}