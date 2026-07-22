&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v7r11 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME    DIALOG-1
&Scoped-define FRAME-NAME     DIALOG-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS DIALOG-1
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заведение константных выражений для фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 06/10/95
Author: Pavel Khnykin
Creation date: 06/10/95

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define input parameter parparentproc as widget-handle no-undo .
define input  parameter spr     as character no-undo .
define input  parameter type    as character no-undo .
define output parameter str     as character no-undo .
define output parameter str_rus as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Заведение константных выражений для фильтра".
{ cmp/vssrevis.i "substitute('&1|&2':u,spr,type)"}
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/flt-shar.i }
{ gbl/cur-time.i }
{ ref/grplibfn.i }
{ ref/cgrplbfn.i }
{ nws/db-rec.i   }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

define variable v_type     as char no-undo.
DEFINE VARIABLE kk as integer no-undo .
define variable vlistValue    as character no-undo.
define variable vlistValueRet as character no-undo.


/* ********************  Preprocessor Definitions  ******************** */

/* Name of first Frame and/or Browse (alphabetically)                   */
&Scoped-define FRAME-NAME  DIALOG-1

/* Custom List Definitions                                              */
&Scoped-define LIST-1
&Scoped-define LIST-2
&Scoped-define LIST-3

/* Definitions for DIALOG-BOX DIALOG-1                                  */
&Scoped-define FIELDS-IN-QUERY-DIALOG-1
&Scoped-define ENABLED-FIELDS-IN-QUERY-DIALOG-1

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-spr
     IMAGE-UP FILE "btn-left-arrow"
     IMAGE-DOWN FILE "btn-left-arrow"
     IMAGE-INSENSITIVE FILE "btn-left-arrow"
     LABEL "":L
     SIZE 3 BY .88.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY DEFAULT
     LABEL "&Отмена":L
     SIZE 7 BY 1.17
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO DEFAULT
     LABEL "&Сохр.":L
     SIZE 7 BY 1.17
     BGCOLOR 8 .

DEFINE BUTTON {&Btn_Help} DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1.17
     BGCOLOR 8 .

DEFINE VARIABLE comb AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "Item 1"
     SIZE 41 BY 1.08 NO-UNDO.

DEFINE VARIABLE in-char AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-date AS DATE FORMAT "99/99/9999":U INITIAL ?
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE in-dec AS DECIMAL FORMAT "->>,>>>,>>>,>>9.99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

DEFINE VARIABLE in-int AS INTEGER FORMAT "->>,>>>,>>>,>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 25.5 BY 1 NO-UNDO.

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
       Btn_OK     AT ROW 1.25 COL  2.5
       Btn_Cancel AT ROW 1.25 COL 11
     {&Btn_Help}  AT ROW 1.25 COL 25   SPACE(0.03)
     in-log       AT ROW 3    COL  4.5 NO-LABEL
     comb         AT ROW 4.5  COL  2.5 NO-LABEL
     in-char      AT ROW 4.5  COL  2.5 NO-LABEL
     in-date      AT ROW 4.5  COL  2.5 NO-LABEL
     toggle-date  AT ROW 4.5  COL 15
     in-dec       AT ROW 4.5  COL  2.5 NO-LABEL
     in-int       AT ROW 4.5  COL  2.5 NO-LABEL
     b-spr        AT ROW 4.5  COL 30.5 SKIP(0.44)
WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
     SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
     TITLE "":L
     DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.




/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-spr IN FRAME DIALOG-1
   NO-ENABLE                                                            */
ASSIGN
       b-spr:HIDDEN IN FRAME DIALOG-1           = TRUE.

