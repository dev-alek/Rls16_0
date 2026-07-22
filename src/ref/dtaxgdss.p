block-level on error undo, throw.
/*

$Revision: da70ce2a1328, 1072, rls $
$Author: SMMolotkov $
$Date: Fri Oct 06 18:35:13 2017 +0300 $
$Workfile: dtaxgdss.p $
$Archive: ref/dtaxgdss.p $

Заполнение полей временной таблицы tt-tax

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/31/06
Author: Bakhtadze Natalya
Creation date: 03/31/06

налоги на товар для показа в карточке товара
на основании таблиц tax-rate-gds tax tax-rate tax-rate-value tax-rate-gds-grp tax-unit

*/

define input parameter p-silent as logical no-undo .
DEFINE INPUT PARAMETER parunit-base like ub.goods.unit-base no-undo.
DEFINE INPUT PARAMETER parnode-code like ub.gds-grp.node-code no-undo.
DEFINE INPUT PARAMETER par-recid as recid no-undo.
DEFINE INPUT PARAMETER par-copy as recid no-undo.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable vss-revision    as character no-undo init "$Revision: da70ce2a1328, 1072, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:35:13 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dtaxgdss.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dtaxgdss.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы tt-tax для показа в карточке товара".
{ cmp/vssrevis.i }

{ str/tt-tax.i SHARED tt-tax full }
{ cmp/trg-def.i }
{ trg/factord.i }
{ gbl/cur-time.i }

define variable v-mess as character no-undo .
DEFINE buffer for-goods for ub.goods.
define buffer buf_goods for ub.goods.

/*вспомогательные*/
define variable found as logical no-undo.
define variable vargds-code like ub.goods.gds-code no-undo.
DEFINE VARIABLE varrate-code like ub.tax-rate.rate-code no-undo .
DEFINE VARIABLE vartax-value like ub.tax-rate-value.rate-value no-undo .
DEFINE VARIABLE vtoday-fact-order as decimal no-undo .
DEFINE VARIABLE vgds-fact-order as decimal no-undo .
DEFINE VARIABLE varfact-date like ub.tax-rate-gds.fact-date no-undo .
DEFINE VARIABLE is-copy as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer buf_units for ub.units.
define buffer buf_tax-units for ub.tax-units.
define buffer buf_tax-rate-gds for ub.tax-rate-gds.
define buffer buf_tax-rate-gds-grp for ub.tax-rate-gds-grp.
define buffer buf_tax-rate for ub.tax-rate.
define buffer buf_tax for ub.tax.

if (parhost-code = 0 or
   parobj-type = "":U or
   parobj-code = 0)
and p-silent = no
then do:
   message
   vss-workfile vss-revision vss-description skip
   "Неверные значения параметров объект и/или фирма при вызове процедуры dtaxgdss.p "
   view-as alert-box error .
end.


for each tt-tax:
    delete tt-tax.
end.

FIND FIRST buf_units no-lock where
           buf_units.unit-name = parunit-base NO-ERROR.
if not avail buf_units then do:
  v-mess = substitute("Нет ед. изм. &1", parunit-base).
  run err-mess in this-procedure ( input-output v-mess).
  return error (if p-silent = yes then v-mess else '':U).
end.
_main:
do
on error undo, return error
:

  IF not par-recid = par-copy then do:
    /*режим копирования*/
    FIND FIRST for-goods NO-LOCK WHERE
                recid(for-goods) = par-copy no-error.
    if not avail for-goods then do:
      v-mess = substitute("Нет товара с recid &1, заданного как источник при копировании", par-copy).
      run err-mess in this-procedure ( input-output v-mess).
      undo _main, return error (if p-silent = yes then v-mess else '':U).
    end.
    assign
    vargds-code = for-goods.gds-code
    is-copy = yes
    .
  end.
  else do:
    if par-recid <> ? then do:
      find first buf_goods no-lock where
                recid(buf_goods) = par-recid no-error .
      if not available buf_goods then do:
        v-mess = substitute("Нет товара с recid &1", par-recid).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
    if avail buf_goods
    then
    assign
    vargds-code = buf_goods.gds-code
    .
  end.
  if par-recid <> ? then do:
    run cur-time in this-procedure(output v-today, output v-time).
  end.
  else do:
    assign
    v-today = 01/01/1990
    .
  end.
  run factord-end-day in this-procedure (
                                          input v-today
                                         ,output vtoday-fact-order).
  /*товара еще нет тогда должен быть известен хотя бы группа */

  /*определим какие налоги должны присутствовать на каждый товар*/

  FOR EACH buf_tax-units No-LOCK WHERE
            LOOKUP(buf_tax-units.type, buf_units.type) > 0
      BREAK BY
      buf_tax-units.tax-code:
    IF FIRST-OF(buf_tax-units.tax-code) then do:
      found = no.
      FIND FIRST buf_tax No-LOCK WHERE
                  buf_tax.tax-code = buf_tax-units.tax-code No-ERROR.
      if error-status:error or not avail buf_tax then do:
        v-mess = substitute("Не найден налог с кодом &1 для ед.изм. с типом &2"
                           , buf_tax-units.tax-code
                           ,buf_units.type).
        run err-mess in this-procedure ( input-output v-mess).
        undo _main, return error (if p-silent = yes then v-mess else '':U).
      end.
      if NOT buf_tax.individual then do:
        if par-copy <> ? then do:

          FIND LAST buf_tax-rate-gds No-LOCK WHERE
                    buf_tax-rate-gds.gds-code = vargds-code AND
                    buf_tax-rate-gds.tax-code = buf_tax.tax-code AND
                    buf_tax-rate-gds.host-code = 0 AND
                    buf_tax-rate-gds.obj-type = "" AND
                    buf_tax-rate-gds.obj-code = 0 /*AND*/
                    /*
                    freeze
                    buf_tax-rate-gds.host-code = parhopst-code AND
                    buf_tax-rate-gds.obj-type = parobj-type AND
                    buf_tax-rate-gds.obj-code = parobj-code AND

                    */
                     use-index pi
                    /*buf_tax-rate-gds.fact-order <= vtoday-fact-order*/  No-ERROR.

          if avail buf_tax-rate-gds then do:
            found = yes.
            assign
            varrate-code = buf_tax-rate-gds.rate-code
            varfact-date = ( if is-copy then v-today else  buf_tax-rate-gds.fact-date)
            .
            run factord-end-day in this-procedure (input varfact-date,
                                                  output vgds-fact-order).
          end.
          else do:
            if vargds-code <> 0 then do:
              v-mess = substitute("Не найдена запись ставки налога на товар &1&2"  +
                                  "Код налога &3&2"  +
                                  "Будет показана ставка налога по соответствующей группе&2" +
                                  "Для исправления ошибки и создания записи ставки налога&2"  +
                                  "откройте карточку товара на изменение и сохраните её.&2" +
                                  "Будет создана запись ставки налога на товар с датой 01/01/1990"
                                   , vargds-code
                                   ,{&new-line}
                                   ,buf_tax.tax-code ).
              run err-mess in this-procedure ( input-output v-mess).
              if p-silent then undo _main, return error (if p-silent = yes then v-mess else '':U).
            end.
          end.
        end.
        if par-copy = ? or not found then do:
          FIND FIRST buf_tax-rate-gds-grp No-LOCK WHERE
                      buf_tax-rate-gds-grp.node-code = parnode-code AND
                      buf_tax-rate-gds-grp.tax-code = buf_tax.tax-code No-ERROR.
          if not avail buf_tax-rate-gds-grp then do:
            v-mess = substitute("Не найдена ставка налога на товар группы товаров с кодом группы &1&2"  +
                                "Код налога &3"
                                  ,parnode-code
                                  ,{&new-line}
                                  ,buf_tax.tax-code ).
            run err-mess in this-procedure ( input-output v-mess).
            undo _main, return error (if p-silent = yes then v-mess else '':U).
          end.
          assign
          varrate-code = buf_tax-rate-gds-grp.rate-code
          varfact-date = v-today
          .
          run factord-end-day in this-procedure (input varfact-date, output vgds-fact-order).
        end.
        FIND FIRST buf_tax-rate No-LOCK WHERE
                  buf_tax-rate.tax-code = buf_tax.tax-code AND
                  buf_tax-rate.rate-code = varrate-code No-ERROR.
        if error-status:error or not avail buf_tax-rate then do:
          v-mess = substitute("Не найдена запись ставки налога:&1"  +
                              "Код налога &2&1" +
                              "Код ставки &3"
                              ,{&new-line}
                              ,buf_tax.tax-code
                              ,varrate-code).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else '':U).
        end.
        { gbl/pftaxval.i recid(buf_tax-rate) 0 0 ? parhost-code parobj-type parobj-code vartax-value no-error }

        if error-status:error or vartax-value = ? then do:
          v-mess = substitute("Ошибка при определении значения ставки налога на товар&1"  +
                             "код налога: &2&1" +
                             "ставка налога: &3"
                             ,{&new-line}
                             ,buf_tax-rate.tax-code
                             ,buf_tax-rate.rate-code).
          run err-mess in this-procedure ( input-output v-mess).
          undo _main, return error (if p-silent = yes then v-mess else '':U).
        end.
      end. /*if not tax.individual */
      FIND FIRST tt-tax NO-LOCK WHERE
                tt-tax.tax-code = buf_tax.tax-code No-ERROR.
      if not avail tt-tax then do:
          create
          tt-tax.
          assign
          tt-tax.tax-code = buf_tax.tax-code
          tt-tax.tax-name = buf_tax.tax-name
          tt-tax.rate-code = if buf_tax.individual then ? else buf_tax-rate.rate-code
          tt-tax.rate-name = if buf_tax.individual then buf_tax.tax-name else buf_tax-rate.rate-name
          tt-tax.tax-type = buf_tax.tax-type
          tt-tax.rate-value = if buf_tax.individual then ? else vartax-value
          tt-tax.individual = buf_tax.individual
          tt-tax.tax-rate-gds-rc = if (avail buf_goods and recid(buf_goods) = par-copy and avail buf_tax-rate-gds )
                              then recid(buf_tax-rate-gds)
                              else ?
          tt-tax.fact-date = varfact-date
          tt-tax.fact-order = vgds-fact-order
          .
          if (avail buf_goods and recid(buf_goods) = par-copy and avail buf_tax-rate-gds ) then
          assign
          tt-tax.corr-user-name    = buf_tax-rate-gds.corr-user-name
          tt-tax.corr-user-db-num  = buf_tax-rate-gds.corr-user-db-num
          tt-tax.corr-date         = buf_tax-rate-gds.corr-date
          tt-tax.corr-time         = buf_tax-rate-gds.corr-time
          .
      end. /*not avail tt-tax*/
    END. /*first of buf_tax-unit.tax-code*/
  END. /*for each buf_tax-unit*/
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Определение налогов на товар:&1&2"
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.