class Particle {
  private float x, y, vx, vy, ax, ay;
  private float lifespan, particleWidth;

  Particle(float x, float y, float vx, float vy, float w) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    // TODO set acceleration
    this.ax = 0f;
    this.ay = 0f;
    this.particleWidth = w;
  }

  public boolean isAlive() { return lifespan == 0; }

  // Method to update location
  public void update() {
    // euler integration
    vx += ax; vy += ay;
    x += vx; y += vy;

    lifespan -= 1.0;
  }

  // Method to display
  public void draw() {
    fill(255);

    ellipse(x, y, particleWidth, particleWidth);
  }
}



// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class ParticleSystem {
  ArrayList<Particle> particles;
  public float x, y, dx, dy;
  float particleWidth, leftToGen;

  ParticleSystem(float x, float y, float dx, float dy, float w, float l) {
    this.x = x;
    this.y = y;
    this.dx = dx;
    this.dy = dy;
    this.leftToGen = l;

    particles = new ArrayList<Particle>();
    particleWidth = w;
  }


  public void update()
  {
    if(leftToGen > 0)
    {
      //TODO
      particles.add(new Particle(x, y, dx, dy, particleWidth));
      leftToGen--;
    }

    // update particles
    for (int i = particles.size()-1; i >= 0; i--)
    {
      Particle p = particles.get(i);
      if(p.isAlive())
        p.update();
    }
  }

  public void draw() {
    for (int i = particles.size()-1; i >= 0; i--) 
    {
      particles.get(i).draw();
    }
  }
}
