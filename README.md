# CC2 Révolution 

## What is it?

Révolution is a mod for the Carrier Command 2 game by Geometa. The mod
aims to deliver richer gameplay for PvP and PvE games by adding some
more strategic challenges and tactical tools to the game.

## What is included?

Révolution is built on top of the [UI Enhancer](https://steamcommunity.com/sharedfiles/filedetails/?id=2761300794) 
and [Albatross AWACS](https://steamcommunity.com/sharedfiles/filedetails/?id=2892401880) mods.

As well as the fantastic solid basis from UI Enhancer, Révolution adds the following headline features!

### Fog of War

You will only be able to see which team controls an island when you are close to it. If an island belongs to another 
team (eg, AI or human) and is more than 16km away from any of your own units or islands, then it will show was grey on
all the control, navigation and holomap screens on your team.

### Needlefish Radars

Needlefish are now given basic Radars, each can detect different classes of threats based on their types and at
different ranges.

| Needlefish Class | Detection Type | Range |
|------------------|----------------|-------|
| CIWS             | Air            | 5000m |
| Torpedo          | Ships          | 3500m |
| Cruise Missile   | Ships          | 6000m |
| 160mm Gun        | Ships          | 2000m |
| All              | Any            |  500m |

This unlocks the needlefish both as a viable sensor picket ship for early warning, and, when working together in
groups as a deadly independant naval strike force against ships and to a lesser extent land and air targets.

### Electronic Warfare

Aircraft can now carry a ECM pod. I Manta carrying one of these will be harder to detect on Radar and 
show up a few seconds later than without one.  In practice, an aircraft heading to your carrier will appear on
operator screens around 8-10 seconds later than nomrmal if it has am ECM pod.

If you fit an ECM to an AWACS aircraft, the pod and AWACS work together to generate an extra ghost contact. Making
your single AWACS appear to be two aircraft.

Just as with some real Radar Jamming, an opposing crew can with skill and attention work out they are being jammed
by carefully watching how the spoofed contacts behave and by checking using the Holomap's additional sensor power.

### Basic QoL changes

I've made a handful of extra changes, some of these may be backported to [UI Enhancer](https://github.com/Quantx/CC2-UI-Enhancer/) in time.

* HUD CCIP bomb fall line now actually always goes "down".
* Basic CCRP bombing HUD symbology for level bombing of locked targets (sill a work in progress really)
* Fix for the ["Attack Waypoint Tracking exploit"](https://github.com/Quantx/CC2-UI-Enhancer/commit/33ba2dace04e2cb90b787fd4c8d9d94ac5920469) 

# Development Plan

Over the course of time I intend to add more features to Révolution.  Some may turn out to work as stand-alone mods
but others definitely will have to be part of Révolution as they will touch too much of the UI Enahncer scripting.

For more about the future see the ["FUTURE.md"](FUTURE.md) file.