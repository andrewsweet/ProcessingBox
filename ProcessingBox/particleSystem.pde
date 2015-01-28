class Particle {
  private Point position, velocity, acceleration;
  private float particleWidth;
  private int lifespan;
  private float r, g, b, redPercentage;

  Particle(Point p, Point v, Point a, float w, int l) {
    this.position = p;
    this.velocity = v;
    this.acceleration = a;
    this.particleWidth = w;
    this.lifespan = l;


    this.r = random(255);
    this.g = random(255);
    this.b = random(255);
    this.redPercentage = 0f;
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

    lifespan -= 1;
  }

  // Method to display
  public void draw() {

    if(this.isAlive())
      this.update();

    if(random(0,1) < redPercentage)
      fill(255,0,0);
    else
      fill(r, g, b);
    ellipse(position.x, position.y, particleWidth, particleWidth);
  }
}



// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  public Point source, target;
  float particleWidth;
  int leftToGenCount;

  /*
    source: source of target 
    target: target point of the particle
    w: width of each particle
    c: number of particles of emit
    
  */
  ParticleSystem(Point source, Point target, float w, int c) {
    this.source = source;
    this.target = target;
    this.particleWidth = w;
    this.leftToGenCount = c;

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
      float distance = dx*dx + dy*dy;
      dx = dx/sqrt(distance) + random(-0.1,0.1);
      dy = dy/sqrt(distance) + random(-0.1,0.1);
      float dvx = random(-0.01f, 0.01f);
      float dvy = random(-0.01f, 0.01f);
      particles.add(new Particle(new Point(source.x, source.y), 
                                 new Point(2f*dx,2f*dy), 
                                 new Point(dvx, dvy), 
                                 particleWidth, 
                                 100+(int)random(-100,200)));
      leftToGenCount--;
    }
  }

  public void draw() {

    this.update();
    noStroke();

    for (int i = particles.size()-1; i >= 0; i--) 
    {
      particles.get(i).draw();
    }
  }
}
