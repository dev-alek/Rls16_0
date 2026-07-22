block-level on error undo, throw.
/*

$Revision: 7045fcb5a0f6, 1396, rls $
$Author: ASMorozov $
$Date: Thu Jun 28 15:24:33 2018 +0300 $
$Workfile: qr2uuid.p $
$Archive: str/qr2uuid.p $

Процедура определения UUID ВСД из QR-кода, напечатанного на ВСД

Автор: Молотков Сергей
Дата создания: 23/04/18
Author: Molotkov Sergey
Creation date: 23/04/18

Пример того, что возвращает сканер:
http://mercury.vetrf.ru/pub/operatorui?_language=ru&_action=showVetDocumentFormByUuid&uuid=a784f7eb-ddcc-4c0a-867d-1f957c85f2b6

*/
define input  parameter p-url      as character no-undo .
define output parameter p-chr-uuid as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 7045fcb5a0f6, 1396, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Jun 28 15:24:33 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: qr2uuid.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/qr2uuid.p $":U .
define variable vss-description as character no-undo init "Процедура определения UUID ВСД из QR-кода, напечатанного на ВСД".
{ cmp/vssrevis.i }

function qrCode2Uuid returns character (input p-url as character) :
define variable v-chr-uuid as character no-undo .
define variable v-ind1     as integer no-undo .
define variable v-ind2     as integer no-undo .
define variable v-str1     as character no-undo .

  assign
    v-ind1 = index(p-url, "&uuid=")
    v-ind2 = index(p-url, "?uuid=")
  .
  
  if (v-ind1 > 0) or (v-ind2 > 0) then do:
    v-str1 = substring(p-url, maximum(v-ind1, v-ind2) + 6) .
    v-ind1 = index(v-str1, "&") .
    v-chr-uuid = if v-ind1 > 0 then substring(v-str1, 1, v-ind1 - 1) else v-str1 .
  /* Должно быть 8 наборов по 4 цифры. Если читается вдруг не так, то приводить к нужному формату */
  /* 21/V-2018 надо оставлять группировку цифр, как возвращает сканер. К нужному формату приводить не надо.
  v-str1 = replace(v-chr-uuid, "-", "").
  v-chr-uuid = substitute("&1-&2-&3-&4-&5-&6-&7-&8"
    , substring(v-str1,  1, 4)
    , substring(v-str1,  5, 4)
    , substring(v-str1,  9, 4)
    , substring(v-str1, 13, 4)
    , substring(v-str1, 17, 4)
    , substring(v-str1, 21, 4)
    , substring(v-str1, 25, 4)
    , substring(v-str1, 29, 4)
  ) .
  */
  end .
  else v-chr-uuid = "" .
  
  return v-chr-uuid .
end function . /* end_of qrCode2Uuid */

p-chr-uuid = qrCode2Uuid (p-url) .