/* SETTINGS FOR COMBO-BOX comb IN FRAME DIALOG-1
   ALIGN-L                                                              */
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
on choose of btn_ok in frame dialog-1 do:
   { gbl/stdbtn.i }
     case spr :
         when 'pay' then do:
            find ub.pay-type where ub.pay-type.obj-code = input frame dialog-1 in-int no-lock no-error.
            if avail ub.pay-type then str_rus = ub.pay-type.obj-name.
         end.
         when 'curr' then do:
            find ub.currency where ub.currency.curr-code = input frame dialog-1 in-int no-lock.
            if available ub.currency then str_rus = ub.currency.curr-abbr.
         end.
         when 'prt' then do:
            find ub.gds-prt where ub.gds-prt.upper-code = input frame dialog-1 in-int no-lock no-error.
            if avail ub.gds-prt then str_rus = ub.gds-prt.node-name.
         end.
         when 'db' then do:
            find ub.db where ub.db.db-num = input frame dialog-1 in-int no-lock no-error.
            if avail ub.db then str_rus = substitute("&1", ub.db.db-num).
         end.

     end case.
end.

&Scoped-define SELF-NAME b-spr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-spr DIALOG-1
ON CHOOSE OF b-spr IN FRAME DIALOG-1
DO:
  { gbl/stdbtn.i }
  define variable grp-rec as recid no-undo.
  define variable ref-rec as recid no-undo.
  define variable grp_name as char no-undo.
  define variable ref-list as char.
  define variable out-an as int no-undo.
  define variable  rid-list as character no-undo .

  case spr :
         when 'pay' then do:
            run ref/paytype.w (input parparentproc, "b-sel", output  rid-list ).
            find ub.pay-type where recid ( ub.pay-type ) = integer( rid-list) no-lock no-error.
            if available ub.pay-type then do:
               in-int = ub.pay-type.obj-code.
               disp in-int with frame {&frame-name}.
               apply "choose" to btn_ok.
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
               apply "choose" to btn_ok.
               return no-apply.
            end.
         end.
         when 'unit' then do:
            run ref/units.w (input parparentproc
                       , input yes
                       , output ref-rec).
            if ref-rec = ? then return no-apply.
            find ub.units where recid ( ub.units ) = ref-rec no-lock.
            if available ub.units then do:
               in-char = ub.units.unit-name.
               disp in-char with frame {&frame-name}.
               apply "choose" to btn_ok.
               return no-apply.
            end.
         end.
         when 'country' then do:
            run ref/countris.w (
                            input parparentproc
                          , input "b-sel"
                          , input-output rid-list).
            if ref-rec = ? then return no-apply.
            find ub.country where recid ( ub.country ) = integer(rid-list) no-lock.
            if available ub.country then do:
               in-char = ub.country.alpha1.
               disp in-char with frame {&frame-name}.
               apply "choose" to btn_ok.
               return no-apply.
            end.
         end.
         when 'prt' then do:
          run ref/gdsprts.w ( parparentproc, yes, output ref-rec ).
          find  ub.gds-prt where recid ( ub.gds-prt ) = ref-rec no-lock no-error.
          if avail ub.gds-prt then do:
            in-int = ub.gds-prt.upper-code.
            disp in-int with frame {&frame-name}.
            apply "choose" to btn_ok.
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
                     apply "choose" to btn_ok.
                     return no-apply.
                  end.
         end.
         when 'gdsgrp' then do:
            ref-list = "".
            run ref/gds-grp.w (parparentproc, "b-sel", '':U, 0, input-output ref-list ).
            grp-rec = int( ref-list ).
            if grp-rec <> 0 then do:
                find ub.gds-grp where recid( ub.gds-grp ) = grp-rec.
                run grplib-get-full-name in this-procedure ( input ub.gds-grp.node-code, output grp_name ).
                in-char = grp_name.
                disp in-char with frame {&frame-name}.
                apply "entry" to btn_ok.
            end. else apply "entry" to b-spr.
         end.
         when 'db' then do:
            run adm/dbs.w (
                           input parparentproc
                          ,input {&lookup}
                          ,output  ref-rec ).
            find ub.db where recid ( ub.db ) = ref-rec no-lock no-error.
            if available ub.db then do:
               in-int = ub.db.db-num.
               disp in-int with frame {&frame-name}.
               apply "choose" to btn_ok.
               return no-apply.
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

  if can-do("cligrp,gdsgrp,pay,curr,unit,prt,country,db",spr) then do:
    assign
      b-spr:sensitive = yes
      b-spr:visible = yes
    .
  end.

  RUN UI_on.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
  case type:
    when "character"
    then do:
      if comb:visible in frame {&frame-name}
      then do:
        assign
          str = input frame {&frame-name} comb
          str_rus = input comb
        .
      end.
      else do:
        assign
          str = input frame {&frame-name} in-char
          str_rus = input in-char
        .
      end.
      if vlistValueRet ne ?
      then do:
        assign
          kk = comb:lookup(str)
          str = entry( kk, vlistValueRet)
        .
      end.

      assign
        str_rus = replace(str_rus, ',', '~~054')
      .
    end.
    when "date"
    then do:
      if input frame {&frame-name} in-date = "":U
      or input frame {&frame-name} in-date = ?
      or input frame {&frame-name} in-date = "?"
      then do:
        assign
          str = {&question-mark}
          str_rus = {&question-mark}
        .
      end.
      else do:
        if toggle-date :checked = true then do:
          define variable v-diff-value as integer   no-undo .
          define variable v-diff-str   as character no-undo .
          define variable v-diff-day   as character no-undo .
          assign
            v-diff-value = input frame {&frame-name} in-date - today
          .
          if v-diff-value = 0
          then do:
            assign
              v-diff-str = ""
              v-diff-day = ""
            .
          end.
          if v-diff-value > 0
          then do:
            assign
              v-diff-str = '+ ':u + string(v-diff-value)
              v-diff-day = v-diff-str + " ДНЕЙ"
            .
          end.
          if v-diff-value < 0
          then do:
            assign
              v-diff-str = '- ':u + string(abs(v-diff-value))
              v-diff-day = v-diff-str + " ДНЕЙ"
            .
          end.
          assign
            str = '(TODAY ':u + v-diff-str + ')':u
            str_rus = "СЕГОДНЯ " + v-diff-day
          .
        end.
        else do:
          define variable v-date as date      no-undo .
          assign
            v-date = input frame {&frame-name} in-date
          .
          if v-date = ?
          then do:
            assign
              str = {&question-mark}
              str_rus = "НЕ_ЗАДАНА"
            .
          end.
          else do:
            assign
              str = 'date(':u + string(month(v-date))
                  + '~~054':u + string(day(v-date))
                  + '~~054':u + string(year(v-date))
                  + ')':u
              str_rus = string(v-date, "99/99/9999")
            .
          end.
        end.
      end.
    end.
    when "decimal"
    then do:
      assign
        str = string(input frame {&frame-name} in-dec)
        str_rus = string(input in-dec)
      .
    end.
    when "integer"
    then do:
      if can-do( "pay,curr,prt,db", spr )
      then do:
        assign
          str = string( input frame {&frame-name} in-int )
        .
      end.
      else do:
        if    comb:visible in frame {&frame-name}
        then do:
          
          assign
             str        = comb:screen-value
             str        = string( entry(lookup(comb:screen-value, vlistValue), vlistValueRet)) when vlistValueRet ne ?
             str_rus = comb:screen-value
          .
        end.
        else do:
          assign
            str = string(input frame {&frame-name} in-int)
            str_rus = string(input in-int)
          .
        end.
      end.
    end.
    when "logical" then do:
      assign
        str = (input frame {&frame-name} in-log)
        str_rus = (if input in-log = "TRUE" then "ИСТИНА" else "ЛОЖЬ")
      .
    end.
  end case.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI DIALOG-1 _DEFAULT-DISABLE
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
   ------------------------------------------------------------------------------ */
  DISPLAY in-log comb in-date toggle-date in-dec in-char in-int
      WITH FRAME DIALOG-1.
  ENABLE in-log comb in-date toggle-date in-dec in-char in-int Btn_OK Btn_Cancel {&Btn_Help}
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
   run InitForm.
END PROCEDURE.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
{ gbl\f-const.i }

&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME