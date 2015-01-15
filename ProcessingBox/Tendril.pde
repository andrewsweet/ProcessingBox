class Tendril
{
	private Point p1, p2;
	public Tendril(Point p1, Point p2)
	{
		this.p1	= p1;
		this.p2	= p2;
	}

	public void changeStartPoint(Point p) { p1 = p; }
	public void changeEndPoint(Point p) { p2 = p; }

	public void draw()
	{
		line(p1.x, p1.y, p2.x, p2.y);
	}
}