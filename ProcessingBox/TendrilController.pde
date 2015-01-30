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
			tendrils.setAmplitude(10f, 30f);
			tendrils.setAmplitudePercentage(0.1f, 5f);
			tendrils.setFrequency(1000f,10000f);
			tendrils.setFrequencyPercentage(0.5f, 1.5f);
			break;	
		default:
			break;
	}
}
