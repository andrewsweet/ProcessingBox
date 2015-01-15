class Tendril
{
	// start and end point
	private Point p1, p2;

	// how crazy the tendril is
	private float amplitude;

	private int r, g, b;

	// point, end point, amplitude
	public Tendril(Point p1, Point p2, float a)
	{
		this.p1	= p1;
		this.p2	= p2;
		this.amplitude = a;

		this.r = 255;
		this.g = 255;
		this.b = 255;
	}

	// for changing tendril properties
	public void setStartPoint(Point p) { p1 = p; }
	public void setEndPoint(Point p) { p2 = p; }
	public void setAmplitude(float a) { amplitude = a; }
	public void setColor(int r, int g, int b)
	{
		this.r = r; this.g = g; this.b = b;
	}

	// draws the tendril
	public void draw()
	{
		//TODO actual drawing tendrils, use
		color(r,g,b);
		line(p1.x, p1.y, p2.x, p2.y);
	}
}