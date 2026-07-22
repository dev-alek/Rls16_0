&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание файла

Автор: Сливенко Сергей Андреевич
Дата создания: 11/07/11
Author: Sergey Slivenko
Creation date: 11/07/11

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Отчет по продажам упаковками (Закладка №2)".
{ cmp/vssrevis.i }


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
def var rserv as char init "all" no-undo .
def var print-o as char init "" no-undo .

define variable Obj1-list  as character no-undo .
define variable Obj2-list  as character no-undo .

{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/showinf.i }
define variable parParentProc as widget-handle no-undo .
assign parParentProc = my-handle .
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ trg/factord.i  }
{ gbl/clntattr.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-8 RECT-9 inv-shift-start inv-shift-end ~
BUTTON-Shift-end BUTTON-Shift-Start inv-date-start inv-date-end ~
tog-only-itog
&Scoped-Define DISPLAYED-OBJECTS inv-shift-start inv-shift-end ~
inv-date-start inv-date-end tog-only-itog

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-Shift-end
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на обьекте"
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-Shift-Start
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .86 TOOLTIP "Выбор  смены на обьекте"
     BGCOLOR 8 .

DEFINE VARIABLE inv-date-end AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE inv-date-start AS DATE FORMAT "99/99/9999":U
     LABEL "с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE inv-shift-end AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN NATIVE
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE VARIABLE inv-shift-start AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "с"
     VIEW-AS FILL-IN NATIVE
     SIZE 3 BY 1
     BGCOLOR 15  NO-UNDO.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 38.2 BY 1.81.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 54 BY 5.

DEFINE VARIABLE tog-only-itog AS LOGICAL INITIAL no 
     LABEL "Выводить только итоги" 
     VIEW-AS TOGGLE-BOX
     SIZE 35 BY 1.19 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     inv-shift-start AT ROW 3.14 COL 7 COLON-ALIGNED
     inv-shift-end AT ROW 3.14 COL 26.8 COLON-ALIGNED
     BUTTON-Shift-end AT ROW 3.14 COL 32 WIDGET-ID 14
     BUTTON-Shift-Start AT ROW 3.19 COL 12.4 WIDGET-ID 12
     inv-date-start AT ROW 4.33 COL 7 COLON-ALIGNED WIDGET-ID 6
     inv-date-end AT ROW 4.33 COL 26.8 COLON-ALIGNED WIDGET-ID 8
     tog-only-itog AT ROW 6.71 COL 3.6 WIDGET-ID 2
     "Период для расчёта данных по инвентаризации :" VIEW-AS TEXT
          SIZE 51.6 BY .95 AT ROW 1.48 COL 3.4 WIDGET-ID 4
     RECT-8 AT ROW 6.62 COL 2
     RECT-9 AT ROW 1.24 COL 2 WIDGET-ID 10
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 9.43
         WIDTH              = 77.2.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object 
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN 
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME BUTTON-Shift-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-Shift-end s-object
ON CHOOSE OF BUTTON-Shift-end IN FRAME F-Main
DO:
  /*{ gbl/getcntxt.i get }*/
  define variable v-doc-rec as recid no-undo .
  define variable rec-list-2      as char no-undo.
  IF  X-SelectObject = {&obj-currency} then do:
    find first shift-obj No-LOCK WHERE
              shift-obj.shift-date = inv-date-end AND
              shift-obj.shift-num = inv-shift-end AND
              shift-obj.obj-type = v-cntxt-obj-type AND
              shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if avail shift-obj then
    rec-list-2 = string(recid(shift-obj)).
  end.
  IF  X-SelectObject = {&obj-currency}
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type   /*p-obj-type*/
                   ,input v-cntxt-obj-code   /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "all":U
                   ,input '':U  /*p-obj-type*/
                   ,input 0     /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
    end.

    find shift-obj where recid (shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if AVAILABLE  shift-obj then DO:
       Assign
        inv-date-end  = shift-obj.shift-date
        inv-shift-end = shift-obj.shift-num.
         enable inv-date-end  inv-shift-end with frame {&frame-name}.
       Display inv-date-end  inv-shift-end with frame {&frame-name}.

        apply "leave" to inv-shift-end .
        apply "leave" to inv-date-end .

    End.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-Shift-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-Shift-Start s-object
ON CHOOSE OF BUTTON-Shift-Start IN FRAME F-Main
DO:
  /*{ gbl/getcntxt.i get }*/
  define variable v-doc-rec as recid no-undo .
  define variable rec-list-2      as char no-undo.
  IF  X-SelectObject = {&obj-currency} then do:
    find first shift-obj No-LOCK WHERE
              shift-obj.shift-date = inv-date-start AND
              shift-obj.shift-num = inv-shift-start AND
              shift-obj.obj-type = v-cntxt-obj-type AND
              shift-obj.obj-code = v-cntxt-obj-code No-ERROR.
    if avail shift-obj then
    rec-list-2 = string(recid(shift-obj)).
  end.
  IF  X-SelectObject = {&obj-currency}
  then do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "obj":U
                   ,input v-cntxt-obj-type   /*p-obj-type*/
                   ,input v-cntxt-obj-code   /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
  end.
  Else do:
      run str/sht-all.w
      (             input my-handle
                   ,input v-cntxt-obj-type /*p-curr-obj-type*/
                   ,input v-cntxt-obj-code /*p-curr-obj-code*/
                   ,input  "b-sel"
                   ,input "all":U
                   ,input '':U  /*p-obj-type*/
                   ,input 0     /*p-obj-code*/
                   ,input ReportProc
                   ,input-output rec-list-2 ).
    end.

    find shift-obj where recid (shift-obj) = integer (entry(1,rec-list-2))  no-lock no-error.
    if AVAILABLE  shift-obj then DO:
       Assign
        inv-date-start  = shift-obj.shift-date
        inv-shift-start = shift-obj.shift-num.
         enable inv-date-start  inv-shift-start with frame {&frame-name}.
       Display inv-date-start  inv-shift-start with frame {&frame-name}.

        apply "leave" to inv-shift-start .
        apply "leave" to inv-date-start .

    End.
 END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Date-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL inv-Date-End s-object
ON LEAVE OF inv-Date-End IN FRAME F-Main /* по */
DO:
    Assign  inv-Date-End no-error.
    run verify-date in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Date-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL inv-Date-Start s-object
ON LEAVE OF inv-Date-Start IN FRAME F-Main /* с */
DO:
    Assign  inv-Date-Start no-error.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Shift-End
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL inv-Shift-End s-object
ON LEAVE OF inv-Shift-End IN FRAME F-Main /* по */
DO:
  Assign inv-Shift-End.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Shift-Start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL inv-Shift-Start s-object
ON LEAVE OF inv-Shift-Start IN FRAME F-Main /* с */
DO:
  Assign inv-Shift-Start.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
  run enable_UI in this-procedure .
&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object
PROCEDURE enable_UI :
assign
    inv-date-start  = TODAY
    inv-date-end    = TODAY
    inv-shift-start = 0
    inv-shift-end   = 0
  .
  display inv-date-start inv-date-end inv-shift-start inv-shift-end with frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE verify-date s-object
PROCEDURE verify-date :
if Date(inv-Date-End:screen-value In frame {&frame-name}) < DATE(inv-Date-Start:screen-value In frame {&frame-name}) then DO:
   message "Интервал дат введен неверно !" view-as alert-box error TITLE "О Ш И Б К А !!!".
   Return error.
End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object 
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :

/*Расчет архив*/
      define variable v-db-num as integer   no-undo .
      define buffer buf_db  for ub.db .
      define buffer buf_clients for ub.clients .
      define variable v-recalc-date as date no-undo .
      
      { gbl/curdbnum.i
        v-db-num
      }

      for each buf_db no-lock
        where v-db-num = 0
           or (v-db-num <> 0
               and buf_db.db-num = v-db-num
              )
      on error undo, return error
      :
        for each buf_clients no-lock
          where buf_clients.db-num = buf_db.db-num
        on error undo, return error
        :
          /* проверка СМЕННЫЙ объект должен иметь открытую смену (или закрытую после даты) */
          define buffer lock_shift-obj for ub.shift-obj .
          run factord-lock-shift in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  0
            ,buffer lock_shift-obj
            ) no-error .
          if error-status :error  then do:
            next.
          end.

          define variable v-attr-arh-del-chr  as character no-undo .
          define variable v-attr-arh-del-type as character no-undo .
          define variable v-attr-arh-del      as logical   no-undo .

          run clntattr-value in this-procedure
            (input  buf_clients.obj-type
            ,input  buf_clients.obj-code
            ,input  {&attr-arh-del}
            ,output v-attr-arh-del-chr
            ,output v-attr-arh-del-type
            ).
          assign
            v-attr-arh-del = lookup(v-attr-arh-del-chr, 'yes,true':u) > 0
          .

          if  v-attr-arh-del <> true
          and buf_clients.stts = 0
          then do:
            run trg/calcarh.p
              (input buf_clients.obj-type /* p-obj-type       */
              ,input buf_clients.obj-code /* p-obj-code       */
              ,input ?                 /* p-check-doc     Если дата пересчета не задана, то надо будет ее найти */
              ,input false                /* p-message-on     */
              ,input inv-date-end        /* p-last-fact-date */
              ,input true                 /* p-check-act         */
              ,input v-cntxt-db-num       /* p-check-act-db-num  */
              ,input v-cntxt-userid       /* p-check-act-user-id */
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при расчете складского архива по товарам" skip
                "Объект" buf_clients.obj-type buf_clients.obj-code skip
                "Информацию о рассчитанных объектах можно посмотреть в файле"
                "objarh.log" skip
                "или в АРМ Администратор" skip
                "Утилиты/Работа с архивами/Информация о складских архивах" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
      end.
run rep/r-inv-RN.p (input my-handle, input tog-only-itog, input inv-date-start, input inv-date-end, input inv-shift-start, input inv-shift-end) .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/

  Assign frame {&frame-name} inv-date-start inv-date-end tog-only-itog .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object 
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.
  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
    when "link-changed":U then  DO:
         Run my-var.
         End.

  END CASE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

