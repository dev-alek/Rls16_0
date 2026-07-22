&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE db-area NO-UNDO LIKE ub.sys-ctrl
       field name-area    like _AreaStatus._AreaStatus-Areaname
       field num-area     AS INT
       field size-area    AS DEC
       field size-Hiwater AS DEC
       field size-empty   AS DEC
       field percent      AS char
       field ID-Area      like _AreaStatus._AreaStatus-Id
       field v-col          AS dec

       index pi is unique primary
       num-area
       .



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Информация о БД

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/28/07
Author: Dmitry Ukhanov
Creation date: 06/28/07

Автор1: Румянцев Юрий Александрович
Дата создания: 04/12/04

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация о БД".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ gbl/color.i }

DEFINE VARIABLE vDelimiter AS CHARACTER NO-UNDO INITIAL "~\".
DEFINE VARIABLE vPercentFull AS DECIMAL NO-UNDO.
DEFINE VARIABLE vEmptyBlocks AS DECIMAL NO-UNDO.
DEFINE VARIABLE vBusyFlag AS CHARACTER NO-UNDO FORMAT "x(4)".
DEFINE VARIABLE vCol  AS DECIMAL NO-UNDO.
DEFINE VARIABLE SizeArea  AS DECIMAL NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-area

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES db-area

/* Definitions for BROWSE br-area                                       */
&Scoped-define FIELDS-IN-QUERY-br-area name-area num-area size-area ~
size-Hiwater size-empty percent
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-area
&Scoped-define QUERY-STRING-br-area FOR EACH db-area NO-LOCK
&Scoped-define OPEN-QUERY-br-area OPEN QUERY br-area FOR EACH db-area NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-area db-area
&Scoped-define FIRST-TABLE-IN-QUERY-br-area db-area


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-area}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit b-help br-area ED-view
&Scoped-Define DISPLAYED-OBJECTS ED-view SizeBI VolBI SizeDB SizeAI VolArea ~
VolAI

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

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-area AUTO-END-KEY 
     LABEL "Состав" 
     SIZE 10 BY 1 TOOLTIP "Состав области"
     BGCOLOR 8 .

DEFINE VARIABLE ED-view AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 99 BY 7.75 NO-UNDO.

DEFINE VARIABLE SizeAI AS DECIMAL FORMAT ">>>,>>>,>>9":U INITIAL 0
     LABEL "Размер AI (MB)"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE SizeBI AS DECIMAL FORMAT ">>>,>>>,>>9":U INITIAL 0
     LABEL "Размер BI (MB)"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE SizeDB AS DECIMAL FORMAT ">>>,>>>,>>>,>>>,>>>":U INITIAL 0
     LABEL "Размер БД (MB)"
      VIEW-AS TEXT
     SIZE 25 BY .67 NO-UNDO.

DEFINE VARIABLE VolAI AS INTEGER FORMAT ">>,>>9":U INITIAL 0
     LABEL "Кол-во томов AI"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE VolArea AS INTEGER FORMAT ">>,>>9":U INITIAL 0
     LABEL "Кол-во областей"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.

