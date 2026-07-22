&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DLGOKCAN
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DLGOKCAN

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список на отгрузку.

Автор: Демин Алексей Сергеевич
Дата создания: 09/08/05
Author: Alexey Demin
Creation date: 09/08/05

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter Record-Id            as recid            no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список на отгрузку.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ gbl/getcntxt.i def }
{ cmp/showinf.i  }

/* Local Variable Definitions ---                                       */

def     buffer  cli-prod        for     clients .
def     buffer  bR-trn-doc   for     trn-doc .

define variable Log-Res1       as      log         no-undo.
define variable Log-Res2       as      log         no-undo.

define variable sym0 as char init ":"   no-undo.
define variable sym1 as char init ":"   no-undo.
define variable sym2 as char init ":"   no-undo.
define variable sym3 as char init ":"   no-undo.
define variable sym4 as char init ":"   no-undo.
define variable sym5 as char init ":"   no-undo.
define variable sym6 as char init ":"   no-undo.
define variable sym7 as char init ":"   no-undo.

define variable  Line               as    char   no-undo.
define variable  tb-code          as    char   no-undo.
define variable  rsrv-FactDate  as  date    no-undo .

define variable  ind                            as    int                no-undo.
define variable rootnode_code        as      integer       no-undo.

def stream RepStr .
def stream  i_inp1.

    define variable  InputFileName    as  char    no-undo.
    define variable  text-string            as  char    FORMAT "x({&DOS_CW_2})" no-undo .

    define variable g#report-num    as integer      no-undo.
    define variable g#quest-print   as logical      no-undo.
    define variable g#log           as logical      no-undo.

DEFINE WORK-TABLE doc-recids no-undo
    field   DocRecid    as  recid
    field   doc-code     like trn-doc.doc-code
    .

def FRAME DocsList
        sym0 column-label ":!:" format "X(1)"
        ind column-label "N!п/п" format ">>9"
        sym1 column-label ":!:" format "X(1)"
        trn-doc.rsrv-date column-label "Дата!отгрузки" format "99/99/9999"
        sym2 column-label ":!:" format "X(1)"
        trn-doc.doc-code column-label "Номер!документа" format "X(11)"
        sym3 column-label ":!:" format "X(1)"
        trn-doc.cli-name column-label "Контрагент! " format "X(60)"
        sym4 column-label ":!:" format "X(1)"
        trn-doc.doc-qnty column-label "Количество! " format "->>,>>>,>>9.999"
        sym5 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 100 PAGE-NUMBER( RepStr ) AT 110 FORMAT ">>9" SKIP
        Line format "X(115)" AT 1
    with width {&A4_CW} down stream-io NO-BOX.

DEFINE FRAME GoodsList
        sym1 column-label ":!:" format "X(1)"
        ind column-label "N!п/п" format ">>9"
        sym3 column-label ":!:" format "X(1)"
        doc-line.artic column-label "Артикул! " format "X(20)"
        sym4 column-label ":!:" format "X(1)"
        goods.gds-name column-label "Название товара! " format "X(50)"
        sym2 column-label ":!:" format "X(1)"
        tb-code column-label "Код! " format "x({&BarCode_Length})"
        sym5 column-label ":!:" format "X(1)"
        goods.unit-base column-label "Единица!измерения" format "X(9)"
        sym6 column-label ":!:" format "X(1)"
        doc-line.doc-qnty column-label "Количество!единиц" format ">>>,>>>,>>9.99"
        sym7 column-label ":!:" format "X(1)"
    HEADER
        cur-time-print() AT 5 format "X(35)"
            "Страница " AT 110 PAGE-NUMBER ( RepStr ) AT 120 FORMAT ">>9" SKIP
        Line format "X(125)" AT 1
    with width {&A4_CW} down stream-io .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DLGOKCAN

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help RECT-1 startdate ~
Repeated NotPrint-GdsList
&Scoped-Define DISPLAYED-OBJECTS startdate Repeated NotPrint-GdsList

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "&Помощь":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK
     LABEL "&Ввод ":L
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE startdate AS DATE FORMAT "99/99/9999":U
     LABEL "Введите дату отгрузки"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 46.5 BY 6.75.

