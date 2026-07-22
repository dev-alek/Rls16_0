&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME get-rep
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS get-rep
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Задание дат для XYZ анализа

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 06/17/05
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define temp-table temp-date no-undo
field date1 as date
field date2 as date
index pi date1
.
define input-output PARAMETER table for temp-date .

define variable is-ok as logical initial false no-undo.
define variable p-from-date as date no-undo .
define variable p-to-date as date no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Задание диапазона дат: начало - конец".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
/* { s t d -func.i } */
FUNCTION LastDay-MY  RETURNS INTEGER ( INPUT i-month AS INTEGER, INPUT i-year AS INTEGER ) :
  DEFINE VARIABLE j_day AS INTEGER NO-UNDO.

  run get-last-day-my in this-procedure ( input i-month, input i-year, output j_day ) no-error.
  RETURN ( IF ERROR-STATUS :ERROR THEN ? ELSE j_day ).
END FUNCTION. /* LastDay-MY */

&SCOP MinMaxDay 28
&SCOP MinDelta   4

PROCEDURE get-last-day-MY :
  DEFINE  INPUT PARAMETER p-month AS INTEGER NO-UNDO.
  DEFINE  INPUT PARAMETER p-year  AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-day   AS INTEGER NO-UNDO.

  DEFINE VARIABLE t_date AS DATE NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN t_date = DATE( p-month, {&MinMaxDay}, p-year ).
    ASSIGN p-day  = DAY( t_date - DAY( t_date + {&MinDelta} ) + {&MinDelta} ).
  END. /* ON ERROR */
END PROCEDURE. /* get-last-day-MY */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME get-rep
&Scoped-define BROWSE-NAME BROWSE-date

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES temp-date

/* Definitions for BROWSE BROWSE-date                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-date temp-date.date1 temp-date.date2
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-date
&Scoped-define SELF-NAME BROWSE-date
&Scoped-define QUERY-STRING-BROWSE-date FOR EACH temp-date
&Scoped-define OPEN-QUERY-BROWSE-date OPEN QUERY {&SELF-NAME} FOR EACH temp-date.
&Scoped-define TABLES-IN-QUERY-BROWSE-date temp-date
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-date temp-date


/* Definitions for DIALOG-BOX get-rep                                   */
&Scoped-define OPEN-BROWSERS-IN-QUERY-get-rep ~
    ~{&OPEN-QUERY-BROWSE-date}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-ok b-quit b-help BROWSE-date date-b date-e ~
RADIO-TYPE B-more b-del
&Scoped-Define DISPLAYED-OBJECTS date-b date-e RADIO-TYPE

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-del
     LABEL "Удал"
     SIZE 7 BY 1 TOOLTIP "Удалить интервал произвольно".

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-more
     LABEL "Еще"
     SIZE 7 BY 1 TOOLTIP "Добавить интервал произвольно".

DEFINE BUTTON b-ok AUTO-GO DEFAULT
     LABEL "&Ввод "
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 12 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE date-b AS DATE FORMAT "99/99/9999":U
     LABEL "С"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE date-e AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-TYPE AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "<--->", 0,
"Годам", 1,
"Месяцам", 2,
"Неделям", 3,
"Размер интервала в днях", 5,
"Количество интервалов", 6,
"Произвольно", 7,
"Очистить", 8
     SIZE 26 BY 9.25 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-date FOR
      temp-date SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-date get-rep _FREEFORM
  QUERY BROWSE-date DISPLAY
      temp-date.date1 FORMAT "99/99/9999"  column-label "c"
      temp-date.date2 FORMAT "99/99/9999"  column-label "по"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 28.63 BY 13.46 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME get-rep
     b-ok AT ROW 1 COL 1
     b-quit AT ROW 1 COL 13
     b-help AT ROW 1 COL 25
     BROWSE-date AT ROW 2 COL 71.51 RIGHT-ALIGNED
     date-b AT ROW 2.5 COL 4.5 COLON-ALIGNED
     date-e AT ROW 2.5 COL 22 COLON-ALIGNED
     RADIO-TYPE AT ROW 5 COL 3 NO-LABEL
     B-more AT ROW 12.25 COL 28
     b-del AT ROW 13.25 COL 28
     "Разбить по:" VIEW-AS TEXT
          SIZE 31 BY .67 AT ROW 4.25 COL 4.5
          FGCOLOR 4
     SPACE(37.12) SKIP(10.61)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Задайте период"
         CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX get-rep
                                                                        */
/* BROWSE-TAB BROWSE-date b-help get-rep */
ASSIGN
       FRAME get-rep:SCROLLABLE       = FALSE.

/* SETTINGS FOR BROWSE BROWSE-date IN FRAME get-rep
   ALIGN-R                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-date
/* Query rebuild information for BROWSE BROWSE-date
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-date.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-date */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX get-rep
/* Query rebuild information for DIALOG-BOX get-rep
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX get-rep */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del get-rep
ON CHOOSE OF b-del IN FRAME get-rep /* Удал */
DO:
  IF AVAILABLE temp-date THEN DELETE  temp-date.

{&OPEN-QUERY-{&BROWSE-NAME}}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-more
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-more get-rep
ON CHOOSE OF B-more IN FRAME get-rep /* Еще */
DO:
        define variable date-1  as date   no-undo .
        define variable date-2  as date   no-undo .
        define variable v-ok as logical   no-undo .

          run gbl/get-per.w (
                output        v-ok ,
                input-output  date-1  ,
                input-output  date-2  ) .
            if v-ok then do:
                  create temp-date.
                  assign
                    temp-date.date1 = date-1
                    temp-date.date2 = date-2
                  .
              end.

{&OPEN-QUERY-{&BROWSE-NAME}}

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok get-rep
ON CHOOSE OF b-ok IN FRAME get-rep /* Ввод  */
DO:
define variable v-calk as integer   no-undo  init 0.
for each  temp-date :
v-calk = v-calk + 1 .
end.
if v-calk = 0 then message "Вы не задали ни одного интервала!!!" view-as alert-box information .

  /* проверка на пересечение интервалов */
  define buffer b_date for temp-date .
  for each temp-date :
    find first b_date where
                  ( b_date.date1 >= temp-date.date1 and
                    b_date.date1 <= temp-date.date2  ) or
                  ( b_date.date2 >= temp-date.date1 and
                    b_date.date2 <= temp-date.date2  )
                 no-error .
     if available b_date and
         not  (   b_date.date1 = temp-date.date1  and
                  b_date.date2 = temp-date.date2  )  then do:
          message "Интервалы пересекаются ! "        skip
                    temp-date.date1   temp-date.date2 skip
                    b_date.date1      b_date.date2    skip
                    view-as alert-box error .
          return no-apply.
     end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit get-rep
ON CHOOSE OF b-quit IN FRAME get-rep /* Отмена */
DO:
  for EACH temp-date: DELETE temp-date. END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-b
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-b get-rep
ON RETURN OF date-b IN FRAME get-rep /* С */
DO:
    APPLY "ENTRY" TO date-e IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date-e
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date-e get-rep
ON RETURN OF date-e IN FRAME get-rep /* По */
DO:
    APPLY "CHOOSE" TO b-ok IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-TYPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-TYPE get-rep
ON VALUE-CHANGED OF RADIO-TYPE IN FRAME get-rep
DO:
  ASSIGN date-b date-e RADIO-TYPE no-error .
  if error-status :error then RADIO-TYPE = 0 .



  if date-b >= date-e then do:
    message "Не верно задана дата !" view-as alert-box error .
    return no-apply .
  end.
  if date-e - date-b <= 4 then do:
    message "Очень маленький период !" view-as alert-box error .
    return no-apply .
  end.

define variable ii as integer   no-undo .
define variable mm as integer   no-undo .
define variable dd as integer   no-undo .
define variable v-last-day as integer   no-undo .
define variable yy1  as integer   no-undo .
define variable yy2  as integer   no-undo .
define variable v-dd as date      no-undo .

    CASE RADIO-TYPE :
     when 8
     then do:
        for EACH temp-date: DELETE temp-date. END.
     end.
     when 1
     then do:
        if year(date-b) <  year(date-e) then do:
           repeat ii = year(date-b) to year(date-e) :
             create temp-date.
             assign
               temp-date.date1 = date(1 ,1 ,ii)
               temp-date.date2 = date(12,31,ii)
             .
           end.
        end.
     end.

     when 2
     then do:
     yy1 = year(date-b) .
     yy2 = year(date-e).
        if yy1 =  yy2 then do:
           repeat ii = yy1 to yy2 :
              repeat mm = month(date-b) to month(date-e) :
                v-last-day = lastday-my ( mm , ii ) .
                create temp-date.
                assign
                  temp-date.date1 = date(mm,1,ii)
                  temp-date.date2 = date(mm, v-last-day ,ii)
                .
              end.
           end.
        end.

       if yy1 < yy2 then do:
              repeat mm = month(date-b) to 12 :
                v-last-day = lastday-my ( mm , yy1 ) .
                create temp-date.
                assign
                  temp-date.date1 = date(mm,1,yy1)
                  temp-date.date2 = date(mm, v-last-day ,yy1)
                .
              end.

              repeat mm = 1 to  month(date-e) :
                v-last-day = lastday-my ( mm , yy2 ) .
                create temp-date.
                assign
                  temp-date.date1 = date(mm,1,yy2)
                  temp-date.date2 = date(mm, v-last-day ,yy2)
                .
              end.

              if yy2 - yy1 > 1 then do:
                  yy1 = year(date-b) + 1 .
                  yy2 = year(date-e) - 1.
                        repeat ii = yy1 to yy2 :
                            repeat mm = 1 to 12 :
                              v-last-day = lastday-my ( mm , ii ) .
                              create temp-date.
                              assign
                                temp-date.date1 = date(mm,1,ii)
                                temp-date.date2 = date(mm, v-last-day ,ii)
                              .
                            end.
                      end.
              end.
       end.
     end.
     when 3
     then do:
            /* выставить на начало недели и конец*/
     define variable v-w as integer   no-undo .
     v-w = int(date-b) modulo 7 .
     if v-w <> 1 then do:
        if v-w = 0 then date-b = date-b + 1 .
        else date-b = date-b - v-w + 1 .

     end.

            repeat v-dd = date-b to date-e  by 7 :
                        create temp-date.
                        assign
                          temp-date.date1 = v-dd
                          temp-date.date2 = v-dd + 6
                        .
               if temp-date.date2 + 6 > date-e then leave.

            end.
     end.


     when 4
     then do:
            repeat v-dd = date-b to date-e  by 1 :
                        create temp-date.
                        assign
                          temp-date.date1 = v-dd
                          temp-date.date2 = v-dd
                        .

            end.
     end.

     when 5
     then do:
        define variable v-kol-days-c as character no-undo .
        run gbl/d-prompt.w (
            'title=':u + "Введите количество дней" + '\':u
          + 'text1=':u + "Введите количество дней" + '\':u
          + 'type=int\':u
          + 'fillin_row=2\':u
          + 'fillin_col=4\':u
          + 'fillin_width=5\':u
          + 'fillin_height=1\':u
          + 'max-chars=5\':u
          + 'readonly=no\':u
          , input-output v-kol-days-c
          ).
          if int (v-kol-days-c) = 0 then do:
              return no-apply .
          end.


         define variable vv-d as integer   no-undo .
         define variable vv-ds as integer   no-undo .
         vv-ds = int(v-kol-days-c).
             repeat v-dd = date-b to date-e  by  1  :
                  create temp-date.
                  assign
                    temp-date.date1 = v-dd
                    temp-date.date2 = v-dd + vv-ds - 1
                    v-dd = temp-date.date2
                  .
                  if temp-date.date2 + vv-ds > date-e then leave.
             end.

     end.
     when 6
     then do:
        define variable v-kol-int-c as character no-undo .
        run gbl/d-prompt.w (
            'title=':u + "Введите количество интервалов" + '\':u
          + 'text1=':u + "Введите количество интервалов" + '\':u
          + 'type=int\':u
          + 'fillin_row=2\':u
          + 'fillin_col=4\':u
          + 'fillin_width=5\':u
          + 'fillin_height=1\':u
          + 'max-chars=5\':u
          + 'readonly=no\':u
          , input-output v-kol-int-c
          ).

          if int (v-kol-int-c) < 3 then do:
              message "Интервалов должно быть не менее 3 !" view-as alert-box error .
              return no-apply .
          end.

          define variable v-vdv as integer   no-undo .
          define variable v-vdvs as integer   no-undo .
          v-vdvs = int( (date-e - date-b) / int (v-kol-int-c)).

            repeat v-dd = date-b to date-e  by  1 :
                        create temp-date.
                        assign
                          temp-date.date1 = v-dd
                          temp-date.date2 = v-dd +  v-vdvs - 1
                          v-dd = temp-date.date2
                        .
                        if v-dd + v-vdvs > date-e then leave.
            end.
     end.
     when 7
     then do:
        define variable date-1  as date   no-undo .
        define variable date-2  as date   no-undo .
        define variable v-ok as logical   no-undo .

          run gbl/get-per.w (
                output        v-ok ,
                input-output  date-1  ,
                input-output  date-2  ) .
            if v-ok then do:
                  create temp-date.
                  assign
                    temp-date.date1 = date-1
                    temp-date.date2 = date-2
                  .
              end.

     end.

    END CASE.

{&OPEN-QUERY-{&BROWSE-NAME}}
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-date
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK get-rep


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/ed_date.i date-b }
{ gbl/ed_date.i date-e }
{ gbl/app_help.i }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   define variable v-time  as integer   no-undo.
  if p-from-date = ? OR p-to-date = ?
  then do:
      run cur-time in this-procedure ( output p-to-date
                                     , output v-time
                                     ).
      assign
          p-from-date = date( month( p-to-date ), 01, year( p-to-date ))
      .
  end.
  assign
      date-b = p-from-date
      date-e = p-to-date
      RADIO-TYPE = 0
      .

  APPLY "VALUE-CHANGED" TO RADIO-TYPE IN FRAME {&frame-name} .
  run enable_ui.
  apply "entry" to date-b in frame {&frame-name}.
  wait-for go of frame {&frame-name}.
end.
run disable_ui.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI get-rep  _DEFAULT-DISABLE
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
  HIDE FRAME get-rep.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI get-rep  _DEFAULT-ENABLE
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
  DISPLAY date-b date-e RADIO-TYPE
      WITH FRAME get-rep.
  ENABLE b-ok b-quit b-help BROWSE-date date-b date-e RADIO-TYPE B-more b-del
      WITH FRAME get-rep.
  {&OPEN-BROWSERS-IN-QUERY-get-rep}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME