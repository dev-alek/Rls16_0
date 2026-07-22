&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
DEFINE TEMP-TABLE x_parts NO-UNDO LIKE  ub.parts.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Связывание ФиБ серий из Excel и БД

Автор: Чернова Светлана Александровна
Дата создания: 03/04/10
Author: Svetlana Chernova
Creation date: 03/04/10

*/
/*------------------------------------------------------------------------
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define input  parameter parparentproc as widget-handle no-undo.
define input  parameter p-handle      as handle no-undo .
define output parameter table for x_parts .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Связывание ФиБ серий из Excel и БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ ref/extclass.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/fltopend.i defproc }
{ gbl/waitfram.i }
{ gbl/key-rec.i }

/* Local Variable Definitions ---                                       */

&scop excel-visable ~
  assign ~
    chexcelapplication:interactive = true ~
    chexcelapplication:screenupdating = true ~
    chexcelapplication:visible = true .

&scop excel-invisable ~
  assign ~
    chexcelapplication:interactive = false  ~
    chexcelapplication:screenupdating = false  ~
    chexcelapplication:visible = false  .
define new shared variable chexcelapplication      as com-handle no-undo .
define new shared variable chworkbook              as com-handle no-undo .
define new shared variable chworksheet             as com-handle no-undo .
define new shared variable chrange                 as com-handle no-undo .

define variable filter-point as character no-undo init "Сведение товаров ФиБ и товаров в БД" .
define variable filter-point0 as character no-undo init "Сведение товаров ФиБ и товаров в БД" .
define variable sort-column-name as character no-undo .
define variable g-log as logical   no-undo .
define variable gds-rec as recid no-undo .

define variable v-gds-code as character no-undo .
define variable v-gds-name as character no-undo .

&scop col-l1  'Фальсификат!Серия'
&scop col-l2  'Название товара!из Excel'
&scop col-l3  'Код Товара!в TH'
&scop col-l4  'Название!в TH'
&scop col-l5  '§'

&scop cop-l1      buf_ext-classif.CharKey_One
&scop cop-l2      buf_ext-classif.CharKey_Three
&scop cop-l3      f-gds-code(recid(buf_ext-classif))
&scop dyn_cop-l3  substitute('dynamic-function(&1f-gds-code&1, recid(buf_ext-classif))', ~{&double-quote~})
&scop cop-l4      f-gds-name(recid(buf_ext-classif))
&scop dyn_cop-l4  substitute('dynamic-function(&1f-gds-name&1, recid(buf_ext-classif))', ~{&double-quote~})
&scop cop-l5      buf_ext-classif.whole-send-news

function f-gds-code returns char
( input p-rec as recid  ) .
def buffer e-c for ub.ext-classif .
find first e-c no-lock where recid(e-c) = p-rec no-error . if error-status :error then return '' .
define buffer goo for ub.goods.
find first goo no-lock where goo.gds-code = integer(entry(2,e-c.uniq-key-rec, {&delim-key}))  no-error .
if avail goo then do:
  return trim(string(goo.gds-code)).
end.
else return '' .
end function.

function f-gds-name returns char
( input p-rec as recid  ) .
def buffer e-c for ub.ext-classif .
find first e-c no-lock where recid(e-c) = p-rec no-error . if error-status :error then return '' .
define buffer goo for ub.goods.
find first goo no-lock where goo.gds-code = integer(entry(2,e-c.uniq-key-rec, {&delim-key}))  no-error .
if avail goo then do:
  return trim(goo.gds-name) .
end.
else return '' .
end function.


/*   buf_goods.gds-code = integer(entry(2,buf_ext-classif.uniq-key-rec, {&delim-key})) */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-ext-goods

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_ext-classif

/* Definitions for BROWSE BROWSE-ext-goods                              */
&Scoped-define FIELDS-IN-QUERY-BROWSE-ext-goods {&cop-l1} {&cop-l2} {&cop-l3} @ v-gds-code {&cop-l4} @ v-gds-name {&cop-l5}
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-ext-goods {&cop-l1}
&Scoped-define SELF-NAME BROWSE-ext-goods
&Scoped-define QUERY-STRING-BROWSE-ext-goods FOR EACH buf_ext-classif NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-ext-goods OPEN QUERY {&SELF-NAME} FOR EACH buf_ext-classif NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-ext-goods buf_ext-classif
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-ext-goods buf_ext-classif


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-ext-goods}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel B-import B-rel B-norel B-charm ~
B-delete-all B-Help R-find R-find-2 f-name f-name-th BROWSE-ext-goods ~
v-name v-name-th v-name-exel
&Scoped-Define DISPLAYED-OBJECTS R-find R-find-2 f-name f-name-th v-name ~
v-name-th v-name-exel

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 10 BY 1 TOOLTIP "Выход без изменения состояния БД"
     BGCOLOR 8 .

DEFINE BUTTON B-charm
     IMAGE-UP FILE "cmp/b-wizard.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "Авто подбор товарв в БД по совпадению в названии".

DEFINE BUTTON B-delete-all
     IMAGE-UP FILE "cmp/cross.bmp":U
     LABEL ""
     SIZE 3 BY 1 TOOLTIP "все удалить".

DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-import
     LABEL "Импорт"
     SIZE 10 BY 1 TOOLTIP "Импорт из файла Excel ФиБ товаров".

DEFINE BUTTON B-norel
     LABEL "Развязать"
     SIZE 10 BY 1 TOOLTIP "Развязать товары Excel с товарами из БД TradeHouse".

DEFINE BUTTON B-OK AUTO-GO
     LABEL "Ввод"
     SIZE 10 BY 1 TOOLTIP "Выйти и занести ФИБ в БД"
     BGCOLOR 8 .

DEFINE BUTTON B-rel
     LABEL "Связать"
     SIZE 10 BY 1 TOOLTIP "Связать товары Excel с товарами из БД TradeHouse".

DEFINE VARIABLE v-name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 96.5 BY 2.75 TOOLTIP "Описание товара в файле Excel"
     FGCOLOR 4 FONT 2 NO-UNDO.

DEFINE VARIABLE v-name-th AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 96.5 BY 1.5 TOOLTIP "Описание товара в БД TH"
     FGCOLOR 1 FONT 2 NO-UNDO.

DEFINE VARIABLE f-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 28.5 BY 1 TOOLTIP "Поиск по Фальсификантам" NO-UNDO.

DEFINE VARIABLE f-name-th AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 37.5 BY 1 TOOLTIP "Поиск по БД TradeHouse" NO-UNDO.

DEFINE VARIABLE v-name-exel AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 96.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-find AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По Названию", 1,
"По Серии", 2
     SIZE 29 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE R-find-2 AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "По коду товара в ТН", 3
     SIZE 37 BY 1
     FGCOLOR 1  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-ext-goods FOR
      buf_ext-classif SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-ext-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-ext-goods Dialog-Frame _FREEFORM
  QUERY BROWSE-ext-goods NO-LOCK DISPLAY
      {&cop-l1}               COLUMN-LABEL {&col-l1} FORMAT "X(20)":U
      {&cop-l2}               COLUMN-LABEL {&col-l2} FORMAT "X(140)":U
      {&cop-l3}  @ v-gds-code COLUMN-LABEL {&col-l3} FORMAT "X(16)":U
      {&cop-l4}  @ v-gds-name COLUMN-LABEL {&col-l4} FORMAT "X(40)":U
      {&cop-l5}               COLUMN-LABEL {&col-l5}
      enable {&cop-l1}
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96.5 BY 13 ROW-HEIGHT-CHARS .67 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1 COL 1
     B-Cancel AT ROW 1 COL 11
     B-import AT ROW 1 COL 26.13 WIDGET-ID 2
     B-rel AT ROW 1 COL 36.25 WIDGET-ID 4
     B-norel AT ROW 1 COL 46.38 WIDGET-ID 6
     B-charm AT ROW 1 COL 56.5 WIDGET-ID 28
     B-delete-all AT ROW 1 COL 59.5 WIDGET-ID 30
     B-Help AT ROW 1 COL 95
     R-find AT ROW 2 COL 1.5 NO-LABEL WIDGET-ID 12
     R-find-2 AT ROW 2 COL 61 NO-LABEL WIDGET-ID 20
     f-name AT ROW 2.96 COL 2.13 NO-LABEL WIDGET-ID 16
     f-name-th AT ROW 2.96 COL 60.5 NO-LABEL WIDGET-ID 18
     BROWSE-ext-goods AT ROW 4 COL 1.5 WIDGET-ID 200
     v-name AT ROW 18 COL 1.5 NO-LABEL WIDGET-ID 24
     v-name-th AT ROW 20.75 COL 1.5 NO-LABEL WIDGET-ID 10
     v-name-exel AT ROW 17.13 COL 1.5 NO-LABEL WIDGET-ID 26
     SPACE(0.37) SKIP(4.55)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "<insert dialog title>"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_ext-classif B "?" ? ub ext-classif
      TABLE: x_parts T "?" NO-UNDO ub parts
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-ext-goods f-name-th Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN f-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN f-name-th IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       v-name:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-name-exel IN FRAME Dialog-Frame
   ALIGN-L                                                              */
ASSIGN
       v-name-th:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-ext-goods
/* Query rebuild information for BROWSE BROWSE-ext-goods
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_ext-classif NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BROWSE-ext-goods */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-charm
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-charm Dialog-Frame
ON CHOOSE OF B-charm IN FRAME Dialog-Frame
DO:
  run proc-charm .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-delete-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-delete-all Dialog-Frame
ON CHOOSE OF B-delete-all IN FRAME Dialog-Frame
DO:
  run delete-all .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-import Dialog-Frame
ON CHOOSE OF B-import IN FRAME Dialog-Frame /* Импорт */
DO:
  /* Импорт из exel*/
   define variable ff as character no-undo.
   define variable var-name-sheet as character no-undo .
   chworkbook = chexcelapplication:activeworkbook no-error.

        define variable okpressed as logical initial true no-undo.
        system-dialog get-file ff
            title      "Выберите файл ..."
            filters    "excel (*.xls)"   "*.xls"
                        use-filename
                        must-exist
                        update okpressed.
                        if okpressed = true then
                           do:
                              run ex-file in this-procedure   (ff, false) .
                           end.
                        else do:
                          return no-apply .
                        end.

   chworkbook   = chexcelapplication:activeworkbook no-error.
   chworksheet  = chexcelapplication:sheets:item(1):select  no-error.
   chworksheet  = chexcelapplication:sheets:item(1) no-error.

  run import-proc in this-procedure  no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "import-proc"
    view-as alert-box error
  .
  RELEASE OBJECT chWorksheet NO-ERROR.
  RELEASE OBJECT chWorkbook NO-ERROR.
  chExcelApplication :QUIT().
  RELEASE OBJECT  chExcelApplication  NO-ERROR.
  run openbr in this-procedure (yes, no, '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-norel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-norel Dialog-Frame
ON CHOOSE OF B-norel IN FRAME Dialog-Frame /* Развязать */
DO:
  /* снять */
  if available buf_ext-classif then do:
      find current buf_ext-classif exclusive-lock.
      buf_ext-classif.uniq-key-rec = "".
      buf_ext-classif.whole-send-news = 0.
      g-log =  {&BROWSE-NAME}:refresh() .
      apply "VALUE-CHANGED" TO {&BROWSE-NAME} IN FRAME {&frame-name} .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* Ввод */
DO:
  /* */
define buffer buf_parts for ub.parts  .
define buffer buf_goods for ub.goods  .
run waitfram-show in this-procedure ("Поиск ФиБ в БД...")   .
  for each buf_ext-classif no-lock where
        buf_ext-classif.uniq-key-rec <> "" and
        Buf_ext-classif.classif-subject = {&extclass_goods}  AND
        Buf_ext-classif.classif-name    = {&extclass_goods_fib}  :
        find first buf_goods no-lock where buf_goods.gds-code = integer(entry(2,buf_ext-classif.uniq-key-rec, {&delim-key}))  no-error .
        if error-status :error then next.
        find first  buf_parts no-lock where
                    buf_parts.artic      = buf_goods.artic     and
                    buf_parts.prod-type  = buf_goods.prod-type and
                    buf_parts.prod-code  = buf_goods.prod-code and
                    buf_parts.part-code  = buf_ext-classif.CharKey_One no-error .
       if available buf_parts then do:
          create x_parts.
          buffer-copy buf_parts to x_parts.
       end.
  end.
run waitfram-hide in this-procedure   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-rel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-rel Dialog-Frame
ON CHOOSE OF B-rel IN FRAME Dialog-Frame /* Связать */
DO:
define variable v-uniq-key-rec as character no-undo .
define variable v-rid-list as character no-undo .

define buffer buf_goods for ub.goods  .

  /* Связать */
  if available buf_ext-classif then do:
  find current buf_ext-classif exclusive-lock.
    run ref/gds-ref.p ( input parparentproc
                      , input "b-sel"
                      , input {&current}
                      , input {&all}
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , input ?
                      , output v-rid-list
                      ) no-error.
    if not error-status:error
    and v-rid-list <> '' then do:
        find first buf_goods no-lock where
                  recid(buf_goods) = integer(v-rid-list) no-error.

        run gen-key-rec IN THIS-PROCEDURE
          ( input {&table_goods}
          , input (buffer buf_goods:handle)
          , output v-uniq-key-rec ).

      buf_ext-classif.uniq-key-rec = v-uniq-key-rec .
      buf_ext-classif.whole-send-news = 0.
      g-log =  {&BROWSE-NAME}:refresh() .
      apply "VALUE-CHANGED" TO {&BROWSE-NAME} IN FRAME {&frame-name} .
      end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-ext-goods
&Scoped-define SELF-NAME BROWSE-ext-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-ext-goods Dialog-Frame
ON ROW-DISPLAY OF BROWSE-ext-goods IN FRAME Dialog-Frame
DO:
  /**/
if available buf_ext-classif then do:
   if buf_ext-classif.whole-send-news = 1 then do:
    assign
      {&cop-l1}:bgcolor   in browse {&browse-name}  = 14
      {&cop-l2}:bgcolor   in browse {&browse-name}  = 14
      v-gds-code:bgcolor  in browse {&browse-name}  = 14
      v-gds-name:bgcolor  in browse {&browse-name}  = 14
    .
   end.
   if buf_ext-classif.whole-send-news = 0 then do:
    assign
      {&cop-l1}:bgcolor  in browse {&browse-name} = ?
      {&cop-l2}:bgcolor  in browse {&browse-name} = ?
      v-gds-code:bgcolor in browse {&browse-name} = ?
      v-gds-name:bgcolor in browse {&browse-name} = ?
    .
   end.

end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-ext-goods Dialog-Frame
ON VALUE-CHANGED OF BROWSE-ext-goods IN FRAME Dialog-Frame
DO:
if available buf_ext-classif then do:
  v-name-exel  =  substitute("&1" ,buf_ext-classif.CharKey_Three  ) .
  v-name  =  substitute("&1" ,buf_ext-classif.CharKey_Two ) .
  v-name-th = f-gds-name ( recid(buf_ext-classif) )  .
  display v-name-exel  v-name v-name-th with frame {&frame-name} .

end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-name Dialog-Frame
ON RETURN OF f-name IN FRAME Dialog-Frame
DO:
 assign r-find f-name.
  case r-find:
  when 1 then do: /* По названию */
     run proc-find-name in this-procedure(no, f-name) no-error.
  end.
  when 2 then do: /* По серии */
     run proc-find-part-code in this-procedure(no, f-name) no-error.
  end.
  end case.
  return no-apply.
END.

ON CTRL-J  OF f-name IN FRAME Dialog-Frame
do:
 assign r-find f-name.
  case r-find:
  when 1 then do: /* По названию */
     run proc-find-name in this-procedure(yes, f-name) no-error.
  end.
  when 2 then do: /* По серии */
     run proc-find-part-code in this-procedure(yes, f-name) no-error.
  end.
  end case.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-name-th
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-name-th Dialog-Frame
ON RETURN OF f-name-th IN FRAME Dialog-Frame
DO:
 assign r-find-2 f-name-th.
  case r-find-2:
  when 1 then do: /* По названию */
     run proc-find-name-th in this-procedure(no, f-name-th) no-error.
  end.
  when 3 then do: /* По коду */
     run proc-find-part-code-th in this-procedure(no, f-name-th) no-error.
  end.
  end case.
  return no-apply.
END.


ON CTRL-J  OF f-name-th IN FRAME Dialog-Frame
do:
 assign r-find-2 f-name-th.
  case r-find-2:
  when 1 then do: /* По названию */
     run proc-find-name-th in this-procedure(yes, f-name-th) no-error.
  end.
  when 3 then do: /* По серии */
     run proc-find-part-code-th in this-procedure(yes, f-name-th) no-error.
  end.
  end case.
  return no-apply.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */
{ gbl/f2.i BROWSE-ext-goods goods-recid init-gds-rec parParentProc }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }

{ gbl/srt-clmd.i
&browse-name          = "{&browse-name}"
&frame-name           = "{&frame-name}"
&table-name           = "buf_ext-classif"
&label-clmn_1         = "{&col-l1}"
&label-clmn_2         = "{&col-l2}"
&label-clmn_3         = "{&col-l3}"
&label-clmn_4         = "{&col-l4}"
&label-clmn_5         = "{&col-l5}"
&sort-clmn_1          = "{&cop-l1}"
&sort-clmn_2          = "{&cop-l2}"
&sort-clmn_3          = "{&cop-l3}"
&dyn_sort-clmn_3      = "{&dyn_cop-l3}"
&sort-clmn_4          = "{&cop-l4}"
&dyn_sort-clmn_4      = "{&dyn_cop-l4}"
&sort-clmn_5          = "{&cop-l5}"
&open-query           = "run OpenBr(yes,no,'':U)."
&open-query-otherwise = "run OpenBr(yes,no,'':U)."
&sort-column-name     = "sort-column-name"
&re-move-clmn         = "no"
&mv-brw-default       = "no" }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

   buf_ext-classif.CharKey_Three :resizable in browse {&browse-name}   = true .
   buf_ext-classif.CharKey_One   :resizable in browse {&browse-name}   = true .
   buf_ext-classif.CharKey_One   :width     in browse {&browse-name}   = 16.
   buf_ext-classif.CharKey_Three :width     in browse {&browse-name}   = 35.
   {&cop-l1}:read-only in browse {&browse-name}   = true .
  RUN enable_UI.
  run openbr in this-procedure (yes, no, '':U) .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-all Dialog-Frame
PROCEDURE delete-all :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-ok as logical   no-undo .
message
 "Запустить удаление всего хранимого списка ФИБ ? "
 view-as alert-box question
       BUTTONS yes-no
       TITLE "Внимание !"
       UPDATE v-ok
       .
if not v-ok then return .
  run waitfram-show in this-procedure ("Процедура связывания товара по первому слову...")   .
  for each buf_ext-classif exclusive-lock where
    Buf_ext-classif.classif-subject = {&extclass_goods}  AND
    Buf_ext-classif.classif-name    = {&extclass_goods_fib}  :
    delete Buf_ext-classif .
  end.
  run waitfram-hide in this-procedure .
  run openbr in this-procedure (yes, no, '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY R-find R-find-2 f-name f-name-th v-name v-name-th v-name-exel
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel B-import B-rel B-norel B-charm B-delete-all B-Help
         R-find R-find-2 f-name f-name-th BROWSE-ext-goods v-name v-name-th
         v-name-exel
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ex-file Dialog-Frame
PROCEDURE ex-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter ff as character no-undo .
define input parameter ex as logical no-undo .
  if ex = false then do:
      create "excel.application" chexcelapplication connect no-error.
     if error-status:error then 
     do:  
        create "excel.application" chexcelapplication no-error.
        if error-status :error then 
        do:
           message
              "Ошибка при запуске Excel" skip
              error-status :get-message(1) skip
              view-as alert-box error .
           undo, return error .
        end.
     end.
    if ff = ""  then do:
      chworkbook   = chexcelapplication:workbooks:add( ).
    end.
    else do:
      chworkbook   = chexcelapplication:workbooks:open( ff ).
    end.
  end.
  {&excel-invisable}
  chworksheet  = chexcelapplication:sheets:item (1).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-proc Dialog-Frame
PROCEDURE import-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable ii         as integer   no-undo .
define variable v-i        as integer   no-undo .
define variable t          as character no-undo .
define variable g-name-gds as character no-undo .  /*Препарат               */
define variable g-doz      as character no-undo .  /*Дозировка              */
define variable g-fas      as character no-undo .  /*Фасовка                */
define variable g-form     as character no-undo .  /*Форма выпуска          */
define variable g-serii    as character no-undo .  /*Серия                  */
define variable g-prod     as character no-undo .  /*Производитель          */
define variable g-brak     as character no-undo .  /*Характер брака         */
define variable g-docn     as character no-undo .  /*Док №                  */
define variable g-dodd     as character no-undo .  /*Док дата               */
define variable g-fpost    as character no-undo .  /*Федеральный поставщик  */
define variable g-rpost    as character no-undo .  /*Региональные поставщики*/
define variable v-desc as character no-undo .

define buffer buf_ext-classif for ub.ext-classif  .
ii = 1 .
v-i = 0 .
run waitfram-show in this-procedure ("Закачка данных из Excel...")   .

define variable v-a as integer   no-undo .
v-a = 0.

 do while  ( ii <= 100000 ) :
    ii = ii  + 1.
    T = string(ii) .
    /*message
    'строка ' T skip
    chWorkSheet:Range ('E' + T):Value skip
    chWorkSheet:Range ('A' + T):Value
    view-as alert-box information .
    */
 if chWorkSheet:Range ('A' + T):Value  = ? then v-a = v-a + 1.
 else v-a = 0.
 if v-a >= 4 then leave.

 Assign
  g-name-gds = chWorkSheet:Range ('A' + T):Value
  g-doz      = chWorkSheet:Range ('B' + T):Value
  g-fas      = chWorkSheet:Range ('C' + T):Value
  g-form     = chWorkSheet:Range ('D' + T):Value
  g-serii    = chWorkSheet:Range ('E' + T):Value
  g-prod     = chWorkSheet:Range ('F' + T):Value
  g-brak     = chWorkSheet:Range ('G' + T):Value
  g-docn     = chWorkSheet:Range ('H' + T):Value
  g-dodd     = chWorkSheet:Range ('I' + T):Value
  g-fpost    = chWorkSheet:Range ('J' + T):Value
  g-rpost    = chWorkSheet:Range ('K' + T):Value
  no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  v-desc = substitute("доза:&1 фасовка:&2 форма:&3 брак:&5документ:&6 от:&7 производитель:&4 фед.пост.:&8 рег.пост.:&9 " ,
            g-doz  ,
            g-fas  ,
            g-form,
            g-prod,
            g-brak,
            g-docn ,
            g-dodd ,
            g-fpost,
            g-rpost
            )
  no-error.

  if g-serii    = ? or
     g-name-gds = ? or
     v-desc     = ?  then next.


  find first ub.ext-classif exclusive-lock where
    ub.ext-classif.classif-name    = {&extclass_goods_fib}    and
    ub.ext-classif.classif-subject = {&extclass_goods}        and
    ub.ext-classif.db-num          =  -1                      and
    ub.ext-classif.CharKey_One     = g-serii                  and
    ub.ext-classif.CharKey_Three   = g-name-gds               and
    ub.ext-classif.CharKey_Two     = v-desc                   and
    ub.ext-classif.Key#_One        = 0                        and
    ub.ext-classif.Key#_Three      = 0                        and
    ub.ext-classif.Key#_Two        = 0                        and
    ub.ext-classif.nonunique       = 0
 no-error .
    if not available ub.ext-classif then do:
      create ub.ext-classif no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "create"
        view-as alert-box error
      .
      assign
        ub.ext-classif.classif-name    = {&extclass_goods_fib}
        ub.ext-classif.classif-subject = {&extclass_goods}
        ub.ext-classif.db-num          =  -1
        ub.ext-classif.CharKey_One     = g-serii
        ub.ext-classif.CharKey_Three   = g-name-gds
        ub.ext-classif.CharKey_Two     = v-desc
        ub.ext-classif.Key#_One        = 0
        ub.ext-classif.Key#_Three      = 0
        ub.ext-classif.Key#_Two        = 0
        ub.ext-classif.nonunique       = 0
      no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "update"
        view-as alert-box error
      .
      v-i = v-i + 1.
    end.
    else do:
    end.
 end.
 run waitfram-hide in this-procedure  .
 message "Импортировано " v-i  " строк".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-gds-rec Dialog-Frame
PROCEDURE init-gds-rec :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define buffer buf_goods for ub.goods  .
gds-rec = ? .
if available buf_ext-classif then do:
  find first   buf_goods no-lock where
               buf_goods.gds-code = integer ( entry ( 2,buf_ext-classif.uniq-key-rec, {&delim-key})) no-error .
   if available buf_goods then do:
      gds-rec = recid(buf_goods) .
   end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
/*
message

'p-open-query     '  p-open-query    skip
'p-find-next      '  p-find-next     skip
'p-find-condition '  p-find-condition skip.
  */
def var l-query-was-opened as logical no-undo .
define variable doc-rec  as recid     no-undo .


def var sort-column-phrase as character no-undo .

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

define variable title0 as character no-undo init "ФиБ" .
title0 = "ФиБ" .

&scop flt-open-open-query OPEN QUERY BROWSE-ext-goods FOR EACH Buf_ext-classif

&scop flt-open-dyn_open-query  FOR EACH Buf_ext-classif

&scop flt-open-query-handle query BROWSE-ext-goods:handle

&scop flt-open-find-buffer-name Buf_ext-classif

&scop flt-open-open-query-tail

&scop flt-open-dyn_open-query-tail ''

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name

&scop flt-open-indexed-reposition  indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          buf_ext-classif

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer buf_ext-classif for ub.ext-classif.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

    if p-open-query then do:
      frame {&frame-name}:TITLE = title0  .
    end.
    { gbl/fltopend.i
    &where-cond = "  ~
                    Buf_ext-classif.classif-subject = {&extclass_goods}  AND ~
                    Buf_ext-classif.classif-name = {&extclass_goods_fib} ~
                    "
    &dyn_where-cond = "~
           substitute(' ~
           Buf_ext-classif.classif-subject = &1&2&1  AND ~
           Buf_ext-classif.classif-name = &1&3&1 '  , ~
           ~{&double-quote~}, ~{&extclass_goods~} ,  ~{&extclass_goods_fib~})"

    &use-ind    = " "
    &by         = " "  }

if not p-open-query then do:
 reposition {&browse-name}  to recid doc-rec no-error.
 end.
if not p-open-query and v-fltopend-rowid[1] <> ? then do:
   query {&browse-name}:handle:reposition-to-rowid(v-fltopend-rowid) no-error.
end.

APPLY "VALUE-CHANGED" TO {&BROWSE-NAME} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-charm Dialog-Frame
PROCEDURE proc-charm :
/* -----------------------------------------------------------
  Purpose: волшебное автоматическое связывание товара
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define variable v-ok as logical   no-undo .
define variable v-first as character no-undo .
define variable v-uniq-key-rec as character no-undo .

define buffer buf_goods for ub.goods  .

message
 "Запустить связывание хранимого списка ФИБ  и справочника товаров TradeHouse ? "
 "Критерий связывания  - по первому слову"
 view-as alert-box question
       BUTTONS yes-no
       TITLE "Внимание !"
       UPDATE v-ok
       .
if not v-ok then return .


run waitfram-show in this-procedure ("Процедура связывания товара по первому слову...")   .
for each buf_ext-classif exclusive-lock where
         buf_ext-classif.db-num          = -1 and
         buf_ext-classif.uniq-key-rec    = "" and
         buf_ext-classif.classif-subject = {&extclass_goods}  and
         buf_ext-classif.classif-name    = {&extclass_goods_fib} :
         v-first = entry( 1 , buf_ext-classif.CharKey_Three, "," ) .
    find first buf_goods no-lock where
               buf_goods.gds-name begins  substitute("&1" , v-first)  no-error .
   if available buf_goods then do:
        run gen-key-rec IN THIS-PROCEDURE
          ( input {&table_goods}
          , input (buffer buf_goods:handle)
          , output v-uniq-key-rec ).
      buf_ext-classif.uniq-key-rec = v-uniq-key-rec .
      buf_ext-classif.whole-send-news = 1.
   end.
end.
run waitfram-hide in this-procedure .

run openbr in this-procedure (yes, no, '':U).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name Dialog-Frame
PROCEDURE proc-find-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.

run openbr in this-procedure (no, par-next , substitute(" and buf_ext-classif.CharKey_Three begins  '&1'" , p-var )) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-name-th Dialog-Frame
PROCEDURE proc-find-name-th :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo.
define input parameter p-var    as char no-undo.

run openbr in this-procedure (no, par-next ,
substitute(' and buf_ext-classif.uniq-key-rec <> "" and dynamic-function(&1f-gds-name&1, recid(buf_ext-classif)) = &1&2&1 ', {&double-quote}, p-var) ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-part-code Dialog-Frame
PROCEDURE proc-find-part-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo .
define input parameter p-var    as character no-undo .

run openbr in this-procedure ( no , par-next , substitute (" and buf_ext-classif.CharKey_One begins '&1' " , p-var )) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-find-part-code-th Dialog-Frame
PROCEDURE proc-find-part-code-th :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter par-next as logical no-undo .
define input parameter p-var    as character no-undo .

run openbr in this-procedure ( no , par-next ,
    substitute(' and buf_ext-classif.uniq-key-rec = &1goods&3&2&1 ', {&double-quote},  p-var , {&delim-key}) ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
