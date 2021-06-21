class MenuSelector
{
	int index;
	color colorCurrent;
	float colorChange;
	float colorChangeFrequency;

	MenuSelector()
	{
		index = 0;
		colorCurrent = color(255, 255, 255, 255);
		colorChange = 1;
		colorChangeFrequency = 4;
	}
}

enum MenuTypes
{
	MAIN,
	DIFFICULTY,
	PAUSE
}

class Menu
{
	MenuTypes menuType;
	String[] text;
	PVector[] textPosition;
	float fontSize;
	MenuSelector selector;
	boolean confirmationQuit;

	Menu(MenuTypes newMenuType, String[] newText)
	{
		menuType = newMenuType;
		text = newText;
		textPosition = new PVector[text.length];

		for(int i = 0; i < text.length; i++)
		{
			if(i == 0)
			{
				if(menuType == MenuTypes.MAIN)
				{
					textPosition[i] = new PVector(width/2, height/3);
				}
				else if(menuType == MenuTypes.DIFFICULTY)
				{
					textPosition[i] = new PVector(width/2, height/3.5);
				}
				else
				{
					textPosition[i] = new PVector(width/2, height/1.75);
				}
			}
			else
			{
				textPosition[i] = textPosition[i-1].copy();
				textPosition[i].y += 100;
			}
		}

		selector = new MenuSelector();
		confirmationQuit = false;
	}

}

void menuUpdate(Menu otherMenu)
{
	if(keyPressed)
	{
		switch(otherMenu.menuType)
		{
			case MAIN:
			{
				if(key == ENTER || key == RETURN)
				{
					key = 0;

					if(otherMenu.text[otherMenu.selector.index].equals("Player vs Computer"))
					{
						programState = ProgramStates.DIFFICULTY_MENU;
					}
					else if(otherMenu.text[otherMenu.selector.index].equals("Credits"))
					{
						programState = ProgramStates.CREDITS;
					}
					else if(otherMenu.text[otherMenu.selector.index].equals("Quit"))
					{
						otherMenu.confirmationQuit = true;
					}
					else if(otherMenu.confirmationQuit)
					{
						exit();
					}

					//menuMain.selector.index = 0; // reseta o cursor de seleção do Menu principal para a primeira opção
				}
				else if(wasEscPressed)
				{
					otherMenu.confirmationQuit = false;
					wasEscPressed = false;
				}

				break;
			}

			case DIFFICULTY:
			{
				if(key == ENTER || key == RETURN)
				{
					if(otherMenu.text[otherMenu.selector.index].equals("Easy"))
					{
						gameMode = GameModes.EASY;
					}
					else if(otherMenu.text[otherMenu.selector.index].equals("Normal"))
					{
						gameMode = GameModes.NORMAL;
					}
					else if(otherMenu.text[otherMenu.selector.index].equals("Hard"))
					{
						gameMode = GameModes.HARD;
					}
					else // impossible
					{
						gameMode = GameModes.IMPOSSIBLE;
						stopwatchStart(stopwatchImpossibleGameMode);
					}

					gameShouldSetupArena = true;
				}
				else if(wasEscPressed)
				{
					programState = ProgramStates.MAIN_MENU;
					wasEscPressed = false;
				}

				break;
			}

			case PAUSE:
			{
				if(key == ENTER || key == RETURN)
				{
					key = 0;

					if(otherMenu.text[otherMenu.selector.index].equals("Continue"))
					{
						programState = ProgramStates.PLAYING;
					}
					else if(otherMenu.text[otherMenu.selector.index].equals("Main Menu"))
					{
						otherMenu.confirmationQuit = true;
					}
					else if(otherMenu.confirmationQuit)
					{
						programState = ProgramStates.MAIN_MENU;
						otherMenu.confirmationQuit = false;
					}

					//menuPause.selector.index = 0; // reseta o cursor de seleção do Menu principal para a primeira opção
				}
				else if(wasEscPressed)
				{
					if(otherMenu.confirmationQuit)
					{
						otherMenu.confirmationQuit = false;
						wasEscPressed = false;
					}
					else
					{
						menuPause.selector.index = 0;
						programState = ProgramStates.PLAYING;
						wasEscPressed = false;
					}
				}

				break;
			}
		}

		if( (keyCode == UP || keyCode == DOWN) &&
			(programState == ProgramStates.MAIN_MENU ||
			 programState == ProgramStates.PAUSE_MENU ||
			 programState == ProgramStates.DIFFICULTY_MENU) )
		{
			// cacula um intervalo em 'ms', faz com que o seletor das opções do Menu não se mova rápido demais
			if(timerMenu.isReady)
			{
				if(keyCode == UP)
				{
					otherMenu.selector.index -= 1;

					if(otherMenu.selector.index < 0)
					{
						otherMenu.selector.index = otherMenu.text.length - 1;
					}

				}
				else if(keyCode == DOWN)
				{
					otherMenu.selector.index += 1;

					if(otherMenu.selector.index >= otherMenu.text.length)
					{
						otherMenu.selector.index = 0;
					}
				}

				sfxMenu.play();
				otherMenu.confirmationQuit = false;
				otherMenu.selector.colorChange = 1;
				keyCode = 0;
			}
		}
	}
}

void menuDraw(Menu otherMenu)
{
	background(#181425);

	textAlign(CENTER);
	textSize(otherMenu.fontSize);
	noStroke();

	switch(otherMenu.menuType)
	{
		case MAIN:
		{
			color menuOptionColor = color(255);

			for(int i = 0; i < otherMenu.text.length; i++)
			{
				if(i == otherMenu.selector.index)
				{
					menuOptionColor = color(#fee761);
					menuDrawSelector(otherMenu, menuOptionColor);
					fill(menuOptionColor, abs(sin(otherMenu.selector.colorChange)) * 255);
				}
				else
				{
					menuOptionColor = color(#b55088);
					fill(menuOptionColor);
				}

				if(otherMenu.text[i].equals("Quit") && otherMenu.confirmationQuit)
				{
					menuMain.text[i] = new String("Quit (Are you sure?)");
				}
				else if(otherMenu.text[i].equals("Quit (Are you sure?)") && !otherMenu.confirmationQuit)
				{
					menuMain.text[i] = new String("Quit");
				}

				text(otherMenu.text[i], otherMenu.textPosition[i].x, otherMenu.textPosition[i].y);
			}

			break;
		}

		case DIFFICULTY:
		{
			color menuOptionColor = color(255);
			for(int i = 0; i < otherMenu.text.length; i++)
			{
				if(i == otherMenu.selector.index)
				{
					menuOptionColor = color(#fee761);
					menuDrawSelector(otherMenu, menuOptionColor);
					fill(menuOptionColor, abs(sin(otherMenu.selector.colorChange)) * 255);
				}
				else
				{
					menuOptionColor = color(#b55088);
					fill(menuOptionColor);
				}

				text(otherMenu.text[i], otherMenu.textPosition[i].x, otherMenu.textPosition[i].y);
			}

			textSize(14);
			fill(#3a4466);
			text("Press \"ESC\" to go back to the main Menu.", width/2, height-30);

			break;
		}

		case PAUSE:
		{
			fill(#3a4466);
			textAlign(CENTER);
			textSize(otherMenu.fontSize*2);
			text("PAUSED", width/2, height/3);

			textSize(otherMenu.fontSize);
			color menuOptionColor = color(255);
			for(int i = 0; i < otherMenu.text.length; i++)
			{
				if(i == otherMenu.selector.index)
				{
					menuOptionColor = color(#fee761);
					menuDrawSelector(otherMenu, menuOptionColor);
					fill(menuOptionColor, abs(sin(otherMenu.selector.colorChange)) * 255);
				}
				else
				{
					menuOptionColor = color(#b55088);
					fill(menuOptionColor);
				}

				if(otherMenu.text[i].equals("Main Menu") && otherMenu.confirmationQuit)
				{
					otherMenu.text[i] = "Main Menu (Are you Sure?)";
				}
				else if(otherMenu.text[i].equals("Main Menu (Are you Sure?)") && !otherMenu.confirmationQuit)
				{
					otherMenu.text[i] = "Main Menu";
				}

				text(otherMenu.text[i], otherMenu.textPosition[i].x, otherMenu.textPosition[i].y);
			}

			fill(#b55088);
			textAlign(LEFT);
			textSize(12);
			text("DIFFICULTY: " + gameMode, 10, height-20);

			break;
		}
	}
}

void menuDrawSelector(Menu otherMenu, color menuOptionColor)
{
	noStroke();
	fill(menuOptionColor, abs(sin(otherMenu.selector.colorChange)) * 255);
	float selectorPositionX = ((width / 2) - (textWidth(otherMenu.text[otherMenu.selector.index]) / 2)) - 30;
	float selectorPositionY = otherMenu.textPosition[otherMenu.selector.index].y - (otherMenu.fontSize/2.0);
	circle(selectorPositionX, selectorPositionY, 16);
	otherMenu.selector.colorChange += otherMenu.selector.colorChangeFrequency * deltaTime;
	
	if(otherMenu.selector.colorChange >= TWO_PI)
	{
		otherMenu.selector.colorChange = 0;
	}
}
