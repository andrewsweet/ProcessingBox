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
		case 2:
			tendrils.setAmplitude(2f*screenRatio, 9f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 4f);
			tendrils.setFrequency(900f,5000f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(255, 230, 230);
			break;
		case 3:
			tendrils.setAmplitude(2f*screenRatio, 7f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 2f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.97f, 1f);
			tendrils.setColor(230, 190, 190);
			break;
		case 4:
			tendrils.setAmplitude(1f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(0.5f, 1.5f);
			tendrils.setFrequency(1000f,200f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(175, 125, 125);
			break;
		case 5:
			tendrils.setAmplitude(1f*screenRatio, 13f*screenRatio);
			tendrils.setAmplitudePercentage(0.1f, 6f);
			tendrils.setFrequency(1000f,5000f);
			tendrils.setFrequencyPercentage(0.1f, 1.9f);
			tendrils.setColor(100, 0, 0);
			break;	
		case 6:
			tendrils.deleteTendrils(4);
			tendrils.setAmplitude(1f*screenRatio, 5f*screenRatio);
			tendrils.setAmplitudePercentage(0.9f, 1.1f);
			tendrils.setFrequency(500f,1500f);
			tendrils.setFrequencyPercentage(0.9f, 1.1f);
			tendrils.setColor(50, 0, 0);
			break;
		case 7:
			tendrils.deleteTendrils(4);
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
	ParticleSystem p1 = null;
	ParticleSystem p2 = null;

	// cos (45 degrees) == 0.707
  float b = 0.707f;
  Point v = new Point(mouseX-boxCenter.x, mouseY-boxCenter.y);
  Point m1 = new Point(boxCenter.x + b*v.x - b*v.y, boxCenter.y + b*v.x + b*v.y);
  Point m2 = new Point(boxCenter.x + b*v.x + b*v.y, boxCenter.y - b*v.x + b*v.y);


	float screenRatio = (float)sketchHeight()/768f;

	float speed = 0f;
	float width = 0f;
	int emitCount = 0;
	float percentRed = 0f;
	int particlePerSpew = 0;
	int lifespan = 0;

	switch(box.numBreaks)
	{
		case 1:
			speed = 5f*screenRatio;
			width = 15f*screenRatio;
			emitCount = 150;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 3;
			lifespan = 130;
	 		break;
		case 2:
			speed = 7f*screenRatio;
			width = 12f*screenRatio;
			emitCount = 200;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 5;
			lifespan = 100;
	 		break;
		case 3:
			speed = 4f*screenRatio;
			width = 15f*screenRatio;
			emitCount = 125;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 2;
			lifespan = 130;
	 		break;
		case 4:
			speed = 1.5f*screenRatio;
			width = 12f*screenRatio;
			emitCount = 100;
			percentRed = (float)box.numBreaks/7f;
			particlePerSpew = 1;
			lifespan = 100;
	 		break;
 		case 5:
 			speed = 20f*screenRatio;
			width = 10f*screenRatio;
			emitCount = 200;
			percentRed = 1f;
			particlePerSpew = 30;
			lifespan = 40;
			break;
		case 6:
			speed = 3f*screenRatio;
			width = 15f*screenRatio;
			emitCount = 150;
			percentRed = 0.8f;
			particlePerSpew = 10;
			lifespan = 70;
			break;
		case 7:
			speed = 1f*screenRatio;
			width = 12f*screenRatio;
			emitCount = 150;
			percentRed = 1f;
			particlePerSpew = 1;
			lifespan = 100;
			break;
	 	default:
	 		break;
 	}

 		p1 = new ParticleSystem(boxCenter, m1, speed, width, 
 													 	emitCount, percentRed, particlePerSpew, lifespan);
		p2 = new ParticleSystem(boxCenter, m2, speed, width, 
 													 	emitCount, percentRed, particlePerSpew, lifespan);
		particleSystems.add(p1);
		particleSystems.add(p2);
}
