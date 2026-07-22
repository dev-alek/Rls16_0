block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: libthpos.p $
$Archive: str/libthpos.p $

Библиотека работы c POS IBS TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/08
Author: Bakhtadze Natalya
Creation date: 07/14/08

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: libthpos.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/libthpos.p $":U .
define variable vss-description as character no-undo init "Библиотека работы c POS IBS TH".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/libthpos.i }
{ gbl/cur-time.i }
{ ref/chdcmask.i }
{ ref/chdcclim.i }
{ str/libthpos_def.i }
{ str/libbcrcn.i }
{ gbl/thbjattr.i }
{ str/name-2cd.i }
{ str/libchkvl.i }
{ str/mpl-auto.i }
{ gbl/printbuffer.i }
{ gbl/cd-attr.i }
{ gbl/key-rec.i }
{ ref/gdsoattr.i }
{ cmp/dr-flddf.i }
{ str/libthpos_bh-def.i }
{ gbl/print-xml.i }
{ gbl/lib-log.i }

&scop step-start 0
&scop step-gds 1
&scop step-subtotal 2
&scop step-pay 3


if valid-handle (g#libthpos)
and g#libthpos <> this-procedure :handle
and g#libthpos :get-signature('libthpos_clear-cda':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с POS IBS TH" skip
    g#libthpos skip
    g#libthpos :type skip
    g#libthpos :file-name skip
    valid-handle(g#libthpos) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#libthpos = this-procedure :handle
  .
end.

{ str/pos_context.i temp-table libthpos_context  }

{ str/pos_context.i dis-card-mask libthpos_ }
{ str/pos_context.i tt-wd libthpos_ }


{ str/pos_chk-context.i temp-table libthpos_chk-context  " " undo_libthpos_chk-context }

{ str/thpospay.i def libthpos_ }
{ str/thpospay.i proc libthpos_ }


define temp-table libthpos_cash-counter no-undo
field pay-code as integer
field curr-code as integer
field wth-code as integer
field par-code as integer
field par-val as integer
field tot-sum as decimal
field tot-rubl as decimal
field tot-base as decimal
field doc-qnty as decimal
field tot-lines as integer
field pre-tot-sum as decimal
field pre-tot-rubl as decimal
field pre-tot-base as decimal
field pre-doc-qnty as decimal
field pre-tot-lines as integer
field is-cash as logical
index pi is unique primary
pay-code curr-code wth-code par-code
.
define temp-table libthpos_rp-by-call no-undo
field profile_id as integer
field once-more as integer
field rph as handle
field call_id as character
index pi is unique primary
profile_id
once-more
.

define temp-table libthpos_flddf no-undo
field table-name_ as character
field name_ as character
field buffer_ as handle
field field-name_ as character
field fld-df as character
field buffer-field_ as handle
field table-no as integer
index pi is unique primary
fld-df
index itable table-name_
.
define temp-table libthpos_chk-doc no-undo like ub.chk-doc before-table undo_libthpos_chk-doc.
/*по строкам чека */
{ str/libthpos_chk-gds.i libthpos_chk-gds undo_libthpos_chk-gds }

/*по строкам оплат */
{ str/libthpos_chk-pay.i libthpos_chk-pay undo_libthpos_chk-pay }

      /*по скидкам */
{ str/libthpos_chk-discnt.i libthpos_chk-discnt undo_libthpos_chk-discnt }

define variable v-bh0 as handle no-undo extent 6 .
define variable v-bh as handle no-undo extent 6 .
define variable loc-print-copy-num as integer no-undo .
define variable loc-print-doc-code as character no-undo .

define dataset libthpos_receipt  for
libthpos_chk-context,
libthpos_chk-doc,
libthpos_chk-gds,
libthpos_chk-pay,
libthpos_chk-discnt
data-relation line-doc for libthpos_chk-doc, libthpos_chk-context relation-fields (doc-code, doc-code)
data-relation line-gds for libthpos_chk-doc, libthpos_chk-gds relation-fields (doc-code, doc-code) nested
data-relation line-pay for libthpos_chk-doc, libthpos_chk-pay relation-fields (doc-code, doc-code) nested
data-relation line-discnt for libthpos_chk-doc, libthpos_chk-discnt relation-fields (doc-code, doc-code) nested
.

define dataset libthpos_context  for
libthpos_context,
libthpos_cash-counter,
libthpos_dis-card-mask
.



/*
define query libthpos_qreceipt for ub.chk-doc.


define data-source libthpos_dsrcchk-doc for  query libthpos_qreceipt.
define data-source libthpos_dsrcchk-gds for  ub.chk-gds keys ( doc-code).
define data-source libthpos_dsrcchk-pay for  ub.chk-pay keys ( doc-code).
define data-source libthpos_dsrcchk-discnt for ub.chk-discnt keys ( doc-code).
*/

define buffer locked_chk-doc for ub.chk-doc.



on delete of this-procedure do:
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.

  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                  , input no).
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                  , input no).
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                  , input no).
  run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                  , input no).

  for each libthpos_cash-desk-attr:
    delete libthpos_cash-desk-attr.
  end.
  for each libthpos_context:
    delete libthpos_context.
  end.
  for each libthpos_chk-context:
    delete libthpos_chk-context.
  end.
  for each libthpos_dis-card-mask:
    delete libthpos_dis-card-mask.
  end.
  dataset libthpos_params:empty-dataset().
  dataset libthpos_receipt:empty-dataset().
  for each buf_libthpos_rp-by-call:
    if  valid-handle(buf_libthpos_rp-by-call.rph) then do:
      delete procedure(buf_libthpos_rp-by-call.rph).
    end.
    delete buf_libthpos_rp-by-call.
  end.

  assign
    g#libthpos = ?
  .
end.


procedure libthpos_clear-cda:
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
  do
  on error undo, return error return-value
  :
    for each buf_libthpos_cash-desk-attr
    on error undo, return error :
      delete buf_libthpos_cash-desk-attr.
    end.
  end.

end procedure. /* libthpos_clear-cda */


function libthpos_rmethod returns decimal ( input p-rmethod-type as character
                                            ,input p-rmethod-coeff as decimal
                                            ,input p-sum as decimal ):
define variable  mround-sum as decimal no-undo.
case p-rmethod-type:
  when "MROUND" then do:
    if p-rmethod-coeff > 0 then do:
      mround-sum = truncate(p-sum, integer(p-rmethod-coeff)).
    end.
    else do:
      mround-sum = truncate(p-sum / exp(10, abs(p-rmethod-coeff)), 0) * EXP(10, abs(p-rmethod-coeff)).
    end.
  end.
  when "NO-COINS" then do:
    mround-sum = truncate( p-sum / p-rmethod-coeff, 0) * p-rmethod-coeff.
  end.
end case.
return mround-sum.
end function.


procedure libthpos_clear-context:
define buffer buf_libthpos_context for libthpos_context.
define buffer buf_libthpos_dis-card-mask for libthpos_dis-card-mask.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_libthpos_flddf for libthpos_flddf.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
  do
  on error undo, return error return-value
  :
    for each buf_libthpos_flddf
    on error undo, return error :
      delete buf_libthpos_flddf.
    end.
    for each buf_libthpos_context
    on error undo, return error :
      delete buf_libthpos_context.
    end.
    for each buf_libthpos_dis-card-mask
    on error undo, return error :
      delete buf_libthpos_dis-card-mask.
    end.
    for each buf_libthpos_cash-counter:
      delete buf_libthpos_cash-counter.
    end.
    for each buf_libthpos_rp-by-call:
      if  valid-handle(buf_libthpos_rp-by-call.rph) then do:
        delete procedure(buf_libthpos_rp-by-call.rph).
      end.
      delete buf_libthpos_rp-by-call.
    end.

  end.

end procedure. /* libthpos_clear-context */



procedure libthpos_fill-cda:
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
do
on error undo, return error return-value
:

define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_cash-desk-attr for ub.cash-desk-attr.
  do
  on error undo, return error return-value
  :

    run libthpos_clear-cda in this-procedure.
    for each buf_cash-desk-attr no-lock where
             buf_cash-desk-attr.db-num = p-db-num
         and buf_cash-desk-attr.obj-code = p-obj-code
         and buf_cash-desk-attr.pos-type = p-pos-type
         and buf_cash-desk-attr.cash-num = p-cash-num
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      create buf_libthpos_cash-desk-attr.
      buffer-copy buf_cash-desk-attr to buf_libthpos_cash-desk-attr.
    end.
  end.
end.
end procedure. /* libthpos_fill-cda */


procedure libthpos_get-cda :
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-upper-attr-code as character no-undo .
define input parameter p-attr-code as character no-undo .
define output parameter p-attr-value-character as character no-undo .
define output parameter p-attr-value-date as date no-undo .
define output parameter p-attr-value-decimal as decimal no-undo .
define output parameter p-attr-value-integer as integer no-undo .
define output parameter p-attr-value-logical as logical no-undo .
define output parameter p-attr-value-type as character no-undo .

define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if not (libthpos_context.db-num = p-db-num
          or
          libthpos_context.obj-code = p-obj-code
          or
          libthpos_context.pos-type = p-pos-type
          or
          libthpos_context.cash-num = p-cash-num) then do:
    undo main-block, return error substitute("Неверный контекст").
  end.

  find first buf_libthpos_cash-desk-attr where
            buf_libthpos_cash-desk-attr.upper-attr-code = p-upper-attr-code
        and buf_libthpos_cash-desk-attr.attr-code = p-attr-code
        and buf_libthpos_cash-desk-attr.db-num = libthpos_context.db-num
        and buf_libthpos_cash-desk-attr.obj-code = libthpos_context.obj-code
        and buf_libthpos_cash-desk-attr.pos-type = libthpos_context.pos-type
        and buf_libthpos_cash-desk-attr.cash-num = libthpos_context.cash-num no-error .
  if not available buf_libthpos_cash-desk-attr then do:
    undo  main-block, return error substitute("Не найден параметр кассы &1 (секция &2)", p-attr-code, p-upper-attr-code).
  end.
  assign
  p-attr-value-character = buf_libthpos_cash-desk-attr.attr-value-character
  p-attr-value-date = buf_libthpos_cash-desk-attr.attr-value-date
  p-attr-value-decimal = buf_libthpos_cash-desk-attr.attr-value-decimal
  p-attr-value-integer = buf_libthpos_cash-desk-attr.attr-value-integer
  p-attr-value-logical = buf_libthpos_cash-desk-attr.attr-value-logical
  p-attr-value-type = buf_libthpos_cash-desk-attr.attr-value-type
  .
end.

end procedure. /* libthpos_get-cda */


procedure libthpos_get-all-cda :
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define output parameter dataset FOR libthpos_params .


define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if not (libthpos_context.db-num = p-db-num
          or
          libthpos_context.obj-code = p-obj-code
          or
          libthpos_context.pos-type = p-pos-type
          or
          libthpos_context.cash-num = p-cash-num) then do:
    undo main-block, return error substitute("Неверный контекст").
  end.
end.

end procedure. /* libthpos_get-all-cda */


procedure libthpos_create-context :
define input parameter p-parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-db-num   as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define output parameter p-serial-code as character no-undo .
define output parameter p-r-b as character no-undo .
define output parameter p-base-code as integer no-undo .
define variable v-type as character no-undo .
define variable v-tth as handle no-undo .

define variable v-process-sale as logical no-undo .
define variable v-nam-artc as logical no-undo .
define variable v-cod-pcod as logical no-undo .
define variable v-nam-2str as logical no-undo .
define variable v-name-2cd as character no-undo .
define variable v-how-temp-disc as character no-undo .
define variable v-nalc as integer no-undo .
define variable v-rmethod-type as character no-undo .
define variable v-rmethod-coeff as decimal no-undo .
define variable v-cash-counter as decimal no-undo .
define variable v-manual-discnt as integer no-undo .
define variable v-salesman-mandatory as integer no-undo .
define variable v-log-level as integer   no-undo .
define variable v-qnty-change as logical   no-undo .
define variable v-pos-type-for-discnt as character no-undo .

define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as integer no-undo .
define variable v-value-logical as logical no-undo .
define variable v-param-type as character no-undo .
define variable v-call-id as character no-undo .
define variable v-prop-code as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_cash-desk for ub.cash-desk.
define buffer buf_libthpos_context for libthpos_context.
define buffer buf_dis-card-mask for ub.dis-card-mask.
define buffer buf_libthpos_dis-card-mask for libthpos_dis-card-mask.
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_thbj-attr for ub.thbj-attr.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define buffer buf_cash-pay for ub.cash-pay.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  if p-pos-type <> {&cd-type-ibs-th}
  and p-pos-type <> {&cd-type-ibs-th-mob}
  then do:
    undo main-block, return error substitute("Неверный тип POS = &1", p-pos-type).
  end.
  find first buf_cash-desk no-lock where
          buf_cash-desk.db-num = p-db-num
      and buf_cash-desk.obj-code = p-obj-code
      and buf_cash-desk.pos-type = p-pos-type
      and buf_cash-desk.cash-num = p-cash-num no-error.
  if not available buf_cash-desk then do:
    undo main-block, return error substitute("Нет POS &1 №&2 на маг&3 БД &4"
                                  , p-pos-type
                                  , p-cash-num
                                  , p-obj-code
                                  , p-db-num
                                  ).
  end.
  if buf_cash-desk.cash-on = no then do:
    undo main-block, return error substitute("POS &1 №&2 на маг&3 БД &4 ВЫКЛЮЧЕН"
                                  , p-pos-type
                                  , p-cash-num
                                  , p-obj-code
                                  , p-db-num
                                  ).
  end.
  for each libthpos_chk-context:
    delete libthpos_chk-context.
  end.
  run libthpos_clear-context in this-procedure .

   run libthpos_create-flddf in this-procedure no-error .
   if error-status:error then do:
     undo, return error substitute("&1&2&3", error-status:get-message(1) , {&new-line}, return-value ).
   end.
  { str/libchkvl_create-context.i
   {&shop}
   p-obj-code
   "buffer buf_libthpos_context:handle"
   no-error
   }
  if error-status:error then do:
    undo, return error substitute("Ошибка при создании контекста&1&2&1&3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  find first buf_libthpos_context.
  for each buf_libthpos_dis-card-mask:
    delete buf_libthpos_dis-card-mask.
  end.
  _maska:
  for each buf_dis-card-mask no-lock where
      buf_Dis-card-mask.stts              = integer({&current-status-int})
  by buf_Dis-card-mask.host-code
  by buf_Dis-card-mask.obj-type
  by buf_Dis-card-mask.obj-code
  by buf_Dis-card-mask.rank
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  :
    if buf_dis-card-mask.host-code <> 0
    And buf_dis-card-mask.host-code <> buf_libthpos_context.host-code then next _maska.
    if (buf_dis-card-mask.obj-type <> "":U
    AND buf_dis-card-mask.obj-type <> {&shop})
    or (buf_dis-card-mask.obj-code <> 0
    and buf_dis-card-mask.obj-code <> p-obj-code)
    then NEXT _maska.
    if buf_dis-card-mask.use-on = integer({&dcm-only-th}) then NEXT _Maska.
    create buf_libthpos_dis-card-mask.
    buffer-copy buf_dis-card-mask to
    buf_libthpos_dis-card-mask.
  end. /*for each _maska*/
  run libthpos_fill-cda in this-procedure (
                                              input p-db-num
                                              ,input p-obj-code
                                              ,input p-pos-type
                                              ,input p-cash-num ) no-error.
  if error-status:error then do:
    undo main-block, return error substitute("Ошибка при поиске заполнении массива значений параметров кассы&1:&2&1&3"
                                   , {&new-line}
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  assign
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  p-obj-code
      ,input  {&attr-cd-inf-send}
      ,input  '':U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then return error .
  for each thbjattr_thbj-attr where
          thbjattr_thbj-attr.obj-type = {&shop}
      and thbjattr_thbj-attr.obj-code = buf_libthpos_context.obj-code
      and thbjattr_thbj-attr.upper-prop-code = {&attr-cd-inf-send}
  on error undo, return error :
    case thbjattr_thbj-attr.prop-code:
      when {&attr-cd-inf-send_nam-artc} then do:
        v-nam-artc = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-cd-inf-send_cod-pcod} then do:
        v-cod-pcod = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-cd-inf-send_nam-2str} then do:
        v-nam-2str = thbjattr_thbj-attr.property-value-logical.
      end.
      when {&attr-cd-inf-send_name-2cd} then do:
        v-name-2cd = thbjattr_thbj-attr.property-value-character.
      end.
      when {&attr-cd-inf-send_how-temp-disc} then do:
        v-how-temp-disc = thbjattr_thbj-attr.property-value-character.
      end.
    end case.
  end.
  v-tth = buffer thbjattr_thbj-attr:table-handle .
  run adm/shattri.p (
      input "get":U
      ,input  {&shop}
      ,input  p-obj-code
      ,input  {&attr-cd-sending}
      ,input  {&attr-cd-sending_process-sale} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-process-sale
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  if error-status:error then return error .

  if p-pos-type = {&cd-type-ibs-th} then do:
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_fisreg}
          and buf_libthpos_cash-desk-attr.attr-code = {&cda-ibs-th_fisreg_cash-pay-list} no-error.
      .
    run libthpos_get-cash-pay-list in this-procedure (
                                                      input  (if available buf_libthpos_cash-desk-attr
                                                      then buf_libthpos_cash-desk-attr.attr-value-character
                                                      else '') ) no-error .
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_fisreg}
          and buf_libthpos_cash-desk-attr.attr-code = {&cda-ibs-th_fisreg_pay-names} no-error.

    run libthpos_get-pay-names in this-procedure ( input  (if available buf_libthpos_cash-desk-attr
                                                    then buf_libthpos_cash-desk-attr.attr-value-character
                                                    else '') ) no-error .
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_main}
          and buf_libthpos_cash-desk-attr.attr-code = {&cda-IBS-TH_main_nalc} no-error.
      .
    assign
    v-nalc = (if available buf_libthpos_cash-desk-attr
              then buf_libthpos_cash-desk-attr.attr-value-integer
              else 0)
    .
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_main}
          and buf_libthpos_cash-desk-attr.attr-code = {&cda-IBS-TH_rec-print_rmethod-type} no-error.
      .
    assign
    v-rmethod-type = (if available buf_libthpos_cash-desk-attr
                      then buf_libthpos_cash-desk-attr.attr-value-character
                      else "MROUND")
    v-rmethod-coeff = (if not available buf_libthpos_cash-desk-attr
                      then 2.0
                      else v-rmethod-coeff)
    .
    if available buf_libthpos_cash-desk-attr then do:
      find first buf_libthpos_cash-desk-attr no-lock where
                buf_libthpos_cash-desk-attr.db-num = p-db-num
            and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
            and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
            and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
            and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_main}
            and buf_libthpos_cash-desk-attr.attr-code = {&cda-IBS-TH_rec-print_rmethod-coeff} no-error.
      assign
      v-rmethod-coeff = (if available buf_libthpos_cash-desk-attr
                        then buf_libthpos_cash-desk-attr.attr-value-decimal
                        else (if v-rmethod-type = "MROUND"
                              then 2.0
                              else 0.0
                              )
                        )
      .
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    for each buf_inkas-pay-wth no-lock where
            buf_inkas-pay-wth.obj-code = p-obj-code
        and buf_inkas-pay-wth.obj-code = p-obj-code
        and buf_inkas-pay-wth.pay-desk = p-cash-num
        and buf_inkas-pay-wth.inkas-code = ''
        and buf_inkas-pay-wth.chk-type = 0
        and buf_inkas-pay-wth.cashier = 0
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_inkas-pay-wth.pay-code = 0
      and buf_inkas-pay-wth.curr-code = 0 then next.
      /*это запись ВСЕГО*/
      create buf_libthpos_cash-counter.
      buffer-copy buf_inkas-pay-wth to buf_libthpos_cash-counter
      .
      find first buf_cash-pay no-lock where
              buf_cash-pay.cdpay-code = buf_inkas-pay-wth.pay-code
          and buf_cash-pay.curr-code = buf_inkas-pay-wth.curr-code .
      if buf_cash-pay.is-cash then do:
        assign
        v-cash-counter = v-cash-counter + ( if buf_libthpos_context.r-b = {&r-b-rubl}
                          then buf_inkas-pay-wth.tot-rubl
                          else buf_inkas-pay-wth.tot-base)
        buf_libthpos_cash-counter.is-cash = yes
        .
      end.
    end.
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_main}
          and buf_libthpos_cash-desk-attr.attr-code = {&cda-IBS-TH_main_manual-discnt} no-error.
      .
    assign
    v-manual-discnt = (if available buf_libthpos_cash-desk-attr
              then buf_libthpos_cash-desk-attr.attr-value-integer
              else 0)
    .
    v-pos-type-for-discnt = {&cd-type-ibs-th}.
  end.
  find first buf_libthpos_cash-desk-attr no-lock where
            buf_libthpos_cash-desk-attr.db-num = p-db-num
        and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
        and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
        and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
        and buf_libthpos_cash-desk-attr.upper-attr-code = (if p-pos-type = {&cd-type-ibs-th}
                                                           then {&cda-IBS-TH_main}
                                                           else {&cda-IBS-TH-MOB_main})
        and buf_libthpos_cash-desk-attr.attr-code = (if p-pos-type = {&cd-type-ibs-th}
                                                    then {&cda-IBS-TH_main_salesman-mandatory}
                                                    else {&cda-IBS-TH-MOB_main_salesman-mandatory})  no-error.
     .
  assign
  v-salesman-mandatory = (if available buf_libthpos_cash-desk-attr
            then buf_libthpos_cash-desk-attr.attr-value-integer
            else 0)
  .
  if p-pos-type = {&cd-type-ibs-th-mob} then do:
    find first buf_libthpos_cash-desk-attr no-lock where
              buf_libthpos_cash-desk-attr.db-num = p-db-num
          and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
          and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
          and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
          and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH-MOB_main}
          and buf_libthpos_cash-desk-attr.attr-code = {&cda-IBS-TH-MOB_main_pos-type-for-discnt}  no-error.
    assign
    v-pos-type-for-discnt = (if available buf_libthpos_cash-desk-attr
              then buf_libthpos_cash-desk-attr.attr-value-character
              else {&cd-type-ibs-th-mob})
    .
  end.
  find first buf_libthpos_cash-desk-attr no-lock where
            buf_libthpos_cash-desk-attr.db-num = p-db-num
        and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
        and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
        and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
        and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_main}
        and buf_libthpos_cash-desk-attr.attr-code = {&cda-ibs-th_main_log-level} no-error.
   assign
   v-log-level = (if available buf_libthpos_cash-desk-attr
                 then buf_libthpos_cash-desk-attr.attr-value-integer
                 else 0).
  find first buf_libthpos_cash-desk-attr no-lock where
            buf_libthpos_cash-desk-attr.db-num = p-db-num
        and buf_libthpos_cash-desk-attr.obj-code = p-obj-code
        and buf_libthpos_cash-desk-attr.pos-type = p-pos-type
        and buf_libthpos_cash-desk-attr.cash-num = p-cash-num
        and buf_libthpos_cash-desk-attr.upper-attr-code = {&cda-IBS-TH_main}
        and buf_libthpos_cash-desk-attr.attr-code = {&cda-ibs-th_main_qnty-change} no-error.
   assign
   v-qnty-change = (if available buf_libthpos_cash-desk-attr
                 then logical(buf_libthpos_cash-desk-attr.attr-value-integer)
                 else no).


  /*найдем call_id*/
  if p-pos-type = {&cd-type-ibs-th} then do:
    assign
    v-prop-code = {&attr-rum_chk-doc_ibs-th}
    .
  end.
  if p-pos-type = {&cd-type-ibs-th-mob} then do:
    assign
    v-prop-code = {&attr-rum_chk-doc_ibs-th-mob}
    .
  end.

  find first buf_thbj-attr share-lock where
            buf_thbj-attr.obj-type = {&shop}
        and buf_thbj-attr.obj-code = p-obj-code
        and buf_thbj-attr.upper-prop-code = {&attr-rum_obj}
        and buf_thbj-attr.prop-code = v-prop-code
        and buf_thbj-attr.property-value-logical = yes
        no-error.
  if not available buf_thbj-attr then do:
    find first buf_thbj-attr share-lock where
              buf_thbj-attr.obj-type = ''
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.upper-prop-code = {&attr-rum}
          and buf_thbj-attr.prop-code = v-prop-code
          /*здесь не надо проверять  and buf_thbj-attr.property-value-logical = yes он и так главный*/
          no-error.
  end.
  if available buf_thbj-attr then do:
    run gen-key-rec in this-procedure (
                                          input  {&table_thbj-attr}
                                         ,input (buffer buf_thbj-attr:handle)
                                         ,output v-call-id) .
    for each buf_rp-by-call no-lock where
            buf_rp-by-call.call_id = v-call-id
    break
    by buf_rp-by-call.profile_id
    by buf_rp-by-call.once-more
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

      create buf_libthpos_rp-by-call.
      assign
      buf_libthpos_rp-by-call.profile_id = buf_rp-by-call.profile_id
      buf_libthpos_rp-by-call.once-more = buf_rp-by-call.once-more
      buf_libthpos_rp-by-call.call_id = buf_rp-by-call.call_id
      v-bh[{&context}] = (buffer buf_libthpos_context:handle)
      .
      run value( substitute("rul/rp-&1.p"
                            , buf_libthpos_rp-by-call.profile_id))
            persistent set buf_libthpos_rp-by-call.rph
                (
                  input p-parparentproc
                  ,input this-procedure:handle
                  ,input p-log-handle /*p-log-handle */
                  ,input ? /*p-cont-handle */
                  ,input v-call-id
                  ,input buf_libthpos_rp-by-call.profile_id
                  ,input buf_libthpos_rp-by-call.once-more
                  ,input buf_libthpos_context.host-code
                  ,input buf_libthpos_context.obj-type
                  ,input buf_libthpos_context.obj-code
                  ,input p-pos-type
                  ,input v-pos-type-for-discnt
                  ,input buf_libthpos_context.p-log-file-name
                  ,input (buffer libthpos_flddf:handle)
                  ,input v-bh
                ) no-error
                .
      if error-status :error then do:
        run libthpos_clear-context in this-procedure no-error.
        undo main-block, return error substitute("Ошибка при загрузке процедуры расчета скидок/бонусов для профайла &1", buf_rp-by-call.profile_id).
      end.
    end.
  end. /*if available buf_thbj-attr then do:*/
  assign
  buf_libthpos_context.parparentproc = p-parparentproc
  buf_libthpos_context.p-log-handle = p-log-handle
  buf_libthpos_context.tt-wd-bh = (buffer libthpos_chk-discnt:handle)
  buf_libthpos_context.process-sale = v-process-sale
  buf_libthpos_context.pos-type = p-pos-type
  buf_libthpos_context.cash-num = p-cash-num
  buf_libthpos_context.nalc = v-nalc
  buf_libthpos_context.rmethod-type = v-rmethod-type
  buf_libthpos_context.rmethod-coeff = v-rmethod-coeff
  buf_libthpos_context.nam-artc   = v-nam-artc
  buf_libthpos_context.nam-2str   = v-nam-2str
  buf_libthpos_context.cod-pcod   = v-cod-pcod
  buf_libthpos_context.name-2cd   = v-name-2cd
  buf_libthpos_context.cash-counter = v-cash-counter
  buf_libthpos_context.salesman-mandatory = v-salesman-mandatory
  buf_libthpos_context.manual-discnt = v-manual-discnt
  buf_libthpos_context.log-level = v-log-level
  buf_libthpos_context.qnty-change = v-qnty-change
  buf_libthpos_context.pos-type-for-discnt = v-pos-type-for-discnt
  buf_libthpos_context.chk-discnt-table = (buffer libthpos_chk-discnt:handle:table-handle)
  buf_libthpos_context.chk-gds-table = (buffer libthpos_chk-gds:handle:table-handle)
  buf_libthpos_context.chk-pay-table = (buffer libthpos_chk-pay:handle:table-handle)
  p-r-b = buf_libthpos_context.r-b
  p-base-code = buf_libthpos_context.base-code
  buf_libthpos_context.serial-code = buf_cash-desk.serial-code
  p-serial-code = buf_cash-desk.serial-code
  .
end. /*doe*/
end procedure. /*libthpos_create-context :*/


procedure libthpos_get-context-property :
define input parameter p-what-context as integer no-undo .
define input parameter p-property as character no-undo .
define output parameter p-character as character no-undo .
define output parameter p-date as date no-undo .
define output parameter p-decimal as decimal no-undo .
define output parameter p-integer as integer no-undo .
define output parameter p-logical as logical no-undo .
define output parameter p-handle as handle no-undo .
define output parameter p-data-type as character no-undo .
define output parameter p-setted as logical no-undo .

define variable v-fh as handle no-undo .

main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if p-what-context = {&chk-context} then do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      undo main-block, return error substitute("Не выставлен контекст чека").
    end.
  end.
  case p-what-context:
    when {&context} then do:
      assign
      v-fh = buffer libthpos_context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста работы =&1", p-property).
      end.
    end.
    when {&chk-context} then do:
      assign
      v-fh = buffer libthpos_chk-context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста чека =&1", p-property).
      end.

    end.
  end case.
  assign
  p-data-type = v-fh:data-type.
  case p-data-type:
    when {&abl-datatype-character} then do:
      assign
      p-character = v-fh:buffer-value
      .
    end.
    when {&abl-datatype-date} then do:
      assign
      p-date = v-fh:buffer-value
      .
    end.
    when {&abl-datatype-decimal} then do:
      assign
      p-decimal = v-fh:buffer-value
      .
    end.
    when {&abl-datatype-integer} then do:
      assign
      p-integer = v-fh:buffer-value
      .
    end.
    when {&abl-datatype-logical} then do:
      assign
      p-logical = v-fh:buffer-value
      .
    end.
    when {&abl-datatype-handle} then do:
      assign
      p-handle = v-fh:buffer-value
      .
    end.
    otherwise do:
      undo main-block, return error substitute("Неверный или неизвестный тип данных для свойства &1 = &2"
                                               , v-fh:data-type
                                               , p-property).
    end.
  end case.
  p-setted = yes.
end.
end procedure.

procedure libthpos_set-context-property :
define input parameter p-what-context as integer no-undo .
define input parameter p-property as character no-undo .
define input parameter p-character as character no-undo .
define input parameter p-date as date no-undo .
define input parameter p-decimal as decimal no-undo .
define input parameter p-integer as integer no-undo .
define input parameter p-logical as logical no-undo .
define input parameter p-handle as handle no-undo .
define output parameter p-setted as logical no-undo .

define variable v-fh as handle no-undo .
define variable v-data-type as character no-undo .

main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if p-what-context = {&chk-context} then do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      undo main-block, return error substitute("Не выставлен контекст чека").
    end.
  end.
  case p-what-context:
    when {&context} then do:
      assign
      v-fh = buffer libthpos_context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста работы =&1", p-property).
      end.
      if lookup(p-property, "p-log-handle,p-log-file-name,z-number,emulator-mode") = 0 then do:
         undo main-block , return error substitute("Запрошенное свойство контекста работы =&1 является READ-ONLY", p-property).
      end.
    end.
    when {&chk-context} then do:
      assign
      v-fh = buffer libthpos_chk-context:buffer-field(p-property) no-error.
      if error-status:error then do:
        undo main-block , return error substitute("Неверное запрошенное свойство контекста чека =&1", p-property).
      end.
      if lookup(p-property, "xxx") = 0 then do:
        undo main-block , return error substitute("Запрошенное свойство контекста чека =&1 является READ-ONLY", p-property).
      end.
    end.
  end case.
  assign
  v-data-type = v-fh:data-type.
  case v-data-type:
    when {&abl-datatype-character} then do:
      assign
      v-fh:buffer-value = p-character
      .
    end.
    when {&abl-datatype-date} then do:
      assign
      v-fh:buffer-value = p-date
      .
    end.
    when {&abl-datatype-decimal} then do:
      assign
      v-fh:buffer-value = p-decimal
      .
    end.
    when {&abl-datatype-integer} then do:
      assign
      v-fh:buffer-value = p-integer
      .
    end.
    when {&abl-datatype-logical} then do:
      assign
      v-fh:buffer-value =  p-logical
      .
    end.
    when {&abl-datatype-handle} then do:
      assign
      v-fh:buffer-value = p-handle
      .
    end.
    otherwise do:
      undo main-block, return error substitute("Неверный или неизвестный тип данных для свойства &1 = &2"
                                               , v-fh:data-type
                                               , p-property).
    end.
  end case.
  p-setted = yes.
end.
end procedure.


procedure libthpos_set-log :
define input parameter p-log-handle as handle no-undo .
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  find first libthpos_context no-error.
  if not available libthpos_context then do:
    undo main-block, return error substitute("Не выставлен контекст работы").
  end.
  if not valid-handle(p-log-handle) then do:
    undo main-block, return error substitute("Неверный указатель на процедуру логирования").
  end.
  for each buf_libthpos_rp-by-call
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run rp-chk-doc_set-log in buf_libthpos_rp-by-call.rph no-error.
  end.
  assign
  libthpos_context.p-log-handle = p-log-handle
  .
end. /*doe*/
end procedure. /* libthpos_set-log */

