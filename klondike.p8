pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main
function _init()
	topy=2
	toprsrv=topy+16+2
	tick=0
	hoverc=9
	selectc=14
	ticklimit=8
 newgame()
 menuitem(1,"new game",newgame)
end

function _update()
	tick += 1
	if (tick > ticklimit) then tick = 0 end
end

function _draw()
 cls()
 rectfill(0,0,128,128,3)

 rendercells()
 
 renderreserves()
 rendertableaus()
 renderstock()
 
 --print(#tableaus[1].cards,1,1,0)
 --print(#stock.cards,1,10,0)
 --print(#reserves[7].cards,1,20,0)
 --print(tableaus[5].cards[1].isfaceup,1,30,0)
 --print(tableaus[1].cards[1],0,0,0)
 --print(tableaus[1].cards[1].suit)
 --print(tableaus[1].cards[1].rank)
end

function newgame()
	stock={}
	stock.x=2
	stock.y=topy
	stock.cards={}
	waste={}
	waste.x=20
	waste.y=topy
	waste.cards={}
	foundations={}
	for i=1,4 do
	 foundations[i]={}
	 foundations[i].x=62+(i-1)*16
	 foundations[i].y=topy
	 foundations[i].cards={}
	end
	
	reserves={}
	tableaus={}
	for i=1,7 do
	 local xoff=18
	 reserves[i]={}
	 reserves[i].x=2+(i-1)*xoff
	 reserves[i].y=toprsrv
	 reserves[i].cards={}
	 reserves[i].deallimit=i
	 tableaus[i]={}
	 tableaus[i].x=2+(i-1)*xoff
	 tableaus[i].y=toprsrv
	 tableaus[i].cards={}
	end
	stock.cards=createdeck()
	stock.cards=shuffle(stock.cards)
	dealhand()
end

function dealhand()
 for i=1,#reserves do
  for j=1,#reserves do
  	local rsrv=reserves[j]
  	if #stock.cards>0 then
  	 if i<=rsrv.deallimit then
  	  local card=stock.cards[#stock.cards]
  	  if i==rsrv.deallimit then
  	   add(tableaus[j].cards,card)
  	   tableaus[j].cards[#tableaus[j].cards].isfaceup=true
  	  elseif i<rsrv.deallimit then
  	   add(reserves[j].cards,card)
  	  end
  	  del(stock.cards,card)
  	 end
  	end
  end
 end
end

--createcard
function createcard(suit,rank)
 local card = {}
 card.suit = suit
 card.rank = rank
 card.isfaceup = false
 card.ishovered = false
 card.isselected = false
 return card
end

--generates a deck of 52 cards
function createdeck()
 local deck={}
	for i=1,4 do
		for j=1,13 do
			add(deck,createcard(i,j))
		end
	end
	return deck
end

--shuffle deck
function shuffle(deck)
 local shuffled = {}
 while(#deck > 0) do
  local card = deck[flr(rnd(#deck))+1]
  add(shuffled,card)
  del(deck,card)
  shuffled[#shuffled].isfaceup = false
 end
 return shuffled
end


-->8
--draw
function reflectcard(sprt,x,y)
 spr(sprt,x,y)
 spr(sprt,x+8,y,1,1,true)
 spr(sprt,x,y+8,1,1,false,true)
 spr(sprt,x+8,y+8,1,1,true,true)
end

function rendercells()
 palt(0,false)
 palt(15,true)
 pal(14,13)
 local sproutline=15
 
 reflectcard(sproutline,stock.x,stock.y)
 reflectcard(sproutline,waste.x,waste.y)
 
 for col in all(foundations) do
  reflectcard(sproutline,col.x,col.y)
 end
 
 for col in all(reserves) do
 	reflectcard(sproutline,col.x,col.y)
 end
 pal()
end

function rendercard(card,x,y)
	palt(0,false)
	palt(15,true)
	if card.isfaceup then
	 --card background
	 reflectcard(14,x,y)
	 
	 spr(card.suit+20,x+5,y+8,1,1)
	 spr(card.rank,x+1,y+1)
	else --just card back
	 spr(46,x,y,2,1)
	 spr(46,x,y+8,2,1,true,true)
	end
	if card.ishovered then
	 --todo show hover outline
	end
	if card.isselected then
	 if (tick >= ticklimit/2) then
	  pal(14,hoverc)
	 end
	 reflectcard(15,x,y)
	end
 pal()
end


--todo remove
function card7test()
 for i=1,7 do
  stock.cards[i].isfaceup = true
  stock.cards[i].isselected = true
  rendercard(stock.cards[i],(i-1)*16,50)
 end
end

function renderreserves()
 for i=1,#reserves do
  local rsrv=reserves[i]
  for j=1,#rsrv.cards do
   rendercard(rsrv.cards[j],rsrv.x,rsrv.y+(j-1)*2)
  end
 end
end

function rendertableaus()
 for i=1,#tableaus do
  local tbl=tableaus[i]
  for j=1,#tbl.cards do
   rendercard(tbl.cards[j],tbl.x,(#reserves[i].cards*2)+tbl.y+(j-1)*12)
  end
 end
end

function renderstock()
 for card in all(stock.cards) do
  rendercard(card,stock.x,stock.y)
 end
end
__gfx__
00000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff77777fffeeeee
00000000fff000fffff000fffff000fffffff0ffff00000ffff000ffff00000ffff000fffff000ffff0ff0ffff00000ffff000ffff0fff0fff777777ffefffff
00700700ff0fff0fff0fff0fff0fff0fffff00ffff0fffffff0ffffffffff0ffff0fff0fff0fff0ff00f0f0ffffff0ffff0fff0fff0ff0fff7777777feffffff
00077000ff0fff0ffffff0fffffff0fffff0f0fffff000ffff0000ffffff0ffffff000ffff0fff0fff0f0f0ffffff0ffff0fff0fff0ff0fff7777777feffffff
00077000ff00000fffff0fffffffff0fff00000fffffff0fff0fff0ffff000ffff0fff0ffff0000fff0f0f0ffffff0ffff0f0f0fff000ffff7777777feffffff
00700700ff0fff0ffff0ffffff0fff0ffffff0ffff0fff0fff0fff0fffff0fffff0fff0fffffff0fff0f0f0fff0ff0ffff0ff0ffff0ff0fff7777777feffffff
00000000ff0fff0fff00000ffff000fffffff0fffff000fffff000ffffff0ffffff000fffff000fff000f0fffff00ffffff00f0fff0fff0ff7777777feffffff
00000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7777777feffffff
0000000000000000000000000000000000000000ffff8ffffff00fffffffffffffff0fff00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000fff888ffff0000ffff88f88ffff000ff00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ff88888fff0000fff8888888ff00000f00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000f8888888f0f00f0ff8888888f000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ff88888f00000000ff88888fff00000f00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000fff888ff00000000fff888ffffff0fff00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffff8ffff00ff00fffff8fffff00f00f00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fff11c111c111fff
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff11c111c111c1ff
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f11c111c111c111f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f1c111c111c111cf
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fc111c111c111c1f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f111c111c111c11f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f11c111c111c111f
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f1c111c111c111cf
__label__
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3333311c111c11133333333dddddddddd33333333333333333333333333333333dddddddddd333333dddddddddd333333dddddddddd333333dddddddddd33333
333311c111c111c1333333d3333333333d333333333333333333333333333333d3333333333d3333d3333333333d3333d3333333333d3333d3333333333d3333
33311c111c111c1113333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
3331c111c111c111c3333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
333c111c111c111c13333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
333111c111c111c113333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
33311c111c111c1113333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
3331c111c111c111c3333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
333c111c111c111c13333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
333111c111c111c113333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
33311c111c111c1113333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
3331c111c111c111c3333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
333c111c111c111c13333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
333111c111c111c113333d333333333333d3333333333333333333333333333d333333333333d33d333333333333d33d333333333333d33d333333333333d333
33331c111c111c11333333d3333333333d333333333333333333333333333333d3333333333d3333d3333333333d3333d3333333333d3333d3333333333d3333
33333111c111c1133333333dddddddddd33333333333333333333333333333333dddddddddd333333dddddddddd333333dddddddddd333333dddddddddd33333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3333377777777773333333311c111c1113333333311c111c1113333333311c111c1113333333311c111c1113333333311c111c1113333333311c111c11133333
333377777777777733333311c111c111c133333311c111c111c133333311c111c111c133333311c111c111c133333311c111c111c133333311c111c111c13333
3337700000777777733331177777777771133331111c111c1111133331111c111c1111133331111c111c1111133331111c111c1111133331111c111c11111333
3337777707777777733331777777777777c3333111c111c111c1c3333111c111c111c1c3333111c111c111c1c3333111c111c111c1c3333111c111c111c1c333
3337777707777777733337777707777777733331177777777771133331111c111c1111133331111c111c1111133331111c111c1111133331111c111c11111333
3337777707777777733337777007777777733331777777777777c3333111c111c111c1c3333111c111c111c1c3333111c111c111c1c3333111c111c111c1c333
3337707707777777733337770707777777733337707770777777733331177777777771133331111c111c1111133331111c111c1111133331111c111c11111333
3337770077777777733337700000777777733337707707777777733331777777777777c3333111c111c111c1c3333111c111c111c1c3333111c111c111c1c333
3337777777787777733337777707777777733337707707777777733337707770777777733331177777777771133331111c111c1111133331111c111c11111333
3337777777888777733337777707777777733337700077777777733337707707777777733331777777777777c3333111c111c111c1c3333111c111c111c1c333
3337777778888877733337777777787777733337707707777777733337707707777777733337770007777777733331177777777771133331111c111c11111333
3337777788888887733337777777888777733337707770777777733337700077777777733337707770777777733331777777777777c3333111c111c111c1c333
33377777788888777333377777788888777333377777777877777333377077077777777333377777077777777333377000007777777333311777777777711333
3337777777888777733337777788888887733337777777888777733337707770777777733337777077777777733337777707777777733331777777777777c333
33337777777877773333377777788888777333377777788888777333377777770077777333377707777777777333377770777777777333377700077777777333
33333777777777733333377777778887777333377777888888877333377777700007777333377000007777777333377700077777777333377077707777777333
33333333333333333333337777777877773333377777788888777333377777700007777333377777777777777333377770777777777333377077707777777333
33333333333333333333333777777777733333377777778887777333377777070070777333377777788788777333377770777777777333377700007777777333
33333333333333333333333333333333333333337777777877773333377770000000077333377777888888877333377777777077777333377777707777777333
33333333333333333333333333333333333333333777777777733333377770000000077333377777888888877333377777770007777333377700077777777333
33333333333333333333333333333333333333333333333333333333337777007700773333377777788888777333377777700000777333377777777877777333
33333333333333333333333333333333333333333333333333333333333777777777733333377777778887777333377777000000077333377777778887777333
33333333333333333333333333333333333333333333333333333333333333333333333333337777777877773333377777700000777333377777788888777333
33333333333333333333333333333333333333333333333333333333333333333333333333333777777777733333377777777077777333377777888888877333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777700700773333377777788888777333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777777777733333377777778887777333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777777877773333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777777777733333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333

