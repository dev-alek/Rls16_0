block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: mrkt-ts.p $
$Archive: str/mrkt-ts.p $

Проверка необходимости послать данные на кассу MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/14/05
Author: Bakhtadze Natalya
Creation date: 02/14/05

*/

define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define output parameter p-to-send as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mrkt-ts.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/mrkt-ts.p $":U .
define variable vss-description as character no-undo init "Проверка необходимости послать данные на кассу MARIA".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/cd-attr.i }

define variable v-mes as character no-undo .
define variable v-to-send as logical no-undo init ?.
define variable ii as integer no-undo .
define variable v-attr-list as character no-undo .
define buffer buf_cash-desk for ub.cash-desk.

do
on error undo, return error
:

  if p-pos-type = '':U then dO:
    assign
    p-pos-type = {&cd-type-maria}  + {&comma-char} +
                 {&cd-type-maria}
    v-attr-list = {&cda-MARIA_operative_to-send} + {&comma-char} +
                  {&cda-MARIA_operative_petrol-to-send}
    .
  end.
  else do:
    if p-pos-type = {&cd-type-maria} then do:
      assign
      p-pos-type = {&cd-type-maria}  + {&comma-char} +
                    {&cd-type-maria}
      v-attr-list = {&cda-MARIA_operative_to-send} + {&comma-char} +
                  {&cda-MARIA_operative_petrol-to-send}
      .
    end.
  end.
  do ii = 1 to num-entries(p-pos-type):
    find first buf_cash-desk no-lock where
              buf_cash-desk.db-num = g#db-num
        AND  buf_cash-desk.obj-code = p-obj-code
        and  buf_cash-desk.pos-type = entry(ii, p-pos-type) no-error .
    if available buf_cash-desk then do:
      assign
      p-to-send = cd-attr_get-attr-log (buffer buf_Cash-desk
                                      , substitute("&1_operative", buf_cash-desk.pos-type)
                                      , input entry(ii, v-attr-list)
                                      , output v-mes).

    end.
    else v-to-send = ?.
    p-to-send = (if v-to-send <> ?
                 then (p-to-send or v-to-send)
                 else p-to-send).
  end.

end. /*doe*/