procedure libthpos_create-chk-doc :
define input parameter p-db-num   as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-chk-type as integer no-undo .
define input parameter p-cashier  as integer no-undo .
define input parameter p-cashier-psn-code as integer no-undo .
define output parameter p-doc-code as character no-undo .
define output parameter p-bank-rate as decimal no-undo .
define output parameter p-bank-scale as decimal no-undo .
define output parameter p-cash-rate as decimal no-undo .
define output parameter p-cash-scale as integer no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-base-rate as decimal no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-cash-scale as integer no-undo .
define variable v-sale-in-out as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_staff for ub.staff.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_chk-doc for ub.chk-doc.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if (lookup(string(p-chk-type), {&receipt-codes}) = 0 and lookup(string(p-chk-type), {&ord-receipt-codes}) = 0)
    or lookup(string(p-chk-type), {&petrol-receipt-codes}) > 0
    or lookup(string(p-chk-type), {&pre-receipt-codes}) > 0
    or lookup(string(p-chk-type), {&rcpt-annu}) > 0
    then do:
      v-err-mess = substitute("Неверный тип чека = &1", p-chk-type).
      undo main-block, retry main-block .
    end.
    if lookup(string(p-chk-type), {&ord-receipt-codes}) = 0
    and p-pos-type = {&cd-type-ibs-th-mob} then do:
      v-err-mess = substitute("Неверный тип чека = &1 для кассы типа &2", p-chk-type, p-pos-type).
      undo main-block, retry main-block .
    end.
    if lookup(string(p-chk-type), {&ord-receipt-codes}) > 0
    and p-pos-type <> {&cd-type-ibs-th-mob} then do:
      v-err-mess = substitute("Неверный тип чека = &1 для кассы типа &2", p-chk-type, p-pos-type).
      undo main-block, retry main-block .
    end.
    find first libthpos_context no-error.
    if not available libthpos_context then do:
      v-err-mess = substitute("Не выставлен контекст работы").
      undo main-block, retry main-block .
    end.
    if libthpos_context.pos-type = {&cd-type-ibs-th}
    and lookup(string(p-chk-type), {&ord-receipt-codes}) = 0
    and (libthpos_context.z-number <= 0
    or libthpos_context.z-number = ?)
    and libthpos_context.emulator-mode = 0
    then do:
      v-err-mess = substitute("Не выставлен № z-отчета").
      undo main-block, retry main-block .
    end.
    if not (libthpos_context.db-num = p-db-num
            and
            libthpos_context.obj-code = p-obj-code
            and
            libthpos_context.pos-type = p-pos-type
            and
            libthpos_context.cash-num = p-cash-num) then do:
      v-err-mess = substitute("Неверный контекст").
      undo main-block, retry main-block .
    end.
    if not is-cdinv and p-chk-type = integer({&rcpt-inventory}) then do:
      v-err-mess = substitute("В данной конфигурации запрещено делать инвентаризацию на кассах").
      undo main-block, retry main-block .
    end.
    if not is-ptrl and lookup(string(p-chk-type), {&petrol-receipt-codes}) > 0
    then do:
      v-err-mess = substitute("В данной конфигурации запрещено делать специфические чеки топлива").
      undo main-block, retry main-block .
    end .
    /*очистим dataset*/
    if buffer libthpos_chk-context:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    if buffer libthpos_chk-pay:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    if buffer libthpos_chk-gds:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    if buffer libthpos_chk-discnt:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).

    dataset libthpos_receipt:empty-dataset().
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input yes).


    run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_staff no-lock where
              buf_staff.role = {&role-cashier}
        and buf_staff.role-level = {&role-level-db}
        and buf_staff.db-num = p-db-num
        and buf_staff.staff-code = p-cashier
        and buf_staff.date-start <= v-today
        and buf_staff.date-end >= v-today
        and buf_staff.psn-code = p-cashier-psn-code no-error.
    if not available buf_staff then do:
      v-err-mess =  substitute("На текущий момент нет кассира с кодом &1 БД &2 и кодом физ.лица &3"
                                  , p-cashier
                                  , p-db-num
                                  , p-cashier-psn-code
                                  ).
      undo main-block, retry main-block.
    end.
    assign
    v-base-rate = 1
    v-cash-rate = 1
    v-cash-scale = 1
    v-bank-rate = 1
    v-bank-scale = 1
    .
    /*найдем курс валюты*/
    if libthpos_context.r-b = {&r-b-base}
    and libthpos_context.base-code <> 0 then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = {&shop}
                AND buf_curr-shop.obj-code = p-obj-code
                AND buf_curr-shop.curr-code = libthpos_context.base-code
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-cash-rate = buf_curr-shop.exch-rate
        v-cash-scale = buf_curr-shop.exch-scale
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess =  substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , {&shop}
                                      , p-obj-code
                                      , v-today
                                    ).

        undo main-block, retry main-block.
      end.
      { gbl/exchrate.i libthpos_context.base-code v-today v-bank-rate v-bank-scale v-bank-abbr }
    end.
    if libthpos_context.r-b = {&r-b-rubl}
    and libthpos_context.base-code <> 0 then do:
      FIND LAST buf_curr-shop NO-LOCK WHERE
                buf_curr-shop.obj-type = {&shop}
            AND buf_curr-shop.obj-code = p-obj-code
            AND buf_curr-shop.curr-code = libthpos_context.base-code
            AND ( ( buf_curr-shop.exch-date = v-today
                    AND
                    buf_curr-shop.exch-time <= v-time ) OR
                    buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess =  substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , {&shop}
                                      , p-obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
      { gbl/exchrate.i libthpos_context.base-code v-today v-bank-rate v-bank-scale v-bank-abbr }
    end.
    if lookup(string(p-chk-type), {&sale-in-receipt-codes}) > 0
    or  lookup(string(p-chk-type), {&sale-out-receipt-codes}) > 0 then do:
      assign
      v-sale-in-out = yes
      .
    end.
    create buf_chk-doc.
    create libthpos_chk-context.
    assign
    buf_chk-doc.obj-type = {&shop}
    buf_chk-doc.obj-code = p-obj-code
    buf_chk-doc.office = ?
    buf_chk-doc.doc-code = (if p-db-num = 0
                            then string(next-value(s-chk, {&db-name_schema} ))
                            else string( p-obj-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
    loc-print-doc-code = buf_chk-doc.doc-code
    buf_chk-doc.chk-id = buf_chk-doc.doc-code
    buf_chk-doc.chk-date = v-today
    buf_chk-doc.chk-time = v-time
    buf_chk-doc.pay-desk = p-cash-num
    buf_chk-doc.cashier  = p-cashier
    buf_chk-doc.cashier-psn-code  = p-cashier-psn-code
    buf_chk-doc.src-d-card =  ''
    buf_chk-doc.d-card =  ''
    buf_chk-doc.src-d-pcnt =  0
    buf_chk-doc.src-cli-type = ?
    buf_chk-doc.src-cli-code = 0
    buf_chk-doc.src-shift-date = v-today /*пока*/
    buf_chk-doc.src-shift-name = ''
    buf_chk-doc.shift-name = ''
    buf_chk-doc.shift-num = 0
    buf_chk-doc.cash-rate = v-cash-rate
    buf_chk-doc.cash-scale = v-cash-scale
    buf_chk-doc.base-rate = v-base-rate
    buf_chk-doc.z-number = libthpos_context.z-number
    buf_chk-doc.chk-type = p-chk-type
    buf_chk-doc.correct = yes
    buf_chk-doc.discnt = 0
    buf_chk-doc.sales-man = libthpos_context.sales-man
    buf_chk-doc.salesman-psn-code = libthpos_context.salesman-psn-code
    buf_chk-doc.src-tot-doc = 0
    buf_chk-doc.netto = 0
    buf_chk-doc.tot-doc = 0
    buf_chk-doc.discnt = 0
    buf_chk-doc.sub-discnt = 0
    buf_chk-doc.doc-qnty = 0
    libthpos_chk-context.doc-code = buf_chk-doc.doc-code
    libthpos_chk-context.obj-code = buf_chk-doc.obj-code
    libthpos_chk-context.chk-type = buf_chk-doc.chk-type
    libthpos_chk-context.lng = 0
    libthpos_chk-context.recalc-gline-num = libthpos_chk-context.lng + 1
    libthpos_chk-context.lnp = 0
    libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
    libthpos_chk-context.lnd = 0
    libthpos_chk-context.chk-date = v-today
    libthpos_chk-context.chk-time = v-time
    libthpos_chk-context.base-rate = v-base-rate
    libthpos_chk-context.cash-rate = v-cash-rate
    libthpos_chk-context.cash-scale = v-cash-scale
    libthpos_chk-context.bank-rate = v-bank-rate
    libthpos_chk-context.bank-scale = v-bank-scale
    libthpos_chk-context.a-chk-date = v-today
    libthpos_chk-context.a-chk-time = v-time
    libthpos_chk-context.a-base-rate = v-base-rate
    libthpos_chk-context.a-cash-rate = v-cash-rate
    libthpos_chk-context.a-cash-scale = v-cash-scale
    libthpos_chk-context.a-bank-rate = v-bank-rate
    libthpos_chk-context.a-bank-scale = v-bank-scale
    libthpos_chk-context.is-petrol-check = lookup(string(p-chk-type), {&petrol-receipt-codes}) > 0
    libthpos_chk-context.rowid_ = rowid(buf_chk-doc)
    libthpos_chk-context.sale-in-out = v-sale-in-out
    p-doc-code = buf_chk-doc.doc-code
    p-bank-rate = v-bank-rate
    p-bank-scale = v-bank-scale
    p-cash-rate = v-cash-rate
    p-cash-scale = v-cash-scale
    .
    { str/libchkvl_right-netto-sign.i
    libthpos_chk-context.direction
    libthpos_chk-context.chk-type
    }
    create libthpos_chk-doc.
    buffer-copy buf_Chk-doc to libthpos_chk-doc.
    find first locked_chk-doc share-lock where
              rowid(locked_chk-doc) = rowid(buf_chk-doc).
    libthpos_context.ll = libthpos_context.ll + 1.
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end.

end procedure. /* libthpos_create-chk-doc */

procedure libthpos_create-chk-title :
define input parameter p-db-num   as integer no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-cash-num as integer no-undo .
define input parameter p-chk-type as integer no-undo .
define input parameter p-cashier  as integer no-undo .
define input parameter p-cashier-psn-code as integer no-undo .
define output parameter p-doc-code as character no-undo .
define output parameter p-bank-rate as decimal no-undo .
define output parameter p-bank-scale as decimal no-undo .
define output parameter p-cash-rate as decimal no-undo .
define output parameter p-cash-scale as integer no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-base-rate as decimal no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-cash-scale as integer no-undo .
define variable v-sale-in-out as logical no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_staff for ub.staff.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_chk-doc for ub.chk-doc.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if lookup(string(p-chk-type), {&wth-receipt-codes}) = 0
    then do:
      v-err-mess = substitute("Неверный тип чека МЦ = &1", p-chk-type).
      undo main-block, retry main-block.
    end.
    if p-pos-type = {&cd-type-ibs-th-mob} then do:
      v-err-mess = substitute("Неверный тип кассы = &2", p-pos-type).
      undo main-block, retry main-block.
    end.
    find first libthpos_context no-error.
    if not available libthpos_context then do:
      v-err-mess = substitute("Не выставлен контекст работы").
      undo main-block, retry main-block.
    end.
    if not (libthpos_context.db-num = p-db-num
            and
            libthpos_context.obj-code = p-obj-code
            and
            libthpos_context.pos-type = p-pos-type
            and
            libthpos_context.cash-num = p-cash-num) then do:
      v-err-mess = substitute("Неверный контекст").
      undo main-block, retry main-block.
    end.
    /*очистим dataset*/
    if buffer libthpos_chk-context:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    if buffer libthpos_chk-pay:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    if buffer libthpos_chk-gds:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    if buffer libthpos_chk-discnt:table-handle:tracking-changes then
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).

    dataset libthpos_receipt:empty-dataset().
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    ,  input yes).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input yes).

    run cur-time in this-procedure ( output v-today, output v-time).
    find first buf_staff no-lock where
              buf_staff.role = {&role-cashier}
        and buf_staff.role-level = {&role-level-db}
        and buf_staff.db-num = p-db-num
        and buf_staff.staff-code = p-cashier
        and buf_staff.date-start <= v-today
        and buf_staff.date-end >= v-today
        and buf_staff.psn-code = p-cashier-psn-code no-error.
    if not available buf_staff then do:
      v-err-mess = substitute("На текущий момент нет кассира с кодом &1 БД &2 и кодом физ.лица &3"
                                  , p-cashier
                                  , p-db-num
                                  , p-cashier-psn-code
                                  ).

      undo main-block, retry main-block.
    end.
    assign
    v-base-rate = 1
    v-cash-rate = 1
    v-cash-scale = 1
    v-bank-rate = 1
    v-bank-scale = 1
    .
    /*найдем курс валюты*/
    if libthpos_context.r-b = {&r-b-base}
    and libthpos_context.base-code <> 0 then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = {&shop}
                AND buf_curr-shop.obj-code = p-obj-code
                AND buf_curr-shop.curr-code = libthpos_context.base-code
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-cash-rate = buf_curr-shop.exch-rate
        v-cash-scale = buf_curr-shop.exch-scale
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , {&shop}
                                      , p-obj-code
                                      , v-today
                                    ).

        undo main-block, retry main-block.
      end.
      { gbl/exchrate.i libthpos_context.base-code v-today v-bank-rate v-bank-scale v-bank-abbr }
    end.
    if libthpos_context.r-b = {&r-b-rubl}
    and libthpos_context.base-code <> 0 then do:
      FIND LAST buf_curr-shop NO-LOCK WHERE
                buf_curr-shop.obj-type = {&shop}
            AND buf_curr-shop.obj-code = p-obj-code
            AND buf_curr-shop.curr-code = libthpos_context.base-code
            AND ( ( buf_curr-shop.exch-date = v-today
                    AND
                    buf_curr-shop.exch-time <= v-time ) OR
                    buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , {&shop}
                                      , p-obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
      { gbl/exchrate.i libthpos_context.base-code v-today v-bank-rate v-bank-scale v-bank-abbr }
    end.
    create buf_chk-doc.
    create libthpos_chk-context.
    assign
    buf_chk-doc.obj-type = {&shop}
    buf_chk-doc.obj-code = p-obj-code
    buf_chk-doc.office = ?
    buf_chk-doc.doc-code = (if p-db-num = 0
                            then string(next-value(s-chk, {&db-name_schema} ))
                            else string( p-obj-code ) + {&slash-char} + string( next-value( s-chk, {&db-name_schema} ) ))
    loc-print-doc-code = buf_chk-doc.doc-code
    buf_chk-doc.chk-date = v-today
    buf_chk-doc.chk-time = v-time
    buf_chk-doc.pay-desk = p-cash-num
    buf_chk-doc.cashier  = p-cashier
    buf_chk-doc.cashier-psn-code  = p-cashier-psn-code
    buf_chk-doc.d-card =  ''
    buf_chk-doc.src-shift-date = v-today /*пока*/
    buf_chk-doc.src-shift-name = ''
    buf_chk-doc.shift-name = ''
    buf_chk-doc.shift-num = 0
    buf_chk-doc.cash-rate = v-cash-rate
    buf_chk-doc.cash-scale = v-cash-scale
    buf_chk-doc.base-rate = v-base-rate
    buf_chk-doc.z-number = libthpos_context.z-number
    buf_chk-doc.chk-type = p-chk-type
    buf_chk-doc.correct = yes
    buf_chk-doc.discnt = 0
    buf_chk-doc.sales-man = libthpos_context.sales-man
    buf_chk-doc.salesman-psn-code = libthpos_context.salesman-psn-code
    libthpos_chk-context.doc-code = buf_chk-doc.doc-code
    libthpos_chk-context.obj-code = buf_chk-doc.obj-code
    libthpos_chk-context.chk-type = buf_chk-doc.chk-type
    libthpos_chk-context.lnp = 0
    libthpos_chk-context.chk-date = v-today
    libthpos_chk-context.chk-time = v-time
    libthpos_chk-context.base-rate = v-base-rate
    libthpos_chk-context.cash-rate = v-cash-rate
    libthpos_chk-context.cash-scale = v-cash-scale
    libthpos_chk-context.bank-rate = v-bank-rate
    libthpos_chk-context.bank-scale = v-bank-scale
    libthpos_chk-context.a-chk-date = v-today
    libthpos_chk-context.a-chk-time = v-time
    libthpos_chk-context.a-base-rate = v-base-rate
    libthpos_chk-context.a-cash-rate = v-cash-rate
    libthpos_chk-context.a-cash-scale = v-cash-scale
    libthpos_chk-context.a-bank-rate = v-bank-rate
    libthpos_chk-context.a-bank-scale = v-bank-scale
    libthpos_chk-context.rowid_ = rowid(buf_chk-doc)
    p-doc-code = buf_chk-doc.doc-code
    p-bank-rate = v-bank-rate
    p-bank-scale = v-bank-scale
    p-cash-rate = v-cash-rate
    p-cash-scale = v-cash-scale
    .
    { str/libchkvl_right-netto-sign.i
    libthpos_chk-context.direction
    libthpos_chk-context.chk-type
    }

    create libthpos_chk-doc.
    buffer-copy buf_chk-doc to libthpos_chk-doc.
    find first locked_chk-doc share-lock where
              rowid(locked_chk-doc) = rowid(buf_chk-doc).
    libthpos_context.ll = libthpos_context.ll + 1.
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end.

end procedure. /* libthpos_create-chk-title */


procedure libthpos_set-salesman :
define input parameter p-doc-code as character no-undo .
define input parameter p-line-num as integer no-undo .
define input parameter p-sales-man as integer no-undo .
define input parameter p-salesman-psn-code as integer no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_staff for ub.staff.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_Chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if p-doc-code <> "" then do:
      if not available libthpos_chk-context then do:
        find first libthpos_chk-context no-error.
      end.
      if not available libthpos_chk-context then do:
        v-err-mess = substitute("Не выставлен контекст чека").
        undo main-block, retry main-block.
      end.
      if libthpos_chk-context.doc-code <> p-doc-code then do:
        v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
        undo main-block, retry main-block.
      end.
      if lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) > 0
      or lookup(string(libthpos_chk-context.chk-type), {&rcpt-pre-z-rep}) > 0
      or lookup(string(libthpos_chk-context.chk-type), {&rcpt-z-rep}) > 0
      or lookup(string(libthpos_chk-context.chk-type), {&rcpt-pre-inventory}) > 0
      or lookup(string(libthpos_chk-context.chk-type), {&rcpt-inventory}) > 0
      then do:
        v-err-mess = substitute("В чеке &1 с типом &2 продавца быть не может", p-doc-code, libthpos_chk-context.chk-type).
        undo main-block, retry main-block.
      end.
    end.
    if p-line-num <> 0  then do:
      if p-doc-code = ""
      then do:
        v-err-mess = substitute("Задана строк чека (=&1) для установки продавца, но не задан номер чека", p-line-num).
        undo main-block, retry main-block.
      end.
      if libthpos_chk-context.lng < p-line-num then do:
        v-err-mess = substitute("В чеке &1 на строки &2"
                                      , p-doc-code
                                      , p-line-num).

        undo main-block, retry main-block.
      end.
    end.
    if p-sales-man <> 0 then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      find first buf_staff no-lock where
                buf_staff.role = {&role-seller}
          and buf_staff.role-level = {&role-level-db}
          and buf_staff.db-num = libthpos_context.db-num
          and buf_staff.staff-code = p-sales-man
          and buf_staff.date-start <= v-today
          and buf_staff.date-end >= v-today
          and buf_staff.psn-code = p-salesman-psn-code no-error.
      if not available buf_staff then do:
        v-err-mess = substitute("На текущий момент нет продавца с кодом &1 БД &2 и кодом физ.лица &3"
                                    , p-sales-man
                                    , libthpos_context.db-num
                                    , p-salesman-psn-code
                                    ).

        undo main-block, retry main-block.
      end.
    end.
    if p-doc-code = "" then do:
      assign
      libthpos_context.sales-man = p-sales-man
      libthpos_context.salesman-psn-code = (if p-sales-man = 0 then 0 else p-salesman-psn-code)
      .
    end.
    else do:
      assign
      libthpos_chk-context.sales-man = p-sales-man
      libthpos_chk-context.salesman-psn-code = (if p-sales-man = 0 then 0 else p-salesman-psn-code)
      .
      find first buf_chk-doc where
                buf_chk-doc.doc-code = p-doc-code.
      assign
      buf_chk-doc.sales-man = p-sales-man
      buf_chk-doc.salesman-psn-code = p-salesman-psn-code
      .
      if p-line-num > 0 then do:
        for first buf_chk-gds share-lock where
                buf_chk-gds.doc-code = p-doc-code
            and buf_chk-gds.line-num = p-line-num,
            first buf_libthpos_chk-gds where
                  buf_libthpos_chk-gds.doc-code = p-doc-code
              and buf_libthpos_chk-gds.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        :
          assign
          buf_chk-gds.sales-man = p-sales-man
          buf_chk-gds.salesman-psn-code = p-salesman-psn-code
          buf_libthpos_chk-gds.sales-man = p-sales-man
          buf_libthpos_chk-gds.salesman-psn-code = p-salesman-psn-code
          .
        end.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
    p-setted = yes.
  end. /*ne retry*/
end.

end procedure. /* libthpos_set-salesman */


procedure libthpos_set-card :
define input parameter p-doc-code as character no-undo .
define input parameter p-src-d-card as character no-undo .
define output parameter p-d-card as character no-undo .
define output parameter p-cli-type as character no-undo .
define output parameter p-cli-code as integer no-undo .
define output parameter p-obj-name as character no-undo .

define variable v-found as logical no-undo .
define variable v-descr as character no-undo .
define variable v-short-number as character no-undo .
define variable v-is-correct as logical no-undo .
define variable v-d-mask as character no-undo .
define variable v-d-card as character no-undo .
define variable v-th-mask as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-err-mess as character no-undo .

define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_libthpos_dis-card-mask for libthpos_dis-card-mask.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), {&no-d-card-receipt-codes}) > 0
    or lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) > 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 карты быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step >= {&step-pay} then do:
      v-err-mess = substitute("Уже есть строки оплаты, нельзя зарегистрировать ДК").
      undo main-block, retry main-block.
    end.
    find first buf_Dis-card no-lock where
              buf_Dis-card.d-card = p-src-d-card no-error.
    if not available buf_dis-card then do:
      if (libthpos_context.dc-mask or libthpos_context.card-by-mask) then do:
        _maska:
        for each buf_libthpos_dis-card-mask no-lock
        by buf_libthpos_dis-card-mask.rank
        on error undo main-block, retry main-block
        :
          assign
          v-found = yes
          v-descr = "":U
          v-short-number = '':U
          v-is-correct = no
          .
          if libthpos_context.card-by-mask then do:
            assign
            v-short-number = card-by-mask (buf_libthpos_dis-card-mask.cli-mask, buf_libthpos_dis-card-mask.cc-run, p-src-d-card)
            no-error
            .
            if error-status:error then do:
              v-err-mess = substitute("Не удается определить короткий номер ДК по маске (полный номер &1):&2&3"
                                            , p-src-d-card
                                            , {&new-line}
                                            , return-value ).
              undo main-block, retry main-block.
            end.
            v-d-mask = buf_libthpos_dis-card-mask.cli-mask.
          end.
          if v-short-number = '':U then do:
            if libthpos_context.dc-mask then do:
              assign
              v-is-correct = check-by-mask (buf_libthpos_dis-card-mask.mask, p-src-d-card, output v-descr)
              no-error
              .
              if error-status:error then do:
                v-err-mess = substitute("Не удается сопоставить карту (полный номер &1) маске:&2&3"
                                              , p-src-d-card
                                              , {&new-line}
                                              , return-value ).
                undo main-block, retry main-block.
              end.
              v-d-mask = buf_libthpos_dis-card-mask.mask.
            end.
          end.
          if v-is-correct or v-short-number <> '':U then do:
            find first buf_dis-card no-lock where
                      buf_dis-card.d-card = (if v-short-number <> '':U
                                            then v-short-number
                                            else buf_libthpos_dis-card-mask.mask) no-error .
            if available buf_dis-card
            and buf_dis-card.type = buf_libthpos_dis-card-mask.type
            and buf_dis-card.emitent-host-code = buf_libthpos_dis-card-mask.emitent-host-code
            then do:
              assign
              v-d-card = buf_Dis-card.d-card
              v-th-mask = yes
              .
              LEAVE _maska.
            end.
          end.
        end. /*for each _maska*/
        if not available buf_dis-card then do:
          v-err-mess =  (if not v-found
                            then substitute("Для карты &1 не определено ни одной действующей маски", v-d-card)
                            else substitute("Карта &1 не соответствует ни одной действующей маске", v-d-card)
                          ) .
          undo main-block, retry main-block.
        end.
      end.  /*if dc-mask or card-by-mask*/
    end. /*if not avail dis-card */
    if avail buf_dis-card
    then find first buf_dis-card-type No-LOCK WHERE
                    buf_dis-card-type.type = buf_dis-card.type AND
                    buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code AND
                    buf_dis-card-type.host-code = 0 AND
                    buf_dis-card-type.obj-type = "":U AND
                    buf_dis-card-type.obj-code = 0
                    NO-ERROR.
    else release buf_dis-card-type.

    IF NOT avail buf_dis-card
    or NOT avail buf_dis-card-type
    OR (buf_dis-card.emitent-host-code <> libthpos_context.host-code and buf_dis-card.emitent-host-code <> 0)
    or (lookup(string(libthpos_context.obj-code), buf_dis-card-type.DCBYSHOP) > 0
        and
        buf_dis-card.issue-code <> libthpos_context.obj-code)
    then do:
      v-err-mess = substitute("Нет сведений о карте клиента &1 или карта выдана другим магазином"
                              , p-src-d-card
                            ) .
      undo main-block, retry main-block.
    end.
    if avail buf_dis-card
    and buf_dis-card.emitent-host-code = 0
    and buf_dis-card.credit-card then do:
      v-err-mess = substitute(
                              "Глобальная карта &1 (&2) не может быть кредитной"
                              , p-src-d-card
                              , v-d-card
                            ) .
      undo main-block, retry main-block.
    end.
    if avail buf_dis-card
    and buf_dis-card.status_ = {&nonused-status} then do:
      v-err-mess = substitute("Карта &2 имеет статус &3&1" +
                              "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА и подлежит ПОЛНОМУ И ОКОНЧАТЕЛЬНОМУ УДАЛЕНИЮ&1"
                              , {&new-line}
                              , buf_dis-card.d-card
                              , buf_dis-card.status_
                            )                  .
      undo main-block, retry main-block.
    end.
    if available buf_Dis-card
    and buf_dis-card.status_ =  {&deleted-status} then do:
      v-err-mess = substitute("Карта &2 имеет статус &3&1" +
                              "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА&1"
                              , {&new-line}
                              , buf_dis-card.d-card
                              , buf_dis-card.status_
                            )                  .
      undo main-block, retry main-block.
    end.
    if available buf_dis-card
    and buf_Dis-card.valid-from <> ? then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      if buf_dis-card.valid-from > v-today then do:
        v-err-mess = substitute("Дата начала действия карты &1 = &2&3" +
                                "карта НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА&1"
                                , buf_dis-card.d-card
                                , string(buf_dis-card.valid-from, "99/99/9999")
                                , {&new-line}
                              )                  .
        undo main-block, retry main-block.
      end.
    end.
    if available buf_dis-card
    and buf_Dis-card.valid-date <> ? then do:
      if v-today = ? then do:
        run cur-time in this-procedure ( output v-today, output v-time).
      end.
      if buf_dis-card.valid-date < v-today then do:
        v-err-mess = substitute("Карта &1 просрочена (&2)&3" +
                                "и НЕ МОЖЕТ БЫТЬ ИСПОЛЬЗОВАНА&1"
                                , buf_dis-card.d-card
                                , string(buf_dis-card.valid-from, "99/99/9999")
                                , {&new-line}
                              )                  .
        undo main-block, retry main-block.
      end.
    end.

    find first buf_chk-doc share-lock where
              rowid(buf_chk-doc) = libthpos_chk-context.rowid_.
    assign
    p-d-card   = buf_Dis-card.d-card
    p-cli-type = buf_Dis-card.cli-type
    p-cli-code = buf_Dis-card.cli-code
    buf_chk-doc.src-d-card = p-src-d-card
    buf_chk-doc.src-d-mask = v-d-mask
    buf_chk-doc.src-cli-type = buf_dis-card.cli-type
    buf_chk-doc.src-cli-code = buf_dis-card.cli-code
    libthpos_chk-doc.src-d-card = p-src-d-card
    libthpos_chk-doc.src-d-mask = v-d-mask
    libthpos_chk-doc.src-cli-type = buf_dis-card.cli-type
    libthpos_chk-doc.src-cli-code = buf_dis-card.cli-code
    libthpos_chk-context.src-d-card = p-src-d-card
    libthpos_chk-context.src-d-mask = v-d-mask
    libthpos_chk-context.src-cli-type = buf_dis-card.cli-type
    libthpos_chk-context.src-cli-code = buf_dis-card.cli-code
     libthpos_chk-context.d-pcnt = (if buf_dis-card.d-pcnt-method = integer({&dc-d-pcnt-good})
                                  or buf_dis-card.d-pcnt-method  = integer({&dc-d-pcnt-both})
                                  then buf_dis-card.d-pcnt
                                  else 0)
    libthpos_chk-context.cash-d-pcnt = (if buf_dis-card.d-pcnt-method = integer({&dc-d-pcnt-cash})
                                        or buf_dis-card.d-pcnt-method  = integer({&dc-d-pcnt-both})
                                        then  buf_dis-card.cash-d-pcnt
                                        else 0)
    libthpos_chk-context.category = buf_dis-card.category
    .


    if buf_dis-card-type.d-pcnt-byshop then do:
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        libthpos_context.host-code
        libthpos_context.obj-type
        libthpos_context.obj-code
        {&ddctr-def-pcnt}
        libthpos_chk-context.d-pcnt
        no-error
        }
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        libthpos_context.host-code
        libthpos_context.obj-type
        libthpos_context.obj-code
        {&ddctr-def-cash-pcnt}
        libthpos_chk-context.cash-d-pcnt
        no-error
        }
      { gbl/objdpcnt.i
        buf_dis-card-type.type
        buf_dis-card-type.emitent-host-code
        libthpos_context.host-code
        libthpos_context.obj-type
        libthpos_context.obj-code
        {&ddctr-def-categ}
        libthpos_chk-context.category
        no-error
        }
    end.



    if libthpos_chk-context.step > {&step-start} then do:
      for each buf_chk-gds share-lock where
              buf_chk-gds.doc-code = p-doc-code,
        first libthpos_chk-gds where
            libthpos_chk-gds.doc-code = p-doc-code
          and libthpos_chk-gds.line-num = buf_chk-gds.line-num
      on error undo main-block, retry main-block:
        assign
        buf_chk-gds.src-d-card = p-src-d-card
        buf_chk-gds.src-d-mask = v-d-mask
        buf_chk-gds.src-cli-type = buf_dis-card.cli-type
        buf_chk-gds.src-cli-code = buf_dis-card.cli-code
        libthpos_chk-gds.src-d-card = p-src-d-card
        libthpos_chk-gds.src-d-mask = v-d-mask
        libthpos_chk-gds.src-cli-type = buf_dis-card.cli-type
        libthpos_chk-gds.src-cli-code = buf_dis-card.cli-code
        libthpos_chk-context.recalc-gline-num = 1
        .
      end.
      run libthpos_recalc-discnt in this-procedure no-error.
      if error-status:error then do:
        v-err-mess = substitute("Ош-ка при пересчете: &1 &2", return-value , error-status:get-message(1) ).
        undo main-block, retry main-block.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end.

end procedure. /* libthpos_set-card */

procedure libthpos_gds-line :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-mode as character no-undo .
define input  parameter p-line-direction as integer no-undo . /*1 прямая строка -1 обратная 0 на будущее*/
define input  parameter p-src-code as character no-undo .
define input-output  parameter p-src-qnty as decimal no-undo .
define input  parameter p-pump as integer no-undo .
define input  parameter p-nozzle-code as integer no-undo .
define input  parameter p-pl-code    as integer no-undo .
define input  parameter p-pass-gds   as integer no-undo .
define input  parameter p-write-off-code as integer no-undo .
define input  parameter p-depart-id  as integer no-undo .
define output parameter p-setted as logical no-undo .
define output parameter p-next as character no-undo .
define output parameter p-b-code as integer no-undo .
define output parameter p-gds-code as integer no-undo .
define output parameter p-chk-name as character no-undo .
define output parameter p-second-name as character no-undo .
define input-output parameter p-src-price as decimal no-undo .
define output parameter p-src-price-rubl as decimal no-undo .
define output parameter p-src-discnt-sum as decimal no-undo .
define output parameter p-src-discnt-sum-rubl as decimal no-undo .
define output parameter p-src-sum as decimal no-undo .
define output parameter p-src-sum-rubl as decimal no-undo .
define output parameter p-src-sum-netto as decimal no-undo .
define output parameter p-src-sum-netto-rubl as decimal no-undo .
define output parameter p-unit-base as character no-undo .                             /*   12345  */


define variable v-doc-qnty as decimal no-undo .
define variable v-cli-base-rate as decimal no-undo .
define variable v-line-direction as integer no-undo .
define variable v-result   as character         no-undo.
define variable v-type-bc  as character         no-undo.
define variable v-weight   as decimal           no-undo.
define variable v-empty-scale as logical no-undo .
define variable v-gds-name as character no-undo .
define variable v-gds-name1 as character no-undo .
define variable v-second-name as character no-undo .
define variable v-f-name as character no-undo .
define variable v-b-code as integer no-undo .
define variable v-main-bar-code as integer no-undo .
define variable v-is-weight-pbc as logical no-undo .
define variable v-is-pgweight-pbc as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-unit-base as character no-undo .
define variable v-unit-base-type as character no-undo .
define variable v-unit-cli as character no-undo .
define variable v-unit-cli-type as character no-undo .
define variable v-prt-root as integer no-undo .
define variable v-root-node-code as integer no-undo .
define variable v-min-rate as decimal no-undo .
define variable v-max-rate as decimal no-undo .
define variable v-node-code as integer no-undo .
define variable v-in-code as character no-undo .
define variable v-part-code as character no-undo .
define variable v-chk-name as character no-undo .
define variable v-cash-parts as logical no-undo .
define variable v-gtd as character no-undo .
define variable v-valid as logical no-undo .
define variable v-mess as character no-undo .
define variable v-chr-err as character no-undo .
define variable v-plt-id          as integer   no-undo .
define variable v-plt-db-num      as integer   no-undo .
define variable v-pdf-id          as integer   no-undo .
define variable v-pdf-db-num      as integer   no-undo .
define variable v-sale-price-base as decimal   no-undo .
define variable v-sale-price-rubl as decimal   no-undo .
define variable v-sale-price-r-b as decimal   no-undo .
define variable v-depart-type as character no-undo .
define variable v-depart-code as integer no-undo .
define variable v-is-null-price as logical no-undo .
define variable v-road-tax-base as decimal   no-undo .
define variable v-road-tax-rubl as decimal   no-undo .
define variable v-excise-base   as decimal   no-undo .
define variable v-excise-rubl   as decimal   no-undo .
define variable v-free-price as logical no-undo .
define variable v-sum-grp-code as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-no-add-price as logical no-undo .
define variable v-discnt as decimal no-undo .
define variable v-m-discnt as decimal no-undo .
define variable v-src-price as decimal no-undo .
define variable v-src-discnt as decimal no-undo .
define variable v-start-src-price as decimal no-undo .
define variable v-start-src-discnt as decimal no-undo .
define variable v-new-src-price as decimal no-undo .
define variable v-new-src-discnt as decimal no-undo .
define variable v-dopchr as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-recalc as logical no-undo .
define variable v-scpg-format as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-accept-changes as logical no-undo .
define variable v-in-ov as logical no-undo .

define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_place for ub.place.
define buffer buf_goods for ub.goods.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_units for ub.units.
define buffer root_gds-prt for ub.gds-prt.
define buffer term_gds-prt for ub.gds-prt.
define buffer cli_units for ub.units.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf2_libthpos_chk-gds for libthpos_chk-gds.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if p-line-num <= 0 then do:
      v-err-mess = substitute("Неверный номер товарной строки = &1", p-line-num).
      undo main-block, retry main-block.
    end.
    if not (p-mode = {&add-def}
            or
            p-mode = {&update}
            or
            p-mode = {&deletion}
            or
            p-mode = {&update}  + {&comma-char} + "recalc"
            or
            p-mode = {&update}  + {&comma-char} + "recalc" + {&comma-char} + "no-changes"
            or
            p-mode = {&lookup}
            ) then do:
      v-err-mess = substitute("Неверное действие над товарной строкой чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    assign
    v-accept-changes = yes.
    if (p-mode = {&update}  + {&comma-char} + "recalc" + {&comma-char} + "no-changes") then do:
      v-accept-changes = no.
    end.
    if (p-mode = {&update}  + {&comma-char} + "recalc")
    or (p-mode = {&update}  + {&comma-char} + "recalc" + {&comma-char} + "no-changes")
    then do:
      assign
      v-is-recalc = yes
      p-mode = {&update}
      .
    end.
    if p-mode = {&lookup} then do:
      find first buf_libthpos_chk-gds where
                buf_libthpos_chk-gds.doc-code = p-doc-code
           and  buf_libthpos_chk-gds.line-num = p-line-num no-error.
      if not available buf_libthpos_chk-gds then do:
        v-err-mess = substitute("Не найдена строка &1 в чеке &2", p-line-num, p-doc-code).
        undo main-block, retry main-block.
      end.
      assign
      p-b-code = buf_libthpos_chk-gds.b-code
      p-gds-code = buf_libthpos_chk-gds.gds-code
      p-second-name = buf_libthpos_chk-gds.second-name
      p-src-price = buf_libthpos_chk-gds.src-price
      p-src-price-rubl = buf_libthpos_chk-gds.src-price-rubl
      p-src-discnt-sum = buf_libthpos_chk-gds.src-discnt-sum
      p-src-discnt-sum-rubl = buf_libthpos_chk-gds.src-discnt-sum-rubl
      p-src-sum = buf_libthpos_chk-gds.src-sum
      p-src-sum-rubl = buf_libthpos_chk-gds.src-sum-rubl
      p-src-sum-netto = p-src-sum - p-src-discnt-sum
      p-src-sum-netto-rubl = p-src-sum-rubl - p-src-discnt-sum-rubl
      p-unit-base = buf_libthpos_chk-gds.unit-base         /*  12345 */
      p-setted = yes
      p-next = (if (libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
                or libthpos_chk-context.step >  {&step-gds})
                  and not v-is-recalc
                  then substitute("recalc=&1,&2,&3"
                                  ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                                  ,(if libthpos_chk-context.step > {&step-gds} or p-mode = {&deletion} then 1 else 0)
                                  ,(if libthpos_chk-context.step > {&step-subtotal} or p-mode = {&deletion} then 1 else 0)
                                )
                  else "")
      .
      /*
      message
      p-b-code "p-b-code" skip
      p-gds-code "p-gds-code" skip
      p-second-name " p-second-name" skip
      p-src-price  "p-src-price" skip
      p-src-price-rubl "p-src-price-rubl" skip
      p-src-discnt-sum "p-src-discnt-sum" skip
      p-src-discnt-sum-rubl "p-src-discnt-sum-rubl" skip
      p-src-sum "p-src-sum" skip
      p-src-sum-rubl "p-src-sum-rubl" skip
      p-src-sum-netto "p-src-sum-netto" skip
      p-src-sum-netto-rubl "p-src-sum-netto-rubl " skip
      p-setted "p-setted"
      p-next "p-next"
      view-as alert-box .
      */
      return ''.
    end.
    if p-mode = {&deletion}
    and p-src-qnty <> 0 then do:
      v-err-mess = substitute("Для удаления товарной строки чека количество должно = 0").
      undo main-block, retry main-block.
    end.
    if p-mode = {&update}
    and p-src-qnty = 0
    or p-src-qnty = ?
    then do:
      v-err-mess = substitute("Для изменения товарной строки чека количество должно быть задано").
      undo main-block, retry main-block.
    end.
    /*проверим корректность знака количества*/
    if libthpos_chk-context.direction > 0
    and p-line-direction > 0
    and p-src-qnty  < 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction > 0
    and p-line-direction < 0
    and p-src-qnty  > 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction < 0
    and p-line-direction < 0
    and p-src-qnty  < 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.direction < 0
    and p-line-direction > 0
    and p-src-qnty  > 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if p-line-direction < 0 then do:
      v-err-mess = substitute("Еще не реализован режим задания отрицательного количества (код &1)", p-src-code).
      undo main-block, retry main-block.
    end.
    if (p-mode = {&add-def}
    or p-mode = {&update})
    and p-line-num = 1
    and libthpos_chk-context.direction > 0
    and p-src-qnty < 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    if (p-mode = {&add-def}
    or p-mode = {&update})
    and p-line-num = 1
    and libthpos_chk-context.direction < 0
    and p-src-qnty > 0 then do:
      v-err-mess = substitute("Неверный знак количества товарной строки чека с кодом &1", p-src-code).
      undo main-block, retry main-block.
    end.
    /*проверим что в таком чеке могут быть строки*/
    if lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) > 0
    or lookup(string(libthpos_chk-context.chk-type), {&no-gds-receipt-codes}) > 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 товарной строки быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    /*  теперь они забыли что мы договорились цену посылать на возврате!
    if (libthpos_chk-context.chk-type = integer({&rcpt-return})
    or libthpos_chk-context.chk-type = integer({&rcpt-return-write-off})
    or libthpos_chk-context.chk-type = integer({&rcpt-ord-return})
      )
    and (p-src-price = ?
        or
        p-src-price = 0)
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 должна быть задана цена", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    */
    if lookup(string(p-write-off-code), {&wro-codes}) = 0 then do:
      v-err-mess = substitute("Неверный код списания = &1 для строки &2", p-write-off-code, p-line-num).
      undo main-block, retry main-block.
    end.
    case p-mode:
      when {&add-def} then do:
        if libthpos_chk-context.lng + 1 <> p-line-num then do:
          v-err-mess = substitute("Неверный № товарной строки чека = &1&2должен быть &3"
                                      , p-line-num
                                      , {&new-line}
                                      , libthpos_chk-context.lng + 1).
          undo main-block, retry main-block.
        end.
        if p-src-code = ?
        or p-src-code = "" then do:
          v-err-mess = substitute("Не задан код товара для новой строки чека &1", P-LINE-NUM).
          undo main-block, retry main-block.
        end.
        { str/bc-rcnz.i
          libthpos_context.parparentproc
          p-src-code
          p-src-price
          ~{&shop~}
          libthpos_context.obj-code
          " ( if g#auto then no else yes ) "
          no
          libthpos_context.sclspref
          libthpos_context.scpgpref
          v-result
          v-type-bc
          v-weight
          buf_bar-code
          buf_prod-bc
          buf_place
          no-error
        }
        if not available buf_bar-code then do:
           v-err-mess = substitute("Не найден товар по коду &1", p-src-code).
          undo main-block, retry main-block.
        end.
        if available buf_prod-bc
        and buf_prod-bc.bc-on = no then do:
          v-err-mess = substitute("Товар по коду &1 найден, но данный ДопБК Выключен", p-src-code).
          undo main-block, retry main-block.
        end.
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if not available buf_goods then do:
          v-err-mess = substitute("Отсутствует в IBS TH товар с кодом &1, основным бар-кодом &2, найденный по коду &3"
                                                , buf_bar-code.gds-code
                                                , buf_bar-code.b-code
                                                , p-src-code).
          undo main-block, retry main-block.
        end.
        find first root_gds-prt where
                root_gds-prt.upper-code = buf_goods.prt-root NO-LOCK .
        assign
        v-unit-base = buf_goods.unit-base
        v-min-rate = buf_goods.min-rate
        v-max-rate = buf_goods.max-rate
        v-gds-code = buf_goods.gds-code
        v-b-code = buf_bar-code.b-code
        v-in-code = buf_bar-code.in-code
        v-part-code = buf_bar-code.part-code
        v-node-code = buf_bar-code.node-code
        v-unit-cli = buf_bar-code.unit-cli
        v-root-node-code = root_gds-prt.node-code
        v-prt-root = buf_goods.prt-root
        .
        if buf_bar-code.in-code = ""
        and buf_bar-code.part-code = ""
        and buf_bar-code.unit-cli = buf_goods.unit-base
        and buf_bar-code.node-code = root_gds-prt.node-code then do:
          v-main-bar-code = buf_bar-code.b-code.
        end.
        else do:
          /*найдем главный код товара*/
          { gbl/gdsbcode.i buf_goods.gds-code v-root-node-code v-main-bar-code }
        end.
        assign
        v-empty-scale = NOT (libthpos_context.doc-prt AND ( root_gds-prt.node-name <> {&empty-scale}))
        .

        FIND FIRST buf_units WHERE
                  buf_units.unit-name = buf_goods.unit-base NO-LOCK .
        if buf_bar-code.unit-cli <> buf_goods.unit-base then do:
          find first cli_units no-lock where
                    cli_units.unit-name = buf_bar-code.unit-cli.
          assign
          v-unit-cli-type = cli_units.type
          v-unit-base-type = buf_units.type
          .
        end.
        else do:
          assign
          v-unit-cli-type = buf_units.type
          v-unit-base-type = buf_units.type
          .
        end.
        find first term_gds-prt no-lock where
                  term_gds-prt.node-code = buf_bar-code.node-code
              and term_gds-prt.prt-root = root_gds-prt.prt-root.
        if lookup({&weight}, v-unit-cli-type) > 0
        then do:
          if lookup(substring(p-src-code, 1, 2), libthpos_context.sclspref) > 0
          and length(p-src-code) = 13
          then do:
            /*проверим КЦ*/
            assign
            v-dopchr = substring(p-src-code, 1, 12).
            run str/chk-sum.p ( input-output v-dopchr) no-error.
            if error-status:error then do:
              v-err-mess = substitute("Не удалось рассчитать КЦ в предположительно весовом коде &1: не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
                          undo main-block, retry main-block.
            end.
            if v-dopchr <> p-src-code then do:
              v-err-mess = substitute("Неверная КЦ &2 в предположительно весовом коде &1 (дожна быть &3): не удалось найти количество весового товара по коду &1"
                                                    , p-src-code
                                                    ,substring(p-src-code, 13, 1)
                                                    ,substring(v-dopchr, 13, 1)
                                                    ).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty  = decimal(substring(p-src-code, 8, 5)) / 1000
            v-is-weight-pbc = yes
            no-error
            .
            if error-status:error then do:
              v-err-mess = substitute("Не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty = libthpos_chk-context.direction * p-src-qnty * p-line-direction
            .
          end.
        end.
        if lookup({&pieces}, v-unit-base-type) > 0
        then do:
          if lookup(substring(p-src-code, 1, 2), libthpos_context.scpgpref-pre) > 0
          and length(p-src-code) = 13
          then do:
            /*проверим КЦ*/
            assign
            v-scpg-format = entry(lookup(substr(p-src-code, 1, 2), libthpos_context.scpgpref-pre), libthpos_context.scpgpref)
            v-dopchr = substring(p-src-code, 1, 12).
            run str/chk-sum.p ( input-output v-dopchr) no-error.
            if error-status:error then do:
              v-err-mess = substitute("Не удалось рассчитать КЦ в предположительно штучном коде для весов &1: не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
              undo main-block, retry main-block.
            end.
            if v-dopchr <> p-src-code then do:
              v-err-mess = substitute("Неверная КЦ &2 в предположительно штучном коде для весов &1 (дожна быть &3): не удалось найти количество весового товара по коду &1"
                                                    , p-src-code
                                                    ,substring(p-src-code, 13, 1)
                                                    ,substring(v-dopchr, 13, 1)
                                                    ).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty  = decimal(substring(p-src-code, 8, 5)) / exp(10, num-entries(substring(v-scpg-format, 8,5), "0") - 1)
            v-is-pgweight-pbc = yes
            no-error
            .
            if error-status:error then do:
              v-err-mess = substitute("Не удалось найти количество весового товара по коду &1"
                                                    , p-src-code).
              undo main-block, retry main-block.
            end.
            assign
            p-src-qnty = libthpos_chk-context.direction * p-src-qnty * p-line-direction
            .
          end.
        end.

        assign
        v-cli-base-rate = buf_bar-code.cli-base-rate
        v-doc-qnty = p-src-qnty * v-cli-base-rate.
        /*сделаем имя*/
        assign
        v-gds-name  = IF libthpos_context.nam-2str
                      then buf_goods.gds-name
                      else (
                            IF libthpos_context.nam-artc
                            then buf_goods.artic
                            else (if buf_goods.chk-name <> ""
                                  then buf_goods.chk-name
                                  else buf_goods.gds-name)
                          )
      v-f-name = (if NOT v-empty-scale
                  then term_gds-prt.f-name
                  else "")
      v-gds-name1 =   name-2cdf(
                        input libthpos_context.name-2cd
                      , input yes /*по товару*/
                      , input libthpos_context.cod-pcod
                      , input buf_bar-code.b-code
                      , input buf_goods.gds-code
                      , input buf_goods.artic
                      , input buf_goods.engl-name
                      , input buf_bar-code.in-code
                      , input buf_bar-code.part-code
                      , input libthpos_context.obj-type
                      , input libthpos_context.obj-code
                      , input buf_goods.alpha1
                      , output v-gtd
                      ).

        assign
        p-chk-name = chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th ( input libthpos_context.pos-type
                                          ,input libthpos_context.nam-2str
                                          ,input libthpos_context.nam-artc
                                          ,input v-unit-cli-type
                                          ,input buf_goods.unit-base
                                          ,input buf_bar-code.unit-cli
                                          ,input buf_bar-code.cli-base-rate
                                          ,input buf_goods.artic
                                          ,input v-f-name
                                          ,input v-gds-name
                                          ,input v-gds-name1
                                          ,output v-second-name ).
        /*проверим можно ли продавать по этому бар-коду*/
        if lookup(string(libthpos_chk-context.chk-type), {&petrol-receipt-codes} ) > 0
        and LOOKUP({&petrolium}, buf_units.type) = 0 then do:
          v-err-mess = substitute("Недопустима строка с обычным товаром в чеке типа &1", libthpos_chk-context.chk-typ).
          undo main-block, retry main-block.
        end.
        { gbl/gdsobjat.i {&shop} libthpos_context.obj-code buf_goods.artic buf_goods.prod-type buf_goods.prod-code 'cash-parts=request' v-cash-parts }
        if lookup(string(libthpos_chk-context.chk-type), {&sale-in-receipt-codes}) = 0
        and p-src-price <> ?
        then do:
          run gdsoattr-value in this-procedure (
                                                  input   {&attr-free-price-o}
                                                ,input   v-gds-code
                                                ,input   libthpos_context.obj-type
                                                ,input   libthpos_context.obj-code
                                                ,output  v-attr-value
                                                ,output  v-attr-type
                                                ) no-error.
          if not error-status:error
          and v-attr-value <> "" then do:
            v-free-price = logical(v-attr-value).
          end.
          if v-free-price = no
          then do:
            v-err-mess = substitute("Для товара с кодом &1 свободный ввод цены не разрешен", p-src-code).
            undo main-block, retry main-block.
          end.
        end.
        if libthpos_context.is-grp-totals =  yes then do:
          run gdsoattr-value in this-procedure (
                                                  input   {&attr-sum-grp-o}
                                                  ,input   v-gds-code
                                                  ,input   libthpos_context.obj-type
                                                  ,input   libthpos_context.obj-code
                                                  ,output  v-attr-value
                                                  ,output  v-attr-type
                                                  ) no-error.
          if not error-status:error
          and v-attr-value <> "" then do:
            v-sum-grp-code = integer(v-attr-value).
          end.
        end.
      end.
      when {&update}
      or
      when {&deletion}
      then do:
        for first buf_chk-gds share-lock where
                buf_chk-gds.doc-code = p-doc-code
            and buf_chk-gds.line-num = p-line-num,
            first buf_libthpos_chk-gds where
                buf_libthpos_chk-gds.doc-code = p-doc-code
            and buf_libthpos_chk-gds.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          leave.
        end.
        if not available buf_chk-gds then do:
          v-err-mess = substitute("Неверный № товарной строки чека = &1"
                                      , p-line-num
                                      ).
          undo main-block, retry main-block.
        end.
        if p-src-code <> buf_chk-gds.src-code
        then do:
          v-err-mess = substitute("Для уже имеющейся строки чека (&1) нельзя изменить код продажи - был &2"
                                      , p-line-num
                                      , buf_chk-gds.src-code
                                      ).
          undo main-block, retry main-block.
        end.
        if p-line-direction <> buf_libthpos_chk-gds.line-direction then do:
          v-err-mess = substitute("Для уже имеющейся строки чека (&1) нельзя изменить знак количества - был &2"
                                      , p-line-num
                                      , buf_libthpos_chk-gds.line-direction
                                      ).
          undo main-block, retry main-block.
        end.

        /*проверим что в результате изменения знак не поменяется на обратный*/
        assign
        v-b-code = buf_libthpos_chk-gds.b-code
        v-main-bar-code = buf_libthpos_chk-gds.main-bar-code
        v-gds-code = buf_libthpos_chk-gds.gds-code
        v-unit-base-type = buf_libthpos_chk-gds.unit-base-type
        v-unit-base = buf_libthpos_chk-gds.unit-base
        v-unit-cli = buf_libthpos_chk-gds.unit-cli
        v-unit-cli-type = buf_libthpos_chk-gds.unit-cli-type
        v-min-rate = buf_libthpos_chk-gds.min-rate
        v-max-rate = buf_libthpos_chk-gds.max-rate
        v-in-code = buf_libthpos_chk-gds.in-code
        v-cash-parts = buf_libthpos_chk-gds.cash-parts
        v-node-code = buf_libthpos_chk-gds.node-code
        v-root-node-code = buf_libthpos_chk-gds.root-node-code
        v-prt-root  = buf_libthpos_chk-gds.prt-root
        v-empty-scale = buf_libthpos_chk-gds.empty-scale
        v-chk-name = buf_libthpos_chk-gds.chk-name
        v-second-name = buf_libthpos_chk-gds.second-name
        v-is-weight-pbc = buf_libthpos_chk-gds.is-weight-pbc
        v-is-pgweight-pbc = buf_libthpos_chk-gds.is-pgweight-pbc
        v-doc-qnty = buf_libthpos_CHK-GDS.will-doc-qnty
        v-cli-base-rate = buf_libthpos_chk-gds.cli-base-rate
        v-free-price = buf_libthpos_chk-gds.free-price
        v-sum-grp-code = buf_libthpos_chk-gds.sum-grp-code
        v-line-direction = buf_libthpos_chk-gds.line-direction
        .
        if v-is-weight-pbc
        and p-mode = {&update}
        and p-src-qnty <> buf_chk-gds.src-qnty
        then do:
          v-err-mess = substitute("Нельзя поменять количество по коду &1, код = весовой, количество ЗАШИТО в коде").
          undo main-block, retry main-block.
        end.
        if v-is-pgweight-pbc
        and p-mode = {&update}
        and p-src-qnty <> buf_chk-gds.src-qnty
        then do:
          v-err-mess = substitute("Нельзя поменять количество по коду &1, код = штучный для весов, количество ЗАШИТО в коде").
          undo main-block, retry main-block.
        end.

      end.
    end case.
    { str/libchkvl_petrol-valid.i
    libthpos_chk-context.chk-type
    p-line-num
    libthpos_context.obj-type
    libthpos_context.obj-code
    libthpos_context.pos-type
    p-src-code
    v-gds-code
    v-unit-base-type
    p-pump
    p-nozzle-code
      v-valid
      v-mess
      v-chr-err
      no-error
    }
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                              , (if error-status:error
                                  then substitute("Ошибка при проверке топливного товара")
                                  else v-mess)
                              , {&new-line}).
      undo main-block, retry main-block.
    end.

    if LOOKUP( {&serial}, v-unit-base-type ) > 0
    OR lookup({&twounit}, v-unit-base-type) > 0
    OR lookup({&altunit}, v-unit-base-type) > 0 then do:
      { str/libchkvl_unit-type-qnty.i
      libthpos_chk-context.chk-type
      p-line-num
      v-unit-base-type
      v-unit-cli-type
      p-src-code
      v-in-code
      p-src-qnty
      v-min-rate
      v-max-rate
      v-valid
      v-mess
      v-chr-err
      no-error
      }
      if error-status:error or
      not v-valid then do:
        v-err-mess = substitute("&1&2&3"
                                , (if error-status:error
                                    then substitute("Ошибка при проверке товара согласно типу ед.изм")
                                    else v-mess)
                                , {&new-line}).
        undo main-block, retry main-block.
      end.
    end.


    { str/libchkvl_part-valid.i
    libthpos_chk-context.chk-type
    p-line-num
    v-unit-base-type
    v-unit-cli-type
    p-src-code
    v-in-code
    v-part-code
    v-cash-parts
    p-src-qnty
    v-valid
    v-mess
    v-chr-err
    no-error
    }
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                                , (if error-status:error
                                    then substitute("Ошибка при проверке возможности продажи товара по партиям")
                                    else v-mess)
                                , {&new-line}).
      undo main-block, retry main-block.
    end.
    { str/libchkvl_prt-valid.i
      libthpos_chk-context.chk-type
      p-line-num
      libthpos_context.doc-prt
      p-src-code
      v-empty-scale
      v-root-node-code
      v-node-code
      v-valid
      v-mess
      v-chr-err
      no-error
    }
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                            , (if error-status:error
                                then substitute("Ошибка при проверке возможности продажи товара по признакам")
                                else v-mess)
                            , {&new-line}).
      undo main-block, retry main-block.
    end.
    { str/libchkvl_chk-gds-wro.i
    libthpos_chk-context.chk-type
    p-line-num
    p-src-qnty
    p-write-off-code
    v-valid
    v-mess
    no-error
    }
    if error-status:error or
    not v-valid then do:
      v-err-mess = substitute("&1&2&3"
                              , (if error-status:error
                                  then substitute("Ошибка при проверке валидности кода списания строки &1", p-line-num)
                                  else v-mess)
                              , {&new-line}).
      undo main-block, retry main-block.
    end.
    if p-mode <> {&deletion}
    and not
      ((libthpos_chk-context.chk-type = integer({&rcpt-return})
    or libthpos_chk-context.chk-type = integer({&rcpt-return-write-off})
    or libthpos_chk-context.chk-type = integer({&rcpt-ord-return})
      )
      and not (p-src-price = ? or p-src-price = 0)
      )
      then do:
      /*цену не нахожим если режим удаления или возвратный чек и в данный момент цена задается оператором*/
    define variable v-doc-num as character no-undo .
    if libthpos_context.r-b = {&r-b-base} then do:
      { gbl/bcodeprc.i
        libthpos_context.obj-type
        libthpos_context.obj-code
        v-b-code
        v-main-bar-code
        0
        v-doc-num
        v-sale-price-base
        v-road-tax-base
        v-excise-base
        no-error
      }
    end.
    else do:
      { gbl/bcodeprc.i
        libthpos_context.obj-type
        libthpos_context.obj-code
        v-b-code
        v-main-bar-code
        0
        v-doc-num
        v-sale-price-rubl
        v-road-tax-rubl
        v-excise-rubl
        no-error
      }

    end.
    /*

      run mpl-autoprice in this-procedure (
                                            input  yes /*p-only-b-code */
                                          ,input  libthpos_chk-context.src-cli-type
                                          ,input  libthpos_chk-context.src-cli-code
                                          ,input  v-main-bar-code
                                          ,input  v-b-code
                                          ,input  libthpos_context.obj-type
                                          ,input  libthpos_context.obj-code
                                          ,input  p-src-qnty
                                          ,input  0 /*p-sum-doc     */
                                          ,input  '' /*p-vid-pay        */
                                          ,input  '' /*p-cash-pay-type  */
                                          ,input  ? /*p-fact-order  */
                                          ,output v-plt-id
                                          ,output v-plt-db-num
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num
                                          ,output v-sale-price-base
                                          ,output v-sale-price-rubl
                                          ,output v-road-tax-base
                                          ,output v-road-tax-rubl
                                          ,output v-excise-base
                                          ,output v-excise-rubl   ) no-error.
      */
      if error-status:error then do:
        v-err-mess = substitute("Не удалось получить цену для кода &1&2&3&2&4"
                                                , p-src-code
                                                , {&new-line}
                                                , error-status:get-message(1)
                                                , return-value ).
        undo main-block, retry main-block.
      end.
      if (v-sale-price-base = ?
      or v-sale-price-rubl = ?)
      then do:
        v-err-mess = substitute("Не определена цена для кода &1&2&3&2&4"
                                                , p-src-code
                                                , {&new-line}
                                                , error-status:get-message(1)
                                                , return-value ).
        undo main-block, retry main-block.
      end.
      /*так же надо проверить на in-ov*/
      if p-mode = {&add-def} then
      do:
        if lookup(string(libthpos_chk-context.chk-type), {&sale-out-receipt-codes}) > 0
        or lookup(string(libthpos_chk-context.chk-type), {&rcpt-pre-sale} + {&comma-char} +
                                    {&rcpt-pre-write-off}) > 0
        or lookup(string(libthpos_chk-context.chk-type), {&rcpt-ord-sale}) > 0
        then do:
         { gbl/gdsobjat.i
          {&shop}
          libthpos_context.obj-code
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          'in-ov=request'
          v-in-ov
          no-error
         }
         if error-status:error then do:
          v-err-mess = substitute("Ошибка при определении свойства <Требует переоценки> для кода &1&2&3&2&4"
                                                  , p-src-code
                                                  , {&new-line}
                                                  , error-status:get-message(1)
                                                  , return-value ).
          undo main-block, retry main-block.
         end.
         if v-in-ov then do:
          v-err-mess = substitute("Товар по коду &1 требует переоценки - продажа запрещена"
                                                  , p-src-code
                                                  ).
          undo main-block, retry main-block.
         end.
        end.

      end.
    end.
    else do:
      if p-mode = {&deletion} then do:
        assign
        p-src-price = buf_libthpos_chk-gds.src-price
        p-src-price = buf_libthpos_chk-gds.src-price-rubl
        .
      end.
      else do:
        assign
        v-sale-price-r-b = p-src-price
        v-sale-price-rubl = (if libthpos_context.r-b = {&r-b-rubl}
                            then p-src-price
                            else p-src-price * libthpos_chk-context.base-rate)
        v-sale-price-base = (if libthpos_context.r-b = {&r-b-base}
                            then p-src-price
                            else p-src-price / libthpos_chk-context.base-rate)
        .
      end.
    end.
    assign
    v-sale-price-r-b = (if libthpos_context.r-b = {&r-b-rubl}
                        then v-sale-price-rubl
                        else v-sale-price-base
                        )
    v-depart-type = {&shop}
    v-depart-code = p-depart-id
    .
    if p-mode <> {&add-def}
    and libthpos_chk-context.direction > 0
    then do:
      if p-mode = {&update}
      and buf_libthpos_chk-gds.manual-discnt-sum >= buf_libthpos_chk-gds.src-price * p-src-qnty
      and buf_libthpos_chk-gds.manual-discnt-sum > 0
      then do:
        v-err-mess = substitute("Нельзя изменить строку &1 чека &2 - ручная скидка по строке (&3) превысит сумму строки (&4)"
                                              , p-line-num
                                              , p-doc-code
                                              , buf_libthpos_chk-gds.manual-discnt-sum
                                              , buf_libthpos_chk-gds.src-price * p-src-qnty
                                              ).
        undo main-block, retry main-block.
      end.
      if (libthpos_chk-context.manual-discnt-sum  - (if p-mode = {&deletion} then buf_libthpos_chk-gds.manual-discnt-sum else 0)) > 0
      and (libthpos_chk-context.manual-discnt-sum - (if p-mode = {&deletion} then buf_libthpos_chk-gds.manual-discnt-sum else 0))
       >= (libthpos_chk-context.src-tot-doc - buf_libthpos_chk-gds.src-sum +
          buf_libthpos_chk-gds.src-price * p-src-qnty) + (if p-mode = {&deletion} then buf_libthpos_chk-gds.manual-discnt-sum else 0)
      then do:
        v-err-mess = substitute("Нельзя удалить/изменить строку &1 чека &2 - общая ручная скидка по чеку (&3) превысит сумму чека (&4)"
                                              ,p-line-num
                                              ,p-doc-code
                                              ,libthpos_chk-context.manual-discnt-sum
                                              ,libthpos_chk-context.src-tot-doc - buf_libthpos_chk-gds.src-sum + buf_libthpos_chk-gds.src-price * p-src-qnty
                                              ).
        undo main-block, retry main-block.
      end.
    end.
    if p-mode <> {&deletion} then do:
      { str/libchkvl_fbr-valid.i
      libthpos_chk-context.chk-type
      p-line-num
      libthpos_context.obj-type
      libthpos_context.obj-code
      libthpos_context.is-catering
      libthpos_context.pos-type
      p-src-code
      v-gds-code
      v-sale-price-r-b
      v-src-discnt
      p-write-off-code
      v-depart-type
      v-depart-code
      v-is-null-price
      v-valid
      v-mess
      v-chr-err
        no-error
      }
      if error-status:error or
      not v-valid then do:
        v-err-mess = substitute("&1&2&3"
                              , (if error-status:error
                                  then substitute("Ошибка при проверке возможности продажи товара")
                                  else v-mess)
                              , {&new-line}).
        undo main-block, retry main-block.
      end.
    end.
    if p-mode <> {&add-def} then do:
      /*удалим все скидки по данному товару и вновь рассчитаем*/
      _chk-discnt-gds:
      for each buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
          and buf_chk-discnt.line-num = p-line-num
          and buf_chk-discnt.record-type = 0
          and buf_chk-discnt.object-line-num = p-line-num
          and buf_chk-discnt.line-type = integer({&discnt-gds}),
          first buf_libthpos_chk-discnt where
                buf_libthpos_chk-discnt.doc-code = p-doc-code
          and buf_libthpos_chk-discnt.line-num = p-line-num
          and buf_libthpos_chk-discnt.record-type = 0
          and buf_libthpos_chk-discnt.object-line-num = p-line-num
          and buf_libthpos_chk-discnt.discnt-id = buf_chk-discnt.discnt-id
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        if buf_libthpos_chk-discnt.discnt-type = integer({&discnt-t-manual}) then next _chk-discnt-gds.
        delete buf_chk-discnt.
        delete buf_libthpos_chk-discnt.
      end.
      buf_libthpos_chk-gds.without-gds-discnt = 0.
    end.
    if p-mode = {&add-def} then do:
      create buf_chk-gds.
      create buf_libthpos_chk-gds.
      assign
      buf_chk-gds.doc-code = p-doc-code
      libthpos_chk-context.lng = libthpos_chk-context.lng + 1
      libthpos_chk-context.recalc-gline-num = libthpos_chk-context.lng + 1
      buf_chk-gds.line-num = libthpos_chk-context.lng
      buf_libthpos_chk-gds.recalc-line-num = buf_chk-gds.line-num
      buf_chk-gds.grp-code = 0
      buf_chk-gds.chk-date = libthpos_chk-doc.chk-date
      buf_chk-gds.b-code = v-b-code
      buf_chk-gds.src-code = p-src-code
      buf_chk-gds.sales-man  = libthpos_chk-context.sales-man
      buf_chk-gds.salesman-psn-code = libthpos_chk-context.salesman-psn-code
      buf_chk-gds.src-sum   = 0
      buf_libthpos_chk-gds.src-sum-rubl   = 0
      buf_chk-gds.src-qnty = 0
      buf_chk-gds.src-discnt = 0
      buf_chk-gds.src-price = 0
      buf_libthpos_chk-gds.src-price-rubl = 0
      buf_chk-gds.doc-qnty = 0
      buf_chk-gds.price-service = 0
      buf_chk-gds.pass-gds = 0
      buf_chk-gds.is-error = no
      buf_chk-gds.pump   = 0
      buf_chk-gds.nozzle = 0
      buf_chk-gds.loc1 = ''
      buf_chk-gds.src-pl-code = 0
      buf_chk-gds.line-type  = ''
      buf_chk-gds.src-d-card = libthpos_chk-context.src-d-card
      buf_chk-gds.src-d-mask = libthpos_chk-context.src-d-mask
      buf_chk-gds.src-cli-type = libthpos_chk-context.src-cli-type
      buf_chk-gds.src-cli-code = libthpos_chk-context.src-cli-code
      buf_chk-gds.depart-id = 0
      .
    end.
    assign
    /*сначала убавим кол-во*/
    libthpos_chk-context.src-qnty = libthpos_chk-context.src-qnty - buf_chk-gds.src-qnty
    libthpos_chk-context.src-tot-doc = libthpos_chk-context.src-tot-doc - buf_chk-gds.src-sum
    /*надо вычесть из общего нетто - нетто товарное - сскидка на итог - скидка на оплаты*/
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    /*надо вычесть из товарного нетто*/
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    /*надо вычесть из нетто-товарное - скидка на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    /*надо вычесть скидку из товарной скидки*/
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt - buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-gds.src-discnt-sum
    /*надо вычесть дельту  из товарной дельты*/
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r - buf_libthpos_chk-gds.r-sum
    .
    /*а теперь новые выставим*/
    assign
    buf_chk-gds.src-price = truncate(v-sale-price-r-b, 2)
    buf_libthpos_chk-gds.src-price-rubl = truncate(v-sale-price-rubl, 2)
    buf_chk-gds.src-qnty = p-src-qnty
    buf_chk-gds.pass-gds = p-pass-gds
    buf_chk-gds.pump = p-pump
    buf_chk-gds.nozzle-code = p-nozzle-code
    buf_chk-gds.src-pl-code = p-pl-code
    buf_chk-gds.write-off-code = p-write-off-code
    buf_chk-gds.depart-id = p-depart-id
    buf_chk-gds.doc-qnty = 0
    buf_chk-gds.price-service = 0
    buf_chk-gds.time-oper = v-time
    buf_chk-gds.road-tax = (if libthpos_context.r-b = {&r-b-rubl}
                            then v-road-tax-rubl
                            else v-road-tax-base)
    buf_chk-gds.line-sign = (if libthpos_chk-context.chk-type = integer({&rcpt-sale})
                              then (buf_chk-gds.src-qnty >= 0)
                              else (buf_chk-gds.src-qnty <= 0)
                        )
    buf_chk-gds.src-sum   = truncate(buf_chk-gds.src-price * buf_chk-gds.src-qnty, 2)
    buf_libthpos_chk-gds.src-sum-rubl = truncate(buf_libthpos_chk-gds.src-price-rubl * buf_chk-gds.src-qnty, 2)
    buf_chk-gds.src-discnt = 0
    buf_libthpos_chk-gds.src-discnt = 0
    buf_libthpos_chk-gds.src-discnt-rubl = 0
    buf_libthpos_chk-gds.src-discnt-sum = 0
    buf_libthpos_chk-gds.src-discnt-sum-rubl = 0
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price
    buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * v-cli-base-rate
    buf_libthpos_chk-gds.will-doc-qnty = p-src-qnty * v-cli-base-rate
    .
    if libthpos_chk-context.chk-type = integer({&rcpt-tech-refuell}) then do:
      assign
      buf_chk-gds.write-off-code =  integer({&wro-r-tech-refuell})
      .
    end.
    else  do:
      assign
      buf_chk-gds.write-off-code = (if v-no-add-price
                                    then (if lookup(string(libthpos_chk-context.chk-type), {&sale-out-receipt-codes}) > 0
                                        then integer({&wro-without-payment})
                                        else integer({&wro-cancell-item})
                                      )
                                      else 0
                                    )
      .
    end.
    buffer-copy buf_chk-gds to buf_libthpos_chk-gds.
    if p-mode = {&add-def} then do:
      assign
      buf_libthpos_chk-gds.start-src-price = truncate(v-sale-price-r-b, 2)
      buf_libthpos_chk-gds.src-price-netto = buf_chk-gds.src-price
      buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * v-cli-base-rate
      buf_libthpos_chk-gds.will-price-base  = buf_libthpos_chk-gds.start-src-price * v-cli-base-rate
      buf_libthpos_chk-gds.main-bar-code = v-main-bar-code
      buf_libthpos_chk-gds.gds-code = v-gds-code
      buf_libthpos_Chk-gds.unit-base  = v-unit-base
      buf_libthpos_chk-gds.unit-cli   = v-unit-cli
      buf_libthpos_chk-gds.unit-base-type        = v-unit-base-type
      buf_libthpos_chk-gds.unit-cli-type    = v-unit-cli-type
      buf_libthpos_chk-gds.min-rate = v-min-rate
      buf_libthpos_chk-gds.max-rate = v-max-rate
      buf_libthpos_chk-gds.in-code  = v-in-code
      buf_libthpos_chk-gds.part-code  = v-part-code
      buf_libthpos_chk-gds.cash-parts  = v-cash-parts
      buf_libthpos_chk-gds.node-code = v-node-code
      buf_libthpos_chk-gds.root-node-code = root_gds-prt.node-code
      buf_libthpos_chk-gds.prt-root = buf_goods.prt-root
      buf_libthpos_chk-gds.empty-scale = v-empty-scale
      buf_libthpos_chk-gds.chk-name = v-chk-name
      buf_libthpos_chk-gds.second-name =   v-second-name
      buf_libthpos_chk-gds.is-weight-pbc = v-is-weight-pbc
      buf_libthpos_chk-gds.is-pgweight-pbc = v-is-pgweight-pbc
      buf_libthpos_chk-gds.will-doc-qnty = v-doc-qnty
      buf_libthpos_chk-gds.cli-base-rate = v-cli-base-rate
      buf_libthpos_chk-gds.sum-grp-code = v-sum-grp-code
      buf_libthpos_chk-gds.free-price = v-free-price
      buf_libthpos_chk-gds.line-direction = v-line-direction
      .
    end.
    assign
    /*добавим в количество*/
    libthpos_chk-context.src-qnty = libthpos_chk-context.src-qnty + buf_libthpos_chk-gds.src-qnty
    /*добавим в сумму брутто*/
    libthpos_chk-context.src-tot-doc = libthpos_chk-context.src-tot-doc + buf_chk-gds.src-sum
    libthpos_chk-context.src-tot-rubl =  (if libthpos_context.r-b = {&r-b-rubl}
                                              or (libthpos_context.r-b = {&r-b-base}
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.src-tot-doc
                                            else libthpos_chk-context.src-tot-doc * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale)
    libthpos_chk-context.src-tot-base =  (if libthpos_context.r-b = {&r-b-base}
                                              or (libthpos_context.r-b = {&r-b-rubl}
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.src-tot-doc
                                            else libthpos_chk-context.src-tot-doc / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale)
    .
    if lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) = 0
    and libthpos_chk-context.direction > 0
    then do:
      /*расчет скидок*/
      /*удельную скидку v-discnt рассчитываем с максимальной точность*/
      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-start-src-price = v-sale-price-r-b
      v-src-price = v-sale-price-r-b
      v-start-src-discnt = 0
      v-src-discnt = 0
      .
      assign
      v-bh[{&context}] = (buffer libthpos_context:handle)
      v-bh[{&chk-gds}] = (buffer buf_libthpos_chk-gds:handle)
      v-bh[{&chk-pay}] = (buffer libthpos_chk-pay:handle)
      v-bh[{&chk-discnt}] = (buffer libthpos_chk-discnt:handle)
      .
      for each buf_libthpos_rp-by-call
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        run rs_15_1 in buf_libthpos_rp-by-call.rph (
                  input '':U /*p-caller*/
                ,input p-line-num
                ,input v-b-code
                ,input v-gds-code
                ,input v-sum-grp-code
                ,input v-node-code
                ,input p-src-qnty
                ,input v-doc-qnty
                ,input v-start-src-price
                ,input v-src-price
                ,input v-start-src-discnt
                ,input v-src-discnt
                ,input v-unit-base
                ,input v-unit-base-type
                ,input v-unit-cli
                ,input v-unit-cli-type
                ,input v-bh
                ,output v-new-src-price
                ,output v-new-src-discnt
                    ) no-error.
        if not error-status :error then do:
          assign
          v-src-price = v-new-src-price
          v-src-discnt = v-new-src-discnt
          .
        end.
        else do:
          message
          error-status:get-message(1)
          return-value view-as alert-box .
        end.
      end.
      assign
      v-discnt = v-new-src-discnt
      .
    end.
    if buf_libthpos_chk-gds.manual-discnt-id > 0
    then do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = p-line-num
        and  buf_libthpos_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = p-line-num
        and  buf_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id:
        leave.
      end.
      if p-mode = {&deletion} then do:
        v-m-discnt = 0.
        libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-gds.manual-discnt-sum.
      end.
      else do:
        case buf_libthpos_chk-discnt.value-type:
          when integer({&discnt-v-pcnt}) then do:
            assign
            /*нетто-цена для расчета ручной скидки стартовая - автоскидка */
            buf_libthpos_chk-discnt.src-price-netto = buf_libthpos_chk-gds.src-price - v-discnt
            v-m-discnt = buf_libthpos_chk-discnt.src-price-netto * buf_libthpos_chk-discnt.discnt-value-pcnt / 100
            buf_libthpos_chk-discnt.object-sum = buf_libthpos_chk-discnt.src-price-netto * buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.object-qnty = buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.discnt-value-abs = buf_libthpos_chk-gds.src-qnty * v-m-discnt
            libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-gds.manual-discnt-sum
            buf_libthpos_chk-gds.manual-discnt-sum = buf_libthpos_chk-discnt.discnt-value-abs
            libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-gds.manual-discnt-sum
            .
          end.
          when integer({&discnt-v-sum}) then do:
            assign
            /*нетто-цена для расчета ручной скидки стартовая - автоскидка */
            buf_libthpos_chk-discnt.src-price-netto = buf_libthpos_chk-gds.src-price - v-discnt
            v-m-discnt = buf_libthpos_chk-discnt.discnt-value-abs / buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.object-sum = buf_libthpos_chk-discnt.src-price-netto * buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.object-qnty = buf_libthpos_chk-gds.src-qnty
            buf_libthpos_chk-discnt.discnt-value-pcnt = v-m-discnt / buf_libthpos_chk-discnt.src-price-netto * 100
            .
          end.
        end case.
        buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
      end.
      v-discnt = v-discnt + v-m-discnt.
      if p-mode = {&deletion} then do:
        delete buf_libthpos_chk-discnt.
        delete buf_chk-discnt.
      end.
    end.
    /*а теперь выставим значения зависящие от скидки*/
    assign
    buf_chk-gds.src-discnt = truncate(v-discnt, 2)
    buf_libthpos_chk-gds.src-discnt = truncate(v-discnt, 2)
    /*нетто-цена = стартовая - ПОЛНАЯ скидка (авто и ручная)*/
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price - buf_libthpos_chk-gds.src-discnt
    buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * v-cli-base-rate
    buf_libthpos_chk-gds.will-price-base  = buf_libthpos_chk-gds.start-src-price * v-cli-base-rate
    buf_libthpos_chk-gds.src-discnt-rubl = (if libthpos_context.r-b = {&r-b-rubl}
                                            then buf_libthpos_chk-gds.src-discnt
                                            else truncate(v-discnt * libthpos_chk-context.base-rate, 2 ))
    .
    assign
    buf_libthpos_chk-gds.src-discnt-sum = truncate(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-discnt, 2)
    buf_libthpos_chk-gds.src-discnt-sum-rubl = truncate(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-discnt-rubl, 2)
    buf_libthpos_chk-gds.r-sum = (buf_libthpos_chk-gds.src-qnty * (v-sale-price-r-b - v-discnt)) -
                                (buf_libthpos_chk-gds.src-sum -  buf_libthpos_chk-gds.src-discnt-sum)
    /*добавим в общее нетто*/
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (p-write-off-code = ?
                                          or p-write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    /*добавим в товарное нетто*/
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (p-write-off-code = ?
                                          or p-write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    /*добавим в нетто с учетом скидок на товар и на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (p-write-off-code = ?
                                          or p-write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    /*добавим в товарные скидки*/
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt + buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-gds.src-discnt-sum
    /*добавим в товарные дельты*/
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r + buf_libthpos_chk-gds.r-sum
    libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-start}
                                then {&step-gds}
                                else libthpos_chk-context.step
    .
    if buf_chk-gds.src-sum <= buf_libthpos_chk-gds.src-discnt-sum
    and libthpos_chk-context.direction > 0
    and buf_libthpos_chk-gds.src-discnt-sum > 0
    and p-mode <> {&deletion}
    then do:
      v-err-mess = substitute("Нельзя удалить/изменить строку &1 чека &2 - общая скидка по строке (&3) превысит сумму строки брутто (&4)"
                                              ,p-line-num
                                              ,p-doc-code
                                              ,buf_libthpos_chk-gds.src-discnt-sum
                                              ,buf_chk-gds.src-sum
                                              ).
      undo main-block, retry main-block.
    end.
    if p-mode = {&deletion}
    and buf_chk-gds.src-qnty = 0 then do:
      define variable v-recalc-line-num as integer no-undo .
      v-recalc-line-num = buf_libthpos_chk-gds.recalc-line-num.
      delete buf_chk-gds.
      delete buf_libthpos_chk-gds.
      find last buf2_libthpos_chk-gds where
              buf2_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code use-index ln no-error.

      assign
      libthpos_chk-context.lng = (if available buf2_libthpos_chk-gds
                                then buf2_libthpos_chk-gds.line-num
                                else 0)
      libthpos_chk-context.recalc-gline-num = (if v-recalc-line-num = p-line-num
                                                then libthpos_chk-context.lng + 1
                                                else v-recalc-line-num)
      .
      if libthpos_chk-context.lng = 0 then do:
        libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-gds}
                                    then {&step-start}
                                    else libthpos_chk-context.step.
      end.
      assign
      p-setted = yes
      p-next = (if (libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
                or libthpos_chk-context.step >  {&step-gds})
                  and not v-is-recalc
                  then substitute("recalc=&1,&2,&3"
                                  ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                                  ,(if libthpos_chk-context.step > {&step-gds} or p-mode = {&deletion} then 1 else 0)
                                  ,(if libthpos_chk-context.step > {&step-subtotal} or p-mode = {&deletion} then 1 else 0)
                                )
                  else "")
      .
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    end.
    else do:
      assign
      p-b-code = v-b-code
      p-gds-code = v-gds-code
      p-second-name = v-second-name
      p-src-price = buf_chk-gds.src-price
      p-src-price-rubl = buf_libthpos_chk-gds.src-price-rubl
      p-src-discnt-sum = buf_libthpos_chk-gds.src-discnt-sum
      p-src-discnt-sum-rubl = buf_libthpos_chk-gds.src-discnt-sum-rubl
      p-src-sum = buf_chk-gds.src-sum
      p-src-sum-rubl = buf_libthpos_chk-gds.src-sum-rubl
      p-src-sum-netto = p-src-sum - p-src-discnt-sum
      p-src-sum-netto-rubl = p-src-sum-rubl - p-src-discnt-sum-rubl
      p-unit-base = buf_libthpos_chk-gds.unit-base                           /* 12345 */
      p-setted = yes
      p-next = (if (libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
                or libthpos_chk-context.step >  {&step-gds})
                  and not v-is-recalc
                  then substitute("recalc=&1,&2,&3"
                                  ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                                  ,(if libthpos_chk-context.step > {&step-gds} or p-mode = {&deletion} then 1 else 0)
                                  ,(if libthpos_chk-context.step > {&step-subtotal} or p-mode = {&deletion} then 1 else 0)
                                )
                  else "")
      .
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
      run printbuffer in this-procedure ( input (buffer buf_chk-gds:handle)).
      run printbuffer in this-procedure ( input (buffer buf_libthpos_chk-gds:handle)).
    end.
    if v-accept-changes then do:
      dataset libthpos_receipt:accept-changes.
    end.
  end. /*ne retry*/
end.

end procedure. /* libthpos_gds-line */


procedure libthpos_sub-total :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-mode as character no-undo .
define output parameter p-setted as logical   no-undo .
define input-output parameter p-st-r-b as decimal no-undo .
define input-output parameter p-st-rubl as decimal no-undo .
define input-output parameter p-st-base as decimal no-undo .
define input-output parameter p-tot-doc as decimal no-undo .
define input-output parameter p-st-discnt as decimal no-undo .

define output parameter p-netto as decimal no-undo .
define output parameter p-netto-rubl as decimal no-undo .
define output parameter p-netto-base as decimal no-undo .
define output parameter p-all-discnt as decimal no-undo .
define output parameter p-all-discnt-rubl as decimal no-undo .
define output parameter p-all-discnt-base as decimal no-undo .


define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-base-rate as decimal no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-cash-scale as integer no-undo .
define variable v-tot-r-b as decimal no-undo .
define variable v-tot-discnt as decimal no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_chk-discnt for ub.chk-discnt.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not (p-mode = ''
            or
            p-mode = "no-changes") then do:
      v-err-mess = substitute("Неверное действие над подитогом чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    /*повторно посчитаем курсы*/
    assign
    v-base-rate = 1
    v-cash-rate = 1
    v-cash-scale = 1
    v-bank-rate = 1
    v-bank-scale = 1
    .
    if libthpos_context.r-b = {&r-b-base}
    and libthpos_context.base-code <> 0 then do:
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = libthpos_context.obj-type
                AND buf_curr-shop.obj-code = libthpos_context.obj-code
                AND buf_curr-shop.curr-code = libthpos_context.base-code
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-cash-rate = buf_curr-shop.exch-rate
        v-cash-scale = buf_curr-shop.exch-scale
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , {&shop}
                                      , libthpos_context.obj-code
                                      , v-today
                                    ).
        undo main-block, retry main-block.
      end.
      if v-today <> libthpos_chk-context.chk-date then do:
        { gbl/exchrate.i libthpos_context.base-code v-today v-bank-rate v-bank-scale v-bank-abbr }
      end.
      else do:
        assign
        v-bank-rate = libthpos_chk-context.bank-rate
        v-bank-scale = libthpos_chk-context.bank-scale
        .
      end.
    end.
    if libthpos_context.r-b = {&r-b-rubl}
    and libthpos_context.base-code <> 0
    then do:
      FIND LAST buf_curr-shop NO-LOCK WHERE
                buf_curr-shop.obj-type = libthpos_context.obj-type
            AND buf_curr-shop.obj-code = libthpos_context.obj-code
            AND buf_curr-shop.curr-code = libthpos_context.base-code
            AND ( ( buf_curr-shop.exch-date = v-today
                    AND
                    buf_curr-shop.exch-time <= v-time ) OR
                    buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-base-rate = buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
        .
      end.
      else do:
        v-err-mess = substitute(
                                      "Нет магазинного курса базовой валюты для &1&2 на дату &3"
                                      , {&shop}
                                      , libthpos_context.obj-code
                                      , v-today
                                    ).

        undo main-block, retry main-block.
      end.
      if libthpos_chk-context.chk-date <> v-today then do:
        { gbl/exchrate.i libthpos_context.base-code v-today v-bank-rate v-bank-scale v-bank-abbr }
      end.
      else do:
        assign
        v-bank-rate = libthpos_chk-context.bank-rate
        v-bank-scale = libthpos_chk-context.bank-scale
        .
      end.
    end.
    assign
    libthpos_chk-context.a-chk-date = v-today
    libthpos_chk-context.a-chk-time = v-time
    libthpos_chk-context.a-base-rate = v-base-rate
    libthpos_chk-context.a-cash-rate = v-cash-rate
    libthpos_chk-context.a-cash-scale = v-cash-scale
    libthpos_chk-context.a-bank-rate = v-bank-rate
    libthpos_chk-context.a-bank-scale = v-bank-scale
    .
    /*сначала вернем взад*/
    assign
    /*добавим к нетто-товар  итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + libthpos_chk-context.tot-discnt
    /*добавим к общему нетто*/
    libthpos_chk-context.netto = libthpos_chk-context.netto + libthpos_chk-context.tot-discnt
    .
    /*расчет скидок на итог - v-tot-discnt*/
    define variable v-start-sum-brutto-r-b as decimal no-undo .
    define variable v-sum-brutto-r-b as decimal no-undo .
    define variable v-st-discnt-r-b as decimal no-undo .
    define variable v-st-r-b as decimal no-undo .
    define variable v-new-st-discnt-r-b as decimal no-undo .
    define variable v-sum-for-discnt-r-b as decimal no-undo .
    define variable v-new-sum-for-discnt-r-b as decimal no-undo .


    assign
    v-start-sum-brutto-r-b = libthpos_chk-context.sub-netto
    v-sum-brutto-r-b = libthpos_chk-context.sub-netto
    libthpos_chk-context.st-for-discnt-r-b = libthpos_chk-context.sub-netto
    v-sum-for-discnt-r-b = libthpos_chk-context.st-for-discnt-r-b
    v-st-discnt-r-b = 0.0
    v-new-st-discnt-r-b = 0.0
    v-new-sum-for-discnt-r-b = 0.0
    .
    assign
    v-bh[{&chk-context}] = buffer libthpos_chk-context:handle
    v-bh[{&chk-gds}] = buffer libthpos_chk-gds:handle
    v-bh[{&context}] = buffer libthpos_context:handle
    v-bh[{&chk-pay}] = buffer libthpos_chk-pay:handle
    .
    if lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) = 0
    and libthpos_chk-context.direction > 0
    then do:
      /*сначала удалим имеющиеся*/
      _chk-discnt:
      for each buf_libthpos_chk-discnt share-lock where
              buf_libthpos_chk-discnt.line-type = integer({&discnt-sub-total})
              or
              buf_libthpos_chk-discnt.line-type = integer({&discnt-gds-without-discnt})
              ,
          first buf_chk-discnt where
                buf_chk-discnt.doc-code = p-doc-code
          and buf_chk-discnt.line-num = buf_libthpos_chk-discnt.line-num
          and buf_chk-discnt.record-type = buf_libthpos_chk-discnt.record-type
          and buf_chk-discnt.discnt-id = buf_libthpos_chk-discnt.discnt-id
          and buf_chk-discnt.object-line-num = buf_libthpos_chk-discnt.object-line-num
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        if buf_libthpos_chk-discnt.discnt-type = integer({&discnt-t-manual}) then do:
          next _chk-discnt.
        end.
        delete buf_chk-discnt.
        delete buf_libthpos_chk-discnt.
      end.
      /*расчет скидок*/
      /*удельную скидку v-discnt рассчитываем с максимальной точность*/
      run cur-time in this-procedure ( output libthpos_chk-context.current-date, output libthpos_chk-context.current-time).

      for each buf_libthpos_rp-by-call
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :


      run rs_16_1 in buf_libthpos_rp-by-call.rph (
                  input '':U /*p-caller*/
                ,input libthpos_chk-context.lng
                ,input v-start-sum-brutto-r-b
                ,input v-sum-brutto-r-b
                ,input v-sum-for-discnt-r-b
                ,input v-st-discnt-r-b
                ,input v-bh
                ,output v-st-r-b
                ,output v-new-st-discnt-r-b
                ,output v-new-sum-for-discnt-r-b

                    ) no-error.

        if not error-status :error then do:
          assign
          v-sum-brutto-r-b = v-st-r-b
          v-st-discnt-r-b = v-new-st-discnt-r-b
          v-sum-for-discnt-r-b = v-new-sum-for-discnt-r-b
          .
        end.
      end.
      assign
      v-tot-discnt = v-new-st-discnt-r-b
      .
    end.
    if libthpos_chk-context.manual-discnt-id <> 0 then do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id:
        assign
        libthpos_chk-context.manual-tot-discnt = libthpos_chk-context.manual-tot-discnt - buf_libthpos_chk-discnt.discnt-value-abs
        libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-discnt.discnt-value-abs
        libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt - buf_libthpos_chk-discnt.discnt-value-abs
        libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-discnt.discnt-value-abs
        .
        leave.
      end. /*for first buf_libthpos_chk-discnt where*/
      case buf_libthpos_chk-discnt.value-type:
        when integer({&discnt-v-pcnt}) then do:
          assign
          buf_libthpos_chk-discnt.discnt-value-abs = libthpos_chk-context.st-for-discnt-r-b *  buf_libthpos_chk-discnt.discnt-value-pcnt / 100
          buf_libthpos_chk-discnt.object-sum  = libthpos_chk-context.st-for-discnt-r-b
          buf_libthpos_chk-discnt.object-qnty = libthpos_chk-context.src-qnty
          .
        end.
        when integer({&discnt-v-sum}) then do:
          assign
          buf_libthpos_chk-discnt.discnt-value-pcnt = buf_libthpos_chk-discnt.discnt-value-abs / libthpos_chk-context.st-for-discnt-r-b * 100
          buf_libthpos_chk-discnt.object-sum  = libthpos_chk-context.st-for-discnt-r-b
          buf_libthpos_chk-discnt.object-qnty = libthpos_chk-context.src-qnty
          .
        end.
      end case.
      buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
      assign
      libthpos_chk-context.manual-tot-discnt = libthpos_chk-context.manual-tot-discnt + buf_libthpos_chk-discnt.discnt-value-abs
      libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-discnt.discnt-value-abs
      libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt + buf_libthpos_chk-discnt.discnt-value-abs
      libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-discnt.discnt-value-abs
      .
    end. /*if libthpos_chk-context.manual-discnt-id <> 0 then do:*/
    assign
    libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-gds}
                                then {&step-subtotal}
                                else libthpos_chk-context.step
    libthpos_chk-context.tot-discnt = libthpos_chk-context.manual-tot-discnt + v-tot-discnt
    /*дельта */
    libthpos_chk-context.tot-r = v-tot-discnt - (libthpos_chk-context.tot-discnt - libthpos_chk-context.manual-tot-discnt )
    /*нетоо товарное с учетом скидки на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto - libthpos_chk-context.tot-discnt
    libthpos_chk-context.st-for-discnt-r-b = libthpos_chk-context.st-for-discnt-r-b - libthpos_chk-context.tot-discnt
    libthpos_chk-context.netto = libthpos_rmethod(libthpos_context.rmethod-type
                                                , libthpos_context.rmethod-coeff
                                                ,libthpos_chk-context.netto - libthpos_chk-context.tot-discnt)
    libthpos_chk-context.st-r-b = libthpos_rmethod(libthpos_context.rmethod-type
                                                    , libthpos_context.rmethod-coeff
                                                    , libthpos_chk-context.sub-netto)
    p-st-r-b = libthpos_chk-context.st-r-b
    libthpos_chk-context.st-rubl =  (if libthpos_context.r-b = {&r-b-rubl}
                                    or (libthpos_context.r-b = {&r-b-base}
                                        and
                                        libthpos_context.base-code = 0)
                                      then libthpos_chk-context.st-r-b
                                      else libthpos_chk-context.st-r-b * libthpos_chk-context.a-base-rate)
    p-st-rubl = libthpos_chk-context.st-rubl
    libthpos_chk-context.st-base = (if libthpos_context.r-b = {&r-b-base}
                                    or (libthpos_context.r-b = {&r-b-rubl}
                                        and
                                        libthpos_context.base-code = 0)
                                    then libthpos_chk-context.st-r-b
                                    else libthpos_chk-context.st-r-b / libthpos_chk-context.a-base-rate)
    libthpos_chk-context.to-pay-r-b   = libthpos_chk-context.st-r-b - libthpos_chk-context.has-pay-r-b - libthpos_chk-context.pay-discnt
    libthpos_chk-context.to-pay-rubl  = (if libthpos_context.r-b = {&r-b-rubl}
                                            or (libthpos_context.r-b = {&r-b-base}
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale)
                                            - libthpos_chk-context.has-pay-rubl - libthpos_chk-context.pay-discnt-rubl
    libthpos_chk-context.all-pay-rubl =  libthpos_chk-context.st-rubl - libthpos_chk-context.pay-discnt-rubl
    libthpos_chk-context.to-pay-base  = (if libthpos_context.r-b = {&r-b-base}
                                            or (libthpos_context.r-b = {&r-b-rubl}
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale)
                                        - libthpos_chk-context.has-pay-base - libthpos_chk-context.pay-discnt-base
    libthpos_chk-context.all-pay-base =  libthpos_chk-context.st-base - libthpos_chk-context.pay-discnt-base
    p-st-base = libthpos_chk-context.st-base
    p-tot-doc = libthpos_chk-context.src-tot-doc
    libthpos_chk-context.tot-r = libthpos_chk-context.sub-netto - libthpos_chk-context.st-r-b
    p-st-discnt  = libthpos_chk-context.gds-discnt + libthpos_chk-context.tot-discnt

    p-netto = libthpos_chk-context.netto
    p-netto-rubl = libthpos_chk-context.all-pay-rubl
    p-netto-base = libthpos_chk-context.all-pay-base
    p-all-discnt = libthpos_chk-context.src-tot-doc - libthpos_chk-context.netto
    p-all-discnt-rubl = libthpos_chk-context.src-tot-rubl - libthpos_chk-context.all-pay-rubl
    p-all-discnt-base = libthpos_chk-context.src-tot-base - libthpos_chk-context.all-pay-base
    p-setted = yes
    .
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc
    and libthpos_chk-context.direction > 0
    then do:
      v-err-mess = substitute("Недопустимая величина скидки для чека &1, общая скидка по чеку (&1) больше товарной суммы (&2) Возможно не стоит применять ручную скидку"
                              , libthpos_chk-context.discnt
                              , libthpos_chk-context.src-tot-doc
                              ).
      undo main-block, retry main-block.
    end.

    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    if p-mode <> "no-changes" then do:
      dataset libthpos_receipt:accept-changes.
    end.
    /*
    message "на выходе из sub-total"
    "p-st-base " p-st-base skip
    "p-tot-doc " p-tot-doc skip
    "p-st-discnt  " p-st-discnt skip
    "p-netto " p-netto          skip
    "p-netto-rubl " p-netto-rubl skip
    "p-netto-base " p-netto-base skip
    "p-all-discnt " p-all-discnt skip
    "p-all-discnt-rubl " p-all-discnt-rubl skip
    "p-all-discnt-base " p-all-discnt-base skip
    view-as alert-box .
    */
  end. /*ne retry*/
end. /*doe*/

end procedure. /* libthpos_sub-total */



procedure libthpos_pay-line :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-cdpay-code as integer no-undo .
define input-output parameter p-curr-code as integer   no-undo .
define input  parameter p-par-code as integer no-undo .
define input  parameter p-src-qnty as decimal no-undo .
define output parameter p-frpay-code as integer no-undo .
define input  parameter p-pass-pay   as integer no-undo .
define input  parameter p-pay-card as character no-undo .
define input-output parameter p-tot-sum as decimal no-undo .
define input-output parameter p-tot-rubl as decimal no-undo .
define input-output parameter p-tot-base as decimal no-undo .
define output parameter p-get-qnty-method as character no-undo .
define output parameter p-2-cdpay-code as integer no-undo .
define output parameter p-2-curr-code as integer   no-undo .
define output parameter p-2-frpay-code as integer no-undo .
define output parameter p-2-tot-sum as decimal no-undo .
define output parameter p-2-tot-rubl as decimal no-undo .
define output parameter p-2-tot-base as decimal no-undo .
define output parameter p-src-discnt-sum as decimal no-undo .
define output parameter p-src-discnt-rubl as decimal no-undo .
define output parameter p-for-discnt-doc as decimal no-undo .
define output parameter p-for-discnt-rubl as decimal no-undo .
define output parameter p-for-discnt-r-b as decimal no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-netto-sum as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-discnt as decimal no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-exch-abbr as character no-undo .
define variable v-exch-date as date no-undo .
define variable v-exch-time as integer no-undo .
define variable v-nalc-exch-rate as decimal no-undo .
define variable v-nalc-exch-scale as integer no-undo .
define variable v-nalc-exch-date as date no-undo .
define variable v-nalc-exch-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-calc-rate as integer no-undo .
define variable v-pay-discnt-sum as decimal no-undo .
define variable v-pay-discnt-rubl as decimal no-undo .
define variable v-pay-discnt-base as decimal no-undo .
/*НЕ КАК остальные скидки - иожнт бвыт*/
define variable v-is-cash as logical no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-has-overpay as integer no-undo .
define variable v-atr1  as logical no-undo .
define variable v-has-return as integer no-undo .
define variable v-can-mix  as integer no-undo .
define variable v-is-credit-card as logical no-undo .
define variable v-is-debet-card  as logical no-undo .
define variable v-atr128 as logical no-undo .
define variable v-atr16 as logical no-undo .
define variable v-atr32 as logical no-undo .
define variable v-wth-code as integer   no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-src-val as integer   no-undo .
define variable v-par-rate as decimal no-undo .

define variable v-inversed as logical no-undo .
define variable v-err-mess as character no-undo .


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_libthpos_rp-by-call for libthpos_rp-by-call.

