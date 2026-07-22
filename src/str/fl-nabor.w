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
       field price-rubl as dec
       field price-base as dec.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и корректировка состава набора

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

               v-pr-wrk
               v-sum-deliv
*/

/* ***************************  Definitions  ************************** */

define input  parameter   parParentProc  as widget-handle no-undo.
define input  parameter   p-doc-mode  as character no-undo .
define input  parameter   p-doc-code  as character no-undo .
define input  parameter   p-bk-gds-code as integer   no-undo .
define output parameter   p-make as logical   no-undo .
define output parameter   p-sum1 as decimal   no-undo .
define output parameter   p-sum2 as decimal   no-undo .

/* УБИТЬ */
define variable g#mainmenu-handle as widget-handle no-undo.
g#mainmenu-handle = parParentProc .
define variable list-mode as character no-undo .
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
define variable vss-description as character no-undo init "Просмотр и корректировка состава набора".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/lineattr.i }
{ str/trdcalib.i }
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
run get-report-num  in parParentProc ( output g#report-num ).


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
if t-doc.status_ = {&ready}  or
   t-doc.status_ = {&rejected}
then p-doc-mode = {&lookup} .
p-make = false  .

/* Local Variable Definitions ---                                       */
define buffer tt2-doc-line-attr for tt-doc-line-attr.

DEF VAR v-sum-deliv AS CHAR NO-UNDO.

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
&Scoped-define INTERNAL-TABLES tt-doc-line-attr ub.goods ub.gds-prt

/* Definitions for BROWSE BROWSE-1                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1 ub.goods.artic ~
(if gds-prt.node-name <> {&empty-scale} and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) ~
ub.goods.unit-base tt-doc-line-attr.attr-value tt-doc-line-attr.price-base ~
tt-doc-line-attr.price-rubl
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1
&Scoped-define QUERY-STRING-BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.gds-code NO-LOCK, ~
      EACH ub.gds-prt WHERE ub.gds-prt.node-code =  tt-doc-line-attr.node-code NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-1 OPEN QUERY BROWSE-1 FOR EACH tt-doc-line-attr NO-LOCK, ~
      EACH ub.goods WHERE ub.goods.gds-code = tt-doc-line-attr.gds-code NO-LOCK, ~
      EACH ub.gds-prt WHERE ub.gds-prt.node-code =  tt-doc-line-attr.node-code NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-1 tt-doc-line-attr ub.goods ~
ub.gds-prt
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1 tt-doc-line-attr
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1 ub.goods
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-1 ub.gds-prt


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-add B-chg B-del B-Help BROWSE-1 ~
v-prim-str v-str v-pr-wrk v-itogo-base v-pr-sk v-itogo-rubl text-1 ~
v-sum-with-disc-base v-sum-with-disc-rubl
&Scoped-Define DISPLAYED-OBJECTS v-prim-str v-str v-pr-wrk v-itogo-base ~
v-pr-sk v-itogo-rubl text-1 v-sum-with-disc-base v-sum-with-disc-rubl

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

DEFINE VARIABLE v-prim-str AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 89.5 BY 3.5 NO-UNDO.

DEFINE VARIABLE text-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Итого c наценкой и скидкой:"
      VIEW-AS TEXT
     SIZE 28 BY .67 NO-UNDO.

DEFINE VARIABLE v-itogo-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого (баз.вал)"
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-itogo-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "Итого "
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-pr-sk AS DECIMAL FORMAT "->>>>9.99%":U INITIAL 0
     LABEL "Скидка клиента"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-pr-wrk AS DECIMAL FORMAT "->>>>9.99%":U INITIAL 0
     LABEL "Наценка за работу"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE v-str AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 89.5 BY 1.25
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE v-sum-with-disc-base AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "баз.вал."
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE v-sum-with-disc-rubl AS DECIMAL FORMAT "->>>>>>>>9.99":U INITIAL 0
     LABEL "."
      VIEW-AS TEXT
     SIZE 21.5 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1 FOR
      tt-doc-line-attr,
      ub.goods,
      ub.gds-prt SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1 Dialog-Frame _STRUCTURED
  QUERY BROWSE-1 NO-LOCK DISPLAY
      ub.goods.artic FORMAT "X(16)":U
      (if gds-prt.node-name <> {&empty-scale} and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) COLUMN-LABEL "Наименование" FORMAT "x(35)":U
      ub.goods.unit-base COLUMN-LABEL "Ед.!изм." FORMAT "X(3)":U
            WIDTH 3
      tt-doc-line-attr.attr-value COLUMN-LABEL "Количество" FORMAT "X(10)":U
      tt-doc-line-attr.price-base COLUMN-LABEL "Цена в !баз.вал." FORMAT ">>>>>>9.99":U
      tt-doc-line-attr.price-rubl COLUMN-LABEL "Цена в {&abbr_rub}" FORMAT ">>>>>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 90 BY 10.75 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-add AT ROW 1 COL 11
     B-chg AT ROW 1 COL 21
     B-del AT ROW 1 COL 31
     B-Help AT ROW 1 COL 81
     BROWSE-1 AT ROW 3.75 COL 1
     v-prim-str AT ROW 19 COL 1 NO-LABEL
     v-str AT ROW 2.25 COL 1.5 NO-LABEL
     v-pr-wrk AT ROW 14.5 COL 21.5 COLON-ALIGNED
     v-itogo-base AT ROW 14.5 COL 67 COLON-ALIGNED
     v-pr-sk AT ROW 15.25 COL 21.5 COLON-ALIGNED
     v-itogo-rubl AT ROW 15.25 COL 67 COLON-ALIGNED
     text-1 AT ROW 16.5 COL 50 COLON-ALIGNED NO-LABEL
     v-sum-with-disc-base AT ROW 17.25 COL 67 COLON-ALIGNED
     v-sum-with-disc-rubl AT ROW 18 COL 67 COLON-ALIGNED
     SPACE(0.62) SKIP(3.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Товары в наборе"
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
          field price-rubl as dec
          field price-base as dec
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

ASSIGN
       v-prim-str:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-str IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1
/* Query rebuild information for BROWSE BROWSE-1
     _TblList          = "Temp-Tables.tt-doc-line-attr,ub.goods WHERE Temp-Tables.tt-doc-line-attr ...,ub.gds-prt WHERE Temp-Tables.tt-doc-line-attr ..."
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _JoinCode[2]      = "ub.goods.gds-code = Temp-Tables.tt-doc-line-attr.gds-code"
     _JoinCode[3]      = "ub.gds-prt.node-code =  Temp-Tables.tt-doc-line-attr.node-code"
     _FldNameList[1]   = ub.goods.artic
     _FldNameList[2]   > "_<CALC>"
"(if gds-prt.node-name <> {&empty-scale} and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name)" "Наименование" "x(35)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[3]   > ub.goods.unit-base
"goods.unit-base" "Ед.!изм." ? "character" ? ? ? ? ? ? no ? no no "3" yes no no "U" "" ""
     _FldNameList[4]   > Temp-Tables.tt-doc-line-attr.attr-value
"tt-doc-line-attr.attr-value" "Количество" "X(10)" "character" ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[5]   > "_<CALC>"
"tt-doc-line-attr.price-base" "Цена в !баз.вал." ">>>>>>9.99" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _FldNameList[6]   > "_<CALC>"
"tt-doc-line-attr.price-rubl" "Цена в {&abbr_rub}" ">>>>>>9.99" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" ""
     _Query            is OPENED
*/  /* BROWSE BROWSE-1 */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Товары в наборе */
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
define variable v-buket-gds-code as integer   no-undo .
define variable v-gds-code as integer   no-undo .
define variable v-prt-code as integer   no-undo .
define variable varartic      like doc-line.artic      initial " " no-undo.
define variable v-exist as logical   no-undo .
define buffer buf_doc-line-attr for ub.doc-line-attr .
define variable s-value as character no-undo .
define variable notes as character no-undo .
define variable lns-cnt as integer   no-undo .

p-make = true .
v-buket-gds-code = p-bk-gds-code .
  run str/chs-gds.w
                ( input parparentproc
                 ,input t-doc.obj-type
                 ,input t-doc.obj-code
                 ,input list-mode
                 ,input t-doc.status_
                 ,input "Для нетоварной позиции" + v-str
                 ,input {&free}
                 ,input t-doc.cli-type
                 ,input t-doc.cli-code
                 ,input t-doc.host-code
                 ,input t-doc.ext-doc-type
                 ,input-output varartic
                 ,output notes
                 ).


if notes = '' then return.
assign
  line-mode = {&add-def}
  prt-rec = ?
  lns-cnt = 1
  .
do while lns-cnt <= num-entries (notes):
  assign
    gds-rec = integer (entry (lns-cnt, notes))
    lns-cnt = lns-cnt + 1.

find first goods no-lock where recid (goods) = gds-rec no-error .
v-gds-code = goods.gds-code.

find first  gds-prt no-lock where  gds-prt.upper-code = goods.prt-root no-error .
if gds-prt.node-name = {&empty-scale} then do:
/* no-scale -------------------------------------------------------------------------------------------------------------*/
   v-prt-code = gds-prt.node-code.
      run lineattr-exist-flora-gds
          ( input   t-doc.doc-code   ,
            input   goods.gds-code   ,
            input   v-prt-code       ,
            input   v-buket-gds-code ,
            output  v-exist          )
            .
      /* есть ли товар в накладной  */
        v-exist = false .
        find first gds-dtl no-lock where
                  gds-dtl.doc-code = t-doc.doc-code   and
                  gds-dtl.artic    = goods.artic      and
                  gds-dtl.prod-type = goods.prod-type and
                  gds-dtl.prod-code = goods.prod-code no-error .

        if available gds-dtl then do:
          assign
          v-exist = true
          .
        end.

        if v-exist = false then do: /* товара нет в накладной */
          run str/out-add.p
          (   parparentproc
             , recid(t-doc)
             , ?
             , ?
             , recid(goods)
             , {&add-def}
             , string(v-buket-gds-code)
              ) no-error.
          if error-status:error then do: next. end.
        end.
        else do: /* товар есть в накладной */
        end.

        find first gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                        gds-dtl.artic     = goods.artic      and
                                        gds-dtl.prod-type = goods.prod-type  and
                                        gds-dtl.prod-code = goods.prod-code  no-error .
        if available gds-dtl then do:
           find first tt-doc-line-attr where
            tt-doc-line-attr.doc-code    = p-doc-code and
            tt-doc-line-attr.gds-code    = v-gds-code and
            tt-doc-line-attr.attr-code   = {&lineattr-flora_gds-code}  + {&comma-char} + string(gds-dtl.prt-code)  + {&comma-char} + string(v-buket-gds-code )
            no-error .
           if not available tt-doc-line-attr then do:
              CREATE tt-doc-line-attr.
              end.
              else do:
              end.
           assign
            tt-doc-line-attr.doc-code    = p-doc-code
            tt-doc-line-attr.gds-code    = v-gds-code
            tt-doc-line-attr.node-code   = gds-dtl.prt-code
            tt-doc-line-attr.attr-value  = if v-exist = true then "1"  else string (gds-dtl.fact-qnty)
            tt-doc-line-attr.attr-code   = {&lineattr-flora_gds-code}  + {&comma-char} + string(tt-doc-line-attr.node-code)  + {&comma-char} + string(v-buket-gds-code )
            tt-doc-line-attr.price-rubl  =  gds-dtl.price-rubl
            tt-doc-line-attr.price-base  =  gds-dtl.price-base
            .
           find first doc-line-attr exclusive-lock where
            doc-line-attr.doc-code    = p-doc-code and
            doc-line-attr.gds-code    = v-gds-code and
            doc-line-attr.attr-code   = {&lineattr-flora_gds-code}  + {&comma-char} + string(gds-dtl.prt-code)  + {&comma-char} + string(v-buket-gds-code )
            no-error .
            if not available doc-line-attr then  create doc-line-attr.

           BUFFER-COPY tt-doc-line-attr  TO doc-line-attr .
        end.
end.
else do:
/* scale ----------------------------------------------------------------------------------------------------------------*/
      /* есть ли товар в накладной ? */
        v-exist = false .
        find first gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                        gds-dtl.artic     = goods.artic      and
                                        gds-dtl.prod-type = goods.prod-type and
                                        gds-dtl.prod-code = goods.prod-code no-error .
        if available gds-dtl then do:
          assign
          v-exist = true
          .
        end.

      if v-exist = false then do: /* товара нет в накладной  и признаков тоже соответственно */
          run str/out-add.p
          (
              parparentproc
             , recid(t-doc)
             , ?
             , ?
             , recid(goods)
             , {&add-def}
             , string(v-buket-gds-code)
              ) no-error.
        if error-status:error then do: next. end.

        for each  gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                        gds-dtl.artic     = goods.artic     and
                                        gds-dtl.prod-type = goods.prod-type and
                                        gds-dtl.prod-code = goods.prod-code  :
          CREATE tt-doc-line-attr.
              assign
              tt-doc-line-attr.doc-code    = p-doc-code
              tt-doc-line-attr.gds-code    = v-gds-code
              tt-doc-line-attr.node-code   = gds-dtl.prt-code
              tt-doc-line-attr.attr-value  = string(gds-dtl.fact-qnty)
              tt-doc-line-attr.attr-code  = {&lineattr-flora_gds-code}  + {&comma-char} + string(tt-doc-line-attr.node-code)  + {&comma-char} + string(v-buket-gds-code )
              tt-doc-line-attr.price-rubl  =  gds-dtl.price-rubl
              tt-doc-line-attr.price-base  =  gds-dtl.price-base

              .
        end.
      end.
      else do:
      /* есть признаки  */
          run str/out-add.p
          (
              parparentproc
             , recid(t-doc)
             , ?
             , ?
             , recid(goods)
             , {&add-def}
             , string(v-buket-gds-code)
              ) no-error.
        if error-status:error then do: next. end.

        for each  doc-line-attr no-lock where
          doc-line-attr.doc-code = t-doc.doc-code   and
          doc-line-attr.gds-code = goods.gds-code   and
          lookup ({&lineattr-flora_gds-code} , doc-line-attr.attr-code)  =  1 and
          lookup ( string(v-buket-gds-code ) , doc-line-attr.attr-code)  =  3 and
          decimal(doc-line-attr.attr-value) <> 0
          :

          find first tt-doc-line-attr where
              tt-doc-line-attr.doc-code    = doc-line-attr.doc-code  and
              tt-doc-line-attr.gds-code    = doc-line-attr.gds-code  and
              tt-doc-line-attr.attr-code   = doc-line-attr.attr-code no-error .
          if not available tt-doc-line-attr then     CREATE tt-doc-line-attr.
          find first gds-dtl no-lock where gds-dtl.doc-code = t-doc.doc-code   and
                                          gds-dtl.prt-code = integer (entry(2, doc-line-attr.attr-code))      and
                                          gds-dtl.artic     = goods.artic      and
                                          gds-dtl.prod-type = goods.prod-type and
                                          gds-dtl.prod-code = goods.prod-code no-error .
              assign
                tt-doc-line-attr.doc-code    = doc-line-attr.doc-code
                tt-doc-line-attr.gds-code    = doc-line-attr.gds-code
                tt-doc-line-attr.node-code   = integer (entry(2, doc-line-attr.attr-code))
                tt-doc-line-attr.attr-value  = doc-line-attr.attr-value
                tt-doc-line-attr.attr-code   = doc-line-attr.attr-code
                tt-doc-line-attr.price-rubl  =  gds-dtl.price-rubl
                tt-doc-line-attr.price-base  =  gds-dtl.price-base

              .
        end.
      end.
end.
end.

{&OPEN-QUERY-BROWSE-1}
run re-disp in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
if not available tt-doc-line-attr then return .
define variable v-qnty as character no-undo .
define variable v-qnty-old as character no-undo .
 v-qnty =  tt-doc-line-attr.attr-value .
 v-qnty-old =  tt-doc-line-attr.attr-value .
run gbl/d-prompt.w
(       'title=':u + "Изменение количества товара" + '\':u
      + 'text1=':u + "Количество" + (if gds-prt.node-name <> {&empty-scale} and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name) + '\':u
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
      run re-disp in this-procedure .
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
   "Удалять товар : " (if gds-prt.node-name <> {&empty-scale} and gds-prt.upper-code <> goods.prt-root then goods.gds-name + ' - ' + gds-prt.f-name else goods.gds-name)
   " из набора : " v-str "?"
   view-as alert-box question
   buttons yes-no
   update v-d as log

   .
   if v-d = true then do:
      delete tt-doc-line-attr.
      run re-disp in this-procedure .
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

    define variable v-ok as logical   no-undo .
    { str/grpnabor.i p-bk-gds-code  v-ok }
    if v-ok = false then do:
      message "Это не набор !" view-as alert-box information .
      return  .
    end.

  v-itogo-rubl:LABEL = "Итого ({&abbr_rub})" .
  v-sum-with-disc-rubl:LABEL = "{&abbr_rub}." .

  run init-proc.
  run enable_ui.
  run re-disp.
  if p-doc-mode =  {&lookup} then disable b-add b-chg b-del with frame {&frame-name} .
  wait-for go of frame {&frame-name}.
end.
run disable_ui.

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
  DISPLAY v-prim-str v-str v-pr-wrk v-itogo-base v-pr-sk v-itogo-rubl text-1
          v-sum-with-disc-base v-sum-with-disc-rubl
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-add B-chg B-del B-Help BROWSE-1 v-prim-str v-str v-pr-wrk
         v-itogo-base v-pr-sk v-itogo-rubl text-1 v-sum-with-disc-base
         v-sum-with-disc-rubl
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
find first bk_goods where bk_goods.gds-code  = p-bk-gds-code   no-error .
if error-status :error then return error .
define buffer ready_trn-doc for trn-doc.
define buffer nakl_trn-doc for trn-doc.

define variable p-type     as character no-undo .
v-prim-str = "" .
v-pr-sk = t-doc.discnt-pc.

if t-doc.status_ = {&ready}  or
   t-doc.status_ = {&rejected}
  then do:
    run lineattr-value   (
        input  t-doc.doc-code ,
        input  p-bk-gds-code ,
        input  {&lineattr-flora_ps}     ,
        output v-prim-str    ,
        output p-type     ).
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-deliv}
        v-sum-deliv
        p-type
    }
    { str/tdat-val.i
        t-doc.doc-code
        {&trdcattr-sumwrk}
        v-pr-wrk
        p-type
    }

      find first nakl_trn-doc no-lock where nakl_trn-doc.out-code = t-doc.doc-code no-error .
      if error-status :error then return error .
      p-doc-code = nakl_trn-doc.doc-code .
  end.
  else do:
    find first ready_trn-doc no-lock where ready_trn-doc.doc-code = t-doc.doc-code no-error .
    if available ready_trn-doc then do:
        run lineattr-value   (
            input  ready_trn-doc.doc-code ,
            input  p-bk-gds-code ,
            input  {&lineattr-flora_ps}     ,
            output v-prim-str    ,
            output p-type     ).
    { str/tdat-val.i
        ready_trn-doc.doc-code
        {&trdcattr-deliv}
        v-sum-deliv
        p-type
    }
    { str/tdat-val.i
        ready_trn-doc.doc-code
        {&trdcattr-sumwrk}
        v-pr-wrk
        p-type
    }
   end.
    p-doc-code =  t-doc.doc-code .
  end.
