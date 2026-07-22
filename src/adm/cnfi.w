&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-cnf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-cnf
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Просмотр и корректировка системных настроек

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/00
Author: Dmitry Ukhanov
Creation date: 03/22/00

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

define input        parameter parparentproc as widget-handle no-undo .
define input        parameter Cnf-hdl       as handle        no-undo .         /* ссылка на библиотеку работы с конфигурацией */
define input        parameter db-hdl        as handle        no-undo .         /* ссылка на библиотеку работы с параметрами в базе */
define input        parameter str-hdl       as handle        no-undo .         /* ссылка на библиотеку работы с параметрами в базе */
define input        parameter p-action      as character     no-undo .
define input-output parameter ri            as integer       no-undo init ?.   /* запись таблицы параметров в памяти */

/* Local Variable Definitions ---                                       */

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Просмотр и корректировка системных настроек".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/cnf-inc.i }
{ adm/cfg-pr.i }
{ cmp/showinf.i }
&if defined(stand-alone) = 0 &then /*для работы с базой */
{ gbl/usr-flt.i      }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
&endif

define variable v-host-code     as integer   no-undo .
define variable v-obj-host-code as integer   no-undo.
define variable v-types         as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-cnf

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-quit b-help RECT-1 RECT-2 ~
f-param-name f-param-ps f-param-value btn_dwl f-obj-name 
&Scoped-Define DISPLAYED-OBJECTS f-db-num f-db-key f-param-name f-param-ps ~
f-param-value f-beg-date t-beg-date f-end-date t-end-date f-obj-type ~
f-obj-code f-host-name f-param-code f-cnf-type f-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-clients DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL "b-clients"
     SIZE 3 BY .88.

DEFINE BUTTON b-exit AUTO-GO DEFAULT
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-quit AUTO-END-KEY DEFAULT
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON btn_dwl 
     LABEL "Загрузить" 
     SIZE 15 BY 1 TOOLTIP "Загрузить значение из excel".

DEFINE VARIABLE f-host-name AS CHARACTER FORMAT "X(80)":U
     LABEL "Фирма"
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 85 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-type AS CHARACTER FORMAT "X(3)":U
     LABEL "Объект"
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 6 BY 1 NO-UNDO.

DEFINE VARIABLE f-param-name AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 85 BY 1.5 NO-UNDO.

DEFINE VARIABLE f-param-ps AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 85 BY 2.5 NO-UNDO.

DEFINE VARIABLE f-beg-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-cnf-type AS CHARACTER FORMAT "X(40)":U
      VIEW-AS TEXT
     SIZE 51.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-db-key AS CHARACTER FORMAT "X(12)" INITIAL ?
     LABEL "Ключ БД"
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.

DEFINE VARIABLE f-db-num AS INTEGER FORMAT ">>>>>>>>9" INITIAL ?
     LABEL "Номер БД"
     VIEW-AS FILL-IN
     SIZE 9 BY 1 NO-UNDO.

DEFINE VARIABLE f-end-date AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-code AS INTEGER FORMAT ">>>>>>>>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.

DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(80)":U
      VIEW-AS TEXT
     SIZE 68.5 BY .67 NO-UNDO.

DEFINE VARIABLE f-param-code AS CHARACTER FORMAT "X(8)":U
     LABEL "Параметр"
      VIEW-AS TEXT
     SIZE 9 BY .67 NO-UNDO.

DEFINE VARIABLE f-param-value AS CHARACTER FORMAT "X(250)":U 
     LABEL "Значение" 
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 85 BY 1 NO-UNDO.

DEFINE VARIABLE f-param-value-2 AS CHARACTER FORMAT "X(31000)":U 
     LABEL "Значение"
     VIEW-AS FILL-IN 
     SIZE 85 BY 1 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 4.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 3.25.

DEFINE VARIABLE t-beg-date AS LOGICAL INITIAL yes
     LABEL "неограничено"
     VIEW-AS TOGGLE-BOX
     SIZE 16.5 BY 1 NO-UNDO.

