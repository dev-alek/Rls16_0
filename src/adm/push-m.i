/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

'Толкатель' автозапуска

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "with-attr-code":U &then
  function get-attr-code returns character (input p-task-type as character ).

    define variable v-db-attr-code as character no-undo .

    case p-task-type :
      when {&btpr-type-autonws} then do:
        assign
          v-db-attr-code = {&attr-schedule-nws}.
        .
      end.
      when {&btpr-type-autoarh} then do:
        assign
          v-db-attr-code = {&attr-schedule-arc}
        .
      end.
      when {&btpr-type-autoexp} then do:
        assign
          v-db-attr-code = {&attr-schedule-exp}
        .
      end.
      when {&btpr-type-autooxml} then do:
        assign
          v-db-attr-code = {&attr-schedule-oxml}
        .
      end.
      when {&btpr-type-autogetcd} then do:
        assign
          v-db-attr-code = {&attr-schedule-getcd}
        .
      end.
      when {&btpr-type-autosale} then do:
        assign
          v-db-attr-code = {&attr-schedule-sale}
        .
      end.
      when {&btpr-type-autosuz} then do:
        assign
          v-db-attr-code = {&attr-schedule-suz}
        .
      end.
      when {&btpr-type-autocbnk} then do:
        assign
          v-db-attr-code = {&attr-schedule-cbnk}
        .
      end.
      when {&btpr-type-autofree} then do:
        assign
          v-db-attr-code = {&attr-schedule-free}
        .
      end.
      when {&btpr-type-mercury} then do:
        assign
          v-db-attr-code = {&attr-schedule-merc}
        .
      end.
      when {&btpr-type-hddtest} then do:
        assign
          v-db-attr-code = {&attr-schedule-hdd}
        .
      end.
      when {&btpr-type-is_motp} then do:
        assign
          v-db-attr-code = {&attr-schedule-motp}
        .
      end.
      when {&btpr-type-is_diadoc} then do:
        assign
          v-db-attr-code = {&attr-schedule-diadoc}
        .
      end.
      when {&btpr-type-is_PM} then do:
        assign
          v-db-attr-code = {&attr-schedule-isPM}
        .
      end.
      otherwise do:
        assign
          v-db-attr-code = ?
        .
      end.
    end.
    return v-db-attr-code.

  end function.

&endif

function get-str-type returns character (input p-task-type as character ).

  define variable v-str as character no-undo .

  case p-task-type :
    when {&btpr-type-autonws} then do:
      assign
        v-str = "связи с БД"
      .
    end.
    when {&btpr-type-autoarh} then do:
      assign
        v-str = "расчета архивов по БД"
      .
    end.
    when {&btpr-type-autoexp} then do:
      assign
        v-str = "экспорта по БД"
      .
    end.
    when {&btpr-type-autooxml} then do:
      assign
        v-str = "OpenXML по БД"
      .
    end.
    when {&btpr-type-autogetcd} then do:
      assign
        v-str = "приема информации с касс по БД"
      .
    end.
    when {&btpr-type-autosale} then do:
      assign
        v-str = "работы с документами продажи по БД"
      .
    end.
    when {&btpr-type-autosuz} then do:
      assign
        v-str = "запуска отчетов по БД"
      .
    end.
    when {&btpr-type-autocbnk} then do:
      assign
        v-str = "эксп/имп в КЛИЕНТ-БАНК"
      .
    end.

    when {&btpr-type-autofree} then do:
      assign
        v-str = "выполнение произ.заданий"
      .
    end.
    
    when {&btpr-type-mercury} then do:
      assign
        v-str = "обмена с ФГИС Меркурий по БД"
      .
    end.
    
    when {&btpr-type-hddtest} then do:
      assign
        v-str = "мониторинга HDD по БД"
      .
    end.
    
    when {&btpr-type-is_motp} then do:
      assign
        v-str = "обмена с ИС МОТП по БД"
      .
    end.

    when {&btpr-type-is_diadoc} then do:
      assign
        v-str = "обмена с ИС Диадок по БД"
      .
    end.
    when {&btpr-type-is_diadoc} then do:
      assign
        v-str = "выгрузки в ИС Президентский мониторинг по БД"
      .
    end.
    otherwise do:
      assign
        v-str = "экспорта по БД"
      .
    end.
  end.

  return v-str.

