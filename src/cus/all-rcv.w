&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE NEW SHARED BUFFER bufs_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_ord-chain FOR ub.ord-chain.
DEFINE NEW SHARED BUFFER buf_ord-doc FOR ub.ord-doc.
DEFINE NEW SHARED BUFFER buf_trn-doc FOR ub.trn-doc.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список поставок

Автор: Чернова Светлана Александровна
Дата создания: 09/14/05
Author: Svetlana Chernova
Creation date: 09/14/05

Creation date: 03/13/02 10:16

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-host-code    as integer   no-undo .
define input  parameter p-g#type       as character no-undo .
define input  parameter p-g#stat       as character no-undo .
define input  parameter p-g#cons-code  as character no-undo .
define input  parameter list-mode      as character no-undo . /* cli obj firm with-fo withowt-fo firm-fin*/
define output parameter del-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список поставок".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-def.i  }
{ gbl/cur-time.i }
{ gbl/fltfield.i }
{ cmp/df-sub.i   }
{ gbl/waitfram.i }
{ cus/str-edi.i  }
{ str/trdcalib.i }
{ cmp/library.i  }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i    }
{ gbl/fltopend.i defproc }
{ gbl/getcntxt.i def }

define variable p-g#host-name  as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable hard-flt-cli    as logical   no-undo init false .
define variable hard-flt-date   as logical   no-undo init false .
define variable doc-mode    as character no-undo .
define variable line-mode   as character no-undo .
define variable doc-rec     as recid no-undo .
define variable line-rec    as recid no-undo . /* - */
define variable gds-rec     as recid no-undo . /* - */
define variable prt-rec     as recid no-undo . /* - */
define variable prt-cli-name     as character no-undo format "x(40)".
define variable prt-out-cli-code as character no-undo format "x(40)".
define variable prt-sum-rubl     as decimal   no-undo .
define new shared variable next-prev    as logical   no-undo .
define variable v-glog      as logical   no-undo .
define variable  mark as character no-undo.
define variable  sss  as character no-undo.
{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.


if store-type = ? or store-type = "" then do:
    define buffer buf_clients-name for ub.clients  .
    find first buf_clients-name no-lock where buf_clients-name.obj-code =  p-host-code and
                                              buf_clients-name.obj-type = {&cmp} no-error .

   p-g#host-name = buf_clients-name.obj-name.
end.
else do:
  { gbl/hostname.i store-type store-code  p-host-code p-g#host-name }
  { cmp/df-sub.i pr }
end.

/*-------------------------------------------------------------*/

define NEW SHARED  buffer  loc-doc-rcv   for ub.ord-doc-rcv.
define NEW SHARED  variable br-rcv-handle as handle no-undo   .
define NEW SHARED  variable x-make-avto   as integer no-undo .


&scop my-code string(buf_ord-doc.date-pay, "99/99/9999" )
&scop my-code1 v-status

define variable v-fo          as   character             no-undo.

define var sch-field as char no-undo.
define buffer t-d-b for ub.ord-cons.  /* для поиска по номеру, дате, факт */
define buffer buf_ord-cons for ub.ord-cons.  /* для поиска по номеру, дате, факт */
define buffer t-trn-line      for ub.doc-line     .
define buffer buf_ord-line-rcv  for ub.ord-line-rcv .

DEFINE  VARIABLE sch-fact AS date NO-UNDO.
define variable ll-rec as recid no-undo .
define variable v-status-edi as character no-undo .
define variable v-status-trn-edi as character no-undo .
define variable v-status-trn-edi1 as character no-undo .

define variable    par-is-edi as character no-undo .
define variable    par-is-edoc-nn as character no-undo .
define variable    par-type as character no-undo .
define variable    is-edi as logical   no-undo .
DEFINE VARIABLE v-color AS INTEGER NO-UNDO.
DEFINE VARIABLE is-edoc-nn AS LOGICAL NO-UNDO.
define variable filter-point as character no-undo init "Поставки " .
define variable sort-column-name as character no-undo .

/* ========== FUNCTION ====== */
FUNCTION sum-rubl returns decimal (buffer loc-t-doc for bufs_ord-doc-rcv) .
  define buffer buf_ord-line-rcv for ub.ord-line-rcv .
  define variable v-sum as decimal   no-undo .
  v-sum = 0.
  for each buf_ord-line-rcv no-lock where
          buf_ord-line-rcv.doc-code = loc-t-doc.doc-code and
          buf_ord-line-rcv.rcv-code = loc-t-doc.rcv-code
          :
      v-sum = v-sum  + buf_ord-line-rcv.cli-qnty * buf_ord-line-rcv.price-cli .
  end.
  return v-sum .
END FUNCTION.

FUNCTION cli-doc-out returns character (buffer loc-doc for ub.ord-doc-rcv) .
  return entry(1,loc-doc.sub-par,{&delim-par}) .
END FUNCTION.

FUNCTION cli-name returns character (buffer loc-t-doc for bufs_ord-doc-rcv) .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-type = loc-t-doc.cli-type and
           buf_clients.obj-code = loc-t-doc.cli-code no-error .
    if available buf_clients then return buf_clients.obj-name.
       else return loc-t-doc.obj-type + string(loc-t-doc.obj-code) .
END FUNCTION.

FUNCTION mark-string RETURNs CHAR (buffer loc-t-doc for bufs_ord-doc-rcv ).
  if can-do (del-list, string (recid (loc-t-doc))) then RETURN "*".
  else RETURN "".
END FUNCTION.

&scop SORTBY-PHRASE by  bufs_ord-doc-rcv.doc-date desc by bufs_ord-doc-rcv.doc-code desc
&scop where-phrase {1}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-docs

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES bufs_ord-doc-rcv buf_ord-doc buf_ord-chain ~
buf_trn-doc bufs_ord-doc-rcv

/* Definitions for BROWSE br-docs                                       */
&Scoped-define FIELDS-IN-QUERY-br-docs mark-string (buffer bufs_ord-doc-rcv) @ mark if bufs_ord-doc-rcv.ord-int2 = integer({&edoc-diff}) then "!" else "" IF (bufs_ord-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр") IF (bufs_ord-doc-rcv.status_ = {&fact} or bufs_ord-doc-rcv.status_ = {&ord-close}) THEN (bufs_ord-doc-rcv.status_ + string(bufs_ord-doc-rcv.flag_,"+/-")) ELSE (bufs_ord-doc-rcv.status_) bufs_ord-doc-rcv.rcv-code cli-doc-out (buffer bufs_ord-doc-rcv) @ prt-out-cli-code bufs_ord-doc-rcv.doc-date bufs_ord-doc-rcv.fact-date cli-name (buffer bufs_ord-doc-rcv) @ prt-cli-name sum-rubl (buffer bufs_ord-doc-rcv) @ prt-sum-rubl bufs_ord-doc-rcv.ship-date bufs_ord-doc-rcv.obj-type + " " + string(bufs_ord-doc-rcv.obj-code) bufs_ord-doc-rcv.cli-type + " " + string(bufs_ord-doc-rcv.cli-code) f-fo ( buffer bufs_ord-doc-rcv ) @ v-fo STRING(bufs_ord-doc-rcv.ship-time, "HH:MM") @ bufs_ord-doc-rcv.ship-time STRING(bufs_ord-doc-rcv.fact-ship-time, "HH:MM") @ bufs_ord-doc-rcv.fact-ship-time bufs_ord-doc-rcv.cons-code bufs_ord-doc-rcv.doc-code buf_ord-doc.cli-type + " " + string(buf_ord-doc.cli-code) buf_ord-doc.doc-type IF (buf_ord-doc.status_ = {&fact} or buf_ord-doc.status_ = {&ord-close}) THEN (buf_ord-doc.status_ + string(buf_ord-doc.flag_,"+/-")) ELSE (buf_ord-doc.status_) status-edoc-edi-light (buffer buf_ord-doc, input is-edoc-nn, input is-edi, output v-color) @ v-status-edi
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-docs
&Scoped-define SELF-NAME br-docs
&Scoped-define QUERY-STRING-br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK where ( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and                                 bufs_ord-doc-rcv.obj-type = store-type)                           else (                                  if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and                                                               bufs_ord-doc-rcv.cli-type = store-type)                                                         else ( true = true )                                ) )    and bufs_ord-doc-rcv.host-code = p-host-code and (p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and (p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and (p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) , ~
       EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK ~{&SORTBY-PHRASE}
&Scoped-define OPEN-QUERY-br-docs OPEN QUERY {&SELF-NAME} FOR EACH bufs_ord-doc-rcv NO-LOCK where ( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and                                 bufs_ord-doc-rcv.obj-type = store-type)                           else (                                  if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and                                                               bufs_ord-doc-rcv.cli-type = store-type)                                                         else ( true = true )                                ) )    and bufs_ord-doc-rcv.host-code = p-host-code and (p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and (p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and (p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) , ~
       EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK ~{&SORTBY-PHRASE} .
&Scoped-define TABLES-IN-QUERY-br-docs bufs_ord-doc-rcv buf_ord-doc
&Scoped-define FIRST-TABLE-IN-QUERY-br-docs bufs_ord-doc-rcv
&Scoped-define SECOND-TABLE-IN-QUERY-br-docs buf_ord-doc


/* Definitions for BROWSE BROWSE-34                                     */
&Scoped-define FIELDS-IN-QUERY-BROWSE-34 buf_ord-chain.rel-doc-code IF (buf_trn-doc.status_ = {&fact} or buf_trn-doc.status_ = {&ord-close}) THEN (buf_trn-doc.status_ + string(buf_trn-doc.flag_,"+/-")) ELSE (buf_trn-doc.status_) /* buf_trn-doc.cli-type + " " + string(buf_trn-doc.cli-code) */ /* buf_trn-doc.obj-type + " " + string(buf_trn-doc.obj-code) */ buf_trn-doc.fact-qnty buf_trn-doc.fact-rubl buf_trn-doc.doc-date buf_trn-doc.fact-date STRING(buf_trn-doc.fact-time, "HH:MM") @ buf_trn-doc.fact-time buf_trn-doc.doc-type status-edi-trn ( buffer buf_trn-doc ) @ v-status-trn-edi
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-34
&Scoped-define SELF-NAME BROWSE-34
&Scoped-define QUERY-STRING-BROWSE-34 FOR EACH buf_ord-chain NO-LOCK WHERE          buf_ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and          buf_ord-chain.doc-type = 'rcv' and          buf_ord-chain.rel-doc-type = 'trn' , ~
           EACH buf_trn-doc NO-LOCK where          buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-34 OPEN QUERY {&SELF-NAME} FOR EACH buf_ord-chain NO-LOCK WHERE          buf_ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and          buf_ord-chain.doc-type = 'rcv' and          buf_ord-chain.rel-doc-type = 'trn' , ~
           EACH buf_trn-doc NO-LOCK where          buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-34 buf_ord-chain buf_trn-doc
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-34 buf_ord-chain
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-34 buf_trn-doc


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-docs}~
    ~{&OPEN-QUERY-BROWSE-34}
&Scoped-define QUERY-STRING-Dialog-Frame FOR EACH bufs_ord-doc-rcv NO-LOCK
&Scoped-define OPEN-QUERY-Dialog-Frame OPEN QUERY Dialog-Frame FOR EACH bufs_ord-doc-rcv NO-LOCK.
&Scoped-define TABLES-IN-QUERY-Dialog-Frame bufs_ord-doc-rcv
&Scoped-define FIRST-TABLE-IN-QUERY-Dialog-Frame bufs_ord-doc-rcv


/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit RECT-1 b-sel b-rep b-sch b-close ~
b-exec b-print b-history b-help b-mark b-chg b-lkp b-del b-export ~
r-cli-type r-cli-code r-cli sch-date-rcv sch-rcv b-excecF sch-ship ~
sch-ship-2 sch-code sch-date br-docs BROWSE-34 FILL-IN-1 r-cli-name
&Scoped-Define DISPLAYED-OBJECTS r-cli-type r-cli-code sch-date-rcv sch-rcv ~
sch-ship sch-ship-2 sch-code sch-date FILL-IN-1 r-cli-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-fo Dialog-Frame
FUNCTION f-fo RETURNS CHARACTER
  ( buffer loc-t-doc for ub.ord-doc-rcv )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD status-edi-trn Dialog-Frame
FUNCTION status-edi-trn RETURNS CHARACTER
  ( buffer loc-t-doc for buf_trn-doc )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU m-exec
       MENU-ITEM m_gen-1        LABEL "Генерация ФО"
       MENU-ITEM m_lkp-fo       LABEL "Просмотр  ФО"
       MENU-ITEM m_gen-2        LABEL "Отказаться от генерации ФО"
       MENU-ITEM m_gen-3        LABEL "Снять признак - есть генерация ФО"
       MENU-ITEM m_gen-4        LABEL "Снять 'не опред'".

DEFINE MENU m-export
       MENU-ITEM m___Excel      LABEL "Экспорт в Excel"
       MENU-ITEM m_mobilscn     LABEL "Экспорт в Моб.сканер".

DEFINE MENU m-print
       MENU-ITEM m_print-list-rcv LABEL "Печать списка поставок"
       MENU-ITEM m_print-one    LABEL "Печать документа".

DEFINE MENU m-rep
       MENU-ITEM m_print_rep    LABEL "Отчет об исполнении поставок".


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 9 BY 1.

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE 12 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 12 BY 1.

DEFINE BUTTON b-excecF
     LABEL "&Применить":L
     SIZE 10.38 BY 1 TOOLTIP "Найти записи по условию".

DEFINE BUTTON b-exec
     LABEL "&Генерация ФО":L
     SIZE 14 BY 1 TOOLTIP "Создание и просмотр ФО".

DEFINE BUTTON b-export
     LABEL "&Экспорт":L
     SIZE 12 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.

DEFINE BUTTON b-history
     LABEL "&История":L
     SIZE 3 BY 1 TOOLTIP "История изменения поставки".

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE 12 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1.

DEFINE BUTTON b-open
     LABEL "&Открыть":L
     SIZE 12 BY 1.

DEFINE BUTTON b-print
     LABEL "Пе&чать":L
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход ":L
     SIZE 12 BY 1.

DEFINE BUTTON b-rep
     LABEL "О&тчеты":L
     SIZE 12 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE 12 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE 12 BY 1.

DEFINE BUTTON r-cli
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-cli"
     SIZE 3 BY 1.

DEFINE VARIABLE r-cli-type AS CHARACTER INITIAL "орг"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "орг","чел","маг","скл"
     DROP-DOWN
     SIZE 6.5 BY 1 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "          Поставщик и Дата доставки           "
      VIEW-AS TEXT
     SIZE 46.25 BY .67 TOOLTIP "Фильтр с кнопкой ПРИМЕНИТЬ"
     BGCOLOR 1 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE r-cli-code AS INTEGER FORMAT ">>>>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Код Поставщика" NO-UNDO.

DEFINE VARIABLE r-cli-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE sch-code AS CHARACTER FORMAT "X(14)"
     LABEL "№ &заказа"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Поиск по № заказа" NO-UNDO.

DEFINE VARIABLE sch-date AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата док-та"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате док.поставки" NO-UNDO.

DEFINE VARIABLE sch-date-rcv AS DATE FORMAT "99/99/9999"
     LABEL "Д&ата факт"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате факт.поставки" NO-UNDO.

DEFINE VARIABLE sch-num AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Найдено"
      VIEW-AS TEXT
     SIZE 3 BY .67
     FGCOLOR 12  NO-UNDO.

DEFINE VARIABLE sch-rcv AS CHARACTER FORMAT "X(14)"
     LABEL "№ &пост-ки"
     VIEW-AS FILL-IN
     SIZE 13.25 BY 1 TOOLTIP "Поиск по № Поставки" NO-UNDO.

DEFINE VARIABLE sch-ship AS DATE FORMAT "99/99/9999"
     LABEL "c"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате доставки С" NO-UNDO.

DEFINE VARIABLE sch-ship-2 AS DATE FORMAT "99/99/9999"
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 TOOLTIP "Поиск по дате доставки ПО" NO-UNDO.


DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 47.5 BY 3.25 TOOLTIP "Фильтр с кнопкой ПРИМЕНИТЬ".

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE new shared QUERY br-docs FOR
      bufs_ord-doc-rcv,
      buf_ord-doc SCROLLING.


DEFINE QUERY BROWSE-34 FOR
      buf_ord-chain,
      buf_trn-doc SCROLLING.

DEFINE QUERY Dialog-Frame FOR
      bufs_ord-doc-rcv SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-docs Dialog-Frame _FREEFORM
  QUERY br-docs NO-LOCK DISPLAY
      mark-string (buffer bufs_ord-doc-rcv) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
if bufs_ord-doc-rcv.ord-int2 = integer({&edoc-diff}) then "!" else "" column-label "!" FORMAT "x(1)" COLUMN-FGCOLOR 12
IF (bufs_ord-doc-rcv.doc-type = "out":U) THEN ("внешн") ELSE ("внутр") COLUMN-LABEL "Тип" FORMAT "x(5)"
IF (bufs_ord-doc-rcv.status_ = {&fact} or bufs_ord-doc-rcv.status_ = {&ord-close})  THEN (bufs_ord-doc-rcv.status_ + string(bufs_ord-doc-rcv.flag_,"+/-"))  ELSE (bufs_ord-doc-rcv.status_)  COLUMN-LABEL "Статус"
bufs_ord-doc-rcv.rcv-code COLUMN-LABEL "Номер"
cli-doc-out (buffer bufs_ord-doc-rcv) @ prt-out-cli-code COLUMN-LABEL "№по пост-ку" FORMAT "x(14)"
bufs_ord-doc-rcv.doc-date FORMAT "99/99/99"
bufs_ord-doc-rcv.fact-date FORMAT "99/99/99"
cli-name (buffer bufs_ord-doc-rcv) @ prt-cli-name   COLUMN-LABEL "Поставщик" FORMAT "x(15)"
sum-rubl (buffer bufs_ord-doc-rcv) @ prt-sum-rubl COLUMN-LABEL "Сумма поставки" FORMAT ">>>>>>>>>>>>9.99"
bufs_ord-doc-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
bufs_ord-doc-rcv.obj-type + " " + string(bufs_ord-doc-rcv.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)"
bufs_ord-doc-rcv.cli-type + " " + string(bufs_ord-doc-rcv.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)"
f-fo ( buffer bufs_ord-doc-rcv ) @ v-fo column-label "ФО" format "x(11)"
STRING(bufs_ord-doc-rcv.ship-time, "HH:MM")  FORMAT "x(6)" @ bufs_ord-doc-rcv.ship-time COLUMN-LABEL "Время"
STRING(bufs_ord-doc-rcv.fact-ship-time, "HH:MM")  FORMAT "x(6)" @ bufs_ord-doc-rcv.fact-ship-time COLUMN-LABEL "Факт"
bufs_ord-doc-rcv.cons-code COLUMN-LABEL "СЗФП"
bufs_ord-doc-rcv.doc-code COLUMN-LABEL "Заказ" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_ord-doc.cli-type + " " + string(buf_ord-doc.cli-code) COLUMN-LABEL "Поставщик" FORMAT "x(10)"
      LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
buf_ord-doc.doc-type COLUMN-LABEL "Тип" FORMAT "x(3)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
IF (buf_ord-doc.status_ = {&fact} or buf_ord-doc.status_ = {&ord-close})  THEN (buf_ord-doc.status_ + string(buf_ord-doc.flag_,"+/-"))  ELSE (buf_ord-doc.status_)
      COLUMN-LABEL "Статус"  FORMAT "x(8)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
status-edoc-edi-light (buffer buf_ord-doc, input is-edoc-nn, input is-edi, output v-color) @ v-status-edi COLUMN-LABEL "Статус EDI" FORMAT "x(12)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 3
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.

DEFINE BROWSE BROWSE-34
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-34 Dialog-Frame _FREEFORM
  QUERY BROWSE-34 NO-LOCK DISPLAY
      buf_ord-chain.rel-doc-code COLUMN-LABEL "ПН" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      IF (buf_trn-doc.status_ = {&fact} or buf_trn-doc.status_ = {&ord-close})  THEN (buf_trn-doc.status_ + string(buf_trn-doc.flag_,"+/-"))  ELSE (buf_trn-doc.status_)
      COLUMN-LABEL "Статус"  FORMAT "x(8)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      /* buf_trn-doc.cli-type + " " + string(buf_trn-doc.cli-code) COLUMN-LABEL "Контрагент" FORMAT "x(10)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1 */
      /* buf_trn-doc.obj-type + " " + string(buf_trn-doc.obj-code) COLUMN-LABEL "Объект" FORMAT "x(10)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 1    */
      buf_trn-doc.fact-qnty COLUMN-LABEL "Количество" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.fact-rubl COLUMN-LABEL "Сумма {&abbr_rub_allshift}" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.doc-date COLUMN-LABEL "Дата док" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.fact-date COLUMN-LABEL "Дата факт" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      STRING(buf_trn-doc.fact-time, "HH:MM") @ buf_trn-doc.fact-time COLUMN-LABEL "Время факт" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      buf_trn-doc.doc-type COLUMN-LABEL "Тип" FORMAT "x(3)"  LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
      status-edi-trn ( buffer buf_trn-doc )  @ v-status-trn-edi COLUMN-LABEL "Статус EDI" FORMAT "x(12)" LABEL-FGCOLOR 15 LABEL-BGCOLOR 1
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.21 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 13
     b-rep AT ROW 1 COL 25
     b-sch AT ROW 1 COL 37
     b-close AT ROW 1 COL 37
     b-exec AT ROW 1 COL 49
     b-open AT ROW 1 COL 63
     b-print AT ROW 1 COL 90.5
     b-history AT ROW 1 COL 93.5
     b-help AT ROW 1 COL 96.5
     b-mark AT ROW 2 COL 1
     b-chg AT ROW 2 COL 4
     b-lkp AT ROW 2 COL 13
     b-del AT ROW 2 COL 25
     b-export AT ROW 2 COL 37 WIDGET-ID 2
     r-cli-type AT ROW 3 COL 51.13 COLON-ALIGNED NO-LABEL WIDGET-ID 14
     r-cli-code AT ROW 3 COL 57.5 COLON-ALIGNED NO-LABEL WIDGET-ID 16
     r-cli AT ROW 3 COL 73.75 WIDGET-ID 18
     sch-date-rcv AT ROW 3.04 COL 36.88 COLON-ALIGNED
     sch-rcv AT ROW 3.08 COL 10 COLON-ALIGNED
     b-excecF AT ROW 4 COL 88 WIDGET-ID 4
     sch-ship AT ROW 4.08 COL 54.75 COLON-ALIGNED WIDGET-ID 6
     sch-ship-2 AT ROW 4.08 COL 71.75 COLON-ALIGNED WIDGET-ID 8
     sch-code AT ROW 4.13 COL 10 COLON-ALIGNED
     sch-date AT ROW 4.13 COL 36.88 COLON-ALIGNED
     br-docs AT ROW 5.25 COL 1
     BROWSE-34 AT ROW 17.25 COL 1 WIDGET-ID 100
     sch-num AT ROW 1.17 COL 83.13 COLON-ALIGNED
     FILL-IN-1 AT ROW 2.17 COL 50.63 COLON-ALIGNED NO-LABEL WIDGET-ID 12
     r-cli-name AT ROW 3.13 COL 75 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     RECT-1 AT ROW 2 COL 52 WIDGET-ID 10
     SPACE(0.00) SKIP(17.21)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Поставки под заказ"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: bufs_ord-doc-rcv B "NEW SHARED" ? ub ord-doc-rcv
      TABLE: buf_ord-chain B "?" ? ub ord-chain
      TABLE: buf_ord-doc B "NEW SHARED" ? ub ord-doc
      TABLE: buf_trn-doc B "NEW SHARED" ? ub trn-doc
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-docs sch-date Dialog-Frame */
/* BROWSE-TAB BROWSE-34 br-docs Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       b-exec:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-exec:HANDLE.

ASSIGN
       b-export:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-export:HANDLE.

/* SETTINGS FOR BUTTON b-open IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       b-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-print:HANDLE.

ASSIGN
       b-rep:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-rep:HANDLE.

/* SETTINGS FOR FILL-IN sch-num IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       sch-num:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-docs
/* Query rebuild information for BROWSE br-docs
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH bufs_ord-doc-rcv NO-LOCK
where
( if list-mode = 'obj':U then ( bufs_ord-doc-rcv.obj-code = store-code and
                                bufs_ord-doc-rcv.obj-type = store-type)
                          else (
                                 if list-mode = 'cli':U then (bufs_ord-doc-rcv.cli-code = store-code and
                                                              bufs_ord-doc-rcv.cli-type = store-type)
                                                        else ( true = true )
                               ) )
   and
bufs_ord-doc-rcv.host-code = p-host-code and
(p-g#cons-code = ? or ( bufs_ord-doc-rcv.cons-code = p-g#cons-code)) and
(p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type)) and
(p-g#stat = ? or  (bufs_ord-doc-rcv.status_ = p-g#stat  )) and
(hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) and
(hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type))
,
EACH buf_ord-doc WHERE buf_ord-doc.doc-code = bufs_ord-doc-rcv.doc-code OUTER-JOIN NO-LOCK
~{&SORTBY-PHRASE} .
     _END_FREEFORM
     _START_FREEFORM_DEFINE
DEFINE new shared QUERY br-docs FOR
      bufs_ord-doc-rcv,
      buf_ord-doc SCROLLING.
     _END_FREEFORM_DEFINE
     _Options          = "NO-LOCK SORTBY-PHRASE"
     _Query            is OPENED
*/  /* BROWSE br-docs */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-34
/* Query rebuild information for BROWSE BROWSE-34
     _START_FREEFORM
OPEN QUERY {&SELF-NAME}
FOR EACH buf_ord-chain NO-LOCK WHERE
         buf_ord-chain.doc-code = bufs_ord-doc-rcv.rcv-code and
         buf_ord-chain.doc-type = 'rcv' and
         buf_ord-chain.rel-doc-type = 'trn' ,
    EACH buf_trn-doc NO-LOCK where
         buf_trn-doc.doc-code = buf_ord-chain.rel-doc-code
INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-34 */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _TblList          = "bufs_ord-doc-rcv"
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Поставки под заказ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg Dialog-Frame
ON CHOOSE OF b-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available bufs_ord-doc-rcv then return .
define variable  v-line-mode  as character no-undo .
define variable  v-doc-mode   as character no-undo .
define variable  v-list-mode  as character no-undo .

 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_update':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .


if buf_ord-doc.doc-type = {&o-o} then return.
    if available bufs_ord-doc-rcv then do:
          if bufs_ord-doc-rcv.status_ = {&fact} then do :
              message "Статус" caps(bufs_ord-doc-rcv.status_) "изменять нельзя! " view-as alert-box error .
              ll-rec = recid(bufs_ord-doc-rcv) .
              return no-apply .
          end.

          ll-rec = recid(bufs_ord-doc-rcv) .

        if bufs_ord-doc-rcv.status_ = {&ord-rcv} then  do:
              assign
                v-line-mode  = {&lookup}
                v-doc-mode   = {&lookup}
                v-list-mode  = {&ord-rcv}
               .
        end.
        else  do:
              assign
                v-line-mode = {&update}
                v-doc-mode  = {&update}
                .
        end.

        run cus/or-obj.w (
               input  parParentProc
             , input  p-host-code
             , input  recid(bufs_ord-doc-rcv)
             , input  3
             , input  v-list-mode
             , input  v-line-mode
             , input-output  v-doc-mode  ) .

        v-glog =  {&BROWSE-NAME}:refresh() .
    end.
apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
END.
ON CHOOSE OF MENU-ITEM m_gen-1 /* Генерация */
DO:
run proc-m_gen-1 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-2 /* Генерация */
DO:
run proc-m_gen-2 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-3 /* Генерация */
DO:
run proc-m_gen-3 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_gen-4 /* Генерация */
DO:
run proc-m_gen-4 no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.
ON CHOOSE OF MENU-ITEM m_lkp-fo /* Генерация */
DO:
run proc-m_lkp-fo no-error .
  if error-status :error then do: message return-value error-status :get-message(1) . return no-apply. end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-close Dialog-Frame
ON CHOOSE OF b-close IN FRAME Dialog-Frame /* Закрыть */
DO:
    run cus/rcv-clos.p
      ( input parParentProc ,
        input bufs_ord-doc-rcv.rcv-code ,
        input yes ,
        input store-type ,
        input store-code ,
        input yes
        ) no-error .
    if error-status :error then do:
          message  return-value  view-as alert-box error .
          return no-apply .
    end.
  if p-g#stat = ? then  v-glog =  {&BROWSE-NAME}:refresh() .
                else {&OPEN-QUERY-{&BROWSE-NAME}}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:
if not available bufs_ord-doc-rcv then return .
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_deletion':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

  if buf_ord-doc.doc-type = {&o-o} then return.

    if available bufs_ord-doc-rcv then do:
       find current bufs_ord-doc-rcv exclusive-lock no-error.
            if avail bufs_ord-doc-rcv then do:
              if bufs_ord-doc-rcv.status_ <> {&g___new} then do :
              message "Статус " bufs_ord-doc-rcv.status_  " удалять нельзя! " view-as alert-box error .
              return.
              end.

               message "Удалить поставку №"  bufs_ord-doc-rcv.rcv-code "?" view-as alert-box
                        question buttons yes-no title "Вопрос" update v-glog.
                    if v-glog then do:
                        delete  bufs_ord-doc-rcv .
                        {&OPEN-QUERY-{&BROWSE-NAME}}
                    end.
               end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-excecF
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-excecF Dialog-Frame
ON CHOOSE OF b-excecF IN FRAME Dialog-Frame /* Применить */
DO:
  run set-selection in this-procedure no-error .
  if error-status :error then return .
  run OpenBr in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Экспорт */
DO:
if not available bufs_ord-doc-rcv then return .
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

if buf_ord-doc.doc-type = {&o-o} then return.
ll-rec = recid(bufs_ord-doc-rcv) .
next-prev = no.
br-rcv-handle = {&BROWSE-NAME}:handle.

do while next-prev <> ?:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  ll-rec = recid(bufs_ord-doc-rcv) .
  run cus/lkp-rcv.w ( parParentProc,  input-output ll-rec ) .
  reposition {&BROWSE-NAME} to recid ll-rec no-error.
  apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
end.

 if br-rcv-handle = ? then reposition {&BROWSE-NAME} to recid ll-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-history Dialog-Frame
ON CHOOSE OF b-history IN FRAME Dialog-Frame /* История */
DO:
if not available bufs_ord-doc-rcv then return .

    run cus/ordcdoc.w (
    parParentProc,
    bufs_ord-doc-rcv.host-code,
    bufs_ord-doc-rcv.doc-code,
    bufs_ord-doc-rcv.rcv-code )
        .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
if not available bufs_ord-doc-rcv then return .
 define variable g-log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_ord-rcv_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g-log
  }
 if not g-log then  return .

if buf_ord-doc.doc-type = {&o-o} then return.
ll-rec = recid(bufs_ord-doc-rcv) .
next-prev = no.
br-rcv-handle = {&BROWSE-NAME}:handle.

do while next-prev <> ?:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор документа.".
    return no-apply.
  end.
  ll-rec = recid(bufs_ord-doc-rcv) .
  run cus/lkp-rcv.w ( parParentProc,  input-output ll-rec ) .
  reposition {&BROWSE-NAME} to recid ll-rec no-error.
  apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
end.

 if br-rcv-handle = ? then reposition {&BROWSE-NAME} to recid ll-rec no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
define variable g#log as logical   no-undo .
  run local-mark no-error .
  if error-status :error  then return .
  g#log = {&browse-name}:select-next-row ().
  apply "entry" to {&browse-name} in frame {&frame-name}.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-open
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-open Dialog-Frame
ON CHOOSE OF b-open IN FRAME Dialog-Frame /* Открыть */
DO:
  if buf_ord-doc.doc-type = {&o-o} then return.

  if available bufs_ord-doc-rcv then do:
       find current bufs_ord-doc-rcv exclusive-lock no-error.
            if avail bufs_ord-doc-rcv then do:
               message "Открыть поставку "  bufs_ord-doc-rcv.rcv-code "?" view-as alert-box
                        question buttons yes-no title "Вопрос" update v-glog.
                    if v-glog then do:
                       ll-rec = recid(bufs_ord-doc-rcv) .
                          case bufs_ord-doc-rcv.status_:
                          when {&g___new} then do:
                             message "Поставка "  bufs_ord-doc-rcv.rcv-code " Уже открыта до НОВЫЙ" view-as alert-box .
                          end.
                          when {&ord-rcv} then do:
                            Assign
                              bufs_ord-doc-rcv.status_   = {&g___new}
                              .
                          end.
                          when {&fact} then do:
                            Assign
                              bufs_ord-doc-rcv.fact-date = ?
                              bufs_ord-doc-rcv.status_   = {&ord-rcv}
                              .
                            end.
                          end case.

                    {&OPEN-QUERY-{&BROWSE-NAME}}
                     reposition {&BROWSE-NAME} to recid ll-rec no-error .
                     apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
                    end.
            end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sch Dialog-Frame
ON CHOOSE OF b-sch IN FRAME Dialog-Frame /* Фильтр */
DO:

  run proc-b-sch no-error.
  if error-status:error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-docs
&Scoped-define SELF-NAME br-docs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON ANY-PRINTABLE OF br-docs IN FRAME Dialog-Frame
DO:
  apply "entry" to sch-code in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON ROW-DISPLAY OF br-docs IN FRAME Dialog-Frame
DO:
define variable v-str as character no-undo .
define variable v-loc-color as integer no-undo .

    assign
v-str = status-edoc-edi-light(buffer buf_ord-doc, input is-edoc-nn, input is-edi, output v-loc-color)
no-error.

if error-status:error then do:
    assign
  v-status-edi:fgcolor in browse BR-DOCS = ?
    .
end.
else do:
  assign
  v-status-edi:fgcolor in browse BR-DOCS = v-loc-color
  .
end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-docs Dialog-Frame
ON VALUE-CHANGED OF br-docs IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-browse-34}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_mobilscn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_mobilscn Dialog-Frame
ON CHOOSE OF MENU-ITEM m_mobilscn /* Экспорт в Моб.сканер */
DO:
  if not available bufs_ord-doc-rcv then return .
  run cus/z-tot2.p (input parparentproc , input "rcv" , input "" ,input   bufs_ord-doc-rcv.rcv-code ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-list-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-list-rcv Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-list-rcv /* Печать списка поставок */
DO:
  run print-list in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print-one
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print-one Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print-one /* Печать документа */
DO:
  if not available bufs_ord-doc-rcv then return .
  run cus/torg-261.p ( input parParentProc, input recid (bufs_ord-doc-rcv)) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_print_rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_print_rep Dialog-Frame
ON CHOOSE OF MENU-ITEM m_print_rep /* Отчет об исполнении поставок */
DO:
  /*  Процедура печати отчета  *** */
  run cus/g-isp-po.p ( input parParentProc ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m___Excel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m___Excel Dialog-Frame
ON CHOOSE OF MENU-ITEM m___Excel /* Экспорт в Excel */
DO:
  if not available bufs_ord-doc-rcv then return .
  run cus/z-tot3.p ( input parParentProc , input bufs_ord-doc-rcv.rcv-code , input bufs_ord-doc-rcv.doc-code ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli Dialog-Frame
ON CHOOSE OF r-cli IN FRAME Dialog-Frame /* r-cli */
DO:
define variable rid-list as character no-undo .
define buffer b#clients for ub.clients.
   run ref/cli-all.w ( parparentproc, input "b-sel", {&cmp}, ?, ?, ?, ?, ?, output  rid-list).
   find first b#clients where recid(b#clients) = integer(rid-list) no-lock no-error.
   if available  b#clients then do:
       r-cli-code = b#clients.obj-code.
       r-cli-type = b#clients.obj-type.
       r-cli-name = b#clients.obj-name.
   end.

   display
   r-cli-code
   r-cli-type
   r-cli-name
   with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-cli-code Dialog-Frame
ON LEAVE OF r-cli-code IN FRAME Dialog-Frame
OR  RETURN OF r-cli-code IN FRAME {&frame-name}
DO:
  assign
    r-cli-code
    r-cli-type
  .
  define buffer b#clients for ub.clients.
  find first b#clients no-lock  where
             b#clients.obj-code = r-cli-code and
             b#clients.obj-type = r-cli-type
             no-error.
  if available b#clients
      then r-cli-name = b#clients.obj-name .
      else r-cli-name = "" .

  display r-cli-name with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-code Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME Dialog-Frame /* № заказа */
OR  RETURN OF sch-code IN FRAME {&frame-name}
DO:
  if sch-code <> input frame {&frame-name} sch-code or sch-field <> "doc-code" then do:
      sch-num = 0.
      hide sch-num in frame {&frame-name}.
  end.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
 sch-field = "doc-code".
 assign sch-code = input frame {&frame-name} sch-code.

 find first buf_ord-doc-rcv no-lock  where
            buf_ord-doc-rcv.doc-code  begins sch-code
        and buf_ord-doc-rcv.obj-code = v-cntxt-obj-code
        and buf_ord-doc-rcv.obj-type = v-cntxt-obj-type
        and buf_ord-doc-rcv.host-code = p-host-code
        and ( p-g#type = ? or  ( buf_ord-doc-rcv.doc-type = p-g#type))
        no-error .
        if available buf_ord-doc-rcv then doc-rec = recid (buf_ord-doc-rcv) .
                                     else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
      reposition {&browse-name} to recid doc-rec no-error.
      apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  end.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME Dialog-Frame /* Дата док-та */
OR  RETURN OF sch-date IN FRAME {&frame-name}
DO:
  if sch-date <> input frame {&frame-name} sch-date or sch-field <> "doc-date" then do:
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
 sch-field = "doc-date".
 assign sch-date = input frame {&frame-name} sch-date.
 find first ub.ord-doc-rcv no-lock  where ub.ord-doc-rcv.doc-date  = sch-date no-error .
        if available ub.ord-doc-rcv then doc-rec = recid(ub.ord-doc-rcv) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
      reposition br-docs to recid doc-rec no-error.
      apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  end.

return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-date-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-date-rcv Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-date-rcv IN FRAME Dialog-Frame /* Дата факт */
OR  RETURN OF sch-date-rcv IN FRAME {&frame-name}
DO:
  if sch-date-rcv <> input frame {&frame-name} sch-date-rcv or sch-field <> "rcv-date" then do:
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
 sch-field = "rcv-date".
 assign sch-date-rcv = input frame {&frame-name} sch-date-rcv.
 find first ub.ord-doc-rcv no-lock  where ub.ord-doc-rcv.fact-date  = sch-date-rcv no-error .
        if available ub.ord-doc-rcv then doc-rec = recid( ub.ord-doc-rcv) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
      reposition br-docs to recid doc-rec no-error.
      apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  end.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-rcv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-rcv Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-rcv IN FRAME Dialog-Frame /* № пост-ки */
OR  RETURN OF sch-rcv IN FRAME {&frame-name}
DO:
  if sch-rcv <> input frame {&frame-name} sch-code or sch-field <> "rcv-code" then do:
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
 sch-field = "rcv-code".
 assign sch-rcv = input frame {&frame-name} sch-rcv.

 find first ub.ord-doc-rcv no-lock where ub.ord-doc-rcv.rcv-code  begins sch-rcv no-error .
        if available ord-doc-rcv then doc-rec = recid(ub.ord-doc-rcv) .
            else doc-rec = ? .
  if doc-rec = ? then message "Документ не найден !"  .
  else do:
    reposition br-docs to recid doc-rec no-error.
    apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
  end.
return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME sch-ship-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL sch-ship-2 Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF sch-ship-2 IN FRAME Dialog-Frame /* по */
DO:
/**/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
{ gbl/ed_date.i sch-date}
{ gbl/ed_date.i sch-date-rcv}
{ gbl/ed_date.i sch-ship}
{ gbl/ed_date.i sch-ship-2}
{ gbl/brwrefre.i "run OpenBr in this-procedure . " }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON stop    UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  b-exec:POPUP-MENU IN FRAME {&frame-name} = MENU m-exec:HANDLE.
  b-exec:MENU-MOUSE = 1.
  b-export:POPUP-MENU IN FRAME {&frame-name} = MENU m-export:HANDLE.
  b-export:MENU-MOUSE = 1.
  b-rep:POPUP-MENU IN FRAME {&frame-name} = MENU m-rep:HANDLE.
  b-rep:MENU-MOUSE = 1.
  b-print:POPUP-MENU IN FRAME {&frame-name} = MENU m-print:HANDLE.
  b-print:MENU-MOUSE = 1.

if lookup (list-mode , "without-fo,whith-fo,firm-fin" ) > 0  then do:
    ASSIGN
      MENU-ITEM m_lkp-fo :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-1 :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-2 :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-3 :SENSITIVE IN MENU m-exec = true
      MENU-ITEM m_gen-4 :SENSITIVE IN MENU m-exec = true
      .
end.
else do:
    ASSIGN
      MENU-ITEM m_lkp-fo :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-1  :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-2  :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-3  :SENSITIVE IN MENU m-exec =  false
      MENU-ITEM m_gen-4  :SENSITIVE IN MENU m-exec =  false
      .
end.
  { gbl/conf-rd.i "'is-edi'" "''" "''" 0 "''" "''" "''" yes par-is-edi par-type }
  { gbl/conf-rd.i "'edoc-nn'" "''" "''" 0 "''" "''" "''" no par-is-edoc-nn par-type no-error }

assign
is-edi = lookup(par-is-edi, "true,yes":U) > 0
.
assign
is-edoc-nn = lookup(par-is-edoc-nn, "true,yes":U) > 0
.
if not (is-edi and is-edoc-nn) then do:
    v-status-edi:VISIBLE IN BROWSE {&browse-name} = FALSE.
    v-status-trn-edi:VISIBLE IN BROWSE browse-34 = FALSE.
end.
  RUN enable_UI.
  RUN init-p.
  run OpenBr in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/

  {&OPEN-QUERY-Dialog-Frame}
  GET FIRST Dialog-Frame.
  DISPLAY r-cli-type r-cli-code sch-date-rcv sch-rcv sch-ship sch-ship-2
          sch-code sch-date FILL-IN-1 r-cli-name
      WITH FRAME Dialog-Frame.
  ENABLE b-quit RECT-1 b-sel b-rep b-sch b-close b-exec b-print b-history
         b-help b-mark b-chg b-lkp b-del b-export r-cli-type r-cli-code r-cli
         sch-date-rcv sch-rcv b-excecF sch-ship sch-ship-2 sch-code sch-date
         br-docs BROWSE-34 FILL-IN-1 r-cli-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-p Dialog-Frame
PROCEDURE init-p :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/



if list-mode = "firm":U  then
    assign
      sss = "ПОСТАВКИ под заказ   ФИРМА: " + p-g#host-name .
    else
    assign
      sss = "ПОСТАВКИ под заказ   ОБЪЕКТ: " + store-type + " " + string(store-code) .


if list-mode = "with-fo":U then do:
  sss = "ПОСТАВКИ под заказ  --  Есть ФО  --  ФИРМА: " + p-g#host-name .
  disable b-close b-chg b-del with frame {&frame-name} .
end.
if list-mode = "without-fo":U then do:
  sss = "ПОСТАВКИ под заказ  --  Нет ФО  --  ФИРМА: " + p-g#host-name .
  disable b-close b-chg b-del with frame {&frame-name} .
end.

if list-mode = "firm-fin":U then do:
  sss = "ПОСТАВКИ под заказ  ФИРМА: " + p-g#host-name .
  disable b-close b-chg b-del with frame {&frame-name} .
end.


if list-mode = "cli":U then do:
    assign
      sss = "ПОСТАВКИ под заказ   ПОСТАВЩИК: " + store-type + " " + string(store-code) .
  disable b-close with frame {&frame-name} .
end.


case p-g#type :
  when "in" then sss = sss + " , Тип: Внутренние".
  when "out" then  sss = sss + " , Тип: Внешние".
end case.

case p-g#stat :
  when {&g___new} then sss = sss + " , Статус: " +  p-g#stat.
  when {&ord-rcv} then sss = sss + " , Статус: " +  p-g#stat.
  when {&fact} then  sss = sss + " , Статус: " +  p-g#stat.
end case.

if p-g#cons-code <> ? then  sss = sss + " , СЗФП № " +  p-g#cons-code.

frame {&frame-name}:title = sss.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error return-value
 :
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
title0 = "Поставки ".
run waitfram-show("Ждите...").
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-open-query   OPEN QUERY br-docs FOR EACH bufs_ord-doc-rcv NO-LOCK

&scop flt-open-dyn_open-query  FOR EACH bufs_ord-doc-rcv

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name bufs_ord-doc-rcv


&scop flt-open-open-query-tail     , ~
       EACH buf_ord-doc WHERE bufs_ord-doc-rcv.doc-code = buf_ord-doc.doc-code OUTER-JOIN NO-LOCK

&scop flt-open-query-was-opened    l-query-was-opened

&scop flt-open-sort-column-phrase  sort-column-phrase

&scop flt-open-call-point          filter-point

&scop flt-open-set-filter-name     set-filter-name

&scop flt-open-indexed-reposition

&SCOP flt-open-debug-file

do:

case list-mode :
when 'obj':U then do:
     { gbl/fltopend.i
&where-cond = " bufs_ord-doc-rcv.obj-code = store-code ~
  and bufs_ord-doc-rcv.obj-type = store-type ~
  and bufs_ord-doc-rcv.host-code = p-host-code ~
  and ( p-g#cons-code = ?                            ~
  or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code )) ~
  and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type )) ~
  and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  )) ~
  and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) ~
  and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ~
  "

