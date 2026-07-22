&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-shift
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник смен

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/22/07
Author: Dmitry Ukhanov
Creation date: 08/22/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 09/19/05
Author1: Alexey Suslov
Creation date1: 09/19/05

input-output:
    s-date   as date        - дата смены
    e-date   as date        - дата конца смены
    s-time   as integer     - время смены
    e-time   as integer     - время конца смены
    s-num    as integer     - порядок смены
    s-name   as character   - номер смены
input:
    p-option as character   - параметры для формы. Значения:
                                'time-only' - допускается изменение времени. Остальные поля enabled = no
                                'edit-time' - допускается редактирование времени открытия и закрытия. Остальные поля заблокированы
*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input-output parameter s-date    as date         no-undo.
define input-output parameter e-date    as date         no-undo.
define input-output parameter s-time    as integer      no-undo.
define input-output parameter e-time    as integer      no-undo.
define input-output parameter s-num     as integer      no-undo.
define input-output parameter s-name    as character    no-undo.
define input parameter  p-option        as character    no-undo.
define output parameter p-cancel        as logical      no-undo.

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Справоник смен".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/cmptime.i  }
{ cmp/showinf.i }
/* Local Variable Definitions ---                                       */
define variable v-today         as date             no-undo.
define variable v-time          as integer          no-undo.
define variable v-exit-enabled  as logical init no  no-undo.
DEFINE BUFFER bf_shift-obj FOR ub.shift-obj.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-shift

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-Help fi-start-hour ~
fi-start-min f-date l-loc-hour l-loc-min fi-colon-2 fi-colon 
&Scoped-Define DISPLAYED-OBJECTS fi-start-date fi-start-hour fi-start-min ~
f-date l-loc-hour l-loc-min rs-num rs-name fi-colon-2 fi-colon 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&Scoped-define List-1 fi-start-hour fi-start-min l-loc-hour l-loc-min 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Ввод "
     SIZE 12 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-Help
     LABEL "Помо&щь"
     SIZE 12 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-quit
     LABEL "&Отмена"
     SIZE 12 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE f-date AS DATE FORMAT "99/99/99":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-colon AS CHARACTER FORMAT "X(1)":U INITIAL ":"
      VIEW-AS TEXT
     SIZE 1.6 BY 1.05 NO-UNDO.

DEFINE VARIABLE fi-colon-2 AS CHARACTER FORMAT "X(1)":U INITIAL ":" 
      VIEW-AS TEXT 
     SIZE 1.6 BY 1.05 NO-UNDO.

DEFINE VARIABLE fi-start-date AS DATE FORMAT "99/99/99":U 
     LABEL "Начало смены"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-start-hour AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE fi-start-min AS INTEGER FORMAT "99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.

DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.

DEFINE VARIABLE rs-name AS CHARACTER FORMAT "X(2)":U INITIAL "0"
     LABEL "Номер смены"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.

DEFINE VARIABLE rs-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок смены"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-shift
     b-exit AT ROW 1.29 COL 2.2
     b-quit AT ROW 1.29 COL 14.6
     b-Help AT ROW 1.29 COL 27.8
     fi-start-date AT ROW 3.19 COL 16 COLON-ALIGNED
     fi-start-hour AT ROW 3.19 COL 29 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     fi-start-min AT ROW 3.19 COL 34 COLON-ALIGNED NO-LABEL WIDGET-ID 6
     f-date AT ROW 5.19 COL 16 COLON-ALIGNED
     l-loc-hour AT ROW 5.19 COL 29 COLON-ALIGNED NO-LABEL
     l-loc-min AT ROW 5.19 COL 34 COLON-ALIGNED NO-LABEL
     rs-num AT ROW 7 COL 16.4 COLON-ALIGNED
     rs-name AT ROW 9 COL 16.4 COLON-ALIGNED
     fi-colon-2 AT ROW 3.19 COL 32.2 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     fi-colon AT ROW 5.19 COL 32.2 COLON-ALIGNED NO-LABEL
     SPACE(4.00) SKIP(4.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Номер и дата смены".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-shift
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-shift:SCROLLABLE       = FALSE
       FRAME d-shift:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN fi-start-date IN FRAME d-shift
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fi-start-hour IN FRAME d-shift
   1                                                                    */
/* SETTINGS FOR FILL-IN fi-start-min IN FRAME d-shift
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-hour IN FRAME d-shift
   1                                                                    */
/* SETTINGS FOR FILL-IN l-loc-min IN FRAME d-shift
   1                                                                    */
/* SETTINGS FOR FILL-IN rs-name IN FRAME d-shift
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN rs-num IN FRAME d-shift
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-shift d-shift
ON WINDOW-CLOSE OF FRAME d-shift /* Номер и дата смены */
DO:
    if v-exit-enabled = no
    then do:
        undo, return no-apply.
    end.
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-shift
ON CHOOSE OF b-exit IN FRAME d-shift /* Ввод  */
DO:

  define variable cur-day           as date      no-undo .
  define variable cur-time          as integer   no-undo .

  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
  define variable v-param-type      as character  no-undo .
  define variable v-difftime        as integer   no-undo initial 0.
  define variable v-diffdate        as integer   no-undo initial 0.

  run cur-time in this-procedure
    ( output cur-day
    , output cur-time
    ).

  assign
    s-date = input frame {&frame-name} f-date
    s-num  = input frame {&frame-name} rs-num
    s-name = left-trim(input frame {&frame-name} rs-name, "0")
  .
  run cmptime-hms-to-integer in this-procedure
    ( input l-loc-hour
    , input l-loc-min
    , input 0
    , output s-time
    ).
    
  run cmptime-hms-to-integer(
    input fi-start-hour,
    input fi-start-min,
    input 0,
    output e-time
  ).

  if s-date >= cur-day
    and p-option = 'time-only':U
  then do:
    run adm/shattri.p
      ( input  "get":U
      , input  p-curr-obj-type
      , input  p-curr-obj-code
      , input  {&attr-obj-date}
      , input  {&attr-obj-date_difftime}
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , input-output table-handle v-tth
      ) no-error .
    if not error-status :error
      and v-value-integer <> ?
    then do:
      assign
        v-difftime = v-value-integer
        no-error.
      if error-status :error
        or v-difftime < 0
      then do:
        delete object v-tth no-error.
        message
          "Неверно задан параметр difftime: " v-difftime skip
          "Параметр может принимать целые значения > 0." skip
          view-as alert-box error.
        return no-apply .
      end.
      else do:
        assign
          v-diffdate = truncate( v-difftime / 86400, 0 )
        .

        if s-date > cur-day + v-diffdate
          or ( s-date = cur-day + v-diffdate
               and s-time > cur-time + v-difftime * 60
             )
        then do:
          delete object v-tth no-error.
          message
            substitute( "Максимально возможное время закрытия смены: &1 &2"
                       , string( cur-day + v-diffdate, "99/99/9999":U )
                       , string( cur-time + v-difftime * 60, "HH:MM":U )
                      ) skip
            substitute( "Объект: &1 &2", p-curr-obj-type, p-curr-obj-code ) skip
            view-as alert-box error .
          return no-apply .
        end.
      end.
    end.
    delete object v-tth no-error.
  end.

  assign
    v-exit-enabled = yes
    p-cancel       = no
  .
  apply "window-close" to frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-shift
ON CHOOSE OF b-quit IN FRAME d-shift /* Отмена */
DO:
    assign
        v-exit-enabled  = yes
        p-cancel        = yes
    .
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-date d-shift
ON LEAVE OF f-date IN FRAME d-shift
DO:
  if f-date <> input frame {&frame-name} f-date then do:
    find last bf_shift-obj where bf_shift-obj.obj-type   = p-curr-obj-type and
                                 bf_shift-obj.obj-code   = p-curr-obj-code and
                                 bf_shift-obj.shift-date = INPUT FRAME {&frame-name} f-date          use-index pi no-lock no-error.
    if not available bf_shift-obj then do:
      assign
        rs-num = 1.
    end.
    else do:
      assign
        rs-num = bf_shift-obj.shift-num + 1.
    end.
    assign
      rs-name = string (rs-num).
    display rs-num rs-name with frame {&frame-name}.
    assign frame {&frame-name}
      f-date.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-start-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-start-hour d-shift
ON CURSOR-DOWN OF fi-start-hour IN FRAME d-shift
DO:
  assign  frame {&frame-name} fi-start-hour .
  fi-start-hour = fi-start-hour -  1.
  if fi-start-hour < 0 then return no-apply.
  display fi-start-hour with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-start-hour d-shift
ON CURSOR-UP OF fi-start-hour IN FRAME d-shift
DO:
  assign  frame {&frame-name} fi-start-hour .
  fi-start-hour = fi-start-hour +  1.
  if fi-start-hour > 23 then return no-apply.
  display fi-start-hour with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-start-hour d-shift
ON LEAVE OF fi-start-hour IN FRAME d-shift
DO:
  assign frame {&frame-name} fi-start-hour .
   if fi-start-hour > 23 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if fi-start-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fi-start-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-start-min d-shift
ON CURSOR-DOWN OF fi-start-min IN FRAME d-shift
DO:
  assign  frame {&frame-name} fi-start-min .
  fi-start-min = fi-start-min -  1.
  if fi-start-min < 0 then return no-apply.
  display fi-start-min with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-start-min d-shift
ON CURSOR-UP OF fi-start-min IN FRAME d-shift
DO:
   assign  frame {&frame-name} fi-start-min .
  fi-start-min = fi-start-min +  1.
  if fi-start-min > 59 then return no-apply.
  display fi-start-min with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fi-start-min d-shift
ON LEAVE OF fi-start-min IN FRAME d-shift
DO:
    assign frame {&frame-name} fi-start-min .
   if fi-start-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-hour
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour d-shift
ON CURSOR-DOWN OF l-loc-hour IN FRAME d-shift
DO:
  assign  frame {&frame-name} l-loc-hour .
  l-loc-hour = l-loc-hour -  1.
  if l-loc-hour < 0 then return no-apply.
  display l-loc-hour with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour d-shift
ON CURSOR-UP OF l-loc-hour IN FRAME d-shift
DO:
  assign  frame {&frame-name} l-loc-hour .
  l-loc-hour = l-loc-hour +  1.
  if l-loc-hour > 23 then return no-apply.
  display l-loc-hour with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-hour d-shift
ON LEAVE OF l-loc-hour IN FRAME d-shift
DO:
  assign frame {&frame-name} l-loc-hour .
   if l-loc-hour > 23 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.

   end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-loc-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min d-shift
ON CURSOR-DOWN OF l-loc-min IN FRAME d-shift
DO:
  assign  frame {&frame-name} l-loc-min .
  l-loc-min = l-loc-min -  1.
  if l-loc-min < 0 then return no-apply.
  display l-loc-min with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min d-shift
ON CURSOR-UP OF l-loc-min IN FRAME d-shift
DO:
   assign  frame {&frame-name} l-loc-min .
  l-loc-min = l-loc-min +  1.
  if l-loc-min > 59 then return no-apply.
  display l-loc-min with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-loc-min d-shift
ON LEAVE OF l-loc-min IN FRAME d-shift
DO:
    assign frame {&frame-name} l-loc-min .
   if l-loc-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-shift


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    if s-date = ? or s-time = ? or s-num = 0 then do:
        { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code f-date }
        assign
            fi-start-date   = date("")
            f-date :label   = "Дата"
            rs-num = 1
            l-loc-hour      = integer (entry(1,string(v-time,"hh:mm"),":"))
            l-loc-min       = integer (entry(2,string(v-time,"hh:mm"),":"))
        .
        find last bf_shift-obj where bf_shift-obj.obj-type   = p-curr-obj-type and
                                     bf_shift-obj.obj-code   = p-curr-obj-code and
                                     bf_shift-obj.shift-date = f-date          use-index pi no-lock no-error.
        if not available bf_shift-obj then do:
          assign
            rs-num = 1.
        end.
        else do:
          assign
            rs-num = bf_shift-obj.shift-num + 1.
        end.
        assign
          rs-name = string (rs-num).
    end.
    else do:
        assign
            rs-num  = s-num
            rs-name = s-name.
        case p-option :
          when 'edit-time':U then do:
            assign
                fi-start-date :label    = "Начало смены"
                fi-start-date           = s-date
                fi-start-hour           = integer (entry(1,string(s-time,"hh:mm"),":"))
                fi-start-min            = integer (entry(2,string(s-time,"hh:mm"),":"))
                f-date :label           = "Конец смены"
                f-date                  = e-date
                l-loc-hour              = integer (entry(1,string(e-time,"hh:mm"),":"))
                l-loc-min               = integer (entry(2,string(e-time,"hh:mm"),":"))
            .
          end.
          when 'time-only':U then do:
            { gbl/curobjdt.i p-curr-obj-type p-curr-obj-code f-date }
            assign
              fi-start-date :label    = "Начало смены"
                fi-start-date           = s-date
              f-date :label           = "Конец смены"
              l-loc-hour              = integer (entry(1,string(v-time,"hh:mm"),":"))
              l-loc-min               = integer (entry(2,string(v-time,"hh:mm"),":"))
            .
          end.
          when 'open-planned':U then do:
            assign
                fi-start-date   = date("")
              f-date :label   = "Дата"
              f-date          = s-date
              f-date :sensitive = no
              l-loc-hour      = integer (entry(1,string(s-time,"hh:mm"),":"))
              l-loc-min       = integer (entry(2,string(s-time,"hh:mm"),":"))
            .
          end.
          otherwise do:
            assign
                fi-start-date   = date("")
              f-date :label   = "Дата"
              f-date          = s-date
              l-loc-hour      = integer (entry(1,string(s-time,"hh:mm"),":"))
              l-loc-min       = integer (entry(2,string(s-time,"hh:mm"),":"))
            .
          end.
        end case.
    end.
    RUN enable_UI.

    if p-option = 'no-time'
    then do:
        assign
            l-loc-hour :visible = no
            l-loc-min  :visible = no
            fi-colon   :visible = no
        .
    end.
    if p-option = 'time-only'
    then do:
        assign
            f-date :sensitive = no
            rs-name :sensitive = no
        .
    end.
    if s-date <> ? then do:
      disable f-date with FRAME {&FRAME-NAME}.
    end.
    if s-num <> ? then do:
      disable rs-num with FRAME {&FRAME-NAME}.
    end.
    IF p-option <> "open-planned" THEN DO:
      ENABLE rs-name WITH FRAME {&FRAME-NAME}.
    END.
    if p-option = 'edit-time'
    then do:
        disable rs-name with FRAME {&FRAME-NAME}.
    end.
    else do:
        assign
            fi-colon-2    :visible = no
            fi-start-hour :visible = no
            fi-start-min  :visible = no
        .
    end.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-shift  _DEFAULT-DISABLE
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
  HIDE FRAME d-shift.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-shift  _DEFAULT-ENABLE
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
  DISPLAY fi-start-date fi-start-hour fi-start-min f-date l-loc-hour l-loc-min 
          rs-num rs-name fi-colon-2 fi-colon 
      WITH FRAME d-shift.
  ENABLE b-exit b-quit b-Help fi-start-hour fi-start-min f-date l-loc-hour 
         l-loc-min fi-colon-2 fi-colon 
      WITH FRAME d-shift.
  VIEW FRAME d-shift.
  {&OPEN-BROWSERS-IN-QUERY-d-shift}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

