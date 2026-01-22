print("Trainers")

-- todo: support simpler moveset structures (simple tables of strings)
-- todo: some battles need to check certain "RequiredEvents" completion as verification

local eyesMeet1 = {9536637771, 9543891464}
local eyesMeet2 = {9536638665, 9543891992}
local eyesMeet3 = {9536658310, 9543892639}
local eyesMeet4 = {748437856}
local eyesMeet5 = {190423831, 190423831}
local eyesMeet6 = {876956901}
local eyesMeet7 = {549159014}
local eyesMeet8 = {4452317890}
local eyesMeet9 = {1163589734}
local eyesMeet10 = {549159014}

return {
	TrainerClassData = {
		['Youngster'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 24,
			Difficulty = 1,
		},
		['Bug Catcher'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 24,
			Difficulty = 1,
		},
		['Camper'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 24,
			Difficulty = 1,
		},
		['Picnicker'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 24,
			Difficulty = 1,
		},
		['Lass'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 24,
			Difficulty = 1,
		},
		['Rookie'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 24,
			Difficulty = 1,
		},
		['Student'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 32,
			Difficulty = 1,
		},
		['Enthusiast'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 32,
			Difficulty = 1,
		},
		['Bouncer'] = {
			Gender = 'M',
			BasePayout = 32,
			Difficulty = 1,
		},
		['Rebellious Girl'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 32,
			Difficulty = 1,
		},
		['Hiker'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 32,
			Difficulty = 1,
		},
		['Black Belt'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 48,
			Difficulty = 2,
		},
		['Eclipse Grunt'] = {
			EyesMeetMusic = 9536675165,
			BasePayout = 40,
			Difficulty = 2,
		},
		['Pyro'] = {
			Gender = 'M',
			BasePayout = 48,
			Difficulty = 2,
		},
		['Cool Trainer'] = {
			EyesMeetMusic = eyesMeet2,
			Gender = 'M',
			BasePayout = 60,
			Difficulty = 2,
		},
		['Lady'] = {
			EyesMeetMusic = eyesMeet2,
			Gender = 'F',
			BasePayout = 60,
			Difficulty = 2,
		},
		['Rising Star'] = {
			EyesMeetMusic = eyesMeet2,
			Gender = 'M',
			BasePayout = 60,
			Difficulty = 2,
		},
		['Hipster'] = {
			EyesMeetMusic = eyesMeet2,
			Gender = 'M',
			BasePayout = 16,
			Difficulty = 2,
		},
		['Salesman'] = {
			EyesMeetMusic = eyesMeet3,
			Gender = 'M',
			BasePayout = 16,
			Difficulty = 2,
		},
		['Lumberjack'] = {
			EyesMeetMusic = eyesMeet3,
			Gender = 'M',
			BasePayout = 24,
			Difficulty = 2,
		},
		['Bird Keeper'] = {
			EyesMeetMusic = eyesMeet3,
			Gender = 'M',
			BasePayout = 40,
			Difficulty = 2,
		},
		['Schoolgirl'] = {
			EyesMeetMusic = eyesMeet1,
			Gender = 'F',
			BasePayout = 32,
			Difficulty = 2,
		},
		['Schoolboy'] = {
			EyesMeetMusic = eyesMeet1,
			Gender = 'M',
			BasePayout = 34,
			Difficulty = 2,
		},
		['Gentleman'] = {
			EyesMeetMusic = eyesMeet3,
			Gender = 'M',
			BasePayout = 72,
			Difficulty = 2,
		},
		['Artist'] = {
			EyesMeetMusic = eyesMeet3,
			Gender = 'M',
			BasePayout = 16,
			Difficulty = 2,
		},
		['Beach Bum'] = {
			EyesMeetMusic = eyesMeet2,
			Gender = 'M',
			BasePayout = 16,
			Difficulty = 3,
		},
		['Beach Babe'] = {
			EyesMeetMusic = eyesMeet2,
			Gender = 'F',
			BasePayout = 16,
			Difficulty = 3,
		},
		['Journalist'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet2,
			BasePayout = 24,
			Difficulty = 2,
		},
		['Adventurer'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 16,
			Difficulty = 2,
		},
		['Worker'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 24,
			Difficulty = 2,
		},
		['Collector'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Marshaller'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 24,
			Difficulty = 3,
		},
		['Scientist'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 72,
			Difficulty = 2,
		},
		['Punk Guy'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Survivalist'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Paleontologist'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Mountaineer'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 16,
			Difficulty = 3,
		},
		['Mountainer'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 16,
			Difficulty = 3,
		},
		['Miner'] = {
			EyesMeetMusic = eyesMeet3,
			Gender = 'M',
			BasePayout = 40,
			Difficulty = 3,
		},
		['Thief'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet2,
			BasePayout = 16,
			Difficulty = 2,
		},
		['Fisherman'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet3,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Swimmer[F]'] = {
			Gender = 'F',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Swimmer[M]'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 32,
			Difficulty = 2,
		},
		['Silhouette'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet1,
			BasePayout = 32,
			Difficulty = 2,
		},
		--CUSTOM VICTORY ROAD TRAINERS--
		['Veteran'] = {
			Gender = 'M',
			EyesMeetMusic = eyesMeet4,
			BasePayout = 32,
			Difficulty = 3,
		},
	},
	Battles = {
		{ -- [#  1] : Route 1 - Bug Catcher
			Name = 'Ralph',
			IntroPhrase = 'Bugs are the most interesting pokemon!',
			LosePhrase = 'OK so maybe my bugs aren\'t the best pokemon for battling...',
			Interact = 'Bugs are just one of many different types of pokemon!',
			Party = {
				{ name = 'Wurmple', level = 3 },
				{ name = 'Wurmple', level = 3 },
			},
		},
		{ -- [#  2] : Route 1 - Camper
			Name = 'Jack',
			IntroPhrase = 'I met my pokemon on this route.',
			LosePhrase = 'Maybe I should catch more pokemon...',
			Interact = 'It\'s probably best to keep multiple pokemon with you at a time.',
			RematchQuestion = 'I haven\'t caught any other pokemon yet, but I\'m down to battle again if you want to.',
			Party = {
				{ name = 'Zigzagoon', level = 4 },
			},
		},
		{ -- [#  3] : Route 1 - Picnicker
			Name = 'Susie',
			IntroPhrase = {'I just love pokemon!', 'They\'re so cute!'},
			LosePhrase = 'I need to train my pokemon more.',
			Interact = {'Battling with your pokemon makes them stronger.', 'Even the cute ones!'},
			Party = {
				{ name = 'Bunnelby', level = 3 },
				{ name = 'Pidgey', level = 3 },
			},
		},

		{ -- [#  4] : Gale Forest - Bug Catcher
			Name = 'Ricky',
			IntroPhrase = 'Let\'s see if you can get past my defenses!',
			LosePhrase = 'Maybe I should attack more...',
			Interact = 'Boosting a pokemon\'s defense allows it to take more hits from other pokemons\' attacks.',
			Party = {
				{ name = 'Kakuna', level = 6 },
				{ name = 'Metapod', level = 6 },
			},
		},
		{ -- [#  5] : Gale Forest - Student
			Name = 'Spencer',
			IntroPhrase = 'Did you know some pokemon only come out at night?',
			LosePhrase = 'Hoothoot was just sleepy.',
			Interact = 'There are also some pokemon that only come out during the day.',
			RematchQuestion = {'Say, I learned a lot the first time we battled.', 'Would you mind battling again?'},
			Party = {
				{ name = 'Hoothoot', level = 6 },
			},
		},
		{ -- [#  6] : Gale Forest - Camper
			Name = 'Steve',
			IntroPhrase = 'My Nidoran[M] and I are looking for a good challenge.',
			LosePhrase = 'We\'ll do better next time.',
			Interact = 'I\'m looking for additional pokemon to help me win battles.',
			RematchQuestion = {'Unfortunately I didn\'t bring any extra Pok[e\'] Balls.', 'Would you battle me again anyway?'},
			Party = {
				{ name = 'Nidoran[M]', level = 7 },
			},
		},
		{ -- [#  7] : Gale Forest - Picnicker
			Name = 'Lucy',
			IntroPhrase = 'It\'s so pleasant to see fellow trainers in the woods.',
			LosePhrase = 'That was rather disappointing.',
			Interact = 'Losing a battle just means I need to train more to be the best that I can.',
			Party = {
				{ name = 'Nidoran[F]', level = 7 },
			},
		},

		{ -- [#  8] : Route 2 - Lass
			Name = 'Jessie',
			IntroPhrase = 'Someday I hope to challenge the Champion of Roria!',
			LosePhrase = 'I\'m lightyears away from my goal right now.',
			Interact = 'I think it\'s every pokemon trainer\'s dream to battle the Roria League Champion.',
			RematchQuestion = {'I must keep training my pokemon!', 'Battle me again, please!'},
			Party = {
				{ name = 'Skitty', level = 7 },
			},
		},

		{ -- [#  9] : Gym 1 - Bouncer
			Name = 'David',
			IntroPhrase = {'I\'m gonna need to see some skills before letting you through.', 'Let\'s battle!'},
			LosePhrase = 'Looks like you\'re ok to go through.',
			Interact = {'Electric-type pokemon are only weak to one type.', 'Can you guess what it is?'},
			Party = {
				{ name = 'Electrike', level = 11 },
			},
		},
		{ -- [# 10] : Gym 1 - Bouncer
			Name = 'Jed',
			IntroPhrase = {'Can you move on the dance floor?', 'Let\'s see what moves you have in a battle first!'},
			LosePhrase = {'Those were some interesting moves.', 'I\'ll have to take note of them.'},
			Interact = {'We get people in here all the time that can\'t dance at all.', 'They just want the badge.'},
			Party = {
				{ name = 'Electrike', level = 10 },
				{ name = 'Mareep', level = 10 },
			},
		},

		{ -- [# 11] : Route 3 - Student
			Name = 'Chase',
			IntroPhrase = {'Welcome to route 3.', 'Oh sorry, did my presence shock you?'},
			LosePhrase = {'Did I win?', 'Oh, well sorta... I lost...'},
			Interact = {'Careful on route 3.', 'There are a lot of Electric-type pokemon that will shock you if you aren\'t careful.'},
			Party = {
				{ name = 'Electrike', level = 8 },
			},
		},
		{ -- [# 12] : Route 3 - Rookie
			Name = 'Adam',
			IntroPhrase = {'My pokemon and I were just playing fetch.', 'We\'ve been waiting for another trainer to battle with.'},
			LosePhrase = 'My pokemon are better at fetch than they are in battle.',
			Interact = {'Great, Poochyena lost the stick again.', 'Playing fetch isn\'t his strength either.'},
			RematchQuestion = {'Perhaps more battling will help.', 'Battle us again?'},
			Party = {
				{ name = 'Poochyena', level = 7 },
				{ name = 'Poochyena', level = 7 },
			},
		},
		{ -- [# 13] : Route 3 - Enthusiast
			Name = 'Tiffany',
			IntroPhrase = {'My pokemon are strong against Water- and Flying-types.', 'Hope you don\'t plan on using either of those.'},
			LosePhrase = 'I never said my pokemon were invincible.',
			Interact = {'Water- and Flying-type Pokemon are weak to Electric-type moves.', 'Makes sense if you ask me.'},
			Party = {
				{ name = 'Mareep', level = 7 },
				{ name = 'Electrike', level = 7 },
			},
		},
		{ -- [# 14] : Route 3 - Camper
			Name = 'Jacob',
			IntroPhrase = 'My jeans are not comfortable, nor easy to wear.',
			LosePhrase = 'I think I need to switch to shorts.',
			Interact = {'I just talked to a guy that suggested I make a switch to shorts.', 'I think I will do that.'},
			RematchQuestion = {'I need more money before I can afford shorts.', 'Battle me?'},
			Party = {
				{ name = 'Dunsparce', level = 9 },
			},
		},

		{ -- [# 15] : Route 5 - Hiker
			Name = 'Stan',
			IntroPhrase = {'I\'ve always admired the beauty of the savannah!', 'The pokemon here are so diverse too.', 'Let me show you.'},
			LosePhrase = {'Your pokemon are quite powerful.', 'I wasn\'t expecting that.'},
			Interact = {'The pokemon on Route 5 have different types.', 'They are quite unique.'},
			RematchQuestion = 'Say, would you like to battle me again?',
			Party = {
				{ name = 'Patrat', level = 11 },
				{ name = 'Litleo', level = 11 },
			},
		},
		{ -- [# 16] : Route 5 - Camper
			Name = 'Jason',
			IntroPhrase = {'Hey, do you fight fair?', 'I want to find out.'},
			LosePhrase = {'Did you cheat?', 'How can I trust you?'},
			Interact = 'It\'s hard to meet people you can trust these days...',
			Party = {
				{ name = 'Nidoran[M]', level = 13 },
			},
		},
		{ -- [# 17] : Route 5 - Picnicker
			Name = 'Lia',
			IntroPhrase = {'This giant rock reminds me of something...', 'I can\'t quite figure out what.', 'Maybe a battle will help me think better.'},
			LosePhrase = {'Oh I remember now!', 'It\'s just like the rock in that commercial for Sawsbuck Coffee!'},
			Interact = 'Wait, I could be wrong about the commercial thing...',
			Party = {
				{ name = 'Litleo', level = 14 },
			},
		},
		{ -- [# 18] : Route 5 - Black Belt
			Name = 'Brian',
			IntroPhrase = {'I never let trainers pass me without testing their strength first!', 'You won\'t be an exception.'},
			LosePhrase = 'You are a worthy opponent.',
			Interact = 'Your skills deem you worthy to pass, traveler.',
			RematchQuestion = {'Unless you\'d like to battle again.', 'Is that the case?'},
			Party = {
				{ name = 'Machop', level = 12 },
				{ name = 'Machop', level = 12 },
				{ name = 'Pancham', level = 12 },
			},
		},
		{ -- [# 19] : Route 5 - Hiker
			Name = 'Kyle',
			IntroPhrase = {'This way leads to Brimber City.', 'Before you go, would you mind having a battle with me?'},
			LosePhrase = {'Wow, that was fast.', 'You must really be in a hurry.'},
			Interact = {'Brimber City is housed beneath a huge volcano.', 'It\'s not very active but it\'s still intimidating.'},
			Party = {
				{ name = 'Geodude', level = 13 },
				{ name = 'Geodude', level = 13 },
				{ name = 'Hippopotas', level = 14 },
			},
		},
		{ -- [# 20] : Route 5 - Bug Catcher
			Name = 'Allen',
			IntroPhrase = {'A lot of bug pokemon are known for how early they evolve.', 'It gives trainers like me a pretty big advantage.'},
			LosePhrase = 'Looks like you had the upper hand.',
			Interact = {'I guess strategy is also important in battle.', 'Having fully evolved pokemon doesn\'t mean you will win the battle.'},
			RematchQuestion = {'Give me another chance?'},
			Party = {
				{ name = 'Butterfree', level = 14 },
				{ name = 'Beedrill', level = 14 },
			},
		},
		{ -- [# 21] : Route 5 - Camper
			Name = 'Gordon',
			IntroPhrase = {'I was just visiting my ancestors\' graves.', 'I get sad when I visit here.', 'Maybe a battle will cheer me up?'},
			LosePhrase = 'Even though I lost, I feel a lot better now.',
			Interact = {'The graveyard is so old and there really aren\'t many people that look after it.',
				'I wish someone would come in and take care of it.', 'The last person that watched over it abandoned their home there.',
				'Maybe they just got spooked.'},
			Party = {
				{ name = 'Cubone', level = 14 },
				{ name = 'Marill', level = 13 },
				{ name = 'Cubone', level = 14 },
			},
		},
		{ -- [# 22] : Route 5 - Rebellious Girl
			Name = 'Lannie',
			IntroPhrase = {'Death is just a new beggining is what I hear.', 'I\'m not ready to die, but it sounds interesting.'},
			LosePhrase = 'That battle made me feel quite alive.',
			Interact = {'I come here to think about life.', 'I\'ve been thinking about what lies beyond this life since my mother died.'},
			RematchQuestion = {'Battling you makes me feel more alive.', 'Would you battle me again?'},
			Party = {
				{ name = 'Gothita', level = 14 },
				{ name = 'Gothita', level = 14 },
				{ name = 'Cubone', level = 15 },
			},
		},

		{ -- [# 23] : Route 6 - Hiker
			Name = 'Kent',
			IntroPhrase = {'These tall walls and narrow paths were created by molten lava years ago.', 'They make great places to sit and wait for trainers to battle.'},
			LosePhrase = 'I may have lost but I like my spot here.',
			Interact = {'I get used to being in one place so much.', 'It\'s like I\'ve claimed this area as my own property.'},
			RematchQuestion = {'Not a lot of people come through here.', 'Would you help me pass the time by battling again?'},
			Party = {
				{ name = 'Geodude', level = 14 },
				{ name = 'Slakoth', level = 15 },
			},
		},
		{ -- [# 24] : Route 6 - Bug Catcher
			Name = 'Silvester',
			IntroPhrase = {'If your pokemon get burned by a Fire-type pokemon, your physical attack power will be cut in half.', 'I need to remember to pick up some Burn Heals when I\'m in town again.'},
			LosePhrase = 'I\'m gonna need a Burn Heal because I just got roasted.',
			Interact = {'Burns are nasty business.', 'They cut a pokemon\'s attack power as well as hurt your pokemon each turn.'},
			Party = {
				{ name = 'Venonat', level = 16 },
			},
		},
		{ -- [# 25] : Route 6 - Lass
			Name = 'Whitney',
			IntroPhrase = {'I heard that the volcano here hasn\'t erupted in a long time.',
				'Supposedly there\'s an incredible pokemon asleep in the volcano that could make it erupt.',
				'That\'s just a story my grandpa used to tell me.', 'Enough stories though, let\'s battle.'},
			LosePhrase = 'I\'m not telling anyone about the story of our fight.',
			Interact = 'I wonder if there really is a pokemon that can make the volcano erupt, sleeping somewhere inside it.',
			Party = {
				{ name = 'Ponyta', level = 14 },
				{ name = 'Teddiursa', level = 14 },
			},
		},
		{ -- [# 26] : Route 6 - Student
			Name = 'Johnson',
			IntroPhrase = {'I heard there are some rare pokemon ahead in the cave.', 'My only problem is that I\'m terrified of caves.', 'Can I see your pokemon instead?'},
			LosePhrase = 'Wow, your pokemon are really nice.',
			Interact = {'The Zubats inside the cave come out at night.', 'It\'s really something, to see so many of them flying around in the night sky.'},
			RematchQuestion = {'Do you remember what Zubat looks like?', 'I\'ll show you mine in another battle.'},
			Party = {
				{ name = 'Zubat', level = 14 },
				{ name = 'Zubat', level = 14 },
				{ name = 'Patrat', level = 14 },
			},
		},
		{ -- [# 27] : Route 6 - Eclipse Grunt
			Name = 'Carl',
			IntroPhrase = {'Stop right there, kid.', 'Nobody\'s allowed to go past here.', 'Team Eclipse will not allow intruders.', 'What, you won\'t leave?', 'Then I guess we\'re going to have to battle.'},
			LosePhrase = {'This isn\'t good.', 'Don\'t try anything funny.'},
			Interact = {'My boss won\'t be happy if I let a random kid get inside during our operation.', 'There\'s nothing I can really do right now, though.'},
			Party = {
				{ name = 'Poochyena', level = 15 },
				{ name = 'Zubat', level = 15 },
			},
		},

		{ -- [# 28] : Mt. Igneus - Eclipse Grunt
			Name = 'Mason',
			IntroPhrase = {'Hey, how did you get past the guard outside?', 'You know it really doesn\'t surprise me.', 'He was weak in my opinion.', 'You will not beat me, though.'},
			LosePhrase = {'What happened?', 'My pokemon must not be having a good day.'},
			Interact = 'It doesn\'t matter that you beat me, you won\'t get past any of the other guards.',
			Party = {
				{ name = 'Slugma', level = 16 },
			},
		},
		{ -- [# 29] : Mt. Igneus - Eclipse Grunt
			Name = 'Jay',
			IntroPhrase = {'I was told to wait here and escort out any intruders.', 'If you won\'t leave on your own then I will have to force you out after I beat you in a battle.'},
			LosePhrase = 'Would you leave if I asked you nicely?',
			Interact = {'I\'m not happy about losing, but honestly, it won\'t make a difference.', 'We are close now to finishing what we started here.'},
			Party = {
				{ name = 'Zubat', level = 15 },
				{ name = 'Grimer', level = 15 },
			},
		},
		{ -- [# 30] : Mt. Igneus - Eclipse Grunt
			Name = 'Louie',
			IntroPhrase = {'Team Eclipse will acheive its goal!', 'We will not allow a brat like you to get in our way.', 'Prepare to be driven out.'},
			LosePhrase = {'I am just a pawn in Team Eclipse\'s grand scheme.', 'We will prevail in the end.'},
			Interact = 'What you do here will make no difference, foolish child.',
			Party = {
				{ name = 'Ekans', level = 16 },
			},
		},
		{ -- [# 31] : Mt. Igneus - Eclipse Grunt
			Name = 'Luey',
			IntroPhrase = {'Our plan is almost in effect now.', 'I\'m afraid you will miss the show after I beat you in battle.'},
			LosePhrase = 'Well maybe you will get to witness our plan in action after all.',
			Interact = {'Our team admin will not allow you to interfere with our plans.', 'He\'s much too powerful for you.'},
			Party = {
				{ name = 'Numel', level = 15 },
				{ name = 'Numel', level = 15 },
				{ name = 'Zubat', level = 15 },
			},
		},
		{ -- [# 32] : Mt. Igneus - Hiker
			Name = 'Darrel',
			IntroPhrase = {'It seems like this chamber is a dead end.', 'Since we\'re both here, would you mind having a battle?'},
			LosePhrase = 'Seems like this battle was a dead end for me too.',
			Interact = 'I\'ve been exploring this cave for a while now and I get the sense that there is more that I have yet to discover.',
			RematchQuestion = {'You know what I could really use, though...', 'A good battle.', 'Battle me again?'},
			Party = {
				{ name = 'Slugma', level = 15 },
				{ name = 'Numel', level = 15 },
				{ name = 'Slugma', level = 15 },
			},
		},

		{ -- [# 33] : Gym 2 - Pyro
			Name = 'Lance',
			IntroPhrase = {'Watch your step!', 'You almost stepped on that lava tile back there.', 'Maybe a battle will make you think more carefully.'},
			LosePhrase = 'Now you\'re thinkin\'!',
			Interact = {'Take it easy in here.', 'It\'s not a race.'},
			Party = {
				{ name = 'Slugma', level = 16 },
				{ name = 'Slugma', level = 16 },
				{ name = 'Slugma', level = 16 },
			},
		},
		{ -- [# 34] : Gym 2 - Pyro
			Name = 'Bryce',
			IntroPhrase = {'You\'re moving awfully fast there.', 'This isn\'t a race, you know.'},
			LosePhrase = 'Wow, you even beat me pretty quickly.',
			Interact = {'Go on ahead and whiz by if you like.', 'What happens to you is on your shoulders.'},
			Party = {
				{ name = 'Charmeleon', level = 18 },
			},
		},
		{ -- [# 35] : Gym 2 - Pyro
			Name = 'Cole',
			IntroPhrase = {'You\'re half way there now.', 'I bet you\'re excited to battle the Gym Leader.', 'Too bad you\'ll have to leave and come back after I beat you.'},
			LosePhrase = {'Well alright then, you win.', 'Go ahead and move on.'},
			Interact = 'You beat me kid, now move on already.',
			Party = {
				{ name = 'Ponyta', level = 17 },
				{ name = 'Litleo', level = 17 },
			},
		},
		{ -- [# 36] : Gym 2 - Pyro
			Name = 'Moe',
			IntroPhrase = {'You\'re almost there now.', 'Let me be the last to test your strength before facing our Gym Leader.'},
			LosePhrase = 'It\'s up to Sebastian now to test your strength.',
			Interact = 'Go now and see how strong you truly are in a battle against our leader.',
			Party = {
				{ name = 'Torkoal', level = 18 },
			},
		},
		{ -- [# 37] : Route 7 - Cool Trainer
			Name = 'Braden',
			IntroPhrase = {'Hey there!', 'Oh neat, you have the badge from the Brimber City Gym!', 'You must be tough.', 'Let\'s have a battle!'},
			LosePhrase = 'I see how you earned that badge now...',
			Interact = 'You can usually tell how tough a trainer is by how many badges they have.',
			Party = {
				{ name = 'Marill', level = 17 },
				{ name = 'Rattata', level = 17 },
				{ name = 'Nidorina', level = 17 },
			}
		},
		{ -- [# 38] : Route 7 - Lady
			Name = 'Sarah',
			IntroPhrase = 'After I have breakfast with my pokemon, we come out here to train for a few hours.',
			LosePhrase = 'Well now it\'s that time of day for me to heal my pokemon...',
			Interact = 'I make sure my pokemon are always healthy before I begin training.',
			Party = {
				{ name = 'Budew', level = 17 },
				{ name = 'Beautifly', level = 19 },
			}
		},
		{ -- [# 39] : Route 7 - Rising Star
			Name = 'Melvin',
			IntroPhrase = 'One day I\'ll have stunt doubles to do all of my pokemon battles for me.',
			LosePhrase = 'Pokemon battles are just too dangerous for someone of my status.',
			Interact = 'Pokemon battles aren\'t my thing anyways...',
			Party = {
				{ name = 'Minccino', level = 18 },
				{ name = 'Surskit', level = 18 },
				{ name = 'Flaaffy', level = 19 },
			}
		},
		{ -- [# 40] : Route 7 - Hipster
			Name = 'Lincoln',
			IntroPhrase = {'I was the first person to stand here and wait for other trainers on this bridge.',
				'I guess you could say I\'m pretty cool.', 'Anyways, let\'s battle.'},
			LosePhrase = 'I should\'ve just gone and hung out by myself at Sawsbuck Coffee this morning...',
			Interact = {'You were the first person to beat me on this bridge.', 'I guess that makes you pretty cool.'},
			RematchQuestion = 'Can I have another shot at being cool?',
			Party = {
				{ name = 'Surskit', level = 18 },
				{ name = 'Fletchinder', level = 20 },
				{ name = 'Masquerain', level = 22 },
			}
		},
		{ -- [# 41] : Route 7 - Rebellious Girl
			Name = 'Jess',
			IntroPhrase = {'My parents don\'t even know that I have pokemon.', 'If they found out I came out here to train, they wouldn\'t be very happy with me.'},
			LosePhrase = 'This is what I get for ignoring my parents...',
			Interact = {'I just can\'t help it.', 'I love pokemon so much.'},
			RematchQuestion = 'I\'ll battle you again if you don\'t tell my parents.',
			Party = {
				{ name = 'Skitty', level = 19 },
				{ name = 'Glameow', level = 20 },
				{ name = 'Herdier', level = 21 },
			}
		},
		{ -- [# 42] : Route 7 - Salesman
			Name = 'Doug',
			IntroPhrase = {'I sell pokemon insurance.', 'You can use it in case your pokemon gets hurt.', 'Allow me to demonstrate...'},
			LosePhrase = 'It\'s a good thing I\'m insured.',
			Interact = 'Wait... my policy only covers Rock-type pokemon with Sturdy?',
			Party = {
				{ name = 'Poliwag', level = 19 },
				{ name = 'Poliwag', level = 19 },
				{ name = 'Kadabra', level = 20 },
			}
		},
		{ -- [# 43] : Route 7 Saw Mill - Lumberjack
			Name = 'Buck',
			IntroPhrase = {'I\'m tired of all this hard work.', 'It\'s time for a break.'},
			LosePhrase = 'I think I\'ll just stay on my break a little longer.',
			Interact = {'My work here isn\'t easy.', 'Chopping wood all day hurts my back.'},
			Party = {
				{ name = 'Bidoof', level = 22 },
				{ name = 'Bidoof', level = 22 },
				{ name = 'Deerling', level = 23 },
			}
		},
		{ -- [# 44] : Route 7 Saw Mill - Lumberjack
			Name = 'Al',
			IntroPhrase = {'We let some of our Bidoofs go out to play in the river a little while ago.',
				'I want to have some fun too...'},
			LosePhrase = 'Losing isn\'t very much fun...',
			Interact = 'Sometimes the Bidoofs get into mischief.',
			Party = {
				{ name = 'Bidoof', level = 22 },
				{ name = 'Bidoof', level = 22 },
				{ name = 'Raticate', level = 23 },
			}
		},
		{ -- [# 45] : Route 7 Saw Mill - Lumberjack
			Name = 'Paul',
			InteractRequired = true,
			WinEvent = 'BeatLumberjack',
			IntroPhrase = {'What\'s wrong?', 'Our Bidoofs have built a dam?', 'What\'s wrong with that?',
				'They don\'t mean any harm.', 'That\'s just what Bidoofs do...', 'We decided to take a little break.',
				'The Bidoofs needed a break, too.', 'I know, let\'s have a battle.', 'That\'s a great way to pass the time!'},
			LosePhrase = 'I\'m still not ready to go back to work.',
			Interact = {'Sorry for causing problems with our Bidoofs.', 'We just wanted to have a little fun.'},
			Party = {
				{ name = 'Bibarel', level = 23 },
				{ name = 'Bibarel', level = 23 },
				{ name = 'Pinsir', level = 24 },
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('DamBusted')
			end
		},
		{ -- [# 46] : Route 8 - Bird Keeper
			Name = 'Armen',
			IntroPhrase = {'Oh, there are two of you?', 'That sure is unexpected.',
				'I guess we\'ll have a double battle then.',
				'If you aren\'t familiar with double battles then you are about to be.', 'Trust me, it\'s a lot of fun!'},
			LosePhrase = 'Wow, looks like you\'ve gotten the hang of it.',
			Interact = {'Double battles are an excellent way to test a pokemon trainer\'s battle strategies.',
				'It really pushes the limits of how you battle.'},
			Party = {
				{ name = 'Pidgeotto', level = 23 },
				{ name = 'Fletchinder', level = 23 },
				{ name = 'Staravia', level = 24 },
			}
		},
		{ -- [# 47] : Route 8 - Lady
			Name = 'Lusine',
			IntroPhrase = {'Oh, hello!', 'You trainers look eager for a battle.',
				'Lucky for you, my pokemon are in prime condition.'},
			LosePhrase = 'Even in prime condition, my pokemon weren\'t good enough.',
			Interact = {'I still love my pokemon.', 'There are always more improvements to be made.',
				'One can never stop improving their qualities.'},
			Party = {
				{ name = 'Gloom', level = 22 },
				{ name = 'Ivysaur', level = 22 },
				{ name = 'Deerling', level = 23 },
				{ name = 'Venonat', level = 23 },
			}
		},
		{ -- [# 48] : Route 8 - Schoolgirl
			Name = 'Stacie',
			IntroPhrase = 'Some pokemon work really great in pairs.',
			LosePhrase = 'I need to learn a new strategy.',
			Interact = 'Developing a good strategy can help you win even in battles where it seems the odds are against you.',
			Party = {
				{ name = 'Plusle', level = 23 },
				{ name = 'Minun', level = 23 },
				{ name = 'Herdier', level = 23 },
				{ name = 'Purugly', level = 23 },
			}
		},
		{ -- [# 49] : Route 8 - Schoolboy
			Name = 'Dexter',
			IntroPhrase = {'Two against one?', 'I can already tell this is going to be a rough battle.', 'Let\'s give it a go anyway.'},
			LosePhrase = 'I can\'t say I was surprised I lost, but I didn\'t exactly try either.',
			Interact = 'I\'m just not very confident, I suppose.',
			Party = {
				{ name = 'Numel', level = 24 },
				{ name = 'Combusken', level = 23 },
				{ name = 'Heatmor', level = 22 },
				{ name = 'Torkoal', level = 22 },
			}
		},
		{ -- [# 50] : Route 8 - Lumberjack
			Name = 'Benson',
			IntroPhrase = {'It\'s my job to cut down wood and take it back to the mill on Route 7.', 'I guess I have time to stop and have a battle.'},
			LosePhrase = 'Well, break\'s over.',
			Interact = {'Lumberjacks love to take breaks.', 'Our boss gets on to us all the time for slacking off.', 'Our job isn\'t easy, though.'},
			Party = {
				{ name = 'Bibarel', level = 23 },
				{ name = 'Bibarel', level = 23 },
				{ name = 'Furfrou', level = 24 },
				{ name = 'Herdier', level = 24 },
			}
		},
		{ -- [# 51] : Route 8 - Gentleman
			Name = 'Nolan',
			IntroPhrase = {'Oh hello, how pleasent to see you.', 'Young people these days tend to run right past me.',
				'Elderly people like myself just don\'t get any attention anymore.', 'This battle will be a pleasant experience for me.'},
			LosePhrase = 'Even though I lost, it was still nice to be noticed by young folk.',
			Interact = 'I really enjoyed our match.',
			RematchQuestion = {'I\'d be happy to have another battle with you.', 'You aren\'t in a hurry, right?'},
			Party = {
				{ name = 'Gible', level = 22 },
				{ name = 'Herdier', level = 23 },
				{ name = 'Growlithe', level = 22 },
				{ name = 'Weepinbell', level = 23 },
				{ name = 'Delcatty', level = 23 },
			}
		},
		{ -- [# 52] : Route 8 - Hiker
			Name = 'Anson',
			IntroPhrase = {'I\'ve been in search of a pokemon that\'s rumored to have been sealed away for its ancient misdeeds.', 'Not much is known about it, but I think it\'s time for a break.'},
			LosePhrase = 'Well, back to searching I guess.',
			Interact = {'I travel all over the world searching for mysteries.', 'This world is so full of them.'},
			RematchQuestion = {'I witness new mysteries every time I battle, too.', 'Would you battle me again?'},
			Party = {
				{ name = 'Graveler', level = 24 },
				{ name = 'Rhyhorn', level = 25 },
				{ name = 'Onix', level = 24 },
				{ name = 'Graveler', level = 25 },
			}
		},
		{ -- [# 53] : Route 8 - Black Belt
			Name = 'Gresham',
			IntroPhrase = 'Bow to your sensei!',
			LosePhrase = 'Aw nuts, you beat me...',
			Interact = {'I\'m not a real black belt.', 'I bought this belt online.', 'I just wear it because it makes me look tough.'},
			Party = {
				{ name = 'Machoke', level = 24 },
				{ name = 'Hitmonchan', level = 25 },
				{ name = 'Machoke', level = 24 },
				{ name = 'Monferno', level = 25 },
			}
		},
		{ -- [# 54] : Route 8 - Artist
			Name = 'Stan',
			InteractRequired = true,
			IntroPhrase = 'This view gives me inspiration when I paint.',
			LosePhrase = 'That battle was inspiring!',
			Interact = {'The view from up here is absolutely amazing.', 'These cliffs against the ocean are so beautiful.'},
			Party = {
				{ name = 'Smeargle', level = 27, moves = {{id='ember'},{id='vinewhip'},{id='bubble'},{id='sketch'}} },
			}
		},
		{ -- [# 55] : Rosecove Beach - Beach Bum [Battle Pier 1]
			Name = 'James',
			IntroPhrase = {'Welcome to the battle pier.',
				'Trainers that take on the battle pier and make it to the end get a special prize.',
				'I\'ll be your first opponent.', 'Let\'s get started!'},
			LosePhrase = 'Good job, but I\'m only the first of five trainers.',
			Interact = 'The pier is just an awesome place to be, not to mention the exciting battles I get to have.',
			Party = {
				{ name = 'Wingull', level = 25 },
				{ name = 'Gloom', level = 25 },
			}
		},
		{ -- [# 56] : Rosecove Beach - Beach Bum [Battle Pier 2]
			Name = 'Hans',
			IntroPhrase = {'Hi, I am your second opponent on the battle pier.',
				'We\'ll need to battle before I can let you continue.'},
			LosePhrase = 'You\'ve passed my test, you may advance.',
			Interact = {'I\'ve been testing people\'s skill on the battle pier in my free time.',
				'We always have at least 5 people staffed on the pier.'},
			Party = {
				{ name = 'Magikarp', level = 27 },
				{ name = 'Staryu', level = 26 },
				{ name = 'Wingull', level = 25 },
				{ name = 'Palpitoad', level = 25 },
			}
		},
		{ -- [# 57] : Rosecove Beach - Beach Bum [Battle Pier 3]
			Name = 'Thomas',
			IntroPhrase = {'Duuuuuuuude, what\'s up!',
				'Ya know how great these waves are during the summer?', 'Totally fantastic!',
				'Oh yeah, I\'m supposed to battle you cause you\'re a trainer, yo.',
				'I\'m the third member of the battle pier.', 'This battle will be gnarly!'},
			LosePhrase = 'Awesome battle duuuuuude!',
			Interact = 'Dang, well Imma go hit some waves soon, I guess.',
			Party = {
				{ name = 'Shellos', level = 25 },
				{ name = 'Tentacool', level = 25 },
				{ name = 'Tentacool', level = 25 },
				{ name = 'Seaking', level = 26 },
			}
		},
		{ -- [# 58] : Rosecove Beach - Beach Babe [Battle Pier 4]
			Name = 'Samantha',
			IntroPhrase = {'Good job making it this far.', 'I\'m the fourth member of the battle pier.',
				'I\'m the best looking one of us, of course!', 'My pokemon are beautiful as well.', 'Have a look!'},
			LosePhrase = 'Oh no, my beautiful pokemon!',
			Interact = {'You get such a beautiful view from this pier.', 'I love being here and battling passerby trainers.'},
			RematchQuestion = 'I know you\'ve already beaten me, but would you mind battling again for practice?',
			Party = {
				{ name = 'Staryu', level = 25 },
				{ name = 'Staryu', level = 25 },
				{ name = 'Starmie', level = 27 },
			}
		},
		{ -- [# 59] : Rosecove Beach - Beach Bum [Battle Pier 5]
			Name = 'Greg',
			IntroPhrase = {'Well, looks like you made it, fellow trainer.', 'I\'m the final trainer of the battle pier.',
				'If you beat me you can advance to our boss.'},
			LosePhrase = 'Great battle, my boss is waiting for you.',
			Interact = {'Our boss is the guy ahead with the brown hair.', 'He\'ll award you your prize.'},
			Party = {
				{ name = 'Seaking', level = 26 },
				{ name = 'Seaking', level = 26 },
				{ name = 'Gyarados', level = 27 },
			}
		},
		{ -- [# 60] : Rosecove Beach - Beach Babe
			Name = 'Kaycee',
			IntroPhrase = {'I\'ll tell you a little secret if you beat me in a battle.', 'It\'s really helpful to trainers.'},
			LosePhrase = 'Alright, I\'ll tell you my secret.',
			Interact = {'So if you have a pokemon that can headbutt things, you can knock pokemon out of those palm trees.',
				'It\'s really cool, right?', 'You can encounter pokemon that you can\'t normally find on the ground!'},
			RematchQuestion = {'You owe me for giving you this valuable information.', 'Battle me again?'},
			Party = {
				{ name = 'Staryu', level = 25 },
				{ name = 'Staryu', level = 25 },
				{ name = 'Seaking', level = 26 },
			}
		},
		{ -- [# 61] : Rosecove Beach - Eclipse Grunt
			Name = 'Jordan',
			IntroPhrase = {'Hey, aren\'t you that kid that tried messing up our plan in the volcano with Groudon?',
				'There\'s no way I\'m letting you go any further after that little stunt you pulled!'},
			LosePhrase = 'There\'s no way!',
			Interact = {'What are you even feeding your pokemon!?', 'They are too strong.'},
			Party = {
				{ name = 'Pancham', level = 27 },
				{ name = 'Golbat', level = 26 },
			}
		},
		{ -- [# 62] : Rosecove Beach - Eclipse Grunt
			Name = 'McCoy',
			IntroPhrase = {'Hey, stop right there!', 'We can\'t be having kids getting in the way of our plans.',
				'We\'ve already had some dumb kid mess things up for us at the volcano.',
				'The boss would be so mad if that happened again here.'},
			LosePhrase = 'I\'m going to get fired for this.',
			Interact = {'My pokemon and I weren\'t ready to fight.', 'You were just lucky.'},
			Party = {
				{ name = 'Haunter', level = 26 },
				{ name = 'Haunter', level = 26 },
				{ name = 'Mightyena', level = 27 },
			}
		},
		{ -- [# 63] : Rosecove Beach - Eclipse Grunt
			Name = 'Corbin',
			IntroPhrase = {'You think you can just walk up here and stop us from our work?', 'Who do you think you are, kid?'},
			LosePhrase = 'Oh wait, you\'re that kid who was at the volcano when things didn\'t go according to plan...',
			Interact = 'If you try here what you did at the volcano, there will be consequences.',
			Party = {
				{ name = 'Torkoal', level = 26 },
				{ name = 'Seviper', level = 26 },
				{ name = 'Arbok', level = 27 },
			}
		},
		{ -- [# 64] : Rosecove Beach - Eclipse Grunt
			Name = 'Brunden',
			IntroPhrase = 'My pokemon are trained to take down meddlesome foes like yourself.',
			LosePhrase = {'My team skipped leg day last week.', 'We\'re never skipping leg day again.'},
			Interact = 'What are you looking at kid, I let you win...',
			Party = {
				{ name = 'Anorith', level = 27 },
				{ name = 'Lileep', level = 27 },
				{ name = 'Skuntank', level = 28 },
			}
		},
		{ -- [# 65] : Gym 3 - Beach Bum
			Name = 'Ralf',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'Hey, I see you figured out the first pipeworks puzzle.',
				'Good job.', 'Now let\'s see if you can beat the first gym trainer.'},
			LosePhrase = 'You really are smart!',
			Interact = 'Once you get the hang of these puzzles it gets easier to solve them.',
			Party = {
				{ name = 'Tentacool', level = 29 },
				{ name = 'Horsea', level = 29 },
				{ name = 'Tentacruel', level = 30 },
			}
		},
		{ -- [# 66] : Gym 3 - Beach Bum
			Name = 'Cameron',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'My friends and I are going to hang out on the beach later.',
				'I must first take care of my duties as a gym trainer and test trainers\' strength before they can battle our gym\'s leader.'},
			LosePhrase = 'Well, maybe I can sneak off to the beach now...',
			Interact = {'I live for the beach here in Rosecove.', 'I\'ve spent my whole life here.'},
			Party = {
				{ name = 'Wailmer', level = 30 },
				{ name = 'Mantine', level = 31 },
			}
		},
		{ -- [# 67] : Gym 3 - Beach Babe
			Name = 'Darla',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'You really are a puzzle master.',
				'Now let\'s see if you have what it takes to be a pokemon master.'},
			LosePhrase = 'Beating me doesn\'t make you a pokemon master, unfortunately.',
			Interact = {'I really don\'t know what it takes to become a true pokemon master.', 'It\'s kind of a vague title.'},
			Party = {
				{ name = 'Wartortle', level = 30 },
				{ name = 'Prinplup', level = 30 },
				{ name = 'Marshtomp', level = 30 },
			}
		},
		{ -- [# 68] : Gym 3 - Beach Bum
			Name = 'Roland',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'People give us beach bums a hard time because of our title.', 'They assume we are all lazy.',
				'I can assure you we are quite the opposite.',
				'All that swimming and lying around in the sun is hard work, you know...'},
			LosePhrase = 'Is there not another name we can go by?',
			Interact = {'I got it! Beach boys!', 'Wait - that\'s taken already, isn\'t it?'},
			Party = {
				{ name = 'Lapras', level = 31 },
			}
		},
		{ -- [# 69] : Rosecove Beach - Eclipse Grunt
			TrainerClass = 'Eclipse Grunt',
			Name = 'Eclipse Grunt Finley',
			LosePhrase = 'Team Eclipse cannot be stopped.',
			Party = {
				{ name = 'Gulpin', level = 26 },
				{ name = 'Lombre', level = 26 },
			},
			onWin = function(PlayerData)
				PlayerData.flags.winBattle69 = true
			end
		},
		{ -- [# 70] : Rosecove Beach - Eclipse Grunt
			TrainerClass = 'Eclipse Grunt',
			Name = 'Eclipse Grunt Colbert',
			LosePhrase = 'You\'re in trouble now.',
			Party = {
				{ name = 'Scraggy', level = 26 },
				{ name = 'Nuzleaf', level = 26 },
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle69 then return end
				PlayerData.flags.winBattle70 = true
			end
		},
		{ -- [# 71] : Rosecove Beach - Eclipse Admin
			Name = 'Eclipse Admin Gabe',
			LosePhrase = 'You will regret this.',
			TrainerDifficulty = 3,
			Payout = 80 * 30,
			Party = {
				{ name = 'Sneasel', level = 28 },
				{ name = 'Arbok', level = 28 },
				{ name = 'Solrock', level = 30 },
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle70 then return end
				PlayerData:completeEventServer('LighthouseScene')
			end
		},
		{ -- [# 72] : Route 9 - Jake
			Name = 'Pokemon Trainer Jake',
			LosePhrase = 'That was unexpected...',
			TrainerDifficulty = 3,
			Payout = 40 * 30,
			Party = {
				{ name = 'Vaporeon', level = 31 },
				{ name = 'Nidorino', level = 29 },
				{ name = 'Zebstrika', level = 30 },
				{ name = 'Slowpoke', level = 30 },
			},
			onWin = function(PlayerData)
				PlayerData.flags.winBattle72 = true
			end
		},
		{ -- [# 73] : Route 9 - Tess
			Name = 'Pokemon Trainer Tess',
			LosePhrase = 'Wait... Did I really lose?',
			TrainerDifficulty = 3,
			Payout = 30 * 30,
			Party = {
				{ name = 'Gabite', level = 32, gender = 'F' },
				{ name = 'Shelgon', level = 31, gender = 'F' },
				{ name = 'Axew', level = 30, gender = 'M' },
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle72 then return end
				PlayerData:completeEventServer('JTBattlesR9')
			end
		},
		{ -- [# 74] : Route 9 - Hiker
			Name = 'Jenson',
			IntroPhrase = {'I was picking up and collecting pine cones when suddenly one attacked me.', 'Have a look for yourself!'},
			LosePhrase = 'My pine cones were Pinecos all along.',
			Interact = 'Some pokemon fall from some of the trees here in the forest.',
			RematchQuestion = 'Would you like to see my Pineco collection again?',
			Party = {
				{ name = 'Pineco', level = 30 },
				{ name = 'Pineco', level = 30 },
				{ name = 'Graveler', level = 31 },
			}
		},
		{ -- [# 75] : Route 9 - Camper
			Name = 'Pal',
			IntroPhrase = {'I\'ve been admiring this large tree for quite some time.',
				'It fills the air with a powerful freshness.',
				'It makes me feel great, good enough to batle even.'},
			LosePhrase = 'Win or lose, I\'m not leaving this place.',
			Interact = {'I draw so much energy from these woods.',
				'I can\'t tell if it\'s the freshness of the air or the luscious scenery.'},
			RematchQuestion = {'It puts me in the mood for another battle.',
				'What do you say?'},
			Party = {
				{ name = 'Pichu', level = 29 },
				{ name = 'Grovyle', level = 30 },
				{ name = 'Linoone', level = 31 },
			}
		},
		{ -- [# 76] : Route 9 - Journalist
			Name = 'Donovan',
			IntroPhrase = {'What\'s good?!',
				'I\'m here to see the great tree of the forest for myself.',
				'I\'m from Anthian City and don\'t get away from the big city much.'},
			LosePhrase = 'Looks like I need more practice.',
			Interact = 'Since I\'m cooped up at home so much, I guess I\'ve gotten a little rusty at battling.',
			Party = {
				{ name = 'Exeggcute', level = 32 },
				{ name = 'Exeggcute', level = 32 },
				{ name = 'Mightyena', level = 32 },
			}
		},
		{ -- [# 77] : Route 9 - Picnicker
			Name = 'Ashley',
			IntroPhrase = {'That shrine has been here in the forest for centuries.',
				'It\'s supposedly a relic to one of the most mysterious pokemon in mythology.',
				'That\'s just a rumor, though.',
				'Enough talk about that, let\'s have a battle!'},
			LosePhrase = 'I need to study more.',
			Interact = {'Right now I\'m studying about the history of the forest.',
				'There is a lot of history here.'},
			RematchQuestion = {'I can take a break, though.', 'Would you like to have another battle?'},
			Party = {
				{ name = 'Kirlia', level = 29 },
				{ name = 'Weepinbell', level = 29 },
				{ name = 'Azurill', level = 29 },
				{ name = 'Roselia', level = 30 },
			}
		},
		{ -- [# 78] : Route 9 - Bug Catcher
			Name = 'Erwin',
			IntroPhrase = {'I got lost earlier in this forest and found myself in front of a large mansion.',
				'Something about it gave me a really creepy feeling so I left as quick as I could.',
				'I\'d much rather stay here and catch more bug pokemon.'},
			LosePhrase = 'No, my precious bug pokemon!',
			Interact = {'Parts of this forest give me the chills.', 'There is too much mystery here.'},
			Party = {
				{ name = 'Beautifly', level = 30 },
				{ name = 'Dustox', level = 30 },
				{ name = 'Vivillon', level = 32 },
			}
		},
		{ -- [# 79] : Route 9 - Bird Keeper
			Name = 'Mark',
			IntroPhrase = {'I let my bird pokemon out early in the mornings to eat.',
				'You know what they say - the early bird catches the worm.'},
			LosePhrase = {'The early bird doesn\'t win the fights.', 'That will be the new saying.'},
			Interact = {'Bird pokemon are great for battles against Ground-type pokemon.',
				'There are moves that can make Flying-type pokemon vulnerable to Ground-type moves, though.'},
			Party = {
				{ name = 'Pidgeotto', level = 30 },
				{ name = 'Noctowl', level = 31 },
			}
		},
		{ -- [# 80] : Route 10 - Black Belt
			Name = 'Mikey',
			IntroPhrase = {'I will focus my energy on winning this battle.',
				'I\'m unstoppable when I focus on a task.'},
			LosePhrase = 'I broke my focus for only a moment, and was defeated.',
			Interact = {'You can accomplish any task simply by focusing on it hard enough.',
				'Others would have you believe that to be a false statement.',
				'Believe only in yourself.'},
			Party = {
				{ name = 'Meditite', level = 32 },
				{ name = 'Meditite', level = 32 },
				{ name = 'Machoke', level = 33 },
				{ name = 'Meditite', level = 32 },
			}
		},
		{ -- [# 81] : Route 10 - Schoolboy
			Name = 'Scotty',
			IntroPhrase = {'I skipped school today to train my team.',
				'I\'m going to tell my parents that I learned about pokemon.',
				'It\'s genius because I\'m not lying.'},
			LosePhrase = 'What have we learned today?',
			Interact = 'I learned that I shouldn\'t skip school.',
			Party = {
				{ name = 'Teddiursa', level = 31 },
				{ name = 'Spoink', level = 32 },
				{ name = 'Spoink', level = 32 },
				{ name = 'Flabebe', level = 32 },
			}
		},
		{ -- [# 82] : Route 10 - Gentleman
			Name = 'Roger',
			IntroPhrase = {'An old man like me needs to be careful how he walks in this wind.', 
				'Thankfully, I have my pokemon here to assist me.',
				'They do more for me than just help me watch my step.',
				'Here, let me show you.'},
			LosePhrase = {'Don\'t worry, my pokemon are much better at helping me keep my balance.',
				'I wouldn\'t be standing here if they weren\'t.'},
			Interact = {'I love walking on this route.', 'I met my pokemon here.'},
			Party = {
				{ name = 'Growlithe', level = 32 },
				{ name = 'Growlithe', level = 32 },
				{ name = 'Growlithe', level = 32 },
				{ name = 'Chimecho', level = 33 },
			}
		},
		{ -- [# 83] : Cragonos Mines - Collector
			Name = 'Grey',
			IntroPhrase = {'Rumor has it that these mines were dug out in order to search for mysterious stones.', 
				'As a collector, I\'m here to see if any were left behind so that I may add to my precious collections.',
				'I\'m not having any luck with finding anything.', 'Maybe I\'ll get lucky and win this fight.'},
			LosePhrase = 'I\'ll get some luck one of these days...',
			Interact = {'Collecting stones is my passion.',
				'I find some good ones every now and then, but I\'ve heard rumors that there are very rare stones here in these mines.'},
			Party = {
				{ name = 'Roggenrola', level = 30 },
				{ name = 'Roggenrola', level = 30 },
				{ name = 'Roggenrola', level = 30 },
				{ name = 'Geodude', level = 30 },
				{ name = 'Graveler', level = 31 },
			}
		},
		{ -- [# 84] : Cragonos Mines - Rookie
			Name = 'Evan',
			IntroPhrase = {'Oh good, I haven\'t seen anyone else in quite a while.',
				'I got lost looking for trainers to battle.',
				'Well, since you\'re here, let\'s have a fight.'},
			LosePhrase = 'I may have lost, but I remembered my way back out.',
			Interact = {'I think I\'ll stick around a bit longer.',
				'My battle with you taught me a lot.',
				'I want to wait and see if I run into any more good trainers like you.'},
			Party = {
				{ name = 'Roggenrola', level = 31 },
				{ name = 'Geodude', level = 31 },
				{ name = 'Geodude', level = 31 },
				{ name = 'Woobat', level = 31 },
			}
		},
		{ -- [# 85] : Cragonos Mines - Hiker
			Name = 'Brennon',
			IntroPhrase = {'This whole area was dug out quite a long time ago by miners.',
				'They left the mine tracks here to make it possible to scale the mountain from the inside.',
				'It makes it less of a challenge to scale the mountain, unless you consider the trainers like me that are here to challenge traveling trainers like yourself.'},
			LosePhrase = 'It seems my pokemon weren\'t enough of a challenge for you.',
			Interact = {'These mines are quite a wonderous place.',
				'I come here to test my strength against trainers and the wild pokemon that have made these caves their home.'},
			RematchQuestion = 'Say, how about another test of strength?',
			Party = {
				{ name = 'Onix', level = 33 },
				{ name = 'Onix', level = 32 },
				{ name = 'Geodude', level = 33 },
			}
		},
		{ -- [# 86] : Cragonos Mines - Black Belt
			Name = 'Cody',
			IntroPhrase = {'I train my rock-hard fists by punching through the rocks in this cave.',
				'Occasionally I\'ll punch a Geodude, and let me tell you, that hurts.'},
			LosePhrase = 'The pain of losing a battle is worse than the sting from punching a Geodude.',
			Interact = {'My training seems difficult to most.',
				'I adjust on a daily basis as I become stronger, so my difficult training doesn\'t seem so difficult any more.'},
			Party = {
				{ name = 'Geodude', level = 33 },
				{ name = 'Geodude', level = 34 },
				{ name = 'Meditite', level = 33 },
				{ name = 'Meditite', level = 34 },
			}
		},
		{ -- [# 87] : Cragonos Mines - Adventurer
			Name = 'Jesper',
			IntroPhrase = {'I look for action at every turn.',
				'Life is meant to be spent exploring and learning about the world we live in.',
				'I\'m here with my pokemon learning about what we\'re made of.'},
			LosePhrase = 'Bad experiences shouldn\'t stop you from going out and experiencing wonderous things first-hand.',
			Interact = 'I\'ve seen a lot in my lifetime, but your team was among the most powerful I\'ve ever seen.',
			RematchQuestion = 'Maybe we can have another battle to see if I\'ve gotten any stronger?',
			Party = {
				{ name = 'Flareon', level = 33 },
				{ name = 'Vaporeon', level = 33 },
				{ name = 'Glaceon', level = 33 },
				{ name = 'Jolteon', level = 33 },
			}
		},
		{ -- [# 88] : Cragonos Mines - Journalist
			Name = 'Joshua',
			IntroPhrase = {'I\'m here collecting the facts on a story.',
				'I\'m learning about what attracts the pokemon that live in this cave to the mines.',
				'I think a battle with the pokemon I\'ve caught here will help me learn more about them.'},
			LosePhrase = 'Let me just finish taking my notes...',
			Interact = 'From what I can tell, the pokemon here are very attracted to rocks and dirt...',
			RematchQuestion = 'Do you think another battle would be more enlightening?',
			Party = {
				{ name = 'Onix', level = 34 },
				{ name = 'Geodude', level = 35 },
				{ name = 'Geodude', level = 35 },
				{ name = 'Boldore', level = 34 },
				{ name = 'Drilbur', level = 34 },
			}
		},
		{ -- [# 89] : Cragonos Mines - Worker [TEMP]
			Name = 'Deven',
			InteractRequired = true,
			IntroPhrase = {'This is as far as you can travel for now.',
				'You\'ll have to wait for the next adventure update to advance.',
				'Let\'s have a battle to pass the time.'},
			LosePhrase = 'Time well spent... or was it?',
			Interact = 'When the update including the 4th gym is made, the road ahead will be opened.',
			RematchQuestion = 'Since the game still hasn\'t been updated, how about another battle?',
			Party = {
				{ name = 'Timburr', level = 35 },
				{ name = 'Timburr', level = 35 },
				{ name = 'Gurdurr', level = 36 },
				{ name = 'Machoke', level = 35 },
			}
		},
		{ -- [# 90] : Cragonos Cliffs - Bird Keeper
			Name = 'Willis',
			IntroPhrase = {'These cliffs are scary to walk close to for most people.',
				'My bird pokemon make me feel safe near them, though.',
				'Here, have a look at them.'},
			LosePhrase = 'I fear losing battles more than heights.',
			Interact = {'My bird pokemon love to soar through the skies in this canyon.',
				'It\'s a great place for them to hunt for prey.'},
			Party = {
				{ name = 'Spearow', level = 35 },
				{ name = 'Spearow', level = 35 },
				{ name = 'Pidgeotto', level = 35 },
			}
		},
		{ -- [# 91] : Cragonos Cliffs - Hiker
			Name = 'Jackson',
			IntroPhrase = {'After being cramped up in that dark cavern for so long, it\'s nice to take a step outside for a breath of fresh air.',
				'Sooner or later you have to go back in.',
				'I\'m not ready to go back in so let\'s have a battle instead.'},
			LosePhrase = 'Well I guess there\'s not much left for me to do out here now.',
			Interact = {'The view from here is amazing.',
				'It makes you realize how big of a world we really live in and how small we really are.'},
			RematchQuestion = {'I\'m still not ready to head back into the cave yet.',
				'If you would like to battle again, I would be happy to oblige.'},
			Party = {
				{ name = 'Geodude', level = 32 },
				{ name = 'Graveler', level = 34 },
				{ name = 'Golem', level = 36 },
			}
		},
		{ -- [# 92] : Cragonos Cliffs - Camper
			Name = 'Travis',
			IntroPhrase = {'The entrance back into the mines is just around this corner.',
				'Would you mind a quick battle before you head back in?'},
			LosePhrase = {'Awesome. That was exactly what I needed.', 'Not every loss is a failure.'},
			Interact = {'I learn so much from every trainer that passes through here.',
				'Everyone seems to have their own unique strategies.'},
			Party = {
				{ name = 'Furret', level = 35 },
				{ name = 'Gogoat', level = 34 },
				{ name = 'Aipom', level = 34 },
				{ name = 'Flaaffy', level = 35 },
			}
		},
		{ -- [# 93] : Gym 4 - Marshaller
			Name = 'Jerome',
			IntroPhrase = {'I was put on clean-up duty.',
				'I\'d say most of this place is in decent order for now.',
				'I\'d like to take a break and have a battle.'},
			LosePhrase = 'Back to work now.',
			Interact = 'I always get put on cleaning duty.',
			Party = {
				{ name = 'Gligar', level = 44 },
				{ name = 'Gligar', level = 44 },
				{ name = 'Jumpluff', level = 44 },
			}
		},
		{ -- [# 94] : Gym 4 - Marshaller
			Name = 'Wilbur',
			IntroPhrase = {'Welcome to the Anthian City Gym.',
				'This gym doubles as a plane hangar for the city\'s airport.',
				'If you don\'t mind now, I\'d like to have a Pokemon battle to test your strength.'},
			LosePhrase = 'You certainly are a strong trainer.',
			Interact = 'We love Flying-type pokemon here.',
			Party = {
				{ name = 'Pidgeot', level = 44 },
				{ name = 'Swoobat', level = 44 },
			}
		},
		{ -- [# 95] : Gym 4 - Marshaller
			Name = 'Orville',
			IntroPhrase = {
				'Be careful where you step up here.',
				'Being this high is a safety hazard for young trainers like yourself.',
				'Speaking of safety hazards, let\'s battle!'},
			LosePhrase = 'Looks like I should have been more prepared for that.',
			Interact = 'Be careful where you walk, there are oil spills and loose tools laying everywhere.',
			Party = {
				{ name = 'Pelipper', level = 46 },
				{ name = 'Pidgeot', level = 46 },
			}
		},
		{ -- [# 96] : Gym 4 - Marshaller (MANUAL)
			Name = 'Marshaller Santos',
			TrainerDifficulty = 3,
			Payout = 24 * 44,
			LosePhrase = {'I was hoping to win that battle.', 'Oh well, I\'ll help you now.'},
			Party = {
				{ name = 'Chatot', level = 43 },
				{ name = 'Archeops', level = 44 },
				{ name = 'Talonflame', level = 44 },
			}
		},
		{ -- [# 97] : Gym 4 - Marshaller (MANUAL)
			Name = 'Marshaller Alberto',
			TrainerDifficulty = 3,
			Payout = 24 * 45,
			LosePhrase = 'Well, I owe you that lift now.',
			Party = {
				{ name = 'Staraptor', level = 45 },
				{ name = 'Pidgeot', level = 45 },
			}
		},
		{ -- [# 98] : Gym 4 - Leader Stephen
			Name = 'Gym Leader Stephen',
			TrainerDifficulty = 4,
			Payout = 160 * 53,
			LosePhrase = 'Mayday! Mayday!',
			Party = {
				{ name = 'Staraptor', level = 46, moves = {
					{ id = 'aerialace' },{ id = 'bravebird' },
					{ id = 'agility' },  { id = 'closecombat' },
				}},
				{ name = 'Skarmory', level = 47, moves = {
					{ id = 'aerialace' },{ id = 'slash' },
					{ id = 'steelwing' },{ id = 'spikes' },
				}},
				{ name = 'Aerodactyl', level = 47, moves = {
					{ id = 'aerialace' },{ id = 'earthquake' },
					{ id = 'firefang' }, { id = 'thunderfang' },
				}},
				{ name = 'Staraptor', level = 46, moves = {
					{ id = 'aerialace' },{ id = 'fly' },
					{ id = 'whirlwind' },{ id = 'doubleteam' },
				}},
				{ name = 'Braviary', level = 50, moves = {
					{ id = 'aerialace' },{ id = 'zenheadbutt' },
					{ id = 'crushclaw' },{ id = 'superpower' },
				}},
			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(4, 40)
			end
		},
		{ -- [# 99] : Anthian Sewers - Scientist
			Name = 'Evan',
			IntroPhrase = {'Well well, we have visitors here in the sewers.',
				'Most people don\'t realize it, but we scientists do a lot of work down here, making sure everything runs properly on the surface.'},
			LosePhrase = 'I really should be working right now.',
			Interact = {'We spend a lot of our time cleaning and recycling water used in the city.',
				'It\'s not easy to import water into this city, and we live above the clouds so rain isn\'t an option.'},
			Party = {
				{ name = 'Magnemite', level = 42 },
				{ name = 'Magneton', level = 42 },
				{ name = 'Magneton', level = 44 },
				{ name = 'Electrode', level = 45 },
			}
		},
		{ -- [#100] : Anthian Sewers - Rebellious Girl
			Name = 'Amanda',
			IntroPhrase = {'These sewers are like my own personal little hideout.',
				'I come down here to get away from everyone on the surface.'},
			LosePhrase = 'My failure is the reason I hide from others.',
			Interact = 'It does smell pretty bad down here, but it doesn\'t stop me from hiding here.',
			Party = {
				{ name = 'Voltorb', level = 42 },
				{ name = 'Electrode', level = 42 },
				{ name = 'Gothitelle', level = 43 },
				{ name = 'Electrode', level = 42 },
				{ name = 'Magneton', level = 42 },
			}
		},
		{ -- [#101] : Anthian Sewers - Rookie
			Name = 'Austin',
			IntroPhrase = {'There are a lot of icky Pokemon that live down here.',
				'I\'m actually here to collect some of them.',
				'Does that make me icky too?'},
			LosePhrase = 'Your pokemon aren\'t icky enough.',
			Interact = {'There are also some Electric-type pokemon down here that like to feed on the electrical wires that run through here.',
				'The lab workers are constantly having to fix the outages caused by the pokemon.'},
			Party = {
				{ name = 'Grimer', level = 43 },
				{ name = 'Trubbish', level = 43 },
				{ name = 'Muk', level = 45 },
				{ name = 'Mightyena', level = 44 },
			}
		},
		{ -- [#102] : Anthian Sewers - Punk Guy
			Name = 'Hunter',
			IntroPhrase = {'Yo yo yo, you here to join my fight club?',
				'If you beat me in battle, I\'ll tell you the number one rule of my fight club.'},
			LosePhrase = {'Well, you beat me.', 'I\'ll tell you the rule now.'},
			Interact = {'The number one rule of my fight club is to tell everyone about my fight club.',
				'Seriously, nobody knows about it, and I\'m down here all alone with nobody to fight.'},
			Party = {
				{ name = 'Scraggy', level = 44 },
				{ name = 'Scrafty', level = 45 },
				{ name = 'Machoke', level = 45 },
				{ name = 'Machamp', level = 46 }
			}
		},
		{ -- [#103] : Anthian Sewers - Adventurer
			Name = 'Mitchel',
			IntroPhrase = {'I came down here looking for something new to explore.',
				'What I found was a horrible stench instead.',
				'I can\'t go on any further.', 'Let\'s just have a battle instead.'},
			LosePhrase = 'This is a sign that I should just turn around.',
			Interact = 'There aren\'t many places to explore in Anthian City for someone who\'s lived here their whole life.',
			Party = {
				{ name = 'Magcargo', level = 44 },
				{ name = 'Magneton', level = 44 },
				{ name = 'Rhydon', level = 44 },
				{ name = 'Doduo', level = 43 },
				{ name = 'Gligar', level = 45 },
			}
		},
		{ -- [#104] : Anthian Sewers - Scientist
			Name = 'Max',
			IntroPhrase = {'I prefer staying in my office.',
				'I\'m pretty far away from the awful smells in here.',
				'Plus, I have air conditioning.'},
			LosePhrase = 'Well, at least I still have an air-conditioned room.',
			Interact = {'Oh crud, it seems the air conditioner has broken.', 'That\'s bad news for me.'},
			Party = {
				{ name = 'Porygon2', level = 45 },
				{ name = 'Klang', level = 44 },
				{ name = 'Magneton', level = 45 },
				{ name = 'Ampharos', level = 46 },
			}
		},
		{ -- [#105] : Anthian Park - Professor Cypress
			Name = 'Professor Cypress',
			TrainerDifficulty = 4,
			Payout = 200 * 55,
			LosePhrase = 'How did this happen...',
			Party = {
				{ name = 'Venusaur', level = 50, moves = {
					{ id = 'solarbeam' },{ id = 'sludgebomb' },
					{ id = 'synthesis' },{ id = 'sleeppowder' },
				}},
				{ name = 'Feraligatr', level = 50, moves = {
					{ id = 'icepunch' },{ id = 'earthquake' },
					{ id = 'screech' }, { id = 'aquatail' },
				}},
				{ name = 'Blaziken', level = 50, moves = {
					{ id = 'bravebird' },{ id = 'nightslash' },
					{ id = 'blazekick' },{ id = 'thunderpunch' },
				}},
				{ name = 'Torterra', level = 50, moves = {
					{ id = 'earthquake' },{ id = 'woodhammer' },
					{ id = 'stoneedge' }, { id = 'synthesis' },
				}},
				{ name = 'Samurott', level = 50, moves = {
					{ id = 'icebeam' },{ id = 'dig' },
					{ id = 'brine' },  { id = 'dragontail' },
				}},
				{ name = 'Delphox', level = 50, moves = {
					{ id = 'psychic' }, { id = 'flamethrower' },
					{ id = 'calmmind' },{ id = 'dazzlinggleam' },
				}}
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('EnteredPast')
			end,
			onLose = function(PlayerData)
				PlayerData:undoGiveStoryAbsol()
			end
		},
		{ -- [#106] : Anthian Energy Core - Tyler
			Name = 'Eclipse Admin Tyler',
			TrainerDifficulty = 4,
			Payout = 80 * 40,
			LosePhrase = 'Well, I really blew that one.',
			Party = {
				{ name = 'Electrode', level = 40, moves = {{id = 'explosion'}}},
				{ name = 'Electrode', level = 40, moves = {{id = 'explosion'}}},
				{ name = 'Electrode', level = 40, moves = {{id = 'explosion'}}},
				{ name = 'Solrock',   level = 40, moves = {{id = 'explosion'}}},
				{ name = 'Lunatone',  level = 40, moves = {{id = 'explosion'}}}
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('DefeatTEinAC') -- woot
			end
		},
		-- MIGRATING OLD BATTLES:
		{ -- [#107] : Mitas Laboratory - Jake
			Name = 'Pokemon Trainer Jake',
			TrainerDifficulty = 1,
			Payout = 40 * 5,
			LosePhrase = 'Amazing!',
			Party = {
				{ name = 'Eevee', level = 5,
					gender = 'M', ivs = {1,1,1,1,1,1},
					ability = 'Run Away', nature = 'Hardy', moves = {
						{ id = 'growl' }, { id = 'helpinghand' },
						{ id = 'tackle' },{ id = 'tailwhip' },
					}}
			},
			onComplete = function(PlayerData)
				PlayerData:completeEventServer('JakeBattle1')
				PlayerData:addBagItems({id = 'bronzebrick', quantity = 1}, {id = 'pokeball', quantity = 5})
				PlayerData:heal()
			end
		},
		{ -- [#108] : Gale Forest - Linda
			Name = 'Eclipse Member Linda',
			TrainerDifficulty = 1,
			Payout = 40 * 9,
			LosePhrase = 'Beaten by a kid... ugh...',
			Party = {
				{ name = 'Poochyena', level = 7,
					gender = 'F', ivs = {6,6,6,6,6,6},
					ability = 'Run Away', nature = 'Hardy' },
				{ name = 'Pancham', level = 9,
					gender = 'F', ivs = {6,6,6,6,6,6},
					ability = 'Iron Fist', nature = 'Adamant' }
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('BronzeBrickRecovered')
			end
		},
		{ -- [#109] : Gym 1 - Leader Chad
			Name = 'Gym Leader Chad',
			TrainerDifficulty = 2,
			Payout = 160 * 14,
			LosePhrase = {'You beat me fair and square.', 'Maybe I should have played a different beat.'},
			Party = {
				{ name = 'Shinx', level = 13,
					gender = 'M', ivs = {12, 12, 12, 12, 12, 12},
					moves = {{id = 'chargebeam'},{id = 'charge'},
						{id = 'tackle'}},
					ability = 'Intimidate', nature = 'Hardy' },
				{ name = 'Pikachu', level = 14,
					gender = 'M', ivs = {12, 12, 12, 12, 12, 12},
					moves = {{id = 'chargebeam'},{id = 'quickattack'},
						{id = 'thunderwave'}},
					ability = 'Static', nature = 'Lax'}
			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(1, 57)
			end
		},
		{ -- [#110] : Route 5 - Jake
			Name = 'Pokemon Trainer Jake',
			TrainerDifficulty = 1,
			Payout = 40 * 15,
			LosePhrase = 'You\'re still a better trainer!',
			Party = {
				{ name = 'Eevee', level = 15,
					gender = 'M', ivs = {8,8,8,8,8,8},
					ability = 'Run Away', nature = 'Hardy' },
				{ name = 'Blitzle', level = 15,
					gender = 'M', ivs = {8,8,8,8,8,8},
					ability = 'Motor Drive', nature = 'Hardy' },
				{ name = 'Nidoran[m]', -- OVH  verify
					level = 15,
					gender = 'M', ivs = {8,8,8,8,8,8},
					ability = 'Rivalry', nature = 'Hardy' }
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('JakeBattle2')
			end
		},
		{ -- [#111] : Mt. Igneus - Eclipse Admin Harry
			Name = 'Eclipse Admin Harry',
			TrainerDifficulty = 3,
			Payout = 80 * 18,
			LosePhrase = 'You little twerp...',
			Party = {
				{ name = 'Honedge', level = 17,
					gender = 'M', ivs = {18,18,18,18,18,18},
					ability = 'No Guard', nature = 'Adamant' },
				{ name = 'Vullaby', level = 17,
					gender = 'F', ivs = {18,18,18,18,18,18},
					ability = 'Overcoat', nature = 'Adamant' },
				{ name = 'Lunatone', level = 18,
					gender = '', ivs = {18,18,18,18,18,18},
					ability = 'Levitate', nature = 'Modest' }
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('GroudonScene')
			end
		},
		{ -- [#112] : Gym 2 - Leader Sebastian
			Name = 'Gym Leader Sebastian',
			TrainerDifficulty = 2,
			Payout = 160 * 25,
			LosePhrase = {'Good work.', 'You really do have quite the potential.'},
			Party = {
				{ name = 'Litleo', level = 22,
					gender = 'M', ivs = {17, 17, 17, 17, 17, 17},
					moves = {{id = 'overheat'},{id = 'takedown'},
						{id = 'nobleroar'}},
					ability = 'Rivalry', nature = 'Hardy' },
				{ name = 'Growlithe', level = 22,
					gender = 'M', ivs = {17, 17, 17, 17, 17, 17},
					moves = {{id = 'overheat'},{id = 'reversal'},
						{id = 'flamewheel'}},
					ability = 'Intimidate', nature = 'Hardy' },
				{ name = 'Magmar', level = 25,
					gender = 'M', ivs = {17, 17, 17, 17, 17, 17},
					moves = {{id = 'overheat'},{id = 'feintattack'},
						{id = 'flameburst'}},
					ability = 'Flame Body', nature = 'Modest' }
			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(2, 50)
			end
		},
		{ -- [#113] : Gym 3 - Leader Quentin
			Name = 'Gym Leader Quentin',
			TrainerDifficulty = 2,
			Payout = 160 * 37,
			LosePhrase = 'You... You really are quite strong after all.',
			Party = {
				{ name = 'Wailmer', level = 35,
					gender = 'F', ivs = {17, 17, 17, 17, 17, 17},
					moves = {{id = 'scald'},{id = 'brine'},
						{id = 'rollout'}},
					ability = 'Water Veil', nature = 'Modest' },
				{ name = 'Gorebyss', level = 37,
					gender = 'F', ivs = {17, 17, 17, 17, 17, 17},
					moves = {{id = 'scald'},{id = 'psychic'},
						{id = 'drainingkiss'}},
					ability = 'Swift Swim', nature = 'Modest' },
				{ name = 'Huntail', level = 37,
					gender = 'M', ivs = {17, 17, 17, 17, 17, 17},
					moves = {{id = 'scald'},{id = 'crunch'},
						{id = 'icefang'}},
					ability = 'Swift Swim', nature = 'Adamant' }
			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(3, 55)
			end
		},
		-- resume added order
		{ -- [#114] : Route 11 - Hiker
			Name = 'Alec',
			Weather = 'sandstorm',
			IntroPhrase = {'Not much sand can beat down on me standing in the crevices of these rocks.',
				'It\'s also pleasantly shady over here.', 'Perfect spot for a battle.'},
			LosePhrase = 'The sand isn\'t the only thing beating on me today.',
			Interact = 'Sandstorms can cause damage to Pokemon, so I choose to stay out of the sand myself.',
			RematchQuestion = {'A good Pokemon battle will help keep us out of the sun and sand.', 'How about a rematch?'},
			Party = {
				{ name = 'Graveler', level = 44 },
				{ name = 'Rhydon', level = 45 },
				{ name = 'Graveler', level = 44 },
				{ name = 'Onix', level = 43 },
			}
		},
		{ -- [#115] : Route 11 - Survivalist
			Name = 'Peter',
			Weather = 'sandstorm',
			IntroPhrase = {'The key to surviving in the desert is making sure you stay hydrated.',
				'The best place to find water in the desert is in the cacti you find.',
				'Be careful of their needles, though.'},
			LosePhrase = 'There goes my water supply.',
			Interact = 'Cacnea don\'t like to share their water, so I get mine from cactus plants.',
			Party = {
				{ name = 'Cacnea', level = 44 },
				{ name = 'Cacnea', level = 44 },
				{ name = 'Cacnea', level = 44 },
				{ name = 'Cacnea', level = 44 },
				{ name = 'Cacnea', level = 44 },
				{ name = 'Cacnea', level = 44 }
			}
		},
		{ -- [#116] : Route 11 - Paleontologist
			Name = 'Aria',
			Weather = 'sandstorm',
			IntroPhrase = {'I\'m here looking for ancient remains of life.',
				'There are signs that there may have been a significant amount of lush life here in the past.',
				'I think I may be on to something, but I wouldn\'t mind taking a break to battle.'},
			LosePhrase = 'I\'ve learned all I can from this battle.',
			Interact = 'Learning about the past can help us determine the future.',
			RematchQuestion = {'I think I learned from our last battle.',
				'Would you give me another chance for a fight to see if I\'ve improved?'},
			Party = {
				{ name = 'Diglett', level = 44 },
				{ name = 'Drilbur', level = 44 },
				{ name = 'Dugtrio', level = 45 },
				{ name = 'Sandslash', level = 45 }
			}
		},
		{ -- [#117] : Route 11 - Rising Star
			Name = 'Darren',
			Weather = 'sandstorm',
			IntroPhrase = {'I\'m here practicing for my audition that I\'m taking for a new movie that\'s filming.',
				'It\'s about a boy and his Pokemon in the desert and how they fight to survive.',
				'Would you mind battling me to help me get into my character?'},
			LosePhrase = 'That was perfect, except the part where I lost.',
			Interact = {'Getting into character for a movie isn\'t easy.', 'It helps to start off with a battle, though.'},
			RematchQuestion = 'Would you battle me again to help me get back into character?',
			Party = {
				{ name = 'Krokorok', level = 46 },
				{ name = 'Trapinch', level = 45 },
				{ name = 'Krokorok', level = 46 },
			}
		},
		{ -- [#118] : Route 11 - Punk Guy
			Name = 'Draysen',
			Weather = 'sandstorm',
			IntroPhrase = {'Yo, I ain\'t happy.', 'I got sand in places it shouldn\'t be, plus I\'m lost out in this nasty heat, yo.',
				'You know what, forget it.', 'Let\'s just have a battle, know what I\'m sayin\'?'},
			LosePhrase = 'Yo, I can\'t get nothin\' right today.',
			Interact = 'If I wasn\'t raised in the heat, I would be in bad shape, you know?',
			RematchQuestion = {'I guess I can have another battle, yo.', 'What do you say?'},
			Party = {
				{ name = 'Scrafty', level = 46 },
				{ name = 'Krokorok', level = 45 },
				{ name = 'Cacnea', level = 45 },
				{ name = 'Cacturne', level = 46 }
			}
		},
		{ -- [#119] : Route 11 - Adventurer
			Name = 'Tommy',
			Weather = 'sandstorm',
			IntroPhrase = {'My adventures have taken me to many places around the world.',
				'This desert is by far the hottest I\'ve been in.',
				'I\'d take this over the cold any day, though.', 'I love the heat.',
				'Let me show you what I mean.'},
			LosePhrase = 'I got burned out, I suppose.',
			Interact = {'I\'m not complaining about the heat out here when I say it\'s the hottest place I\'ve ever been.',
				'My Pokemon and I don\'t mind it.'},
			Party = {
				{ name = 'Magcargo', level = 46 },
				{ name = 'Magmar', level = 45 },
				{ name = 'Camerupt', level = 46 }
			}
		},
		{ -- [#120] : SANTA FREAKIN' CLAUS
			Name = 'Santa Claus',
			TrainerDifficulty = 4,
			Payout = 1225,
			LosePhrase = 'You might have just earned a spot on the naughty list.',
			Party = {
				{ name = 'Stantler', level = 55,
					gender = 'M', ability = 'Intimidate',
					moves = {{id = 'takedown'},{id = 'zenheadbutt'},
						{id = 'jumpkick'},{id = 'mefirst'}}},
				{ name = 'Stantler', level = 55,
					gender = 'M', ability = 'Intimidate',
					moves = {{id = 'takedown'},{id = 'zenheadbutt'},
						{id = 'jumpkick'},{id = 'mefirst'}}},
				{ name = 'Stantler', level = 55,
					gender = 'M', ability = 'Intimidate',
					moves = {{id = 'takedown'},{id = 'zenheadbutt'},
						{id = 'jumpkick'},{id = 'mefirst'}}},
				{ name = 'Stantler', level = 55,
					gender = 'M', ability = 'Intimidate',
					moves = {{id = 'takedown'},{id = 'zenheadbutt'},
						{id = 'jumpkick'},{id = 'mefirst'}}},
				{ name = 'Stantler', level = 55,
					gender = 'M', ability = 'Intimidate',
					moves = {{id = 'takedown'},{id = 'zenheadbutt'},
						{id = 'jumpkick'},{id = 'mefirst'}}},
				{ name = 'Stantler', level = 70, forme = 'santa', -- special "Rudolph" Stantler
					gender = 'M', ability = 'Intimidate',
					moves = {{id = 'takedown'},{id = 'zenheadbutt'},
						{id = 'jumpkick'},{id = 'mefirst'}}},
			},
			onWin = function(PlayerData)
				-- honestly we should error when they attempt to start this battle from now on
				PlayerData:completeEventServer('BeatSanta')
			end
		},
		{ -- [#121] : The Test Battle
			Name = 'Pops',
			TrainerDifficulty = 2,
			Payout = 5,
			LosePhrase = 'I lose.',
			Party = {
				{name = 'Gengar', level = 50, moves = {{id = 'splash'}}}
			}
			-- should error if launched on a real server
		},
		{ -- [#122] : Gym 5 - Miner
			Name = 'Chuck',
			InteractRequired = true,
			IntroPhrase = {'I\'m your first opponent.', 'If you want a shovel to dig into this dirt, you\'ll need to beat me.'},
			LosePhrase = 'Well, you\'ve earned yourself a shovel.',
			Interact = {'The shovel will only get you through the dirt.',
				'You\'ll need a pickaxe to take on the stone below.'},
			WinEvent = 'G5GetShovel',
			Party = {
				{name = 'Gastrodon', level = 53},
				{name = 'Whiscash', level = 53}
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('G5Shovel')
			end
		},
		{ -- [#123] : Gym 5 - Miner
			Name = 'Stanley',
			InteractRequired = true,
			IntroPhrase = {'Hey, careful where you swing your tools!',
				'This safety helmet only protects my head.',
				'How about we battle to make up for that wild intrusion?'},
			LosePhrase = 'Your pokemon fight like you dig: wildly.',
			Interact = {'If you\'re looking for the pickaxe to mine the stone, I don\'t have it.',
				'Sorry, you\'ll have to keep looking.'},
			Party = {
				{name = 'Donphan', level = 53},
				{name = 'Hippowdon', level = 53}
			}
		},
		{ -- [#124] : Gym 5 - Miner
			Name = 'Carson',
			InteractRequired = true,
			IntroPhrase = {'You\'re looking for the pickaxe?',
				'I might be able to help you with that, but first I want to have a battle.'},
			LosePhrase = 'Alright, you can have it.',
			Interact = {'The pickaxe will allow you to dig even deeper into the ground.',
				'The stone doesn\'t stand a chance against it.'},
			WinEvent = 'G5GetPickaxe',
			Party = {
				{name = 'Stunfisk', level = 52},
				{name = 'Stunfisk', level = 52},
				{name = 'Golurk', level = 53}
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('G5Pickaxe')
			end
		},
		{ -- [#125] : Gym 5 - Miner
			Name = 'Chance',
			InteractRequired = true,
			IntroPhrase = {'The Gym Leader likes to hide out near this part of the mines.',
				'Don\'t give up looking for him.'},
			LosePhrase = 'You are now one step closer to finding our gym leader.',
			Interact = {'Like I said, the Gym Leader is somewhat close to here.',
				'Don\'t give up looking for him.'},
			Party = {
				{name = 'Donphan', level = 53},
				{name = 'Gliscor', level = 53}
			}
		},
		{ -- [#126] : Gym 5 - Leader Ryan
			Name = 'Prince Ryan',
			TrainerDifficulty = 4,
			Payout = 160 * 57,
			LosePhrase = 'I dig your technique!',
			--			ExperimentalAI = true,
			Party = {
				{ name = 'Quagsire', level = 55, moves = { -- todo: make AI use super-effective moves first
					{ id = 'bulldoze' },{ id = 'slam' },
					{ id = 'icebeam' }, { id = 'muddywater' },
				}},
				{ name = 'Steelix', level = 56, ability = 'Sturdy', moves = {
					{ id = 'bulldoze' },{ id = 'thunderfang' },
					{ id = 'aquatail' },{ id = 'irontail' },
				}},
				{ name = 'Claydol', level = 56, moves = {
					{ id = 'bulldoze' },{ id = 'shadowball' },
					{ id = 'psychic' }, { id = 'dazzlinggleam' },
				}},
				{ name = 'Excadrill', level = 56, moves = {
					{ id = 'bulldoze' },{ id = 'metalclaw' },
					{ id = 'xscissor' },{ id = 'poisonjab' },
				}},
				{ name = 'Garchomp', level = 57,
					item = 'garchompite', moves = {
						{ id = 'bulldoze' },{ id = 'dragonclaw' },
						{ id = 'firefang' },{ id = 'ironhead' },
					}},
			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(5, 78)
				PlayerData:completeEventServer('RJO')
			end
		},
		{ -- [#127] : Old Aredia - Survivalist
			Name = 'Sanders', 
			IntroPhrase = {'I\'m not a robber, I swear!', 'I just like surprising trainers with a battle.'},
			LosePhrase = 'I guess my surprise didn\'t work to my advantage.',
			Interact = 'Not many people run through here so I\'m really just wasting my time.',
			Party = {
				{name = 'Maractus', level = 47},
				{name = 'Hippowdon', level = 47},
				{name = 'Dunsparce', level = 46},
			}
		},
		{ -- [#128] : Old Aredia - Thief
			Name = 'Tomas',
			IntroPhrase = {'Surrender your Pokemon to me at once.',
				'No you say?', 'Well then we\'ll battle for them.'},
			LosePhrase = 'This was a mistake.',
			Interact = 'I wait in the shadows and challenge trainers to a match of high stakes.',
			Party = {
				{name = 'Nuzleaf', level = 45},
				{name = 'Liepard', level = 46},
				{name = 'Shiftry', level = 47},
			}
		},
		{ -- [#129] : Old Aredia - Adventurer
			Name = 'Samson',
			IntroPhrase = {'I just got out of the castle.',
				'There isn\'t much that I could find in there.',
				'Pretty neat piece of history, though.',
				'I\'m ready for a battle now!'},
			LosePhrase = 'Time for my next adventure.',
			Interact = {'I love getting out and seeing the world.',
				'Places like this really bring history to life for me.'},
			Party = {
				{name = 'Gallade', level = 46},
				{name = 'Gardevoir', level = 46}
			}
		},
		{ -- [#130] : Castle Ruins - Ancient King
			Name = 'The Ancient King',
			TrainerDifficulty = 4,
			Payout = 32 * 55,
			LosePhrase = 'You are worthy...',
			Party = {
				{name = 'Nidoking', level = 55},
				{name = 'Gengar', level = 55},
				{name = 'Cofagrigus', level = 55},
				{name = 'Aegislash', level = 55}
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('BJO')
			end
		},
		{ -- [#131] : Castle Ruins - Eclipse Grunt
			TrainerClass = 'Eclipse Grunt',
			Name = 'Eclipse Grunt Anais',
			LosePhrase = 'Tch!',
			Party = {
				{name = 'Arbok', level = 53},
				{name = 'Skuntank', level = 53},
				{name = 'Shiftry', level = 54}
			},
			onWin = function(PlayerData)
				PlayerData.flags.winBattle131 = true
			end
		},
		{ -- [#132] : Castle Ruins - Eclipse Grunt
			TrainerClass = 'Eclipse Grunt',
			Name = 'Eclipse Grunt Larry',
			LosePhrase = 'Great! Ugh...',
			Party = {
				{name = 'Raichu', level = 53},
				{name = 'Trevenant', level = 53}
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle131 then return end
				PlayerData:completeEventServer('TEinCastle')
				PlayerData:obtainTM(6, true)
			end
		},
		{ -- [#133] : Route 12 - Adventurer
			Name = 'Simon',
			IntroPhrase = {'The tall rocks leading to the mountains have sheltered this area so that it can grow luscious life so close to the hot desert.',
				'My Pokemon and I come here to admire its beauty.', 'We also come here to battle trainers.'},
			LosePhrase = 'I wasn\'t quite prepared for that.',
			Interact = {'The life of an adventurer is always full of twists and turns.',
				'You never know what natural miracles you will turn out to find.'},
			Party = {
				{name = 'Ursaring', level = 50},
				{name = 'Donphan', level = 50},
				{name = 'Pupitar', level = 50}
			}
		},
		{ -- [#134] : Route 12 - Picnicker
			Name = 'Sandy',
			IntroPhrase = {'Tall grass is so itchy, not to mention there are always scary wild Pokemon waiting for you in them.',
				'Let\'s have a battle away from the itchy grass.'},
			LosePhrase = 'Losing battles also makes me itchy.',
			Interact = {'The life outside is probably not meant for me, after all.',
				'It\'s never too late to change who you are and what you do.'},
			Party = {
				{name = 'Wigglytuff', level = 50},
				{name = 'Florges', level = 50}
			}
		},
		{ -- [#135] : Route 12 - Camper
			Name = 'Henry',
			IntroPhrase = {'Running through the tall grass in my jeans is what life is all about.',
				'The wild Pokemon are usually the ones surprised to see me.'},
			LosePhrase = 'I\'m the surprised one now.',
			Interact = {'I love being outdoors.', 'When the weather is great like this, I can\'t help but stay out and battle with my Pokemon!'},
			RematchQuestion = 'Speaking of battling, would you like to have another battle?',
			Party = {
				{name = 'Tauros', level = 51},
				{name = 'Tauros', level = 51},
				{name = 'Miltank', level = 52}
			}
		},
		{ -- [#136] : Route 12 - Hiker
			Name = 'Garret',
			IntroPhrase = {'This route is full of twists and turns.', 'It can get confusing pretty quickly.',
				'Maybe a battle will help me gather my sense of direction.'},
			LosePhrase = 'Oh that\'s right, my pokemon can give me directions.',
			Interact = 'For a hiker, I sure do lose my way a lot.',
			Party = {
				{name = 'Nosepass', level = 54},
				{name = 'Nosepass', level = 54},
				{name = 'Nosepass', level = 54},
				{name = 'Nosepass', level = 54},
				{name = 'Probopass', level = 54}
			}
		},
		{ -- [#137] : Route 12 - Gentleman
			Name = 'Harrison',
			IntroPhrase = {'Hello, I bet you weren\'t expecting me.', 'My Pokemon are surprisingly tough.'},
			LosePhrase = 'Well that\'s not right.',
			Interact = 'My Pokemon are always ready for a surprise challenge.',
			Party = {
				{name = 'Arcanine', level = 54},
				{name = 'Zebstrika', level = 54}
			}
		},
		{ -- [#138] : Route 12 - Schoolgirl
			Name = 'Gabby',
			IntroPhrase = {'This bridge always has the most lovely breeze blowing through it.',
				'It makes the perfect environment for a battle.'},
			LosePhrase = 'That battle blew me away.',
			Interact = {'I have to be careful of the winds here.', 'Sometimes my Pokemon can get swept away by the breeze.'},
			Party = {
				{name = 'Hoppip', level = 55},
				{name = 'Skiploom', level = 55},
				{name = 'Jumpluff', level = 55}
			}
		},
		{ -- [#139] : Route 12 - Fisherman
			Name = 'Patrick',
			IntroPhrase = {'The fish just aren\'t biting for me today.', 'Maybe I should give fishing a break and have a battle.'},
			LosePhrase = 'I\'m not having luck with battling, either.',
			Interact = 'I did have a bite earlier today but I didn\'t reel in fast enough.',
			Party = {
				{name = 'Magikarp', level = 56},
				{name = 'Gyarados', level = 54},
				{name = 'Qwilfish', level = 54}
			}
		},-- [[
		{ -- [#140] : Route 13 - Collector
			Name = 'Simon',
			IntroPhrase = {'Are you on your way to Fluoruma City?', 'I bet you are on your way to challenge the gym.',
				'That would make you a trainer.', 'If that\'s the case, we should have a battle.'},
			LosePhrase = 'You might have beaten me, but that doesn\'t mean you\'re ready for the gym battle ahead.',
			Interact = {'I tried fighting at the Fluoruma City gym.', 'I didn\'t even make it to the Gym Leader.'},
			Party = {
				{name = 'Volbeat', level = 54},
				{name = 'Illumise', level = 54}
			}
		},
		{ -- [#141] : Route 13 - Black Belt
			Name = 'Hagar',
			IntroPhrase = {'This mushroom actually produces some heat from its light.',
				'I stand here between training sessions to relax my body.',
				'I think I\'m ready now for my next session.'},
			LosePhrase = 'Time to relax again',
			Interact = {'This cave is full of so many mysteries.',
				'I can\'t wrap my head around how these plants are producing so much light!'},
			RematchQuestion = 'I guess I\'ll just have another battle instead, if thats alright with you?',
			Party = {
				{name = 'Scrafty', level = 54},
				{name = 'Poliwrath', level = 54}
			}
		},
		{ -- [#142] : Route 13 - Journalist
			Name = 'Peter',
			IntroPhrase = {'I\'m writing an article on the bioluminescent life found in this cave.',
				'I\'ve determined so far that the plants draw their energy from the large, glowing crystals.',
				'So naturally, I\'ve gathered some crystal-like Pokemon to battle with for further research.'},
			LosePhrase = 'I guess my connection between Pokemon and crystals was not so helpful.',
			Interact = 'I need a scientist now to help me make a final conclusion for the article I\'m writing on these crystals and the life it brings to these plants.',
			Party = {
				{name = 'Carbink', level = 54},
				{name = 'Sableye', level = 54},
				{name = 'Gigalith', level = 54}
			}
		},
		{ -- [#143] : Gym 6 - Camper
			Name = 'Samuel',
			IntroPhrase = {'I just finished plucking this peach from that tree.', 'If you want it, you\'ll have to battle me for it. Deal?'},
			LosePhrase = 'Alright, it\'s yours.',
			Interact = {'The peach is one of several fruits we grow in these gardens.',
				'You will need to toss it into the bucket, along with other fruit, to get to the gym leader.'},
			Party = {
				{name = 'Simisage', level = 57},
				{name = 'Sunflora', level = 57}
			}
		},
		{ -- [#144] : Gym 6 - Picnicker
			Name = 'Gale',
			IntroPhrase = {'Looks like you were able to find some scrap wood to rebuild that bridge.',
				'You\'re really handy to have around here.', 'I suppose you\'re just here for a badge, though.',
				'If that\'s the case, I\'ll need to test your skills before you can take my apple.'},
			LosePhrase = 'You are pretty skilled after all.',
			Interact = {'We do appreciate the help we get from trainers.',
				'Creating the gym\'s challenges was the only way for us to get help from trainers.'},
			Party = {
				{name = 'Meganium', level = 57},
				{name = 'Serperior', level = 57},
			}
		},
		{ -- [#145] : Gym 6 - Camper
			Name = 'Davis',
			IntroPhrase = {'The giant fruit you find in this garden are made possible by Grass-type Pokemon.',
				'We challenge trainers to return the fruit to the basket mostly because we get tired of carrying them ourselves.'},
			LosePhrase = 'Battles can also be quite tiring.',
			Interact = {'You\'re quite a strong trainer.', 'I have no doubt that you can carry some oversized fruit.'},
			Party = {
				{name = 'Leafeon', level = 57},
				{name = 'Parasect', level = 57}
			}
		},
		{ -- [#146] : Gym 6 - Picnicker
			Name = 'Beth',
			IntroPhrase = {'One of these bushes grows blueberries, but I can\'t seem to remember which one it was.',
				'Maybe a battle will jog my memory?'},
			LosePhrase = 'Nope, that didn\'t help.',
			Interact = 'I\'m nowhere close to finding those blueberries.',
			Party = {
				{name = 'Vileplume', level = 57},
				{name = 'Victreebel', level = 57}
			}
		},
		{ -- [#147] : Gym 6 - Leader Fissy
			Name = 'Gym Leader Fissy',
			TrainerDifficulty = 4,
			Payout = 160 * 66,
			LosePhrase = 'What an exciting match!',
			Party = {
				{ name = 'Leavanny', level = 64, ivs = {25, 25, 25, 25, 25, 31},
					evs = {0, 200, 60, 0, 0, 252}, moves = {
						{ id = 'electroweb' },{ id = 'slash' },
						{ id = 'stickyweb' }, { id = 'xscissor' },
					}, strategy = function(_, side) if not side.foe.sideConditions.stickyweb then return 'stickyweb' end end},
				{ name = 'Tropius', level = 65, moves = {
					{ id = 'steelwing' },{ id = 'energyball' },
					{ id = 'synthesis' },{ id = 'earthquake' },
				}},
				{ name = 'Breloom', level = 64, ability = 'Technician', moves = {
					{ id = 'spore' },   { id = 'machpunch' },
					{ id = 'rocktomb' },{ id = 'seedbomb' },
				}},
				{ name = 'Roserade', level = 65, ability = 'Poison Point', moves = {
					{ id = 'solarbeam' },{ id = 'toxic' },
					{ id = 'sunnyday' }, { id = 'venoshock' },
				}, strategy = function(_, _, _, target) if target.status == '' and not target:hasType('Poison', 'Steel') then return 'toxic' end end},
				{ name = 'Tangrowth', level = 65, ability = 'Chlorophyll', moves = { -- grassy terrain and power whip
					{ id = 'solarbeam' },{ id = 'knockoff' },
					{ id = 'sunnyday' }, { id = 'ancientpower' },
				}, strategy = function(battle) if not battle:isWeather({'sunnyday', 'desolateland'}) then return 'sunnyday' end end},
				{ name = 'Venusaur', level = 66,
					item = 'venusaurite', moves = {
						{ id = 'solarbeam' },{ id = 'earthquake' },
						{ id = 'sunnyday' }, { id = 'sludgebomb' },
					}},
			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(6, 22)
			end
		},
		{ -- [#148] : Route 14 (Ruins) - Punk Guy
			Name = 'Nathaniel',
			IntroPhrase = {'Hey you, looks like you got skills, yo.',
				'Let\'s put those skills to the test now.'},
			LosePhrase = 'Alright, I see where what you\'re all about.',
			Interact = 'Yeah, I got mad respect for you now.',
			RematchQuestion = {'I\'ll even let you battle me again.', 'What do you think?'},
			Party = {
				{name = 'Scrafty', level = 56},
				{name = 'Krookodile', level = 56},
				{name = 'Cacturne', level = 56}
			}
		},
		{ -- [#149] : Route 14 (Ruins) - Adventurer
			Name = 'Zach',
			IntroPhrase = {'I\'m here in search of adventure.',
				'So far I\'ve fallen down a couple rocks, lost my lunch, and can\'t remember which direction I came from.',
				'Maybe I\'ll have better luck with a battle?'},
			LosePhrase = 'Today is just not my day...',
			Interact = {'I\'ll keep wandering around until I find my way out.', 'That\'s how the great adventerers do it.'},
			Party = {
				{name = 'Pidgeot', level = 55},
				{name = 'Ampharos', level = 55},
				{name = 'Skuntank', level = 55},
				{name = 'Sableye', level = 55}
			}
		},
		{ -- [#150] : Route 14 (Ruins) - Rebellious Girl
			Name = 'Rebecca',
			IntroPhrase = {'I like to stand here and stare into the dark abyss and reflect on my life choices.',
				'I also like to battle strangers passing by.'},
			LosePhrase = 'It\'s so dark.',
			Interact = 'The dark emptiness inside this cave reflects my personality quite well.',
			Party = {
				{name = 'Umbreon', level = 55},
				{name = 'Gothitelle', level = 55},
				{name = 'Sneasel', level = 55}
			}
		},
		{ -- [#151] : Route 14 (Ice) - Eclipse Grunt
			TrainerClass = 'Eclipse Grunt',
			Name = 'Eclipse Grunt Wayne',
			LosePhrase = 'Wait, what just happened?',
			Party = {
				{name = 'Arbok', level = 56},
				{name = 'Weezing', level = 56},
				{name = 'Seviper', level = 56}
			},
			onWin = function(PlayerData)
				PlayerData.flags.winBattle151 = true
			end
		},
		{ -- [#152] : Route 14 (Ice) - Eclipse Grunt
			TrainerClass = 'Eclipse Grunt',
			Name = 'Eclipse Grunt Jared',
			LosePhrase = 'Well, I was expecting more from my Pokemon.',
			Party = {
				{name = 'Cacturne', level = 56},
				{name = 'Zangoose', level = 56},
				{name = 'Scrafty', level = 56}
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle151 then return end
				PlayerData.flags.winBattle152 = true
				--				PlayerData:completeEventServer('TEinCastle')
				--				PlayerData:obtainTM(6, true)
			end
		},
		{ -- [#153] : Route 14 (Ice) - Eclipse Admin JAKE?????
			Name = 'Eclipse Admin Jake',
			TrainerDifficulty = 4,
			Payout = 80 * 63,
			LosePhrase = 'I\'m sorry about this...',
			Party = {
				{ name = 'Zebstrika', level = 60--, moves = {
					--					{ id = 'solarbeam' },{ id = 'sludgebomb' },
					--					{ id = 'synthesis' },{ id = 'sleeppowder' },
				},--},
				{ name = 'Nidoking', level = 61--, moves = {
					--					{ id = 'icepunch' },{ id = 'earthquake' },
					--					{ id = 'screech' }, { id = 'aquatail' },
				},--},
				{ name = 'Slowbro', level = 62--, moves = {
					--					{ id = 'bravebird' },{ id = 'nightslash' },
					--					{ id = 'blazekick' },{ id = 'thunderpunch' },
				},--},
				{ name = 'Arcanine', level = 62--, moves = {
					--					{ id = 'earthquake' },{ id = 'woodhammer' },
					--					{ id = 'stoneedge' }, { id = 'synthesis' },
				},--},
				{ name = 'Vaporeon', level = 63--, moves = {
					--					{ id = 'psychic' }, { id = 'flamethrower' },
					--					{ id = 'calmmind' },{ id = 'dazzlinggleam' },
				}--}
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle152 then return end
				PlayerData:completeEventServer('TERt14')
			end
		},
		{ -- [#154] : Gym 6 - Leader Zeek
			Name = 'Gym Leader Zeek',
			TrainerDifficulty = 4,
			Payout = 160 * 66,
			LosePhrase = 'What an exciting match!',
			Party = {
				{ name = 'Honchkrow', level = 72},
				{ name = 'Krookodile', level = 72},
				{ name = 'Bisharp', level = 72},
				{ name = 'Umbreon', level = 73},
				{ name = 'Pangoro', level = 73},
				{ name = 'Houndoom', item = 'houndoominite', level = 74},

			},
			onWin = function(PlayerData)
				PlayerData:winGymBadge(7, 97)
			end
		},


		{-- [#155] : Cosmeos Valley Brett -- Camper
			Name = 'Brett',
			IntroPhrase = {'Are you here for the stargazing, or just passing by?', 'My Pokemon and I love to camp out under the night sky and watch the meteor showers.', 'I also love battling passerby trainers.'},
			LosePhrase = 'I feel like a shooting star. Burned up.',
			Interact = 'Maybe we should just stick to stargazing.',
			Party = {
				{name = 'Staraptor', level = 62},
				{name = 'Mismagius', level = 62},
			}
		},
		{ -- [#156] : Cosmeos Valley Ciel -- Bug Catcher
			Name = 'Ciel',
			IntroPhrase = {'Pokemon evolution is interesting.', 'There are more than one way for Pokemon to evolve.', 'Some form of evolution are still not understood.'},
			LosePhrase = 'I don\'t understand my loss.',
			Interact = 'Maybe I should evolve some more Pokemon.',
			Party = {
				{name = 'Shelmet', level = 64},
				{name = 'Accelgor', level = 64},
			}
		},
		{ -- [#157] : Cosmeos Valley Laura -- Picnicker
			Name = 'Laura',
			IntroPhrase = 'There\'s a fishing hole nearby that supposedly has super rare Magikarps.',
			LosePhrase = 'Well, I guess it\'s time to do something else.',
			Interact = 'Maybe fishing would be a nice thing to do.',
			Party = {
				{name = 'Magikarp', level = 64},
				{name = 'Magikarp', level = 64},
				{name = 'Gyarados', level = 63},
				{name = 'Gyarados', level = 63},
			}
		},
		{ -- [#158] : Cosmeos Valley Luke -- Gentleman
			Name = 'Luke',
			IntroPhrase = {'I take time everyday to go for a walk through the valley.', 'I like to battle the trainers I meet along the path.', 'If you wouldn\'t mind, I\'d like to have a battle with you here.'},
			LosePhrase = 'That was a freshing experience.',
			Interact = 'Thank you for that battle.',
			Party = {
				{name = 'Furfrou', level = 64},
				{name = 'Persian', level = 64},
				{name = 'Liepard', level = 64},
			}
		},
		{ -- [#159] : Cosmeos Valley Luke -- Collector
			Name = 'Jameson',
			IntroPhrase = {'I come here to collect rare stones that fall from the skies.', 'Meteors sometimes collect super rare minerals that are too hard to find anywhere else.'},
			LosePhrase = 'I need to spend less time collecting and more time training.',
			Interact = 'I need to to more training.',
			RematchQuestion = 'Could we have another battle?',
			Party = {
				{name = 'Carbink', level = 63},
				{name = 'Carbink', level = 63},
				{name = 'Sableye', level = 62},
			}
		},--]]
		{ -- [#160] : Cresent Island --Cindy
			Name = 'Cindy',
			IntroPhrase = {'Cresent Island is full of Criminals and Robbers.', 'I Hide around and I avoid everyone if I can.', 'If you wouldn\'t mind, I\'d like to have a battle with you.'},
			LosePhrase = 'Ouch!',
			Interact = 'If I ever wan\'t to be able to avoid people the least I can do is Battle.',
			Party = {
				{name = 'Mandibuzz', level = 68},
				{name = 'Skuntank', level = 68},
			}
		},
		{ -- [#161] : 7th Gym - Adventurer
			Name = 'Sam',
			IntroPhrase = {'Boo!', 'I Bet you didn\'t see me There!'},
			LosePhrase = 'My Battle skills don\'t Match with my Surprise Skills..',
			Interact = 'I Just wait here for Passerby Trainers. I always get them!',
			Party = {
				{name = 'Scrafty', level = 66},
				{name = 'Sableye', level = 68},
				{name = 'Mightyena', level = 68},
			}
		},
		{ -- [#162] : 7th Gym - Rich Boy
			Name = 'Hansen',
			IntroPhrase = {'Oh sure I\'ll Batlle you I have a lot of Money.'},
			LosePhrase = 'How could I lose?',
			Interact = {'Theres so many things Money can\'t Buy.',
				'Pokemon Battles are one of them.'},
			Party = {
				{name = 'Electrode', level = 64},
				{name = 'Liepard', level = 66},
			}
		},
		{ -- [#163] : Route 18- Adventurer
			Name = 'Stanley',
			IntroPhrase = {'There is a cave at the end of this route with a lot of old stories tied to it.',
				'I came out here to see it for myself, but the inside is just a dead end.',
				'It\'s creepy in there.',
				'I think a battle will help me shake off the spooks I got from being in there.'},
			LosePhrase = 'Now I need something to distract me from my loss.',
			Interact = {'I gotta make sure I don\'t stay here for long.',
				'I don\'t trust this place.'},
			Party = {
				{ name = 'Miltank', level = 66, 
					moves = {
						{ id = 'gyroball' }, { id = 'healbell' },
						{ id = 'powerwhip' }, { id = 'captivate' },
					}},
				{ name = 'Aggron', level = 66,
					ability = 'Sturdy', 
					moves = {
						{ id = 'heavyslam' }, { id = 'doubleedge' },
						{ id = 'autotomize' }, { id = 'metalburst' },
					}},
			}
		},
		{ -- [#164] : Route 18- RB
			Name = 'Mindy',
			IntroPhrase = {'This dreadful swamp is the perfect place to get away and enjoy the solitude from others.',
				'That is, until you came along.',
				'If I beat you in a battle, you have to leave.'},
			LosePhrase = 'Well, you may have beaten me, but I\'m not going anywhere.',
			Interact = {'I just want to be alone here.'},
			Party = {
				{ name = 'Mismagius', level = 67,
					ability = 'Levitate', 
					moves = {
						{ id = 'spite' }, { id = 'psywave' },
						{ id = 'growl' }, { id = 'astonish' },
					}},
				{ name = 'Gothitelle', level = 67,
					ability = 'Competitive', 
					moves = {
						{ id = 'magicroom' }, { id = 'telekinesis' },
						{ id = 'psychic' }, { id = 'charm' },
					}},
			}
		},
		{ -- [#165] : Route 18- Adventurer
			Name = 'Axel',
			IntroPhrase = {'I have been battling for a long time now, and I find that the Pokemon on this route are quite strong compared to Pokemon anywhere else in the Roria Region.',
				'That\'s why I spend my time training here.',},
			LosePhrase = 'We\'ll need to spend more time training, I guess.',
			Interact = {'You see the Pokemon here are radiated by the chemicals in the water.',
				'You can encounter a lot of strange Pokemon here.'},
			Party = {
				{ name = 'Swalot', level = 67,
					ability = 'Liquid Ooze', 
					moves = {
						{ id = 'gastroacid' }, { id = 'wringout' },
						{ id = 'gunkshot' }, { id = 'belch' },
					}},
				{ name = 'Drapion', level = 67,
					ability = 'Sniper', 
					moves = {
						{ id = 'crunch' }, { id = 'fellstinger' },
						{ id = 'scaryface' }, { id = 'crosspoison' },
					}},
			}
		},
		{ -- [#166] : GYM 8 - BEACH BUM
			Name = 'Rob',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'I\'ll Be Your First Opponent'},
			LosePhrase = 'That didn\'t Go Well.',
			Interact = {'I didn\'t expect to lose so quickly.'},
			Party = {
				{name = 'Drapion', level = 72},
				{name = 'Mawile', item = 'mawilite', level = 75}

			}
		},
		{ -- [#167] : GYM 8 - BEACH BUM
			Name = 'Tom',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'Well I\'m Your Second Opponent','Lets Battle!'},
			LosePhrase = 'Today is not my lucky day..',
			Interact = {'Im not having a Good Day today.'},
			Party = {
				{name = 'Huntail', level = 73},
				{name = 'Gardevoir', level = 74},
			}
		},
		{ -- [#168] : GYM 8 - ADVENTURER
			Name = 'Larry',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'Hello Im your Third Opponent','Are you ready, Cause I am!'},
			LosePhrase = 'Well..',
			Interact = {'Lets Just say you won for now.'},
			Party = {
				{name = 'Skuntank', level = 74},
				{name = 'Bronzor', level = 74},
				{name = 'Hippowdon', level = 75},
			}
		},
		{ -- [#169] : GYM 8 - SCHOOLGIRL
			Name = 'Sally',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'Hello there!','If you wouldn\'t Mind Id like to Battle.'},
			LosePhrase = 'Tough Loss.',
			Interact = {'I wasn\'t Expecting Defeat thats for sure.'},
			Party = {
				{name = 'Purugly', level = 75},
				{name = 'Delcatty', level = 76},
				{name = 'Medicham', level = 76},
			}
		},
		{ -- [#170] : GYM 8 - SCHOOLGIRL
			Name = 'Dan',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'I wont let you through unless we Battle.','Deal? Ok!'},
			LosePhrase = 'You can pass.',
			Interact = {'You can go through now.'},
			Party = {
				{name = 'Lairon', level = 75},
				{name = 'Volbeat', level = 76},
				{name = 'Sharpedo', level = 76},
			}
		},
		{ -- [#171] : GYM 8 - LADY
			Name = 'Rosa',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'My Pokemon and I are ready to win!'},
			LosePhrase = 'Nevermind then.',
			Interact = {'I regret what I said now.'},
			Party = {
				{name = 'Plusle', level = 76},
				{name = 'Azumarill', level = 76},
			}
		},
		{ -- [#172] : GYM 8 - BLACK BELT
			Name = 'Mike',
			IgnoreWalls = true,
			DontWalk = true,
			IntroPhrase = {'Im the Last trainer.','Lets see what you got!'},
			LosePhrase = 'You are Ready.',
			Interact = {'You can Now go ahead and face the gym leader.'},
			Party = {
				{name = 'Golem', level = 77},
				{name = 'Boldore', level = 77},
			}
		},
		{ -- [#173] : GYM 8 - CAPTAIN B
			Name = 'Gym Leader Captain B',
			TrainerDifficulty = 4,
			Payout = 160 * 66,
			LosePhrase = 'This loss has me spooked. How did you beat me?',
			Party = {
			--[[--test battle	
				{ name = 'Squirtle', level = 2,
					gender = 'M',
					 
					moves = {
						{ id = 'tackle' }, 
					}},
					--]]
				-- [[
				{ name = 'Gengar', level = 81, 
					item = 'Focus Sash',
					ability = 'Cursed Body', 
					moves = {
						{ id = 'shadowclaw' }, { id = 'sludgebomb' },
						{ id = 'focusblast' }, { id = 'destinybond' },
					}},
				{ name = 'Decidueye', level = 81, 
					item = 'Life Orb',
					ability = 'Long Reach', 
					moves = {
						{ id = 'swordsdance' }, { id = 'shadowclaw' },
						{ id = 'leafblade' }, { id = 'suckerpunch' },
					}},
				{ name = 'Spiritomb', level = 81,
					ability = 'Pressure', 
					item = 'Leftovers',
					moves = {
						{ id = 'rest' }, { id = 'calmmind' },
						{ id = 'sleeptalk' }, { id = 'snarl' },
					}},
				{ name = 'Mismagius', level = 81,
					ability = 'Levitate', 
					item = 'Life Orb',
					moves = {
						{ id = 'nastyplot' }, { id = 'powergem' },
						{ id = 'dazzlinggleam' }, { id = 'shadowball' },
					}},

				{ name = 'Aegislash', level = 82,
					ability = 'Stance Change', 
					item = 'Weakness Policy',
					moves = {
						{ id = 'swordsdance' }, { id = 'sacredsword' },
						{ id = 'kingsshield' }, { id = 'shadowclaw' },
					}},
				{ name = 'Sableye', level = 83,
					ability = 'Magic Bounce', 
					item = 'Sablenite',
					moves = {
						{ id = 'toxic' }, { id = 'recover' },
						{ id = 'foulplay' }, { id = 'willowisp' },
					}},
			},




			onWin = function(PlayerData)
				PlayerData:winGymBadge(8, 65)
			end
		},
		{ -- [#174] : ECLIPSE BASE - GRUNT
			Name = 'Jeb',
			IntroPhrase = {'What do we have here?','Are you a new recruit?','You aren\'t in Uniform.','You must be an intruder.','Im the first line of defense in this base.','I\'ll have you finished off and out of here in no time.'},
			LosePhrase = 'Well that\'s just great. The boss won\'t be happy.',
			Interact = {'The boss will be angry at me for letting some kid in.'},
			Party = {
				{name = 'Muk', level = 64},
				{name = 'Toxicroak', level = 64},
			} 
		},
		{ -- [#175] : ECLIPSE BASE - GRUNT
			Name = 'Allan',
			IntroPhrase = {'Are you on your way to the cafeteria?','Wait, you aren\'t a Team Eclipse member.','We\'re going to need to battle.'},
			LosePhrase = 'Well, at least lunch will be ready soon.',
			Interact = {'Im super hungry from standing here all day.'},
			Party = {
				{name = 'Snorlax', level = 65},
			} 
		},
		{ -- [#176] : ECLIPSE BASE - GRUNT
			Name = 'Alex',
			IntroPhrase = {'I am on a Diet.','Since im not eating. Lets Battle'},
			LosePhrase = 'My break is nearly over.',
			Interact = {'My Break is very close to over then I have to get back to work.'},
			Party = {
				{name = 'Slurpuff', level = 65},
			} 
		},
		{ -- [#177] : ECLIPSE BASE - GRUNT
			Name = 'Jeff',
			IntroPhrase = {'Hey!','Its Your Turn to wash the Dishes!'},
			LosePhrase = 'Wow Nevermind Then.',
			Interact = {'I guess you won\'t be Doing any dishes then.'},
			Party = {
				{name = 'Cottonee', level = 66},
			} 
		},
		{ -- [#178] : ECLIPSE BASE - GRUNT
			Name = 'Jeff',
			IntroPhrase = {'This is Not a safe place to be!','You wont leave? Lets Battle Then!'},
			LosePhrase = 'You are free to go.',
			Interact = {'You can go I guess but its not my fault if you get hurt!'},
			Party = {
				{name = 'Kadabra', level = 66},
			} 
		},
		{ -- [#179] : ECLIPSE BASE - GRUNT
			Name = 'Arin',
			IntroPhrase = {'I\'ve Been Observing Pokemon.','I will observe our Battle too.'},
			LosePhrase = 'Well Played.',
			Interact = {'That battle will Help me with my Experiments.'},
			Party = {
				{name = 'Pyroar', level = 66},
				{name = 'Dartrix', level = 67},
			} 
		},
		{ -- [#180] : Route 14 (Ice) - Eclipse Admin JAKE?????
			Name = 'Eclipse Admin Jake',
			TrainerDifficulty = 4,
			Payout = 80 * 63,
			LosePhrase = 'You are still the strongest.',
			Party = {
				{ name = 'Zebstrika', level = 76--, moves = {
					--					{ id = 'solarbeam' },{ id = 'sludgebomb' },
					--					{ id = 'synthesis' },{ id = 'sleeppowder' },
				},--},
				{ name = 'Nidoking', level = 76--, moves = {
					--					{ id = 'icepunch' },{ id = 'earthquake' },
					--					{ id = 'screech' }, { id = 'aquatail' },
				},--},
				{ name = 'Slowbro', level = 77--, moves = {
					--					{ id = 'bravebird' },{ id = 'nightslash' },
					--					{ id = 'blazekick' },{ id = 'thunderpunch' },
				},--},
				{ name = 'Arcanine', level = 77--, moves = {
					--					{ id = 'earthquake' },{ id = 'woodhammer' },
					--					{ id = 'stoneedge' }, { id = 'synthesis' },
				},--},
				{ name = 'Vaporeon', level = 78--, moves = {
					--					{ id = 'psychic' }, { id = 'flamethrower' },
					--					{ id = 'calmmind' },{ id = 'dazzlinggleam' },
				}--}
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle152 then return end
				--PlayerData:completeEventServer('TERt14')
			end
		},
		{ -- [#181] : Route 14 (Ice) - Eclipse Admin JAKE?????
			Name = 'Eclipse Boss Cypress',
			TrainerDifficulty = 4,
			Payout = 80 * 63,
			LosePhrase = 'Hoopa is waiting.',
			Party = {
				{ name = 'Greninja', level = 78--, moves = {
					--					{ id = 'solarbeam' },{ id = 'sludgebomb' },
					--					{ id = 'synthesis' },{ id = 'sleeppowder' },
				},--},
				{ name = 'Decidueye', level = 79--, moves = {
					--					{ id = 'icepunch' },{ id = 'earthquake' },
					--					{ id = 'screech' }, { id = 'aquatail' },
				},--},
				{ name = 'Incineroar', level = 79--, moves = {
					--					{ id = 'bravebird' },{ id = 'nightslash' },
					--					{ id = 'blazekick' },{ id = 'thunderpunch' },
				},--},
				{ name = 'Empoleon', level = 79--, moves = {
					--					{ id = 'earthquake' },{ id = 'woodhammer' },
					--					{ id = 'stoneedge' }, { id = 'synthesis' },
				},--},
				{ name = 'Sceptile', level = 79--, moves = {
					--					{ id = 'earthquake' },{ id = 'woodhammer' },
					--					{ id = 'stoneedge' }, { id = 'synthesis' },
				},--},


				{ name = 'Charizard', item = 'charizarditex', level = 80--, moves = {
					--					{ id = 'psychic' }, { id = 'flamethrower' },
					--					{ id = 'calmmind' },{ id = 'dazzlinggleam' },
				}--}
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle152 then return end
				--PlayerData:completeEventServer('TERt14')
			end
		},
		{ -- [#182] : Route 14 (Ice) - Eclipse Admin JAKE?????
			Name = 'Hoopa',
			TrainerDifficulty = 4,
			Payout = 80 * 63,
			LosePhrase = '...',
			Party = {
				{ name = 'Hoopa-Unbound', level = 65,
					--					{ id = 'solarbeam' },{ id = 'sludgebomb' },
					--					{ id = 'synthesis' },{ id = 'sleeppowder' },
				}
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle152 then return end
				--PlayerData:completeEventServer('TERt14')
			end
		},
		{ -- [# 183] : Route 15 - Zach
			Name = 'Zach',
			IntroPhrase = {'Route 15 is full of Ice-type Pokemon.',
				'They love the frigid conditions up here on top of the Craganos Range.',
				'I\'ll show you the Ice-type Pokemon I\'ve been training!'},
			LosePhrase = 'Your strats were too hot for my Pokemon.',
			Interact = {'My Pokemon really love the cold here.'},
			Party = {
				{ name = 'Snorunt', level = 55, 
					ability = 'Inner Focus', moves = { -- todo: make AI use super-effective moves first
						{ id = 'frostbreath' },{ id = 'crunch' },
						{ id = 'earthquake' }, { id = 'blizzard' },
					}},
				{ name = 'Swinub', level = 55, 
					ability = 'Snow Cloak', moves = {
						{ id = 'earthquake' },{ id = 'flail' },
						{ id = 'blizzard' },{ id = 'amnesia' },
					}},
				{ name = 'Piloswine', level = 56, 
					gender = 'M',
					ability = 'Snow Cloak', moves = {
						{ id = 'thrash' },{ id = 'blizzard' },
						{ id = 'earthquake' }, { id = 'mist' }
					}},
			},
		},

		{ -- [# 184] : Route 15 - Tawnya
			Name = 'Tawnya',
			IntroPhrase = {'The winds up ahead on the bridges made my cheeks so cold!',
				'I should have brought a scarf out with me.',
				'I\'ll need to head back to Frostveil soon.',
				'How about a battle first?'},
			LosePhrase = 'That was a cold loss.',
			Interact = {'I got to go back to Frostveil soon, I\'m freezing!'},
			RematchQuestion = 'But before I go, do you mind having another battle?',
			Party = {


				{ name = 'Snorunt', level = 55, 
					ability = 'Inner Focus', moves = { -- todo: make AI use super-effective moves first
						{ id = 'frostbreath' },{ id = 'crunch' },
						{ id = 'earthquake' }, { id = 'blizzard' },
					}},
				{ name = 'Piloswine', level = 55,
					gender = 'F', 
					ability = 'Snow Cloak', moves = {
						{ id = 'earthquake' },{ id = 'flail' },
						{ id = 'blizzard' },{ id = 'amnesia' },
					}},
				{ name = 'Glalie', level = 56, 
					gender = 'M',
					ability = 'Ice Body', moves = {
						{ id = 'frostbreath' },{ id = 'blizzard' },
						{ id = 'hail' }, { id = 'crunch' }
					}},
			},
		},




		{ -- [# 185] : Route 15 - Darren
			Name = 'Darren',
			IntroPhrase = {'My legs are frozen from standing in the snow for so long!',
				'A good battle should help thaw them out.'},
			LosePhrase = 'I think I\'m catching a cold.',
			Interact = {'Maybe I shouldn\'t stand in the snow like this.'},
			Party = {
				{ name = 'Crawdaunt', level = 56, moves = { -- todo: make AI use super-effective moves first
					{ id = 'swordsdance' }, { id = 'crunch' },
					{ id = 'crabhammer' }, { id = 'guillotine' },
				}},
				{ name = 'Clawitzer', level = 56, ability = 'Mega Launcher', moves = {
					{ id = 'crabhammer' }, { id = 'waterpulse' },
					{ id = 'smackdown' }, { id = 'aquajet' },
				}},

			},
		},

		{ -- [# 186] : Decca Beach - Beach Bum Joe
			Name = 'Joe',
			IntroPhrase = {'I need help making my Pokemon stronger.',
				'Battle me, and both of our Pokemon will improve!'},
			LosePhrase = 'I may have lost, but I can feel my Pokemon getting stronger.',
			Interact = {'My Pokemon still aren\'t strong enough.'},
			RematchQuestion = 'Will you battle me again so that our Pokemon can improve?',


			Party = {
				{ name = 'Vileplume', level = 61, 
					gender = 'M',
					ability = 'Chlorophyll', 
					moves = {
						{ id = 'petaldance' }, { id = 'stunspore' },
						{ id = 'petalblizzard' }, { id = 'poisonpowder' },
					}},
				{ name = 'Golduck', level = 61, 
					ability = 'Cloud Nine', 
					moves = {
						{ id = 'hydropump' }, { id = 'amnesia' },
						{ id = 'psychup' }, { id = 'wonderroom' },
					}},
				{ name = 'Exeggutor', level = 62,
					ability = 'Chlorophyll', 
					moves = {
						{ id = 'leafstorm' }, { id = 'psyshock' },
						{ id = 'woodhammer' }, { id = 'eggbomb' },
					}},
			},
		},
		-- [[		



		--tess frostveil

		{ -- [#187] : tess
			Name = 'Trainer Tess',
			TrainerDifficulty = 5,
			Payout = 150 * 14,
			LosePhrase = 'You\'re so strong!',
			Party = {
			--[[--test battle	
				{ name = 'Squirtle', level = 2,
					gender = 'M',
					 
					moves = {
						{ id = 'tackle' }, 
					}},
					--]]
				-- [[
				{ name = 'Garchomp', level = 68, 
					gender = 'F',
					ability = 'Sand Veil', 
					moves = {
						{ id = 'dragonclaw' }, { id = 'slash' },
						{ id = 'dig' }, { id = 'dragonrush' },
					}},
				{ name = 'Salamence', level = 69, 
					gender = 'F',
					ability = 'Intimidate', 
					moves = {
						{ id = 'zenheadbutt' }, { id = 'flamethrower' },
						{ id = 'doubleedge' }, { id = 'scaryface' },
					}},
				{ name = 'Haxorus', level = 69,
					gender = 'M',
					ability = 'Rivalry', 
					moves = {
						{ id = 'dragonpulse' }, { id = 'outrage' },
						{ id = 'swordsdance' }, { id = 'dragonclaw' },
					}},
				{ name = 'Druddigon', level = 68,
					gender = 'M',
					ability = 'Rough Skin', 
					moves = {
						{ id = 'outrage' }, { id = 'rockclimb' },
						{ id = 'dragontail' }, { id = 'superpower' },
					}},

				{ name = 'Altaria', level = 70,
					gender = 'F',
					ability = 'Natural Cure', 
					moves = {
						{ id = 'moonblast' }, { id = 'perishsong' },
						{ id = 'dragonpulse' }, { id = 'skyattack' },
					}},
				--]]

			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('BeatTessFrost')
			end
		},


		-- [[
		{ -- [#188] : Cosmeos Valley - Gatekeeper Geoffrey
			Name = 'Geoffrey',
			TrainerDifficulty = 5,
			Payout = 80 * 63,
			LosePhrase = 'Amazing!',
			Party = {
				{ name = 'Kingdra', 
					level = 71,
					gender = 'M', ivs = {153,158,158,158,158,148},
					ability = 'Swift Swim', nature = 'Lonely',
					moves = { 
						{ id = 'hydropump' }, { id = 'agility' },
						{ id = 'dragonpulse' }, { id = 'icebeam' },
					}},
				{ name = 'Crobat', 
					level = 72,
					gender = 'M', ivs = {182,140,144,130,145,190},
					ability = 'Infiltrator', nature = 'Jolly', 
					moves = { 
						{ id = 'venoshock' }, { id = 'airslash' },
						{ id = 'xscissor' }, { id = 'gigaimpact' },
					}},
				{ name = 'Nidoking', 
					level = 75,
					gender = 'M', ivs = {180,158,140,150,135,145},
					ability = 'Sheer Force', nature = 'Relaxed',
					moves = { 
						{ id = 'megahorn' }, { id = 'roar' },
						{ id = 'earthquake' }, { id = 'shadowclaw' },
					}},
				{ name = 'Gengar', 
					level = 77,
					item = 'gengarite',
					gender = 'M', ivs = {166,120,120,200,130,178},
					ability = 'Cursed Body', nature = 'Rash',
					moves = { 
						{ id = 'focusblast' }, { id = 'dreameater' },
						{ id = 'shadowball' }, { id = 'suckerpunch' },
					}},
			},
			onWin = function(PlayerData)
				if not PlayerData.flags.winBattle188 then return end
				PlayerData:completeEventServer('vVictoryRoad')
			end
		},

		{ -- [# 189] : Adventurer Tanner
			Name = 'Tanner',
			IntroPhrase = {'I\'ve been all over the place, but I\'ve learned to appreciate the mountains the most.',
				'There\'s a certain sort of beauty that these mountains offer that you just don\'t see anywhere else.'},
			LosePhrase = 'Well, at least I still have the beautiful view from this mountain going for me.',
			Interact = {'I really appreciate these mountains the longer I stay here.'},
			--	RematchQuestion = 'Will you battle me again so that you can experience it with me?',

			Party = {
				{ name = 'Toxicroak', level = 55, 
					gender = 'M',
					ability = 'Anticipation', 
					moves = {
						{ id = 'sludgebomb' }, { id = 'poisonjab' },
						{ id = 'venoshock' }, { id = 'nastyplot' },
					}},
				{ name = 'Carvinine', level = 55, 
					ability = 'Levitate', 
					moves = {
						{ id = 'powerwhip' }, { id = 'swallow' },
						{ id = 'wringout' }, { id = 'crunch' },
					}},
				{ name = 'Beedrill', level = 55,
					ability = 'Swarm', 
					moves = {
						{ id = 'poisonjab' }, { id = 'endeavor' },
						{ id = 'fellstinger' }, { id = 'agility' },
					}},
			},
		},

		{ -- [# 190] : route 15 - mountaineer mia
			Name = 'Mia',
			IntroPhrase = {'This area looks like it used to serve a purpose, but the trail just ends.',
				'Maybe there were settlers here before the Frostveilians?',
				'Roria is just full of history and secrets.'},
			LosePhrase = 'I guess I should study more history instead of getting into battles I can\'t win.',
			Interact = {'Roria has a lot of hidden mysteries that I really like learning about.'},

			Party = {
				{ name = 'Mamoswine', level = 57, 
					gender = 'F',
					ability = 'Oblivious', 
					moves = {
						{ id = 'earthquake' }, { id = 'thrash' },
						{ id = 'mist' }, { id = 'blizzard' },
					}},
			},
		},
		-- [[
		{ -- [# 191] : Silvent Cove - Adventurer Thomas
			Name = 'Thomas',
			IntroPhrase = {'I came all the way from Anthian City just to catch a few rare Pokemon here.',
				'So I was just resting under this mushroom taking a short break.',
				'Looks like my break is up!'},
			LosePhrase = 'My Greedent was just tired.',
			Interact = {'This mushroom\'s green hue makes you feel relaxed.'},

			Party = {
				-- [[
				{ name = 'Greedent', level = 35, 
					gender = 'M',
					--ability = 'Strong Jaw', 
					--	moves = {
					--		{ id = 'crunch' }, { id = 'roar' },
					--		{ id = 'spark' }, { id = 'tackle' },
					--}
				},
				--]]
				--[[
				{ name = 'Ponyta', level = 37, 
					gender = 'M',
					forme = 'Galar',
					ability = 'Pastel Veil', 
					moves = {
						{ id = 'tackle' }, { id = 'stomp' },
						{ id = 'healpulse' }, { id = 'fairywind' },
					}},
--]]
			},
		},


		{ -- [# 192] : Silvent Cove - Hiker Mike
			Name = 'Mike',
			IntroPhrase = {'I just love the unique scenary in this cave.',
				'Maybe a little battle won\'t hurt.'},
			LosePhrase = 'Back to watching the scenary.',
			Interact = {'Don\'t mind me, I\'m just enjoying the atmosphere here.'},

			Party = {

				{ name = 'Orbeetle', level = 38, 
					gender = 'M',
					ability = 'Frisk', 
					--moves = {
					--{ id = 'psychic' }, { id = 'hypnosis' },
					--{ id = 'bugbuzz' }, { id = 'confuseray' },
					--}
				},

				{ name = 'Drednaw', level = 37, 
					gender = 'F',
					ability = 'Strong Jaw', 
					--moves = {
					--{ id = 'bite' }, { id = 'watergun' },
					--{ id = 'protect' }, { id = 'headbutt' },
					--}
				},

			},
		},

		{ -- [# 193] : Silvent Cove - Student James
			Name = 'James',
			IntroPhrase = {'I\'m on recess so I decided to come to this place.',
				'Looking at the waterfall just makes me forget about the stress of school.',
				'A battle will help ease the stress I have from my homework.'},
			LosePhrase = 'I\'m actually not on recess, to be honest.',
			Interact = {'Please don\'t tell my teachers that I\'m here.'},

			Party = {

				{ name = 'Flapple', level = 36, 
					gender = 'F',
					ability = 'Hustle', 
					--moves = {
					--{ id = 'gravapple' }, { id = 'leechseed' },
					--{ id = 'dragonpulse' }, { id = 'protect' },
					--}
				},


			},
		},


		{ -- [# 194] : Silvent Cove - Journalist Sylvester
			Name = 'Sylvester',
			IntroPhrase = {'This cave has a lot of history to it.',
				'That\'s why I\'m writing a thesis statement on the extensive history of this place.',
				'That doesn\'t mean I won\'t enjoy a battle though!'},
			LosePhrase = 'You\'ll be in the history books as well!',
			Interact = {'It\'s so cool to learn about the many histories of Roria.'},

			Party = {

				{ name = 'Corvisquire', level = 36, 
					gender = 'M',
					ability = 'Keen Eye', 
					--moves = {
					--	{ id = 'drillpeck' }, { id = 'pluck' },
					--	{ id = 'peck' }, { id = 'scaryface' },
					--}
				},

				{ name = 'Mareanie', level = 37, 
					gender = 'F',
					ability = 'Regenerator', 
					--moves = {
					--	{ id = 'toxicspikes' }, { id = 'bite' },
					--	{ id = 'venoshock' }, { id = 'recover' },
					--}
				},
			},
		},


		--Route 17 Surf		
		{ -- [# 195] : Route 17 - Swimmer Kristy 
			Name = 'Kristy',
			IntroPhrase = {'I\'ve been swimming for so long that I can cross these waters easily without a Pokemon.'},
			LosePhrase = 'Good thing I can swim without my Pokemon',
			Interact = {'Swimming is my favorite thing to pass the time.'},
			Party = {
				{ name = 'Sharpedo', level = 65, 
					gender = 'F',
					ability = 'Rough Skin', 
					moves = {
						{ id = 'agility' }, { id = 'nightslash' },
						{ id = 'taunt' }, { id = 'skullbash' },
						--}
					},
				},
				{ name = 'Corsola', level = 65, 
					gender = 'F',
					ability = 'Natural Cure', 
					moves = {
						{ id = 'flail' }, { id = 'powergem' },
						{ id = 'mirrorcoat' }, { id = 'earthpower' },
						--}
					},
				},
			},
		},


		{ -- [# 196] : Route 17 - Swimmer Tabatha
			Name = 'Tabatha',
			IntroPhrase = {'The water feels so nice.',
				'Why don\'t you and your Pokemon join me?'},
			LosePhrase = 'Why does the water feel warm?',
			Interact = {'You should really try the water some time.'},
			Party = {
				{ name = 'Wailord', level = 64, 
					gender = 'F',
					ability = 'Oblivious', 
					moves = {
						{ id = 'dive' }, { id = 'bounce' },
						{ id = 'amnesia' }, { id = 'hydropump' },
						--}
					},
				},
				{ name = 'Wailord', level = 64, 
					gender = 'F',
					ability = 'Water Veil', 
					moves = {
						{ id = 'dive' }, { id = 'bounce' },
						{ id = 'amnesia' }, { id = 'hydropump' },
						--}
					},
				},
				{ name = 'Octillery', level = 64, 
					gender = 'F',
					ability = 'Sniper', 
					moves = {
						{ id = 'soak' }, { id = 'hydropump' },
						{ id = 'bulletseed' }, { id = 'hyperbeam' },
						--}
					},
				},
			},		
		},


		{ -- [# 197] : Route 17 - Swimmer Branson
			Name = 'Branson',
			IntroPhrase = {'Just ahead is Crescent Island.',
				'You may want to be careful if you plan to go there.',
				'Let\'s have a battle to see if you are prepared.'},
			LosePhrase = 'I still have my concerns.',
			Interact = {'You should still be careful.'},
			Party = {
				{ name = 'Sharpedo', level = 65, 
					gender = 'M',
					ability = 'Rough Skin', 
					moves = {
						{ id = 'agility' }, { id = 'taunt' },
						{ id = 'nightslash' }, { id = 'skullbash' },
						--}
					},
				},
				{ name = 'Mantine', level = 64, 
					gender = 'F',
					ability = 'Swift Swim', 
					moves = {
						{ id = 'aquaring' }, { id = 'airslash' },
						{ id = 'bounce' }, { id = 'hydropump' },
						--}
					},
				},
				{ name = 'Seadra', level = 64, 
					gender = 'M',
					ability = 'Sniper', 
					moves = {
						{ id = 'agility' }, { id = 'dragonpulse' },
						{ id = 'dragondance' }, { id = 'hydropump' },
						--}
					},
				},
			},		
		},

		--gym 7		
		{ -- [# 198] : Gym 7 2.0 - Silhouette Devon
			Name = 'Devon',
			IntroPhrase = {"Watch your step in here.",
				"The darkness can often hide the path ahead of you."},
			LosePhrase = "I've been left in the dark for too long",
			Interact = {'You should still be careful of the dark.'},
			Party = {
				{ name = 'Liepard', level = 68, 
					gender = 'M',
					ability = 'Unburden', 
					moves = {
						{ id = 'snatch' }, { id = 'playrough' },
						{ id = 'nastyplot' }, { id = 'suckerpunch' },
					},
				},
				{ name = 'Scrafty', level = 68, 
					gender = 'M',
					ability = 'Shed Skin', 
					moves = {
						{ id = 'facade' }, { id = 'focuspunch' },
						{ id = 'rockclimb' }, { id = 'headsmash' },
					},
				},
				{ name = 'Liepard', level = 68, 
					gender = 'M',
					ability = 'Unburden', 
					moves = {
						{ id = 'snatch' }, { id = 'playrough' },
						{ id = 'nastyplot' }, { id = 'suckerpunch' },
					},
				},
			},		
		},

		{ -- [# 199] : Gym 7 2.0 - Silhouette Adam
			Name = 'Adam',
			IntroPhrase = "I conceal myself to help keep from revealing my strategy.",
			LosePhrase = "I tripped on something. What was that?",
			Interact = "Don't tell anyone that I'm hiding here.",
			Party = {
				{ name = 'Mightyena', level = 68, 
					gender = 'M',
					ability = 'Quick Feet', 
					moves = {
						{ id = 'yawn' }, { id = 'playrough' },
						{ id = 'takedown' }, { id = 'suckerpunch' },
					},
				},
				{ name = 'Mightyena', level = 68, 
					gender = 'M',
					ability = 'Intimidate', 
					moves = {
						{ id = 'yawn' }, { id = 'playrough' },
						{ id = 'takedown' }, { id = 'suckerpunch' },
					},
				},
				{ name = 'Mightyena', level = 68, 
					gender = 'M',
					ability = 'Quick Feet', 
					moves = {
						{ id = 'yawn' }, { id = 'playrough' },
						{ id = 'takedown' }, { id = 'suckerpunch' },
					},
				},
			},		
		},

		{ -- [# 200] : Gym 7 2.0 - Silhouette Rubin
			Name = 'Rubin',
			IntroPhrase = "The sunlight hurts my eyes.",
			LosePhrase = "I tripped on something. What was that?",
			Interact = "Don't tell anyone that I'm hiding here.",
			Party = {
				{ name = 'Mandibuzz', level = 68, 
					gender = 'F',
					ability = 'Overcoat', 
					moves = {
						{ id = 'darkpulse' }, { id = 'whirlwind' },
						{ id = 'embargo' }, { id = 'bravebird' },
					},
				},
				{ name = 'Skuntank', level = 68, 
					gender = 'M',
					ability = 'Stench', 
					moves = {
						{ id = 'venomdrench' }, { id = 'explosion' },
						{ id = 'belch' }, { id = 'suckerpunch' },
					},
				},
				{ name = 'Sableye', level = 68, 
					gender = 'M',
					ability = 'Stall', 
					moves = {
						{ id = 'shadowball' }, { id = 'meanlook' },
						{ id = 'foulplay' }, { id = 'quash' },
					},
				},
			},		
		},

		{ -- [#201] : Hidden Lab - Scientist
			Name = "Jeremy",
			IntroPhrase = {'How did you get in here?', 'This place is strictly off-limits to outsiders.',
				'We cannot allow you down here.', '...', 'You won\'t leave huh?', 'I guess I have to battle you to teach you a lesson.'},
			LosePhrase = 'My Battle strategies are worse than I projected.',
			Interact = {'Don\'t you dare go to the computer.', 'That\'s what keeps the Pokemon inside.'},
			Party = {
				{ name = 'Porygon', level = 60},
				{ name = 'Porygon2', level = 63},
				{ name = 'Porygonz', level = 66},
			}
		},

		{ -- [#202] : Hidden Lab - Scientist
			Name = "Albert",
			IntroPhrase = {'What do you think you\'re doing?', 'Our research is top secret.',
				'You must forget everything you\'ve seen and leave at once.'},
			LosePhrase = 'I must forget this happened.',
			Interact = 'Would you leave if we asked nicely?',
			Party = {
				{ name = 'Magnemite', level = 60},
				{ name = 'Magneton', level = 63},
				{ name = 'Magnezone', level = 66},
			}
		},

		{ -- [#203] : Hidden Lab - Scientist
			Name = "Herald",
			IntroPhrase = {'What happens in this lab is none of your concern.',
				'Our research is going to create the most powerful Pokemon alive and one puny trainer won\'t stop that.'},
			LosePhrase = 'I\'m shocked, this isn\'t good!',
			Interact = 'Please, don\'t ruin our research!',
			Party = {
				{ name = 'Shinx', level = 60},
				{ name = 'Luxio', level = 63},
				{ name = 'Luxray', level = 66},
			}
		},
		{ -- [#204] : Magik Pond - Fisherman Dwayne
			Name = 'Dwayne',
			TrainerDifficulty = 2,
			InteractRequired = true,
			IntroPhrase = {'Let me show you the Pokemon that I caught in Bob\'s Magik Cave!'},
			LosePhrase = 'They\'re cool, aren\'t they?',
			Interact = {'They\'re cool, aren\'t they?'},
			Party = { -- TODO: Give em formes
				{name = 'Magikarp', level = 60, forme = 'CalicoOrangeWhite'},
				{name = 'Gyarados', level = 65, forme = 'CalicoOrangeWhite'},
				{name = 'Magikarp', level = 60, forme = 'PinkDapples'},
				{name = 'Gyarados', level = 65, forme = 'PinkDapples'}, 
				{name = 'Magikarp', level = 60, forme = 'Relicanth'},
				{name = 'Gyarados', level = 65, forme = 'Relicanth'}, 
			},
		},
		--]]


		{ -- [#205] : Tinbell Tower - Worker George - (1/F)
			Name = "George",
			IntroPhrase = {'Oh, welcome to Tinbell Tower.',
				'You look like an aspiring young trainer.',
				'How about I take a quick break and we have a battle?',
				'My Pokemon are pumped from all the lifting they\'ve done today.'},
			LosePhrase = 'Well, my break just ended so I better get back to work.',
			Interact = 'My Pokemon are pumped from all the lifting they\'ve done today.',
			Party = {
				{ name = 'Machoke', level = 64},
				{ name = 'Machoke', level = 64},
			}
		},
		{ -- [#206] : Tinbell Tower - Worker Jensen (1/F)
			Name = "Jensen",
			IntroPhrase = {'Be careful where you walk.',
				'I just dropped a bolt and I don\'t want it getting kicked around.',
				'Actually, I\'ll find it later, let\'s have a battle.'},
			LosePhrase = 'Oh, here\'s that bolt!',
			Interact = 'I just dropped a bolt and I don\'t want it getting kicked around.',
			Party = {
				{ name = 'Gurdurr', level = 64},
				{ name = 'Machoke', level = 64},
			}
		},
		{ -- [#207] : Tinbell Tower - Worker Jimbo - (1/F)
			Name = "Jimbo",
			IntroPhrase = {'Hey, what\'s poppin\'? Let\'s battle.'},
			LosePhrase = 'It\'s off to the showers for me now.',
			Interact = 'It\'s off to the showers for me now.',
			Party = {
				{ name = 'Machoke', level = 64},
				{ name = 'Gurdurr', level = 64},
			}
		},
		{ -- [#208] : Tinbell Tower - Worker Stan - (1/F)
			Name = "Stan",
			IntroPhrase = {'This ladder leads up to then next floor.',
				'I\'ll let you pass if you can beat me in a battle.'},
			LosePhrase = 'This ladder leads up to then next floor.',
			Interact = 'Well, you\'re free to pass.',
			Party = {
				{ name = 'Gurdurr', level = 64},
				{ name = 'Machoke', level = 64},
				{ name = 'Hariyama', level = 64},
			}
		},
		{ -- [#209] : Tinbell Tower - Worker Allen - (2/F)
			Name = "Allen",
			IntroPhrase = {'My back is killing me from lifting these heavy boards.',
				'I need a break, and a battle sounds like a great way to fill the time.'},
			LosePhrase = 'I think I\'ll just on my break a little bit longer to recover from that battle as well.',
			Interact = 'My back is killing me from lifting these heavy boards.',
			Party = {
				{ name = 'Medicham', level = 64, gender = 'M'},
				{ name = 'Gurdurr', level = 64},
			}
		},
		{ -- [#210] : Tinbell Tower - Worker Lee - (2/F)
			Name = "Lee",
			IntroPhrase = {'This is where we run a lot of our electrical power from.',
				'I\'ll battle you so you can see where I draw my power from.'},
			LosePhrase = 'I need more power!',
			Interact = 'This is where we run a lot of our electrical power from.',
			Party = {
				{ name = 'Machoke', level = 64},
				{ name = 'Heracross', level = 64, gender = 'M'},
			}
		},
		{ -- [#211] : Tinbell Tower - Worker Jack - (2/F)
			Name = "Jack",
			IntroPhrase = {'Trainers that visit the tower often catch our hard-working Machokes and Gurdurr.',
				'They are technically wild, so there isn\'t much we can do about it.',
				'It sure does make work harder on us.',
				'I\'ll show you just how hard of a worker I am because of it.'},
			LosePhrase = 'I could\'ve worked harder.',
			Interact = 'Trainers that visit the tower often catch our hard-working Machokes and Gurdurr.',
			Party = {
				{ name = 'Machoke', level = 64},
				{ name = 'Gurdurr', level = 64},
			}
		},
		{ -- [#212] : Tinbell Tower - Worker Josh - (2/F)
			Name = "Josh",
			IntroPhrase = {'When you borrow someone\'s tools, always be sure to return them.',
				'Otherwise, people like me end up with nothing to work with!',
				'I\'m training my Pokemon to help me build the courage to ask for my tools back.',
				'Take a look!'},
			LosePhrase = 'I could\'ve worked harder.',
			Interact = 'When you borrow someone\'s tools, always be sure to return them.',
			Party = {
				{ name = 'Sawk', level = 64},
				{ name = 'Throh', level = 64},
			}
		},
		{ -- [#213] : Tinbell Tower - Worker Karl - (2/F/R)
			Name = "Karl",
			IntroPhrase = {'This scaffolding leads to the top of the presently built tower.',
				'Our boss usually sits up there so he can see all of us.',
				'I don\'t think he\'ll mind if we have a quick battle.'},
			LosePhrase = 'My boss will be disappointed in me.',
			Interact = 'This scaffolding leads to the top of the presently built tower.',
			Party = {
				{ name = 'Machoke', level = 64},
				{ name = 'Primeape', level = 64},
			}
		},
		{ -- [#214] : Tinbell Tower - Worker Wilson - (2/F/R)
			Name = "Wilson",
			IntroPhrase = {'The boss is up ahead.',
				'If you want to talk to him, you\'ll have to battle me first.'},
			LosePhrase = 'You can go on ahead. I need to catch up on work.',
			Interact = 'The boss is up ahead.',
			Party = {
				{ name = 'Machoke', level = 64},
				{ name = 'Hariyama', level = 64},
			}
		},
		{ -- [#215] : Tinbell Tower - Worker Kaleb - (3/F)
			Name = "Kaleb",
			IntroPhrase = {'Everyone has a job to do here on the tower.',
				'My job is to inspect the building for possible weaknesses.',
				'May I inspect your Pokemon team for possible weaknesses?'},
			LosePhrase = 'Looks like I need to inspect my own team.',
			Interact = 'My job is to inspect the building for possible weaknesses.',
			Party = {
				{ name = 'Machop', level = 64},
				{ name = 'Machoke', level = 64},
				{ name = 'Timburr', level = 64},
				{ name = 'Gurdurr', level = 64},
			}
		},
		{ -- [#216] : Tinbell Tower - Worker Adam - (3/F)
			Name = "Adam",
			IntroPhrase = {'I haven\'t seen a trainer make it up this high in quite a while.',
				'The boss is just around the corner.',
				'If you can beat me, I\'ll let you go through to talk to him.'},
			LosePhrase = 'You\'re welcome to go talk to the boss now.',
			Interact = 'The boss is just around the corner.',
			Party = {
				{ name = 'Machoke', level = 65},
				{ name = 'Gurdurr', level = 65},
				{ name = 'Throh', level = 65},
				{ name = 'Sawk', level = 65},
			}
		},
		{ -- [#217] : Tinbell Tower - Boss Deven - (3/F)
			Name = 'Boss Deven',
			TrainerDifficulty = 5,
			Payout = 6300 * 1,
			LosePhrase = 'You\'re pretty strong, ya know.',
			Party = {
				{ name = 'Machamp', level = 67},
				{ name = 'Conkeldurr', level = 67},
				{ name = 'Hitmonlee', level = 68},
				{ name = 'Hitmonchan', level = 68},
				{ name = 'Hitmontop', level = 68},
				{ name = 'Lucario', item = 'lucarionite', level = 70},
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('DefeatTinbell')
			end
		},

		{ -- [#218] : Eclipse Base - (Entrance Hall)
			Name = 'Jeb',
			IntroPhrase = {'What do we have here?',
				'Are you a new recruit?',
				'You aren\'t in uniform.',
				'You must be an intruder.',
				'I\'m the first line of defense in this secret base.',
				'I\'ll have you finished off and out of here in no time.'
			},
			LosePhrase = 'Well that\'s just great. The boss won\'t be happy.',
			Interact = 'Please, don\'t tell the boss.',
			Party = {
				{name = 'Muk', level = 64},
				{name = 'Toxicroak', level = 64},
			}
		},

		{ -- [#219] : Eclipse Base - (Entrance Hall)
			Name = 'Allan',
			IntroPhrase = {'Are you on your way to the cafeteria?',
				'Wait, you aren\'t a Team Eclipse member.',
				'We\'re going to need to battle.'
			},
			LosePhrase = 'Well, at least lunch will be ready soon.',
			Interact = 'I can\'t wait for lunch time!',
			Party = {
				{name = 'Snorlax', level = 65},
			}
		},

		{ -- [#220] : Eclipse Base - (Entrance Hall)
			Name = 'Jasmine',
			IntroPhrase = {'Where do you think you\'re going?',
				'This secret base is for Team Eclipse only.',
				'How did you even find your way in here?'
			},
			LosePhrase = 'You\'re pretty strong. Ever think about joining Team Eclipse?',
			Interact = 'Ever think about joining Team Eclipse?',
			Party = {
				{name = 'Gothitelle', level = 64},
				{name = 'Greninja', level = 64},
			}
		},

		{ -- [#221] : Eclipse Base - (Cafeteria)
			Name = 'Raymond',
			IntroPhrase = 'Only Team Eclipse eats for free.',
			LosePhrase = 'I guess I paid for it in the end.',
			Interact = 'I paid for it!',
			Party = {
				{name = 'Steelix', level = 64},
				{name = 'Magnezone', level = 64},
			}
		},

		{ -- [#222] : Eclipse Base - (Cafeteria)
			Name = 'Jennifer',
			IntroPhrase = 'I\'m on a diet right now, so instead of eating, I\'ll have a battle.',
			LosePhrase = 'Another loss to swallow...',
			Interact = 'My diet is not going to well.',
			Party = {
				{name = 'Slurpuff', level = 66},
			}
		},

		{ -- [#223] : Eclipse Base - (Cafeteria)
			Name = 'Brittney',
			IntroPhrase = 'I hope you aren\'t trying to skip out on dish duty.',
			LosePhrase = 'omg reported',
			Interact = 'I\'am gonna report you to the boss.',
			Party = {
				{name = 'Mr. Mime', level = 66},
			}
		},

		{ -- [#224] : Eclipse Base - (Power Station)
			Name = 'Jeff',
			IntroPhrase = 'It\'s so hot in this room, but I can take a little heat.',
			LosePhrase = 'I\'m burned out now.',
			Interact = 'I\'m burned out now I need a break.',
			Party = {
				{name = 'Magcargo', level = 64},
				{name = 'Torkoal', level = 64}
			}
		},

		{ -- [#225] : Eclipse Base - (Power Station)
			Name = 'Connor',
			IntroPhrase = {'I\'m conducting research on the abilities of my Pokemon.', 'Will you please help me with my experiment?'},
			LosePhrase = 'My findings are less than what I had expected.',
			Interact = 'My findings are not good.',
			Party = {
				{name = 'Slaking', level = 66},
			}
		},

		{ -- [#226] : Eclipse Base - (Power Station)
			Name = 'Jeremy',
			IntroPhrase = {'Stop right there.', 'My DNA scanner does not have you in its database.', 'You are not with Team Eclipse.', 'I must stop you.'},
			LosePhrase = 'I\'m recording you as an enemy.',
			Interact = 'I\'m recording you as an enemy.',
			Party = {
				{name = 'Porygon-Z', level = 66}
			}
		},

		{ -- [#227] : Eclipse Base - (Living Quarters)
			Name = 'Kelley',
			IntroPhrase = {'Shhh, keep it down.', 'We have team members trying to rest in here.', 'I\'ll have to teach you a lesson with a quiet battle.'},
			LosePhrase = 'I think we were too loud.',
			Interact = 'We have team members trying to rest in here.',
			Party = {
				{name = 'Hypno', level = 66}
			}
		},

		{ -- [#228] : Eclipse Base - (Living Quarters)
			Name = 'Kylie',
			IntroPhrase = {'I need help falling asleep.', 'Do any of your Pokemon know Hypnosis?'},
			LosePhrase = 'Well I lost. Perfect time for a nap.',
			Interact = 'Do any of your Pokemon know Hypnosis?',
			Party = {
				{name = 'Heracross', level = 64},
				{name = 'Pinsir', level = 64}
			}
		},

		{ -- [#229] : Eclipse Base - (Surveillance Room)
			Name = 'Eclipse Grunt Hugh',
			TrainerDifficulty = 4,
			Payout = 2600 * 1,
			LosePhrase = 'I should have seen that coming.',
			Party = {
				{name = 'Magnezone', level = 65},
				{name = 'Lickilicky', level = 65},
				{name = 'Weavile', level = 65},
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('ExposeSecurity')
			end
		},

		{ -- [#230] : Eclipse Base - (Aircraft Hangar)
			Name = 'Eclipse Admin Jake',
			TrainerDifficulty = 5,
			Payout = 80 * 63,
			LosePhrase = 'You are still the strongest.',
			Party = {
				{ name = 'Zebstrika', level = 76},
				{ name = 'Nidoking', level = 76},
				{ name = 'Slowbro', level = 76},
				{ name = 'Arcanine', level = 76},
				{ name = 'Dhelmise', level = 76},
				{ name = 'Vaporeon', level = 78}
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('DefeatEclipseBase')
			end
		},

		{ -- [#231] : Leader Sebastian Rebattle
			Name = 'Gym Leader Sebastian',
			TrainerDifficulty = 5,
			Payout = 130 * 57,
			LosePhrase = {"You just might be the strongest opponent I've ever faced."},
			Party = {

--[[]]
				
				{ name = 'Pyroar', level = 86},
				{ name = 'Arcanine', level = 87},
				{ name = 'Magmortar', level = 88},
								{ name = 'Marowak', forme = 'Alola', gender = 'M', level = 90},
								{ name = 'Incineroar', gender = 'M', level = 91},
								{ name = 'Charizard', item = 'charizarditey', level = 93},

--]]

			},
			onWin = function(PlayerData)
			--	PlayerData:addBagItems({id='redorb', quantity=1})
				PlayerData:completeEventServer('SebastianRebattle')
			end
		},
		
		{ -- [#232] : Sawmill Boss
			Name = 'Lumberjack Josh',
			TrainerDifficulty = 5,
			Payout = 160 * 32,
			LosePhrase = {'I got cut down by my opponent. How ironic...'},
			Party = {
				{ name = 'Forretress', level = 80},
				{ name = 'Bisharp', level = 80},
				{ name = 'Pinsir', level = 80},
				{ name = 'Haxorus', level = 80},
				{ name = 'Bibarel', level = 80},
				{ name = 'Scizor', level = 80, item = 'scizorite'},

			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('getGSBall')
			end
		},
		
		-- [[
		
		--AND BELOW ARE VICTORY ROAD CUSTOM TRAINERS--
		
								{ -- [# 233]] : Cosmeos Valley - Veteran Luther

		
			Name = 'Veteran Luther',
			TrainerDifficulty = 5,
			Payout = 160 * 32,
			LosePhrase = {"Amazing battle!"},
			Party = {
				{ name = 'Hippowdon', level = 91,
					gender = 'M', 
					item = 'leftovers',
				},
				{ name = 'Excadrill', level = 91,
					gender = 'F',
				},
				{ name = 'Garchomp', level = 92, 
					gender = 'M',
				},
				{ name = 'Conkeldurr', level = 93, 
					gender = 'M',
					item = 'flameorb',
				},
				{ name = 'Aegislash', level = 94,
					gender = 'M',
					item = 'weaknesspolicy',
				},
				{ name = 'Tyranitar', level = 96,
					gender = 'M',
					item = 'tyranitarite',
				},
		
			},
			onWin = function(PlayerData)
				PlayerData:completeEventServer('DefeatLuther')
			end
		
	},		
		
		--]]









		--dont mess with these below		
	},

}













