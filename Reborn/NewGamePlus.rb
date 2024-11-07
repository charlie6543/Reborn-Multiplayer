def getNGPData
  $Unidata[:starterQ] = ($game_variables[:Starter_Quest] >= 21) if $Unidata[:starterQ] != true
  $Unidata[:magicS] = $game_switches[:Magic_Square_Done] if $Unidata[:magicS] != true
  $Unidata[:dexQ] = $game_switches[:Dex_Quest_Done] if $Unidata[:dexQ] != true
  # $Unidata[:spiritQ] = ($game_variables[:Spirit_Rewards]>=25) if $Unidata[:spiritQ] != true
  $Unidata[:treePuzzle] = ($game_variables[:Xernyvel] >= 19) if $Unidata[:treePuzzle] != true
  $Unidata[:vrGem3] = $game_switches[:VR_Gem3] if $Unidata[:vrGem3] != true
  $Unidata[:vrGem4] = $game_switches[:VR_Gem4] if $Unidata[:vrGem4] != true
  $Unidata[:vrGem5] = $game_switches[:VR_Gem5] if $Unidata[:vrGem5] != true
  $Unidata[:southAv] = $game_switches[:HearPinsir_Puzzle] if $Unidata[:southAv] != true
  $Unidata[:chessPuzzle] = ($game_variables[:E10_Story] >= 40) if $Unidata[:chessPuzzle] != true

  # NG++ mod by Stardust
  $Unidata[:mirage] = ($game_variables[377] >= 6) if $Unidata[:mirage] != true
  $Unidata[:mirage2] = ($game_variables[646] >= 3) if $Unidata[:mirage2] != true
  $Unidata[:saphiraGym] = $game_switches[1098] if $Unidata[:saphiraGym] != true
  $Unidata[:vrAme] = ($game_variables[520] >= 9) if $Unidata[:vrAme] != true
  $Unidata[:tinaDoor] = (($game_variables[651] >= 11) && (!$game_switches[1867])) if $Unidata[:tinaDoor] != true
  $Unidata[:sub7stealth] = $game_switches[528] if $Unidata[:sub7stealth] != true
  $Unidata[:sugiline] = ($game_switches[887] && $game_switches[886]) if $Unidata[:sugiline] != true
  $Unidata[:vrEmer] = ($game_variables[521] >= 8) if $Unidata[:vrEmer] != true
  $Unidata[:necro] = ($game_variables[725] >= 9) if $Unidata[:necro] != true
  $Unidata[:devon] = ($game_variables[339] >= 39) if $Unidata[:devon] != true
  $Unidata[:blacksteam] = ($game_variables[107] >= 13) if $Unidata[:blacksteam] != true
  $Unidata[:route2] = ($game_variables[173] >= 8) if $Unidata[:route2] != true
  $Unidata[:vrSaph] = ($game_variables[523] >= 1) if $Unidata[:vrSaph] != true
  $Unidata[:mineboom] = ($game_variables[475] >= 118) if $Unidata[:mineboom] != true

  # $Unidata[:fieldNotes] = checkSeenFields

  # new stuff
  $Unidata[:tapu] = ($game_variables[617] >= 5) if $Unidata[:tapu] != true
  $Unidata[:lati] = ($game_variables[622] >= 14) if $Unidata[:lati] != true
  $Unidata[:amyZek] = ($game_switches[657] && !$game_switches[878]) if $Unidata[:amyZek] != true
  $Unidata[:amyResh] = ($game_switches[657] && $game_switches[878]) if $Unidata[:amyResh] != true
  $Unidata[:charGym] = $game_switches[499] if $Unidata[:charGym] != true
  $Unidata[:charBackRoom] = $game_switches[1033] if $Unidata[:charBackRoom] != true
  $Unidata[:scrapyard] = ($game_variables[381] >= 1) if $Unidata[:scrapyard] != true
  $Unidata[:voidskip] = ($game_variables[391] >= 45) if $Unidata[:voidskip] != true
  $Unidata[:shaymin] = ($game_variables[641] >= 19) if $Unidata[:shaymin] != true
  saveClientData
end
