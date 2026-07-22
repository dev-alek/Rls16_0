&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER X_wealth FOR ub.wealth.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Справочник материальных ценностей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/


/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
define input parameter bttns as char no-undo.
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-mode as character no-undo .
define input-output parameter p-rid-list as char no-undo.



/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Справочник материальных ценностей ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/cur-time.i }
{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ cmp/r-pril.i new }
{ gbl/prn-lib.i }
{ str/wth-lib.i  }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ cmp/mrk-strf.i }
{ gbl/fltopend.i defproc }
{ gbl/usr-flt.i }
define variable filter-label as character no-undo init "Материальные_ценности" .
define variable filter-label0 as character no-undo init "Материальные_ценности" .
define variable filter-point as character no-undo init "wth-ref" .
define variable filter-point0 as character no-undo init "wth-ref" .

define variable sort-column-name as character no-undo .
define variable ri          as      recid   no-undo     init ? .
define variable choice as log no-undo.
define variable mark as char no-undo.
define variable print-option as char no-undo.
define variable varwth-obj as decimal no-undo.
define variable v-doc-rec as recid no-undo .
define variable ser-wth  as logical   no-undo. /* для чтения параметра конфигурации */
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BR-wth

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES X_wealth

/* Definitions for BROWSE BR-wth                                        */
&Scoped-define FIELDS-IN-QUERY-BR-wth mark-string(recid(X_wealth), v-rid-list) X_wealth.wth-code (if X_wealth.stts = 0 then X_wealth.wth-name else substring (X_wealth.wth-name, 1, 15) + {&deleted-stat_}) X_wealth.is-money X_wealth.curr-code get-curr(buffer X_wealth) wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code)
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-wth
&Scoped-define SELF-NAME BR-wth
&Scoped-define QUERY-STRING-BR-wth FOR EACH X_wealth NO-LOCK
&Scoped-define OPEN-QUERY-BR-wth OPEN QUERY {&SELF-NAME} FOR EACH X_wealth NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-wth X_wealth
&Scoped-define FIRST-TABLE-IN-QUERY-BR-wth X_wealth


/* Definitions for DIALOG-BOX Dialog-Frame                              */

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-quit B-mark B-sel B-add B-chg b-lkp B-del ~
B-pobj B-par B-print B-hist B-sch B-Help BR-wth E-PS mark-num F-type
&Scoped-Define DISPLAYED-OBJECTS rsfl-par rstp-par E-PS mark-num F-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Menu Definitions                                                     */
DEFINE MENU MENU-B-print
       MENU-ITEM m_par          LABEL "С номиналами"
       MENU-ITEM m_wealth       LABEL "Без номиналов" .


/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "&Добавить"
     SIZE 10 BY 1.

DEFINE BUTTON B-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON B-del
     LABEL "&Удалить"
     SIZE 10 BY 1.

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 10 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1.

DEFINE BUTTON B-mark
     LABEL "&*"
     SIZE 3 BY 1.

DEFINE BUTTON B-par
     LABEL "&Номиналы"
     SIZE 10 BY 1.

DEFINE BUTTON B-pobj
     LABEL "&Остатки"
     SIZE 10 BY 1.

DEFINE BUTTON B-print
     LABEL "Пе&чать"
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1.

DEFINE VARIABLE E-PS AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 98 BY 2.75 NO-UNDO.

DEFINE VARIABLE F-type AS CHARACTER FORMAT "X(256)":U INITIAL "Тип"
      VIEW-AS TEXT
     SIZE 3.5 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE mark-num AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 2 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE rsfl-par AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущие", 0,
"Все", 3,
"Удаленные", 1
     SIZE 31.5 BY 1 NO-UNDO.

