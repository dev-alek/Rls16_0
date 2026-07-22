block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности записи строки документа МЦ инвентар

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter parcli-type like ub.wth-doc.cli-type no-undo .
define input parameter parcli-code like ub.wth-doc.cli-code no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter par-borned like ub.wth-doc.borned no-undo .
define input parameter par-rid as recid no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности записи строки документа МЦ инвентар".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

DEFINE VARIABLE var-entry as character no-undo .
define buffer buf_wth-place for ub.wth-place .
define buffer buf_wth-line for ub.wth-line .

do
on error undo, return error
:


IF NOT CAN-FIND( ub.wealth NO-LOCK WHERE ub.wealth.wth-code = parwth-code ) THEN DO:
  MESSAGE
  "Материальная ценность" parwth-code "не найдена в справочнике!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "wth-code":U.
  return error var-entry .
END.

FIND FIRST buf_wth-place NO-LOCK WHERE
    buf_wth-place.host-code   = parhost-code AND
    buf_wth-place.obj-type    = parobj-type AND
    buf_wth-place.obj-code    = parobj-code AND
    buf_wth-place.w-p-code    = parw-p-code  NO-ERROR.
IF NOT AVAIL buf_wth-place THEN DO:
  MESSAGE
  "Документ" pardoc-code skip
  "МЦ" parwth-code skip
  "МХ" parw-p-code skip
  "Не найдено место хранения МЦ в справочнике!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "w-p-code":U.
  return error var-entry .
END.

if parauto-fill and buf_wth-place.cash-desk = 0 and not par-borned then do:
  MESSAGE
  "Документ" pardoc-code skip
  "МЦ" parwth-code skip
  "МХ" parw-p-code skip
  "Для автоматического документа место хранения должно быть кассой!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "w-p-code":U.
  return error var-entry .
end.


FIND FIRST buf_wth-line NO-LOCK WHERE
          buf_wth-line.obj-type    = parobj-type   AND
          buf_wth-line.obj-code    = parobj-code   AND
          buf_wth-line.w-p-code    = parw-p-code   AND
          buf_wth-line.wth-code    = parwth-code   AND
          buf_wth-line.doc-code    = pardoc-code AND
          RECID( buf_wth-line )   <>  par-rid NO-ERROR.
IF AVAIL buf_wth-line THEN DO:
  MESSAGE
  "В этом документе уже есть запись материальной ценности" parwth-code "по м/х" parw-p-code "!" SKIP
  "Невозможно добавить в документ!"
  VIEW-AS ALERT-BOX ERROR.
  var-entry = "wth-code":U.
  return error var-entry .
END.

end. /*doe*/