&dyn_where-cond = " substitute('
  bufs_ord-doc-rcv.obj-code = &3 and
  bufs_ord-doc-rcv.obj-type = &1&4&1
      and bufs_ord-doc-rcv.host-code = &5
      and ( &1&6&1 = &1?&1
      or  ( bufs_ord-doc-rcv.cons-code = &1&6&1 ))
      and ( &1&7&1 = &1?&1 or  ( bufs_ord-doc-rcv.doc-type = &1&7&1 ))
      and ( &1&8&1 = &1?&1 or  ( bufs_ord-doc-rcv.status_ = &1&8&1  )) '
          , ~{&double-quote~}
          , list-mode
          , store-code
          , store-type
          , p-host-code
          , p-g#cons-code
          , p-g#type
          , p-g#stat ) +
        substitute(' and (&2 = no or ( bufs_ord-doc-rcv.ship-date >= &4 and bufs_ord-doc-rcv.ship-date <= &5 ))
                     and (&3 = no or ( bufs_ord-doc-rcv.cli-code = &6 and bufs_ord-doc-rcv.cli-type = &1&7&1 ))'
          , ~{&double-quote~}
          , hard-flt-date
          , hard-flt-cli
          , string(sch-ship,'99/99/9999')
          , string(sch-ship-2,'99/99/9999')
          , r-cli-code
          , r-cli-type
           )"

&use-ind    = "  "
&by         = "  " }
end.
when 'cli':U  then do:
     { gbl/fltopend.i
&where-cond = " bufs_ord-doc-rcv.cli-code = store-code ~
  and bufs_ord-doc-rcv.cli-type = store-type       ~
  and bufs_ord-doc-rcv.host-code = p-host-code     ~
  and ( p-g#cons-code = ?                          ~
  or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code )) ~
  and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type )) ~
  and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  )) ~
  and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) ~
  and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ~
  "

&dyn_where-cond = " substitute('
    bufs_ord-doc-rcv.cli-code = &3 and
    bufs_ord-doc-rcv.cli-type = &1&4&1 and
    bufs_ord-doc-rcv.host-code = &5
      and ( &1&6&1 = &1?&1
      or  ( bufs_ord-doc-rcv.cons-code = &1&6&1 ))
      and ( &1&7&1 = &1?&1 or  ( bufs_ord-doc-rcv.doc-type = &1&7&1 ))
      and ( &1&8&1 = &1?&1 or  ( bufs_ord-doc-rcv.status_ = &1&8&1  )) '
          , ~{&double-quote~}
          , list-mode
          , store-code
          , store-type
          , p-host-code
          , p-g#cons-code
          , p-g#type
          , p-g#stat )  +
         substitute(' and (&2 = no or ( bufs_ord-doc-rcv.ship-date >= &4 and bufs_ord-doc-rcv.ship-date <= &5 ))
                     and (&3 = no or ( bufs_ord-doc-rcv.cli-code = &6 and bufs_ord-doc-rcv.cli-type = &1&7&1 ))'
          , ~{&double-quote~}
          , hard-flt-date
          , hard-flt-cli
          , string(sch-ship,'99/99/9999')
          , string(sch-ship-2,'99/99/9999')
          , r-cli-code
          , r-cli-type
           )"

  &use-ind    = "  "
  &by         = "  " }
