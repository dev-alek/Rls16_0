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
&Scop FRAME-NAME d-gds-prt
{ arc/gds_inf.i def  }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter doc-rec        as recid no-undo .
define input  parameter line-rec       as recid no-undo .
define input  parameter gds-rec        as recid no-undo .
define input  parameter prt-mode       as character no-undo .
define variable prt-rec        as recid no-undo .
define variable g#host-code    as integer   no-undo .
define variable g#host-name  as character no-undo .
define variable store-type     as character no-undo .
define variable store-code     as integer   no-undo .
define variable g#log          as logical   no-undo .
define variable g#report-num   as integer   no-undo .
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).


{ gbl/color.i       }
&if "{&cll-pnt}" = "rcv" &then
{ cus/df-zakaz.i }
define input parameter ord-line-fact-qnty like ub.ord-line-rcv.qnty no-undo .
define input parameter ord-line-cli-qnty  like ub.ord-line-rcv.cli-qnty no-undo .
define buffer b-ord-line     for ub.ord-line-rcv.
define buffer b-ord-gds-dtl  for ub.ord-dtl-rcv.

DEFINE QUERY br-dtl FOR b-ord-gds-dtl, ub.gds-prt, ub.goods, ub.bar-code SCROLLING.
&endif

&if "{&cll-pnt}" = "ord" &then
{ cus/df-zakaz.i }
define input parameter ord-line-fact-qnty like ub.ord-line.qnty no-undo .
define input parameter ord-line-cli-qnty  like ub.ord-line.cli-qnty no-undo .
define buffer b-ord-line     for Tmp#zakaz1.
define buffer b-ord-gds-dtl  for Tmp#zakaz-dtl1.

DEFINE QUERY br-dtl FOR b-ord-gds-dtl, ub.gds-prt, ub.goods, ub.bar-code SCROLLING.
&endif



&if "{&cll-pnt}" = "doc" or "{&cll-pnt}" = "fac" or "{&cll-pnt}" = "gds" or "{&cll-pnt}" = "inv"  &then
DEFINE QUERY br-dtl FOR ub.gds-dtl, ub.gds-prt, ub.goods, ub.bar-code SCROLLING.
&endif

/* описание рабочей таблицы для дерева признаков */
def work-table prt-tree no-undo
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
&if "{&cll-pnt}" = "inv" &then
  field doc-amnt  like ub.gds-dtl.doc-qnty   format "->>>,>>>,>>9.<<<" init 0 column-label "Разница"
  field fac-amnt  like ub.gds-dtl.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Факт остаток"
  field free-qnty like ub.prt-obj.free-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Свободно"
  field fact-qnty like ub.prt-obj.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "По описи"
&endif
&if "{&cll-pnt}" = "doc" or "{&cll-pnt}" = "fac" or "{&cll-pnt}" = "gds" &then
  field doc-amnt  like ub.gds-dtl.doc-qnty   format "->>>,>>>,>>>.<<<" init 0 column-label "По накл."
  field fac-amnt  like ub.gds-dtl.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Факт"
  field free-qnty like ub.prt-obj.free-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Свободно"
  field fact-qnty like ub.prt-obj.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Остаток"
  field price     like ub.prt-obj.price-sale format ">>>,>>>,>>9.99"   init ? column-label "Цена"
&endif
&if "{&cll-pnt}" = "ord" &then
  field doc-amnt  like ub.gds-dtl.doc-qnty   format "->>>,>>>,>>>.<<<" init 0 column-label "Заказ(ед.баз.)"
  field cli-amnt  like ub.gds-dtl.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Заказ(ед.пост)"
  field free-qnty like ub.prt-obj.free-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Свободно"
  field fact-qnty like ub.prt-obj.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Остаток"
  field price     like ub.prt-obj.price-sale format ">>>,>>>,>>9.99"   init ? column-label "Цена на объекте"
  field price-r-b like ub.gds-dtl.price-rubl format ">>>,>>>,>>9.99"   init ? column-label "Цена заказа"
&endif
&if "{&cll-pnt}" = "rcv" &then
  field doc-amnt  like ub.gds-dtl.doc-qnty   format "->>>,>>>,>>>.<<<" init 0 column-label "Поставка(ед.баз.)"
  field cli-amnt  like ub.gds-dtl.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Поставка(ед.пост)"
  field free-qnty like ub.prt-obj.free-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Свободно"
  field fact-qnty like ub.prt-obj.fact-qnty  format "->>>,>>>,>>>.<<<" init 0 column-label "Остаток"
  field price     like ub.prt-obj.price-sale format ">>>,>>>,>>9.99"   init ? column-label "Цена на объекте"
  field price-r-b like ub.gds-dtl.price-rubl format ">>>,>>>,>>9.99"   init ? column-label "Цена заказа"
&endif

  .
define variable tree-level  as   integer           no-undo. /* величина сдвига в обрабатываемом поддереве */
define variable gds-prt-row as   integer init 1    no-undo. /* текущая запись ub.gds-prt для перерисовки дерева */

define variable old_qnty    like ub.doc-line.doc-qnty no-undo.
define variable shift-name  as   char              no-undo.

