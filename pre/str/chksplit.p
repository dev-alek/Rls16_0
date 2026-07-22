block-level on error undo, throw.
define input-output parameter p-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chksplit.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chksplit.p $":U .
define variable vss-description as character no-undo init "Утилита деления чеков на товары и услуги".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
DEFINE VARIABLE v-office as logical no-undo .
DEFINE VARIABLE v-sum-goods like ub.chk-doc.tot-doc .
DEFINE VARIABLE v-sum-office like ub.chk-doc.tot-doc .
DEFINE VARIABLE v-discnt-goods like ub.chk-doc.discnt .
DEFINE VARIABLE v-discnt-office like ub.chk-doc.discnt .
DEFINE VARIABLE v-netto-goods like ub.chk-doc.netto .
DEFINE VARIABLE v-netto-office like ub.chk-doc.netto .
DEFINE VARIABLE v-write-off-goods like ub.chk-doc.netto .
DEFINE VARIABLE v-write-off-office like ub.chk-doc.netto .
DEFINE VARIABLE v-is-office as logical no-undo .
DEFINE VARIABLE v-ratio-goods-sum as decimal no-undo .
DEFINE VARIABLE v-ratio-office-sum as decimal no-undo .
DEFINE VARIABLE v-ratio-goods-netto as decimal no-undo .
DEFINE VARIABLE v-ratio-office-netto as decimal no-undo .
DEFINE VARIABLE v-ratio-goods-discnt as decimal no-undo .
DEFINE VARIABLE v-ratio-office-discnt as decimal no-undo .
DEFINE VARIABLE v-ratio-goods-bonus as decimal no-undo .
DEFINE VARIABLE v-ratio-office-bonus as decimal no-undo .
DEFINE VARIABLE v-object-sum as decimal no-undo .
DEFINE VARIABLE v-object-sum-bonus as decimal no-undo .
DEFINE VARIABLE v-object-sum-goods as decimal no-undo .
DEFINE VARIABLE v-object-sum-office as decimal no-undo .
DEFINE VARIABLE v-object-sum-goods-bonus as decimal no-undo .
DEFINE VARIABLE v-object-sum-office-bonus as decimal no-undo .
DEFINE VARIABLE v-tot-doc-annu as decimal no-undo .
DEFINE VARIABLE v-netto-annu as decimal no-undo .
DEFINE VARIABLE current-line-num like ub.chk-discnt.line-num no-undo .
DEFINE VARIABLE current-line-num-bonus like ub.chk-discnt.line-num no-undo .
DEFINE VARIABLE num-pay as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-is-annu as logical no-undo .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf1_chk-doc for ub.chk-doc.
define buffer buf2_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf1_chk-gds for ub.chk-gds.
define buffer buf2_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf1_chk-pay for ub.chk-pay.
define buffer buf2_chk-pay for ub.chk-pay.
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf1_chk-discnt for ub.chk-discnt.
define buffer buf2_chk-discnt for ub.chk-discnt.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define temp-table temp-goods no-undo
  field line-num like ub.chk-gds.line-num
  field object-sum like ub.chk-discnt.object-sum
  index pi is unique primary
  line-num.
define temp-table temp-office no-undo
  field line-num like ub.chk-gds.line-num
  field object-sum like ub.chk-discnt.object-sum
  index pi is unique primary
  line-num.
