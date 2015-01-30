class Tendril
{
	// start and end point
	private Point p1, p2;

	// how crazy the tendril is
	private float amplitude, frequency, squaredLength;

	// 
	private float lowAmpPercent, highAmpPercent, lowFreqPercent, highFreqPercent;

	// color of tendril
	private int r, g, b;

	// point, end point, amplitude
	public Tendril(Point p1, Point p2,
								 float a, float lap, float hap, 
								 float f, float lfp, float hfp,
								 float l)
	{
		this.p1	= p1;
		this.p2	= p2;
		this.amplitude = a;
		this.lowAmpPercent = lap;
		this.highAmpPercent = hap;
		this.lowFreqPercent = lfp;
		this.highFreqPercent = hfp;
		this.frequency = f;
		this.squaredLength = l*l;

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
	public void setSquareLength(float l) { squaredLength = l*l; }

	

	public Point endpoint(){
		return p2;
	}

	// retracts tendril
	public void update()
	{
	}

	// draws the tendril
	public void draw()
	{
		stroke(r,g,b,150);
		noFill();

		// source: http://forum.processing.org/one/topic/draw-a-sine-curve-between-any-two-points.html
	  float d = p1.squareDistanceTo(p2);
	  d = min(d,squaredLength);

	  float a = atan2(p2.y-p1.y,p2.x-p1.x);
	  pushMatrix();
	    translate(p1.x,p1.y);
	    rotate(a);
	    beginShape();
	      for (float i = 0; i*i <= d; i += 1) {
	      	float ra = random(lowAmpPercent,highAmpPercent);
	      	float rf = random(lowFreqPercent,highFreqPercent);
	        vertex(i,sin(i*TWO_PI*frequency/d+rf)*ra*amplitude);
	      }
	    endShape();
	  popMatrix();

	  if(!isMouseDown) {
	     this.update();
          }
	}
}
