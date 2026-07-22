&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование фильтров - списков со справочниками

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input  parameter parParentProc  as widget-handle no-undo .
define input  parameter spr      as character no-undo .
define input  parameter lab_user as character no-undo .
define input  parameter fld      as character no-undo .
define input  parameter lab      as character no-undo .
define input  parameter type     as character no-undo .
define output parameter str      as character no-undo .
define output parameter str_rus  as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование фильтров - списков со справочниками".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5':u,spr,lab_user,fld,lab,type)" }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-shar.i }

DEFINE BUTTON  b-spr
     IMAGE-UP FILE "btn-down-arrow"
     IMAGE-DOWN FILE "btn-down-arrow"
     IMAGE-INSENSITIVE FILE "btn-down-arrow"
     LABEL "":L
     SIZE 2.5 BY .9.

define variable grp     AS WIDGET NO-UNDO.
define variable flw      AS WIDGET NO-UNDO.
define variable fill_in AS WIDGET NO-UNDO.
define variable txt      AS WIDGET NO-UNDO.
define variable btn     AS WIDGET NO-UNDO.

define variable min-width      AS INT    NO-UNDO INIT 20.
define variable frm                AS CHAR NO-UNDO.
define variable frm-text         AS CHAR NO-UNDO.
define variable type_            AS CHAR NO-UNDO.
define variable lab_              AS CHAR NO-UNDO.
define variable fld_               AS CHAR NO-UNDO.
define variable data              AS CHAR NO-UNDO.
define variable join-tbl          AS CHAR NO-UNDO.
define variable join_rus        AS CHAR NO-UNDO.
define variable join_ext        AS CHAR NO-UNDO.
define variable join_rus_ext AS CHAR NO-UNDO.
define variable ii                    AS INT     NO-UNDO.
define variable ii1                   AS INT     NO-UNDO.
define variable j                    AS INT     NO-UNDO.
define variable s                   AS CHAR NO-UNDO.
define variable a                   AS CHAR NO-UNDO.
define variable next-fill-in     AS LOG   NO-UNDO INIT FALSE.
define variable znak             AS CHAR NO-UNDO.
define variable offset            AS CHAR NO-UNDO.
define variable scr-val          AS CHAR NO-UNDO.
define variable name            AS CHAR NO-UNDO.
define variable ref-list           AS CHAR NO-UNDO.
define variable out-an           AS INT     NO-UNDO.
define variable v_type          AS CHAR NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-help b-add b-del list togl Btn_OK ~
Btn_Cancel
&Scoped-Define DISPLAYED-OBJECTS list togl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 10 BY 1 TOOLTIP "Ввести в список внесенное с клавиатуры значение".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 10 BY 1 TOOLTIP "Удалить ранее включенное в список значение".

DEFINE BUTTON B-help
     LABEL "Помо&щь"
     SIZE 2.5 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 10 BY 1 TOOLTIP "Отменить формирование критерия"
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1 TOOLTIP "Сохранить сформированный критерий"
     BGCOLOR 8 .

DEFINE VARIABLE list AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL
     SIZE 20 BY 5.5 NO-UNDO.

DEFINE VARIABLE togl AS LOGICAL INITIAL no
     LABEL "Включительно":L
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     B-help AT ROW 1 COL 1 WIDGET-ID 2
     b-add AT ROW 3.25 COL 3
     b-del AT ROW 3.25 COL 13
     list AT ROW 4.75 COL 3 NO-LABEL
     togl AT ROW 10.25 COL 3
     Btn_OK AT ROW 11.25 COL 3
     Btn_Cancel AT ROW 11.25 COL 13.13
     SPACE(8.11) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "":L
         CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
   FRAME-NAME                                                           */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add DIALOG-1
ON CHOOSE OF b-add IN FRAME DIALOG-1 /* Добавить */
DO:
  run proc-b-add in this-procedure No-ERROR.
  APPLY "ENTRY":U TO btn_cancel IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del DIALOG-1
ON CHOOSE OF b-del IN FRAME DIALOG-1 /* Удалить */
DO:
  ASSIGN list.
  IF list:DELETE( list ) THEN.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-help
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _Main-Block DIALOG-1


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

Main-Block:
DO ON ERROR    UNDO Main-Block, RETURN ERROR
      ON STOP       UNDO Main-Block, RETURN ERROR
      ON END-KEY UNDO Main-Block, RETURN ERROR :
   ASSIGN
     offset    = "3"
     frm        = "":U
     frm-text = "":U.

   DO ii = 1 TO NUM-ENTRIES( lab, '{&delim-flt}' ) :
        type_ = ENTRY(ii, type, '{&delim-flt}' ).
        CASE type_ :
                WHEN {&abl-datatype-character} THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY(ii, offset ) ) + 20 + 2 )
                     frm        = frm        + ',' + "x(20)"
                     frm-text = frm-text + ',' + "x(20)".
                END.
                WHEN {&abl-datatype-integer} THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY(ii, offset ) ) +  10  + 2 )
                     frm        = frm        + ',' + ( ">>>>>>>>>9" )
                     frm-text = frm-text + ',' + ( "x(10)" ).
                END.
                WHEN {&abl-datatype-int64} THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT64( ENTRY(ii, offset ) ) +  10  + 2 )
                     frm        = frm        + ',' + ( ">>>>>>>>>>>>>>>>>>>9" )
                     frm-text = frm-text + ',' + ( "x(20)" ).
                END.
                WHEN {&abl-datatype-decimal} THEN DO:
                   ASSIGN
                     offset    = offset     + ',' + STRING( INT( ENTRY( ii, offset ) ) + 12 + 2 )
                     frm        = frm        + ',' + ">>>>>>>9.999"
                     frm-text = frm-text + ',' + "x(12)".
                END.
                WHEN {&abl-datatype-date} THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY( ii, offset ) ) + 10 + 2 )
                     frm        = frm        + ',' + "99/99/9999"
                     frm-text = frm-text + ',' + "x(10)".
                END.
                WHEN {&abl-datatype-logical} THEN DO:
                   ASSIGN
                     offset    = offset     + ',' + STRING( INT( ENTRY( ii, offset ) ) + 10 + 2 )
                     frm        = frm        + ',' + "yes/no"
                     frm-text = frm-text + ',' + "x(10)".
                END.
                WHEN {&abl-datatype-recid} THEN DO:
                   ASSIGN
                     offset    = offset    + ',' + STRING( INT( ENTRY( ii, offset ) ) +  10  + 2 )
                     frm        = frm        + ',' +  ">>>>>>>>>9"
                     frm-text = frm-text + ',' +  "x(10)" .
                END.
        END CASE.
   END.

   SUBSTR( frm,        1, 1 ) = "".
   SUBSTR( frm-text, 1, 1 ) = "".

   IF INT( ENTRY( NUM-ENTRIES( offset ), offset ) ) > min-width THEN
      min-width = INT( ENTRY( NUM-ENTRIES( offset ), offset ) ).
   IF CAN-DO( "cli,gds", spr ) THEN min-width = min-width + 20 .
   ASSIGN FRAME {&FRAME-NAME}:WIDTH-CHAR = min-width + 3.

   IF spr <> "" THEN DO:
       FORM b-spr WITH FRAME {&FRAME-NAME}.
       ASSIGN
         b-spr:ROW          = 2
         b-spr:COLUMN    = min-width
         b-spr:VISIBLE      = TRUE
         b-spr:SENSITIVE = TRUE.

       ON CHOOSE OF b-spr IN FRAME {&FRAME-NAME} DO:
         define variable grp-rec AS RECID NO-UNDO.
         define variable ref-rec  AS RECID NO-UNDO.

         CASE spr :
            WHEN 'cli' THEN DO:
              ref-list = "".
              run ref/cli-all.w (
                             parParentProc
                           , "b-sel,b-mark":U
                           , {&cmp}
                           , {&all}
                           , {&current}
                           , ?
                           , ",,,,,,NO"
                           , "":U
                           , OUTPUT ref-list ).
              IF ref-list <> "":U THEN DO:
                DO ii1 = 1 to num-entries(ref-list):
                  ASSIGN ref-rec = integer(entry(ii1, ref-list)).
                  FIND ub.clients WHERE RECID( ub.clients ) = ref-rec.
                  ASSIGN
                  name = ub.clients.obj-name
                  grp     = FRAME {&FRAME-NAME}:FIRST-CHILD.
                  DO WHILE ( grp <> ? ) :
                    flw = grp:FIRST-CHILD.
                    DO WHILE ( flw <> ? ) :
                      IF flw:type = 'fill-in' THEN DO:
                        CASE ENTRY( 2, ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ), '-' ) :
                          WHEN "code" THEN flw:SCREEN-VALUE = STRING( clients.obj-code ).
                          WHEN "type"  THEN flw:SCREEN-VALUE = clients.obj-type.
                        END CASE.
                      END.
                      flw = flw:NEXT-SIBLING.
                    END.
                    grp = grp:NEXT-SIBLING.
                  END.

                  APPLY "ENTRY":U   TO b-add IN FRAME {&FRAME-NAME}.
                  RUN proc-b-add in this-procedure.
                END.
              END.
              ELSE DO:
                APPLY "ENTRY":U TO b-spr IN FRAME {&FRAME-NAME}.
              end.
            END. /*when cli*/
            WHEN 'gds' THEN DO:
              run ref/gds-ref.p ( input parparentproc
                              , input "b-sel,b-mark":U
                              , input ?                     /*p-stat */
                              , input ?                     /*p-list  */
                              , input ?                     /*p-cond  */
                              , input ?                     /*p-rec   */
                              , input ?                    /*p-grp   */
                              , input ?                     /*p-cli-type */
                              , input ?                     /*p-cli-code  */
                              , input ?                     /*p-obj-type  */
                              , input ?                      /*p-obj-code  */
                              , input ?                     /*p-other     */
                              , OUTPUT ref-list ).
              IF ref-list <> "":U THEN DO:
                DO II1 = 1 to num-entries(ref-list):
                  ASSIGN ref-rec = INT( ENTRY(ii1, ref-list )).
                  FIND ub.goods NO-LOCK WHERE RECID( ub.goods ) = ref-rec.
                  ASSIGN
                  name = ub.goods.gds-name
                  grp     = FRAME {&FRAME-NAME}:FIRST-CHILD.
                  DO WHILE ( grp <> ? ) :
                    ASSIGN flw = grp:FIRST-CHILD.
                    DO WHILE ( flw <> ? ) :
                      IF flw:type = 'fill-in' THEN DO:
                        CASE ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ) :
                          WHEN "prod-code" THEN flw:SCREEN-VALUE = STRING( prod-code ).
                          WHEN "prod-type"  THEN flw:SCREEN-VALUE = prod-type.
                          WHEN "artic"          THEN flw:SCREEN-VALUE = artic.
                        END CASE.
                      END.
                      ASSIGN flw = flw:NEXT-SIBLING.
                    END.
                    ASSIGN grp = grp:NEXT-SIBLING.
                  END.
                  APPLY "ENTRY":U   TO b-add IN FRAME {&FRAME-NAME}.
                  RUN proc-b-add in this-procedure.
                END.
              END.
              ELSE DO:
                APPLY "ENTRY":U TO b-spr IN FRAME {&FRAME-NAME}.
              END.

            END. /*when gds*/
         END CASE.
       END.
   END.

   ASSIGN list:WIDTH-CHAR = INT( ENTRY( NUM-ENTRIES( offset ), offset ) ) - 3 + 1.
   IF CAN-DO( "cli,gds", spr) THEN list:WIDTH-CHAR = list:WIDTH-CHAR +  20 .
   IF lab_user = "":U OR lab_user = ? THEN lab_user = lab.
   DO ii = 1 TO NUM-ENTRIES( lab_user, '{&delim-flt}' ) :
        lab_ = ENTRY( ii, lab_user, '{&delim-flt}' ).
        CREATE TEXT txt
                   ASSIGN
                     FRAME               = FRAME {&FRAME-NAME}:HANDLE
                     DATA-TYPE        = "character"
                     FORMAT             = ENTRY( ii, frm-text )
                     SCREEN-VALUE = lab_
                     ROW                  = 1
                     COLUMN            = INT( ENTRY(ii, offset ) ).
   END.

   DO ii = 1 TO NUM-ENTRIES( type, '{&delim-flt}' ) :
      ASSIGN
        type_ = ENTRY( ii, type, '{&delim-flt}' )
        fld_    = ENTRY( ii, fld,    '{&delim-flt}' )
        lab_   = ENTRY( ii, lab,   '{&delim-flt}' ).
        CREATE FILL-IN fill_in
                   ASSIGN
                     FRAME            = FRAME {&FRAME-NAME}:HANDLE
                     DATA-TYPE     = type_
                     FORMAT          = ENTRY( ii, frm )
                     PRIVATE-DATA = fld_ + ',' + lab_
                     ROW                = 2
                     COLUMN          = INT( ENTRY( ii, offset ) )
                     SENSITIVE       = TRUE
                     VISIBLE            = TRUE.
   END.
   togl = TRUE.

   RUN enable_UI.
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.

   ASSIGN list.
   IF list:NUM-ITEMS = 0 THEN RETURN ERROR.

   IF INPUT FRAME {&FRAME-NAME} togl THEN DO:
     ASSIGN
      znak      = " = "
      join-tbl   = " AND "  join_rus        = " И "
      join_ext = " OR "    join_rus_ext = " ИЛИ ".
   END. ELSE DO:
     ASSIGN
      znak      = " <> "
      join-tbl   = " OR "    join_rus        = " ИЛИ "
      join_ext = " AND "  join_rus_ext = " И ".
   END.

   ASSIGN
     str        = '('
     str_rus = '('.

   DO ii = 1 TO list:NUM-ITEMS :
        ASSIGN
          s   = ENTRY( ii, list:LIST-ITEMS )
          str = str + '('.
        IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + '('.
        DO j = 1 TO NUM-ENTRIES( type, '{&delim-flt}' ) :
             ASSIGN
               type_ = ENTRY( j, type, '{&delim-flt}' )
               fld_    = ENTRY( j, fld,    '{&delim-flt}' )
               lab_   = ENTRY( j, lab,   '{&delim-flt}' )
               data   = TRIM( ENTRY( j, s, '|' ) ).
             IF type_ = "character" THEN data = '"' + data + '"'.
             IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + lab_ + znak + data.
             IF type_ = "date" THEN data = ENTRY( 2, data, {&slash-char} ) + ENTRY( 1, data, {&slash-char} ) + ENTRY( 3, data, {&slash-char} ).
             str = str + fld_ + znak + data.
             IF j <> NUM-ENTRIES( type, '{&delim-flt}' ) THEN DO:
                  str = str + join-tbl.
                  IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + join_rus.
             END.
        END.

        IF CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + lab_user + znak + '"' + TRIM( ENTRY( j, s, '|' ) ) + '"'.
        str = str + ')'.
        IF NOT CAN-DO( "cli,gds", spr ) THEN str_rus = str_rus + ')'.
        IF ii <> list:NUM-ITEMS THEN DO:
           ASSIGN
             str        = str + join_ext
             str_rus = str_rus + join_rus_ext.
        END.
   END.

   ASSIGN
     str        = str        + ')'
     str_rus = str_rus + ')'.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1  _DEFAULT-DISABLE
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
  HIDE FRAME DIALOG-1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1  _DEFAULT-ENABLE
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
  DISPLAY list togl
      WITH FRAME DIALOG-1.
  ENABLE B-help b-add b-del list togl Btn_OK Btn_Cancel
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add DIALOG-1
PROCEDURE proc-b-add :
define variable type_  AS CHAR NO-UNDO.
define variable code_ AS INT     NO-UNDO.
define variable art_     AS CHAR NO-UNDO.
define variable jnum_ AS INT     NO-UNDO.
define variable jsub_  AS INT     NO-UNDO.
define variable jhost-code_ as int no-undo.
define variable v-found as integer no-undo extent 4.

  ASSIGN
   s    = ""
   grp = FRAME {&FRAME-NAME}:FIRST-CHILD.

  DO WHILE ( grp <> ? ) :
        flw = grp:FIRST-CHILD.
        DO WHILE ( flw <> ? ) :
             IF flw:type = 'fill-in' THEN DO:
                IF spr = 'cli' THEN DO:
                  CASE ENTRY( 2, ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ), '-' ) :
                      WHEN "code" THEN code_ = INT( flw:SCREEN-VALUE ).
                      WHEN "type"  THEN type_  = flw:SCREEN-VALUE.
                  END CASE.
                END.
                IF spr = 'gds' THEN DO:
                  CASE ENTRY( 2, ENTRY( 1, flw:PRIVATE-DATA ), '.' ) :
                       WHEN "prod-code" THEN code_ = INT( flw:SCREEN-VALUE ).
                       WHEN "prod-type"  THEN type_ = flw:SCREEN-VALUE.
                       WHEN "artic"          THEN art_    = flw:SCREEN-VALUE.
                  END CASE.
                END.

                CASE flw:DATA-TYPE :
                   WHEN {&abl-datatype-character} THEN scr-val = STRING(          flw:SCREEN-VALUE,   flw:FORMAT ).
                   WHEN {&abl-datatype-decimal}   THEN scr-val = STRING( DEC( flw:SCREEN-VALUE ), flw:FORMAT ).
                   WHEN {&abl-datatype-integer}     THEN scr-val = STRING( INT( flw:SCREEN-VALUE ),  flw:FORMAT ).
                   WHEN {&abl-datatype-int64}     THEN scr-val = STRING( INT( flw:SCREEN-VALUE ),  flw:FORMAT ).
                   WHEN {&abl-datatype-date}         THEN scr-val = STRING(         flw:SCREEN-VALUE,    'x(10)'          ).
                   WHEN {&abl-datatype-logical}     THEN scr-val = STRING(         flw:SCREEN-VALUE,    'x(10)'          ).
                   WHEN {&abl-datatype-recid}        THEN scr-val = STRING( INT( flw:SCREEN-VALUE ), '>>>>>>>>>9' ).
                END CASE.
                s = s + scr-val + ' |'.
             END.
             flw = flw:NEXT-SIBLING.
        END.
        grp = grp:NEXT-SIBLING.
   END.

   CASE spr :
      WHEN 'cli' THEN DO:
        if lookup(type_, ("":U + {&comma-char} +
                          {&cmp} + {&comma-char} +
                          {&prs} + {&comma-char} +
                          {&shop} + {&comma-char} +
                          {&stock}) ) = 0 then do:
          message "Неверный тип клиента".
          return no-apply.
        end.
        if type_ = "":U then do:
            FIND ub.clients WHERE
                ub.clients.obj-type  = {&cmp}
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[1] = 1.
            FIND ub.clients WHERE
                ub.clients.obj-type  = {&prs}
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[2] = 1.
            FIND ub.clients WHERE
                ub.clients.obj-type  = {&shop}
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[3] = 1.
            FIND ub.clients WHERE
                ub.clients.obj-type  = {&stock}
            AND ub.clients.obj-code = code_ NO-ERROR.
            if avail ub.clients then v-found[4] = 1.
            if v-found[1] + v-found[2] + v-found[3] + v-found[4] > 1 then do:
              message "Есть два клиента или более с кодом" code_ skip
              "Уточните тип клиента"
              view-as alert-box .
              return no-apply.
            end.
            else do:
              if v-found[1]  = 1 then
              assign
              type_ =   {&cmp}
              .
              if v-found[2]  = 1 then
              assign
              type_ =   {&prs}
              .
              if v-found[3]  = 1 then
              assign
              type_ =   {&shop}
              .
              if v-found[4]  = 1 then
              assign
              type_ =   {&stock}
              .
            end.
         end.
         FIND ub.clients WHERE
             ub.clients.obj-type  = type_
         AND ub.clients.obj-code = code_ NO-ERROR.
         IF NOT AVAIL ub.clients THEN DO:
            MESSAGE "Клиент отсутствует".
            RETURN NO-APPLY.
         END.
         ELSE ASSIGN name = ub.clients.obj-name.
      END.
      WHEN 'gds' THEN DO:
        FIND ub.goods WHERE ub.goods.prod-type  = type_
                                        AND ub.goods.prod-code = code_
                                        AND ub.goods.artic          = art_     NO-ERROR.
        IF NOT AVAIL ub.goods THEN DO:
            MESSAGE "Товар отсутствует".
            RETURN NO-APPLY.
        END.
        ELSE do:
          ASSIGN name = ub.goods.gds-name.
        end.
      END.
   END CASE.

  IF CAN-DO( "cli,gds", spr ) THEN s = s + name.
  ii = LOOKUP( s, list:LIST-ITEMS ).
  IF ii = 0 OR ii = ? THEN IF list:ADD-LAST( s ) THEN.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME