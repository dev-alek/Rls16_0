block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка отложенных заданий

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/21/00

Краткое описание алгоритма:
В поле BP_Type хранится тип информации, которую надо обрабатывать

Записи каждого типа обрабатываются в отдельной программе
'bt_' + Batch_Process.BP_Type + '.p'

Программа возвращает '' в случае, когда не была обработана никакая информация.
Если что-либо было обработано, то необходимо вернуть строку отличную от пустой
(например, количество обработанных записей).

*/

define input  parameter parparentproc  as widget-handle no-undo.

&scop log_file 'batch_pr.txt'

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Обработка отложенных заданий".
{ cmp/vssrevis.i }
{ gbl/cur-time.i }

define variable s-username as character no-undo .
define variable s-password as character no-undo .
define variable s-connect  as character no-undo .
define variable l-dbg      as logical   no-undo init true .

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define stream slog .

output stream slog to {&log_file} /* intentinally no append */ .
put stream slog unformatted "batch_pr.p: "  cur-time-string-sec()
   '  connected-ub: ' + string( connected("ub"), 'yes/no ')
   skip.
output stream slog close .


/* Данную определение необходимо использовать после каждого вызова программы обработки */
&scop Check_Records_Processed ~
  if return-value <> '' then do: ~
    assign ~
      l-recods-processed = true ~
    . ~
  end. ~

define variable l-recods-processed as logical no-undo .

/* Цикл обработки записей до тех пор, пока есть что обрабатывать */

do
on error undo, return error return-value
:

  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).
  run putlog in this-procedure
    (input 'start':U
    ).

  assign
    l-recods-processed = false
  .


  do   on error undo, leave     on stop undo, leave:
    run putlog in this-procedure
      (input 'bt_trnhd':U
      ).

    run trg/bt_trnhd.p (input 0) .

    {&check_records_processed}
  end.

  do   on error undo, leave     on stop undo, leave:
    run putlog in this-procedure
      (input 'bt_arh':U
      ).

    run trg/bt_arh.p
      (input ""    /* p-obj-type          */
      ,input 0     /* p-obj-code          */
      ,input ?     /* p-last-date         */
      ,input false /* p-check-act         */
      ,input 0     /* p-check-act-db-num  */
      ,input '':U  /* p-check-act-user-id */
      ).

    {&check_records_processed}
  end.

  do   on error undo, leave     on stop undo, leave:
    run putlog in this-procedure
      (input 'bt_aht':U
      ).

    run trg/bt_aht.p
      (input ""    /* p-obj-type          */
      ,input 0     /* p-obj-code          */
      ,input ?     /* p-last-date         */
      ,input false /* p-check-act         */
      ,input 0     /* p-check-act-db-num  */
      ,input '':U  /* p-check-act-user-id */
      ).

    {&check_records_processed}
  end.


  do   on error undo, leave     on stop undo, leave:
    run putlog in this-procedure
      (input 'bt_ahsp':u
      ).

    run trg/bt_ahsp.p
      (input ""    /* p-obj-type          */
      ,input 0     /* p-obj-code          */
      ,input ?     /* p-last-date         */
      ,input false /* p-check-act         */
      ,input 0     /* p-check-act-db-num  */
      ,input '':U  /* p-check-act-user-id */
      ).

    {&check_records_processed}
  end.

  do   on error undo, leave     on stop undo, leave:
    run putlog in this-procedure
      (input 'bt_hold':u
      ).

    run trg/bt_hold.p
      (input ?     /* p-last-date         */
      ,input false /* p-check-act         */
      ,input 0     /* p-check-act-db-num  */
      ,input '':U  /* p-check-act-user-id */
      ).

    {&check_records_processed}
  end.


  /* !!! ВНИМАНИЕ !!!
     Все циклы обработки необходимо вставлять непосредственно перед этой строкой
   */

  /* Очистка старых записей имеющих статус {&btpr-deleted}
     Перевод старых записей, имеющих статус {&btpr-executing} в статус {&btpr-normal}
  */
  do   on error undo, leave     on stop undo, leave:
    run putlog in this-procedure
      (input 'bt_clr':U
      ).

    run trg/bt_clr.p .

    {&check_records_processed}
  end.

  run putlog in this-procedure
    (input 'end':U
    ).

end.


procedure putlog :
  define input parameter p-text as character no-undo.

  define variable v-today as date      no-undo.
  define variable v-time  as integer   no-undo.

  if l-dbg then do:
    output stream slog to {&log_file} append .
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    put stream slog unformatted string( v-time , "HH:MM:SS") ': ' p-text skip.
    output stream slog close .
  end.
end procedure. /* putlog */