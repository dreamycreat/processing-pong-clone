//
// Created by Douglas Lima (Brazil, 2021).
//

import processing.sound.*;

enum ProgramStates
{
	MAIN_MENU,
	DIFFICULTY_MENU,
	PLAYING,
	WIN,
	CREDITS,
	PAUSE_MENU
}

enum GameModes
{
	EASY,
	NORMAL,
	HARD,
	IMPOSSIBLE
}

//
// GLOBAIS
//
float deltaTime;
boolean wasEscPressed; // necessário por conta do evento padrão aplicado na tecla ESC pelo framework
ProgramStates programState;
GameModes gameMode;
Menu menuMain;
Menu menuDifficulty;
Menu menuPause;
boolean playerInput[];
Player player1, player2;
String winner;
int winnerScore;
Ball gameBall;
boolean gameShouldSetupArena;

// Fonte utilizada no programa inteiro
PFont textFont;

// Temporizadores e Cronômetro
Stopwatch stopwatchImpossibleGameMode;
Timer timerMenu;
Timer timerPlayerComputerReactionTime;

// Efeitos de Som do Jogo
SoundFile sfxMenu;
SoundFile sfxWall;
SoundFile sfxPlayer;
SoundFile sfxScore;

void setup()
{
	fullScreen(P2D);
	//size(1280, 720);
	surface.setTitle("Pong Clone");
	frameRate(60);
	noSmooth();
	noCursor();

	sfxMenu = new SoundFile(this, "sound_effects/sfx_menu.wav");
	sfxWall = new SoundFile(this, "sound_effects/sfx_wall.wav");
	sfxPlayer = new SoundFile(this, "sound_effects/sfx_player.wav");
	sfxScore = new SoundFile(this, "sound_effects/sfx_score.wav");

	// Máximo de pontos para vencer.
	winnerScore = 9;

	// Cronômetro de quanto tempo o jogador ficou na arena no modo modo de jogo "Impossible"
	stopwatchImpossibleGameMode = new Stopwatch();

	// Delay de entrada dos menus
	timerMenu = new Timer(25); // em ms
	timerMenu.lastTime = millis();
	
	// Tempo de resposta da máquina contra o jogador (alto = fácil, baixo = difícil)
	// O tempo de reação precisa ser baseado na largura da tela, porque quanto maior a tela mais demora para a bolinha chegar do outro lado.
	timerPlayerComputerReactionTime = new Timer(0); // isso muda quando o jogador selecionar uma dificuldade no Menu de difficuldade
	timerPlayerComputerReactionTime.shouldUpdate = false;

	textFont = createFont("fonts/PressStart2P.ttf", height/32, true);
	textFont(textFont);

	//
	// Valores para os menus
	//
	menuMain = new Menu(MenuTypes.MAIN, new String[] {"Player vs Computer", "Credits", "Quit"});
	menuMain.fontSize = height/32;

	menuDifficulty = new Menu(MenuTypes.DIFFICULTY, new String[] {"Easy", "Normal", "Hard", "Impossible"});
	menuDifficulty.fontSize = menuMain.fontSize;

	menuPause = new Menu(MenuTypes.PAUSE, new String[] {"Continue", "Main Menu"});
	menuPause.fontSize = menuMain.fontSize;

	playerInput = new boolean[2];

	// Inicia no menu principal
	programState = ProgramStates.MAIN_MENU;
}

void draw()
{
	gameUpdate();
	gameDraw();
}

void gameUpdate()
{
	deltaTime = 1/frameRate;
	timerUpdate(timerMenu);
	timerUpdate(timerPlayerComputerReactionTime);
	stopwatchUpdate(stopwatchImpossibleGameMode);
	gameSetupArena();

	switch(programState)
	{
		case MAIN_MENU:
		{
			menuUpdate(menuMain);
			break;
		}

		case DIFFICULTY_MENU:
		{
			menuUpdate(menuDifficulty);
			break;
		}

		case PLAYING:
		{
			playerUpdate(player1);
			playerUpdate(player2);

			// ballUpdate(gameBall);
			{
				gameBall.position.add(gameBall.velocity.copy().mult(deltaTime)); // se não utilizar "copy()" eventualmente a velocidade fica igual a zero porque o vetor da velocidade não é copiado e sim alterado.

				// Verifica a colisão da bolinha nos cantos superior e inferior
				{
					if(gameBall.position.y - gameBall.radius <= 0)
					{
						gameBall.position.y = gameBall.radius;
						gameBall.velocity.y *= -1;
						sfxWall.play();
					}
					else if(gameBall.position.y + gameBall.radius >= height)
					{
						gameBall.position.y = height - gameBall.radius;
						gameBall.velocity.y *= -1;
						sfxWall.play();
					}
				}
			}

			gameCollisionUpdate(player1, gameBall);
			gameCollisionUpdate(player2, gameBall);
			gameCheckPlayersScore(player1, gameBall);
			gameCheckPlayersScore(player2, gameBall);

			if(wasEscPressed)
			{
				programState = ProgramStates.PAUSE_MENU;
				wasEscPressed = false;
			}

			break;
		}

		case PAUSE_MENU:
		{
			menuUpdate(menuPause);
			break;
		}

		case WIN:
		case CREDITS:
		{
			if(keyPressed && (key == ENTER || key == RETURN || wasEscPressed))
			{
				key = 0;
				programState = ProgramStates.MAIN_MENU;
				wasEscPressed = false;
			}

			break;
		}
	}
}

void gameDraw()
{
	switch(programState)
	{
		case MAIN_MENU:
		{
			menuDraw(menuMain);
			break;
		}

		case PLAYING:
		{
			background(#181425);

			// Linha Central
			stroke(255, 50);
			line(width/2, 0, width/2, height);

			if(gameMode == GameModes.IMPOSSIBLE)
			{
				// Segundos na arena
				noStroke();
				fill(255, 63);
				textSize(40);
				textAlign(CENTER);
				text("" + stopwatchImpossibleGameMode.secondsSinceLastTime, width/2, height/11);
			}
			else
			{
				// Pontos dos Jogadores
				noStroke();
				fill(255, 63);
				textSize(40);
				textAlign(RIGHT);
				text(str(player1.score), width/2-30, height/11);
				textAlign(LEFT);
				text(str(player2.score), width/2+30, height/11);
			}

			// Nome dos Jogadores
			textSize(22);
			textAlign(LEFT);
			text("Player", 10, 30);
			textAlign(RIGHT);
			text("Computer", width-10, 30);

			playerDraw(player1);
			playerDraw(player2);
		
			//ballDraw(gameBall);
			{
				noStroke();
				fill(gameBall.colorBall);
				circle(gameBall.position.x, gameBall.position.y, gameBall.radius*2);
			}

			break;
		}

		case DIFFICULTY_MENU:
		{
			menuDraw(menuDifficulty);
			break;
		}

		case PAUSE_MENU:
		{
			menuDraw(menuPause);
			break;
		}

		case WIN:
		{
			background(#181425);

			String text;
			if(gameMode == GameModes.IMPOSSIBLE)
			{
				text = "Score: " + stopwatchImpossibleGameMode.secondsSinceLastTime + "s";
			}
			else
			{
				text = "" + winner + " Won!";
			}

			noStroke();
			textAlign(CENTER);
			textSize(menuMain.fontSize);
			fill(#fee761);
			text(text, width/2, height/2);

			textSize(14);
			fill(#3a4466);
			text("Press \"Return\" to go back to the main Menu.", width/2, height-30);

			break;
		}

		case CREDITS:
		{
			background(#181425);

			textAlign(CENTER);

			textSize(9);
			fill(#3a4466);
			text("Pong is not a creation of mine (Douglas),", width/2, 30);
			text("altought I coded this clone version for education porpurse (not financial).", width/2, 45);
			text("I don't have any rights for the original software (Pong)", width/2, 60);
			text("and this is not a try to sell someonelse's software.\n", width/2, 75);
			
			textSize(menuMain.fontSize);
			String text = "Programmer: Douglas Lima";
			fill(#fee761);
			text(text, width/2, height/2);

			textSize(14);
			fill(#3a4466);
			text("Press \"Return\" to go back to the main Menu.", width/2, height-30);
		}
	}
}

void gameSetupArena()
{
	if(gameShouldSetupArena)
	{
		gameShouldSetupArena = false;
		programState = ProgramStates.PLAYING;
		player1 = new Player(PlayerTypes.HUMAN, new PVector(35, height/2), int(width/51), height/9, color(#63c74d));
		player2 = new Player(PlayerTypes.COMPUTER, new PVector(width-35, height/2), int(width/51), height/9, color(#ff0044));

		switch(gameMode)
		{
			case EASY:
			{
				timerPlayerComputerReactionTime = new Timer(1250);
				break;
			}

			case NORMAL:
			{
				timerPlayerComputerReactionTime = new Timer(1000);
				break;
			}

			case HARD:
			{
				timerPlayerComputerReactionTime = new Timer(850);
				break;
			}

			case IMPOSSIBLE:
			{
				timerPlayerComputerReactionTime = new Timer(0);
				break;
			}
		}
		
		player2.reactionTime = int(timerPlayerComputerReactionTime.timeDifference);
		timerPlayerComputerReactionTime.lastTime = millis();
		timerPlayerComputerReactionTime.shouldUpdate = true;
		gameBall = new Ball(new PVector(width/2, height/2), int(width/250), color(#fee761));

		PVector angle;
		if(random(1) < 0.5)
			angle = PVector.fromAngle(radians(random(-75, 75)));
		else
			angle = PVector.fromAngle(radians(random(110, 250)));

		angle.normalize();
		gameBall.velocity.set(angle.mult(width/2));
	}
}

// Verifica a colisão da bolinha com os jogadores
void gameCollisionUpdate(Player otherPlayer, Ball otherBall)
{
	boolean collide = false;

	// Verifica a colisão da bolinha com o jogador
	if(otherBall.position.x <= otherPlayer.position.x + otherPlayer.width/2 &&
	   otherBall.position.x >= otherPlayer.position.x - otherPlayer.width/2 &&
	   otherBall.position.y >= otherPlayer.position.y - otherPlayer.height/2 &&
	   otherBall.position.y <= otherPlayer.position.y + otherPlayer.height/2)
	{
		collide = true;
		PVector angle;
		float angle_min;
		float angle_max;

		// Os ângulas são calculados de acordo com o sistema de coordenadas que é diferente do sistema cartesiano por +90 graus
		// E é levado em conta também o ângulo de projeção da bolinha em diferentes lados da tela (direita e esquerda)

		if(otherPlayer.playerType == PlayerTypes.COMPUTER) 
		{
			// da direita para esquerda (180 = 0, (120, -120) = (60, -60))
			angle_min = 180;
			angle_max = 120;

			// Ajusta a posição da bolinha para não ocupar a mesma região que os jogador e colidir mais de uma vez
			otherBall.position.x = otherPlayer.position.x - otherPlayer.width/2;
		}
		else
		{
			// da esquerda pra direita
			angle_min = 0;
			angle_max = 60;

			otherBall.position.x = otherPlayer.position.x + otherPlayer.width/2;
			timerPlayerComputerReactionTime.lastTime = millis();
			timerPlayerComputerReactionTime.shouldUpdate = true;
		}

		// Verifica se o Player rebateu com a parte superior ou inferior
		if(otherBall.position.y <= otherPlayer.position.y)
		{
			float top_region_collision = map(otherBall.position.y,
											 otherPlayer.position.y, otherPlayer.position.y - otherPlayer.height/2,
											 angle_min, angle_max);

			angle = PVector.fromAngle(radians(top_region_collision * -1));
		}
		else
		{
			float bottom_region_collision = map(otherBall.position.y,
											 otherPlayer.position.y, otherPlayer.position.y + otherPlayer.height/2,
											 angle_min, angle_max);
			angle = PVector.fromAngle(radians(bottom_region_collision));
		}

		otherBall.velocity.set(angle.mult(width/1.15));
	}

	// Quando algum jogador rebater...
	if(collide)
	{
		sfxPlayer.play();

		if(otherPlayer.playerType == PlayerTypes.HUMAN)
		{
			timerPlayerComputerReactionTime.shouldUpdate = true;
		}
		else
		{
			timerPlayerComputerReactionTime.shouldUpdate = false;
		}
	}
}

//
// Verifica a posição da bolinha nas laterais para calcular os pontos dos jogadores e restaurar as informações da bolinha.
//
void gameCheckPlayersScore(Player otherPlayer, Ball otherBall)
{
	if( (gameMode == GameModes.IMPOSSIBLE) && (otherBall.position.x - otherBall.radius < 0) )
	{
		programState = ProgramStates.WIN;
		stopwatchStop(stopwatchImpossibleGameMode);
	}
	else if(otherBall.position.x - otherBall.radius < 0)
	{
		if(otherPlayer.playerType == PlayerTypes.COMPUTER)
		{
			otherPlayer.score += 1;
			sfxScore.play();

			if(otherPlayer.score == winnerScore)
			{
				winner = new String("Computer");
				programState = ProgramStates.WIN;
			}
			else
			{
				otherBall.position.set(width/2, height/2);
				PVector angle = PVector.fromAngle(radians(random(120, 240)));
				otherBall.velocity.set(angle.mult(width/2));
			}
		}
	}
	else if(otherBall.position.x + otherBall.radius > width)
	{
		if(otherPlayer.playerType == PlayerTypes.HUMAN)
		{
			otherPlayer.score += 1;
			sfxScore.play();

			if(otherPlayer.score == winnerScore)
			{
				winner = new String("Player");
				programState = ProgramStates.WIN;
			}
			else
			{
				otherBall.position.set(width/2, height/2);
				PVector angle = PVector.fromAngle(radians(random(300, 420)));
				otherBall.velocity.set(angle.mult(width/2));
			}
		}
	}
}

//
// Entrada do Jogador no jogo
//
void keyReleased()
{
	if(keyCode == UP)
	{
		keyCode = 0;
		playerInput[INPUT_UP] = false;
	}

	if(keyCode == DOWN)
	{
		keyCode = 0;
		playerInput[INPUT_DOWN] = false;
	}	
}

//
// Entrada do Jogador no jogo
//
void keyPressed()
{
	if(programState == ProgramStates.PLAYING)
	{
		if(keyCode == UP)
		{
			keyCode = 0;
			playerInput[INPUT_UP] = true;
		}

		if(keyCode == DOWN)
		{
			keyCode = 0;
			playerInput[INPUT_DOWN] = true;
		}
	}	

	//
	// Verificando se o jogador tentou pausar o jogo.
	//
	if(key == ESC)
	{
		key = 0; // Cancela o evento padrão de fechar o programa
		wasEscPressed = true; // Substitui "key == ESC"
	}
}
