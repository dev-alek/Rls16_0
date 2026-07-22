block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-elvd2q.p $
$Archive: cus/e-elvd2q.p $

Заполнение полей временной таблицы для отчета Ведомости по клиентам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/*вызвается с тремя параметрами компиляции - WHERE-Phrase для chk-doc.d-card и
where-phrase для dis-card
*/

DEFINE INPUT PARAMETER StartPoint as date no-undo.
DEFINE INPUT PARAMETER EndPoint as date no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-elvd2q.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/e-elvd2q.p $":U .
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
define variable v-pump-code as integer no-undo .

{ cus/e-elvd2d.i "SHARED" }

{ gbl/curr-r-b.i v-curr-r-b }

define buffer buf_shop for ub.shop.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_clients for ub.clients.
define buffer buf_bar-code for ub.bar-code.
define buffer card_dcards for dcards.
define buffer pet_dcards for dcards.
define buffer buf_chk-gds for ub.chk-gds.

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
    if not (v-cli-type = p-cli-type
            and
            v-cli-code = p-cli-code) then next _chk-doc.
    find first card_dcards no-lock where
              card_dcards.d-card = buf_chk-doc.d-card
          and card_dcards.chk-date = 01/01/1990
          and card_dcards.chk-time = 0
          and card_dcards.obj-type = '':U
          and card_dcards.obj-code = 0
          and card_dcards.gds-code = 0
          and card_dcards.pump = 0
          no-error.
    if not available card_dcards then do:
      create card_dcards.
      assign
      card_dcards.d-card = buf_chk-doc.d-card
      card_dcards.chk-date = 01/01/1990
      card_dcards.chk-time = 0
      card_dcards.obj-type = '':U
      card_dcards.obj-code = 0
      card_dcards.gds-code = 0
      card_dcards.pump = 0
      card_dcards.cli-type = v-cli-type
      card_dcards.cli-code = v-cli-code
      card_dcards.doc-qnty = 0
      .
    end.
    assign
    card_dcards.doc-qnty = card_dcards.doc-qnty +  buf_chk-doc.doc-qnty
    card_dcards.sum-netto = card_dcards.sum-netto +
                            (if v-curr-r-b = {&r-b-rubl}
                               then buf_chk-doc.netto
                               else (if v-base-code = 0
                                     then buf_chk-doc.netto
                                     else (buf_chk-doc.netto * buf_chk-doc.cash-rate))
                               )
    .
    for each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code,
           first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_chk-gds.b-code:
      v-pump-code = buf_chk-gds.pump.
      find first dcards no-lock where
                dcards.d-card = buf_chk-doc.d-card
            and dcards.chk-date = buf_chk-doc.chk-date
            and dcards.chk-time = buf_chk-doc.chk-time
            and dcards.obj-type = buf_chk-doc.obj-type
            and dcards.obj-code = buf_chk-doc.obj-code
            and dcards.gds-code = buf_bar-code.b-code
            and dcards.pump     = v-pump-code
            no-error.
      if not available dcards then do:
        create dcards.
        assign
        dcards.d-card = buf_chk-doc.d-card
        dcards.chk-date = buf_chk-doc.chk-date
        dcards.chk-time = buf_chk-doc.chk-time
        dcards.obj-type = buf_chk-doc.obj-type
        dcards.obj-code = buf_chk-doc.obj-code
        dcards.gds-code = buf_bar-code.gds-code
        dcards.pump     = v-pump-code
        dcards.cli-type = v-cli-type
        dcards.cli-code = v-cli-code
        dcards.doc-qnty = 0
        .
      end.
      find first pet_dcards no-lock where
                pet_dcards.d-card = '':U
            and pet_dcards.cli-type = p-cli-type
            and pet_dcards.cli-code = p-cli-code
            and pet_dcards.gds-code = buf_bar-code.gds-code
            and pet_dcards.price-real = round(buf_chk-gds.price-base - buf_chk-gds.discnt, 2) no-error.
      if not available pet_dcards then do:
        create pet_dcards.
        assign
        pet_dcards.d-card = '':U
        pet_dcards.chk-date = 01/01/1990
        pet_dcards.chk-time = 0
        pet_Dcards.pump     = 0
        pet_dcards.cli-type = p-cli-type
        pet_dcards.cli-code = p-cli-code
        pet_dcards.gds-code = buf_bar-code.gds-code
        pet_dcards.price-real = round(buf_chk-gds.price-base - buf_chk-gds.discnt, 2)
        pet_dcards.doc-qnty = 0
        .
      end.
      assign
      dcards.price-real = round(buf_chk-gds.price-base - buf_chk-gds.discnt, 2)
      dcards.doc-qnty = dcards.doc-qnty + buf_chk-gds.doc-qnty
      dcards.sum-netto = dcards.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt) *
                                            (if v-curr-r-b = {&r-b-rubl}
                                              then  1
                                              else (if v-base-code = 0
                                                    then 1
                                                    else buf_chk-doc.cash-rate)
                                              )
      pet_dcards.doc-qnty = pet_dcards.doc-qnty + buf_chk-gds.doc-qnty
      pet_dcards.sum-netto = pet_dcards.sum-netto + buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt) *
                                            (if v-curr-r-b = {&r-b-rubl}
                                              then  1
                                              else (if v-base-code = 0
                                                    then 1
                                                    else buf_chk-doc.cash-rate)
                                              )
     .
    end. /*for each buf_chk-gds no-lock where*/
  END.    /* FOR EACH chk-doc WHERE ... */
END. /* FOR EACH shop */

run waitfram-hide in this-procedure .