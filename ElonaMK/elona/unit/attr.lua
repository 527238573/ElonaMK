
g.attr = {
  str = 1,
  con = 1,
  dex = 1,
  per = 1,
  ler = 1,
  wil = 1,
  mag = 1,
  chr = 1,
}
g.skills = {
  
  --专业技能
  blacksmithing = 1,
  mechanics = 1,
  fabrication = 1,
  alchemy =1,
  tailoring  =1,
  jeweler =1,
  cooking =1,
  gardening =1,
  tailoring  =1,
  fishing =1,
  performer =1,
  --武器技能
  cutting =1,
  stabbing =1,
  bashing =1,
  polearm =1,
  martial_arts = 1,
  bow =1,
  firearm=1,
  energy_gun =1,
  big_gun=1,
  throw = 1,
  sheild =1,
  magic_device =1,
  soft_weapon =1,
}

function Unit.unitInitAttrAndBouns(unit)
  local attr = {
  --基础
    life = 100,
    mana = 100,
    speed = 70,
    
    --属性
  str = 1,
  con = 1,
  dex = 1,
  per = 1,
  ler = 1,
  wil = 1,
  mag = 1,
  chr = 1,
  
  --属性潜力
  str_p = 1,
  con_p = 1,
  dex_p = 1,
  per_p = 1,
  ler_p = 1,
  wil_p = 1,
  mag_p = 1,
  chr_p = 1,
}

  for k,v in pairs(g.skills) do --所有技能
    attr[k] =1
  end
  
  local bonus = {}
  for k,v in pairs(attr) do --所有在attr里的都在bonus里有
    bonus[k] =0
  end
  
  unit.attr = attr
  unit.bonus = bonus
end