display
  v-prim-str
  v-pr-wrk

with frame {&frame-name} .

define variable v-ok as logical   no-undo .

define buffer prt_goods for goods.
define buffer b2_doc-line-attr for doc-line-attr.
for each gds-dtl no-lock  where gds-dtl.doc-code  = p-doc-code :
  find first prt_goods no-lock where
            prt_goods.artic     = gds-dtl.artic       and
            prt_goods.prod-type = gds-dtl.prod-type   and
            prt_goods.prod-code = gds-dtl.prod-code   no-error .
   find first b2_doc-line-attr no-lock where b2_doc-line-attr.doc-code = p-doc-code         and
                                             b2_doc-line-attr.gds-code = prt_goods.gds-code  and
                                             num-entries(b2_doc-line-attr.attr-code) = 3    no-error .
    { str/grpnabor.i prt_goods.gds-code  v-ok }
    if v-ok = true then next.
    create  temp-gds-dtl .
    assign
    temp-gds-dtl.node-code  = gds-dtl.prt-code
    temp-gds-dtl.artic     = prt_goods.artic
    temp-gds-dtl.prod-type = prt_goods.prod-type
    temp-gds-dtl.prod-code = prt_goods.prod-code
    temp-gds-dtl.gds-code  = prt_goods.gds-code
    temp-gds-dtl.rel-bk    = if available b2_doc-line-attr then true else false
    .
