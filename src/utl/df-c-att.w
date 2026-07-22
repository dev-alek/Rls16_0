&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание df для таблиц истории и атрибутов

Автор: Белоусов Илья Александрович
Дата создания: 10/24/07
Author: Ilia Belousov
Creation date: 10/24/07


*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание df для таблиц истории и атрибутов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/color.i    }
{ gbl/waitfram.i }

DEFINE VARIABLE v-Field     AS CHARACTER  NO-UNDO.

define temp-table tt-file no-undo like _file
      field f-attr      as logical
      field f-c         as logical
      field f-attr-old  as logical
      field f-c-old     as logical
.
define temp-table tt-trig-name no-undo
      field f-name      as CHARACTER
INDEX pi IS PRIMARY UNIQUE
      f-name
    .

define stream st-out.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-file

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-file

/* Definitions for BROWSE BR-file                                       */
&Scoped-define FIELDS-IN-QUERY-BR-file tt-file._File-Number tt-file._File-Name tt-file.f-attr view-as toggle-box tt-file.f-c view-as toggle-box   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-file tt-file.f-attr ~
tt-file.f-c   
&Scoped-define ENABLED-TABLES-IN-QUERY-BR-file tt-file
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BR-file tt-file
&Scoped-define SELF-NAME BR-file
&Scoped-define OPEN-QUERY-BR-file /* OPEN QUERY {&SELF-NAME} FOR EACH tt-file . */ RUN refresh-query in this-procedure .
&Scoped-define TABLES-IN-QUERY-BR-file tt-file
&Scoped-define FIRST-TABLE-IN-QUERY-BR-file tt-file


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-file}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-export b-help v-all b-sel-all-c ~
b-sel-all-attr b-drop-all-c b-drop-all-attr BR-file 
&Scoped-Define DISPLAYED-OBJECTS v-all 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-drop-all-attr 
     LABEL "все атр." 
     SIZE 10 BY 1.

DEFINE BUTTON b-drop-all-c 
     LABEL "все ист." 
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-export 
     LABEL "Выгрузить" 
     SIZE 10 BY 1.

DEFINE BUTTON b-help 
     LABEL "Помо&щь" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-sel-all-attr 
     LABEL "все атр." 
     SIZE 10 BY 1.

DEFINE BUTTON b-sel-all-c 
     LABEL "все ист." 
     SIZE 10 BY 1.

DEFINE VARIABLE v-all AS LOGICAL INITIAL yes 
     LABEL "В один файл new.df" 
     VIEW-AS TOGGLE-BOX
     SIZE 20.6 BY .81 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-file FOR 
      tt-file SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-file Dialog-Frame _FREEFORM
  QUERY BR-file NO-LOCK DISPLAY
      tt-file._File-Number column-label "№"
      tt-file._File-Name   column-label "Таблица"
      tt-file.f-attr column-label "Атр" view-as toggle-box
      tt-file.f-c column-label "Ист" view-as toggle-box
