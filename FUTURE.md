# Future Plans

A révolution does keeps going around and around. I have some
ideas that I want to add to the game and Révolution is the 
best way I can do these without trying to maintian a ever growing
matrix of merged/unmerged mods.

## Shared Mod Data

QuantX worked out that you could use the drydock "vehicle" waypoints
to draw share the position of the holomap cursor with the operator control
screens.  When the captain moves their mouse, the operators see the location.

With a slight modification to how the drydock waypoints are used, we can do much
more. 

* Drydock can have multiple waypoints, each at any x,y location in the game
* Each waypoint can store a 32bit unsigned integer as the altitude value

Once created, we cannot change the position of a waypoint. But we can  alter the 
altitude values, this essentially gives us a way to share limited amounts of arbitrary data
between most of the screens, and, all of the players in the game.

We can use this to do several things (already done in other mods)

* Place [navigation markers](https://steamcommunity.com/sharedfiles/filedetails/?id=3021316783) on maps (circles, named marks etc)
* Store global state data for other mods
* Per-carrier holomap cursor (original version only works properly with one holomap per team)

Making robust use of this data store is complex, there is no real way to "lock" the waypoint data, several scripts
running on different screens/carriers/players can all potentially change the data.

### Map Markers

Using the shared data system, we can use the holomap to place markers and see them in the operator screens. This
will be good for planning, the tricky thing here is making the user interface for adding/removing markers be easy 
to use.  It should also be possible for an operator screen to add markers too.

### Operator Holomap Cursors.

It should be possible to have the operator screen cursors shown on the holomap with the name of each operator. I've
not attempted this yet, but I think it is possible.

### Custom Carrier Names

This one is totally untested, but I think it might be possible.

We could allow a crew to choose a name for their carrier from a list. The only problem I can see would
be how to get these names into the HUD script as the HUD is unable to read waypoints.

## Airlift Buttons

I'm considering adding "airlift nearest" and "unload here" buttons to vehicle control screens for Petrels. It is very hard
to manually create a pickup waypoint for a unit close to a petrel or to drop close to it.