define buffer buf_libthpos_temp-cash-pay-list for libthpos_temp-cash-pay-list.
define buffer buf2_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf2_cash-pay for ub.cash-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer undo_libthpos_chk-context for libthpos_chk-context.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    find first libthpos_chk-doc.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step < {&step-subtotal} then do:
      v-err-mess = substitute("Не подведены итоги по чеку &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if p-line-num <= 0 then do:
      v-err-mess = substitute("Неверный номер строки оплат = &1", p-line-num).
      undo main-block, retry main-block.
    end.
    if not (
            (
              (p-mode = {&add-def}
              or
              p-mode = {&update}
              or
              p-mode = {&deletion}
              )
              and p-tot-sum <> ?
              )
            or
            (p-mode = 'check'
            and p-tot-sum = ?)
            ) then do:
      v-err-mess = substitute("Неверное действие над строкой оплат чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    if p-mode = {&deletion}
    and (p-tot-sum = ?
    or p-tot-sum <> 0 ) then do:
      v-err-mess = substitute("Для удаления строки оплат чека сумма должна = 0").
      undo main-block, retry main-block.
    end.
    if p-mode = {&update}
    and (p-tot-sum = ?
    or p-tot-sum = 0) then do:
      v-err-mess = substitute("Для изменения строки оплат чека сумма не должна = 0 или ?").
      undo main-block, retry main-block.
    end.
    if p-tot-sum <> ? then do:
      v-inversed = yes.
    end.
    if p-tot-sum = ?
    and p-mode = "check"
    then do:
      p-mode = {&add-def}.
    end.
    define variable v-na-vhode as decimal no-undo .
    v-na-vhode = p-tot-sum.
    /*проверим что в таком чеке могут быть строки оплат*/
    if lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) > 0
    or lookup(string(libthpos_chk-context.chk-type), {&no-pay-receipt-codes}) > 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 строки оплат быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    case p-mode:
      when {&add-def} then do:

        if libthpos_chk-context.lnp + 1 <> p-line-num then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1&2должен быть &3"
                                      , p-line-num
                                      , {&new-line}
                                      , libthpos_chk-context.lnp + 1).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code = ? then do:
          assign
          p-cdpay-code = 1
          p-curr-code = libthpos_context.nalc
          v-is-cash = yes
          v-has-overpay = 0
          v-atr1  = yes
          v-has-return = 1
          v-can-mix  = 1
          v-src-val = 0
          p-par-code = 0
          .
        end.
        else do:
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = p-cdpay-code
                and buf_cash-pay.curr-code = p-curr-code no-error.
          if not available buf_cash-pay then do:
            v-err-mess = substitute("Не найден тип кассового платежа с кодом &1 и валютой &2"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          if buf_cash-pay.wth-code > 0 then do:
            find first buf_wealth no-lock where
                      buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
            if not available buf_wealth then do:
              v-err-mess = substitute("Не найдена МЦ с кодом &1 для типа кассового платежа с кодом &2 и валютой &3"
                                                      , buf_cash-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            v-get-qnty-method = buf_wealth.get-qnty-method.
                  end.
          if p-par-code <> 0 then do:
            find first buf_wth-par no-lock where
                      buf_wth-par.par-code = p-par-code
                  and buf_wth-par.wth-code = buf_cash-pay.wth-code no-error.
            if not available buf_wth-par then do:
              v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                      , p-par-code
                                                      , buf_cash-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            assign
            v-src-val = buf_wth-par.par-val
            v-par-rate = buf_wth-par.par-rate
            .
          end.
          assign
          v-has-overpay = buf_cash-pay.has-overpay
          v-atr1  = buf_cash-pay.atr1
          v-has-return = buf_cash-pay.has-return
          v-can-mix  = buf_cash-pay.can-mix
          v-is-credit-card = buf_cash-pay.is-credit-card
          v-is-debet-card  = buf_cash-pay.is-debet-card
          v-atr128 = buf_Cash-pay.atr128
          v-atr16 = buf_Cash-pay.atr16
          v-atr32 = buf_Cash-pay.atr32
          v-wth-code = buf_cash-pay.wth-code
          .
          if v-has-return = 0
          and lookup(string(libthpos_chk-context.chk-type), {&sale-in-receipt-codes}) > 0 then do:
            v-err-mess = substitute("Для типа касс платежа с кодом &1 и валютой &2 возврат ЗАПРЕЩЕН"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          if p-line-num > 1 then do:
            for each buf2_libthpos_chk-pay where
                    buf2_libthpos_chk-pay.doc-code = libthpos_chk-context.doc-code,
                first buf2_cash-pay no-lock where
                    buf2_cash-pay.cdpay-code = buf2_libthpos_chk-pay.pay-code
              and  buf2_cash-pay.curr-code = buf2_libthpos_chk-pay.curr-code:
              if buf2_cash-pay.can-mix = 0
              and not (buf2_cash-pay.cdpay-code = buf_cash-pay.cdpay-code
                      and
                      buf2_cash-pay.curr-code = buf_cash-pay.curr-code)
              then do:
                v-err-mess = substitute("В чеке есть строка оплаты с № &1, для которой запрещена СМЕШАННАЯ ОПЛАТА"
                                                        , buf2_libthpos_chk-pay.line-num
                                                        ).
                undo main-block, retry main-block.
              end.
            end.
          end.
          assign
          v-is-cash = buf_cash-pay.is-cash
          .
          if p-pay-card <> "0"
          and p-pay-card <> ""
          and buf_cash-pay.is-cash then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 с признаком НАЛИЧНЫЕ не может быть № карты"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
        end.
        if p-cdpay-code = 1 then do:
          v-frpay-code = 1.
        end.
        else do:
          find first buf_libthpos_temp-cash-pay-list where
                  buf_libthpos_temp-cash-pay-list.cdpay-code = p-cdpay-code
              and  buf_libthpos_temp-cash-pay-list.curr-code = p-curr-code no-error .
          if not available  buf_libthpos_temp-cash-pay-list then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 не удалось найти соответствующий код оплаты на ФР"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          v-frpay-code = buf_libthpos_temp-cash-pay-list.frpay-code.
        end.
        if p-tot-sum = ? then do:
          assign
          v-tot-rubl = libthpos_chk-context.to-pay-rubl
          v-tot-base = libthpos_chk-context.to-pay-base
          .
          /*получим курсы*/
          if p-curr-code = 0 then do:
            assign
            v-cash-rate = 1
            v-calc-rate = 1
            v-bank-rate = 1
            v-bank-scale = 1
            v-exch-rate = 1
            v-exch-scale = 1
            v-exch-date = libthpos_chk-context.chk-date
            v-exch-time = libthpos_chk-context.chk-time
            v-tot-sum = v-tot-rubl
            .
          end.
          else do:
            if p-curr-code = libthpos_context.base-code then do:
              assign
              v-cash-rate = libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
              v-calc-rate = 1
              v-bank-rate = libthpos_chk-context.a-bank-rate
              v-bank-scale = libthpos_chk-context.a-bank-scale
              v-exch-rate = libthpos_chk-context.a-bank-rate
              v-exch-scale = libthpos_chk-context.a-bank-scale
              v-exch-date = libthpos_chk-context.chk-date
              v-exch-time = libthpos_chk-context.chk-time
              v-tot-sum = v-tot-base
              .

            end.
            else do:
              run cur-time in this-procedure ( output v-today, output v-time).
              find  LAST buf_curr-shop NO-LOCK WHERE
                            buf_curr-shop.obj-type = libthpos_context.obj-type
                        AND buf_curr-shop.obj-code = libthpos_context.obj-code
                        AND buf_curr-shop.curr-code = p-curr-code
                        AND ( ( buf_curr-shop.exch-date = v-today
                              AND
                              buf_curr-shop.exch-time <= v-time ) OR
                              buf_curr-shop.exch-date < v-today ) NO-ERROR .
              if available buf_curr-shop then do:
                assign
                v-exch-rate = buf_curr-shop.exch-rate
                v-exch-scale = buf_curr-shop.exch-scale
                v-exch-date  = buf_curr-shop.exch-date
                v-exch-time  = buf_curr-shop.exch-time
                .
              end.
              else do:
                v-err-mess =  substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                          , p-curr-code
                          , libthpos_context.obj-type
                          , libthpos_context.obj-code
                          , string(v-today, "99/99/9999")
                          , string(v-time, "HH:MM:SS")
                      ).
                undo main-block, retry main-block.
              end.
              { gbl/exchrate.i p-curr-code v-today v-bank-rate v-bank-scale v-bank-abbr no-error }
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при определении курса валюты с кодом &1 на &2", p-curr-code, string(v-today, "99/99/999")).
                undo main-block, retry main-block.
              end.
              assign
              v-tot-sum = (if libthpos_context.r-b = {&r-b-rubl}
                          then p-tot-rubl / v-exch-rate * v-exch-scale
                          else p-tot-base * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale / v-exch-rate * v-exch-scale
                            )
              .
            end.
          end. /*else if p-curr-code = 0*/
        end. /*if p-tot-sum = ? then do:*/
        else do:
          assign
          v-tot-sum = p-tot-sum
          .
          if p-curr-code = 0 then do:
            assign
              v-cash-rate = 1
              v-calc-rate = 1
              v-bank-rate = 1
              v-bank-scale = 1
              v-exch-rate = 1
              v-exch-scale = 1
              v-exch-date = libthpos_chk-context.chk-date
              v-exch-time = libthpos_chk-context.chk-time
            v-tot-rubl = p-tot-sum
            v-tot-base = (if libthpos_context.base-code = 0
                          then v-tot-rubl
                          else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
          end. /*if p-curr-code = 0 then do:*/
          else do:
            if p-curr-code = libthpos_context.base-code then do:
              assign
              v-cash-rate = libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
              v-calc-rate = 1
              v-bank-rate = libthpos_chk-context.a-bank-rate
              v-bank-scale = libthpos_chk-context.a-bank-scale
              v-exch-rate = libthpos_chk-context.a-bank-rate
              v-exch-scale = libthpos_chk-context.a-bank-scale
              v-exch-date = libthpos_chk-context.chk-date
              v-exch-time = libthpos_chk-context.chk-time
              v-tot-base = p-tot-sum
              v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
              .
            end. /*if p-curr-code = libthpos_context.base-code then do:*/
            else do:
              run cur-time in this-procedure ( output v-today, output v-time).
              find  LAST buf_curr-shop NO-LOCK WHERE
                            buf_curr-shop.obj-type = libthpos_context.obj-type
                        AND buf_curr-shop.obj-code = libthpos_context.obj-code
                        AND buf_curr-shop.curr-code = p-curr-code
                        AND ( ( buf_curr-shop.exch-date = v-today
                              AND
                              buf_curr-shop.exch-time <= v-time ) OR
                              buf_curr-shop.exch-date < v-today ) NO-ERROR .
              if available buf_curr-shop then do:
                assign
                v-exch-rate = buf_curr-shop.exch-rate
                v-exch-scale = buf_curr-shop.exch-scale
                v-exch-date  = buf_curr-shop.exch-date
                v-exch-time  = buf_curr-shop.exch-time
                .
              end.
              else do:
                v-err-mess = substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                          , p-curr-code
                          , libthpos_context.obj-type
                          , libthpos_context.obj-code
                          , string(v-today, "99/99/9999")
                          , string(v-time, "HH:MM:SS")
                      ).
                undo main-block, retry main-block.
              end.
              { gbl/exchrate.i p-curr-code v-today v-bank-rate v-bank-scale v-bank-abbr no-error }
              if error-status:error then do:
                v-err-mess = substitute("Ошибка при получении курса валюты &1 на &2", p-curr-code, string(v-today, "99/99/9999")).
                undo main-block, retry main-block.
              end.
              assign
              v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
              v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
              .
            end. /*else if p-curr-code = libthpos_context.base-code then do:*/
          end. /*else if p-curr-code = 0 then do:*/
          if v-atr1 = no
          and (v-has-overpay = 0
              or
              lookup(string(libthpos_chk-context.chk-type), {&sale-out-receipt-codes}) = 0
              )
          and (
                ( libthpos_context.r-b = {&r-b-rubl}
                and
                abs(v-tot-rubl) > abs(libthpos_chk-context.to-pay-rubl))
                or
                ( libthpos_context.r-b = {&r-b-base}
                and
                abs(v-tot-rubl) > abs(libthpos_chk-context.to-pay-base))
              ) then do:
            /*сдача не разрешена*/
            v-err-mess = substitute("Для типа касс. платежа с кодом &1 НЕ РАЗРЕШЕНА СДАЧА, а сумма >, чем сумма к оплате"
                                                      , p-cdpay-code
                                                      , p-curr-code).
            undo main-block, retry main-block.
          end.
        end. /*else if p-tot-sum = ? then do:*/
      end. /*when {&add-def}*/
      when {&update}
      or
      when {&deletion} then do:
        for first buf_chk-pay share-lock where
                buf_chk-pay.doc-code = p-doc-code
            and buf_chk-pay.line-num = p-line-num,
            first buf_libthpos_chk-pay where
                buf_libthpos_chk-pay.doc-code = p-doc-code
            and buf_libthpos_chk-pay.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          leave.
        end.
        if not available buf_chk-pay then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1"
                                      , p-line-num
                                      ).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code <> buf_chk-pay.pay-code
        /*  or p-curr-code <> buf_chk-pay.curr-code */
        then do:
          v-err-mess = substitute("Для уже имеющейся строки оплат чека (&1) нельзя изменить код типа касс. платеж и код валюты - были &2 &3"
                                      , p-line-num
                                      , buf_chk-pay.pay-code
                                      , buf_chk-pay.curr-code
                                      ).
          undo main-block, retry main-block.
        end.
        if p-pay-card = ""
        and (buf_libthpos_chk-pay.is-credit-card
              or
              buf_libthpos_chk-pay.is-debet-card
              or
              buf_libthpos_chk-pay.atr128
              or
              buf_libthpos_chk-pay.atr16
              or
              buf_libthpos_chk-pay.atr32
              )
        and p-mode <> {&deletion}
        then do:
          v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 необходим № карты"
                                                  , p-cdpay-code
                                                  , p-curr-code).
          undo main-block, retry main-block.
        end.
        if p-mode = {&update} then do:
          if p-par-code <> 0 then do:
            find first buf_wth-par no-lock where
                      buf_wth-par.par-code = p-par-code
                  and buf_wth-par.wth-code = libthpos_chk-pay.wth-code no-error.
            if not available buf_wth-par then do:
              v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                      , p-par-code
                                                      , libthpos_chk-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).

              undo main-block, retry main-block.
            end.
            assign
            v-src-val = buf_wth-par.par-val
            v-par-rate = buf_wth-par.par-rate
            .
          end.
        end.
        assign
        v-tot-sum  = p-tot-sum
        .
        if buf_libthpos_chk-pay.curr-code = 0 then do:
          assign
          v-tot-rubl = p-tot-sum
          v-tot-base = (if libthpos_context.base-code = 0
                        then v-tot-rubl
                        else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
        end.
        else do:
          if p-curr-code = libthpos_context.base-code then do:
            assign
            v-tot-base = p-tot-sum
            v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            .
          end.
          else do:
            assign
            v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
            .
          end.
        end.
        assign
        v-bank-rate = buf_libthpos_chk-pay.bank-rate
        v-bank-scale = buf_libthpos_chk-pay.bank-scale
        v-cash-rate = buf_libthpos_chk-pay.cash-rate
        v-exch-date = buf_libthpos_chk-pay.b-exch-date
        v-exch-time = buf_libthpos_chk-pay.b-exch-time
        v-exch-rate = buf_libthpos_chk-pay.b-exch-rate
        v-exch-scale =  buf_libthpos_chk-pay.b-exch-scale
        v-calc-rate = buf_libthpos_chk-pay.b-calc-rate
        v-is-cash = buf_libthpos_chk-pay.is-cash
        v-frpay-code = buf_libthpos_chk-pay.frpay-code
        v-pay-discnt-sum = buf_libthpos_chk-pay.discnt-sum
        v-pay-discnt-rubl = buf_libthpos_chk-pay.discnt-rubl
        v-pay-discnt-base = buf_libthpos_chk-pay.discnt-base
        v-has-overpay = buf_libthpos_chk-pay.has-overpay
        v-can-mix = buf_libthpos_chk-pay.can-mix
        v-has-return = buf_libthpos_chk-pay.has-return
        v-atr1 = buf_libthpos_chk-pay.atr1
        v-is-credit-card = buf_libthpos_chk-pay.is-credit-card
        v-is-debet-card  = buf_libthpos_chk-pay.is-debet-card
        v-atr128 = buf_libthpos_chk-pay.atr128
        v-atr16 = buf_libthpos_chk-pay.atr16
        v-atr32 = buf_libthpos_chk-pay.atr32
        v-wth-code = buf_libthpos_chk-pay.wth-code
        v-get-qnty-method = buf_libthpos_chk-pay.get-qnty-method
        .
        if v-get-qnty-method = {&wth-qnty-val-qnty}
        and p-mode = {&update} then do:
          if not (p-par-code > 0
                and
                p-src-qnty <> 0) then do:
            v-err-mess = substitute("Для типа касс. платеж с кодом &1 и кодом валюты &2 необходимо указать номинал и количество знаков оплаты"
                                        , buf_chk-pay.pay-code
                                        , buf_chk-pay.curr-code
                                        ).
            undo main-block, retry main-block.
          end.
        end.
      end.
    end case.
    if libthpos_context.nalc <>  0
    and libthpos_context.nalc <> libthpos_context.base-code
    and libthpos_context.nalc <> p-curr-code then do:
      /*надо найти курс*/
      find  LAST buf_curr-shop NO-LOCK WHERE
                    buf_curr-shop.obj-type = libthpos_context.obj-type
                AND buf_curr-shop.obj-code = libthpos_context.obj-code
                AND buf_curr-shop.curr-code = libthpos_context.nalc
                AND ( ( buf_curr-shop.exch-date = v-today
                      AND
                      buf_curr-shop.exch-time <= v-time ) OR
                      buf_curr-shop.exch-date < v-today ) NO-ERROR .
      if available buf_curr-shop then do:
        assign
        v-nalc-exch-rate = buf_curr-shop.exch-rate
        v-nalc-exch-scale = buf_curr-shop.exch-scale
        v-nalc-exch-date  = buf_curr-shop.exch-date
        v-nalc-exch-time  = buf_curr-shop.exch-time
        .
      end.
      else do:
        v-err-mess = substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                          , libthpos_context.nalc
                          , libthpos_context.obj-type
                          , libthpos_context.obj-code
                          , string(v-today, "99/99/9999")
                          , string(v-time, "HH:MM:SS")
                      ).
        undo main-block, retry main-block.
      end.
    end.
    if (p-mode = {&add-def}
    or p-mode = {&update})
    and p-line-num = 1
    and libthpos_chk-context.direction > 0
    and v-tot-sum < 0 then do:
      v-err-mess = substitute("Неверный знак суммы по типу кассового платежа с кодом &1", p-cdpay-code).
      undo main-block, retry main-block.
    end.
    if (p-mode = {&add-def}
    or p-mode = {&update})
    /*and p-line-num = 1*/ /*если надо разрешить сдачу на возврате здесь разкоментарить*/
    and libthpos_chk-context.direction < 0
    and v-tot-sum > 0 then do:
      v-err-mess = substitute("Неверный знак суммы строки оплаты &1 чека &2", p-cdpay-code, p-doc-code).
      undo main-block, retry main-block.
    end.
    if p-mode = {&add-def}
    then do:
      create buf_libthpos_chk-pay.
      if p-mode = {&add-def}
      and v-inversed then do:
        create buf_chk-pay.
        assign
        buf_chk-pay.doc-code = p-doc-code
        libthpos_chk-context.lnp = libthpos_chk-context.lnp + 1
        libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
        buf_chk-pay.line-num = libthpos_chk-context.lnp
        buf_libthpos_chk-pay.recalc-line-num = buf_chk-pay.line-num
        buf_chk-pay.chk-date = libthpos_chk-doc.chk-date
        buf_chk-pay.time-oper = v-time
        buf_chk-pay.pay-code = p-cdpay-code
        buf_chk-pay.curr-code = p-curr-code
        buf_chk-pay.par-code = p-par-code
        buf_chk-pay.pass-pay = 0
        buf_chk-pay.line-type  = ''
        buf_chk-pay.pay-card = ""
        buf_Chk-pay.obj-type = libthpos_context.obj-type
        buf_chk-pay.obj-code = libthpos_context.obj-code
        buf_Chk-pay.bank-rate = 1
        buf_Chk-pay.bank-scale = 1
        buf_Chk-pay.cash-rate = 1
        buf_chk-pay.is-error = no
        buf_chk-pay.line-sign = ((v-tot-sum > 0 ) = (libthpos_chk-context.direction > 0))
        buf_chk-pay.line-type = ""
        buf_chk-pay.out-code = ?
        buf_chk-pay.tot-base = 0
        buf_chk-pay.tot-rubl = 0
        buf_chk-pay.tot-sum = 0
        buf_chk-pay.par-code = p-par-code
        buf_chk-pay.src-val = v-src-val
        buf_chk-pay.pass-pay = p-pass-pay
        .
        buffer-copy buf_chk-pay to buf_libthpos_chk-pay.
      end.
      else do:
        assign
        buf_libthpos_chk-pay.doc-code = p-doc-code
        buf_libthpos_chk-pay.line-num = -1
        buf_libthpos_chk-pay.recalc-line-num = -1
        buf_libthpos_chk-pay.chk-date = libthpos_chk-doc.chk-date
        buf_libthpos_chk-pay.time-oper = v-time
        buf_libthpos_chk-pay.pay-code = p-cdpay-code
        buf_libthpos_chk-pay.curr-code = p-curr-code
        buf_libthpos_chk-pay.par-code = p-par-code
        buf_libthpos_chk-pay.pass-pay = 0
        buf_libthpos_chk-pay.line-type  = ''
        buf_libthpos_chk-pay.pay-card = ""
        buf_libthpos_chk-pay.obj-type = libthpos_context.obj-type
        buf_libthpos_chk-pay.obj-code = libthpos_context.obj-code
        buf_libthpos_chk-pay.bank-rate = 1
        buf_libthpos_chk-pay.bank-scale = 1
        buf_libthpos_chk-pay.cash-rate = 1
        buf_libthpos_chk-pay.is-error = no
        buf_libthpos_chk-pay.line-sign = ((v-tot-sum > 0 ) = (libthpos_chk-context.direction > 0))
        buf_libthpos_chk-pay.line-type = ""
        buf_libthpos_chk-pay.out-code = ?
        buf_libthpos_chk-pay.tot-base = 0
        buf_libthpos_chk-pay.tot-rubl = 0
        buf_libthpos_chk-pay.tot-sum = 0
        buf_libthpos_chk-pay.par-code = p-par-code
        buf_libthpos_chk-pay.src-val = v-src-val
        buf_libthpos_chk-pay.pass-pay = p-pass-pay
        .

      end.
      assign
      buf_libthpos_chk-pay.has-overpay = v-has-overpay
      buf_libthpos_chk-pay.atr1  = v-atr1
      buf_libthpos_chk-pay.has-return = v-has-return
      buf_libthpos_chk-pay.can-mix  = v-can-mix
      buf_libthpos_chk-pay.is-credit-card = v-is-credit-card
      buf_libthpos_chk-pay.is-debet-card = v-is-debet-card
      buf_libthpos_chk-pay.atr128 = v-atr128
      buf_libthpos_chk-pay.atr16 = v-atr16
      buf_libthpos_chk-pay.atr32 =  v-atr32
      buf_libthpos_chk-pay.get-qnty-method = v-get-qnty-method
      buf_libthpos_chk-pay.wth-code = v-wth-code
      buf_libthpos_chk-pay.par-rate = v-par-rate
      .
    end.
    if libthpos_chk-context.sale-in-out
    and libthpos_context.pos-type = {&cd-type-ibs-th}
    and v-inversed
    then do:
      find first buf_libthpos_cash-counter where
                buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
          and  buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
          and  buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
          and  buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
                no-error.
      if not available buf_libthpos_cash-counter then do:
        create buf_libthpos_cash-counter.
        assign
        buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
        buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
        buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
        buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
        buf_libthpos_cash-counter.par-val = buf_chk-pay.src-val
        .
      end.
    end.
    assign
    /*сначала убавим сумму*/
    libthpos_chk-context.pay-discnt = libthpos_chk-context.pay-discnt - buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.pay-discnt-rubl = libthpos_chk-context.pay-discnt-rubl - buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.pay-discnt-base = libthpos_chk-context.pay-discnt-base - buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.netto = libthpos_chk-context.netto + buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.to-pay-r-b = libthpos_chk-context.to-pay-r-b + buf_libthpos_chk-pay.brutto-r-b +
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-r-b else 0)
    libthpos_chk-context.with-atr1-sum = libthpos_chk-context.with-atr1-sum -
                                        (if buf_libthpos_chk-pay.atr1
                                        then (if libthpos_context.r-b = {&r-b-base}
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.change-sum = libthpos_chk-context.change-sum -
                                        (if buf_libthpos_chk-pay.line-sign = no
                                        then (if libthpos_context.r-b = {&r-b-base}
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)

    libthpos_chk-context.has-pay-r-b = libthpos_chk-context.has-pay-r-b - (if libthpos_context.r-b = {&r-b-base}
                                                                            then buf_libthpos_chk-pay.tot-base
                                                                            else buf_libthpos_chk-pay.tot-rubl)
    libthpos_chk-context.to-pay-rubl = libthpos_chk-context.to-pay-rubl + buf_libthpos_chk-pay.brutto-rubl +
                                        (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-rubl else 0)
    libthpos_chk-context.has-pay-rubl = libthpos_chk-context.has-pay-rubl - buf_libthpos_chk-pay.tot-rubl
    libthpos_chk-context.all-pay-rubl = libthpos_chk-context.all-pay-rubl + buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.to-pay-base = libthpos_chk-context.to-pay-base + buf_libthpos_chk-pay.brutto-base +
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-base else 0)
    libthpos_chk-context.has-pay-base = libthpos_chk-context.has-pay-base - buf_libthpos_chk-pay.tot-base
    libthpos_chk-context.all-pay-base = libthpos_chk-context.all-pay-base + buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.pay-r = libthpos_chk-context.pay-r - buf_libthpos_chk-pay.r-sum
    .
    if libthpos_chk-context.sale-in-out
    and libthpos_context.pos-type = {&cd-type-ibs-th}
    and v-inversed
    then do:
      assign
      buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum - buf_chk-pay.tot-sum
      buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base - buf_libthpos_chk-pay.tot-base
      buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl - buf_libthpos_chk-pay.tot-rubl
      buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines - 1
      buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty - buf_chk-pay.src-qnty
      libthpos_context.pre-cash-counter = (if buf_libthpos_cash-counter.is-cash = yes
                                          then (libthpos_context.pre-cash-counter -
                                                  (if libthpos_context.r-b = {&r-b-rubl}
                                                  then buf_libthpos_chk-pay.tot-rubl
                                                  else buf_libthpos_chk-pay.tot-base)
                                                )
                                          else libthpos_context.pre-cash-counter)
      .
    end.
    assign
    buf_libthpos_chk-pay.inversed = (if p-mode <> {&deletion} then v-inversed else buf_libthpos_chk-pay.inversed)
    buf_libthpos_chk-pay.is-cash = v-is-cash
    buf_libthpos_chk-pay.frpay-code = v-frpay-code
    buf_libthpos_chk-pay.has-overpay = v-has-overpay
    buf_libthpos_chk-pay.can-mix = v-can-mix
    buf_libthpos_chk-pay.has-return = v-has-return
    buf_libthpos_chk-pay.atr1 = v-atr1
    buf_libthpos_chk-pay.is-credit-card = v-is-credit-card
    buf_libthpos_chk-pay.is-debet-card = v-is-debet-card
    buf_libthpos_chk-pay.atr128 = v-atr128
    buf_libthpos_chk-pay.atr16 = v-atr16
    buf_libthpos_chk-pay.atr32 =  v-atr32
    buf_libthpos_chk-pay.get-qnty-method =  v-get-qnty-method
    buf_libthpos_chk-pay.par-rate =  v-par-rate
    buf_libthpos_chk-pay.wth-code =  v-wth-code
    buf_libthpos_chk-pay.src-val =  v-src-val
    buf_libthpos_chk-pay.tot-base = v-tot-base
    buf_libthpos_chk-pay.tot-rubl = v-tot-rubl
    buf_libthpos_chk-pay.tot-sum = v-tot-sum
    buf_libthpos_chk-pay.bank-rate = v-bank-rate
    buf_libthpos_chk-pay.bank-scale = v-bank-scale
    buf_libthpos_chk-pay.cash-rate = v-cash-rate
    buf_libthpos_chk-pay.b-exch-date = v-exch-date
    buf_libthpos_chk-pay.b-exch-time = v-exch-time
    buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
    buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
    buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
    buf_libthpos_chk-pay.brutto-doc = v-tot-sum
    buf_libthpos_chk-pay.brutto-rubl = v-tot-rubl
    buf_libthpos_chk-pay.brutto-base = v-tot-base
    buf_libthpos_chk-pay.brutto-r-b = (if libthpos_context.r-b = {&r-b-rubl}
                                      then v-tot-rubl
                                      else v-tot-base)
    .
    if buf_libthpos_chk-pay.line-sign = yes
    and ((libthpos_chk-context.to-pay-r-b > 0) = (libthpos_chk-context.direction > 0))
    then do:
      /*прямое направление*/
      assign
      buf_libthpos_chk-pay.for-discnt-rubl = (if libthpos_chk-context.to-pay-rubl * libthpos_chk-context.direction < (v-tot-sum /  buf_libthpos_chk-pay.b-exch-rate * buf_libthpos_chk-pay.b-exch-scale) * libthpos_chk-context.direction
                                            then libthpos_chk-context.to-pay-rubl
                                            else  v-tot-rubl)
      buf_libthpos_chk-pay.for-discnt-doc = (if buf_libthpos_chk-pay.curr-code = 0
                                            then buf_libthpos_chk-pay.for-discnt-rubl
                                            else  buf_libthpos_chk-pay.for-discnt-rubl / buf_libthpos_chk-pay.b-exch-rate * buf_libthpos_chk-pay.b-exch-scale )
      buf_libthpos_chk-pay.for-discnt-r-b = (if libthpos_context.r-b = {&r-b-rubl}
                                              or libthpos_context.base-code = 0
                                              then buf_libthpos_chk-pay.for-discnt-rubl
                                              else buf_libthpos_chk-pay.for-discnt-rubl / libthpos_chk-context.base-rate )
      buf_libthpos_chk-pay.for-discnt-base = (if buf_libthpos_chk-pay.curr-code = libthpos_context.base-code
                                              then buf_libthpos_chk-pay.for-discnt-doc
                                              else (if buf_libthpos_chk-pay.curr-code = 0
                                                    then buf_libthpos_chk-pay.for-discnt-rubl
                                                    else buf_libthpos_chk-pay.for-discnt-rubl / libthpos_chk-context.base-rate )
                                              )
      .
    end.
    else do:
      assign
      buf_libthpos_chk-pay.for-discnt-rubl = 0
      buf_libthpos_chk-pay.for-discnt-doc = 0
      buf_libthpos_chk-pay.for-discnt-r-b = 0
      buf_libthpos_chk-pay.for-discnt-base = 0
      .

    end.
    /*расчет скидок v-pay-discnt-sum v-pay-discnt-r-b v-pay-discnt-rubl v-pay-discnt-base */

    define variable v-start-curr-sum as decimal no-undo .
    define variable v-start-rubl-sum as decimal no-undo .
    define variable v-start-base-sum as decimal no-undo .
    define variable v-curr-sum as decimal no-undo .
    define variable v-rubl-sum as decimal no-undo .
    define variable v-base-sum as decimal no-undo .
    define variable v-discnt-curr as decimal no-undo .
    define variable v-discnt-rubl as decimal no-undo .
    define variable v-discnt-base as decimal no-undo .
    define variable v-new-curr-sum as decimal no-undo .
    define variable v-new-rubl-sum as decimal no-undo .
    define variable v-new-base-sum as decimal no-undo .
    define variable v-new-discnt-curr as decimal no-undo .
    define variable v-new-discnt-rubl as decimal no-undo .
    define variable v-new-discnt-base as decimal no-undo .

    assign
    v-start-curr-sum = buf_libthpos_chk-pay.tot-sum
    v-start-rubl-sum = buf_libthpos_chk-pay.tot-rubl
    v-start-base-sum = buf_libthpos_chk-pay.tot-base
    v-curr-sum = buf_libthpos_chk-pay.tot-sum
    v-rubl-sum = buf_libthpos_chk-pay.tot-rubl
    v-base-sum = buf_libthpos_chk-pay.tot-base
    v-new-curr-sum = buf_libthpos_chk-pay.tot-sum
    v-new-rubl-sum = buf_libthpos_chk-pay.tot-rubl
    v-new-base-sum = buf_libthpos_chk-pay.tot-base
    v-discnt-curr = 0
    v-discnt-rubl = 0
    v-discnt-base = 0
    v-new-discnt-curr = 0
    v-new-discnt-rubl = 0
    v-new-discnt-base = 0
    .
    if lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) = 0
    and buf_libthpos_chk-pay.line-sign = yes
    and ((libthpos_chk-context.to-pay-r-b > 0) = (libthpos_chk-context.direction > 0))
    and libthpos_chk-context.direction > 0
    then do:
      /*расчет скидок*/
      if p-mode <> {&add-def} then do:
        /*сначала удалим имеющиеся*/
        _chk-discnt-pay:
        for each buf_libthpos_chk-discnt share-lock where
                buf_libthpos_chk-discnt.line-type = integer({&discnt-payment})
          and buf_libthpos_chk-discnt.line-num = p-line-num
          and buf_libthpos_chk-discnt.record-type = 0
          and buf_libthpos_chk-discnt.object-line-num = p-line-num,
            first buf_chk-discnt where
                  buf_chk-discnt.doc-code = p-doc-code
            and buf_chk-discnt.line-num = buf_libthpos_chk-discnt.line-num
            and buf_chk-discnt.record-type = buf_libthpos_chk-discnt.record-type
            and buf_chk-discnt.discnt-id = buf_libthpos_chk-discnt.discnt-id
            and buf_chk-discnt.object-line-num = buf_libthpos_chk-discnt.object-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          delete buf_chk-discnt.
          delete buf_libthpos_chk-discnt.
        end.
        assign
        buf_libthpos_chk-pay.discnt-r-b = 0
        buf_libthpos_chk-pay.discnt-rubl = 0
        buf_libthpos_chk-pay.discnt-base = 0
        buf_libthpos_chk-pay.discnt-sum = 0
        .
      end.
      if p-mode <> {&deletion} then do:
        /*удельную скидку v-discnt рассчитываем с максимальной точность*/
        run cur-time in this-procedure ( output libthpos_chk-context.current-date, output libthpos_chk-context.current-time).
        assign
        v-bh[{&context}] = (buffer libthpos_context:handle)
        v-bh[{&chk-gds}] = (buffer libthpos_chk-gds:handle)
        v-bh[{&chk-pay}] = (buffer buf_libthpos_chk-pay:handle)
        v-bh[{&chk-discnt}] = (buffer libthpos_chk-discnt:handle)
        .

        for each buf_libthpos_rp-by-call
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :

        run rs_17_1 in buf_libthpos_rp-by-call.rph (
                    input '':U /*p-caller */
                  ,input p-line-num
                  ,input p-cdpay-code
                  ,input p-curr-code
                  ,input p-pay-card
                  ,input buf_libthpos_chk-pay.inversed
                  ,input v-start-curr-sum
                  ,input v-curr-sum
                  ,input v-start-rubl-sum
                  ,input v-rubl-sum
                  ,input v-start-base-sum
                  ,input v-base-sum
                  ,input v-discnt-curr
                  ,input v-discnt-rubl
                  ,input v-discnt-base
                  ,input v-bh
                  ,output v-new-curr-sum
                  ,output v-new-rubl-sum
                  ,output v-new-base-sum
                  ,output v-new-discnt-curr
                  ,output v-new-discnt-rubl
                  ,output v-new-discnt-base
                      ) no-error.
          if not error-status :error then do:
            assign
            v-curr-sum = v-new-curr-sum
            v-rubl-sum = v-new-rubl-sum
            v-base-sum = v-new-base-sum
            v-discnt-curr = v-new-discnt-curr
            v-discnt-rubl = v-new-discnt-rubl
            v-discnt-base = v-new-discnt-base
            .
          end.
        end.
      end.
    end. /*if lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) = 0*/
    assign
    v-pay-discnt-sum = v-new-discnt-curr
    v-pay-discnt-rubl = v-new-discnt-rubl
    v-pay-discnt-base = v-new-discnt-base
    .
    /*а теперь новые выставим*/
    /*
    не проставляем - это при постобработке
    buf_chk-pay.exch-date
    buf_chk-pay.exch-time
    buf_chk-pay.exch-rate
    buf_chk-pay.exch-scale
    buf_chk-pay.calc-rate
    */
    define variable v-netto-sum-wr as decimal no-undo .
    assign
    buf_libthpos_chk-pay.discnt-sum = round(v-pay-discnt-sum, 2)
    buf_libthpos_chk-pay.discnt-rubl = round(v-pay-discnt-rubl, 2)
    buf_libthpos_chk-pay.discnt-base = round(v-pay-discnt-base, 2)
    buf_libthpos_chk-pay.discnt-r-b = round((if libthpos_context.r-b = {&r-b-rubl}
                                      then v-pay-discnt-rubl
                                      else v-pay-discnt-base), 2)
    buf_libthpos_chk-pay.brutto-doc = (if buf_libthpos_chk-pay.inversed then (v-tot-sum /* + v-pay-discnt-sum*/ ) else buf_libthpos_chk-pay.brutto-doc)
    buf_libthpos_chk-pay.brutto-rubl = (if buf_libthpos_chk-pay.inversed then (v-tot-rubl /*+ v-pay-discnt-rubl*/ ) else buf_libthpos_chk-pay.brutto-rubl)
    buf_libthpos_chk-pay.brutto-base = (if buf_libthpos_chk-pay.inversed then (v-tot-base /*+ v-pay-discnt-base*/ ) else buf_libthpos_chk-pay.brutto-base)
    buf_libthpos_chk-pay.brutto-r-b = (if libthpos_context.r-b = {&r-b-rubl}
                                      then buf_libthpos_chk-pay.brutto-rubl
                                      else buf_libthpos_chk-pay.brutto-base)
    v-netto-sum-wr = (if libthpos_context.r-b = {&r-b-rubl}
                      then v-rubl-sum
                      else v-base-sum)
    v-netto-sum  = round(v-netto-sum, 2)
    v-netto-sum  = round(v-curr-sum, 2)
    v-netto-rubl = round(v-rubl-sum, 2)
    v-netto-base = round(v-base-sum, 2)
    buf_libthpos_chk-pay.tot-sum = v-netto-sum
    buf_libthpos_chk-pay.tot-rubl = v-netto-rubl
    buf_libthpos_chk-pay.tot-base = v-netto-base
    buf_libthpos_chk-pay.r-sum = (v-netto-sum - v-netto-sum-wr) -
                                ((if libthpos_context.r-b = {&r-b-rubl}
                                  then v-pay-discnt-rubl
                                  else v-pay-discnt-base) - buf_libthpos_chk-pay.discnt-r-b)
      /*
    при постобработке
    buf_chk-pay.tot-rubl
    buf_chk-pay.tot-base
    */
    buf_libthpos_chk-pay.pass-pay = p-pass-pay
    .
    if v-inversed then do:
      assign
      buf_chk-pay.tot-sum   = v-netto-sum
      buf_chk-pay.src-qnty = p-src-qnty
      buf_chk-pay.bank-rate = v-bank-rate
      buf_chk-pay.bank-scale = v-bank-scale
      buf_chk-pay.cash-rate = v-cash-rate
      buf_chk-pay.pass-pay = p-pass-pay

      buf_chk-pay.time-oper = v-time
      buf_chk-pay.line-sign = (if libthpos_chk-context.chk-type = integer({&rcpt-sale})
                                then (buf_chk-pay.tot-sum >= 0)
                                else (buf_chk-pay.tot-sum <= 0)
                          )
      .
    end.
    if buf_libthpos_chk-pay.line-sign = yes
    and ((libthpos_chk-context.to-pay-r-b > 0) = (libthpos_chk-context.direction > 0))
    then do:
      /*прямое направление*/
      assign
      buf_libthpos_chk-pay.for-discnt-rubl = buf_libthpos_chk-pay.for-discnt-rubl + buf_libthpos_chk-pay.discnt-rubl
      buf_libthpos_chk-pay.for-discnt-doc  = buf_libthpos_chk-pay.for-discnt-doc + buf_libthpos_chk-pay.discnt-sum
      buf_libthpos_chk-pay.for-discnt-base = buf_libthpos_chk-pay.for-discnt-base + buf_libthpos_chk-pay.discnt-base
      buf_libthpos_chk-pay.for-discnt-r-b  = buf_libthpos_chk-pay.for-discnt-r-b +  (if libthpos_context.r-b = {&r-b-rubl}
                                                                                      then buf_libthpos_chk-pay.discnt-rubl
                                                                                      else buf_libthpos_chk-pay.discnt-base)
      .
    end.
    else do:
      /*ничего не прибавляем*/
    end.



    if libthpos_chk-context.sale-in-out
    and libthpos_context.pos-type = {&cd-type-ibs-th}
    and v-inversed
    then do:
      assign
      buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum + buf_chk-pay.tot-sum
      buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base + buf_libthpos_chk-pay.tot-base
      buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl + buf_libthpos_chk-pay.tot-rubl
      buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty + buf_chk-pay.src-qnty
      buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines + 1
      libthpos_context.pre-cash-counter = (if buf_libthpos_chk-pay.is-cash
                                          then  (libthpos_context.pre-cash-counter +
                                              (if libthpos_context.r-b = {&r-b-rubl}
                                              then buf_libthpos_chk-pay.tot-rubl
                                              else buf_libthpos_chk-pay.tot-base)
                                              )
                                              else libthpos_context.pre-cash-counter)
      .
    end.
    assign
    libthpos_chk-context.pay-discnt = libthpos_chk-context.pay-discnt + buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.pay-discnt-rubl = libthpos_chk-context.pay-discnt-rubl + buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.pay-discnt-base = libthpos_chk-context.pay-discnt-base + buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.netto = libthpos_chk-context.netto - buf_libthpos_chk-pay.discnt-r-b
    libthpos_chk-context.to-pay-r-b = libthpos_chk-context.to-pay-r-b -  buf_libthpos_chk-pay.brutto-r-b -
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-r-b else 0)
    libthpos_chk-context.has-pay-r-b = libthpos_chk-context.has-pay-r-b + (if libthpos_context.r-b = {&r-b-base}
                                                                            then v-netto-base
                                                                            else v-netto-rubl)
    libthpos_chk-context.change-sum = libthpos_chk-context.change-sum +
                                        (if buf_libthpos_chk-pay.line-sign = no
                                        then (if libthpos_context.r-b = {&r-b-base}
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.with-atr1-sum = libthpos_chk-context.with-atr1-sum +
                                        (if buf_libthpos_chk-pay.atr1
                                        then (if libthpos_context.r-b = {&r-b-base}
                                                then buf_libthpos_chk-pay.tot-base
                                                else buf_libthpos_chk-pay.tot-rubl)
                                        else 0)
    libthpos_chk-context.to-pay-rubl = libthpos_chk-context.to-pay-rubl - buf_libthpos_chk-pay.brutto-rubl -
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-rubl else 0)
    libthpos_chk-context.has-pay-rubl = libthpos_chk-context.has-pay-rubl + v-netto-rubl
    libthpos_chk-context.all-pay-rubl = libthpos_chk-context.all-pay-rubl - buf_libthpos_chk-pay.discnt-rubl
    libthpos_chk-context.to-pay-base = libthpos_chk-context.to-pay-base - buf_libthpos_chk-pay.brutto-base -
                                      (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-base else 0)
    libthpos_chk-context.has-pay-base = libthpos_chk-context.has-pay-base + v-netto-base
    libthpos_chk-context.all-pay-base = libthpos_chk-context.all-pay-base - buf_libthpos_chk-pay.discnt-base
    libthpos_chk-context.pay-r = libthpos_chk-context.pay-r + buf_libthpos_chk-pay.r-sum
    libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-subtotal}
                                then {&step-pay}
                                else libthpos_chk-context.step

    .
    if p-mode = {&deletion}
    and buf_chk-pay.tot-sum = 0 then do:
      delete buf_chk-pay.
      delete buf_libthpos_chk-pay.
      find last buf2_libthpos_chk-pay where
                buf2_libthpos_chk-pay.doc-code = libthpos_chk-context.doc-code use-index ln no-error.

      assign
      libthpos_chk-context.lnp = (if available buf2_libthpos_chk-pay
                                  then buf2_libthpos_chk-pay.line-num
                                  else 0)
      libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
      .
      if libthpos_chk-context.lnp = 0 then do:
        libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-pay}
                                    then {&step-subtotal}
                                    else libthpos_chk-context.step.
      end.
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    end.
    if available buf_libthpos_chk-pay then do:
      assign
      buf_libthpos_chk-pay.b-exch-date = v-exch-date
      buf_libthpos_chk-pay.b-exch-time = v-exch-time
      buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
      buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
      buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
      .
    end.
    if p-mode = {&add-def}
    and v-atr1 = yes then do:
      assign
      p-2-cdpay-code = p-cdpay-code
      p-2-curr-code = p-curr-code
      p-frpay-code = v-frpay-code
      .
    end.
    else do:
      assign
      p-2-cdpay-code = 1
      p-2-curr-code = libthpos_context.nalc
      p-2-frpay-code = 1
      .
    end.
    assign
    p-frpay-code = v-frpay-code
    p-tot-sum = v-netto-sum
    p-tot-rubl = v-netto-rubl
    p-tot-base = v-netto-base
    p-2-tot-sum  = (if p-2-curr-code = 0
                    then libthpos_chk-context.to-pay-rubl
                    else (if p-2-curr-code = libthpos_context.base-code
                          then libthpos_chk-context.to-pay-base
                          else (if libthpos_context.r-b = {&r-b-rubl}
                                then  libthpos_chk-context.to-pay-rubl / v-nalc-exch-rate * v-nalc-exch-scale
                                else libthpos_chk-context.to-pay-base / libthpos_chk-context.a-cash-rate * libthpos_chk-context.a-cash-scale
                                * v-nalc-exch-rate / v-nalc-exch-scale
                                )
                          )
                    )
    p-2-tot-rubl = libthpos_chk-context.to-pay-rubl
    p-2-tot-base = libthpos_chk-context.to-pay-base
    /*теперб проверим еще и переплату*/
    p-2-tot-sum  =  (if v-atr1 = no and v-has-overpay = 1 then 0 else p-2-tot-sum)
    p-2-tot-rubl =  (if v-atr1 = no and v-has-overpay = 1 then 0 else p-2-tot-rubl)
    p-2-tot-base =  (if v-atr1 = no and v-has-overpay = 1 then 0 else p-2-tot-base)
    p-get-qnty-method = v-get-qnty-method
    p-src-discnt-sum = (if p-mode = {&deletion} then 0 else (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-sum else 0))
    p-src-discnt-rubl = (if p-mode = {&deletion} then 0 else (if buf_libthpos_chk-pay.inversed then buf_libthpos_chk-pay.discnt-rubl else 0))
    p-for-discnt-doc =  (if p-mode = {&deletion} then 0 else buf_libthpos_chk-pay.for-discnt-doc)
    p-for-discnt-rubl = (if p-mode = {&deletion} then 0 else buf_libthpos_chk-pay.for-discnt-rubl)
    p-for-discnt-r-b = (if p-mode = {&deletion} then 0 else buf_libthpos_chk-pay.for-discnt-r-b)
    p-setted = yes
    .
    if available buf_libthpos_chk-pay then do:
      run printbuffer in this-procedure ( input (buffer buf_chk-pay:handle)).
      run printbuffer in this-procedure ( input (buffer buf_libthpos_chk-pay:handle)).
    end.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    if not v-inversed then do:
      dataset libthpos_receipt:reject-changes.
      undo main-block, return ''.
    end.
    else do:
      dataset libthpos_receipt:accept-changes.
    end.
    find first libthpos_chk-context.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    /*
    message "на выходе из pay-line"
    "p-tot-sum было "        v-na-vhode
    "p-mode"                 p-mode    skip
    "p-tot-sum"              p-tot-sum  skip
    "p-tot-rubl"             p-tot-rubl  skip
    "p-tot-base"             p-tot-base  skip
    "p-2-tot-sum"            p-2-tot-sum skip
    "p-2-tot-rubl"           p-2-tot-rubl skip
    "p-2-tot-base"           p-2-tot-base skip
    "p-2-tot-sum"            p-2-tot-sum  skip
    "p-2-tot-rubl"           p-2-tot-rubl skip
    "p-2-tot-base"           p-2-tot-base skip
    "p-get-qnty-method"      p-get-qnty-method skip
    "p-src-discnt-sum"       p-src-discnt-sum  skip
    "p-src-discnt-rubl"      p-src-discnt-rubl skip
    "p-for-discnt-doc"       p-for-discnt-doc  skip
    "p-for-discnt-rubl"      p-for-discnt-rubl skip
    "p-for-discnt-r-b"      p-for-discnt-r-b   skip
     view-as alert-box .
     */
  end. /*ne retry*/
