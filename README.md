#*De: Wasserspiel*
#*En:* water game

#Links
*En:* Experimental Download: <https://github.com/Baerche/wasserspiel/wiki>

##*De: Wozu?*
##*En:* What for?

*De: Eine leere harmlose Welt ist langweilig. Mobs bauen war mir zu schwierig. Und mein Hund schaut immer so besorgt wenn er das die Sterbetöne in Spielen hört. Ausserdem, dies ist ein Bauspiel. Und warum baut man? Richtig, weil sonst wird man pitschnass. Und dann hatte ich eine Idee :-)*

*En:* An empty harmless world is boring. Building mobs was too difficult. And my dog always looks so worried when he hears the sounds of death in games. Moreover, this is a building game. And why do you build? Right, because otherwise you will get soaking wet. And then I had an idea :-)

---
*De: Wenn man Minetest-wasser in die Luft setzt, fällt es vielleicht irgendwie runter? Tat es dann auch, nach etwas überreden. Nachdem ich es schön für endliche Flüssigkeit abgestimmt hatte, kam version 4.10, und die hatte es nicht mehr. Na gut.*

If you set mine test water in the air, it might somehow falls down? Indeed, it did, after some persuasion. After I had it nicely tuned for finite liquid came version 4.10 and it no longer had it. Oh well.

---
*De: Mittlerweile kann Wasserspiel folgendes:*

*En:* Meanwhile, watergame can do the following:

---
*De: Regentropfen fallenlassen und aufplatschen und Pfützen bilden. Na gut, die Wassertropfen sind halb so gross wie man selbst, deswegen empfehle ich als Ameise zu spielen. Also nicht F7 drücken, sonst ist die Illusion weg :-) *

*En:* Drop raindrops and splashing and form puddles. Well, the water droplets are half as large as oneself, that's why I recommend to play as ant. So do not press F7, otherwise the illusion is gone :-)

---
*De: Ausrutschen. Das ist richtig cool und macht wahnsinnig. Wenn man in einer Pfütze steht rutscht man alle paar Sekunden auf das nächste Feld. Und verliert den Focus, gerade wenn man noch einen Moment länger hacken muss. Also sorgt man besser für ein Dach oder eine rutschfeste Unterlage, oder geht nachts ins Bett :-) *

*En:* Slipping. This is really cool and drives mad. When you are standing in a puddle you slip every few seconds to the next field. And lose the focus, just when you still have to hack a bit longer. So better provide for a roof or a non-slip base, or go to bed at night :-)

---
*De: Wechselnden Regen. Der orientiert sich nicht an der Uhrzeit, sondern am Licht. Mehr Dunkelheit, mehr nass. Ich hatte gehofft das das Dämmern durch Wolken auch mehr Regen erzeugt, aber leider nicht. Dafür regnet es kräftig in grossen Höhlen. :-) *

*En:* Changing rain. It is not oriented at the position, but based on light. More darkness, more wet. I had hoped that the dawning through clouds produced more rain, but unfortunately not. Instead, it is raining heavily in large caves.

---
*De: Ertrinken. Na gut, das ist nicht von mir. Aber ganz praktisch wenn man in eine 2 Blocks hohe Grube rutscht oder direkt neben einem Baum einschläft. :-) *

*En:* Drowning. Well, that's not mine. But handy with slipping when you slip into a 2 blocks high pit or fall asleep next to a tree.

---
*De: Tropfen in Höhlen. Für den Fall das die nicht so hoch sind. Passiert nur unter rohem Felsen. Was würde ein Miner da tun?*

*En:* Drops in caves. For the case that they are not so high. Happened only below raw rock. What would a miner do?

---
*De: Erosion. So in etwa. In der Nähe von Wasser rutscht Erde manchmal zur Seite oder nach unten. Oder in den Kanal den man gerade gegraben hat. Sand und so auch.*

*En:* Erosion. Something like that. In the vicinity of water earth slips sometimes to the side or down. Or in the channel's you just had dug. Sand and so does too.

---

## Manual
### Installation

Either you know know how to do it with github, or you go to <https://github.com/Baerche/wasserspiel/wiki> and download the zip. That does not include the nasty "-master" in the name. just put it in mods folder. (Once tried to upload to the library but it did not like me)

###Configuration
Currently through chat. Commands begin with /ws/ for /wasserspiel/ . 

* /ws/info: Shows internal info.


* /ws/rain <number>: chooses rain volume. default -1. 

 * 1: strongest, bigger is weaker. 
 * 0: off. 
 * -1: automatic, more when dark.
  
* /ws/version: Choose a version by number, then restart. Allows to switch to experimental versions for the current map. Currently:

 * dev: I experiment here. More debugging info,quick fixes, big rewrites, depends. May crash.
 * default: Used for hours of play in dev before updating.
 * jungle: Harder, more fun. It now rains heavily when bright, with cozy nights to relax. And erosion is much faster, do not mine in dirt :-)
 * kristalltuerme (kristall towers). Oder version before i mastered objects. Looks like skyscrapers popping up. May no longer be compatible.

##Three sorts of water...

There are three sorts of water in minetest/freeminer. Which are choosen globally for all maps, so when i /?/einen schönen see gestaut hast/ and switched to infinite liquid for another map and played this one again, water would go away :-(

* minetest 4.10 has infinite liquid, which multiplies while going down, but goes quick away. 
* 4.9 had an early try of realistic finity, which somehow got removed.  Sadly gone. With wasserspiel-rain land got quickly flooded, so i wrote evaporation. After some balance land flooded 2 nodes high which got away in the morning. /?/Ausser wenn es gestaut wurde/.
* freeminer tries relistic liquid. The 4.9-finite code works, but somehow produces much less water.

---
