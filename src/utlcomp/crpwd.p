block-level on error undo, throw.
define input  parameter iRc as logical no-undo.
define variable mOutFile as character no-undo.
define variable mMaxNumPas as integer no-undo.
define variable mLogin as character no-undo init "sysadm".
mOutFile = replace (search(program-name (1)),"crpwd.p","crpwd.i").
function crpas returns integer  (input iText as character) forward.
output to value(mOutFile).
   crpas("sysadm").
   mMaxNumPas = 6.
   crpas("!sysadm_new1").
   crpas(" аждыйќхотникƒолжен«нать√де—идит‘азан").
   crpas("»ногдаЌашќгонь√аснетЌоƒругой„еловек—нова–аздувает≈го").
   crpas("¬сеƒело¬ћгновенииќноќпредел€ет∆изнь").
   crpas("»ногда’ватаетћгновени€„тобы«абыть∆изнь").
   crpas("ј»ногдаЌе’ватает∆изни„тобы«абытьћгновение").
   crpas("Ќе¬ыпускайте—олнце»зƒушиќно“епломѕо∆изни–азойдетс€").
   crpas("ћјћј¬сего„етыреЅуквыј—мыслƒлиною¬∆изнь").
   crpas("—ложнее¬сего«абывать“ехЋюдей— оторыми“ы«абывалќбо¬сЄм").
   crpas("ћолчание¬сегдаЌаполнено—ловами").
   crpas("’орошиеƒрузь€’орошие ниги»—п€ща€—овесть¬от»деальна€∆изнь").
   crpas("”йтиЌеѕодвигѕодвигЌе¬ернутьс€≈сенин").
   crpas("ѕорой„увства ак÷ветокЌужно¬рем€„тобы–аспуститьс€").
   crpas("∆ивешь¬едь“олько–аз“олько–аз–ешайс€").
   crpas("—амое¬ажное¬∆изниЁтоЌаучитьс€ѕадать").
   crpas("„асто—частье»щут“ак∆е акќчки огдаќниЌаЌосу").
   crpas("«апомнитеЁтотƒень¬озврату»ќбменуЌеѕодлежит").
   crpas("≈сли’очешь”видеть„удоЅудь»м").
   crpas("¬се”спехиЌачинаютс€——амодисциплины").
   crpas("¬чераЁто»стори€«автраЁто«агадкај—егодн€Ётоƒар").
   crpas("„емЌиже„еловекƒушой“ем¬ыше«адираетЌос").
   crpas("—амоеѕрекрасное—мотреть¬√лаза„еловеку оторый”лыбаетс€").
   crpas("Ћучша€–еакци€Ќа¬ражескую ритику”лыбнутьс€»«абыть").
   crpas("ѕлата«а»ндивидуальностьќдиночество").
   crpas("ƒовериеЁто¬ажној“очнееЁто¬сЄ").
   crpas("Ѕерегите¬—ебе„еловека").
   crpas("»≈слиѕридетс€”пасть”пади расиво").

   /* Ёто должна быть последн€€ строка зоздани€ записи парол€*/
   if iRc
   then
      crpas("Ќеизвестна€¬ерси€ѕарол€ѕарол€").
   else
      crpas("sysadm").
      
      
      
   mMaxNumPas = 0.
   mLogin = "odbc".
   crpas(mLogin).
   mMaxNumPas = 6.
   crpas("odbc").
   crpas("111Ўла—ашаѕоЎоссе»—осала—ушку!!!").
   if not iRc
   then
      crpas("odbc").
   
   
output close.


function covchar returns character   (input iText as character):
  define variable oldchar as character no-undo
  init "йцукенгшщзхъфывапролджэ€чсмитьбюЄ…÷” ≈Ќ√Ўў«’Џ‘џ¬јѕ–ќЋƒ∆я„—ћ»“№Ѕё®Ё"
  .
  define variable newchar as character no-undo
  init "qwertyuiop[]asdfghjkl;'zxcvbnm,.tQWERTYUIOP{}ASDFGHJKL:ZXCVBNM<>T-"
  .
  newchar = newchar + '"'.
  define variable vi as integer no-undo.
  do vi = 1 to length(oldchar):
     iText = replace(itext,substring(oldchar,vi,1),substring(newchar,vi,1)).
  end.
  return iText. 
end.

function crpas returns integer  (input iText as character):
put unformatted  "create pasSysadm." skip .
put unformatted  "assign" skip.
 mMaxNumPas     = mMaxNumPas + 1.
put unformatted  '     pasSysadm.Flogin  = "' + mLogin + '"'         skip .
put unformatted  "     pasSysadm.num     = " mMaxNumPas              skip .
put unformatted  '                      /* "' + itext + '" */'       skip .
put unformatted  '     pasSysadm.pasw    = "' + covchar(itext) + '"' skip .
put unformatted  "  .  " skip(1) .
  

end.  