block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: calc-arc.p $
$Archive: adm/calc-arc.p $

Расчет архивов для всех объектов, которые принадлежат указанной базе данных

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

define input  parameter p-db-num     as integer   no-undo .
define input  parameter p-cre-db-num as integer   no-undo .
define input  parameter p-task-type  as character no-undo .
define input  parameter p-task-num   as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: calc-arc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/calc-arc.p $":U .
define variable vss-description as character no-undo init "Расчет архивов для всех объектов, которые принадлежат указанной базе данных".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4',p-cre-db-num,p-task-type,p-task-num)" }
{ cmp/trg-def.i  }
{ adm/auto-def.i }
{ ref/shd-attr.i }
{ gbl/clntattr.i }

define buffer buf_db for ub.db .
define buffer buf_clients for ub.clients .

do
on error undo, return error return-value
:
  define variable v-ind as integer   no-undo .

  run gbl/set-gbl.p
    (input true                 /* p-auto        */
    ,input g#auto-user-id       /* p-user-id     */
    ,input g#auto-user-password /* p-user-passwd */
    ) no-error.
  if error-status :error
  then do:
    run write-to-log in this-procedure
      ( vss-workfile + {&space-char}
      + "Ошибка при инициализации переменных g#..." + {&new-line}
      + error-status :get-message(error-status :num-messages) + {&new-line}
      + return-value
      ) .
    return error return-value .
  end.

  define variable v-calc-arh   as logical   no-undo .
  define variable v-calc-ahsp  as logical   no-undo .
  define variable v-calc-aht   as logical   no-undo .
  define variable v-calc-hold  as logical   no-undo .
  define variable v-param-list as character no-undo .
  define variable v-param-type as character no-undo .

  run schedule-attr-value in this-procedure
    (input  p-cre-db-num
    ,input  p-task-type
    ,input  p-task-num
    ,input  {&attr-schedule-param-list-h}
    ,output v-param-list
    ,output v-param-type
    ) .
  if v-param-list = ""
  then do:
    assign
      v-calc-arh  = true
      v-calc-ahsp = true
      v-calc-aht  = true
      v-calc-hold = true
    .
  end.
  else do:
    run schedule-attr-extract-logical in this-procedure
      (input  1
      ,input  v-param-list
      ,output v-calc-arh
    ).
    run schedule-attr-extract-logical in this-procedure
      (input  2
      ,input  v-param-list
      ,output v-calc-ahsp
    ).
    run schedule-attr-extract-logical in this-procedure
      (input  3
      ,input  v-param-list
      ,output v-calc-aht
    ).
    run schedule-attr-extract-logical in this-procedure
      (input  4
      ,input  v-param-list
      ,output v-calc-hold
    ).
  end.

  find first buf_db no-lock
    where buf_db.db-num = p-db-num
    no-error .
  if not available buf_db
  then do:
    undo, return error
      "Ошибка задания входящих параметров" + {&new-line}
      + substitute("Не найдена база данных &1", p-db-num)
      .
  end.

  run write-to-log in this-procedure
    ( substitute("Расчет складских архивов по базе данных &1", buf_db.db-num)
    + (if v-calc-arh  = true then {&new-line} + "                         Складской архив по товарам" else "")
    + (if v-calc-ahsp = true then {&new-line} + "                         Складской архив по поставщикам" else "")
    + (if v-calc-aht  = true then {&new-line} + "                         Складской архив по типам приобретения" else "")
    + (if v-calc-hold = true then {&new-line} + "                         Межфирменный архив" else "")
    ) .

  for each buf_clients no-lock
    where buf_clients.db-num = buf_db.db-num
      and buf_clients.stts   = 0
  on error undo, return error return-value
  :
    define variable v-attr-arh-disable-chr  as character no-undo .
    define variable v-attr-arh-disable-type as character no-undo .
    define variable v-attr-arh-disable      as logical   no-undo .

    run clntattr-value in this-procedure
      (input  buf_clients.obj-type
      ,input  buf_clients.obj-code
      ,input  {&attr-arh-disable}
      ,output v-attr-arh-disable-chr
      ,output v-attr-arh-disable-type
      ).
    assign
      v-attr-arh-disable = lookup(v-attr-arh-disable-chr, "yes,true") > 0
    .

    if  v-calc-arh         = true
    and v-attr-arh-disable <> true
    then do:
      /* расчет складского архива по товарам */
      run trg/bt_arh.p
        (input buf_clients.obj-type /* p-obj-type          */
        ,input buf_clients.obj-code /* p-obj-code          */
        ,input ?                    /* p-last-date         */
        ,input false                /* p-check-act         */
        ,input 0                    /* p-check-act-db-num  */
        ,input '':U                 /* p-check-act-user-id */
        ) no-error .
      if error-status :error
      then do:
        run write-to-log in this-procedure
          ( vss-workfile + {&space-char}
            + substitute("Ошибка при расчете складского архива по товарам. Объект &1 &2" + {&new-line}
                          + "&3" + {&new-line}
                          + "&4" + {&new-line}
                        ,buf_clients.obj-type
                        ,buf_clients.obj-code
                        ,error-status :get-message(1)
                        ,return-value
                        )
          ) .
      end.
    end.

    define variable v-attr-ahsp-disable-chr  as character no-undo .
    define variable v-attr-ahsp-disable-type as character no-undo .
    define variable v-attr-ahsp-disable      as logical   no-undo .

    run clntattr-value in this-procedure
      (input  buf_clients.obj-type
      ,input  buf_clients.obj-code
      ,input  {&attr-ahsp-disable}
      ,output v-attr-ahsp-disable-chr
      ,output v-attr-ahsp-disable-type
      ).
    assign
      v-attr-ahsp-disable = lookup(v-attr-ahsp-disable-chr, "yes,true") > 0
    .

    if  v-calc-ahsp = true
    and v-attr-ahsp-disable <> true
    then do:
      /* расчет складского архива по поставщикам */
      run trg/bt_ahsp.p
        (input buf_clients.obj-type /* p-obj-type          */
        ,input buf_clients.obj-code /* p-obj-code          */
        ,input ?                    /* p-last-date         */
        ,input false                /* p-check-act         */
        ,input 0                    /* p-check-act-db-num  */
        ,input '':U                 /* p-check-act-user-id */
        ) no-error .
      if error-status :error
      then do:
        run write-to-log in this-procedure
          ( vss-workfile + {&space-char}
            + substitute("Ошибка при расчете складского архива по поставщикам. Объект &1 &2" + {&new-line}
                          + "&3" + {&new-line}
                          + "&4" + {&new-line}
                        ,buf_clients.obj-type
                        ,buf_clients.obj-code
                        ,error-status :get-message(1)
                        ,return-value
                        )
          ) .
      end.
    end.

    define variable v-attr-aht-disable-chr  as character no-undo .
    define variable v-attr-aht-disable-type as character no-undo .
    define variable v-attr-aht-disable      as logical   no-undo .

    run clntattr-value in this-procedure
      (input  buf_clients.obj-type
      ,input  buf_clients.obj-code
      ,input  {&attr-aht-disable}
      ,output v-attr-aht-disable-chr
      ,output v-attr-aht-disable-type
      ).
    assign
      v-attr-aht-disable = lookup(v-attr-aht-disable-chr, "yes,true") > 0
    .

    if  v-calc-aht = true
    and v-attr-aht-disable <> true
    then do:
      /* расчет складского архива по типам приобретения */
      run trg/bt_aht.p
        (input buf_clients.obj-type /* p-obj-type  */
        ,input buf_clients.obj-code /* p-obj-code  */
        ,input ?                    /* p-last-date */
        ,input false                /* p-check-act */
        ,input 0                    /* p-check-act-db-num  */
        ,input '':U                 /* p-check-act-user-id */
        ) no-error .
      if error-status :error
      then do:
        run write-to-log in this-procedure
          ( vss-workfile + {&space-char}
            + substitute("Ошибка при расчете складского архива по типам приобретения. Объект &1 &2" + {&new-line}
                          + "&3" + {&new-line}
                          + "&4" + {&new-line}
                        ,buf_clients.obj-type
                        ,buf_clients.obj-code
                        ,error-status :get-message(1)
                        ,return-value
                        )
          ) .
      end.
    end.
  end.

  if v-calc-hold = true
  then do:
    /* расчет межфирменных архивов */
    define variable hold-value as character no-undo .
    define variable hold-type  as character no-undo.

    define variable v-holding as logical   no-undo .

    { gbl/conf-rd.i
      "'holding'"
      0
      "''"
      0
      "''"
      "''"
      "''"
      no
      hold-value
      hold-type
      no-error
    }
    if  ( not error-status:error )
    and hold-value = "yes"
    then do:
      assign
        v-holding = true
      .
    end.
    else do:
      assign
        v-holding = false
      .
    end.

    if v-holding = true
    then do:
      run trg/bt_hold.p
        (input ?     /* p-last-date         */
        ,input false /* p-check-act         */
        ,input 0     /* p-check-act-db-num  */
        ,input '':U  /* p-check-act-user-id */
        ) no-error .
      if error-status :error
      then do:
        run write-to-log in this-procedure
          ( vss-workfile + {&space-char}
            + substitute("Ошибка при расчете межфирменных архивов" + {&new-line} +
                        "&1" + {&new-line} +
                        "&2" + {&new-line}
                        ,error-status :get-message(1)
                        ,return-value
                        )
          ) .
      end.
    end.
  end.

  /* очистка выполненных отложенных заданий */
  run trg/bt_clr.p .

end.