DEFINE VARIABLE NotPrint-GdsList AS LOGICAL INITIAL no
     LABEL "Не выводить список товаров на отгрузку"
     VIEW-AS TOGGLE-BOX
     SIZE 42.5 BY .75 NO-UNDO.

DEFINE VARIABLE Repeated AS LOGICAL INITIAL no
     LABEL "Повторно в набор"
     VIEW-AS TOGGLE-BOX
     SIZE 18.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DLGOKCAN
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     startdate AT ROW 3.5 COL 25 COLON-ALIGNED
     Repeated AT ROW 5.5 COL 15
     NotPrint-GdsList AT ROW 7.5 COL 4
     RECT-1 AT ROW 2.5 COL 1.5
     SPACE(1.12) SKIP(0.57)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS THREE-D  SCROLLABLE
         BGCOLOR 8 FGCOLOR 0
         TITLE BGCOLOR 8 FGCOLOR 1 "Отправить в набор":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DLGOKCAN
   UNDERLINE                                                            */
ASSIGN
       FRAME DLGOKCAN:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK DLGOKCAN
ON CHOOSE OF Btn_OK IN FRAME DLGOKCAN /* Ввод  */
DO:
    assign startdate Repeated NotPrint-GdsList .
    FOR EACH doc-recids :
        delete doc-recids .
    END.
    if can-find( first trn-doc WHERE trn-doc.obj-type = v-cntxt-obj-type AND
                                     trn-doc.obj-code = v-cntxt-obj-code AND
                                     trn-doc.rsrv-date = startdate AND
                                     trn-doc.doc-type = {&expense} AND
                                     trn-doc.status_ = {&permitted} AND
                                     trn-doc.flag_ )
                                     OR
       can-find( first trn-doc WHERE recid( trn-doc ) = Record-Id AND ( not trn-doc.flag_ ) ) then
        do:
            RUN main_proc.
            if return-value <> "Bad-Reading"
            then do:
                { rep/q-print.i 0 }
            end.
        end.
    else
        message "Нет ни одного документа," skip
                        "подготовленного к отгрузке" skip
                        "на текущем объекте" skip
                        "в указанный Вами день."
                        view-as alert-box information buttons ok .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME NotPrint-GdsList
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL NotPrint-GdsList DLGOKCAN
ON VALUE-CHANGED OF NotPrint-GdsList IN FRAME DLGOKCAN /* Не выводить список товаров на отгрузку */
DO:
    assign NotPrint-GdsList .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DLGOKCAN


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
assign startdate = v-today .

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    { gbl/getcntxt.i get " " p-mainmenu-handle }
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).
    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).

    RUN enable_UI.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_composition-reprint_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      Log-Res1
    }
    if not Log-Res1
    then do:
        DISABLE Repeated WITH FRAME DLGOKCAN.
    end.

    { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_composition-print_print':U
      {&cntxt-firm}
      v-cntxt-host-code-obj
      '':U
      0
      0
      0
      0
      false
      Log-Res2
    }

    if not ( Log-Res1 OR Log-Res2 )
    then do:
            message
                "У Вас недостаточно ПРАВ" skip
                "для выполнения данного действия." skip
                "Обратитесь к администратору" skip
                "системы." view-as alert-box error.
            LEAVE MAIN-BLOCK .
    end.

    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DLGOKCAN  _DEFAULT-DISABLE
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
  HIDE FRAME DLGOKCAN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DLGOKCAN  _DEFAULT-ENABLE
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
  DISPLAY startdate Repeated NotPrint-GdsList
      WITH FRAME DLGOKCAN.
  ENABLE Btn_OK Btn_Cancel b-help RECT-1 startdate Repeated NotPrint-GdsList
      WITH FRAME DLGOKCAN.
  {&OPEN-BROWSERS-IN-QUERY-DLGOKCAN}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE main_proc DLGOKCAN
PROCEDURE main_proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

define buffer b-trn-doc for trn-doc .

    { gbl/working.i }
    Line = fill( "-", 140) .

    output stream RepStr to value( string( session:temp-directory +
                                     {&PLT_Name} + string( g#report-num ) ) ) page-size {&CS_PS} .

    FIND clients WHERE clients.obj-type = v-cntxt-obj-type AND
                                       clients.obj-code = v-cntxt-obj-code NO-LOCK .
    FORM HEADER
                Line format "X(115)" AT 1 SKIP
                "Продолжение - на следующей странице" AT 30 SKIP
                with FRAME BottomFrame-1 width {&A4_CW} PAGE-BOTTOM no-labels no-box.
    VIEW stream RepStr FRAME BottomFrame-1 .
    PUT stream RepStr space(10) CAPS( clients.obj-name ) format "x(100)" SKIP(1) .
    PUT stream RepStr space(30) string( "Список документов на отгрузку за " +
            string( ( if Repeated then rsrv-FactDate else startdate ), "99/99/9999" ) + "." )
            format "x(100)" SKIP(2) .
    FORM with frame DocsList .

    DO FOR b-trn-doc :
        if Repeated then
            FOR EACH b-trn-doc WHERE b-trn-doc.obj-type = v-cntxt-obj-type    AND
                                     b-trn-doc.obj-code  = v-cntxt-obj-code   AND
                                     b-trn-doc.doc-type  = {&expense}   AND
                                     b-trn-doc.status_   = {&permitted} AND
                                     b-trn-doc.rsrv-date = rsrv-FactDate

                                     use-index obj-load
                                     SHARE-LOCK BREAK BY b-trn-doc.doc-code :
                { rep/load-cre.i }
            END .
        else
            FOR EACH b-trn-doc WHERE b-trn-doc.obj-type = v-cntxt-obj-type  AND
                                     b-trn-doc.obj-code = v-cntxt-obj-code  AND
                                     b-trn-doc.status_ = {&permitted} AND
                                     b-trn-doc.rsrv-date = startdate  AND
                                     b-trn-doc.flag_                  AND
                                     b-trn-doc.doc-type = {&expense}
                                     SHARE-LOCK BREAK BY b-trn-doc.doc-code :
                { rep/load-cre.i }
            END .

        PUT stream RepStr Line format "x(115)" SKIP .
        DISPLAY stream RepStr
                            "ИТОГО" @ trn-doc.doc-code
                            ( ACCUM TOTAL b-trn-doc.doc-qnty ) @ trn-doc.doc-qnty
                            with frame DocsList .
        DOWN stream RepStr 1 with frame DocsList .
        UNDERLINE stream RepStr trn-doc.doc-code trn-doc.doc-qnty with frame DocsList .
        HIDE stream RepStr FRAME BottomFrame-1 .
        output stream RepStr CLOSE .

        FOR EACH doc-recids BREAK BY doc-recids.doc-code :
                FIND b-trn-doc WHERE recid( b-trn-doc ) = doc-recids.DocRecid NO-LOCK .
                ACCUMULATE b-trn-doc.doc-code ( COUNT ) .
                if first( doc-recids.doc-code ) then
                    run rep/r-outret.p ( input p-mainmenu-handle, input doc-recids.DocRecid, input no) .
                else
                    run rep/r-outret.p ( input p-mainmenu-handle, input doc-recids.DocRecid, input no) .
                { gbl/stopwork.i }
        END .
        InputFileName = {&PLT_Name} .
        { cmp/open-out.i " "   " "   append}
        { rep/prntri.i yes}
        DO WHILE line-counter <= page-size :
            PUT " " SKIP .
        END.
        output CLOSE .

        if NOT NotPrint-GdsList then
            do:
                { cmp/open-out.i stream RepStr append}
                PUT stream RepStr space(10) CAPS( clients.obj-name ) format "x(100)" SKIP(1) .
                PUT stream RepStr space(30) string( "Список товаров на отгрузку за " +
                        string( ( if Repeated then rsrv-FactDate else startdate ), "99/99/9999" ) + "." )
                        format "x(100)" SKIP(2) .
                FORM HEADER
                    Line format "X(125)" AT 1 SKIP
                    "Продолжение - на следующей странице" AT 30 SKIP
                    with FRAME BottomFrame-2 width {&A4_CW} PAGE-BOTTOM no-labels no-box.
                VIEW stream RepStr FRAME BottomFrame-2 .

                ind = 0 .
                FOR EACH doc-recids ,
                        EACH doc-line WHERE doc-line.doc-code = doc-recids.doc-code NO-LOCK
                            BREAK BY string( doc-line.prod-type + string( doc-line.prod-code ) )
                                         BY doc-line.artic
                                         with frame GoodsList :
                    if first-of( string( doc-line.prod-type + string( doc-line.prod-code ) ) ) then
                        do:
                            if NOT first( string( doc-line.prod-type + string( doc-line.prod-code ) ) ) then
                                UNDERLINE stream RepStr doc-line.artic goods.gds-name .
                            FIND cli-prod WHERE cli-prod.obj-type = doc-line.prod-type AND
                                                                cli-prod.obj-code = doc-line.prod-code NO-LOCK .
                            DISPLAY stream RepStr
                                        "Производитель" @ doc-line.artic
                                        cli-prod.obj-name @ goods.gds-name .
                            DOWN stream RepStr 1 .
                            UNDERLINE stream RepStr doc-line.artic goods.gds-name .
                        end.
                    FIND goods WHERE goods.prod-type = doc-line.prod-type AND
                                                  goods.prod-code = doc-line.prod-code AND
                                                  goods.artic = doc-line.artic NO-LOCK .
                    FIND gds-prt where gds-prt.upper-code = doc-line.prt-root NO-LOCK .
                    rootnode_code = gds-prt.node-code .
                    FIND bar-code WHERE bar-code.gds-code = goods.gds-code AND
                                      bar-code.unit-cli = goods.unit-base AND
                                      bar-code.node-code = rootnode_code AND
                                      bar-code.part-code = "" AND
                                      bar-code.in-code = ""
                                      NO-LOCK NO-ERROR.
                    if not available bar-code then
                        tb-code = "?".
                    else
                        tb-code = trim ( string (bar-code.b-code )) .
                    ACCUMULATE doc-line.doc-qnty ( SUB-TOTAL BY doc-line.artic )
                                            doc-line.doc-qnty ( TOTAL )
                                            doc-line.artic ( COUNT ) .
                    if last-of( doc-line.artic ) then
                        do:
                            ind = ind + 1 .
                            DISPLAY stream RepStr
                                    sym1 ind
                                    sym3 doc-line.artic
                                    sym4 goods.gds-name
                                    sym2 tb-code
                                    sym5 goods.unit-base
    sym6 ( ACCUM SUB-TOTAL BY doc-line.artic doc-line.doc-qnty ) @ doc-line.doc-qnty
                                    sym7 .
                            DOWN stream RepStr 1 .
                        end.
                    if last( string( doc-line.prod-type + string( doc-line.prod-code ) ) ) then
                        do:
                            PUT stream RepStr Line format "x(125)" SKIP .
                            DISPLAY stream RepStr
                                "ИТОГО" @ doc-line.artic
                                ( ACCUM TOTAL doc-line.doc-qnty ) @ doc-line.doc-qnty .
                            DOWN stream RepStr 1 .
                            UNDERLINE stream RepStr doc-line.artic doc-line.doc-qnty .
                        end.
                END .
                HIDE stream RepStr FRAME BottomFrame-2 .
                output stream RepStr CLOSE .
            end.
        { gbl/stopwork.i }

        if NOT Repeated then
            do:
                FOR EACH doc-recids ,
                        EACH b-trn-doc OF doc-recids EXCLUSIVE-LOCK
                            on error undo, return "Bad-Reading" :
                        delete doc-recids .
                END .
            end.
    END.        /*  DO FOR b-trn-doc  */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME