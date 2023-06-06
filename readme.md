# ElectroHavocV1
Top-down 2d shooter for a game jam with the prompt "chain reaction". Dubbed Electro Havoc, the objective is to stay alive as long as possible while destroying as many enemies as possible. 

## Planned Additions
* ~Concept of waves~
* ~Player and enemy death animations~
* Score (~points~, time alive, high score)
  * Then persist this
* ~Pathfinding (reading about A* algorithm and Godot's implementation of it)~
  * Pathfinding is implemented but agents still get stuck on edges, and it's a bit of a rushed implementation where I had to create two tilemap layers - one for the navigation paths, the other as an inverse of it with walls and collision shapes. To do this less janky, we need to wait for this PR that merges tilemap layers together to make a navMesh in 2d: https://github.com/godotengine/godot/pull/70724. This PR adds 2D navigation mesh baking with proper agent size so you can just use a NavigationRegion2D and ignore the entire TileMap build-in navigation.
* ~BG music and sfx~
* Figure out how to make particles damage other enemies (thus delivering on the "chain reaction" prompt)
* ~Varied enemies with health~
* Power-ups and different weapons, if only to change bullet sprite and particle design
* Finish the game loop

## Notes
### Color Palette
* https://lospec.com/palette-list/lava-gb
* https://lospec.com/palette-list/spacehaze
