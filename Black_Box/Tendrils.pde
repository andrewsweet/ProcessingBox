class Tendrils
{
	private Tendril[] tendrils;
  Point pt1;
  Point pt2;

	/*
	 c: number of tendrils
	 la: amplitude min
	 ha: amplitude max
	 lap: low amplitude percentage (for random movement)
	 hap: high amplitude percentage (for random movement)
	 lf: frequency mino
	 hf: frequency max
	 lfp: low frequency percentage (for random movement)
	 hfp: high frequency percentage (for random movement)
	*/
	public Tendrils(int c, 
									float la, float ha, float lap, float hap,
									float lf, float hf, float lfp, float hfp)
	{

          float centerX = sketchWidth()/2.0;
          float centerY = sketchHeight()/2.0;
          
          pt1 = new Point(centerX, centerY);
          pt2 = pt1;
  
	  tendrils = new Tendril[c];
	  for(int i = 0; i < tendrils.length; i++)
	  {
	    float x = centerX + random(-20,20);
	    float y = centerY + random(-20,20);
	    Point p = new Point(x,y);

	    float pa = random(la,ha);
	    float pf = random(lf,hf);

	    tendrils[i] = new Tendril(p, p, pa, lap, hap, pf, lfp, hfp);
	  }
	}

	// for setting frequency
	public void setFrequency(float lowFreq, float highFreq)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setFrequency(random(lowFreq,highFreq));
	}

	// for setting randomness in frequency
	public void setFrequencyPercentage(float lowPercent, float highPercent)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setFrequencyPercentage(lowPercent, highPercent);
	}

	// for setting amplitude
	public void setAmplitude(float lowAmp, float highAmp)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setAmplitude(random(lowAmp,highAmp));
	}

	// for setting randomness in amplitude
	public void setAmplitudePercentage(float lowPercent, float highPercent)
	{
		for(int i = 0; i < tendrils.length; i++)
	  	tendrils[i].setAmplitudePercentage(lowPercent, highPercent);
	}

	// set color of the tendril
	public void setColor(int r, int g, int b)
	{
		for(int i = 0; i < tendrils.length; i++)
	  {
	  	tendrils[i].setColor(r,g,b);
	  }
	}

	// set where the end point is (start point is always center of box)
	public void setEndPoint(Point p)
	{
    pt2 = p;
  
	  for(int i = 0; i < tendrils.length; i++)
	  {
	    float x = p.x + random(-5,5);
	    float y = p.y + random(-5,5);
	    tendrils[i].setEndPoint(new Point(x, y));
	  }
	}

	// delete numToDelete number of tendrils
	// if there are more than available, all of them will disappear
	public void deleteTendrils(int numToDelete)
	{
  	for(int i = 0; i < tendrils.length; i++)
  	{
  		if(numToDelete <= 0)
  			break;
  		if(!(tendrils[i].shouldDraw))
    		continue;
    	tendrils[i].setShouldDraw(false);
    	numToDelete--;
    }
	}

	// draw the tendrils
	public void draw()
	{
  	for(int i = 0; i < tendrils.length; i++)
  	{
  		if(tendrils[i].shouldDraw)
    		tendrils[i].draw();
    }
	}


  public float currentLengthSquared()
  {
    return pt1.squareDistanceTo(pt2);
  }
}
