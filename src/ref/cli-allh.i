/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/25/09
Author: Bakhtadze Natalya
Creation date: 06/25/09

*/

&if "{1}" = "def" &then
define variable v-total-select-num as integer   no-undo .
define temp-table temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer

  index xpk is primary unique obj-type obj-code
  .

&endif


&if "{1}" = "procedures" &then

PROCEDURE userobjs_append :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_temp-user-obj
    then do:
      create buf_temp-user-obj .
      assign
        buf_temp-user-obj.obj-type = p-obj-type
        buf_temp-user-obj.obj-code = p-obj-code
      .
      assign
        v-total-select-num = v-total-select-num + 1
      .
    end.
  end.

END PROCEDURE.
PROCEDURE userobjs_delete :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      delete buf_temp-user-obj .
      assign
        v-total-select-num = v-total-select-num - 1
      .
    end.
  end.

END PROCEDURE.


PROCEDURE display-select-num :
  do
  on error undo, return error return-value
  :
    assign
      mark-num = v-total-select-num
    .
    display
      mark-num
      with frame {&frame-name}.
    if v-total-select-num = 0
    then do:
      hide
        mark-num
        in frame {&frame-name}.
    end.
    else do:
      display
        mark-num
        with frame {&frame-name}.
    end.
  end.
END PROCEDURE.

PROCEDURE check-selection :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define variable v-ok as logical   no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if can-do (p-bttns, "b-mark")
      then do:
        find first buf_temp-user-obj
          no-error .

        if available buf_temp-user-obj
        then do:
          message
            "Информация о выбранных элементах будет потеряна" Skip
            "Продолжить?" Skip
            view-as alert-box question buttons yes-no update v-ok .
          if v-ok = true
          then do:
            for each buf_temp-user-obj
            on error undo, return error return-value
            :
              delete buf_temp-user-obj .
            end.
          end.
          else do:
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.

END PROCEDURE.

PROCEDURE choose-mark :
  define variable v-log as logical no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    if available X_clients
    then do:
      find first buf_temp-user-obj
        where buf_temp-user-obj.obj-type = X_clients.obj-type
          and buf_temp-user-obj.obj-code = X_clients.obj-code
        no-error .
      if available buf_temp-user-obj
      then do:
        run userobjs_delete in this-procedure
          (input  X_clients.obj-type
          ,input  X_clients.obj-code
          ) .
      end.
      else do:
        run userobjs_append in this-procedure
          (input  X_clients.obj-type
          ,input  X_clients.obj-code
          ) .
      end.

      {&refresh-br}
      if last-event :function <> "MOUSE-SELECT-DBLCLICK"
      then do:
        {&select-next-row}
        {&apply-value-changed}
      end.
      run display-select-num in this-procedure .
      {&apply-entry}
    end.
  end.

END PROCEDURE.

PROCEDURE choose-select :

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}
    :
      if available X_clients
      then do:
        if NOT can-do (p-bttns, "b-mark")
        then do:
          /*
          assign
            p-select-obj-type = X_clients.obj-type
            p-select-obj-code = X_clients.obj-code
          .
          */
        end.
        else do:
          find first buf_temp-user-obj
            no-error .
          if not available buf_temp-user-obj
          then do:
            run userobjs_append in this-procedure
              (input  X_clients.obj-type
              ,input  X_clients.obj-code
              ) .
          end.

          run userobjs_clear in p-callback-handle .

          for each buf_temp-user-obj
          on error undo, return error return-value
          :
            run userobjs_append in p-callback-handle
              (input  buf_temp-user-obj.obj-type
              ,input  buf_temp-user-obj.obj-code
              ) .
          end.
        end.
      end.
    end.
    /*
    assign
      p-user-select = true
    .
    */
  end.

END PROCEDURE.

PROCEDURE get-mark-string :
  define input  parameter p-obj-type    as character no-undo .
  define input  parameter p-obj-code    as integer   no-undo .
  define output parameter p-mark-string as character no-undo .

  define buffer buf_temp-user-obj for temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_temp-user-obj
      where buf_temp-user-obj.obj-type = p-obj-type
        and buf_temp-user-obj.obj-code = p-obj-code
      no-error .
    if available buf_temp-user-obj
    then do:
      assign
        p-mark-string = '*':U
      .
    end.
    else do:
      assign
        p-mark-string = '':U
      .
    end.

  end.

END PROCEDURE.


&endif