end.

end procedure. /* libthpos_pay-line */

procedure libthpos_inst-line :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter p-cdpay-code as integer no-undo .
define input-output parameter p-curr-code as integer   no-undo .
define input  parameter p-par-code as integer no-undo .
define input  parameter p-src-qnty as decimal no-undo .
define output parameter p-frpay-code as integer no-undo .
define input  parameter p-pass-pay   as integer no-undo .
define input  parameter p-pay-card as character no-undo .
define input-output parameter p-tot-sum as decimal no-undo .
define input-output parameter p-tot-rubl as decimal no-undo .
define input-output parameter p-tot-base as decimal no-undo .
define output parameter p-get-qnty-method as character no-undo .
define output parameter p-setted as logical no-undo .

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-exch-rate as decimal no-undo .
define variable v-exch-scale as integer no-undo .
define variable v-exch-abbr as character no-undo .
define variable v-exch-date as date no-undo .
define variable v-exch-time as integer no-undo .
define variable v-bank-rate as decimal no-undo .
define variable v-bank-scale as integer no-undo .
define variable v-bank-abbr as character no-undo .
define variable v-cash-rate as decimal no-undo .
define variable v-calc-rate as integer no-undo .
define variable v-is-cash as logical no-undo .
define variable v-wth-code as integer   no-undo .
define variable v-src-val as integer   no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-par-rate as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-inversed as logical no-undo .
define variable v-err-mess as character no-undo .


define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_libthpos_cash-desk-attr for libthpos_cash-desk-attr.
define buffer buf_curr-shop for ub.curr-shop.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf2_libthpos_chk-pay for libthpos_chk-pay.

define buffer buf_libthpos_temp-cash-pay-list for libthpos_temp-cash-pay-list.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if not (p-mode = {&add-def}
            or
            p-mode = {&update}
            or
            p-mode = {&deletion}
            ) then do:
      v-err-mess = substitute("Неверное действие над строкой оплат чека = &1", p-mode).
      undo main-block, retry main-block.
    end.
    if p-mode = {&deletion}
    and (p-tot-sum = ?
    or p-tot-sum <> 0 ) then do:
      v-err-mess = substitute("Для удаления строки оплат чека сумма должна = 0").
      undo main-block, retry main-block.
    end.
    if p-mode = {&update}
    and (p-tot-sum = ?
    or p-tot-sum = 0)
    and not libthpos_chk-context.chk-type = integer({&cd-drawer})
    then do:
      v-err-mess = substitute("Для изменения строки оплат чека сумма не должна = 0 или ?").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.chk-type = integer({&cd-drawer})
    and p-tot-sum <> 0
    then do:
      v-err-mess = substitute("Для строки оплат в чеке типа ДЕКЛАРАЦИЯ сумма должна = 0").
      undo main-block, retry main-block.
    end.


    /*проверим что в таком чеке могут быть строки оплат*/
    if lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) = 0
    then do:
      v-err-mess = substitute("В чеке &1 с типом &2 строки оплат быть не может", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if p-tot-sum = ?
    and not (libthpos_chk-context.chk-type = integer({&encashment})
            or
            libthpos_chk-context.chk-type = integer({&expense})
            or
            (libthpos_chk-context.chk-type = integer({&pay-transfer})  and p-line-num = 2)
            ) then do:
      v-err-mess = substitute("В чеке &1 с типом &2 должна быть задана сумма", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if p-line-num > 2
    and libthpos_chk-context.chk-type = integer({&pay-transfer}) then do:
      v-err-mess = substitute("В чеке &1 с типом &2 может быть только 2 строки", p-doc-code, libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.

    case p-mode:
      when {&add-def} then do:
        if libthpos_chk-context.lnp + 1 <> p-line-num then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1&2должен быть &3"
                                      , p-line-num
                                      , {&new-line}
                                      , libthpos_chk-context.lnp + 1).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code = ? then do:
          assign
          p-cdpay-code = 1
          p-curr-code = libthpos_context.nalc
          v-is-cash = yes
          .
        end.
        else do:
        end.
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = p-cdpay-code
                and buf_cash-pay.curr-code = p-curr-code no-error.
          if not available buf_cash-pay then do:
            v-err-mess = substitute("Не найден тип кассового платежа с кодом &1 и валютой &2"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          assign
          v-is-cash = buf_cash-pay.is-cash
          .

        if buf_cash-pay.wth-code > 0 then do:
          find first buf_wealth no-lock where
                    buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
          if not available buf_wealth then do:
            v-err-mess = substitute("Не найдена МЦ с кодом &1 для типа кассового платежа с кодом &2 и валютой &3"
                                                    , buf_cash-pay.wth-code
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          assign
          v-get-qnty-method = buf_wealth.get-qnty-method
          v-wth-code = buf_wealth.wth-code
          .
        end.
        if p-par-code <> 0 then do:
          find first buf_wth-par no-lock where
                    buf_wth-par.par-code = p-par-code
                and buf_wth-par.wth-code = buf_cash-pay.wth-code no-error.
          if not available buf_wth-par then do:
            v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                    , p-par-code
                                                    , buf_cash-pay.wth-code
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          assign
          v-src-val = buf_wth-par.par-val
          v-par-rate = buf_wth-par.par-rate
          .
        end.
        if p-cdpay-code = 1 then do:
          v-frpay-code = 1.
        end.
        else do:
          find first buf_libthpos_temp-cash-pay-list where
                  buf_libthpos_temp-cash-pay-list.cdpay-code = p-cdpay-code
              and  buf_libthpos_temp-cash-pay-list.curr-code = p-curr-code no-error .
          if not available  buf_libthpos_temp-cash-pay-list then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 не удалось найти соответствующий код оплаты на ФР"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
          v-frpay-code = buf_libthpos_temp-cash-pay-list.frpay-code.
        end.
        /*найдем что суммы достаточно для инкассации*/
        /*  проверяется в  c d m o d e
        if libthpos_context.emulator-mode = 0
        and libthpos_chk-context.chk-type = integer({&encashment})
        then do:
           /*найдем доступную сумму */
          find first buf_libthpos_cash-counter where
                    buf_libthpos_cash-counter.curr-code = p-curr-code
                and buf_libthpos_cash-counter.pay-code = p-cdpay-code
                and buf_libthpos_cash-counter.wth-code = buf_cash-pay.wth-code
                and buf_libthpos_cash-counter.par-code = p-par-code
                    no-error.
          if not available buf_libthpos_cash-counter
          or buf_libthpos_cash-counter.tot-sum < (- p-tot-sum)
          then do:
            v-err-mess = substitute("Для типа кассового платежа с кодом &1 и валютой &2 нельзя сделать инкассацию - недостаточно суммы в ДЯ"
                                                    , p-cdpay-code
                                                    , p-curr-code).
            undo main-block, retry main-block.
          end.
        end.
        */
        assign
        v-tot-sum = p-tot-sum
        .
        if p-curr-code = 0 then do:
            assign
            v-cash-rate = 1
            v-calc-rate = 1
            v-bank-rate = 1
            v-bank-scale = 1
            v-exch-rate = 1
            v-exch-scale = 1
            v-exch-date = libthpos_chk-context.chk-date
            v-exch-time = libthpos_chk-context.chk-time
            v-tot-rubl = p-tot-sum
            v-tot-base = (if libthpos_context.base-code = 0
                          then v-tot-rubl
                          else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
        end.
        else do:
          if p-curr-code = libthpos_context.base-code then do:
            assign
            v-cash-rate = libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            v-calc-rate = 1
            v-bank-rate = libthpos_chk-context.a-bank-rate
            v-bank-scale = libthpos_chk-context.a-bank-scale
            v-exch-rate = libthpos_chk-context.a-bank-rate
            v-exch-scale = libthpos_chk-context.a-bank-scale
            v-exch-date = libthpos_chk-context.chk-date
            v-exch-time = libthpos_chk-context.chk-time
            v-tot-base = p-tot-sum
            v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            .
          end.
          else do:
            find  LAST buf_curr-shop NO-LOCK WHERE
                          buf_curr-shop.obj-type = libthpos_context.obj-type
                      AND buf_curr-shop.obj-code = libthpos_context.obj-code
                      AND buf_curr-shop.curr-code = p-curr-code
                      AND ( ( buf_curr-shop.exch-date = v-today
                            AND
                            buf_curr-shop.exch-time <= v-time ) OR
                            buf_curr-shop.exch-date < v-today ) NO-ERROR .
            if available buf_curr-shop then do:
              assign
              v-exch-rate = buf_curr-shop.exch-rate
              v-exch-scale = buf_curr-shop.exch-scale
              v-exch-date  = buf_curr-shop.exch-date
              v-exch-time  = buf_curr-shop.exch-time
              .
            end.
            else do:
              v-err-mess = substitute("Не найден курс валюты с кодом &1 для &2&3 на &4 &5"
                        , p-curr-code
                        , libthpos_context.obj-type
                        , libthpos_context.obj-code
                        , string(v-today, "99/99/9999")
                        , string(v-time, "HH:MM:SS")
                      ).
              undo main-block, retry main-block.
            end.
            { gbl/exchrate.i p-curr-code v-today v-bank-rate v-bank-scale v-bank-abbr no-error }
            if error-status:error then do:
              v-err-mess = substitute("Ошибка при определении курса валюты с кодом &1 на &2", p-curr-code, string(v-today, "99/99/9999")).
              undo main-block, retry main-block.
            end.
            assign
            v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
            .
          end.
        end.
      end. /*when {&add-def}*/
      when {&update}
      or
      when {&deletion} then do:
        for first buf_chk-pay share-lock where
                buf_chk-pay.doc-code = p-doc-code
            and buf_chk-pay.line-num = p-line-num,
            first buf_libthpos_chk-pay where
                buf_libthpos_chk-pay.doc-code = p-doc-code
            and buf_libthpos_chk-pay.line-num = p-line-num
        on error  undo main-block, retry main-block
        on stop   undo main-block, retry main-block
        on endkey undo main-block, retry main-block
        :
          leave.
        end.
        if not available buf_chk-pay then do:
          v-err-mess = substitute("Неверный № строки оплат чека = &1"
                                      , p-line-num
                                      ).
          undo main-block, retry main-block.
        end.
        if p-cdpay-code <> buf_chk-pay.pay-code
        or p-curr-code <> buf_chk-pay.curr-code
        then do:
          v-err-mess = substitute("Для уже имеющейся строки оплат чека (&1) нельзя изменить код типа касс. платеж и код валюты - были &2 &3"
                                      , p-line-num
                                      , buf_chk-pay.pay-code
                                      , buf_chk-pay.curr-code
                                      ).
                  undo main-block, retry main-block.
        end.
        if p-mode = {&update} then do:
          if p-par-code <> 0 then do:
            find first buf_wth-par no-lock where
                      buf_wth-par.par-code = p-par-code
                  and buf_wth-par.wth-code = buf_libthpos_chk-pay.wth-code no-error.
            if not available buf_wth-par then do:
              v-err-mess = substitute("Не найден номинал с кодом &1 для МЦ с кодом &2 для типа кассового платежа с кодом &3 и валютой &4"
                                                      , p-par-code
                                                      , buf_cash-pay.wth-code
                                                      , p-cdpay-code
                                                      , p-curr-code).
              undo main-block, retry main-block.
            end.
            assign
            v-src-val = buf_wth-par.par-val
            v-par-rate = buf_wth-par.par-rate
            .
          end.
        end.
        assign
        v-tot-sum  = p-tot-sum
        .
        if buf_libthpos_chk-pay.curr-code = 0 then do:
          assign
          v-tot-rubl = p-tot-sum
          v-tot-base = (if libthpos_context.base-code = 0
                        then v-tot-rubl
                        else  v-tot-rubl / libthpos_chk-context.a-cash-rate *  libthpos_chk-context.a-cash-scale)
            .
        end.
        else do:
          if p-curr-code = libthpos_context.base-code then do:
            assign
            v-tot-base = p-tot-sum
            v-tot-rubl = v-tot-base * libthpos_chk-context.a-cash-rate / libthpos_chk-context.a-cash-scale
            .
          end.
          else do:
            assign
            v-tot-rubl = v-tot-sum * buf_curr-shop.exch-rate / buf_curr-shop.exch-scale
            v-tot-base = v-tot-rubl / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale
            .
          end.
        end.
        assign
        v-bank-rate = buf_libthpos_chk-pay.bank-rate
        v-bank-scale = buf_libthpos_chk-pay.bank-scale
        v-cash-rate = buf_libthpos_chk-pay.cash-rate
        v-exch-date = buf_libthpos_chk-pay.b-exch-date
        v-exch-time = buf_libthpos_chk-pay.b-exch-time
        v-exch-rate = buf_libthpos_chk-pay.b-exch-rate
        v-exch-scale =  buf_libthpos_chk-pay.b-exch-scale
        v-calc-rate = buf_libthpos_chk-pay.b-calc-rate
        v-is-cash = buf_libthpos_chk-pay.is-cash
        v-frpay-code = buf_libthpos_chk-pay.frpay-code
        v-get-qnty-method = buf_libthpos_chk-pay.get-qnty-method
        v-wth-code = buf_libthpos_chk-pay.wth-code
        v-src-val = buf_libthpos_chk-pay.src-val
        .
      end.
    end case.
    if p-mode = {&add-def} then do:
      create buf_chk-pay.
      create buf_libthpos_chk-pay.
      assign
      buf_chk-pay.doc-code = p-doc-code
      libthpos_chk-context.lnp = libthpos_chk-context.lnp + 1
      libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
      buf_chk-pay.line-num = libthpos_chk-context.lnp
      buf_libthpos_chk-pay.recalc-line-num = buf_chk-pay.line-num
      buf_chk-pay.time-oper = v-time
      buf_chk-pay.pay-code = p-cdpay-code
      buf_chk-pay.curr-code = p-curr-code
      buf_chk-pay.pass-pay = 0
      buf_chk-pay.line-type  = ''
      buf_chk-pay.pay-card = ""
      buf_chk-pay.obj-type = libthpos_context.obj-type
      buf_chk-pay.obj-code = libthpos_context.obj-code
      buf_chk-pay.bank-rate = 1
      buf_chk-pay.bank-scale = 1
      buf_chk-pay.cash-rate = 1
      buf_chk-pay.is-error = no
      buf_chk-pay.line-sign = ((v-tot-sum > 0 ) = (libthpos_chk-context.direction > 0))
      buf_chk-pay.line-type = ""
      buf_chk-pay.out-code = ?
      buf_chk-pay.tot-sum = 0
      buf_chk-pay.pass-pay = p-pass-pay
      buf_chk-pay.par-code = p-par-code
      buf_chk-pay.src-val = v-src-val
      buf_chk-pay.wth-code = v-wth-code
      buf_libthpos_chk-pay.par-rate = v-par-rate
      .
      buffer-copy buf_chk-pay to buf_libthpos_chk-pay.
    end.
    find first buf_libthpos_cash-counter where
              buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
          and buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
          and buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
          and buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
              no-error.
    if not available buf_libthpos_cash-counter then do:
      create buf_libthpos_cash-counter.
      assign
      buf_libthpos_cash-counter.curr-code = buf_chk-pay.curr-code
      buf_libthpos_cash-counter.pay-code = buf_chk-pay.pay-code
      buf_libthpos_cash-counter.wth-code = buf_chk-pay.wth-code
      buf_libthpos_cash-counter.par-code = buf_chk-pay.par-code
      .
    end.
    assign
    buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum - buf_chk-pay.tot-sum
    buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base - buf_libthpos_chk-pay.tot-base
    buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl - buf_libthpos_chk-pay.tot-rubl
    buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty - buf_chk-pay.src-qnty
    buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines - 1
    libthpos_context.pre-cash-counter = (if buf_libthpos_cash-counter.is-cash
                                        then (libthpos_context.pre-cash-counter -
                                                (if libthpos_context.r-b = {&r-b-rubl}
                                                then buf_libthpos_chk-pay.tot-rubl
                                                else buf_libthpos_chk-pay.tot-base)
                                              )
                                              else libthpos_context.pre-cash-counter)
    .
    assign
    libthpos_chk-context.netto = libthpos_chk-context.netto - buf_libthpos_chk-pay.tot-sum * buf_libthpos_chk-pay.cash-rate
    .
    assign
    buf_libthpos_chk-pay.is-cash = v-is-cash
    buf_libthpos_chk-pay.get-qnty-method = v-get-qnty-method
    buf_libthpos_chk-pay.par-rate = v-par-rate
    buf_libthpos_chk-pay.wth-code = v-wth-code
    buf_libthpos_chk-pay.frpay-code = v-frpay-code
    buf_libthpos_chk-pay.tot-base = v-tot-base
    buf_libthpos_chk-pay.tot-rubl = v-tot-rubl
    buf_libthpos_chk-pay.tot-sum = v-tot-sum
    buf_libthpos_chk-pay.bank-rate = v-bank-rate
    buf_libthpos_chk-pay.bank-scale = v-bank-scale
    buf_libthpos_chk-pay.cash-rate = v-cash-rate
    buf_libthpos_chk-pay.b-exch-date = v-exch-date
    buf_libthpos_chk-pay.b-exch-time = v-exch-time
    buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
    buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
    buf_libthpos_chk-pay.b-calc-rate = v-calc-rate

    /*
    не проставляем - это при постобработке
    buf_chk-pay.exch-date
    buf_chk-pay.exch-time
    buf_chk-pay.exch-rate
    buf_chk-pay.exch-scale
    buf_chk-pay.calc-rate
    */
    buf_chk-pay.tot-sum = v-tot-sum
    buf_chk-pay.src-qnty = p-src-qnty
    buf_chk-pay.bank-rate = v-bank-rate
    buf_chk-pay.bank-scale = v-bank-scale
    buf_chk-pay.cash-rate = v-cash-rate
    buf_chk-pay.pass-pay = p-pass-pay
    buf_libthpos_chk-pay.pass-pay = p-pass-pay
    buf_chk-pay.time-oper = v-time
    buf_chk-pay.line-sign = (if libthpos_chk-context.chk-type = integer({&rcpt-sale})
                              then (buf_chk-pay.tot-sum >= 0)
                              else (buf_chk-pay.tot-sum <= 0)
                        )
    .
    assign
    libthpos_chk-context.netto = libthpos_chk-context.netto + buf_libthpos_chk-pay.tot-sum * buf_libthpos_chk-pay.cash-rate
    .
    assign
    buf_libthpos_cash-counter.pre-tot-sum = buf_libthpos_cash-counter.pre-tot-sum + buf_chk-pay.tot-sum
    buf_libthpos_cash-counter.pre-tot-base = buf_libthpos_cash-counter.pre-tot-base + buf_libthpos_chk-pay.tot-base
    buf_libthpos_cash-counter.pre-tot-rubl = buf_libthpos_cash-counter.pre-tot-rubl + buf_libthpos_chk-pay.tot-rubl
    buf_libthpos_cash-counter.pre-tot-lines = buf_libthpos_cash-counter.pre-tot-lines + 1
    buf_libthpos_cash-counter.pre-doc-qnty = buf_libthpos_cash-counter.pre-doc-qnty + buf_chk-pay.src-qnty
    libthpos_context.pre-cash-counter = (if buf_libthpos_chk-pay.is-cash
                                        then  (libthpos_context.pre-cash-counter +
                                            (if libthpos_context.r-b = {&r-b-rubl}
                                            then buf_libthpos_chk-pay.tot-rubl
                                            else buf_libthpos_chk-pay.tot-base)
                                            )
                                            else libthpos_context.pre-cash-counter)
    .
    assign
    libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-start}
                                then {&step-pay}
                                else libthpos_chk-context.step
    .
    if p-mode = {&deletion}
    and buf_chk-pay.tot-sum = 0 then do:
      delete buf_chk-pay.
      delete buf_libthpos_chk-pay.
      find last buf2_libthpos_chk-pay where
              buf2_libthpos_chk-pay.doc-code = libthpos_chk-context.doc-code use-index ln no-error.
      assign
      libthpos_chk-context.lnp = (if available buf_libthpos_chk-pay
                                  then buf_libthpos_chk-pay.line-num
                                  else 0)
      libthpos_chk-context.recalc-pline-num = libthpos_chk-context.lnp + 1
      .
      if libthpos_chk-context.lnp = 0 then do:
        libthpos_chk-context.step =  if libthpos_chk-context.step = {&step-pay}
                                    then {&step-start}
                                    else libthpos_chk-context.step.
      end.
      run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    end.
    if available buf_libthpos_chk-pay then do:
      assign
      buf_libthpos_chk-pay.b-exch-date = v-exch-date
      buf_libthpos_chk-pay.b-exch-time = v-exch-time
      buf_libthpos_chk-pay.b-exch-rate = v-exch-rate
      buf_libthpos_chk-pay.b-exch-scale = v-exch-scale
      buf_libthpos_chk-pay.b-calc-rate = v-calc-rate
      .
    end.
    assign
    p-frpay-code = v-frpay-code
    p-tot-sum = v-tot-sum
    p-tot-rubl = v-tot-rubl
    p-tot-base = v-tot-base
    p-get-qnty-method = v-get-qnty-method
    p-setted = yes
    .
    if available buf_libthpos_chk-pay then do:
      run printbuffer in this-procedure ( input (buffer buf_chk-pay:handle)).
      run printbuffer in this-procedure ( input (buffer buf_libthpos_chk-pay:handle)).
    end.
    run printbuffer in this-procedure ( input (buffer libthpos_chk-context:handle)).
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end.

end procedure. /* libthpos_inst-line */


procedure libthpos_getcheck :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-close-check as logical no-undo .

define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.

define variable v-doc-code as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define buffer buf_chk-doc for ub.chk-doc.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    session:set-wait-state("").
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.with-atr1-sum < libthpos_chk-context.change-sum
    and libthpos_chk-context.direction > 0
    and lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&annu-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&ord-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&petrol-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&petrol-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-gds-receipt-codes}) = 0
    then do:
      v-err-mess = substitute("Нельзя закрыть чек &1 - Сумма сдачи (&2) в чеке превышает сумму платежей (&3), на которые сдача разрешена"
                                            , libthpos_chk-context.change-sum
                                            , libthpos_chk-context.with-atr1-sum
                                            , p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.manual-discnt-sum >= libthpos_chk-context.src-tot-doc
    and lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) = 0
    then do:
      v-err-mess = substitute("Нельзя закрыть чек &1 - сумма всех ручных скидок &2 >= суммы брутто &3"
                                                , p-doc-code
                                                , libthpos_chk-context.manual-discnt-sum
                                                , libthpos_chk-context.src-tot-doc
                                                ).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc
    and lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) = 0
    then do:
      v-err-mess = substitute("Нельзя закрыть чек &1 - сумма скидок &2 >= суммы брутто &3"
                                                , p-doc-code
                                                , libthpos_chk-context.discnt
                                                , libthpos_chk-context.src-tot-doc
                                                ).
          undo main-block, retry main-block.
    end.
    if libthpos_context.salesman-mandatory > 0
    and lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&annu-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&ord-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&petrol-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&no-gds-receipt-codes}) = 0
    then do:
      for each buf_libthpos_chk-gds where
              buf_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code:
        if buf_libthpos_chk-gds.salesman = 0
        or buf_libthpos_chk-gds.salesman = ? then do:
          v-err-mess = substitute("Нельзя закрыть чек &1 - в одной или нескольких строках чека НЕ УКАЗАН ПРОДАВЕЦ").
          undo main-block, retry main-block.
        end.
      end.
    end.
    if libthpos_chk-context.getcheck > 0 then do:
      run libthpos_prepare-getcheck in this-procedure ( input p-doc-code) no-error.
      if error-status:error then do:
        v-err-mess = substitute("Ошибки при постобработке чека = &1&2&3&2&4"
                                                , p-doc-code
                                                , {&new-line}
                                                , error-status:get-message(1)
                                                , return-value
                                                ).
        undo main-block, retry main-block.
      end.
    end.
    libthpos_chk-context.getcheck = libthpos_chk-context.getcheck + 1.
    if libthpos_chk-context.step < {&step-pay}
    and lookup(string(libthpos_chk-context.chk-type), {&no-pay-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&annu-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&ord-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) = 0
    and lookup(string(libthpos_chk-context.chk-type), {&petrol-receipt-codes}) = 0
    and libthpos_chk-context.chk-type  <> integer({&rcpt-z-rep})
    and libthpos_chk-context.chk-type  <> integer({&rcpt-pre-z-rep})
    then do:
      v-err-mess = substitute("Чек &1 еще не закончен", p-doc-code).
      undo main-block, retry main-block.
    end.
    v-doc-code = libthpos_chk-context.doc-code.
    v-chk-type = libthpos_chk-context.chk-type.
    if lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) > 0 then do:
      { str/libchkvl_getwcheck.i
      "buffer libthpos_context:handle"
      ~{&add-def~}
      ''
      p-close-check
      yes
      libthpos_chk-context.netto
      v-doc-code
      no-error
      }
    end.
    else do:
      { str/libchkvl_getcheck.i
        "buffer libthpos_context:handle"
        ~{&add-def~}
        ''
        p-close-check
        yes
        libthpos_chk-context.netto
        libthpos_chk-context.lng
        "libthpos_chk-context.tot-discnt + libthpos_chk-context.pay-discnt"
        libthpos_chk-context.discnt-id
        v-doc-code
        no-error
      }
    end.
    if error-status:error then do:
      v-err-mess = substitute("Ошибка при валидации чека &1&2&3&2&4"
                                              , p-doc-code
                                              , {&new-line}
                                              , error-status:get-message(1)
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    if p-close-check then do:
      run libthpos_write-cash-counter in this-procedure no-error.
      if error-status:error then do:
        v-err-mess = substitute("&1&2&3", error-status:get-message(1), {&new-line}, return-value ).
        undo main-block, retry main-block.
      end.
      release locked_chk-doc no-error.
      if not available libthpos_chk-context then do:
        find first libthpos_chk-context.
      end.
      if not available libthpos_chk-context then do:
        find first libthpos_chk-context.
        if available libthpos_chk-context then do:
          run libthpos_print-dataset in this-procedure ( input no).
          delete libthpos_chk-context.
        end.
      end.
    end.
    else do:

    end.
    dataset libthpos_receipt:accept-changes.
    if p-close-check = yes then do:
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                      , input no).
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                      , input no).
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                      , input no).
      run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                      , input no).
    end.
    session:set-wait-state("").
  end. /*ne retry*/