end function.

procedure push-abtpr :
  define input parameter parparentproc as handle    no-undo .
  define input parameter p-db-num      as integer   no-undo .
  define input parameter p-task-type   as character no-undo .
  define input parameter p-start-type  as character no-undo .
  define input parameter p-date        as date      no-undo .
  define input parameter p-time        as integer   no-undo .

  do
  on error undo, return error
  :
    define buffer buf_BatchProcess for ub.BatchProcess .
    define buffer buf_sys-ctrl     for ub.sys-ctrl .

    define variable v-curr-date as date      no-undo .
    define variable v-curr-time as integer   no-undo .
    define variable v-str       as character no-undo .
    define variable v-user-id   as character no-undo .

    run cur-time in this-procedure
      ( output v-curr-date
       ,output v-curr-time
      ) no-error.
    if error-status :error then do:
      return error substitute( "&1. Ошибка при определении текущей даты!", vss-include-info{&vssseq} ).
    end.

    if p-date = ? then do:
      assign
        p-date = v-curr-date
      .
    end.

    if p-time = ? then do:
      assign
        p-time = v-curr-time
      .
    end.

    assign
      v-str = get-str-type( p-task-type )
    .
    if v-str = ? then do:
      return error substitute( "&1. НЕТ ОБРАБОТКИ АТРИБУТА &2!", vss-include-info{&vssseq}, p-task-type ).
    end.

    run get-userid in parparentproc
      ( output v-user-id
      ).

    find first buf_sys-ctrl no-lock .
    find first buf_BatchProcess no-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( p-db-num )
        and buf_BatchProcess.CharKey_Two = "auto":U
      no-error
    .
    if available buf_BatchProcess
      and ( buf_BatchProcess.BP_ExecSysDate < v-curr-date
            or (buf_BatchProcess.BP_ExecSysDate = v-curr-date
                and buf_BatchProcess.BP_ExecSysTimeInt < v-curr-time
                )
          )
    then do:
      return error substitute( "Автоматический режим &1 для БД &2 не запущен или в данный момент идет обработка!"
                              ,v-str ,p-db-num
                            ).
    end.

    find first buf_BatchProcess exclusive-lock
      where buf_BatchProcess.BP_Status   = {&btpr-normal}
        and buf_BatchProcess.BP_Type     = p-task-type
        and buf_BatchProcess.CharKey_One = string( p-db-num )
        and buf_BatchProcess.CharKey_Two = p-start-type
      no-error
    .
    if not available buf_BatchProcess then do:
      create buf_BatchProcess.
      assign
        buf_BatchProcess.BatchProcess# = next-value (s-btpr, {&db-name_schema})
        buf_BatchProcess.BP_Status     = {&btpr-normal}
        buf_BatchProcess.BP_Type       = p-task-type
        buf_BatchProcess.CharKey_One   = string( p-db-num )
        buf_BatchProcess.CharKey_Two   = p-start-type
      .
    end.
    assign
      buf_BatchProcess.CharKey_Three     = string( buf_sys-ctrl.db-num ) + {&delim-key} + p-task-type + {&delim-key} + "-1":U
      buf_BatchProcess.User_ID           = v-user-id
      buf_BatchProcess.Key#_One          = (if p-start-type = "manual":U then 1 else 0)
      buf_BatchProcess.BP_SysDate        = v-curr-date
      buf_BatchProcess.BP_SysTimeInt     = v-curr-time
      buf_BatchProcess.BP_SysTime        = string(v-curr-time, 'HH:MM:SS':U)
      buf_BatchProcess.BP_ExecSysDate    = p-date
      buf_BatchProcess.BP_ExecSysTimeInt = p-time
      buf_BatchProcess.BP_ExecSysTime    = string(p-time, 'HH:MM:SS':U)
    .

  end.

  return.
end procedure. /* push-m */


/* $Workfile$ end */