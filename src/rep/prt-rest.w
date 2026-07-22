/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Остатки по объекту для всех товаров, где есть данный узел шкалы

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

*/
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-prt-rec as recid no-undo .

&Scoped-define FRAME-NAME d-prt-obj

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Остатки по объекту для всех товаров, где есть данный узел шкалы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }
/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 7.75 BY 1.17.

DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE fact-qnty_ AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "По всем товарам ФАКТ"
     FGCOLOR 4
     VIEW-AS FILL-IN
     SIZE 14 BY 1
     NO-UNDO.

DEFINE  VARIABLE free-qnty_ AS DECIMAL FORMAT "->>,>>>,>>9.999":U INITIAL 0
     LABEL "По всем товарам СВОБОДНО"
     FGCOLOR 4
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE QUERY br-rest FOR prt-obj, goods SCROLLING.

DEFINE BROWSE br-rest QUERY br-rest NO-LOCK DISPLAY
      prt-obj.artic COLUMN-LABEL "Артикул" FORMAT "x(12)"
      goods.gds-name COLUMN-LABEL "Название" FORMAT "x(36)"
      prt-obj.fact-qnty COLUMN-LABEL "Факт" FORMAT "->>,>>>,>>>.<<"
      prt-obj.free-qnty COLUMN-LABEL "Свободно" FORMAT "->>,>>>,>>>.<<"
      prt-obj.price-sale COLUMN-LABEL "Цена продажи" FORMAT "->>,>>>.<<"
    WITH SEPARATORS SIZE 90 BY 13.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
     b-quit AT ROW 1 COL 1
     b-help AT ROW 1 COL 14
     br-rest AT ROW 5 COL 1.5
     fact-qnty_ AT ROW 3.25 COL 26.5 COLON-ALIGNED
     free-qnty_ AT ROW 3.25 COL 60 COLON-ALIGNED
     SPACE(3.24) SKIP(0.45)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-quit.

ASSIGN
       FRAME {&frame-name}:SCROLLABLE       = FALSE
       br-rest:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 1.

{ gbl/app_help.i }

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find gds-prt where recid (gds-prt) = p-prt-rec no-lock.
  for each prt-obj where prt-obj.prt-code = gds-prt.node-code
                                      and prt-obj.obj-type = p-curr-obj-type
                                      and prt-obj.obj-code = p-curr-obj-code no-lock:
    assign
        fact-qnty_ = fact-qnty_ + prt-obj.fact-qnty
        free-qnty_ = free-qnty_ + prt-obj.free-qnty
        .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.


PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE enable_UI :
  frame {&frame-name}:title = substitute('ОСТАТКИ ПО ТОВАРАМ &1 &2       ДЛЯ ПРИЗНАКА : &3'
                                          ,p-curr-obj-type
                                          ,p-curr-obj-code
                                          ,gds-prt.f-name).
  DISPLAY fact-qnty_ free-qnty_ WITH FRAME {&frame-name}.
  ENABLE br-rest b-quit b-help WITH FRAME {&frame-name}.
  open query br-rest for each prt-obj where prt-obj.prt-code = gds-prt.node-code
                                        and prt-obj.obj-type = p-curr-obj-type
                                        and prt-obj.obj-code = p-curr-obj-code no-lock,
                                      each goods where goods.artic = prt-obj.artic
                                                              and goods.prod-type = prt-obj.prod-type
                                                              and goods.prod-code = prt-obj.prod-code no-lock.
END PROCEDURE.