end.
/*не в блоке !!!!*/
if p-close-check then do:
  run libthpos_process-sale in this-procedure ( input v-chk-type
                                              ,input v-doc-code) no-error.
end.
end procedure. /* libthpos_getcheck */

procedure libthpos_close-check :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-chk-num as integer no-undo .

define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-doc-code as character no-undo .

define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    find first buf_chk-doc share-lock where
            buf_chk-doc.doc-code = p-doc-code.
    assign
    buf_chk-doc.office = trim(replace(replace(buf_chk-doc.office, {&ready}, ''), {&comma-char} + {&comma-char}, {&comma-char}), {&comma-char})
    buf_chk-doc.chk-num  = p-chk-num
    v-chk-type = buf_chk-doc.chk-type
    v-doc-code = buf_chk-doc.doc-code
    .
    run libthpos_write-cash-counter in this-procedure no-error.
    if error-status:error then do:
      v-err-mess = substitute("&1&2&3", error-status:get-message(1), {&new-line}, return-value ).
      undo main-block, retry main-block.
    end.
    release buf_chk-doc no-error.
    release locked_chk-doc no-error.

    if not available libthpos_chk-context then do:
      find first libthpos_chk-context.
      if available libthpos_chk-context then do:
        run libthpos_print-dataset in this-procedure ( input no).
        delete libthpos_chk-context.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end. /*ne retry*/
end. /*doe*/
/*не в блоке !!!!*/
run libthpos_process-sale in this-procedure ( input v-chk-type
                                             ,input v-doc-code) no-error.
end procedure. /* libthpos_close-check */



procedure libthpos_annulate :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-chk-num as integer no-undo .

define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-doc-code as character no-undo .

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    assign
    v-chk-type = (if lookup(string(libthpos_chk-context.chk-type), {&ord-receipt-codes}) > 0
                  then integer({&rcpt-ord-annu})
                  else integer({&rcpt-annu})
                  )
    libthpos_chk-context.prev-chk-type = libthpos_chk-context.chk-type
    locked_chk-doc.prev-chk-type = locked_chk-doc.chk-type
    libthpos_chk-context.chk-type = v-chk-type
    locked_chk-doc.chk-type = v-chk-type
    locked_chk-doc.chk-num  = p-chk-num
    v-doc-code = locked_chk-doc.doc-code
    .
    run libthpos_getcheck in this-procedure ( input p-doc-code
                                              , input yes /*p-close-check*/
                                              ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("&1&2&3"
                                              , error-status:get-message(1)
                                              , {&new-line}
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end. /*ne retry*/
end. /*doe*/
/*не в блоке !!!!*/
run libthpos_process-sale in this-procedure ( input v-chk-type
                                             ,input v-doc-code) no-error.
end procedure. /* libthpos_annulate */

procedure libthpos_delete-chk-doc :
define input  parameter p-doc-code as character no-undo .

define variable v-chk-type as integer no-undo .
define variable v-err-mess as character no-undo .

define buffer buf_chk-doc for ub.chk-doc.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), {&wth-receipt-codes}) > 0 then do:
      v-err-mess = substitute("Нельзя удалить чек МЦ").
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), {&ord-receipt-codes}) > 0 then do:
      v-err-mess = substitute("Нельзя удалить чек с типом &1", libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    find first buf_chk-doc where
              buf_chk-doc.doc-code = p-doc-code.
    delete buf_chk-doc no-error.
    if error-status:error then do:
      release buf_chk-doc.
    end.
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context.
      if available libthpos_chk-context then do:
        run libthpos_print-dataset in this-procedure ( input no).
        delete libthpos_chk-context.
      end.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end. /*ne retry*/
end. /*doe*/
end procedure. /* libthpos_delete-chk-doc */



procedure libthpos_postpone :
define input  parameter p-doc-code as character no-undo .

define variable v-chk-type as integer no-undo .
define variable v-err-mess as character no-undo .

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if not (libthpos_chk-context.chk-type = integer({&rcpt-sale})
            or
            libthpos_chk-context.chk-type = integer({&rcpt-return})) then do:
      v-err-mess = substitute("Нельзя отложить чеки с типом &1", libthpos_chk-context.chk-type ).
      undo main-block, retry main-block.
    end.
    assign
    v-chk-type = (if libthpos_chk-context.chk-type = integer({&rcpt-sale})
                  then integer({&rcpt-ord-sale})
                  else integer({&rcpt-ord-return})
                  )
    libthpos_chk-context.chk-type = v-chk-type
    locked_chk-doc.chk-type = v-chk-type
    .
    if not can-find(first libthpos_chk-gds where
                          libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code)
    then do:
      v-err-mess = substitute("Нельзя отложить чек &1 - в чеке нет ни одной строки"
                             , p-doc-code).
      undo main-block, retry main-block.
    end.
    run libthpos_getcheck in this-procedure ( input p-doc-code
                                            , input yes /*p-close-check*/
                                            ) no-error.
    if error-status:error then do:
      v-err-mess = substitute("&1&2&3"
                                              , error-status:get-message(1)
                                              , {&new-line}
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end. /*ne retry*/
end. /*doe*/
end procedure. /* libthpos_postpone */

procedure libthpos_close-postpone :
define input parameter p-doc-code as character no-undo .
define input parameter p-postpone-doc-code as character no-undo .
define input parameter p-close-mode as integer no-undo . /*1 в оплаченные 0 в аннулированные отложенные*/

define variable v-err-mess as character no-undo .
define variable v-chk-type as integer no-undo .
define variable v-doc-code as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer bufp_chk-doc for ub.chk-doc.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    find first bufp_chk-doc exclusive-lock where
            bufp_chk-doc.doc-code = p-postpone-doc-code no-error no-wait.
    if not available bufp_chk-doc
    and not locked(bufp_chk-doc)
    then do:
      v-err-mess = substitute("Не найден чек &1", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    if locked(bufp_chk-doc) then do:
      v-err-mess = substitute("Занят чек &1", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(bufp_chk-doc.chk-type), {&ord-receipt-codes}) = 0 then do:
      v-err-mess = substitute("Чек &1 не является отложенным чеком, операция неприменима", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    if bufp_chk-doc.chk-type = integer({&rcpt-ord-annu}) then do:
      v-err-mess = substitute("Чек &1 аннулирован, операция неприменима", p-postpone-doc-code).
      undo main-block, retry main-block.
    end.
    v-chk-type = bufp_chk-doc.chk-type.
    v-doc-code = bufp_chk-doc.doc-code.
    case p-close-mode:
      when 1 then do:
        assign
        bufp_chk-doc.chk-type = bufp_chk-doc.chk-type + 100
        bufp_chk-doc.tot-doc = 0
        bufp_chk-doc.netto = 0
        bufp_chk-doc.discnt = 0
        bufp_chk-doc.sub-discnt = 0
        bufp_chk-doc.doc-qnty = 0
        bufp_chk-doc.ps = substitute(">>&1", p-doc-code)
        .
      end.
      when 0 then do:
        assign
        bufp_chk-doc.chk-type = integer({&rcpt-ord-annu})
        bufp_chk-doc.tot-doc = 0
        bufp_chk-doc.netto = 0
        bufp_chk-doc.discnt = 0
        bufp_chk-doc.sub-discnt = 0
        bufp_chk-doc.doc-qnty = 0
        .
      end.
    end case.
    dataset libthpos_receipt:accept-changes.
    run libthpos_print-dataset in this-procedure ( input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end. /*ne retry*/
end. /*doe*/
/*не в блоке !!!!*/
run libthpos_process-sale in this-procedure ( input v-chk-type
                                             ,input v-doc-code) no-error.

end procedure. /* libthpos_close-postpone */


procedure libthpos_annu-lost-check :
define input parameter p-doc-code as character no-undo .

define variable v-lng as integer no-undo .
define variable v-discnt-id as integer no-undo .
define variable v-doc-code as character no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-discnt for ub.chk-discnt.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    session:set-wait-state("").
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    session:set-wait-state("GENERAL").
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if available libthpos_chk-context
    and libthpos_chk-context.doc-code = p-doc-code
    then do:
      v-err-mess = substitute("В данный момент Вы работаете с чеком &1, операция аннуляции сбойного чека неприменима").
      undo main-block, retry main-block.
    end.
    find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = p-doc-code no-error no-wait.
    if not available buf_chk-doc
    and not locked(buf_chk-doc)
    then do:
      v-err-mess = substitute("Не найден чек &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if locked(buf_chk-doc) then do:
      v-err-mess = substitute("Занят чек &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if buf_chk-doc.chk-type = integer({&rcpt-ord-annu})
    or buf_chk-doc.chk-type = integer({&rcpt-annu})
    then do:
      v-err-mess = substitute("Чек &1 уже аннулирован, операция неприменима", p-doc-code).
      undo main-block, retry main-block.
    end.
    if trim(replace(replace(buf_chk-doc.office, {&gds-office}, ''), {&gds-goods}, ''), {&comma-char}) = ''
    and buf_chk-doc.correct = yes then do:
      v-err-mess = substitute("Чек &1 уже прошел валидацию, операция неприменима", p-doc-code).
      undo main-block, retry main-block.
    end.
    find last buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code no-error.
    find last buf_chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
        and buf_chk-discnt.record-type = 0  no-error.
    assign
    v-lng = (if available buf_chk-gds
            then buf_chk-gds.line-num
            else 0)
    v-discnt-id = (if available buf_chk-discnt
                  then buf_chk-discnt.discnt-id
                  else 0)
    .
    if lookup(string(buf_chk-doc.chk-type), {&ord-receipt-codes}) > 0 then do:
      assign
      buf_chk-doc.chk-type = integer({&rcpt-ord-annu})
      .
    end.
    else do:
      assign
      buf_chk-doc.chk-type = integer({&rcpt-annu})
      .
    end.
    v-doc-code = buf_chk-doc.doc-code.
    { str/libchkvl_getcheck.i
      "buffer libthpos_context:handle"
      ~{&update~}
      ~{&update~}
      yes
      yes
      0
      v-lng
      0
      v-discnt-id
      v-doc-code
      no-error
      }
    if error-status:error then do:
      v-err-mess = substitute("Ошибка при валидации чека &1&2&3&2&4"
                                              , p-doc-code
                                              , {&new-line}
                                              , error-status:get-message(1)
                                              , return-value ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
    run libthpos_print-dataset in this-procedure ( input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-context:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-pay:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-gds:table-handle)
                                                    , input no).
    run libthpos_tracking-changes in this-procedure ( input (buffer libthpos_chk-discnt:table-handle)
                                                    , input no).
    session:set-wait-state("").
  end. /*ne retry*/
end. /*doe*/
end procedure. /* libthpos_annu-lost-check */



procedure libthpos_write-cash-counter private:
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.

define variable v-err-mess as character no-undo .
define variable v-all-counter-base as decimal no-undo .
define variable v-all-counter-rubl as decimal no-undo .

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    for each buf_libthpos_cash-counter
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      if lookup(string(libthpos_chk-context.chk-type), {&annu-receipt-codes}) > 0 then do:
        assign
        buf_libthpos_cash-counter.pre-tot-sum = 0
        buf_libthpos_cash-counter.pre-tot-rubl = 0
        buf_libthpos_cash-counter.pre-tot-base = 0
        buf_libthpos_cash-counter.pre-tot-lines = 0
        buf_libthpos_cash-counter.pre-doc-qnty = 0
        .
      end.
      else do:
        assign
        buf_libthpos_cash-counter.tot-sum = buf_libthpos_cash-counter.tot-sum + buf_libthpos_cash-counter.pre-tot-sum
        buf_libthpos_cash-counter.pre-tot-sum = 0
        buf_libthpos_cash-counter.tot-rubl = buf_libthpos_cash-counter.tot-rubl + buf_libthpos_cash-counter.pre-tot-rubl
        buf_libthpos_cash-counter.pre-tot-rubl = 0
        buf_libthpos_cash-counter.tot-base = buf_libthpos_cash-counter.tot-base + buf_libthpos_cash-counter.pre-tot-base
        buf_libthpos_cash-counter.pre-tot-base = 0
        buf_libthpos_cash-counter.tot-lines = buf_libthpos_cash-counter.tot-lines + buf_libthpos_cash-counter.pre-tot-lines
        buf_libthpos_cash-counter.pre-tot-lines = 0
        buf_libthpos_cash-counter.doc-qnty = buf_libthpos_cash-counter.doc-qnty + buf_libthpos_cash-counter.pre-doc-qnty
        buf_libthpos_cash-counter.pre-doc-qnty = 0
        .
      end.
      /*запишем в БД*/
      find first buf_inkas-pay-wth where
                buf_inkas-pay-wth.inkas-code = ''
            and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
            and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
            and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
            and buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
            and buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
            and buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
            and buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
            and buf_inkas-pay-wth.cashier = 0
            and buf_inkas-pay-wth.chk-type = 0
            no-error.
      if not available buf_inkas-pay-wth then do:
        create buf_inkas-pay-wth.
        assign
        buf_inkas-pay-wth.inkas-code = ''
        buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
        buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
        buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
        buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
        buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
        buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
        buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
        buf_inkas-pay-wth.par-val = buf_libthpos_cash-counter.par-val
        buf_inkas-pay-wth.cashier = 0
        buf_inkas-pay-wth.chk-type = 0
        buf_inkas-pay-wth.doc-qnty = 0
        .
      end.
      assign
      buf_inkas-pay-wth.tot-sum = buf_libthpos_cash-counter.tot-sum
      buf_inkas-pay-wth.tot-base = buf_libthpos_cash-counter.tot-base
      buf_inkas-pay-wth.tot-rubl = buf_libthpos_cash-counter.tot-rubl
      buf_inkas-pay-wth.tot-lines = buf_libthpos_cash-counter.tot-lines
      buf_inkas-pay-wth.doc-qnty = buf_libthpos_cash-counter.doc-qnty
      v-all-counter-base = v-all-counter-base + buf_inkas-pay-wth.tot-base
      v-all-counter-rubl = v-all-counter-rubl + buf_inkas-pay-wth.tot-rubl
      .
    end .
    assign
    libthpos_context.cash-counter = libthpos_context.cash-counter + libthpos_context.pre-cash-counter
    libthpos_context.pre-cash-counter = 0
    .
    /*запишем в БД*/
    find first buf_inkas-pay-wth where
              buf_inkas-pay-wth.inkas-code = ''
          and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
          and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
          and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
          and buf_inkas-pay-wth.pay-code = 0
          and buf_inkas-pay-wth.curr-code = 0
          and buf_inkas-pay-wth.wth-code = 0
          and buf_inkas-pay-wth.par-code = 0
          and buf_inkas-pay-wth.cashier = 0
          and buf_inkas-pay-wth.chk-type = 0
          no-error.
    if not available buf_inkas-pay-wth then do:
      create buf_inkas-pay-wth.
      assign
      buf_inkas-pay-wth.inkas-code = ''
      buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
      buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
      buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
      buf_inkas-pay-wth.pay-code = 0
      buf_inkas-pay-wth.curr-code = 0
      buf_inkas-pay-wth.wth-code = 0
      buf_inkas-pay-wth.par-code = 0
      buf_inkas-pay-wth.par-val = 0
      buf_inkas-pay-wth.cashier = 0
      buf_inkas-pay-wth.chk-type = 0
      .
    end.
    assign
    buf_inkas-pay-wth.tot-rubl = v-all-counter-rubl
    buf_inkas-pay-wth.tot-base = v-all-counter-base
    .
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end. /*doe*/
end procedure. /* libthpos_write-cash-counter */

procedure libthpos_clear-cash-counter:
define buffer buf_libthpos_cash-counter for libthpos_cash-counter.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
define variable v-all-counter-base as decimal no-undo .
define variable v-all-counter-rubl as decimal no-undo .
define variable v-err-mess as character no-undo .

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if available libthpos_chk-context then do:
      v-err-mess = substitute("Выставлен контекст чека - операция обнуления невозможна").
      undo main-block, retry main-block.
    end.
    for each buf_libthpos_cash-counter
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      if buf_libthpos_cash-counter.is-cash then
      assign
      buf_libthpos_cash-counter.tot-sum = 0
      buf_libthpos_cash-counter.pre-tot-sum = 0
      buf_libthpos_cash-counter.tot-rubl = 0
      buf_libthpos_cash-counter.pre-tot-rubl = 0
      buf_libthpos_cash-counter.tot-base = 0
      buf_libthpos_cash-counter.pre-tot-base = 0
      buf_libthpos_cash-counter.tot-lines = 0
      buf_libthpos_cash-counter.pre-tot-lines = 0
      buf_libthpos_cash-counter.doc-qnty = 0
      buf_libthpos_cash-counter.pre-doc-qnty = 0
      .
      /*запишем в БД*/
      find first buf_inkas-pay-wth where
                buf_inkas-pay-wth.inkas-code = ''
            and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
            and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
            and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
            and buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
            and buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
            and buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
            and buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
            and buf_inkas-pay-wth.cashier = 0
            and buf_inkas-pay-wth.chk-type = 0
            no-error.
      if not available buf_inkas-pay-wth then do:
        create buf_inkas-pay-wth.
        assign
        buf_inkas-pay-wth.inkas-code = ''
        buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
        buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
        buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
        buf_inkas-pay-wth.pay-code = buf_libthpos_cash-counter.pay-code
        buf_inkas-pay-wth.curr-code = buf_libthpos_cash-counter.curr-code
        buf_inkas-pay-wth.wth-code = buf_libthpos_cash-counter.wth-code
        buf_inkas-pay-wth.par-code = buf_libthpos_cash-counter.par-code
        buf_inkas-pay-wth.par-val = buf_libthpos_cash-counter.par-val
        buf_inkas-pay-wth.cashier = 0
        buf_inkas-pay-wth.chk-type = 0
        buf_inkas-pay-wth.doc-qnty = 0
        .
      end.
      assign
      buf_inkas-pay-wth.tot-sum = buf_libthpos_cash-counter.tot-sum
      buf_inkas-pay-wth.tot-base = buf_libthpos_cash-counter.tot-base
      buf_inkas-pay-wth.tot-rubl = buf_libthpos_cash-counter.tot-rubl
      buf_inkas-pay-wth.tot-lines = buf_libthpos_cash-counter.tot-lines
      buf_inkas-pay-wth.doc-qnty = buf_libthpos_cash-counter.doc-qnty
      v-all-counter-base = v-all-counter-base + buf_inkas-pay-wth.tot-base
      v-all-counter-rubl = v-all-counter-rubl + buf_inkas-pay-wth.tot-rubl
      .
    end .
    assign
    libthpos_context.cash-counter = 0
    libthpos_context.pre-cash-counter = 0
    .
    /*запишем в БД*/
    find first buf_inkas-pay-wth where
              buf_inkas-pay-wth.inkas-code = ''
          and buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
          and buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
          and buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
          and buf_inkas-pay-wth.pay-code = 0
          and buf_inkas-pay-wth.curr-code = 0
          and buf_inkas-pay-wth.wth-code = 0
          and buf_inkas-pay-wth.par-code = 0
          and buf_inkas-pay-wth.cashier = 0
          and buf_inkas-pay-wth.chk-type = 0
          no-error.
    if not available buf_inkas-pay-wth then do:
      create buf_inkas-pay-wth.
      assign
      buf_inkas-pay-wth.inkas-code = ''
      buf_inkas-pay-wth.obj-type = libthpos_context.obj-type
      buf_inkas-pay-wth.obj-code = libthpos_context.obj-code
      buf_inkas-pay-wth.pay-desk = libthpos_context.cash-num
      buf_inkas-pay-wth.pay-code = 0
      buf_inkas-pay-wth.curr-code = 0
      buf_inkas-pay-wth.wth-code = 0
      buf_inkas-pay-wth.par-code = 0
      buf_inkas-pay-wth.par-val = 0
      buf_inkas-pay-wth.cashier = 0
      buf_inkas-pay-wth.chk-type = 0
      .
    end.
    assign
    buf_inkas-pay-wth.tot-rubl = v-all-counter-rubl
    buf_inkas-pay-wth.tot-base = v-all-counter-base
    .
  end. /*ne retry*/
end. /*doe*/
end procedure. /* libthpos_write-cash-counter */



procedure libthpos_create-flddf :
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define buffer buf_libthpos_flddf for  libthpos_flddf .

define variable v-err-mess as character no-undo .

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    assign
    v-bh0[{&context}] = (buffer libthpos_context:handle)
    v-bh[{&context}] = v-bh0[{&context}]
    v-bh0[{&chk-context}] = (buffer libthpos_chk-context:handle)
    v-bh[{&chk-context}] = v-bh0[{&chk-context}]
    v-bh0[{&chk-doc}] = (buffer libthpos_chk-doc:handle)
    v-bh[{&chk-doc}] = v-bh0[{&chk-doc}]
    v-bh0[{&chk-gds}] = (buffer libthpos_chk-gds:handle)
    v-bh[{&chk-gds}] = v-bh0[{&chk-gds}]
    v-bh0[{&chk-pay}] = (buffer libthpos_chk-pay:handle)
    v-bh[{&chk-pay}] = v-bh0[{&chk-pay}]
    v-bh0[{&chk-discnt}] = (buffer libthpos_chk-discnt:handle)
    v-bh[{&chk-discnt}] = v-bh0[{&chk-discnt}]
    .
    assign
    buffer libthpos_chk-context:handle:buffer-field("chk-date"):help = {&dr-flddf_doc_chk-date}
    buffer libthpos_chk-context:handle:buffer-field("chk-time"):help = {&dr-flddf_doc_chk-time}
    buffer libthpos_chk-gds:handle:buffer-field("line-num"):help = {&dr-flddf_gline_line-num}
    buffer libthpos_chk-pay:handle:buffer-field("line-num"):help = {&dr-flddf_pline_line-num}
    buffer libthpos_chk-pay:handle:buffer-field("tot-sum"):help = {&dr-flddf_pline_tot-sum}
    buffer libthpos_chk-gds:handle:buffer-field("src-qnty"):help = {&dr-flddf_gline_src-qnty}
    buffer libthpos_chk-gds:handle:buffer-field("src-price"):help = {&dr-flddf_gline_src-price}
    buffer libthpos_chk-gds:handle:buffer-field("src-code"):help = {&dr-flddf_gline_src-code}
    buffer libthpos_chk-gds:handle:buffer-field("b-code"):help = {&dr-flddf_gline_b-code}
    buffer libthpos_chk-gds:handle:buffer-field("src-sum"):help = {&dr-flddf_gline_src-base}
    buffer libthpos_chk-gds:handle:buffer-field("src-discnt"):help = {&dr-flddf_gline_src-discnt}
    buffer libthpos_chk-discnt:handle:buffer-field("discnt-value-pcnt"):help = {&dr-flddf_dline_discnt-value-pcnt}
    buffer libthpos_chk-discnt:handle:buffer-field("discnt-value-abs"):help = {&dr-flddf_dline_discnt-value-abs}
    buffer libthpos_chk-discnt:handle:buffer-field("value-type"):help = {&dr-flddf_dline_value-type}
    buffer libthpos_chk-discnt:handle:buffer-field("templ-rl-root"):help = {&dr-flddf_dline_templ-rl-root}
    buffer libthpos_chk-discnt:handle:buffer-field("object-sum"):help = {&dr-flddf_dline_object-sum}
    buffer libthpos_chk-discnt:handle:buffer-field("rule-num"):help = {&dr-flddf_dline_rule-num}
    .
    do v-ii = 1 to 6:
      do v-jj = 1 to v-bh[v-ii]:num-fields:
        v-bh[v-ii]:buffer-field(v-jj):private-data  = v-bh[v-ii]:buffer-field(v-jj):help.
        if v-bh[v-ii]:buffer-field(v-jj):private-data <> ?
        and v-bh[v-ii]:buffer-field(v-jj):private-data <> '' then do:
          find first buf_libthpos_flddf where
                    buf_libthpos_flddf.fld-df = v-bh[v-ii]:buffer-field(v-jj):private-data no-error.
          if not available buf_libthpos_flddf then do:
            create buf_libthpos_flddf.
            assign
            buf_libthpos_flddf.fld-df = v-bh[v-ii]:buffer-field(v-jj):private-data
            buf_libthpos_flddf.table-name_ = v-bh[v-ii]:table
            buf_libthpos_flddf.name_ = v-bh[v-ii]:name
            buf_libthpos_flddf.buffer_ = v-bh[v-ii]
            buf_libthpos_flddf.field-name_ = v-bh[v-ii]:buffer-field(v-jj):name
            buf_libthpos_flddf.buffer-field_ = v-bh[v-ii]:buffer-field(v-jj)
            buf_libthpos_flddf.table-no = v-ii
            .
          end.
          else do:
            message
            substitute("Неверно настроены регистры значений для расчета скидок и бонусов&1"  +
                        "регистр &2 для расчета скидок определен дважды&1" +
                        "обратитесь к администратору"
                        , {&new-line}
                        , v-bh[v-ii]:buffer-field(v-jj):private-data
                      )
            view-as alert-box error.
            return error.
          end.
        end.
      end.
    end.
    /*
    output to flddf.txt.
    for each buf_libthpos_flddf:
      export buf_libthpos_flddf.fld-df   buf_libthpos_flddf.table-name buf_libthpos_flddf.name_ buf_libthpos_flddf.fld-name_ .
    end.
    output close.
    */
  end. /*ne retry*/
end.
end procedure. /* libthpos_create-flddf */

procedure libthpos_set-gds-manual-discnt :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-line-num as integer no-undo .
define input  parameter p-value-type as integer no-undo .
define input  parameter p-discnt-value as decimal no-undo .
define output parameter p-setted as logical no-undo .
define output parameter p-next as character no-undo .
define input-output parameter p-src-discnt-sum as decimal no-undo .
define input-output parameter p-src-sum as decimal no-undo .
define input-output parameter p-src-sum-netto as decimal no-undo .

define variable v-discnt as decimal no-undo .
define variable v-pcnt as decimal no-undo .
define variable v-discnt-sum as decimal no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    find first buf_libthpos_chk-gds where buf_libthpos_chk-gds.line-num = p-line-num.
    /*непонятно зачем но без этого не работает - НЕ УДАЛЯТЬ!!!!!*/
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) > 0
    or lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) > 0
    then do:
      v-err-mess = substitute("Неверный тип чека для задания скидки = &1", libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.lng < p-line-num
    or not can-find(first libthpos_chk-gds where
                          libthpos_chk-gds.doc-code = p-doc-code
                      and libthpos_chk-gds.line-num = p-line-num) then do:
      v-err-mess = substitute("Неверный номер товарной строки для начисления скидки = &1", p-line-num).
      undo main-block, retry main-block.
    end.
    if not ( p-value-type = integer({&discnt-v-pcnt})
            or
            p-value-type = integer({&discnt-v-sum})) then do:
      v-err-mess = substitute("Неверный тип значения скидки = &1", p-value-type).
      undo main-block, retry main-block.
    end.
    if libthpos_context.manual-discnt = 0 then do:
      v-err-mess = substitute("Запрещены ручные скидки на данной кассе/магазине").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step >= {&step-pay} then do:
      v-err-mess = substitute("Уже есть строки оплаты").
      undo main-block, retry main-block.
    end.
    for first buf_chk-gds share-lock where
            buf_chk-gds.doc-code = p-doc-code
        and buf_chk-gds.line-num = p-line-num,
        first buf_libthpos_chk-gds where
              buf_libthpos_chk-gds.doc-code = p-doc-code
        and  buf_libthpos_chk-gds.line-num = p-line-num :
      leave.
    end.
    if buf_libthpos_chk-gds.without-gds-discnt > 0 then do:
      v-err-mess = substitute("На товаре стоит флаг запрета товарных скидок").
      undo main-block, retry main-block.
    end.
    case p-value-type:
      when integer({&discnt-v-pcnt}) then do:
        if p-discnt-value > 100 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1 (>= 100%)"
                                                  , p-discnt-value
                                                  ).
          undo main-block, retry main-block.
        end.
        assign
        v-discnt = buf_libthpos_chk-gds.src-price-netto *  p-discnt-value / 100
        v-pcnt = p-discnt-value
        v-discnt-sum = v-discnt *  buf_libthpos_chk-gds.src-qnty
        .
      end.
      when integer({&discnt-v-sum}) then do:
        if buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-price-netto - p-discnt-value  <= 0 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1&2Сумма по строке без этой скидки =&3"
                                                    , p-discnt-value
                                                    , {&new-line}
                                                    ,(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-price-netto)
                                                    ).
          undo main-block, retry main-block.
        end.
        assign
        v-discnt = p-discnt-value / buf_libthpos_chk-gds.src-qnty
        v-pcnt = p-discnt-value / buf_libthpos_chk-gds.src-price-netto * 100  / buf_libthpos_chk-gds.src-qnty
        v-discnt-sum = p-discnt-value
        .
      end.
    end case.
    if buf_libthpos_chk-gds.manual-discnt-id = 0 then do:
      create buf_libthpos_chk-discnt.
      assign
      buf_libthpos_chk-discnt.doc-code = p-doc-code
      buf_libthpos_chk-discnt.record-type = 0
      buf_libthpos_chk-discnt.line-type = integer({&discnt-gds})
      buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.discnt-id + 1
      libthpos_chk-context.discnt-id = libthpos_chk-context.discnt-id + 1
      buf_libthpos_chk-discnt.line-num = p-line-num
      libthpos_chk-context.lnd = libthpos_chk-context.lnd + 1
      buf_libthpos_chk-discnt.pay-desk = libthpos_context.cash-num
      buf_libthpos_chk-discnt.obj-type = libthpos_context.obj-type
      buf_libthpos_chk-discnt.obj-code = libthpos_context.obj-code
      buf_libthpos_chk-discnt.chk-date = libthpos_chk-context.chk-date
      buf_libthpos_chk-discnt.chk-time = libthpos_chk-context.chk-time
      buf_libthpos_chk-discnt.time-oper = buf_libthpos_chk-gds.time-oper
      buf_libthpos_chk-discnt.src-d-card = buf_libthpos_chk-gds.src-d-card
      buf_libthpos_chk-discnt.kateg = libthpos_chk-context.category
      buf_libthpos_chk-discnt.rank = 999999999
      buf_libthpos_chk-discnt.pass-discnt = integer({&discnt-p-manual})
      buf_libthpos_chk-discnt.rule-num = 0
      buf_libthpos_chk-discnt.templ-rl-root = 0
      buf_libthpos_chk-discnt.discnt-type = integer({&discnt-t-manual})
      buf_libthpos_chk-discnt.discnt-role = ''
      buf_libthpos_chk-discnt.object-line-num =  p-line-num
      buf_libthpos_chk-discnt.src-price-netto = buf_libthpos_chk-gds.src-price-netto
      buf_libthpos_chk-gds.manual-discnt-id = buf_libthpos_chk-discnt.discnt-id
      .
    end.
    else do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = p-line-num
        and  buf_libthpos_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = p-line-num
        and  buf_chk-discnt.discnt-id = buf_libthpos_chk-gds.manual-discnt-id:
        leave.
      end.
    end.
    assign
    /*надо вычесть из общего нетто - нетто товарное - сскидка на итог - скидка на оплаты*/
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-gds.manual-discnt-sum
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    /*надо вычесть из товарного нетто*/
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    /*надо вычесть из нетто-товарное - скидка на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (buf_chk-gds.write-off-code = ?
                                          or buf_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then
                                          ( - (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum))
                                          else 0)
    /*надо вычесть скидку из товарной скидки*/
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt - buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-gds.src-discnt-sum
    /*надо вычесть дельту  из товарной дельты*/
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r - buf_libthpos_chk-gds.r-sum
    buf_chk-gds.src-discnt = buf_chk-gds.src-discnt - buf_libthpos_chk-discnt.delta-discnt
    buf_libthpos_chk-gds.src-discnt = buf_libthpos_chk-gds.src-discnt - buf_libthpos_chk-discnt.delta-discnt
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price-netto + buf_libthpos_chk-discnt.delta-discnt
    buf_libthpos_chk-discnt.object-qnty =  buf_libthpos_chk-gds.src-qnty
    buf_libthpos_chk-discnt.object-sum =  buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-price-netto
    buf_libthpos_chk-discnt.discnt-value-abs =  v-discnt-sum
    buf_libthpos_chk-discnt.discnt-value-pcnt =  v-pcnt
    buf_libthpos_chk-discnt.delta-discnt  =  v-discnt
    buf_libthpos_chk-discnt.value-type = p-value-type
    .
    buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
    assign
    buf_chk-gds.src-discnt = buf_chk-gds.src-discnt + v-discnt
    buf_libthpos_chk-gds.src-discnt = buf_libthpos_chk-gds.src-discnt + v-discnt
    buf_libthpos_chk-gds.src-price-netto = buf_libthpos_chk-gds.src-price-netto - v-discnt
    buf_libthpos_chk-gds.price-base-netto = buf_libthpos_chk-gds.src-price-netto * buf_libthpos_chk-gds.cli-base-rate
    buf_libthpos_chk-gds.will-price-base  = buf_libthpos_chk-gds.start-src-price * buf_libthpos_chk-gds.cli-base-rate
    .
    assign
    buf_libthpos_chk-gds.src-discnt-sum = truncate(buf_libthpos_chk-gds.src-qnty * buf_libthpos_chk-gds.src-discnt, 2)
    buf_libthpos_chk-gds.r-sum = (buf_libthpos_chk-gds.src-qnty * (buf_libthpos_chk-gds.start-src-price - v-discnt)) -
                                (buf_libthpos_chk-gds.src-sum -  buf_libthpos_chk-gds.src-discnt-sum)
    buf_libthpos_chk-gds.manual-discnt-sum = buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-gds.manual-discnt-sum
    /*добавим в общее нетто*/
    libthpos_chk-context.netto = libthpos_chk-context.netto + (if (buf_libthpos_chk-gds.write-off-code = ?
                                          or buf_libthpos_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    /*добавим в товарное нетто*/
    libthpos_chk-context.gds-netto = libthpos_chk-context.gds-netto + (if (buf_libthpos_chk-gds.write-off-code = ?
                                          or buf_libthpos_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    /*добавим в нетто с учетом скидок на товар и на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto + (if (buf_libthpos_chk-gds.write-off-code = ?
                                          or buf_libthpos_chk-gds.write-off-code <= 0)
                                          and not libthpos_chk-context.is-petrol-check
                                          then (buf_chk-gds.src-sum - buf_libthpos_chk-gds.src-discnt-sum)
                                          else 0)
    /*добавим в товарные скидки*/
    libthpos_chk-context.gds-discnt = libthpos_chk-context.gds-discnt + buf_libthpos_chk-gds.src-discnt-sum
    libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-gds.src-discnt-sum
    /*добавим в товарные дельты*/
    libthpos_chk-context.gds-r = libthpos_chk-context.gds-r + buf_libthpos_chk-gds.r-sum
    .
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc
    and libthpos_chk-context.direction > 0
    then do:
      v-err-mess = substitute("Недопустимая величина скидки для чека &1, общая скидка по чеку (&1) больше товарной суммы (&2) Возможно не стоит применять ручную скидку"
                              , libthpos_chk-context.discnt
                              , libthpos_chk-context.src-tot-doc
                              ).
      undo main-block, retry main-block.
    end.

    if (buf_libthpos_chk-discnt.discnt-value-abs = 0.0 and buf_libthpos_chk-discnt.value-type = integer({&discnt-v-sum}))
    or (buf_libthpos_chk-discnt.discnt-value-pcnt = 0.0 and buf_libthpos_chk-discnt.value-type = integer({&discnt-v-pcnt}))
    then do:
      delete buf_libthpos_chk-discnt.
      delete buf_chk-discnt.
      buf_libthpos_chk-gds.manual-discnt-id = 0.
    end.
    assign
    libthpos_chk-context.recalc-gline-num = (if p-line-num <= libthpos_chk-context.lng
                                              then buf_libthpos_chk-gds.recalc-line-num
                                              else libthpos_chk-context.recalc-gline-num)
    p-src-discnt-sum = buf_libthpos_chk-gds.src-discnt-sum
    p-src-sum = buf_chk-gds.src-sum
    p-src-sum-netto = p-src-sum - p-src-discnt-sum
    p-setted = yes
    p-next = ''
    /*(if libthpos_chk-context.recalc-gline-num < libthpos_chk-context.lng + 1
              or libthpos_chk-context.step > {&step-gds}
              then substitute("recalc=&1,&2,&3"
                              ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                              ,(if libthpos_chk-context.step > {&step-gds} then 1 else 0)
                              ,(if libthpos_chk-context.step > {&step-subtotal} then 1 else 0)
                            )
              else "")*/
    .
    run libthpos_recalc-discnt in this-procedure no-error.
    if error-status:error then do:
      v-err-mess = substitute("Ош-ка при пересчете: &1 &2", return-value , error-status:get-message(1) ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end. /*doe*/

end procedure. /* libthpos_set-gds-manual-discnt */

procedure libthpos_set-subtotal-manual-discnt :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-value-type as integer no-undo .
define input  parameter p-discnt-value as decimal no-undo .
define output parameter p-setted as logical no-undo .
define output parameter p-next as character no-undo .
define input-output parameter p-st-r-b as decimal no-undo .
define input-output parameter p-st-rubl as decimal no-undo .
define input-output parameter p-st-base as decimal no-undo .
define input-output parameter p-tot-doc as decimal no-undo .
define input-output parameter p-discnt as decimal no-undo .

define variable v-discnt as decimal no-undo .
define variable v-pcnt as decimal no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_chk-discnt  for ub.chk-discnt.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:

  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if not available libthpos_chk-context then do:
      v-err-mess = substitute("Не выставлен контекст чека").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if lookup(string(libthpos_chk-context.chk-type), {&no-discnt-receipt-codes}) > 0
    or lookup(string(libthpos_chk-context.chk-type), {&no-calc-discnt-receipt-codes}) > 0
    then do:
      v-err-mess = substitute("Неверный тип чека для задания скидки = &1", libthpos_chk-context.chk-type).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.lng = 0
    or not can-find(first libthpos_chk-gds where
                          libthpos_chk-gds.doc-code = p-doc-code
                      ) then do:
      v-err-mess = substitute("Нет строк в чеке").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step < {&step-subtotal} then do:
      v-err-mess = substitute("Не был подведен итог в чеке").
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.step >= {&step-pay} then do:
      v-err-mess = substitute("Уже есть строки оплаты").
      undo main-block, retry main-block.
    end.


    if not ( p-value-type = integer({&discnt-v-pcnt})
            or
            p-value-type = integer({&discnt-v-sum})) then do:
      v-err-mess = substitute("Неверный тип значения скидки = &1", p-value-type).
      undo main-block, retry main-block.
    end.
    if libthpos_context.manual-discnt = 0 then do:
      v-err-mess = substitute("Запрещены ручные скидки на данной кассе/магазине").
      undo main-block, retry main-block.
    end.
    case p-value-type:
      when integer({&discnt-v-pcnt}) then do:
        if  p-discnt-value >= 100 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1 (>= 100%)"
                                                    , p-discnt-value
                                                    ).
          undo main-block, retry main-block.
        end.
      end.
      when integer({&discnt-v-sum}) then do:
        if libthpos_chk-context.st-for-discnt-r-b - p-discnt-value  <= 0 then do:
          v-err-mess = substitute("Недопустимая величина скидки = &1&2Сумма по чеку без этой скидки =&3"
                                                    , p-discnt-value
                                                    , {&new-line}
                                                    ,libthpos_chk-context.st-for-discnt-r-b
                                                    ).
          undo main-block, retry main-block.
        end.
      end.
    end.
    if libthpos_chk-context.manual-discnt-id <> 0 then do:
      for first buf_libthpos_chk-discnt where
              buf_libthpos_chk-discnt.doc-code = p-doc-code
        and  buf_libthpos_chk-discnt.record-type = 0
        and  buf_libthpos_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id,
        first buf_chk-discnt share-lock where
              buf_chk-discnt.doc-code = p-doc-code
        and  buf_chk-discnt.record-type = 0
        and  buf_chk-discnt.line-num = libthpos_chk-context.manual-discnt-ln
        and  buf_chk-discnt.discnt-id = libthpos_chk-context.manual-discnt-id:
        assign
        libthpos_chk-context.st-for-discnt-r-b = libthpos_chk-context.st-for-discnt-r-b + buf_libthpos_chk-discnt.discnt-value-abs
        .
        leave.
      end.
    end.
    case p-value-type:
      when integer({&discnt-v-pcnt}) then do:
        assign
        v-discnt = libthpos_chk-context.st-for-discnt-r-b *  p-discnt-value / 100
        v-pcnt = p-discnt-value
        .
      end.
      when integer({&discnt-v-sum}) then do:
        assign
        v-discnt = p-discnt-value
        v-pcnt = p-discnt-value / libthpos_chk-context.st-for-discnt-r-b * 100
        .
      end.
    end case.
    if libthpos_chk-context.manual-discnt-id = 0 then do:
      run cur-time in this-procedure ( output v-today, output v-time).
      create buf_libthpos_chk-discnt.
      assign
      buf_libthpos_chk-discnt.doc-code = p-doc-code
      buf_libthpos_chk-discnt.record-type = 0
      buf_libthpos_chk-discnt.line-type = integer({&discnt-receipt})
      buf_libthpos_chk-discnt.discnt-id = libthpos_chk-context.discnt-id + 1
      libthpos_chk-context.discnt-id = libthpos_chk-context.discnt-id + 1
      buf_libthpos_chk-discnt.line-num = libthpos_chk-context.lng
      libthpos_chk-context.lnd = libthpos_chk-context.lnd + 1
      buf_libthpos_chk-discnt.pay-desk = libthpos_context.cash-num
      buf_libthpos_chk-discnt.obj-type = libthpos_context.obj-type
      buf_libthpos_chk-discnt.obj-code = libthpos_context.obj-code
      buf_libthpos_chk-discnt.chk-date = libthpos_chk-context.chk-date
      buf_libthpos_chk-discnt.chk-time = libthpos_chk-context.chk-time
      buf_libthpos_chk-discnt.time-oper = v-time
      buf_libthpos_chk-discnt.src-d-card = libthpos_chk-context.src-d-card
      buf_libthpos_chk-discnt.kateg = libthpos_chk-context.category
      buf_libthpos_chk-discnt.rank = 999999999
      buf_libthpos_chk-discnt.pass-discnt = integer({&discnt-p-manual})
      buf_libthpos_chk-discnt.rule-num = 0
      buf_libthpos_chk-discnt.templ-rl-root = 0
      buf_libthpos_chk-discnt.discnt-type = integer({&discnt-t-manual})
      buf_libthpos_chk-discnt.discnt-role = ''
      buf_libthpos_chk-discnt.object-line-num =  libthpos_chk-context.lnd
      libthpos_chk-context.manual-discnt-id = buf_libthpos_chk-discnt.discnt-id
      libthpos_chk-context.manual-discnt-ln = libthpos_chk-context.lng
      .
    end.
    else do:
      assign
      buf_libthpos_chk-discnt.line-num = libthpos_chk-context.lng
      buf_chk-discnt.line-num = libthpos_chk-context.lng
      libthpos_chk-context.manual-discnt-ln = libthpos_chk-context.lng
      .
    end.
    assign
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum - buf_libthpos_chk-discnt.discnt-value-abs
    /*надо вычесть из общего нетто - нетто товарное - сскидка на итог - скидка на оплаты*/
    libthpos_chk-context.netto = libthpos_chk-context.netto + buf_libthpos_chk-discnt.discnt-value-abs
    /*надо вычесть из нетто-товарное - скидка на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto +  buf_libthpos_chk-discnt.discnt-value-abs
    /*надо вычесть из итоговых скидок*/
    libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt - buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.discnt = libthpos_chk-context.discnt - buf_libthpos_chk-discnt.discnt-value-abs

    /*надо вычесть дельту  из подитог дельты*/
    /*libthpos_chk-context.tot-r = libthpos_chk-context.tot-r - buf_libthpos_chk-discnt.r-sum*/
    buf_libthpos_chk-discnt.discnt-value-abs = truncate(v-discnt, 2)
    buf_libthpos_chk-discnt.discnt-value-pcnt = v-pcnt
    buf_libthpos_chk-discnt.delta-discnt  =  v-discnt
    buf_libthpos_chk-discnt.object-qnty =  libthpos_chk-context.src-qnty
    buf_libthpos_chk-discnt.object-sum =  libthpos_chk-context.st-for-discnt-r-b

    buf_libthpos_chk-discnt.value-type = p-value-type
    .
    buffer-copy buf_libthpos_chk-discnt to buf_chk-discnt.
    assign
    /*вычтем из общего нетто*/
    libthpos_chk-context.manual-discnt-sum = libthpos_chk-context.manual-discnt-sum + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.netto = libthpos_chk-context.netto - buf_libthpos_chk-discnt.discnt-value-abs
    /*добавим в нетто с учетом скидок на товар и на итог*/
    libthpos_chk-context.sub-netto = libthpos_chk-context.sub-netto  - buf_libthpos_chk-discnt.discnt-value-abs
    /*добавим в итоговые скидки*/
    libthpos_chk-context.tot-discnt = libthpos_chk-context.tot-discnt + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.discnt = libthpos_chk-context.discnt + buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.manual-tot-discnt = buf_libthpos_chk-discnt.discnt-value-abs
    libthpos_chk-context.manual-tot-dis-type = buf_libthpos_chk-discnt.value-type
    /*добавим в товарные дельты*/
    /*libthpos_chk-context.tot-r = libthpos_chk-context.tot-r + buf_libthpos_chk-gds.r-sum*/
    libthpos_chk-context.st-r-b = libthpos_rmethod(libthpos_context.rmethod-type
                                                    , libthpos_context.rmethod-coeff
                                                    , libthpos_chk-context.sub-netto)
    .
    if libthpos_chk-context.discnt >= libthpos_chk-context.src-tot-doc then do:
      v-err-mess = substitute("Недопустимая величина скидки для чека &1, общая скидка по чеку (&1) больше товарной суммы (&2)"
                              , libthpos_chk-context.discnt
                              , libthpos_chk-context.src-tot-doc
                              ).
      undo main-block, retry main-block.
    end.

    if (buf_libthpos_chk-discnt.discnt-value-abs = 0.0 and buf_libthpos_chk-discnt.value-type = integer({&discnt-v-sum}))
    or (buf_libthpos_chk-discnt.discnt-value-pcnt = 0.0 and buf_libthpos_chk-discnt.value-type = integer({&discnt-v-pcnt}))
    then do:
      delete buf_libthpos_chk-discnt.
      delete buf_chk-discnt.
      libthpos_chk-context.manual-discnt-id = 0.
    end.
    assign
    p-st-r-b = libthpos_chk-context.st-r-b
    libthpos_chk-context.st-rubl =  (if libthpos_context.r-b = {&r-b-rubl}
                                    or (libthpos_context.r-b = {&r-b-base}
                                        and
                                        libthpos_context.base-code = 0)
                                      then libthpos_chk-context.st-r-b
                                      else libthpos_chk-context.st-r-b * libthpos_chk-context.a-base-rate)
    p-st-rubl = libthpos_chk-context.st-rubl
    libthpos_chk-context.st-base = (if libthpos_context.r-b = {&r-b-base}
                                    or (libthpos_context.r-b = {&r-b-rubl}
                                        and
                                        libthpos_context.base-code = 0)
                                    then libthpos_chk-context.st-r-b
                                    else libthpos_chk-context.st-r-b / libthpos_chk-context.a-base-rate)
    p-st-base = libthpos_chk-context.st-base
    p-tot-doc = libthpos_chk-context.src-tot-doc
    libthpos_chk-context.tot-r = libthpos_chk-context.sub-netto - libthpos_chk-context.st-r-b
    p-discnt  = libthpos_chk-context.gds-discnt + libthpos_chk-context.tot-discnt
    libthpos_chk-context.to-pay-r-b   = libthpos_chk-context.st-r-b - libthpos_chk-context.has-pay-r-b
    libthpos_chk-context.to-pay-rubl  = (if libthpos_context.r-b = {&r-b-rubl}
                                            or (libthpos_context.r-b = {&r-b-base}
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b * libthpos_chk-context.cash-rate / libthpos_chk-context.cash-scale)
                                        - libthpos_chk-context.has-pay-rubl
    libthpos_chk-context.all-pay-rubl =  libthpos_chk-context.st-rubl - libthpos_chk-context.pay-discnt-rubl
    libthpos_chk-context.to-pay-base  = (if libthpos_context.r-b = {&r-b-base}
                                            or (libthpos_context.r-b = {&r-b-rubl}
                                                and
                                                libthpos_context.base-code  = 0)
                                            then libthpos_chk-context.st-r-b
                                            else libthpos_chk-context.st-r-b / libthpos_chk-context.cash-rate * libthpos_chk-context.cash-scale)
                                            - libthpos_chk-context.has-pay-base
    libthpos_chk-context.all-pay-base =  libthpos_chk-context.st-base - libthpos_chk-context.pay-discnt-base
    p-setted = yes
    p-next = /*(if libthpos_chk-context.step > {&step-gds}
              then substitute("recalc=&1,&2,&3"
                              ,min(libthpos_chk-context.recalc-gline-num, libthpos_chk-context.lng)
                              ,(if libthpos_chk-context.step > {&step-gds} then 1 else 0)
                              ,(if libthpos_chk-context.step > {&step-subtotal} then 1 else 0)
                            )
              else "")*/
              ''
    .
    run libthpos_recalc-discnt in this-procedure no-error.
    if error-status:error then do:
      v-err-mess = substitute("Ош-ка при пересчете: &1 &2", return-value , error-status:get-message(1) ).
      undo main-block, retry main-block.
    end.
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end. /*doe*/

end procedure. /* libthpos_set-subtotal-manual-discnt */

procedure libthpos_cfr :
define input  parameter p-doc-code as character no-undo .
define input parameter p-trans-type as integer no-undo .
define input parameter p-charkey_one as character no-undo .
define input parameter p-deckey_one as decimal no-undo .
define input parameter p-key#_one as integer no-undo .

define variable v-err-mess as character no-undo .
define buffer buf_cd-trans for ub.cd-trans.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
      if not available libthpos_chk-context then do:
        v-err-mess = substitute("Не выставлен контекст чека").
        undo main-block, retry main-block.
      end.
    end.
    if libthpos_chk-context.doc-code <> p-doc-code then do:
      v-err-mess = substitute("Неверный номер чека = &1", p-doc-code).
      undo main-block, retry main-block.
    end.
    if libthpos_chk-context.chk-type <> integer({&rcpt-z-rep})  then do:
      v-err-mess = substitute("Запись фискальных регистров возможна только внутри чека z-отчета").
      undo main-block, retry main-block.
    end.
    find first buf_cd-trans share-lock where
          buf_cd-trans.trans-type = p-trans-type
        and buf_cd-trans.obj-type = libthpos_context.obj-type
        and buf_cd-trans.obj-code = libthpos_context.obj-code
        and buf_cd-trans.pay-desk = libthpos_context.cash-num
        and buf_cd-trans.chk-id = libthpos_chk-context.doc-code
        and buf_cd-trans.charkey_one = p-charkey_one
    no-error.
    if not available buf_cd-trans then do:
      create buf_cd-trans.
      assign
      buf_cd-trans.db-num   = g#db-num
      buf_cd-trans.trans-id = next-value(s-cd-trans, {&db-name_schema})
      buf_cd-trans.trans-type = p-trans-type
      buf_cd-trans.obj-type = libthpos_context.obj-type
      buf_cd-trans.obj-code = libthpos_context.obj-code
      buf_cd-trans.chk-date = libthpos_chk-context.chk-date
      buf_cd-trans.chk-time = libthpos_chk-context.chk-time
      buf_cd-trans.chk-id = libthpos_chk-context.doc-code
      buf_cd-trans.z-number = libthpos_context.z-number
      buf_cd-trans.doc-code = libthpos_chk-context.doc-code
      buf_cd-trans.src-shift-date = libthpos_context.shift-date
      buf_cd-trans.src-shift-name = libthpos_context.shift-name
      buf_cd-trans.shift-name = libthpos_context.shift-name
      buf_cd-trans.shift-date = libthpos_context.shift-date
      buf_cd-trans.shift-num = libthpos_context.shift-num
      buf_cd-trans.pay-desk = libthpos_context.cash-num
      buf_cd-trans.charkey_one = p-charkey_one
      buf_cd-trans.deckey_one = p-deckey_one
      buf_cd-trans.key#_one = p-key#_one
      .
    end.
  end. /*ne retry*/
end.
end procedure. /* libthpos_cfr */


procedure libthpos_recalc-discnt private:
define variable v-setted as logical no-undo .
define variable v-b-code as integer no-undo .
define variable v-gds-code as integer no-undo .
define variable v-chk-name as character no-undo .
define variable v-second-name as character no-undo .
define variable v-src-price as decimal no-undo .
define variable v-src-discnt-sum as decimal no-undo .
define variable v-src-sum as decimal no-undo .
define variable v-src-sum-netto as decimal no-undo .
define variable v-next as character no-undo .
define variable  v-src-price-rubl as decimal no-undo .
define variable  v-src-discnt-sum-rubl as decimal no-undo .
define variable  v-src-sum-rubl as decimal no-undo .
define variable  v-src-sum-netto-rubl as decimal no-undo .
define variable v-err-mess as character no-undo .
define variable v-mode as character no-undo .
define variable v-ii as integer no-undo .
define variable v-st-rb as decimal no-undo .
define variable v-st-rubl as decimal no-undo .
define variable v-st-base as decimal no-undo .
define variable v-tot-doc as decimal no-undo .
define variable v-st-discnt as decimal no-undo .
define variable v-netto as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-all-discnt as decimal no-undo .
define variable v-all-discnt-rubl as decimal no-undo .
define variable v-all-discnt-base as decimal no-undo .
define variable v-unit-base as character no-undo .
define variable v-step as integer no-undo .

define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf2_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    v-step = libthpos_chk-context.step.
    if v-step >= {&step-gds} then do:
      for each buf_libthpos_chk-gds where
              buf_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code
          and buf_libthpos_chk-gds.line-num >= libthpos_chk-context.recalc-gline-num
      on error  undo main-block, retry main-block
      on stop   undo main-block, retry main-block
      on endkey undo main-block, retry main-block
      :
        v-ii = v-ii + 1.
        assign
        v-setted = no.
        if (libthpos_chk-context.chk-type = integer({&rcpt-return})
        or libthpos_chk-context.chk-type = integer({&rcpt-return-write-off})
        or libthpos_chk-context.chk-type = integer({&rcpt-ord-return})
          ) then do:
          v-src-price = buf_libthpos_chk-gds.src-price.
        end.
        else v-src-price = ?.
        assign
        v-mode = {&update} + {&comma-char} + "recalc" + {&comma-char} + "no-changes".
        run libthpos_gds-line  in this-procedure (
                                                    input libthpos_chk-context.doc-code
                                                  ,input buf_libthpos_chk-gds.line-num
                                                  ,input v-mode
                                                  ,input buf_libthpos_chk-gds.line-direction
                                                  ,input buf_libthpos_chk-gds.src-code
                                                  ,input-output buf_libthpos_chk-gds.src-qnty
                                                  ,input buf_libthpos_chk-gds.pump
                                                  ,input buf_libthpos_chk-gds.nozzle-code
                                                  ,input buf_libthpos_chk-gds.pl-code
                                                  ,input buf_libthpos_chk-gds.pass-gds
                                                  ,input buf_libthpos_chk-gds.write-off-code
                                                  ,input buf_libthpos_chk-gds.depart-id
                                                  ,output v-setted
                                                  ,output v-next
                                                  ,output v-b-code
                                                  ,output v-gds-code
                                                  ,output v-chk-name
                                                  ,output v-second-name
                                                  ,input-output v-src-price
                                                  ,output v-src-price-rubl
                                                  ,output v-src-discnt-sum
                                                  ,output v-src-discnt-sum-rubl
                                                  ,output v-src-sum
                                                  ,output v-src-sum-rubl
                                                  ,output v-src-sum-netto
                                                  ,output v-src-sum-netto-rubl
                                                  ,output v-unit-base
                                                  ) no-error.
        if not error-status:error
        and v-setted
        then do:
          assign
          libthpos_chk-context.recalc-gline-num  = min(libthpos_chk-context.recalc-gline-num  + 1, libthpos_chk-context.lng)
          .
        end.
        else do:
          v-err-mess = substitute("Строка &1: &2 &3"
                                  , buf_libthpos_chk-gds.line-num
                                  , return-value
                                  , error-status:get-message(1)
                                  ).
          undo main-block, retry main-block.
        end.
        find first buf2_libthpos_chk-gds no-lock where
                  buf2_libthpos_chk-gds.doc-code = libthpos_chk-context.doc-code
              and buf2_libthpos_chk-gds.line-num > buf_libthpos_chk-gds.line-num no-error.
        if available buf2_libthpos_chk-gds then do:
          v-mode = "no-changes".
        end.
        else do:
          v-mode = ''.
        end.
        run libthpos_sub-total  in this-procedure (
                                                    input libthpos_chk-context.doc-code
                                                    ,input v-mode
                                                    ,output v-setted
                                                    ,input-output v-st-rb
                                                    ,input-output v-st-rubl
                                                    ,input-output v-st-base
                                                    ,input-output v-tot-doc
                                                    ,input-output v-st-discnt
                                                    ,output v-netto
                                                    ,output v-netto-rubl
                                                    ,output v-netto-base
                                                    ,output v-all-discnt
                                                    ,output v-all-discnt-rubl
                                                    ,output v-all-discnt-base
                                                    ) no-error.
        if error-status:error
        or not v-setted
        then do:
          v-err-mess = substitute("Ошибка в Подитоге после строки &1: &2 &3"
                                  , buf_libthpos_chk-gds.line-num
                                  , return-value
                                  , error-status:get-message(1)
                                  ).
          undo main-block, retry main-block.
        end.
      end. /*    for each buf_libthpos_chk-gds*/
    end. /*if v-step >= {&step-gds} then do:*/
    if v-step >= {&step-pay} then do:
      /*todo*/
    end.
    dataset libthpos_receipt:accept-changes.
  end. /*ne retry*/
end.
end procedure. /* libthpos_recalc-discnt */


procedure libthpos_prepare-getcheck private:
define input parameter p-doc-code as character no-undo .

define variable v-err-mess as character no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.

main-block:
do
on error undo main-block, retry main-block
on stop undo main-block, retry main-block
on endkey undo main-block, retry main-block
:
  if retry then do:
    if v-err-mess = '' then do:
      v-err-mess = substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
    end.
    dataset libthpos_receipt:reject-changes.
    return error v-err-mess.
  end.
  else do:
    find first buf_chk-doc exclusive-lock where buf_chk-doc.doc-code = p-doc-code.
    assign
    buf_chk-doc.netto = 0
    buf_chk-doc.tot-doc = 0
    buf_chk-doc.discnt = 0
    buf_chk-doc.sub-discnt = 0
    buf_chk-doc.correct = yes
    buf_chk-doc.doc-qnty = 0
    buf_chk-doc.office = ''
    .
    for each buf_chk-discnt where
              buf_chk-discnt.doc-code = p-doc-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      if buf_chk-discnt.record-type = 0 then NEXT.
      if buf_chk-discnt.record-type = 4  then NEXT.
      delete buf_chk-discnt.
    end.
    for each buf_chk-gds-pay where buf_chk-gds-pay.doc-code = p-doc-code
    on error  undo main-block, retry main-block
    on stop   undo main-block, retry main-block
    on endkey undo main-block, retry main-block
    :
      delete buf_chk-gds-pay.
    end.
  end. /*ne retry*/
end.
end procedure. /* libthpos_prepare-getcheck */


procedure libthpos_tracking-changes private :
define input  parameter p-tbl-handle as handle no-undo .
define input  parameter p-on-off as logical   no-undo .

p-tbl-handle:tracking-changes = p-on-off.

end procedure. /* libthpos_tracking-changes private */

procedure libthpos_undo :
define buffer buf_libthpos_chk-doc for libthpos_chk-doc.
define buffer buf_libthpos_chk-gds for libthpos_chk-gds.
define buffer buf_libthpos_chk-pay for libthpos_chk-pay.
define buffer buf_libthpos_chk-discnt for libthpos_chk-discnt.

do
on error undo, return error return-value
:

  for each undo_libthpos_chk-doc:
    case buffer undo_libthpos_chk-doc:handle:row-state:
      when row-deleted then do:
      end.
      when row-modified then do:
        buffer-copy undo_libthpos_chk-doc to libthpos_chk-context.
      end.
      when row-created then do:
      end.
    end.
  end.
  for each undo_libthpos_chk-context:
    case buffer undo_libthpos_chk-context:handle:row-state:
      when row-deleted then do:
      end.
      when row-modified then do:
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
      end.
    end.
  end.
  for each undo_libthpos_chk-gds:
    case buffer undo_libthpos_chk-gds:handle:row-state:
      when row-deleted then do:
         create buf_libthpos_chk-gds.
         buffer-copy undo_libthpos_chk-gds to buf_libthpos_chk-gds.
      end.
      when row-modified then do:
        find first buf_libthpos_chk-gds where
                  buf_libthpos_chk-gds.doc-code = undo_libthpos_chk-gds.doc-code
              and buf_libthpos_chk-gds.line-num = undo_libthpos_chk-gds.line-num.
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
        find first buf_libthpos_chk-gds where
                  buf_libthpos_chk-gds.doc-code = undo_libthpos_chk-gds.doc-code
              and buf_libthpos_chk-gds.line-num = undo_libthpos_chk-gds.line-num.
         delete buf_libthpos_chk-gds.
      end.
    end.
  end.
  for each undo_libthpos_chk-pay:
    case buffer undo_libthpos_chk-pay:handle:row-state:
      when row-deleted then do:
         create buf_libthpos_chk-pay.
         buffer-copy undo_libthpos_chk-pay to buf_libthpos_chk-pay.
      end.
      when row-modified then do:
        find first buf_libthpos_chk-pay where
                  buf_libthpos_chk-pay.doc-code = undo_libthpos_chk-pay.doc-code
              and buf_libthpos_chk-pay.line-num = undo_libthpos_chk-pay.line-num.
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
        find first buf_libthpos_chk-pay where
                  buf_libthpos_chk-pay.doc-code = undo_libthpos_chk-pay.doc-code
              and buf_libthpos_chk-pay.line-num = undo_libthpos_chk-pay.line-num.
         delete buf_libthpos_chk-pay.
      end.
    end.
  end.
  for each undo_libthpos_chk-discnt:
    case buffer undo_libthpos_chk-discnt:handle:row-state:
      when row-deleted then do:
         create buf_libthpos_chk-discnt.
         buffer-copy undo_libthpos_chk-discnt to buf_libthpos_chk-discnt.
      end.
      when row-modified then do:
        find first buf_libthpos_chk-discnt where
                  buf_libthpos_chk-discnt.doc-code = undo_libthpos_chk-discnt.doc-code
              and buf_libthpos_chk-discnt.line-num = undo_libthpos_chk-discnt.line-num.
        buffer-copy undo_libthpos_chk-context to libthpos_chk-context.
      end.
      when row-created then do:
        find first buf_libthpos_chk-discnt where
                  buf_libthpos_chk-discnt.doc-code = undo_libthpos_chk-discnt.doc-code
              and buf_libthpos_chk-discnt.line-num = undo_libthpos_chk-discnt.line-num.
         delete buf_libthpos_chk-discnt.
      end.
    end.
  end.
end.

end procedure. /* libthpos_undo */


procedure libthpos_print-dataset :
define input parameter p-forced as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

do
on error undo, return error
:
  if search("print-xml.xml") <> ?
  or p-forced
  then do:
    if not available libthpos_chk-context then do:
      find first libthpos_chk-context no-error.
    end.
    if available libthpos_chk-context then do:
      libthpos_chk-context.print-copy-num = libthpos_chk-context.print-copy-num + 1.
      run print-xml in this-procedure ( input (dataset libthpos_receipt:handle)
                                          ,input substitute("&1_&2"
                                                            ,libthpos_chk-context.doc-code
                                                            ,libthpos_chk-context.print-copy-num)).
     find first libthpos_chk-context.
    end.
    else do:
      loc-print-copy-num = loc-print-copy-num + 1.
      run print-xml in this-procedure ( input (dataset libthpos_receipt:handle)
                                          ,input substitute("&1_&2"
                                                            ,loc-print-doc-code
                                                            ,loc-print-copy-num)).
    end.
    find first libthpos_chk-doc no-error.
    run cur-time in this-procedure ( output v-today, output v-time).
     run print-xml in this-procedure ( input (dataset libthpos_context:handle)
                                        ,input substitute("thpos_context_&1-&2-&3_&4"
                                                          , string(year(v-today), "9999")
                                                          , string(month(v-today), "99")
                                                          , string(day(v-today), "99")
                                                          , replace(string(v-time, "HH:MM:SS"), ":", "-")
                                                           )
                                        ).
     run print-xml in this-procedure ( input (dataset libthpos_params:handle)
                                        ,input substitute("thpos_params_&1-&2-&3_&4"
                                                          , string(year(v-today), "9999")
                                                          , string(month(v-today), "99")
                                                          , string(day(v-today), "99")
                                                          , replace(string(v-time, "HH:MM:SS"), ":", "-")
                                                           )
                                        ).


  end.
end.

end procedure. /* libthpos_print-dataset */


procedure libthpos_process-sale :
define input parameter p-chk-type as integer no-undo .
define input parameter p-doc-code as character no-undo .
define variable v-log-handle as handle no-undo .
if  libthpos_context.process-sale
and lookup(string(p-chk-type), {&no-inkas-receipt-codes}) = 0
and lookup(string(p-chk-type), {&wth-receipt-codes}) = 0
then do:
  if not valid-handle(libthpos_context.p-log-handle) then do:
    { gbl/get-lgh.i v-log-handle no-error }
  end.
  else do:
    v-log-handle = libthpos_context.p-log-handle.
  end.
  run str/afgetchk.p (
                       input libthpos_context.parparentproc
                      ,input this-procedure:handle
                      ,input v-log-handle
                      ,input (libthpos_context.obj-type + {&delim-par}  +
                             string(libthpos_context.obj-code) + {&delim-par} +
                             p-doc-code /*на перспективу*/)
                      ) no-error.
end.
end procedure. /* libthpos_process-sale */