DEFINE VARIABLE VolBI AS INTEGER FORMAT ">>,>>9":U INITIAL 0
     LABEL "Кол-во томов BI"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-area FOR
      db-area SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-area
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-area Dialog-Frame _STRUCTURED
  QUERY br-area NO-LOCK DISPLAY
      name-area COLUMN-LABEL "Имя области" WIDTH 28.38
      num-area COLUMN-LABEL "N" WIDTH 3.88
      size-area COLUMN-LABEL "Размер области (MB)" FORMAT ">>,>>>,>>>,>>>,>>>":U
      size-Hiwater COLUMN-LABEL "Заполнено (MB)" FORMAT ">>,>>>,>>>,>>>,>>>":U
      size-empty COLUMN-LABEL "Свободно (MB)" FORMAT ">>,>>>,>>>,>>>,>>>":U
      percent COLUMN-LABEL "Внимание"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.88 BY 9.5 ROW-HEIGHT-CHARS .63.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 2
     b-help AT ROW 1 COL 89.5 WIDGET-ID 4
     b-area AT ROW 4.33 COL 89 WIDGET-ID 6
     br-area AT ROW 5.5 COL 1
     ED-view AT ROW 15.75 COL 1 NO-LABEL
     SizeBI AT ROW 2.25 COL 60 COLON-ALIGNED
     VolBI AT ROW 3 COL 60 COLON-ALIGNED
     SizeDB AT ROW 3.5 COL 17 COLON-ALIGNED
     SizeAI AT ROW 3.75 COL 60 COLON-ALIGNED
     VolArea AT ROW 4.25 COL 17 COLON-ALIGNED
     VolAI AT ROW 4.5 COL 60 COLON-ALIGNED
     "Информация об области" VIEW-AS TEXT
          SIZE 38 BY .67 AT ROW 15 COL 1.5
     SPACE(60.74) SKIP(8.03)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация о базе данных"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: db-area T "?" NO-UNDO ub sys-ctrl
      ADDITIONAL-FIELDS:
          field name-area    like _AreaStatus._AreaStatus-Areaname
          field num-area     AS INT
          field size-area    AS DEC
          field size-Hiwater AS DEC
          field size-empty   AS DEC
          field percent      AS char
          field ID-Area      like _AreaStatus._AreaStatus-Id
          field v-col          AS dec

          index pi is unique primary
          num-area

      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-area b-help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ED-view:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN SizeAI IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN SizeBI IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN SizeDB IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN VolAI IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN VolArea IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN VolBI IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-area
