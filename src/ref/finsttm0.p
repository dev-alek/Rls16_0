block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: finsttm0.p $
$Archive: ref/finsttm0.p $

Сохранение изменений в банковских выписках

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/29/05
Author: Bakhtadze Natalya
Creation date: 08/29/05

Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

{ ref/fnstmip.i }

define input parameter p-silent                       as logical no-undo .
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode                         as character no-undo .
define input parameter p-author                       as character no-undo .
/*можети быть пусто - если оператор или название системы cl-bank*/
/*если пусто - то поля сумм по данным банка вводятся оператором
если импорт из cl-bank то обсчитваютс
поля сумм по данным TH ВСЕГДА обсчитваютс
*/
{&all-fin-statement-params-doc-status-define}
define input parameter p-status_ as character no-undo .
define input parameter p-lines-exist as logical no-undo .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finsttm0.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finsttm0.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в банковских выписках".
{ cmp/vssrevis.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define variable v-correct as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-acc as decimal no-undo .
define variable v-year-start-date as date no-undo .
define variable v-year-end-date as date no-undo .
define variable v-in-sum-doc  like ub.fin-statement.in-sum-doc no-undo .
define variable v-in-sum-base like ub.fin-statement.in-sum-base no-undo .
define variable v-in-sum-rubl like ub.fin-statement.in-sum-rubl no-undo .
define variable v-out-sum-doc like ub.fin-statement.out-sum-doc no-undo .
define variable v-out-sum-base like ub.fin-statement.out-sum-base no-undo .
define variable v-out-sum-rubl like ub.fin-statement.out-sum-rubl no-undo .
define variable v-start-sum-doc like ub.fin-statement.start-sum-doc no-undo .
define variable v-start-sum-base like ub.fin-statement.start-sum-base no-undo .
define variable v-start-sum-rubl like ub.fin-statement.start-sum-rubl no-undo .
define variable v-end-sum-doc  like ub.fin-statement.end-sum-doc no-undo .
define variable v-end-sum-base like ub.fin-statement.end-sum-base no-undo .
define variable v-end-sum-rubl like ub.fin-statement.end-sum-rubl no-undo .
define variable v-sum-doc like ub.fin-statement.sum-doc no-undo .
define variable v-sum-base like ub.fin-statement.sum-base no-undo .
define variable v-sum-rubl like ub.fin-statement.sum-rubl no-undo .
define variable v-exch-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-exch-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-base-rate like ub.curr-accnt.exch-rate no-undo .
define variable v-base-scale like ub.curr-accnt.exch-scale no-undo .
define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
define variable v-mes  as character no-undo .


define variable v-type as character no-undo .
define variable v-ret-mess as character no-undo .
/*кто запрашивает изменение документа - может быть '' или 'cl-bank:U*/
define buffer buf_sysconf  for ub.sysconf.
define buffer buf_fin-statement for ub.fin-statement.
define buffer buf_clients for ub.clients.
define buffer buf_currency for ub.currency.
define buffer buf_fin-schet for ub.fin-schet.
define buffer buf_fin-statement-line for ub.fin-statement-line.
define buffer buf_c-fin-statement for ub.c-fin-statement.

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/fin-stmh.i }


if p-mode <> {&add-def}
AND p-mode <> {&update}
then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  undo, return error '':u.
end.
{ gbl/curdbnum.i v-db-num }


find first buf_sysconf no-lock where
                buf_sysconf.host-code = p-host-code.
if not avail buf_sysconf then dO:
  run err-mess in this-procedure ( input substitute("Не найдена фирма с кодом &1", string(p-host-code)), output v-ret-mess).
  undo, return error (if p-silent = no then "host-code":U else v-ret-mess).
end.
if v-db-num <> buf_sysconf.firm-db-num
then do:
  run err-mess in this-procedure ( input substitute("Нельзя изменять запись ВЫПИСКИ в БД, отличной от главной БД фирмы&3:" +
                           "номер текущей БД &1, номер главной БД фирмы &2", v-db-num, buf_sysconf.firm-db-num, {&new-line}), output v-err-mess).
  undo, return error (if p-silent = no then "host-code":U else v-ret-mess).
end.

assign
v-base-code = buf_sysconf.base-code
.
if p-prn-doc-code <> "":U
then do:
  assign
  v-year-start-date = date(1, 1, year(p-doc-date))
  v-year-end-date = date(12, 31, year(p-doc-date))
  .
  IF can-find(first buf_fin-statement no-lock where
                    buf_fin-statement.host-code = p-host-code
                AND buf_fin-statement.prn-doc-code = p-prn-doc-code
                AND buf_fin-statement.fins-doc-type = p-fins-doc-type
                AND (buf_fin-statement.doc-date >= v-year-start-date
                     and
                     buf_fin-statement.doc-date <= v-year-end-date)
                AND (p-mode = {&add-def} OR p-doc-rec <> recid(buf_fin-statement))
                ) then do:
    run err-mess in this-procedure ( input substitute("Уже есть ВЫПИСКА с номером &1 для фирмы &2 за &3 год"
                              , p-prn-doc-code
                              , p-host-code
                              , year(p-doc-date)), output v-ret-mess).
    undo, return error (if p-silent = no then "prn-doc-code":U else v-ret-mess).
  end.
end.
if p-doc-date = ? then do:
  run err-mess in this-procedure ( input "Неверная дата составления ВЫПИСКИ", output v-ret-mess).
  undo, return error (if p-silent = no then "doc-date":U else v-ret-mess).
end.
if p-curr-code <> 0 then do:
  find first buf_currency no-lock where
            buf_currency.curr-code = p-curr-code no-error.
  if not available buf_currency then do:
    run err-mess in this-procedure ( input substitute("Не найдена валюта с кодом &1", p-curr-code), output v-ret-mess).
    undo, return error (if p-silent = no then "curr-code":U else v-ret-mess) .
  end.
end.
if p-cli-name = '':U then do:
  run err-mess in this-procedure ( input substitute("Не задано имя держателя счета для выписки"), output v-ret-mess).
  undo, return error (if p-silent = no then "cli-name":U else v-ret-mess) .
end.
if p-bank-name = '':U then do:
  run err-mess in this-procedure ( input substitute("Не задано название банка для выписки"), output v-ret-mess).
  undo, return error (if p-silent = no then "cli-name":U else v-ret-mess) .
end.
if p-bank-city = '':U then do:
  run err-mess in this-procedure ( input substitute("Не задан город банка для выписки"), output v-ret-mess).
  undo, return error (if p-silent = no then "cli-name":U else v-ret-mess) .
