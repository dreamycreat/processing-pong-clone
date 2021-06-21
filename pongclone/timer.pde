class Timer
{
	boolean shouldUpdate;
	long timeDifference;
	long lastTime;
	long currentTime;
	boolean isReady;

	Timer(int newTimeDifference)
	{
		shouldUpdate = true;
		timeDifference = newTimeDifference;
		lastTime = 0;
		currentTime = 0;
		isReady = false;
	}
}

void timerUpdate(Timer otherTimer)
{
	if(otherTimer.shouldUpdate)
	{
		otherTimer.currentTime = millis();

		if(otherTimer.currentTime - otherTimer.lastTime >= otherTimer.timeDifference)
		{
			otherTimer.lastTime = otherTimer.currentTime;
			otherTimer.isReady = true;
		}
		else
		{
			otherTimer.isReady = false;
		}
	}
}