/* Query rebuild information for BROWSE br-area
     _TblList          = "Temp-Tables.db-area"
     _Options          = "NO-LOCK"
     _FldNameList[1]   > "_<CALC>"
"name-area" "Имя области" ? ? ? ? ? ? ? ? no ? no no "28.38" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > "_<CALC>"
"num-area" "N" ? ? ? ? ? ? ? ? no ? no no "3.88" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > "_<CALC>"
"size-area" "Размер области (MB)" ">>,>>>,>>>,>>>,>>>" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[4]   > "_<CALC>"
"size-Hiwater" "Заполнено (MB)" ">>,>>>,>>>,>>>,>>>" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[5]   > "_<CALC>"
"size-empty" "Свободно (MB)" ">>,>>>,>>>,>>>,>>>" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[6]   > "_<CALC>"
"percent" "Внимание" ? ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-area */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Информация о базе данных */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-area
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-area Dialog-Frame
ON CHOOSE OF b-area IN FRAME Dialog-Frame /* Состав */
DO:
  if avail db-area then
    run utl/info-area.w (db-area.num-area). 
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-area
&Scoped-define SELF-NAME br-area
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-area Dialog-Frame
ON VALUE-CHANGED OF br-area IN FRAME Dialog-Frame
DO:

  ed-view:SCREEN-VALUE = "":U.

  ASSIGN
    ed-view:SCREEN-VALUE = string("Имя файла области", "X(28)") + " ":U +
                           string("Размер (MB)", "X(12)") + " ":U +
                           string("Заполняется", "X(12)") + CHR(13) + CHR(10)
    .
  FIND _areastatus WHERE _areastatus._AreaStatus-Id = db-area.Id-Area NO-LOCK.
  FIND _Area WHERE _Area._Area-Num = _AreaStatus._AreaStatus-AreaNum  NO-LOCK.
  
  SizeArea = 0.
  FOR EACH _AreaExtent where _AreaExtent._Area-Recid = RECID(_Area)  NO-LOCK:
        FIND _FileList WHERE ENTRY(NUM-ENTRIES(_FileList._FileList-Name, vDelimiter),
                           _FileList._FileList-Name, vDelimiter)
                   = ENTRY(NUM-ENTRIES(_AreaExtent._Extent-Path, vDelimiter),
                           _AreaExtent._Extent-Path, vDelimiter)  NO-LOCK.
        
        IF _FileList-name = _AreaStatus-Lastextent THEN DO:
            IF  _FileList._FileList-Openmode = "BOTHIO" THEN DO:
               IF _AreaStatus-Areanum = 6 THEN DO: 
                   IF _AreaExtent._Extent-type < 32 THEN 
                       vBusyFlag = "Последний том области, заполнен на " + STRING (
                    dec(_FileList._FileList-Size) * 100 / 2048000, ">>9.99"
                    ) + " %" .
                   ELSE
                       ASSIGN vBusyFlag = "Заполнен на " +
                              STRING( ( (DEC(_AreaStatus-Hiwater) * dec(_Area._Area-blocksize) - SizeArea )  / 
                                dec(_FileList._FileList-Size * 1024) ) 
                                * 100 ,  ">>9.99" ) + " %" .

               END.
               ELSE IF _AreaExtent._Extent-type < 32 THEN
                    vBusyFlag = "Последний том области, заполнен на " + STRING (
                      dec(_FileList._FileList-Size) * 100 / 2048000, ">>9.99"
                      ) + " %" .
               ELSE IF _AreaExtent._Extent-type > 32 THEN
                    vBusyFlag = "Последний том области, заполнен на " +
                     STRING( ( (DEC(_AreaStatus-Hiwater) * dec(_Area._Area-blocksize) - SizeArea )  / 
                     dec(_FileList._FileList-Size * 1024) ) 
                     * 100 ,  ">>9.99" ) + " %" .
            END.
            ELSE
               ASSIGN vBusyFlag = "Заполнен на " +
                      STRING( ( (DEC(_AreaStatus-Hiwater) * dec(_Area._Area-blocksize) - SizeArea )  / 
                        dec(_FileList._FileList-Size * 1024) ) 
                        * 100 ,  ">>9.99" ) + " %" .
               
        END.
        ELSE 
            ASSIGN 
                SizeArea = SizeArea +  dec(_FileList._FileList-Size * 1024)
                vBusyFlag = "".

  ASSIGN
  ed-view:SCREEN-VALUE = ed-view:SCREEN-VALUE + CHR(13) + CHR(10) +
                         string(_FileList._FileList-Name, "x(28)") + " " +
                         STRING(_FileList._FileList-Size, ">>>,>>>,>>>") + " " +
                         STRING(vBusyFlag, "X(55)").

        /*DISPLAY
            _FileList._FileList-Name FORMAT "x(48)"       LABEL "Имя файла"
            _FileList._FileList-Size FORMAT ">>>,>>>,>>>" LABEL "Размер"
            vBusyFlag               FORMAT "x(4)"        LABEL "Заполняется"
/*              _FileList._FileList-Openmode */
        WITH DOWN FRAME Extentf TITLE "Информация об областьи".*/

END. /* FOR EACH _AreaExtent */



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */


IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON ROW-DISPLAY OF br-area IN frame {&frame-name}
DO:
  IF AVAIL db-area THEN DO:
    RUN set-row-color.
  END.