end.


v-str = bk_goods.artic + " " + bk_goods.gds-name .

define buffer buf_doc-line-attr for doc-line-attr.
define buffer buf_gds-dtl for gds-dtl.
define buffer buf_goods   for goods.

        for each buf_doc-line-attr no-lock
          where buf_doc-line-attr.doc-code  = p-doc-code
            and lookup ({&lineattr-flora_gds-code} , buf_doc-line-attr.attr-code ) > 0
            and lookup (string(p-bk-gds-code)      , buf_doc-line-attr.attr-code ) > 0
            :
            if integer (entry( 3 , buf_doc-line-attr.attr-code)) <> p-bk-gds-code then next.
              find first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code no-error .
              find first  buf_gds-dtl no-lock where
                          buf_gds-dtl.doc-code  = p-doc-code          and
                          buf_gds-dtl.artic     = buf_goods.artic     and
                          buf_gds-dtl.prod-type = buf_goods.prod-type and
                          buf_gds-dtl.prod-code = buf_goods.prod-code and
                          buf_gds-dtl.prt-code  = integer ( entry (2 , buf_doc-line-attr.attr-code))
                          .
              if available buf_gds-dtl then do:
                create tt-doc-line-attr.
                BUFFER-COPY buf_doc-line-attr TO tt-doc-line-attr.
                assign
                  tt-doc-line-attr.node-code  = integer ( entry (2 , buf_doc-line-attr.attr-code))
                  tt-doc-line-attr.price-rubl = buf_gds-dtl.price-rubl
                  tt-doc-line-attr.price-base = buf_gds-dtl.price-base
                .
                if t-doc.status_ = {&fact} then
                assign
                   tt-doc-line-attr.price-rubl = buf_gds-dtl.price-rubl  -    buf_gds-dtl.discnt-rubl
                   tt-doc-line-attr.price-base = buf_gds-dtl.price-base  -    buf_gds-dtl.discnt-base

                .






              end.

        end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE re-disp Dialog-Frame
PROCEDURE re-disp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  v-itogo-base = 0
  v-itogo-rubl = 0
.
   for each tt2-doc-line-attr :
      assign
        v-itogo-base = (tt2-doc-line-attr.price-base * dec(tt2-doc-line-attr.attr-value))  + v-itogo-base
        v-itogo-rubl = (tt2-doc-line-attr.price-rubl * dec(tt2-doc-line-attr.attr-value))  + v-itogo-rubl
    .

   end.

define variable v-itogo-base2 as decimal   no-undo .
define variable v-itogo-rubl2 as decimal   no-undo .

v-itogo-base2 = v-itogo-base - (v-itogo-base * t-doc.discnt-pc / 100 ) .
v-itogo-rubl2 = v-itogo-rubl - (v-itogo-rubl * t-doc.discnt-pc / 100 ) .

IF t-doc.status_ = {&fact} THEN DO:
  v-sum-with-disc-base = v-itogo-base2 .
  v-sum-with-disc-rubl = v-itogo-rubl2 .
END.
ELSE DO:
  v-sum-with-disc-base = v-itogo-base2 +  (v-pr-wrk  ) * v-itogo-base2 / 100 .
  v-sum-with-disc-rubl = v-itogo-rubl2 +  (v-pr-wrk  ) * v-itogo-rubl2 / 100 .
END.



display
  v-prim-str
  v-pr-wrk

  v-sum-with-disc-rubl  when t-doc.status_ <> {&fact}
  v-sum-with-disc-base  when t-doc.status_ <> {&fact}
  v-itogo-base
  v-itogo-rubl
  v-pr-sk
  WITH FRAME {&FRAME-NAME}.
  if  t-doc.status_ =  {&fact} then
  hide v-sum-with-disc-rubl
       v-sum-with-disc-base
       text-1
       in frame {&frame-name} .

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
  for each buf_doc-line-attr exclusive-lock
    where buf_doc-line-attr.doc-code  = p-doc-code
      and lookup ({&lineattr-flora_gds-code} , buf_doc-line-attr.attr-code ) > 0
      and lookup (string(p-bk-gds-code)      , buf_doc-line-attr.attr-code ) > 0
      :
        if integer (entry( 3 , buf_doc-line-attr.attr-code)) <> p-bk-gds-code then next.
        find first tt-doc-line-attr where
                      tt-doc-line-attr.doc-code = buf_doc-line-attr.doc-code
                  and tt-doc-line-attr.gds-code = buf_doc-line-attr.gds-code
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

define buffer ready_trn-doc for trn-doc.
define buffer nakl_trn-doc for trn-doc.

find first nakl_trn-doc  no-lock where nakl_trn-doc.doc-code  = p-doc-code no-error .
if nakl_trn-doc.status_ = {&inquiry} then return .

