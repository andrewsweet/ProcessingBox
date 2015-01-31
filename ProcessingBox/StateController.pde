public void updateTendrilState()
{
	switch(box.numBreaks)
	{
		case 0:
			tendrils.setAmplitude(2f, 7f);
			tendrils.setAmplitudePercentage(0.1f, 2f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.97f, 1f);
			break;	
		case 5:
			tendrils.setAmplitude(1f, 13f);
			tendrils.setAmplitudePercentage(0.1f, 6f);
			tendrils.setFrequency(1000f,5000f);
			tendrils.setFrequencyPercentage(0.1f, 1.9f);
			tendrils.setColor(255, 0, 0);
			break;	
		default:
			break;
	}
}


public void updateParticlesState()
{
	ParticleSystem p = null;
	Point c = new Point(sketchWidth()/2f, sketchHeight()/2f);
	Point m = new Point(mouseX, mouseY);

	switch(box.numBreaks)
	{
		case 0:
	 		p = new ParticleSystem(c, m, 4f, 20f, 100, (float)box.numBreaks/7f, 3, 100);
	 		break;
		case 1:
			//TODO
	 		p = new ParticleSystem(c, m, 6f, 17f, 150, (float)box.numBreaks/7f, 3, 100);
	 		break;
		case 2:
			//TODO
	 		p = new ParticleSystem(c, m, 4f, 20f, 100, (float)box.numBreaks/7f, 3, 100);
	 		break;
		case 3:
			//TODO
	 		p = new ParticleSystem(c, m, 4f, 20f, 100, (float)box.numBreaks/7f, 3, 100);
	 		break;
		case 4:
			//TODO
	 		p = new ParticleSystem(c, m, 2f, 20f, 100, (float)box.numBreaks/7f, 7, 100);
	 		break;
 		case 5:
 			p = new ParticleSystem(c, m, 20f, 15f, 200, 1f, 30, 40);
			break;
		case 6:
			//TODO	
 			p = new ParticleSystem(c, m, 4f, 20f, 100, 0.6f, 3, 100);
			break;
		case 7:
 			p = new ParticleSystem(c, m, 1f, 20f, 100, 0.7f, 3, 100);
			break;
	 	default:
	 		p = new ParticleSystem(c, m, 4f, 20f, 100, (float)box.numBreaks/7f, 3, 100);
	 		break;
 	}

 	if(p != null);
  	particleSystems.add(p);
}
