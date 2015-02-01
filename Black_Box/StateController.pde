public void updateTendrilState()
{
	float screenRatio = (float)sketchHeight()/768f;

	switch(box.numBreaks)
	{
		case 1:
			tendrils.setAmplitude(2f*screenRatio, 7f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 2f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.97f, 1f);
			tendrils.setColor(255, 255, 255);
			break;	
		case 5:
			tendrils.setAmplitude(1f*screenRatio, 13f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 6f);
			tendrils.setFrequency(1000f,5000f);
			tendrils.setFrequencyPercentage(0.1f, 1.9f);
			tendrils.setColor(100, 0, 0);
			break;	
		case 6:
			tendrils.deleteTendrils(5);
			tendrils.setAmplitude(1f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(0.9f, 1.1f);
			tendrils.setFrequency(500f,1500f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(50, 0, 0);
			break;
		case 7:
			tendrils.deleteTendrils(3);
			finalTendrilsLeftCount = 2;
			tendrils.setAmplitude(5f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(1f, 1f);
			tendrils.setFrequency(1500f,1500f);
			tendrils.setFrequencyPercentage(1f, 1f);
			tendrils.setColor(25, 0, 0);
		default:
			break;
	}
}


public void updateParticlesState()
{
	ParticleSystem p = null;
	Point c = new Point(sketchWidth()/2f, sketchHeight()/2f);
	Point m = new Point(mouseX, mouseY);
	float screenRatio = (float)sketchHeight()/768f;

	switch(box.numBreaks)
	{
		case 1:
	 		p = new ParticleSystem(c, m, 4f*screenRatio, 15f*screenRatio, 
	 													 100, (float)box.numBreaks/7f, 3, 100);
	 		break;
		case 2:
	 		p = new ParticleSystem(c, m, 6f*screenRatio, 12f*screenRatio, 
	 													 150, (float)box.numBreaks/7f, 5, 100);
	 		break;
		case 3:
	 		p = new ParticleSystem(c, m, 4f*screenRatio, 15f*screenRatio, 
	 													 125, (float)box.numBreaks/7f, 3, 130);
	 		break;
		case 4:
	 		p = new ParticleSystem(c, m, 1.5f*screenRatio, 12f*screenRatio, 
	 													 100, (float)box.numBreaks/7f, 1, 100);
	 		break;
 		case 5:
 			p = new ParticleSystem(c, m, 20f*screenRatio, 10f*screenRatio, 
 														 200, 1f, 30, 40);
			break;
		case 6:
 			p = new ParticleSystem(c, m, 3f*screenRatio, 15f*screenRatio, 
 														 100, 0.6f, 3, 100);
			break;
		case 7:
 			p = new ParticleSystem(c, m, 1f*screenRatio, 12f*screenRatio, 
 														 100, 1f, 1, 100);
			break;
	 	default:
	 		break;
 	}

 	if(p != null);
  	particleSystems.add(p);
}