DEFINE VARIABLE t-end-date AS LOGICAL INITIAL yes
     LABEL "неограничено"
     VIEW-AS TOGGLE-BOX
     SIZE 16.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-cnf
     b-clients AT ROW 15.38 COL 26
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 89
     f-db-num AT ROW 2.5 COL 12 COLON-ALIGNED
     f-db-key AT ROW 2.5 COL 31.5 COLON-ALIGNED
     f-param-name AT ROW 4.96 COL 14 NO-LABEL
     f-param-ps AT ROW 6.79 COL 14 NO-LABEL
     f-param-value-2 AT ROW 9.54 COL 12 COLON-ALIGNED WIDGET-ID 4
     f-param-value AT ROW 9.54 COL 12 COLON-ALIGNED
     f-beg-date AT ROW 11.29 COL 30.5 COLON-ALIGNED NO-LABEL
     t-beg-date AT ROW 11.29 COL 45
     btn_dwl AT ROW 11.29 COL 62.5 WIDGET-ID 2
     f-end-date AT ROW 12.54 COL 30.5 COLON-ALIGNED NO-LABEL
     t-end-date AT ROW 12.54 COL 45
     f-obj-type AT ROW 15.29 COL 11 COLON-ALIGNED
     f-obj-code AT ROW 15.29 COL 17 COLON-ALIGNED NO-LABEL
     f-host-name AT ROW 16.5 COL 11 COLON-ALIGNED
     f-param-code AT ROW 3.79 COL 12 COLON-ALIGNED
     f-cnf-type AT ROW 3.79 COL 21 COLON-ALIGNED NO-LABEL
     f-obj-name AT ROW 15.46 COL 27.5 COLON-ALIGNED NO-LABEL
     "Дата окончания действия:" VIEW-AS TEXT
          SIZE 25 BY .75 AT ROW 12.54 COL 7.5
     "Название:" VIEW-AS TEXT
          SIZE 9.5 BY 1 AT ROW 4.79 COL 4
     "Дата начала действия:" VIEW-AS TEXT
          SIZE 22 BY .75 AT ROW 11.54 COL 10.5
     "Привязки" VIEW-AS TEXT
          SIZE 9 BY .67 AT ROW 14.29 COL 2.5
     "Примечание:" VIEW-AS TEXT
          SIZE 11 BY 1 AT ROW 6.79 COL 2
     RECT-1 AT ROW 14.04 COL 2
     RECT-2 AT ROW 10.79 COL 2
     SPACE(0.87) SKIP(4.33)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Модификация параметра конфигурации"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-cnf
   FRAME-NAME                                                           */
ASSIGN
       FRAME d-cnf:SCROLLABLE       = FALSE.

/* SETTINGS FOR BUTTON b-clients IN FRAME d-cnf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-beg-date IN FRAME d-cnf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-cnf-type IN FRAME d-cnf
   NO-ENABLE                                                            */
ASSIGN
       f-cnf-type:READ-ONLY IN FRAME d-cnf        = TRUE.

/* SETTINGS FOR FILL-IN f-db-key IN FRAME d-cnf
   NO-ENABLE                                                            */
ASSIGN
       f-db-key:READ-ONLY IN FRAME d-cnf        = TRUE.

/* SETTINGS FOR FILL-IN f-db-num IN FRAME d-cnf
   NO-ENABLE                                                            */
ASSIGN
       f-db-num:READ-ONLY IN FRAME d-cnf        = TRUE.

/* SETTINGS FOR FILL-IN f-end-date IN FRAME d-cnf
   NO-ENABLE                                                            */
/* SETTINGS FOR COMBO-BOX f-host-name IN FRAME d-cnf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-obj-code IN FRAME d-cnf
   NO-ENABLE                                                            */
ASSIGN
       f-obj-name:READ-ONLY IN FRAME d-cnf        = TRUE.

/* SETTINGS FOR COMBO-BOX f-obj-type IN FRAME d-cnf
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-param-code IN FRAME d-cnf
   NO-ENABLE                                                            */
ASSIGN
       f-param-code:READ-ONLY IN FRAME d-cnf        = TRUE.

ASSIGN
       f-param-name:READ-ONLY IN FRAME d-cnf        = TRUE.

ASSIGN
       f-param-ps:READ-ONLY IN FRAME d-cnf        = TRUE.

/* SETTINGS FOR FILL-IN f-param-value-2 IN FRAME d-cnf
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR TOGGLE-BOX t-beg-date IN FRAME d-cnf
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX t-end-date IN FRAME d-cnf
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK DIALOG-BOX d-cnf
/* Query rebuild information for DIALOG-BOX d-cnf
     _Options          = "SHARE-LOCK"
     _Query            is NOT OPENED
*/  /* DIALOG-BOX d-cnf */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-cnf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-cnf d-cnf
ON WINDOW-CLOSE OF FRAME d-cnf /* Модификация параметра конфигурации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clients
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clients d-cnf
ON CHOOSE OF b-clients IN FRAME d-cnf /* b-clients */
DO:
  &if defined (stand-alone) = 0 &then
    /* сюда должны попадать только при работе с базой */
    define variable ref-list   as character no-undo.
    define variable ref-rec    as recid     no-undo.
    define variable clr-object as logical   no-undo .

    run ref/cli-all.w ( parparentproc, "b-sel", ?, ?, ?, ?, ?, ?, output ref-list) .
    if ref-list <> ""
    then do:
      assign
        ref-rec = integer (ref-list)
      .
      run disp-obj in this-procedure
        ( input ref-rec
         ,input ?
         ,input ?
        ) no-error .
      if error-status :error then do:
        return no-apply .
      end.
      run chk-host-code in db-hdl (f-obj-type, f-obj-code, output v-obj-host-code).
      if v-obj-host-code = ?
      then do:
        run clr-ref-object ( return-value ).
      end.
      else do:
        if v-host-code <> v-obj-host-code then do:
          if v-host-code <> 0 then do:
            message "Выбранный объект относится к другой фирме " skip
                    "Заменить привязку к фирме?" skip
              view-as alert-box buttons yes-no update clr-object .
          end.
          if clr-object = true
            or v-host-code = 0
          then do:
            assign
              v-host-code = v-obj-host-code
            .
            find first ub.clients no-lock
              where ub.clients.obj-code = v-obj-host-code
                and ub.clients.obj-type = {&cmp}
            no-error.
            assign
              f-host-name = substitute( "&1  &2", string(ub.clients.obj-code, "999999999"), ub.clients.obj-name )
            .
            display f-host-name with frame {&frame-name}.
          end.
        end.
      end.
    end.
  &endif
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-cnf
ON CHOOSE OF b-exit IN FRAME d-cnf /* Ввод */
DO:

  define variable v-msg as character no-undo .
  define variable v-ok  as logical   no-undo .

  define buffer buf_cnf for cnf.

  assign
    f-db-num
    f-db-key
    f-param-value
    f-param-value-2
    f-obj-type
    f-obj-code
    t-beg-date
    t-end-date
  .
  if t-beg-date <> true
  then do:
    assign
      f-beg-date
    .
  end.
  if t-end-date <> true
  then do:
    assign
      f-end-date
    .
  end.

  if f-param-value = ? then do:
    assign
      f-param-value = "":U
    .
  end.

  if f-param-value-2 = ? then do:
    assign
      f-param-value-2 = "":U
    .
  end.

  if f-beg-date = ? then do:
    message
      "Не установлена дата начала срока действия параметра!" skip
      view-as alert-box error .
    apply "entry":U to f-beg-date in frame {&frame-name}.
    return no-apply.
  end.
  if f-end-date = ? then do:
    message
      "Не установлена дата окончания срока действия параметра!" skip
      view-as alert-box error .
    apply "entry":U to f-end-date in frame {&frame-name}.
    return no-apply.
  end.

  if f-db-num = ? then do:
    message
      "Не установлен номер БД в которой будет действовать этот параметр!" skip
      view-as alert-box error .
    apply "entry":U to f-db-num in frame {&frame-name}.
    return no-apply.
  end.


  if f-obj-type <> "":U
    or f-obj-code <> 0
  then do:
    apply "leave" to f-obj-code in frame {&frame-name}.
  end.

  find first buf_cnf no-lock
    where buf_cnf.db-num     = f-db-num
      and buf_cnf.param-code = f-param-code
      and buf_cnf.beg-date   = f-beg-date
      and buf_cnf.end-date   = f-end-date
      and buf_cnf.host-code  = v-host-code
      and buf_cnf.obj-type   = f-obj-type
      and buf_cnf.obj-code   = f-obj-code
      and rowid( buf_cnf ) <> rowid( cnf )
    no-error
  .
  if available buf_cnf then do:
    assign
      v-msg = substitute( "Уже есть параметр &1 для БД &2&3"
                          ,f-param-code
                          ,f-db-num
                          ,{&new-line}
                        )
    .
    if t-beg-date = true
      and t-end-date = true
    then do:
      assign
        v-msg = v-msg + substitute( "с неограниченным периодом действия" )
      .
    end.
    else do:
      assign
        v-msg = v-msg + substitute( "с периодом действия&1", {&space-char} )
      .
      if t-beg-date <> true then do:
        assign
          v-msg = v-msg + substitute( "c &1&2", f-beg-date, {&space-char} )
        .
      end.
      if t-end-date <> true then do:
        assign
          v-msg = v-msg + substitute( "по &1&2", f-end-date, {&space-char} )
        .
      end.
    end.
    assign
      v-msg = v-msg + substitute( "&1", {&new-line} )
    .
    message
      v-msg skip
      view-as alert-box error .
    apply "entry":U to f-db-num in frame {&frame-name}.
    return no-apply.
  end.

  &if defined(stand-alone) > 0 &then /*для работы без базы */
    for first buf_cnf
      where ( buf_cnf.db-key = f-db-key
              and buf_cnf.db-num > f-db-num
            )
        or ( buf_cnf.db-key = f-db-key
              and buf_cnf.db-num < f-db-num
            )
    on error undo, return no-apply
    :
      message
        substitute( "Ключ БД '&1' уже используется для БД &2 .", f-db-key, buf_cnf.db-num ) skip
        substitute( "Вы хотите сохранить это значение ключа для БД &1?", f-db-num ) skip
        view-as alert-box question buttons yes-no update v-ok
        .
      if v-ok = false then do:
        apply "entry":U to f-db-key in frame {&frame-name}.
        return no-apply.
      end.
    end.
  &endif

  /* только если хоть что-то изменилось */
  do transaction
  on error undo, return no-apply
  :
    assign
      cnf.db-num      = f-db-num
      cnf.db-key      = f-db-key
      cnf.param-value = if f-param-code = "tsd-list" then f-param-value-2 else f-param-value
      cnf.beg-date    = f-beg-date
      cnf.end-date    = f-end-date
      cnf.host-code   = v-host-code
      cnf.obj-type    = f-obj-type
      cnf.obj-code    = f-obj-code
      cnf.NotUsed     = false
    .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit d-cnf
ON CHOOSE OF b-quit IN FRAME d-cnf /* Отмена */
DO:
  assign
    ri = ?
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME btn_dwl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_dwl d-cnf
ON CHOOSE OF btn_dwl IN FRAME d-cnf /* Загрузить */
DO:
  def var v-outstr as char no-undo.
  run adm/xlssn.p
    (output v-outstr) no-error.
  if length (v-outstr) > 31000
  then do:
    message "Превышена длинна значения, не возможно загрузить даенные" view-as alert-box information.
  end. 
  else do:
    f-param-value-2 = v-outstr.
    f-param-value-2:screen-value = v-outstr.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-db-key
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-db-key d-cnf
ON RETURN OF f-db-key IN FRAME d-cnf /* Ключ БД */
DO:
  apply "TAB" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-db-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-db-num d-cnf
ON LEAVE OF f-db-num IN FRAME d-cnf /* Номер БД */
DO:

  define variable v-new-key as character no-undo .

  assign
    f-db-num
  .

  if f-db-num <> ? then do:
    run check-db-key in this-procedure
      ( input  f-db-num
      , output v-new-key
      ).

    if v-new-key <> ?
      and v-new-key <> "?":U
    then do:
      assign
        f-db-key = trim( v-new-key )
      .

      display
        f-db-key
        with frame {&frame-name}
      .
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-db-num d-cnf
ON RETURN OF f-db-num IN FRAME d-cnf /* Номер БД */
DO:
  apply "TAB" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-host-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-host-name d-cnf
ON RETURN OF f-host-name IN FRAME d-cnf /* Фирма */
DO:
  apply "TAB" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-host-name d-cnf
ON VALUE-CHANGED OF f-host-name IN FRAME d-cnf /* Фирма */
DO:
  assign
    f-host-name
  .
  assign
    v-host-code = integer(substr(f-host-name, 1, 6))
  .
  if v-obj-host-code <> v-host-code
  and f-obj-code:sensitive in frame {&frame-name}
  then do:
     run clr-ref-object ("").
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-obj-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-obj-code d-cnf
ON LEAVE OF f-obj-code IN FRAME d-cnf
OR RETURN OF f-obj-code IN FRAME d-cnf
DO:
  &if defined (stand-alone) = 0 &then                         /*для работы c базой */
    assign
      f-obj-code
    .
    run disp-obj in this-procedure
      ( input ?
       ,input f-obj-code
       ,input f-obj-type
      ) no-error .
    if error-status :error then do:
      apply "CHOOSE" to b-clients.
      return.
    end.
    if valid-handle (db-hdl)
    then do:
      run chk-host-code in db-hdl (f-obj-type, f-obj-code, output v-obj-host-code).
      if v-obj-host-code = ?   /* не нашли */
      then do:
        run clr-ref-object (return-value).
      end.
      else do:
        if v-host-code <> v-obj-host-code
        then do:
          if v-host-code <> 0
          then do:
              message "Выбранный объект относится к другой фирме " skip
                      "Заменить привязку к фирме?"
              view-as alert-box buttons yes-no update clr-object as logical.
          end.
          if clr-object = true
          or v-host-code = 0
          then do:
            assign
              v-host-code = v-obj-host-code
            .

            find first ub.clients no-lock
              where ub.clients.obj-code = v-obj-host-code
                and ub.clients.obj-type = {&cmp}
              no-error.
            assign
              f-host-name = substitute( "&1  &2", string(ub.clients.obj-code, "999999999"), ub.clients.obj-name )
            .
            display
              f-host-name
              with frame {&frame-name}.
          end.
        end.
      end.
    end.
  &endif
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-obj-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-obj-type d-cnf
ON RETURN OF f-obj-type IN FRAME d-cnf /* Объект */
DO:
  apply "TAB" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-obj-type d-cnf
ON VALUE-CHANGED OF f-obj-type IN FRAME d-cnf /* Объект */
DO:
  &if defined (stand-alone) = 0 &then
    assign
      f-obj-type
    .
    if f-obj-type = ""
    then do:
      assign
        v-types = {&all}
      .
    end.
    else do:
      assign
        v-types = f-obj-type
      .
    end.
    run uf-get in this-procedure
      ( input  {&uf-cli-all-p}
       ,input  v-cntxt-userid
       ,output v-uf-List_
       ,output v-uf-Naim
       ,output v-uf-print-graft
       ,output v-uf-sort-gr
       ,output v-uf-type-price
       ,output v-uf-type-val
      ) no-error.
    if not error-status:error
    then do:
      assign
        entry(1, v-uf-List_, {&delim-par}) = v-types
      .
    end.
    else do:
      assign
        v-uf-List_ = v-types + fill({&delim-par}, 5)
      .
    end.
    run uf-set in this-procedure
      ( input {&uf-cli-all-p}
       ,input v-cntxt-userid
       ,input v-uf-List_
       ,input v-uf-Naim
       ,input v-uf-print-graft
       ,input v-uf-sort-gr
       ,input v-uf-type-price
       ,input v-uf-type-val
      ) no-error.
  &endif
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-param-value
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-param-value d-cnf
ON LEAVE OF f-param-value IN FRAME d-cnf /* Значение */
DO:

  define variable v-tmp-date        as date      no-undo .
  define variable v-tmp-param-value as character no-undo .

  assign
    v-tmp-param-value = f-param-value:screen-value
  .

  if v-tmp-param-value = ? then do:
    /* видимо combo-box в режиме simple при пустой строке выдает значание знак вопроса */
    assign
      v-tmp-param-value = "":U
    .
  end.

  if cnf-struct.data-type = "date":U
    and trim( v-tmp-param-value ) <> "":U
  then do:
    assign
      v-tmp-date = date( v-tmp-param-value ) no-error
    .
    if error-status :error
      or v-tmp-date = ?
    then do:
      message
        "Значение параметра должно быть датой в формате число/месяц/год !" skip
        substitute( "введено значение: &1", v-tmp-param-value ) skip
        substitute( "после преобразования: &1", string( v-tmp-date, "99/99/9999" ) ) skip
        view-as alert-box error .
      apply "entry":U to f-param-value in frame {&frame-name}.
      return no-apply.
    end.
    else do:
      assign
        f-param-value = string( v-tmp-date, "99/99/9999" )
      .
      display
        f-param-value
        with frame {&frame-name}
        .
      if v-tmp-param-value <> f-param-value then do:
        message
          "Значение параметра преобразованно в соответствии с форматом даты число/месяц/год" skip
          substitute( "введено значение: &1", v-tmp-param-value ) skip
          substitute( "после преобразования: &1", f-param-value ) skip
          view-as alert-box information .
      end.
    end.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-param-value d-cnf
ON RETURN OF f-param-value IN FRAME d-cnf /* Значение */
DO:
  apply "TAB" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-param-value-2 d-cnf
ON RETURN OF f-param-value-2 IN FRAME d-cnf /* Значение */
DO:
  apply "TAB" to self.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME t-beg-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-beg-date d-cnf
ON VALUE-CHANGED OF t-beg-date IN FRAME d-cnf /* неограничено */
DO:
  assign
    t-beg-date
  .
  if t-beg-date = true
  then do:
    assign
      f-beg-date = {&beg-unlim-lcns}
    .
    hide f-beg-date in frame {&frame-name}.
  end.
  else do:
    assign
      f-beg-date = ?
    .
    enable f-beg-date with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME t-end-date
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL t-end-date d-cnf
ON VALUE-CHANGED OF t-end-date IN FRAME d-cnf /* неограничено */
DO:
  assign
    t-end-date
  .
  if t-end-date = true
  then do:
    assign
      f-end-date = {&end-unlim-lcns}
    .
    hide f-end-date in frame {&frame-name}.
  end.
  else do:
    assign
      f-end-date = ?
    .
    enable f-end-date with frame {&frame-name}.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-cnf


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */

MAIN-BLOCK:
DO
ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
:

  { gbl/app_help.i }
  { gbl/ed_date.i f-beg-date }
  { gbl/ed_date.i f-end-date }

  define variable v-num-entries as integer   no-undo .
  define variable v-db-key      as character no-undo .

  find first cnf
    where recid( cnf ) = ri
    no-error.
  if not available cnf then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не передана ссылка на параметр!" skip
      view-as alert-box error .
    assign
      ri = ?
    .
    return.
  end.

  &if defined (stand-alone) = 0 &then
    if lookup (cnf.conf-type, {&cnf-type-list-protect}) > 0
    and p-action <> "lkp":U
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Параметр закодирован. Изменение не допускается!" skip
        view-as alert-box error .
      return error.
    end.
  &endif

  /* если есть ошибки, то заполняем значениями из таблицы */
  if cnf.errorexist > 0
  then do:
    run fill-default in cnf-hdl
      ( buffer cnf
      ).
  end.
  if not available cnf
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "После исправления неверных привязок параметр удален, " skip
      "так как дублирует уже существующий параметр" skip
      view-as alert-box error .
    assign
      ri = -1
    .
    return.
  end.

  find first cnf-struct
    where cnf-struct.param-code = cnf.param-code
    no-error.
  if not available cnf-struct
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Невозможно корректировать строку без описания параметра!" skip
      view-as alert-box error .
    assign
      ri = ?
    .
    return.
  end.

  case cnf-struct.param-type:
    when {&cnf-enc} then f-cnf-type = "(конфигурационный)".
    when {&cnf-obl} then f-cnf-type = "(обязательный)".
    when {&cnf-sal} then f-cnf-type = "(кодированный)".
    when "":U       then f-cnf-type = "(необязательный)".
    otherwise            f-cnf-type = "(такого типа не знаю!!!)".
  end.

  assign
    f-db-num      = cnf.db-num
    f-db-key      = cnf.db-key
    f-param-code  = cnf.param-code
    f-param-name  = cnf.param-name
    f-param-ps    = cnf.param-ps
    f-beg-date    = cnf.beg-date
    f-end-date    = cnf.end-date
    v-host-code   = cnf.host-code
  .
  if f-param-code = "tsd-list" 
    then assign f-param-value-2 = cnf.param-value.
    else assign f-param-value = cnf.param-value.
  
  if ( f-db-key = "" or f-db-key = ? )
    and f-db-num <> ?
  then do:
    run check-db-key in this-procedure
      ( input  f-db-num
       ,output v-db-key
      ).
    if v-db-key <> ?
      and v-db-key <> "?":U
    then do:
      assign
        f-db-key = v-db-key
      .
    end.
  end.

  if lookup( cnf-struct.param-type, {&cnf-type-list-protect} ) > 0
  then do:
    assign
      t-beg-date = false
      t-end-date = false
    .
    if cnf.beg-date = {&beg-unlim-lcns}
    or cnf.beg-date = ?
    then do:
      assign
        t-beg-date = true
      .
    end.
    if cnf.end-date = {&end-unlim-lcns}
      or cnf.end-date = ?
    then do:
      assign
        t-end-date = true
      .
    end.
  end.
  else do:
    assign
      t-beg-date = true
      t-end-date = true
    .
  end.

/* определяем список возможных значений параметра:
   Если есть список, то из списка значений,
   иначе если логический, то Да или Нет
   иначе пользователь вводит произвольный текст */

  if trim( cnf-struct.list-value ) <> "":U
  then do:
    assign
      v-num-entries = num-entries( cnf-struct.list-value )
      f-param-value:list-items  = cnf-struct.list-value
      f-param-value:subtype     = "drop-down-list":U
      f-param-value:inner-lines = ( if v-num-entries <= 10 then v-num-entries else 10 )
    .
    if lookup( f-param-value, f-param-value:list-items ) = 0
    then do:
       if f-param-value <> ""
       then do:
         message
           "значение параметра не соответствует списку возможных значений" skip
           "значение заменено на первое из списка возможных." skip
           view-as alert-box error .
       end.
       assign
         f-param-value:screen-value = entry (1, f-param-value:list-items)
       .
    end.
    else do:
      assign
        f-param-value:screen-value = f-param-value
      .
    end.
  end.
  else do:
    if cnf-struct.data-type = "logical":U
    then do:
      assign
        f-param-value:list-items  = "yes,no":U
        f-param-value:subtype     = "drop-down-list":U
        f-param-value:inner-lines = 2
      .
    end.
    else do:
      assign
        f-param-value:screen-value = f-param-value
        f-param-value:subtype      = "simple":U
        f-param-value:inner-lines  = 0
      .
    end.
  end.

  RUN enable_UI.
  
  run prepare-screen .

  if f-obj-code:sensitive in frame {&frame-name} then do:
    assign
      f-obj-type = cnf.obj-type
      f-obj-code = cnf.obj-code
    .
  end.



  apply "value-changed" to t-beg-date in frame {&frame-name}.
  apply "value-changed" to t-end-date in frame {&frame-name}.

  &if defined(stand-alone) > 0 &then
    if lookup( cnf-struct.param-type, {&cnf-type-list-protect} ) > 0
      /* and ( cnf.param-type = {&type-log}
            or cnf.param-type = {&type-int}
          )
          */
    then do:
      enable
        t-beg-date
        t-end-date
        with frame {&frame-name}.
    end.
/*    if f-db-num = ? then do:*/
      assign
        f-db-num:read-only in frame {&frame-name} = false
      .
      enable
        f-db-num
        with frame {&frame-name}.
      display
        f-db-num
        with frame {&frame-name}.
/*    end.*/
    assign
      f-db-key:read-only in frame {&frame-name} = false
    .
    enable
      f-db-key
      with frame {&frame-name}.
    display
      f-db-key
      with frame {&frame-name}.
  &endif

  if p-action = "lkp":U
  then do:
    disable
      b-clients
      b-exit
      f-param-value
      f-param-value-2
      f-beg-date
      t-beg-date
      f-end-date
      t-end-date
      f-obj-type
      f-obj-code
      f-host-name
      with frame {&frame-name}
    .
  end.

  wait-for go of frame {&frame-name}.

end.

RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-db-key d-cnf
PROCEDURE check-db-key :
define input  parameter p-db-num as integer no-undo.
  define output parameter p-db-key as character no-undo.

  define buffer buf_cnf for cnf .

  assign
    p-db-key = ?
  .

  for first buf_cnf no-lock
    where buf_cnf.db-num = p-db-num
      and buf_cnf.db-key <> ?
      and buf_cnf.db-key <> "":U
  on error undo, return error return-value
  :
    assign
      p-db-key = buf_cnf.db-key
    .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clr-ref-object d-cnf
PROCEDURE clr-ref-object :
/*------------------------------------------------------------------------------
  Purpose:     известить пользователя об ошибке и очистить привязку объекта.
------------------------------------------------------------------------------*/
  define input parameter par-mes as character format "x(80)" no-undo.

  define variable clr-object as logical   no-undo .

  if par-mes <> ""
  then do:
    message
      par-mes skip
      " Отменить привязку к объекту?" skip
      view-as alert-box buttons yes-no update clr-object .
  end.
  if clr-object = true
  or par-mes = ""
  then do:
    assign
      f-obj-code = 0
      f-obj-type = ""
      f-obj-name = ""
    .
    display
      f-obj-code
      f-obj-type
      f-obj-name
      with frame {&frame-name}.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-cnf  _DEFAULT-DISABLE
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
  HIDE FRAME d-cnf.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disp-obj d-cnf
