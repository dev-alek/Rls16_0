block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: wth-lnc1.p $
$Archive: str/wth-lnc1.p $

Сохранение изменений в строке документа МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/04
Author: Bakhtadze Natalya
Creation date: 01/20/04

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define temp-table tt-par-dtl  no-undo like ub.wth-par
{ str/ttpardt0.i }
.

define input-output parameter par-rid as recid no-undo .
define input parameter par-mode    as character no-undo .
define input parameter p-silent    as logical no-undo .
define input parameter pardoc-code like ub.wth-line.doc-code no-undo .
define input parameter parwth-code like ub.wth-line.wth-code no-undo .
define input parameter parw-p-code like ub.wth-line.w-p-code no-undo .
define input parameter parout-code like ub.wth-line.out-code no-undo .
define input parameter pardoc-sum  like ub.wth-line.doc-sum no-undo .
define input parameter parfact-sum  like ub.wth-line.doc-sum no-undo .
define input parameter table for tt-par-dtl.
define input parameter parline-exist as logical no-undo .
define input parameter parext-type like ub.wth-doc.ext-doc-type no-undo.
define input parameter parsum-gds-rubl  like ub.wth-line.sum-gds-rubl no-undo .
define input parameter parsum-gds-base  like ub.wth-line.sum-gds-base no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-lnc1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/wth-lnc1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке ставки налога".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }

DEFINE VARIABLE var-entry as character no-undo .
define variable v-mes     as character no-undo .
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE vardtl-rec as recid no-undo .
DEFINE VARIABLE varis-dtl as logical no-undo .
DEFINE VARIABLE vardtl-doc-sum as decimal no-undo .
DEFINE VARIABLE vardtl-fact-sum as decimal no-undo .
DEFINE VARIABLE varline-doc-sum as decimal no-undo .
DEFINE VARIABLE varline-fact-sum as decimal no-undo .
DEFINE VARIABLE end-doc-sum like ub.wth-line.doc-sum no-undo .
DEFINE VARIABLE end-fact-sum like ub.wth-line.fact-sum no-undo .
DEFINE VARIABLE v-is-deletion as logical no-undo .
DEFINE VARIABLE v-stts like ub.wealth.wth-code no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer buf_wth-doc for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer inv_wth-doc for ub.wth-doc.
define buffer check_chk-doc for ub.chk-doc .
define buffer buf_wealth for ub.wealth.
_main:
do
on error undo, return error
:

if NOT (par-mode = {&add-def} OR par-mode = {&update} or par-mode = {&deletion}) then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр вызова par-mode" par-mode
  view-as alert-box ERROR.
  return error '':U.
end.
if par-mode = {&deletion} then do:
  assign
  par-mode = {&update}
  v-is-deletion = yes
  .
end.


FIND FIRST buf_wth-doc EXCLUSIVE-LOCK WHERE
           buf_wth-doc.doc-code = pardoc-code No-ERROR No-WAIT.
IF LOCKED buf_wth-doc then do:
  assign
  v-mes = "Запись документа МЦ занята, добавление/изменение строки невозможно".
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
IF NOT available buf_wth-doc then do:
  assign
  v-mes = "Не найден документ МЦ".
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
if buf_wth-doc.status_ = {&fact} then do:
  assign
  v-mes = substitute("Документ имеет статус &1, добавление/изменение строки невозможно", buf_wth-doc.status_).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.
if buf_wth-doc.status_ = {&permitted}
and par-mode = {&add-def} then dO:
  assign
  v-mes = substitute("Документ имеет статус &1, добавление строки невозможно", buf_wth-doc.status_).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
end.


if par-mode = {&add-def} then do:
  par-rid = ?.
  if  parline-exist = yes then do:
    FIND FIRST ub.wth-line No-LOCK WHERE
              ub.wth-line.doc-code = pardoc-code AND
              ub.wth-line.wth-code = parwth-code AND
              ub.wth-line.w-p-code = parw-p-code No-ERROR.
    if available ub.wth-line then do:
      par-rid = recid(ub.wth-line).
      assign
      pardoc-sum = pardoc-sum + ub.wth-line.doc-sum
      parfact-sum = parfact-sum + ub.wth-line.fact-sum
      .
    end.
  end.
end.

if not v-is-deletion then do:
  run trg/wth-lnc2.p (
                input pardoc-code,
                input buf_wth-doc.host-code,
                input buf_wth-doc.obj-type,
                input buf_wth-doc.obj-code,
                input buf_wth-doc.cli-type,
                input buf_wth-doc.cli-code,
                input buf_wth-doc.auto-fill,
                input buf_wth-doc.borned,
                input buf_wth-doc.exter_,
                input par-rid,
                input parwth-code,
                input parw-p-code,
                input parout-code,
                input pardoc-sum,
                input parfact-sum,
                output v-stts ) no-error.
  if error-status:error then return error return-value.
  if par-mode = {&add-def} and buf_wth-doc.auto-fill = no
     and v-stts <> 0 then do:
    assign
    v-mes = substitute("МЦ &1 удалена, добавление строки невозможно", parwth-code).
    run err-mess(input-output v-mes).
    undo _main, return error v-mes.
  end.
end.

if par-mode = {&add-def} then do:
  FIND FIRST buf_wth-line NO-LOCK WHERE
            buf_wth-line.obj-type    = buf_wth-doc.obj-type   AND
            buf_wth-line.obj-code    = buf_wth-doc.obj-code   AND
            buf_wth-line.w-p-code    = parw-p-code   AND
            buf_wth-line.shift-date  = buf_wth-doc.shift-date AND
            buf_wth-line.shift-num   = buf_wth-doc.shift-num  AND
            buf_wth-line.wth-code    = parwth-code   AND
            buf_wth-line.status_    <> {&fact}           AND
            RECID( buf_wth-line )   <>  par-rid  NO-ERROR.
  IF AVAIL buf_wth-line THEN DO:
    FIND FIRST inv_wth-doc NO-LOCK WHERE
                inv_wth-doc.doc-code = buf_wth-line.doc-code No-ERROR.
    IF inv_wth-doc.doc-type = {&inventory} THEN DO:
    FIND FIRST check_chk-doc No-LOCK WHERE
              check_chk-doc.out-code = inv_wth-doc.doc-code NO-ERROR.
    if avail check_chk-doc and string(check_chk-doc.chk-type) = {&pay-transfer} then.
      else do:
        assign
        v-mes = substitute("Материальная ценность &1 есть в незакрытой инвентаризации &2 по МХ &3&4добавление строки невозможно"
                          , parwth-code
                          , buf_wth-line.doc-code
                          , parw-p-code
                          , {&new-line}
                          ).
        run err-mess(input-output v-mes).
        undo _main, return error v-mes.
      END.
    END.
  END.
end.


DO ON ERROR UNDO, return '':U
   On STOP UNDO, return '':U:

  if par-mode = {&add-def} and par-rid = ? then do:

  run cur-time in this-procedure(output v-today, output v-time).

    { trg/wth-licr.i wth-line buf_wth-doc doc parw-p-code parout-code v-today }
    assign par-rid = recid(ub.wth-line).
  end.
  else do:
    FIND FIRST ub.wth-line EXCLUSIVE-LOCK WHERE
              recid(ub.wth-line) = par-rid No-WAIT No-ERROR.
    if locked ub.wth-line then do:
      assign
      v-mes = substitute("Строка документа занята").
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
    if not avail ub.wth-line then do:
      assign
      v-mes = substitute("Не найжена строка документа").
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
    if buf_wth-doc.status_ = {&permitted} and
      (ub.wth-line.doc-code <> pardoc-code OR
      ub.wth-line.wth-code <> parwth-code OR
      ub.wth-line.w-p-code <> parw-p-code OR
      ub.wth-line.out-code <> parout-code OR
      ub.wth-line.doc-sum <> pardoc-sum ) then dO:
      assign
      v-mes = substitute("Документ МЦ имеет статус &1, можно изменить только сумму факт", buf_wth-doc.status_).
      run err-mess(input-output v-mes).
      undo _main, return error v-mes.
    end.
  end.

  assign
  ub.wth-line.doc-code = pardoc-code
  ub.wth-line.wth-code = parwth-code
  ub.wth-line.w-p-code = parw-p-code
  ub.wth-line.out-code = parout-code
  ub.wth-line.ext-doc-type = parext-type
/*  buf_wth-doc.doc-sum = if (buf_wth-doc.auto-fill or buf_wth-doc.doc-type <> {&income} or buf_wth-doc.borned = yes)
                        then  (buf_wth-doc.doc-sum - ub.wth-line.doc-sum + pardoc-sum)
                        else buf_wth-doc.doc-sum  */
                        /*Решено сумму\количество во всех документах рассчитывать автоматически*/
  buf_wth-doc.doc-sum = buf_wth-doc.doc-sum - ub.wth-line.doc-sum + pardoc-sum
  ub.wth-line.doc-sum = pardoc-sum
  buf_wth-doc.sum-gds-rubl = buf_wth-doc.sum-gds-rubl - ub.wth-line.sum-gds-rubl + parsum-gds-rubl
  buf_wth-doc.sum-gds-base = buf_wth-doc.sum-gds-base - ub.wth-line.sum-gds-base + parsum-gds-base
  ub.wth-line.sum-gds-base = parsum-gds-base
  ub.wth-line.sum-gds-rubl = parsum-gds-rubl
  /*buf_wth-doc.fact-sum = if (buf_wth-doc.auto-fill or buf_wth-doc.doc-type <> {&income} or buf_wth-doc.borned = yes)
                         then (buf_wth-doc.fact-sum - ub.wth-line.fact-sum + parfact-sum)
                         else buf_wth-doc.fact-sum                                                                  */
  buf_wth-doc.fact-sum = buf_wth-doc.fact-sum - ub.wth-line.fact-sum + parfact-sum
  ub.wth-line.fact-sum = parfact-sum
  end-doc-sum  = ub.wth-line.doc-sum
  end-fact-sum = ub.wth-line.fact-sum
  ub.wth-line.price-rubl = ub.wth-line.sum-gds-rubl / ub.wth-line.fact-sum
  ub.wth-line.price-base = ub.wth-line.sum-gds-base / ub.wth-line.fact-sum
  .

  assign
  varline-doc-sum = (IF buf_wth-doc.doc-type = {&inventory}
                    THEN ub.wth-line.bef-sum
                    ELSE ub.wth-line.doc-sum
                    )
  varline-fact-sum = (IF buf_wth-doc.doc-type = {&inventory}
                    THEN ub.wth-line.aft-sum
                    ELSE ub.wth-line.fact-sum
                    )
  .

  if par-mode = {&add-def} then dO:
    release ub.wth-line no-error.
    if error-status:error then do:
            v-mes = return-value.
            run err-mess(input-output v-mes).
            return error (if p-silent = yes then v-mes else '':U).
    end.
  end.
  if not v-is-deletion then do:
    for each tt-par-dtl:
      if tt-par-dtl.wth-code <> parwth-code then next.
      varis-dtl = yes.
      run str/wth-dtl1.p (output vardtl-rec,
                    input par-mode,
                    input pardoc-code,
                    input parwth-code,
                    input parw-p-code,
                    input tt-par-dtl.par-code,
                    input tt-par-dtl.doc-sum,
                    input tt-par-dtl.fact-sum,
                    input tt-par-dtl.sum-gds-rubl ,
                    input tt-par-dtl.sum-gds-base ,
                    input parline-exist
                    ) no-error.

      if error-status:error or vardtl-rec = ? then do:
        var-entry = "b-par":U.
        return error var-entry.
      end.
      assign
      vardtl-doc-sum = vardtl-doc-sum + tt-par-dtl.doc-sum
      vardtl-fact-sum = vardtl-fact-sum + tt-par-dtl.fact-sum
      .
    END.
    if varis-dtl then dO: /*заходили в форму номиналов*/
      case buf_wth-doc.status_ :
        when {&wayb} then dO:
          if varline-doc-sum <> vardtl-doc-sum and
            NOT (vardtl-doc-sum  = 0 and
                  not can-find(first ub.wth-dtl No-LOCK WHERE
                                      ub.wth-dtl.doc-code = pardoc-code AND
                                      ub.wth-dtl.wth-code = parwth-code AND
                                      ub.wth-dtl.w-p-code = parw-p-code)
                  )
              then dO:
            assign
            v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                             , vardtl-doc-sum
                             , varline-doc-sum
                             ).
            run err-mess(input-output v-mes).
            return error (if p-silent = yes then v-mes else 'doc-sum':U).
          end.
        end.
        when {&permitted} then do:
          if varline-fact-sum <> vardtl-fact-sum and
            NOT (vardtl-fact-sum  = 0 and
                  not can-find(first ub.wth-dtl No-LOCK WHERE
                                     ub.wth-dtl.doc-code = pardoc-code AND
                                     ub.wth-dtl.wth-code = parwth-code AND
                                     ub.wth-dtl.w-p-code = parw-p-code)
                  )
              then dO:
            assign
            v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                             , vardtl-fact-sum
                             , varline-fact-sum
                             ).
            run err-mess(input-output v-mes).
            return error (if p-silent = yes then v-mes else 'wth-dtl':U).
          end.
        end.
      END CASE.
    end.
    else do:
      if can-find(first ub.wth-dtl No-LOCK WHERE
                        ub.wth-dtl.doc-code = pardoc-code AND
                        ub.wth-dtl.wth-code = parwth-code AND
                        ub.wth-dtl.w-p-code = parw-p-code) then do:
        FOR EACH ub.wth-dtl No-LOCK WHERE
                  wth-dtl.doc-code = ub.wth-line.doc-code AND
                  wth-dtl.wth-code = ub.wth-line.wth-code AND
                  wth-dtl.w-p-code = ub.wth-line.w-p-code:
          assign
          vardtl-doc-sum = vardtl-doc-sum + wth-dtl.doc-sum
          vardtl-fact-sum = vardtl-fact-sum + wth-dtl.fact-sum
          .
        END.
        if varline-doc-sum <> vardtl-doc-sum or
          varline-fact-sum <> vardtl-fact-sum then dO:
          if varline-doc-sum <> vardtl-doc-sum then
          assign
          v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                            , vardtl-doc-sum
                            , varline-doc-sum
                            ).
          else
          assign
          v-mes = substitute("Сумма по номиналам &1 не совпадает с суммой движения материального средства &2"
                            , vardtl-fact-sum
                            , varline-fact-sum
                            ).
          run err-mess(input-output v-mes).
          return error (if p-silent = yes then v-mes else 'wth-dtl':U).
        end.
      end. /*номиналы есть*/
    end. /*в форму номиналов не заходили*/
  end.
  if v-is-deletion then do:
  assign
    buf_wth-doc.doc-sum      = buf_wth-doc.doc-sum - ub.wth-line.doc-sum
    buf_wth-doc.sum-gds-rubl = buf_wth-doc.sum-gds-rubl - ub.wth-line.sum-gds-rubl
    buf_wth-doc.sum-gds-base = buf_wth-doc.sum-gds-base - ub.wth-line.sum-gds-base
    buf_wth-doc.fact-sum     = buf_wth-doc.fact-sum - ub.wth-line.fact-sum
  .
  end.
  if parline-exist and
  end-doc-sum = 0 AND
  end-fact-sum = 0
  then do:
    FIND FIRSt ub.wth-line exclusive-lock where
               recid(ub.wth-line) = par-rid.
    delete ub.wth-line no-error.
    if error-status:error then do:
      v-mes = return-value .
      run err-mess(input-output v-mes).
      return error (if p-silent = yes then v-mes else '':U).
    end.
    par-rid = ?.
  end.
END.
return '':U.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
    p-mess = substitute("Документ МЦ №&1 строка с МЦ &2 МЗ &3: &4&5"
                   , pardoc-code
                   , parwth-code
                   , parw-p-code
                   , {&new-line}
                   , p-mess).
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.