ENABLE
      tt-file.f-attr
      tt-file.f-c
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 52.6 BY 16.52 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-export AT ROW 1 COL 11 WIDGET-ID 4
     b-help AT ROW 1 COL 43.6
     v-all AT ROW 1.1 COL 22 WIDGET-ID 2
     b-sel-all-c AT ROW 2 COL 11 WIDGET-ID 8
     b-sel-all-attr AT ROW 2 COL 21 WIDGET-ID 6
     b-drop-all-c AT ROW 3 COL 11 WIDGET-ID 16
     b-drop-all-attr AT ROW 3 COL 21 WIDGET-ID 18
     BR-file AT ROW 4 COL 1 WIDGET-ID 200
     "Выделить" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 2.24 COL 2 WIDGET-ID 12
     "Сбросить" VIEW-AS TEXT
          SIZE 8 BY .67 AT ROW 3.24 COL 2 WIDGET-ID 14
     SPACE(43.63) SKIP(16.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Таблицы"
         DEFAULT-BUTTON b-exit WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-file b-drop-all-attr Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-file
/* Query rebuild information for BROWSE BR-file
     _START_FREEFORM
/* OPEN QUERY {&SELF-NAME} FOR EACH tt-file . */
RUN refresh-query in this-procedure .
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE BR-file */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Таблицы */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-drop-all-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-drop-all-attr Dialog-Frame
ON CHOOSE OF b-drop-all-attr IN FRAME Dialog-Frame /* все атр. */
DO:
   run deselect-all-attr in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-drop-all-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-drop-all-c Dialog-Frame
ON CHOOSE OF b-drop-all-c IN FRAME Dialog-Frame /* все ист. */
DO:
   run deselect-all-c in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Выгрузить */
DO:
   assign
      v-all
   .
   run waitfram-show in this-procedure
      ( input "Идет формирование файла"
      ) .
   run create-df in this-procedure NO-ERROR.
   IF ERROR-STATUS:ERROR THEN DO:
      MESSAGE "Ошибка формированяи DF-файла" RETURN-VALUE SKIP
               ERROR-STATUS:GET-MESSAGE(1)
      VIEW-AS ALERT-BOX.
      UNDO, RETURN NO-APPLY.
   END.
   run waitfram-hide in this-procedure .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all-attr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all-attr Dialog-Frame
ON CHOOSE OF b-sel-all-attr IN FRAME Dialog-Frame /* все атр. */
DO:
   run select-all-attr in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-sel-all-c
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all-c Dialog-Frame
ON CHOOSE OF b-sel-all-c IN FRAME Dialog-Frame /* все ист. */
DO:
   run select-all-c in this-procedure .
   RUN enable_UI.
   RUN post-enable_UI IN THIS-PROCEDURE .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-file
&Scoped-define SELF-NAME BR-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-file Dialog-Frame
ON ROW-DISPLAY OF BR-file IN FRAME Dialog-Frame
DO:
   IF  tt-file.f-c-old = FALSE
   AND tt-file.f-c     = TRUE
   then do:
      assign
         tt-file.f-c:bgcolor    in browse br-file = GRAY_COLOR
      .
   end.
   IF  tt-file.f-attr-old = FALSE
   AND tt-file.f-attr     = TRUE
   then do:
      assign
         tt-file.f-attr:bgcolor in browse br-file = GRAY_COLOR
      .
   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


ON "value-changed" OF tt-file.f-attr  IN BROWSE br-file
DO:
   define variable v-ok    as logical      no-undo.
   IF tt-file.f-attr-old = TRUE THEN dO:
      assign
         tt-file.f-attr:SCREEN-VALUE in browse br-file = STRING(tt-file.f-attr-old)
         tt-file.f-attr = tt-file.f-attr-old
      .
         APPLY "LEAVE" TO tt-file.f-attr in browse br-file.
      RETURN.
   END.
END.

ON "value-changed" OF tt-file.f-c  IN BROWSE br-file
DO:
   define variable v-ok    as logical      no-undo.
   IF tt-file.f-c-old = TRUE THEN dO:
      assign
         tt-file.f-c:SCREEN-VALUE in browse br-file = STRING(tt-file.f-c-old)
         tt-file.f-c = tt-file.f-c-old
      .
      APPLY "LEAVE" TO tt-file.f-c in browse br-file.
      RETURN.
   END.
END.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  run fill-file in this-procedure .

  RUN enable_UI.
  RUN post-enable_UI IN THIS-PROCEDURE .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-all-attr Dialog-Frame 
PROCEDURE add-all-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-trig-delete     as character    no-undo.
define variable v-trig-write     as character    no-undo.
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = TRUE
       no-lock
       :
       RUN add-attr  IN THIS-PROCEDURE ( INPUT tt-file._File-Number ) .
   end.
end.  /* do on error */
END PROCEDURE. /* add-all-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-attr Dialog-Frame 
PROCEDURE add-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-number as integer no-undo .
define variable v-file-name     as character    no-undo.
define variable v-trig-name     as character    no-undo.
define variable v-log-gds-code     as LOGICAL    no-undo.
define variable v-log-host-code     as LOGICAL    no-undo.
define variable v-log-obj-code     as LOGICAL    no-undo.
define variable v-log-b-code     as LOGICAL    no-undo.
define variable v-log-doc-code     as LOGICAL    no-undo.
define variable V-LOG-wth-CODE     as LOGICAL    no-undo.
define variable v-log-rvs-code     as LOGICAL    no-undo.

define variable v-log-artic     as LOGICAL    no-undo.
define variable v-log-doc-num     as LOGICAL    no-undo.

DEFINE VARIABLE v-idx-c AS INTEGER NO-UNDO .

define buffer buf__Field      for _Field .

do
on error undo, return error
:
    ASSIGN
        v-log-gds-code = FALSE
        v-log-host-code = FALSE
        v-log-obj-code = FALSE
        v-log-b-code   = FALSE
        v-log-doc-code = FALSE
        V-LOG-wth-CODE = FALSE
        v-log-rvs-code = FALSE
        v-idx-c = 0
   . 
        FIND FIRST _file
         where _file._File-Number = p-number
         no-lock
         .
    run trig-name in this-procedure
       ( input _file._File-Name
       , output v-trig-name
       ) .

    IF v-all THEN DO:
      assign
      v-file-name = SUBSTITUTE("new.df")
      .
    END.
    ELSE DO:
      assign
         v-file-name = SUBSTITUTE("&1-attr.df", _file._File-Name)
      .
    END.
    
    for first _index
        where recid( _index  ) = _file._prime-index
          and LC( _index._index-name ) <> "default":U
        no-lock
        ,
        each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq
      :
        ASSIGN
              v-idx-c = v-idx-c + 1
        .
    END.
    IF v-idx-c >= 16 THEN DO:
        MESSAGE "В таблице "
            _File._File-Name
            " первичный ключ шестнадцать полей."
            SKIP "Создание таблицы атрибутов невозможно."
            VIEW-AS ALERT-BOX.
        NEXT.
    END.
        
    output stream st-out to value(v-file-name) append .

    put stream st-out unformatted
        'ADD TABLE "' + _File._File-Name + '-attr"' + {&new-line}
      + '  AREA "Schema Area"' + {&new-line}
      + '  CAN-READ "!,*"' + {&new-line}
      + '  CAN-WRITE "!,!odbc,*"' + {&new-line}
      + '  CAN-CREATE "!,!odbc,*"' + {&new-line}
      + '  CAN-DELETE "!,!odbc,*"' + {&new-line}
      + '  CAN-DUMP "!odbc,*"' + {&new-line}
      + '  CAN-LOAD "!odbc,*"' + {&new-line}
      + '  LABEL "ABC анализ"' + {&new-line}
      + SUBSTITUTE('  DUMP-NAME "&1"', SUBSTRING(v-trig-name, 5, 8)) + {&new-line}
      + Substitute('  TABLE-TRIGGER "DELETE" OVERRIDE PROCEDURE "&1d.p" CRC "?"', v-trig-name) + {&new-line}
      + Substitute('  TABLE-TRIGGER "WRITE" OVERRIDE PROCEDURE "&1w.p" CRC "?"', v-trig-name) + {&new-line}
      + {&new-line}
      .

/*
    for each _Field of _File
        no-lock
        on error undo, return error
      :
      CASE _Field._Field-Name:
          WHEN "gds-code"  THEN v-log-gds-code  = TRUE.
          WHEN "b-code"    THEN v-log-b-code    = TRUE.
          WHEN "doc-code"  THEN v-log-doc-code  = TRUE.
          WHEN "rvs-code"  THEN v-log-rvs-code  = TRUE.
          WHEN "wth-code"  THEN v-log-wth-code  = TRUE.
          WHEN "host-code" THEN v-log-host-code = TRUE.
          WHEN "obj-code"  THEN IF CAN-FIND(FIRST buf__Field of _File where buf__Field._Field-Name = "obj-type" )
                           THEN v-log-obj-code  = TRUE.
          WHEN "artic"     THEN IF  CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-type" )
                                and CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-code" )
                           THEN v-log-artic     = TRUE.
          WHEN "doc-num"   THEN v-log-doc-num   = TRUE.
          OTHERWISE DO:
          END.
      END CASE.
    end.
*/

    field-block:
    for first _index
        where recid( _index  ) = _file._prime-index
          and LC( _index._index-name ) <> "default":U
        no-lock
        ,
        each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq
      :
      CASE _Field._Field-Name:
          WHEN "gds-code"  THEN v-log-gds-code  = TRUE.
          WHEN "b-code"    THEN v-log-b-code    = TRUE.
          WHEN "doc-code"  THEN v-log-doc-code  = TRUE.
          WHEN "rvs-code"  THEN v-log-rvs-code  = TRUE.
          WHEN "wth-code"  THEN v-log-wth-code  = TRUE.
          WHEN "host-code" THEN v-log-host-code = TRUE.
          WHEN "obj-code"  THEN IF CAN-FIND(FIRST buf__Field of _File where buf__Field._Field-Name = "obj-type" no-lock)
                           THEN v-log-obj-code  = TRUE.
          WHEN "artic"     THEN IF  CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-type" no-lock)
                                and CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-code" no-lock)
                           THEN v-log-artic     = TRUE.
          WHEN "doc-num"   THEN v-log-doc-num   = TRUE.
          OTHERWISE DO:
          END.
      END CASE.
      
      put stream st-out unformatted
        'ADD FIELD "' + _Field._Field-Name
                      + '" OF "'
                      + _File._File-Name
                      + '-attr"'
                      + ' AS '
                      + _Field._Data-Type
                      + {&new-line}
        .
      put stream st-out unformatted
        '  DESCRIPTION ' .
      export stream st-out
          _Field._Desc
        .

      put stream st-out unformatted
        '  FORMAT ' .
      export stream st-out
          _Field._Format
        .

      put stream st-out unformatted
        '  INITIAL ' .
      export stream st-out
          _Field._Initial
        .

      put stream st-out unformatted
        '  LABEL ' .
      export stream st-out
          _Field._Label
        .

      put stream st-out unformatted
        '  MANDATORY '
        {&new-line}
        .

      put stream st-out unformatted
        {&new-line}
      .
    end.

    /* attr-code */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "attr-code" OF "&1-attr" AS CHARACTER', _File._File-Name )
                      + {&new-line}
         '  FORMAT "X(8)"'
                      + {&new-line}
         '  INITIAL ""'
                      + {&new-line}
         '  LABEL "Атрибут"'
                      + {&new-line}
         '  MAX-WIDTH 16'
                      + {&new-line}
         '  COLUMN-LABEL "Атрибут"'
                      + {&new-line}
         '  MANDATORY'
                      + {&new-line}
                      + {&new-line}
      .

    /* attr-value */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "attr-value" OF "&1-attr" AS CHARACTER', _File._File-Name )
                      + {&new-line}
         + '  FORMAT "X(30)"'
                      + {&new-line}
         + '  INITIAL ""'
                      + {&new-line}
         + '  LABEL "Значение атрибута"'
                      + {&new-line}
         + '  MAX-WIDTH 60'
                      + {&new-line}
         + '  COLUMN-LABEL "Значение!атрибута"'
                      + {&new-line}
                      + {&new-line}
      .

    /* index */
    find first _index
         where recid( _index  ) = _file._prime-index
           and LC( _index._index-name ) <> "default":U
         no-lock
         no-error.
    if not available _index then do:
      message
         "Не найден первичный индекс для таблицы" _File._File-Name
      view-as alert-box information.
      next.
    end.

    put stream st-out unformatted
      SUBSTITUTE('ADD INDEX "pi" ON "&1-attr"', _File._File-Name )
                        + {&new-line}
      + '  AREA "Schema Area"'
                        + {&new-line}
      + '  UNIQUE'
                        + {&new-line}
      + '  PRIMARY'
                        + {&new-line}
    .
    for each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq:
      put stream st-out unformatted
         SUBSTITUTE('  INDEX-FIELD "&1" &2', _Field._Field-Name, IF _index-field._Ascending THEN "ASCENDING" ELSE "DESCENDING")
                           + {&new-line}
      .
    end.
    put stream st-out unformatted
      '  INDEX-FIELD "attr-code" ASCENDING'
                        + {&new-line}
                        + {&new-line}
    .

    IF v-log-gds-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-gds-code" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "gds-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-b-code    THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-b-code" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "b-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-doc-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-doc-code" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "doc-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-rvs-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-rvs-code" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "rvs-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-wth-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-wth-code" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "wth-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-host-code THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-host-code" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "host-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-obj-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-obj" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "obj-type" ASCENDING'
                           + {&new-line}
         + '  INDEX-FIELD "obj-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-artic     THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-artic" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "artic" ASCENDING'
                           + {&new-line}
         + '  INDEX-FIELD "prod-type" ASCENDING'
                           + {&new-line}
         + '  INDEX-FIELD "prod-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-doc-num   THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-doc-num" ON "&1-attr"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "doc-num" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.

    output stream st-out close .
    
    RUN create-trg-w IN THIS-PROCEDURE (INPUT Substitute('&1w.p', v-trig-name), INPUT SUBSTITUTE('&1-attr', _file._File-Name) ) .
    RUN create-trg-d IN THIS-PROCEDURE (INPUT Substitute('&1d.p', v-trig-name), INPUT SUBSTITUTE('&1-attr', _file._File-Name) ) .
    
    output stream st-out to value("tbl.lst") append .
    put stream st-out unformatted
       SUBSTITUTE('&1-attr', _File._File-Name )
       + {&new-line}
    .
    output stream st-out close .

end.  /* do on error */
END PROCEDURE. /* add-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE add-c Dialog-Frame 
PROCEDURE add-c :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-number as integer no-undo .
define variable v-file-name     as character    no-undo.
define variable v-trig-name     as character    no-undo.
define variable v-log-gds-code     as LOGICAL    no-undo.
define variable v-log-host-code     as LOGICAL    no-undo.
define variable v-log-obj-code     as LOGICAL    no-undo.
define variable v-log-b-code     as LOGICAL    no-undo.
define variable v-log-doc-code     as LOGICAL    no-undo.
define variable V-LOG-wth-CODE     as LOGICAL    no-undo.
define variable v-log-rvs-code     as LOGICAL    no-undo.

define variable v-log-artic     as LOGICAL    no-undo.
define variable v-log-doc-num     as LOGICAL    no-undo.

DEFINE VARIABLE v-idx-c AS INTEGER NO-UNDO .

define buffer buf__Field      for _Field .

do
on error undo, return error
:
    FIND FIRST _file
         where _file._File-Number = p-number
         no-lock
         .
    run trig-name in this-procedure
       ( input _file._File-Name
       , output v-trig-name
       ) .

    IF v-all THEN DO:
      assign
      v-file-name = SUBSTITUTE("new.df")
      .
    END.
    ELSE DO:
      assign
         v-file-name = SUBSTITUTE("c-&1.df", _file._File-Name)
      .
    END.
    for first _index
        where recid( _index  ) = _file._prime-index
          and LC( _index._index-name ) <> "default":U
        no-lock
        ,
        each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq
      :
        ASSIGN
              v-idx-c = v-idx-c + 1
        .
    END.
    IF v-idx-c >= 16 THEN DO:
        MESSAGE "В таблице "
            _File._File-Name
            " первичный ключ шестнадцать полей."
            SKIP "Создание таблицы атрибутов невозможно."
            VIEW-AS ALERT-BOX.
        NEXT.
    END.
    
    output stream st-out to value(v-file-name) append .
    put stream st-out unformatted
        'ADD TABLE "c-' + _File._File-Name + '"' + {&new-line}
      + '  AREA "Schema Area"' + {&new-line}
      + '  CAN-READ "!,*"' + {&new-line}
      + '  CAN-WRITE "!,!odbc,*"' + {&new-line}
      + '  CAN-CREATE "!,!odbc,*"' + {&new-line}
      + '  CAN-DELETE "!,!odbc,*"' + {&new-line}
      + '  CAN-DUMP "!odbc,*"' + {&new-line}
      + '  CAN-LOAD "!odbc,*"' + {&new-line}
      + '  LABEL "ABC анализ"' + {&new-line}
      + SUBSTITUTE('  DUMP-NAME "&1"', v-trig-name) + {&new-line}
      + Substitute('  TABLE-TRIGGER "DELETE" OVERRIDE PROCEDURE "&1d.p" CRC "?"', v-trig-name) + {&new-line}
      + Substitute('  TABLE-TRIGGER "WRITE" OVERRIDE PROCEDURE "&1w.p" CRC "?"', v-trig-name) + {&new-line}
      + {&new-line}
      .


    field-block:
    for each _Field of _File
        no-lock
        on error undo, return error
      :
      CASE _Field._Field-Name:
          WHEN "gds-code"  THEN v-log-gds-code  = TRUE.
          WHEN "b-code"    THEN v-log-b-code    = TRUE.
          WHEN "doc-code"  THEN v-log-doc-code  = TRUE.
          WHEN "rvs-code"  THEN v-log-rvs-code  = TRUE.
          WHEN "wth-code"  THEN v-log-wth-code  = TRUE.
          WHEN "host-code" THEN v-log-host-code = TRUE.
          WHEN "obj-code"  THEN IF CAN-FIND(FIRST buf__Field of _File where buf__Field._Field-Name = "obj-type" no-lock)
                           THEN v-log-obj-code  = TRUE.
          WHEN "artic"     THEN IF  CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-type" no-lock)
                                and CAN-FIND(FIRST  buf__Field of _File where buf__Field._Field-Name = "prod-code" no-lock)
                           THEN v-log-artic     = TRUE.
          WHEN "doc-num"   THEN v-log-doc-num   = TRUE.
          OTHERWISE DO:
          END.
      END CASE.

      put stream st-out unformatted
        'ADD FIELD "' + _Field._Field-Name
                      + '" OF c-"'
                      + _File._File-Name
                      + '" AS '
                      + _Field._Data-Type
                      + {&new-line}
        .
      put stream st-out unformatted
        '  DESCRIPTION ' .
      export stream st-out
          _Field._Desc
        .

      put stream st-out unformatted
        '  FORMAT ' .
      export stream st-out
          _Field._Format
        .

      put stream st-out unformatted
        '  INITIAL ' .
      export stream st-out
          _Field._Initial
        .

      put stream st-out unformatted
        '  LABEL ' .
      export stream st-out
          _Field._Label
        .

      put stream st-out unformatted
        '  MANDATORY '
        {&new-line}
        .

      put stream st-out unformatted
        {&new-line}
      .
    end. /* field */

    /* corr-user-db-num */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-user-db-num" OF "c-&1" AS INTEGER', _File._File-Name )
                      + {&new-line}
         '  DESCRIPTION "Номер БД"'
                      + {&new-line}
         '  FORMAT ">>>>9"'
                      + {&new-line}
         '  INITIAL ?'
                      + {&new-line}
         '  LABEL "Номер БД"'
                      + {&new-line}
         '  MAX-WIDTH 4'
                      + {&new-line}
         '  COLUMN-LABEL "Номер БД"'
                      + {&new-line}
         '  MANDATORY'
                      + {&new-line}
                      + {&new-line}
      .

    /*     chip-num */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "chip-num" OF "c-&1" AS INTEGER', _File._File-Name )
                      + {&new-line}
         '  FORMAT ">,>>>,>>9"'
                      + {&new-line}
         '  INITIAL 0'
                      + {&new-line}
         '  LABEL "Щепка"'
                      + {&new-line}
         '  MAX-WIDTH 4'
                      + {&new-line}
         '  COLUMN-LABEL "Щепка"'
                      + {&new-line}
         '  MANDATORY'
                      + {&new-line}
                      + {&new-line}
      .

    /* corr-time */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-time" OF "c-&1" AS INTEGER', _File._File-Name )
                      + {&new-line}
         '  DESCRIPTION "Время изменения в секундах"'
                      + {&new-line}
         '  FORMAT ">>>,>>9"'
                      + {&new-line}
         '  INITIAL 0'
                      + {&new-line}
         '  LABEL "Время изменения в секундах"'
                      + {&new-line}
         '  MAX-WIDTH 4'
                      + {&new-line}
         '  COLUMN-LABEL "Время"'
                      + {&new-line}
                      + {&new-line}
      .

    /* corr-date */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-date" OF "c-&1" AS DATE', _File._File-Name )
                      + {&new-line}
         '  FORMAT 99/99/9999"'
                      + {&new-line}
         '  INITIAL ?'
                      + {&new-line}
         '  LABEL "Дата коррекции"'
                      + {&new-line}
         '  MAX-WIDTH 4'
                      + {&new-line}
         '  COLUMN-LABEL "Номер БД"'
                      + {&new-line}
                      + {&new-line}
      .

    /*corr-user-name     */
      put stream st-out unformatted
         SUBSTITUTE('ADD FIELD "corr-user-name" OF "c-&1" AS CHARACTER', _File._File-Name )
                      + {&new-line}
         '  DESCRIPTION "Имя пользователя"'
                      + {&new-line}
         '  FORMAT "X(8)"'
                      + {&new-line}
         '  INITIAL ""'
                      + {&new-line}
         '  LABEL "Имя пользователя"'
                      + {&new-line}
         '  MAX-WIDTH 16'
                      + {&new-line}
         '  COLUMN-LABEL "Имя"'
                      + {&new-line}
                      + {&new-line}
      .



    /* index */
    find first _index
         where recid( _index  ) = _file._prime-index
           and LC( _index._index-name ) <> "default":U
         no-lock
         no-error.
    if not available _index then do:
      message
         "Не найден первичный индекс для таблицы" _File._File-Name
      view-as alert-box information.
      next.
    end.

    put stream st-out unformatted
      SUBSTITUTE('ADD INDEX "pi" ON "c-&1"', _File._File-Name )
                        + {&new-line}
      + '  AREA "Schema Area"'
                        + {&new-line}
      + '  UNIQUE'
                        + {&new-line}
      + '  PRIMARY'
                        + {&new-line}
    .
    for each _index-field of _index
        no-lock
        ,
        each _field of _index-field
        no-lock
        break by _index-seq:
      put stream st-out unformatted
         SUBSTITUTE('  INDEX-FIELD "&1" &2', _Field._Field-Name, IF _index-field._Ascending THEN "ASCENDING" ELSE "DESCENDING")
                           + {&new-line}
      .

    end.

    put stream st-out unformatted
         '  INDEX-FIELD "corr-user-db-num" ASCENDING'
                           + {&new-line}
         '  INDEX-FIELD "chip-num" ASCENDING'
                           + {&new-line}
                           + {&new-line}
    .

    /*
    IF v-log-gds-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-gds-code" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "gds-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-b-code    THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-b-code" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "b-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-doc-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-doc-code" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "doc-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-rvs-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-rvs-code" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "rvs-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-wth-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-wth-code" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "wth-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-host-code THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-host-code" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "host-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-obj-code  THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-obj" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "obj-type" ASCENDING'
                           + {&new-line}
         + '  INDEX-FIELD "obj-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-artic     THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-artic" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "actic" ASCENDING'
                           + {&new-line}
         + '  INDEX-FIELD "prod-type" ASCENDING'
                           + {&new-line}
         + '  INDEX-FIELD "prod-code" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    IF v-log-doc-num   THEN
    do:
      put stream st-out unformatted
         SUBSTITUTE('ADD INDEX "by-doc-num" ON "c-&1"', _File._File-Name )
                           + {&new-line}
         + '  AREA "Schema Area"'
                           + {&new-line}
         + '  INDEX-FIELD "doc-num" ASCENDING'
                           + {&new-line}
                           + {&new-line}
      .
    end.
    */

    output stream st-out close .
    
    RUN create-trg-w IN THIS-PROCEDURE (INPUT Substitute('&1w.p', v-trig-name), INPUT SUBSTITUTE('c-&1', _file._File-Name)).
    RUN create-trg-d IN THIS-PROCEDURE (INPUT Substitute('&1d.p', v-trig-name), INPUT SUBSTITUTE('c-&1', _file._File-Name)).
    
    
    output stream st-out to value("tbl.lst") append .
    put stream st-out unformatted
       SUBSTITUTE('&1-attr', _File._File-Name )
       + {&new-line}
    .
    output stream st-out close .

end.  /* do on error */
END PROCEDURE. /* add-c */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-df Dialog-Frame 
PROCEDURE create-df :
/*------------------------------------------------------------------------------
   Purpose:
   Parameters:  <none>
   Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-c-old = FALSE
         AND tt-file.f-c     = TRUE
       :
       RUN add-c in this-procedure ( INPUT tt-file._File-Number) .
   end.
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = TRUE
       :
       RUN add-attr in this-procedure  ( INPUT tt-file._File-Number) .
   end.

end.  /* do on error */
END PROCEDURE. /* create-df */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-trg-d Dialog-Frame 
PROCEDURE create-trg-d :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO .
DEFINE INPUT PARAMETER p-tbl-name AS CHARACTER NO-UNDO .

do
on error undo, return error
:
    output stream st-out to value(p-file-name) .

put stream st-out unformatted '/*' +  {&new-line}.
put stream st-out unformatted '' +  {&new-line}.
put stream st-out unformatted '$Revision$' +  {&new-line}.
put stream st-out unformatted '$Author$' +  {&new-line}.
put stream st-out unformatted '$Date$' +  {&new-line}.
put stream st-out unformatted '$Workfile$' +  {&new-line}.
put stream st-out unformatted '$Archive$' +  {&new-line}.
put stream st-out unformatted '' +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('??????? ?? ???????? ??????? &1', p-tbl-name) +  {&new-line}.
put stream st-out unformatted '' +  {&new-line}.
put stream st-out unformatted '?????: ' +  {&new-line}.
put stream st-out unformatted '???? ????????:' +  {&new-line}.
put stream st-out unformatted 'Author: Ilia Belousov' +  {&new-line}.
put stream st-out unformatted 'Creation date:' +  {&new-line} +  {&new-line}.
put stream st-out unformatted '*/' +  {&new-line}  +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('TRIGGER PROCEDURE FOR DELETE OF ub.&1 old old-&1.', p-tbl-name) +  {&new-line} +  {&new-line}.
put stream st-out unformatted 'define variable vss-revision    as character no-undo init "$Revision$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-author      as character no-undo init "$Author$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-date        as character no-undo init "$Date$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-workfile    as character no-undo init "$Workfile$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-archive     as character no-undo init "$Archive$":U .' +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('define variable vss-description as character no-undo init "??????? ?? ???????? ???????".', p-tbl-name) +  {&new-line}  +  {&new-line} +  {&new-line}.
/*put stream st-out unformatted '{ cmp/vssrevis.i "substitute("&1|&2":u, !!!)" }' +  {&new-line}.
put stream st-out unformatted '{ cmp/trg-def.i }' +  {&new-line}.
put stream st-out unformatted '{ gbl/cur-time.i }' +  {&new-line}  +  {&new-line}.
*/
put stream st-out unformatted 'main-block:' +  {&new-line}.
put stream st-out unformatted 'do' +  {&new-line}.
put stream st-out unformatted 'on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))' +  {&new-line}.
put stream st-out unformatted 'on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )' +  {&new-line}.
put stream st-out unformatted 'on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )' +  {&new-line}.
put stream st-out unformatted ':' +  {&new-line}  +  {&new-line} +  {&new-line}.
/*
put stream st-out unformatted         '   run nws/cmd-del.p'.
put stream st-out unformatted SUBSTITUTE('      ( input "&1":U', p-tbl-name) +  {&new-line}.
put stream st-out unformatted '      ,input (buffer ub.alc-type:handle)' +  {&new-line}.
put stream st-out unformatted '      ,input ""' +  {&new-line}.
put stream st-out unformatted '      ) no-error .' +  {&new-line}.
put stream st-out unformatted '   if error-status :error' +  {&new-line}.
put stream st-out unformatted '   then do:' +  {&new-line}.
put stream st-out unformatted '      undo main-block, return error substitute("&1. ?????? ??? ???????? ? ??????? ??????? ?? ???????? ??????. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).' +  {&new-line}.
put stream st-out unformatted '   end.' +  {&new-line}  +  {&new-line}.
put stream st-out unformatted '   if g#oxml = yes' +  {&new-line}.
put stream st-out unformatted '   then do:' +  {&new-line}.
put stream st-out unformatted '   run str/calloxml.p (' +  {&new-line}.
put stream st-out unformatted '         input {&nwsdochs_action_update}' +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('      , input {&table_&1}', p-tbl-name) +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('      , input ( buffer ub.&1:handle )', p-tbl-name) +  {&new-line}.
put stream st-out unformatted '   ) no-error.' +  {&new-line}.
put stream st-out unformatted '   if error-status :error' +  {&new-line}.
put stream st-out unformatted '   then do:' +  {&new-line}.
put stream st-out unformatted '      undo, return error substitute( "&2&1 ?????? ??? ???????? ? ??????? OpenXML ??????? ?? ???????? ?????? OpenXML&1&3&1&4"' +  {&new-line}.
put stream st-out unformatted '                           , {&new-line}' +  {&new-line}.
put stream st-out unformatted '                           , vss-workfile' +  {&new-line}.
put stream st-out unformatted '                           , return-value' +  {&new-line}.
put stream st-out unformatted '                           , error-status :get-message ( 1 ) ).' +  {&new-line}.
put stream st-out unformatted '   end.' +  {&new-line}.
put stream st-out unformatted '   end.' +  {&new-line}.
*/
put stream st-out unformatted 'end. /* main-block */' +  {&new-line}.

    output stream st-out close .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-trg-w Dialog-Frame 
PROCEDURE create-trg-w :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-file-name AS CHARACTER NO-UNDO .
DEFINE INPUT PARAMETER p-tbl-name AS CHARACTER NO-UNDO .

do
on error undo, return error
:
    output stream st-out to value(p-file-name) .
put stream st-out unformatted '/*' +  {&new-line}.
put stream st-out unformatted '' +  {&new-line}.
put stream st-out unformatted '$Revision$' +  {&new-line}.
put stream st-out unformatted '$Author$' +  {&new-line}.
put stream st-out unformatted '$Date$' +  {&new-line}.
put stream st-out unformatted '$Workfile$' +  {&new-line}.
put stream st-out unformatted '$Archive$' +  {&new-line} +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('??????? ?? ????????? ??????? &1', p-tbl-name) +  {&new-line} +  {&new-line}.
put stream st-out unformatted '?????: ' +  {&new-line}.
put stream st-out unformatted '???? ????????:' +  {&new-line}.
put stream st-out unformatted 'Author: Ilia Belousov' +  {&new-line}.
put stream st-out unformatted 'Creation date:' +  {&new-line} +  {&new-line}.
put stream st-out unformatted '*/' +  {&new-line} +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('TRIGGER PROCEDURE FOR WRITE OF ub.&1 old old-&1.', p-tbl-name) +  {&new-line} +  {&new-line}.
put stream st-out unformatted 'define variable vss-revision    as character no-undo init "$Revision$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-author      as character no-undo init "$Author$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-date        as character no-undo init "$Date$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-workfile    as character no-undo init "$Workfile$":U .' +  {&new-line}.
put stream st-out unformatted 'define variable vss-archive     as character no-undo init "$Archive$":U .' +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('define variable vss-description as character no-undo init "??????? ??  ????????? ???????".', p-tbl-name) +  {&new-line} +  {&new-line} +  {&new-line}.
/*
put stream st-out unformatted '{ cmp/vssrevis.i "substitute("&1|&2":u, !!!)" }' +  {&new-line}.
put stream st-out unformatted '{ cmp/trg-def.i }' +  {&new-line}.
put stream st-out unformatted '{ gbl/cur-time.i }' +  {&new-line} +  {&new-line}.
*/
put stream st-out unformatted 'main-block:' +  {&new-line}.
put stream st-out unformatted 'do' +  {&new-line}.
put stream st-out unformatted 'on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))' +  {&new-line}.
put stream st-out unformatted 'on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )' +  {&new-line}.
put stream st-out unformatted 'on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )' +  {&new-line}.
put stream st-out unformatted ':' +  {&new-line} +  {&new-line} +  {&new-line}.
/*put stream st-out unformatted '   run str/callnews.p' +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('      (input {&table_&1}', p-tbl-name) +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('      ,input (buffer ub.&1:handle)', p-tbl-name) +  {&new-line}.
put stream st-out unformatted '      ) no-error .' +  {&new-line}.
put stream st-out unformatted '   if error-status :error' +  {&new-line}.
put stream st-out unformatted '   then do:' +  {&new-line}.
put stream st-out unformatted '      undo main-block, return error substitute("&1. ?????????? ???????????????? ' + p-tbl-name + ' ??? ????????. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( 1 ) ).' +  {&new-line}.
put stream st-out unformatted '   end.' +  {&new-line} +  {&new-line}.
put stream st-out unformatted '   if g#oxml = yes' +  {&new-line}.
put stream st-out unformatted '   then do:' +  {&new-line}.
put stream st-out unformatted '   run str/calloxml.p (' +  {&new-line}.
put stream st-out unformatted '         input {&nwsdochs_action_update}' +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('      , input {&table_&1}', p-tbl-name) +  {&new-line}.
put stream st-out unformatted SUBSTITUTE('      , input ( buffer ub.&1:handle )', p-tbl-name) +  {&new-line}.
put stream st-out unformatted '   ) no-error.' +  {&new-line}.
put stream st-out unformatted '   if error-status :error' +  {&new-line}.
put stream st-out unformatted '   then do:' +  {&new-line}.
put stream st-out unformatted '      undo, return error substitute( "&2&1 ?????? ??? ???????? ? ??????? OpenXML ??????? ?? ???????? ?????? OpenXML&1&3&1&4"' +  {&new-line}.
put stream st-out unformatted '                           , {&new-line}' +  {&new-line}.
put stream st-out unformatted '                           , vss-workfile' +  {&new-line}.
put stream st-out unformatted '                           , return-value' +  {&new-line}.
put stream st-out unformatted '                           , error-status :get-message ( 1 ) ).' +  {&new-line}.
put stream st-out unformatted '   end.' +  {&new-line}.
put stream st-out unformatted '   end.' +  {&new-line}.
*/
put stream st-out unformatted 'end. /* main-block */' +  {&new-line}.
    output stream st-out close .
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deselect-all-attr Dialog-Frame 
PROCEDURE deselect-all-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = TRUE
       :
       assign
         tt-file.f-attr     = FALSE
       .
   end.
end.  /* do on error */
END PROCEDURE. /* deselect-all-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE deselect-all-c Dialog-Frame 
PROCEDURE deselect-all-c :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-c-old = FALSE
         AND tt-file.f-c     = TRUE
       :
       assign
         tt-file.f-c     = FALSE
       .
   end.
end.  /* do on error */
END PROCEDURE. /* deselect-all-c */

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
  DISPLAY v-all 
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-export b-help v-all b-sel-all-c b-sel-all-attr b-drop-all-c 
         b-drop-all-attr BR-file 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-file Dialog-Frame 
PROCEDURE fill-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  define buffer buf__file     for _file .

  for each  _file
      where _file._hidden = false
      no-lock
      /*on error undo, return error*/
      :
      if _file._File-Name begins "c-":U
      or index(_file._File-Name , "-attr":U ) <> 0
      then do:
         next.
      end.
      FIND FIRST _Field OF _File WHERE _Field._Field-Name = "attr-code"
          NO-LOCK
          NO-ERROR
          .
      IF AVAILABLE _Field THEN DO:
          NEXT.
      END.

      create tt-file.
      buffer-copy _file to tt-file .
      IF can-find (FIRST buf__file
                   where buf__file._file-name = SUBSTITUTE( "&1-attr", _file._File-Name)
                   no-lock
                  )
      then do:
         assign
            tt-file.f-attr       = YES
            tt-file.f-attr-old   = YES
         .
      end.
      IF can-find (FIRST buf__file
                   where buf__file._file-name = SUBSTITUTE( "c-&1", _file._File-Name)
                   no-lock
                  )
      then do:
         assign
            tt-file.f-c       = YES
            tt-file.f-c-old   = YES
         .
      end.
  end.
end.  /* do on error */
END PROCEDURE. /* fill-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE post-enable_UI Dialog-Frame 
PROCEDURE post-enable_UI :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   ASSIGN
      tt-file.f-c :READ-ONLY    in browse br-file = NO
      tt-file.f-attr :READ-ONLY in browse br-file = NO
   .
end.  /* do on error */
END PROCEDURE. /* post-enable_UI */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE refresh-query Dialog-Frame 
PROCEDURE refresh-query :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
      OPEN QUERY BR-file
           for each  tt-file
/*               no-lock*/

      INDEXED-REPOSITION .
end.  /* do on error */
END PROCEDURE. /* refresh-query */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-all-attr Dialog-Frame 
PROCEDURE select-all-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-attr-old = FALSE
         AND tt-file.f-attr     = FALSE
       :
       assign
         tt-file.f-attr     = TRUE
       .
   end.
end.  /* do on error */
END PROCEDURE. /* select-all-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-all-c Dialog-Frame 
PROCEDURE select-all-c :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   for each  tt-file
       where tt-file.f-c-old = FALSE
         AND tt-file.f-c     = FALSE
       :
       assign
         tt-file.f-c     = TRUE
       .
   end.
end.  /* do on error */
END PROCEDURE. /* select-all-c */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE trig-name Dialog-Frame 
PROCEDURE trig-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-name   as character no-undo .
define output parameter p-trig-name as character no-undo .

define variable v-absent    as logical      no-undo.
define variable v-file-name as character    no-undo.
define variable v-counter    as integer      no-undo.

do
on error undo, return error
:
   assign
      v-file-name = SUBSTITUTE("trg/&1", SUBSTRING(p-name, 1 , 7 ))
      v-counter   = 0
   .
   REPEAT WHILE NOT v-absent:
      FIND FIRST _File-Trig
         WHERE _File-Trig._Proc-Name begins v-file-name
         no-lock
         no-error
         .
      FIND FIRST tt-trig-name
         WHERE tt-trig-name.f-name begins v-file-name
         no-lock
         no-error
         .
      IF AVAILABLE _File-Trig 
      OR AVAILABLE tt-trig-name
      THEN DO:
         assign
            v-file-name = IF v-counter < 10
                          THEN
                          SUBSTITUTE
                          ( "trg/&1&2"
                          , SUBSTRING(p-name, 1 , 6 )
                          , STRING(v-counter, "9")
                          )
                          ELSE
                          SUBSTITUTE
                          ( "trg/&1&2"
                          , SUBSTRING(p-name, 1 , 5 )
                          , STRING(v-counter, "99")
                          )
            v-counter = v-counter + 1
         .
         next.
      END.
      ELSE DO:
         CREATE tt-trig-name.
         assign
            tt-trig-name.f-name = v-file-name
            v-absent = TRUE
            p-trig-name = v-file-name
         .
         return.
      END.
   END.

end.  /* do on error */
END PROCEDURE. /* trig-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

