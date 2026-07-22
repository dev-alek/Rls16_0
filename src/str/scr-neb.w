&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран по сравнению количеств по бар-кодам

Автор: Чернова Светлана Александровна
Дата создания: 12/22/06
Author: Svetlana Chernova
Creation date: 12/22/06

create: Суслов Алексей Юрьевич
Дата создания: 09/08/05


*/

/* ***************************  Definitions  ************************** */
{ str/scr-neb.i }
define input parameter parparentproc as handle no-undo.
define input-output parameter table for tt-bar-code-ne.
define input parameter parfile-name as character no-undo.
define input parameter paradd-qnty  as logical   no-undo.
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/prn-lib.i  }
{ str/fact-bc.i  &onlycheck=yes}
{ ref/gds-attr.i }
{ gbl/waitfram.i }
define variable g#report-num as integer   no-undo .
run get-report-num in parparentproc (output g#report-num ).

&global-define  BarCode_Length               10
&global-define  DOS_CW                    235
&global-define  DOS_CW_2                232     /* реально на формате А3 умещается 233
                                                                           condenced-символа */
&global-define  A4_CW0                     136     /* формат A4 */

&global-define  A4_CW                       160
&global-define  CS_PS                   62    /*Current Stream Page Size ( in lines) */
&global-define  CP_PS                   63    /*Current Printer Page Size ( in lines) = CS_PS + 1*/
&global-define  LS_PS_A4                43    /*Current Printer Page Size ( in lines) */
&global-define  HP_PS-7                 100
&global-define  DF_Name                 "rpt"
&global-define  PLT_Name               "plt"        /* Price List Title */
&global-define  OEMF_Name           "oem"
&global-define  OEMF_Ext                ".txt"
&global-define  Types_RepDocs   {&as-is}
&global-define  MaxCashNum              10000   /* макс. номер кассы */
&global-define  MaxSalemanNum        10000   /* макс. номер продавца */
&global-define  ZapUpBound              9999999
&global-define  ZapDownBound                    1
&global-define  TmpHelpMess     {&excuse-help-is-not-realized}
&global-define  MyWaitMess          {&wait2}
&global-define  Max_ColumnAmount      14
&global-define  Total_Width                  136
&global-define  TotalNames_Width                  28
&global-define  NameField_Width                   33
&global-define  ArticField_Width                      18
&global-define  LastSignField_Width               10 /* длина поля рассчитана с учетом ": " */
&global-define  Max_ColumnWeight                20
&global-define  Min_ColumnWeight                    7
&global-define  RowAmount_ColumnWeight       8 /* длина поля рассчитана с учетом ": " */
define variable PrintCopiesCounter  as integer  INIT 1 no-undo.   /* кол-во печатаемых                                                        экземпляров документа */
define variable RepPathName     as      character         no-undo.
define variable LifeStartDate     as      character         no-undo.
define variable PrintRubl     as      logical         no-undo.
define variable type-par as char no-undo.
define variable tmp-var as character no-undo.
define variable FullGdsName as log no-undo.
define variable XL-delim as character no-undo.
define variable trim-artic-ch as character no-undo.
define variable in-cur-rate as log no-undo.
define variable Line       as   char    no-undo.
{ cmp/breakstr.i  }
{ gbl/color.i }

/* Parameters Definitions ---                                           */

/*

*/
/* Local Variable Definitions ---                                       */
define variable varqnty as decimal no-undo.
define stream str-f.
define stream str-g.
define stream str-fg.
define variable par-type as character no-undo.
{ str/libbcrcn.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-bar-code-ne

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 tt-bar-code-ne.mark tt-bar-code-ne.b-c tt-bar-code-ne.artic tt-bar-code-ne.scn-qnty-file tt-bar-code-ne.scn-qnty-doc (tt-bar-code-ne.scn-qnty-file - tt-bar-code-ne.scn-qnty-doc) @ varqnty tt-bar-code-ne.gds-name tt-bar-code-ne.node-name tt-bar-code-ne.prod-type tt-bar-code-ne.prod-code tt-bar-code-ne.in-code tt-bar-code-ne.part-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-bar-code-ne
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY {&SELF-NAME} FOR EACH tt-bar-code-ne.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-bar-code-ne
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-bar-code-ne


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel b-re b-exp-f b-print b-help ~
BROWSE-1
&Scoped-Define DISPLAYED-OBJECTS EDITOR-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU POPUP-MENU-b-exp-f
       MENU-ITEM m_f            LABEL "f"
       MENU-ITEM m_item         LABEL ">"
       MENU-ITEM m_f2           LABEL "f>"            .


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-exp-f
     LABEL "&Экспорт"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1.

DEFINE BUTTON b-re
     LABEL "&Восстановить"
     SIZE 14 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE EDITOR-1 AS CHARACTER
     VIEW-AS EDITOR
     SIZE 96 BY 3.38
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varstr AS CHARACTER FORMAT "X(40)"
     VIEW-AS FILL-IN
     SIZE 17.5 BY .96 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-bar-code-ne SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _FREEFORM
  QUERY BROWSE-1 DISPLAY
      tt-bar-code-ne.mark         format "x(1)" label ""
tt-bar-code-ne.b-c         format "999999999" label "Бар-код"
tt-bar-code-ne.artic        label "Артикул"
tt-bar-code-ne.scn-qnty-file label "Факт кол-во"
tt-bar-code-ne.scn-qnty-doc  label "Докум. кол-во"
(tt-bar-code-ne.scn-qnty-file - tt-bar-code-ne.scn-qnty-doc) @ varqnty label "Несоответствие"
tt-bar-code-ne.gds-name     format "x(30)" label "Название товара"
tt-bar-code-ne.node-name    format "x(15)" label "Шкала"
tt-bar-code-ne.prod-type    label ""
tt-bar-code-ne.prod-code    label "Производитель"
tt-bar-code-ne.in-code      label "Накладная для партии"
tt-bar-code-ne.part-code    label "Код партии"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 15.17.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     varstr AT ROW 1 COL 43 COLON-ALIGNED NO-LABEL
     b-exit AT ROW 1 COL 1
     b-cancel AT ROW 1 COL 11
     b-re AT ROW 1 COL 21
     b-exp-f AT ROW 1 COL 35
     b-print AT ROW 1 COL 78
     b-help AT ROW 1 COL 88
     EDITOR-1 AT ROW 2.5 COL 2 NO-LABEL
     BROWSE-1 AT ROW 5.96 COL 1.88
     SPACE(0.24) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE " Сравнение количества и номенклатуры товаров по факту и по документу"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME Custom                                                    */
/* BROWSE-TAB BROWSE-1 EDITOR-1 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN 
       b-exp-f:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-b-exp-f:HANDLE.

/* SETTINGS FOR EDITOR EDITOR-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varstr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       varstr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-bar-code-ne.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /*  Сравнение количества и номенклатуры товаров по факту и по документу */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
    for each tt-bar-code-ne:
     assign tt-bar-code-ne.scn-qnty-file = tt-bar-code-ne.bef-qnty.
    end.
    apply "go" to frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:


define variable sym1  as char init ":"   no-undo.
define variable sym2  as char init ":"   no-undo.
define variable sym3  as char init ":"   no-undo.
define variable sym4  as char init ":"   no-undo.
define variable sym5  as char init ":"   no-undo.
define variable sym6  as char init ":"   no-undo.
define variable sym7  as char init ":"   no-undo.
define variable sym8  as char init ":"   no-undo.
define variable sym9  as char init ":"   no-undo.
define variable sym10 as char init ":"   no-undo.
define variable sym11 as char init ":"   no-undo.
define variable sym12 as char init ":"   no-undo.
define variable sym13 as char init ":"   no-undo.
  assign
    line = fill("-", {&A4_CW} )
  .

DEFINE FRAME doc
        sym1  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.mark         format "x(1)" label "" space(0)
        sym2  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.b-c         format "999999999" label "Бар-код" space(0)
        sym3  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.artic        label "Артикул" space(0)
        sym4  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.scn-qnty-file label "Кол-во в файле" space(0)
        sym5  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.scn-qnty-doc  label "Докум. кол-во"  space(0)
        sym6  column-label ":" format "X(1)" space(0)
        varqnty label "Несоответствие"                 space(0)
        sym7  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.gds-name     format "x(20)" label "Название товара" space(0)
        sym8  column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.node-name    format "x(15)" label "Шкала" space(0)
        sym9  column-label ":" format "X(1)" space(0) space(0)
        tt-bar-code-ne.prod-type    label "" space(0)
        sym10 column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.prod-code    label "Производитель" space(0)
        sym11 column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.in-code      label "Накладная для партии" space(0)
        sym12 column-label ":" format "X(1)" space(0)
        tt-bar-code-ne.part-code    label "Код партии" space(0)
        sym13 column-label ":" format "X(1)" space(0)
    HEADER
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) AT 5 format "X(35)"
        string( "Различия между документом и сканерным файлом") AT 50 format "X(65)"
        string( "Страница " + string( PAGE-NUMBER(PrnLibStream), ">>9") ) AT 120 format "X(13)" SKIP
        line format "X(153)"
    with width {&A4_CW} down stream-io.


if session:set-wait-state("compiler") then.


run prn-lib-open-stream in this-procedure ( input parparentproc, input {&CS_PS}, input yes, input no ).
for each tt-bar-code-ne :
if tt-bar-code-ne.scn-qnty-file = tt-bar-code-ne.scn-qnty-doc then next.
DISPLAY STREAM PrnLibStream
        sym1
        tt-bar-code-ne.mark
        sym2
        tt-bar-code-ne.b-c
        sym3
        tt-bar-code-ne.artic
        sym4
        tt-bar-code-ne.scn-qnty-file
        sym5
        tt-bar-code-ne.scn-qnty-doc
        sym6
        (tt-bar-code-ne.scn-qnty-file - tt-bar-code-ne.scn-qnty-doc) @ varqnty
        sym7
        tt-bar-code-ne.gds-name
        sym8
        tt-bar-code-ne.node-name
        sym9
        tt-bar-code-ne.prod-type
        sym10
        tt-bar-code-ne.prod-code
        sym11
        tt-bar-code-ne.in-code
        sym12
        tt-bar-code-ne.part-code
        sym13
with FRAME doc .
put stream PrnLibStream line format "x(153)".
/*DOWN STREAM PrnLibStream 1 with FRAME doc .*/
end.
output stream PrnLibStream close.

run waitfram-hide in this-procedure .

  /* вывести */
  run prn-lib-prn-file in this-procedure ( input parparentproc, input 8 ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-re
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-re Dialog-Frame
ON CHOOSE OF b-re IN FRAME Dialog-Frame /* Восстановить */
DO:
  for each tt-bar-code-ne:
     assign tt-bar-code-ne.scn-qnty-file = tt-bar-code-ne.mem-qnty.
  end.
  RUN enable_UI.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON ROW-DISPLAY OF BROWSE-1 IN FRAME Dialog-Frame
DO:
&scop rasukrashka assign ~
tt-bar-code-ne.b-c:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.artic:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.scn-qnty-file:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.scn-qnty-doc:fgcolor in browse {&browse-name} = ~{&my-color} ~
varqnty:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.gds-name:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.node-name:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.prod-type:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.prod-code:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.in-code:fgcolor in browse {&browse-name} = ~{&my-color} ~
tt-bar-code-ne.part-code:fgcolor in browse {&browse-name} = ~{&my-color} .

if tt-bar-code-ne.mark = "f" then do:
  &scop my-color red_color
  {&rasukrashka}
end.
if tt-bar-code-ne.mark = "d" then do:
  &scop my-color dark_green_color
  {&rasukrashka}
end.

if tt-bar-code-ne.mark = ">" then do:
  &scop my-color blue_color
  {&rasukrashka}
end.
if tt-bar-code-ne.mark = "<" then do:
  &scop my-color brown_color
  {&rasukrashka}
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_f
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_f Dialog-Frame
ON CHOOSE OF MENU-ITEM m_f /* f */
DO:
  output stream str-f to value(parfile-name + ".f").
  for each tt-bar-code-ne :
    if tt-bar-code-ne.mark <> "f" then next.
    put stream str-f unformatted tt-bar-code-ne.b-c ", " tt-bar-code-ne.scn-qnty-file skip.
  end.
  output stream str-f close.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_f2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_f2 Dialog-Frame
ON CHOOSE OF MENU-ITEM m_f2 /* f> */
DO:
  output stream str-fg to value(parfile-name + ".fg").
  for each tt-bar-code-ne :
    if tt-bar-code-ne.mark <> ">" and
       tt-bar-code-ne.mark <> "f" then next.
    put stream str-fg unformatted tt-bar-code-ne.b-c ", " (tt-bar-code-ne.scn-qnty-file - tt-bar-code-ne.scn-qnty-doc)  skip.
  end.
  output stream str-fg close.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_item
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_item Dialog-Frame
ON CHOOSE OF MENU-ITEM m_item /* > */
DO:
  output stream str-g to value(parfile-name + ".g").
  for each tt-bar-code-ne :
    if tt-bar-code-ne.mark <> ">" then next.
    put stream str-g unformatted tt-bar-code-ne.b-c ", " (tt-bar-code-ne.scn-qnty-file - tt-bar-code-ne.scn-qnty-doc)  skip.
  end.
  output stream str-g close.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varstr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varstr Dialog-Frame
ON return OF varstr IN FRAME Dialog-Frame
DO:
define variable varresult   as character                no-undo.
define variable vartype-bc  as character                no-undo.
define variable varweight   as decimal                  no-undo.
define buffer bf_bar-code for ub.bar-code.
define buffer bf_prod-bc  for ub.prod-bc.
define buffer bf_place    for ub.place.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define buffer bf_tt-bar-code-ne for tt-bar-code-ne.
assign frame {&frame-name} varstr.

{ str/sclspref.i }

if varstr <> "" then
do:
  run checkTypeByBarCode in this-procedure (integer(varstr), ?) no-error.
  if error-status:error then
  do:
    varstr = "".
    disp varstr with frame {&frame-name}.
    return no-apply.
  end.
end.

{ str/bc-rcnz.i
  parparentproc
  varstr
  ?
  parobj-type
  parobj-code
  yes
  no
  varscales-pref
  varpgscales-pref
  varresult
  vartype-bc
  varweight
  bf_bar-code
  bf_prod-bc
  bf_place
  no-error
}

if error-status:error then do:
  message
  "Ошибка при вызове процедуры распознования бар-кода." skip
  return-value skip
  error-status:get-message(1) skip
  error-status:get-message(2) skip
  error-status:get-message(3)
  view-as alert-box error.
  display "" @ varstr with frame {&frame-name}.
  return no-apply.
end.
if not available bf_bar-code then do:
  message "Бар-код не распознан." view-as alert-box error.
  display "" @ varstr with frame {&frame-name}.
  return no-apply.
end.
find first bf_tt-bar-code-ne where bf_tt-bar-code-ne.b-c = bf_bar-code.b-code no-error.
if not available bf_tt-bar-code-ne then do:
  message "Такого бар-кода нет в документе" view-as alert-box error.
  find first bf_goods   where bf_goods.gds-code    = bf_bar-code.gds-code  no-lock.
  find first bf_gds-prt where bf_gds-prt.node-code = bf_bar-code.node-code no-lock.
  create bf_tt-bar-code-ne.
  assign
    bf_tt-bar-code-ne.nm             = -1
    bf_tt-bar-code-ne.mark           = "f"
    bf_tt-bar-code-ne.b-c            = bf_bar-code.b-code
    bf_tt-bar-code-ne.scn-qnty-doc   = 0
    bf_tt-bar-code-ne.mem-qnty       = 0
    bf_tt-bar-code-ne.bef-qnty       = 0
    bf_tt-bar-code-ne.artic          = bf_goods.artic
    bf_tt-bar-code-ne.prod-type      = bf_goods.prod-type
    bf_tt-bar-code-ne.prod-code      = bf_goods.prod-code
    bf_tt-bar-code-ne.gds-name       = bf_goods.gds-name
    bf_tt-bar-code-ne.node-name      = (if bf_gds-prt.node-name = {&empty-scale} then "--------------------" else bf_gds-prt.node-name)
    bf_tt-bar-code-ne.part-code      = ''
    bf_tt-bar-code-ne.in-code        = ''.
  display "" @ varstr with frame {&frame-name}.
  {&open-query-browse-1}
end.
assign
   bf_tt-bar-code-ne.scn-qnty-file = bf_tt-bar-code-ne.scn-qnty-file + 1.
if bf_tt-bar-code-ne.mark <> "f" then do:
  assign
  bf_tt-bar-code-ne.mark = (if bf_tt-bar-code-ne.scn-qnty-file < bf_tt-bar-code-ne.scn-qnty-doc then "<" else (if bf_tt-bar-code-ne.scn-qnty-file > bf_tt-bar-code-ne.scn-qnty-doc then ">" else "")).
end.
reposition {&browse-name} to recid recid(bf_tt-bar-code-ne).
apply "ROW-DISPLAY" to {&browse-name} IN FRAME {&frame-name}.
display "" @ varstr with frame {&frame-name}.
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

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  assign
    editor-1 = "d  - товар присутствует только в документе" + {&new-line} +
               "f  - товар присутствует только по факту"     + {&new-line} +
               "<> - кол-во в документе не равно кол-ву по факту"  + {&new-line} +
               "?  - приведен бар-код партии или складского места".
  display editor-1 with frame {&frame-name}.
  if paradd-qnty = yes then do:
    assign varstr:sensitive = yes
                      varstr:visible     = yes.
  end.
  assign b-exp-f:MENU-MOUSE = 1.
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
  DISPLAY EDITOR-1 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-cancel b-re b-exp-f b-print b-help BROWSE-1 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