end.

otherwise do:
     { gbl/fltopend.i
&where-cond = " bufs_ord-doc-rcv.host-code = p-host-code     ~
  and ( p-g#cons-code = ?                          ~
  or  ( bufs_ord-doc-rcv.cons-code = p-g#cons-code )) ~
  and ( p-g#type = ? or  ( bufs_ord-doc-rcv.doc-type = p-g#type )) ~
  and ( p-g#stat = ? or  ( bufs_ord-doc-rcv.status_ = p-g#stat  )) ~
  and (hard-flt-date = no or ( bufs_ord-doc-rcv.ship-date >= sch-ship and bufs_ord-doc-rcv.ship-date <= sch-ship-2 )) ~
  and (hard-flt-cli  = no or ( bufs_ord-doc-rcv.cli-code = r-cli-code and bufs_ord-doc-rcv.cli-type = r-cli-type)) ~
  "

&dyn_where-cond = "substitute(' ~
            bufs_ord-doc-rcv.host-code = &2 ~
      and ( &1&3&1 = &1?&1  or  ( bufs_ord-doc-rcv.cons-code = &1&3&1 )) ~
      and ( &1&4&1 = &1?&1 or  ( bufs_ord-doc-rcv.doc-type = &1&4&1 )) ~
      and ( &1&5&1 = &1?&1 or  ( bufs_ord-doc-rcv.status_  = &1&5&1  )) '    ~
          , ~{&double-quote~}                          ~
          , p-host-code                                 ~
          , p-g#cons-code                               ~
          , p-g#type                                    ~
          , p-g#stat )  ~
          +             ~
        substitute(' and (&2 = no or ( bufs_ord-doc-rcv.ship-date >= &4 and bufs_ord-doc-rcv.ship-date <= &5 ))  ~
                     and (&3 = no or ( bufs_ord-doc-rcv.cli-code = &6 and bufs_ord-doc-rcv.cli-type = &1&7&1 ))'  ~
          , ~{&double-quote~}                                                                                   ~
          , hard-flt-date                                                                                       ~
          , hard-flt-cli                                                                                        ~
          , string(sch-ship,'99/99/9999')                                                                       ~
          , string(sch-ship-2,'99/99/9999')                                                                     ~
          , r-cli-code                                                                                          ~
          , r-cli-type                                                                                          ~
          ) "

  &use-ind    = "  "
  &by         = "  " }
end.
end case.

end.
filter-point =  "Поставки " .
run waitfram-hide.
apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.

  end.  /* do */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-list Dialog-Frame
PROCEDURE print-list :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-kol   as integer   no-undo .
define variable v-i-sum as decimal   no-undo .
define variable v-d as decimal   no-undo .
v-kol   = 0 .
v-i-sum = 0 .
v-d = 0 .

define variable sym1  as char format "X(1)" init ":".
define variable sym2  as char format "X(1)" init ":".
define variable sym3  as char format "X(1)" init ":".
define variable sym4  as char format "X(1)" init ":".
define variable sym5  as char format "X(1)" init ":".
define variable sym6  as char format "X(1)" init ":".
define variable sym7  as char format "X(1)" init ":".
define variable sym8  as char format "X(1)" init ":".
define variable sym9  as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable sym11 as char format "X(1)" init ":".
define variable sym12 as char format "X(1)" init ":".

define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable vv-val as character no-undo .
define variable v-i as integer   no-undo .
define variable p-delta as decimal format "->,>>>,>>>,>>>,>>9.99"  no-undo .

DEFINE FRAME prt-frame
bufs_ord-doc-rcv.doc-type  COLUMN-LABEL "Тип" FORMAT "x(5)"
bufs_ord-doc-rcv.status_   COLUMN-LABEL "Статус"
bufs_ord-doc-rcv.rcv-code  COLUMN-LABEL "Номер"
prt-out-cli-code COLUMN-LABEL "№по пост-ку" FORMAT "x(14)"
bufs_ord-doc-rcv.doc-date FORMAT "99/99/99"
bufs_ord-doc-rcv.fact-date FORMAT "99/99/99"
prt-cli-name   COLUMN-LABEL "Поставщик" FORMAT "x(15)"
prt-sum-rubl  COLUMN-LABEL "Сумма поставки" FORMAT ">>>>>>>>>>>>9.99"
bufs_ord-doc-rcv.ship-date COLUMN-LABEL "Доставка" FORMAT "99/99/99"
bufs_ord-doc-rcv.ship-time COLUMN-LABEL "Время"
bufs_ord-doc-rcv.fact-ship-time COLUMN-LABEL "Факт"
bufs_ord-doc-rcv.obj-type
bufs_ord-doc-rcv.obj-code COLUMN-LABEL "Объект"
bufs_ord-doc-rcv.cli-type
bufs_ord-doc-rcv.cli-code COLUMN-LABEL "Контрагент"
bufs_ord-doc-rcv.doc-code COLUMN-LABEL "Заказ"
v-fo column-label "ФО" format "x(11)"
        HEADER  date_string AT 5 format "X(35)"
                    string( "Страница " ) format "X(9)" AT 50 PAGE-NUMBER( PrnLibStream) AT 70 FORMAT ">>>>9" SKIP
                    Line format "X(157)" AT 1
    with width {&DOS_CW_2} down stream-io use-text    .

    Line = fill("-", 157).
    date_string = cur-time-print() .
    run prn-lib-open-stream in this-procedure
    (  input parParentProc
      ,input {&LS_PS_A4}
      ,input yes /*p-is-stream*/
      ,input no /*p-append*/
      ).
    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(157)" SKIP(1) .
    FORM HEADER
            Line format "X(177)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME prt-frame  .
    run waitfram-show in this-procedure ("Ждите печатаю...").

    run OpenBR in this-procedure .
     DO WHILE available bufs_ord-doc-rcv :
       v-kol    = v-kol   + 1 .

        Display STREAM PrnLibStream

            if bufs_ord-doc-rcv.doc-type = 'out' then 'внешн' else 'внутр'  @ bufs_ord-doc-rcv.doc-type
            bufs_ord-doc-rcv.status_
            bufs_ord-doc-rcv.rcv-code
            cli-doc-out (buffer bufs_ord-doc-rcv) @ prt-out-cli-code
            bufs_ord-doc-rcv.doc-date
            bufs_ord-doc-rcv.fact-date
            cli-name (buffer bufs_ord-doc-rcv) @ prt-cli-name
            sum-rubl (buffer bufs_ord-doc-rcv) @ prt-sum-rubl
            bufs_ord-doc-rcv.ship-date
            bufs_ord-doc-rcv.obj-type
            bufs_ord-doc-rcv.obj-code
            bufs_ord-doc-rcv.cli-type
            bufs_ord-doc-rcv.cli-code
            f-fo ( buffer bufs_ord-doc-rcv ) @ v-fo
            string(bufs_ord-doc-rcv.ship-time,'hh:mm') @ bufs_ord-doc-rcv.ship-time
            string(bufs_ord-doc-rcv.fact-ship-time,'hh:mm')  @ bufs_ord-doc-rcv.fact-ship-time
            bufs_ord-doc-rcv.doc-code
            with FRAME prt-frame .
         DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .
         GET next br-docs.
      END.
      underline  stream PrnLibStream
        bufs_ord-doc-rcv.doc-type
        bufs_ord-doc-rcv.status_
        bufs_ord-doc-rcv.rcv-code
      with FRAME prt-frame .


    if v-kol > 1 then do:
      Display STREAM PrnLibStream
      "Итого"    @    bufs_ord-doc-rcv.doc-type
      "док.шт."  @    bufs_ord-doc-rcv.status_
        v-kol    @    bufs_ord-doc-rcv.rcv-code
      with FRAME prt-frame .
    end.
     DOWN STREAM PrnLibStream 1 with FRAME prt-frame  .

    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
    run prn-lib-prn-file in this-procedure (
        input parParentProc
       ,input 8
        ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-sch Dialog-Frame
PROCEDURE proc-b-sch :
assign
  tbl = 'ord-doc-rcv'
  join-tbl = 'bufs_ord-doc-rcv'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .

run fltfield-add in this-procedure('rcv-code', 'Номер поставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-code', 'Номер заказа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('cons-code', 'Номер СЗФП', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure('doc-date', 'Дата документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-date', 'Дата закрытия документа', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('ship-date', 'Дата доставки', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure ('cli-type{&delim-flt}cli-code', 'Поставщик', 'cli',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('fact-ship-time', 'Фактическое время доставки', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.



/*'order-status-all*/
run fltfield-add in this-procedure('status_', 'Статус', 'order-status-all',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('doc-type', 'Тип', 'rcv-type-all',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


run fltfield-add in this-procedure('PS', 'Комментарий', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

run fltfield-add in this-procedure('creid', 'Опер-р', 'usr',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('user-name', 'Правил', 'usr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('exch-code', 'Валюта','curr',input-output fld, input-output lab, input-output spr, input-output dim)  no-error.


  Filter-Block:
  DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
     ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
     ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
    run gbl/filter.w ( INPUT parParentProc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
    RUN OpenBr.
  END. /* Filter-Block */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-m_gen-1 Dialog-Frame
PROCEDURE proc-m_gen-1 :
do
  on error undo, return error return-value
  :
    if num-entries(del-list) = 0 then do:
      message "Не выделено ни одной поставки для генерации ФО !".
      return error .
    end.

    run str/gen-fl.w (
        input parparentproc,
        input p-host-code,
        input del-list,
        input "rcv"
        ) .


    assign del-list = "" .
    /*run UI-on (yes, no, '':U) .*/
    RUN OpenBr.
  end.

end procedure. /*  proc-m_gen-1 */

PROCEDURE proc-m_gen-2 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define buffer bf_ord-doc-rcv for ub.ord-doc-rcv.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.

do on error undo, return error return-value
:
    if del-list = "" then do:
      if available bufs_ord-doc-rcv then assign del-list = string(recid(bufs_ord-doc-rcv)).
    end.

define variable v-num-entries-del-list as integer no-undo .
v-num-entries-del-list = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-num-entries-del-list :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc-rcv where recid(bf_ord-doc-rcv) = v-doc-code exclusive-lock.
    find first bf_ord-doc where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code no-lock .
    if bf_ord-doc-rcv.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc-rcv.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
      message "Главная БД для фирмы по документу с кодом " bf_ord-doc-rcv.rcv-code " не является текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
      view-as alert-box error.
      next v-i-cycle.
    end.
    if bf_ord-doc-rcv.cr-fo = yes then do:
      message "По документу " bf_ord-doc-rcv.rcv-code " уже создавался ФО от " bf_ord-doc-rcv.fo-date " числа." view-as alert-box.
      next v-i-cycle.
    end.
    else do:
      if bf_ord-doc-rcv.need-fo = 1 or bf_ord-doc-rcv.need-fo = 2 then assign  bf_ord-doc-rcv.need-fo = 0.
      else do:
        message "Данный документ не нуждался в генерации ФО." view-as alert-box.
        next v-i-cycle.
      end.
      reposition {&browse-name} to recid recid(bf_ord-doc-rcv) no-error.
      if not error-status:error then do:
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
        display f-fo (buffer bf_ord-doc-rcv) @ v-fo with browse {&browse-name}.
      end.
    end.
  end.
  assign del-list = "".
end.
end procedure.


PROCEDURE proc-m_gen-3 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc for ub.ord-doc.
define buffer bf_ord-doc-rcv for ub.ord-doc-rcv.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-log as logical   no-undo .

do on error undo, return error return-value
:
  if del-list = "" then do:
    if available bufs_ord-doc-rcv then assign del-list = string(recid(bufs_ord-doc-rcv)).
  end.

define variable v-nn as integer   no-undo .
v-nn = num-entries (del-list) .
v-i-cycle:
  do v-i = 1 to v-nn :
    assign v-doc-code = integer(entry (v-i, del-list)).
    find first bf_ord-doc-rcv where recid(bf_ord-doc-rcv) = v-doc-code exclusive-lock.
    find first bf_ord-doc where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code no-lock.
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc-rcv.status_ " не в статусе " {&fact} " . Пропускаем." view-as alert-box.
      next v-i-cycle.
    end.
    if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
      message "Главная БД для фирмы по документу с кодом " bf_ord-doc-rcv.rcv-code " не является текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip   "Главная БД фирмы: " bf_sysconf.firm-db-num
      view-as alert-box error.
      next v-i-cycle.
    end.
    if bf_ord-doc-rcv.cr-fo = yes then do:
      assign
        v-log = no.
        message "По документу " bf_ord-doc-rcv.rcv-code " был создан ФО от " bf_ord-doc-rcv.fo-date " ." skip
                "Вы действительно хотите снять признак, чтобы по этому документу был ФО?"
        view-as alert-box question buttons yes-no update v-log.
       if v-log <> yes then  next v-i-cycle.
       assign
         bf_ord-doc-rcv.cr-fo   = no
         bf_ord-doc-rcv.fo-date = 01/01/1990
       .
       reposition {&browse-name} to recid recid(bf_ord-doc-rcv) no-error.
      if not error-status:error then do:
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
        display f-fo (buffer bf_ord-doc-rcv) @ v-fo with browse {&browse-name}.
      end.
    end.
    else do:
      message "По документу " bf_ord-doc-rcv.rcv-code " не было генерации."
      view-as alert-box.
   end.
 end.
 assign del-list = "".
end.
end procedure.

PROCEDURE proc-m_gen-4 :
define buffer bf_sysconf for ub.sysconf.
define buffer bf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer bf_ord-doc for ub.ord-doc.
define variable v-i as integer no-undo.
define variable v-doc-code as integer no-undo.
define variable v-need-fo as logical no-undo.
define buffer bf_contract for ub.contract.

do on error undo, return error return-value
:
  if del-list = "" then do:
    if available bufs_ord-doc-rcv then assign del-list = string(recid(bufs_ord-doc-rcv)).
  end.

define variable  v-nn as integer   no-undo .
v-nn = num-entries (del-list) .

v-i-cycle:
  do v-i = 1 to v-nn:
    assign v-doc-code = integer(entry (v-i, del-list)) .
    find first bf_ord-doc-rcv where recid(bf_ord-doc-rcv) = v-doc-code exclusive-lock.
    find first bf_ord-doc where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code no-lock .
    find first bf_sysconf where bf_sysconf.host-code = bf_ord-doc.host-code no-lock.
    if bf_ord-doc.status_ <> {&fact} then do:
      message "Документ " bf_ord-doc.status_ " не в статусе " {&fact} " . Пропускаем."  view-as alert-box.
      next.
    end.
    if bf_sysconf.firm-db-num <> v-cntxt-db-num then do:
      message "Главная БД для фирмы по документу с кодом " bf_ord-doc.doc-code " не является текущей БД." skip
              "Текущая БД: " v-cntxt-db-num skip "Главная БД фирмы: " bf_sysconf.firm-db-num
      view-as alert-box error.
      return error.
    end.
    if bf_ord-doc-rcv.need-FO = 2 then do:
      if bf_ord-doc-rcv.contract-code <> 0 then do:
        find first bf_contract where bf_contract.host-code     = bf_ord-doc.host-code   and
                                     bf_contract.contract-code = bf_ord-doc.contract-code no-lock no-error.
        if available bf_contract then do:
          if /* bf_contract.usl-opl = по поставке  или по поставке с отсрочкой  */ true  then do:
            assign bf_ord-doc-rcv.need-FO = 1  .
            reposition {&browse-name} to recid recid(bf_ord-doc-rcv) no-error.
            if not error-status:error then do:
              apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
              display f-FO (buffer bf_ord-doc-rcv) @ v-FO with browse {&browse-name}.
            end.
          end.
          else message "По документу " bf_ord-doc-rcv.rcv-code " нет договоров для генерации ФО."  view-as alert-box.
        end.
      end.
    end.
    else do:
      message "Документ " bf_ord-doc-rcv.rcv-code "не имеет признака 'не опред' генерация ФО."
      view-as alert-box.
      next v-i-cycle.
    end.
  end.
  assign del-list = "" .
end.
end procedure.

procedure proc-m_lkp-fo :
  do
  on error undo, return error return-value
  :
  if available bufs_ord-doc-rcv then do:
    run str/fi-trns.w (
        input parparentproc,
        input bufs_ord-doc-rcv.host-code,
        input ?              ,
        input bufs_ord-doc-rcv.rcv-code ,
        input "rcv":U
        ) .
    end.

  end.

end procedure. /* proc-m_lkp-fo */

PROCEDURE local-mark:
  if not available bufs_ord-doc-rcv then do:
    message "Неправильный выбор строки.".
    return error.
  end.

  { gbl/markstrn.i bufs_ord-doc-rcv del-list }
  if lookup(string( recid(bufs_ord-doc-rcv) ), del-list ) > 0
      then disp "*"  @ mark with browse  {&browse-name}.
      else disp "" @ mark with browse  {&browse-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title = sss + "   ФИЛЬТР: " + p-filter-name
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
        frame {&frame-name}:title = sss
      .
    end.

  end. /* do with frame */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-selection Dialog-Frame
PROCEDURE set-selection :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
assign frame {&frame-name}
sch-ship sch-ship-2  r-cli-type r-cli-code
.
hard-flt-date = false  .
hard-flt-cli  = false  .

if not( sch-ship = ? and sch-ship-2 = ? ) then do:
    if sch-ship = ? then sch-ship = 01/01/1900 .
    if sch-ship-2 = ? then sch-ship-2 = 01/01/2100 .
    if sch-ship > sch-ship-2 then do:
      message 'Не верно задан интервал дат для поиска поставок' view-as alert-box information .
      return error .
    end.
    hard-flt-date = true  .
end.

if r-cli-code <> 0 and r-cli-code <> ? then do:
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where
           buf_clients.obj-type = r-cli-type and
           buf_clients.obj-code = r-cli-code no-error .
  if not available buf_clients then do:
      message 'Не верно задан Поставщик для поиска поставок' view-as alert-box information .
      return error .
  end.
  hard-flt-cli  = true .
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION f-fo Dialog-Frame
FUNCTION f-fo RETURNS CHARACTER
  ( buffer loc-t-doc for ub.ord-doc-rcv ) :
 if loc-t-doc.cr-fo = yes then do:
   return string (loc-t-doc.fo-date, "99/99/99").
 end.
 else do:
   if loc-t-doc.need-fo = 0 then do:
     return "--------".
   end.
   if loc-t-doc.need-fo = 1 then do:
     return "".
   end.
   if loc-t-doc.need-fo = 2 then do:
     return "не опред".
   end.
 end.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION status-edi-trn Dialog-Frame
FUNCTION status-edi-trn RETURNS CHARACTER
  ( buffer loc-t-doc for buf_trn-doc ) :

define variable v-status as character no-undo .
define variable p-type     as character no-undo .

     if available loc-t-doc then do:
      { str/tdat-val.i
          loc-t-doc.doc-code
          {&trdcattr-edi}
          v-status
          p-type
          no-error
      }
&SCOPED-DEFINE order-stts-int1 v-status
      if v-status = "" or v-status = "0"  or v-status = ?  then return "" .
      else
         return  {&edi-stts-name}   .
    end.
  RETURN "".   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
