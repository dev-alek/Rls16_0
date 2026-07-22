block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmdcmpgd.p $
$Archive: nws/cmdcmpgd.p $

Распределённая проверка целостности остатков по товару

Автор: Перваков Михаил Сергеевич
Дата создания: 03/16/05
Author: Mikhail Pervakov
Creation date: 03/16/05

Из УБД пришла информация об остатках по товару.
Необходимо сравнить пришедшую информацию с текущими остатками по товару

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter    as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdcmpgd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdcmpgd.p $":U .
define variable vss-description as character no-undo init "Распределённая проверка целостности остатков по товару".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter,p-obj-type,p-obj-code)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define temp-table temp-gds-obj no-undo like ub.gds-obj .
define temp-table temp-prt-obj no-undo like ub.prt-obj .
define temp-table temp-parts   no-undo like ub.parts .

define temp-table temp-cmp-gds-obj no-undo
  field gds-code          as integer
  field current-fact-qnty as decimal
  field current-free-qnty as decimal
  field remote-fact-qnty  as decimal
  field remote-free-qnty  as decimal
  field error-qnty        as logical

  index xpk is primary unique gds-code
  index xie1 error-qnty
  .

define temp-table temp-cmp-prt-obj no-undo
  field gds-code          as integer
  field prt-code          as integer
  field current-fact-qnty as decimal
  field current-free-qnty as decimal
  field remote-fact-qnty  as decimal
  field remote-free-qnty  as decimal

  index xpk is primary unique gds-code prt-code
  .

define temp-table temp-cmp-parts no-undo
  field gds-code          as integer
  field in-code           as character
  field out-code          as character
  field part-code         as character
  field current-fact-qnty as decimal
  field remote-fact-qnty  as decimal

  index xpk is primary unique gds-code in-code out-code part-code
  .

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .

define buffer buf_batchprocess     for ub.batchprocess .
define buffer buf_temp-gds-obj     for temp-gds-obj .
define buffer buf_temp-prt-obj     for temp-prt-obj .
define buffer buf_temp-parts       for temp-parts .
define buffer buf_gds-obj          for ub.gds-obj .
define buffer buf_prt-obj          for ub.prt-obj .
define buffer buf_parts            for ub.parts .
define buffer buf_temp-cmp-gds-obj for temp-cmp-gds-obj .
define buffer buf_temp-cmp-prt-obj for temp-cmp-prt-obj .
define buffer buf_temp-cmp-parts   for temp-cmp-parts .

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  do counter = 1 to p-counter
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    if counter modulo 10 = 0
    then do:
      run waitfram-show in this-procedure
        (input substitute("Получение остатков по товарам из УБД. Объект УБД &1 &2. Получено &3", p-obj-type, p-obj-code, counter)
        ) .
    end.

    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
    .

    CASE entry(1, v-rec-name, {&delim-par}) :
      when {&table_gds-obj}
      then do:
        create buf_temp-gds-obj .
        run nws-impl in p-imp-handle
          ( input {&table_gds-obj}
           ,input (buffer buf_temp-gds-obj:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      when {&table_prt-obj}
      then do:
        create buf_temp-prt-obj .
        run nws-impl in p-imp-handle
          ( input {&table_prt-obj}
           ,input (buffer buf_temp-prt-obj:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      when {&table_parts}
      then do:
        create buf_temp-parts .
        run nws-impl in p-imp-handle
          ( input {&table_parts}
            ,input (buffer buf_temp-parts:handle)
          ) no-error.
        if error-status :error then do:
          return error return-value .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Не предусмотрен прием таблицы " v-rec-name skip
          "в составе команды" {&cmd-transfer-goods} skip
          view-as alert-box error .
        return error .
      end.
    end case.
  end.

  run waitfram-hide .

  /* обработка команды */

  /* блокируем создание gds-obj */
  run gbl/lockgdoc.p
    (input  p-obj-type                  /* p-obj-type        */
    ,input  p-obj-code                  /* p-obj-code        */
    ,input  {&lock-prc-gds-obj-create}  /* p-lock-gds-type   */
    ,input  {&lock-prc-subtype-disable} /* p-sub-type        */
    ,buffer buf_batchprocess            /* lock_batchprocess */
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке возможности создания записей товара на объекте" skip
      "Объект" p-obj-type p-obj-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.

  /* захватываем все gds-obj */
  define variable v-ind as integer   no-undo .

  do transaction
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    for each buf_gds-obj exclusive-lock
      where buf_gds-obj.obj-type = p-obj-type
        and buf_gds-obj.obj-code = p-obj-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        run waitfram-show in this-procedure
          (input substitute("Блокировка товаров на объекте. Объект УБД &1 &2. Заблокировано &3", p-obj-type, p-obj-code, v-ind)
          ) .
      end.

      create buf_temp-cmp-gds-obj .
      assign
        buf_temp-cmp-gds-obj.gds-code          = buf_gds-obj.gds-code
        buf_temp-cmp-gds-obj.current-fact-qnty = buf_gds-obj.fact-qnty
        buf_temp-cmp-gds-obj.current-free-qnty = buf_gds-obj.free-qnty
      .

      for each buf_prt-obj share-lock
        where buf_prt-obj.obj-type  = buf_gds-obj.obj-type
          and buf_prt-obj.obj-code  = buf_gds-obj.obj-code
          and buf_prt-obj.artic     = buf_gds-obj.artic
          and buf_prt-obj.prod-type = buf_gds-obj.prod-type
          and buf_prt-obj.prod-code = buf_gds-obj.prod-code
      on error undo, return error return-value
      :
        create buf_temp-cmp-prt-obj .
        assign
          buf_temp-cmp-prt-obj.gds-code          = buf_gds-obj.gds-code
          buf_temp-cmp-prt-obj.prt-code          = buf_prt-obj.prt-code
          buf_temp-cmp-prt-obj.current-fact-qnty = buf_prt-obj.fact-qnty
          buf_temp-cmp-prt-obj.current-free-qnty = buf_prt-obj.free-qnty
        .
      end.

      for each buf_parts share-lock
        where buf_parts.obj-type  = buf_gds-obj.obj-type
          and buf_parts.obj-code  = buf_gds-obj.obj-code
          and buf_parts.artic     = buf_gds-obj.artic
          and buf_parts.prod-type = buf_gds-obj.prod-type
          and buf_parts.prod-code = buf_gds-obj.prod-code
          and buf_parts.rsrv-free = yes
          and buf_parts.status_   = no
          and buf_parts.in-code   <> buf_parts.out-code
      on error undo, return error return-value
      :
        create buf_temp-cmp-parts .
        assign
          buf_temp-cmp-parts.gds-code          = buf_gds-obj.gds-code
          buf_temp-cmp-parts.in-code           = buf_parts.in-code
          buf_temp-cmp-parts.out-code          = buf_parts.out-code
          buf_temp-cmp-parts.part-code         = buf_parts.part-code
          buf_temp-cmp-parts.current-fact-qnty = buf_parts.fact-qnty
        .
      end.
    end.

    run waitfram-hide in this-procedure .
  end.

  /* сравниваем пришедшие остатки с текущими остатками в БД */

  for each buf_temp-gds-obj
  on error undo, return error return-value
  :
    find first buf_temp-cmp-gds-obj
      where buf_temp-cmp-gds-obj.gds-code = buf_temp-gds-obj.gds-code
      no-error .
    if not available buf_temp-cmp-gds-obj
    then do:
      create buf_temp-cmp-gds-obj .
      assign
        buf_temp-cmp-gds-obj.gds-code = buf_temp-gds-obj.gds-code
      .
    end.
    assign
      buf_temp-cmp-gds-obj.remote-fact-qnty = buf_temp-gds-obj.fact-qnty
      buf_temp-cmp-gds-obj.remote-free-qnty = buf_temp-gds-obj.free-qnty
    .

    for each buf_temp-prt-obj
      where buf_temp-prt-obj.obj-type  = buf_temp-gds-obj.obj-type
        and buf_temp-prt-obj.obj-code  = buf_temp-gds-obj.obj-code
        and buf_temp-prt-obj.artic     = buf_temp-gds-obj.artic
        and buf_temp-prt-obj.prod-type = buf_temp-gds-obj.prod-type
        and buf_temp-prt-obj.prod-code = buf_temp-gds-obj.prod-code
    on error undo, return error return-value
    :
      find first buf_temp-cmp-prt-obj
        where buf_temp-cmp-prt-obj.gds-code = buf_temp-gds-obj.gds-code
          and buf_temp-cmp-prt-obj.prt-code = buf_temp-prt-obj.prt-code
        no-error .
      if not available buf_temp-cmp-prt-obj
      then do:
        create buf_temp-cmp-prt-obj .
        assign
          buf_temp-cmp-prt-obj.gds-code = buf_temp-gds-obj.gds-code
          buf_temp-cmp-prt-obj.prt-code = buf_temp-prt-obj.prt-code
        .
      end.

      assign
        buf_temp-cmp-prt-obj.remote-fact-qnty = buf_temp-prt-obj.fact-qnty
        buf_temp-cmp-prt-obj.remote-free-qnty = buf_temp-prt-obj.free-qnty
      .
    end.

    for each buf_temp-parts
      where buf_temp-parts.obj-type  = buf_temp-gds-obj.obj-type
        and buf_temp-parts.obj-code  = buf_temp-gds-obj.obj-code
        and buf_temp-parts.artic     = buf_temp-gds-obj.artic
        and buf_temp-parts.prod-type = buf_temp-gds-obj.prod-type
        and buf_temp-parts.prod-code = buf_temp-gds-obj.prod-code
    on error undo, return error return-value
    :
      find first buf_temp-cmp-parts
        where buf_temp-cmp-parts.gds-code  = buf_temp-gds-obj.gds-code
          and buf_temp-cmp-parts.in-code   = buf_temp-parts.in-code
          and buf_temp-cmp-parts.out-code  = buf_temp-parts.out-code
          and buf_temp-cmp-parts.part-code = buf_temp-parts.part-code
        no-error .
      if not available buf_temp-cmp-parts
      then do:
        create buf_temp-cmp-parts .
        assign
          buf_temp-cmp-parts.gds-code  = buf_temp-gds-obj.gds-code
          buf_temp-cmp-parts.in-code   = buf_temp-parts.in-code
          buf_temp-cmp-parts.out-code  = buf_temp-parts.out-code
          buf_temp-cmp-parts.part-code = buf_temp-parts.part-code
        .
      end.

      assign
        buf_temp-cmp-parts.remote-fact-qnty = buf_temp-parts.fact-qnty
      .
    end.
  end.

  /* производим сравнение */
  /* и выводим результат сравнения в файл */
  define variable v-error-file-name as character no-undo .
  define variable v-log-file-name   as character no-undo .
  define variable v-error-exist     as logical   no-undo .
  define variable v-error-message   as character no-undo .
  define variable v-log-message     as character no-undo .

  assign
    v-error-exist     = false
    v-error-file-name = 'cmdcmpgd.err':u
    v-log-file-name   = 'cmdcmpgd.log':u
  .
  for each buf_temp-cmp-gds-obj
  on error undo, return error return-value
  :
    if buf_temp-cmp-gds-obj.current-fact-qnty <> buf_temp-cmp-gds-obj.remote-fact-qnty
    then do:
      assign
        buf_temp-cmp-gds-obj.error-qnty = true
      .
    end.

    for each buf_temp-cmp-prt-obj
      where buf_temp-cmp-prt-obj.gds-code = buf_temp-cmp-gds-obj.gds-code
    on error undo, return error return-value
    :
      if buf_temp-cmp-prt-obj.current-fact-qnty <> buf_temp-cmp-prt-obj.remote-fact-qnty
      then do:
        assign
          buf_temp-cmp-gds-obj.error-qnty = true
        .
      end.
    end.
  end.

  for each buf_temp-cmp-gds-obj
    where buf_temp-cmp-gds-obj.error-qnty = true
  on error undo, return error return-value
  :
    run cur-time in this-procedure
      (output v-today
      ,output v-time
      ) .

    assign
      v-error-exist   = true
      v-error-message = substitute("&1 товар_на_объекте код_товара &2 факт_количество_в_ГБД &3 факт_количество_в_УБД &4 свободное_количество_в_ГБД &5 свободное_количество_в_УБД &6"
                                  ,substitute('&1 &2 &3 &4':u
                                             ,string(v-today, '99/99/9999':u)
                                             ,string(v-time, 'HH:MM:SS':u)
                                             ,p-obj-type
                                             ,p-obj-code
                                             )
                                  ,buf_temp-cmp-gds-obj.gds-code
                                  ,buf_temp-cmp-gds-obj.current-fact-qnty
                                  ,buf_temp-cmp-gds-obj.remote-fact-qnty
                                  ,buf_temp-cmp-gds-obj.current-free-qnty
                                  ,buf_temp-cmp-gds-obj.remote-free-qnty
                                  )
                      + {&new-line}
    .

    { gbl/file-wr.i
      v-error-file-name
      v-error-message
    }

    for each buf_temp-cmp-prt-obj
      where buf_temp-cmp-prt-obj.gds-code = buf_temp-cmp-gds-obj.gds-code
    on error undo, return error return-value
    :
      run cur-time in this-procedure
        (output v-today
        ,output v-time
        ) .

      assign
        v-error-message = substitute("  признак_на_объекте код_товара &1 код_признака &2 факт_количество_в_ГБД &3 факт_количество_в_УБД &4 свободное_количество_в_ГБД &5 свободное_количество_в_УБД &6"
                                    ,buf_temp-cmp-prt-obj.gds-code
                                    ,buf_temp-cmp-prt-obj.prt-code
                                    ,buf_temp-cmp-prt-obj.current-fact-qnty
                                    ,buf_temp-cmp-prt-obj.remote-fact-qnty
                                    ,buf_temp-cmp-prt-obj.current-free-qnty
                                    ,buf_temp-cmp-prt-obj.remote-free-qnty
                                    )
                        + {&new-line}
      .

      { gbl/file-wr.i
        v-error-file-name
        v-error-message
      }
    end.

    for each buf_temp-cmp-parts
      where buf_temp-cmp-parts.gds-code = buf_temp-cmp-gds-obj.gds-code
    on error undo, return error return-value
    :
      assign
        v-error-exist   = true
        v-error-message = substitute("  партия код_товара &1 документ &2 резерв &3 код_партии &4 факт_количество_в_ГБД &5 факт_количество_в_УБД &6"
                                    ,buf_temp-cmp-parts.gds-code
                                    ,buf_temp-cmp-parts.in-code
                                    ,buf_temp-cmp-parts.out-code
                                    ,buf_temp-cmp-parts.part-code
                                    ,buf_temp-cmp-parts.current-fact-qnty
                                    ,buf_temp-cmp-parts.remote-fact-qnty
                                    )
                        + {&new-line}
      .

      { gbl/file-wr.i
        v-error-file-name
        v-error-message
      }
    end.
  end.

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .

  if v-error-exist = true
  then do:
    assign
      v-log-message = substitute("** &1 &2 объект &3 &4 найдены_ошибки_при_сравнении_товаров"
                                ,string(v-today,'99/99/9999':u)
                                ,string(v-time,'HH:MM:SS':U)
                                ,p-obj-type
                                ,p-obj-code
                                )
                    + {&new-line}
    .
  end.
  else do:
    assign
      v-log-message = substitute("__ &1 &2 объект &3 &4 сравнение_остатков_прошло_успешно"
                                ,string(v-today,'99/99/9999':u)
                                ,string(v-time,'HH:MM:SS':U)
                                ,p-obj-type
                                ,p-obj-code
                                )
                    + {&new-line}
    .
  end.

  { gbl/file-wr.i
    v-log-file-name
    v-log-message
  }
end.