define variable flt-amnt    as   log               no-undo. /* отметка на экране, что показывать только с имеющимися количествами */
define variable rec-list    as   char              no-undo.
define variable print-option as character no-undo.
define variable varr-b as character no-undo.
{ gbl/curr-r-b.i varr-b }

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
def  query   br-gds-prt for prt-tree SCROLLING.
def  browse  br-gds-prt
       query br-gds-prt
       disp
       fnc-shift-name (prt-tree.level, prt-tree.mark, prt-tree.n-name) @ shift-name
       format "x(23)" column-label "Признак"
&if "{&cll-pnt}" = "inv" &then
       prt-tree.fac-amnt
       prt-tree.doc-amnt
       prt-tree.fact-qnty
       prt-tree.bc
&endif
&if "{&cll-pnt}" = "doc" &then
       prt-tree.doc-amnt
       prt-tree.free-qnty
       prt-tree.fact-qnty
       prt-tree.price
       prt-tree.bc
&endif
&if "{&cll-pnt}" = "gds" &then
       prt-tree.free-qnty
       prt-tree.fact-qnty
       prt-tree.price
       prt-tree.bc
&endif
&if "{&cll-pnt}" = "fac"   &then
       prt-tree.doc-amnt
       prt-tree.fac-amnt
       prt-tree.free-qnty
       prt-tree.fact-qnty
       prt-tree.price
       prt-tree.bc
&endif
&if "{&cll-pnt}" = "ord"  &then
       prt-tree.doc-amnt
       prt-tree.cli-amnt
       prt-tree.price-r-b
       prt-tree.free-qnty
       prt-tree.fact-qnty
       prt-tree.price
       prt-tree.bc
&endif
&if "{&cll-pnt}" = "rcv"  &then
       prt-tree.doc-amnt
       prt-tree.cli-amnt
       prt-tree.price-r-b
       prt-tree.free-qnty
       prt-tree.fact-qnty
       prt-tree.price
       prt-tree.bc
&endif

WITH SIZE 93 BY 15 separators.


/*----------------------------BUTTONS---------------------------------*/
DEFINE BUTTON b-exit AUTO-go
     LABEL "&Выход ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-sel AUTO-go
     LABEL "Вы&бор ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить ":L
     SIZE 9 BY 1.

DEFINE BUTTON b-exp-nd
     LABEL "&>>":L
     SIZE 4.5 BY 1.

DEFINE BUTTON b-exp-tree
     LABEL ">>&->>":L
     SIZE 9 BY 1.

DEFINE BUTTON b-amnt
&if "{&cll-pnt}" = "gds" &then
     LABEL "&Чеки  ":L
&else
     LABEL "&Колич":L
&endif
     SIZE 9 BY 1.

DEFINE BUTTON b-codes
     LABEL "&Коды":L
     SIZE 9 BY 1.

DEFINE MENU m-alt
       MENU-ITEM m-alt-current  LABEL "Существующие неосновные цены"
       MENU-ITEM m-alt-all      LABEL "Все неосновные коды"
       rule
       MENU-ITEM m-prod-all     LABEL "Дополнительные коды"
       .

DEFINE MENU MENU-b-print
       MENU-ITEM m_hor          LABEL "Уровни по горизонтали"
       MENU-ITEM m_vert         LABEL "Уровни по вертикали"
       .

DEFINE BUTTON b-alt
     LABEL "&Неос/Доп":L
     SIZE 9 BY 1.

DEFINE BUTTON b-rest
     LABEL "&Остатки":L
     SIZE 9 BY 1.

DEFINE MENU m-inf
       MENU-ITEM m-inf-prt      LABEL "По признаку"
       MENU-ITEM m-inf-gds      LABEL "По товару"
       .

DEFINE BUTTON b-info
     LABEL "&Архив":L
     SIZE 9 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 9 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 9 BY 1.

&if "{&cll-pnt}" = "gds" &then
DEFINE BUTTON b-prt-ref
     LABEL "Шкала - новый интерфейс":L
     SIZE 25 BY 1.
&endif


DEFINE FRAME {&frame-name}
  b-exit     AT ROW 1.25  COL 1
  b-sel      AT ROW 1.25  COL 10
  b-del      AT ROW 1.25  COL 19
  b-exp-nd   AT ROW 1.25  COL 28
  b-exp-tree AT ROW 1.25  COL 32.5
  b-amnt     AT ROW 1.25  COL 41.5
  b-codes    AT ROW 1.25  COL 50.5
  b-alt      AT ROW 1.25  COL 59.5
  b-rest     AT ROW 1.25  COL 68.5
  b-info     AT ROW 1.25  COL 77.5
  b-print    AT ROW 1.25  COL 76.5
  b-help     AT ROW 1.25  COL 78.5
&if "{&cll-pnt}" = "gds" &then
  b-prt-ref  AT ROW 2.25  COL 1
&endif
&if "{&cll-pnt}" = "inv" &then
  "В целом по товару :"
             at row 2.5   col 5   view-as text
  ub.doc-line.doc-qnty
             at row 2.5   col 36  no-label      format "->>>,>>>,>>9.<<<"
  ub.doc-line.fact-qnty
             at row 2.5   col 49  no-label      format "->>>,>>>,>>9.<<<"
  old_qnty   at row 2.5   col 62  no-label      format "->>>,>>>,>>9.<<<"
&endif
&if "{&cll-pnt}" = "doc" or "{&cll-pnt}" = "fac" &then
  ub.doc-line.doc-qnty
             at row 2.5   col 30  label "Товар" format "->>>,>>>,>>9.<<<"
&endif
&if "{&cll-pnt}" = "fac" &then
  ub.doc-line.fact-qnty
             at row 2.5   col 50  label "Факт"  format "->>>,>>>,>>9.<<<"
&endif
&if "{&cll-pnt}" = "ord" &then
   ord-line-cli-qnty   at row 2.5   col 10  label "Заказ(ед.пост)"  format "->>>,>>>,>>9.<<<"
   ord-line-fact-qnty  at row 2.5   col 39  label "Заказ"           format "->>>,>>>,>>9.<<<"

&endif
&if "{&cll-pnt}" = "rcv" &then
  ord-line-cli-qnty   at row 2.5   col 10  label "Поставка(ед.пост)"  format "->>>,>>>,>>9.<<<"
  ord-line-fact-qnty  at row 2.5   col 39  label "Поставка"           format "->>>,>>>,>>9.<<<"

&endif
  ub.goods.unit-base at row 2.5   col 70  no-label      format "x(3)"

  flt-amnt        at row 3.5   col 5   label "Только с количествами" view-as toggle-box
  br-gds-prt      AT ROW 4.5   COL 2
  WITH size 96 by 21 VIEW-AS DIALOG-BOX SIDE-LABELS THREE-D.

/* ***************  Runtime Attributes and UIB Settings  ************** */
  ASSIGN
  b-print:POPUP-MENU IN FRAME d-gds-prt       = MENU MENU-b-print:HANDLE.
  br-gds-prt :set-repositioned-row (10, "conditional").
  b-print:MENU-MOUSE in frame {&frame-name}  = 1.
  ASSIGN
    FRAME {&frame-name}:SCROLLABLE = FALSE
    b-info    :POPUP-MENU IN FRAME {&frame-name}         = MENU m-inf  :HANDLE
    b-info    :MENU-MOUSE                                = 1
    b-alt     :POPUP-MENU IN FRAME {&frame-name}         = MENU m-alt  :HANDLE
    b-alt     :MENU-MOUSE                                = 1
    .

/* ************************  Control Triggers  ************************ */

on value-changed of flt-amnt do:
  gds-prt-row = current-result-row ("br-gds-prt").
  find first prt-tree.
  if input frame {&frame-name} flt-amnt then
    run exp-tree.
    run UI-on.
end.

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
  prt-rec = prt-tree.rid.
  return "exit":U.
END.

ON CHOOSE OF b-sel IN FRAME {&frame-name}  DO: /* Выбор */
  prt-rec = prt-tree.rid.
END.

ON choose of b-del IN FRAME {&frame-name} DO:
   def var gds-prt-recid as recid   no-undo.
   def var chg-qnty      as decimal no-undo.

  &if "{&cll-pnt}" = "doc"
  &then
   /* обнуляем кол-во в prt-tree */
  if available prt-tree then do:
     assign
       gds-prt-recid = recid(prt-tree)
       prt-tree.doc-amnt = 0
     .
    disp prt-tree.doc-amnt with browse br-gds-prt.
  end.

  def buffer b-gds-prt for gds-prt .

  /* удаляем линии */
  find gds-dtl exclusive-lock where
      gds-dtl.artic     = doc-line.artic and
      gds-dtl.prod-code = doc-line.prod-code and
      gds-dtl.prod-type = doc-line.prod-type and
      gds-dtl.doc-code  = doc-line.doc-code and
      gds-dtl.prt-code  = prt-tree.n-code no-error.
  if available gds-dtl then do:
    chg-qnty =  - ( gds-dtl.doc-qnty ). /*уменьшаем кол-во по партии на кол-во gds-dtl.doc-qnty */
    run trg/rsrv-dtl.p
      ( input        ParParentProc
      , input        {&rsrv-dtl_action_reserv}
      , buffer       gds-dtl
      , input-output chg-qnty
      , input-output doc-line.price-base
      , input-output doc-line.price-rubl
      , input        -1
      , input ""
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "rsrv-dtl.p {1}"
        view-as alert-box error
      .
    end.
    delete gds-dtl . /*удаляем gds-dtl*/
  end.

  /* перерасчитаем оставшиеся кол-ва */
  run clc-nd (buffer prt-tree).
  disp  &if "{&cll-pnt}" <> "ord" &then prt-tree.doc-amnt &endif
        &if "{&cll-pnt}" = "fac" &then prt-tree.fac-amnt &endif
        &if "{&cll-pnt}" = "ord" &then prt-tree.doc-amnt prt-tree.cli-amnt prt-tree.price-r-b &endif
        &if "{&cll-pnt}" = "rcv" &then prt-tree.cli-amnt prt-tree.price-r-b &endif
        prt-tree.bc
        with browse br-gds-prt.
  find first prt-tree.
  &if "{&cll-pnt}" = "ord" or "{&cll-pnt}" = "rcv" &then  run calc-tree (output prt-tree.doc-amnt, output prt-tree.cli-amnt).
  &else run calc-tree (output prt-tree.doc-amnt, output prt-tree.fac-amnt).
  &endif
  &if "{&cll-pnt}" = "inv" &then
    assign
      prt-tree.fac-amnt = 0 .
  &endif

  run ui-on.

  reposition br-gds-prt to recid gds-prt-recid no-error.
  &endif
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
  if prt-tree.is-term then do:
    if b-amnt:sensitive then
      apply "choose" to b-amnt in frame {&frame-name}.
  end.
  else
    apply "choose" to b-exp-nd in frame {&frame-name}.
  return no-apply.
END.

ON CHOOSE OF b-amnt IN FRAME {&frame-name}  DO:      /* Количество / Чеки */
  DEFINE VARIABLE rid-list as character no-undo .
  gds-prt-row = current-result-row ("br-gds-prt").
  if not prt-tree.is-root and
     not prt-tree.is-term then do:
    message "Данный признак промежуточный и не может быть выбран."
            view-as alert-box error.
    return no-apply.
  end.
  &if "{&cll-pnt}" = "gds" &then
  if prt-tree.bc = ? then do:
    message
      "Чеков по данному признаку нет."
      view-as alert-box.
    return no-apply.
  end.
  run ref/gds-chk.w (input parparentproc
                ,input prt-tree.bc
                ,input "":U /*bttns*/
                ,input {&g___object}
                ,input ? /*pardoc-rec*/
                ,input store-type
                ,input store-code
                ,input "":U /*out-code*/
                ,input "":U /*d-card*/
                ,output rid-list
                ).
  apply "entry" to br-gds-prt in frame {&frame-name}.
  &elseif "{&cll-pnt}" <> "scl"  &then
  &if NOT ("{&cll-pnt}" = "ord" or "{&cll-pnt}" = "rcv" ) &then
  case ub.trn-doc.doc-type:
    when {&income} or
    when {&expense} or
    when {&write-off} or
    when {&return} then
      run str/out-prt.w (
                      parParentProc ,
                      doc-rec       ,
                      line-rec      ,
                      gds-rec       ,
                      prt-mode      ,
                      prt-tree.rid,
                     (if prt-tree.is-term then {&g#term}  else {&g#root}))
                     no-error.
    when {&inventory} then do:
      if ub.trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
        run str/inv-prt.w (
                      parParentProc ,
                      doc-rec       ,
                      line-rec      ,
                      gds-rec       ,
                      prt-mode      ,
                      prt-tree.rid,
                       (if prt-tree.is-term then
                          {&g#term}
                        else
                          {&g#root})) no-error.
      end.
      else do:
        message "Работа с признаками запрещена при работе с документом, имеющим расширенный тип: " ub.trn-doc.ext-doc-type "."
        view-as alert-box.
        return no-apply.
      end.
    end.
  end.
  &else
  /* корректировка количества */
  /* ord */
  /* rcv */
    if "{&cll-pnt}" = "rcv" then do:
    run cus/rcv-prt.w
                 ( parParentProc ,
                   doc-rec       ,
                   line-rec      ,
                   gds-rec       ,
                   prt-mode      ,
                   prt-tree.rid  ,
                  ( if prt-tree.is-term then  {&g#term}  else   {&g#root} )
                   ) no-error.
    end.
    if "{&cll-pnt}" = "ord" then do:
    run cus/ord-prt.w
                 ( parParentProc ,
                   doc-rec       ,
                   line-rec      ,
                   gds-rec       ,
                   prt-mode      ,
                   prt-tree.rid  ,
                  ( if prt-tree.is-term then  {&g#term} else   {&g#root} )
                  ) no-error.
    end.
  &endif
  if not error-status:error then do:
    run clc-nd (buffer prt-tree).
    disp  &if "{&cll-pnt}" <> "ord" &then prt-tree.doc-amnt &endif
          &if "{&cll-pnt}" = "fac" &then prt-tree.fac-amnt &endif
          &if "{&cll-pnt}" = "ord" &then prt-tree.doc-amnt prt-tree.cli-amnt prt-tree.price-r-b &endif
          &if "{&cll-pnt}" = "rcv" &then prt-tree.cli-amnt prt-tree.price-r-b &endif
          prt-tree.bc
          with browse br-gds-prt.
    find first prt-tree.
    &if "{&cll-pnt}" = "ord" or "{&cll-pnt}" = "rcv" &then  run calc-tree (output prt-tree.doc-amnt, output prt-tree.cli-amnt).
    &else run calc-tree (output prt-tree.doc-amnt, output prt-tree.fac-amnt).
    &endif
    &if "{&cll-pnt}" = "inv" &then
      assign
        prt-tree.fac-amnt = 0 .
    &endif

    run ui-on.
  end.
  &endif

END.

&if "{&cll-pnt}" = "scl" &then
ON CHOOSE OF b-print IN FRAME {&frame-name}  do:
 if print-option = "" then do:
    run gbl/pop-up.p (b-print:handle, no) no-error.
 end.
 if print-option = "" then return no-apply.
CASE print-option:
    when "hor":U then do:
        run ref/gdsprtpr.p (parparentproc,  ub.gds-prt.node-code) no-error.
    end.
    when "vert":U then do:
        run ref/gdsprtpv.p (parparentproc,  ub.gds-prt.node-code) no-error.
    end.
END CASE.
print-option = "":U.
if error-status:error then do:
    return no-apply.
end.
  apply "entry" to br-gds-prt in frame {&frame-name}.
end.
&endif

&if "{&cll-pnt}" <> "scl" &then
ON CHOOSE OF b-codes IN FRAME {&frame-name} do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  prt-rec = prt-tree.rid.
  run ref/alt-bc.w (
                input parParentProc
              , input store-type
              , input store-code
              , input prt-tree.bc).
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.
&endif

&if "{&cll-pnt}" = "scl" &then
ON CHOOSE OF MENU-ITEM m_hor /* Уровни по горизонтали */
DO:
  assign
  print-option = "hor":U.
  apply "CHOOSE" to b-print in frame {&frame-name}.
END.
ON CHOOSE OF MENU-ITEM m_vert /* Уровни по вертикали */
DO:
    assign
  print-option = "vert":U.
  apply "CHOOSE" to b-print in frame {&frame-name}.

END.
&endif

&if "{&cll-pnt}" <> "scl" &then
ON CHOOSE OF menu-item m-alt-current do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  run ref/alt-cds.w ( input parParentProc
                     ,input store-type
                     ,input store-code
                     ,input "code-current"
                     ,input ub.goods.gds-code
                     ,input prt-tree.bc
                     ,output rec-list).
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.
&endif

&if "{&cll-pnt}" <> "scl" &then
ON CHOOSE OF menu-item m-alt-all do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  run ref/alt-cds.w ( input parParentProc
                     ,input store-type
                     ,input store-code
                     ,input "code-all"
                     ,input ub.goods.gds-code
                     ,input prt-tree.bc
                     ,output rec-list).
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.
&endif

&if "{&cll-pnt}" <> "scl" &then
ON CHOOSE OF menu-item m-prod-all do:
  run cre-code no-error.
  if error-status :error then
    return no-apply.
  run ref/prod-cds.w (parParentProc, store-type, store-code,
                  "code-all", ub.goods.gds-code, prt-tree.bc, output rec-list).
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.
&endif

ON CHOOSE OF menu-item m-inf-prt
do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_reference_archive':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    true
    g#log
  }
  if g#log then
    run ref/prt_inf.w (buffer ub.goods,
                   input prt-tree.n-code,
                   input store-type,
                   input store-code).
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.

ON CHOOSE OF menu-item m-inf-gds do:
   run local-gds_inf.
END.

ON CHOOSE OF b-rest IN FRAME {&frame-name} do:
  prt-rec = prt-tree.rid.
  &if "{&cll-pnt}" = "scl" &then
  run rep/prt-rest.w
  ( parParentProc,
    v-cntxt-obj-type,
    v-cntxt-obj-code,
    prt-rec      )

  .
  &else
    run rep/gds-objs.w (parparentproc, ub.goods.artic, ub.goods.prod-type, ub.goods.prod-code, g#host-code, prt-tree.n-code).
  &endif
  apply "entry" to br-gds-prt in frame {&frame-name}.
END.


&if "{&cll-pnt}" = "gds" &then
ON CHOOSE OF b-prt-ref IN FRAME {&frame-name} do:

  define variable v-sel-node-code as integer   no-undo .
  run str/prt-ref.w
    (input parParentProc
    ,input  ub.goods.gds-code  /* p-gds-code      */
    ,input  prt-mode        /* p-mode          */
    ,input  store-type      /* p-obj-type      */
    ,input  store-code      /* p-obj-code      */
    ,input  ""              /* p-doc-code      */
    ,input  ""              /* p-search-code   */
    ,output v-sel-node-code /* v-sel-node-code */
    ) .

END.
&endif


/* ***************************  Main Block  *************************** */

IF CURRENT-WINDOW:WINDOW-STATE = WINDOW-MINIMIZED THEN
  CURRENT-WINDOW:WINDOW-STATE = WINDOW-NORMAL.

{ gbl/app_help.i }

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.
&if "{&cll-pnt}" = "scl" &then
find  ub.gds-prt no-lock where
     recid ( ub.gds-prt) = prt-rec.
&else
find ub.goods no-lock where
     recid (ub.goods) = gds-rec.
find ub.gds-prt no-lock where
     ub.gds-prt.upper-code = ub.goods.prt-root.
&endif

&if "{&cll-pnt}" <> "gds" and
    "{&cll-pnt}" <> "rcv" and
    "{&cll-pnt}" <> "ord" and
    "{&cll-pnt}" <> "scl" &then
find ub.trn-doc no-lock where
     recid (ub.trn-doc) = doc-rec.
find ub.doc-line no-lock where
     recid (ub.doc-line) = line-rec. /* буфер нужен для clc-nd */
assign
store-type = ub.trn-doc.obj-type
store-code = ub.trn-doc.obj-code
.
&endif

&if "{&cll-pnt}" = "ord"  &then
find first b-ord-line where b-ord-line.artic = ub.goods.artic and
     b-ord-line.prod-code = ub.goods.prod-code and
     b-ord-line.prod-type = ub.goods.prod-type no-error .
assign
store-type = b-ord-line.obj-type
store-code = b-ord-line.obj-code
.
&endif


g#log = session:set-wait-state ("COMPILER") .
ENABLE br-gds-prt
       b-exit
       b-help
       b-rest
       &if "{&cll-pnt}" = "scl" &then
       b-print
       &endif
       &if "{&cll-pnt}" = "doc" &then
       b-del
       &endif
       b-exp-nd
       b-exp-tree with FRAME {&frame-name}.
run cre-nd (buffer  ub.gds-prt, buffer prt-tree, 0).
find first prt-tree.
run exp-nd (yes).
FRAME {&FRAME-NAME}:title =
&if "{&cll-pnt}" = "scl" &then
  "Шкала : " +  ub.gds-prt.node-name + "  -  " + prt-mode.
&else
  ub.goods.artic + " " + ub.goods.gds-name + "  -  " + prt-mode.
ENABLE b-sel when prt-mode = {&choose}
       b-info
       b-codes b-alt b-amnt
       with FRAME {&frame-name}.
ENABLE flt-amnt with FRAME {&frame-name}.

&if "{&cll-pnt}" <> "gds" &then
find first prt-tree.
&if "{&cll-pnt}" = "ord"  or "{&cll-pnt}" = "rcv" &then run calc-tree (output prt-tree.doc-amnt, output prt-tree.cli-amnt).
&else  run calc-tree (output prt-tree.doc-amnt, output prt-tree.fac-amnt).
&if "{&cll-pnt}" = "inv" &then
  assign
    prt-tree.fac-amnt = 0.
&endif
&endif
&endif
&endif
run ui-on.
g#log = session:set-wait-state ( "" ) .


&if "{&cll-pnt}" = "gds" &then
define variable v-sys-key as character no-undo .
{ gbl/currsysk.i
  v-sys-key
  no-error
}

if error-status :error
  or v-sys-key <> {&SuperSysKey}
then do:
  assign
    b-prt-ref :visible   = false
  .
end.
else do:
  assign
    b-prt-ref :visible   = true
    b-prt-ref :sensitive = true
  .
end.
&endif


do on endkey undo, leave  on error undo, leave:
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
end.
run disable_ui.


/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE UI-on :
find  ub.prt-obj where  ub.prt-obj.prt-code  =  ub.gds-prt.node-code
               and  ub.prt-obj.prod-code = ub.goods.prod-code
               and  ub.prt-obj.prod-type = ub.goods.prod-type
               and  ub.prt-obj.artic     = ub.goods.artic
               and  ub.prt-obj.obj-code  = store-code
               and  ub.prt-obj.obj-type  = store-type
               no-lock no-error.

&if "{&cll-pnt}" <> "gds" and
    "{&cll-pnt}" <> "rcv" and
    "{&cll-pnt}" <> "ord" and
    "{&cll-pnt}" <> "scl" &then
find ub.doc-line where recid (ub.doc-line) = line-rec no-lock.
old_qnty = ub.doc-line.doc-qnty - ub.doc-line.fact-qnty.
if old_qnty = ? then
  if available  ub.prt-obj then
    old_qnty =  ub.prt-obj.fact-qnty.
  else
    old_qnty = 0.
disp ub.goods.unit-base ub.doc-line.doc-qnty
&if "{&cll-pnt}" = "inv" &then
    old_qnty
&endif
&if "{&cll-pnt}" = "fac" or
    "{&cll-pnt}" = "inv" &then
    ub.doc-line.fact-qnty
&endif
    with frame {&frame-name}.
&endif

&if "{&cll-pnt}" = "ord" or "{&cll-pnt}" = "rcv"  &then
find first b-ord-line where b-ord-line.artic = ub.goods.artic and
     b-ord-line.prod-code = ub.goods.prod-code and
     b-ord-line.prod-type = ub.goods.prod-type no-error .

disp ub.goods.unit-base
     ord-line-fact-qnty
     ord-line-cli-qnty
    with frame {&frame-name}.
&endif


&if "{&cll-pnt}" <> "scl" and "{&cll-pnt}" <> "ord"  and "{&cll-pnt}" <> "rcv"  &then
if input frame {&frame-name} flt-amnt then
  OPEN QUERY br-gds-prt
    FOR EACH  prt-tree where
              prt-tree.visible = yes and
              (prt-tree.is-term = no or
              &if "{&cll-pnt}" = "gds" &then
              prt-tree.fact-qnty <> 0
              &else
              prt-tree.doc-amnt <> 0 or
              prt-tree.fac-amnt <> 0
              &endif
              ) no-lock.
else
&endif
&if "{&cll-pnt}" = "ord"  &then
if input frame {&frame-name} flt-amnt then
  OPEN QUERY br-gds-prt
    FOR EACH  prt-tree where
              prt-tree.visible = yes and
              (prt-tree.is-term = no or
              prt-tree.doc-amnt <> 0 or
              prt-tree.cli-amnt <> 0
              ) no-lock.
else
&endif
&if "{&cll-pnt}" = "rcv"  &then
if input frame {&frame-name} flt-amnt then
  OPEN QUERY br-gds-prt
    FOR EACH  prt-tree where
              prt-tree.visible = yes and
              (prt-tree.is-term = no or
              prt-tree.doc-amnt <> 0 or
              prt-tree.cli-amnt <> 0
              ) no-lock.
else
&endif

OPEN QUERY  br-gds-prt
  FOR EACH  prt-tree where
            prt-tree.visible = yes no-lock.
reposition br-gds-prt to row gds-prt-row no-error.
apply "ENTRY":U to br-gds-prt in frame {&frame-name}.
END PROCEDURE.


&if "{&cll-pnt}" <> "gds" and
    "{&cll-pnt}" <> "rcv" and
    "{&cll-pnt}" <> "ord" and
    "{&cll-pnt}" <> "scl" &then

PROCEDURE calc-tree:
def output param doc-accum like ub.gds-dtl.doc-qnty  no-undo.
def output param fac-accum like ub.gds-dtl.fact-qnty no-undo.

def buffer b-gds-dtl for ub.gds-dtl.

for each b-gds-dtl no-lock where
         b-gds-dtl.doc-code  = ub.doc-line.doc-code and
         b-gds-dtl.artic     = ub.doc-line.artic and
         b-gds-dtl.prod-type = ub.doc-line.prod-type and
         b-gds-dtl.prod-code = ub.doc-line.prod-code:
  accumulate b-gds-dtl.doc-qnty  (total)
             b-gds-dtl.fact-qnty (total)
             .
end.
assign
  doc-accum  = (accum total b-gds-dtl.doc-qnty)
  fac-accum  = (accum total b-gds-dtl.fact-qnty)
  .
END PROCEDURE.
&endif

&if "{&cll-pnt}" = "ord" &then
PROCEDURE calc-tree:
def output param doc-accum like ub.gds-dtl.doc-qnty no-undo.
def output param cli-accum like  ub.gds-dtl.fact-qnty no-undo.

find first b-ord-line where b-ord-line.artic = ub.goods.artic and
     b-ord-line.prod-code = ub.goods.prod-code and
     b-ord-line.prod-type = ub.goods.prod-type no-error .

for each b-ord-gds-dtl no-lock where
         b-ord-gds-dtl.doc-code  = b-ord-line.doc-code and
         b-ord-gds-dtl.artic     = b-ord-line.artic and
         b-ord-gds-dtl.prod-type = b-ord-line.prod-type and
         b-ord-gds-dtl.prod-code = b-ord-line.prod-code:
  accumulate
             b-ord-gds-dtl.qnty (total)
             b-ord-gds-dtl.cli-qnty (total)
             .
end.
assign
  doc-accum  = (accum total b-ord-gds-dtl.qnty)
  cli-accum  = (accum total b-ord-gds-dtl.cli-qnty)
  .
END PROCEDURE.
&endif

&if "{&cll-pnt}" = "rcv" &then
PROCEDURE calc-tree:

def output param doc-accum like  ub.gds-dtl.doc-qnty no-undo.
def output param cli-accum like  ub.gds-dtl.fact-qnty no-undo.
find first b-ord-line where recid(b-ord-line) = line-rec no-lock no-error .
assign
    doc-accum = 0
    cli-accum = 0
    .
for each b-ord-gds-dtl no-lock where
         b-ord-gds-dtl.rcv-code  = b-ord-line.rcv-code and
         b-ord-gds-dtl.doc-code  = b-ord-line.doc-code and
         b-ord-gds-dtl.artic     = b-ord-line.artic and
         b-ord-gds-dtl.prod-type = b-ord-line.prod-type and
         b-ord-gds-dtl.prod-code = b-ord-line.prod-code :
    assign
        doc-accum = doc-accum + b-ord-gds-dtl.qnty
        cli-accum = cli-accum + b-ord-gds-dtl.cli-qnty
    .
end.
END PROCEDURE.
&endif

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
    prt-tree.mark = " ".
  else
    prt-tree.mark = "»".
END PROCEDURE.

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

def buffer b-gds-prt  for  ub.gds-prt.
def buffer b-prt-tree for prt-tree.
define variable up-code like  ub.gds-prt.node-code no-undo.

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
def param buffer b-gds-prt  for  ub.gds-prt.
def param buffer b-prt-tree for prt-tree.
def input param cur-lev as integer no-undo.

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
&if "{&cll-pnt}" <> "scl" &then
run clc-nd (buffer b-prt-tree).
&endif
END PROCEDURE.

&if "{&cll-pnt}" <> "scl" &then
PROCEDURE clc-nd:
/* -----------------------------------------------------------------------------------------
   заполнение количеств, цен и кода одного терминального узла в таблице
   ----------------------------------------------------------------------------------------- */
def param buffer b-prt-tree for prt-tree.
def buffer b-gds-prt for  ub.gds-prt.

/* вычисляем ОСТАТОК (по описи) и СВОБОДНО */
&if "{&cll-pnt}" = "doc" or
    "{&cll-pnt}" = "fac" or
    "{&cll-pnt}" = "gds" or
    "{&cll-pnt}" = "rcv" or
    "{&cll-pnt}" = "ord" or
    "{&cll-pnt}" = "inv" &then
find b-gds-prt no-lock where
     recid (b-gds-prt) = b-prt-tree.rid.
find  ub.prt-obj no-lock where
       ub.prt-obj.prt-code  = b-gds-prt.node-code and
       ub.prt-obj.obj-type  = store-type and
       ub.prt-obj.obj-code  = store-code and
       ub.prt-obj.artic     = ub.goods.artic and
       ub.prt-obj.prod-type = ub.goods.prod-type and
       ub.prt-obj.prod-code = ub.goods.prod-code no-error.
if available  ub.prt-obj then do:
  assign
    b-prt-tree.free-qnty  =  ub.prt-obj.free-qnty
    b-prt-tree.fact-qnty  =  ub.prt-obj.fact-qnty
    .
  &if "{&cll-pnt}" = "inv" &then
  if ub.trn-doc.status_ <> {&fact} and
      b-prt-tree.is-term then
    /* начальное значение - сохраняется, если нет ub.gds-dtl */
    b-prt-tree.fac-amnt =  ub.prt-obj.fact-qnty.
  &else
  b-prt-tree.price =  ub.prt-obj.price-sale.
  &endif
end.
&endif

/* вычисляем ПО НАКЛ. (разницу) и ФАКТ */
&if "{&cll-pnt}" = "doc" or
    "{&cll-pnt}" = "fac" or
    "{&cll-pnt}" = "inv" &then
find  ub.gds-dtl no-lock where
      ub.gds-dtl.artic = ub.doc-line.artic and
      ub.gds-dtl.prod-code = ub.doc-line.prod-code and
      ub.gds-dtl.prod-type = ub.doc-line.prod-type and
      ub.gds-dtl.doc-code = ub.doc-line.doc-code and
      ub.gds-dtl.prt-code = b-gds-prt.node-code no-error.
if available  ub.gds-dtl then
  assign
    b-prt-tree.doc-amnt =  ub.gds-dtl.doc-qnty
    b-prt-tree.fac-amnt =  ub.gds-dtl.fact-qnty
    &if "{&cll-pnt}" = "inv" &then
    b-prt-tree.fact-qnty = b-prt-tree.fac-amnt - b-prt-tree.doc-amnt
    &endif
    .
else
&if "{&cll-pnt}" = "inv" &then
  if b-prt-tree.is-term and
     ub.trn-doc.status_ = {&fact} then
    assign
      b-prt-tree.fact-qnty = ?
      b-prt-tree.fac-amnt = ?
      b-prt-tree.doc-amnt = 0
      .
&else
  assign
    b-prt-tree.fac-amnt = 0
    b-prt-tree.doc-amnt = 0
    .
&endif
&endif

&if "{&cll-pnt}" = "ord"     &then
find first b-ord-gds-dtl no-lock where
     b-ord-gds-dtl.doc-code   = b-ord-line.doc-code  and
     b-ord-gds-dtl.artic      = b-ord-line.artic     and
     b-ord-gds-dtl.prod-code  = b-ord-line.prod-code and
     b-ord-gds-dtl.prod-type  = b-ord-line.prod-type and
     b-ord-gds-dtl.node-code  = b-gds-prt.node-code no-error.

if available b-ord-gds-dtl then do:
  assign
    b-prt-tree.cli-amnt     = b-ord-gds-dtl.cli-qnty
    b-prt-tree.doc-amnt     = b-ord-gds-dtl.qnty
    b-prt-tree.price-r-b    = (if varr-b = "rubl":u then b-ord-gds-dtl.price-rubl else b-ord-gds-dtl.price-base)
    .
end.
&endif
&if "{&cll-pnt}" = "rcv"     &then
find b-ord-gds-dtl no-lock where
     b-ord-gds-dtl.doc-code   = b-ord-line.doc-code and
     b-ord-gds-dtl.rcv-code   = b-ord-line.rcv-code and
     b-ord-gds-dtl.artic      = b-ord-line.artic and
     b-ord-gds-dtl.prod-code  = b-ord-line.prod-code and
     b-ord-gds-dtl.prod-type  = b-ord-line.prod-type and
     b-ord-gds-dtl.node-code   = b-gds-prt.node-code no-error.
if available b-ord-gds-dtl then
  assign
    b-prt-tree.cli-amnt     = b-ord-gds-dtl.cli-qnty
    b-prt-tree.doc-amnt     = b-ord-gds-dtl.qnty
    b-prt-tree.price-r-b    = (if varr-b = "rubl":u then b-ord-gds-dtl.price-rubl else b-ord-gds-dtl.price-base)
    .
&endif

find  ub.bar-code no-lock where
      ub.bar-code.gds-code  = ub.goods.gds-code and
      ub.bar-code.node-code = b-gds-prt.node-code and
      ub.bar-code.part-code = "" and
      ub.bar-code.in-code   = "" and
      ub.bar-code.unit-cli  = ub.goods.unit-base no-error.
if available ub.bar-code then
  b-prt-tree.bc = ub.bar-code.b-code.
else
  b-prt-tree.bc = ?.
END PROCEDURE.
&endif

&if "{&cll-pnt}" <> "scl" &then
PROCEDURE cre-code:
/* -----------------------------------------------------------------------------------------
   поиск / создание кода в узле
   ----------------------------------------------------------------------------------------- */
define variable is-new as log no-undo.
def buffer buf_bar-code for ub.bar-code.

  if not prt-tree.is-term and
     not prt-tree.is-root then do:
    message
      "Узел промежуточный. Работа с кодами запрещена."
      view-as alert-box error.
    return error.
  end.
  if prt-tree.bc = ? then do:
    g#log = no.
    message "Основной код для данного признака отсутствует. Создать код?"
            view-as alert-box question buttons YES-NO update g#log.
    if not g#log then
      return error.
    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_main-barcode_preparation':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      g#log
    }
    if not g#log then do:
      return error.
    END.
    { gbl/barcodcr.i
      ub.goods.gds-code
      prt-tree.n-code
      "''"
      "''"
      ub.goods.unit-base
      1
      is-new
      buf_bar-code
      no-error }
    if error-status :error then do:
      message
        "Ошибка поиска / создания основного кода." skip
        "Код товара:"        ub.goods.gds-code skip
        "Код признака:"      prt-tree.n-code skip
        "Единица измерения:" ub.goods.unit-base skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error.
      return error.
    end.
    prt-tree.bc = buf_bar-code.b-code.
    disp prt-tree.bc with browse br-gds-prt.
  end.
end.
&endif

{ arc/gds_inf.i calc ub.goods}
/* $Workfile$ e n d */