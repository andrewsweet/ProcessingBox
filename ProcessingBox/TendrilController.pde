public void updateTendril()
{
	switch(numberOfTimesPulled)
	{
		case 0:
			tendrils.setFrequency(1000f,10000f);
			break;	
		case 1:
			tendrils.setFrequency(1000f,10000f);
			tendrils.setAmplitude(10f, 30f);
			break;	
		default:
			break;
	}
}
