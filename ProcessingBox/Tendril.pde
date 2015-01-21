class Tendril
{
	// start and end point
	private Point p1, p2;

	// how crazy the tendril is
	private float amplitude, frequency, length;

	// color of tendril
	private int r, g, b;

	// point, end point, amplitude
	public Tendril(Point p1, Point p2, float a, float f, float l)
	{
		this.p1	= p1;
		this.p2	= p2;
		this.amplitude = a;
		this.frequency = f;
		this.length = l;

		this.r = 255;
		this.g = 255;
		this.b = 255;
	}

	// for changing tendril properties
	public void setStartPoint(Point p) { p1 = p; }
	public void setEndPoint(Point p) { p2 = p; }
	public void setAmplitude(float a) { amplitude = a; }
	public void setFrequency(float f) { frequency = f; }
	public void setColor(int r, int g, int b)
	{
		this.r = r; this.g = g; this.b = b;
	}
	public void setSquareLength(float l) { length = l; }

	// retracts tendril
	public void update()
	{
		p2.x = (0.96 * p2.x + 0.04 * p1.x);
		p2.y = (0.96 * p2.y + 0.04 * p1.y);
	}

	// draws the tendril
	public void draw()
	{

		stroke(r,g,b,150);
		noFill();

		// source: http://forum.processing.org/one/topic/draw-a-sine-curve-between-any-two-points.html
	  float d = p1.squareDistanceTo(p2);
	  d = min(d,length);

	  float a = atan2(p2.y-p1.y,p2.x-p1.x);
	  pushMatrix();
	    translate(p1.x,p1.y);
	    rotate(a);
	    beginShape();
	      for (float i = 0; i*i <= d; i += 1) {
	      	float ra = random(0.1,2f);
	      	float rf = random(0.97,1.0);
	        vertex(i,sin(i*TWO_PI*frequency/d+rf)*ra*amplitude);
	      }
	    endShape();
	  popMatrix();

	  if(!isMouseDown)
	  	this.update();
	}
}
