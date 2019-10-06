pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--main
function _init()
	topy=3
	toprsrv=topy+16+3
	tick=0
	hoverc=9
	selectc=14
	ticklimit=8
	hoveredarea="stock"
	hoveredxindex=1
	hoveredyindex=1
	
 newgame()
 deselectcards()
 menuitem(1,"new game",newgame)
end

function _update()
	changearea()
 cardsupdate()
 selectedtick()
end

function _draw()
 cls()
 rectfill(0,0,128,128,3)

 drawcells()
 
 drawreserves()
 drawtableaus()
 drawstock()
 drawwaste()
 drawfoundations()
 
 --debug
 print(hoveredxindex,2,50,0)
 print(hoveredyindex,2,56,0)
 print(#foundations[1].cards,2,62,0)
 print(#foundations[2].cards,2,68,0)
 print(#foundations[3].cards,2,74,0)
 print(#foundations[4].cards,2,80,0)
 print(reserverank,2,86,0)
 print(reservecount,2,92,0)
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
	 foundations.y=topy
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
--update
function selectedtick()
	tick += 1
	if (tick > ticklimit) then
		tick = 0
	end
end

function cardsupdate()
 if hoveredarea~="reserves" then
  deselectcards()
 end

 --stock
 for i=1,#stock.cards do
  stock.cards[i].ishovered=false
  stock.cards[i].isselected=false
  stock.cards[i].isfaceup=false
  if hoveredarea=="stock" and i==#stock.cards then
   stock.cards[i].ishovered=true
  end
 end
 
 --waste
 for i=1,#waste.cards do
  waste.cards[i].isfaceup=true
  waste.cards[i].ishovered=false
  if i==#waste.cards then
   if hoveredarea=="waste" then
    waste.cards[i].ishovered=true
   end
  end
 end
 
 --foundations
 for i=1,#foundations do
  for j=1,#foundations[i].cards do
   foundations[i].cards[j].isfaceup=true
   foundations[i].cards[j].ishovered=false
  end
 end
 
 --reserves
 for i=1,#reserves do
  for j=1,#reserves[i].cards do
   reserves[i].cards[j].isfaceup=false
   
   --todo make this work
   reserves[i].cards[j].ishovered=i==hoveredxindex and #tableaus[i].cards==0 and j==#reserves[i].cards
  end
 end
 
 --tableaus
 for i=1,#tableaus do
  for j=1,#tableaus[i].cards do
   tableaus[i].cards[j].isfaceup=true
   tableaus[i].cards[j].ishovered=j>=hoveredyindex and hoveredxindex==i and hoveredarea=="reserves"
  end
 end
end

function selectcards()
 if hoveredarea=="reserves" then
  selectedxindex=hoveredxindex
  selectedyindex=hoveredyindex
  for i=selectedyindex,#tableaus[selectedxindex].cards do
   tableaus[selectedxindex].cards[i].isselected=true
  end
 end
end

function deselectcards()
 selectedxindex=nil
 selectedyindex=nil
 for i=1,#tableaus do
  for j=1,#tableaus[i].cards do
   tableaus[i].cards[j].isselected=false
  end
 end
end
-->8
--draw
function reflectcard(sprt,x,y)
 spr(sprt,x,y)
 spr(sprt,x+8,y,1,1,true)
 spr(sprt,x,y+8,1,1,false,true)
 spr(sprt,x+8,y+8,1,1,true,true)
end

function drawcells()
	--todo hover state

 palt(0,false)
 palt(15,true)
 local sprcolor=14
 local standardc=6
 local hoverc=14
 local sprindex=15
 
 --stock
 local usecolor = standardc
 if hoveredarea=="stock" then
  pal(sprcolor,hoverc)
 else
  pal(sprcolor,standardc)
 end
 reflectcard(sprindex,stock.x,stock.y)
 
 --waste
 if hoveredarea=="waste" then
  pal(sprcolor,hoverc)
 else
  pal(sprcolor,standardc)
 end
 reflectcard(sprindex,waste.x,waste.y)
 
 --foundations
 pal(sprcolor,standardc)
 for col in all(foundations) do
  reflectcard(sprindex,col.x,foundations.y)
 end
 
 --reserves
 for i=1,#reserves do
  local col=reserves[i]
  if hoveredarea=="reserves" and i==hoveredxindex then
   pal(sprcolor,hoverc)
  else
   pal(sprcolor,standardc)
  end
 	reflectcard(sprindex,col.x,col.y)
 end
 pal()
end

function drawcard(card,x,y,isshadowed)
	palt(0,false)
	palt(15,true)
	if card.isfaceup then
		if isshadowed then
	  pal(14,6)
	  spr(15,x,y-1)
	  spr(15,x+8,y-1,1,1,true)
	  pal()
	  palt(0,false)
	  palt(15,true)
	 end
	
	 --card background
	 reflectcard(14,x,y)
	 
	 spr(21+2*(card.suit-1),x,y+1,2,2)
	 spr(card.rank,x+1,y+1)
	else --just card back
	 spr(46,x,y,2,1)
	 spr(46,x,y+8,2,1,true,true)
	end
	if card.ishovered then
	 reflectcard(15,x,y)
	end
	if card.isselected then
	 if (tick >= ticklimit/2) then
	  pal(14,hoverc)
	 end
	 reflectcard(15,x,y)
	end
 pal()
end

function drawreserves()
 for i=1,#reserves do
  local rsrv=reserves[i]
  for j=1,#rsrv.cards do
   drawcard(rsrv.cards[j],rsrv.x,rsrv.y+(j-1)*2)
  end
 end
end

function drawtableaus()
 for i=1,#tableaus do
  local tbl=tableaus[i]
  for j=1,#tbl.cards do
   local isshadowed=j>1
   drawcard(tbl.cards[j],tbl.x,(#reserves[i].cards*2)+tbl.y+(j-1)*7,isshadowed)
  end
 end
end

function drawstock()
 for card in all(stock.cards) do
  drawcard(card,stock.x,stock.y)
 end
end

function drawwaste()
 --todo make sure this works
 for card in all(waste.cards) do
  drawcard(card,waste.x,waste.y)
 end
end

function drawfoundations()
	--todo make sure this works
	for i=1,#foundations do
	 for j=1,#foundations[i].cards do
	  drawcard(foundations[i].cards[j],foundations[i].x,foundations.y)
	 end
	end
end
-->8
--interaction
function changearea()
	if hoveredarea=="stock" then
	 if btnp(➡️) or btnp(⬅️) then
	 	hoveredarea="waste"
	 elseif btnp(⬇️) then
   enterreserves()
  elseif btnp(🅾️) then
   flipstock()
	 end
	elseif hoveredarea=="waste" then
	 if btnp(⬅️) or btnp(➡️) then
	  hoveredarea="stock"
	 elseif btnp(⬇️) then
   enterreserves()
	 end
	elseif hoveredarea=="reserves" then
	 if btnp(⬆️) then
	  if #tableaus[hoveredxindex].cards==0 or hoveredyindex==1 then
	   exitreserve(hoveredxindex)
	  	hoveredarea="stock"
	  else
	   --tableaus[hoveredxindex].cards[hoveredyindex].ishovered=false
	   hoveredyindex-=1
	   --tableaus[hoveredxindex].cards[hoveredyindex].ishovered=true
	  end
	 elseif btnp(⬇️) then
	  local cardcount=#tableaus[hoveredxindex].cards
	  if cardcount>0 and cardcount~=hoveredyindex then
	   --tableaus[hoveredxindex].cards[hoveredyindex].ishovered=false
	   hoveredyindex+=1
	   --tableaus[hoveredxindex].cards[hoveredyindex].ishovered=true
	  end
	  deselectcards()
	 elseif btnp(➡️) or btnp(⬅️) then
	  --todo while selection~=nil, check if new xindex has a tableau, skip if it doesn't
	  if btnp(➡️) then
	  	newxindex=hoveredxindex+1
	  	if newxindex>#tableaus then newxindex=1 end
	  else
	   newxindex=hoveredxindex-1
	   if newxindex<1 then newxindex=#tableaus end
	  end
	  exitreserve(hoveredxindex)
	  hoveredxindex=newxindex
	  enterreserves()
	 elseif btnp(🅾️) then
	  local tableaucount=#tableaus[hoveredxindex].cards
	  local reservecount=#reserves[hoveredxindex].cards
	  if tableaucount>0 or (reservecount==0 and tableaucount==0) then
		  if selectedxindex==hoveredxindex then
		   deselectcards()
		  elseif selectedxindex==nil then
		   selectcards()
		  else
		   checkmovetableau()
		  end
		 elseif selectedxindex==nil then
		  flipreserve()
		 end
		elseif btnp(❎) then
		 if selectedxindex~=nil then
		  deselectcards()
		 else
		 	checkmovetofoundation()
		 end
	 end
	end
end

function checkmovetofoundation()
 local tableau=tableaus[hoveredxindex]
 local cardcount=#tableau.cards
 if cardcount>0 then
  local cardsuit = tableau.cards[cardcount].suit
  local cardrank = tableau.cards[cardcount].rank
  local foundation = foundations[cardsuit]
  local foundationcount = #foundation.cards
  --todo change this to a local variable
  local foundationrank=0
  if foundationcount>0 then
   foundationrank=foundation.cards[foundationcount].rank
  end
  if cardrank==foundationrank+1 then
   sfx(0)
   movetofoundation()
  end
 end
end

function movetofoundation()
 local card=tableaus[hoveredxindex].cards[#tableaus[hoveredxindex].cards]
 add(foundations[card.suit].cards,card)
 del(tableaus[hoveredxindex].cards,card)
end

function flipstock()
 local stockcount=#stock.cards
 if stockcount>0 then
	 local card=stock.cards[stockcount]
	 debugcard=card
	 add(waste.cards,card)
	 del(stock.cards,card)
	else
	 for i=#waste.cards,1,-1 do
	  add(stock.cards,waste.cards[i])
	 end
	 while #waste.cards>0 do
	  del(waste.cards,waste.cards[1])
	 end
 end
end

function flipreserve()
 local reserve=reserves[hoveredxindex]
 local card=reserve.cards[#reserve.cards]
 add(tableaus[hoveredxindex].cards,card)
 del(reserves[hoveredxindex].cards,card)
 hoveredyindex=1
end

function checkmovetableau()
 --todo code for handling moving to empty reserve
 --todo code for handling moving from waste to tableau or empty reserve
 if hoveredarea=="reserves" and selectedxindex~=nil and selectedxindex~=hoveredxindex then
  if selectedxindex~=nil and #tableaus[hoveredxindex].cards>0 then
		 local selectedcard=tableaus[selectedxindex].cards[selectedyindex]
		 local hoveredcard=tableaus[hoveredxindex].cards[#tableaus[hoveredxindex].cards]
		 if hoveredcard~=nil and selectedcard.suit%2~=hoveredcard.suit%2 and selectedcard.rank==hoveredcard.rank-1 then
		  movetableau()
		 end
		elseif #tableaus[hoveredxindex].cards==0 and #reserves[hoveredxindex].cards==0 then
		 --move king to empty cell
			movetableau()
	 else
	  sfx(0)
	  --todo play did not happen sfx?
	 end
 end 
end

function movetableau()
 for i=selectedyindex,#tableaus[selectedxindex].cards do
	 add(tableaus[hoveredxindex].cards,tableaus[selectedxindex].cards[i])
	end
 local i=selectedyindex
 while i<=#tableaus[selectedxindex].cards do
  del(tableaus[selectedxindex].cards,tableaus[selectedxindex].cards[i])
 end
 deselectcards()
 --todo play sfx?
end

function enterreserves()
 hoveredarea="reserves"
 local x=hoveredxindex
 if #tableaus[x].cards>0 then
  hoveredyindex=1
  --tableaus[x].cards[hoveredyindex].ishovered=true
 elseif #reserves[x].cards>0 then
  hoveredyindex=#reserves[x].cards
  reserves[x].cards[hoveredyindex].ishovered=true
 end
end

function exitreserve(xindex)
 for i=1,#reserves[xindex].cards do
  reserves[xindex].cards[i].ishovered=false
 end
 for i=1,#tableaus[xindex].cards do
  --tableaus[xindex].cards[i].ishovered=false
 end
end
__gfx__
00000000ffcccccfffcccccfffcccccfffffcccffcccccccffcccccffcccccccffcccccfffcccccffccccccffcccccccffcccccffcccfcccfff77777fffeeeee
00000000fcc777ccfcc777ccfcc777ccfffcc7cffc77777cfcc777cffc77777cfcc777ccfcc777cccc7cc7ccfc77777cfcc777ccfc7ccc7cff777777ffefffff
00700700fc7ccc7cfc7ccc7cfc7ccc7cffcc77cffc7cccccfc7ccccffcccc7ccfc7ccc7cfc7ccc7cc77c7c7cfcccc7ccfc7ccc7cfc7cc7ccf7777777feffffff
00077000fc7ccc7cfcccc7ccfcccc7ccfcc7c7ccfcc777ccfc7777ccffcc7ccffcc777ccfc7ccc7ccc7c7c7cffffc7cffc7ccc7cfc7cc7cff7777777feffffff
00077000fc77777cffcc7ccffccccc7cfc77777cfccccc7cfc7ccc7cffc777cffc7ccc7cfcc7777cfc7c7c7cfcccc7cffc7c7c7cfc777ccff7777777feffffff
00700700fc7ccc7cfcc7ccccfc7ccc7cfcccc7ccfc7ccc7cfc7ccc7cffcc7ccffc7ccc7cffcccc7cfc7c7c7cfc7cc7cffc7cc7ccfc7cc7ccf7777777feffffff
00000000fc7cfc7cfc77777cfcc777ccffffc7cffcc777ccfcc777ccfffc7cfffcc777ccffc777ccfc7cc7ccfcc77ccffcc77c7cfc7ccc7cf7777777feffffff
00000000fcccfcccfcccccccffcccccfffffcccfffcccccfffcccccffffcccffffcccccfffcccccffccccccfffccccffffccccccfcccfcccf7777777feffffff
0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
0000000000000000000000000000000000000000fffffffffff8fffffffffffffff0ffffffffffffff8f8ffffffffffffff0ffff000000000000000000000000
0000000000000000000000000000000000000000ffffffffff888ffffffffffffffffffffffffffffff8ffffffffffffff000fff000000000000000000000000
0000000000000000000000000000000000000000fffffffffff8ffffffffffffff0f0fffffffffffffffffffffffffffffffffff000000000000000000000000
0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000
0000000000000000000000000000000000000000fffffffff8fffffffffffffff0fffffffffffff8fff8fffffffffffff0ffffff000000000000000000000000
0000000000000000000000000000000000000000ffffffff888fffffffffffff000fffffffffff888f888fffffffffff000fffff000000000000000000000000
0000000000000000000000000000000000000000fffffff88888ffffffffffff000ffffffffff888888888fffffffff00000ffff000000000000000000000000
0000000000000000000000000000000000000000ffffff8888888fffffffff00f0f00ffffffff888888888ffffffff0000000fff00000000fff11c111c111fff
0000000000000000000000000000000000000000fffff888888888fffffff000000000fffffff888888888fffffff000000000ff00000000ff11c111c111c1ff
0000000000000000000000000000000000000000ffffff8888888fffffffff00f0f00fffffffff8888888fffffffff0000000fff00000000f11c111c111c111f
0000000000000000000000000000000000000000fffffff88888fffffffffffff0fffffffffffff88888fffffffffffff0ffffff00000000f1c111c111c111cf
0000000000000000000000000000000000000000ffffffff888fffffffffffff000fffffffffffff888fffffffffffff000fffff00000000fc111c111c111c1f
0000000000000000000000000000000000000000fffffffff8fffffffffffff00000fffffffffffff8fffffffffffff00000ffff00000000f111c111c111c11f
0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000f11c111c111c111f
0000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000f1c111c111c111cf
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

__sfx__
00010000180000c000240002a050000000000029050000002a0502a0502a0502a0502a0502a05029050290502905029050290502a0502b0502b0502b0502b0502b05000000000000000000000000000000000000