DEFINE VARIABLE rstp-par AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", 3,
"Серийные", 1,
"Несерийные", 0
     SIZE 32 BY .75 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-wth FOR
      X_wealth SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-wth Dialog-Frame _FREEFORM
  QUERY BR-wth NO-LOCK DISPLAY
      mark-string(recid(X_wealth), v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      X_wealth.wth-code FORMAT "999999999":U
      (if X_wealth.stts = 0
 then X_wealth.wth-name
 else substring (X_wealth.wth-name, 1, 15) + {&deleted-stat_}) COLUMN-LABEL "Название" FORMAT "X(49)":U
      X_wealth.is-money COLUMN-LABEL "Денежн.!эквив." FORMAT "+/":U
      X_wealth.curr-code COLUMN-LABEL "Код!вал" FORMAT ">>9":U
      get-curr(buffer X_wealth) COLUMN-LABEL "Валюта/!Ед.изм."
      wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code) COLUMN-LABEL "На объекте" FORMAT "->>>,>>>,>>9.99":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 16.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-quit AT ROW 1 COL 1
     B-mark AT ROW 1 COL 13
     B-sel AT ROW 1 COL 16
     B-add AT ROW 1 COL 26
     B-chg AT ROW 1 COL 36
     b-lkp AT ROW 1 COL 46
     B-del AT ROW 1 COL 56
     B-pobj AT ROW 1 COL 66
     B-par AT ROW 1 COL 76
     B-print AT ROW 1 COL 86
     B-hist AT ROW 1 COL 89
     B-sch AT ROW 1 COL 92
     B-Help AT ROW 1 COL 95
     rsfl-par AT ROW 2.25 COL 10 NO-LABEL WIDGET-ID 2
     rstp-par AT ROW 3.25 COL 10 NO-LABEL WIDGET-ID 14
     BR-wth AT ROW 4.25 COL 1
     E-PS AT ROW 21 COL 1 NO-LABEL
     mark-num AT ROW 1 COL 11 NO-LABEL
     F-type AT ROW 3.25 COL 3 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     "Статус" VIEW-AS TEXT
          SIZE 7 BY .67 AT ROW 2.42 COL 2 WIDGET-ID 12
          FGCOLOR 4
     SPACE(90.39) SKIP(20.66)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Справочник материальных ценностей".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: X_wealth B "?" ? ub wealth
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BR-wth rstp-par Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       B-print:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-print:HANDLE.

ASSIGN
       E-PS:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR RADIO-SET rsfl-par IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RADIO-SET rstp-par IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       rstp-par:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-wth
/* Query rebuild information for BROWSE BR-wth
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH X_wealth NO-LOCK.
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* BROWSE BR-wth */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame /* Справочник материальных ценностей */
DO:
  RUN save-position IN THIS-PROCEDURE NO-ERROR.
  p-rid-list = v-rid-list.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник материальных ценностей */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wealth_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply.
run ref/wth-form.w (
                 input parparentproc
               , input 0
               , input {&add-def}
               , output rep-rec).

if rep-rec <> ? then do:
   v-doc-rec = rep-rec.
   RUn OpenBr in this-procedure  ( input yes, input no, input '':U).
  apply "entry" to br-wth in frame {&frame-name}.
end.
else do:
  apply "entry" to br-wth in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
define variable rep-rec as recid no-undo .
define variable glog as logical no-undo .
  if not available X_wealth then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
if X_wealth.stts = 1 then do:
  message substitute("Изменение записи со статусом &1 невозможно!",{&deleted-stat_}).
  return no-apply.
end.
rep-rec = recid (X_wealth).
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wealth_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}

if NOT glog then return no-apply.
run ref/wth-form.w (
                 input parparentproc
               , input X_wealth.wth-code
               , input {&update}
               , output rep-rec).
if rep-rec <> ? then do:
   RUn OpenBr in this-procedure  ( input yes, input no, input '':U).
   apply "entry" to br-wth in frame {&frame-name}.
end.
else do:
  apply "entry" to br-wth in frame {&frame-name}.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:
define variable del-rec as recid no-undo.
define variable glog as logical no-undo .
define variable rep-rec as recid no-undo .
define buffer buf_wealth for ub.wealth.
if not available X_wealth then do:
  message "Неправильно выбрана строка.".
  return no-apply.
end.
{ gbl/chk-actg.i
v-cntxt-db-num
v-cntxt-userid
{&action-head-code-main}
'actn_wealth_work':U
{&cntxt-global}
0
'':U
0
0
0
0
true
glog
}
if NOT glog then return no-apply.
rep-rec = recid ( X_wealth).
glog = no.