end.
if p-lines-exist then do:
  find first buf_fin-schet no-lock where
            buf_fin-schet.host-code = p-host-code
        AND buf_fin-schet.code-schet = p-code-schet no-error.
  if not available buf_fin-schet then do:
    run err-mess in this-procedure ( input substitute("Не найден РАСЧЕТНЫЙ СЧЕТ: фирма &1 код счета &2"
                                                    , p-host-code
                                                    , p-code-schet)
                                  , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.curr-code <> p-curr-code then do:
    run err-mess in this-procedure ( input substitute("Валюта РАСЧЕТНОГО СЧЕТА: фирма &1 код счета &2 валюта &3 - не совпадает с валютой ВЫПИСКИ &4",
    p-host-code, p-code-schet, buf_fin-schet.curr-code, p-curr-code) , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
  if buf_fin-schet.code-bank <> p-code-bank then do:
    run err-mess in this-procedure ( input substitute("Банк РАСЧЕТНОГО СЧЕТА: фирма &1 код счета &2 код банка &3 - не совпадает с кодом банка ВЫПИСКИ &4",
    p-host-code, p-code-schet, buf_fin-schet.code-bank, p-code-bank) , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
  if not (buf_fin-schet.cli-type = {&cmp}
  and buf_fin-schet.cli-code = p-host-code ) then do:
    run err-mess in this-procedure ( input substitute("Держатель РАСЧЕТНОГО СЧЕТА (фирма &1 р/счет &2 код счета &3)&6&4&5 - не является СВОЕЙ ФИРМОЙ&6" +
                                                       "выписку можно создавать только для счетов СВОЕЙ ФИРМЫ"
                                                       ,p-host-code
                                                       ,buf_fin-schet.r-schet
                                                       ,buf_fin-schet.code-schet
                                                       ,buf_fin-schet.cli-type
                                                       ,buf_fin-schet.cli-code
                                                       ,{&new-line}
                                                       )
                                              , output v-ret-mess).
    undo, return error (if p-silent = no then "code-schet":U else v-ret-mess).
  end.
end.

if p-status_ <> {&fin-new}
and p-author <> '':U
then do:
  if v-base-code <> 0 then do:
  { gbl/exchrate.i v-base-code p-fact-date v-base-rate v-base-scale v-curr-abbr }
  end.
  if p-curr-code <> 0 then do:
    { gbl/exchrate.i p-curr-code p-fact-date v-exch-rate v-exch-scale v-curr-abbr }
  end.
  assign
  v-sum-doc = p-sum-doc
  v-sum-rubl = (if p-curr-code = 0
                then p-sum-doc
                else (p-sum-doc * v-exch-rate / v-exch-scale))
  v-sum-base = if v-base-code = 0
                then v-sum-rubl
                else (v-sum-rubl / v-base-rate * v-base-scale)
  v-in-sum-doc = p-in-sum-doc
  v-in-sum-rubl = (if p-curr-code = 0
                then p-in-sum-doc
                else (p-in-sum-doc * v-exch-rate / v-exch-scale))
  v-in-sum-base = if v-base-code = 0
                then v-in-sum-rubl
                else (v-in-sum-rubl / v-base-rate * v-base-scale)
  v-out-sum-doc = p-out-sum-doc
  v-out-sum-rubl = (if p-curr-code = 0
                then p-out-sum-doc
                else (p-out-sum-doc * v-exch-rate / v-exch-scale))
  v-out-sum-base = if v-base-code = 0
                then v-out-sum-rubl
                else (v-out-sum-rubl / v-base-rate * v-base-scale)
  v-start-sum-doc = p-start-sum-doc
  v-start-sum-rubl = (if p-curr-code = 0
                then p-start-sum-doc
                else (p-start-sum-doc * v-exch-rate / v-exch-scale))
  v-start-sum-base = if v-base-code = 0
                then v-start-sum-rubl
                else (v-start-sum-rubl / v-base-rate * v-base-scale)
  v-end-sum-doc = p-end-sum-doc
  v-end-sum-rubl = (if p-curr-code = 0
                then p-end-sum-doc
                else (p-end-sum-doc * v-exch-rate / v-exch-scale))
  v-end-sum-base = if v-base-code = 0
                then v-end-sum-rubl
                else (v-end-sum-rubl / v-base-rate * v-base-scale)
  .
end.

if lookup(p-fins-ext-doc-type, {&fins-ext-doc-types}) = 0 then do:
  run err-mess in this-procedure ( input substitute("Неверный расширенный тип выписки &1", p-fins-ext-doc-type), output v-ret-mess ).
  undo, return error (if p-silent = no then  "fins-ext-doc-type":U  else v-ret-mess).
end.

&scop prfx p-
/*здесь проверим все выписки отдельно по типам*/
CASE p-fins-doc-type:
  when {&standard-sttm} then do:
    run ref/finstm01.p (
                    input p-mode
                    ,input "":U /*p-close-mode*/
                    {&all-fin-statement-params-doc-status-transfer}
                    ,input "":U
                    ,input ?
                    ,output v-correct
                    ,output v-err-mess
                    ) no-error.
  end.
END CASE.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = {&add-def} then do:
    if p-sttm-code = 0 then do:
      assign
      p-sttm-code = next-value(s-fin-sttm, {&db-name_schema})
      .
    end.
    create ub.fin-statement.
    assign
    ub.fin-statement.host-code = p-host-code
    ub.fin-statement.sttm-code = p-sttm-code
    ub.fin-statement.status_ = {&fin-new}
    p-doc-rec = recid(ub.fin-statement)
    .
  end.
  else do:
    FIND FIRST ub.fin-statement where
              recid(ub.fin-statement) = p-doc-rec No-ERROR.
    if not available ub.fin-statement then do:
      run err-mess in this-procedure ( input substitute("Не найдена запись ВЫПИСКИ - p-doc-rec &1", p-doc-rec), output v-ret-mess).
      undo, return error (if p-silent = no then  '':u  else v-ret-mess).
    end.
    if ub.fin-statement.host-code <> p-host-code
    OR ub.fin-statement.sttm-code <> p-sttm-code
    OR ub.fin-statement.fins-doc-type <> p-fins-doc-type
    OR ub.fin-statement.fins-doc-type <> p-fins-doc-type
    OR (p-lines-exist
        AND (
        ub.fin-statement.bank-name           <> p-bank-name
        or
        ub.fin-statement.bik                 <> p-bik
        or
        ub.fin-statement.c-schet             <> p-c-schet
        or
        ub.fin-statement.code-schet          <> p-code-schet
        or
        ub.fin-statement.r-schet             <> p-r-schet
            )
    )
    then do:
      run err-mess in this-procedure ( input substitute("Для уже имеющейся записи нельзя изменить&1" +
                               "код фирмы, внутренний № выписки, тип выписки, счет&1"
                               , {&new-line}), output v-ret-mess).
      undo, return error (if p-silent = no then  '':U  else v-ret-mess).
    end.
    if ub.fin-statement.status_ <> {&fin-new}
    then do:
      if
      ub.fin-statement.start-sum-doc       <> p-start-sum-doc
      or
      ub.fin-statement.end-sum-doc         <> p-end-sum-doc
      or
      ub.fin-statement.in-sum-doc          <> p-in-sum-doc
      or
      ub.fin-statement.out-sum-doc         <> p-out-sum-doc
      or
      ub.fin-statement.sum-doc             <> p-sum-doc
      then do:
        run err-mess in this-procedure ( input substitute("Для ВЫПИСКИ в статусе не &1&2" +
                                "НЕЛЬЗЯ менять суммы остатков, оборотов, счет, валюту платежа&2"
                                ,{&fin-new}
                                , {&new-line})
                      , output v-ret-mess).
        undo, return error (if p-silent = no then  '':U  else v-ret-mess).
      end.
    end.
  end.
  create tt-fin-statement.
  buffer-copy ub.fin-statement to tt-fin-statement.
  assign
  ub.fin-statement.curr-code           = p-curr-code
  ub.fin-statement.doc-date            = p-doc-date
  ub.fin-statement.fins-doc-type       = p-fins-doc-type
  ub.fin-statement.fins-ext-doc-type   = p-fins-ext-doc-type
  ub.fin-statement.bank-name           = p-bank-name
  ub.fin-statement.bank-city           = p-bank-city
  ub.fin-statement.bik                 = p-bik
  ub.fin-statement.c-schet             = p-c-schet
  ub.fin-statement.code-schet          = p-code-schet
  ub.fin-statement.code-bank           = p-code-bank
  ub.fin-statement.r-schet             = p-r-schet
  ub.fin-statement.prn-doc-code        = p-prn-doc-code
  ub.fin-statement.PS                  = p-PS
  ub.fin-statement.cli-name            = p-cli-name
  ub.fin-statement.start-date          = p-start-date
  ub.fin-statement.end-date            = p-end-date
  .
  if p-author <> '':U
  or p-status_ = {&fin-new}
  then do:
    assign
    ub.fin-statement.sum-base            = v-sum-base
    ub.fin-statement.sum-doc             = p-sum-doc
    ub.fin-statement.sum-rubl            = v-sum-rubl
    ub.fin-statement.in-sum-base         = v-in-sum-base
    ub.fin-statement.in-sum-doc          = p-in-sum-doc
    ub.fin-statement.in-sum-rubl         = v-in-sum-rubl
    ub.fin-statement.out-sum-base        = v-out-sum-base
    ub.fin-statement.out-sum-doc         = p-out-sum-doc
    ub.fin-statement.out-sum-rubl        = v-out-sum-rubl
    ub.fin-statement.start-sum-base      = v-start-sum-base
    ub.fin-statement.start-sum-doc       = p-start-sum-doc
    ub.fin-statement.start-sum-doc-th    = p-start-sum-doc-th
    ub.fin-statement.start-sum-rubl      = v-start-sum-rubl
    ub.fin-statement.end-sum-base        = v-end-sum-base
    ub.fin-statement.end-sum-doc         = p-end-sum-doc
    ub.fin-statement.end-sum-rubl        = v-end-sum-rubl
    ub.fin-statement.num-docs            = p-num-docs
    .
  end.
  release ub.fin-statement no-error.
  if error-status:error then do:
   run err-mess in this-procedure ( input substitute("Ошибка при сохранении записи ПЛАТЕЖА &1: &2", ERROR-STATUS:GET-message(1), return-value ), output v-ret-mess).
    undo, return error (if p-silent = no then  "":U  else v-ret-mess).
  end.
  /*проверим нужно ли писать историю.*/
  find last buf_c-fin-statement no-lock where
            buf_c-fin-statement.host-code = p-host-code
        AND  buf_c-fin-statement.sttm-code = p-sttm-code
        AND  buf_c-fin-statement.corr-user-db-num = g#db-num no-error.
  if not available buf_c-fin-statement
  /*кто-то исправил созданный другим документ и это исправление - первая запись в истории*/
  or (available buf_c-fin-statement
  and buf_c-fin-statement.corr-user-name <> g#userid)
  /*предыдущее исправление было другим пользователем*/
  then do:
    run fin-statementh_write-fin-statement-history in this-procedure (
                                                            buffer tt-fin-statement
                                                            ,input p-host-code
                                                            ,input p-sttm-code
                                                            ) no-error .
    if error-status:error then do:
        v-mes = error-status:get-message(1) .
        run err-mess in this-procedure ( input v-mes, output v-ret-mess).
        undo _main, return error (if p-silent  = no then '':U else v-ret-mess).
    end.
  end.
end. /*doe*/


PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  define output parameter p-ret-mess as character no-undo .
  assign
  p-ret-mess =  substitute("ВЫПИСКА &1: фирма: &2 N: &3,&4 вн. № &5&4&6"
                            , p-fins-doc-type
                            , p-host-code
                            , p-prn-doc-code
                            , {&new-line}
                            , p-sttm-code
                            , p-mess
                            ).

  CASE p-silent:
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.