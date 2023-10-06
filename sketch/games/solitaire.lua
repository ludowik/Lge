Solitaire = class() : extends(Sketch)

-- TODO : trouver un autre moyen pour pointer globalement sur le jeu (à la place de env.sketch)
-- TODO : trouver un autre moyen pour adresser items (count and last)

-- TODO : dériver des classes spécifiques pour chaque tas
-- TODO : pouvoir revenir en arrière
-- TODO : gérér un décalage entre les cartes sur tous les déplacements (du tas vers le awst, en mode auto...)
-- TODO : trouver d'autres icônes sans fioritures sur les couleurs

function Solitaire:init()
    Sketch.init(self)

    Card.setup()

    self.deckList = Array()

    self.deck = Deck(0, 0)
    self.deckList:push(self.deck)
    self.deck.position:set(6*Card.wcard+7*Card.margin, Card.hcard*1.5)

    self.wast = Deck(Card.wcard/3, 0)
    self.deckList:push(self.wast)
    self.wast.isMoveable = wast_isMoveable
    self.wast.position:set(4*Card.wcard+7*Card.margin, Card.hcard*1.5)

    self.piles = Node()
    for i in range(4) do
        local deck = Deck(0, 0)
        self.deckList:push(deck)
        deck.isMoveable = pile_isMoveable
        deck.isValidMove = pile_isValidMove
        self.piles:add(deck)
        deck.position:set((i-1)*Card.wcard+i*Card.margin, Card.hcard*1.5)
    end

    self.rows = Node()
    for i in range(7) do
        local deck = Deck(0, Card.wtext + Card.margin)
        self.deckList:push(deck)
        deck.isMoveable = row_isMoveable
        deck.isValidMove = row_isValidMove
        self.rows:add(deck)
        deck.position:set((i-1)*Card.wcard+i*Card.margin, Card.hcard*2.5+2*Card.margin)
    end
    
    self.parameter:boolean('auto', Bind(self, 'autoPlay'), true)
    self.parameter:action('Nouvelle donne', function () self:newGame() end)

    self.scene = Scene()
    self.scene:add(self.rows)
    self.scene:add(self.piles)    
    self.scene:add(self.wast)
    self.scene:add(self.deck)

    self:loadGame()
end

function Solitaire:resetGame()
    self.deck:reset()
    self.wast:reset()

    for i in range(self.piles:count()) do
        self.piles.items[i]:reset()
    end
    for i in range(self.rows:count()) do
        self.rows.items[i]:reset()
    end
end

function Solitaire:newGame()
    self:resetGame()

    self.deck:create()
    self.deck:shuffle()

    local index = 1
    local countCard = 0
    local nextStartIndex = 1

    while not (countCard == 28) do -- 7+6+5+4+3+2+1
        local card = self.deck.items:last()
        card:move2(self.rows.items[index], countCard)

        if index == #self.rows.items[index].items then
            card.faceUp = true
        end

        if index == 7 then -- #self.rows.items
            nextStartIndex = nextStartIndex + 1
            index = nextStartIndex
        else
            index = index + 1
        end
        countCard = countCard + 1        
    end
end

function Solitaire:serialize()
    return {
        deck = self.deck:serialize(),
        wast = self.wast:serialize(),
        rows = {
            self.rows.items[1]:serialize(),
            self.rows.items[2]:serialize(),
            self.rows.items[3]:serialize(),
            self.rows.items[4]:serialize(),
            self.rows.items[5]:serialize(),
            self.rows.items[6]:serialize(),
            self.rows.items[7]:serialize(),
        },
        piles = {
            self.piles.items[1]:serialize(),
            self.piles.items[2]:serialize(),
            self.piles.items[3]:serialize(),
            self.piles.items[4]:serialize(),
        }
    }
end

function Solitaire:saveGame()
    saveFile('solitaire', self:serialize())
end

