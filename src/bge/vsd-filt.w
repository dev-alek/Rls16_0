&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INIT "$Revision$":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author$":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date$":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile$":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive$":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "".

DEFINE VARIABLE v-bge-dper-host-code    AS INTEGER      NO-UNDO.
DEFINE VARIABLE v-bge-dper-store-type   AS CHARACTER    NO-UNDO.
DEFINE VARIABLE v-bge-dper-store-code   AS INTEGER      NO-UNDO.

{ bge/ds-vsd-set.i }
DEFINE VARIABLE v-host-name         AS CHARACTER    NO-UNDO.
DEFINE INPUT PARAMETER parparentproc        AS HANDLE               NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER DATASET FOR ds-vsd-set.

{ cmp/library.i  }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
&UNDEFINE gds-list_i_def
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/userobjs.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-2 Btn_OK Btn_Cancel btn_cler ~
vTime v-date-start v-date-end vdoc-code vReqVerif vToExtin vRep vFalVerif ~
vFalExting vSent SelObj b-obj b-spisok 
&Scoped-Define DISPLAYED-OBJECTS vTime v-date-start v-date-end vdoc-code ~
vReqVerif vToExtin vRep vFalVerif vFalExting vSent v-obj-list SelObj ~
v-gds-list 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-obj DEFAULT 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "":L 
     SIZE 8 BY 1.08.

DEFINE BUTTON b-spisok 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Товары" 
     SIZE 8 BY 1.92 TOOLTIP "Выбор товаров".

DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отменить" 
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btn_cler 
     LABEL "Сброс" 
     SIZE 12 BY 1.

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Применить" 
     SIZE 15 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-gds-list AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 58 BY 3.67 NO-UNDO.

DEFINE VARIABLE v-obj-list AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 58 BY 3.79 NO-UNDO.

DEFINE VARIABLE v-date-end AS DATE FORMAT "99/99/9999":U 
     LABEL "По" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-start AS DATE FORMAT "99/99/9999":U 
     LABEL "C" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE vdoc-code AS CHARACTER FORMAT "X(256)":U 
     LABEL "Ном. Накл." 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE vTime AS INTEGER FORMAT ">>>9":U INITIAL 0 
     LABEL "Время гашения" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE SelObj AS CHARACTER INITIAL "Глобально" 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Глобально", "Глобально",
"По фирме", "По фирме",
"Выборочно", "Выборочно"
     SIZE 17 BY 2.21 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 92 BY 4.5.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 92 BY 4.5.

DEFINE VARIABLE vFalExting AS LOGICAL INITIAL yes 
     LABEL "Ошибка гашения" 
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY 1 NO-UNDO.

DEFINE VARIABLE vFalRegis AS LOGICAL INITIAL no 
     LABEL "Ошибка регистрации" 
     VIEW-AS TOGGLE-BOX
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE vFalVerif AS LOGICAL INITIAL yes 
     LABEL "Ошибка проверки ВСД" 
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY 1 NO-UNDO.

DEFINE VARIABLE vRegis AS LOGICAL INITIAL no 
     LABEL "Зарегистрирован" 
     VIEW-AS TOGGLE-BOX
     SIZE 23 BY 1 NO-UNDO.

DEFINE VARIABLE vRep AS LOGICAL INITIAL yes 
     LABEL "Погашен" 
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE vReqVerif AS LOGICAL INITIAL yes 
     LABEL "Требует проверки" 
     VIEW-AS TOGGLE-BOX
     SIZE 22 BY 1 NO-UNDO.

DEFINE VARIABLE vSent AS LOGICAL INITIAL yes 
     LABEL "Отправлен" 
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.

DEFINE VARIABLE vToExtin AS LOGICAL INITIAL yes 
     LABEL "К гашению" 
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.

DEFINE VARIABLE vToRegi AS LOGICAL INITIAL no 
     LABEL "К регистрации" 
     VIEW-AS TOGGLE-BOX
     SIZE 19 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.5 COL 7
     Btn_Cancel AT ROW 1.5 COL 22.5
     btn_cler AT ROW 1.5 COL 35 WIDGET-ID 44
     vTime AT ROW 3.88 COL 16 COLON-ALIGNED WIDGET-ID 22
     v-date-start AT ROW 3.88 COL 34 COLON-ALIGNED WIDGET-ID 36
     v-date-end AT ROW 3.88 COL 53 COLON-ALIGNED WIDGET-ID 38
     vdoc-code AT ROW 3.88 COL 81 COLON-ALIGNED WIDGET-ID 40
     vReqVerif AT ROW 5.5 COL 6 WIDGET-ID 2
     vToExtin AT ROW 5.5 COL 38 WIDGET-ID 6
     vRep AT ROW 5.5 COL 62 WIDGET-ID 10
     vFalVerif AT ROW 6.71 COL 6 WIDGET-ID 4
     vFalExting AT ROW 6.71 COL 38 WIDGET-ID 8
     vSent AT ROW 6.71 COL 62 WIDGET-ID 42
     v-obj-list AT ROW 9.08 COL 34 NO-LABEL
     SelObj AT ROW 10.04 COL 6 NO-LABEL
     b-obj AT ROW 11.25 COL 23
     v-gds-list AT ROW 13.88 COL 34 NO-LABEL
     b-spisok AT ROW 15.71 COL 19 WIDGET-ID 26
     vToRegi AT ROW 18.13 COL 7 WIDGET-ID 12
     vFalRegis AT ROW 18.13 COL 27 WIDGET-ID 14
     vRegis AT ROW 18.13 COL 54 WIDGET-ID 16
     "Выбор товаров" VIEW-AS TEXT
          SIZE 17 BY 1.67 TOOLTIP "Выбор товаров" AT ROW 13.88 COL 14 WIDGET-ID 30
     RECT-1 AT ROW 8.88 COL 3 WIDGET-ID 32
     RECT-2 AT ROW 13.38 COL 3 WIDGET-ID 34
     SPACE(3.59) SKIP(2.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Фильтр ВСД"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


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
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR EDITOR v-gds-list IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR EDITOR v-obj-list IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX vFalRegis IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       vFalRegis:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX vRegis IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       vRegis:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR TOGGLE-BOX vToRegi IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN 
       vToRegi:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Фильтр ВСД */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-obj Dialog-Frame
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO: /* выбрать объект */
  define variable v-user-select as logical   no-undo .

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  { gbl/uobjsman.i
    parparentproc
    v-cntxt-db-num
    v-cntxt-userid
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-user-select
  }
  if v-user-select = true
  then do:
    for each t-obj-list
    on error undo, return no-apply
    :
      delete t-obj-list .
    end.
    assign
      v-obj-list    = "":U
    .

    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      create t-obj-list .
      assign
        t-obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        t-obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
        v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U NO-ERROR.
      .
    end.
    display
      v-obj-list
      with frame {&frame-name}
    .

  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spisok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spisok Dialog-Frame
ON CHOOSE OF b-spisok IN FRAME Dialog-Frame /* Товары */
DO:
    RUN sel-goods IN THIS-PROCEDURE .
     
   /* run refresh-query in this-procedure. */   
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_cler
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_cler Dialog-Frame
ON CHOOSE OF btn_cler IN FRAME Dialog-Frame /* Сброс */
DO:
   DEFINE VARIABLE v-object-available AS LOGICAL   NO-UNDO .
   ASSIGN 
        v-date-end   = TODAY
        v-date-start = TODAY
        vFalExting   = YES
        vFalVerif    = YES 
        vRep         = YES 
        vReqVerif    = YES 
        vToExtin     = YES
        vTime        = 0
        tt-vsd-filt.doc-code = ?
        SelObj       = "Глобально"
        v-obj-list   = "" 
         
        .
     
      
      FOR EACH t-obj-list:
         delete t-obj-list.
      end.
      
      FOR EACH t-obj-list:
         delete tt-gds-list.
      end.
      
      FOR EACH db NO-LOCK
        ON ERROR UNDO, RETURN NO-APPLY
        :
        FOR EACH clients NO-LOCK
            WHERE clients.db-num = db.db-num
            ON ERROR UNDO, RETURN NO-APPLY
            :
            { gbl/usobjava.i
            v-cntxt-db-num
            {&action-head-code-main}
            v-cntxt-userid
            clients.obj-type
            clients.obj-code
            v-object-available
            no-error
          }
            IF ERROR-STATUS :ERROR
                THEN 
            DO:
                MESSAGE
                    vss-workfile vss-revision vss-description SKIP
                    "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
                    ERROR-STATUS :GET-MESSAGE(1) SKIP
                    RETURN-VALUE SKIP
                    VIEW-AS ALERT-BOX ERROR .
                UNDO, RETURN NO-APPLY .
            END.

            IF v-object-available = TRUE
                THEN 
            DO:
                CREATE t-obj-list .
                ASSIGN
                    t-obj-list.obj-type = clients.obj-type
                    t-obj-list.obj-code = clients.obj-code
                    v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
                    no-error.
            END.
        END.
    END.
     DISPLAY vTime v-date-start v-date-end vReqVerif vFalVerif vToExtin vFalExting 
          vRep vSent SelObj v-obj-list
      WITH FRAME Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Применить */
DO:
    FOR EACH tt-gds-list:
        DELETE tt-gds-list.
    END.
    FOR EACH gds-list:
        CREATE tt-gds-list.
        BUFFER-COPY gds-list TO tt-gds-list.
    END.
    FIND FIRST tt-vsd-filt.
    ASSIGN
        v-date-end 
        v-date-start
        vtime
        vFalExting
        vFalVerif
        vRep
        vReqVerif
        vToExtin
        vdoc-code
        vSent.
    Assign
        tt-vsd-filt.date-end    = v-date-end    
        tt-vsd-filt.date-start  = v-date-start 
        tt-vsd-filt.fTime       = vtime         
        tt-vsd-filt.FalExting   = vFalExting   
        tt-vsd-filt.FalVerif    = vFalVerif
        tt-vsd-filt.Rep         = vRep         
        tt-vsd-filt.ReqVerif    = vReqVerif     
        tt-vsd-filt.ToExtin     = vToExtin
        tt-vsd-filt.Sent        = vSent
        tt-vsd-filt.doc-code    = vdoc-code      
    .
   
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME SelObj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL SelObj Dialog-Frame
ON VALUE-CHANGED OF SelObj IN FRAME Dialog-Frame
DO:
  DEFINE BUFFER buf_db      FOR ub.db  .
  DEFINE BUFFER buf_clients FOR ub.clients .

  DEFINE VARIABLE v-object-available AS LOGICAL   NO-UNDO .
  ASSIGN
    SelObj
  .
  FOR EACH t-obj-list
  ON ERROR UNDO, RETURN NO-APPLY
  :
    DELETE t-obj-list .
  END.
  ASSIGN
    v-obj-list = "":U
  .
  CASE SelObj :
    WHEN "Выборочно" THEN DO:
      ENABLE b-obj WITH FRAME {&frame-name} .
    END.
    WHEN "По фирме" THEN DO:
      DISABLE b-obj WITH FRAME {&frame-name} .

      FOR EACH buf_clients NO-LOCK
        WHERE buf_clients.host-code = v-cntxt-host-code-obj
      ON ERROR UNDO, RETURN NO-APPLY
      :
        { gbl/usobjava.i
          v-cntxt-db-num
          {&action-head-code-main}
          v-cntxt-userid
          buf_clients.obj-type
          buf_clients.obj-code
          v-object-available
          no-error
        }
        IF ERROR-STATUS :ERROR
        THEN DO:
          MESSAGE
            vss-workfile vss-revision vss-description SKIP
            "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
            ERROR-STATUS :GET-MESSAGE(1) SKIP
            RETURN-VALUE SKIP
            VIEW-AS ALERT-BOX ERROR .
          UNDO, RETURN NO-APPLY .
        END.

        IF v-object-available = TRUE
        THEN DO:
          CREATE t-obj-list .
          ASSIGN
            t-obj-list.obj-type = buf_clients.obj-type
            t-obj-list.obj-code = buf_clients.obj-code
            v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U 
          NO-ERROR .
        END.
      END.
    END.
    WHEN "Глобально" THEN DO:
      DISABLE b-obj WITH FRAME {&frame-name} .
      FOR EACH buf_db NO-LOCK
      ON ERROR UNDO, RETURN NO-APPLY
      :
        FOR EACH buf_clients NO-LOCK
          WHERE buf_clients.db-num = buf_db.db-num
        ON ERROR UNDO, RETURN NO-APPLY
        :
          { gbl/usobjava.i
            v-cntxt-db-num
            {&action-head-code-main}
            v-cntxt-userid
            buf_clients.obj-type
            buf_clients.obj-code
            v-object-available
            no-error
          }
          IF ERROR-STATUS :ERROR
          THEN DO:
            MESSAGE
              vss-workfile vss-revision vss-description SKIP
              "Ошибка при вызове процедуры gbl/usobjava.i" SKIP
              ERROR-STATUS :GET-MESSAGE(1) SKIP
              RETURN-VALUE SKIP
              VIEW-AS ALERT-BOX ERROR .
            UNDO, RETURN NO-APPLY .
          END.

          IF v-object-available = TRUE
          THEN DO:
            CREATE t-obj-list .
            ASSIGN
              t-obj-list.obj-type = buf_clients.obj-type
              t-obj-list.obj-code = buf_clients.obj-code
              v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U
            .
          END.
        END.
      END.
    END.
  END CASE.
  DISPLAY
    v-obj-list
    WITH FRAME {&frame-name}
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT EQ ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    FOR EACH tt-gds-list:
        CREATE gds-list.
        BUFFER-COPY tt-gds-list TO gds-list.
        v-gds-list = v-gds-list + "," + string(gds-list.gds-code) NO-ERROR.
        
    END.
    v-gds-list = TRIM (SUBSTRING(v-gds-list,2))  .
    FOR EACH t-obj-list:
        v-obj-list = v-obj-list + t-obj-list.obj-type + string( t-obj-list.obj-code ) + " ":U.
    END. 
    IF TRIM (v-obj-list) NE ""
    THEN
        SelObj = "выборочно".
    IF TRIM (v-obj-list) NE ""
    THEN
        ENABLE b-obj WITH FRAME {&frame-name} .
    ELSE     
        DISABLE b-obj WITH FRAME {&frame-name} . 
    FIND FIRST tt-vsd-filt NO-ERROR .
    IF AVAIL tt-vsd-filt  
    THEN ASSIGN 
        v-date-end   = tt-vsd-filt.date-end
        v-date-start = tt-vsd-filt.date-start
        vtime        = tt-vsd-filt.fTime
        vFalExting   = tt-vsd-filt.FalExting
        vFalVerif    = tt-vsd-filt.FalVerif
        vRep         = tt-vsd-filt.Rep
        vReqVerif    = tt-vsd-filt.ReqVerif
        vToExtin     = tt-vsd-filt.ToExtin
        vdoc-code    = tt-vsd-filt.doc-code
        vSent        = tt-vsd-filt.Sent
        .
    { gbl/getcntxt.i get }
    
    . 

  RUN enable_UI.
  IF TRIM (v-obj-list) EQ  ""
  THEN
    APPLY "value-changed" TO SelObj IN FRAME {&frame-name} .
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
  DISPLAY vTime v-date-start v-date-end vdoc-code vReqVerif vToExtin vRep 
          vFalVerif vFalExting vSent v-obj-list SelObj v-gds-list 
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-2 Btn_OK Btn_Cancel btn_cler vTime v-date-start v-date-end 
         vdoc-code vReqVerif vToExtin vRep vFalVerif vFalExting vSent SelObj 
         b-obj b-spisok 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE sel-goods Dialog-Frame 
PROCEDURE sel-goods :
DEFINE VARIABLE v-list AS CHARACTER NO-UNDO.
    v-list = "" .
    RUN str/gds-list.w (
        INPUT parparentproc
      , INPUT v-cntxt-host-code-obj
      , INPUT v-cntxt-obj-type
      , INPUT v-cntxt-obj-code) NO-ERROR.

     
    FOR EACH gds-list NO-LOCK:
        v-list = v-list + "," + string(gds-list.gds-code) NO-ERROR.
    END.
    v-gds-list = TRIM (SUBSTRING(v-list,2))  .
    DISPLAY v-gds-list WITH FRAME Dialog-Frame .
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

