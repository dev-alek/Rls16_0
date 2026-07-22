/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Изменение название признака

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 06/20/03

*/

&scop frame-name td

define input  parameter p-node-code as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание симметричной шкалы признаков".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/color.i    }

define variable sc-name like ub.gds-prt.node-name format "x(40)" label "Название шкалы" no-undo.

/* уровень шкалы */
def temp-table temp-level no-undo
    field num  as integer                     /* Номер уровня */
    field ord  as integer                     /* Число признаков */
    field name like ub.gds-prt.node-name         /* Название уровня */
    index num is primary unique num .

/* узел шкалы */
def temp-table temp-node no-undo
    field num  as integer                     /* Номер уровня */
    field ord  as integer                     /* Номер признака */
    field name like ub.gds-prt.node-name         /* Название признака */
    index num  is primary unique num ord.

/*def temp-table prt like ub.gds-prt.*/

def query temp-level for temp-level .
def browse temp-level query temp-level
       disp temp-level.name
       with size 35 by 10 no-labels title "Уровни".

def query temp-node for temp-node .
def browse temp-node query temp-node
       display temp-node.name
       with size 35 by 10 no-labels title "Признаки".

def button b-exit auto-go default
     LABEL "&Выход"
     SIZE 10 BY 1.
def button b-help
    label "Помо&щь"
     SIZE 10 BY 1.
def button b-upd-nd
    label "&Изменить"
     SIZE 10 BY 1.

DEF FRAME {&FRAME-NAME}
  b-exit     AT ROW  1   COL  1
  b-help     AT ROW  1   COL 11
  sc-name    AT ROW  2.5 COL  5
  temp-level AT ROW  4   COL  1
  temp-node  AT ROW  4   COL 37
  b-upd-nd   AT ROW 14.5 COL 45
WITH VIEW-AS DIALOG-BOX SCROLLABLE SIDE-LABELS THREE-D DEFAULT-BUTTON b-exit TITLE "".

/* --------------- TRIGGERS --------------------- */

on go of frame {&frame-name} do:

end.

on choose of b-upd-nd
or return of temp-node
or default-action of temp-node
do:
  run upd-nd in this-procedure .
end.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

on value-changed of temp-level in frame {&frame-name} do:
  run open-temp-node in this-procedure .
end.

/* ------------------- MAIN ------------------------ */

{ gbl/app_help.i }

do
on error undo, return error return-value
:
  assign
    frame {&frame-name} :title = "Шкала"
  .

  run open-all in this-procedure .

  temp-level :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
  temp-node :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .

  enable
    temp-level temp-node b-exit b-upd-nd b-help
    with frame {&frame-name}.

  wait-for go of frame {&frame-name}.
end.


/* --------------- PROCEDURES ------------------ */

procedure prt-tree :
  /* -------------------------------------------------------------------
  рекурсия без транзакции
  заполнение временной таблицы узлов
  - при копировании коды узлов не заполняются - будут генериться новые
  ------------------------------------------------------------------- */

  def input param uc like ub.gds-prt.upper-code no-undo. /* код вышестоящего узла */
  def buffer buf_gds-prt   for ub.gds-prt.
  define variable nc         as int no-undo.                  /* код текущего узла */
  define variable next-level as log no-undo.                  /* наличие вышестоящего узла */

  /* ищем любой узел текущего уровня и заполняем инфо об уровне */
  /* шкала точно не пустая, так что при первом вызове не отвалится */
  find first buf_gds-prt where buf_gds-prt.upper-code = uc.
  find temp-level where temp-level.num = buf_gds-prt.lvl-num.
  assign
    temp-level.ord = 0
    nc = buf_gds-prt.node-code
    .
  /* проверяем, есть ли следующий уровень */
  if can-find (first buf_gds-prt where buf_gds-prt.upper-code = nc)
  then do:
    next-level = yes.
  end.
  else do:
    next-level = no.
  end.

  /* заполняем таблицу для всех узлов уровня */
  for each buf_gds-prt
    where buf_gds-prt.upper-code = uc
  :
    if buf_gds-prt.prt-num > temp-level.ord
    then do:
      assign
        temp-level.ord = buf_gds-prt.prt-num
      .
    end.
    create temp-node.
    assign
      temp-node.num  = buf_gds-prt.lvl-num
      temp-node.ord  = buf_gds-prt.prt-num
      temp-node.name = buf_gds-prt.node-name
    .
  end.

  /* обрабатываем следующий уровень, если он есть */
  if next-level
  then do:
    run prt-tree (nc).
  end.
end procedure.



PROCEDURE upd-nd :
  define variable ri as recid no-undo .

  if not available temp-node
  then do:
    return .
  end.

  define variable v-node-name as character no-undo .

  assign
    v-node-name = temp-node.name
  .

  run gbl/d-prompt.w (
      'title=':u + "Имя признака" + '\':u
    + 'text1=':u + "Имя признака" + '\':u
    + 'format=x(16)\':u
    + 'type=char\':u
    ,input-output v-node-name
    ).
  if return-value = 'false':u then do:
    return .
  end.

  if v-node-name = ""
  then do:
    message
      "Не задано значение признака" skip
      view-as alert-box information .
    return .
  end.

  if can-find(first temp-node
    where temp-node.num = temp-level.num
      and temp-node.name = v-node-name
      and recid( temp-node ) <> ri )
  then do:
    message
      "Признак" v-node-name "уже есть" skip
      view-as alert-box information .
    return .
  end.

  run utl/rengdprt.p
    (input p-node-code
    ,input temp-level.num
    ,input temp-node.name
    ,input v-node-name
    ) .

  run open-all in this-procedure .


END PROCEDURE.    /* upd-nd */


procedure open-temp-level :

  do
  on error undo, return error return-value
  :
    open query temp-level for each temp-level.
  end.

end procedure. /* open-temp-level */


procedure open-temp-node :

  do
  on error undo, return error return-value
  :
    open query temp-node for each temp-node where temp-node.num = temp-level.num.
  end.

end procedure. /* open-temp-node */


procedure open-all :

  do
  on error undo, return error return-value
  :
    find ub.gds-prt
      where ub.gds-prt.node-code = p-node-code
      .

    if ub.gds-prt.node-name = {&empty-scale}
    then do:
      message
        "Изменение пустой шкалы невозможно."
        view-as alert-box error.
      undo, return error return-value .
    end.

    assign
      sc-name  = ub.gds-prt.node-name
    .

    for each temp-level
    :
      delete temp-level .
    end.

    for each temp-node
    :
      delete temp-node .
    end.

    for each ub.lvl-name
      where lvl-name.upper-code = ub.gds-prt.upper-code
    :
      create temp-level.
      assign
        temp-level.num = ub.lvl-name.level
        temp-level.name = ub.lvl-name.lvl-name
      .
    end.

    run prt-tree in this-procedure
      (input p-node-code
      ).

    disp sc-name with frame {&frame-name}.

    run open-temp-level in this-procedure .
    run open-temp-node in this-procedure .
  end.

end procedure. /* open-all */