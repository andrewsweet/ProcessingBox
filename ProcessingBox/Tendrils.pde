class Tendrils
{
	Tendril[] tendrils;

	/*
	 c: number of tendrils
	 la: amplitude min
	 ha: amplitude max
	 lf: frequency min
	 hf: frequency max
	 l: max length of the tendril
	*/
	public Tendrils(int c, float la, float ha, float lf, float hf, float l)
	{

	  tendrils = new Tendril[c];
	  for(int i = 0; i < tendrils.length; i++)
	  {
	    float x = SCREEN_WIDTH/2.0 + random(-20,20);
	    float y = SCREEN_HEIGHT/2.0 + random(-20,20);
	    Point p = new Point(x,y);

	    float pa = random(la,ha);
	    float pf = random(lf,hf);

	    tendrils[i] = new Tendril(p, p, pa, pf, l);
	  }
	}
	

	public void setEndPoint(Point p)
	{
	  for(int i = 0; i < tendrils.length; i++)
	  {
	    float x = p.x + random(-5,5);
	    float y = p.y + random(-5,5);
	    tendrils[i].setEndPoint(new Point(x, y));
	  }
	}


	public void draw()
	{
  	for(int i = 0; i < tendrils.length; i++)
    	tendrils[i].draw();
	}



}