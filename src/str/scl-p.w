/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с деревом признаков

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/12/06


*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input  parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input  parameter p-prt-mode as character no-undo .
define input  parameter p-prt-rec  as recid     no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " работа с деревом признаков   ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ arc/gds_inf.i def }
{ gbl/getcntxt.i def }
{ gbl/color.i    }
{ gbl/waitfram.i }
{ arc/gds_inf.i calc ub.goods p-curr-obj-type p-curr-obj-code }

&Scop FRAME-NAME d-gds-prt

/* описание рабочей таблицы для дерева признаков */
define work-table prt-tree no-undo
  field bc        like ub.bar-code.b-code    format "9999999999" column-label "Осн. код"
  field n-code    like ub.gds-prt.node-code
  field n-name    like ub.gds-prt.node-name
  field rid       as   recid              /* ссылка на ub.gds-prt */
  field visible   as   log
  field exp       as   log
  field is-term   like ub.gds-prt.is-term
  field is-root   like ub.gds-prt.root
  field level     as   integer
  field mark      as   char

  .
define variable tree-level  as   integer           no-undo. /* величина сдвига в обрабатываемом поддереве */
define variable gds-prt-row as   integer init 1    no-undo. /* текущая запись ub.gds-prt для перерисовки дерева */

define variable old_qnty    like ub.doc-line.doc-qnty no-undo.
define variable shift-name  as   char              no-undo.

define variable rec-list    as   char              no-undo.
define variable glog as logical no-undo .

/* ------------------------- FUNCTIONS --------------------------------- */
FUNCTION fnc-shift-name RETURN char (cur-lev  as integer,
                                     cur-mark as char,
                                     cur-name as char).
  return (fill ("  ", cur-lev) +
          cur-mark +
          " " +
          cur-name).
END FUNCTION.

/* -------------- описание QUERY  и  BROWSE ---------------------------- */
define  query   br-gds-prt for prt-tree SCROLLING.
define  browse  br-gds-prt
       query br-gds-prt
       disp
       fnc-shift-name (prt-tree.level, prt-tree.mark, prt-tree.n-name) @ shift-name
       format "x(23)" column-label "Признак"
WITH SIZE 26 BY 14.3 separators.


/*----------------------------BUTTONS---------------------------------*/
DEFINE BUTTON b-exit AUTO-go
     LABEL "&Выход ":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exp-nd
     LABEL "&>>":L
     SIZE 10 BY 1.

DEFINE BUTTON b-exp-tree
     LABEL ">>&->>":L
     SIZE 10 BY 1.

DEFINE BUTTON b-rest
     LABEL "&Остатки":L
     SIZE 10 BY 1.

DEFINE BUTTON b-hist
     LABEL "Ис&тория":L
     SIZE 10 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.

DEFINE FRAME {&frame-name}
  b-exit     AT ROW 1.25  COL 1
  b-exp-nd   AT ROW 1.25  COL 11
  b-exp-tree AT ROW 1.25  COL 21
  b-rest     AT ROW 1.25  COL 31
  b-hist     AT ROW 1.25  COL 41
  b-help     AT ROW 1.25  COL 51
  br-gds-prt      AT ROW 2.5   COL 12
  WITH size 64 by 19 VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D.

/* ***************  Runtime Attributes and UIB Settings  ************** */

  br-gds-prt :set-repositioned-row (10, "conditional").
  ASSIGN
    FRAME {&frame-name}:SCROLLABLE = FALSE
    .

/* ************************  Control Triggers  ************************ */

/* вывод строки в список */
on row-display of br-gds-prt do:
  if prt-tree.is-root then
    shift-name :fgcolor in browse br-gds-prt = BLUE_COLOR.
  else
    if not prt-tree.is-term then
      shift-name :fgcolor in browse br-gds-prt = BROWN_COLOR.
end.

ON CHOOSE OF b-exit IN FRAME {&frame-name}  DO: /* Выход */
  /* пока работает так же, как и Выбор - ? подставлять не стал,
     чтоб не сломался reposition в документах на последнюю добавленную строку */
  p-prt-rec = prt-tree.rid.
END.

ON choose of b-exp-nd IN FRAME {&frame-name} DO:
  /* раскрытие одного узла */
  gds-prt-row = current-result-row ("br-gds-prt").
  run exp-nd (?).
  run UI-on.
END.

ON choose of b-exp-tree IN FRAME {&frame-name} DO:
  /* раскрытие поддерева одного узла */
  gds-prt-row = current-result-row ("br-gds-prt").
  run exp-tree.
  run UI-on.
END.

ON MOUSE-SELECT-DBLCLICK, return OF br-gds-prt IN FRAME {&frame-name} DO:
  gds-prt-row = current-result-row ("br-gds-prt").
  if prt-tree.is-term = false then do:
    apply "choose" to b-exp-nd in frame {&frame-name}.
  end.
  return no-apply.
END.

ON CHOOSE OF b-rest IN FRAME {&frame-name} do:
  run rep/prt-rest.w (
                 input parparentproc
                ,input p-curr-obj-type
                ,input p-curr-obj-code
                ,input prt-tree.rid).
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.

ON CHOOSE OF b-hist IN FRAME {&frame-name} DO:
 DEFINE VARIABLE rid-list AS character NO-UNDO.
 IF NOT AVAILABLE prt-tree THEN RETURN NO-APPLY.
   run ref/cgdsprts.w (
                     input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "one":U /*parref-mode */
                    ,INPUT prt-tree.n-code
                    ,INPUT NO
                    ,OUTPUT rid-list
       ) .
 apply "ENTRY":U to br-gds-prt .
END.


/* ***************************  Main Block  *************************** */

IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED THEN
  CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/getcntxt.i get }

find ub.gds-prt no-lock where
     recid (ub.gds-prt) = p-prt-rec.


glog = session:set-wait-state ("COMPILER") .
ENABLE br-gds-prt
       b-exit
       b-hist
       b-help
       b-rest
       b-exp-nd
       b-exp-tree with FRAME {&frame-name}.
run cre-nd (buffer ub.gds-prt, buffer prt-tree, 0).
find first prt-tree.
run exp-nd (yes).
FRAME {&FRAME-NAME}:title =
  "Шкала : " + ub.gds-prt.node-name + "  -  " + p-prt-mode.
RUN UI-on.
glog = session:set-wait-state ( "" ) .

do on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.
RUN disable_UI.


/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :

OPEN QUERY  br-gds-prt
  FOR EACH  prt-tree where
            prt-tree.visible = yes no-lock.
reposition br-gds-prt to row gds-prt-row no-error.
apply "ENTRY":U to br-gds-prt in frame {&frame-name}.
END PROCEDURE.


PROCEDURE exp-nd :
/* -----------------------------------------------------------------------------------------
   показавает или прячет подузлы текущего узла
   ----------------------------------------------------------------------------------------- */

/* направление визуализации всех подузлов (независимо от текущего состояния):
   yes - сделать видимым
   no  - сделать невидимым
   ? - начальное значение, определить по подузлам */
define input param make-visible as logical no-undo.
define variable nd-level as integer no-undo.               /* величина сдвига в обрабатываемом узле */
define buffer b-prt-tree for prt-tree.                /* вспомогат. буфер */

if prt-tree.exp then do:
  /* во временной таблице узел уже раскрыт - надо только показать */
  /* величина отступа в раскрываемом узле */
  nd-level = prt-tree.level.
  /* идем по таблице начиная с текущего узла (не включая) по отступам */
  find b-prt-tree where
       recid (b-prt-tree) = recid (prt-tree).
  inverse:
  do while true:
    find next b-prt-tree no-error.
    if not available b-prt-tree then
      /* дошли до конца таблицы */
      leave inverse.
    if b-prt-tree.level > nd-level then do:
      /* это подузел обрабатываемого узла */
      if make-visible = ? then
        make-visible = not (b-prt-tree.visible).
      if not make-visible or
         b-prt-tree.level - nd-level = 1 then do:
        b-prt-tree.visible = make-visible.
        if not b-prt-tree.is-term then
          b-prt-tree.mark = "»".
      end.
    end.
    else
      /* это узел того же или более высокого уровня по сравнению с обрабатываемым */
      leave inverse.
  end.
end.
else do:
  prt-tree.exp = yes.
  run cre-level (recid (prt-tree), prt-tree.level + 1).
  make-visible = yes.
end.
if not prt-tree.is-term then
  if make-visible then
    prt-tree.mark = " ".
  else
    prt-tree.mark = "»".
END PROCEDURE.

PROCEDURE exp-tree :
/* -----------------------------------------------------------------------------------------
   раскрытие поддерева одного узла
   ----------------------------------------------------------------------------------------- */
define variable rid as recid no-undo.                         /* для перечитывания записи */

/* величина отступа в раскрываемом узле */
tree-level = prt-tree.level.
run waitfram-show in this-procedure
  (input "Раскрывается шкала. Ждите..."
  ).
tree:
do while true:
  rid = recid (prt-tree).
  run exp-nd (yes).
  find prt-tree where rid = recid (prt-tree).        /* чтоб не сбивался порядок просмотра */
  find next prt-tree no-error.
  if not available prt-tree or
     /* дошли до конца таблицы */
     prt-tree.level <= tree-level
     /* это узел того же или более высокого уровня по сравнению с обрабатываемым */
     then
    leave tree.
end.
run waitfram-hide in this-procedure .

END PROCEDURE.

PROCEDURE cre-level:
/* -----------------------------------------------------------------------------------------
   заполнение таблицы для поддерева одного узла

   Для ускорения переделано на recid,
   b-prt-tree должен сначала содержать запись, после которой нужно добавлять, иначе добавляет в конец.
   ----------------------------------------------------------------------------------------- */
define input param prt-tree-rec as recid   no-undo.
define input param cur-lev      as integer no-undo.

define buffer b-gds-prt  for ub.gds-prt.
define buffer b-prt-tree for prt-tree.
define variable up-code like ub.gds-prt.node-code no-undo.

find b-prt-tree where
     recid (b-prt-tree) = prt-tree-rec.
up-code = b-prt-tree.n-code.
for each b-gds-prt no-lock where
         b-gds-prt.upper-code = up-code
         by b-gds-prt.prt-num:
  run cre-nd (buffer b-gds-prt, buffer b-prt-tree, cur-lev).
end.  /*  for each b-gds-prt  */
END PROCEDURE.

PROCEDURE cre-nd:
/* -----------------------------------------------------------------------------------------
   заполнение таблицы для одного узла
   ----------------------------------------------------------------------------------------- */
define parameter buffer b-gds-prt  for ub.gds-prt.
define parameter buffer b-prt-tree for prt-tree.
define input  parameter  cur-lev as integer no-undo.

create b-prt-tree.
assign
  b-prt-tree.n-code   = b-gds-prt.node-code
  b-prt-tree.level    = cur-lev
  b-prt-tree.n-name   = b-gds-prt.node-name
  b-prt-tree.rid      = recid (b-gds-prt)
  b-prt-tree.visible  = yes
  b-prt-tree.is-term  = b-gds-prt.is-term
  b-prt-tree.is-root  = b-gds-prt.root
  .
if b-gds-prt.is-term then
  assign
    b-prt-tree.mark = " "
    b-prt-tree.exp = yes
    .
else
  assign
    b-prt-tree.mark = "»"
    b-prt-tree.exp = no
    .
END PROCEDURE.

/* $Workfile$ e n d */