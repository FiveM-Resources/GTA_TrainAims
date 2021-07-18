Config = {}

--> Counter down color: 
Config.TextColorR = 245
Config.TextColorG = 200
Config.TextColorB = 66
Config.TextColorA = 255

Config.language = 'en'

Config.StartPos = {["x"] = 13.23, ["y"] = -1097.56, ["z"] = 29.83} --> Position to start the training.
Config.HashTarget = 2156975659 --> Hash of the target.
Config.CountTimer = 11000 --> 30 SECONDES.

Config.infinitAmmo = true
Config.enableTargetTouchText = true


--> Position of the target where they will spawn.
TargetPosition = {
    {x= 22.41, y= -1082.23, z=29.79, h=157.85, rX = -90.0,  rY = 0.0, rZ = -20.0},
    {x= 21.03, y= -1081.44, z=29.79, h=157.85, rX = -90.0,  rY = 0.0, rZ = -20.0},
    {x= 21.37, y= -1091.38, z=29.79, h=157.85, rX = -90.0,  rY = 0.0, rZ = -20.0},
	{x= 19.85, y= -1090.81, z=29.79, h=157.09, rX = -90.0,  rY = 0.0, rZ = -20.0},
	{x= 16.84, y= -1079.94, z=29.79, h=157.09, rX = -90.0,  rY = 0.0, rZ = -20.0},
	{x= 15.34, y= -1079.46, z=29.79, h=157.09, rX = -90.0,  rY = 0.0, rZ = -20.0},
}

--> Some color used for the "text touch" when hiting target.
RandomColorsTargetTouchText = {
    {R= 255, G= 255, B=255, A=255}, --> White
    {R= 70, G= 163, B=3, A=255}, --> Green
    {R= 3, G= 150, B=163, A=255},--> blue
	{R= 3, G= 75, B=163, A=255}, --> blue
	{R= 83, G= 3, B=163, A=255}, --> purple
	{R= 163, G= 3, B=11, A=255}, --> red
}

--> Some text used for the "text touch" when hiting target.
RandomTextTargetTouch = {
    {touch = "Wow"}, 
    {touch = "Boom"}, 
    {touch = "Hiit"},
	{touch = "poof"}, 
	{touch = "peww"},
    {touch = "splash"},
    {touch = "touch"},
    {touch = "bim"},
    {touch = "bam"},
    {touch = "bloup"},
}