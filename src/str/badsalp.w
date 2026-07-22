&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
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

Отрицательные партии по продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/04/05
Author: Bakhtadze Natalya
Creation date: 10/04/05

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-doc-rec  as recid no-undo .
define input parameter p-gds-rec as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Отрицательные партии по продаже" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/waitfram.i }
{ str/trdcalib.i }

DEFINE VARIABLE doc-line-rec as recid no-undo.
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable gds-rec as recid no-undo .
DEFINE BUFFER buf_sale-doc FOR ub.sale-doc.
define buffer buf_inkas for ub.inkas.

/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-badprts

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_sale-doc ub.doc-line ub.parts ub.goods ~
ub.gds-obj

/* Definitions for BROWSE BR-badprts                                    */
&Scoped-define FIELDS-IN-QUERY-BR-badprts ub.goods.negative-rest ub.doc-line.artic ub.goods.gds-name ub.goods.unit-base ub.doc-line.fact-qnty ub.doc-line.doc-qnty ub.parts.fact-qnty ub.gds-obj.fact-qnty ub.gds-obj.free-qnty ub.parts.out-code ub.parts.status_ ub.parts.rsrv-free
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-badprts
&Scoped-define SELF-NAME BR-badprts
&Scoped-define QUERY-STRING-BR-badprts FOR EACH buf_sale-doc WHERE     buf_sale-doc.inkas-code = buf_inkas.inkas-code     AND buf_sale-doc.doc-kind <> {&sale-add-return-write-off}, ~
                                   EACH ub.doc-line NO-LOCK       WHERE ub.doc-line.doc-code = buf_sale-doc.doc-code, ~
             EACH ub.parts WHERE ub.parts.artic = ub.doc-line.artic   AND ub.parts.prod-type = ub.doc-line.prod-type  AND  ub.parts.prod-code = ub.doc-line.prod-code       AND ub.parts.obj-type = buf_sale-doc.obj-type  AND ub.parts.obj-code = buf_sale-doc.obj-code  AND ub.parts.out-code = buf_sale-doc.doc-code  AND ub.parts.out-code = parts.in-code NO-LOCK, ~
             first ub.goods NO-LOCK WHERE           ub.goods.artic = ub.doc-line.artic      AND  ub.goods.prod-type = ub.doc-line.prod-type      AND  ub.goods.prod-code = ub.doc-line.prod-code, ~
            FIRST ub.gds-obj NO-LOCK where           ub.gds-obj.obj-type = ub.doc-line.obj-type     AND ub.gds-obj.obj-code = ub.doc-line.obj-code     AND ub.gds-obj.artic = ub.doc-line.artic     AND  ub.gds-obj.prod-type = ub.doc-line.prod-type      AND  ub.gds-obj.prod-code = ub.doc-line.prod-code
&Scoped-define OPEN-QUERY-BR-badprts OPEN QUERY {&SELF-NAME} FOR EACH buf_sale-doc WHERE     buf_sale-doc.inkas-code = buf_inkas.inkas-code     AND buf_sale-doc.doc-kind <> {&sale-add-return-write-off}, ~
                                   EACH ub.doc-line NO-LOCK       WHERE ub.doc-line.doc-code = buf_sale-doc.doc-code, ~
             EACH ub.parts WHERE ub.parts.artic = ub.doc-line.artic   AND ub.parts.prod-type = ub.doc-line.prod-type  AND  ub.parts.prod-code = ub.doc-line.prod-code       AND parts.obj-type = buf_sale-doc.obj-type  AND parts.obj-code = buf_sale-doc.obj-code  AND ub.parts.out-code = buf_sale-doc.doc-code  AND ub.parts.out-code = parts.in-code NO-LOCK, ~
             first ub.goods NO-LOCK WHERE           ub.goods.artic = ub.doc-line.artic      AND  ub.goods.prod-type = ub.doc-line.prod-type      AND  ub.goods.prod-code = ub.doc-line.prod-code, ~
            FIRST ub.gds-obj NO-LOCK where           ub.gds-obj.obj-type = ub.doc-line.obj-type     AND ub.gds-obj.obj-code = ub.doc-line.obj-code     AND ub.gds-obj.artic = ub.doc-line.artic     AND  ub.gds-obj.prod-type = ub.doc-line.prod-type      AND  ub.gds-obj.prod-code = ub.doc-line.prod-code.
&Scoped-define TABLES-IN-QUERY-BR-badprts buf_sale-doc ub.doc-line ub.parts ~
ub.goods ub.gds-obj
&Scoped-define FIRST-TABLE-IN-QUERY-BR-badprts buf_sale-doc
&Scoped-define SECOND-TABLE-IN-QUERY-BR-badprts ub.doc-line
&Scoped-define THIRD-TABLE-IN-QUERY-BR-badprts ub.parts
&Scoped-define FOURTH-TABLE-IN-QUERY-BR-badprts ub.goods
&Scoped-define FIFTH-TABLE-IN-QUERY-BR-badprts ub.gds-obj


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-badprts}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel b-print b-list b-help BR-badprts ~
FILL-INFO prod-name
&Scoped-Define DISPLAYED-OBJECTS FILL-INFO prod-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-list
     LABEL "&Список"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Выход "
     SIZE 10 BY 1
     BGCOLOR 8 FGCOLOR 0 .

DEFINE VARIABLE FILL-INFO AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 76.38 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE prod-name AS CHARACTER FORMAT "X(40)"
      VIEW-AS TEXT
     SIZE 50 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-badprts FOR
      buf_sale-doc,
      ub.doc-line,
      ub.parts,
      ub.goods,
      ub.gds-obj SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-badprts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-badprts Dialog-Frame _FREEFORM
  QUERY BR-badprts NO-LOCK DISPLAY
      ub.goods.negative-rest COLUMN-LABEL "-ост." FORMAT "+/-":U
      ub.doc-line.artic FORMAT "X(16)":U
      ub.goods.gds-name FORMAT "X(48)":U
      ub.goods.unit-base COLUMN-LABEL "Изм." FORMAT "X(3)":U
      ub.doc-line.fact-qnty COLUMN-LABEL "Продано" FORMAT "->>,>>>,>>9.999":U
      ub.doc-line.doc-qnty COLUMN-LABEL "Зарезерв." FORMAT "->>,>>>,>>9.999":U
      ub.parts.fact-qnty COLUMN-LABEL "Из них в -ост." FORMAT "->>,>>>,>>9.999":U
      ub.gds-obj.fact-qnty FORMAT "->>,>>>,>>9.<<<":U
      ub.gds-obj.free-qnty COLUMN-LABEL "Свободно(кол-во)" FORMAT "->>,>>>,>>9.<<<":U
      ub.parts.out-code FORMAT "X(14)":U
      ub.parts.status_ FORMAT "yes/no":U
      ub.parts.rsrv-free FORMAT "yes/no":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 12.25
         BGCOLOR 15  ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     b-print AT ROW 1 COL 21
     b-list AT ROW 1 COL 31
     b-help AT ROW 1 COL 85
     BR-badprts AT ROW 4.5 COL 1
     FILL-INFO AT ROW 2.5 COL 1.75 NO-LABEL
     prod-name AT ROW 3.5 COL 1 NO-LABEL
     SPACE(48.00) SKIP(12.25)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE ""
         CANCEL-BUTTON Btn_Cancel.


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
                                                                        */
