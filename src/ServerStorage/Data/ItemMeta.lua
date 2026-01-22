print("ItemMeta")

return require(script.Parent.CSV)([[item_id,name,sell_price,bag_kind,battle_kind,desc
1,Master Ball,,3,1,"The best Pok[e'] Ball with the ultimate level of performance. With it, you will catch any wild pokemon without fail."
2,Ultra Ball,600,3,1,An ultra-high-performance Pok[e'] Ball that provides a higher success rate for catching pokemon than a Great Ball.
3,Great Ball,300,3,1,"A good, high-performance Pok[e'] Ball that provides a higher pokemon catch rate than a standard Pok[e'] Ball can."
4,Poke Ball,100,3,1,"A device for catching wild pokemon. It's thrown like a ball at a pokemon, comfortably encapsulating its target."
5,Safari Ball,,3,1,A special Pok[e'] Ball that is used only in the Great Marsh. It is recognizable by the camouflage pattern decorating it.
6,Net Ball,500,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Water- or Bug-type pokemon.
7,Dive Ball,500,3,1,A somewhat different Pok[e'] Ball that works especially well when catching pokemon that live underwater.
8,Nest Ball,500,3,1,A somewhat different Pok[e'] Ball that becomes more effective the lower the level of the wild pokemon.
9,Repeat Ball,500,3,1,A somewhat different Pok[e'] Ball that works especially well on a pokemon species that has been caught before.
10,Timer Ball,500,3,1,A somewhat different Pok[e'] Ball that becomes progressively more effective the more turns that are taken in battle.
11,Luxury Ball,500,3,1,A particularly comfortable Pok[e'] Ball that makes a wild pokemon quickly grow friendlier after being caught.
12,Premier Ball,100,3,1,A somewhat rare Pok[e'] Ball that was made as a commemorative item used to celebrate an event of some sort.
13,Dusk Ball,500,3,1,A somewhat different Pok[e'] Ball that makes it easier to catch wild pokemon at night or in dark places like caves.
14,Heal Ball,150,3,1,A remedial Pok[e'] Ball that restores the HP of a pokemon caught with it and eliminates any status conditions.
15,Quick Ball,500,3,1,A somewhat different Pok[e'] Ball that has a more successful catch rate if used at the start of a wild encounter.
16,Cherish Ball,100,3,1,A quite rare Pok[e'] Ball that has been crafted in order to commemorate a special occasion of some sort.
17,Potion,150,2,2,A spray-type medicine for treating wounds. It can be used to restore 20 HP to an injured pokemon.
18,Antidote,50,2,2,A spray-type medicine for poisoning. It can be used once to lift the effects of being poisoned from a pokemon.
19,Burn Heal,125,2,2,A spray-type medicine for treating burns. It can be used once to heal a pokemon suffering from a burn.
20,Ice Heal,125,2,2,A spray-type medicine for freezing. It can be used once to defrost a pokemon that has been frozen solid.
21,Awakening,125,2,2,A spray-type medicine used against sleep. It can be used once to rouse a pokemon from the clutches of sleep.
22,Paralyze Heal,100,2,2,A spray-type medicine for paralysis. It can be used once to free a pokemon that has been paralyzed.
23,Full Restore,1500,2,2,A medicine that can be used to fully restore the HP of a single pokemon and heal any status conditions it has.
24,Max Potion,1250,2,2,A spray-type medicine for treating wounds. It will completely restore the max HP of a single pokemon.
25,Hyper Potion,600,2,2,A spray-type medicine for treating wounds. It can be used to restore 200 HP to an injured pokemon.
26,Super Potion,350,2,2,A spray-type medicine for treating wounds. It can be used to restore 50 HP to an injured pokemon.
27,Full Heal,300,2,2,A spray-type medicine that is broadly effective. It can be used once to heal all the status conditions of a pokemon.
28,Revive,750,2,2,A medicine that can revive fainted pokemon. It also restores half of a fainted pokemon's maximum HP.
29,Max Revive,2000,2,2,A medicine that can revive fainted pokemon. It also fully restores a fainted pokemon's maximum HP.
30,Fresh Water,100,2,2,"Water with a high mineral content. When consumed, it restores 50 HP to an injured pokemon."
31,Soda Pop,150,2,2,"A highly carbonated soda drink. When consumed, it restores 60 HP to an injured pokemon."
32,Lemonade,175,2,2,"A very sweet and refreshing drink. When consumed, it restores 80 HP to an injured pokemon."
33,Moomoo Milk,250,2,2,"A bottle of highly nutritious milk. When consumed, it restores 100 HP to an injured pokemon."
34,Energy Powder,250,2,2,"A bitter medicine powder. When consumed, it restores 50 HP to an injured pokemon."
35,Energy Root,400,2,2,"An extremely bitter medicinal root. When consumed, it restores 200 HP to an injured pokemon."
36,Heal Powder,225,2,2,"A very bitter medicine powder. When consumed, it heals all of a pokemon's status conditions."
37,Revival Herb,1400,2,2,A terribly bitter medicinal herb. It revives a fainted pokemon and fully restores its maximum HP.
38,Ether,600,2,2,This medicine can restore 10 PP to a single selected move that has been learned by a pokemon.
39,Max Ether,1000,2,2,This medicine can fully restore the PP of a single selected move that has been learned by a pokemon.
40,Elixir,1500,2,2,This medicine can restore 10 PP to each of the moves that have been learned by a pokemon.
41,Max Elixir,2250,2,2,This medicine can fully restore the PP of all of the moves that have been learned by a pokemon.
42,Lava Cookie,100,2,2,Lavaridge Town's local specialty. It can be used once to heal all the status conditions of a pokemon.
43,Berry Juice,50,2,2,"A 100 percent pure juice made of Berries. When consumed, it restores 20 HP to an injured pokemon."
44,Sacred Ash,100,2,2,"This rare ash can revive all fainted pokemon in a party. In doing so, it also fully restores their maximum HP."
45,HP Up,4900,2,,"A nutritious drink for pokemon. When consumed, it raises the base HP of a single pokemon."
46,Protein,4900,2,,"A nutritious drink for pokemon. When consumed, it raises the base Attack stat of a single pokemon."
47,Iron,4900,2,,"A nutritious drink for pokemon. When consumed, it raises the base Defense stat of a single pokemon."
48,Carbos,4900,2,,"A nutritious drink for pokemon. When consumed, it raises the base Speed stat of a single pokemon."
49,Calcium,4900,2,,"A nutritious drink for pokemon. When consumed, it raises the base Sp. Atk stat of a single pokemon."
50,Rare Candy,2400,2,,"A candy that is packed with energy. When consumed, it will instantly raise the level of a single pokemon by one."
51,PP Up,4900,2,,A medicine that can slightly raise the maximum PP of a single move that has been learned by the target pokemon.
52,Zinc,4900,2,,"A nutritious drink for pokemon. When consumed, it raises the base Sp. Def stat of a single pokemon."
53,PP Max,4900,2,,A medicine that can optimally raise the maximum PP of a single move that has been learned by the target pokemon.
54,Old Gateau,100,2,2,The Old Chateau's hidden specialty. It can be used once to heal all the status conditions of a pokemon.
55,Guard Spec.,350,1,3,An item that prevents stat reduction among the Trainer's party pokemon for five turns after it is used in battle.
56,Dire Hit,325,1,3,An item that raises the critical-hit ratio greatly. It can be used only once and wears off if the pokemon is withdrawn.
57,X Attack,250,1,3,An item that boosts the Attack stat of a pokemon during a battle. It wears off once the pokemon is withdrawn.
58,X Defense,275,1,3,An item that boosts the Defense stat of a pokemon during a battle. It wears off once the pokemon is withdrawn.
59,X Speed,175,1,3,An item that boosts the Speed stat of a pokemon during a battle. It wears off once the pokemon is withdrawn.
60,X Accuracy,475,1,3,An item that boosts the accuracy of a pokemon during a battle. It wears off once the pokemon is withdrawn.
61,X Sp. Atk,175,1,3,An item that boosts the Sp. Atk stat of a pokemon during a battle. It wears off once the pokemon is withdrawn.
62,X Sp. Def,175,1,3,An item that boosts the Sp. Def stat of a pokemon during a battle. It wears off once the pokemon is withdrawn.
63,Poke Doll,500,1,3,A doll that attracts the attention of a pokemon. It guarantees escape from any battle with wild pokemon.
64,Fluffy Tail,500,1,3,A toy that attracts the attention of a pokemon. It guarantees escape from any battle with wild pokemon.
65,Blue Flute,200,1,,A flute made from blue glass that awakens sleeping pokemon.
66,Yellow Flute,200,1,,A flute made from white glass. It makes it easier to encounter Strong Pokemon in the place you use it.
67,Red Flute,200,1,,A flute made from red glass that snaps pokemon out of infatuation.
68,Black Flute,200,1,,A flute made from black glass. It makes it easier to encounter Strong Pokemon in the place you use it.
69,White Flute,200,1,,A flute made from yellow glass that snaps pokemon out of confusion.
70,Shoal Salt,10,1,,Pure salt that can be discovered only deep inside the Shoal Cave.
71,Shoal Shell,10,1,,A pretty seashell that can be found deep inside the Shoal Cave.
72,Red Shard,100,1,,A small red shard. It appears to be a fragment of some sort of implement made long ago.
73,Blue Shard,100,1,,A small blue shard. It appears to be a fragment of some sort of implement made long ago.
74,Yellow Shard,100,1,,A small yellow shard. It appears to be a fragment of some sort of implement made long ago.
75,Green Shard,100,1,,A small green shard. It appears to be a fragment of some sort of implement made long ago.
76,Super Repel,250,1,,An item that prevents any low-level wild pokemon from jumping out at you for 200 steps after its use.
77,Max Repel,350,1,,An item that prevents any low-level wild pokemon from jumping out at you for 250 steps after its use.
78,Escape Rope,275,1,,A long and durable rope. Use it to escape instantly from a cave or a dungeon.
79,Repel,175,1,,An item that prevents any low-level wild pokemon from jumping out at you for 100 steps after its use.
80,Sun Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It burns as red as the evening sun.
81,Moon Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It is as black as the night sky.
82,Fire Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. The stone has a fiery orange heart.
83,Thunder Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It has a distinct thunderbolt pattern.
84,Water Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It is the blue of a pool of clear water.
85,Leaf Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It has an unmistakable leaf pattern.
86,Tiny Mushroom,250,1,,A very small and rare mushroom. It's popular with a certain class of collectors and sought out by them.
87,Big Mushroom,2500,1,,A very large and rare mushroom. It's popular with a certain class of collectors and sought out by them.
88,Pearl,700,1,,A rather small pearl that has a very nice silvery sheen to it. It can be sold cheaply to shops.
89,Big Pearl,3750,1,,A rather large pearl that has a very nice silvery sheen. It can be sold to shops for a high price.
90,Stardust,1000,1,,"Lovely, red sand that flows between the fingers with a loose, silky feel. It can be sold at a high price to shops."
91,Star Piece,4900,1,,A small shard of a beautiful gem that demonstrates a distinctly red sparkle. It can be sold at a high price to shops.
92,Nugget,5000,1,,A nugget of the purest gold that gives off a lustrous gleam in direct light. It can be sold at a high price to shops.
93,Heart Scale,50,1,,"A pretty, heart-shaped scale that is extremely rare. It glows faintly with all of the colors of the rainbow."
94,Honey,50,1,,"A sweet honey with a lush aroma that attracts wild pokemon when it is slathered on special trees."
95,Growth Mulch,100,1,,A fertilizer to be spread on soft soil in regions where Berries are grown.
96,Damp Mulch,100,1,,A fertilizer to be spread on soft soil in regions where Berries are grown.
97,Stable Mulch,100,1,,A fertilizer to be spread on soft soil in regions where Berries are grown.
98,Gooey Mulch,100,1,,A fertilizer to be spread on soft soil in regions where Berries are grown.
99,Root Fossil,500,1,,A fossil from a prehistoric pokemon that once lived in the sea. It looks as if it could be part of a plant's root.
100,Claw Fossil,500,1,,A fossil from a prehistoric pokemon that once lived in the sea. It appears to be a fragment of a claw.
101,Helix Fossil,500,1,,A fossil from a prehistoric pokemon that once lived in the sea. It might be a piece of a seashell.
102,Dome Fossil,500,1,,A fossil from a prehistoric pokemon that once lived in the sea. It could be a shell or carapace.
103,Old Amber,500,1,,"A piece of amber that still contains the genetic material of an ancient pokemon. It's clear with a tawny, reddish tint."
104,Armor Fossil,500,1,,A fossil from a prehistoric pokemon that once lived on the land. It looks to be from some kind of protective collar.
105,Skull Fossil,500,1,,A fossil from a prehistoric pokemon that once lived on the land. It appears as though it's part of a head.
106,Rare Bone,5000,1,,A rare bone that is extremely valuable for the study of pokemon archeology. It can be sold for a high price to shops.
107,Shiny Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It shines with a dazzling light.
108,Dusk Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It holds shadows as dark as can be.
109,Dawn Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It sparkles like a glittering eye.
110,Oval Stone,1050,1,,A peculiar stone that can make certain species of pokemon evolve. It's as round as a pokemon Egg.
111,Odd Keystone,1050,1,,A vital item that is needed to keep a stone tower from collapsing. Voices can be heard from it occasionally.
112,Griseous Orb,5000,1,,A glowing orb to be held by Giratina. It boosts the power of Dragon- and Ghost-type moves when it is held.
113,Douse Drive,500,1,,A cassette to be held by Genesect. It changes Genesect's Techno Blast move so it becomes Water type.
114,Shock Drive,500,1,,A cassette to be held by Genesect. It changes Genesect's Techno Blast move so it becomes Electric type.
115,Burn Drive,500,1,,A cassette to be held by Genesect. It changes Genesect's Techno Blast move so it becomes Fire type.
116,Chill Drive,500,1,,A cassette to be held by Genesect. It changes Genesect's Techno Blast move so it becomes Ice type.
117,Sweet Heart,50,1,,"A piece of cloyingly sweet chocolate. When consumed, it restores 20 HP to an injured pokemon."
118,Adamant Orb,5000,1,,A brightly gleaming orb to be held by Dialga. It boosts the power of Dragon- and Steel-type moves when it is held.
119,Lustrous Orb,5000,1,,A beautifully glowing orb to be held by Palkia. It boosts the power of Dragon- and Water-type moves when it is held.
120,Greet Mail,25,,,
121,Favored Mail,25,,,
122,RSVP Mail,25,,,
123,Thanks Mail,25,,,
124,Inquiry Mail,25,,,
125,Like Mail,25,,,
126,Reply Mail,25,,,
127,Bridge Mail S,25,,,
128,Bridge Mail D,5,,,
129,Bridge Mail T,25,,,
130,Bridge Mail V,25,,,
131,Bridge Mail M,25,,,
132,Cheri Berry,10,4,2,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from paralysis on its own in battle."
133,Chesto Berry,10,4,2,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from sleep on its own in battle."
134,Pecha Berry,10,4,2,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from poisoning on its own in battle."
135,Rawst Berry,10,4,2,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from a burn on its own in battle."
136,Aspear Berry,10,4,2,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from being frozen on its own in battle."
137,Leppa Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, it can restore 10 PP to a depleted move during battle."
138,Oran Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, it can restore its own HP by 10 points during battle."
139,Persim Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from confusion on its own in battle."
140,Lum Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, it can recover from any status condition during battle."
141,Sitrus Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, it can restore its own HP by a small amount during battle."
142,Figy Berry,10,4,,"If held by a pokemon, it restores the user's HP in a pinch, but it will cause confusion if the user hates the taste."
143,Wiki Berry,10,4,,"If held by a pokemon, it restores the user's HP in a pinch, but it will cause confusion if the user hates the taste."
144,Mago Berry,10,4,,"If held by a pokemon, it restores the user's HP in a pinch, but it will cause confusion if the user hates the taste."
145,Aguav Berry,10,4,,"If held by a pokemon, it restores the user's HP in a pinch, but it will cause confusion if the user hates the taste."
146,Iapapa Berry,10,4,,"If held by a pokemon, it restores the user's HP in a pinch, but it will cause confusion if the user hates the taste."
147,Razz Berry,10,4,,Used to make Pok[e']blocks that will enhance your Coolness. Its red flesh is spicy when eaten.
148,Bluk Berry,10,4,,Used to make Pok[e']blocks that will enhance your Beauty. Its blue flesh is sour when eaten.
149,Nanab Berry,10,4,,Used to make Pok[e']blocks that will enhance your Cuteness. Its pink flesh is sweet when eaten.
150,Wepear Berry,10,4,,Used to make Pok[e']blocks that will enhance your Cleverness. Its green flesh is bitter when eaten.
151,Pinap Berry,10,4,,Used to make Pok[e']blocks that will enhance your Toughness. Its yellow flesh is sour when eaten.
152,Pomeg Berry,10,4,,A Berry to be consumed by pokemon. Using it on a pokemon makes it more friendly but lowers its base HP.
153,Kelpsy Berry,10,4,,A Berry to be consumed by pokemon. Using it on a pokemon makes it more friendly but lowers its base Attack.
154,Qualot Berry,10,4,,A Berry to be consumed by pokemon. Using it on a pokemon makes it more friendly but lowers its base Defense.
155,Hondew Berry,10,4,,A Berry to be consumed by pokemon. Using it on a pokemon makes it more friendly but lowers its base Sp. Atk.
156,Grepa Berry,10,4,,A Berry to be consumed by pokemon. Using it on a pokemon makes it more friendly but lowers its base Sp. Def.
157,Tamato Berry,10,4,,A Berry to be consumed by pokemon. Using it on a pokemon makes it more friendly but lowers its base Speed.
158,Cornn Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Beauty, this Berry is rare in other regions."
159,Magost Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Cuteness, this Berry is rare in other regions."
160,Rabuta Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Cleverness, this Berry is rare in other regions."
161,Nomel Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Toughness, this Berry is rare in other regions."
162,Spelon Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Cuteness, this Berry is rare in other regions."
163,Pamtre Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Beauty, this Berry is rare in other regions."
164,Watmel Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Cleverness, this Berry is rare in other regions."
165,Durin Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Cleverness, this Berry is rare in other regions."
166,Belue Berry,10,4,,"Used to make Pok[e']blocks that will enhance your Beauty, this Berry is rare in other regions."
167,Occa Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Fire-type attack."
168,Passho Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Water-type attack."
169,Wacan Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Electric-type attack."
170,Rindo Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Grass-type attack."
171,Yache Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Ice-type attack."
172,Chople Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Fighting-type attack."
173,Kebia Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Poison-type attack."
174,Shuca Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Ground-type attack."
175,Coba Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Flying-type attack."
176,Payapa Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Psychic-type attack."
177,Tanga Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Bug-type attack."
178,Charti Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Rock-type attack."
179,Kasib Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Ghost-type attack."
180,Haban Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Dragon-type attack."
181,Colbur Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Dark-type attack."
182,Babiri Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Steel-type attack."
183,Chilan Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one Normal-type attack."
184,Liechi Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its Attack stat will increase when it's in a pinch."
185,Ganlon Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its Defense stat will increase when it's in a pinch."
186,Salac Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its Speed stat will increase when it's in a pinch."
187,Petaya Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its Sp. Atk stat will increase when it's in a pinch."
188,Apicot Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its Sp. Def stat will increase when it's in a pinch."
189,Lansat Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its critical-hit ratio will increase when it's in a pinch."
190,Starf Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, one of its stats will sharply increase when it's in a pinch."
191,Enigma Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, being hit by a supereffective attack will restore its HP."
192,Micle Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, its accuracy will increase just once when it's in a pinch."
193,Custap Berry,10,4,,"A Berry to be consumed by pokemon. If a pokemon holds one, it will be able to move first just once when it's in a pinch."
194,Jaboca Berry,10,4,,"A Berry to be consumed by pokemon. If a physical attack hits the pokemon holding it, the attacker will also be hurt."
195,Rowap Berry,10,4,,"A Berry to be consumed by pokemon. If a special attack hits the pokemon holding it, the attacker will also be hurt."
196,Bright Powder,50,1,,An item to be held by a pokemon. It casts a tricky glare that lowers the opposing pokemon's accuracy.
197,White Herb,50,1,,An item to be held by a pokemon. It will restore any lowered stat in battle. It can be used only once.
198,Macho Brace,1500,1,,"An item to be held by a pokemon. This stiff, heavy brace helps pokemon grow strong but cuts Speed in battle."
199,Exp. Share,,5,,Turning on this special device will allow all the pokemon on your team to receive Exp. Points from battles.
200,Quick Claw,50,1,,"An item to be held by a pokemon. This light, sharp claw lets the bearer move first occasionally."
201,Soothe Bell,50,1,,"An item to be held by a pokemon. The comforting chime of this bell calms the holder, making it friendly."
202,Mental Herb,50,1,,An item to be held by a pokemon. It snaps the holder out of infatuation. It can be used only once.
203,Choice Band,50,1,,An item to be held by a pokemon. This curious headband boosts Attack but only allows the use of one move.
204,King's Rock,50,1,,"An item to be held by a pokemon. When the holder successfully inflicts damage, the target may also flinch."
205,Silver Powder,50,1,,"An item to be held by a pokemon. It is a shiny, silver powder that will boost the power of Bug-type moves."
206,Amulet Coin,50,1,,An item to be held by a pokemon. It doubles any prize money received if the holding pokemon joins a battle.
207,Cleanse Tag,100,1,,An item to be held by a pokemon. It helps keep wild pokemon away if the holder is the head of the party.
208,Soul Dew,100,1,,A wondrous orb to be held by either Latios or Latias. It raises both the Sp. Atk and Sp. Def stats.
209,Deep Sea Tooth,100,1,,An item to be held by Clamperl. This fang gleams a sharp silver and raises the holder's Sp. Atk stat.
210,Deep Sea Scale,100,1,,An item to be held by Clamperl. This scale shines with a faint pink and raises the holder's Sp. Def stat.
211,Smoke Ball,100,1,,An item to be held by a pokemon. It enables the holder to flee from any wild pokemon encounter without fail.
212,Everstone,100,1,,An item to be held by a pokemon. A pokemon holding this peculiar stone is prevented from evolving.
213,Focus Band,100,1,,"An item to be held by a pokemon. The holder may endure a potential KO attack, leaving it with just 1 HP."
214,Lucky Egg,100,1,,An item to be held by a pokemon. It's an egg filled with happiness that earns extra Exp. Points in battle.
215,Scope Lens,100,1,,An item to be held by a pokemon. It's a lens for scoping out weak points. It boosts the holder's critical-hit ratio.
216,Metal Coat,50,1,,An item to be held by a pokemon. It is a special metallic film that can boost the power of Steel-type moves.
217,Leftovers,100,1,,An item to be held by a pokemon. The holder's HP is slowly but steadily restored throughout every battle.
218,Dragon Scale,1050,1,,A very tough and inflexible scale. Dragon-type pokemon may be holding this item when caught.
219,Light Ball,50,1,,An item to be held by Pikachu. It's a puzzling orb that boosts its Attack and Sp. Atk stats.
220,Soft Sand,50,1,,"An item to be held by a pokemon. It is a loose, silky sand that boosts the power of Ground-type moves."
221,Hard Stone,50,1,,An item to be held by a pokemon. It is a durable stone that boosts the power of Rock-type moves.
222,Miracle Seed,50,1,,An item to be held by a pokemon. It is a seed imbued with life force that boosts the power of Grass-type moves.
223,Black Glasses,50,1,,An item to be held by a pokemon. A pair of shady-looking glasses that boost the power of Dark-type moves.
224,Black Belt,50,1,,An item to be held by a pokemon. This belt helps the wearer to focus and boosts the power of Fighting-type moves.
225,Magnet,50,1,,An item to be held by a pokemon. It is a powerful magnet that boosts the power of Electric-type moves.
226,Mystic Water,50,1,,An item to be held by a pokemon. This teardrop-shaped gem boosts the power of Water-type moves.
227,Sharp Beak,50,1,,"An item to be held by a pokemon. It's a long, sharp beak that boosts the power of Flying-type moves."
228,Poison Barb,50,1,,"An item to be held by a pokemon. This small, poisonous barb boosts the power of Poison-type moves."
229,Never-Melt Ice,50,1,,An item to be held by a pokemon. It's a piece of ice that repels heat effects and boosts Ice-type moves.
230,Spell Tag,50,1,,"An item to be held by a pokemon. It's a sinister, eerie tag that boosts the power of Ghost-type moves."
231,Twisted Spoon,50,1,,An item to be held by a pokemon. This spoon is imbued with telekinetic power and boosts Psychic-type moves.
232,Charcoal,100,1,,An item to be held by a pokemon. It is a combustible fuel that boosts the power of Fire-type moves.
233,Dragon Fang,50,1,,An item to be held by a pokemon. This hard and sharp fang boosts the power of Dragon-type moves.
234,Silk Scarf,50,1,,An item to be held by a pokemon. It's a sumptuous scarf that boosts the power of Normal-type moves.
235,Up-Grade,1050,1,,A transparent device somehow filled with all sorts of data. It was produced by Silph Co.
236,Shell Bell,100,1,,An item to be held by a pokemon. The holder regains a little HP every time it inflicts damage on others.
237,Sea Incense,4800,1,,An item to be held by a pokemon. This incense has a curious aroma that boosts the power of Water-type moves.
238,Lax Incense,4800,1,,An item to be held by a pokemon. The beguiling aroma of this incense may cause attacks to miss its holder.
239,Lucky Punch,5,1,,An item to be held by Chansey. This pair of lucky boxing gloves will boost Chansey's critical-hit ratio.
240,Metal Powder,5,1,,"An item to be held by Ditto. Extremely fine yet hard, this odd powder boosts the Defense stat."
241,Stick,100,1,,An item to be held by Farfetch'd. This very long and stiff stalk of leek boosts its critical-hit ratio.
242,Red Scarf,50,1,,"An item to be held by a pokemon. During a Contest, it raises the Cool aspect of the pokemon holding it."
243,Blue Scarf,50,1,,"An item to be held by a pokemon. During a Contest, it raises the Beauty aspect of the pokemon holding it."
244,Pink Scarf,50,1,,"An item to be held by a pokemon. During a Contest, it raises the Cute aspect of the pokemon holding it."
245,Green Scarf,50,1,,"An item to be held by a pokemon. During a Contest, it raises the Smart aspect of the pokemon holding it."
246,Yellow Scarf,50,1,,"An item to be held by a pokemon. During a Contest, it raises the Tough aspect of the pokemon holding it."
247,Wide Lens,100,1,,An item to be held by a pokemon. It's a magnifying lens that slightly boosts the accuracy of moves.
248,Muscle Band,100,1,,"An item to be held by a pokemon. This headband exudes strength, slightly boosting the power of physical moves."
249,Wise Glasses,100,1,,An item to be held by a pokemon. This thick pair of glasses slightly boosts the power of special moves.
250,Expert Belt,100,1,,An item to be held by a pokemon. It's a well-worn belt that slightly boosts the power of supereffective moves.
251,Light Clay,100,1,,An item to be held by a pokemon. Protective moves like Light Screen and Reflect will be effective longer.
252,Life Orb,100,1,,"An item to be held by a pokemon. It boosts the power of moves, but at the cost of some HP on each hit."
253,Power Herb,50,1,,A single-use item to be held by a pokemon. It allows the holder to immediately use a move that normally requires a turn to charge.
254,Toxic Orb,50,1,,An item to be held by a pokemon. It is a bizarre orb that will badly poison the holder during battle.
255,Flame Orb,50,1,,An item to be held by a pokemon. It is a bizarre orb that will afflict the holder with a burn during battle.
256,Quick Powder,5,1,,"An item to be held by Ditto. Extremely fine yet hard, this odd powder boosts the Speed stat."
257,Focus Sash,100,1,,"An item to be held by a pokemon. If the holder has full HP, it will endure a potential KO attack with 1 HP. The item then disappears."
258,Zoom Lens,100,1,,"An item to be held by a pokemon. If the holder moves after its target moves, its accuracy will be boosted."
259,Metronome,100,1,,"An item to be held by a pokemon. It boosts moves used consecutively, but only until a different move is used."
260,Iron Ball,100,1,,An item to be held by a pokemon. It lowers Speed and allows Ground-type moves to hit Flying-type and levitating holders.
261,Lagging Tail,100,1,,An item to be held by a pokemon. It is tremendously heavy and makes the holder move slower than usual.
262,Destiny Knot,100,1,,"An item to be held by a pokemon. If the holder becomes infatuated, the opposing pokemon will be, too."
263,Black Sludge,100,1,,An item to be held by a pokemon. It gradually restores HP to Poison-type pokemon. It damages any other type.
264,Icy Rock,100,1,,An item to be held by a pokemon. It extends the duration of the move Hail when it's used by the holder.
265,Smooth Rock,100,1,,An item to be held by a pokemon. It extends the duration of the move Sandstorm when used by the holder.
266,Heat Rock,100,1,,An item to be held by a pokemon. It extends the duration of the move Sunny Day when used by the holder.
267,Damp Rock,100,1,,An item to be held by a pokemon. It extends the duration of the move Rain Dance when used by the holder.
268,Grip Claw,100,1,,An item to be held by a pokemon. It extends the duration of multi-turn attacks like Bind and Wrap.
269,Choice Scarf,100,1,,An item to be held by a pokemon. This curious scarf boosts Speed but only allows the use of one move.
270,Sticky Barb,100,1,,An item to be held by a pokemon. It damages the holder every turn and may latch on to pokemon that touch the holder.
271,Power Bracer,1500,1,,An item to be held by a pokemon. It reduces Speed but allows the holder's Attack stat to grow more after battling.
272,Power Belt,1500,1,,An item to be held by a pokemon. It reduces Speed but allows the holder's Defense stat to grow more after battling.
273,Power Lens,1500,1,,An item to be held by a pokemon. It reduces Speed but allows the holder's Sp. Atk stat to grow more after battling.
274,Power Band,1500,1,,An item to be held by a pokemon. It reduces Speed but allows the holder's Sp. Def stat to grow more after battling.
275,Power Anklet,1500,1,,An item to be held by a pokemon. It reduces Speed but allows the holder's Speed stat to grow more after battling.
276,Power Weight,1500,1,,An item to be held by a pokemon. It reduces Speed but allows the holder's maximum HP to grow more after battling.
277,Shed Shell,50,1,,An item to be held by a pokemon. This discarded carapace enables the holder to switch out of battle without fail.
278,Big Root,100,1,,An item to be held by a pokemon. It boosts the power of HP-stealing moves so the holder recovers more HP.
279,Choice Specs,100,1,,An item to be held by a pokemon. These curious glasses boost Sp. Atk but only allow the use of one move.
280,Flame Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Fire-type moves.
281,Splash Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Water-type moves.
282,Zap Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Electric-type moves.
283,Meadow Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Grass-type moves.
284,Icicle Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Ice-type moves.
285,Fist Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Fighting-type moves.
286,Toxic Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Poison-type moves.
287,Earth Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Ground-type moves.
288,Sky Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Flying-type moves.
289,Mind Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Psychic-type moves.
290,Insect Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Bug-type moves.
291,Stone Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Rock-type moves.
292,Spooky Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Ghost-type moves.
293,Draco Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Dragon-type moves.
294,Dread Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Dark-type moves.
295,Iron Plate,500,1,,An item to be held by a pokemon. It's a stone tablet that boosts the power of Steel-type moves.
296,Odd Incense,4800,1,,An item to be held by a pokemon. This exotic-smelling incense boosts the power of Psychic-type moves.
297,Rock Incense,4800,1,,An item to be held by a pokemon. This exotic-smelling incense boosts the power of Rock-type moves.
298,Full Incense,4800,1,,An item to be held by a pokemon. This exotic-smelling incense makes the holder bloated and slow moving.
299,Wave Incense,4800,1,,An item to be held by a pokemon. This exotic-smelling incense boosts the power of Water-type moves.
300,Rose Incense,4800,1,,An item to be held by a pokemon. This exotic-smelling incense boosts the power of Grass-type moves.
301,Luck Incense,4800,1,,An item to be held by a pokemon. It doubles any prize money received if the holding pokemon joins a battle.
302,Pure Incense,4800,1,,An item to be held by a pokemon. It helps keep wild pokemon away if the holder is the head of the party.
303,Protector,1050,1,,A protective item of some sort. It is extremely stiff and heavy. It's loved by a certain pokemon.
304,Electirizer,1050,1,,A box packed with a tremendous amount of electric energy. It's loved by a certain pokemon.
305,Magmarizer,1050,1,,A box packed with a tremendous amount of magma energy. It's loved by a certain pokemon.
306,Dubious Disc,1050,1,,A transparent device overflowing with dubious data. Its producer is unknown.
307,Reaper Cloth,1050,1,,A cloth imbued with horrifyingly strong spiritual energy. It's loved by a certain pokemon.
308,Razor Claw,1050,1,,An item to be held by a pokemon. This sharply hooked claw increases the holder's critical-hit ratio.
309,Razor Fang,1050,1,,"An item to be held by a pokemon. When the holder successfully inflicts damage, the target may also flinch."
310,[TM:Dark],,,,
311,[TM:Dragon],,,,
312,[TM:Psychic],,,,
313,[TM:Normal],,,,
314,[TM:Poison],,,,
315,[TM:Ice],,,,
316,[TM:Fighting],,,,
317,[TM:Fire],,,,
318,[TM:Water],,,,
319,[TM:Grass],,,,
320,[TM:Rock],,,,
321,[TM:Electric],,,,
322,[TM:Ground],,,,
323,[TM:Ghost],,,,
324,[TM:Flying],,,,
325,[TM:Steel],,,,
326,[TM:Bug],,,,
327,[HM:Normal],,,,
328,[HM:Flying],,,,
329,[HM:Water],,,,
330,Explorer Kit,,5,,A bag filled with convenient tools for exploring. It provides access to the Underground in the Sinnoh region.
331,Loot Sack,,5,,"A sturdy, spacious bag that is used to carry any treasures or loot obtained in the coal mine."
332,Rule Book,,5,,"It lists the rules for holding battles. For Link Battles, you may choose which set of rules you wish to use."
333,Poke Radar,,5,,A tool that can search out pokemon that are hiding in the tall grass. Its battery is recharged as you walk.
334,Point Card,,5,,A card that lists how many Battle Points you have earned.
335,Journal,,5,,A notebook that keeps a day-to-day record of your adventure so far.
336,Seal Case,,5,,A case for storing Seals that can be applied to the exteriors of Pok[e'] Balls.
337,Fashion Case,,5,,A lovely case to store colorful Props for your pokemon to wear in a musical.
338,Seal Bag,,5,,A tiny bag that can hold 10 Seals for decorating Pok[e'] Balls.
339,Pal Pad,,5,,A convenient notepad that is used to register your Friends and friend codes and keep a record of your gameplay.
340,Works Key,,5,,A large key for operating the doors of the Valley Windworks in the canyon. It was held by a Team Galactic Grunt.
341,Old Charm,,5,,An ancient good-luck charm made of pokemon bones to be taken to the elder of Celestic Town.
342,Galactic Key,,5,,"A card key for disengaging the security systems in the Galactic HQ. Losing it can result in punishment, apparently."
343,Red Chain,,5,,A mythical chain that is said to link the Legendary pokemon that created the Sinnoh region.
344,Town Map,,5,,A very convenient map that can be viewed anytime. It even shows you your present location in the region.
345,Vs. Seeker,,5,,A device that indicates Trainers who want to battle. Its battery charges while you walk.
346,Coin Case,,5,,"A case for holding coins obtained at the Game Corner. It can hold up to 50,000 coins."
347,Old Rod,,5,,An old and beat-up fishing rod. Use it at any body of water to fish for wild aquatic pokemon.
348,Good Rod,,5,,"A new, good-quality fishing rod. Use it at any body of water to fish for wild aquatic pokemon."
349,Super Rod,,5,,"An awesome, high-tech fishing rod. Use it at any body of water to fish for wild aquatic pokemon."
350,Sprayduck,,5,,"A watering can shaped like a Psyduck. It helps promote the healthy growth of any Berries planted in good, soft soil."
351,Poffin Case,,5,,A case for storing Poffins cooked from Berries.
352,Bicycle,,5,,A folding Bicycle that enables a rider to get around much faster than a pair of Running Shoes will allow.
353,Core Key,,5,,"A key to the facility containing Anthian City's energy core. The entrance can be found in Anthian's sewers."
354,Oak's Letter,,5,,A letter from Professor Oak. Written in it is a request for you to go to Route 224.
355,Lunar Wing,,5,,A feather that glows like the moon. It's said to possess the power to dispel nightmares.
356,Member Card,,5,,"A card needed for entering the inn in Canalave City. Oddly, the last date marked on it was 50 years ago."
357,Azure Flute,,5,,A flute that puts out echoing sounds that do not seem to be of this world. No one knows who made it.
358,S.S. Ticket,,5,,A ticket required for sailing on the ferry S.S. Aqua. It has a drawing of a ship on its front.
359,Contest Pass,,5,,A pass required for entering pokemon Contests. It has a drawing of an award ribbon on its front.
360,Magma Stone,,5,,"A stone formed by boulders melting in intensely hot magma, then hardening. Magma remains sealed inside it."
361,Parcel,,5,,A parcel entrusted into your care. You are supposed to deliver it to your childhood friend who left Twinleaf Town.
362,Coupon 1,,5,,A coupon to be exchanged for a pokemon Watch--Pok[e']tch for short. Three coupons are needed.
363,Coupon 2,,5,,A coupon to be exchanged for a pokemon Watch--Pok[e']tch for short. Three coupons are needed.
364,Coupon 3,,5,,A coupon to be exchanged for a pokemon Watch--Pok[e']tch for short. Three coupons are needed.
365,Galactic Storage Key,,5,,The key to Team Galactic's sinister warehouse located at the edge of Veilstone City.
366,Secret Potion,,5,,A fantastic medicine dispensed by the pharmacy in Cianwood City. It fully heals a pokemon of any ailment.
367,Vs. Recorder,,5,,An amazing device that can record a battle between friends or the battles at certain special battle facilities.
368,Gracidea,,5,,A flower sometimes bundled in bouquets to convey gratitude on special occasions like birthdays.
369,Secret Key,,5,,A high-tech key that has to be used at a specific location. It emits a special electronic signal to open a door.
370,Apricorn Box,,5,,A handy box where you can store up to 99 of each kind of Apricorn.
371,Unown Report,,5,,A report of all the discovered kinds of Unown.
372,Berry Pots,,5,,Handy containers for cultivating Berries wherever you go.
373,Dowsing Machine,,5,,It searches for hidden items in the area and emits different lights and sounds when it detects something.
374,Blue Card,,5,,A card to save points for the Buena's Password show.
375,Slowpoke Tail,4900,5,,A very tasty tail of something. It can be sold at a high price to shops.
376,Clear Bell,,5,,A very old-fashioned bell that makes a gentle ringing sound.
377,Card Key,,5,,A card key that opens a door in Team Eclipse's Base.
378,Basement Key,,5,,A key that opens the door that leads under the Pok[e'] Ball Emporium.
379,Squirt Bottle,,5,,A bottle used for watering plants in the Berry Pots.
380,Red Scale,,5,,A scale from a red Gyarados. It glows red like a flame.
381,Lost Item,,5,,The Mime Jr. doll that was lost by the Copycat.
382,Pass,,5,,A pass required for riding the Magnet Train. It allows you to ride whenever and however much you'd like.
383,Machine Part,,5,,An important part of a machine that was stolen from the Power Plant.
384,Silver Wing,,5,,"A strange, silvery feather that sparkles."
385,Rainbow Wing,,5,,A mystical rainbow feather that sparkles.
386,Mystery Egg,,5,,A mysterious Egg obtained from Mr. pokemon. What is in the Egg is unknown.
387,Red Apricorn,,1,,A red Apricorn. It assails your nostrils.
388,Blue Apricorn,,1,,A blue Apricorn. It smells a bit like grass.
389,Yellow Apricorn,,1,,A yellow Apricorn. It has an invigorating scent.
390,Green Apricorn,,1,,"A green Apricorn. It has a mysterious, aromatic scent."
391,Pink Apricorn,,1,,"A pink Apricorn. It has a nice, sweet scent."
392,White Apricorn,,1,,A white Apricorn. It doesn't smell like anything.
393,Black Apricorn,,1,,A black Apricorn. It has a scent beyond one's experience.
394,Fast Ball,100,3,1,A Pok[e'] Ball that is good for catching pokemon that you reel in with a Rod while out fishing.
395,Level Ball,100,3,1,A Pok[e'] Ball that makes it easier to catch pokemon that are at a lower level than your own pokemon.
396,Lure Ball,100,3,1,A Pok[e'] Ball that will make it easier to catch pokemon that can evolve using a Moon Stone.
397,Heavy Ball,100,3,1,A Pok[e'] Ball that is better than usual at catching very heavy pokemon.
398,Love Ball,100,3,1,A Pok[e'] Ball that makes it easier to catch pokemon that are usually very quick to run away.
399,Friend Ball,100,3,1,A strange Pok[e'] Ball that will make the wild pokemon caught with it more friendly toward you immediately.
400,Moon Ball,100,3,1,A Pok[e'] Ball that works best when catching a pokemon that is of the opposite gender of your pokemon.
401,Sport Ball,,3,1,A special Pok[e'] Ball that is used during the Bug-Catching Contest.
402,GS Ball,,5,,The mysterious Ball.
403,GB Sounds,,5,,A music player that allows you to listen to nostalgic songs. It's operated with the flip of a single switch.
404,Tidal Bell,,5,,A very old-fashioned bell that makes a gentle ringing sound.
405,Rage Candy Bar,200,5,,"Mahogany Town's famous candy. When consumed, it restores 20 HP to an injured pokemon."
406,Jade Orb,,5,,A shiny green orb that is said to have a legend tied to it. It's known to have a deep connection with the Hoenn region.
407,Lock Capsule,,5,,A sturdy Capsule that can only be opened with a special key.
408,Red Orb,,1,,A shiny red orb that is said to have a legend tied to it. It's known to have a deep connection with the Hoenn region.
409,Blue Orb,,1,,A shiny blue orb that is said to have a legend tied to it. It's known to have a deep connection with the Hoenn region.
410,Enigma Stone,,5,,A crystal ball that was excavated from the ground. It's a very beautiful stone that is covered with bits of rock and earth.
411,Prism Scale,250,1,,A mysterious scale that causes a certain pokemon to evolve. It shines in rainbow colors.
412,Eviolite,100,1,,"A mysterious Evolutionary lump. When held by a pokemon that can still evolve, it raises both Defense and Sp. Def."
413,Float Stone,100,1,,An item to be held by a pokemon. This very light stone reduces the weight of a pokemon when held.
414,Rocky Helmet,100,1,,"An item to be held by a pokemon. If the holder is hit, the attacker will also be damaged upon contact."
415,Air Balloon,100,1,,"An item to be held by a pokemon. The holder will float in the air until hit. Once hit, this item will burst."
416,Red Card,100,1,,"An item to be held by a pokemon. When the holder is hit by an attack, the attacker is removed from battle."
417,Ring Target,100,1,,An item to be held by a pokemon. Moves that normally have no effect will land on a pokemon holding it.
418,Binding Band,100,1,,An item to be held by a pokemon. A band that increases the power of binding moves used by the holder.
419,Absorb Bulb,100,1,,An item to be held by a pokemon. It boosts Sp. Atk if hit with a Water- type attack. It can only be used once.
420,Cell Battery,100,1,,An item to be held by a pokemon. It boosts Attack if hit with an Electric- type attack. It can only be used once.
421,Eject Button,100,1,,"An item to be held by a pokemon. If the holder is hit by an attack, it will be switched out of battle."
422,Fire Gem,100,1,,"A gem with an essence of fire. When held, it strengthens the power of a Fire-type move one time."
423,Water Gem,100,1,,"A gem with an essence of water. When held, it strengthens the power of a Water-type move one time."
424,Electric Gem,100,1,,"A gem with an essence of electricity. When held, it strengthens the power of an Electric-type move one time."
425,Grass Gem,100,1,,"A gem with an essence of nature. When held, it strengthens the power of a Grass-type move one time."
426,Ice Gem,100,1,,"A gem with an essence of ice. When held, it strengthens the power of an Ice-type move one time."
427,Fighting Gem,100,1,,"A gem with an essence of combat. When held, it strengthens the power of a Fighting-type move one time."
428,Poison Gem,100,1,,"A gem with an essence of poison. When held, it strengthens the power of a Poison-type move one time."
429,Ground Gem,100,1,,"A gem with an essence of land. When held, it strengthens the power of a Ground-type move one time."
430,Flying Gem,100,1,,"A gem with an essence of air. When held, it strengthens the power of a Flying-type move one time."
431,Psychic Gem,100,1,,"A gem with an essence of the mind. When held, it strengthens the power of a Psychic-type move one time."
432,Bug Gem,100,1,,"A gem with an insect-like essence. When held, it strengthens the power of a Bug-type move one time."
433,Rock Gem,100,1,,"A gem with an essence of rock. When held, it strengthens the power of a Rock-type move one time."
434,Ghost Gem,100,1,,"A gem with a spectral essence. When held, it strengthens the power of a Ghost-type move one time."
435,Dragon Gem,100,1,,"A gem with a draconic essence. When held, it strengthens the power of a Dragon-type move one time."
436,Dark Gem,100,1,,"A gem with an essence of darkness. When held, it strengthens the power of a Dark-type move one time."
437,Steel Gem,100,1,,"A gem with an essence of steel. When held, it strengthens the power of a Steel-type move one time."
438,Normal Gem,100,1,,"A gem with an ordinary essence. When held, it strengthens the power of a Normal-type move one time."
439,Health Wing,1500,1,,An item for use on a pokemon. It slightly increases the base HP of a single pokemon.
440,Muscle Wing,1500,1,,An item for use on a pokemon. It slightly increases the base Attack stat of a single pokemon.
441,Resist Wing,1500,1,,An item for use on a pokemon. It slightly increases the base Defense stat of a single pokemon.
442,Genius Wing,1500,1,,An item for use on a pokemon. It slightly increases the base Sp. Atk stat of a single pokemon.
443,Clever Wing,1500,1,,An item for use on a pokemon. It slightly increases the base Sp. Def stat of a single pokemon.
444,Swift Wing,1500,1,,An item for use on a pokemon. It slightly increases the base Speed stat of a single pokemon.
445,Pretty Wing,100,1,,"Though this feather is beautiful, it's just a regular feather and has no effect on pokemon."
446,Cover Fossil,500,1,,A fossil from a prehistoric pokemon that once lived in the sea. It appears as though it could be part of its back.
447,Plume Fossil,500,1,,A fossil from a prehistoric pokemon that once lived in the sky. It looks as if it could come from part of its wing.
448,Liberty Pass,,5,,A special pass to go to Liberty Garden. Board the ship in Castelia City.
449,Pass Orb,100,,,"A mysterious orb containing the power of the Unova region, to be used when generating Pass Power."
450,Dream Ball,,3,1,A special Pok[e'] Ball that appears in your Bag out of nowhere in the Entree Forest. It can catch any pokemon.
451,Poke Toy,250,1,3,A toy that attracts the attention of a pokemon. It guarantees escape from any battle with a wild pokemon.
452,Prop Case,,5,,A lovely case to store colorful Props for your pokemon to wear in a musical.
453,Dragon Skull,,,,A skull of a pokemon which was said to have braved the angry waters to fly around the world.
454,Balm Mushroom,6000,1,,A rare mushroom that gives off a nice fragrance. It can be sold at a high price to shops.
455,Big Nugget,10000,1,,A big nugget of pure gold that gives off a lustrous gleam. It can be sold at a high price to shops.
456,Pearl String,,1,,Very large pearls that sparkle in a pretty silver color. They can be sold at a high price to shops.
457,Comet Shard,,1,,A shard that fell to the ground when a comet approached. It can be sold at a high price to shops.
458,Relic Copper,,1,,"A copper coin used by an ancient civilization about 3,000 years ago."
459,Bottle Cap,,1,,"A beautiful bottle cap that gives off a silver gleam. Some people are happy to receive one."
460,Relic Gold,,1,,"A gold coin used by an ancient civilization about 3,000 years ago."
461,Relic Vase,,1,,"A fragile vase made by an ancient civilization about 3,000 years ago."
462,Relic Band,,1,,"A heavy bracelet made by an ancient civilization about 3,000 years ago."
463,Relic Statue,,1,,"A stone figurine made by an ancient civilization about 3,000 years ago."
464,Relic Crown,,1,,"A heavy crown made by an ancient civilization about 3,000 years ago."
465,Casteliacone,50,1,,"Castelia City's specialty, soft-serve ice cream. It heals all the status problems of a single pokemon."
466,Dire Hit 2,,,,
467,X Speed 2,,,,
468,X Sp. Atk 2,,,,
469,X Sp. Def 2,,,,
470,X Defense 2,,,,
471,X Attack 2,,,,
472,X Accuracy 2,,,,
473,X Speed 3,,,,
474,X Sp. Atk 3,,,,
475,X Sp. Def 3,,,,
476,X Defense 3,,,,
477,X Attack 3,,,,
478,X Accuracy 3,,,,
479,X Speed 6,,,,
480,X Sp. Atk 6,,,,
481,X Sp. Def 6,,,,
482,X Defense 6,,,,
483,X Attack 6,,,,
484,X Accuracy 6,,,,
485,Ability Urge,,,,
486,Item Drop,,,,
487,Item Urge,,,,
488,Reset Urge,,,,
489,Dire Hit 3,,,,
490,Light Stone,,1,,Reshiram's body was removeed and changed into this stone. It is said to be waiting for the emergence of a hero.
491,Dark Stone,,1,,Zekrom's body was removeed and changed into this stone. It is said to be waiting for the emergence of a hero.
492,Xtransceiver,,5,,A high-tech transceiver with a camera function. It allows up to four-way calls.
493,God Stone,,,,A rare stone.
494,[Gram 1-3],,,,An important letter that Wingull delivers.
495,Dropped Item,,5,,The Xtransceiver found at the Nimbasa City amusement park. It seems it belongs to a boy.
496,Medal Box,,5,,A box-shaped machine that stores Medals and Medal information.
497,DNA Splicers,,5,,A splicer that fuses Kyurem and a certain pokemon. They are said to have been one in the beginning.
498,Sky Train Pass,,5,,A pass that is needed to ride the Sky Train on or off of Cragonos Peaks.
499,Oval Charm,,5,,An oval charm said to increase the chance of pokemon Eggs being found at the Day Care.
500,Shiny Charm,,5,,A shiny charm said to increase the chance of finding a Shiny pokemon in the wild.
501,Plasma Card,,5,,A card key needed to enter the password inside the Plasma Frigate.
502,Grubby Hanky,,5,,A handkerchief dropped by a regular at Caf[e'] Warehouse. It smells faintly like a pokemon.
503,Colress Machine,,5,,A special device that wrings out the potential of pokemon. It is an imperfect prototype.
504,Reveal Glass,,5,,A looking glass that reveals the truth. It's a mysterious glass that returns a pokemon to its original shape.
505,Weakness Policy,,1,,An item to be held by a pokemon. Attack and Sp. Atk sharply increase if the holder is hit with a move it's weak to.
506,Assault Vest,,1,,An item to be held by a pokemon. This offensive vest raises Sp. Def but prevents the use of status moves.
507,Holo Caster,,5,,A device that allows users to receive and view hologram clips at any time. It is also used to chat with others.
508,Roller Skates,,5,,"Attaches roller skates to the bottom of your shoes, allowing you to glide quickly around and perform tricks."
509,Ability Capsule,,1,,A capsule that allows a pokemon with two Abilities to switch between these Abilities when it is used.
510,Whipped Dream,,1,,"A soft and sweet treat made of fluffy, puffy, whipped and whirled cream. It's loved by a certain pokemon."
511,Sachet,,1,,A sachet filled with fragrant perfumes that are just slightly too overwhelming. Yet it's loved by a certain pokemon.
512,Safety Goggles,,1,,An item to be held by a pokemon. These goggles protect the holder from both weather-related damage and powder.
513,Gengarite,,1,,"One variety of the mysterious Mega Stones. Have Gengar hold it, and this stone will enable it to Mega Evolve during battle."
514,Gardevoirite,,1,,"One variety of the mysterious Mega Stones. Have Gardevoir hold it, and this stone will enable it to Mega Evolve during battle."
515,Ampharosite,,1,,"One variety of the mysterious Mega Stones. Have Ampharos hold it, and this stone will enable it to Mega Evolve during battle."
516,Venusaurite,,1,,"One variety of the mysterious Mega Stones. Have Venusaur hold it, and this stone will enable it to Mega Evolve during battle."
517,Charizardite X,,1,,"One variety of the mysterious Mega Stones. Have Charizard hold it, and this stone will enable it to Mega Evolve during battle."
518,Blastoisinite,,1,,"One variety of the mysterious Mega Stones. Have Blastoise hold it, and this stone will enable it to Mega Evolve during battle."
519,Mewtwonite X,,1,,"One variety of the mysterious Mega Stones. Have Mewtwo hold it, and this stone will enable it to Mega Evolve during battle."
520,Mewtwonite Y,,1,,"One variety of the mysterious Mega Stones. Have Mewtwo hold it, and this stone will enable it to Mega Evolve during battle."
521,Blazikenite,,1,,"One variety of the mysterious Mega Stones. Have Blaziken hold it, and this stone will enable it to Mega Evolve during battle."
522,Medichamite,,1,,"One variety of the mysterious Mega Stones. Have Medicham hold it, and this stone will enable it to Mega Evolve during battle."
523,Houndoominite,,1,,"One variety of the mysterious Mega Stones. Have Houndoom hold it, and this stone will enable it to Mega Evolve during battle."
524,Aggronite,,1,,"One variety of the mysterious Mega Stones. Have Aggron hold it, and this stone will enable it to Mega Evolve during battle."
525,Banettite,,1,,"One variety of the mysterious Mega Stones. Have Banette hold it, and this stone will enable it to Mega Evolve during battle."
526,Tyranitarite,,1,,"One variety of the mysterious Mega Stones. Have Tyranitar hold it, and this stone will enable it to Mega Evolve during battle."
527,Scizorite,,1,,"One variety of the mysterious Mega Stones. Have Scizor hold it, and this stone will enable it to Mega Evolve during battle."
528,Pinsirite,,1,,"One variety of the mysterious Mega Stones. Have Pinsir hold it, and this stone will enable it to Mega Evolve during battle."
529,Aerodactylite,,1,,"One variety of the mysterious Mega Stones. Have Aerodactyl hold it, and this stone will enable it to Mega Evolve during battle."
530,Lucarionite,,1,,"One variety of the mysterious Mega Stones. Have Lucario hold it, and this stone will enable it to Mega Evolve during battle."
531,Abomasite,,1,,"One variety of the mysterious Mega Stones. Have Abomasnow hold it, and this stone will enable it to Mega Evolve during battle."
532,Kangaskhanite,,1,,"One variety of the mysterious Mega Stones. Have Kangaskhan hold it, and this stone will enable it to Mega Evolve during battle."
533,Gyaradosite,,1,,"One variety of the mysterious Mega Stones. Have Gyarados hold it, and this stone will enable it to Mega Evolve during battle."
534,Absolite,,1,,"One variety of the mysterious Mega Stones. Have Absol hold it, and this stone will enable it to Mega Evolve during battle."
535,Charizardite Y,,1,,"One variety of the mysterious Mega Stones. Have Charizard hold it, and this stone will enable it to Mega Evolve during battle."
536,Alakazite,,1,,"One variety of the mysterious Mega Stones. Have Alakazam hold it, and this stone will enable it to Mega Evolve during battle."
537,Heracronite,,1,,"One variety of the mysterious Mega Stones. Have Heracross hold it, and this stone will enable it to Mega Evolve during battle."
538,Mawilite,,1,,"One variety of the mysterious Mega Stones. Have Mawile hold it, and this stone will enable it to Mega Evolve during battle."
539,Manectite,,1,,"One variety of the mysterious Mega Stones. Have Manectric hold it, and this stone will enable it to Mega Evolve during battle."
540,Garchompite,,1,,"One variety of the mysterious Mega Stones. Have Garchomp hold it, and this stone will enable it to Mega Evolve during battle."
541,Latiasite,,1,,"One variety of the mysterious Mega Stones. Have Latias hold it, and this stone will enable it to Mega Evolve during battle."
542,Latiosite,,1,,"One variety of the mysterious Mega Stones. Have Latios hold it, and this stone will enable it to Mega Evolve during battle."
543,Roseli Berry,10,4,,"If held by a pokemon, this Berry will lessen the damage taken from one supereffective Fairy-type attack."
544,Kee Berry,10,4,,"If held by a pokemon, this Berry will increase the holder's Defense if it's hit with a physical move."
545,Maranga Berry,10,4,,"If held by a pokemon, this Berry will increase the holder's Sp. Def if it's hit with a special move."
546,Sprinklotad,,5,,"A watering can shaped like a Lotad. It helps promote the healthy growth of any Berries planted in good, soft soil."
547,[TM:Fairy],,,,
548,Power Plant Pass,,5,,This pass serves as an ID card for gaining access to the power plant that lies along Route 13.
549,Mega Ring,,5,,This ring contains an untold power that somehow enables pokemon carrying Mega Stones to Mega Evolve in battle.
550,Intriguing Stone,,5,,A rather curious stone that might appear to be valuable to some. It's all in the eye of the beholder.
551,,,,,
552,Discount Coupon,,5,,This special coupon allows you to buy items at a discount when you are shopping at a boutique.
553,Elevator Key,,5,,A card key that activates the elevator in Lysandre Labs. It is emblazoned with Team Flare's logo.
554,TMV Pass,,5,,A commuter pass that allows the holder to ride the TMV between Lumiose City and Kiloude City at any time.
555,Honor of Kalos,,5,,A precious symbol that is awarded only to an individual who has done great things for the Kalos region.
556,Adventure Rules,,5,,This book contains all the points a new Trainer needs to know on a journey. It was handmade by a kind friend.
557,Strange Souvenir,,5,,An ornament depicting a pokemon that is venerated as a protector in some region far from Kalos.
558,Lens Case,,5,,A rather chic-looking case for carrying contact lenses.
559,,,,,
560,,,,,
561,Lumiose Galette,100,1,,A popular treat in Lumiose City. It can be used once to heal all the status conditions of a pokemon.
562,Shalour Sable,100,1,,Shalour City's famous shortbread. It can be used once to heal all the status conditions of a pokemon.
563,Jaw Fossil,500,1,,A fossil from a prehistoric pokemon that once lived on the land. It looks as if it could be a piece of a large jaw.
564,Sail Fossil,500,1,,A fossil from a prehistoric pokemon that once lived on the land. It looks like the impression from a skin sail.
565,Looker Ticket,,5,,A ticket that was handmade by Looker. It's decorated with a liberal amount of glittery paint.
566,[Yellow Bicycle],,5,,
567,[Red Holo Caster],,5,,
568,Fairy Gem,100,1,,"A gem with an essence of the fey. When held, it strengthens the power of a Fairy-type move one time."
569,,,,,
570,Mach Bike,,5,,This folding Bike more than doubles your movement speed.
571,Acro Bike,,5,,This folding Bike allows you to perform actions such as wheelies and bunny hops.
572,Wailmer Pail,,5,,This is a tool for watering Berries you planted to make them grow more quickly.
573,Devon Goods,,5,,A case that contains mechanical parts of some sort made by the Devon Corporation.
574,Soot Sack,,5,,A sack used to gather and hold volcanic ash.
575,[Key],,5,,
576,Pokeblock Kit,,5,,A set containing a Berry Blender for making Pok[e']blocks and a Pok[e']block Case for storing Pok[e']blocks.
577,Letter,,5,,An extremely important letter to Steven from the President of Devon Corporation.
578,Tropics Ticket,,5,,"With this ticket, Salty Sam will sail you to the Lost Islands. These islands are still full of mystery!"
579,Scanner,,5,,A device found inside Sea Mauville.
580,Go-Goggles,,5,,Nifty goggles to protect eyes from desert sandstorms.
581,Meteorite,,5,,A Meteorite originally found at Meteor Falls. You got it at Mt. Chimney.
582,Rm. 1 Key,,5,,A key that opens a door inside Sea Mauville.
583,Rm. 2 Key,,5,,A key that opens a door inside Sea Mauville.
584,Rm. 4 Key,,5,,A key that opens a door inside Sea Mauville.
585,Rm. 6 Key,,5,,A key that opens a door inside Sea Mauville.
586,Storage Key,,5,,A key that opens the storage hold inside Sea Mauville.
587,Devon Scope,,5,,A special device made by Devon Corporation that signals the presence of any unseen pokemon.
588,[Another S.S. Ticket],,5,,
589,[HM:Fighting],,,,
590,Devon Scuba Gear,,5,,A device made by Devon Corporation that provides oxygen to users during the use of Dive.
591,Contest Suit,,5,,A very cool suit to be worn during the Contest Spectacular.
592,Contest Dress,,5,,A very cute dress to be worn during the Contest Spectacular.
593,Magma Suit,,5,,A suit made with the collective technological know-how of Team Magma. It can withstand any impact.
594,Aqua Suit,,5,,A suit made with the collective technological know-how of Team Aqua. It can withstand any impact.
595,Pair of Tickets,,5,,Tickets for two to the astronomical show being held at the Mossdeep Space Center.
596,Mega Bracelet,,5,,This cuff contains an untold power that somehow enables pokemon carrying a Mega Stone to Mega Evolve in battle.
597,Meteorite 2,,5,,A Meteorite that you got at Mt. Chimney. It gives off a faint glow.
598,Swampertite,,1,,"One variety of the mysterious Mega Stones. Have Swampert hold it, and this stone will enable it to Mega Evolve during battle."
599,Sceptilite,,1,,"One variety of the mysterious Mega Stones. Have Sceptile hold it, and this stone will enable it to Mega Evolve during battle."
600,Sablenite,,1,,"One variety of the mysterious Mega Stones. Have Sableye hold it, and this stone will enable it to Mega Evolve during battle."
601,Altarianite,,1,,"One variety of the mysterious Mega Stones. Have Altaria hold it, and this stone will enable it to Mega Evolve during battle."
602,Galladite,,1,,"One variety of the mysterious Mega Stones. Have Gallade hold it, and this stone will enable it to Mega Evolve during battle."
603,Audinite,,1,,"One variety of the mysterious Mega Stones. Have Audino hold it, and this stone will enable it to Mega Evolve during battle."
604,Metagrossite,,1,,"One variety of the mysterious Mega Stones. Have Metagross hold it, and this stone will enable it to Mega Evolve during battle."
605,Sharpedonite,,1,,"One variety of the mysterious Mega Stones. Have Sharpedo hold it, and this stone will enable it to Mega Evolve during battle."
606,Slowbronite,,1,,"One variety of the mysterious Mega Stones. Have Slowbro hold it, and this stone will enable it to Mega Evolve during battle."
607,Steelixite,,1,,"One variety of the mysterious Mega Stones. Have Steelix hold it, and this stone will enable it to Mega Evolve during battle."
608,Pidgeotite,,1,,"One variety of the mysterious Mega Stones. Have Pidgeot hold it, and this stone will enable it to Mega Evolve during battle."
609,Glalitite,,1,,"One variety of the mysterious Mega Stones. Have Glalie hold it, and this stone will enable it to Mega Evolve during battle."
610,Diancite,,1,,"One variety of the mysterious Mega Stones. Have Diancie hold it, and this stone will enable it to Mega Evolve during battle."
611,Prison Bottle,,1,,"A bottle believed to have been used to seal away the power of a certain pokemon long, long ago."
612,,,,,
613,Cameruptite,,1,,"One variety of the mysterious Mega Stones. Have Camerupt hold it, and this stone will enable it to Mega Evolve during battle."
614,Lopunnite,,1,,"One variety of the mysterious Mega Stones. Have Lopunny hold it, and this stone will enable it to Mega Evolve during battle."
615,Salamencite,,1,,"One variety of the mysterious Mega Stones. Have Salamence hold it, and this stone will enable it to Mega Evolve during battle."
616,Beedrillite,,1,,"One variety of the mysterious Mega Stones. Have Beedrill hold it, and this stone will enable it to Mega Evolve during battle."
617,Meteorite 3,,5,,A Meteorite that you got at Mt. Chimney. It continues to give off a faint glow and is slightly warm to the touch.
618,Meteorite 4,,5,,"A Meteorite that you got at Mt. Chimney. Some sort of pattern has risen to the surface, and it's shining with seven colors of light."
619,Meteorite Shard,,5,,One of the fragments of a Meteorite from Granite Cave. It's faintly warm to the touch.
620,Eon Flute,,5,,A flute that can be used to summon Latios or Latias no matter where you are.
621,Prof's Letter,,5,,A letter that Professor Sycamore wrote to your mother. A faint but pleasant perfume seems to cling to the paper.
622,Pixie Plate,500,1,,An item to be held by a pokemon. It is a stone tablet that boosts the power of Fairy-type moves.
623,Luminous Moss,100,1,,An item to be held by a pokemon. It boosts Sp. Def if hit with a Water- type attack. It can only be used once.
624,Snowball,100,1,,An item to be held by a pokemon. It boosts Attack if hit with an Ice-type attack. It can only be used once.
625,Pok[e'] Flute,,5,,A flute which can play with such a beautiful tone that even sleeping pokemon find themselves roused.
626,Rich Mulch,,1,,Mulch to be used in a Berry field. It increases the Berry harvest without the need for particularly diligent care.
627,Surprise Mulch,,1,,"Mulch to be used in a Berry field. It causes strange, sudden mutations based on the combination of Berries."
628,Boost Mulch,,1,,Mulch to be used in a Berry field. It increases the Berry harvest that can be grown by diligent watering.
629,Amaze Mulch,,1,,"Mulch to be used in a Berry field. An amazing Mulch with the effects of Rich, Surprise, and Boost Mulch."
630,[Cancel],,,,
631,Sawsbuck Coffee,600,1,,An item to be held by a pokemon. It has a chance of boosting a pokemon's speed each turn.
632,Bronze Brick,,5,,A mysterious bronze brick given to you by your parents. It is a symbol of their support for you and your new adventure. 
633,Affection Ribbon,600,1,,An item to be held by a pokemon. It is a symbol of affection between a trainer and their pokemon.
634,HP Reset,100,2,,"When used on a pokemon, it will reset the pokemon's effort in training its HP stat."
635,Attack Reset,100,2,,"When used on a pokemon, it will reset the pokemon's effort in training its Attack stat."
636,Defense Reset,100,2,,"When used on a pokemon, it will reset the pokemon's effort in training its Defense stat."
637,Speed Reset,100,2,,"When used on a pokemon, it will reset the pokemon's effort in training its Speed stat."
638,Sp. Def. Reset,100,2,,"When used on a pokemon, it will reset the pokemon's effort in training its Special Defense stat."
639,Sp. Atk. Reset,100,2,,"When used on a pokemon, it will reset the pokemon's effort in training its Special Attack stat."
640,UMV Battery,,5,,A battery that powers the Underwater Mining Vessel for a limited amount of time.
641,Hot Chocolate,175,2,2,A cup of delicious hot chocolate. Drinking it will restore the HP of one pokemon by 60 points.
642,Thick Club,250,1,,An item to be held by Cubone or Marowak. It is a hard bone of some sort that boosts the Attack stat.
643,Ability Charm,,5,,A peculiar charm said to increase the chance of hatching and encountering pokemon with rare abilities.
644,Mega Key Stone,,5,,This small stone contains an untold power that somehow enables pokemon carrying a Mega Stone to Mega Evolve in battle.
645,Pumpkin Ball,1250,3,1,A decorative Pok[e'] Ball built to commemorate the Autumn season. It functions the same as a regular Pok[e'] Ball.
646,Colorless Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Normal-type pokemon.
647,Insect Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Bug-type pokemon.
648,Dread Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Dark-type pokemon.
649,Draco Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Dragon-type pokemon.
650,Zap Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Electric-type pokemon.
651,Fist Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Fighting-type pokemon.
652,Flame Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Fire-type pokemon.
653,Sky Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Flying-type pokemon.
654,Spooky Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Ghost-type pokemon.
655,Meadow Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Grass-type pokemon.
656,Earth Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Ground-type pokemon.
657,Icicle Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Ice-type pokemon.
658,Toxic Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Poison-type pokemon.
659,Mind Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Psychic-type pokemon.
660,Stone Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Rock-type pokemon.
661,Steel Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Steel-type pokemon.
662,Splash Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Water-type pokemon.
663,Pixie Ball,1000,3,1,A somewhat different Pok[e'] Ball that is more effective when attempting to catch Fairy-type pokemon.
664,Gengarite H,,1,,"One variety of the mysterious Mega Stones. Have Halloween Gengar hold it, and this stone will enable it to Mega Evolve during battle."
665,Ice Stone,1050,1,,A peculiar stone that can make certain species of Pokemon evolve. It has an unmistakable snowflake pattern.
666,Frost Ball,1250,3,1,A decorative Pok[e'] Ball built to commemorate the Winter season. It functions the same as a regular Pok[e'] Ball.
667,Stamp Case,,5,,A case used to collect Pok[e'] Ball Stamps. Visit the Stamp Shop in Fluoruma City to collect and apply stamps.
735,Sceptilite C,,1,,"One variety of the mysterious Mega Stones. Have Christmas Sceptile hold it, and this stone will enable it to Mega Evolve during battle."

777,Firium Z,,6,,It converts Z-Power into crystals that upgrade Fire-type moves to Fire-type Z-Moves.
778,Waterium Z,,6,,It converts Z-Power into crystals that upgrade Water-type moves to Water-type Z-Moves.
779,Grassium Z,,6,,It converts Z-Power into crystals that upgrade Grass-type moves to Grass-type Z-Moves.
780,Dragonium Z,,6,,It converts Z-Power into crystals that upgrade Dragon-type moves to Dragon-type Z-Moves.
781,Buginium Z,,6,,It converts Z-Power into crystals that upgrade Bug-type moves to Bug-type Z-Moves.
782,Icium Z,,6,,It converts Z-Power into crystals that upgrade Ice-type moves to Ice-type Z-Moves.
787,Darkinium Z,,6,,It converts Z-Power into crystals that upgrade Dark-type moves to Dark-type Z-Moves.
788,Electrium Z,,6,,It converts Z-Power into crystals that upgrade Electric-type moves to Electric-type Z-Moves.
789,Fairium Z,,6,,It converts Z-Power into crystals that upgrade Fairy-type moves to Fairy-type Z-Moves.
790,Fightinium Z,,6,,It converts Z-Power into crystals that upgrade Fighting-type moves to Fighting-type Z-Moves.
791,Flyinium Z,,6,,It converts Z-Power into crystals that upgrade Flying-type moves to Flying-type Z-Moves.
792,Ghostium Z,,6,,It converts Z-Power into crystals that upgrade Ghost-type moves to Ghost-type Z-Moves.
793,Groundium Z,,6,,It converts Z-Power into crystals that upgrade Ground-type moves to Ground-type Z-Moves.
794,Normalium Z,,6,,It converts Z-Power into crystals that upgrade Normal-type moves to Normal-type Z-Moves.
795,Poisonium Z,,6,,It converts Z-Power into crystals that upgrade Poison-type moves to Poison-type Z-Moves.
796,Psychium Z,,6,,It converts Z-Power into crystals that upgrade Psychic-type moves to Psychic-type Z-Moves.
797,Rockium Z,,6,,It converts Z-Power into crystals that upgrade Rock-type moves to Rock-type Z-Moves.
798,Steelium Z,,6,,It converts Z-Power into crystals that upgrade Steel-type moves to Steel-type Z-Moves.


783,Epineshroom,,5,,"A meal prepared by Cooke which, when eaten, would fill you with enough adrenaline to punch through a wall!"
784,Voltaic Ticket,,5,,"With this ticket, Salty Sam will sail you to the Voltaic Island."
785,Frigid Ticket,,5,,"With this ticket, Salty Sam will sail you to the Frigid Island."
786,Obsidian Ticket,,5,,"With this ticket, Salty Sam will sail you to the Obsidian Island."
699,Terrain Extender,,1,,An item to be held by a Pokemon. It extends the duration of the terrain caused by the holder's move or Ability.
700,Grassy Seed,,1,,An item to be held by a Pokemon. It boosts Defense on Grassy Terrain. It can only be used once.
701,Electric Seed,,1,,An item to be held by a Pokemon. It boosts Defense on Electric Terrain. It can only be used once.
702,Misty Seed,,1,,An item to be held by a Pokemon. It boosts Sp. Defense on Misty Terrain. It can only be used once.
703,Psychic Seed,,1,,An item to be held by a Pokemon. It boosts Sp. Defense on Psychic Terrain. It can only be used once.
708,Ability Patch,,1,,A patch that allows a Pokemon with a regular Ability to have a rare Ability.
710,Heavy Duty Boots,,1,,These boots prevent the effects of traps set on the battlefield.
713,Gold Bottle Cap,,1,,"A beautiful bottle cap that gives off a golden gleam. Some people are happy to receive one."
705,Sassy Mint,,1,,"When a Pokemon smells this mint, its Sp. Def will grow more easily, but its Speed will grow more slowly."
706,Serious Mint,,1,,"When a Pokemon smells this mint, all of its stats will grow at an equal rate."
707,Timid Mint,,1,,"When a Pokemon smells this mint, its Speed will grow more easily, but its Attack will grow more slowly."
737,Adamant Mint,,1,,"When a Pokemon smells this mint, its Attack will grow more easily, but its Sp. Atk will grow more slowly."
738,Bold Mint,,1,,"When a Pokemon smells this mint, its Defense will grow more easily, but its Attack will grow more slowly."
739,Brave Mint,,1,,"When a Pokemon smells this mint, its Attack will grow more easily, but its Speed will grow more slowly."
740,Calm Mint,,1,,"When a Pokemon smells this mint, its Sp. Def will grow more easily, but its Attack will grow more slowly."
741,Careful Mint,,1,,"When a Pokemon smells this mint, its Sp. Def will grow more easily, but its Sp. Atk will grow more slowly."
742,Gentle Mint,,1,,"When a Pokemon smells this mint, its Sp. Def will grow more easily, but its Defense will grow more slowly."
743,Hasty Mint,,1,,"When a Pokemon smells this mint, its Speed will grow more easily, but its Defense will grow more slowly."
744,Impish Mint,,1,,"When a Pokemon smells this mint, its Defense will grow more easily, but its Sp. Atk will grow more slowly."
745,Jolly Mint,,1,,"When a Pokemon smells this mint, its Speed will grow more easily, but its Sp. Atk will grow more slowly."
746,Lax Mint,,1,,"When a Pokemon smells this mint, its Defense will grow more easily, but its Sp. Def will grow more slowly."
747,Lonely Mint,,1,,"When a Pokemon smells this mint, its Attack will grow more easily, but its Defense will grow more slowly."
748,Mild Mint,,1,,"When a Pokemon smells this mint, its Sp. Atk will grow more easily, but its Defense will grow more slowly."
749,Modest Mint,,1,,"When a Pokemon smells this mint, its Sp. Atk will grow more easily, but its Attack will grow more slowly."
750,Naive Mint,,1,,"When a Pokemon smells this mint, its Speed will grow more easily, but its Sp. Def will grow more slowly."
751,Naughty Mint,,1,,"When a Pokemon smells this mint, its Attack will grow more easily, but its Sp. Def will grow more slowly."
752,Quiet Mint,,1,,"When a Pokemon smells this mint, its Sp. Atk will grow more easily, but its Speed will grow more slowly."
753,Rash Mint,,1,,"When a Pokemon smells this mint, its Sp. Atk will grow more easily, but its Sp. Def will grow more slowly."
754,Relaxed Mint,,1,,"When a Pokemon smells this mint, its Defense will grow more easily, but its Speed will grow more slowly."
756,Pokemon Box Link,,5,,"A beautiful bottle cap that gives off a golden gleam. Some people are happy to receive one."
758,Lopunnite E,,1,,"One variety of the mysterious Mega Stones. Have Easter Lopunny hold it, and this stone will enable it to Mega Evolve during battle."

]])