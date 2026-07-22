/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск последнего fact-order за дату

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure lastordr :

  define input  parameter parobj-type     as character no-undo .
  define input  parameter parobj-code     as integer   no-undo .
  define input  parameter paris-shift     as logical   no-undo .
  define input  parameter paris-shift-num as logical   no-undo .
  define input  parameter pardate         as date      no-undo .
  define input  parameter parshift-num    as integer   no-undo .
  define output parameter parfact-order   as decimal   no-undo .

  if paris-shift = no
  then do:
    find last ub.stk-tot no-lock
      where ub.stk-tot.obj-type    = parobj-type
        and ub.stk-tot.obj-code    = parobj-code
        and ub.stk-tot.fact-date <= pardate
        and ub.stk-tot.shift-num  = 0
      use-index fact-date
      no-error .
  end.
  else do:
    if paris-shift-num = no
    then do:
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type    = parobj-type
          and ub.stk-tot.obj-code    = parobj-code
          and ub.stk-tot.shift-date <= pardate
          and ub.stk-tot.shift-num   > 0
        use-index shift-num
        no-error .
    end.
    else do:
      find last ub.stk-tot no-lock
        where ub.stk-tot.obj-type   = parobj-type
          and ub.stk-tot.obj-code   = parobj-code
          and ub.stk-tot.shift-date = pardate
          and ub.stk-tot.shift-num  <= parshift-num
          and ub.stk-tot.shift-num  > 0
        use-index shift-num
        no-error .
      if not available ub.stk-tot
      then do:
        find last ub.stk-tot no-lock
          where ub.stk-tot.obj-type   = parobj-type
            and ub.stk-tot.obj-code   = parobj-code
            and ub.stk-tot.shift-date < pardate
            and ub.stk-tot.shift-num  > 0
          use-index shift-num
          no-error .
      end.
    end.
  end.

  assign
    parfact-order = (if available ub.stk-tot then ub.stk-tot.fact-order else 0)
  .

end procedure.

/* $Workfile$ e n d */