_main:
do
on error undo, return error
:
  find first buf_chk-doc exclusive-lock where
            recid(buf_chk-doc) = p-rec no-error .
  if not avail buf_chk-doc then do:
    undo, return error substitute("не найден чек: recid &1"
                                  ,p-rec
                                  ).
  end.
  if buf_chk-doc.out-code <> ? then do:
    undo, return error substitute("чек &1 привязан к продаже", buf_chk-doc.doc-code).
  end.
  if buf_Chk-doc.chk-type = integer('8':U) then do:
    assign
    v-is-annu = yes.
  end.
  if buf_chk-doc.office = 'т':U
  or buf_chk-doc.office = 'у':U then return.
  if not trim(trim(trim(trim(buf_chk-doc.office, 'т':U), 'у':U), chr(44))) = '':U
  or not(lookup('т':U, buf_chk-doc.office) > 0
    and lookup('у':U, buf_chk-doc.office) > 0 )
  then do:
    return substitute("чек &1 не может быть разбит на товары и услуги&2имеются ошибки в чеке&3"
                                   ,buf_chk-doc.doc-code
                                   ,chr(10)
                                   ,buf_chk-doc.office).
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  create buf1_chk-doc.
  buffer-copy buf_chk-doc except doc-code to buf1_chk-doc
  assign
  buf1_chk-doc.doc-code = buf_chk-doc.doc-code + "-":U + 'т':U
  buf1_chk-doc.PS = buf1_chk-doc.ps + "@":U + "split":U
  .
  assign
  p-rec = recid(buf1_chk-doc)
  .
  create buf2_chk-doc.
  buffer-copy buf_chk-doc except doc-code to buf2_chk-doc
  assign
  buf2_chk-doc.doc-code = buf_chk-doc.doc-code + "-":U + 'у':U
  buf2_chk-doc.PS = buf2_chk-doc.ps + "@":U + "split":U
  .
  for each buf_chk-gds where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code:
    find first buf_bar-code no-lock where
               buf_bar-code.b-code = buf_chk-gds.b-code no-error .
    if not available buf_bar-code then do:
      undo _main, return error substitute("не найден бар-код &1:&2чек &3 строка &4"
                                         , buf_chk-gds.b-code
                                         , chr(10)
                                         , buf_chk-doc.doc-code
                                         , buf_chk-gds.line-num)
                                         .
    end.
    find first buf_goods no-lock where
               buf_goods.gds-code = buf_bar-code.gds-code no-error .
    if not available buf_goods then do:
      undo _main, return error substitute("не найден товар для бар-кода &1:&2чек &3 строка &4"
                                         , buf_chk-gds.b-code
                                         , chr(10)
                                         , buf_chk-doc.doc-code
                                         , buf_chk-gds.line-num)
                                         .
    end.
    assign
    v-office = trim(buf_chk-gds.line-type, chr(44)) begins 'у':U
    .
    case v-office:
      when no then do:
        if v-is-annu then do:
          assign
          v-tot-doc-annu = v-tot-doc-annu + buf_chk-gds.src-price * buf_chk-gds.src-qnty
          v-sum-goods = v-sum-goods + buf_chk-gds.src-price * buf_chk-gds.src-qnty
          v-discnt-goods = v-discnt-goods + buf_chk-gds.src-discnt * buf_chk-gds.src-qnty
          v-netto-goods = v-netto-goods + (buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty
          v-netto-annu = v-netto-annu + (buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty
          v-write-off-goods = v-write-off-goods + (if buf_chk-gds.write-off-code <> 0
                                                  and buf_chk-gds.write-off-code <> ?
                                                  then ((if buf_chk-gds.write-off-code > 0 then 1 else - 1) *
                                                          buf_chk-gds.src-qnty * (buf_chk-gds.src-price - buf_chk-gds.src-discnt)
                                                        )
                                                  else 0)
          .
        end.
        else do:
          assign
          v-sum-goods = v-sum-goods + buf_chk-gds.price-base * buf_chk-gds.doc-qnty
          v-discnt-goods = v-discnt-goods + buf_chk-gds.discnt * buf_chk-gds.doc-qnty
          v-netto-goods = v-netto-goods + (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          v-netto-annu = v-netto-annu + (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          v-write-off-goods = v-write-off-goods + (if buf_chk-gds.write-off-code <> 0
                                                  and buf_chk-gds.write-off-code <> ?
                                                  then ((if buf_chk-gds.write-off-code > 0 then 1 else - 1) *
                                                          buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
                                                        )
                                                  else 0)
          .
        end.
        create buf1_chk-gds.
        buffer-copy buf_chk-gds except doc-code to buf1_chk-gds
        assign
        buf1_chk-gds.doc-code = buf1_chk-doc.doc-code
        .
        create temp-goods.
        assign
        temp-goods.line-num = buf_chk-gds.line-num
        temp-goods.object-sum = buf_chk-gds.src-price * buf_chk-gds.src-qnty
        .
      end.
      when yes then do:
        if buf_chk-doc.chk-type = integer('8':U) then do:
          assign
          v-tot-doc-annu = v-tot-doc-annu + buf_chk-gds.src-price * buf_chk-gds.src-qnty
          v-sum-office = v-sum-office + buf_chk-gds.src-price * buf_chk-gds.src-qnty
          v-discnt-office = v-discnt-office + buf_chk-gds.src-discnt * buf_chk-gds.src-qnty
          v-netto-office = v-netto-office + (buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty
          v-netto-annu = v-netto-annu + (buf_chk-gds.src-price - buf_chk-gds.src-discnt) * buf_chk-gds.src-qnty
          v-write-off-office = v-write-off-office + (if buf_chk-gds.write-off-code <> 0
                                                  and buf_chk-gds.write-off-code <> ?
                                                  then ((if buf_chk-gds.write-off-code > 0 then 1 else - 1) *
                                                          buf_chk-gds.src-qnty * (buf_chk-gds.src-price - buf_chk-gds.src-discnt)
                                                        )
                                                  else 0)
          .
        end.
        else do:
          assign
          v-sum-office = v-sum-office + buf_chk-gds.price-base * buf_chk-gds.doc-qnty
          v-discnt-office = v-discnt-office + buf_chk-gds.discnt * buf_chk-gds.doc-qnty
          v-netto-office = v-netto-office + (buf_chk-gds.price-base - buf_chk-gds.discnt) * buf_chk-gds.doc-qnty
          v-write-off-office = v-write-off-office + (if buf_chk-gds.write-off-code <> 0
                                                  and buf_chk-gds.write-off-code <> ?
                                                  then ((if buf_chk-gds.write-off-code > 0 then 1 else - 1) *
                                                          buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
                                                        )
                                                  else 0)
          .
        end.
        create buf2_chk-gds.
        buffer-copy buf_chk-gds except doc-code to buf2_chk-gds
        assign
        buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
        .
        create temp-office.
        assign
        temp-office.line-num = buf_chk-gds.line-num
        temp-office.object-sum = buf_chk-gds.src-price * buf_chk-gds.src-qnty
        .
      end.
    END case.
      delete buf_chk-gds.
   end.
   if  buf_chk-doc.chk-type = integer('8':U) then do:
    for each buf_Chk-discnt no-lock where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
        AND buf_chk-discnt.record-type = 0:
      if NOT (buf_chk-discnt.line-type = integer('2':U) or
              buf_chk-discnt.line-type = integer('3':U) or
              buf_chk-discnt.line-type = integer('4':U) or
              buf_chk-discnt.line-type = integer('5':U)
            ) then NEXT.
      if buf_chk-discnt.value-type = integer('1':U)
      and buf_chk-discnt.object-line-num = 0 then do:
        assign
        v-netto-goods = v-netto-goods  - (v-netto-goods * buf_chk-discnt.discnt-value-pcnt) / 100
        v-netto-office = v-netto-office  - (v-netto-office * buf_chk-discnt.discnt-value-pcnt) / 100
        v-netto-annu = v-netto-annu - (v-netto-annu * buf_chk-discnt.discnt-value-pcnt) / 100
        .
      end.
      else do:
        assign
        v-netto-goods = v-netto-goods * (v-netto-annu - buf_chk-discnt.discnt-value-abs) / v-netto-annu
        v-netto-office = v-netto-office * (v-netto-annu - buf_chk-discnt.discnt-value-abs) / v-netto-annu
        v-netto-annu = v-netto-annu - buf_chk-discnt.discnt-value-abs.
      end.
    end.
    assign
    v-ratio-goods-sum = v-sum-goods / v-tot-doc-annu
    v-ratio-office-sum = v-sum-office / v-tot-doc-annu
    buf1_chk-doc.sub-discnt = (if buf_chk-doc.sub-discnt <> ?
                              and buf_chk-doc.sub-discnt <> 0
                              then v-write-off-goods
                              else 0)
    buf2_chk-doc.sub-discnt = if buf_chk-doc.sub-discnt <> ?
                              and buf_chk-doc.sub-discnt <> 0
                              then v-write-off-office
                              else 0
    buf1_chk-doc.tot-doc = if buf_chk-doc.tot-doc <> ?
                           and buf_chk-doc.tot-doc <> 0
                           then  (v-sum-goods + (if v-tot-doc-annu < 0
                                                 then 0
                                                 else - buf1_chk-doc.sub-discnt)
                                 )
                           else buf_chk-doc.tot-doc
    buf2_chk-doc.tot-doc = if buf_chk-doc.tot-doc <> ?
                           and buf_chk-doc.tot-doc <> 0
                           then (v-sum-office + (if v-tot-doc-annu < 0
                                                then 0
                                                else - buf2_chk-doc.sub-discnt)
                                )
                           else buf_chk-doc.tot-doc
    buf1_chk-doc.netto = if buf_chk-doc.netto <> ?
                         and buf_chk-doc.netto <> 0
                         then (v-netto-goods - v-write-off-goods)
                         else buf_chk-doc.netto
    buf2_chk-doc.netto = if buf_chk-doc.netto <> ?
                         and buf_chk-doc.netto <> 0
                         then (v-netto-office - v-write-off-office)
                         else buf_chk-doc.netto
    buf1_chk-doc.discnt = if buf_chk-doc.discnt <> ?
                          and buf_chk-doc.discnt <> 0
                          then v-discnt-goods
                          else buf_chk-doc.discnt
    buf2_chk-doc.discnt = if buf_chk-doc.discnt <> ?
                          and buf_chk-doc.discnt <> 0
                          then v-discnt-office
                          else buf_chk-doc.discnt
    buf1_chk-doc.d-pcnt = if buf1_chk-doc.tot-doc = 0
                          or buf1_chk-doc.tot-doc = ?
                            then 0
                            else ( buf1_chk-doc.discnt / buf1_chk-doc.tot-doc * 100 )
    buf2_chk-doc.d-pcnt = if buf2_chk-doc.tot-doc = 0
                          or buf2_chk-doc.tot-doc = ?
                            then 0
                            else ( buf2_chk-doc.discnt / buf2_chk-doc.tot-doc * 100 )
    buf1_chk-doc.office = 'т':U
    buf2_chk-doc.office = 'у':U
    v-ratio-goods-netto = (v-netto-goods - v-write-off-goods) / v-netto-annu
    v-ratio-office-netto = (v-netto-office - v-write-off-office) / v-netto-annu
    .
   end.
   else do:
    assign
    v-ratio-goods-sum = v-sum-goods / buf_chk-doc.tot-doc
    v-ratio-office-sum = v-sum-office / buf_chk-doc.tot-doc
    buf1_chk-doc.sub-discnt = v-write-off-goods
    buf2_chk-doc.sub-discnt = v-write-off-office
    buf1_chk-doc.tot-doc = v-sum-goods + (if buf_Chk-doc.chk-type = integer('6':U)
                                          or buf_Chk-doc.chk-type = integer('96':U)
                                          then 0
                                          else - buf1_chk-doc.sub-discnt)
    buf2_chk-doc.tot-doc = v-sum-office + (if buf_Chk-doc.chk-type = integer('6':U)
                                          or buf_Chk-doc.chk-type = integer('96':U)
                                          then 0
                                          else - buf2_chk-doc.sub-discnt)
    buf1_chk-doc.netto = v-netto-goods - buf1_chk-doc.sub-discnt
    buf2_chk-doc.netto = v-netto-office - buf2_chk-doc.sub-discnt
    buf1_chk-doc.discnt = v-discnt-goods
    buf2_chk-doc.discnt = v-discnt-office
    buf1_chk-doc.d-pcnt = if buf1_chk-doc.tot-doc = 0
                            then 0
                            else ( buf1_chk-doc.discnt / buf1_chk-doc.tot-doc * 100 )
    buf2_chk-doc.d-pcnt = if buf2_chk-doc.tot-doc = 0
                            then 0
                            else ( buf2_chk-doc.discnt / buf2_chk-doc.tot-doc * 100 )
    buf1_chk-doc.office = 'т':U
    buf2_chk-doc.office = 'у':U
    v-ratio-goods-netto = buf1_chk-doc.netto / buf_chk-doc.netto
    v-ratio-office-netto = buf2_chk-doc.netto / buf_chk-doc.netto
    .
   end.
   for each buf_chk-pay where
            buf_chk-pay.doc-code = buf_chk-doc.doc-code:
     num-pay = num-pay + 1.
   end.
   if num-pay = 1 then do:
     for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code:
      create buf1_chk-pay.
      buffer-copy buf_chk-pay except doc-code to buf1_chk-pay
      assign
      buf1_chk-pay.doc-code = buf1_chk-doc.doc-code
      buf1_chk-pay.tot-base = (if v-curr-r-b = 'base':U and  not v-is-annu
                              then buf1_chk-doc.netto
                              else  v-ratio-goods-netto * buf_chk-pay.tot-base
                              )
      buf1_chk-pay.tot-rubl = (if v-curr-r-b = 'rubl':U and  not v-is-annu
                               then buf1_chk-doc.netto
                               ELSE v-ratio-goods-netto * buf_chk-pay.tot-rubl
                               )
      buf1_chk-pay.tot-sum = v-ratio-goods-netto * buf_chk-PAY.TOT-SUM
      .
      create buf2_chk-pay.
      buffer-copy buf_chk-pay except doc-code to buf2_chk-pay
      assign
      buf2_chk-pay.doc-code = buf2_chk-doc.doc-code
      buf2_chk-pay.tot-base = If v-is-annu
                              then (v-ratio-office-netto * buf_chk-pay.tot-base)
                              else (buf_chk-pay.tot-base - buf1_chk-pay.tot-base)
      buf2_chk-pay.tot-rubl = If v-is-annu
                              then (v-ratio-office-netto * buf_chk-pay.tot-rubl)
                              else (buf_chk-pay.tot-rubl - buf1_chk-pay.tot-rubl)
      buf2_chk-pay.tot-sum = If v-is-annu
                             then v-ratio-office-netto * buf_chk-PAY.TOT-SUM
                             else (buf_chk-pay.tot-sum - buf1_chk-pay.tot-sum)
      .
      delete buf_chk-pay.
     end.
   end.
   else do:
    for each buf_chk-pay where
              buf_chk-pay.doc-code = buf_chk-doc.doc-code:
      create buf1_chk-pay.
      buffer-copy buf_chk-pay except doc-code to buf1_chk-pay
      assign
      buf1_chk-pay.doc-code = buf1_chk-doc.doc-code
      buf1_chk-pay.tot-sum = v-ratio-goods-netto * buf_chk-pay.tot-sum
      buf1_chk-pay.tot-base = v-ratio-goods-netto * buf_chk-pay.tot-base
      buf1_chk-pay.tot-rubl = v-ratio-goods-netto * buf_chk-pay.tot-rubl
      .
      create buf2_chk-pay.
      buffer-copy buf_chk-pay except doc-code to buf2_chk-pay
      assign
      buf2_chk-pay.doc-code = buf2_chk-doc.doc-code
      buf2_chk-pay.tot-sum = v-ratio-office-netto * buf_chk-pay.tot-sum
      buf2_chk-pay.tot-base = v-ratio-office-netto * buf_chk-pay.tot-base
      buf2_chk-pay.tot-rubl = v-ratio-office-netto * buf_chk-pay.tot-rubl
      .
      delete buf_chk-pay.
    end.
   end.
   assign
   current-line-num = 0
   .
   _buf_chk-didscnt:
   for each buf_chk-discnt where
            buf_chk-discnt.doc-code = buf_chk-doc.doc-code
   by buf_chk-discnt.line-num
   by buf_chk-discnt.discnt-id
   by abs(buf_chk-discnt.object-line-num)
   by buf_chk-discnt.object-line-num
   :
     CASE buf_chk-discnt.record-type:
       when 0 then do:
        for each temp-goods no-lock where
                  abs(temp-goods.line-num) > abs(current-line-num) and
                  abs(temp-goods.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum-goods = v-object-sum-goods + temp-goods.object-sum
            .
        end.
        for each temp-office no-lock where
                  abs(temp-office.line-num) > abs(current-line-num) and
                  abs(temp-office.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum-office = v-object-sum-office + temp-office.object-sum
            .
        end.
        assign
        v-object-sum = v-object-sum-goods + v-object-sum-office
        v-ratio-goods-discnt = v-object-sum-goods / v-object-sum
        v-ratio-office-discnt = v-object-sum-office / v-object-sum
        .
        assign
        current-line-num = buf_chk-discnt.line-num
        .
        if buf_chk-discnt.line-type = integer('1':U)
        and can-find(first temp-office where
                           temp-office.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf1_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf1_chk-discnt
          assign
          buf1_chk-discnt.doc-code = buf1_chk-doc.doc-code
          .
          CASE buf_chk-discnt.line-type:
            when integer('2':U) or when integer('3':U) then do:
              assign
              buf1_chk-discnt.object-sum = v-ratio-goods-discnt * buf_chk-discnt.object-sum
              buf1_chk-discnt.discnt-value-abs = v-ratio-goods-discnt * buf_chk-discnt.discnt-value-abs
              buf1_chk-discnt.discnt-value-pcnt =  if buf1_chk-discnt.object-sum <> 0
                                                  then buf1_chk-discnt.discnt-value-abs / buf1_chk-discnt.object-sum * 100
                                                  else 0
              .
            end.
            when integer('4':U) or when integer('5':U) then do:
            assign
            buf1_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * v-ratio-goods-netto
            buf1_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * v-ratio-goods-netto
            buf1_chk-discnt.discnt-value-pcnt =  if buf1_chk-discnt.object-sum <> 0
                                                  then buf1_chk-discnt.discnt-value-abs / buf1_chk-discnt.object-sum * 100
                                                  else 0
            .
            end.
          END CASE.
          v-object-sum-goods = v-object-sum-goods - buf1_chk-discnt.discnt-value-abs.
        end.
        if buf_chk-discnt.line-type = integer('1':U)
        and can-find(first temp-goods where
                           temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf2_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf2_chk-discnt
          assign
          buf2_chk-discnt.doc-code = buf2_chk-doc.doc-code
          .
          CASE buf_chk-discnt.line-type:
            when integer('2':U) or when integer('3':U) then do:
              assign
              buf2_chk-discnt.object-sum = v-ratio-office-discnt * buf_chk-discnt.object-sum
              buf2_chk-discnt.discnt-value-abs = v-ratio-office-discnt * buf_chk-discnt.discnt-value-abs
              buf2_chk-discnt.discnt-value-pcnt =  if buf2_chk-discnt.object-sum <> 0
                                                  then buf2_chk-discnt.discnt-value-abs / buf2_chk-discnt.object-sum * 100
                                                  else 0
              .
            end.
            when integer('4':U) or when integer('5':U) then do:
            assign
            buf2_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * v-ratio-office-netto
            buf2_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * v-ratio-office-netto
            buf2_chk-discnt.discnt-value-pcnt =  if buf2_chk-discnt.object-sum <> 0
                                                  then buf2_chk-discnt.discnt-value-abs / buf2_chk-discnt.object-sum * 100
                                                  else 0
            .
            end.
          END CASE.
          v-object-sum-office = v-object-sum-office - buf2_chk-discnt.discnt-value-abs.
        end.
        assign
        v-object-sum = v-object-sum-goods + v-object-sum-office
        v-ratio-goods-discnt = v-object-sum-goods / v-object-sum
        v-ratio-office-discnt = v-object-sum-office / v-object-sum
        .
      end.
      when 1 then do:
        if can-find(first temp-office where
                          temp-office.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf1_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf1_chk-discnt
          assign
          buf1_chk-discnt.doc-code = buf1_chk-doc.doc-code
          .
        end.
        if can-find(first temp-goods where
                          temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf2_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf2_chk-discnt
          assign
          buf2_chk-discnt.doc-code = buf2_chk-doc.doc-code
          .
        end.
      end.
      when 2 then do:
        if can-find(first temp-office where
                          temp-office.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf1_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf1_chk-discnt
          assign
          buf1_chk-discnt.doc-code = buf1_chk-doc.doc-code
          .
        end.
        if can-find(first temp-goods where
                          temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf2_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf2_chk-discnt
          assign
          buf2_chk-discnt.doc-code = buf2_chk-doc.doc-code
          .
        end.
      end.
      when 4 then do:
        for each temp-goods no-lock where
                  abs(temp-goods.line-num) > abs(current-line-num-bonus) and
                  abs(temp-goods.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum-goods-bonus = v-object-sum-goods-bonus + temp-goods.object-sum
            .
        end.
        for each temp-office no-lock where
                  abs(temp-office.line-num) > abs(current-line-num-bonus) and
                  abs(temp-office.line-num) <= abs(buf_chk-discnt.line-num):
            assign
            v-object-sum-office-bonus = v-object-sum-office-bonus + temp-office.object-sum
            .
        end.
        assign
        v-object-sum-bonus = v-object-sum-goods-bonus + v-object-sum-office-bonus
        v-ratio-goods-bonus = ( if v-object-sum-bonus = 0
                                then 0
                                else v-object-sum-goods-bonus / v-object-sum-bonus)
        v-ratio-office-bonus = (if v-object-sum-bonus = 0
                                then 0
                                else v-object-sum-office-bonus / v-object-sum-bonus)
        .
        assign
        current-line-num-bonus = buf_chk-discnt.line-num
        .
        if buf_chk-discnt.line-type = integer('1':U)
        and can-find(first temp-office where
                           temp-office.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf1_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf1_chk-discnt
          assign
          buf1_chk-discnt.doc-code = buf1_chk-doc.doc-code
          .
          CASE buf_chk-discnt.line-type:
            when integer('2':U) or when integer('3':U) then do:
              assign
              buf1_chk-discnt.object-sum = v-ratio-goods-bonus * buf_chk-discnt.object-sum
              buf1_chk-discnt.discnt-value-abs = v-ratio-goods-bonus * buf_chk-discnt.discnt-value-abs
              buf1_chk-discnt.discnt-value-pcnt =  if buf1_chk-discnt.object-sum <> 0
                                                  then buf1_chk-discnt.discnt-value-abs / buf1_chk-discnt.object-sum * 100
                                                  else 0
              .
            end.
            when integer('4':U) or when integer('5':U) then do:
            assign
            buf1_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * v-ratio-goods-netto
            buf1_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * v-ratio-goods-netto
            buf1_chk-discnt.discnt-value-pcnt =  if buf1_chk-discnt.object-sum <> 0
                                                  then buf1_chk-discnt.discnt-value-abs / buf1_chk-discnt.object-sum * 100
                                                  else 0
            .
            end.
          END CASE.
        end.
        if buf_chk-discnt.line-type = integer('1':U)
        and can-find(first temp-goods where
                           temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf2_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf2_chk-discnt
          assign
          buf2_chk-discnt.doc-code = buf2_chk-doc.doc-code
          .
          CASE buf_chk-discnt.line-type:
            when integer('2':U) or when integer('3':U) then do:
              assign
              buf2_chk-discnt.object-sum = v-ratio-office-bonus * buf_chk-discnt.object-sum
              buf2_chk-discnt.discnt-value-abs = v-ratio-office-bonus * buf_chk-discnt.discnt-value-abs
              buf2_chk-discnt.discnt-value-pcnt =  if buf2_chk-discnt.object-sum <> 0
                                                  then buf2_chk-discnt.discnt-value-abs / buf2_chk-discnt.object-sum * 100
                                                  else 0
              .
            end.
            when integer('4':U) or when integer('5':U) then do:
            assign
            buf2_chk-discnt.discnt-value-abs = buf_chk-discnt.discnt-value-abs * v-ratio-office-netto
            buf2_chk-discnt.object-sum       = buf_chk-discnt.discnt-value-abs * v-ratio-office-netto
            buf2_chk-discnt.discnt-value-pcnt =  if buf2_chk-discnt.object-sum <> 0
                                                  then buf2_chk-discnt.discnt-value-abs / buf2_chk-discnt.object-sum * 100
                                                  else 0
            .
            end.
          END CASE.
        end.
        assign
        v-object-sum-bonus = v-object-sum-goods-bonus + v-object-sum-office-bonus
        v-ratio-goods-bonus = v-object-sum-goods-bonus / v-object-sum-bonus
        v-ratio-office-bonus = v-object-sum-office-bonus / v-object-sum-bonus
        .
      end.
      when 5 then do:
        if can-find(first temp-office where
                          temp-office.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf1_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf1_chk-discnt
          assign
          buf1_chk-discnt.doc-code = buf1_chk-doc.doc-code
          .
        end.
        if can-find(first temp-goods where
                          temp-goods.line-num = buf_chk-discnt.object-line-num) then do:
        end.
        else do:
          create buf2_chk-discnt.
          buffer-copy buf_chk-discnt except doc-code to buf2_chk-discnt
          assign
          buf2_chk-discnt.doc-code = buf2_chk-doc.doc-code
          .
        end.
      end.
     END CASE.
     delete buf_chk-discnt.
   end.
   delete buf_chk-doc.
   return ''.
end.
