public void updateTendril()
{
	switch(numberOfTimesPulled)
	{
		case 0:
			tendrils.setAmplitude(2f, 7f);
			tendrils.setAmplitudePercentage(0.1f, 2f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.97f, 1f);
			break;	
		case 1:
			tendrils.setAmplitude(1f, 10f);
			tendrils.setAmplitudePercentage(0.1f, 5f);
			tendrils.setFrequency(1000f,3000f);
			tendrils.setFrequencyPercentage(0.5f, 1.5f);
			break;	
		default:
			break;
	}
}


public void updateParticles()
{
	ParticleSystem p = null;
	switch(numberOfTimesPulled)
	{
		case 0:
	 		p = new ParticleSystem(
	          new Point(SCREEN_WIDTH/2f,SCREEN_HEIGHT/2f), 
	          new Point(mouseX, mouseY),
	          4f, 20f, 100, (float)numberOfTimesPulled/7f, 3);
	 		break;
	 	default:
	 		break;
 	}

 	if(p != null);
  	particleSystems.add(p);
}