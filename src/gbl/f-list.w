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

Редактирование фильтров - списки

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input  parameter parparentproc as widget-handle no-undo .
define input  parameter spr          as character no-undo .
define input  parameter type         as character no-undo .
define output parameter sel_list     as character no-undo .
define output parameter sel_list_rus as character no-undo .
define output parameter incl         as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование фильтров - списки".
{ cmp/vssrevis.i "substitute('&1|&2':u,spr,type)" }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-shar.i }
{ ref/grplibfn.i }
{ ref/cgrplbfn.i }
{ nws/db-rec.i   }
{ gbl/cur-time.i }
define variable k as int no-undo.
define variable s as char no-undo.
define variable v_type     as char no-undo.
define variable vlistValue    as character no-undo.
define variable vlistValueRet as character no-undo.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME DIALOG-1

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS in-int in-dec in-date in-char comb b-add ~
b-del b-help list togl Btn_OK Btn_Cancel
&Scoped-Define DISPLAYED-OBJECTS in-int in-dec in-date in-char comb list ~
togl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 8.75 BY 1.17 TOOLTIP "Ввести в список значение".

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 8.75 BY 1.17 TOOLTIP "Удалить ранее включенное в список значение".

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 8.75 BY 1.17 TOOLTIP "Интерактивная помощь в формате *.html".

DEFINE BUTTON b-spr
     IMAGE-UP FILE "btn-left-arrow":U
     IMAGE-DOWN FILE "btn-left-arrow":U
     IMAGE-INSENSITIVE FILE "btn-left-arrow":U
     LABEL "":L
     SIZE 3 BY .88.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 10 BY 1.17 TOOLTIP "Отменить формирование критерия"
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохранить":L
     SIZE 10 BY 1.17 TOOLTIP "Сохранить сформированный критерий"
     BGCOLOR 8 .

DEFINE VARIABLE comb AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS " "
     SIZE 41 BY 1 NO-UNDO.

DEFINE VARIABLE in-char AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-dec AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-int AS INTEGER FORMAT "->>,>>>,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE list AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE
     SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 41.5 BY 5.5 NO-UNDO.

DEFINE VARIABLE togl AS LOGICAL INITIAL no
     LABEL "Включительно":L
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY .83 NO-UNDO.

DEFINE VARIABLE in-log AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Да (Истино)", "TRUE",
"Нет (Ложь)", "FALSE"
     SIZE 14 BY 2.25 NO-UNDO.

DEFINE VARIABLE toggle-date AS LOGICAL INITIAL no
     LABEL "СЕГОДНЯ +/- ДНЕЙ"
     VIEW-AS TOGGLE-BOX
     SIZE 21 BY .83 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DIALOG-1
     in-int AT ROW 1.5 COL 3 NO-LABEL
     in-dec AT ROW 1.5 COL 3 NO-LABEL
     in-date AT ROW 1.5 COL 3 NO-LABEL
     in-log  AT ROW 1.5    COL  4.5 NO-LABEL
     toggle-date  AT ROW 1.5  COL 15
     in-char AT ROW 1.5 COL 3 NO-LABEL
     comb AT ROW 1.5 COL 1 COLON-ALIGNED NO-LABEL
     b-spr AT ROW 1.5 COL 31.5
     b-add AT ROW 2.75 COL 3
     b-del AT ROW 2.75 COL 13
     b-help AT ROW 2.75 COL 25.5
     list AT ROW 4.25 COL 3 NO-LABEL
     togl AT ROW 9.75 COL 3
     Btn_OK AT ROW 10.75 COL 3
     Btn_Cancel AT ROW 10.75 COL 34.75
     SPACE(2.12) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "":L
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX DIALOG-1
                                                                        */
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-spr IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN
       b-spr:HIDDEN IN FRAME DIALOG-1           = TRUE.

/* SETTINGS FOR FILL-IN in-char IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-date IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-dec IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN in-int IN FRAME DIALOG-1
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add DIALOG-1
ON CHOOSE OF b-add IN FRAME DIALOG-1 /* Добавить */
DO:
define variable s-private as character no-undo .
  case type:
     when "character" then do:
        if comb:visible
        then do:
          s = input frame {&frame-name} comb.
          if vlistValueRet ne ?
          then do:
             k = comb:lookup(s).
             s = entry( k, comb:list-items).
             s-private = entry( k, vlistValueRet)          .
           end.
        end.
        else s = input frame {&frame-name} in-char.
        
     end.
     when "date" then
     assign
     s = if (input frame {&frame-name} in-date = "":U or
             input frame {&frame-name} in-date = ? or
             input frame {&frame-name} in-date = "?")
         then {&question-mark}
         else string(input frame {&frame-name} in-date, "99/99/9999").
     when "decimal" then s = string(input frame {&frame-name} in-dec).
     when "integer" then do:
        if    comb:visible in frame {&frame-name}
        then do:
           assign
              s         =  input frame {&frame-name} comb
              s-private =  entry(lookup(s,vlistValue), vlistValueRet) when vlistValueRet ne ?
          .
        end.
        else do:
           assign
              s = string(input frame {&frame-name} in-int)
              
           .
        end.
     end.
     end case.
     k = lookup( s, list:list-items ).
     if k = 0 or k = ? then do:
        if list:add-last( s ) 
        then do:
           assign
              list:private-data = list:private-data + (if list:private-data = "":u then "":U else {&comma-char}) + s-private.
        end.
     end.
  apply "entry" to btn_cancel in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del DIALOG-1
ON CHOOSE OF b-del IN FRAME DIALOG-1 /* Удалить */
DO:
    define variable k as integer no-undo .

  assign list.
  if list:delete( list ) then do:
    if comb:visible then do:
      replace(list:private-data, entry(lookup(comb, comb:list-items), vlistValueRet), "":U) no-error .
      replace(list:private-data, ({&comma-char} + {&comma-char}), {&comma-char}).
    end.
  end.
    def var vValue as character no-undo .
    list:private-data = "" .
    do k = 1 to num-entries(list:list-items):
        vValue = entry(k,list:list-items) .
        list:private-data = list:private-data + {&comma-char} + entry(lookup(vValue,vListValue,","),vListValueRet,",") .
    end.
    list:private-data = trim(list:private-data,",") .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-spr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spr DIALOG-1
ON CHOOSE OF b-spr IN FRAME DIALOG-1
DO:
  define variable grp-rec as recid no-undo.
  define variable ref-rec as recid no-undo.
  define variable grps as char no-undo.
  define variable gdss as char no-undo.
  define variable grp_name as char no-undo.
  define variable ref-list as char no-undo.
  define variable out-an as int no-undo.
  define buffer buf_db for ub.db.
  define variable  rid-list as character no-undo .
  case spr:
         when 'pay' then do:
            run ref/paytype.w ( input parparentproc, "b-sel", output  rid-list ).
            find ub.pay-type where recid ( ub.pay-type ) = integer( rid-list) no-lock no-error.
            if available ub.pay-type then do:
               in-int = ub.pay-type.obj-code.
               disp in-int with frame {&frame-name}.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'curr' then do:
            assign
            ref-rec = ?.
            run ref/currency.w (parparentproc, "b-sel", input-output ref-rec ).
            if ref-rec = ? then return no-apply.
            find ub.currency where recid ( ub.currency ) = ref-rec no-lock.
            if available ub.currency then do:
               in-int = ub.currency.curr-code.
               disp in-int with frame {&frame-name}.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'unit' then do:
            run ref/units.w (
                          input parparentproc
                        , input yes
                        , output ref-rec).
            if ref-rec = ? then return no-apply.
            find ub.units where recid ( ub.units ) = ref-rec no-lock.
            if available ub.units then do:
               in-char = ub.units.unit-name.
               disp in-char with frame {&frame-name}.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'country' then do:
            run ref/countris.w (input parparentproc
                           ,input "b-sel"
                           ,input-output rid-list).
            if ref-rec = ? then return no-apply.
            find ub.country where recid ( ub.country ) = integer(rid-list) no-lock.
            if available ub.country then do:
               in-char = ub.country.alpha1.
               disp in-char with frame {&frame-name}.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'prt' then do:
            run ref/gdsprts.w ( parparentproc, yes, output ref-rec).
            find  ub.gds-prt where recid ( ub.gds-prt ) = ref-rec no-lock.
            if available ub.gds-prt then do:
               in-int = ub.gds-prt.upper-code.
               disp in-int with frame {&frame-name}.
               apply "choose" to b-add.
               return no-apply.
            end.
         end.
         when 'cligrp' then do:
                  ref-list = "".
                  run ref/cli-grps.w (input parparentproc, "b-sel", input-output ref-list).
                  grp-rec = int(ref-list).
                  if grp-rec <> 0 then do:
                     find ub.cli-grp where recid(ub.cli-grp) = grp-rec.
                     run cli-grplib-get-full-name in this-procedure(input ub.cli-grp.node-code, output grp_name).
                     in-char = grp_name.
                     disp in-char with frame {&frame-name}.
                     apply "choose" to b-add.
                     return no-apply.
                  end.
         end.
         when 'gdsgrp' then do:
          ref-list = "".
          run ref/gds-grp.w ( input parparentproc
                             ,input "b-sel"
                             ,input '':U
                             ,input 0
                             ,input-output ref-list).
          grp-rec = int(ref-list).
          if grp-rec <> 0 then do:
              find ub.gds-grp where recid(ub.gds-grp) = grp-rec.
              run grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output grp_name).
              in-char = grp_name.
              disp in-char with frame {&frame-name}.
              apply "choose" to b-add.
              return no-apply.
          end.
          else apply "entry" to b-spr.

         end.
         when 'db' then do:
          run adm/dbs.w (
                        input parparentproc
                       ,input {&lookup}
                       ,output ref-rec).
          if ref-rec <> ? then do:
            find first buf_db no-lock where recid(buf_db) = ref-rec no-error.
            if available buf_db then do:
              assign
              in-int = buf_db.db-num
              .
              disp in-int with frame {&frame-name}.
              apply "choose" to b-add in frame {&frame-name}.
              return no-apply.
            end.
            else apply "entry":U to b-spr in frame {&frame-name}.
          end.
         end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME comb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL comb DIALOG-1
ON VALUE-CHANGED OF comb IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME in-char
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL in-char DIALOG-1
ON RETURN OF in-char IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME in-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL in-date DIALOG-1
ON RETURN OF in-date IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME in-dec
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL in-dec DIALOG-1
ON RETURN OF in-dec IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME in-int
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL in-int DIALOG-1
ON RETURN OF in-int IN FRAME DIALOG-1
DO:
apply "choose" to b-add in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME list
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL list DIALOG-1
ON VALUE-CHANGED OF list IN FRAME DIALOG-1
DO:
  assign list.
  case type:
     when "character" then do:
        if comb:visible
        then do:
           comb = list.
           disp comb with frame {&frame-name}.
        end.
        else do:
           in-char = list.
           disp in-char with frame {&frame-name}.
        end.
     end.
     when "date" then do:
        in-date = date(list).
        disp in-date with frame {&frame-name}.
     end.
     when "decimal" then do:
        in-dec = decimal(list).
        disp in-dec with frame {&frame-name}.
     end.
     when "integer" then do:
        if comb:visible
        then do:
           comb = list.
           disp comb with frame {&frame-name}.
        end.
        else do:
           in-int = integer( list ).
           disp in-int with frame {&frame-name}.
        end.
     end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK DIALOG-1


{ gbl/hot-key.i {&Btn_Help} }

/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR                      */
ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i }

{ gbl/ed_date.i in-date }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR    UNDO MAIN-BLOCK, return error
      ON STOP       UNDO MAIN-BLOCK, return error
      ON END-KEY UNDO MAIN-BLOCK, return error :
  if can-do( "cligrp,gdsgrp,pay,curr,unit,prt,country,db", spr ) then
     assign
       b-spr:sensitive = yes
       b-spr:visible     = yes
       togl                   = yes.
  RUN UI_on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  assign list.
  if list:num-items = 0 then return error.
  assign incl = input frame {&frame-name} togl.
  assign
  sel_list_rus = list:list-items
  sel_list     = (if vlistValueRet ne ? then list:private-data else list:list-items)
  .

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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI DIALOG-1 _DEFAULT-ENABLE
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
  DISPLAY in-int in-dec in-date in-char comb list togl
      WITH FRAME DIALOG-1.
  ENABLE in-int in-dec in-date in-char comb b-add b-del list togl Btn_OK
         Btn_Cancel b-help
      WITH FRAME DIALOG-1.
  {&OPEN-BROWSERS-IN-QUERY-DIALOG-1}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE UI_on DIALOG-1
PROCEDURE UI_on :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
assign
list:private-data in frame {&frame-name} = "".

  disp togl with frame {&frame-name}.
  enable b-add b-del list togl Btn_OK Btn_Cancel b-help with frame {&frame-name}.
run InitForm.
toggle-date:visible = false.
END PROCEDURE.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
{ gbl\f-const.i }