PROCEDURE disp-obj :
/*------------------------------------------------------------------------------
  Purpose:     проверить соответствие введенного клиента выбранной фирме
               и показать его если все хорошо
------------------------------------------------------------------------------*/
  define input parameter par-recid    as recid     no-undo.  /* поиск по Recid */
  define input parameter par-obj-code as integer   no-undo.  /* поиск по коду */
  define input parameter par-obj-type as character no-undo.  /* поиск по коду */

  &if defined (stand-alone) = 0 &then                         /*для работы c базой */
    define variable ref-rec as recid no-undo.
    define buffer buf_clients for ub.clients .

    if par-recid <> ? then do:
      find first buf_clients no-lock
        where recid ( buf_clients ) = par-recid
        no-error.
    end.
    else do:
      find buf_clients no-lock
        where buf_clients.obj-type = par-obj-type
          and buf_clients.obj-code = par-obj-code
        no-error .
    end.
    if not available buf_clients then do:
      return error .
    end.

    if buf_clients.obj-type <> {&stock}
      and buf_clients.obj-type <> {&shop}
    then do:
      message substitute( "Привязать параметр можно только к клиенту с типом '&1' или '&2'", {&shop}, {&stock} ) skip
        view-as alert-box information .
      return error .
    end.

    assign
      f-obj-code = buf_clients.obj-code
      f-obj-type = buf_clients.obj-type
      f-obj-name = buf_clients.obj-name
    .
    display
      f-obj-code
      f-obj-type
      f-obj-name
      with frame {&frame-name}
    .
  &endif

  return.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-cnf  _DEFAULT-ENABLE
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
  DISPLAY f-db-num f-db-key f-param-name f-param-ps f-param-value f-beg-date
          t-beg-date f-end-date t-end-date f-obj-type f-obj-code f-host-name
          f-param-code f-cnf-type f-obj-name
      WITH FRAME d-cnf.
  ENABLE b-exit b-quit b-help RECT-1 RECT-2 f-param-name f-param-ps
         f-param-value btn_dwl f-obj-name 
      WITH FRAME d-cnf.
  {&OPEN-BROWSERS-IN-QUERY-d-cnf}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Prepare-screen d-cnf
PROCEDURE Prepare-screen :
/*------------------------------------------------------------------------------
  Purpose:     Подготовить поля ввода в зависимости от типа параметра
------------------------------------------------------------------------------*/

define variable v-ok as logical   no-undo .

/* проверяем необходимость привязок и открываем поля для ввода */

&if defined(stand-alone) = 0 &then

  define buffer buf_sysconf for ub.sysconf .
  define buffer buf_clients for ub.clients .

  if cnf-struct.attach-type = {&cnf-company}
  or cnf-struct.attach-type = {&cnf-object}
  then do:
    enable
      f-host-name
      with frame {&frame-name}
    .
    assign
      v-ok = f-host-name:add-last ( substitute( "&1  Нет привязки", "000000" ) ) in frame {&frame-name}
    .
    for each buf_sysconf no-lock
    on error undo, return error
    :
      find first buf_clients no-lock
        where buf_clients.obj-code = buf_sysconf.host-code
          and buf_clients.obj-type = {&cmp}
        no-error.
      assign
        v-ok = f-host-name:add-last ( substitute( "&1  &2", string(buf_clients.obj-code, "999999999"), buf_clients.obj-name ) ) in frame {&frame-name}
      .

      if v-host-code = buf_sysconf.host-code
      then do:
        assign
          f-host-name = substitute( "&1  &2", string(buf_clients.obj-code, "999999999"), buf_clients.obj-name )
        .
      end.
    end.
    if f-host-name = ""
    then do:
      assign
        f-host-name = substitute( "&1  Нет привязки", "000000":U )
      .
    end.
  end.

  if cnf-struct.attach-type = {&cnf-object}
  then do:
    enable
      f-obj-code
      f-obj-type
      b-clients
    with frame {&frame-name}.
    assign
      f-obj-type:list-items = {&stock} + ",":U + {&shop}
    .
    if f-obj-code > 0
    then do:
      run chk-host-code in db-hdl (input f-obj-type, input f-obj-code, output v-obj-host-code).
      if v-obj-host-code <> v-host-code
      then do:
        run clr-ref-object ("Привязка к объекту противоречит привязке к фирме").
      end.
    end.

    run disp-obj in this-procedure
      ( input ?
       ,input f-obj-code
       ,input f-obj-type
      ) no-error .
    if error-status :error then do:
      /* просто проигнорируем */
    end.
    apply "value-changed" to f-obj-type in frame {&frame-name}.

  end.
  else do:
    if f-obj-type <> ""
    then do:
      run clr-ref-object ("Привязка к объекту не предусмотрена").
    end.
  end.
&endif

if f-param-code = "tsd-list" and p-action <> "lkp":U
then do:
  enable
    btn_dwl
    f-param-value-2
    with frame {&frame-name}.
end.
else do:
  hide
    btn_dwl
    in frame {&frame-name}.
end.

if f-param-code = "tsd-list"
then do:
  enable
    f-param-value-2
    with frame {&frame-name}.
  f-param-value-2:screen-value = f-param-value-2.  
  hide
    f-param-value
    in frame {&frame-name}.
end.
else do:
  hide
    f-param-value-2
    in frame {&frame-name}.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME