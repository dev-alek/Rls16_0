&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-type-tmp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-type-tmp 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник типов  темпов продаж

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 09/06/05

*/

define input  parameter parParentProc  as widget-handle no-undo.
define input     param bttns  as char   no-undo .
define output    param rid-list    as  char no-undo . /* список recid'ов выбранных аписей */

def var log-res as log no-undo.
def var rr as recid no-undo.

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Справочник типов темпов продаж".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i new   }
{ gbl/cur-time.i     }
{ cmp/showinf.i      }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i     }
{ gbl/getcntxt.i get }
define variable g#report-num as integer   no-undo .
run get-report-num  in parParentProc ( output g#report-num ).
define variable g#log as logical   no-undo .

def stream ListStream .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-type-tmp
&Scoped-define BROWSE-NAME br-tmp-sale

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.tmp-sale

/* Definitions for BROWSE br-tmp-sale                                   */
&Scoped-define FIELDS-IN-QUERY-br-tmp-sale ~
(IF ( CAN-DO (rid-list, string( recid( ub.tmp-sale ) ) ) ) THEN ("*") ELSE (" ")) ~
ub.tmp-sale.tmp-code ub.tmp-sale.desc_ 
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-tmp-sale 
&Scoped-define QUERY-STRING-br-tmp-sale FOR EACH ub.tmp-sale NO-LOCK ~
    BY ub.tmp-sale.tmp-code INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-tmp-sale OPEN QUERY br-tmp-sale FOR EACH ub.tmp-sale NO-LOCK ~
    BY ub.tmp-sale.tmp-code INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-tmp-sale ub.tmp-sale
&Scoped-define FIRST-TABLE-IN-QUERY-br-tmp-sale ub.tmp-sale


/* Definitions for DIALOG-BOX d-type-tmp                                */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-type-tmp ~
    ~{&OPEN-QUERY-br-tmp-sale}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-sel B-mark b-add b-chg b-print ~
b-goods b-help br-tmp-sale mark-num 
&Scoped-Define DISPLAYED-OBJECTS mark-num 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add 
     LABEL "&Добавить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-chg 
     LABEL "&Изменить":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "&Выход ":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-goods 
     LABEL "Товары":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь":L 
     SIZE 10 BY 1.

DEFINE BUTTON B-mark 
     LABEL "&*" 
     SIZE 3 BY 1.

DEFINE BUTTON b-print 
     LABEL "Пе&чать":L 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel AUTO-GO 
     LABEL "Вы&бор ":L 
     SIZE 10 BY 1.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 9 BY .67
     FGCOLOR 4  NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-tmp-sale FOR 
      ub.tmp-sale SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-tmp-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-tmp-sale d-type-tmp _STRUCTURED
  QUERY br-tmp-sale NO-LOCK DISPLAY
      (IF ( CAN-DO (rid-list, string( recid( ub.tmp-sale ) ) ) ) THEN ("*") ELSE (" ")) COLUMN-LABEL "*" FORMAT "X(1)":U
      ub.tmp-sale.tmp-code FORMAT "X(12)":U WIDTH 14.88
      ub.tmp-sale.desc_ FORMAT "X(80)":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 83.25 BY 18.75
         BGCOLOR 15 FGCOLOR 0 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-type-tmp
     b-exit AT ROW 1 COL 1
     b-sel AT ROW 1 COL 11
     B-mark AT ROW 1 COL 23
     b-add AT ROW 1 COL 34
     b-chg AT ROW 1 COL 44
     b-print AT ROW 1 COL 54
     b-goods AT ROW 1 COL 64
     b-help AT ROW 1 COL 74
     br-tmp-sale AT ROW 3.04 COL 1.13
     mark-num AT ROW 2.17 COL 74.75 NO-LABEL
     SPACE(0.87) SKIP(19.15)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "ТЕМПЫ ПРОДАЖ":L.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-type-tmp
   FRAME-NAME                                                           */
/* BROWSE-TAB br-tmp-sale b-help d-type-tmp */
ASSIGN 
       FRAME d-type-tmp:SCROLLABLE       = FALSE.

ASSIGN 
       br-tmp-sale:NUM-LOCKED-COLUMNS IN FRAME d-type-tmp     = 3.

/* SETTINGS FOR FILL-IN mark-num IN FRAME d-type-tmp
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-tmp-sale
/* Query rebuild information for BROWSE br-tmp-sale
     _TblList          = "ub.tmp-sale"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _OrdList          = "ub.tmp-sale.tmp-code|yes"
     _FldNameList[1]   > "_<CALC>"
"(IF ( CAN-DO (rid-list, string( recid( ub.tmp-sale ) ) ) ) THEN (""*"") ELSE ("" ""))" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > ub.tmp-sale.tmp-code
"tmp-code" ? "X(12)" "character" ? ? ? ? ? ? no ? no no "14.88" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   = ub.tmp-sale.desc_
     _Query            is OPENED
*/  /* BROWSE br-tmp-sale */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-type-tmp
/* Query rebuild information for DIALOG-BOX d-type-tmp
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-type-tmp */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-type-tmp
ON CHOOSE OF b-add IN FRAME d-type-tmp /* Добавить */
DO:
    run ref/tmpsalei.w
      ( {&add-def}, input-output rr ).
    if rr <> ? then
        do:
            {&open-query-br-tmp-sale}
            reposition br-tmp-sale to recid rr.
            log-res  = br-tmp-sale:select-focused-row( ).
            apply "ENTRY":U to br-tmp-sale.
            apply "home"  to {&browse-name}.
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-chg d-type-tmp
ON CHOOSE OF b-chg IN FRAME d-type-tmp /* Изменить */
DO:
    if not available ub.tmp-sale THEN
        return no-apply.

    rr = recid( ub.tmp-sale ).
    run ref/tmpsalei.w
    ( {&update}, input-output rr ).
    {&open-query-br-tmp-sale}
    reposition br-tmp-sale to recid rr .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-type-tmp
ON CHOOSE OF b-exit IN FRAME d-type-tmp /* Выход  */
DO:
  rid-list = "" .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-goods
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods d-type-tmp
ON CHOOSE OF b-goods IN FRAME d-type-tmp /* Товары */
DO:
      if not available ub.tmp-sale THEN
        return no-apply.
    run ref/tmpgdsl.w
        ( parParentProc ,  input ub.tmp-sale.tmp-code, input ub.tmp-sale.desc_ ).


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark d-type-tmp
ON CHOOSE OF B-mark IN FRAME d-type-tmp /* * */
DO:
   { gbl/markstrn.i ub.tmp-sale rid-list }
   g#log = br-tmp-sale  :refresh( ) in frame {&frame-name}.

    if not can-do ("MOUSE-SELECT-DBLCLICK,Return", last-event:function) then do:
            g#log = br-tmp-sale:select-next-row () in frame {&frame-name}.
            apply "iteration-changed" to br-tmp-sale in frame {&frame-name}.
    end.
    if num-entries (rid-list) = 0 then
        hide mark-num in frame {&frame-name}.
    else
    disp num-entries (rid-list) @ mark-num
    with frame {&frame-name}.
    apply "entry" to br-tmp-sale in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print d-type-tmp
ON CHOOSE OF b-print IN FRAME d-type-tmp /* Печать */
DO:
    def var sym1 as char init ":"   no-undo.
    def var sym2 as char init ":"   no-undo.
    def var sym3 as char init ":"   no-undo.
    def var Line                    as char         no-undo.

    def var ii      as integer   no-undo.
    def var StartRecid      as integer   no-undo.

    DEFINE FRAME List
        sym1 column-label ":" format "x(1)"
        ub.tmp-sale.tmp-code column-label {&g___code} format "9999"
        sym2 column-label ":" format "x(1)"
        ub.tmp-sale.desc_ column-label "Наименование" format "x(80)"
        sym3 column-label ":" format "x(1)"
        HEADER
                cur-time-print () format "X(35)" at 5
                string( "Страница " + string( PAGE-NUMBER( ListStream ) , ">>9") )
                    AT 86 format "X(15)" SKIP
            Line format "x(110)" AT 1
        with width {&A4_CW} down use-text stream-io no-box .

    if num-results( "br-tmp-sale" ) = 0 then
        do:
            message "Список  П У С Т !" skip view-as alert-box information .
            return no-apply .
        end.


    Line = fill( "-" , 140 ) .
/*
    Это из-за того, что в QUERY br-tmp-sale используется index reposition и,
    как следствие, не работает GET first br-tmp-sale  ( ошибка 3157 )
*/
    StartRecid = recid( ub.tmp-sale ) .
    DO WHILE available ub.tmp-sale :
        GET prev br-tmp-sale NO-LOCK .
    END.
    GET next br-tmp-sale NO-LOCK .
    ii = 1 .

    { cmp/open-out.i stream ListStream }

    FORM HEADER
                Line format "X(130)" SKIP
                "Продолжение - на следующей странице" AT 30 SKIP
                with FRAME CliBottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS no-box.
    VIEW stream ListStream FRAME CliBottomFrame .
    PUT stream ListStream space(20)
        "С П И С О К  Т Е М П О В   П Р О Д А Ж" format "X(100)" SKIP(2) .
    FORM with frame List .
    DO WHILE available ub.tmp-sale :
        DISPLAY stream ListStream
                        sym1 ub.tmp-sale.tmp-code
                        sym2 ub.tmp-sale.desc_
                        sym3    with frame List .
        DOWN stream ListStream 1 with frame List .
        ii =  ii + 1 .
        if ( ( ii modulo 10 ) = 0 ) AND ( ii >= 10 ) then
            run waitfram-show in this-procedure
               ( "Просмотрено строк : " + string( ii ) ) .
        GET next br-tmp-sale .
    END.
    PUT stream ListStream Line format "X(110)" SKIP.
    HIDE stream ListStream FRAME CliBottomFrame .
    output stream ListStream close .
    define variable v-user-action as character no-undo .
    define variable v-printed as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    DisabledOptions = 0 .

    run gbl/prnfilen.w
      (input  ""
      ,input  DisabledOptions
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    reposition br-tmp-sale to recid StartRecid NO-ERROR .
    run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel d-type-tmp
ON CHOOSE OF b-sel IN FRAME d-type-tmp /* Выбор  */
DO:
    if ( available ub.tmp-sale ) AND ( rid-list = "" ) then
        rid-list = string( recid( ub.tmp-sale ) ) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-tmp-sale
&Scoped-define SELF-NAME br-tmp-sale
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tmp-sale d-type-tmp
ON DEFAULT-ACTION OF br-tmp-sale IN FRAME d-type-tmp
DO:
  case yes:
      when  b-chg:sensitive THEN apply "CHOOSE":U to b-chg.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tmp-sale d-type-tmp
ON MOUSE-SELECT-DBLCLICK OF br-tmp-sale IN FRAME d-type-tmp
DO:
    if lookup ( "b-sel", bttns ) > 0  then
        do:
            apply "choose" to b-sel in frame {&frame-name} .
            return no-apply .
        end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-tmp-sale d-type-tmp
ON RETURN OF br-tmp-sale IN FRAME d-type-tmp
DO:
    if Lookup( "b-sel",  bttns ) > 0 then
        do:
            apply "choose" to b-sel in frame {&frame-name} .
            return no-apply .
        end.
    else
        apply "DEFAULT-ACTION":U to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-type-tmp 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

    run enable_ui.

    if num-entries (rid-list) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp
        num-entries (rid-list) @ mark-num
        with frame {&frame-name}.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-type-tmp  _DEFAULT-DISABLE
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
  HIDE FRAME d-type-tmp.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-type-tmp 
PROCEDURE enable_UI :
/* --------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
   -------------------------------------------------------------------- */
    ENABLE
     br-tmp-sale
        b-exit
        b-add WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-sel WHEN  (lookup  ( "b-sel" , bttns) > 0 )
        b-mark when (lookup  ( "b-mark", bttns) > 0 )
        b-chg WHEN  (lookup  ( "b-add" , bttns) > 0 )
        b-print
        b-help
        b-goods
        WITH FRAME  {&frame-name}.
    {&OPEN-BROWSERS-IN-QUERY-d-tmp-sale}
    if available ub.tmp-sale then
        log-res  = br-tmp-sale:select-focused-row( ) in frame {&frame-name}.

     {&open-query-br-tmp-sale}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