find first ready_trn-doc no-lock where ready_trn-doc.doc-code = nakl_trn-doc.out-code no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ-щепка в статусе ГОТОВ"
      view-as alert-box error .
    return error.
  end.


for each gds-dtl exclusive-lock where gds-dtl.doc-code  = p-doc-code ,
    first temp-gds-dtl where
        temp-gds-dtl.artic     = gds-dtl.artic and
        temp-gds-dtl.prod-type = gds-dtl.prod-type and
        temp-gds-dtl.prod-code = gds-dtl.prod-code and
        temp-gds-dtl.node-code = gds-dtl.prt-code and
        temp-gds-dtl.rel-bk = true
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
                input   temp-gds-dtl.gds-code   ,
                input   gds-dtl.prt-code  ,
                input   buf2_goods.gds-code    ,
                input   {&lineattr-flora_gds-code}        ,
                output  v-qnty       ).
            v-qnty-prt = v-qnty-prt + v-qnty .
            /* message v-qnty "кол-во по букету". */
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
           assign line-mode = {&update}.
            run str/out-add.p
            (  parparentproc
             , recid(t-doc)
             , recid(doc-line)
             , recid(gds-dtl)
             , recid(buf2_goods)
             , "delete"
             , ? ).

         end.
    end.
end.


p-sum1 = v-sum-with-disc-rubl .
p-sum2 = v-sum-with-disc-base .


end.
end procedure. /* save-proc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME