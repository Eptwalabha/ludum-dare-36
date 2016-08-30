# Aqueduct simulator

_unfinished game for Ludum-dare 36_

__Theme: Ancient technology__

## Goal

The emperor asked you to bring water to Roman cities by building aqueduct.  
The construction of an aqueduct's section requires iron, stone and wood which can be:
- collected from natural resources
- traded from the Roman market

## Tools used

- [LÖVE2D](https://love2d.org/)
- [ASEPRITE](https://github.com/aseprite/aseprite)

## What's been done

- Build map from .PNG image
- Pathfinding (A\*)
- Trade system
- Map mask
- The game detects when the aqueduct was over
- Game over
- Buildings gathering resources at each tic

## What's yet to be done

### Note:

I might continue the project… maybe…
The __master__ branch doesn't necessarily represent the state where the game was when I abandoned Ludum dare 36.
To have a look at that, switch to branch __ld36__

In order to have a playable game, I should've:
- Code a way to select the kind of building to build
- Code all the buildings states/infos
- Display to the player the cost of each construction
- Created a dozen of different maps
- Optimize the Pathfinding
- Make a game menu

## Additional features

Those are the missing (also optional) features that were initially planned:
- Fog of war
- Splash screen
- Sounds
- Musics
- Tutorial section via gameplay
- Map editor

## Screenshots

<img src="https://i.imgur.com/vy1Vq6L.png">
<img src="https://i.imgur.com/QpzOBpC.png">
<img src="https://i.imgur.com/bhFAJUl.png">
