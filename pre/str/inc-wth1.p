block-level on error undo, throw.
define parameter buffer loc-chk-doc for ub.chk-doc.
define input parameter par-koeff as integer no-undo .
define input parameter pardoc-code like ub.wth-doc.doc-code no-undo .
define input parameter parcurrent-w-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parout-w-p-code like ub.wth-line.out-code no-undo .
define input parameter parext-doc-type like ub.wth-doc.ext-doc-type no-undo .
define input parameter parchk-type like ub.chk-doc.chk-type no-undo .
define input parameter p-silent as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inc-wth1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inc-wth1.p $":U .
define variable vss-description as character no-undo init "Добавление/удаление чека МЦ в документ".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define temp-table tt-par-dtl  no-undo like ub.wth-par
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (рубл)"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(рубл)"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc
.
define temp-table tt-par-dtl-inv  no-undo like ub.wth-par
FIELD q-ty-bef     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во план"
FIELD q-ty-aft     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во факт"
FIELD sum-bef  like ub.wth-line.bef-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма план"
FIELD sum-aft  like ub.wth-line.aft-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма факт"
FIELD sum-fact  like ub.wth-line.fact-sum FORM "->,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Расхождение"
INDEX tt-pi    IS   PRIMARY UNIQUE par-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        sum-bef  q-ty-bef
.
DEFINE VARIABLE varline-rec as recid no-undo .
define buffer buf_chk-pay for ub.chk-pay .
define buffer buf2_chk-pay for ub.chk-pay .
define buffer buf_c-chk-doc for ub.c-chk-doc .
define buffer buf_c-chk-pay for ub.c-chk-pay .
define buffer buf_wth-place for ub.wth-place.
define buffer buf_wealth for ub.wealth.
define buffer buf_cash-pay for ub.cash-pay .
define buffer bufdoc_wth-place for ub.wth-place.
define buffer buf_wth-par for ub.wth-par.
define buffer buf_inkas-pay-wth for ub.inkas-pay-wth.
DEFINE VARIABLE varkoef as integer no-undo .
DEFINE VARIABLE var-sum like ub.chk-pay.tot-sum no-undo .
def var cur-wth like    ub.wealth.wth-code no-undo.
if NOT ABS(par-koeff) = 1 then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-koeff" par-koeff
  view-as alert-box error .
  return error.
end.
FIND FIRST buf_wth-place No-LOCK WHERE
          buf_wth-place.obj-type = loc-chk-doc.obj-type AND
          buf_wth-place.obj-code = loc-chk-doc.obj-code AND
          buf_wth-place.cash-desk = loc-chk-doc.pay-desk NO-ERROR.
if not available buf_wth-place then do:
  message
  "Не определено МХ МЦ для кассы N" loc-chk-doc.pay-desk SKIP
  "объект" loc-chk-doc.obj-type loc-chk-doc.obj-code
  view-as alert-box error .
  return error .
end.
if parcurrent-w-p-code <> 0 and par-koeff = 1 then do:
  FIND FIRST bufdoc_wth-place No-LOCK WHERE
            bufdoc_wth-place.obj-type = loc-chk-doc.obj-type AND
            bufdoc_wth-place.obj-code = loc-chk-doc.obj-code AND
            bufdoc_wth-place.w-p-code = parcurrent-w-p-code No-ERROR.
  if not available bufdoc_wth-place or bufdoc_wth-place.cash-desk = 0 then dO:
    message
    "Не определено МХ МЦ в документе" pardoc-code " определено неверно" SKIP
    "объект" loc-chk-doc.obj-type loc-chk-doc.obj-code
    view-as alert-box error .
    return error .
  end.
  if buf_wth-place.w-p-code <> parcurrent-w-p-code then do:
    message
    "Документ МЦ" pardoc-code "сформирован для чеков кассы N" bufdoc_wth-place.cash-desk
    "а чек " loc-chk-doc.doc-code "пробит на кассе" loc-chk-doc.pay-desk SKIP
    "объект" loc-chk-doc.obj-type loc-chk-doc.obj-code
    view-as alert-box error .
    return error .
  end.
end.
main-block:
do
on error undo, return error
:
_chk-pay:
FOR EACH buf_chk-pay where
          buf_chk-pay.doc-code = loc-chk-doc.doc-code
BREAK
By buf_chk-pay.pay-code
BY buf_chk-pay.curr-code
ON ERROR UNDO _chk-pay, return error
          :
  if first-of(buf_chk-pay.curr-code)or first-of(buf_chk-pay.pay-code) then do:
    FIND FIRST buf_cash-pay No-LOCK where
                buf_cash-pay.cdpay-code = buf_chk-pay.pay-code AND
                buf_cash-pay.curr-code = buf_chk-pay.curr-code No-ERROR.
    IF NOT AVAILABLE buf_cash-pay then do:
      message
      "Не найден тип кассового платежа" skip
      "код платежа" buf_chk-pay.pay-code
      "код валюты" buf_chk-pay.curr-code
      view-as alert-box error .
      undo main-block, return error.
    end.
    FIND FIRST buf_wealth No-LOCK WHERE
                buf_wealth.wth-code = buf_cash-pay.wth-code No-ERROR.
    if NOT AVAILABLE buf_wealth then do:
      if buf_cash-pay.wth-code = 0 and
        buf_cash-pay.is-cash = no AND
        string(loc-chk-doc.chk-type) = '4':U then do:
      error-status:error = no.
      end.
      else do:
        undo _chk-pay, return error substitute("Не найдена МЦ с кодом &1&2Чек МЦ &3"
                                                , buf_cash-pay.wth-code
                                                ,chr(10)
                                                , loc-chk-doc.doc-code).
      end.
    end.
    assign
    var-sum = 0
    cur-wth = buf_wealth.wth-code.
    for each buf2_chk-pay no-lock where
            buf2_chk-pay.doc-code = loc-chk-doc.doc-code
         and buf2_chk-pay.pay-code = buf_chk-pay.pay-code
         and buf2_chk-pay.curr-code = buf_chk-pay.curr-code
         and buf2_chk-pay.par-code > 0
     ON ERROR UNDO _chk-pay, return error:
      find first buf_wth-par no-lock where
                buf_wth-par.wth-code = buf2_chk-pay.wth-code
            and buf_wth-par.par-code = buf2_chk-pay.par-code no-error.
      if not available buf_wth-par then do:
        undo _chk-pay, return error substitute("Не найден номинал МЦ &1 для МЦ &2&2Чек МЦ &4"
                                                , buf2_chk-pay.wth-code
                                                , buf2_chk-pay.par-code
                                                ,chr(10)
                                                , loc-chk-doc.doc-code).
      end.
      find first tt-par-dtl where tt-par-dtl.par-code = buf2_chk-pay.par-code no-error.
      if not available tt-par-dtl then do:
        create tt-par-dtl.
        assign
        tt-par-dtl.wth-code = buf2_chk-pay.wth-code
        tt-par-dtl.doc-sum  = buf2_chk-pay.tot-sum
        tt-par-dtl.fact-sum  = 0.0
        tt-par-dtl.q-ty-doc  = buf2_chk-pay.doc-qnty
        tt-par-dtl.q-ty-fact  = 0.0
        tt-par-dtl.par-code = buf2_chk-pay.par-code
        tt-par-dtl.par-rate = buf_wth-par.par-rate
        tt-par-dtl.par-feat = buf_wth-par.par-feat
        tt-par-dtl.par-unit = buf_wth-par.par-unit
        tt-par-dtl.par-val = buf2_chk-pay.par-val
        .
      end.
      else do:
        assign
        tt-par-dtl.doc-sum  = tt-par-dtl.doc-sum  + buf2_chk-pay.tot-sum
        tt-par-dtl.q-ty-doc  = tt-par-dtl.q-ty-doc + buf2_chk-pay.doc-qnty
        .
      end.
      release tt-par-dtl.
    end.
      if loc-chk-doc.chk-type <> integer('7':U) then do:
        find first buf_inkas-pay-wth where
                  buf_inkas-pay-wth.inkas-code = pardoc-code
              and buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
              and buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
              and buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
              and buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
              and buf_inkas-pay-wth.pay-desk = loc-chk-doc.pay-desk
              and buf_inkas-pay-wth.cashier = loc-chk-doc.cashier
              and buf_inkas-pay-wth.chk-type = loc-chk-doc.chk-type no-error.
        if not available  buf_inkas-pay-wth then do:
          create buf_inkas-pay-wth.
          assign
          buf_inkas-pay-wth.inkas-code = pardoc-code
          buf_inkas-pay-wth.pay-code = buf_chk-pay.pay-code
          buf_inkas-pay-wth.curr-code = buf_chk-pay.curr-code
          buf_inkas-pay-wth.wth-code = buf_chk-pay.wth-code
          buf_inkas-pay-wth.par-code = buf_chk-pay.par-code
          buf_inkas-pay-wth.pay-desk = loc-chk-doc.pay-desk
          buf_inkas-pay-wth.cashier = loc-chk-doc.cashier
          buf_inkas-pay-wth.chk-type = loc-chk-doc.chk-type
          buf_inkas-pay-wth.par-val = buf_chk-pay.par-val
          .
        end.
        assign
        buf_inkas-pay-wth.tot-sum = buf_inkas-pay-wth.tot-sum + buf_chk-pay.tot-sum
        buf_inkas-pay-wth.tot-base = buf_inkas-pay-wth.tot-base + buf_chk-pay.tot-base
        buf_inkas-pay-wth.tot-rubl = buf_inkas-pay-wth.tot-rubl + buf_chk-pay.tot-rubl
        buf_inkas-pay-wth.doc-qnty = buf_inkas-pay-wth.doc-qnty + buf_chk-pay.doc-qnty
        buf_inkas-pay-wth.tot-lines = buf_inkas-pay-wth.tot-lines + 1
        .
      end.
  end.
  assign
  var-sum = var-sum + buf_chk-pay.tot-sum
  .
  if last-of(buf_chk-pay.curr-code) and var-sum <> 0 then do:
    if parext-doc-type = 'iy':U then do:
      if string(parchk-type) = '4':U then dO:
        if buf_cash-pay.wth-code = 0 and
          buf_cash-pay.is-cash = no AND
          string(loc-chk-doc.chk-type) = '4':U then do:
        end.
        else do:
          run str/wth-lni1.p (
                        input-output varline-rec
                        ,input  'ДОБАВЛЕНИЕ':U
                        ,input  pardoc-code
                        ,input  cur-wth
                        ,input  buf_wth-place.w-p-code
                        ,input  par-koeff * buf_chk-pay.tot-sum
                        ,input  yes
                        ) no-error .
        end.
      END.
      else do:
        run str/wth-lnv1.p (
                       input-output varline-rec
                      ,input  'ДОБАВЛЕНИЕ':U
                      ,input  pardoc-code
                      ,input  cur-wth
                      ,input  buf_wth-place.w-p-code
                      ,input  ?
                      ,input  par-koeff * buf_chk-pay.tot-sum
                      ,input  table tt-par-dtl-inv
                      ,input  yes
                      ) no-error .
      end.
    end.
    else do:
      run str/wth-lnc1.p (
                     input-output varline-rec
                    ,input  'ДОБАВЛЕНИЕ':U
                    ,input p-silent
                    ,input pardoc-code
                    ,input cur-wth
                    ,input buf_wth-place.w-p-code
                    ,input parout-w-p-code
                    ,input par-koeff * abs(var-sum)
                    ,input (if loc-chk-doc.chk-type = integer('7':U)
                            then 0.0
                            else par-koeff * abs(var-sum))
                    ,input table tt-par-dtl
                    ,input yes
                    ,input parext-doc-type
                    ,input 0
                    ,input 0
                    ) no-error .
    end.
    if error-status:error then do:
      define variable v-mess as character no-undo .
      v-mess = substitute("Не удалось создать (изменить, удалить) строку автоматического документа МЦ&1"  +
                          "код МЦ &2&1"  +
                          "МХ &3&1" +
                          "МХ назначения &4&1&5&1&6"
                          , chr(10)
                          , cur-wth
                          , buf_wth-place.w-p-code
                          , parout-w-p-code
                          , error-status:get-message(1)
                          , return-value).
      if not p-silent then do:
        message
        v-mess
        view-as alert-box error .
      end.
      undo _chk-pay, return error (if p-silent then v-mess else '').
    end.
  end.
  assign
  buf_chk-pay.out-code = (if par-koeff = 1 then pardoc-code else '':U)
  .
END.
for each buf_c-chk-doc where
        buf_c-chk-doc.doc-code = loc-chk-doc.doc-code  :
    assign
    buf_c-chk-doc.out-code = (if par-koeff = 1 then pardoc-code else '':U)
    .
end.
for each buf_c-chk-pay where
        buf_c-chk-pay.doc-code = loc-chk-doc.doc-code     :
    assign
    buf_c-chk-pay.out-code = (if par-koeff = 1 then pardoc-code else '':U)
    .
end.
assign
loc-chk-doc.out-code = (if par-koeff = 1 then pardoc-code else '':U).
end.
