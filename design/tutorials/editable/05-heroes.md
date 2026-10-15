# Heroes — editable tutorial script

Snapshot of the implementation, 15 October 2026.
Each numbered stop is one Continue/Next pause. Blank narration lines are intentional.
Authoritative narration: `design/tutorials/heroes-script.json`. Edits here need importing into that source.

# Main tutorial

## heroes.001 — welcome

{Heading: WELCOME}
Welcome to the Heroes Tutorial!
This tutorial deals with Warcraft III's most iconic aspect: Heroes.

Once you are done reading a section and playing around with whichever mechanic you learn, press the {Button: Continue} or {Button: Next} button to move on!

Scene: `overview`.
Trigger: Have the arrow blink while pointing at the "Next/Continue" button, the same way as in the opening section of the other tutorials.
Trigger: Lock daytime at noon for the tutorial and restore it on exit.
Trigger: Move the Night Elf and Tavern groups 300 units north; move Pit Lord 200 units left.
Trigger: Presented heroes are vulnerable so armor is visible. Target Dummies display damage popups.
Progression: Next.

Your notes:

## heroes.002 — basics

{Heading: BASICS}
In every game, you can create up to three hero units at your {Term: Altar}.
You can recruit the first as soon as you finish the building, and the others once you upgrade your main building to Tier 2 and Tier 3, respectively.

Every race has four unique heroes to choose from.

Scene: `overview`.
Trigger: Center the camera on each of the racial altars, and switch between them at five-second intervals.
Action: altar-tour
Progression: Continue.

Your notes:

## heroes.003 — basics

In addition to this, all races can choose from nine neutral heroes at the {Term: Tavern} building.
The Tavern is usually located somewhere in the middle of the map.

Scene: `overview`.
Trigger: Center the camera on the Tavern.
Action: tavern-camera
Progression: Continue.

Your notes:

## heroes.004 — basics

Recruiting at the {Term: Tavern} becomes possible 135 seconds after the game starts, and also requires you to have built an {Term: Altar}.

Scene: `overview`.
Progression: Continue.

Your notes:

## heroes.005 — basics

Heroes are a serious presence on any battlefield, either on their own, or through the way their abilities support and synergize with the rest of your army.

For this reason, your choice of heroes is incredibly significant for how you are going to play a game.

Scene: `overview`.
Progression: Next.

Your notes:

## heroes.006 — levels

{Heading: LEVELS}
Heroes start out stronger than your basic military units, and they only get stronger as the game goes on.
This is because they gain experience and rise in level.

Scene: `overview`.
Progression: Continue.

Your notes:

## heroes.007 — levels

A starting hero is level 1, and may go up to level 10 in a game.
However, in many games heroes will barely reach level 6.

Scene: `archmages`.
Trigger: Move the camera to the center of Arena2.
Trigger: Hide the displayed heroes in Arena1.
Trigger: Spawn in a level 1 Archmage with no ability selected, and a level 10 Archmage with all abilities selected, under player control. They should be 600 units apart.
Trigger: Restrict their movement to Arena2.
Progression: Continue.

Your notes:

## heroes.008 — levels

Compare the two Archmages!
You will notice that the level 10 Archmage is significantly stronger, with more health, more mana, and more attack damage.

Scene: `archmages-target`.
Trigger: Spawn in a little straw man as an enemy unit training dummy with infinite health, and have the Archmages attack it.
Progression: Continue.

Your notes:

## heroes.009 — levels

If you look closer, even their attack speed and armor are different.
Also, the higher level Archmage has more and stronger abilities.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.011 — levels

{Heading: ATTRIBUTES}
Unlike regular units, heroes have three attributes: {Term: Strength}, {Term: Agility} and {Term: Intelligence}.
Each hero has different starting attribute values and gains attribute points at different rates.

Scene: `archmages-target`.
Trigger: Set the Archmage target dummy to Neutral after the attack-speed comparison.
Progression: Continue.

Your notes:

## heroes.012 — levels

Each point of {Term: Strength} raises the hero's health by 25 points and their HP regeneration by 0.05 points per second.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.013 — levels

Each point of {Term: Intelligence} raises the hero's mana by 15 points and their mana regeneration by 0.05 points per second.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.014 — levels

Each point of {Term: Agility} raises the hero's attack speed by 2% and their armor by 0.3.
{Term: Armor} reduces the damage from attacks that is applied to a unit's health.
For a detailed demonstration of armor, check out the {Menu: Unit Comparison} demonstration in {Menu: Tools & Extras}.
In addition to armor, heroes have a flat 30% damage reduction against spells.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.015 — levels

Aside from these general effects of {Term: Strength}, {Term: Agility} and {Term: Intelligence}, every hero has a {Term: Primary Attribute}.
Heroes gain one point of extra damage for every point of their primary attribute.
For the details about the damage values of heroes, check out the {Button: Optional} button.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.016 — levels

On every level-up, a hero gains attribute points. Most heroes gain six points in total.
These are divided across the three attributes in a way unique to that hero.
This means that heroes can gain attributes at very different rates.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.017 — levels

Some heroes, including the Archmage, Keeper of the Grove, Lich, Alchemist and Firelord, gain more than six attribute points per level on average.
The exact increase shown at a particular level depends on their attribute growth rates.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.018 — levels

{Heading: ABILITIES}
In addition to attribute points, every hero gains one {Term: Ability} point per level.
You can then freely choose which ability you want to raise.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.019 — levels

Every hero has three regular abilities, and one {Term: Ultimate} ability.
Regular abilities have three levels, while ultimate abilities have only one level.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.020 — levels

Level 1 regular abilities can be chosen at any level.
Level 2 regular abilities can be chosen starting at level 3.
Level 3 regular abilities can be chosen starting at level 5.
The {Term: Ultimate} ability can be chosen starting at level 6.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.021 — levels

Raising a regular ability to its next level will always make it significantly better with no drawbacks.
A higher level will make it more effective, and it can lower its cost or cooldown.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.022 — levels

Since many hero abilities cost mana, and since mana is a scarce resource with a low regeneration rate, it is almost always best to max out two regular abilities before putting a point in the third.
For the same reason, it makes sense to avoid using level 1 regular abilities, and instead wait for their second level to be unlocked.

Scene: `archmages-target`.
Progression: Continue.

Your notes:

## heroes.023 — levels

The exception is using a level 1 ability as soon as possible, so you can take advantage of your hero's mana regeneration.

Scene: `archmages-target`.
Progression: Next.

Your notes:

## heroes.024 — hero-showcase

Check out the different heroes!
You can use the {Button: +} and {Button: -} buttons to raise and lower the heroes' levels, to see what changes about them when you do.

Scene: `showcase`.
Trigger: Change back to Arena1. Despawn the two heroes in Arena2.
Trigger: Transition all heroes into player control. Spawn a training dummy 500 units under each altar and the tavern.
Trigger: Make a "+" and a "-" button on the right side of the screen.
Trigger: The buttons should work such that selecting a hero and pressing the "+" button raises its level by 1, while pressing the "-" button lowers it by 1, resetting all learned abilities.
Trigger: Set all heroes' levels to 1.
Trigger: Make it so that no heroes are assigned to F1, F2 or F3, and no hero icons are displayed in the top-left corner of the screen.
Progression: Next.

Your notes:

## heroes.025 — experience

{Heading: EXPERIENCE}
{Yellow Font: Your} heroes can get experience from any enemy or neutral unit that {Yellow Font: your army} kills.
A unit killed by your buildings, including the living buildings of Night Elves, generates no experience for your heroes.
A unit killed by neutral or enemy units does not generate experience for your heroes either.

Scene: `xp-initial`.
Trigger: Move back to Arena2.
Trigger: Spawn in a gnoll in the center of the arena. Movement should be disabled for this gnoll.
Trigger: The player should have vision of the whole Arena2.
Trigger: Around the center of the arena, there should be a golden circle with a radius of 1200 units (2400-unit diameter).
Progression: Next.

Your notes:

## heroes.026 — xp-range

{Heading: XP RANGE}
Experience is {Yellow Font: divided equally} between all of your heroes who are {Yellow Font: within 1200 units} of the source.
If no heroes are within 1200 units, experience is divided equally between all of your heroes {Yellow Font: on the entire map}.

Scene: `xp-initial`.
Progression: Continue.

Your notes:

## heroes.028 — xp-range

Kill this Gnoll using your army, leaving one hero behind outside of the 1200 unit circle!

Afterwards, check your heroes' experience bars in the interface!

Scene: `xp-range-1`.
Trigger: Outside of the 1200 circle, spawn four Footmen, a level 1 Paladin, a level 1 Archmage, and a level 1 Mountain King. Each of the heroes should be 1 XP away from the next level.
Progression: Continue.

Your notes:

## heroes.029 — xp-range

Kill the Gnoll just using your Footmen, leaving all heroes behind outside of the 1200 unit circle!

Afterwards, check your heroes' experience bars in the interface!

Scene: `xp-range-2`.
Trigger: Reset both army and gnoll.
Progression: Continue.

Your notes:

## heroes.030 — xp-range

Kill the Gnoll using your army, leaving two heroes behind outside of the 1200 unit circle!

Afterwards, check your heroes' experience bars in the interface!

Scene: `xp-range-3`.
Trigger: Reset both army and gnoll.
Progression: Next.

Your notes:

## heroes.031 — xp-amounts

{Heading: XP AMOUNTS}
If you kill a unit, the amount of XP gained is displayed in a small blue number over the heroes.
Broadly speaking, units give XP based on their level, with summoned units giving half as much.

A higher level unit gives more XP.
Generally, the levels of player-controlled units are equal to their Food Cost, with some exceptions.

Scene: `xp-empty`.
Trigger: Remove both army and gnoll.
Progression: Continue.

Your notes:

## heroes.032 — xp-amounts

If you want the detailed breakdown of experience values, check out the {Menu: Optional} topic on the toolbar.
Once you are done with it, you will be returned to this part of the tutorial.

Scene: `xp-empty`.
Progression: Continue.

Your notes:

## heroes.033 — xp-amounts

The amount of XP a hero gains can be modified.
For example, as soon as your main building reaches tier 2, your first hero gains a {Yellow Font: +15% bonus} until you start training a second hero.
This is called the {Term: Solo Hero Bonus}.
Upon reaching tier 3, this bonus is raised to {Yellow Font: +30%}.

Scene: `xp-empty`.
Progression: Continue.

Your notes:

## heroes.034 — xp-amounts

Another modifier applies to the neutral {Term: Creeps} spread around the map.
Experience gained from creeps is always lower than for an enemy unit.
Heroes gain less experience from {Term: Creeps} as they level up. Starting at {Yellow Font: level 5}, they gain {Yellow Font: no experience from creeps at all}.

Scene: `xp-empty`.
Progression: Continue.

Your notes:

## heroes.035 — xp-amounts

The last way to modify experience gain comes from a {Term: Hex} or the {Term: Polymorph} spell, which turn the hero into an animal, {Yellow Font: reducing any experience they gain by 100%}.

Scene: `xp-empty`.
Progression: Continue.

Your notes:

## heroes.036 — xp-amounts

Modified experience gain affects your decisions in two ways.
First, a hero whose experience gain is reduced {Yellow Font: still gets an equal part of the experience} before it is reduced.
This means that if a hero's experience gain is reduced, you may want to {Yellow Font: keep him outside of the 1200 unit experience range}, so as little experience as possible is lost.

Scene: `xp-empty`.
Progression: Continue.

Your notes:

## heroes.037 — xp-amounts

Attack the Gnoll using your army and both heroes!
Pay attention to the experience amounts!

Scene: `xp-modifier-4`.
Trigger: Spawn in a 1200 unit radius golden circle around the middle of the Arena2.
Trigger: Spawn in four footmen, a Mountain King and a Paladin outside of the circle. The Mountain King should be level 4. The Paladin should be level 2, 35 XP away from level 3.
Trigger: Spawn in a level 3 gnoll creep of some kind at 1/4 health in the middle of the circle, that cannot move.
Progression: Continue.

Your notes:

## heroes.039 — xp-amounts

Attack the Gnoll again, using your entire army! Keep both heroes within the circle.
Pay attention to the experience amounts!

Scene: `xp-modifier-paladin`.
Trigger: Reset the Gnoll and army. The Paladin is level 2, 35 XP from level 3. The Mountain King is level 5 and starts outside the 1200-radius circle with the other Human units.
Progression: Continue.

Your notes:

## heroes.040 — xp-amounts

You may have noticed that the Mountain King did not gain any experience last time.
Attack the Gnoll one last time, using your army, but leave the Mountain King outside of the 1200 range circle!
Pay attention to the experience amount of your Paladin!

Scene: `xp-modifier-outside`.
Trigger: Reset both Gnoll and the army and the heroes, especially the Paladin's experience.
Progression: Continue.

Your notes:

## heroes.041 — xp-amounts

As you can see, how you handle distance can make a difference.

Scene: `empty`.
Trigger: Remove the army, the gnoll and the circle.
Progression: Continue.

Your notes:

## heroes.042 — xp-amounts

Another thing that can make a difference is the order in which you kill units.
When a hero is very close to a level-up, you should kill higher level creeps first.
That way, any experience that flows over into the next level is not reduced by the new level's lower creep XP rate.

Scene: `empty`.
Progression: Next.

Your notes:

## heroes.043 — items

{Heading: ITEMS}
One of the advantages of heroes is that they can carry and use items.
Through the {Term: Backpacks} research, some units can learn to carry them, but they cannot use them.

Scene: `items`.
Trigger: Center the camera over Arena2.
Trigger: Spawn in all four racial shops and a Goblin Merchant and a Marketplace in equal spacing 500 units from the middle of the arena. Set the timers for the items to be ready. Spawn in a main building of tier 3 for each race in the corners of the arena respectively.
Trigger: Spawn in a Paladin, an Archmage, and a Mountain King under player control in the middle of the arena.
Trigger: Spawn all items from the drop table of Twisted Meadows, ordered by camp size where they can be dropped.
Trigger: Set the player's Gold and Lumber to 10,000 each.
Trigger: Spawn in a training dummy next to the heroes.
Progression: Continue.

Your notes:

## heroes.044 — items

Items can have all kinds of different effects and advantages.
They can be gained either as random {Term: Drops} from {Term: Creeps}, or by buying them from a neutral {Term: Goblin Merchant} or your own shop building.
Items can also be sold for some instant Gold.

Scene: `items`.
Progression: Continue.

Your notes:

## heroes.045 — items

To pick up an item from the ground, you have to {Input: right-click it}.
When you have selected more than one hero, the one in active selection will pick it up.

Scene: `items`.
Progression: Continue.

Your notes:

## heroes.046 — items

To remove an item from a hero's inventory, {Input: right-click it, and then left-click} where you want to put it.
You can put items on the ground, into the inventory of other heroes or units, or sell them to shops.

Scene: `items`.
Progression: Continue.

Your notes:

## heroes.047 — items

You can also destroy an item on the ground with an {Input: Attack Command}.
Destroying it requires three attacks.

Scene: `items`.
Progression: Continue.

Your notes:

## heroes.048 — items

To buy an item from a shop, you have to {Input: move your hero into range}, and then select the item by {Input: clicking it or pressing its hotkey}.
If several heroes are within range of a shop, you can change the active patron by {Input: right-clicking the hero} you want it to sell to.

Scene: `items`.
Progression: Continue.

Your notes:

## heroes.049 — items

Some items in shops have to be unlocked, either by a simple timer, or by upgrading your main building to tier 2 or 3.

Scene: `items`.
Progression: Continue.

Your notes:

## heroes.050 — items

{Heading: END OF TUTORIAL}
This concludes the Heroes tutorial. Press the {Button: Menu} button to choose another tutorial!

Scene: `items`.
Progression: Menu (completed).

Your notes:

# Optional: dice

## heroes.dice.001 — welcome

{Heading: BONUS: ATTACK DICE}
A hero's attack damage is mostly determined by their primary attribute.
In addition to that, some {Term: Dice} are rolled and added on top.

Scene: `dice`.
Trigger: Use Arena2, with full vision.
Trigger: Spawn in all heroes, in the same color scheme as in Arena1. Arrange them in five groups, depending on their attack dice. From left to right: 2D4, 2D6, 2D12, 2D11, 3D10
Trigger: The heroes should be arranged in ordered columns of five, filled bottom to top, 300 units apart. Between the last column of one group and the first of the next, there should be 600 units distance.
Trigger: 400 units below the first column of any group, there should be text on the ground in enlarged white font: "2D4", "2D6", "2D12", "2D11", and "3D10".
Trigger: For this optional section, display the "+" and "-" buttons.
Progression: Continue.

Your notes:

## heroes.dice.002 — welcome

Most heroes fall into one of three categories, rolling either two four-sided, two six-sided or two twelve-sided dice for every attack.
The only exceptions are the Night Elf Warden with two eleven-sided dice, and the Goblin Alchemist with three ten-sided dice.

Scene: `dice`.
Trigger: Move to 2D4, wait one second after arrival, move to 2D6, wait one second, move to 2D12, wait one second, then move to the midpoint between 2D11 and 3D10. All camera moves take the standard 1.5 seconds.
Action: dice-tour
Progression: Continue.

Your notes:

## heroes.dice.003 — welcome

{Heading: OPTIONAL TOPIC COMPLETE}
This optional topic is complete.
Press the {Button: Next} button to return to the tutorial section you previously left.

Scene: `dice`.
Progression: Next.

Your notes:

# Optional: xp

## heroes.xp.001 — welcome

{Heading: BONUS: XP NUMBERS}
Use the {Button: buttons} on the right to navigate through the different units to see which units have which level.
Consult the {Button: Quest Log} for a listing of all precise experience values.

Scene: `xp-numbers`.
Trigger: I want six buttons on the right side of the screen: one called "Hero" four racial buttons, and a Neutral button for the Tavern heroes' summons.
Trigger: Depending on which button is pressed there should be a demonstration in Arena2.
Trigger: "Hero" arranges 10 neutral heroes left to right, in ascending levels. Below each hero, display two lines of text: "Level X" and "Y XP", with the values from the Quest Log.
Trigger: Each of the racial buttons should arrange one of each racial unit, including summons of that respective race, and buildings that can yield XP, arranged in groups left to right, according to unit level and food costs. Sort the groups first by unit level, then by food cost in ascending order within each level. Below each group, display three lines of text: "Unit Level: X", "Food Cost: Y", and "Z XP".
Progression: Continue.

Your notes:

## heroes.xp.002 — welcome

{Heading: OPTIONAL TOPIC COMPLETE}
This optional topic is complete.
Press the {Button: Next} button to return to the tutorial section you previously left.

Scene: `xp-numbers`.
Progression: Next.

Your notes:

# Quest: XP Numbers

Heroes require 100 times the new level in experience.
So getting from level 1 to level 2 requires 200 XP, while getting from level 5 to level 6 requires 600 XP.

XP from {Term: Regular Player Units} depends on their level, which is often equal to their food cost:
- level 1 -> 25 XP
- level 2 -> 40 XP
- level 3 -> 60 XP
- level 4 -> 85 XP
- level 5 -> 115 XP
- level 6 -> 150 XP

XP from {Term: Summons} is halved.

Experience gained from {Term: Creeps} depends on your hero's level:
- Level 1: {Yellow Font: 80%}
- Level 2: {Yellow Font: 70%}
- Level 3: {Yellow Font: 60%}
- Level 4: {Yellow Font: 50%}
- Level 5 and above: {Yellow Font: 0%}
These percentages apply to the hero's share of the experience. Heroes at level 5 or above still take a share when experience is divided, but gain no experience from it.

XP from {Term: Enemy Heroes} also depends on their level:
- level 1 -> 100 XP
- level 2 -> 120 XP
- level 3 -> 160 XP
- level 4 -> 220 XP
- level 5 -> 300 XP
Any level above 5 adds another 100 XP.
