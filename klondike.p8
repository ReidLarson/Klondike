pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
deck={}

function _init()

end

function _update()
end

function _draw()
	rectfill(0,0,127,127,5)
	circfill(x,y,7,14)
end

--generates a deck of 52 cards
function createdeck()
	for i=1,52 do
		deck[#deck+1]={i}
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