/* BROWSE-TAB BR-badprts b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-INFO IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN prod-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-badprts
/* Query rebuild information for BROWSE BR-badprts
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH buf_sale-doc WHERE
    buf_sale-doc.inkas-code = buf_inkas.inkas-code
    AND buf_sale-doc.doc-kind <> {&sale-add-return-write-off},
                            EACH ub.doc-line NO-LOCK
      WHERE doc-line.doc-code = buf_sale-doc.doc-code,
      EACH parts WHERE ub.parts.artic = ub.doc-line.artic
  AND ub.parts.prod-type = ub.doc-line.prod-type
 AND  ub.parts.prod-code = ub.doc-line.prod-code
      AND ub.parts.obj-type = buf_sale-doc.obj-type
 AND ub.parts.obj-code = buf_sale-doc.obj-code
 AND ub.parts.out-code = buf_sale-doc.doc-code
 AND ub.parts.out-code = ub.parts.in-code NO-LOCK,
      first ub.goods NO-LOCK WHERE
          ub.goods.artic = ub.doc-line.artic
     AND  ub.goods.prod-type = ub.doc-line.prod-type
     AND  ub.goods.prod-code = ub.doc-line.prod-code,
     FIRST ub.gds-obj NO-LOCK where
          ub.gds-obj.obj-type = ub.doc-line.obj-type
    AND ub.gds-obj.obj-code = ub.doc-line.obj-code
    AND ub.gds-obj.artic = ub.doc-line.artic
    AND  ub.gds-obj.prod-type = ub.doc-line.prod-type
     AND  ub.gds-obj.prod-code = ub.doc-line.prod-code.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Where[1]         = "ub.doc-line.doc-code = buf_sale-doc.doc-code"
     _JoinCode[2]      = "ub.parts.artic = ub.doc-line.artic
  AND ub.parts.prod-type = ub.doc-line.prod-type
 AND  ub.parts.prod-code = ub.doc-line.prod-code"
     _Where[2]         = "ub.parts.obj-type = buf_sale-doc.obj-type
 AND ub.parts.obj-code = buf_sale-doc.obj-code
 AND ub.parts.out-code = buf_sale-doc.doc-code
 AND ub.parts.out-code = ub.parts.in-code"
     _Query            is OPENED
*/  /* BROWSE BR-badprts */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX Dialog-Frame
/* Query rebuild information for DIALOG-BOX Dialog-Frame
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX Dialog-Frame */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-list Dialog-Frame
ON CHOOSE OF b-list IN FRAME Dialog-Frame /* Список */
DO:
      doc-line-rec = recid(ub.doc-line).
      DO WHILE available ub.doc-line :
            GET prev br-badprts.
      END.
      run PrintProc in this-procedure ( input "L" ).
      run str/gds-list.w ( input parparentproc
                         , input buf_inkas.host-code
                         , input buf_inkas.obj-type
                         , input buf_inkas.obj-code).
      reposition br-badprts to recid doc-line-rec no-error.
      apply "entry" to br-badprts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
      doc-line-rec = recid(ub.doc-line).
      DO WHILE available doc-line :
            GET prev br-badprts.
      END.
      run PrintProc in this-procedure ( input "P").
      reposition br-badprts to recid doc-line-rec no-error.
      apply "entry" to br-badprts in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-badprts
&Scoped-define SELF-NAME BR-badprts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-badprts Dialog-Frame
ON VALUE-CHANGED OF BR-badprts IN FRAME Dialog-Frame
DO:
    if not available ub.goods then do:
        return no-apply.
    end.
    FIND FIRST ub.clients where ub.clients.obj-type = ub.goods.prod-type AND ub.clients.obj-code = goods.prod-code
    NO-LOCK NO-ERROR.
    IF avail ub.clients then assign prod-name = "Пр-ль: " + ub.clients.obj-name.
    else prod-name = "".
    display prod-name with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_Cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_Cancel Dialog-Frame
ON CHOOSE OF Btn_Cancel IN FRAME Dialog-Frame /* Выход  */
DO:
    FOR EACH gds-list:
        DELETE gds-list.
    END.
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

{ gbl/f2.i br-badprts }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find FIRST buf_inkas where recid (buf_inkas) = p-doc-rec no-lock no-error.

  RUN enable_UI.
  run waitfram-show in this-procedure ( input "Ждите...").
  FOR EACH gds-list :
      delete gds-list .
  END .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = buf_inkas.inkas-code:
     if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then NEXT.
      if CAN-FIND(First doc-line where doc-line.doc-code = buf_sale-doc.doc-code AND
                                   doc-line.doc-qnty < doc-line.fact-qnty) then do:
      run waitfram-hide in this-procedure .
      FILL-INFO = "Данные неполные - не на весь проданный товар выделен резерв!!!".
      DISPLAY FILL-INFO with frame {&Frame-name}.
    end.
  end.
  run waitfram-hide in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

{ gbl/mv-clmn.i
&browse-name = "br-badprts"
&frame-name = "{&frame-name}"
&ext-col = 10
&start-column = 4}

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
  DISPLAY FILL-INFO prod-name
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel b-print b-list b-help BR-badprts FILL-INFO prod-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
frame {&frame-name}:title = substitute("&1&2 продажа &3: отрицательные партии в результате закрытия"
                             , buf_inkas.obj-type, buf_inkas.obj-code, buf_inkas.inkas-code) .

br-badprts:NUM-LOCKED-COLUMNS = 3.
DISPLAY FILL-INFO prod-name
WITH FRAME {&FRAME-NAME}.
ENABLE
Btn_Cancel
b-print
b-list
b-help
br-badprts
FILL-INFO
prod-name
WITH FRAME {&FRAME-NAME}.
VIEW FRAME {&FRAME-NAME}.
run waitfram-show in this-procedure ( input "Ждите...").
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
APPLY "ENTRY" TO br-badprts.
APPLY "VALUE-CHANGED" to br-badprts.
run waitfram-hide in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER pmode as character.
define variable sym1   as char format "X(1)" init ":".
define variable sym10 as char format "X(1)" init ":".
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable for-price-base as decimal.
define variable for-price-rubl as decimal.
define variable accum-count as integer.
define variable accum-qnty as decimal.
define variable accum-price-base as decimal.
define variable accum-price-rubl as decima.
define variable i as integer no-undo.

DEFINE FRAME Parts-List
sym1                     column-label ""                    format "X(1)" space(0)
ub.doc-line.artic         column-label "Артикул"
ub.goods.gds-name   column-label "Название товара" format "X(35)"
ub.goods.unit-base COLUMN-LABEL "Изм."
ub.parts.fact-qnty COLUMN-LABEL "По партии в -ост."
ub.parts.price-base COLUMn-LABEL "Учетн.цена!баз.вал."
for-price-base COLUMn-LABEL "Сумма в!учетн.ценах!баз.вал."   FORMAT "->>>,>>>,>>9.99"
ub.parts.price-rubl COLUMn-LABEL "Учетн.цена!{&abbr_rub}."
for-price-rubl COLUMn-LABEL "Сумма в!учетн.ценах!{&abbr_rub}."        FORMAT "->>>,>>>,>>9.99"
ub.parts.out-code COLUmn-LABEL "Документ"
sym10                    column-label " "                   format "X(1)"
HEADER  date_string AT 5 format "X(35)"
            string( "Страница " ) format "X(9)" AT 115 PAGE-NUMBER AT 125 FORMAT ">>9" SKIP
            Line format "X(177)" AT 1
with width {&DOS_CW_2} down stream-io use-text    .

Line = fill("-", 150).
date_string = cur-time-print() .

IF pmode = "P" then do:
   run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&LS_PS_A4}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).
    PUT  STREAM prnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(90)" SKIP(1) .
    FORM HEADER
            Line format "X(150)" AT 1 SKIP
            "Продолжение - на следующей странице" AT 30 SKIP
            with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM prnLibStream FRAME BottomFrame .
    FORM with FRAME Parts-List  .
END.
    run waitfram-show in this-procedure ( input "Ждите...").
    GET next br-badprts.
    i = 0 .
    DO WHILE available doc-line :
      IF pmode = "P" then do:
        Display STREAM prnLibStream
        sym1
        doc-line.artic
        goods.gds-name
        goods.unit-base
        parts.fact-qnty
        parts.price-base
        parts.price-base * parts.fact-qnty @ for-price-base
        parts.price-rubl
        parts.price-rubl * parts.fact-qnty @ for-price-rubl
        parts.out-code
        sym10
        with FRAME Parts-List .
        DOWN STREAM prnLibStream 1 with FRAME Parts-List  .
        assign
        accum-count = accum-count + 1
        accum-qnty = accum-qnty + parts.fact-qnty
        accum-price-base = accum-price-base + parts.price-base * parts.fact-qnty
        accum-price-rubl = accum-price-rubl + parts.price-rubl * parts.fact-qnty.
      END.   /*pmode = P*/
      ELSE do:
         { cmp/gds-list.i gds-list assign }
      END.
        GET next br-badprts.
    END.
    IF pmode = "P" then do:
      UNDERLINE  STREAM prnLibStream
      sym1
      doc-line.artic
      goods.gds-name
      goods.unit-base
      parts.fact-qnty
      parts.price-base
      for-price-base
      parts.price-rubl
      for-price-rubl
      parts.out-code
      sym10
      with FRAME Parts-List .

    DISPLAY STREAM prnLibStream
    "ИТОГО"  @ doc-line.artic
    "-партий: " + string(accum-count) @ goods.gds-name
    accum-qnty @ parts.fact-qnty
    accum-price-base @ for-price-base
    accum-price-rubl @ for-price-rubl
    with frame Parts-List.
    HIDE  STREAM prnLibStream FRAME BottomFrame .
    HIDE  STREAM prnLibStream FRAME CheckList.
    output  STREAM prnLibStream CLOSE.
/*
       assign
             g#rep-tblname = ""
             g#rep-tblrid = -117
             g#rep-updflds = string( "Список -партий по продаже " + t-doc-code + "|" ) .
*/
    END. /*pmode = P*/

    run waitfram-hide in this-procedure .
    if pmode = "P" then
    run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 8
                                          ).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME