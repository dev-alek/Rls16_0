block-level on error undo, throw.
/*

$Revision: 245fc987699b, 3203, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:28 $
$Workfile: rpychk0.p $
$Archive: rep/rpychk0.p $

Проверка размазывания чеков по алгоритму 1 и строке запроса

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/28/08
Author: Bakhtadze Natalya
Creation date: 02/28/08

*/

define input parameter p-caller as character no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-date-start as date no-undo .
define input parameter p-date-end as date no-undo .
define input parameter p-shift-date-start as date no-undo .
define input parameter p-shift-date-end as date no-undo .
define input parameter p-shift-num-start as integer no-undo .
define input parameter p-shift-num-end as integer no-undo .
define input parameter p-inkas-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 245fc987699b, 3203, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rpychk0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/rpychk0.p $":U .
define variable vss-description as character no-undo init "Проверка размазывания чеков по алгоритму 1 и строке запроса".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rep/real3tm.i }
{ ref/gds-attr.i }
{ rep/r-pychk0.i defalgo    }
{ rep/r-pychk0.i def    }

define variable v-host-code as integer no-undo .
define variable v-base-code as integer no-undo .
define variable v-curr-r-b as character no-undo .

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }

{ gbl/curr-r-b.i
  v-curr-r-b
}

if v-curr-r-b = {&r-b-base} or
v-base-code = 0 then pychk_NO-exch = yes.
else pychk_No-exch = no.
if v-curr-r-b = {&r-b-rubl} or
v-base-code = 0 then pychk_NO-exch-rubl = yes.
else pychk_No-exch-rubl = no.

case p-caller:
  when "r-shftc2" then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        AND ub.chk-doc.obj-code = p-obj-code
        AND ub.chk-doc.shift-date >= p-shift-date-start
        AND ub.chk-doc.shift-date <= p-shift-date-end
        and ub.chk-doc.out-code <> ?,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY ub.CHK-pay.doc-code
      BY ub.CHK-pay.line-num:
      if ub.chk-doc.shift-date = p-shift-date-start  and ub.chk-doc.shift-num < p-shift-num-start  then next .
      if ub.chk-doc.shift-date = p-shift-date-end and ub.chk-doc.shift-num > p-shift-num-end then next .
      if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
      { rep/r-pychk0.i }
    end.
  end.
  when "r-shft3f" then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        AND ub.chk-doc.obj-code = p-obj-code
        AND ub.chk-doc.shift-date >= p-shift-date-start
        AND ub.chk-doc.shift-date <= p-shift-date-end,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY ub.CHK-pay.doc-code
      BY ub.CHK-pay.line-num:
      if ub.chk-doc.shift-date = p-shift-date-start  and ub.chk-doc.shift-num < p-shift-num-start  then next .
      if ub.chk-doc.shift-date = p-shift-date-end and ub.chk-doc.shift-num > p-shift-num-end then next .
      if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
      { rep/r-pychk0.i }
    end.
  end.
  when "r-date" then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        AND ub.chk-doc.obj-code = p-obj-code
        AND ub.chk-doc.chk-date >= p-shift-date-start
        AND ub.chk-doc.chk-date <= p-shift-date-end
        and ub.chk-doc.out-code <> ?,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
      BREAK
      BY ub.CHK-pay.doc-code
      BY ub.CHK-pay.line-num:
 
      if lookup(string(ub.chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.

      { rep/r-pychk0.i }
    end.
  end.  
  when "r-ptrsp2" then do:
    _chk-doc:
    for each ub.chk-doc no-lock where
             ub.chk-doc.obj-type    = p-obj-type
         and ub.chk-doc.obj-code    = p-obj-code
         and ub.chk-doc.shift-date  = p-shift-date-start
         and ub.chk-doc.shift-num   = p-shift-num-start
         and ub.chk-doc.out-code   <> ? ,
    EACH ub.chk-pay NO-LOCK WHERE
            ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY ub.CHK-pay.doc-code
    BY ub.CHK-pay.line-num:
      if lookup( string( ub.chk-doc.chk-type ), {&no-docum-receipt-codes} ) > 0
      then do:
        next _chk-doc .
      end.
      { rep/r-pychk0.i }
    end.
  end.
  when "r-pychk2"
  or
  when "bgepych2"
  or
  when "r-accor2"
  or
  when "r-pychk0"
  or
  when "salevza2"
  or
  when "exp-elc2"
  or
  when "r-trg29d"
  then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        and ub.chk-doc.obj-code = p-obj-code
        and ub.chk-doc.out-code = p-inkas-code,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY CHK-pay.DOC-CODE
    BY CHK-pay.LINE-NUM:
      if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
      if p-caller = "r-accor2" and
            not ( ub.chk-doc.chk-type = {&bef-rcpt-sale} or
                 ub.chk-doc.chk-type = {&bef-rcpt-return} ) then next _chk-doc.
      if p-caller = "exp-elc2" and ub.chk-doc.d-card = "":U then next _chk-doc.
      { rep/r-pychk0.i }
    end.
  end.
  when "r-autocu"
  then do:
    _chk-doc:
    FOR EACH ub.chk-doc No-LOCK WHERE
            ub.chk-doc.obj-type = p-obj-type
        and ub.chk-doc.obj-code = p-obj-code
        and ub.chk-doc.chk-date >= p-date-start
        and ub.chk-doc.chk-date <= p-date-end,
      EACH ub.chk-pay NO-LOCK WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY CHK-pay.DOC-CODE
    BY CHK-pay.LINE-NUM:
      if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
      if replace(replace(replace(replace(ub.chk-doc.office, {&gds-office}, ''), {&gds-goods}, ''), {&shift-err}, ''), {&comma-char}, '') <> '' then next _chk-doc.
      { rep/r-pychk0.i }
    end.
  end.

  /*сюда вставлять свои вызовы*/
  otherwise do:
    message
    substitute("&1&2&3Неверное значение p-caller=&4"
               ,vss-workfile
               ,vss-revision
               ,vss-description
               , p-caller)
    view-as alert-box error .
  end.
end case.

{ gbl/catcherr.i }
