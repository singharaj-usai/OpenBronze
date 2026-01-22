print("PokedexMisc")

-- NOTE: Gen 7 are missing color_id, shape_id
--Color_id and Shape_id aren't even used in the game
return require(script.Parent.CSV)([[id,identifier,color_id,shape_id,capture_rate,base_happiness,hatch_counter,growth_rate_id,egg_icon,classification,flavor_text



1,bulbasaur,5,8,45,70,20,4,1,Seed,"Bulbasaur can be seen napping in bright sunlight. There is a seed on its back. By soaking up the sun's rays, the seed grows progressively larger."
2,ivysaur,5,8,45,70,20,4,,Seed,"There is a bud on this pokemon's back. To support its weight, Ivysaur's legs and trunk grow thick and strong. If it starts spending more time lying in the sunlight, it's a sign that the bud will bloom into a large flower soon."
3,venusaur,5,8,45,70,20,4,,Seed,There is a large flower on Venusaur's back. The flower is said to take on vivid colors if it gets plenty of nutrition and sunlight. The flower's aroma soothes the emotions of people.
4,charmander,8,6,45,70,20,4,2,Lizard,"The flame that burns at the tip of its tail is an indication of its emotions. The flame wavers when Charmander is enjoying itself. If the pokemon becomes enraged, the flame burns fiercely."
5,charmeleon,8,6,45,70,20,4,,Flame,"Charmeleon mercilessly removes its foes using its sharp claws. If it encounters a strong foe, it turns aggressive. In this excited state, the flame at the tip of its tail flares with a bluish white color."
6,charizard,8,6,45,70,20,4,,Flame,"Charizard flies around the sky in search of powerful opponents. It breathes fire of such great heat that it melts anything. However, it never turns its fiery breath on any opponent weaker than itself."
7,squirtle,2,6,45,70,20,4,3,Tiny Turtle,"Squirtle's shell is not merely used for protection. The shell's rounded shape and the grooves on its surface help minimize resistance in water, enabling this pokemon to swim at high speeds."
8,wartortle,2,6,45,70,20,4,,Turtle,"Its tail is large and covered with a rich, thick fur. The tail becomes increasingly deeper in color as Wartortle ages. The scratches on its shell are evidence of this pokemon's toughness as a battler."
9,blastoise,2,6,45,70,20,4,,Shellfish,Blastoise has water spouts that protrude from its shell. The water spouts are very accurate. They can shoot bullets of water with enough accuracy to strike empty cans from a distance of over 160 feet.
10,caterpie,5,2,255,70,15,2,4,Worm,"Caterpie has a voracious appetite. It can devour leaves bigger than its body right before your eyes. From its antenna, this pokemon releases a terrifically strong odor."
11,metapod,5,2,120,70,15,2,,Cocoon,The shell covering this pokemon's body is as hard as an iron slab. Metapod does not move very much. It stays still because it is preparing its soft innards for evolution inside the hard shell.
12,butterfree,9,13,45,70,15,2,,Butterfly,"Butterfree has a superior ability to search for delicious honey from flowers. It can even search out, extract, and carry honey from flowers that are blooming over six miles from its nest."
13,weedle,3,2,255,70,15,2,5,Hairy Bug,Weedle has an extremely acute sense of smell. It is capable of distinguishing its favorite kinds of leaves from those it dislikes just by sniffing with its big red proboscis (nose).
14,kakuna,10,2,120,70,15,2,,Cocoon,"Kakuna remains virtually immobile as it clings to a tree. However, on the inside, it is extremely busy as it prepares for its coming evolution. This is evident from how hot the shell becomes to the touch."
15,beedrill,10,13,45,70,15,2,,Poison Bee,"Beedrill is extremely territorial. No one should ever approach its nest-this is for their own safety. If angered, they will attack in a furious swarm."
16,pidgey,3,9,255,70,15,4,6,Tiny Bird,"Pidgey has an extremely sharp sense of direction. It is capable of unerringly returning home to its nest, however far it may be removed from its familiar surroundings."
17,pidgeotto,3,9,120,70,15,4,,Bird,"Pidgeotto claims a large area as its own territory. This pokemon flies around, patrolling its living space. If its territory is violated, it shows no mercy in thoroughly punishing the foe with its sharp claws."
18,pidgeot,3,9,45,70,15,4,,Bird,"This pokemon has a dazzling plumage of beautifully glossy feathers. Many Trainers are captivated by the striking beauty of the feathers on its head, compelling them to choose Pidgeot as their pokemon."
19,rattata,7,8,255,70,15,2,7,Mouse,"Rattata is cautious in the extreme. Even while it is asleep, it constantly listens by moving its ears around. It is not picky about where it lives-it will make its nest anywhere."
20,raticate,3,8,127,70,15,2,,Mouse,"Raticate's sturdy fangs grow steadily. To keep them ground down, it gnaws on rocks and logs. It may even chew on the walls of houses."
21,spearow,3,9,255,70,15,2,8,Tiny Bird,"Spearow has a very loud cry that can be heard over half a mile away. If its high, keening cry is heard echoing all around, it is a sign that they are warning each other of danger."
22,fearow,3,9,90,70,15,2,,Beak,Fearow is recognized by its long neck and elongated beak. They are conveniently shaped for catching prey in soil or water. It deftly moves its long and skinny beak to pluck prey.
23,ekans,7,2,255,70,20,2,9,Snake,Ekans curls itself up in a spiral while it rests. Assuming this position allows it to quickly respond to a threat from any direction with a glare from its upraised head.
24,arbok,7,2,90,70,20,2,,Cobra,"This pokemon is terrifically strong in order to constrict things with its body. It can even flatten steel oil drums. Once Arbok wraps its body around its foe, escaping its crunching embrace is impossible."
25,pikachu,10,8,190,70,10,2,,Mouse,"Whenever Pikachu comes across something new, it blasts it with a jolt of electricity. If you come across a blackened berry, it's evidence that this pokemon mistook the intensity of its charge."
26,raichu,10,6,75,70,10,2,,Mouse,"If the electrical sacs become excessively charged, Raichu plants its tail in the ground and discharges. Scorched patches of ground will be found near this pokemon's nest."
27,sandshrew,10,6,255,70,20,2,10,Mouse,"Sandshrew's body is configured to absorb water without waste, enabling it to survive in an arid desert. This pokemon curls up to protect itself from its enemies."
28,sandslash,10,6,90,70,20,2,,Mouse,"Sandslash's body is covered by tough spikes, which are hardened sections of its hide. Once a year, the old spikes fall out, to be replaced with new spikes that grow out from beneath the old ones."
29,nidoranf,2,8,235,70,20,4,11,Poison Pin,"Nidoran[F] has barbs that secrete a powerful poison. They are thought to have developed as protection for this small-bodied pokemon. When enraged, it releases a horrible toxin from its horn."
30,nidorina,2,8,120,70,20,4,,Poison Pin,"When Nidorina are with their friends or family, they keep their barbs tucked away to prevent hurting each other. This pokemon appears to become nervous if separated from the others."
31,nidoqueen,2,6,45,70,20,4,,Drill,Nidoqueen's body is encased in extremely hard scales. It is adept at sending foes flying with harsh tackles. This pokemon is at its strongest when it is defending its young.
32,nidoranm,7,8,235,70,20,4,12,Poison Pin,"Nidoran[M] has developed muscles for moving its ears. Thanks to them, the ears can be freely moved in any direction. Even the slightest sound does not escape this pokemon's notice."
33,nidorino,7,8,120,70,20,4,,Poison Pin,"Nidorino has a horn that is harder than a diamond. If it senses a hostile presence, all the barbs on its back bristle up at once, and it challenges the foe with all its might."
34,nidoking,7,6,45,70,20,4,,Drill,"Nidoking's thick tail packs enormously destructive power. With one swing, it can topple a metal transmission tower. Once this pokemon goes on a rampage, there is no stopping it."
35,clefairy,6,6,150,140,10,3,,Fairy,"On every night of a full moon, groups of this pokemon come out to play. When dawn arrives, the tired Clefairy return to their quiet mountain retreats and go to sleep nestled up against each other."
36,clefable,6,6,25,140,10,3,,Fairy,"Clefable moves by skipping lightly as if it were flying using its wings. Its bouncy step lets it even walk on water. It is known to take strolls on lakes on quiet, moonlit nights."
37,vulpix,3,8,190,70,20,2,13,Fox,"At the time of its birth, Vulpix has one white tail. The tail separates into six if this pokemon receives plenty of love from its Trainer. The six tails become magnificently curled."
38,ninetales,10,8,75,70,20,2,,Fox,Ninetales casts a sinister light from its bright red eyes to gain total control over its foe's mind. This pokemon is said to live for a thousand years.
39,jigglypuff,6,12,170,70,10,3,,Balloon,Jigglypuff's vocal cords can freely adjust the wavelength of its voice. This pokemon uses this ability to sing at precisely the right wavelength to make its foes most drowsy.
40,wigglytuff,6,12,50,70,10,3,,Balloon,"Wigglytuff has large, saucerlike eyes. The surfaces of its eyes are always covered with a thin layer of tears. If any dust gets in this pokemon's eyes, it is quickly washed away."
41,zubat,7,9,255,70,15,2,14,Bat,Zubat remains quietly unmoving in a dark spot during the bright daylight hours. It does so because prolonged exposure to the sun causes its body to become slightly burned.
42,golbat,7,9,90,70,15,2,,Bat,"Golbat loves to drink the blood of living things. It is particularly active in the pitch black of night. This pokemon flits around in the night skies, seeking fresh blood."
43,oddish,2,7,255,70,20,4,15,Weed,"During the daytime, Oddish buries itself in soil to absorb nutrients from the ground using its entire body. The more fertile the soil, the glossier its leaves become."
44,gloom,2,12,120,70,20,4,,Weed,"Gloom releases a foul fragrance from the pistil of its flower. When faced with danger, the stench worsens. If this pokemon is feeling calm and secure, it does not release its usual stinky aroma."
45,vileplume,8,12,45,70,20,4,,Flower,"Vileplume's toxic pollen triggers atrocious allergy attacks. That's why it is advisable never to approach any attractive flowers in a jungle, however pretty they may be."
46,paras,8,14,190,70,20,2,16,Mushroom,Paras has parasitic mushrooms growing on its back called tochukaso. They grow large by drawing nutrients from this Bug pokemon host. They are highly valued as a medicine for extending life.
47,parasect,8,14,75,70,20,2,,Mushroom,"Parasect is known to infest large trees en masse and drain nutrients from the lower trunk and roots. When an infested tree dies, they move onto another tree all at once."
48,venonat,7,12,190,70,20,2,17,Insect,"Venonat is said to have evolved with a coat of thin, stiff hair that covers its entire body for protection. It possesses large eyes that never fail to spot even minuscule prey."
49,venomoth,7,13,75,70,20,2,,Poison Moth,"Venomoth is nocturnal-it is a pokemon that only becomes active at night. Its favorite prey are small insects that gather around streetlights, attracted by the light in the darkness."
50,diglett,3,5,255,70,20,2,18,Mole,"Diglett are raised in most farms. The reason is simple- wherever this pokemon burrows, the soil is left perfectly tilled for planting crops. This soil is made ideal for growing delicious vegetables."
51,dugtrio,3,11,50,70,20,2,,Mole,"Dugtrio are actually triplets that emerged from one body. As a result, each triplet thinks exactly like the other two triplets. They work cooperatively to burrow endlessly."
52,meowth,10,8,255,70,20,2,19,Scratch Cat,"Meowth withdraws its sharp claws into its paws to slinkily sneak about without making any incriminating footsteps. For some reason, this pokemon loves shiny coins that glitter with light."
53,persian,10,8,90,70,20,2,,Classy Cat,Persian has six bold whiskers that give it a look of toughness. The whiskers sense air movements to determine what is in the pokemon's surrounding vicinity. It becomes docile if grabbed by the whiskers.
54,psyduck,10,6,190,70,20,2,20,Duck,"Psyduck uses a mysterious power. When it does so, this pokemon generates brain waves that are supposedly only seen in sleepers. This discovery spurred controversy among scholars."
55,golduck,2,6,75,70,20,2,,Duck,The webbed flippers on its forelegs and hind legs and the streamlined body of Golduck give it frightening speed. This pokemon is definitely much faster than even the most athletic swimmer.
56,mankey,3,6,190,70,20,2,21,Pig Monkey,"When Mankey starts shaking and its nasal breathing turns rough, it's a sure sign that it is becoming angry. However, because it goes into a towering rage almost instantly, it is impossible for anyone to flee its wrath."
57,primeape,3,6,75,70,20,2,,Pig Monkey,"When Primeape becomes furious, its blood circulation is boosted. In turn, its muscles are made even stronger. However, it also becomes much less intelligent at the same time."
58,growlithe,3,8,190,70,20,1,22,Puppy,"Growlithe has a superb sense of smell. Once it smells anything, this pokemon won't forget the scent, no matter what. It uses its advanced olfactory sense to determine the emotions of other living things."
59,arcanine,3,8,75,70,20,1,,Legendary,"Arcanine is known for its high speed. It is said to be capable of running over 6,200 miles in a single day and night. The fire that blazes wildly within this pokemon's body is its source of power."
60,poliwag,2,7,255,70,20,4,23,Tadpole,"Poliwag has a very thin skin. It is possible to see the pokemon's spiral innards right through the skin. Despite its thinness, however, the skin is also very flexible. Even sharp fangs bounce right off it."
61,poliwhirl,2,12,120,70,20,4,,Tadpole,"The surface of Poliwhirl's body is always wet and slick with a slimy fluid. Because of this slippery covering, it can easily slip and slide out of the clutches of any enemy in battle."
62,poliwrath,2,12,45,70,20,4,,Tadpole,"Poliwrath's highly developed, brawny muscles never grow fatigued, however much it exercises. It is so tirelessly strong, this pokemon can swim back and forth across the ocean without effort."
63,abra,3,6,200,70,20,4,24,Psi,"Abra sleeps for eighteen hours a day. However, it can sense the presence of foes even while it is sleeping. In such a situation, this pokemon immediately teleports to safety."
64,kadabra,3,6,100,70,20,4,,Psi,Kadabra emits a peculiar alpha wave if it develops a headache. Only those people with a particularly strong psyche can hope to become a Trainer of this pokemon.
65,alakazam,3,12,50,70,20,4,,Psi,"Alakazam's brain continually grows, making its head far too heavy to support with its neck. This pokemon holds its head up using its psychokinetic power instead."
66,machop,4,6,180,70,20,4,25,Superpower,Machop's muscles are special-they never get sore no matter how much they are used in exercise. This pokemon has sufficient power to hurl a hundred adult humans.
67,machoke,4,12,90,70,20,4,,Superpower,"Machoke's thoroughly toned muscles possess the hardness of steel. This pokemon has so much strength, it can easily hold aloft a sumo wrestler on just one finger."
68,machamp,4,12,45,70,20,4,,Superpower,"Machamp has the power to hurl anything aside. However, trying to do any work requiring care and dexterity causes its arms to get tangled. This pokemon tends to leap into action before it thinks."
69,bellsprout,5,12,255,70,20,4,26,Flower,"Bellsprout's thin and flexible body lets it bend and sway to avoid any attack, however strong it may be. From its mouth, this pokemon spits a corrosive fluid that melts even iron."
70,weepinbell,5,5,120,70,20,4,,Flycatcher,"Weepinbell has a large hook on its rear end. At night, the pokemon hooks on to a tree branch and goes to sleep. If it moves around in its sleep, it may wake up to find itself on the ground."
71,victreebel,5,5,45,70,20,4,,Flycatcher,"Victreebel has a long vine that extends from its head. This vine is waved and flicked about as if it were an animal to attract prey. When an unsuspecting prey draws near, this pokemon swallows it whole."
72,tentacool,2,10,190,70,20,1,27,Jellyfish,"Tentacool's body is largely composed of water. If it is removed from the sea, it dries up like parchment. If this pokemon happens to become dehydrated, put it back into the sea."
73,tentacruel,2,10,60,70,20,1,,Jellyfish,Tentacruel has large red orbs on its head. The orbs glow before lashing the vicinity with a harsh ultrasonic blast. This pokemon's outburst creates rough waves around it.
74,geodude,3,4,255,70,15,4,28,Rock,"The longer a Geodude lives, the more its edges are chipped and worn away, making it more rounded in appearance. However, this pokemon's heart will remain hard, craggy, and rough always."
75,graveler,3,12,120,70,15,4,,Rock,"Graveler grows by feeding on rocks. Apparently, it prefers to eat rocks that are covered in moss. This pokemon eats its way through a ton of rocks on a daily basis."
76,golem,3,12,45,70,15,4,,Megaton,"Golem live up on mountains. If there is a large earthquake, these pokemon will come rolling down off the mountains en masse to the foothills below."
77,ponyta,10,8,190,70,20,2,29,Fire Horse,Ponyta is very weak at birth. It can barely stand up. This pokemon becomes stronger by stumbling and falling to keep up with its parent.
78,rapidash,10,8,60,70,20,2,,Fire Horse,"Rapidash usually can be seen casually cantering in the fields and plains. However, when this pokemon turns serious, its fiery manes flare and blaze as it gallops its way up to 150 mph."
79,slowpoke,6,8,190,70,20,2,30,Dopey,"Slowpoke uses its tail to catch prey by dipping it in water at the side of a river. However, this pokemon often forgets what it's doing and often spends entire days just loafing at water's edge."
80,slowbro,6,6,75,70,20,2,,Hermit Crab,"Slowbro's tail has a Shellder firmly attached with a bite. As a result, the tail can't be used for fishing anymore. This causes Slowbro to grudgingly swim and catch prey instead."
81,magnemite,4,4,190,70,20,2,31,Magnet,"Magnemite attaches itself to power lines to feed on electricity. If your house has a power outage, check your circuit breakers. You may find a large number of this pokemon clinging to the breaker box."
82,magneton,4,11,60,70,20,2,,Magnet,"Magneton emits a powerful magnetic force that is fatal to mechanical devices. As a result, large cities sound sirens to warn citizens of large-scale outbreaks of this pokemon."
83,farfetchd,3,9,45,70,20,2,32,Wild Duck,"Farfetch'd is always seen with a stalk from a plant of some sort. Apparently, there are good stalks and bad stalks. This pokemon has been known to fight with others over stalks."
84,doduo,3,7,190,70,20,2,33,Twin Bird,"Doduo's two heads never sleep at the same time. Its two heads take turns sleeping, so one head can always keep watch for enemies while the other one sleeps."
85,dodrio,3,7,45,70,20,2,,Triple Bird,Watch out if Dodrio's three heads are looking in three separate directions. It's a sure sign that it is on its guard. Don't go near this pokemon if it's being wary-it may decide to peck you.
86,seel,9,3,190,70,20,2,34,Sea Lion,"Seel hunts for prey in the frigid sea underneath sheets of ice. When it needs to breathe, it punches a hole through the ice with the sharply protruding section of its head."
87,dewgong,9,3,75,70,20,2,,Sea Lion,Dewgong loves to snooze on bitterly cold ice. The sight of this pokemon sleeping on a glacier was mistakenly thought to be a mermaid by a mariner long ago.
88,grimer,7,4,190,70,20,2,35,Sludge,"Grimer's sludgy and rubbery body can be forced through any opening, however small it may be. This pokemon enters sewer pipes to drink filthy wastewater."
89,muk,7,4,75,70,20,2,,Sludge,From Muk's body seeps a foul fluid that gives off a nose-bendingly horrible stench. Just one drop of this pokemon's body fluid can turn a pool stagnant and rancid.
90,shellder,7,1,190,70,20,1,36,Bivalve,"At night, this pokemon uses its broad tongue to burrow a hole in the seafloor sand and then sleep in it. While it is sleeping, Shellder closes its shell, but leaves its tongue hanging out."
91,cloyster,7,1,60,70,20,1,,Bivalve,"Cloyster is capable of swimming in the sea. It does so by swallowing water, then jetting it out toward the rear. This pokemon shoots spikes from its shell using the same system."
92,gastly,7,1,190,70,20,4,37,Gas,"Gastly is largely composed of gaseous matter. When exposed to a strong wind, the gaseous body quickly dwindles away. Groups of this pokemon cluster under the eaves of houses to escape the ravages of wind."
93,haunter,7,4,90,70,20,4,,Gas,"Haunter is a dangerous pokemon. If one beckons you while floating in darkness, you must never approach it. This pokemon will try to lick you with its tongue and steal your life away."
94,gengar,7,6,45,70,20,4,,Shadow,"Sometimes, on a dark night, your shadow thrown by a streetlight will suddenly and startlingly overtake you. It is actually a Gengar running past you, pretending to be your shadow."
95,onix,4,2,45,70,25,2,38,Rock Snake,"Onix has a magnet in its brain. It acts as a compass so that this pokemon does not lose direction while it is tunneling. As it grows older, its body becomes increasingly rounder and smoother."
96,drowzee,10,12,190,70,20,2,39,Hypnosis,"If your nose becomes itchy while you are sleeping, it's a sure sign that one of these pokemon is standing above your pillow and trying to eat your dream through your nostrils."
97,hypno,10,12,75,70,20,2,,Hypnosis,"Hypno holds a pendulum in its hand. The arcing movement and glitter of the pendulum lull the foe into a deep state of hypnosis. While this pokemon searches for prey, it polishes the pendulum."
98,krabby,8,14,225,70,20,2,40,River Crab,"Krabby live on beaches, burrowed inside holes dug into the sand. On sandy beaches with little in the way of food, these pokemon can be seen squabbling with each other over territory."
99,kingler,8,14,60,70,20,2,,Pincer,"Kingler has an enormous, oversized claw. It waves this huge claw in the air to communicate with others. However, because the claw is so heavy, the pokemon quickly tires."
100,voltorb,8,1,190,70,20,2,41,Ball,Voltorb was first sighted at a company that manufactures Pok? Balls. The link between that sighting and the fact that this pokemon looks very similar to a Pok? Ball remains a mystery.
101,electrode,8,1,60,70,20,2,,Ball,"Electrode eats electricity in the atmosphere. On days when lightning strikes, you can see this pokemon exploding all over the place from eating too much electricity."
102,exeggcute,6,11,90,70,20,1,42,Egg,"This pokemon consists of six eggs that form a closely knit cluster. The six eggs attract each other and spin around. When cracks increasingly appear on the eggs, Exeggcute is close to evolution."
103,exeggutor,10,7,45,70,20,1,,Coconut,"Exeggutor originally came from the tropics. Its heads steadily grow larger from exposure to strong sunlight. It is said that when the heads fall off, they group together to form Exeggcute."
104,cubone,3,6,190,70,20,2,43,Lonely,"Cubone pines for the mother it will never see again. Seeing a likeness of its mother in the full moon, it cries. The stains on the skull the pokemon wears are made by the tears it sheds."
105,marowak,3,6,75,70,20,2,,Bone Keeper,Marowak is the evolved form of a Cubone that has overcome its sadness at the loss of its mother and grown tough. This pokemon's tempered and hardened spirit is not easily broken.
106,hitmonlee,3,12,45,70,25,2,,Kicking,"Hitmonlee's legs freely contract and stretch. Using these springlike legs, it bowls over foes with devastating kicks. After battle, it rubs down its legs and loosens the muscles to overcome fatigue."
107,hitmonchan,3,12,45,70,25,2,,Punching,Hitmonchan is said to possess the spirit of a boxer who had been working toward a world championship. This pokemon has an indomitable spirit and will never give up in the face of adversity.
108,lickitung,6,6,45,70,20,2,44,Licking,"Whenever Lickitung comes across something new, it will unfailingly give it a lick. It does so because it memorizes things by texture and by taste. It is somewhat put off by sour things."
109,koffing,7,1,190,70,20,2,45,Poison Gas,"If Koffing becomes agitated, it raises the toxicity of its internal gases and jets them out from all over its body. This pokemon may also overinflate its round body, then explode."
110,weezing,7,11,60,70,20,2,,Poison Gas,"Weezing loves the gases given off by rotted kitchen garbage. This pokemon will find a dirty, unkempt house and make it its home. At night, when the people in the house are asleep, it will go through the trash."
111,rhyhorn,4,8,120,70,20,1,46,Spikes,"Rhyhorn runs in a straight line, smashing everything in its path. It is not bothered even if it rushes headlong into a block of steel. This pokemon may feel some pain from the collision the next day, however."
112,rhydon,4,6,60,70,20,1,,Drill,Rhydon's horn can crush even uncut diamonds. One sweeping blow of its tail can topple a building. This pokemon's hide is extremely tough. Even direct cannon hits don't leave a scratch.
113,chansey,6,6,30,140,40,3,220,Egg,"Chansey lays nutritionally excellent eggs on an everyday basis. The eggs are so delicious, they are easily and eagerly devoured by even those people who have lost their appetite."
114,tangela,2,7,45,70,20,2,47,Vine,"Tangela's vines snap off easily if they are grabbed. This happens without pain, allowing it to make a quick getaway. The lost vines are replaced by newly grown vines the very next day."
115,kangaskhan,3,6,45,70,20,2,48,Parent,"If you come across a young Kangaskhan playing by itself, you must never disturb it or attempt to catch it. The baby pokemon's parent is sure to be in the area, and it will become violently enraged at you."
116,horsea,2,5,225,70,20,2,49,Dragon,"Horsea eats small insects and moss off of rocks. If the ocean current turns fast, this pokemon anchors itself by wrapping its tail around rocks or coral to prevent being washed away."
117,seadra,2,5,75,70,20,2,,Dragon,Seadra sleeps after wriggling itself between the branches of coral. Those trying to harvest coral are occasionally stung by this pokemon's poison barbs if they fail to notice it.
118,goldeen,8,3,225,70,20,2,50,Goldfish,"Goldeen is a very beautiful pokemon with fins that billow elegantly in water. However, don't let your guard down around this pokemon-it could ram you powerfully with its horn."
119,seaking,8,3,60,70,20,2,,Goldfish,"In the autumn, Seaking males can be seen performing courtship dances in riverbeds to woo females. During this season, this pokemon's body coloration is at its most beautiful."
120,staryu,3,5,225,70,20,1,51,Star Shape,"Staryu's center section has an organ called the core that shines bright red. If you go to a beach toward the end of summer, the glowing cores of these pokemon look like the stars in the sky."
121,starmie,7,5,60,70,20,1,,Mysterious,"Starmie's center section-the core-glows brightly in seven colors. Because of its luminous nature, this pokemon has been given the nickname ""the gem of the sea."""
122,mrmime,6,12,45,70,25,2,219,Barrier,"Mr. Mime is a master of pantomime. Its gestures and motions convince watchers that something unseeable actually exists. Once the watchers are convinced, the unseeable thing exists as if it were real."
123,scyther,5,13,45,70,25,2,52,Mantis,"Scyther is blindingly fast. Its blazing speed enhances the effectiveness of the twin scythes on its forearms. This pokemon's scythes are so effective, they can slice through thick logs in one wicked stroke."
124,jynx,8,12,45,70,25,2,,Human Shape,"Jynx walks rhythmically, swaying and shaking its hips as if it were dancing. Its motions are so bouncingly alluring, people seeing it are compelled to shake their hips without giving any thought to what they are doing."
125,electabuzz,10,6,45,70,25,2,,Electric,"When a storm arrives, gangs of this pokemon compete with each other to scale heights that are likely to be stricken by lightning bolts. Some towns use Electabuzz in place of lightning rods."
126,magmar,8,6,45,70,25,2,,Spitfire,"In battle, Magmar blows out intensely hot flames from all over its body to intimidate its opponent. This pokemon's fiery bursts create heat waves that ignite grass and trees in its surroundings."
127,pinsir,3,12,45,70,25,1,53,Stag Beetle,Pinsir is astoundingly strong. It can grip a foe weighing twice its weight in its horns and easily lift it. This pokemon's movements turn sluggish in cold places.
128,tauros,3,8,45,70,20,1,54,Wild Bull,"This pokemon is not satisfied unless it is rampaging at all times. If there is no opponent for Tauros to battle, it will charge at thick trees and knock them down to calm itself."
129,magikarp,8,3,255,70,5,1,55,Fish,Magikarp is a pathetic excuse for a pokemon that is only capable of flopping and splashing. This behavior prompted scientists to undertake research into it.
130,gyarados,2,2,45,70,5,1,,Atrocious,"When Magikarp evolves into Gyarados, its brain cells undergo a structural transformation. It is said that this transformation is to blame for this pokemon's wildly violent nature."
131,lapras,2,3,45,70,40,1,56,Transport,"People have driven Lapras almost to the point of extinction. In the evenings, this pokemon is said to sing plaintively as it seeks what few others of its kind still remain."
132,ditto,7,1,35,70,20,2,57,Transform,"Ditto rearranges its cell structure to transform itself into other shapes. However, if it tries to transform itself into something by relying on its memory, this pokemon manages to get details wrong."
133,eevee,3,8,45,70,35,2,58,Evolution,Eevee has an unstable genetic makeup that suddenly mutates due to the environment in which it lives. Radiation from various stones causes this pokemon to evolve.
134,vaporeon,2,8,45,70,35,2,,Bubble Jet,Vaporeon underwent a spontaneous mutation and grew fins and gills that allow it to live underwater. This pokemon has the ability to freely control water.
135,jolteon,10,8,45,70,35,2,,Lightning,"Jolteon's cells generate a low level of electricity. This power is amplified by the static electricity of its fur, enabling the pokemon to drop thunderbolts. The bristling fur is made of electrically charged needles."
136,flareon,8,8,45,70,35,2,,Flame,"Flareon's fluffy fur has a functional purpose-it releases heat into the air so that its body does not get excessively hot. This pokemon's body temperature can rise to a maximum of 1,650 degrees Fahrenheit."
137,porygon,6,7,45,70,20,2,59,Virtual,Porygon is capable of reverting itself entirely back to program data and entering cyberspace. This pokemon is copy protected so it cannot be duplicated by copying.
138,omanyte,2,10,45,70,30,2,60,Spiral,"Omanyte is one of the ancient and long-since-extinct pokemon that have been regenerated from fossils by people. If attacked by an enemy, it withdraws itself inside its hard shell."
139,omastar,2,10,45,70,30,2,,Spiral,"Omastar uses its tentacles to capture its prey. It is believed to have become extinct because its shell grew too large and heavy, causing its movements to become too slow and ponderous."
140,kabuto,3,14,45,70,30,2,61,Shellfish,"Kabuto is a pokemon that has been regenerated from a fossil. However, in extremely rare cases, living examples have been discovered. The pokemon has not changed at all for 300 million years."
141,kabutops,3,6,45,70,30,2,,Shellfish,Kabutops swam underwater to hunt for its prey in ancient times. The pokemon was apparently evolving from being a water dweller to living on land as evident from the beginnings of change in its gills and legs.
142,aerodactyl,7,9,45,70,35,1,62,Fossil,Aerodactyl is a pokemon from the age of dinosaurs. It was regenerated from genetic material extracted from amber. It is imagined to have been the king of the skies in ancient times.
143,snorlax,1,12,25,70,40,1,224,Sleeping,Snorlax's typical day consists of nothing more than eating and sleeping. It is such a docile pokemon that there are children who use its expansive belly as a place to play.
144,articuno,2,9,3,35,80,1,63,Freeze,"Articuno is a legendary bird pokemon that can control ice. The flapping of its wings chills the air. As a result, it is said that when this pokemon flies, snow will fall."
145,zapdos,10,9,3,35,80,1,64,Electric,Zapdos is a legendary bird pokemon that has the ability to control electricity. It usually lives in thunderclouds. The pokemon gains power if it is stricken by lightning bolts.
146,moltres,10,9,3,35,80,1,65,Flame,"Moltres is a legendary bird pokemon that has the ability to control fire. If this pokemon is injured, it is said to dip its body in the molten magma of a volcano to burn and heal itself."
147,dratini,2,2,45,35,40,1,66,Dragon,Dratini continually molts and sloughs off its old skin. It does so because the life energy within its body steadily builds to reach uncontrollable levels.
148,dragonair,2,2,45,35,40,1,,Dragon,Dragonair stores an enormous amount of energy inside its body. It is said to alter weather conditions in its vicinity by discharging energy from the crystals on its neck and tail.
149,dragonite,3,6,45,35,40,1,,Dragon,Dragonite is capable of circling the globe in just 16 hours. It is a kindhearted pokemon that leads lost and foundering ships in a storm to the safety of land.
150,mewtwo,7,6,3,0,120,1,67,Genetic,"Mewtwo is a pokemon that was created by genetic manipulation. However, even though the scientific power of humans created this pokemon's body, they failed to endow Mewtwo with a compassionate heart."
151,mew,6,6,45,100,120,4,68,New Species,"Mew is said to possess the genetic composition of all pokemon. It is capable of making itself invisible at will, so it entirely avoids notice even if it approaches people."



152,chikorita,5,8,45,70,20,4,69,Leaf,"In battle, Chikorita waves its leaf around to keep the foe at bay. However, a sweet fragrance also wafts from the leaf, becalming the battling pokemon and creating a cozy, friendly atmosphere all around."
153,bayleef,5,8,45,70,20,4,,Leaf,Bayleef's neck is ringed by curled-up leaves. Inside each tubular leaf is a small shoot of a tree. The fragrance of this shoot makes people peppy.
154,meganium,5,8,45,70,20,4,,Herb,"The fragrance of Meganium's flower soothes and calms emotions. In battle, this pokemon gives off more of its becalming scent to blunt the foe's fighting spirit."
155,cyndaquil,10,12,45,70,20,4,70,Fire Mouse,"Cyndaquil protects itself by flaring up the flames on its back. The flames are vigorous if the pokemon is angry. However, if it is tired, the flames splutter fitfully with incomplete combustion."
156,quilava,10,8,45,70,20,4,,Volcano,Quilava keeps its foes at bay with the intensity of its flames and gusts of superheated air. This pokemon applies its outstanding nimbleness to dodge attacks even while scorching the foe with flames.
157,typhlosion,10,8,45,70,20,4,,Volcano,Typhlosion obscures itself behind a shimmering heat haze that it creates using its intensely hot flames. This pokemon creates blazing explosive blasts that burn everything to cinders.
158,totodile,2,6,45,70,20,4,71,Big Jaw,"Despite the smallness of its body, Totodile's jaws are very powerful. While the pokemon may think it is just playfully nipping, its bite has enough power to cause serious injury."
159,croconaw,2,6,45,70,20,4,,Big Jaw,"Once Croconaw has clamped its jaws on its foe, it will absolutely not let go. Because the tips of its fangs are forked back like barbed fishhooks, they become impossible to remove when they have sunk in."
160,feraligatr,2,6,45,70,20,4,,Big Jaw,"Feraligatr intimidates its foes by opening its huge mouth. In battle, it will kick the ground hard with its thick and powerful hind legs to charge at the foe at an incredible speed."
161,sentret,3,8,255,70,15,2,72,Scout,"When Sentret sleeps, it does so while another stands guard. The sentry wakes the others at the first sign of danger. When this pokemon becomes separated from its pack, it becomes incapable of sleep due to fear."
162,furret,3,8,90,70,15,2,,Long Body,"Furret has a very slim build. When under attack, it can slickly squirm through narrow spaces and get away. In spite of its short limbs, this pokemon is very nimble and fleet."
163,hoothoot,3,9,255,70,15,2,73,Owl,"Hoothoot has an internal organ that senses and tracks the earth's rotation. Using this special organ, this pokemon begins hooting at precisely the same time every day."
164,noctowl,3,9,90,70,15,2,,Owl,"Noctowl never fails at catching prey in darkness. This pokemon owes its success to its superior vision that allows it to see in minimal light, and to its soft, supple wings that make no sound in flight."
165,ledyba,8,9,255,70,15,3,74,Five Star,Ledyba secretes an aromatic fluid from where its legs join its body. This fluid is used for communicating with others. This pokemon conveys its feelings to others by altering the fluid's scent.
166,ledian,8,9,90,70,15,3,,Five Star,"It is said that in lands with clean air, where the stars fill the sky, there live Ledian in countless numbers. There is a good reason for this-the pokemon uses the light of the stars as its energy."
167,spinarak,5,14,255,70,15,3,75,String Spit,The web spun by Spinarak can be considered its second nervous system. It is said that this pokemon can determine what kind of prey is touching its web just by the tiny vibrations it feels through the web's strands.
168,ariados,8,14,90,70,15,3,,Long Leg,Ariados's feet are tipped with tiny hooked claws that enable it to scuttle on ceilings and vertical walls. This pokemon constricts the foe with thin and strong silk webbing.
169,crobat,7,13,90,70,15,2,,Bat,"If this pokemon is flying by fluttering only a pair of wings on either the forelegs or hind legs, it's proof that Crobat has been flying a long distance. It switches the wings it uses if it is tired."
170,chinchou,2,3,190,70,20,1,76,Angler,Chinchou lets loose positive and negative electrical charges from its two antennas to make its prey faint. This pokemon flashes its electric lights to exchange signals with others.
171,lanturn,2,3,75,70,20,1,,Light,"Lanturn is nicknamed ""the deep-sea star"" for its illuminated antenna. This pokemon produces light by causing a chemical reaction between bacteria and its bodily fluids inside the antenna."
172,pichu,10,8,190,70,10,2,77,Tiny Mouse,Pichu charges itself with electricity more easily on days with thunderclouds or when the air is very dry. You can hear the crackling of static electricity coming off this pokemon.
173,cleffa,6,6,150,140,10,3,78,Star Shape,"On nights with many shooting stars, Cleffa can be seen dancing in a ring. They dance through the night and stop only at the break of day, when these pokemon quench their thirst with the morning dew."
174,igglybuff,6,12,170,70,10,3,79,Balloon,Igglybuff's vocal cords are not sufficiently developed. It would hurt its throat if it were to sing too much. This pokemon gargles with freshwater from a clean stream.
175,togepi,9,12,190,70,10,3,80,Spike Ball,"As its energy, Togepi uses the positive emotions of compassion and pleasure exuded by people and pokemon. This pokemon stores up feelings of happiness inside its shell, then shares them with others."
176,togetic,9,12,75,70,10,3,,Happiness,"Togetic is said to be a pokemon that brings good fortune. When the pokemon spots someone who is pure of heart, it is said to appear and share its happiness with that person."
177,natu,5,9,190,70,20,2,81,Tiny Bird,"Natu cannot fly because its wings are not yet fully grown. If your eyes meet with this pokemon's eyes, it will stare back intently at you. But if you move even slightly, it will hop away to safety."
178,xatu,5,9,75,70,20,2,,Mystic,Xatu stands rooted and still in one spot all day long. People believe that this pokemon does so out of fear of the terrible things it has foreseen in the future.
179,mareep,9,8,235,70,20,4,82,Wool,"Mareep's fluffy coat of wool rubs together and builds a static charge. The more static electricity is charged, the more brightly the lightbulb at the tip of its tail glows."
180,flaaffy,6,6,120,70,20,4,,Wool,Flaaffy's wool quality changes so that it can generate a high amount of static electricity with a small amount of wool. The bare and slick parts of its hide are shielded against electricity.
181,ampharos,10,6,45,70,20,4,,Light,Ampharos gives off so much light that it can be seen even from space. People in the old days used the light of this pokemon to send signals back and forth with others far away.
182,bellossom,5,12,45,70,20,4,,Flower,"When Bellossom gets exposed to plenty of sunlight, the leaves ringing its body begin to spin around. This pokemon's dancing is renowned in the southern lands."
183,marill,2,6,190,70,10,3,140,Aqua Mouse,"Marill's oil-filled tail acts much like a life preserver. If you see just its tail bobbing on the water's surface, it's a sure indication that this pokemon is diving beneath the water to feed on aquatic plants."
184,azumarill,2,6,75,70,10,3,,Aqua Rabbit,"Azumarill's long ears are indispensable sensors. By focusing its hearing, this pokemon can identify what kinds of prey are around, even in rough and fast-running rivers."
185,sudowoodo,3,12,65,70,20,2,218,Imitation,"Sudowoodo camouflages itself as a tree to avoid being attacked by enemies. However, because its hands remain green throughout the year, the pokemon is easily identified as a fake during the winter."
186,politoed,5,12,45,70,20,4,,Frog,"The curled hair on Politoed's head is proof of its status as a king. It is said that the longer and more curled the hair, the more respect this pokemon earns from its peers."
187,hoppip,6,6,255,70,20,4,83,Cottonweed,"This pokemon drifts and floats with the wind. If it senses the approach of strong winds, Hoppip links its leaves with other Hoppip to prepare against being blown away."
188,skiploom,5,6,120,70,20,4,,Cottonweed,"Skiploom's flower blossoms when the temperature rises above 64 degrees Fahrenheit. How much the flower opens depends on the temperature. For that reason, this pokemon is sometimes used as a thermometer."
189,jumpluff,2,6,45,70,20,4,,Cottonweed,Jumpluff rides warm southern winds to cross the sea and fly to foreign lands. The pokemon descends to the ground when it encounters cold air while it is floating.
190,aipom,7,6,45,70,20,3,84,Long Tail,"Aipom's tail ends in a hand-like appendage that can be cleverly manipulated. However, because the pokemon uses its tail so much, its real hands have become rather clumsy."
191,sunkern,10,1,235,70,20,4,85,Seed,"Sunkern tries to move as little as it possibly can. It does so because it tries to conserve all the nutrients it has stored in its body for its evolution. It will not eat a thing, subsisting only on morning dew."
192,sunflora,10,12,120,70,20,4,,Sun,Sunflora converts solar energy into nutrition. It moves around actively in the daytime when it is warm. It stops moving as soon as the sun goes down for the night.
193,yanma,8,13,75,70,20,2,86,Clear Wing,Yanma is capable of seeing 360 degrees without having to move its eyes. It is a great flier that is adept at making sudden stops and turning midair. This pokemon uses its flying ability to quickly chase down targeted prey.
194,wooper,2,7,255,70,20,2,87,Water Fish,"Wooper usually lives in water. However, it occasionally comes out onto land in search of food. On land, it coats its body with a gooey, toxic film."
195,quagsire,2,6,90,70,20,2,,Water Fish,"Quagsire hunts for food by leaving its mouth wide open in water and waiting for its prey to blunder in unaware. Because the pokemon does not move, it does not get very hungry."
196,espeon,7,8,45,70,35,2,,Sun,Espeon is extremely loyal to any Trainer it considers to be worthy. It is said that this pokemon developed its precognitive powers to protect its Trainer from harm.
197,umbreon,1,8,45,35,35,2,,Moonlight,Umbreon evolved as a result of exposure to the moon's waves. It hides silently in darkness and waits for its foes to make a move. The rings on its body glow when it leaps to attack.
198,murkrow,1,9,30,35,20,4,88,Darkness,Murkrow was feared and loathed as the alleged bearer of ill fortune. This pokemon shows strong interest in anything that sparkles or glitters. It will even try to steal rings from women.
199,slowking,6,6,70,70,20,2,,Royal,"Slowking undertakes research every day in an effort to solve the mysteries of the world. However, this pokemon apparently forgets everything it has learned if the Shellder on its head comes off."
200,misdreavus,4,1,45,35,25,3,89,Screech,"Misdreavus frightens people with a creepy, sobbing cry. The pokemon apparently uses its red spheres to absorb the fearful feelings of foes and turn them into nutrition."
201,unown,1,1,225,70,40,2,90,Symbol,"This pokemon is shaped like ancient writing. It is a mystery as to which came first, the ancient writings or the various Unown. Research into this topic is ongoing but nothing is known."
202,wobbuffet,2,5,45,70,20,2,178,Patient,"If two or more Wobbuffet meet, they will turn competitive and try to outdo each other's endurance. However, they may try to see which one can endure the longest without food. Trainers need to beware of this habit."
203,girafarig,10,8,60,70,20,2,91,Long Neck,"Girafarig's rear head also has a brain, but it is small. The rear head attacks in response to smells and sounds. Approaching this pokemon from behind can cause the rear head to suddenly lash out and bite."
204,pineco,4,1,190,70,20,2,92,Bagworm,"Pineco hangs from a tree branch and patiently waits for prey to come along. If the pokemon is disturbed while eating by someone shaking its tree, it drops down to the ground and explodes with no warning."
205,forretress,7,1,75,70,20,2,,Bagworm,"Forretress conceals itself inside its hardened steel shell. The shell is opened when the pokemon is catching prey, but it does so at such a quick pace that the shell's inside cannot be seen."
206,dunsparce,10,2,190,70,20,2,93,Land Snake,Dunsparce has a drill for its tail. It uses this tail to burrow into the ground backward. This pokemon is known to make its nest in complex shapes deep under the ground.
207,gligar,7,9,60,70,20,4,94,Fly Scorpion,"Gligar glides through the air without a sound as if it were sliding. This pokemon hangs on to the face of its foe using its clawed hind legs and the large pincers on its forelegs, then injects the prey with its poison barb."
208,steelix,4,2,25,70,25,2,,Iron Snake,Steelix lives even further underground than Onix. This pokemon is known to dig toward the earth's core. There are records of this pokemon reaching a depth of over six-tenths of a mile underground.
209,snubbull,6,12,190,70,20,3,95,Fairy,"By baring its fangs and making a scary face, Snubbull sends smaller pokemon scurrying away in terror. However, this pokemon seems a little sad at making its foes flee."
210,granbull,7,6,75,70,20,3,,Fairy,"Granbull has a particularly well-developed lower jaw. The enormous fangs are heavy, causing the pokemon to tip its head back for balance. Unless it is startled, it will not try to bite indiscriminately."
211,qwilfish,4,3,45,70,20,2,96,Balloon,"Qwilfish sucks in water, inflating itself. This pokemon uses the pressure of the water it swallowed to shoot toxic quills all at once from all over its body. It finds swimming somewhat challenging."
212,scizor,8,13,25,70,25,2,,Pincer,Scizor has a body with the hardness of steel. It is not easily fazed by ordinary sorts of attacks. This pokemon flaps its wings to regulate its body temperature.
213,shuckle,10,14,190,70,20,4,97,Mold,"Shuckle quietly hides itself under rocks, keeping its body concealed inside its hard shell while eating berries it has stored away. The berries mix with its body fluids to become a juice."
214,heracross,2,12,45,70,25,1,98,Single Horn,"Heracross charges in a straight line at its foe, slips beneath the foe's grasp, and then scoops up and hurls the opponent with its mighty horn. This pokemon even has enough power to topple a massive tree."
215,sneasel,1,6,60,35,20,4,99,Sharp Claw,Sneasel scales trees by punching its hooked claws into the bark. This pokemon seeks out unguarded nests and steals eggs for food while the parents are away.
216,teddiursa,3,6,120,70,20,2,100,Little Bear,This pokemon likes to lick its palms that are sweetened by being soaked in honey. Teddiursa concocts its own honey by blending fruits and pollen collected by Beedrill.
217,ursaring,3,6,60,70,20,2,,Hibernator,"In the forests inhabited by Ursaring, it is said that there are many streams and towering trees where they gather food. This pokemon walks through its forest gathering food every day."
218,slugma,8,2,190,70,20,2,101,Lava,"Molten magma courses throughout Slugma's circulatory system. If this pokemon is chilled, the magma cools and hardens. Its body turns brittle and chunks fall off, reducing its size."
219,magcargo,8,2,75,70,20,2,,Lava,Magcargo's shell is actually its skin that hardened as a result of cooling. Its shell is very brittle and fragile-just touching it causes it to crumble apart. This pokemon returns to its original size by dipping itself in magma.
220,swinub,3,8,225,70,20,1,102,Pig,Swinub roots for food by rubbing its snout against the ground. Its favorite food is a mushroom that grows under the cover of dead grass. This pokemon occasionally roots out hot springs.
221,piloswine,3,8,75,70,20,1,,Swine,Piloswine is covered by a thick coat of long hair that enables it to endure the freezing cold. This pokemon uses its tusks to dig up food that has been buried under ice.
222,corsola,6,14,60,70,20,3,103,Coral,"Corsola's branches glitter very beautifully in seven colors when they catch sunlight. If any branch breaks off, this pokemon grows it back in just one night."
223,remoraid,4,3,190,70,20,2,104,Jet,"Remoraid sucks in water, then expels it at high velocity using its abdominal muscles to shoot down flying prey. When evolution draws near, this pokemon travels downstream from rivers."
224,octillery,8,10,75,70,20,2,,Jet,"Octillery grabs onto its foe using its tentacles. This pokemon tries to immobilize it before delivering the finishing blow. If the foe turns out to be too strong, Octillery spews ink to escape."
225,delibird,8,9,45,70,20,3,105,Delivery,"Delibird carries its food bundled up in its tail. There once was a famous explorer who managed to reach the peak of the world's highest mountain, thanks to one of these pokemon sharing its food."
226,mantine,7,9,25,70,25,1,231,Kite,"On sunny days, schools of Mantine can be seen elegantly leaping over the sea's waves. This pokemon is not bothered by the Remoraid that hitches rides."
227,skarmory,4,9,25,70,25,1,106,Armor Bird,"Skarmory is entirely encased in hard, protective armor. This pokemon flies at close to 190 mph. It slashes foes with its wings that possess swordlike cutting edges."
228,houndour,1,8,120,35,20,1,107,Dark,Houndour hunt as a coordinated pack. They communicate with each other using a variety of cries to corner their prey. This pokemon's remarkable teamwork is unparalleled.
229,houndoom,1,8,45,35,20,1,,Dark,"In a Houndoom pack, the one with its horns raked sharply toward the back serves a leadership role. These pokemon choose their leader by fighting among themselves."
230,kingdra,2,5,45,70,20,2,,Dragon,Kingdra lives at extreme ocean depths that are otherwise uninhabited. It has long been believed that the yawning of this pokemon creates spiraling ocean currents.
231,phanpy,2,8,120,70,20,2,108,Long Nose,"For its nest, Phanpy digs a vertical pit in the ground at the edge of a river. It marks the area around its nest with its trunk to let the others know that the area has been claimed."
232,donphan,4,8,60,70,20,2,,Armor,"Donphan's favorite attack is curling its body into a ball, then charging at its foe while rolling at high speed. Once it starts rolling, this pokemon can't stop very easily."
233,porygon2,8,7,45,70,20,2,,Virtual,Porygon2 was created by humans using the power of science. The man-made pokemon has been endowed with artificial intelligence that enables it to learn new gestures and emotions on its own.
234,stantler,3,8,45,70,20,1,109,Big Horn,"Stantler's magnificent antlers were traded at high prices as works of art. As a result, this pokemon was hunted close to extinction by those who were after the priceless antlers."
235,smeargle,9,6,45,70,20,3,110,Painter,"Smeargle marks the boundaries of its territory using a body fluid that leaks out from the tip of its tail. Over 5,000 different marks left by this pokemon have been found."
236,tyrogue,7,12,75,70,25,2,111,Scuffle,"Tyrogue becomes stressed out if it does not get to train every day. When raising this pokemon, the Trainer must establish and uphold various training methods."
237,hitmontop,3,6,45,70,25,2,,Handstand,"Hitmontop spins on its head at high speed, all the while delivering kicks. This technique is a remarkable mix of both offense and defense at the same time. The pokemon travels faster spinning than it does walking."
238,smoochum,6,12,45,70,25,2,112,Kiss,"Smoochum actively runs about, but also falls quite often. Whenever the chance arrives, it will look for its reflection to make sure its face hasn't become dirty."
239,elekid,10,12,45,70,25,2,113,Electric,"Elekid stores electricity in its body. If it touches metal and accidentally discharges all its built-up electricity, this pokemon begins swinging its arms in circles to recharge itself."
240,magby,8,6,45,70,25,2,114,Live Coal,"Magby's state of health is determined by observing the fire it breathes. If the pokemon is spouting yellow flames from its mouth, it is in good health. When it is fatigued, black smoke will be mixed in with the flames."
241,miltank,6,6,45,70,20,1,115,Milk Cow,Miltank gives over five gallons of milk on a daily basis. Its sweet milk is enjoyed by children and grown-ups alike. People who can't drink milk turn it into yogurt and eat it instead.
242,blissey,6,12,30,140,40,3,,Happiness,"Blissey senses sadness with its fluffy coat of fur. If it does so, this pokemon will rush over to a sad person, no matter how far away, to share a Lucky Egg that brings a smile to any face."
243,raikou,10,8,3,35,80,1,116,Thunder,Raikou embodies the speed of lightning. The roars of this pokemon send shock waves shuddering through the air and shake the ground as if lightning bolts had come crashing down.
244,entei,3,8,3,35,80,1,117,Volcano,Entei embodies the passion of magma. This pokemon is thought to have been born in the eruption of a volcano. It sends up massive bursts of fire that utterly consume all that they touch.
245,suicune,2,8,3,35,80,1,118,Aurora,Suicune embodies the compassion of a pure spring of water. It runs across the land with gracefulness. This pokemon has the power to purify dirty water.
246,larvitar,5,6,45,35,40,1,119,Rock Skin,"Larvitar is born deep under the ground. To come up to the surface, this pokemon must eat its way through the soil above. Until it does so, Larvitar cannot see its parents."
247,pupitar,4,2,45,35,40,1,,Hard Shell,Pupitar creates a gas inside its body that it compresses and forcefully ejects to propel itself like a jet. The body is very durable-it avoids damage even if it hits solid steel.
248,tyranitar,5,6,45,35,40,1,,Armor,"Tyranitar is so overwhelmingly powerful, it can bring down a whole mountain to make its nest. This pokemon wanders about in mountains seeking new opponents to fight."
249,lugia,9,9,3,0,120,1,120,Diving,"Lugia's wings pack devastating power-a light fluttering of its wings can blow apart regular houses. As a result, this pokemon chooses to live out of sight deep under the sea."
250,hooh,8,9,3,0,120,1,121,Rainbow,Ho-Oh's feathers glow in seven colors depending on the angle at which they are struck by light. These feathers are said to bring happiness to the bearers. This pokemon is said to live at the foot of a rainbow.
251,celebi,5,12,45,100,120,4,122,Time Travel,"This pokemon came from the future by crossing over time. It is thought that so long as Celebi appears, a bright and shining future awaits us."



252,treecko,5,6,45,70,20,4,123,Wood Gecko,Treecko has small hooks on the bottom of its feet that enable it to scale vertical walls. This pokemon attacks by slamming foes with its thick tail.
253,grovyle,5,6,45,70,20,4,,Wood Gecko,The leaves growing out of Grovyle's body are convenient for camouflaging it from enemies in the forest. This pokemon is a master at climbing trees in jungles.
254,sceptile,5,6,45,70,20,4,,Forest,The leaves growing on Sceptile's body are very sharp edged. This pokemon is very agile-it leaps all over the branches of trees and jumps on its foe from above or behind.
255,torchic,8,7,45,70,20,4,124,Chick,"Torchic sticks with its Trainer, following behind with unsteady steps. This pokemon breathes fire of over 1,800 degrees Fahrenheit, including fireballs that leave the foe scorched black."
256,combusken,8,6,45,70,20,4,,Young Fowl,"Combusken toughens up its legs and thighs by running through fields and mountains. This pokemon's legs possess both speed and power, enabling it to dole out 10 kicks in one second."
257,blaziken,8,6,45,70,20,4,,Blaze,"In battle, Blaziken blows out intense flames from its wrists and attacks foes courageously. The stronger the foe, the more intensely this pokemon's wrists burn."
258,mudkip,2,8,45,70,20,4,125,Mud Fish,"The fin on Mudkip's head acts as highly sensitive radar. Using this fin to sense movements of water and air, this pokemon can determine what is taking place around it without using its eyes."
259,marshtomp,2,6,45,70,20,4,,Mud Fish,"The surface of Marshtomp's body is enveloped by a thin, sticky film that enables it to live on land. This pokemon plays in mud on beaches when the ocean tide is low."
260,swampert,2,6,45,70,20,4,,Mud Fish,Swampert is very strong. It has enough power to easily drag a boulder weighing more than a ton. This pokemon also has powerful vision that lets it see even in murky water.
261,poochyena,4,8,255,70,15,2,126,Bite,"At first sight, Poochyena takes a bite at anything that moves. This pokemon chases after prey until the victim becomes exhausted. However, it may turn tail if the prey strikes back."
262,mightyena,4,8,127,70,15,2,,Bite,Mightyena gives obvious signals when it is preparing to attack. It starts to growl deeply and then flattens its body. This pokemon will bite savagely with its sharply pointed fangs.
263,zigzagoon,3,8,255,70,15,2,127,Tiny Raccoon,Zigzagoon restlessly wanders everywhere at all times. This pokemon does so because it is very curious. It becomes interested in anything that it happens to see.
264,linoone,9,8,90,70,15,2,,Rushing,"Linoone always runs full speed and only in straight lines. If facing an obstacle, it makes a right-angle turn to evade it. This pokemon is very challenged by gently curving roads."
265,wurmple,8,2,255,70,15,2,128,Worm,"Using the spikes on its rear end, Wurmple peels the bark off trees and feeds on the sap that oozes out. This pokemon's feet are tipped with suction pads that allow it to cling to glass without slipping."
266,silcoon,9,1,120,70,15,2,,Cocoon,"Silcoon tethers itself to a tree branch using silk to keep from falling. There, this pokemon hangs quietly while it awaits evolution. It peers out of the silk cocoon through a small hole."
267,beautifly,10,13,45,70,15,2,,Butterfly,"Beautifly's favorite food is the sweet pollen of flowers. If you want to see this pokemon, just leave a potted flower by an open window. Beautifly is sure to come looking for pollen."
268,cascoon,7,1,120,70,15,2,,Cocoon,"Cascoon makes its protective cocoon by wrapping its body entirely with a fine silk from its mouth. Once the silk goes around its body, it hardens. This pokemon prepares for its evolution inside the cocoon."
269,dustox,5,13,45,70,15,2,,Poison Moth,"Dustox is instinctively drawn to light. Swarms of this pokemon are attracted by the bright lights of cities, where they wreak havoc by stripping the leaves off roadside trees for food."
270,lotad,5,14,255,70,15,4,129,Water Weed,"Lotad live in ponds and lakes, where they float on the surface. It grows weak if its broad leaf dies. On rare occasions, this pokemon travels on land in search of clean water."
271,lombre,5,12,120,70,15,4,,Jolly,"Lombre is nocturnal-it will get active after dusk. It is also a mischief maker. When this pokemon spots anglers, it tugs on their fishing lines from beneath the surface and enjoys their consternation."
272,ludicolo,5,12,45,70,15,4,,Carefree,"Ludicolo begins dancing as soon as it hears cheerful, festive music. This pokemon is said to appear when it hears the singing of children on hiking outings."
273,seedot,3,7,255,70,15,4,130,Acorn,"Seedot attaches itself to a tree branch using the top of its head. It sucks moisture from the tree while hanging off the branch. The more water it drinks, the glossier this pokemon's body becomes."
274,nuzleaf,3,12,120,70,15,4,,Wily,Nuzleaf live in densely overgrown forests. They occasionally venture out of the forest to startle people. This pokemon dislikes having its long nose pinched.
275,shiftry,3,12,45,70,15,4,,Wicked,Shiftry is a mysterious pokemon that is said to live atop towering trees dating back over a thousand years. It creates terrific windstorms with the fans it holds.
276,taillow,2,9,200,70,15,4,131,Tiny Swallow,"Taillow courageously stands its ground against foes, however strong they may be. This gutsy pokemon will remain defiant even after a loss. On the other hand, it cries loudly if it becomes hungry."
277,swellow,2,9,45,70,15,4,,Swallow,"Swellow flies high above our heads, making graceful arcs in the sky. This pokemon dives at a steep angle as soon as it spots its prey. The hapless prey is tightly grasped by Swellow's clawed feet, preventing escape."
278,wingull,9,9,190,70,20,2,132,Seagull,Wingull has the habit of carrying prey and valuables in its beak and hiding them in all sorts of locations. This pokemon rides the winds and flies as if it were skating across the sky.
279,pelipper,10,9,45,70,20,2,,Water Bird,Pelipper is a flying transporter that carries small pokemon and eggs inside its massive bill. This pokemon builds its nest on steep cliffs facing the sea.
280,ralts,9,12,235,35,20,1,133,Feeling,"Ralts senses the emotions of people using the horns on its head. This pokemon rarely appears before people. But when it does, it draws closer if it senses that the person has a positive disposition."
281,kirlia,9,12,120,35,20,1,,Emotion,It is said that a Kirlia that is exposed to the positive emotions of its Trainer grows beautiful. This pokemon controls psychokinetic powers with its highly developed brain.
282,gardevoir,9,12,45,35,20,1,,Embrace,"Gardevoir has the ability to read the future. If it senses impending danger to its Trainer, this pokemon is said to unleash its psychokinetic energy at full power."
283,surskit,2,14,200,70,15,2,134,Pond Skater,"From the tips of its feet, Surskit secretes an oil that enables it to walk on water as if it were skating. This pokemon feeds on microscopic organisms in ponds and lakes."
284,masquerain,2,13,75,70,15,2,,Eyeball,Masquerain intimidates enemies with the eyelike patterns on its antennas. This pokemon flaps its four wings to freely fly in any direction-even sideways and backwards-as if it were a helicopter.
285,shroomish,3,7,255,70,15,6,135,Mushroom,"Shroomish live in damp soil in the dark depths of forests. They are often found keeping still under fallen leaves. This pokemon feeds on compost that is made up of fallen, rotted leaves."
286,breloom,5,6,90,70,15,6,,Mushroom,"Breloom closes in on its foe with light and sprightly footwork, then throws punches with its stretchy arms. This pokemon's fighting technique puts boxers to shame."
287,slakoth,3,8,255,70,15,1,136,Slacker,"Slakoth lolls around for over 20 hours every day. Because it moves so little, it does not need much food. This pokemon's sole daily meal consists of just three leaves."
288,vigoroth,9,6,120,70,15,1,,Wild Monkey,Vigoroth is always itching and agitated to go on a wild rampage. It simply can't tolerate sitting still for even a minute. This pokemon's stress level rises if it can't be moving constantly.
289,slaking,3,12,45,70,15,1,,Lazy,"Slaking spends all day lying down and lolling about. It eats grass growing within its reach. If it eats all the grass it can reach, this pokemon reluctantly moves to another spot."
290,nincada,4,14,255,70,15,5,137,Trainee,Nincada lives underground for many years in complete darkness. This pokemon absorbs nutrients from the roots of trees. It stays motionless as it waits for evolution.
291,ninjask,10,13,120,70,15,5,,Ninja,"Ninjask moves around at such a high speed that it cannot be seen, even while its crying can be clearly heard. For that reason, this pokemon was long believed to be invisible."
292,shedinja,3,5,45,70,15,5,,Shed,"Shedinja's hard body doesn't move-not even a twitch. In fact, its body appears to be merely a hollow shell. It is believed that this pokemon will steal the spirit of anyone peering into its hollow body from its back."
293,whismur,6,6,190,70,20,4,138,Whisper,"Normally, Whismur's voice is very quiet-it is barely audible even if one is paying close attention. However, if this pokemon senses danger, it starts crying at an earsplitting volume."
294,loudred,2,6,120,70,20,4,,Big Voice,Loudred's bellowing can completely decimate a wood-frame house. It uses its voice to punish its foes. This pokemon's round ears serve as loudspeakers.
295,exploud,2,6,45,70,20,4,,Loud Noise,"Exploud triggers earthquakes with the tremors it creates by bellowing. If this pokemon violently inhales from the ports on its body, it's a sign that it is preparing to let loose a huge bellow."
296,makuhita,10,12,180,70,20,6,139,Guts,"Makuhita is tenacious-it will keep getting up and attacking its foe however many times it is knocked down. Every time it gets back up, this pokemon stores more energy in its body for evolving."
297,hariyama,3,12,200,70,20,6,,Arm Thrust,"Hariyama practices its straight-arm slaps in any number of locations. One hit of this pokemon's powerful, openhanded, straight-arm punches could snap a telephone pole in two."
298,azurill,2,7,150,70,10,3,140,Polka Dot,"Azurill spins its tail as if it were a lasso, then hurls it far. The momentum of the throw sends its body flying, too. Using this unique action, one of these pokemon managed to hurl itself a record 33 feet."
299,nosepass,4,12,255,70,20,2,141,Compass,"Nosepass's magnetic nose is always pointed to the north. If two of these pokemon meet, they cannot turn their faces to each other when they are close because their magnetic noses repel one another."
300,skitty,6,8,255,70,15,3,142,Kitten,Skitty has the habit of becoming fascinated by moving objects and chasing them around. This pokemon is known to chase after its own tail and become dizzy.
301,delcatty,7,8,60,70,15,3,,Prim,"Delcatty prefers to live an unfettered existence in which it can do as it pleases at its own pace. Because this pokemon eats and sleeps whenever it decides, its daily routines are completely random."
302,sableye,7,12,45,35,25,4,143,Darkness,"Sableye lead quiet lives deep inside caverns. They are feared, however, because these pokemon are thought to steal the spirits of people when their eyes burn with a sinister glow in the darkness."
303,mawile,1,12,45,70,20,3,144,Deceiver,"Mawile's huge jaws are actually steel horns that have been transformed. Its docile-looking face serves to lull its foe into letting down its guard. When the foe least expects it, Mawile chomps it with its gaping jaws."
304,aron,4,8,180,35,35,1,145,Iron Armor,"This pokemon has a body of steel. To make its body, Aron feeds on iron ore that it digs from mountains. Occasionally, it causes major trouble by eating bridges and rails."
305,lairon,4,8,90,35,35,1,,Iron Armor,Lairon tempers its steel body by drinking highly nutritious mineral springwater until it is bloated. This pokemon makes its nest close to springs of delicious water.
306,aggron,4,6,45,35,35,1,,Iron Armor,Aggron claims an entire mountain as its own territory. It mercilessly beats up anything that violates its environment. This pokemon vigilantly patrols its territory at all times.
307,meditite,2,12,180,70,20,2,146,Meditate,"Meditite undertakes rigorous mental training deep in the mountains. However, whenever it meditates, this pokemon always loses its concentration and focus. As a result, its training never ends."
308,medicham,8,12,90,70,20,2,,Meditate,"It is said that through meditation, Medicham heightens energy inside its body and sharpens its sixth sense. This pokemon hides its presence by merging itself with fields and mountains."
309,electrike,5,8,120,70,20,1,147,Lightning,Electrike stores electricity in its long body hair. This pokemon stimulates its leg muscles with electric charges. These jolts of power give its legs explosive acceleration performance.
310,manectric,10,8,45,70,20,1,,Discharge,"Manectric is constantly discharging electricity from its mane. The sparks sometimes ignite forest fires. When it enters a battle, this pokemon creates thunderclouds."
311,plusle,10,6,200,70,20,2,148,Cheering,"Plusle always acts as a cheerleader for its partners. Whenever a teammate puts out a good effort in battle, this pokemon shorts out its body to create the crackling noises of sparks to show its joy."
312,minun,10,6,200,70,20,2,149,Cheering,Minun is more concerned about cheering on its partners than its own safety. It shorts out the electricity in its body to create brilliant showers of sparks to cheer on its teammates.
313,volbeat,4,6,150,70,15,5,150,Firefly,"With the arrival of night, Volbeat emits light from its tail. It communicates with others by adjusting the intensity and flashing of its light. This pokemon is attracted by the sweet aroma of Illumise."
314,illumise,7,12,150,70,15,6,151,Firefly,"Illumise attracts a swarm of Volbeat using a sweet fragrance. Once the Volbeat have gathered, this pokemon leads the lit-up swarm in drawing geometric designs on the canvas of the night sky."
315,roselia,5,12,150,70,20,4,203,Thorn,Roselia shoots sharp thorns as projectiles at any opponent that tries to steal the flowers on its arms. The aroma of this pokemon brings serenity to living things.
316,gulpin,5,4,225,70,20,6,152,Stomach,"Virtually all of Gulpin's body is its stomach. As a result, it can swallow something its own size. This pokemon's stomach contains a special fluid that digests anything."
317,swalot,7,4,75,70,20,6,,Poison Bag,"When Swalot spots prey, it spurts out a hideously toxic fluid from its pores and sprays the target. Once the prey has weakened, this pokemon gulps it down whole with its cavernous mouth."
318,carvanha,8,3,225,35,20,1,153,Savage,Carvanha's strongly developed jaws and its sharply pointed fangs pack the destructive power to rip out boat hulls. Many boats have been attacked and sunk by this pokemon.
319,sharpedo,2,3,60,35,20,1,,Brutal,"Nicknamed ""the bully of the sea,"" Sharpedo is widely feared. Its cruel fangs grow back immediately if they snap off. Just one of these pokemon can thoroughly tear apart a supertanker."
320,wailmer,2,3,125,70,40,6,154,Ball Whale,Wailmer's nostrils are located above its eyes. This playful pokemon loves to startle people by forcefully snorting out seawater it stores inside its body out of its nostrils.
321,wailord,2,3,60,70,40,6,,Float Whale,"Wailord is the largest of all identified pokemon up to now. This giant pokemon swims languorously in the vast open sea, eating massive amounts of food at once with its enormous mouth."
322,numel,10,8,255,70,20,2,155,Numb,"Numel is extremely dull witted-it doesn't notice being hit. However, it can't stand hunger for even a second. This pokemon's body is a seething cauldron of boiling magma."
323,camerupt,8,8,150,70,20,2,,Eruption,"Camerupt has a volcano inside its body. Magma of 18,000 degrees Fahrenheit courses through its body. Occasionally, the humps on this pokemon's back erupt, spewing the superheated magma."
324,torkoal,3,8,90,70,20,2,156,Coal,"Torkoal digs through mountains in search of coal. If it finds some, it fills hollow spaces on its shell with the coal and burns it. If it is attacked, this pokemon spouts thick black smoke to beat a retreat."
325,spoink,1,4,255,70,20,3,157,Bounce,"Spoink bounces around on its tail. The shock of its bouncing makes its heart pump. As a result, this pokemon cannot afford to stop bouncing-if it stops, its heart will stop."
326,grumpig,7,6,60,70,20,3,,Manipulate,"Grumpig uses the black pearls on its body to amplify its psychic power waves for gaining total control over its foe. When this pokemon uses its special power, its snorting breath grows labored."
327,spinda,3,6,255,70,15,3,158,Spot Panda,"All the Spinda that exist in the world are said to have utterly unique spot patterns. The shaky, tottering steps of this pokemon give it the appearance of dancing."
328,trapinch,3,14,255,70,20,4,159,Ant Pit,"Trapinch's nest is a sloped, bowl-like pit dug in sand. This pokemon patiently waits for prey to tumble down the pit. Its giant jaws have enough strength to crush even boulders."
329,vibrava,5,13,120,70,20,4,,Vibration,"To make prey faint, Vibrava generates ultrasonic waves by vigorously making its two wings vibrate. This pokemon's ultrasonic waves are so powerful, they can bring on headaches in people."
330,flygon,5,9,45,70,20,4,,Mystic,"Flygon is nicknamed ""the elemental spirit of the desert."" Because its flapping wings whip up a cloud of sand, this pokemon is always enveloped in a sandstorm while flying."
331,cacnea,5,12,190,35,20,4,160,Cactus,"Cacnea lives in arid locations such as deserts. It releases a strong aroma from its flower to attract prey. When prey comes near, this pokemon shoots sharp thorns from its body to bring the victim down."
332,cacturne,5,12,60,35,20,4,,Scarecrow,"During the daytime, Cacturne remains unmoving so that it does not lose any moisture to the harsh desert sun. This pokemon becomes active at night when the temperature drops."
333,swablu,2,9,255,70,20,5,161,Cotton Bird,Swablu has light and fluffy wings that are like cottony clouds. This pokemon is not frightened of people. It lands on the heads of people and sits there like a cotton-fluff hat.
334,altaria,2,9,45,70,20,5,,Humming,"Altaria dances and wheels through the sky among billowing, cotton-like clouds. By singing melodies in its crystal-clear voice, this pokemon makes its listeners experience dreamy wonderment."
335,zangoose,9,6,90,70,20,5,162,Cat Ferret,Memories of battling its archrival Seviper are etched into every cell of Zangoose's body. This pokemon adroitly dodges attacks with incredible agility.
336,seviper,1,2,90,70,20,6,163,Fang Snake,Seviper shares a generations-long feud with Zangoose. The scars on its body are evidence of vicious battles. This pokemon attacks using its sword-edged tail.
337,lunatone,10,1,45,70,25,3,164,Meteorite,"Lunatone was discovered at a location where a meteoroid fell. As a result, some people theorize that this pokemon came from space. However, no one has been able to prove this theory so far."
338,solrock,8,1,45,70,25,3,165,Meteorite,"Solrock is a new species of pokemon that is said to have fallen from space. It floats in air and moves silently. In battle, this pokemon releases intensely bright light."
339,barboach,4,3,190,70,20,2,166,Whiskers,"Barboach's sensitive whiskers serve as a superb radar system. This pokemon hides in mud, leaving only its two whiskers exposed while it waits for prey to come along."
340,whiscash,2,3,75,70,20,2,,Whiskers,"Whiscash is extremely territorial. Just one of these pokemon will claim a large pond as its exclusive territory. If a foe approaches it, it thrashes about and triggers a massive earthquake."
341,corphish,8,14,205,70,15,6,167,Ruffian,Corphish were originally foreign pokemon that were imported as pets. They eventually turned up in the wild. This pokemon is very hardy and has greatly increased its population.
342,crawdaunt,8,14,155,70,15,6,,Rogue,"Crawdaunt has an extremely violent nature that compels it to challenge other living things to battle. Other life-forms refuse to live in ponds inhabited by this pokemon, making them desolate places."
343,baltoy,3,4,255,70,20,2,168,Clay Doll,Baltoy moves while spinning around on its one foot. Primitive wall paintings depicting this pokemon living among people were discovered in some ancient ruins.
344,claydol,1,4,90,70,20,2,,Clay Doll,Claydol are said to be dolls of mud made by primitive humans and brought to life by exposure to a mysterious ray. This pokemon moves about while levitating.
345,lileep,7,5,45,70,30,5,169,Sea Lily,Lileep became extinct approximately a hundred million years ago. This ancient pokemon attaches itself to a rock on the seafloor and catches approaching prey using tentacles shaped like flower petals.
346,cradily,5,5,45,70,30,5,,Barnacle,Cradily roams around the ocean floor in search of food. This pokemon freely extends its tree trunk-like neck and captures unwary prey using its eight tentacles.
347,anorith,4,14,45,70,30,5,170,Old Shrimp,Anorith was regenerated from a prehistoric fossil. This primitive pokemon once lived in warm seas. It grips its prey firmly between its two large claws.
348,armaldo,4,6,45,70,30,5,,Plate,Armaldo's tough armor makes all attacks bounce off. This pokemon's two enormous claws can be freely extended or contracted. They have the power to punch right through a steel slab.
349,feebas,3,3,255,70,20,5,171,Fish,"Feebas's fins are ragged and tattered from the start of its life. Because of its shoddy appearance, this pokemon is largely ignored. It is capable of living in both the sea and in rivers."
350,milotic,6,2,60,70,20,5,,Tender,Milotic is said to be the most beautiful of all the pokemon. It has the power to becalm such emotions as anger and hostility to quell bitter feuding.
351,castform,9,1,45,70,25,2,172,Weather,Castform's appearance changes with the weather. This pokemon gained the ability to use the vast power of nature to protect its tiny body.
352,kecleon,5,6,200,70,20,4,173,Color Swap,Kecleon is capable of changing its body colors at will to blend in with its surroundings. There is one exception-this pokemon can't change the zigzag pattern on its belly.
353,shuppet,1,1,225,35,25,3,174,Puppet,"Shuppet is attracted by feelings of jealousy and vindictiveness. If someone develops strong feelings of vengeance, this pokemon will appear in a swarm and line up beneath the eaves of that person's home."
354,banette,1,6,45,35,25,3,,Marionette,Banette generates energy for laying strong curses by sticking pins into its own body. This pokemon was originally a pitiful plush doll that was thrown away.
355,duskull,1,4,190,35,25,3,175,Requiem,"Duskull can pass through any wall no matter how thick it may be. Once this pokemon chooses a target, it will doggedly pursue the intended victim until the break of dawn."
356,dusclops,1,12,90,35,25,3,,Beckon,"Dusclops's body is completely hollow-there is nothing at all inside. It is said that its body is like a black hole. This pokemon will absorb anything into its body, but nothing will ever come back out."
357,tropius,5,8,200,70,25,1,176,Fruit,"The bunches of fruit around Tropius's neck are very popular with children. This pokemon loves fruit, and eats it continuously. Apparently, its love for fruit resulted in its own outgrowth of fruit."
358,chimecho,2,4,45,70,25,3,215,Wind Chime,"Chimecho makes its cries echo inside its hollow body. When this pokemon becomes enraged, its cries result in ultrasonic waves that have the power to knock foes flying."
359,absol,9,8,30,35,25,4,177,Disaster,"Every time Absol appears before people, it is followed by a disaster such as an earthquake or a tidal wave. As a result, it came to be known as the disaster pokemon."
360,wynaut,2,6,125,70,20,2,178,Bright,"Wynaut can always be seen with a big, happy smile on its face. Look at its tail to determine if it is angry. When angered, this pokemon will be slapping the ground with its tail."
361,snorunt,4,12,190,70,20,2,179,Snow Hat,"Snorunt live in regions with heavy snowfall. In seasons without snow, such as spring and summer, this pokemon steals away to live quietly among stalactites and stalagmites deep in caverns."
362,glalie,4,1,75,70,20,2,,Face,"Glalie has a body made of rock, which it hardens with an armor of ice. This pokemon has the ability to freeze moisture in the atmosphere into any shape it desires."
363,spheal,2,3,255,70,20,4,180,Clap,"Spheal is much faster rolling than walking to get around. When groups of this pokemon eat, they all clap at once to show their pleasure. Because of this, their mealtimes are noisy."
364,sealeo,2,3,120,70,20,4,,Ball Roll,Sealeo has the habit of always juggling on the tip of its nose anything it sees for the first time. This pokemon occasionally entertains itself by balancing and rolling a Spheal on its nose.
365,walrein,2,8,45,70,20,4,,Ice Break,Walrein's two massively developed tusks can totally shatter blocks of ice weighing 10 tons with one blow. This pokemon's thick coat of blubber insulates it from subzero temperatures.
366,clamperl,2,1,255,70,20,5,181,Bivalve,Clamperl's sturdy shell is not only good for protection-it is also used for clamping and catching prey. A fully grown Clamperl's shell will be scored with nicks and scratches all over.
367,huntail,2,2,60,70,20,5,,Deep Sea,Huntail's presence went unnoticed by people for a long time because it lives at extreme depths in the sea. This pokemon's eyes can see clearly even in the murky dark depths of the ocean.
368,gorebyss,6,2,60,70,20,5,,South Sea,"Gorebyss lives in the southern seas at extreme depths. Its body is built to withstand the enormous pressure of water at incredible depths. Because of this, this pokemon's body is unharmed by ordinary attacks."
369,relicanth,4,3,25,70,40,1,182,Longevity,Relicanth is a pokemon species that existed for a hundred million years without ever changing its form. This ancient pokemon feeds on microscopic organisms with its toothless mouth.
370,luvdisc,6,3,225,70,20,3,183,Rendezvous,Luvdisc live in shallow seas in the tropics. This heart-shaped pokemon earned its name by swimming after loving couples it spotted in the ocean's waves.
371,bagon,2,12,45,35,40,1,184,Rock Head,"Bagon has a dream of one day soaring in the sky. In doomed efforts to fly, this pokemon hurls itself off cliffs. As a result of its dives, its head has grown tough and as hard as tempered steel."
372,shelgon,9,8,45,35,40,1,,Endurance,"Inside Shelgon's armor-like shell, cells are in the midst of transformation to create an entirely new body. This pokemon's shell is extremely heavy, making its movements sluggish."
373,salamence,2,8,45,35,40,1,,Dragon,"Salamence came about as a result of a strong, long-held dream of growing wings. It is said that this powerful desire triggered a sudden mutation in this pokemon's cells, causing it to sprout its magnificent wings."
374,beldum,2,5,3,35,40,1,185,Iron Ball,"Instead of blood, a powerful magnetic force courses throughout Beldum's body. This pokemon communicates with others by sending controlled pulses of magnetism."
375,metang,2,4,3,35,40,1,,Iron Claw,"When two Beldum fuse together, Metang is formed. The brains of the Beldum are joined by a magnetic nervous system. By linking its brains magnetically, this pokemon generates strong psychokinetic power."
376,metagross,2,11,3,35,40,1,,Iron Leg,"Metagross has four brains in total. Combined, the four brains can breeze through difficult calculations faster than a supercomputer. This pokemon can float in the air by tucking in its four legs."
377,regirock,3,12,3,35,80,1,186,Rock Peak,"Regirock was sealed away by people long ago. If this pokemon's body is damaged in battle, it is said to seek out suitable rocks on its own to repair itself."
378,regice,2,12,3,35,80,1,187,Iceberg,"Regice's body was made during an ice age. The deep-frozen body can't be melted, even by fire. This pokemon controls frigid air of -328 degrees Fahrenheit."
379,registeel,4,12,3,35,80,1,188,Iron,Registeel has a body that is harder than any kind of metal. Its body is apparently hollow. No one has any idea what this pokemon eats.
380,latias,8,9,3,90,120,1,189,Eon,"Latias is highly sensitive to the emotions of people. If it senses any hostility, this pokemon ruffles the feathers all over its body and cries shrilly to intimidate the foe."
381,latios,2,9,3,90,120,1,190,Eon,Latios has the ability to make others see an image of what it has seen or imagines in its head. This pokemon is intelligent and understands human speech.
382,kyogre,2,3,5,0,120,1,191,Sea Basin,"Through Primal Reversion and with nature's full power, it will take back its true form. It can summon storms that cause the sea levels to rise."
383,groudon,8,6,5,0,120,1,192,Continent,"Groudon is said to be the personification of the land itself. Legends tell of its many clashes against Kyogre, as each sought to gain the power of nature."
384,rayquaza,5,2,3,0,120,1,193,Sky High,Rayquaza is said to have lived for hundreds of millions of years. Legends remain of how it put to rest the clash between Kyogre and Groudon.
385,jirachi,10,12,3,100,120,1,194,Wish,"A legend states that Jirachi will make true any wish that is written on notes attached to its head when it awakens. If this pokemon senses danger, it will fight without awakening."
386,deoxys,8,12,3,0,120,1,195,DNA,The DNA of a space virus underwent a sudden mutation upon exposure to a laser beam and resulted in Deoxys. The crystalline organ on this pokemon's chest appears to be its brain.



387,turtwig,5,8,45,70,20,4,196,Tiny Leaf,Photosynthesis occurs across its body under the sun. The shell on its back is actually hardened soil.
388,grotle,5,8,45,70,20,4,,Grove,"It lives along water in forests. In the daytime, it leaves the forest to sunbathe its treed shell."
389,torterra,5,8,45,70,20,4,,Continent,"Ancient people imagined that beneath the ground, a gigantic Torterra dwelled."
390,chimchar,3,6,45,70,20,4,197,Chimp,Its fiery rear end is fueled by gas made in its belly. Even rain can't extinguish the fire.
391,monferno,3,6,45,70,20,4,,Playful,It skillfully controls the intensity of the fire on its tail to keep its foes at an ideal distance.
392,infernape,3,6,45,70,20,4,,Flame,Its crown of fire is indicative of its fiery nature. It is beaten by none in terms of quickness.
393,piplup,2,12,45,70,20,4,198,Penguin,It doesn't like to be taken care of. It's difficult to bond with since it won't listen to its Trainer.
394,prinplup,2,6,45,70,20,4,,Penguin,"It lives alone, away from others. Apparently, every one of them believes it is the most important."
395,empoleon,2,6,45,70,20,4,,Emperor,It swims as fast as a jet boat. The edges of its wings are sharp and can slice apart drifting ice.
396,starly,3,9,255,70,15,4,199,Starling,"They flock in great numbers. Though small, they flap their wings with great power."
397,staravia,3,9,120,70,15,4,,Starling,"They maintain huge flocks, although fierce scuffles break out between various flocks."
398,staraptor,3,9,45,70,15,4,,Predator,The muscles in its wings and legs are strong. It can easily fly while gripping a small pokemon.
399,bidoof,3,8,255,70,15,2,200,Plump Mouse,"With nerves of steel, nothing can perturb it. It is more agile and active than it appears."
400,bibarel,3,6,127,70,15,2,,Beaver,It busily makes its nest with stacks of branches and roots it has cut up with its sharp incisors.
401,kricketot,8,12,255,70,15,4,201,Cricket,It chats with others using the sounds of its colliding antennae. These sounds are fall hallmarks.
402,kricketune,8,13,45,70,15,4,,Cricket,It crosses its knifelike arms in front of its chest when it cries. It can compose melodies ad lib.
403,shinx,2,8,235,70,20,4,202,Flash,The extension and contraction of its muscles generates electricity. It glows when in trouble.
404,luxio,2,8,120,100,20,4,,Spark,Its claws loose electricity with enough amperage to cause fainting. They live in small groups.
405,luxray,2,8,45,70,20,4,,Gleam Eyes,"When its eyes gleam gold, it can spot hiding prey-even those taking shelter behind a wall."
406,budew,5,12,255,70,20,4,203,Bud,"When it feels the sun's warm touch, it opens its bud to release pollen. It lives alongside clear pools."
407,roserade,5,12,75,70,20,4,,Bouquet,"Luring prey with a sweet scent, it uses poison whips on its arms to poison, bind, and finish off the prey."
408,cranidos,2,6,45,70,30,5,204,Head Butt,It was resurrected from an iron ball-like fossil. It downs prey with its headbutts.
409,rampardos,2,6,45,70,30,5,,Head Butt,"Its skull withstands impacts of any magnitude. As a result, its brain never gets the chance to grow."
410,shieldon,4,8,45,70,30,5,205,Shield,It habitually polishes its face by rubbing it against tree trunks. It is weak to attacks from behind.
411,bastiodon,4,8,45,70,30,5,,Shield,"When they lined up side by side, no foe could break through. They shielded their young in that way."
412,burmy,4,2,120,70,15,2,206,Bagworm,"To shelter itself from cold, wintry winds, it covers itself with a cloak made of twigs and leaves."
413,wormadam,4,2,45,70,15,2,,Bagworm,Its appearance changes depending on where it evolved. The materials on hand become a part of its body.
414,mothim,10,13,45,70,15,2,,Moth,It loves the honey of flowers and steals honey collected by Combee.
415,combee,10,11,120,70,15,4,207,Tiny Bee,The trio is together from birth. It constantly gathers honey from flowers to please Vespiquen.
416,vespiquen,10,9,45,70,15,4,,Beehive,It houses its colony in cells in its body and releases various pheromones to make those grubs do its bidding.
417,pachirisu,9,8,200,100,10,2,208,EleSquirrel,It makes fur balls that crackle with static electricity. It stores them with berries in tree holes.
418,buizel,3,8,190,70,20,2,209,Sea Weasel,"It swims by rotating its two tails like a screw. When it dives, its flotation sac collapses."
419,floatzel,3,8,75,70,20,2,,Sea Weasel,It floats using its well-developed flotation sac. It assists in the rescues of drowning people.
420,cherubi,6,11,190,70,20,2,210,Cherry,"Sunlight colors it red. When the small ball is drained of nutrients, it shrivels to herald evolution."
421,cherrim,6,7,75,70,20,2,,Blossom,"During times of strong sunlight, its bud blooms, its petals open fully, and it becomes very active."
422,shellos,7,14,190,70,20,2,211,Sea Slug,"Beware of pushing strongly on its squishy body, as it makes a mysterious purple fluid ooze out."
423,gastrodon,7,14,75,70,20,2,,Sea Slug,"When its natural enemy attacks, it oozes purple fluid and escapes."
424,ambipom,7,6,45,100,20,3,,Long Tail,"They work in large colonies and make rings by linking their tails, apparently in friendship."
425,drifloon,7,4,125,70,30,6,212,Balloon,"A pokemon formed by the spirits of people and pokemon. It loves damp, humid seasons."
426,drifblim,7,4,60,70,30,6,,Blimp,"It carries people and pokemon when it flies. But since it only drifts, it can end up anywhere."
427,buneary,3,6,190,0,20,2,213,Rabbit,Its ears are always rolled up. They can be forcefully extended to shatter even a large boulder.
428,lopunny,3,6,60,140,20,2,,Rabbit,"Extremely cautious, it quickly bounds off when it senses danger."
429,mismagius,7,1,45,35,25,3,,Magical,"It chants incantations. While they usually torment targets, some chants bring happiness."
430,honchkrow,1,9,30,35,20,4,,Big Boss,"If one utters a deep cry, many Murkrow gather quickly. For this, it is called ""Summoner of Night."""
431,glameow,4,8,190,70,20,3,214,Catty,It claws if displeased and purrs when affectionate. Its fickleness is very popular among some.
432,purugly,4,8,75,70,20,3,,Tiger Cat,It would claim another pokemon's nest as its own if it finds a nest sufficiently comfortable.
433,chingling,10,12,120,70,25,3,215,Bell,"Each time it hops, it makes a ringing sound. It deafens foes by emitting high-frequency cries."
434,stunky,7,8,225,70,20,2,216,Skunk,"It sprays a foul fluid from its rear. Its stench spreads over a mile radius, driving pokemon away."
435,skuntank,7,8,60,70,20,2,,Skunk,It sprays a vile-smelling fluid from the tip of its tail to attack. Its range is over 160 feet.
436,bronzor,5,1,255,70,20,2,217,Bronze,Ancient people believed that the pattern on Bronzor's back contained a mysterious power.
437,bronzong,5,4,90,70,20,2,,Bronze Bell,"In ages past, this pokemon was revered as a bringer of rain. It was found buried in the ground."
438,bonsly,3,7,255,70,20,2,218,Bonsai,It prefers arid environments. It leaks water from its eyes to adjust its body's fluid levels.
439,mimejr,6,12,145,70,25,2,219,Mime,"In an attempt to confuse its enemy, it mimics the enemy's movements. Then it wastes no time in making itself scarce!"
440,happiny,6,12,130,140,40,3,220,Playhouse,"It carries a round, egg-shaped rock in its belly pouch and gives the rock to its friends."
441,chatot,1,9,30,35,20,4,221,Music Note,It mimics the cries of other pokemon to trick them into thinking it's one of them. This way they won't attack it.
442,spiritomb,7,5,100,70,30,2,222,Forbidden,A pokemon that was formed by 108 spirits. It is bound to a fissure in an odd keystone.
443,gible,2,6,45,70,40,1,223,Land Shark,It nests in horizontal holes warmed by geothermal heat. Foes who get too close can expect to be pounced on and bitten.
444,gabite,2,6,45,70,40,1,,Cave,It loves sparkly things. It seeks treasures in caves and hoards the loot in its nest.
445,garchomp,2,6,45,70,40,1,,Mach,"When it folds up its body and extends its wings, it looks like a jet plane. It flies at sonic speed."
446,munchlax,1,12,50,70,40,1,224,Big Eater,"It hides food under its long body hair. However, it forgets it has hidden the food."
447,riolu,2,6,75,70,25,4,225,Emanation,"It uses the shapes of auras, which change according to emotion, to communicate with others."
448,lucario,2,6,45,70,25,4,,Aura,"By catching the aura emanating from others, it can read their thoughts and movements."
449,hippopotas,3,8,140,70,30,1,226,Hippo,"It lives in arid places. Instead of perspiration, it expels grainy sand from its body."
450,hippowdon,3,8,60,70,30,1,,Heavyweight,It brandishes its gaping mouth in a display of fearsome strength. It raises vast quantities of sand while attacking.
451,skorupi,7,14,120,70,20,1,227,Scorpion,It grips prey with its tail claws and injects poison. It tenaciously hangs on until the poison takes.
452,drapion,7,14,45,70,20,1,,Ogre Scorpion,"It takes pride in its strength. Even though it can tear foes apart, it finishes them off with powerful poison."
453,croagunk,2,12,140,100,10,2,228,Toxic Mouth,Its cheeks hold poison sacs. It tries to catch foes off guard to jab them with toxic fingers.
454,toxicroak,2,12,75,70,20,2,,Toxic Mouth,"It has a poison sac at its throat. When it croaks, the stored poison is churned for greater potency."
455,carnivine,5,10,200,70,25,1,229,Bug Catcher,"It attracts prey with its sweet-smelling saliva, then chomps down. It takes a whole day to eat prey."
456,finneon,2,3,190,70,20,5,230,Wing Fish,The line running down its side can store sunlight. It shines vividly at night.
457,lumineon,2,3,75,70,20,5,,Neon,It lives on the deep-sea floor. It attracts prey by flashing the patterns on its four tail fins.
458,mantyke,2,9,25,70,25,1,231,Kite,The pattern on its back varies by region. It often swims in a school of Remoraid.
459,snover,9,6,120,70,20,1,232,Frost Tree,"During cold seasons, it migrates to the mountain's lower reaches. It returns to the snow-covered summit in the spring."
460,abomasnow,9,6,60,70,20,1,,Frost Tree,"It blankets wide areas in snow by whipping up blizzards. It is also known as ""The Ice Monster."""
461,weavile,1,6,45,35,20,4,,Sharp Claw,It lives in snowy regions. It carves patterns in trees with its claws as a signal to others.
462,magnezone,4,4,30,70,20,2,,Magnet Area,"Sometimes the magnetism emitted by Magnezone is too strong, making them attract each other so they cannot move."
463,lickilicky,6,12,30,70,20,2,,Licking,It wraps things with its extensible tongue. Getting too close to it will leave you soaked with drool.
464,rhyperior,4,6,30,70,20,1,,Drill,"From holes in its palms, it fires out Geodude. Its carapace can withstand volcanic eruptions."
465,tangrowth,2,12,30,70,20,2,,Vine,It ensnares prey by extending arms made of vines. Losing arms to predators does not trouble it.
466,electivire,10,6,30,70,25,2,,Thunderbolt,"As its electric charge amplifies, blue sparks begin to crackle between its horns."
467,magmortar,8,6,30,70,25,2,,Blast,"It blasts fireballs of over 3,600 degrees Fahrenheit from the ends of its arms. It lives in volcanic craters."
468,togekiss,9,9,30,70,10,3,,Jubilee,"As everyone knows, it visits peaceful regions, bringing them gifts of kindness and sweet blessings."
469,yanmega,5,13,30,70,20,2,,Ogre Darner,It prefers to battle by biting apart foes' heads instantly while flying by at high speed.
470,leafeon,5,8,45,35,35,2,,Verdant,"When you see Leafeon asleep in a patch of sunshine, you'll know it is using photosynthesis to produce clean air."
471,glaceon,2,8,45,35,35,2,,Fresh Snow,"By controlling its body heat, it can freeze the atmosphere around it to make a diamond-dust flurry."
472,gliscor,7,9,30,70,20,4,,Fang Scorpion,"It observes prey while hanging inverted from branches. When the chance presents itself, it swoops!"
473,mamoswine,3,8,50,70,20,1,,Twin Tusk,"A frozen Mamoswine was dug from ice dating back 10,000 years. This pokemon has been around a long, long, long time."
474,porygonz,8,4,30,70,20,2,,Virtual,"Additional software was installed to make it a better pokemon. It began acting oddly, however."
475,gallade,9,12,45,35,20,1,,Blade,"Because it can sense what its foe is thinking, its attacks burst out first, fast, and fierce."
476,probopass,4,11,60,70,20,2,,Compass,It exudes strong magnetism from all over. It controls three small units called Mini-Noses.
477,dusknoir,1,4,45,35,25,3,,Gripper,It is said to take lost spirits into its pliant body and guide them home.
478,froslass,9,4,75,70,20,2,,Snow Land,It freezes foes with an icy breath nearly -60 degrees Fahrenheit. What seems to be its body is actually hollow.
479,rotom,8,1,45,70,20,2,233,Plasma,"Research continues on this pokemon, which could be the power source of a unique motor."
480,uxie,10,6,3,140,80,1,234,Knowledge,"Known as ""The Being of Knowledge."" It is said that it can wipe out the memory of those who see its eyes."
481,mesprit,6,6,3,140,80,1,235,Emotion,"Known as ""The Being of Emotion."" It taught humans the nobility of sorrow, pain, and joy."
482,azelf,2,6,3,140,80,1,236,Willpower,"Known as ""The Being of Willpower."" It sleeps at the bottom of a lake to keep the world in balance."
483,dialga,9,8,30,0,120,1,237,Temporal,A pokemon spoken of in legend. It is said that time began moving when Dialga was born.
484,palkia,7,6,30,0,120,1,238,Spatial,It is said to live in a gap in the spatial dimension parallel to ours. It appears in mythology.
485,heatran,3,8,3,100,10,1,239,Lava Dome,It dwells in volcanic caves. It digs in with its cross-shaped feet to crawl on ceilings and walls.
486,regigigas,9,12,3,0,120,1,240,Colossal,"It is said to have made pokemon that look like itself from a special ice mountain, rocks, and magma."
487,giratina,1,10,3,0,120,1,241,Renegade,"This pokemon is said to live in a world on the reverse side of ours, where common knowledge is distorted and strange."
488,cresselia,10,14,3,100,120,1,242,Lunar,Shiny particles are released from its wings like a veil. It is said to represent the crescent moon.
489,phione,2,4,30,70,40,1,243,Sea Drifter,"When the water warms, they inflate the flotation sac on their heads and drift languidly on the sea in packs."
490,manaphy,2,12,3,70,10,1,244,Seafaring,It is born with a wondrous power that lets it bond with any kind of pokemon.
491,darkrai,1,12,3,0,120,1,245,Pitch-Black,"It chases people and pokemon from its territory by causing them to experience deep, nightmarish slumbers."
492,shaymin,5,8,45,100,120,4,246,Gratitude,It can dissolve toxins in the air to instantly transform ruined land into a lush field of flowers.
493,arceus,4,8,3,0,120,1,247,Alpha,"According to the legends of Sinnoh, this pokemon emerged from an egg and shaped all there is in this world."
494,victini,10,12,3,100,120,1,248,Victory,"This pokemon brings victory. It is said that Trainers with Victini always win, regardless of the type of encounter."
495,snivy,5,6,45,70,20,4,249,Grass Snake,Being exposed to sunlight makes its movements swifter. It uses vines more adeptly than its hands.




496,servine,5,6,45,70,20,4,,Grass Snake,"It moves along the ground as if sliding. Its swift movements befuddle its foes, and it then attacks with a vine whip."
497,serperior,5,2,45,70,20,4,,Regal,It only gives its all against strong opponents who are not fazed by the glare from Serperior's noble eyes.
498,tepig,8,8,45,70,20,4,250,Fire Pig,It can deftly dodge its foe's attacks while shooting fireballs from its nose. It roasts berries before it eats them.
499,pignite,8,6,45,70,20,4,,Fire Pig,"The more it eats, the more fuel it has to make the fire in its stomach stronger. This fills it with even more power."
500,emboar,8,6,45,70,20,4,,Mega Fire Pig,It can throw a fire punch by setting its fists on fire with its fiery chin. It cares deeply about its friends.
501,oshawott,2,6,45,70,20,4,251,Sea Otter,The scalchop on its stomach isn't just used for battle-it can be used to break open hard berries as well.
502,dewott,2,6,45,70,20,4,,Discipline,Strict training is how it learns its flowing double-scalchop technique.
503,samurott,2,8,45,70,20,4,,Formidable,"In the time it takes a foe to blink, it can draw and sheathe the seamitars attached to its front legs."
504,patrat,3,8,255,70,15,2,252,Scout,"Using food stored in cheek pouches, they can keep watch for days. They use their tails to communicate with others."
505,watchog,3,6,255,70,20,2,,Lookout,"Using luminescent matter, it makes its eyes and body glow and stuns attacking opponents."
506,lillipup,3,8,255,70,15,4,253,Puppy,The long hair around its face provides an amazing radar that lets it sense subtle changes in its surroundings.
507,herdier,4,8,120,70,15,4,,Loyal Dog,"This very loyal pokemon helps Trainers, and it also takes care of other pokemon."
508,stoutland,4,8,45,70,15,4,,Big-Hearted,It rescues people stranded by blizzards in the mountains. Its shaggy fur shields it from the cold.
509,purrloin,7,8,255,70,20,2,254,Devious,"Its cute act is a ruse. When victims let down their guard, they find their items taken. It attacks with sharp claws."
510,liepard,7,8,90,70,20,2,,Cruel,Their beautiful form comes from the muscles they have developed. They run silently in the night.
511,pansage,5,6,190,70,20,2,255,Grass Monkey,It shares the leaf on its head with weary-looking pokemon. These leaves are known to relieve stress.
512,simisage,5,6,75,70,20,2,,Thorn Monkey,It attacks enemies with strikes of its thorn-covered tail. This pokemon is wild tempered.
513,pansear,8,6,190,70,20,2,256,High Temp,"Very intelligent, it roasts berries before eating them. It likes to help people."
514,simisear,8,6,75,70,20,2,,Ember,A flame burns inside its body. It scatters embers from its head and tail to sear its opponents.
515,panpour,2,6,190,70,20,2,257,Spray,The water stored inside the tuft on its head is full of nutrients. It waters plants with it using its tail.
516,simipour,2,6,75,70,20,2,,Geyser,"The high-pressure water expelled from its tail is so powerful, it can remove a concrete wall."
517,munna,6,8,190,70,10,3,258,Dream Eater,This pokemon appears before people and pokemon who are having nightmares and eats those dreams.
518,musharna,6,12,75,70,10,3,,Drowsing,The mist emanating from their foreheads is packed with the dreams of people and pokemon.
519,pidove,4,9,255,70,15,4,259,Tiny Pigeon,This very forgetful pokemon will wait for a new order from its Trainer even though it already has one.
520,tranquill,4,9,120,70,15,4,,Wild Pigeon,"Many people believe that, deep in the forest where Tranquill live, there is a peaceful place where there is no war."
521,unfezant,4,9,45,70,15,4,,Proud,Males swing their head plumage to threaten opponents. The females' flying abilities surpass those of the males.
522,blitzle,1,8,190,70,20,2,260,Electrified,"When thunderclouds cover the sky, it will appear. It can catch lightning with its mane and store the electricity."
523,zebstrika,1,8,75,70,20,2,,Thunderbolt,"When this ill-tempered pokemon runs wild, it shoots lightning from its mane in all directions."
524,roggenrola,2,7,255,70,15,4,261,Mantle,"Its ear is hexagonal in shape. Compressed underground, its body is as hard as steel."
525,boldore,2,10,120,70,15,4,,Ore,"Because its energy was too great to be contained, the energy leaked and formed orange crystals."
526,gigalith,2,10,45,70,15,4,,Compressed,The solar rays it absorbs are processed in its energy core and fired as a ball of light.
527,woobat,2,9,190,70,15,2,262,Bat,Its habitat is dark forests and caves. It emits ultrasonic waves from its nose to learn about its surroundings.
528,swoobat,2,9,45,70,15,2,,Courting,It shakes its tail vigorously when it emits ultrasonic waves strong enough to reduce concrete to rubble.
529,drilbur,4,6,120,70,20,2,263,Mole,It makes its way swiftly through the soil by putting both claws together and rotating at high speed.
530,excadrill,4,12,60,70,20,2,,Subterrene,It can help in tunnel construction. Its drill has evolved into steel strong enough to bore through iron plates.
531,audino,6,6,255,70,20,3,264,Hearing,"Using the feelers on its ears, it can tell how someone is feeling or when an egg might hatch."
532,timburr,4,12,180,70,20,4,265,Muscular,These pokemon appear at building sites and help out with construction. They always carry squared logs.
533,gurdurr,4,12,90,70,20,4,,Muscular,"With strengthened bodies, they skillfully wield steel beams to take down buildings."
534,conkeldurr,3,12,45,70,20,4,,Muscular,"It is thought that Conkeldurr taught humans how to make concrete more than 2,000 years ago."
535,tympole,2,3,255,70,20,4,266,Tadpole,"By vibrating its cheeks, it emits sound waves imperceptible to humans and warns others of danger."
536,palpitoad,2,6,120,70,20,4,,Vibration,"When they vibrate the bumps on their heads, they can make waves in water or earthquake-like vibrations on land."
537,seismitoad,2,12,45,70,20,4,,Vibration,It increases the power of its punches by vibrating the bumps on its fists. It can turn a boulder to rubble with one punch.
538,throh,8,12,45,70,20,2,267,Judo,"When it tightens its belt, it becomes stronger. Wild Throh use vines to weave their own belts."
539,sawk,2,12,45,70,20,2,268,Karate,"Desiring the strongest karate chop, they seclude themselves in mountains and train without sleeping."
540,sewaddle,10,14,255,70,15,4,269,Sewing,This pokemon makes clothes for itself. It chews up leaves and sews them with sticky thread extruded from its mouth.
541,swadloon,5,4,120,70,15,4,,Leaf-Wrapped,Forests where Swadloon live have superb foliage because the nutrients they make from fallen leaves nourish the plant life.
542,leavanny,10,12,45,70,15,4,,Nurturing,"Upon finding a small pokemon, it weaves clothing for it from leaves by using the sticky silk secreted from its mouth."
543,venipede,8,14,255,70,15,4,270,Centipede,It discovers what is going on around it by using the feelers on its head and tail. It is brutally aggressive.
544,whirlipede,4,1,120,70,15,4,,Curlipede,"Protected by a hard shell, it spins its body like a wheel and crashes furiously into its enemies."
545,scolipede,8,14,45,70,20,4,,Megapede,It clasps its prey with the claws on its neck until it stops moving. Then it finishes it off with deadly poison.
546,cottonee,5,1,190,70,20,2,271,Cotton Puff,"When attacked, it escapes by shooting cotton from its body. The cotton serves as a decoy to distract the attacker."
547,whimsicott,5,12,75,70,20,2,,Windveiled,"They appear along with whirlwinds. They pull pranks, such as moving furniture and leaving balls of cotton in homes."
548,petilil,5,5,190,70,20,2,272,Bulb,The leaves on its head are very bitter. Eating one of these leaves is known to refresh a tired body.
549,lilligant,5,5,75,70,20,2,,Flowering,The fragrance of the garland on its head has a relaxing effect. It withers if a Trainer does not take good care of it.
550,basculin,5,3,25,70,40,2,273,Hostile,Red- and blue-striped Basculin are very violent and always fighting. They are also remarkably tasty.
551,sandile,3,8,180,70,20,4,274,Desert Croc,"It moves along below the sand's surface, except for its nose and eyes. A dark membrane shields its eyes from the sun."
552,krokorok,3,8,90,70,20,4,,Desert Croc,They live in groups of a few individuals. Protective membranes shield their eyes from sandstorms.
553,krookodile,8,6,45,70,20,4,,Intimidation,"Very violent pokemon, they try to clamp down on anything that moves in front of their eyes."
554,darumaka,8,12,120,70,20,4,275,Zen Charm,"Darumaka's droppings are hot, so people used to put them in their clothes to keep themselves warm."
555,darmanitan,8,8,60,70,20,4,,Blazing,"When one is injured in a fierce battle, it hardens into a stone-like form. Then it meditates and sharpens its mind."
556,maractus,5,5,255,70,20,2,276,Cactus,It uses an up-tempo song and dance to drive away the bird pokemon that prey on its flower seeds.
557,dwebble,8,14,190,70,20,2,277,Rock Inn,"It makes a hole in a suitable rock. If that rock breaks, the pokemon remains agitated until it locates a replacement."
558,crustle,8,14,75,70,20,2,,Stone Home,"It possesses legs of enormous strength, enabling it to carry heavy slabs for many days, even when crossing arid land."
559,scraggy,10,6,180,35,15,2,278,Shedding,"Its skin has a rubbery elasticity, so it can reduce damage by defensively pulling its skin up to its neck."
560,scrafty,8,6,90,70,15,2,,Hoodlum,"It pulls up its shed skin to protect itself while it kicks. The bigger the crest, the more respected it is."
561,sigilyph,1,9,45,70,20,2,279,Avianoid,"The guardians of an ancient city, they use their psychic power to attack enemies that invade their territory."
562,yamask,1,4,190,70,25,2,280,Spirit,These pokemon arose from the spirits of people interred in graves. Each retains memories of its former life.
563,cofagrigus,10,5,90,70,25,2,,Coffin,It has been said that they swallow those who get too close and turn them into mummies. They like to eat gold nuggets.
564,tirtouga,2,8,45,70,30,2,281,Prototurtle,"About 100 million years ago, these pokemon swam in oceans. It is thought they also went on land to attack prey."
565,carracosta,2,6,45,70,30,2,,Prototurtle,They can live both in the ocean and on land. A slap from one of them is enough to open a hole in the bottom of a tanker.
566,archen,10,9,45,70,30,2,282,First Bird,"Revived from a fossil, this pokemon is thought to be the ancestor of all bird pokemon."
567,archeops,10,9,45,70,30,2,,First Bird,"They are intelligent and will cooperate to catch prey. From the ground, they use a running start to take flight."
568,trubbish,5,12,190,70,20,2,283,Trash Bag,The combination of garbage bags and industrial waste caused the chemical reaction that created this pokemon.
569,garbodor,5,12,60,70,20,2,,Trash Heap,It clenches opponents with its left arm and finishes them off with foul-smelling poison gas belched from its mouth.
570,zorua,4,8,75,70,25,4,284,Tricky Fox,"It changes so it looks just like its foe, tricks it, and then uses that opportunity to flee."
571,zoroark,4,6,45,70,20,4,,Illusion Fox,Each has the ability to fool a large group of people simultaneously. They protect their lair with illusory scenery.
572,minccino,4,8,255,70,15,3,285,Chinchilla,Minccino greet each other by grooming one another thoroughly with their tails.
573,cinccino,4,8,60,70,15,3,,Scarf,Their white fur feels amazing to touch. Their fur repels dust and prevents static electricity from building up.
574,gothita,7,12,200,70,20,4,286,Fixation,Their ribbonlike feelers increase their psychic power. They are always staring at something.
575,gothorita,7,12,100,70,20,4,,Manipulate,"Starlight is the source of their power. At night, they mark star positions by using psychic power to float stones."
576,gothitelle,7,12,50,70,20,4,,Astral Body,Starry skies thousands of light-years away are visible in the space distorted by their intense psychic power.
577,solosis,5,1,200,70,20,4,287,Cell,"Because their bodies are enveloped in a special liquid, they are fine in any environment, no matter how severe."
578,duosion,5,1,100,70,20,4,,Mitosis,"Since they have two divided brains, at times they suddenly try to take two different actions at once."
579,reuniclus,5,4,50,70,20,4,,Multiplying,"They use psychic power to control their arms, which are made of a special liquid. They can crush boulders psychically."
580,ducklett,2,9,190,70,20,2,288,Water Bird,"When attacked, it uses its feathers to splash water, escaping under cover of the spray."
581,swanna,9,9,45,70,20,2,,White Bird,"Despite their elegant appearance, they can flap their wings strongly and fly for thousands of miles."
582,vanillite,9,5,255,70,20,1,289,Fresh Snow,The temperature of their breath is -58 degrees Fahrenheit. They create snow crystals and make snow fall in the areas around them.
583,vanillish,9,5,120,70,20,1,,Icy Snow,"They cool down the surrounding air and create ice particles, which they use to freeze their foes."
584,vanilluxe,9,11,45,70,20,1,,Snowstorm,"If both heads get angry simultaneously, this pokemon expels a blizzard, burying everything in snow."
585,deerling,10,8,190,70,20,2,290,Season,Their coloring changes according to the seasons and can be slightly affected by the temperature and humidity as well.
586,sawsbuck,3,8,75,70,20,2,,Season,They migrate according to the seasons. People can tell the season by looking at Sawsbuck's horns.
587,emolga,9,8,200,70,20,2,291,Sky Squirrel,They live on treetops and glide using the inside of a cape-like membrane while discharging electricity.
588,karrablast,2,12,200,70,15,2,292,Clamping,These mysterious pokemon evolve when they receive electrical stimulation while they are in the same place as Shelmet.
589,escavalier,4,4,75,70,15,2,,Cavalry,"Wearing the shell covering they stole from Shelmet, they defend themselves and attack with two lances."
590,foongus,9,4,190,70,20,2,293,Mushroom,"It lures people in with its Pok? Ball pattern, then releases poison spores. Why it resembles a Pok? Ball is unknown."
591,amoonguss,9,4,75,70,20,2,,Mushroom,"They show off their Pok? Ball caps to lure prey, but very few pokemon are fooled by this."
592,frillish,9,10,190,70,20,2,294,Floating,"They paralyze prey with poison, then drag them down to their lairs, five miles below the surface."
593,jellicent,9,10,60,70,20,2,,Floating,Its body is mostly seawater. It's said there's a castle of ships Jellicent have sunk on the seafloor.
594,alomomola,6,3,75,70,40,3,295,Caring,"Floating in the open sea is how they live. When they find a wounded pokemon, they embrace it and bring it to shore."
595,joltik,10,14,190,70,20,2,296,Attaching,"Since it can't generate its own electricity, it sticks onto large-bodied pokemon and absorbs static electricity."
596,galvantula,10,14,75,70,20,2,,EleSpider,"They employ an electrically charged web to trap their prey. While it is immobilized by shock, they leisurely consume it."
597,ferroseed,4,1,255,70,20,2,297,Thorn Seed,"When threatened, it attacks by shooting a barrage of spikes, which gives it a chance to escape by rolling away."
598,ferrothorn,4,10,90,70,20,2,,Thorn Pod,"By swinging around its three spiky feelers and shooting spikes, it can obliterate an opponent."
599,klink,4,11,130,70,20,4,298,Gear,Interlocking two bodies and spinning around generates the energy they need to live.
600,klang,4,11,60,70,20,4,,Gear,"By changing the direction in which it rotates, it communicates its feelings to others. When angry, it rotates faster."
601,klinklang,4,11,30,70,20,4,,Gear,The gear with the red core is rotated at high speed for a rapid energy charge.
602,tynamo,9,3,190,70,20,1,299,EleFish,"While one alone doesn't have much power, a chain of many Tynamo can be as powerful as lightning."
603,eelektrik,2,3,60,70,20,1,,EleFish,It wraps itself around its prey and paralyzes it with electricity from the round spots on its sides. Then it chomps.
604,eelektross,2,3,30,70,20,1,,EleFish,"With their sucker mouths, they suck in prey. Then they use their fangs to shock the prey with electricity."
605,elgyem,2,6,255,70,20,2,300,Cerebral,"It uses its strong psychic power to squeeze its opponent's brain, causing unendurable headaches."
606,beheeyem,3,12,90,70,20,2,,Cerebral,"Apparently, it communicates by flashing its three fingers, but those patterns haven't been decoded."
607,litwick,9,5,190,70,20,4,301,Candle,"While shining a light and pretending to be a guide, it leeches off the life force of any who follow it."
608,lampent,1,4,90,70,20,4,,Lamp,The spirits it absorbs fuel its baleful fire. It hangs around hospitals waiting for people to pass on.
609,chandelure,1,4,45,70,20,4,,Luring,"Being consumed in Chandelure's flame burns up the spirit, leaving the body behind."
610,axew,5,6,75,35,40,1,302,Tusk,They use their tusks to crush the berries they eat. Repeated regrowth makes their tusks strong and sharp.
611,fraxure,5,6,60,35,40,1,,Axe Jaw,Their tusks can shatter rocks. Territory battles between Fraxure can be intensely violent.
612,haxorus,10,6,45,35,40,1,,Axe Jaw,They are kind but can be relentless when defending territory. They challenge foes with tusks that can cut steel.
613,cubchoo,9,6,120,70,20,2,303,Chill,Its nose is always running. It sniffs the snot back up because the mucus provides the raw material for its moves.
614,beartic,9,8,60,70,20,2,,Freezing,They love the cold seas of the north. They create pathways across the ocean waters by freezing their own breath.
615,cryogonal,2,1,25,70,25,2,304,Crystallizing,They are born in snow clouds. They use chains made of ice crystals to capture prey.
616,shelmet,8,1,200,70,15,2,305,Snail,"When it and Karrablast are together, and both receive electrical stimulation, they both evolve."
617,accelgor,8,4,75,70,15,2,,Shell Out,"Having removed its heavy shell, it becomes very light and can fight with ninja-like movements."
618,stunfisk,3,3,75,70,20,2,306,Trap,"Its skin is very hard, so it is unhurt even if stepped on by sumo wrestlers. It smiles when transmitting electricity."
619,mienfoo,10,6,180,70,25,4,307,Martial Arts,"It takes pride in the speed at which it can use moves. What it loses in power, it makes up for in quantity."
620,mienshao,7,6,45,70,25,4,,Martial Arts,It wields the fur on its arms like a whip. Its arm attacks come with such rapidity that they cannot even be seen.
621,druddigon,8,6,45,70,30,2,308,Cave,"It races through narrow caves, using its sharp claws to catch prey. The skin on its face is harder than a rock."
622,golett,5,12,190,70,25,2,309,Automaton,"The energy that burns inside it enables it to move, but no one has yet been able to identify this energy."
623,golurk,5,12,90,70,25,2,,Automaton,It is said that Golurk were ordered to protect people and pokemon by the ancient people who made them.
624,pawniard,8,12,120,35,20,2,310,Sharp Blade,"Blades comprise this pokemon's entire body. If battling dulls the blades, it sharpens them on stones by the river."
625,bisharp,8,12,45,35,20,2,,Sword Blade,This pitiless pokemon commands a group of Pawniard to hound prey into immobility. It then moves in to finish the prey off.
626,bouffalant,3,8,45,70,20,2,311,Bash Buffalo,They charge wildly and headbutt everything. Their headbutts have enough destructive force to derail a train.
627,rufflet,9,9,190,70,20,1,312,Eaglet,"They crush berries with their talons. They bravely stand up to any opponent, no matter how strong it is."
628,braviary,8,9,60,70,20,1,,Valiant,"For the sake of its friends, this brave warrior of the sky will not stop battling, even if injured."
629,vullaby,3,9,190,35,20,1,313,Diapered,"Its wings are too tiny to allow it to fly. As the time approaches for it to evolve, it discards the bones it was wearing."
630,mandibuzz,3,9,60,35,20,1,,Bone Vulture,"They fly in circles around the sky. When they spot prey, they attack and carry it back to their nest with ease."
631,heatmor,8,6,90,70,20,2,314,Anteater,"Using their very hot, flame-covered tongues, they burn through Durant's steel bodies and consume their insides."
632,durant,4,14,90,70,20,2,315,Iron Ant,"Individuals each play different roles in driving Heatmor, their natural predator, away from their colony."
633,deino,2,8,45,35,40,1,316,Irate,"They cannot see, so they tackle and bite to learn about their surroundings. Their bodies are covered in wounds."
634,zweilous,2,8,45,35,40,1,,Hostile,The two heads do not get along. Whichever head eats more than the other gets to be the leader.
635,hydreigon,2,6,45,35,40,1,,Brutal,The heads on their arms do not have brains. They use all three heads to consume and remove everything.
636,larvesta,9,14,45,70,40,1,317,Torch,"Said to have been born from the sun, it spews fire from its horns and encases itself in a cocoon of fire when it evolves."
637,volcarona,9,13,15,70,40,1,,Sun,"A sea of fire engulfs the surroundings of their battles, since they use their six wings to scatter their ember scales."
638,cobalion,2,8,3,35,80,1,318,Iron Will,It has a body and heart of steel. Its glare is sufficient to make even an unruly pokemon obey it.
639,terrakion,4,8,3,35,80,1,319,Cavern,Its charge is strong enough to break through a giant castle wall in one blow. This pokemon is spoken of in legends.
640,virizion,5,8,3,35,80,1,320,Grassland,"Its head sprouts horns as sharp as blades. Using whirlwind-like movements, it confounds and swiftly cuts opponents."
641,tornadus,5,4,3,90,120,1,321,Cyclone,The lower half of its body is wrapped in a cloud of energy. It zooms through the sky at 200 mph.
642,thundurus,2,4,3,90,120,1,322,Bolt Strike,The spikes on its tail discharge immense bolts of lightning. It flies around the Unova region firing off lightning bolts.
643,reshiram,9,9,45,0,120,1,323,Vast White,This legendary pokemon can scorch the world with fire. It helps those who want to build a world of truth.
644,zekrom,1,6,45,0,120,1,324,Deep Black,This legendary pokemon can scorch the world with lightning. It assists those who want to build an ideal world.
645,landorus,3,4,3,90,120,1,325,Abundant,"Lands visited by Landorus grant such bountiful crops that it has been hailed as ""The Guardian of the Fields."""
646,kyurem,4,6,3,0,120,1,326,Boundary,This legendary ice pokemon waits for a hero to fill in the missing parts of its body with truth or ideals.
647,keldeo,10,8,3,35,80,1,327,Colt,"It crosses the world, running over the surfaces of oceans and rivers. It appears at scenic waterfronts."
648,meloetta,9,12,3,100,120,1,328,Melody,The melodies sung by Meloetta have the power to make pokemon that hear them happy or sad.
649,genesect,7,12,3,0,120,1,329,Paleozoic,This ancient bug pokemon was altered by Team Plasma. They upgraded the cannon on its back.



650,chespin,5,6,45,70,20,4,330,Spiny Nut,"The quills on its head are usually soft. When it flexes them, the points become so hard and sharp that they can pierce rock."
651,quilladin,5,6,45,70,20,4,,Spiny Armor,It relies on its sturdy shell to deflect predators' attacks. It counterattacks with its sharp quills.
652,chesnaught,5,6,45,70,20,4,,Spiny Armor,Its Tackle is forceful enough to flip a 50-ton tank. It shields its allies from danger with its own body.
653,fennekin,8,8,45,70,20,4,331,Fox,"Eating a twig fills it with energy, and its roomy ears give vent to air hotter than 390 degrees Fahrenheit."
654,braixen,8,6,45,70,20,4,,Fox,"It has a twig stuck in its tail. With friction from its tail fur, it sets the twig on fire and launches into battle."
655,delphox,8,6,45,70,20,4,,Fox,"It gazes into the flame at the tip of its branch to achieve a focused state, which allows it to see into the future."
656,froakie,2,8,45,70,20,4,332,Bubble Frog,It secretes flexible bubbles from its chest and back. The bubbles reduce the damage it would otherwise take when attacked.
657,frogadier,2,12,45,70,20,4,,Bubble Frog,"It can throw bubble-covered pebbles with precise control, hitting empty cans up to a hundred feet away."
658,greninja,2,12,45,70,20,4,,Ninja,"It creates throwing stars out of compressed water. When it spins them and throws them at high speed, these stars can split metal in two."
659,bunnelby,3,6,255,70,15,2,333,Digging,They use their large ears to dig burrows. They will dig the whole night through.
660,diggersby,3,6,127,70,15,2,,Digging,"With their powerful ears, they can heft boulders of a ton or more with ease. They can be a big help at construction sites."
661,fletchling,8,9,255,70,15,4,334,Tiny Robin,These friendly pokemon send signals to one another with beautiful chirps and tail-feather movements.
662,fletchinder,8,9,120,70,15,4,,Ember,"From its beak, it expels embers that set the tall grass on fire. Then it pounces on the bewildered prey that pop out of the grass."
663,talonflame,8,9,45,70,15,4,,Scorching,"In the fever of an exciting battle, it showers embers from the gaps between its feathers and takes to the air."
664,scatterbug,1,14,255,70,15,2,335,Scatterdust,"When under attack from bird pokemon, it spews a poisonous black powder that causes paralysis on contact."
665,spewpa,1,5,120,70,15,2,,Scatterdust,"It lives hidden within thicket shadows. When predators attack, it quickly bristles the fur covering its body in an effort to threaten them."
666,vivillon,1,13,45,70,15,2,,Scale,Vivillon with many different patterns are found all over the world. These patterns are affected by the climate of their habitat.
667,litleo,3,8,220,70,20,4,336,Lion Cub,"The stronger the opponent it faces, the more heat surges from its mane and the more power flows through its body."
668,pyroar,3,8,65,70,20,4,,Royal,The male with the largest mane of fire is the leader of the pride.
669,flabebe,9,4,225,70,20,2,337,Single Bloom,It draws out and controls the hidden power of flowers. The flower Flab?b? holds is most likely part of its body.
670,floette,9,4,120,70,20,2,,Single Bloom,It flutters around fields of flowers and cares for flowers that are starting to wilt. It draws out the hidden power of flowers to battle.
671,florges,9,4,45,70,20,2,,Garden,"It claims exquisite flower gardens as its territory, and it obtains power from basking in the energy emitted by flowering plants."
672,skiddo,3,8,200,70,20,2,338,Mount,"Thought to be one of the first pokemon to live in harmony with humans, it has a placid disposition."
673,gogoat,3,8,45,70,20,2,,Mount,It can tell how its Trainer is feeling by subtle shifts in the grip on its horns. This empathic sense lets them run as if one being.
674,pancham,9,6,220,70,25,2,339,Playful,"It does its best to be taken seriously by its enemies, but its glare is not sufficiently intimidating. Chewing on a leaf is its trademark."
675,pangoro,9,12,65,70,25,2,,Daunting,"Although it possesses a violent temperament, it won't put up with bullying. It uses the leaf in its mouth to sense the movements of its enemies."
676,furfrou,9,8,160,70,20,2,340,Poodle,Trimming its fluffy fur not only makes it more elegant but also increases the swiftness of its movements.
677,espurr,4,6,190,70,20,2,341,Restraint,The organ that emits its intense psychic power is sheltered by its ears to keep power from leaking out.
678,meowstic,9,6,75,70,20,2,,Constraint,"When in danger, it raises its ears and releases enough psychic power to grind a 10-ton truck into dust."
679,honedge,3,5,180,70,20,2,342,Sword,Apparently this pokemon is born when a departed spirit inhabits a sword. It attaches itself to people and drinks their life force.
680,doublade,3,11,90,70,20,2,,Sword,"When Honedge evolves, it divides into two swords, which cooperate via telepathy to coordinate attacks and slash their enemies to ribbons."
681,aegislash,3,5,45,70,20,2,,Royal Sword,"Generations of kings were attended by these pokemon, which used their spectral power to manipulate and control people and pokemon."
682,spritzee,6,4,200,70,20,2,343,Perfume,It emits a scent that enraptures those who smell it. This fragrance changes depending on what it has eaten.
683,aromatisse,6,12,140,70,20,2,,Fragrance,"It devises various scents, pleasant and unpleasant, and emits scents that its enemies dislike in order to gain an edge in battle."
684,swirlix,9,7,200,70,20,2,344,Cotton Candy,"To entangle its opponents in battle, it extrudes white threads as sweet and sticky as cotton candy."
685,slurpuff,9,12,140,70,20,2,,Meringue,It can distinguish the faintest of scents. It puts its sensitive sense of smell to use by helping pastry chefs in their work.
686,inkay,2,10,190,70,20,2,345,Revolving,Opponents who stare at the flashing of the light-emitting spots on its body become dazed and lose their will to fight.
687,malamar,2,5,80,70,20,2,,Overturning,"It wields the most compelling hypnotic powers of any pokemon, and it forces others to do whatever it wants."
688,binacle,3,11,120,70,20,2,346,Two-Handed,"Two Binacle live together on one rock. When they fight, one of them will move to a different rock."
689,barbaracle,3,11,45,70,20,2,,Collective,"When they evolve, two Binacle multiply into seven. They fight with the power of seven Binacle."
690,skrelp,3,5,225,70,20,2,347,Mock Kelp,"Camouflaged as rotten kelp, they spray liquid poison on prey that approaches unawares and then finish it off."
691,dragalge,3,5,55,70,20,2,,Mock Kelp,"Their poison is strong enough to eat through the hull of a tanker, and they spit it indiscriminately at anything that enters their territory."
692,clauncher,2,14,225,70,15,1,348,Water Gun,They knock down flying prey by firing compressed water from their massive claws like shooting a pistol.
693,clawitzer,2,2,55,70,15,1,,Howitzer,Their enormous claws launch cannonballs of water powerful enough to pierce tanker hulls.
694,helioptile,10,6,190,70,20,2,349,Generator,"They make their home in deserts. They can generate their energy from basking in the sun, so eating food is not a requirement."
695,heliolisk,10,6,75,70,20,2,,Generator,They flare their frills and generate energy. A single Heliolisk can generate sufficient electricity to power a skyscraper.
696,tyrunt,3,6,45,70,30,2,350,Royal Heir,"This pokemon was restored from a fossil. If something happens that it doesn't like, it throws a tantrum and runs wild."
697,tyrantrum,8,6,45,70,30,2,,Despot,"Thanks to its gargantuan jaws, which could shred thick metal plates as if they were paper, it was invincible in the ancient world it once inhabited."
698,amaura,2,8,45,70,30,2,351,Tundra,This ancient pokemon was restored from part of its body that had been frozen in ice for over 100 million years.
699,aurorus,2,8,45,70,30,2,,Tundra,"The diamond-shaped crystals on its body expel air as cold as -240 degrees Fahrenheit, surrounding its enemies and encasing them in ice."
700,sylveon,6,8,45,70,35,2,,Intertwining,It sends a soothing aura from its ribbonlike feelers to calm fights.
701,hawlucha,5,12,100,70,20,2,352,Wrestling,"Although its body is small, its proficient fighting skills enable it to keep up with big bruisers like Machamp and Hariyama."
702,dedenne,10,6,180,70,20,2,353,Antenna,"Its whiskers serve as antennas. By sending and receiving electrical waves, it can communicate with others over vast distances."
703,carbink,4,1,60,70,25,1,354,Jewel,"Born from the temperatures and pressures deep underground, it fires beams from the stone in its head."
704,goomy,7,2,45,35,40,1,355,Soft Tissue,"The weakest Dragon-type pokemon, it lives in damp, shady places, so its body doesn't dry out."
705,sliggoo,7,2,45,35,40,1,,Soft Tissue,"It drives away opponents by excreting a sticky liquid that can dissolve anything. Its eyes devolved, so it can't see anything."
706,goodra,7,6,45,35,40,1,,Dragon,"This very friendly Dragon-type pokemon will hug its beloved Trainer, leaving that Trainer covered in sticky slime."
707,klefki,4,1,75,70,20,3,356,Key Ring,These key collectors threaten any attackers by fiercely jingling their keys at them.
708,phantump,3,4,120,70,20,2,357,Stump,These pokemon are created when spirits possess rotten tree stumps. They prefer to live in abandoned forests.
709,trevenant,3,10,60,70,20,2,,Elder Tree,"It can control trees at will. It will trap people who harm the forest, so they can never leave."
710,pumpkaboo,3,1,120,70,20,2,358,Pumpkin,"The pumpkin body is inhabited by a spirit trapped in this world. As the sun sets, it becomes restless and active."
711,gourgeist,3,5,60,70,20,2,,Pumpkin,"Singing in eerie voices, they wander town streets on the night of the new moon. Anyone who hears their song is cursed."
712,bergmite,2,8,190,70,20,2,359,Ice Chunk,It blocks opponents' attacks with the ice that shields its body. It uses cold air to repair any cracks with new ice.
713,avalugg,2,8,55,70,20,2,,Iceberg,Its ice-covered body is as hard as steel. Its cumbersome frame crushes anything that stands in its way.
714,noibat,7,9,190,70,20,2,360,Sound Wave,"They live in pitch-black caves. Their enormous ears can emit ultrasonic waves of 200,000 hertz."
715,noivern,7,9,45,70,20,2,,Sound Wave,They fly around on moonless nights and attack careless prey. Nothing can beat them in a battle in the dark.
716,xerneas,2,8,45,0,120,1,361,Life,Legends say it can share eternal life. It slept for a thousand years in the form of a tree before its revival.
717,yveltal,8,9,45,0,120,1,362,Destruction,"When this legendary pokemon's wings and tail feathers spread wide and glow red, it absorbs the life force of living creatures."
718,zygarde,5,2,3,0,120,1,363,Order,"When the Kalos region's ecosystem falls into disarray, it appears and reveals its secret power."
719,diancie,6,4,3,70,25,1,,Jewel,"A sudden transformation of Carbink, its pink, glimmering body is said to be the loveliest sight in the whole world."
720,hoopa,7,1,3,100,120,1,,Mischief,"In its true form, it possess a huge amount of power. Legends of its avarice tell how it once carried off an entire castle to gain the treasure hidden within."
721,volcanion,3,8,3,100,120,1,,Steam,It lets out billows of steam and disappears into the dense fog. It's said to live in mountains where humans do not tread.



722,rowlet,3,9,45,70,15,4,371,Grass Quill,"Silently it glides, drawing near its targets. Before they even notice it, it begins to pelt them with vicious kicks."
723,dartrix,3,9,45,70,15,4,,Blade Quill,It throws sharp feathers called blade quills at enemies or prey. It seldom misses.
724,decidueye,3,9,45,70,15,4,,Arrow Quill,"Although basically cool and cautious, when it's caught by surprise, it's seized by panic."
725,litten,8,8,45,70,15,4,372,Fire Cat,It doesn't allow its emotions to be easily seen. Earning its trust takes time. It prefers solitude.
726,torracat,8,8,45,70,15,4,,Fire Cat,"It boasts powerful front legs. With a single punch, it can bend an iron bar right over."
727,incineroar,8,8,45,70,15,4,,Heel,"After hurling ferocious punches and flinging furious kicks, it finishes opponents off by spewing fire from around its navel."
728,popplio,2,3,45,70,15,4,373,Sea Lion,This Pokemon can control water bubbles. It practices diligently so it can learn to make big bubbles.
729,brionne,2,3,45,70,15,4,,Pop Star,"It cares deeply for its companions. When its Trainer is feeling down, it performs a cheery dance to try and help."
730,primarina,2,3,45,70,15,4,,Soloist,"Its singing voice is its chief weapon in battle. This Pokemon's Trainer must prioritize the daily maintenance of its throat at all costs."


731,pikipek,1,9,225,70,15,4,374,Woodpecker,"It can peck at a rate of 16 times a second to drill in trees. It uses the holes for food storage and for nesting."
732,trumbeak,1,9,120,70,15,4,,Bugle Beak,"It eats berries and stores their seeds in its beak. When it encounters enemies or prey, it fires off all the seeds in a burst."
733,toucannon,1,9,45,70,15,4,,Cannon,"When it battles, its beak heats up. The temperature can easily exceed 212 degrees Fahrenheit, causing severe burns when it hits."

734,yungoos,3,8,255,70,15,2,375,Loitering,"It wanders around in a never-ending search for food. At dusk, it collapses from exhaustion and falls asleep on the spot."
735,gumshoos,3,8,127,70,15,2,,Stakeout,"When it finds a trace of its prey, it patiently stakes out the location but its always snoozing by nightfall."

736,grubbin,4,14,255,70,15,2,376,Larva,"If you find its nest, you shouldnt stick your hand inside. Youll get bitten by an irritated Grubbin."
737,charjabug,5,2,120,70,15,2,,Battery,"Its stout shell provides excellent defense from attacks. It uses electricity on persistent opponents."
738,vikavolt,2,14,45,70,15,2,,Stag Beetle,"It builds up electricity in its abdomen, focuses it through its jaws, and then fires the electricity off in concentrated beams."

739,crabrawler,7,14,225,70,20,2,377,Boxing,"It punches so much, its pincers often come off from overuse, but they grow back quickly. What little meat they contain is rich and delicious."
740,crabominable,9,14,60,70,20,2,,Wolly Crab,"It just throws punches indiscriminately. In times of desperation, it can lop off its own pincers and fire them like rockets."

741,oricorio,8,9,45,70,20,2,378,Dancing,"It beats its wings together to create fire. As it moves in the steps of its beautiful dance, it bathes opponents in intense flames."

742,cutiefly,10,14,190,70,20,2,379,Bee Fly,"It feeds on the nectar and pollen of flowers. Because its able to sense auras, it can identify which flowers are about to bloom."
743,ribombee,10,13,75,70,20,2,,Bee Fly,"It rolls up pollen into puffs. It makes many different varieties, some used as food and others used in battle."

744,rockruff,3,8,190,70,15,2,380,Puppy,"When it rubs the rocks on its neck against you, thats proof of its love for you. However, the rocks are sharp, so the gesture is quite painful!"
745,lycanroc,3,8,90,70,15,2,,Wolf,"The rocks in its mane are sharper than a knife. Fragments that break off are treasured as good luck charms."



746,wishiwashi,2,3,60,70,15,1,381,Small Fry,"When its in trouble, its eyes moisten and begin to shine. The shining light attracts its comrades, and they stand together against their enemies."

747,mareanie,2,5,190,70,20,2,382,Brutal Star,"Aside from its head, its body parts regenerate quickly if theyre cut off. After a good nights sleep, Mareanie is back to normal."
748,toxapex,2,10,75,70,20,2,,Brutal Star,"With its 12 legs, it creates a dome to shelter within. The flow of the tides doesnt affect Toxapex in there, so it�s very comfortable."

749,mudbray,3,7,190,70,20,2,383,Donkey,"It has a stubborn, individualistic disposition. Eating dirt, making mud, and playing in the mire all form part of its daily routine."
750,mudsdale,3,7,60,70,20,2,,Draft Horse,"It spits a mud that provides resistance to both wind and rain, so the walls of old houses were often coated with it."

751,dewpider,5,7,200,70,15,2,384,Water Bubble,"It crawls onto the land in search of food. Its water bubble allows it to breathe and protects its soft head."
752,araquanid,5,14,100,70,15,2,,Water Bubble,"It usually passes its time in the water. When its belly is full, it stores its subdued prey in the water bubble on its head."

753,fomantis,6,6,190,70,20,2,385,Sickle Grass,"During the day, it sleeps and soaks up light. When night falls, it walks around looking for a safer place to sleep."
754,lurantis,6,12,75,70,20,2,,Bloom Sickle,"It fires beams from its sickle-shaped petals. These beams are powerful enough to cleave through thick metal plates."

755,morelull,7,5,190,70,20,2,386,Illuminating,"It scatters spores that flicker and glow. Anyone seeing these lights falls into a deep slumber."
756,shiinotic,7,12,75,70,20,2,,Illuminating,"It puts its prey to sleep and siphons off their vitality through the tip of its arms. If one of its kind is weakened, it helps by sending it vitality."

757,salandit,1,8,120,70,20,2,387,Toxic Lizard,"It burns its bodily fluids to create a poisonous gas. When its enemies become disoriented from inhaling the gas, it attacks them."
758,salazzle,1,8,45,70,20,2,,Toxic Lizard,"Filled with pheromones, its poisonous gas can be diluted to use in the production of luscious perfumes."

759,stufful,6,8,140,70,15,2,388,Flailing,"Despite its adorable appearance, when it gets angry and flails about, its arms and legs could knock a pro wrestler sprawling."
760,bewear,6,6,70,70,15,2,,Strong Arm,"It waves its hands wildly in intimidation and warning. Life is over for anyone who doesnt run away as fast as possible."

761,bounsweet,7,7,235,70,20,3,389,Fruit,"When under attack, it secretes a sweet and delicious sweat. The scent only calls more enemies to it."
762,steenee,7,12,120,70,20,3,,Fruit,"It bounces around, swinging the sepals on its head with abandon. Theyre quite painful when they smack you!"
763,tsareena,7,12,45,70,20,3,,Fruit,"Its long, striking legs arent just for show but to be used to kick with skill. In victory, it shows off by kicking the defeated, laughing boisterously."

764,comfey,5,1,60,70,20,1,390,Posy Picker,"It attaches flowers to its highly nutritious vine. This revitalizes the flowers, and they give off an aromatic scent."

765,oranguru,9,12,45,70,20,1,391,Sage,"It dont get along with each other, so theyre always engaging in battles of wits to decide which one is superior."

766,passimian,9,6,45,70,20,1,392,Teamwork,"They use their saliva to stick leaves to their shoulders. You can tell what troop they belong to from the position of the leaves."

767,wimpod,4,10,90,70,20,2,393,Turn Tail,"Its habitat varies from beaches to seabeds. A natural scavenger, it will gleefully chow down on anything edible, no matter how rotten."
768,golisopod,4,12,45,70,20,2,,Hard Scale,"It will do anything to win, taking advantage of every opening and finishing opponents off with the small claws on its front legs."

769,sandygast,3,2,140,70,15,2,394,Sand Heap,"Born from a sand mound playfully built by a child, this Pokemon embodies the grudges of the departed."
770,palossand,3,2,60,70,15,2,,Sand Castle,"Buried beneath the castle are masses of dried-up bones from those whose vitality it has drained."

771,pyukumuku,1,2,60,70,15,1,395,Sea Cucumber,"Its entire body is covered in its own slime. If you accidentally step on one, youll slip, and it will get mad and smack you!"

772,typenull,4,8,3,0,120,1,396,Synthetic,"Theres danger of its going on a rampage, so its true power is sealed away beneath its control mask."
773,silvally,4,8,3,0,120,1,,Synthetic,"This is its form once it has awakened and evolved. Freed from its heavy mask, its speed is greatly increased."

774,minior,3,1,30,70,25,3,397,Meteor,"Although its outer shell is uncommonly durable, the shock of falling to the ground smashes the shell to smithereens."

775,komala,2,12,45,70,20,1,398,Drowsing,"It stays asleep from the moment its born. When it falls into a deep sleep, it stops moving altogether."

776,turtonator,8,6,70,70,20,2,399,Blast Turtle,"Eating sulfur in its volcanic habitat is what causes explosive compounds to develop in its shell. Its droppings are also dangerously explosive."

777,togedemaru,4,6,180,70,10,2,400,Roly-Poly,"Its capacity to produce electricity is somewhat limited, so it gets charged up by letting lightning strike it!"

778,mimikyu,10,2,45,70,20,2,401,Disguise,"Its actual appearance is unknown. A scholar who saw what was under its rag was overwhelmed by terror and died from the shock."

779,bruxish,6,3,80,70,15,2,402,Gnash Teeth,"When it unleashes its psychic power from the protuberance on its head, the grating sound of grinding teeth echoes through the area."

780,drampa,9,2,70,70,20,2,403,Placid,"It has a compassionate personality, but if it is angered, it completely removes its surroundings with its intense breath."

781,dhelmise,5,5,25,70,25,2,404,Sea Creeper,"Swinging its massive anchor, it can KO Wailord in a single blow. What appears to be green seaweed is actually its body."

782,jangmoo,4,8,45,70,40,1,405,Scaly,"It smacks the scales on its head against rocks or against the ground to frighten its opponents. It can also contact its friends with these noises."
783,hakamoo,4,6,45,70,40,1,,Scaly,"It leaps at its prey with a courageous shout. Its scaly punches tear its opponents to shreds."
784,kommoo,4,6,45,70,40,1,,Scaly,"When it spots enemies, it threatens them by jingling the scales on its tail. Weak opponents will crack and flee in panic."

785,tapukoko,10,4,3,70,15,1,406,Land Spirit,"It confuses its enemies by flying too quickly for the eye to follow. It has a hair-trigger temper but forgets what made it angry an instant later."
786,tapulele,6,4,3,70,15,1,407,Land Spirit,"As it flutters about, it scatters its strangely glowing scales. Touching them is said to restore good health on the spot."
787,tapubulu,8,4,3,70,15,1,408,Land Spirit,"It pulls large trees up by the roots and swings them around. It causes vegetation to grow, and then it absorbs energy from the growth."
788,tapufini,7,4,3,70,15,1,409,Land Spirit,"The dense fog it creates brings the downfall and destruction of its confused enemies. Ocean currents are the source of its energy."

789,cosmog,2,1,45,0,120,1,410,Nebula,"Its body is gaseous and frail. It slowly grows as it collects dust from the atmosphere."
790,cosmoem,2,1,45,0,120,1,,Protostar,"Motionless as if dead, its body is faintly warm to the touch. In the distant past, it was called the cocoon of the stars."
791,solgaleo,9,8,45,0,120,1,,Sunne,"It is said to live in another world. The intense light it radiates from the surface of its body can make the darkest of nights light up like midday."
792,lunala,7,9,45,0,120,1,,Moone,"It sometimes summons unknown powers and life-forms here to this world from holes that lead to other worlds."

793,nihilego,9,10,45,0,120,1,411,Parasite,"One of several mysterious Ultra Beasts. People on the street report observing those infested by it suddenly becoming violent."

794,buzzwole,8,10,45,0,120,1,412,Swollen,"A mysterious life-form called an Ultra Beast. Witnesses saw it pulverize a dump truck with a single punch."

795,pheromosa,9,12,45,0,120,1,413,Lissome,"A life-form that lives in another world, its body is thin and supple, but it also possesses great power."

796,xurkitree,1,6,45,0,120,1,414,Glowing,"Although its alien to this world and a danger here, its apparently a common organism in the world where it normally lives."

797,celesteela,5,12,45,0,120,1,415,Launch,"One of the dangerous UBs, high energy readings can be detected coming from both of its huge arms."

798,kartana,9,12,45,0,120,1,416,Drawn Sword,"Although its alien to this world and a danger here, its apparently a common organism in the world where it normally lives."

799,guzzlord,1,6,45,0,120,1,417,Junkivore,"Although its alien to this world and a danger here, its apparently a common organism in the world where it normally lives."

800,necrozma,1,4,255,0,120,1,418,Prism,"Light is apparently the source of its energy. It has an extraordinarily vicious disposition and is constantly firing off laser beams."

801,magearna,4,12,3,0,120,1,419,Artificial,"It synchronizes its consciousness with others to understand their feelings. This faculty makes it useful for taking care of people."

802,marshadow,4,12,3,0,120,1,420,Gloomdweller,"It sinks into the shadows of people and Pokemon, where it can understand their feelings and copy their capabilities."

803,poipole,7,6,45,0,120,1,421,Poison Pin,"This Ultra Beast is well enough liked to be chosen as a first partner in its own world."
804,naganadel,7,9,45,0,120,1,,Poison Pin,"It stores hundreds of liters of poisonous liquid inside its body. It is one of the organisms known as UBs."

805,stakataka,4,8,30,0,120,1,,Rampart,"It appeared from an Ultra Wormhole. Each one appears to be made up of many life-forms stacked one on top of each other."

806,blacephalon,9,12,30,0,120,1,,Fireworks,"It slithers toward people. Then, without warning, it triggers the explosion of its own head. It’s apparently one kind of Ultra Beast."

807,zeraora,10,12,3,0,120,1,,Thunderclap,"It electrifies its claws and tears its opponents apart with them. Even if they dodge its attack, they’ll be electrocuted by the flying sparks."

808,meltan,4,1,3,0,120,1,422,Hex Nut,"It melts particles of iron and other metals found in the subsoil, so it can absorb them into its body of molten steel."
809,melmetal,4,1,3,0,120,1,,Hex Nut,"At the end of its life-span, Melmetal will rust and fall apart. The small shards left behind will eventually be reborn as Meltan."

810,grookey,5,6,45,50,20,4,432,Chimp,"When it uses its special stick to strike up a beat, the sound waves produced carry revitalizing energy to the plants and flowers in the area."
811,thwackey,5,6,45,50,20,4,,Beat,"The faster a Thwackey can beat out a rhythm with its two sticks, the more respect it wins from its peers."
812,rillaboom,5,12,45,50,20,4,,Drummer,"By drumming, it taps into the power of its special tree stump. The roots of the stump follow its direction in battle."
813,scorbunny,9,6,45,50,20,4,433,Rabbit,"A warm-up of running around gets fire energy coursing through this Pokemon's body. Once that happens, it's ready to fight at full power."
814,raboot,4,6,45,50,20,4,,Rabbit,"Its thick and fluffy fur protects it from the cold and enables it to use hotter fire moves."
815,cinderace,9,6,45,50,20,4,,Striker,"It juggles a pebble with its feet, turning it into a burning soccer ball. Its shots strike opponents hard and leave them scorched."
816,sobble,2,8,45,50,20,4,434,Water Lizard,"When scared, this Pokemon cries. Its tears pack the chemical punch of 100 onions, and attackers won't be able to resist weeping."
817,drizzile,2,6,45,50,20,4,,Water Lizard,"A clever combatant, this Pokemon battles using water balloons created with moisture secreted from its palms."
818,inteleon,2,6,45,50,20,4,,Secret Agent,"It has many hidden capabilities, such as fingertips that can shoot water and a membrane on its back that it can use to glide through the air."
819,skwovet,3,6,255,50,20,2,435,Cheeky,"Found throughout the Galar region, this Pokemon becomes uneasy if its cheeks are ever completely empty of berries."
820,greedent,3,6,255,50,20,2,,Greedy,"Common throughout the Galar region, this Pokemon has strong teeth and can chew through the toughest of berry shells."
821,rookidee,2,9,255,50,15,4,436,Tiny Bird,"It will bravely challenge any opponent, no matter how powerful. This Pokemon benefits from every battleóeven a defeat increases its strength a bit."
822,corvisquire,2,9,120,50,15,4,,Raven,"The lessons of many harsh battles have taught it how to accurately judge an opponent's strength."
823,corviknight,7,9,45,50,15,4,,Raven,"With their great intellect and flying skills, these Pokemon very successfully act as the Galar region's airborne taxi service."
824,blipbug,2,14,255,50,15,3,437,Larva,"A constant collector of information, this Pokemon is very smart. Very strong is what it isn't."
825,dottler,10,14,120,50,15,3,,Radome,"It barely moves, but it's still alive. Hiding in its shell without food or water seems to have awakened its psychic powers."
826,orbeetle,8,14,45,50,15,3,,Seven Spot,"It emits psychic energy to observe and study what's around itóand what's around it can include things over six miles away."
827,nickit,3,8,255,50,15,3,438,Fox,"Aided by the soft pads on its feet, it silently raids the food stores of other Pokemon. It survives off its ill-gotten gains."
828,thievul,3,8,127,50,15,3,,Greedy,"Common throughout the Galar region, this Pokemon has strong teeth and can chew through the toughest of berry shells."
829,gossifleur,5,5,190,50,20,2,439,Flowering,"It whirls around in the wind while singing a joyous song. This delightful display has charmed many into raising this Pokemon."
830,eldegoss,5,5,75,50,20,2,,Cotton Bloom,"The cotton on the head of this Pokemon can be spun into a glossy, gorgeous yarnóa Galar regional specialty."
831,wooloo,,,255,50,15,2,440,Sheep,"If its fleece grows too long, Wooloo won't be able to move. Cloth made with the wool of this Pokemon is surprisingly strong."
832,dubwool,,,127,50,15,2,,Sheep,"Its majestic horns are meant only to impress the opposite gender. They never see use in battle."
833,chewtle,,,255,50,20,2,441,Snapping,"Apparently the itch of its teething impels it to snap its jaws at anything in front of it."
834,drednaw,,,75,50,20,2,,Snapping,"With jaws that can shear through steel rods, this highly aggressive Pokemon chomps down on its unfortunate prey."
835,yamper,,,255,50,20,4,442,Puppy,"This Pokemon is very popular as a herding dog in the Galar region. As it runs, it generates electricity from the base of its tail."
836,boltund,,,45,50,20,4,,Dog,"It sends electricity through its legs to boost their strength. Running at top speed, it easily breaks 50 mph."
837,rolycoly,,,255,50,15,4,443,Coal,"It can race around like a unicycle, even on rough, rocky terrain. Burning coal sustains it."
838,carkol,,,120,50,15,4,,Coal,"It forms coal inside its body. Coal dropped by this Pokemon once helped fuel the lives of people in the Galar region."
839,coalossal,,,45,50,15,4,,Coal,"	While it's engaged in battle, its mountain of coal will burn bright red, sending off sparks that scorch the surrounding area."
840,applin,,,255,50,20,5,444,Apple Core,"It spends its entire life inside an apple. It hides from its natural enemies, bird Pokemon, by pretending it's just an apple and nothing more."
841,flapple,,,45,50,20,5,,Apple Wing,"It flies on wings of apple skin and spits a powerful acid. It can also change its shape into that of an apple."
842,appletun,,,45,50,20,5,,Apple Nectar,"Its body is covered in sweet nectar, and the skin on its back is especially yummy. Children used to have it as a snack."
843,silicobra,,,255,50,20,2,445,Sand Snake,"It spews sand from its nostrils. While the enemy is blinded, it burrows into the ground to hide."
844,sandaconda,,,120,50,20,2,,Sand Snake,"Its unique style of coiling allows it to blast sand out of its sand sac more efficiently."
845,cramorant,,,45,50,20,2,446,Gulp,"It's so strong that it can knock out some opponents in a single hit, but it also may forget what it's battling midfight."
846,arrokuda,,,255,50,20,1,447,Rush,"After it's eaten its fill, its movements become extremely sluggish. That's when Cramorant swallows it up."
847,barraskewda,,,60,50,20,1,,Skewer,"It spins its tail fins to propel itself, surging forward at speeds of over 100 knots before ramming prey and spearing into them."
848,toxel,,,75,50,25,4,448,Baby,"It manipulates the chemical makeup of its poison to produce electricity. The voltage is weak, but it can cause a tingling paralysis."
849,toxtricity,,,45,50,25,4,,Punk,"Capable of generating 15,000 volts of electricity, this Pokemon looks down on all that would challenge it."
850,sizzlipede,,,190,50,20,2,449,Radiator,"It stores flammable gas in its body and uses it to generate heat. The yellow sections on its belly get particularly hot."
851,centiskorch,,,75,50,20,2,,Radiator,"When it heats up, its body temperature reaches about 1,500 degrees Fahrenheit. It lashes its body like a whip and launches itself at enemies."
852,clobbopus,,,180,50,25,4,450,Tantrum,"It's very curious, but its means of investigating things is to try to punch them with its tentacles. The search for food is what brings it onto land."
853,grapploct,,,45,50,20,4,,Tantrum,"Searching for an opponent to test its skills against, it emerges onto land. Once the battle is over, it returns to the sea."
854,sinistea,,,120,50,20,2,451,Black Tea,"The swirl pattern in this Pokemon's body is its weakness. If it gets stirred, the swirl loses its shape, and Sinistea gets dizzy."
855,polteageist,,,60,50,20,2,,Black Tea,"When angered, it launches tea from its body at the offender's mouth. The tea causes strong chills if swallowed."
856,hatenna,,,235,50,20,1,452,Calm,"Via the protrusion on its head, it senses other creatures' emotions. If you don't have a calm disposition, it will never warm up to you."
857,hattrem,,,120,50,20,1,,Serene,"Using the braids on its head, it pummels foes to get them to quiet down. One blow from those braids would knock out a professional boxer."
858,hatterene,,,45,50,20,1,,Silent,"It emits psychic power strong enough to cause headaches as a deterrent to the approach of others."
859,impidimp,,,255,50,20,2,453,Wily,"It sneaks into people's homes, stealing things and feasting on the negative energy of the frustrated occupants."
860,morgrem,,,120,50,20,2,,Devious,"With sly cunning, it tries to lure people into the woods. Some believe it to have the power to make crops grow."
861,grimmsnarl,,,120,50,20,2,,Bulk Up,"With the hair wrapped around its body helping to enhance its muscles, this Pokemon can overwhelm even Machamp."
862,obstagoon,,,45,50,15,2,,Blocking,"It evolved after experiencing numerous fights. While crossing its arms, it lets out a shout that would make any opponent flinch."
863,perrserker,,,90,50,20,2,,Viking,"After many battles, it evolved dangerous claws that come together to form daggers when extended."
864,cursola,,,30,50,20,3,,Viking,"Be cautious of the ectoplasmic body surrounding its soul. You'll become stiff as stone if you touch it."
865,sirfetchd,,,45,50,20,2,,Wild Duck,"After deflecting attacks with its hard leaf shield, it strikes back with its sharp leek stalk. The leek stalk is both weapon and food."
866,mrrime,,,45,50,20,2,,Comedian,"It's highly skilled at tap-dancing. It waves its cane of ice in time with its graceful movements."
867,runerigus,,,90,50,25,2,,Grudge,"Never touch its shadowlike body, or you'll be shown the horrific memories behind the picture carved into it."
868,milcery,,,200,50,20,2,454,Cream,"They say that any patisserie visited by Milcery is guaranteed success and good fortune."
869,alcremie,,,100,50,20,2,,Cream,"The cells that compose its cream fluctuated suddenly during evolution, giving the cream a bitter flavor."
870,falinks,,,45,50,25,2,455,Formation,"Five of them are troopers, and one is the brass. The brass's orders are absolute."
871,pincurchin,,,75,50,20,2,456,Sea Urchin,"It feeds on seaweed, using its teeth to scrape it off rocks. Electric current flows from the tips of its spines."
872,snom,,,190,50,20,2,457,Worm,"It eats snow that piles up on the ground. The more snow it eats, the bigger and more impressive the spikes on its back grow."
873,frosmoth,,,75,50,20,2,,Frost Moth,"It shows no mercy to any who desecrate fields and mountains. It will fly around on its icy wings, causing a blizzard to chase offenders away."
874,stonjourner,,,60,50,20,1,458,Big Rock,"Once a year, on a specific date and at a specific time, they gather out of nowhere and form up in a circle."
875,eiscue,,,60,50,25,1,459,Penguin,"It drifted in on the flow of ocean waters from a frigid place. It keeps its head iced constantly to make sure it stays nice and cold."
876,indeedee,,,30,50,40,3,460,Emotion,"It uses the horns on its head to sense the emotions of others. Males will act as valets for those they serve, looking after their every need."
877,morpeko,,,180,50,10,2,461,Two-Sided,"As it eats the seeds stored up in its pocket-like pouches, this Pokemon is not just satisfying its constant hunger. It's also generating electricity."
878,cufant,,,190,50,25,2,462,Copperderm,"It digs up the ground with its trunk. It's also very strong, being able to carry loads of over five tons without any problem at all."
879,copperajah,,,90,50,25,2,,Copperderm,"They came over from another region long ago and worked together with humans. Their green skin is resistant to water."
880,dracozolt,,,45,50,35,1,463,Fossil,"In ancient times, it was unbeatable thanks to its powerful lower body, but it went extinct anyway after it depleted all its plant-based food sources."
881,arctozolt,,,45,50,35,1,464,Fossil,"The shaking of its freezing upper half is what generates its electricity. It has a hard time walking around."
882,dracovish,,,45,50,35,1,465,Fossil,"Powerful legs and jaws made it the apex predator of its time. Its own overhunting of its prey was what drove it to extinction."
883,arctovish,,,45,50,35,1,466,Fossil,"The skin on its face is impervious to attack, but breathing difficulties made this Pokemon go extinct anyway."
884,duraludon,,,45,50,30,2,467,Alloy,"Its body resembles polished metal, and it's both lightweight and strong. The only drawback is that it rusts easily."
885,dreepy,,,45,50,40,1,468,Lingering,"After being reborn as a ghost Pokemon, Dreepy wanders the areas it used to inhabit back when it was alive in prehistoric seas."
886,drakloak,,,45,50,40,1,,Caretaker,"It's capable of flying faster than 120 mph. It battles alongside Dreepy and dotes on them until they successfully evolve."
887,dragapult,,,45,50,40,1,,Stealth,"When it isn't battling, it keeps Dreepy in the holes on its horns. Once a fight starts, it launches the Dreepy like supersonic missiles."
888,zacian,,,10,0,35,1,469,Warrior,"Able to cut down anything with a single strike, it became known as the Fairy King's Sword, and it inspired awe in friend and foe alike."
889,zamazenta,,,10,0,35,1,470,Warrior,"Its ability to deflect any attack led to it being known as the Fighting Master's Shield. It was feared and respected by all."
890,eternatus,,,255,0,120,1,471,Gigantic,"The core on its chest absorbs energy emanating from the lands of the Galar region. This energy is what allows Eternatus to stay active."
891,kubfu,,,3,50,120,1,472,Wushu,"Kubfu trains hard to perfect its moves. The moves it masters will determine which form it takes when it evolves."
892,urshifu,,,3,50,120,1,,Wushu,"This form of Urshifu is a strong believer in the one-hit KO. Its strategy is to leap in close to foes and land a devastating blow with a hardened fist."
893,zarude,,,3,0,120,1,473,Rogue Monkey,"Once the vines on Zarude's body tear off, they become nutrients in the soil. This helps the plants of the forest grow."
894,regieleki,,,3,35,120,1,474,Electron,"Its entire body is made up of a single organ that generates electrical energy. Regieleki is capable of creating all Galaris electricity."
895,regidrago,,,3,35,120,1,475,Dragon Orb,"An academic theory proposes that Regidrago's arms were once the head of an ancient dragon Pokemon. The theory remains unproven."
896,glastrier,,,3,35,120,1,476,Wild Horse,"Glastrier has tremendous physical strength, and the mask of ice covering its face is 100 times harder than diamond."
897,spectrier,,,3,35,120,1,477,Swift Horse,"As it dashes through the night, Spectrier absorbs the life-force of sleeping creatures. It craves silence and solitude."
898,calyrex,,,3,100,120,1,478,King,"Calyrex is known in legend as a king that ruled over Galar in ancient times. It has the power to cause hearts to mend and plants to spring forth."


899,wyrdeer,,,45,50,20,1,,Big Horn,"The black orbs shine with an uncanny light when the Pokemon is erecting invisible barriers. The fur shed from its beard retains heat well and is a highly useful material for winter clothing."
900,kleavor,,,45,50,20,2,,Axe,"A violent creature that fells towering trees with its crude axes and shields itself with hard stone. If one should chance upon this Pokemon in the wilds, one's only recourse is to flee."
901,ursaluna,,,6,50,70,2,,Peat,"I believe it was Hisui's swampy terrain that gave Ursaluna its burly physique and newfound capacity to manipulate peat at will."
902,basculegion,,,50,70,20,2,,Big Fish,"Clads itself in the souls of comrades that perished before fulfilling their goals of journeying upstream. No other species throughout all Hisui's rivers is Basculegion's equal."
903,sneasler,,,60,50,20,4,,Free Climb,"Because of Sneasler's virulent poison and daunting physical prowess, no other species could hope to best it on the frozen highlands. Preferring solitude, this species does not form packs."
904,overqwil,,,45,50,20,2,,Pin Cluster,Its lancelike spikes and savage temperament have earned it the nickname 'sea fiend.' It slurps up poison to nourish itself.
905,enamorus,,,3,50,120,1,497,Love-Hate,"When it flies to this land from across the sea, the bitter winter comes to an end. According to legend, this Pokemon's love gives rise to the budding of fresh life across Hisui."


906,sprigatito,,,45,50,20,4,503,Grass Cat,"Its fluffy fur is similar in composition to plants. This Pokemon frequently washes its face to keep it from drying out."
907,floragato,,,45,50,20,4,,Grass Cat,"Floragato deftly wields the vine hidden beneath its long fur, slamming the hard flower bud against its opponents."
908,meowscarada,,,45,50,20,4,,Magician,"This Pokemon uses the reflective fur lining its cape to camouflage the stem of its flower, creating the illusion that the flower is floating."
909,fuecoco,,,45,50,20,4,504,Fire Croc,"It lies on warm rocks and uses the heat absorbed by its square-shaped scales to create fire energy."
910,crocalor,,,45,50,20,4,,Fire Croc,"The combination of Crocalor's fire energy and overflowing vitality has caused an egg-shaped fireball to appear on the Pokemon's head."
911,skeledirge,,,45,50,20,4,,Singer,"The fiery bird changes shape when Skeledirge sings. Rumor has it that the bird was born when the fireball on Skeledirge's head gained a soul."
912,quaxly,,,45,50,20,4,505,Duckling,"This Pokemon migrated to Paldea from distant lands long ago. The gel secreted by its feathers repels water and grime."
913,quaxwell,,,45,50,20,4,,Practicing,"These Pokemon constantly run through shallow waters to train their legs, then compete with each other to see which of them kicks most gracefully."
914,quaquaval,,,45,50,20,4,,Dancer,"A single kick from a Quaquaval can send a truck rolling. This Pokemon uses its powerful legs to perform striking dances from far-off lands."
915,lechonk,,,255,50,15,2,506,Hog,"It searches for food all day. It possesses a keen sense of smell but doesn't use it for anything other than foraging."
916,oinkologne,,,100,50,15,2,,Hog,"Oinkologne is proud of its fine, glossy skin. It emits a concentrated scent from the tip of its tail."
917,tarountula,,,255,50,15,5,507,String Ball,"The ball of threads wrapped around its body is elastic enough to deflect the scythes of Scyther, this Pokemon's natural enemy."
918,spidops,,,120,50,15,5,,Trap,"It clings to branches and ceilings using its threads and moves without a sound. It takes out its prey before the prey even notices it."
919,nymble,,,190,20,20,2,508,Grasshopper,"It has its third set of legs folded up. When it's in a tough spot, this Pokemon jumps over 30 feet using the strength of its legs."
920,lokix,,,30,0,20,2,,Grasshopper,"When it decides to fight all out, it stands on its previously folded legs to enter Showdown Mode. It neutralizes its enemies in short order."
921,pawmi,,,190,50,15,2,509,Mouse,"It has underdeveloped electric sacs on its cheeks. These sacs can produce electricity only if Pawmi rubs them furiously with the pads on its forepaws."
922,pawmo,,,80,50,15,2,,Mouse,"When its group is attacked, Pawmo is the first to leap into battle, defeating enemies with a fighting technique that utilizes electric shocks."
923,pawmot,,,45,50,15,2,,Hands-On,"This Pokemon normally is slow to react, but once it enters battle, it will strike down its enemies with lightning-fast movements."
924,tandemaus,,,150,50,10,3,510,Couple,"Exhibiting great teamwork, they use their incisors to cut pieces out of any material that might be useful for a nest, then make off with them."
925,maushold,,,75,50,10,3,,Family,"The two little ones just appeared one day. The group might be a family of related Pokemon, but nobody knows for sure."
926,fidough,,,190,50,20,4,511,Puppy,"This Pokemon is smooth and moist to the touch. Yeast in Fidough's breath induces fermentation in the Pokemon's vicinity."
927,dachsbun,,,90,50,20,4,,Dog,"The pleasant aroma that emanates from this Pokemon's body helps wheat grow, so Dachsbun has been treasured by farming villages."
928,smoliv,,,255,50,20,4,512,Olive,"It protects itself from enemies by emitting oil from the fruit on its head. This oil is bitter and astringent enough to make someone flinch."
929,dolliv,,,120,50,20,4,,Olive,"Dolliv shares its tasty, fresh-scented oil with others. This species has coexisted with humans since times long gone."
930,arboliva,,,45,50,20,4,,Olive,"This calm Pokemon is very compassionate. It will share its delicious, nutrient-rich oil with weakened Pokemon."
931,squawkabilly,,,190,50,15,5,513,Parrot,"These Pokemon prefer to live in cities. They form flocks based on the color of their feathers, and they fight over territory."
932,nacli,,,255,50,20,4,514,Rock Salt,"It was born in a layer of rock salt deep under the earth. This species was particularly treasured in the old days, as they would share precious salt."
933,naclstack,,,120,50,20,4,,Rock Salt,"This Pokemon dry cures its prey by spraying salt over them. The curing process steals away the water in the prey's body."
934,garganacl,,,45,50,20,4,,Rock Salt,"Garganacl will rub its fingertips together and sprinkle injured Pokemon with salt. Even severe wounds will promptly heal afterward."
935,charcadet,,,90,50,35,1,515,Fire Child,"Burnt charcoal came to life and became a Pokemon. Possessing a fiery fighting spirit, Charcadet will battle even tough opponents."
936,armarouge,,,25,20,35,1,,Fire Warrior,"Armarouge evolved through the use of a set of armor that belonged to a distinguished warrior. This Pokemon is incredibly loyal."
937,ceruledge,,,25,20,35,1,,Fire Blades,"The fiery blades on its arms burn fiercely with the lingering resentment of a sword wielder who fell before accomplishing their goal."
938,tadbulb,,,190,50,20,2,516,EleTadpole,"Tadbulb shakes its tail to generate electricity. If it senses danger, it will make its head blink on and off to alert its allies."
939,bellibolt,,,50,50,20,2,,EleFrog,"When this Pokemon expands and contracts its wobbly body, the belly-button dynamo in its stomach produces a huge amount of electricity."
940,wattrel,,,180,50,20,4,517,Storm Petrel,"When its wings catch the wind, the bones within produce electricity. This Pokemon dives into the ocean, catching prey by electrocuting them."
941,kilowattrel,,,90,50,20,4,,Frigatebird,"Kilowattrel inflates its throat sac to amplify its electricity. By riding the wind, this Pokemon can fly over 430 miles in a day."
942,maschiff,,,150,50,20,4,518,Rascal,"It always scowls in an attempt to make opponents take it seriously, but even crying children will burst into laughter when they see Maschiff's face."
943,mabosstiff,,,75,50,20,4,,Boss,"This Pokemon can store energy in its large dewlap. Mabosstiff unleashes this energy all at once to blow away enemies."
944,shroodle,,,190,50,20 ,4,519,Toxic Mouse,"Though usually a mellow Pokemon, it will sink its sharp, poison-soaked front teeth into any that anger it, causing paralysis in the object of its ire."
945,grafaiai,,,90,50,20,4,,Toxic Monkey,"The color of the poisonous saliva depends on what the Pokemon eats. Grafaiai covers its fingers in its saliva and draws patterns on trees in forests."
946,bramblin,,,190,50,20,2,520,Tumbleweed,"A soul unable to move on to the afterlife was blown around by the wind until it got tangled up with dried grass and became a Pokemon."
947,brambleghast,,,45,50,20,2,,Tumbleweed,"It will open the branches of its head to envelop its prey. Once it absorbs all the life energy it needs, it expels the prey and discards it."
948,toedscool,,,190,50,20,4,521,Woodear,"Toedscool lives in muggy forests. The flaps that fall from its body are chewy and very delicious."
949,toedscruel,,,90,50,20,4,,Woodear,"These Pokemon gather into groups and form colonies deep within forests. They absolutely hate it when strangers approach."
950,klawf,,,120,50,35,2,522,Ambush,"Klawf hangs upside-down from cliffs, waiting for prey. But Klawf can't remain in this position for long because its blood rushes to its head."
951,capsakid,,,190,50,20,2,523,Spicy Pepper,"The more sunlight this Pokemon bathes in, the more spicy chemicals are produced by its body, and thus the spicier its moves become."
952,scovillain,,,75,50,20,2,,Spicy Pepper,"The red head converts spicy chemicals into fire energy and blasts the surrounding area with a super spicy stream of flame."
953,rellor,,,190,50,20,3,524,Rolling,"This Pokemon creates a mud ball by mixing sand and dirt with psychic energy. It treasures its mud ball more than its own life."
954,rabsca,,,45,50,20,3,,Rolling,"The body that supports the ball barely moves. Therefore, it is thought that the true body of this Pokemon is actually inside the ball."
955,flittle,,,120,50,20,4,525,Frill,"Flittle's toes levitate about half an inch above the ground because of the psychic power emitted from the frills on the Pokemon's belly."
956,espathra,,,60,50,20,4,,Ostrich,"It immobilizes opponents by bathing them in psychic power from its large eyes. Despite its appearance, it has a vicious temperament."
957,tinkatink,,,190,50,20,4,526,Metalsmith,"It swings its handmade hammer around to protect itself, but the hammer is often stolen by Pokemon that eat metal."
958,tinkatuff,,,90,50,20,4,,Hammer,"This Pokemon will attack groups of Pawniard and Bisharp, gathering metal from them in order to create a large and sturdy hammer."
959,tinkaton,,,45,50,20,4,,Hammer,"This intelligent Pokemon has a very daring disposition. It knocks rocks into the sky with its hammer, aiming for flying Corviknight."
960,wiglett,,,255,50,20,2,527,Garden Eel,"This Pokemon can pick up the scent of a Veluza just over 65 feet away and will hide itself in the sand."
961,wugtrio,,,50,50,20,2,,Garden Eel,"It has a vicious temperament, contrary to what its appearance may suggest. It wraps its long bodies around prey, then drags the prey into its den."
962,bombirdier,,,25,50,35,1,528,Item Drop,"It gathers things up in an apron made from shed feathers added to the Pokemon's chest feathers, then drops those things from high places for fun."
963,finizen,,,200,50,40,1,529,Dolphin,"It likes playing with others of its kind using the water ring on its tail. It uses ultrasonic waves to sense the emotions of other living creatures."
964,palafin,,,45,50,40,1,,Dolphin,"This Pokemon changes its appearance if it hears its allies calling for help. Palafin will never show anybody its moment of transformation."
965,varoom,,,190,50,20,2,530,Single-Cyl,"It is said that this Pokemon was born when an unknown poison Pokemon entered and inspirited an engine left at a scrap-processing factory."
966,revavroom,,,75,50,20,2,,Multi-Cyl,"It creates a gas out of poison and minerals from rocks. It then detonates the gas in its cylinders—now numbering eight—to generate energy."
967,cyclizar,,,190,50,30,4,531,Mount,"Apparently Cyclizar has been allowing people to ride on its back since ancient times. Depictions of this have been found in 10,000-year-old murals."
968,orthworm,,,25,50,35,1,532,Earthworm,"When attacked, this Pokemon will wield the tendrils on its body like fists and pelt the opponent with a storm of punches."
969,glimmet,,,70,50,30,4,533,Ore,"It absorbs nutrients from cave walls. The petals it wears are made of crystallized poison."
970,glimmora,,,25,50,30,4,,Ore,"When this Pokemon detects danger, it will open up its crystalline petals and fire beams from its conical body."
971,greavard,,,120,50,20,4,534,Ghost Dog,"It is said that a dog Pokemon that died in the wild without ever interacting with a human was reborn as this Pokemon."
972,houndstone,,,60,50,20,4,,Ghost Dog,"Houndstone spends most of its time sleeping in graveyards. Among all the dog Pokemon, this one is most loyal to its master."
973,flamigo,,,100,50,20,4,535,Synchronize,"This Pokemon apparently ties the base of its neck into a knot so that energy stored in its belly does not escape from its beak."
974,cetoddle,,,150,50,25,4,536,Terra Whale,"This species left the ocean and began living on land a very long time ago. It seems to be closely related to Wailmer."
975,cetitan,,,50,50,25,4,,Terra Whale,"This Pokemon wanders around snowy, icy areas. It protects its body with powerful muscles and a thick layer of fat under its skin."
976,veluza,,,100,50,20,3,537,Jettison,"When Veluza discards unnecessary flesh, its mind becomes honed and its psychic power increases. The spare flesh has a mild but delicious flavor."
977,dondozo,,,25,50,40,1,538,Big Catfish,"This Pokemon is a glutton, but it's bad at getting food. It teams up with a Tatsugiri to catch prey."
978,tatsugiri,,,100,50,35,4,539,Mimicry,"This is a small dragon Pokemon. It lives inside the mouth of Dondozo to protect itself from enemies on the outside."
979,annihilape,,,45,50,20,2,,Rage Monkey,"When its anger rose beyond a critical point, this Pokemon gained power that is unfettered by the limits of its physical body."
980,clodsire,,,90,50,20,2,,Spiny Fish,"When attacked, this Pokemon will retaliate by sticking thick spines out from its body. It's a risky move that puts everything on the line."
981,farigiraf,,,45,50,20,2,,Long Neck,"Now that the brain waves from the head and tail are synced up, the psychic power of this Pokemon is 10 times stronger than Girafarig's."
982,dudunsparce,,,45,50,20,2,,Land Snake,"This Pokemon uses its hard tail to make its nest by boring holes into bedrock deep underground. The nest can reach lengths of over six miles."
983,kingambit,,,25,50,20,2,,Big Blade,"Only a Bisharp that stands above all others in its vast army can evolve into Kingambit."
984,greattusk,,,30,0,50,1,540,Paradox,"Sightings of this Pokemon have occurred in recent years. The name Great Tusk was taken from a creature listed in a certain book."
985,screamtail,,,50,0,50,1,541,Paradox,"There has been only one reported sighting of this Pokemon. It resembles a mysterious creature depicted in an old expedition journal."
986,brutebonnet,,,50,0,50,1,542,Paradox,"It is possible that the creature listed as Brute Bonnet in a certain book could actually be this Pokemon."
987,fluttermane,,,30,0,50,1,543,Paradox,"This Pokemon has characteristics similar to those of Flutter Mane, a creature mentioned in a certain book."
988,slitherwing,,,30,0,50,1,544,Paradox,"This mysterious Pokemon has some similarities to a creature that an old book introduced as Slither Wing."
989,sandyshocks,,,30,0,50,1,545,Paradox,"No records exist of this Pokemon being caught. Data is lacking, but the Pokemon's traits match up with a creature shown in an expedition journal."
990,irontreads,,,30,0,50,1,546,Paradox,"This Pokemon closely resembles a scientific weapon that a paranormal magazine claimed was sent to this planet by aliens."
991,ironbundle,,,50,0,50,1,547,Paradox,"Its shape is similar to a robot featured in a paranormal magazine article. The robot was said to have been created by an ancient civilization."
992,ironhands,,,50,0,50,1,548,Paradox,"It is very similar to a cyborg covered exclusively by a paranormal magazine. The cyborg was said to be the modified form of a certain athlete."
993,ironjugulis,,,30,0,50,1,549,Paradox,"It resembles a certain Pokemon introduced in a paranormal magazine, described as the offspring of a Hydreigon that fell in love with a robot."
994,ironmoth,,,30,0,50,1,550,Paradox,"This Pokemon resembles an unknown object described in a paranormal magazine as a UFO sent to observe humanity."
995,ironthorns,,,30,0,50,1,551,Paradox,"It has some similarities to a Pokemon introduced in a dubious magazine as a Tyranitar from one billion years into the future."
996,frigibax,,,45,50,40,1,552,Ice Fin,"Frigibax absorbs heat through its dorsal fin and converts the heat into ice energy. The higher the temperature, the more energy Frigibax stores."
997,arctibax,,,25,50,40,1,,Ice Fin,"Arctibax freezes the air around it, protecting its face with an ice mask and turning its dorsal fin into a blade of ice."
998,baxcalibur,,,10,50,40,1,,Ice Dragon,"This Pokemon blasts cryogenic air out from its mouth. This air can instantly freeze even liquid-hot lava."
999,gimmighoul,,,45,50,50,1,553,Coin Chest,"This Pokemon was born inside a treasure chest about 1,500 years ago. It sucks the life-force out of scoundrels who try to steal the treasure."
1000,gholdengo,,,45,50,50,1,,Coin Entity,"Its body seems to be made up of 1,000 coins. This Pokemon gets along well with others and is quick to make friends with anybody."
1001,wochien,,,6,0,50,1,554,Ruinous,"The grudge of a person punished for writing the king's evil deeds upon wooden tablets has clad itself in dead leaves to become a Pokemon."
1002,chienpao,,,6,0,50,1,555,Ruinous,"This Pokemon can control 100 tons of fallen snow. It plays around innocently by leaping in and out of avalanches it has caused."
1003,tinglu,,,6,0,50,1,556,Ruinous,"The fear poured into an ancient ritual vessel has clad itself in rocks and dirt to become a Pokemon."
1004,chiyu,,,6,0,50,1,557,Ruinous,"It controls flames burning at over 5,400 degrees Fahrenheit. It casually swims through the sea of lava it creates by melting rock and sand."
1005,roaringmoon,,,10,0,50,1,558,Paradox,"It is possible that this is the creature listed as Roaring Moon in an expedition journal that still holds many mysteries."
1006,ironvaliant,,,10,0,50,1,559,Paradox,"It has some similarities to a mad scientist's invention covered in a paranormal magazine."
1007,koraidon,,,3,0,50,1,560,Paradox,"This seems to be the Winged King mentioned in an old expedition journal. It was said to have split the land with its bare fists."
1008,miraidon,,,3,0,50,1,561,Paradox,"Much remains unknown about this creature. It resembles Cyclizar, but it is far more ruthless and powerful."
1009,walkingwake,,,5,0,50,2,562,Paradox,"Ecology under research..."
1010,ironleaves,,,5,0,50,2,563,Paradox,"Ecology under analysis..."
1011,dipplin,,,45,50,20,5,564,Candy Apple,"Dipplin is two creatures in one Pokemon. Its evolution was triggered by a special apple grown only in one place."
1012,poltchageist,,,120,50,20,2,565,Matcha,"Supposedly, the regrets of a tea ceremony master who died before perfecting his craft lingered in some matcha and became a Pokemon."
1013,sinistcha,,,60,50,20,2,,Matcha,"It pretends to be tea, trying to fool people into drinking it so it can drain their life-force. Its ruse is generally unsuccessful."
1014,okidogi,,,3,0,120,1,566,Retainer,"After all its muscles were stimulated by the toxic chain around its neck, Okidogi transformed and gained a powerful physique."
1015,munkidori,,,3,0,120,1,567,Retainer,"The chain is made from toxins that enhance capabilities. It stimulated Munkidori's brain and caused the Pokémon's psychic powers to bloom."
1016,fezandipiti,,,3,0,120,1,568,Retainer,"Fezandipiti owes its beautiful looks and lovely voice to the toxic stimulants emanating from the chain wrapped around its body."
1017,ogerpon,,,5,50,10,1,569,Mask,"This Pokemon's type changes based on which mask it's wearing. It confounds its enemies with nimble movements and kicks."
1018,archaludon,,,10,0,0,2,570,Alloy,"It gathers static electricity from its surroundings. The beams it launches when down on all fours are tremendously powerful."
1019,hydrapple,,,10,0,20,5,,Apple Hydra,"Seven syrpents live inside an apple made of syrup. The syrpent in the center is the commander."
1020,gougingfire,,,10,0,0,1,571,Paradox,"There are scant few reports of this creature being sighted. One short video shows it rampaging and spouting pillars of flame."
1021,ragingbolt,,,10,0,0,1,572,Paradox,"It's said to incinerate everything around it with lightning launched from its fur. Very little is known about this creature."
1022,ironboulder,,,10,0,0,1,573,Paradox,"It was named after a mysterious object recorded in an old book. Its body seems to be metallic."
1023,ironcrown,,,10,0,0,1,574,Paradox,"There was supposedly an incident in which it launched shining blades to cut everything around it to pieces. Little else is known about it."
1024,terapagos,,,255,0,0,1,575,Tera,"Terapagos protects itself using its power to transform energy into hard crystals. This Pokémon is the source of the Terastal phenomenon."
1025,pecharunt,,,3,0,0,1,576,Subjugation,"It feeds others toxic mochi that draw out desires and capabilities. Those who eat the mochi fall under Pecharunt's control, chained to its will."



]])