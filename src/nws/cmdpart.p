block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cmdpart.p $
$Archive: nws/cmdpart.p $

Обработка команды на разбитие, слияние партий

Автор: Перваков Михаил Сергеевич
Дата создания: 03/30/05
Author: Mikhail Pervakov
Creation date: 03/30/05

*/

define input  parameter p-imp-handle as handle    no-undo .
define input  parameter p-counter  as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cmdpart.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/cmdpart.p $":U .
define variable vss-description as character no-undo init "Распределённая проверка целостности остатков по товару".
{ cmp/vssrevis.i "substitute('&1|&2|&3':u,p-counter)" }
{ cmp/trg-def.i  }
{ gbl/waitfram.i }
{ gbl/cur-time.i }

define temp-table temp-gds-obj no-undo like ub.gds-obj .
define temp-table temp-parts   no-undo like ub.parts .

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .

define buffer buf_temp-gds-obj     for temp-gds-obj .
define buffer buf_temp-parts       for temp-parts .
define buffer buf_gds-obj          for ub.gds-obj .
define buffer buf_parts            for ub.parts .

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
        (input substitute("Получение команды на разбиение партий. Получено записей &1", counter)
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
          "в составе команды" {&cmd-parts-split} skip
          view-as alert-box error .
        return error .
      end.
    end case.
  end.

  run waitfram-hide .

  /* обработка команды */
  find first buf_temp-gds-obj
    no-error .
  if not available buf_temp-gds-obj
  then do:
    undo, return error substitute( "&2&1В пакете отсутствует запись gds-obj.&1"
                          , {&new-line}
                          , vss-workfile
                          ) .
  end.

  find first buf_gds-obj
    where buf_gds-obj.obj-type  = buf_temp-gds-obj.obj-type
      and buf_gds-obj.obj-code  = buf_temp-gds-obj.obj-code
      and buf_gds-obj.artic     = buf_temp-gds-obj.artic
      and buf_gds-obj.prod-type = buf_temp-gds-obj.prod-type
      and buf_gds-obj.prod-code = buf_temp-gds-obj.prod-code
    no-error .
  if not available buf_gds-obj
  then do:
    undo, return error substitute( "&2&1На объекте не найдена запись gds-obj.&1Объект &3 &4 Артикул &5 &6 &7"
            ,{&new-line}
            ,vss-workfile
            ,buf_temp-gds-obj.obj-type
            ,buf_temp-gds-obj.obj-code
            ,buf_temp-gds-obj.artic
            ,buf_temp-gds-obj.prod-type
            ,buf_temp-gds-obj.prod-code
             ) .
  end.

  { gbl/gdscheck.i
    buf_gds-obj.obj-type
    buf_gds-obj.obj-code
    buf_gds-obj.artic
    buf_gds-obj.prod-type
    buf_gds-obj.prod-code
    ?
    "''"
    no-error
  }
  if error-status :error
  then do:
    undo, return error substitute( "&2&1Ошибка при проверке целостности товара на объекте&1Объект &3 &4 Артикул &5 &6 &7&1&8 &9"
            ,{&new-line}
            ,vss-workfile
            ,buf_temp-gds-obj.obj-type
            ,buf_temp-gds-obj.obj-code
            ,buf_temp-gds-obj.artic
            ,buf_temp-gds-obj.prod-type
            ,buf_temp-gds-obj.prod-code
            ,return-value
            ,error-status :get-message(1)
             ) .
  end.

  for each buf_temp-parts
    where buf_temp-parts.obj-type  = buf_temp-gds-obj.obj-type
      and buf_temp-parts.obj-code  = buf_temp-gds-obj.obj-code
      and buf_temp-parts.artic     = buf_temp-gds-obj.artic
      and buf_temp-parts.prod-type = buf_temp-gds-obj.prod-type
      and buf_temp-parts.prod-code = buf_temp-gds-obj.prod-code
  on error undo, return error return-value
  :
    find first buf_parts exclusive-lock
      where buf_parts.obj-type  = buf_temp-parts.obj-type
        and buf_parts.obj-code  = buf_temp-parts.obj-code
        and buf_parts.artic     = buf_temp-parts.artic
        and buf_parts.prod-type = buf_temp-parts.prod-type
        and buf_parts.prod-code = buf_temp-parts.prod-code
        and buf_parts.in-code   = buf_temp-parts.in-code
        and buf_parts.out-code  = buf_temp-parts.out-code
        and buf_parts.part-code = buf_temp-parts.part-code
      no-error.
    if not available buf_parts
    then do:
      create buf_parts .
      buffer-copy buf_temp-parts to buf_parts
      assign
        buf_parts.qnty      = 0
        buf_parts.fact-qnty = 0
        buf_parts.real-qnty = 0
        buf_parts.cli-qnty  = 0
      .
    end.

    assign
      buf_parts.qnty      = buf_parts.qnty      + buf_temp-parts.qnty
      buf_parts.fact-qnty = buf_parts.fact-qnty + buf_temp-parts.fact-qnty
      buf_parts.cli-qnty  = buf_parts.cli-qnty  + buf_temp-parts.cli-qnty
    .

    if  buf_parts.qnty      = 0
    and buf_parts.fact-qnty = 0
    and buf_parts.cli-qnty  = 0
    then do:
      /* удаляем партию */
      delete buf_parts .
    end.
    else do:
      if buf_parts.qnty      = 0
      or buf_parts.fact-qnty = 0
      or buf_parts.cli-qnty  = 0
      then do:
        undo, return error substitute( "&2&1Ошибка при удалении партии. Объект &3 &4. Артикул &5 &6 &7.&1 В партии имеются количества отличные от нуля &8"
                ,{&new-line}
                ,vss-workfile
                ,buf_temp-gds-obj.obj-type
                ,buf_temp-gds-obj.obj-code
                ,buf_temp-gds-obj.artic
                ,buf_temp-gds-obj.prod-type
                ,buf_temp-gds-obj.prod-code
                ,substitute("qnty &1 fact-qnty &2 cli-qnty &3", buf_parts.qnty, buf_parts.fact-qnty, buf_parts.cli-qnty)
                ) .
      end.
    end.
  end.

  { gbl/gdscheck.i
    buf_gds-obj.obj-type
    buf_gds-obj.obj-code
    buf_gds-obj.artic
    buf_gds-obj.prod-type
    buf_gds-obj.prod-code
    ?
    "''"
    no-error
  }
  if error-status :error
  then do:
    undo, return error substitute( "&2&1Ошибка при проверке целостности товара после обновления партия на объекте &3 &4 Артикул &5 &6 &7&1&8 &9"
            ,{&new-line}
            ,vss-workfile
            ,buf_temp-gds-obj.obj-type
            ,buf_temp-gds-obj.obj-code
            ,buf_temp-gds-obj.artic
            ,buf_temp-gds-obj.prod-type
            ,buf_temp-gds-obj.prod-code
            ,return-value
            ,error-status :get-message(1)
             ) .
  end.
end.