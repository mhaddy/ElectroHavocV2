# ElectroHavocV1
Top-down 2d shooter for a game jam with the prompt "chain reaction". Dubbed Electro Havoc, the objective is to stay alive as long as possible while destroying as many enemies as possible. 

## Planned Additions
* **Add rapid fire or new weapon power-up**
* Address performance issues
* Add a timer/limit on the chain reaction damage (it's kind of insta-kill right now)

## Features
* 10 waves of increasingly difficult enemies (health, speed, size)
* Player and enemy death animations
* HUD that tracks score, high score and waves
* High score persists to disk
* Modal window for game over, game complete
* Pathfinding
  * _Pathfinding is implemented but agents still get stuck on edges, and it's a bit of a rushed implementation where I had to create two tilemap layers - one for the navigation paths, the other as an inverse of it with walls and collision shapes. To do this less janky, we need to wait for this PR that merges tilemap layers together to make a navMesh in 2d: https://github.com/godotengine/godot/pull/70724. This PR adds 2D navigation mesh baking with proper agent size so you can just use a NavigationRegion2D and ignore the entire TileMap build-in navigation._
* BG music and sfx
* Enemy explosions damage other enemies
* Shield power-up

## Notes
### Color Palette
* https://lospec.com/palette-list/lava-gb
* https://lospec.com/palette-list/spacehaze