function Solitaire:loadGame()
    local data = loadFile('solitaire')
    if data and data.rows and data.piles then
        self:resetGame()
        Array.foreach(data.deck, function (card)
            self.deck:push(Card(card.value, card.suit, card.faceUp))
        end)
        Array.foreach(data.wast, function (card)
            self.wast:push(Card(card.value, card.suit, card.faceUp))
        end)
        Array.foreach(data.rows, function (row, i)
            Array.foreach(row, function (card)
                self.rows.items[i]:push(Card(card.value, card.suit, card.faceUp))
            end)
        end)
        Array.foreach(data.piles, function (pile, i)
            Array.foreach(pile, function (card)
                self.piles.items[i]:push(Card(card.value, card.suit, card.faceUp))
            end)
        end)
    end
end

function Solitaire:update(dt)
    if #self.tweenManager == 0 and self.autoPlay then
        for i in range(self.rows:count()) do
            local lastCard = self.rows.items[i].items:last()
            if lastCard then
                local validMoves = Array()
                getValidMovesFor(validMoves, lastCard, self.piles.items)
                if #validMoves == 1 then
                    lastCard:move2(validMoves[1])
                end
            end
        end
    end
end

function Solitaire:draw()
    background(colors.white)
    --self.scene:draw()

    local cards = Array()

    self.deckList:foreach(function (deck)
        deck:draw()
        for _,card in ipairs(deck.items) do
            if not card.tween then
                cards:add(card)
            end
        end
    end)

    self.deckList:foreach(function (deck)
        for _,card in ipairs(deck.items) do
            if card.tween then
                cards:add(card)
            end
        end
    end)

    cards:foreach(function (card) card:draw() end)
end

Deck = class() : extends(Node)

function Deck:init(dx, dy)
    Node.init(self)

    self.reverseSearch = true
    
    self.dx = dx
    self.dy = dy

    self:reset()
end

function Deck:reset()
    self.items = Array()
end

AS = 1
VALET = 11
QUEEN = 12
KING = 13

suits = {
    spade = {name = 'pique', color = 'black'},
    heart = {name = 'coeur', color = 'red'},
    diamond = {name = 'carreau', color = 'red'},
    club = {name = 'trefle', color = 'black'},    
}

function Deck:serialize()
    local data = Array()
    self.items:foreach(function (card)
        data:push({
            value = card.value,
            suit = card.suit,
            faceUp = card.faceUp,
        })
    end)
    return data
end

function Deck:create()
    for _,suitName in ipairs{'heart', 'diamond', 'club', 'spade'} do
        for value in range(13) do
            self:push(Card(value, suits[suitName], false))
        end
    end
end

