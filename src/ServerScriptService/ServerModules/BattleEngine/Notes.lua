print("Notes")
--[[
Notes to self regarding Battle Engine (particularly program flow)


Input Process:
Server makes a request
...
Client creates `choice`, sends to BattleEngine:choose
BattleEngine:choose creates a `decision` for the side by calling BattleEngine:parseChoice(choice, side)

If both decisions are present, BattleEngine:commitDecisions is called
For each side, side:resolveDecision is called and the result is added to the queue
BattleEngine:go is called







MaybeTrapped is a flag that indicates the Pokemon is within the reach of an ability that an opponent MAY have
The opponent doesn't necessarily have that Ability, but the client won't know that until they attempt to make a switch
--]]