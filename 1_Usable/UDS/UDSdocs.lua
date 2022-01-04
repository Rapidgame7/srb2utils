do return end -- just in case
-- won't stop Lua from trying to interpret the rest though ok


-- ########################################## --
-- Ultimate Draw String - Usage documentation --
-- ########################################## --
-- Previously known as FontShit.lua,
-- but rewritten to be less annoying!
-- Updated to 0.0.1

/* Mini cheatsheet for common glyphs:

9 : TAB (usually empty)
32 : Space (usually empty)
48-57 : 0-9
65-90 : A-Z
97-122 : a-z

Also see: http://www.asciitable.com
*/

-- The font lib prints somewhat helpful debug messages on console.
-- Critical ones ("Now caching font X", "Font X failed to load", and such are critical, and always print.
-- Others are strictly verbose ("Assuming height is X" and others), which require the game to be in debug mode (-debug).


-- Before reading, note the following distinctions:
-- When I'm talking about a number, an integer outside the fixed point scale,
-- I will refer to it as "number".
-- If I'm talking about an integer WITHIN the fixed point scale,
-- I will refer to it as "fixedpoint".



-- ################################ --
-- FNT_Sentinel(drawer_t v)

/* Not designed to be called directly...
Performs patch caching functionality, storing glyph patches into tables for quicker access,
as well as (some) additional font consistency checks.

Can be called directly if you so desire, but it won't make any difference.
(if anything, it will cause your code to be less performant)
*/

-- Example:
hud.add( function(v,p,c)
	FNT_Sentinel(v) -- Calls upon thy Sentinel
end, "game")



-- ################################ --
-- FNT_NewFont(string name, table fontinfo)

/* Creates a new font for future use.
Must be called only once for a font, and before any attempts to draw with the font are made.

name: Must be a string. The first five characters must be "FONT_".
fontinfo: A table containing various parameters for the font.

For proper colorization, make sure the font's glyphs are colored with the recolorable shade of green.

*/

-- Available parameters for fontinfo:
fontinfo = {
	
	prefix = string,
	-- Signals the name format of each glyph of this font.
	-- The usual format to name the glyphs in SLADE is "XXXXXYYY", where:
	-- XXXXX is the prefix, and
	-- YYY is the ascii representation of said glyph.
	-- Thus, a pattern of "XXXXX%03d" can be formatted as "XXXXX000" thru "XXXXX255".
	-- Make sure that:
	-- - This parameter is a string.
	-- - Numerical pattern is not missing.
	-- - Formatted prefix does not exceed 8 characters when given a 3 character long number.
	
	monospacewidth = number,
	-- Under monospace mode, the width that all glyphs will have.
	-- Default: Average of every glyph's width, ruonded down.
	
	spacewidth = number,
	-- The width of the space glyph (ascii 32).
	-- Shortcut for doing forcedwidths[32].
	-- Default: Space glyph's patch width.
	--          If missing, monospacewidth/2
	
	height = number,
	-- The height of all glyphs.
	-- Default: Average of every glyph's height, rounded down.
	
	forcedwidths = table,
	-- Table in the format {[ascii] = number}
	-- While caching a particular glyph, the script checks if this table has the glyph's ascii number as a key.
	-- If so, will interpret this number as the glyph's width instead of using the patch's width.	
	
	spritefont = boolean, -- /!\ CURRENTLY UNIMPLEMENTED /!\
	-- No description lol
	
	charsep = number,
	-- Extra horizontal separation between each drawn glyph.
	-- Most useful when using flat color fonts whose dimensions make each glyph smush together.
	-- Default: 0
}


-- Example:
FNT_NewFont("FONT_CONSOLE", {
	prefix = "COLFN%03d",
	monospacewidth = 8,
	spacewidth = 4,
})



-- ################################ --
-- FNT_Write(drawer_t v, table drawdata)

/* Draws a string. woah
*/

-- Available parameters for drawdata:

drawdata = {
	-- The following parameters are critical (if missing, function errors):
	
	x = fixedpoint,
	y = fixedpoint,
	-- Take a guess.
	
	font = number,
	-- Font to use.
	-- Use one of the FONT constants you created!
	
	text = string,
	-- Text to draw.
	-- Glyphs missing from font will not be drawn.
	-- Accepts line breaks.
	
	
	
	-- ###
	-- The following parameters are optional:
	
	color = number,
	-- Color to use. Use SKINCOLOR constants.
	-- Internally, gets the corresponding colormap and uses such.
	-- Default: SKINCOLOR_NONE, basically no remapping.
	
	colormap = userdata, -- /!\ CURRENTLY UNIMPLEMENTED /!\
	-- Colormap to use. Overrides color for obvious reasons.
	-- Default: Whatever the current color is lol iunno
	
	flags = number,
	-- Video flags to pass to drawStretched.
	-- Default: 0
	
	wflags = number,
	-- FNT_Write specific flags to modify behaviour.
	-- See next section for available flags.
	-- Default: 0
	
	halign = fixedpoint,
	valign = fixedpoint,
	-- Text alignment. Range: [-FRACUNIT, FRACUNIT]
	-- A value of -FRACUNIT will align the font towards the left/top.
	-- A value of FRACUNIT will align the font towards the right/bottom.
	-- A value of 0 centers the font in the respective axis.
	-- Out of bound values can be used if you're crazy enough.
	-- Default: -FRACUNIT for both of them.
	
	scale = fixedpoint,
	-- Value for glyph scaling.
	-- Avoid negative scale! There is no failsafe!
	-- Default: FRACUNIT
	hscale = fixedpoint,
	vscale = fixedpoint,
	-- Same, but for separate axes.
	
	maxwidth = int,
	-- If a line exceeds this length,
	-- the remainder of the line will be shifted to the next line.
	-- Does not respect words, but a wflag can make the script attempt this.
	-- TODO: Make this a fixedpoint value in both input and code. (Maybe not?)
	
	predrawfunc = func,
	-- Function format: function(drawdata)
	-- Function to run right before drawing a glyph.
	-- (Not *exactly* - Some stuff like colormap calculation is done first)
	-- This will be called with drawdata as an argument.
	-- Allows you to do crazy things!
	-- Returning false prevents the patch from being drawn.
	
	postdrawfunc = func,
	-- Same idea, but called after the glyph is drawn. Rather useless though.
	-- Returning anything has no effect.
	
	
	
	-- ###
	-- The following parameters are also optional, but are special:
	
	xoff = fixedpoint,
	yoff = fixedpoint,
	-- Amount of distance to shift subsequent glyphs.
	-- Best used within predrawfunc.
	-- Can be assigned outside predrawfunc, but would be rather pointless.
	
	
	
	-- ###
	-- The following parameters are assigned by FNT_Write during runtime.
	-- These exist for interaction with pre/postdrawfunc.
	-- (Changing these have no effect and will be (re)set to the appropiate value next glyph)
	
	mem = table,
	-- Persistent table for the duration of the drawing process.
	-- A bit useless. Might be removed?
	
	curchar = number,
	-- The current character's position in the current line.
	
	curascii = number,
	-- The current character's ASCII representation.
	
	curline = number,
	-- The current line being processed.
	
	curchartotal = number,
	-- Characters processed so far, including this one.
	
	
	
	-- ###
	-- Shorthand is also available:
	[1] = x,
	[2] = y,
	[3] = font,
	[4] = text,
	[5] = flags,
	[6] = color,
	-- They take priority over their named counterparts
}


-- Available flags and constants:

flags = {
	WF_INTPOS, -- Signals the script that positions input in X and Y are not in fixed point.
	           -- Makes script multiply them by FRACUNIT.
	
	WF_NOLINEFEED, -- Prevents the script from processing new lines as such.
	
	WF_WORDWRAP, -- If data.maxwidth is set, attempts wrapping while respecting words.
				 -- (For the purposes of the script, words are defined as
				 -- non-space characters that are together)
}

constants = {
	
	-- For alignment:
	HALIGN_LEFT, -- -FRACUNIT
	HALIGN_MIDDLE, HALIGN_CENTER, -- 0
	HALIGN_RIGHT, -- FRACUNIT
	
	VALIGN_TOP, -- -FRACUNIT
	VALIGN_MIDDLE, VALIGN_CENTER, -- 0
	VALIGN_BOTTOM, -- FRACUNIT
	
	
}




-- Example:

-- Rainbow text
FNT_Write(v, {x=100*FRACUNIT, y=50*FRACUNIT, text="Rainbow text!", font=FONT_CONSOLE, valign=0, halign=0,
	predrawfunc = function(d)
		d.color = rainbo[((d.curchar-1+leveltime/3) % #rainbo) + 1]
	end
})





-- okay that's it

-- trailing newlines





















