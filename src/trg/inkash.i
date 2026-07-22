/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Процедура записи истории на inkas

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/05
Author: Bakhtadze Natalya
Creation date: 06/01/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure write-inkas-history :
define parameter buffer buf_inkas for ub.inkas.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-host-code like ub.inkas.host-code no-undo .
define input parameter p-obj-type like ub.inkas.obj-type no-undo .
define input parameter p-obj-code like ub.inkas.obj-code no-undo .
define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define variable v-message as character no-undo .
define variable varobj-date as date no-undo .
define variable varshift-date as date no-undo .
define variable varshift-num as integer no-undo .
define variable v-shift-name as character no-undo.
define variable l-shift-on as logical no-undo .
define variable varshift-name as character no-undo .

define buffer buf_c-inkas for ub.c-inkas.
define buffer buf_c-inkas-pay for ub.c-inkas-pay.
define buffer buf_c-inkas-pay-desk for ub.c-inkas-pay-desk.
define buffer buf_c-inkas-pay-wth for ub.c-inkas-pay-wth.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).

  { gbl/curobjdt.i
    p-obj-type
    p-obj-code
    varobj-date
    no-error
  }
  if error-status :error
  or varobj-date = ?
  then do:
   v-message = substitute("Нет текущей даты на объекте продажи &1 &2&3&4&5 &6"
                , buf_inkas.inkas-code
                , p-obj-type
                , p-obj-code
                , {&new-line}
                , error-status:get-message(1)
                , return-value
                ).


    undo, return error v-message.
  end.

  { gbl/objat.i
    p-obj-type
    p-obj-code
    "'shift-on=request'"
    l-shift-on
  }
  if l-shift-on then do:
    /* на объекте включены смены */
    { gbl/curshift.i
      p-obj-type
      p-obj-code
      varshift-date
      varshift-num
      varshift-name
      no-error
    }
    /*
    if error-status :error then do:
      v-message = substitute("!!!Ошибка при поиске текущей смены на объекте продажи &1 &2&3&4&5 &6"
                , buf_inkas.inkas-code
                , p-obj-type
                , p-obj-code
                , {&new-line}
                , error-status:get-message(1)
                , return-value
                ).
      undo, return error v-message.
    end.
    */
  end.
  else do:
    assign
      varshift-date = ?
      varshift-num  = ?
    .
  end.


    create buf_c-inkas.
    buffer-copy buf_inkas to buf_c-inkas
    assign
    buf_c-inkas.inkas-code         = p-inkas-code
    buf_c-inkas.obj-type           = p-obj-type
    buf_c-inkas.obj-code           = p-obj-code
    buf_c-inkas.host-code          = p-host-code
    buf_c-inkas.chip-num           = next-value (s-corr-chip, {&db-name_schema})
    buf_c-inkas.corr-time          = v-time
    buf_c-inkas.corr-user-name     = g#userid
    buf_c-inkas.real-corr-date     = v-date
    buf_c-inkas.corr-date          = varobj-date /*здесь дата объекта*/
    buf_c-inkas.corr-shift-date    = varshift-date
    buf_c-inkas.corr-shift-num     = varshift-num
    buf_c-inkas.corr-shift-name    = varshift-name
    buf_c-inkas.corr-user-db-num   = g#db-num
    .
    /*здесь наверно не нужно запоминать ничего кроме шапки*/
    /*
    for each ub.inkas-pay where
             ub.inkas-pay.inkas-code = buf_inkas.inkas-code:
      create buf_c-inkas-pay.
      buffer-copy ub.inkas-pay to buf_c-inkas-pay
      assign
      buf_c-inkas-pay.chip-num           = buf_c-inkas.chip-num
      .
    end.
    for each ub.inkas-pay-desk where
            ub.inkas-pay-desk.inkas-code = buf_inkas.inkas-code:
      create buf_c-inkas-pay-desk.
      buffer-copy ub.inkas-pay-desk to buf_c-inkas-pay-desk
      assign
      buf_c-inkas-pay-desk.chip-num           = buf_c-inkas.chip-num
      .
    end.
    for each ub.inkas-pay-wth where
            ub.inkas-pay-wth.inkas-code = buf_inkas.inkas-code:
      create buf_c-inkas-pay-wth.
      buffer-copy ub.inkas-pay-wth to buf_c-inkas-pay-wth
      assign
      buf_c-inkas-pay-wth.chip-num           = buf_c-inkas.chip-num
      .
    end.

    */
    release buf_c-inkas.
    /*чтобы отработал триггер на запись buf_c-trn-doc раньше чем отработает триггер на удаление inkas*/
  end. /*doe*/

end procedure. /* write-inkas-history */