/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Выбор шкалы для переименования признаков

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 02/05/03

no_app_help.i
*/


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор шкалы для сортировки признаков".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }


&scop define-temp-prt-root define temp-table temp-prt-root no-undo ~
    field node-code  as integer label 'Код' ~
    field node-name like gds-prt.node-name format 'x(40)' label 'Название' ~
    index pk is primary unique node-code ~
    index ie1 node-name ~
    .
{&define-temp-prt-root}

define variable v-node-code as integer   no-undo .
define variable v-level     as integer   no-undo .

define query temp-prt-root for temp-prt-root .
define browse temp-prt-root query temp-prt-root
       display temp-prt-root.node-name
       with size 45 by 13.7 no-labels separators .

define button b-exit auto-go default
     LABEL "&Выход"
     SIZE 10 BY 1.
define button b-sel
     LABEL "Вы&бор"
     SIZE 10 BY 1.
define button b-help
    label "Помо&щь"
     SIZE 10 BY 1.

&scop frame-name f-rengd

define FRAME {&FRAME-NAME}
  b-exit        AT ROW  1   COL  1
  b-sel         AT ROW  1   COL 11
  b-help        AT ROW  1   COL 21
  "Редактирование названий признаков шкалы"  AT ROW  2   COL 1
  temp-prt-root AT ROW  4   COL  1
WITH VIEW-AS DIALOG-BOX SCROLLABLE SIDE-LABELS THREE-D DEFAULT-BUTTON b-exit TITLE "".

on choose of b-sel
or return of temp-prt-root
or default-action of temp-prt-root
do:
  if available temp-prt-root
  then do:
    run utl/ren-grp.w
      (input temp-prt-root.node-code
      ) .
  end.
end.

do
on error undo, return error return-value
:

  define buffer buf_sys-ctrl for ub.sys-ctrl .
  find first buf_sys-ctrl no-lock .
  if buf_sys-ctrl.db-num <> 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Процедура переименования признака шкалы может запускаться только в ГБД"
      view-as alert-box error .
    undo, return error .
  end.

  run fill-temp-table in this-procedure .

  open query temp-prt-root for each temp-prt-root .

  enable
    temp-prt-root b-exit b-sel b-help
    with frame {&frame-name}.

  apply 'entry':u to temp-prt-root .

  wait-for go of frame {&frame-name}.


end.

procedure fill-temp-table :

  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-prt-root for temp-prt-root .

  do
  on error undo, return error return-value
  :
    define variable v-prt-level as integer   no-undo .


    for each buf_gds-prt no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name <> {&empty-scale}
    on error undo, return error
    :
      create buf_temp-prt-root .
      assign
        buf_temp-prt-root.node-code = buf_gds-prt.node-code
        buf_temp-prt-root.node-name = buf_gds-prt.node-name
      .
    end.
  end.

end procedure. /* fill-temp-table */