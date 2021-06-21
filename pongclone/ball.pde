class Ball
{
	PVector acceleration;
	PVector velocity;
	PVector position;
	float radius;
	color colorBall;

	Ball(PVector newPosition, float newRadius, color newColor)
	{
		acceleration = new PVector(0, 0);
		velocity = new PVector(0, 0);
		position = newPosition;
		radius = newRadius;
		colorBall = newColor;
	}
}
