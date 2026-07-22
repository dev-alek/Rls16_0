/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

заполнение полей временной таблицы для выгрузки в файл ТСД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/28/05
Author: Bakhtadze Natalya
Creation date: 10/28/05

*/
/* loc-goods -  предполагается goods */
/* loc-bar-code -  предполагается bar-code */
/* loc-gds-prt -  предполагается gds-prt корень*/
/* loc-gds-obj -  предполагается gds-obj */
/* loc-price-list -  предполагается price-list */
/* loc-units -  предполагается units */
/* loc-gds-prt-term -  предполагается gds-prt для признака*/
/* loc-prod-bc -  предполагается prod-bc */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE asc-gds.
DEFINE parameter buffer loc-goods for {1}.
DEFINE parameter buffer loc-bar-code for ub.bar-code.
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
/*для совместимости со стандартными кассовыми инклюдами*/
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
/*цена в спуле*/
DEFINE VARIABLE for-price                    as decimal          no-undo init ?.
/*дор налог*/
DEFINE VARIABLE for-road                     as decimal          no-undo .
/*акциз*/
DEFINE VARIABLE for-excise                   as decimal          no-undo .
/*переоценка*/
define variable v-doc-num like ub.price-list.doc-num no-undo .

/*код представленяи на POS_IBM*/
DEFINE VARIABLE IBM-good-code                as character        no-undo .
/*код представленяи на POS_IBM*/
DEFINE VARIABLE IBM-good-code-2              as character        no-undo .
define variable v-no-price                   as integer no-undo .
define variable v-err-price                  as integer no-undo .
define variable v-no-time                    as integer no-undo .

define variable IBM2-short as character no-undo .


DEF BUFFER BUF_BAR-CODE FOR UB.BAR-CODE.
DEF BUFFER BUF_PRICE-DOC FOR UB.PRICE-DOC.
/*отсечем заведомо неверные */
CASE v-bb-mode:
  when "bb-list" then do:
    /*а вообще какой-нибудь код по этому есть?*/
    find first bb-list no-lock where
            bb-list.gds-code = loc-bar-code.gds-code
        and bb-list.node-code = loc-bar-code.node-code
        and bb-list.unit-cli = loc-bar-code.unit-cli no-error.
    if not available bb-list then return.
  end.
  when "b-code" then do:
    find first bb-list no-lock where
            bb-list.gds-code = loc-bar-code.gds-code
        and bb-list.node-code = loc-bar-code.node-code
        and bb-list.unit-cli = loc-bar-code.unit-cli
          AND bb-list.b-str = '':U no-error .
    if not available bb-list then return.
  end.
END.
if v-is-price then do:
  if v-no-good and l-empty-scale then do:
    assign
    v-no-price = 1
    .
  end.
  else do:
    if v-err-ov = 0 then do:
      for-price = ?.
      { gbl/bcodeprc.i
        i-obj-type
        i-obj-code
        loc-bar-code.b-code
        main-b-code
        0
        v-doc-num
        for-price
        for-road
        for-excise
        no-error
      }
      if error-status:error then do:
        assign
        v-err-price = 1
        .
      end.
      if return-value = "error" then do:
        if for-price = ? then do:
          assign
          v-no-price = 1
          .
        end.
        else do:
          assign
          v-err-price = 1
          .
        end.
      end.
      else if for-price = ? then do:
        assign
        v-no-price = 1
        .
      end.
    end. /*v-err-ov = 0*/
  end. /*v-no-good = yes*/
end. /*нужна цена*/
if for-price <> 0
and for-price <> ?
then for-price = round-m( for-price , rnd-znak ).
if v-is-time then do:
  if v-no-good then do:
    assign
    v-no-price = 1
    .
  end.
  else do:
    if v-err-ov = 0 then do:
      find first buf_price-doc no-lock where
                buf_price-doc.doc-num = v-doc-num no-error .
      if not avail buf_price-doc then do:
        assign
        v-no-time = 1
        .
      end.
    end.
  end.
end.
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-gds then do:
create cash-gds.
error-status:error = false.
end.
cash-gds.crf = cr + 1.
cr = cr + 1.
assign
cash-gds.gds-code = loc-goods.gds-code
cash-gds.artic = loc-goods.artic
cash-gds.b-code = loc-bar-code.b-code
cash-gds.node-code = loc-bar-code.node-code
cash-gds.part-code = loc-bar-code.part-code
cash-gds.in-code   = loc-bar-code.in-code
/*если loc-prod-bc <> значит это для prod-bc*/
cash-gds.b-str = if loc-prod-bc = ? then "" else loc-prod-bc
cash-gds.bc-on-type = loc-bc-on-type
cash-gds.unit-cli = loc-bar-code.unit-cli
cash-gds.cli-base-rate = loc-bar-code.cli-base-rate
cash-gds.gds-name = loc-goods.gds-name
cash-gds.engl-name = loc-goods.engl-name
/*посмотрим как они разберутся без этого - хаха*/
/*
cash-gds.chk-name = IF nam-artc
                      then loc-goods.artic
                    else (if loc-goods.chk-name <> ""
                          then loc-goods.chk-name
                          else loc-goods.gds-name)
                          */
cash-gds.f-name = if NOT l-empty-scale then loc-gds-prt-term.f-name else ""
cash-gds.unit-base = loc-goods.unit-base
cash-gds.price-sale =  for-price
cash-gds.unit-type = loc-units.type
cash-gds.unit-cli-type = loc-bc-units-cli-type
cash-gds.new-good = new-good
cash-gds.prod-name = for-prod-name
cash-gds.price-date =  if avail buf_price-doc then buf_price-doc.fact-date else ?
cash-gds.price-time = if avail buf_price-doc then buf_price-doc.fact-time else 0
cash-gds.rc = recid(loc-goods)
cash-gds.is-err = (v-artic-delim * 16 + v-err-ov + v-err-price * 2 + v-no-price * 4 + v-no-time * 8 )
.
if new-good then new-good = not new-good.

assign
IBM-good-code = "":U
IBM-good-code-2 = "":U
.
run ibm-gdsc in this-procedure (
                                 input no /*p-zeros*/
                                ,output IBM-good-code
                                ,output IBM-good-code-2
                                ,output IBM2-short
  ) no-error .
if error-status:error then do:
  return.
end.
if IBM-good-code = "":U then
assign
IBM-good-code = IBM-good-code-2
.
if IBM-good-code <> "":U then
assign
cash-gds.b-code-tsd = IBM-good-code
.
if IBM-good-code <> Ibm-good-code-2
and ibm-good-code-2 <> "":U then do:

    FIND FIRST buf_cash-gds where
            buf_cash-gds.crf = (cr + 1) No-ERROR.

    if not avail buf_cash-gds then do:
      create buf_cash-gds.
      error-status:error = false.
    end.
    buffer-copy cash-gds except crf b-code-tsd to buf_cash-gds
    assign
    buf_cash-gds.crf = cr + 1
    cr = cr + 1
    buf_cash-gds.b-code-tsd = IBM-good-code-2
    .
    assign
    buf_cash-gds.b-code-tsd = tsd-scl-format(buffer buf_cash-gds, v-scl-format)
    .
    assign
    buf_cash-gds.b-code-tsd = tsd-pg-format(buffer buf_cash-gds, v-pg-format)
    .

end.
assign
cash-gds.b-code-tsd = tsd-scl-format(buffer cash-gds, v-scl-format)
.


/*
if IBM-good-code <> Ibm-good-code-2
and ibm-good-code-2 <> "":U then do:*/

END PROCEDURE.
/* $Workfile$ e n d */