class Stopwatch
{
	boolean shouldUpdate;
	long lastTime;
	long currentTime;
	long secondsSinceLastTime;

	Stopwatch()
	{
		shouldUpdate = false;
		lastTime = 0;
		currentTime = 0;
		secondsSinceLastTime = 0;
	}
}

void stopwatchStart(Stopwatch otherStopwatch)
{
	otherStopwatch.shouldUpdate = true;
	otherStopwatch.lastTime = otherStopwatch.currentTime = otherStopwatch.secondsSinceLastTime = 0;
}

void stopwatchUpdate(Stopwatch otherStopwatch)
{
	if(otherStopwatch.shouldUpdate)
	{
		otherStopwatch.currentTime = millis();
		
		if(otherStopwatch.currentTime - otherStopwatch.lastTime >= 1000)
		{
			otherStopwatch.lastTime = otherStopwatch.currentTime;
			otherStopwatch.secondsSinceLastTime += 1;
		}
	}
}

void stopwatchStop(Stopwatch otherStopwatch)
{
	otherStopwatch.shouldUpdate = false;
}
