block-level on error undo, throw.
/*

$Revision: 784232a2254b, 2720, rls $
$Author: SSlivenko $
$Date: Пн янв 18 10:14:30 2021 +0300 $
$Workfile: chk-btpr.p $
$Archive: utl/chk-btpr.p $

проверка BatchProcess ДО начала обрезани

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/13/06
Author: Dmitry Ukhanov
Creation date: 04/13/06

*/
/*
Если ГБД готова, то p-ready устанавливается true
*/
define input  parameter p-type-cut as integer   no-undo .
define input  parameter p-db-list  as character no-undo .
define output parameter p-ready    as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 784232a2254b, 2720, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн янв 18 10:14:30 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-btpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chk-btpr.p $":U .
define variable vss-description as character no-undo init "проверка BatchProcess ДО начала обрезания".
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  define buffer buf_BatchProcess for ub.BatchProcess .

  define variable v-return-value as character no-undo .

  assign
    p-ready        = true
    v-return-value = "":U
  .

  for each buf_BatchProcess
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    case buf_BatchProcess.BP_type
    :
      when {&btpr-type-autonws} or
      when {&btpr-type-autoarh} or
      when {&btpr-type-autoexp} or
      when {&btpr-type-autooxml} or
      when {&btpr-type-autosuz} or
      when {&btpr-type-autogetcd} or
      when {&btpr-type-autosale} or
      when {&btpr-type-autocbnk} or
      when {&btpr-type-autofree} or
      when {&btpr-type-mercury} or
      when {&btpr-type-hddtest} or
      when {&btpr-type-is_motp} or
      when {&btpr-type-is_diadoc} or
      when {&btpr-type-is_PM}
      then do:
        /* Игнорируется. Создаются сами заново. */
      end.
      when {&btpr-type-cutdbs}
      then do:
        /* Игнорируется. Контролируется самим обрезанием */
      end.
      when {&btpr-type-rt-doc} or
      when {&btpr-type-rt-line} or
      when {&btpr-type-rt-bcprint}
      then do:
        /* Игнорируется. Вся работа с радиотерминалом при обрезании будет потеряна */
      end.
      when {&btpr-type-lock-route}
      then do:
        assign
          p-ready = false
          v-return-value = v-return-value + {&new-line}
                           + substitute( "Маршрутизация в БД &1 заблокирована пользователем &2 &3 в &4 (&5)"
                                         ,buf_BatchProcess.CharKey_One
                                         ,buf_BatchProcess.User_ID
                                         ,string( buf_BatchProcess.BP_SysDate, "99.99.9999" )
                                         ,buf_BatchProcess.BP_SysTime
                                         ,buf_BatchProcess.CharKey_Three
                                        )
        .
      end.
      when {&btpr-type-autoupg}
      then do:
        assign
          p-ready = false
          v-return-value = v-return-value + {&new-line} + "Не завершен upgrade."
        .
      end.
      when {&btpr-type-arh}
      then do:
        /* задания на расчёт складского архива по товарам */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-ahsp}
      then do:
        /* задания на расчёт складского архива по поставщикам */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-aht}
      then do:
        /* задания на расчёт складского архива по типам приобретения */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-prc}
      then do:
        /* задания на перерасчёт переоценок после закрытия документов задним числом */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-trnhd}
      then do:
        /* задания на перерасчёт шапок складских документов */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-hold}
      then do:
        /* задания на расчёт межфирменного архива по приходам и расходам */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-hinv}
      then do:
        /* задания на расчёт межфирменного архива по инвентаризациям */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-hspi}
      then do:
        /* задания на расчёт межфирменного архива по документам списания */
        /* обрезанию не мешают */
      end.
      when {&btpr-type-gds}
      then do:

      end.
      when {&btpr-type-dcard}
      then do:

      end.
      when {&btpr-type-goa}
      then do:

      end.
      when {&btpr-type-seller}
      then do:

      end.
      when {&btpr-type-cashier}
      then do:

      end.
      when {&btpr-type-fgrp}
      then do:

      end.
      when {&btpr-type-move-object}
      then do:
          assign
          p-ready = false
          v-return-value = v-return-value + {&new-line} +
                          substitute("Не завершен перенос объекта из одной БД в БД:&1" +
                                     "&2&3 переносится из БД &4 в БД &5"
                                     , {&new-line}
                                     , buf_BatchProcess.CharKey_One
                                     , buf_BatchProcess.Key#_One
                                     , buf_BatchProcess.Key#_Two
                                     , buf_BatchProcess.Key#_Three )
          .
      end.
      when {&btpr-type-bcode}
      then do:

      end.
      when {&btpr-type-ren-art}
      then do:

      end.
      otherwise do:
        if buf_BatchProcess.BP_type begins {&btpr-type-lock}
        or buf_BatchProcess.BP_type begins {&btpr-type-lock-user}
        then do:
          /* записи блокировки ресурсов */
          /* обрезанию не мешают */
        end.
        else do:
          return error substitute("&1. Неизвестный тип BatchProcess &2", vss-workfile, buf_BatchProcess.BP_type ) .
        end.
      end.
    end case.
  end.

  return v-return-value .
end.

/* $Workfile: chk-btpr.p $ end */