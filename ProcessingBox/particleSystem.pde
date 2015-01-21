class Particle {
  float x, y, vx, vy, ax, ay;
  float lifespan, particleWidth;

  Particle(float x, float y, float vx, float vy, float w) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.ax = 0f;
    this.ay = 0f;
    this.particleWidth = w;
  }

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
  float x, y, dx, dy;
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


  void update()
  {
    if(leftToGen > 0)
    {
      //TODO
      particles.add(new Particle(x, y, x, y, particleWidth));
      leftToGen--;
    }

    // update particles
    for (int i = particles.size()-1; i >= 0; i--)
      particles.get(i).update();
  }

  void draw() {
    for (int i = particles.size()-1; i >= 0; i--) 
    {
      particles.get(i).draw();
    }
  }
}
