local assets = {}

assets.musicId = {
	ContinueScreen = 124370180904368, --424126550, --257152251,--288893031 --pokemon diamond left, cm right
}

-- Group Place / Animation / Dev Product / Game Pass / Badge IDs
assets.placeId = {
	Main = 101312236197989,
	Battle = 120576570377936,
	Trade = 124737548790762,
}
assets.animationId = {
	IntroSleep = 8308854229,
	IntroSit = 8308856432,
	NPCSwim = 8308858672,
	NPCIdleSwim = 8308861579,
	NPCIdle = 8308863632,
	NPCWalk = 8308865694,
	NPCWave = 8308867602,
	NPCDance1 = 8308869629,
	NPCDance2 = 8308871832,
	NPCDance3 = 8308873821,
	NPCBreakDance = 6783341169,
	NurseBow = 8308876485,
	Run = 8308878740,--5209722902,
	RodIdle = 8308880941,
	RodCast = 8308883421,
	RodReel = 8308885334,
	ThrowBall = 8308887819,
	FlipSign = 8308890159,
	cmJump = 8308891923,
	cmHats = 8308895466,
	profChange = 8308897595,
	profTurn = 8308899565,
	absolIdle = 8308901968,
	absolRun = 8308904049,
	absolSniff = 8308906621,
	palkiaIdle = 8308908776,
	palkiaHover = 8308910646,
	-----------------
	palkiaRoarAir = 8308912795,
	palkiaRoarGround = 8308914980,
	dialgaIdle = 8308916913,
	dialgaHover = 8308919239,
	dialgaRoarAir = 8308921223,
	dialgaRoarGround = 8308923235,
	EatSushi = 8308924900,
	Sit = 8308927696,
	Carry = 8308929305,
	heatranIdle = 8308936756,
	heatranRoar = 8308939092,
	jhatIdle = 8308941565,
	jhatAction = 8308943970,

	raikouRun = 8308946276,
	enteiRun = 8308948592,
	suicuneRun = 8308950291,

	CobalionIdle = 73004504803990,
	TerrakionIdle = 85948602441314,
	VirizionIdle = 130248625269075,
	KeldeoIdle = 70989061799492,

	h_idle = 8308952950,
	h_mount = 8308955573,
	h_forward = 8308957665,
	h_backward = 8308959163,
	h_left = 8308961564,
	h_right = 8308963741,
	h_trick1 = 106976348449888, 
	h_trick2 = 84501588593550, 
	h_trick3 = 71502083258613,

	Surf = 8308965520,

	ZPower = 7980494774,

	jakeLift = 1334719479,
	jakeHold = 1334726096,
	jakeThrow = 1334702274,
	jakePush = 1339450401,
	jakePortal = 1339667328,
	tessFall = 1339452304,


	-- R15
	R15_IntroSleep = 8308970092,
	R15_IntroWake = 8308972425,
	R15_IntroTossClock = 8308974181,

	R15_Idle = 8308976316,
	R15_Run = 8308978382,
	R15_ThrowBall = 8308980373,
	R15_Sit = 8308982438,
	R15_Sushi = 8308984303,

	R15_RodIdle = 8308986626,
	R15_RodCast = 8308988838,
	R15_RodReel = 8308992794,

	R15_Carry = 8308994967,

	R15_h_idle = 8308997979,
	R15_h_mount = 8309000203,
	R15_h_forward = 8309002432,
	R15_h_backward = 8309004626,
	R15_h_left = 8309006853,
	R15_h_right = 8309009064,
	R15_h_trick1 = 76387587237133, 
	R15_h_trick2 = 116419322907220, 
	R15_h_trick3 = 80187737718686, 

	R15_Surf = 8309011996,

	R15_ZPower = 7481103545,

}

--ORIGINAL GAMEPASSES FROM BRICK BRONZE, I HAVENT MADE ONE YET
assets.productId = {
	Starter = 3329152885	, --5
	TenBP = 3329152975, --5
	FiftyBP = 3329153072, --20
	UMV1 = 3329153133, --5
	UMV3 = 3329153170, --8
	UMV6 = 3329153230, --12
	_10kP  = 3329153265, -- 10 R$
	_50kP  = 3329153312, -- 15 R$
	_100kP = 3329153362, -- 20 R$
	_200kP = 3329153423, -- 25 R$
	PBSpins1 = 3329153474, --5
	PBSpins5 = 3329153522, --10
	PBSpins10 = 3329153571, --15
	AshGreninja = 3329153612, --10
	Hoverboard = 3329153664, --5
	MasterBall = 3329153718	, --8
	LottoTicket = 3329153761, --10
	TixPurchase = 3274518869, --// 10 R$

	RoPowers = {
		{ 3329153810, 3329153865 }, --x1.5 EXP 8R$, x2 EXP 14R$
		{ 3329153934, 3329153978	 }, --x2 Steps 5 R$, x3 Steps 10 R$
		{ 3329154094, 3329154147		 }, --x2 Money 10R$, x3 Money 15R$

{ 3329154212, 3329154260 }, --x2 EVs 5 R$, x3 EVs 10R$
{ 3329154320, }, --x16 Shiny 10R$
{ 3329154368, }, --This or the bottom one is Legend Encounter Rate
{ 3329154425, }
	},
}

--ORIGINAL GAMEPASSES FROM BRICK BRONZE, I HAVENT MADE ONE YET
assets.passId = {
	ExpShare = 10324694,
	MoreBoxes = 10572037,
	ShinyCharm = 1044767426,
	AbilityCharm = 1044558190,
	OvalCharm = 1044773441,
	StatViewer = 383208089,
	RoamingCharm = 1044671599,
	ThreeStamps = 1044821309,
	PondPass = 1050653395,

}
--BADGES DO NOT WORK, I DONT HAVE THE ROBUX TO PURCHASE THEM SORRY
assets.badgeId = {
	Gym1 = 313617167,
	Gym2 = 317830251,
	Gym3 = 338423949,
	Gym4 = 512924091,
	Gym5 = 620490478,
	Gym6 = 668968355,
	DexCompletion = {
		{100, 687781576},
		{250, 687782030},
		{400, 687782269},
		{550, 688159425},
	}
}
assets.badgeImageId = {
	5219643843,
	5219634385,
	5219655002,
	5219615653,
	5219619392,
	5219622135,
	2566476879,
	1349659837,
}

--[[

--IGNORE THIS, THEY ARE TEST ANIMATIONS
if game.CreatorId == 2022685502 then
	-- tbradm Place / Animation / Dev Product / Game Pass IDs (Test game)
	assets.placeId = {
		Main = 6192316738,
		Battle = 6192632762,
		Trade = 6192632907,
	}
	--[[
	assets.animationId = {
		IntroSleep = 5707172507,
		IntroSit = 5707174730,
		NPCIdle = 5707176936,
		NPCWalk = 5707180313,
		NPCWave = 5707181660,
		NPCDance1 = 5707183329,
		NPCDance2 = 5707185455,
		NPCDance3 = 5707187058,
		NPCBreakDance = 5707189684,
		NurseBow = 5707191663,
		Run = 5707193897,--5209722902,
		RodIdle = 5707196009,
		RodCast = 5707197802,
		RodReel = 5707199712,
		ThrowBall = 5707202131,
		FlipSign = 5707203924,
		cmJump = 5707206141,
		cmHats = 5707207653,
		profChange = 5707210166,
		profTurn = 5707211711,
		absolIdle = 5707213091,
		absolRun = 5707214829,
		absolSniff = 5707216325,
		palkiaIdle = 5707218445,
		palkiaHover = 5707219933,
		-----------------
		palkiaRoarAir = 5707222007,
		palkiaRoarGround = 5707223590,
		dialgaIdle = 5707225237,
		dialgaHover = 5707227076,
		dialgaRoarAir = 5707228568,
		dialgaRoarGround = 5707230437,
		EatSushi = 5707231856,
		Sit = 5707232976,
		Carry = 5707234396,
		heatranIdle = 5707235730,
		heatranRoar = 5707237285,
		jhatIdle = 5707238873,
		jhatAction = 5707240452,

		raikouRun = 5707241801,
		enteiRun = 5707243109,
		suicuneRun = 5707244305,

		h_idle = 5707246201,
		h_mount = 5707247845,
		h_forward = 5707261721,
		h_backward = 5707265423,
		h_left = 5707266786,
		h_right = 5707296481,


		-- R15
		R15_IntroSleep = 5707298220,
		R15_IntroWake = 5707299432,
		R15_IntroTossClock = 5707300794,

		R15_Idle = 5707302316,
		R15_Run = 5707303804,
		R15_ThrowBall = 5707305107,
		R15_Sit = 5707306271,
		R15_Sushi = 5707307409,

		R15_RodIdle = 5707309435,
		R15_RodCast = 5707310650,
		R15_RodReel = 5209687130,

		R15_Carry = 5707313140,
	}
	
	--GAMEPASS LINKS, I HAVENT MADE ANY YET AS THESE ARE FROM THE ORIGINAL BRICK BRONZE LINKS
	assets.productId = {
		Starter = 1131808114,
		TenBP = 1052619777,
		FiftyBP = 1052620108,
		UMV1 = 1131808554	,
		UMV3 = 1131808602,
		UMV6 = 1131808641,
		_10kP  = 1020661543, -- 20 R$
		_50kP  = 1020662062, -- 85 R$
		_100kP = 1020662731, -- 150 R$
		_200kP = 1020663131, -- 275 R$
		PBSpins1 = 1131808719,
		PBSpins5 = 1131808751,
		PBSpins10 = 1131808768,
		AshGreninja = 1131808792,
		Hoverboard = 1020659462,
		MasterBall = 1131808831,
		RoPowers = {
			{ 1020669483, 1052457787 },
			{ 1052457947, 1052458119 },
			{ 1052458538, 1052458711 },

			{ 1052458860, 1052459073 },
			{ 1052459232, },
			{ 1052459397, },
			{ 1052461817, }
		},
	}
	assets.passId = {
		ExpShare = 311450760,
		MoreBoxes = 10572037,
		ShinyCharm = 385726501,
		ThreeStamps = 678769823,
		-- below are not test place passes
		AbilityCharm = 383208830,
		OvalCharm = 460812378,
		StatViewer = 383208089,
		RoamingCharm = 460812984,
	}
end
--]]

return assets