END.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  FOR EACH _areastatus NO-LOCK:
      vEmptyBlocks = _AreaStatus-Totblocks - _AreaStatus-Hiwater.
      vPercentFull = (1 - (vEmptyBlocks / _AreaStatus-Totblocks)) * 100.

      FIND _Area WHERE _Area._Area-Num = _AreaStatus._AreaStatus-AreaNum  NO-LOCK.

      ASSIGN
          SizeDB = SizeDB + ( DEC (_AreaStatus._AreaStatus-Totblocks) * DEC( _Area._Area-blocksize)) / 1024.

      IF _AreaStatus._AreaStatus-Areanum = 1 THEN NEXT.
      IF _AreaStatus._AreaStatus-Areaname /*_AreaStatus-Areanum = 3 */ BEGINS "Primary Recovery" THEN do:
          ASSIGN
            SizeBI = SizeBI + ( DEC (_AreaStatus._AreaStatus-Totblocks) * DEC( _Area._Area-blocksize)) / 1024
            VolBI = VolBI + 1.
          NEXT.
      END.

      IF _AreaStatus._AreaStatus-Areaname /*_AreaStatus-Areanum = 3 */ BEGINS "After Image" THEN do:
          ASSIGN
            SizeAI = SizeAI + ( DEC (_AreaStatus._AreaStatus-Totblocks) * DEC( _Area._Area-blocksize)) / 1024
            VolAI = VolAI + 1.
          NEXT.
      END.
      /***********/
      vCol = 0.
      FOR EACH _AreaExtent where _AreaExtent._Area-Recid = RECID(_Area)  NO-LOCK:
          FIND _FileList WHERE ENTRY(NUM-ENTRIES(_FileList._FileList-Name, vDelimiter),
                            _FileList._FileList-Name, vDelimiter)
                    = ENTRY(NUM-ENTRIES(_AreaExtent._Extent-Path, vDelimiter),
                            _AreaExtent._Extent-Path, vDelimiter)  NO-LOCK.
          IF _FileList-name = _AreaStatus-Lastextent THEN DO:
            IF _AreaStatus-Areanum = 6 THEN DO:
                IF _AreaExtent._Extent-type < 32 THEN 
                  vCol = (dec(_FileList._FileList-Size) * 100 / 2048000) .
              END.
            ELSE 
              IF  _FileList._FileList-Openmode = "BOTHIO"  THEN
                  vCol = (dec(_FileList._FileList-Size) * 100 / 2048000) .
          END.
      END.

      /************/
      VolArea = VolArea + 1.
      CREATE db-area.
      ASSIGN
          name-area    = _AreaStatus._AreaStatus-Areaname
          num-area     = _AreaStatus._AreaStatus-Areanum
          size-area    = DEC (DEC (_AreaStatus._AreaStatus-Totblocks) * DEC( _Area._Area-blocksize)) / 1024
          size-Hiwater = DEC (( DEC(_AreaStatus._AreaStatus-Hiwater)) * DEC (_Area._Area-blocksize)) / 1024
          size-empty   = (vEmptyBlocks  * _Area._Area-blocksize) / 1024
/*         percent       = vPercentFull */
          Id-Area      = _AreaStatus._AreaStatus-Id
          v-Col = vCol.

  END. /* EACH _areastatus */
  RUN enable_UI.
  apply "VALUE-CHANGED":U TO br-area.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carring-obj Dialog-Frame
PROCEDURE carring-obj :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-qnty Dialog-Frame
PROCEDURE check-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
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
  DISPLAY ED-view SizeBI VolBI SizeDB SizeAI VolArea VolAI
      WITH FRAME Dialog-Frame.
  ENABLE b-quit b-help b-area br-area ED-view
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-row-color Dialog-Frame
PROCEDURE set-row-color :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define variable iFGColor AS INTEGER NO-UNDO.
  define variable iBGColor AS INTEGER NO-UNDO.

/*  IF db-area.percent > 99  THEN DO: */
      IF db-area.v-Col > 80 THEN
         ASSIGN
           iFGColor = WHITE_COLOR
           iBGColor = /*DARK_GREEN_COLOR*/ RED_COLOR
         .
      ELSE IF db-area.v-Col > 50 THEN
         ASSIGN
           iFGColor = WHITE_COLOR
           iBGColor = /*DARK_GREEN_COLOR*/ YELLOW_COLOR
         .
      ELSE
          ASSIGN
            iFGColor = Black_COLOR
            iBGColor = White_COLOR
          .
/*  end.
  ELSE do:
      ASSIGN
        iFGColor = Black_COLOR
        iBGColor = White_COLOR
      .
  end.
*/
    ASSIGN
      db-area.percent:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      db-area.percent:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor
/*
      db-area.name-area:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      db-area.name-area:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor

      db-area.num-area:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      db-area.num-area:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor

      db-area.size-area:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      db-area.size-area:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor

      db-area.size-Hiwater:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      db-area.size-Hiwater:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor

      db-area.size-empty:FGCOLOR IN BROWSE {&BROWSE-NAME} = iFGColor
      db-area.size-empty:BGCOLOR IN BROWSE {&BROWSE-NAME} = iBGColor
*/
    .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

