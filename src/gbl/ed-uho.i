/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггера для работы с fill-in содержащим @ как символ начала нередактируемой (автоматически поддерживаемой) части полЯ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/13/04
Author: Bakhtadze Natalya
Creation date: 07/13/04

{1} - fill-in для которого определяются триггера
{2} = 1 если разрешено стирать @
  и = 0 если ухо стирать не разрешено

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

ON ANY-PRINTABLE OF {1} IN FRAME {&frame-name}
DO:
  RUN proc-uho-check IN THIS-PROCEDURE(1) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO: RETURN NO-APPLY. END.
END.

ON BACKSPACE OF {1} IN FRAME {&frame-name}
DO:
define variable v-offset as integer no-undo .
  RUN proc-uho-check IN THIS-PROCEDURE(1) NO-ERROR.
  IF ERROR-STATUS :ERROR THEN DO: RETURN NO-APPLY. END.
  if {1} :CURSOR-OFFSET > 1 then do :
    assign
    v-offset = {1}:CURSOR-OFFSET
    {1}:screen-value = substring({1}:screen-value, 1, {1}:CURSOR-OFFSET - 2) +
                      substring({1}:screen-value, {1}:CURSOR-OFFSET , length({1}:screen-value)  -  {1}:CURSOR-OFFSET + 1)
    {1}:CURSOR-OFFSET = v-offset - 1
    .
  end.
END.

ON DELETE-CHARACTER OF {1} IN FRAME {&frame-name}
DO:
define variable v-offset as integer no-undo .
  if {1}:selection-start = ? then do:
    RUN proc-uho-check IN THIS-PROCEDURE(0) NO-ERROR.
    IF ERROR-STATUS :ERROR THEN DO: RETURN NO-APPLY. END.

    assign
    v-offset = {1}:CURSOR-OFFSET
    {1}:screen-value = substring({1}:screen-value, 1, {1}:CURSOR-OFFSET - 1) +
                      substring({1}:screen-value, {1}:CURSOR-OFFSET + 1, length({1}:screen-value)  -  {1}:CURSOR-OFFSET + 1)
    {1}:CURSOR-OFFSET = v-offset
    .
  end.
  else do:
    IF  index({1}:SCREEN-VALUE IN FRAME {&FRAME-NAME}, "@") > 0 then do:
      IF {1}:Selection-start >= index({1}:SCREEN-VALUE, "@") + {2} THEN   do:
        RETURN no-apply.
      end.
    END.
    {1}:edit-clear().
  end.

END.

ON CTRL-X OF {1} IN FRAME {&frame-name}
DO:
  IF  index({1}:SCREEN-VALUE IN FRAME {&FRAME-NAME}, "@") > 0 then do:
    IF {1}:Selection-start >= index({1}:SCREEN-VALUE, "@") + {2} THEN   do:
      RETURN no-apply.
    end.
  END.
  {1}:edit-cut().
END.

ON CTRL-V OF {1} IN FRAME {&frame-name}
DO:
  IF  index({1}:SCREEN-VALUE IN FRAME {&FRAME-NAME}, "@") > 0 then do:
    IF {1}:Selection-start >= index({1}:SCREEN-VALUE, "@") + {2} THEN   do:
      RETURN no-apply.
    end.
  END.
  {1}:edit-paste().
END.


    &IF DEFINED( proc-uho-check_def ) = 0 &THEN
      &GLOB proc-uho-check_def
procedure proc-uho-check :
DEFINE INPUT PARAMETER p-offset AS INTEGER NO-UNDO.

  do
  on error undo, return error
  :
    IF  index({1}:SCREEN-VALUE IN FRAME {&FRAME-NAME}, "@") > 0 then do:
      IF ({1}:CURSOR-OFFSET >= index({1}:SCREEN-VALUE, "@") + {2}
      AND p-offset = 0)
      OR ({1}:CURSOR-OFFSET > index({1}:SCREEN-VALUE, "@") + {2}
      AND p-offset = 1)  THEN   do:
        RETURN ERROR.
      end.
    END.
  end.

end procedure. /* proc-uho-check */
    &ENDIF


/* $Workfile$ e n d */
