&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE tt-doc-line-attr NO-UNDO LIKE ub.doc-line-attr
       field node-code as int
       field bk-gds-code as int.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

В какие наборы входит товар

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 01/26/05

*/
/*------------------------------------------------------------------------

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define input  parameter   parParentProc  as widget-handle no-undo.
define input  parameter   p-doc-mode  as character no-undo .
define input  parameter   p-doc-code  as character no-undo .
define input  parameter   p-gds-code  as integer   no-undo .
define input  parameter   p-prt-code  as integer   no-undo .
define output parameter   p-make      as logical   no-undo .

/* УБИТЬ */
define variable g#mainmenu-handle as widget-handle no-undo.
g#mainmenu-handle = parParentProc .
define new shared variable prt-rec   as recid no-undo .
define new shared variable line-mode as character no-undo .
define new shared variable line-rec  as recid no-undo .
define new shared variable gds-rec   as recid no-undo .

/* Parameters Definitions ---                                           */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "В какие наборы входит товар".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/lineattr.i }
{ str/lib-calc.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .



{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num in parParentProc ( output g#report-num ).

define temp-table temp-gds-dtl no-undo
field node-code as integer
field artic     as char
field prod-type     as char
field prod-code     as int
field gds-code  as integer
field rel-bk    as logical
index pi node-code
.
/*для запуска резервирования*/
def var chg-qnty like gds-dtl.doc-qnty init ? no-undo.
def shared buffer t-doc for trn-doc.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-doc-line-attr ub.goods

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 ub.goods.artic ub.goods.gds-name ~
tt-doc-line-attr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1 tt-doc-line-attr.attr-value
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1 tt-doc-line-attr
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1 tt-doc-line-attr
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.bk-gds-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.bk-gds-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-doc-line-attr ub.goods
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-doc-line-attr
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1 ub.goods


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-add B-chg B-del B-Help BROWSE-1 ~
v-str
&Scoped-Define DISPLAYED-OBJECTS v-str

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-str AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 75.5 BY 1.25
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-doc-line-attr,
      ub.goods SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 NO-LOCK DISPLAY
      ub.goods.artic FORMAT "X(16)":U
      ub.goods.gds-name COLUMN-LABEL "Название набора" FORMAT "X(48)":U
      tt-doc-line-attr.attr-value COLUMN-LABEL "Количество" FORMAT "x(10)":U
  ENABLE
      tt-doc-line-attr.attr-value
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 79 BY 9.25 ROW-HEIGHT-CHARS .75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-add AT ROW 1 COL 11
     B-chg AT ROW 1 COL 21
     B-del AT ROW 1 COL 31
     B-Help AT ROW 1 COL 70
     BROWSE-1 AT ROW 4 COL 1
     v-str AT ROW 2.25 COL 1.5 NO-LABEL
     SPACE(3.37) SKIP(9.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товар входит в наборы"
         CANCEL-BUTTON B-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: tt-doc-line-attr T "?" NO-UNDO ub doc-line-attr
      ADDITIONAL-FIELDS:
          field node-code as int
          field bk-gds-code as int
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB BROWSE-1 B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN v-str IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "Temp-Tables.tt-doc-line-attr,ub.goods WHERE Temp-Tables.tt-doc-line-attr ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _JoinCode[2]      = "ub.goods.gds-code = Temp-Tables.tt-doc-line-attr.bk-gds-code"
     _FldNameList[1]   = ub.goods.artic
     _FldNameList[2]   > ub.goods.gds-name
"ub.goods.gds-name" "Название набора" ? "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > Temp-Tables.tt-doc-line-attr.attr-value
"tt-doc-line-attr.attr-value" "Количество" "x(10)" "character" ? ? ? ? ? ? yes ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товар входит в наборы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:

define variable  v-qnty     as character no-undo .
define variable  v-qnty-old as character no-undo .
define variable v-exist as logical   no-undo .
define variable v-buket-gds-code as integer   no-undo .

run str/flornakl.p
  ( input parParentProc , input "all", input p-doc-code , output v-exist , output v-buket-gds-code ) .

if v-exist then do:
find first tt-doc-line-attr where
      tt-doc-line-attr.doc-code    = p-doc-code and
      tt-doc-line-attr.gds-code    = p-gds-code and
      tt-doc-line-attr.attr-code  = {&lineattr-flora_gds-code}  + {&comma-char} + string(p-prt-code)  + {&comma-char} + string(v-buket-gds-code ) no-error .
if available tt-doc-line-attr then do:
    message "В таком наборе товар " v-str " уже присутствует!" view-as alert-box information .
    return .
end.

if v-buket-gds-code = 0 or v-buket-gds-code = ? then return .

      CREATE tt-doc-line-attr.
      assign
      tt-doc-line-attr.doc-code    = p-doc-code
      tt-doc-line-attr.gds-code    = p-gds-code
      tt-doc-line-attr.node-code   = p-prt-code
      tt-doc-line-attr.attr-value  = "1"
      tt-doc-line-attr.bk-gds-code = v-buket-gds-code
      tt-doc-line-attr.attr-code  = {&lineattr-flora_gds-code}  + {&comma-char} + string(p-prt-code)  + {&comma-char} + string(v-buket-gds-code )
      .

     {&OPEN-QUERY-BROWSE-1}
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available tt-doc-line-attr    then return .
define variable  v-qnty     as character no-undo .
define variable  v-qnty-old as character no-undo .

 v-qnty     =  tt-doc-line-attr.attr-value .
 v-qnty-old =  tt-doc-line-attr.attr-value .
run gbl/d-prompt.w (
        'title=':u + "Изменение количества товара" + '\':u
      + 'text1=':u + "Количество" + ( goods.gds-name ) + '\':u
      + 'format=' + ">>>>>>>9.99" + '\':u
      + 'type=' + "decimal" + '\':u
      + 'fillin_row=2\':u
      + 'fillin_col=4\':u
      + 'fillin_width=10\':u
      + 'fillin_height=1\':u
      + 'max-chars=10\':u     /*- максимальное количество символов для редактора*/
      + 'readonly=' + (if p-doc-mode <> {&lookup} then 'no':u else 'yes':u) + '\':u
      , input-output v-qnty
      ) no-error.
   if caps(return-value) = "TRUE" and p-doc-mode <> {&lookup}  then do:
      tt-doc-line-attr.attr-value  = v-qnty  .
     {&browse-name}:refresh() in frame {&frame-name} .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
if not available tt-doc-line-attr then return .
   message
   "Удалять товар : " v-str
   " из набора : " goods.gds-name  "?"
   view-as alert-box question
   buttons yes-no
   update v-d as log

   .
   if v-d = true then do:
      delete tt-doc-line-attr.
      {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
  run save-proc in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1
&Scoped-define SELF-NAME BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1 Dialog-Frame
ON ROW-LEAVE OF BROWSE-1 IN FRAME Dialog-Frame
DO:
define variable ll as decimal   no-undo .
 ll = DEC(tt-doc-line-attr.attr-value:screen-value in browse {&browse-name} ) no-error .
 IF error-status :error  THEN  RETURN NO-APPLY.
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

  run init-proc no-error .
  if error-status :error then return .
  run enable_ui in this-procedure .
  if p-doc-mode =  {&lookup} then
     disable b-add b-chg b-del with frame {&frame-name} .
  wait-for go of frame {&frame-name}.
end.
run disable_ui in this-procedure .

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
  DISPLAY v-str
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-add B-chg B-del B-Help BROWSE-1 v-str
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer bk_goods for goods.
find first bk_goods where bk_goods.gds-code  = p-gds-code   no-error .
if error-status :error then return error .


define variable v-ok as logical   no-undo .
 { str/grpnabor.i p-gds-code  v-ok }
 if v-ok then  do:
 message "Выбранная позиция является нетоварной и в наборы не входит !".
 return error .
 end.

v-str = bk_goods.artic + " " + bk_goods.gds-name .

define buffer buf_doc-line-attr for doc-line-attr.

        for each buf_doc-line-attr no-lock
          where buf_doc-line-attr.doc-code  = p-doc-code
            and buf_doc-line-attr.gds-code  = p-gds-code
            and lookup ( string  (p-prt-code) , buf_doc-line-attr.attr-code ) > 0
            and lookup ({&lineattr-flora_gds-code} , buf_doc-line-attr.attr-code ) > 0
            :
            if integer (entry( 2 , buf_doc-line-attr.attr-code)) <> p-prt-code then next.
              create tt-doc-line-attr.
              BUFFER-COPY buf_doc-line-attr TO tt-doc-line-attr.
              assign
                tt-doc-line-attr.node-code   = integer ( entry ( 2 , buf_doc-line-attr.attr-code ))
                tt-doc-line-attr.bk-gds-code = integer ( entry ( 3 , buf_doc-line-attr.attr-code ))
              .
        end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame
PROCEDURE save-proc :
do
  on error undo, return error return-value
  :
define variable v-ok as logical   no-undo .
define buffer buf_doc-line-attr for doc-line-attr.
if p-doc-mode = {&lookup} then return .
/* запись в doc-line-attr  из временной таблицы */
for each tt-doc-line-attr :
        find first  buf_doc-line-attr where
                    tt-doc-line-attr.doc-code  = buf_doc-line-attr.doc-code
                and tt-doc-line-attr.gds-code  = buf_doc-line-attr.gds-code
                and tt-doc-line-attr.attr-code = buf_doc-line-attr.attr-code no-error .
        if available buf_doc-line-attr then do:
          if buf_doc-line-attr.attr-value <> tt-doc-line-attr.attr-value then
          assign
            buf_doc-line-attr.attr-value = tt-doc-line-attr.attr-value
          .
        end.
        else do:
          create buf_doc-line-attr.
          BUFFER-COPY tt-doc-line-attr TO buf_doc-line-attr.
        end.
end.

  for each buf_doc-line-attr exclusive-lock
    where buf_doc-line-attr.doc-code  = p-doc-code
      and buf_doc-line-attr.gds-code  = p-gds-code
      and lookup ({&lineattr-flora_gds-code} , buf_doc-line-attr.attr-code ) > 0
      and lookup ( string(p-prt-code) , buf_doc-line-attr.attr-code ) > 0
      :
        find first  tt-doc-line-attr where
                    tt-doc-line-attr.doc-code  = buf_doc-line-attr.doc-code
                and tt-doc-line-attr.gds-code  = buf_doc-line-attr.gds-code
                and tt-doc-line-attr.attr-code = buf_doc-line-attr.attr-code no-error .

        if available tt-doc-line-attr then do:
          if buf_doc-line-attr.attr-value <> tt-doc-line-attr.attr-value then
          assign
            buf_doc-line-attr.attr-value = tt-doc-line-attr.attr-value
          .
        end.
        else do:
          delete buf_doc-line-attr.
        end.
  end.

/* проверка количеств по признакам для товаров входящих в наборы*/

define variable v-qnty as decimal   no-undo .
define variable v-qnty-prt as decimal   no-undo .
define buffer buf_goods for goods.
define buffer buf2_goods for goods.
define buffer buf2_doc-line for doc-line.

find  first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .

define buffer ready_trn-doc for trn-doc.
define buffer nakl_trn-doc for trn-doc.

find first nakl_trn-doc  no-lock where nakl_trn-doc.doc-code  = p-doc-code no-error .
if error-status :error then return .
find first ready_trn-doc no-lock where ready_trn-doc.doc-code = nakl_trn-doc.out-code no-error .
  if error-status :error
  then do:
    message
        vss-workfile vss-revision vss-description skip
        "Не найден документ-щепка в статусе ГОТОВ" skip
        error-status :get-message(1)
        return-value
        view-as alert-box error .
    return error.
  end.


for each gds-dtl exclusive-lock where gds-dtl.doc-code  = p-doc-code and
                                      gds-dtl.artic     = buf_goods.artic       and
                                      gds-dtl.prod-type = buf_goods.prod-type   and
                                      gds-dtl.prod-code = buf_goods.prod-code   and
                                      gds-dtl.prt-code  = p-prt-code
  :
    v-qnty = 0 .
    v-qnty-prt = 0 .

    for each buf2_doc-line no-lock where buf2_doc-line.doc-code  = ready_trn-doc.doc-code :
      find first buf2_goods no-lock where
                buf2_goods.artic     = buf2_doc-line.artic       and
                buf2_goods.prod-type = buf2_doc-line.prod-type   and
                buf2_goods.prod-code = buf2_doc-line.prod-code   no-error .
                { str/grpnabor.i buf2_goods.gds-code  v-ok }
        if v-ok then do:
            run lineattr-value-flora-gds (
                input   p-doc-code       ,
                input   buf_goods.gds-code   ,
                input   gds-dtl.prt-code  ,
                input   buf2_goods.gds-code    ,
                input   {&lineattr-flora_gds-code}        ,
                output  v-qnty       ).
            v-qnty-prt = v-qnty-prt + v-qnty .
         end.
    end.

    if v-qnty-prt <> gds-dtl.fact-qnty then do:

       p-make = true .
        find first doc-line exclusive-lock where
                 doc-line.doc-code   = gds-dtl.doc-code  and
                 doc-line.artic      = gds-dtl.artic     and
                 doc-line.prod-type  = gds-dtl.prod-type and
                 doc-line.prod-code  = gds-dtl.prod-code no-error .
      if not t-doc.flag_ and t-doc.status_ <> {&permitted} then do:
        { str/rsrv-out.i "doc" "v-qnty-prt"}
         end.
      else do:
        { str/rsrv-out.i "fact" "v-qnty-prt"}
      end.

      find first buf2_goods no-lock where
                buf2_goods.artic     = doc-line.artic       and
                buf2_goods.prod-type = doc-line.prod-type   and
                buf2_goods.prod-code = doc-line.prod-code   no-error .

      if gds-dtl.doc-qnty = 0 then do:
            run str/out-add.p
                          (parparentproc,
                           recid(nakl_trn-doc),
                           recid(doc-line),
                           recid(gds-dtl),
                           recid(buf2_goods),
                           "delete",
                           ?) no-error.

      end.

    end.
end.

end.
end procedure. /* save-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME