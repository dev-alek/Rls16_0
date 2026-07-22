/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

работа с деревом признаков

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init " работа с деревом признаков   ".
{ cmp/vssrevis.i }
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*== DEFINE ========================================================================================================*/
&Scop FRAME-NAME e-prt-z-dlg
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
define input  parameter parParentProc  as widget-handle no-undo.
define input-output  parameter v-prizn as character     no-undo.
define variable prt-rec        as recid     no-undo .
define variable g#host-code    as integer   no-undo .
define variable g#host-name    as character no-undo .
define variable store-type     as character no-undo .
define variable store-code     as integer   no-undo .
define variable g#log          as logical   no-undo .
define variable g#report-num   as integer   no-undo .
define temp-table work-elems no-undo
field elem as integer
index iel elem.
define variable found as logical no-undo init false.

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).

{ gbl/color.i       }

/* описание рабочей таблицы для дерева признаков */
define work-table prt-tree no-undo
  field n-code    like gds-prt.node-code
  field n-name    like gds-prt.node-name
  field rid       as   recid              /* ссылка на gds-prt */
  field visible   as   log
  field exp       as   log
  field is-term   like gds-prt.is-term
  field is-root   like gds-prt.root
  field level     as   integer
  field mark      as   char
  field is-sel    as   char
  field parnt     like gds-prt.upper-code
  .
define work-table prt-sel no-undo
  field ncode like gds-prt.node-code
  .
define variable tree-level  as   integer           no-undo. /* величина сдвига в обрабатываемом поддереве */
define variable gds-prt-row as   integer init 1    no-undo. /* текущая запись gds-prt для перерисовки дерева */

define variable shift-name  as   char              no-undo.

define variable rec-list    as   char              no-undo.
define variable print-option as character no-undo.
define variable varr-b       as character no-undo.
{ gbl/curr-r-b.i varr-b }

/* ------------------------- FUNCTIONS --------------------------------- */
FUNCTION fnc-shift-name RETURN char (cur-lev  as integer,
                                     cur-mark as char,
                                     cur-name as char).
  return (fill ("     ", cur-lev) +
          cur-mark +
          "" +
          cur-name).
END FUNCTION.

/* -------------- описание QUERY  и  BROWSE ---------------------------- */
def  query   br-gds-prt for prt-tree SCROLLING.
def  browse  br-gds-prt
       query br-gds-prt
       disp
       is-sel format "x(1)" column-label "*" 
       fnc-shift-name (prt-tree.level, prt-tree.mark, prt-tree.n-name) @ shift-name
       format "x(55)" column-label "Признак" 
WITH SIZE 57 BY 16 separators.


/*----------------------------BUTTONS---------------------------------*/
DEFINE BUTTON b-exp-nd
     LABEL "&>>":L
     SIZE 4.5 BY 1.

DEFINE BUTTON b-exp-tree
     LABEL ">>&->>":L
     SIZE 9 BY 1.

DEFINE BUTTON b-exit AUTO-go
     LABEL "&Выход ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-sel AUTO-go
     LABEL "Вы&бор ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9 BY 1.
        
DEFINE BUTTON b-snezhinka 
     LABEL "*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-sel-all 
     LABEL "+":L
     SIZE 3 BY 1.

DEFINE BUTTON b-unsel-all 
     LABEL "-":L
     SIZE 3 BY 1.
     
                  
DEFINE FRAME {&frame-name}
  b-exit     AT ROW 1.25  COL 1
  b-sel      AT ROW 1.25  COL 10
  b-help     AT ROW 1.25  COL 22
  b-snezhinka AT ROW 3 COL 2
  b-sel-all   at row 3 col 5
  b-unsel-all at row 3 col 8
  br-gds-prt      AT ROW 4.5   COL 2
  b-exp-nd   AT ROW 3  COL 23
  b-exp-tree AT ROW 3  COL 27.5
  WITH size 60 by 21 VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D.

/* ***************  Runtime Attributes and UIB Settings  ************** */

/* ************************  Control Triggers  ************************ */


/* вывод строки в список */
on row-display of br-gds-prt do:
  if prt-tree.is-root then
    shift-name :fgcolor in browse br-gds-prt = BLUE_COLOR.
  else
    if not prt-tree.is-term then
      shift-name :fgcolor in browse br-gds-prt = BROWN_COLOR.
  prt-tree.is-sel = "".
  for first work-elems where work-elems.elem = prt-tree.n-code:
      prt-tree.is-sel = "*".
  end.
end.

ON CHOOSE OF b-exit IN FRAME {&frame-name}  DO: /* Выход */
  /* пока работает так же, как и Выбор - ? подставлять не стал,
     чтоб не сломался reposition в документах на последнюю добавленную строку */
  return "exit":U.
END.

ON CHOOSE OF b-sel IN FRAME {&frame-name}  DO: /* Выбор */
      /*v-prizn = string(prt-tree.n-code).*/
      v-prizn = "".
      for each work-elems:
          v-prizn = v-prizn + string(work-elems.elem) + ",".
      end.
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

ON choose of b-snezhinka IN FRAME {&frame-name} DO:
   if prt-tree.is-sel = "*" then do:
      run waitfram-show in this-procedure
      (input "Производится удаление признаков из списка. Ждите..."
      ).
      if not prt-tree.is-term then run delete-child (prt-tree.n-code).
      else do:
        for each work-elems where elem = prt-tree.n-code:
            delete work-elems.
        end.
      end.
      run waitfram-hide in this-procedure .
    end.
    else do:
        found = no.
        run waitfram-show in this-procedure
        (input "Производится добавление признаков в список. Ждите..."
        ).
        if not prt-tree.is-term then run write-child (prt-tree.n-code).
        else do:
            for first work-elems where elem = prt-tree.n-code:
                found = yes.
            end.
            if not found then do:
                create work-elems.
                assign elem = prt-tree.n-code.
            end.
        end.
        run waitfram-hide in this-procedure .
    end.
    gds-prt-row = current-result-row ("br-gds-prt").
    run ui-on.
END.

ON MOUSE-SELECT-DBLCLICK, return OF br-gds-prt IN FRAME {&frame-name} DO:
    apply "choose" to b-exp-nd in frame {&frame-name}.
    return no-apply.
END. 

ON choose of b-sel-all IN FRAME {&frame-name} DO:
  for each work-elems:
      delete work-elems.
  end.
  for each gds-prt no-lock:
      create work-elems.
      assign work-elems.elem = gds-prt.node-code.
  end.
  run UI-on.
END.

ON choose of b-unsel-all IN FRAME {&frame-name} DO:
  for each work-elems:
      delete work-elems.
  end.
  run UI-on.
END.

/* ***************************  Main Block  *************************** */

IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED THEN
  CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
 ENABLE br-gds-prt
           b-exit
           b-help
           b-exp-nd
           b-exp-tree
           b-snezhinka
           b-sel-all
           b-unsel-all
           with FRAME {&FRAME-NAME}.
define variable pr-cur as integer no-undo init 0.
if v-prizn <> "" then do:
    do while pr-cur < num-entries(v-prizn,","):
        pr-cur = pr-cur + 1.
        create work-elems.
        assign elem = integer(entry(pr-cur,v-prizn,",")).
    end.
end.           
for each gds-prt  where gds-prt.root no-lock:
    g#log = session:set-wait-state ("COMPILER") .
    run cre-nd (buffer gds-prt, buffer prt-tree, 0).
end.
find first prt-tree.
/*run exp-nd (yes).*/
FRAME {&FRAME-NAME}:title = "Выбор признака".
ENABLE b-sel 
       with FRAME {&frame-name}.

find first prt-tree.
run ui-on.
g#log = session:set-wait-state ( "" ) .


do on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.
run disable_ui.


/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :

OPEN QUERY br-gds-prt
    FOR EACH  prt-tree where
              prt-tree.visible = yes and
              (prt-tree.is-term = no
              ) no-lock.


OPEN QUERY  br-gds-prt
  FOR EACH  prt-tree where
            prt-tree.visible = yes no-lock.
reposition br-gds-prt to row gds-prt-row no-error.
apply "ENTRY":U to br-gds-prt in frame {&frame-name}.
END PROCEDURE.


PROCEDURE exp-nd :
/* -----------------------------------------------------------------------------------------
   показывает или прячет подузлы текущего узла
   ----------------------------------------------------------------------------------------- */

/* направление визуализации всех подузлов (независимо от текущего состояния):
   yes - сделать видимым
   no  - сделать невидимым
   ? - начальное значение, определить по подузлам */
def input param make-visible as logical no-undo.
define variable nd-level as integer no-undo.               /* величина сдвига в обрабатываемом узле */
def buffer b-prt-tree for prt-tree.                /* вспомогат. буфер */

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
    prt-tree.mark = "".
  else
    prt-tree.mark = "»".
END PROCEDURE.

procedure write-child :
    define input parameter parnode as integer no-undo.
    define buffer b-prt-tree for gds-prt.
        create work-elems.
        assign elem = parnode.
    for each b-prt-tree where b-prt-tree.upper-code = parnode no-lock:
        if b-prt-tree.is-term then do:
                create work-elems.
                assign elem = b-prt-tree.node-code. 
        end.
        else run write-child (b-prt-tree.node-code).
    end.
end.

procedure delete-child :
    define input parameter parnode as integer no-undo.
    define buffer b-prt-tree for gds-prt.
    for each work-elems where elem = parnode:
        delete work-elems.
    end.
    for each b-prt-tree where b-prt-tree.upper-code = parnode no-lock:
        if b-prt-tree.is-term then do:
            for each work-elems where elem = b-prt-tree.node-code:
                delete work-elems.
            end.
        end.
        else run delete-child (b-prt-tree.node-code).
    end.
end.

PROCEDURE exp-tree :
/* -----------------------------------------------------------------------------------------
   раскрытие поддерева одного узла
   ----------------------------------------------------------------------------------------- */
  define variable rid as recid no-undo.                         /* для перечитывания записи */

  do
  on error undo, return error return-value
  :
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
  end.
END PROCEDURE.

PROCEDURE cre-level:
/* -----------------------------------------------------------------------------------------
   заполнение таблицы для поддерева одного узла

   Для ускорения переделано на recid,
   b-prt-tree должен сначала содержать запись, после которой нужно добавлять, иначе добавляет в конец.
   ----------------------------------------------------------------------------------------- */
def input param prt-tree-rec as recid   no-undo.
def input param cur-lev      as integer no-undo.

def buffer b-gds-prt  for gds-prt.
def buffer b-prt-tree for prt-tree.
define variable up-code like gds-prt.node-code no-undo.

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
def param buffer b-gds-prt  for gds-prt.
def param buffer b-prt-tree for prt-tree.
def input param cur-lev as integer no-undo.
def buffer bf-prt-tree for prt-tree.
create b-prt-tree.
assign
  b-prt-tree.n-code   = b-gds-prt.node-code
  b-prt-tree.level    = cur-lev
  b-prt-tree.n-name   = b-gds-prt.node-name
  b-prt-tree.rid      = recid (b-gds-prt)
  b-prt-tree.visible  = yes
  b-prt-tree.is-term  = b-gds-prt.is-term
  b-prt-tree.is-root  = b-gds-prt.root
  b-prt-tree.parnt    = b-gds-prt.upper-code
  .
for first bf-prt-tree where bf-prt-tree.n-code = b-gds-prt.upper-code.
    if bf-prt-tree.is-sel = "*" then do:
        b-prt-tree.is-sel = "*".
    end.
end.
if b-gds-prt.is-term then
  assign
    b-prt-tree.mark = "  "
    b-prt-tree.exp = yes
    .
else
  assign
    b-prt-tree.mark = "  »"
    b-prt-tree.exp = no
    .

/*run clc-nd (buffer b-prt-tree).*/
END PROCEDURE.



PROCEDURE cre-code:
/* -----------------------------------------------------------------------------------------
   поиск / создание кода в узле
   ----------------------------------------------------------------------------------------- */
define variable is-new as log no-undo.
def buffer buf_bar-code for bar-code.

  if not prt-tree.is-term and
     not prt-tree.is-root then do:
    message
      "Узел промежуточный. Работа с кодами запрещена."
      view-as alert-box error.
    return error.
  end.
end.
/* $Workfile$ e n d */