FIND FIRST buf_wealth WHERE recid (buf_wealth) = rep-rec.
if buf_wealth.stts <> 0 then do:
    glog = no.
    message
    "МЦ" buf_wealth.wth-code buf_wealth.wth-name "уже удалена." skip
    "Восстановить ?"
    view-as alert-box question buttons Yes-No update glog.
    if not glog then do:
      apply "entry" to br-wth in frame {&frame-name}.
      return no-apply.
    end.
    assign
    buf_wealth.stts = 0
    .
    run OpenBr in this-procedure  ( input yes, input no, input '':U).
    apply "entry" to br-wth in frame {&frame-name}.

end.
else do:
      glog = no.
      message
      "Удалить МЦ :" skip
      buf_wealth.wth-code buf_wealth.wth-name skip
     "Вы уверены ?"
      view-as alert-box question buttons OK-Cancel update glog.
      if not glog then do:
        apply "entry" to br-wth in frame {&frame-name}.
        return no-apply.
      end.
      /*проверка на количество*/
      if wth-lib_cur-stock-host-func(p-curr-host-code,buf_wealth.wth-code ) <> 0 then do:
        message 'Удаление невозможно!' skip
       'МЦ имеется на остатках по фирме.' skip
       'Количество по фирме: ' wth-lib_cur-stock-host-func(p-curr-host-code,buf_wealth.wth-code )
       view-as alert-box error.
       apply "entry" to br-wth in frame {&frame-name}.
       return no-apply.
      end.
      assign
      buf_wealth.stts = 1
      .
    run OpenBr in this-procedure  ( input yes, input no, input '':U).
    apply "entry" to br-wth in frame {&frame-name}.


 end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-hist
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-hist Dialog-Frame
ON CHOOSE OF B-hist IN FRAME Dialog-Frame /* История */
DO:
  IF NOT AVAILABLE X_wealth THEN RETURN NO-APPLY.
  define variable v-rid-list  as   character            no-undo .
  define variable v-host-code like ub.sysconf.host-code no-undo .
  run ref/cwthhist.w (
                   input        parparentproc
                 , input        p-curr-host-code
                 , input        p-curr-obj-type
                 , input        p-curr-obj-code
                 , input        "":U          /* bttns */
                 , input        "one":U       /* p-mode */
                 , input        X_wealth.wth-code /*p-wth-code*/
                 , INPUT        0             /*p-par-code*/
                 , input        ?             /* p-host-code */
                 , input        ?             /* p-obj-type*/
                 , input        ?             /* p-obj-code*/
                 , input        ?             /* p-corr-user-db-num */
                 , input        "":U          /* p-corr-user-name */
                 , input        "":U          /* p-subject */
                 , input         v-cntxt-db-num      /* p-db-num */
                 , input        ?
                 , input        ?
                 , input-output v-rid-list
                 ) no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-lkp Dialog-Frame
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
    define variable rep-rec as recid no-undo .
    if not available X_wealth then do:
      message "Неправильно выбрана строка.".
      return no-apply.
    end.
    rep-rec = recid (X_wealth).

    run ref/wth-form.w (
                     input parparentproc
                   , input X_wealth.wth-code
                   , input {&lookup}
                   , output rep-rec) NO-ERROR.
     apply "entry" to br-wth in frame {&frame-name}.
     return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:
 define variable glog as logical no-undo .
  if available X_wealth then do:
    { gbl/markstrn.i X_wealth v-rid-list }
    br-wth:refresh().
    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
            glog = br-wth:select-next-row ().
            apply "iteration-changed" to br-wth in frame {&frame-name}.
        end.
    if num-entries( v-rid-list ) = 0 then
        hide mark-num in frame {&frame-name}.
    else
        disp num-entries( v-rid-list ) @ mark-num with frame {&frame-name}.
  end.
  apply "entry" to br-wth in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-par Dialog-Frame
ON CHOOSE OF B-par IN FRAME Dialog-Frame /* Номиналы */
DO:
  if not avail X_wealth then return no-apply.
  define variable v-rid-list as character no-undo .
  run ref/wthp-ref.w (
                  input parparentproc
                 ,input (if lookup("b-add", bttns) > 0 then "b-add" else "")
                 ,input p-curr-host-code
                 ,input p-curr-obj-type
                 ,input p-curr-obj-code
                 ,input {&wealth}
                 ,input X_wealth.wth-code
                 ,input-output v-rid-list).

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-pobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-pobj Dialog-Frame
ON CHOOSE OF B-pobj IN FRAME Dialog-Frame /* Остатки */
DO:
define variable v-rid-list as character no-undo .

  if avail X_wealth then do:
    run ref/wthpobjr.w (
                    input parparentproc
                   ,input ({&wealth} + {&slash-char} + {&g___object})
                   ,input X_wealth.wth-code
                   ,input ?
                   ,input p-curr-obj-type
                   ,input p-curr-obj-code
                   ,input-output v-rid-list
                   ) .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
define variable doc-rec as recid no-undo .
  if print-option = "" then do:
       run gbl/pop-up.p (self:handle, no) no-error.
  end.
    doc-rec = recid( X_wealth ).
    DO WHILE available X_wealth :
          GET prev br-wth.
    END.
    CASE print-option:
      when "wealth":U then do:
          run PrintProc.

      end.
      when "wth-par":U then do:
          run PrintProcPar.

      end.
    END CASE.
    print-option = "".
    reposition br-wth to recid doc-rec no-error.
    apply "entry" to br-wth in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&Scoped-define SELF-NAME B-sch
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sch Dialog-Frame
ON CHOOSE OF B-sch IN FRAME Dialog-Frame /* Фильтр */
DO:
  assign
  tbl = 'wealth'
  join-tbl = 'X_wealth'
  fld = '':U
  spr = '':U
  lab = '':U
  dim = '0':U
  .
  run fltfield-add in this-procedure('wth-code', 'Код МЦ', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('wth-name', 'Название', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('curr-code', '', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-money', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('PS', 'Примечание', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  DO on stop undo, leave:
      run gbl/filter.w ( input parparentproc
                        ,input filter-point
                        ,input tbl
                        ,input join-tbl
                        ,input fld
                        ,input lab
                        ,input spr
                        ,input dim).
      RUN OpenBr in this-procedure  ( input yes, input no, input '':U).
  END .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
    if ( available X_wealth
        AND (v-rid-list = ""
            or
            b-mark:sensitive = no)
        ) then
        v-rid-list = string( recid( X_wealth ) ) .


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BR-wth
&Scoped-define SELF-NAME BR-wth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wth Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BR-wth IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wth Dialog-Frame
ON RETURN OF BR-wth IN FRAME Dialog-Frame
DO:
    if lookup("b-sel", bttns) > 0 then APPLY "CHOOSE" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BR-wth Dialog-Frame
ON VALUE-CHANGED OF BR-wth IN FRAME Dialog-Frame
DO:
  if avail X_wealth then do:
    E-PS:screen-value = X_wealth.PS  .
    b-del:label = if X_wealth.stts = 1 then 'Восстанов' else 'Удалить'.
  end.
  else
  E-PS:screen-value = "".

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_par Dialog-Frame
ON CHOOSE OF MENU-ITEM m_par /* С номиналами */
DO:
      print-option = "wth-par":U.
    apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME m_wealth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL m_wealth Dialog-Frame
ON CHOOSE OF MENU-ITEM m_wealth /* Без номиналов */
DO:
        print-option = "wealth":U.
    apply "choose" to b-print in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rsfl-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rsfl-par Dialog-Frame
ON VALUE-CHANGED OF rsfl-par IN FRAME Dialog-Frame
DO:
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rstp-par
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rstp-par Dialog-Frame
ON VALUE-CHANGED OF rstp-par IN FRAME Dialog-Frame
DO:
  RUN OpenBR in this-procedure  ( input yes, input no, input '':U).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/app_help.i }
{ gbl/setfltnm.i }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-del }
{ gbl/hot-key.i b-sel }
&scop b-quit ~{&b-exit~}
{ gbl/hot-key.i b-quit }
{ gbl/hot-key.i b-print }
{ gbl/brwrepos.i
&browse-name = "br-wth"
&line-num=5
}
{ gbl/brwrefre.i " v-doc-rec = ?. if available X_wealth then assign v-doc-rec = recid(X_wealth). run openbr in this-procedure  ( input yes, input no, input '':U). ~
               reposition br-wth to recid v-doc-rec no-error. APPLY 'ENTRY' to br-wth. APPLY 'VALUe-CHANGED' to br-wth. " }

  { gbl/conf-rd.i
  "'ser-wth'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  NO
  conf-par
  par-type
  no-error
  }
  IF not error-status:error then
  assign
  ser-wth = (conf-par = "yes":U).

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  v-rid-list = p-rid-list.
  RUN Myenable.
 /* RUN OpenBR in this-procedure  ( input yes, input no, input '':U).   */
  if v-rid-list <> "":u then do:
    assign
    v-doc-rec = integer(v-rid-list)
    no-error .
  end.
  APPLY "ENTRY" to br-wth.

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
  DISPLAY rsfl-par rstp-par E-PS mark-num F-type
      WITH FRAME Dialog-Frame.
  ENABLE b-quit B-mark B-sel B-add B-chg b-lkp B-del B-pobj B-par B-print
         B-hist B-sch B-Help BR-wth E-PS mark-num F-type
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE load-position Dialog-Frame
PROCEDURE load-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-current-stts-string       as character    no-undo.
define variable v-current-type-string       as character    no-undo.
define variable v-void-logical              as logical      no-undo.
define variable v-void-character            as character    no-undo.
define variable v-found                     as logical      no-undo.

do   with frame {&frame-name}
on error undo, return error
:
    run uf-get (
          input {&uf-wthref-stts}
        , input v-cntxt-userid
        , output v-current-stts-string
        , output v-void-character
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
    ) no-error.

    if not error-status :error then rsfl-par:screen-value =  v-current-stts-string.
        run uf-get (
              input {&uf-wthref-type}
            , input v-cntxt-userid
            , output v-current-type-string
            , output v-void-character
            , output v-void-logical
            , output v-void-logical
            , output v-void-logical
            , output v-void-logical
    ) no-error.
    if not error-status :error then  rstp-par:screen-value = v-current-type-string  .
 end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable glog as logical no-undo .
DISPLAY E-PS mark-num
WITH FRAME {&frame-name}.
ENABLE
br-wth
b-quit
b-mark WHEN LOOKUP("b-mark":U, bttns) > 0
b-sel  WHEN LOOKUP("b-sel":U, bttns) > 0
b-pobj
b-print
b-sch
b-lkp
b-help
b-add WHEN (LOOKUP("b-add":U, bttns) > 0 AND v-cntxt-db-num = 0)
b-del WHEN (LOOKUP("b-add":U, bttns) > 0 AND v-cntxt-db-num = 0)
b-chg WHEN (LOOKUP("b-add":U, bttns) > 0 AND v-cntxt-db-num = 0)
b-par
b-hist
rsfl-par
rstp-par
f-type
WITH FRAME {&frame-name}.
VIEW FRAME Dialog-Frame.
if not ser-wth then hide   rstp-par f-type
IN FRAME {&frame-name}.
else f-type:screen-value = 'Тип'.
if not p-mode = {&all} then
disable
 rstp-par
WITH FRAME {&frame-name}.
run load-position in this-procedure.
if p-mode = 'wth-ser':U then rstp-par:screen-value = '1'.
else if p-mode = 'wth-nser':U then rstp-par:screen-value = '0'.
apply 'value-changed':U to rstp-par.
if available X_wealth then
glog = br-wth:select-focused-row( ).
ASSIGN b-print:MENU-MOUSE = 1.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE OpenBr Dialog-Frame
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .

define variable l-query-was-opened as logical no-undo .

ASSIGN FRAME {&FRAME-NAME} rsfl-par.
ASSIGN FRAME {&FRAME-NAME} rstp-par.


/*run waitfram-show in this-procedure ("Ждите..." ).  */

define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.

&scop flt-open-debug-file

&scop flt-open-open-query OPEN QUERY br-wth FOR EACH X_wealth

&scop flt-open-dyn_open-query FOR EACH X_wealth

&scop flt-open-query-handle QUERY br-wth:handle

&scop flt-open-open-query-tail


&scop flt-open-query-was-opened  l-query-was-opened

&scop flt-open-sort-column-phrase sort-column-phrase

&scop flt-open-call-point filter-point

&scop flt-open-set-filter-name set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-waitfram yes

CASE p-mode:
    when {&all} then do:
        ASSIGN frame {&frame-name}:TITLE = "Материальные ценности "
        filter-point = "Материальные ценности " + p-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par) and (if rstp-par = 3 then true else x_wealth.is-ser = rstp-par) "
            &dyn_where-cond = " substitute('(if &1 = 3 then true else x_wealth.stts = &1) and (if &2 = 3 then true else x_wealth.is-ser = &2) ' ~
                               ,rsfl-par, rstp-par )"
            &use-ind = "  "
            &by = "  "
          }
    end.
    when 'wth-ser':U then do:
        ASSIGN frame {&frame-name}:TITLE = "Серийные материальные ценности "
        filter-point = "Материальные ценности " + p-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wealth.is-ser = 1 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)  "
            &dyn_where-cond = " substitute('X_wealth.is-ser = 1 and (if &1 = 3 then true else x_wealth.stts = &1)  ', rsfl-par)"
            &use-ind = "  "
            &by = " by X_wealth.wth-code  "
          }
    end.
    when 'wth-nser':U then do:
        ASSIGN frame {&frame-name}:TITLE = "Несерийные материальные ценности "
        filter-point = "Материальные ценности " + p-mode
        filter-label = substitute("&1", filter-label0)
        .
          { gbl/fltopend.i
            &where-cond = " X_wealth.is-ser = 0 and (if rsfl-par = 3 then true else x_wealth.stts = rsfl-par)  "
            &dyn_where-cond = " substitute('X_wealth.is-ser = 0 and (if &1 = 3 then true else x_wealth.stts = &1)  ', rsfl-par)"
            &use-ind = "  "
            &by = " by X_wealth.wth-code "
          }
    end.


END CASE.

if v-doc-rec <> ? then reposition br-wth to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-wth:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if error-status:error then do:
  reposition br-wth to row 1 no-error.
end.
apply "entry" to br-wth in frame {&frame-name}.
/*run waitfram-hide in this-procedure . */
if avail X_wealth then
APPLY "VALUE-CHANGED":U to br-wth.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc Dialog-Frame
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable var-on-obj as decimal no-undo.

DEFINE FRAME Wth-List
X_wealth.wth-code     column-label "Код"
X_wealth.wth-name     column-label "Название"
X_wealth.is-money     column-label "Денежн.!эквив."
X_wealth.curr-code    column-label "Код!валюты"
X_wealth.unit-base    column-label "Валюта/!Ед.изм."
var-on-obj          column-label "Остаток!на объекте" format "->>>,>>>,>>9.99"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width {&A4_CW} down stream-io use-text    .
Line = fill("-", 70).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&Cs_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

    PUT  STREAM PrnLibStream
    SPACE(25) ( frame {&frame-name}:title )
    format "x(90)" SKIP(1) .
    FORM HEADER
    Line AT 1 SKIP
    "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW  STREAM PrnLibStream FRAME BottomFrame .

    FORM with FRAME Wth-List  .
    run waitfram-show in this-procedure ("Ждите...").
    GET next br-wth.
     DO WHILE available X_wealth :
        var-on-obj = wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code).
        Display STREAM PrnLibStream
        X_wealth.wth-code
        X_wealth.wth-name
        X_wealth.is-money
        X_wealth.curr-code
        X_wealth.unit-base
        var-on-obj
        with FRAME Wth-List .
        DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
        GET next br-wth.
      END.
      UNDERLINE  STREAM PrnLibStream
        X_wealth.wth-code
        X_wealth.wth-name
        X_wealth.is-money
        X_wealth.curr-code
        X_wealth.unit-base
        var-on-obj
        with FRAME Wth-List .
    HIDE  STREAM PrnLibStream FRAME BottomFrame .
    HIDE  STREAM PrnLibStream FRAME CheckList.
    output  STREAM PrnLibStream CLOSE.
    run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProcpar Dialog-Frame
PROCEDURE PrintProcpar :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable date_string     as      char    no-undo.
define variable Line                as      char    no-undo.
define variable for-time as char.
define variable var-on-obj as decimal no-undo.
define buffer buf_wth-par for ub.wth-par.

DEFINE FRAME Wth-List
X_wealth.wth-code     column-label "Код"
X_wealth.wth-name     column-label "Название"
X_wealth.is-money     column-label "Денежн.!эквив."
X_wealth.curr-code    column-label "Код!валюты"
X_wealth.unit-base    column-label "Валюта/!Ед.изм."
var-on-obj          column-label "Остаток!на объекте" format "->>>,>>>,>>9.99"
buf_wth-par.par-code     column-label "Код!номинала"
buf_wth-par.par-val     column-label "Номинал"
buf_wth-par.par-unit     column-label "Ед.изм.!номинала"
buf_wth-par.par-rate     column-label "Коэфф."
buf_wth-par.par-feat     column-label "Доп. признак"
HEADER  date_string AT 5 format "X(35)"
string( "Страница " ) format "X(9)" AT 100 PAGE-NUMBER(PrnLibStream) AT 110 FORMAT ">>9" SKIP
Line format "X(138)" AT 1
with width {&A4_CW} down stream-io use-text    .
Line = fill("-", 122).
date_string = cur-time-print() .

run prn-lib-open-stream  in this-procedure (
                                             input parParentProc
                                            ,input {&CS_PS}
                                            ,input yes /*p-is-stream*/
                                            ,input no /*p-append*/
                                            ).

PUT  STREAM PrnLibStream
SPACE(25) ( frame {&frame-name}:title )
format "x(90)" SKIP(1) .
FORM HEADER
Line AT 1 SKIP
"Продолжение - на следующей странице" AT 30 SKIP
with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
VIEW  STREAM PrnLibStream FRAME BottomFrame .

FORM with FRAME Wth-List  .
run waitfram-show in this-procedure ("Ждите...").
GET next br-wth.
DO WHILE available X_wealth :
  var-on-obj = wth-lib_cur-stock-obj-func(p-curr-obj-type,p-curr-obj-code, X_wealth.wth-code).
  Display STREAM PrnLibStream
  X_wealth.wth-code
  X_wealth.wth-name
  X_wealth.is-money
  X_wealth.curr-code
  X_wealth.unit-base
  var-on-obj
  with FRAME Wth-List .
  DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  FOR EACH buf_wth-par No-LOCK WHERE
            buf_wth-par.wth-code = X_wealth.wth-code:
      Display STREAM PrnLibStream
      buf_wth-par.par-code
      buf_wth-par.par-val
      buf_wth-par.par-unit
      buf_wth-par.par-rate
      buf_wth-par.par-feat
      with FRAME Wth-List .
      DOWN STREAM PrnLibStream 1 with FRAME Wth-List  .
  END.
  UNDERLINE  STREAM PrnLibStream
  X_wealth.wth-code
  X_wealth.wth-name
  X_wealth.is-money
  X_wealth.curr-code
  X_wealth.unit-base
  var-on-obj
  buf_wth-par.par-code
  buf_wth-par.par-val
  buf_wth-par.par-unit
  buf_wth-par.par-rate
  buf_wth-par.par-feat
  with FRAME Wth-List .

  GET next br-wth.
END.
HIDE  STREAM PrnLibStream FRAME BottomFrame .
HIDE  STREAM PrnLibStream FRAME CheckList.
output  STREAM PrnLibStream CLOSE.
run waitfram-hide in this-procedure .
run prn-lib-prn-file in this-procedure (
                                          input parParentProc
                                          ,input 0
                                          ).


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-position Dialog-Frame
PROCEDURE save-position :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
assign rsfl-par rstp-par.
        run uf-set (
              input {&uf-wthref-stts}
            , input v-cntxt-userid
            , input string( rsfl-par )
            , input {&uf-wthref-stts}
            , input no
            , input no
            , input no
            , input no
        ) no-error .
        run uf-set (
              input {&uf-wthref-type}
            , input v-cntxt-userid
            , input string( rstp-par )
            , input {&uf-wthref-type}
            , input no
            , input no
            , input no
            , input no
        ) no-error.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME