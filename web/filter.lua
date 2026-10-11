-- Pandoc-filter voor de website (zie web/bouw.py).
-- Metadata via -M:  soort (week|voor|bijlagen|start)  maxweek (aantal weken)
local MAX_REGELS = 40
local soort, maxweek
local listing_nr = 0
local weeknr

local function html(s) return pandoc.RawBlock("html", s) end

local function lees_regels(pad)
  local f = io.open("labs/" .. pad, "r")
  if not f then error("listing niet gevonden: labs/" .. pad) end
  local r = {}
  for l in f:lines() do r[#r + 1] = l end
  f:close()
  return r
end

local function listing(cb)
  local pad = cb.attributes["include"]
  listing_nr = listing_nr + 1
  local nr = (soort == "week") and (weeknr .. "." .. listing_nr) or tostring(listing_nr)
  local regels = lees_regels(pad)
  local van = tonumber(cb.attributes["van"]) or 1
  local tot = tonumber(cb.attributes["tot"]) or #regels
  local stuk = table.concat(regels, "\n", van, tot)
  local n = tot - van + 1
  local code = pandoc.CodeBlock(stuk, pandoc.Attr("", cb.classes))
  local kop = pandoc.RawBlock("html", string.format(
    '<p class="listing-kop"><strong>Listing %s</strong> <code>labs/%s</code></p>', nr, pad))
  local lang = n > MAX_REGELS and not cb.classes:includes("volledig")
  local uit = pandoc.List({ kop })
  if lang then
    uit:insert(html(string.format('<details class="lang"><summary>Toon de listing (%d regels)</summary>', n)))
    uit:insert(code)
    uit:insert(html("</details>"))
  else
    uit:insert(code)
  end
  return pandoc.Div(uit, pandoc.Attr("", { "listing" }))
end

local function is_antwoorden_para(b)
  return b.t == "Para" and b.content[1] and b.content[1].t == "Str" and b.content[1].text == "Antwoorden:"
end

local function strip_nummer(inl)
  if #inl >= 2 and inl[1].t == "Str" and inl[1].text:match("^%d+%.$") and inl[2].t == "Space" then
    local rest = pandoc.List()
    for i = 3, #inl do rest:insert(inl[i]) end
    return rest
  end
  return inl
end

local function verwerk(blocks)
  local uit = pandoc.List()
  local subtitel = nil
  local i = 1
  local sectie = nil
  while i <= #blocks do
    local b = blocks[i]
    if b.t == "RawBlock" and b.format == "html" and b.text:match('class="subtitle"') then
      if blocks[i + 1] and (blocks[i + 1].t == "Plain" or blocks[i + 1].t == "Para") then
        subtitel = blocks[i + 1].content
        i = i + 1
      end
      if blocks[i + 1] and blocks[i + 1].t == "RawBlock" and blocks[i + 1].text:match("^</p>") then i = i + 1 end
    elseif b.t == "HorizontalRule" then
      -- streep voor het slotkader: op het web overbodig
    elseif b.t == "Header" and b.level == 1 and soort == "week" and weeknr then
      -- "Week 14: Het datapath": het nummer komt in een gekleurd blok, "Week 14:" blijft voor schermlezers en zoeken
      local inl = b.content
      local i = 1
      while i <= #inl and not (inl[i].t == "Str" and inl[i].text:match(":$")) do i = i + 1 end
      if inl[1] and inl[1].t == "Str" and inl[1].text == "Week" and i <= #inl then
        local nieuw = pandoc.List({ pandoc.RawInline("html", '<span class="weeklabel">') })
        for j = 1, i do nieuw:insert(inl[j]) end
        nieuw:insert(pandoc.RawInline("html", "</span>"))
        for j = i + 1, #inl do nieuw:insert(inl[j]) end
        b = pandoc.Header(1, nieuw, b.attr)
      end
      uit:insert(html('<div class="weekkop"><span class="badge" aria-hidden="true">' .. weeknr ..
        '</span><div class="titelblok">'))
      uit:insert(b)
      if subtitel then
        uit:insert(pandoc.Div({ pandoc.Plain(subtitel) }, pandoc.Attr("", { "subtitel" })))
        subtitel = nil
      end
      uit:insert(html("</div></div>"))
    elseif b.t == "Header" and b.level == 1 then
      uit:insert(b)
    elseif b.t == "Header" and b.level == 2 then
      sectie = pandoc.utils.stringify(strip_nummer(b.content))
      uit:insert(b)
      if soort == "week" and (sectie == "Wat je na deze week kunt") then
        local j = i + 1
        local inhoud = pandoc.List()
        while j <= #blocks and not (blocks[j].t == "Header" and blocks[j].level <= 2) do
          inhoud:insert(blocks[j]); j = j + 1
        end
        uit:insert(pandoc.Div(inhoud, pandoc.Attr("", { "doelen" })))
        i = j - 1
      elseif soort == "week" and sectie == "Antwoorden" then
        local j = i + 1
        uit:insert(html('<details class="antwoorden"><summary>Toon de antwoorden bij de oefeningen</summary>'))
        while j <= #blocks and not (blocks[j].t == "Header" and blocks[j].level <= 2) do
          local x = blocks[j]
          if x.t == "CodeBlock" and x.attributes["include"] then x = listing(x) end
          uit:insert(x); j = j + 1
        end
        uit:insert(html("</details>"))
        i = j - 1
      end
    elseif soort == "week" and sectie == "Zelftest" and is_antwoorden_para(b) then
      local inl = pandoc.List(b.content)
      inl:remove(1)
      if inl[1] and inl[1].t == "Space" then inl:remove(1) end
      uit:insert(html('<details class="antwoorden"><summary>Toon de antwoorden bij de zelftest</summary>'))
      uit:insert(pandoc.Para(inl))
      uit:insert(html("</details>"))
    elseif b.t == "CodeBlock" and b.attributes["include"] then
      uit:insert(listing(b))
    elseif b.t == "Table" then
      uit:insert(pandoc.Div({ b }, pandoc.Attr("", { "tabel" })))
    else
      uit:insert(b)
    end
    i = i + 1
  end
  return uit
end

-- "week 14" in lopende tekst wordt een link naar die weekpagina (@BASIS@ vervangt bouw.py per pagina)
local links = {
  traverse = "topdown",
  Header = function(h) return h, false end,
  Link = function(l) return l, false end,
  Inlines = function(inl)
    local uit, i, gewijzigd = pandoc.List(), 1, false
    while i <= #inl do
      local a, sp, c = inl[i], inl[i + 1], inl[i + 2]
      local nr, rest, voor, wk = nil, nil, nil, nil
      if a.t == "Str" and sp and sp.t == "Space" and c and c.t == "Str" then
        voor, wk = a.text:match("^(%p*)([Ww]eek)$")   -- ook "(week 12)"
        if wk then nr, rest = c.text:match("^(%d+)(.*)$") end
      end
      if nr and tonumber(nr) >= 1 and tonumber(nr) <= maxweek then
        if voor ~= "" then uit:insert(pandoc.Str(voor)) end
        uit:insert(pandoc.Link({ pandoc.Str(wk), sp, pandoc.Str(nr) }, string.format("@BASIS@week/%02d/", tonumber(nr))))
        if rest ~= "" then uit:insert(pandoc.Str(rest)) end
        i = i + 3
        gewijzigd = true
      else
        uit:insert(a); i = i + 1
      end
    end
    if gewijzigd then return uit end
  end,
}

function Pandoc(doc)
  soort = doc.meta.soort and pandoc.utils.stringify(doc.meta.soort) or "voor"
  maxweek = tonumber(pandoc.utils.stringify(doc.meta.maxweek or "0")) or 0
  weeknr = doc.meta.nr and tonumber(pandoc.utils.stringify(doc.meta.nr)) or nil
  local d = pandoc.Pandoc(verwerk(doc.blocks), doc.meta)
  return d:walk(links)
end
