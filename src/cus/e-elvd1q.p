block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-elvd1q.p $
$Archive: cus/e-elvd1q.p $

Заполнение полей временной таблицы для отчета Ведомости по клиентам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/*вызвается с тремя параметрами компиляции - WHERE-Phrase для chk-doc.d-card и
where-phrase для dis-card
*/
define input parameter p-cli-mode as character no-undo .
DEFINE INPUT PARAMETER StartPoint as date no-undo.
DEFINE INPUT PARAMETER EndPoint as date no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-elvd1q.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-elvd1q.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета Ведомости по клиентам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/waitfram.i }


define variable v-accum as integer no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code as integer no-undo .

{ cmp/cli-list.i cli-list def "shared" }
{ cus/e-elvd1d.i "SHARED" }

{ gbl/curr-r-b.i v-curr-r-b }

define buffer buf_shop for ub.shop.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_clients for ub.clients.

for each buf_shop no-lock:
  if v-curr-r-b = {&r-b-base} then do:
    { gbl/basecode.i buf_shop.host-code v-base-code }
  end.
  _chk-doc:
  FOR EACH buf_chk-doc NO-LOCK WHERE
          buf_chk-doc.obj-type = {&shop}
      AND buf_chk-doc.obj-code = buf_shop.obj-code
      AND buf_chk-doc.chk-date >= StartPoint
      AND buf_chk-doc.chk-date <= EndPoint
      AND buf_chk-doc.out-code > '':U
      and buf_chk-doc.d-card > '':U:
    if LOOKUP(string(buf_chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _CHk-doc.
    PROCESS EVENTS .
    assign
    v-accum = v-accum + 1.
    if ( v-accum modulo 10 ) = 0  then do:
      run waitfram-show in this-procedure  (
                                        substitute("&1&2 обработано &3"  , {&shop}, buf_shop.obj-code, v-accum)
                                        ).
    end.
    if buf_chk-doc.cli-type = ?
    or buf_chk-doc.cli-code = ?
    or buf_chk-doc.cli-type = '':U
    or buf_chk-doc.cli-code = 0 then do:
      find first buf_dis-card no-lock where
                buf_dis-card.d-card = buf_chk-doc.d-card no-error .
      if available buf_dis-card then do:
        assign
        v-cli-type = buf_dis-card.cli-type
        v-cli-code = buf_dis-card.cli-code
        .
      end.
    end.
    else do:
      assign
      v-cli-type = buf_chk-doc.cli-type
      v-cli-code = buf_chk-doc.cli-code
      .
    end.
    if p-cli-mode <> "ALL" then do:
      find first cli-list no-lock where
                cli-list.obj-type = v-cli-type
            and cli-list.obj-code = v-cli-code no-error.
      if not available cli-list then next _chk-doc.
    end.
    find first dcards where
              dcards.cli-type = v-cli-type
         and  dcards.cli-code = v-cli-code no-error.
    if not available dcards then do:
      create dcards.
      assign
      dcards.cli-type = v-cli-type
      dcards.cli-code = v-cli-code
      .
      if p-cli-mode = "all" then do:
        find first buf_clients no-lock where
                  buf_clients.obj-type = dcards.cli-type
              and buf_clients.obj-code = dcards.cli-code.
        assign
        dcards.cli-name = buf_clients.obj-name.
      end.
      else do:
        assign
        dcards.cli-name = cli-list.obj-name.
      end.
    end.
    assign
    dcards.sum = dcards.sum + (if v-curr-r-b = {&r-b-rubl}
                               then buf_chk-doc.netto
                               else (if v-base-code = 0
                                     then buf_chk-doc.netto
                                     else (buf_chk-doc.netto * buf_chk-doc.cash-rate))
                               )
    .
  END.    /* FOR EACH chk-doc WHERE ... */
END. /* FOR EACH shop */

run waitfram-hide in this-procedure .