function Deck:shuffle()
    local items = self.items
    self.items = Array()
    for _ in range(#items) do
        local i = randomInt(1, #items)
        self:push(items:remove(i))
    end
end

function Deck:isMoveable(self, card)
    return true
end

function wast_isMoveable(self, card)
    return card == self.items:last()
end

function pile_isMoveable(self, card)
    return card == self.items:last()
end

function row_isMoveable(self, card)
    return card.faceUp
end

function Deck:push(card, count)
    count = count or 0

    -- compute next position
    if card.position == vec2() then
        card.position:set(self.position)
    end

    card.nextPosition = vec2()
    if #self.items == 0 then
        card.nextPosition:set(self.position.x, self.position.y)
    else
        local lastCard = self.items[#self.items]
        card.nextPosition:set(
            lastCard.nextPosition.x + self.dx,
            lastCard.nextPosition.y + self.dy)
    end

    if card.tween then
        card.tween:finalize()
    end
    
    -- init animation
    card.tween = animate(card.position, card.nextPosition, {
        delayBeforeStart = count/60,
        delay = 30/60
    }, tween.easing.quadOut, function () card.tween = nil end)

    self.items:push(card)
    card.deck = self
end

function Deck:draw()
    noFill()
    stroke(colors.gray)
    strokeSize(1)
    rect(self.position.x, self.position.y, Card.wcard, Card.hcard, Card.margin)
end

Card = class() : extends(Rect)

function Card.setup()
    Card.size = Anchor(7):size(1, 1):floor()
    Card.size.y = floor(Card.size.x * 1.5)

    Card.margin = 4

    Card.wcard = Card.size.x - 2*Card.margin
    Card.hcard = Card.size.y - 2*Card.margin

    Card.wtext = floor(Card.wcard * 0.4)
end

function Card:init(value, suit, faceUp)
    Rect.init(self, 0, 0, Card.wcard, Card.hcard)

    self.value = value
    self.suit = suit

    self.faceUp = faceUp

    self.img = Image('resources/images/'..self.suit.name..'.png')
end

local labels = {'A', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K'}

function Card:draw()
    local x, y = self.position.x, self.position.y

    local size = Card.size
    local margin = Card.margin
    local wcard = Card.wcard
    local hcard = Card.hcard
    local wtext = Card.wtext
    
    if self.faceUp then
        strokeSize(0.5)
        stroke(colors.black)
        fill(colors.white)
        rectMode(CORNER)
        rect(x, y, wcard, hcard, Card.margin)

        fontSize(wtext)
        fontName('arial')
        textMode(CENTER)
        textColor(colors.black)
        text(labels[self.value],
            x + wtext/2 + margin,
            y + wtext/2 + margin)

        spriteMode(CENTER)
        sprite(self.img,
            x + wcard - wtext/2 - margin,
            y + wtext/2 + margin, wtext, wtext)

        sprite(self.img,
            x + wcard/2,
            y + hcard - wcard/2 - margin, wcard*.7, wcard*.7)
    
    else
        strokeSize(0.5)
        stroke(colors.black)
        fill(colors.blue)
        rectMode(CORNER)
        rect(x, y, wcard, hcard, Card.margin)
    end
end

function Card:click()
    -- find first available move
    if self.tween and self.tween.state == 'running' then return end
    if not self.deck:isMoveable(self) then return end

    if self.deck == env.sketch.deck then
        for i in range(#env.sketch.wast.items) do
            local card = env.sketch.wast.items:first()
            card.faceUp = false
            card:move2bottom(env.sketch.deck)            
        end
        for i in range(3) do
            local card = env.sketch.deck.items:last()
            card.faceUp = true
            card:move2(env.sketch.wast)            
        end

    else
        local toDeck = getFirstValidMove(self)
        if toDeck then
            self:move2(toDeck)
        end
    end

    env.sketch:saveGame()
end

function Card:move2(newDeck, countCard)
    local currentDeck = self.deck
    local index = currentDeck.items:indexOf(self)
    
    while index <= #currentDeck.items do
        newDeck:push(currentDeck.items:remove(index), countCard)
    end
    
    for _,row in ipairs(env.sketch.rows.items) do
        if row == currentDeck and #currentDeck.items > 0 then
            currentDeck.items:last().faceUp = true
        end
    end

    -- print('move2Over '..labels[self.value]..' '..self.suit.name..' : '..tostring(self.faceUp))
end

function Card:move2bottom(newDeck, countCard)
    assert(self.deck.items:shift() == self)

    self.faceUp = false

    if self.tween then
        self.tween:finalize()
    end

    self.position:set(newDeck.position)
    newDeck.items:insert(1, self)
    self.deck = newDeck

    -- print('move2Bottom '..labels[self.value]..' '..self.suit.name..' : '..tostring(self.faceUp))
end

function getFirstValidMove(card)
    return getValidMoves(card)[1]
end

function getValidMovesFor(validMoves, card, items)
    for _,item in ipairs(items) do
        if item:isValidMove(card, item) then
            validMoves:add(item)
        end
    end
end

function getValidMoves(card)
    local self  = env.sketch

    local validMoves = Array()

    getValidMovesFor(validMoves, card, self.piles.items)
    getValidMovesFor(validMoves, card, self.rows.items)    

    return validMoves
end

function row_isValidMove(_, card, toDeck)
    if not card.faceUp then return false end
    if #toDeck.items == 0 then
        if card.value == KING then
            return true
        end
    else
        local last = toDeck.items:last()
        if card.value == last.value - 1 and card.suit.color ~= last.suit.color then
            return true
        end
    end
end

function pile_isValidMove(_, card, toDeck)
    if not card.faceUp then return false end
    if #toDeck.items == 0 then
        if card.value == AS then
            return true
        end
    else
        local last = toDeck.items:last()
        if card.value == last.value + 1 and card.suit.name == last.suit.name and card == card.deck.items:last() then
            return true
        end
    end
end
