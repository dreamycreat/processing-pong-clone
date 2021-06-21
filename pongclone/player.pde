enum PlayerTypes
{
	HUMAN,
	COMPUTER
}

final int INPUT_UP = 0;
final int INPUT_DOWN = 1;

class Player
{
	PlayerTypes playerType;
	int reactionTime; // ms
	float maxVelocity;
	PVector velocity;
	PVector position;
	float width;
	float height;
	color colorPlayer;
	int score;

	Player(PlayerTypes newPlayerTime, PVector newPosition, float newWidth, float newHeight, color newColor)
	{
		playerType = newPlayerTime;
		reactionTime = 0;
		maxVelocity = width/1.3;
		velocity = new PVector(0, 0);
		position = newPosition;
		width = newWidth;
		height = newHeight;
		colorPlayer = newColor;
		score = 0;
	}
}

void playerUpdate(Player otherPlayer)
{
	otherPlayer.maxVelocity = width/1.3;
	
	if(otherPlayer.playerType == PlayerTypes.HUMAN)
	{
		if(playerInput[INPUT_UP])
		{
			otherPlayer.velocity.set(0, -otherPlayer.maxVelocity);
		}
		else if(playerInput[INPUT_DOWN])
		{
			otherPlayer.velocity.set(0, otherPlayer.maxVelocity);
		}
	}

	if(otherPlayer.playerType == PlayerTypes.COMPUTER)
	{
		// Verifica o tempo de resposta do computador para seguir a bolinha
		if(timerPlayerComputerReactionTime.isReady)
		{
			timerPlayerComputerReactionTime.shouldUpdate = false;
			float gameBallAngle = abs(degrees(gameBall.velocity.heading()));

			// Verifica se a bola estiver indo na direção do "jogador computador"
			if(gameBallAngle >= 270 && gameBallAngle <= 360 ||
			   gameBallAngle >= 0   && gameBallAngle <= 90)
			{
				if(gameBall.position.y > otherPlayer.position.y + otherPlayer.height/2 - 20)
				{
					otherPlayer.velocity.set(0, otherPlayer.maxVelocity);
				}
				else if(gameBall.position.y < otherPlayer.position.y - otherPlayer.height/2 + 20)
				{
					otherPlayer.velocity.set(0, -otherPlayer.maxVelocity);
				}
				else
				{
					otherPlayer.velocity.set(0, 0);
				}
			}
		}
	}

	otherPlayer.position.add(otherPlayer.velocity.mult(deltaTime));

	// Limita a posição dos jogadores no eixo vertical
	{
		if(otherPlayer.position.y - otherPlayer.height/2 <= 0)
		{
			otherPlayer.position.y = otherPlayer.height/2 + 1;
			otherPlayer.velocity.set(0, 0);
		}
		else if(otherPlayer.position.y + otherPlayer.height/2 >= height)
		{
			otherPlayer.position.y = height - otherPlayer.height/2 - 1;
			otherPlayer.velocity.set(0, 0);
		}
	}
}

void playerDraw(Player otherPlayer)
{
	noStroke();
	fill(otherPlayer.colorPlayer, 255);
	rectMode(CENTER);
	rect(otherPlayer.position.x, otherPlayer.position.y, otherPlayer.width, otherPlayer.height);
}
