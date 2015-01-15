class Tendril
{
	// start and end point
	private Point p1, p2;

	// how crazy the tendril is
	private float amplitude;

	// point, end point, amplitude
	public Tendril(Point p1, Point p2, float a)
	{
		this.p1	= p1;
		this.p2	= p2;
		this.amplitude = a;
	}

	// for changing tendril properties
	public void changeStartPoint(Point p) { p1 = p; }
	public void changeEndPoint(Point p) { p2 = p; }
	public void changeAmplitude(float a) { amplitude = a; }

	// draws the tendril
	public void draw()
	{
		//TODO actual drawing tendrils, use
		line(p1.x, p1.y, p2.x, p2.y);
	}
}