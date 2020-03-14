# Auto Pilot Car

## Introduction

An interactive demonstration of the idea about auto pilot car learning from scratch(hitting the wall and die) and re-spawn then finally make it from the Egg place(start point) to the Farm house(end point).
Car powered by FeedForward Neuron Network and apply Genetic Algorithm to keep selecting/crossing over/mutating for the best sprouts to go through the track. Developed with Godot game engine. Have fun exploring! Extra: I really like the way people on the internet calls shibainu(A Japanese breed dog) "good boi" which sounds super cute to me and I am pretty much having the similar feeling about these cars while developing/testing this project so :), BOI(boy) = Car

## Acomplished Feature

### Status Panel

Current Generation, Live Cars, 1st & 2nd place performance given entire track, speed & turn information for current leading car, global best, etc


### Clickable Button

- **DISCARD BOI**: Discard global best performance car if you feel current best one may not act the way you want it to or you got stuck for a couple generations/runs already (I personally do not recommend click this button but just in case). **Precautious Level: High**

- **Next GENE**: Clear all existing/running cars and generate next generation based on the global best car without affecting any other data in a safe way (Use this when you see some cars doing "爱的魔力转圈圈"/Spinning around over 3 mins) **Precautious Level: None**

- **PRINT**: Save the your global recorded best car's gene/data into your local machine for future fun stuff (It should be under your system drive `C:\Users\<Your User Name>\AppData\Roaming\Godot\app_userdata\Self-Driving-Car-2D` please note `AppData` is usually a hidden folder) **Precautious Level: None**

- **CHAMPION**: Clear all existing/running cars and generate next generation based on a confirmed champion car that can run 100% with no fall.(Well if you have a super high learning rate, exception can still happen, explain later), this means you can compete your own well trained car with this one in the future or even compete by attending the race. Human VS AI!

### Scroller and Toggle

- **Learning**: A scroller range from 0 to 5 which stands for something like a learning rate. (But does not mean the higher the merrier) I recommend start at a high value and gradually decrease it when your car perform better and better

- **Manual Drive**: Player A wants to join the game!!! Will make one car controllable by you if there is one instance live for current run. Notice the button will always be disabled if you join and fail once.


Disclaimer: This is not/will not be used for Commercial purpose and i don't own any assets.
