&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка или удаление пометки выгруженности документов для инкрементальной выгрузки.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Установка или удаление пометки выгруженности документов для инкрементальной выгрузки.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/temphost.i }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ gbl/clntattr.i }
{ bge/bge-xml.i  }

&scop log-file "setincrd.log"

define stream sout.

define variable v-obj-list          as character    no-undo.
define variable v-host-code         as integer      no-undo.
define variable v-host-name         as character    no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.

define temp-table temp_obj-list no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique obj-type obj-code
.

define variable v-obj-type   like ub.clients.obj-type no-undo .
define variable v-obj-code   like ub.clients.obj-code no-undo .
define variable v-obj-name   like ub.clients.obj-name no-undo .
define variable v-table-name as character             no-undo .
define variable v-doc-code   as character             no-undo .

define frame info
  v-obj-name    format "X(20)"        label "Объект"  skip
  v-table-name  format "X(30)"        label "Таблица" skip
  v-doc-code    format "X(14)"        label "Номер документа"
with view-as dialog-box side-labels three-d title "Обработка документов":U .


&scop display-info ~
  do with frame info ~
  : ~
    assign ~
      v-obj-name :screen-value    = string( ~{&obj-name~}   , v-obj-name :format    ) ~
      v-table-name :screen-value  = string( ~{&table-name~} , v-table-name :format  ) ~
      v-doc-code :screen-value    = string( ~{&doc-code~}   , v-doc-code :format    ) ~
    . ~
  end. ~
  process events.



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 Btn_OK bt-set-incr bt-clear-incr ~
b-help tg-shift date_from date_to fi-shift-num rs-1 bt-sel-obj
&Scoped-Define DISPLAYED-OBJECTS tg-shift date_from date_to fi-shift-num ~
ed-object rs-1

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON bt-clear-incr
     LABEL "Снять"
     SIZE 12 BY 1 TOOLTIP "Снять пометку выгруженности документов".

DEFINE BUTTON bt-sel-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "..."
     SIZE 3.63 BY 1.04.

DEFINE BUTTON bt-set-incr
     LABEL "Установить"
     SIZE 12 BY 1 TOOLTIP "Установить пометку выгруженности документов".

DEFINE BUTTON Btn_OK DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON BUTTON-1
     LABEL "test"
     SIZE 7.5 BY 1.13.

DEFINE VARIABLE ed-object AS CHARACTER
     VIEW-AS EDITOR NO-BOX
     SIZE 35.63 BY 3.38
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE date_from AS DATE FORMAT "99/99/9999":U
     LABEL "Дата с"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date_to AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE fi-shift-num AS INTEGER FORMAT ">9":U INITIAL 0
     LABEL "Порядок смены"
     VIEW-AS FILL-IN
     SIZE 4.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-1 AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "глобально", 1,
"по фирме", 2,
"по объектам", 3
     SIZE 13.75 BY 3.25 NO-UNDO.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 55.38 BY 4.38.

DEFINE VARIABLE tg-shift AS LOGICAL INITIAL no
     LABEL "По смене"
     VIEW-AS TOGGLE-BOX
     SIZE 11.13 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 1.5
     bt-set-incr AT ROW 1.25 COL 11.5
     bt-clear-incr AT ROW 1.25 COL 23.5
     BUTTON-1 AT ROW 1.25 COL 37
     b-help AT ROW 1.25 COL 47
     tg-shift AT ROW 2.75 COL 2
     date_from AT ROW 4 COL 12 COLON-ALIGNED
     date_to AT ROW 4 COL 29 COLON-ALIGNED
     fi-shift-num AT ROW 4 COL 38.5 COLON-ALIGNED
     ed-object AT ROW 6.04 COL 20.88 NO-LABEL
     rs-1 AT ROW 6.13 COL 3.13 NO-LABEL
     bt-sel-obj AT ROW 8.29 COL 17.13
     RECT-1 AT ROW 5.5 COL 2
     SPACE(0.86) SKIP(0.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Установка инкрементальной выгрузки документов".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON BUTTON-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       BUTTON-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR ed-object IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Установка инкрементальной выгрузки документов */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-clear-incr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-clear-incr Dialog-Frame
ON CHOOSE OF bt-clear-incr IN FRAME Dialog-Frame /* Снять */
DO:
    ASSIGN
        date_from
        date_to
        rs-1
    .
    run test-input in this-procedure .
    { gbl/working.i }
    run fill-temphost in this-procedure (
          input rs-1
        , input ed-object :screen-value
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка создания списка объектов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    view frame info.
    run write-log in this-procedure ( input substitute( "Снятие даты инкрементальной выгрузки &1 &2."
                                                      , if tg-shift = yes then "по сменам" else "по документам"
                                                      , if tg-shift = yes then string(date_from , "99/99/9999") + ' ' + string(fi-shift-num)
                                                                          else 'c ' + string(date_from , "99/99/9999") + ' по ' + string(date_to , "99/99/9999")
                                                      )
                                    ).
    for each temp-obj
    :
        run clear-incr in this-procedure (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input tg-shift
            , input date_from
            , input date_to
            , input fi-shift-num
        ) no-error.
        if error-status :error
        then do:
          run write-log in this-procedure ( input substitute( "&1 &2 &3&4Ошибка снятия даты инкрементальной выгрузки&4Объект: &5 &6&4&7&8&9"
                                                            , vss-workfile
                                                            , vss-revision
                                                            , vss-description
                                                            , {&new-line}
                                                            , temp-obj.obj-type
                                                            , temp-obj.obj-code
                                                            , return-value
                                                            , trim(error-status :get-message(1))
                                                            , trim(error-status :get-message(2))
                                                            )
                                          ).
            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка очистки даты инкрементальной выгрузки"
                skip "Объект:" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
        end.
    end.
    run write-log-nl in this-procedure .
    hide frame info.
    { gbl/stopwork.i }
    if tg-shift = yes
    then do:
        message
                 "Для выбранных объектов"
            skip "дата и номер смены выгрузки "
            skip "установлены по смене,"
            skip "предыдущей выбранной."
        view-as alert-box information.
    end.        /* if tg-shift = yes */
    else do:
        message
            "Дата инкрементальной выгрузки"
            skip "снята"
            skip "для выбранных объектов"
            skip "в диапазоне дат документов"
            skip date_from "-" date_to
        view-as alert-box information.
    end.        /* NOT ( if tg-shift = yes ) */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-sel-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-sel-obj Dialog-Frame
ON CHOOSE OF bt-sel-obj IN FRAME Dialog-Frame /* ... */
DO:
    define variable v-obj-list           as character no-undo .
    define variable v-exclude-obj-list   as character no-undo .

    define variable v-object-available   as logical   no-undo .

    assign
        rs-1 :screen-value  = "3"
    .
    { gbl/uobjclr.i  }

    { gbl/usobjava.i
      v-cntxt-db-num
      {&action-head-code-main}
      v-cntxt-userid
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-object-available
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры gbl/usobjava.i" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply .
    end.

    if v-object-available = true
    then do:
      { gbl/uobjapnd.i
        v-cntxt-obj-type
        v-cntxt-obj-code
      }
    end.

    define variable v-user-select as logical   no-undo .
    { gbl/uobjsman.i
      parparentproc
      v-cntxt-db-num
      v-cntxt-userid
      v-cntxt-host-code-obj
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-user-select
    }
    if v-user-select <> true
    then do:
      message
        "Объект не выбран"
        view-as alert-box information .
      return no-apply .
    end.
    define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

    for each temp_obj-list:
        delete temp_obj-list.
    end.

    for each buf_userobjs_temp-user-obj
    on error undo, return no-apply
    :
      find first temp_obj-list where
              temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
          and temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
      if not available temp_obj-list then do:
      create temp_obj-list .
      assign
        temp_obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
        temp_obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code
      .
    end.
    end.
    assign
        v-obj-list = ""
    .
    for each temp_obj-list
    :
        assign v-obj-list = v-obj-list + (if v-obj-list <> "" then ", " else "" )
                                    + temp_obj-list.obj-type + string( temp_obj-list.obj-code ).
    end.
    assign
        ed-object :screen-value = v-obj-list
    .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-set-incr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-set-incr Dialog-Frame
ON CHOOSE OF bt-set-incr IN FRAME Dialog-Frame /* Установить */
DO:
    ASSIGN
        date_from
        date_to
        fi-shift-num
        rs-1
    .
    run test-input in this-procedure .
    { gbl/working.i }
    run fill-temphost in this-procedure (
          input rs-1
        , input ed-object :screen-value
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip "Ошибка создания списка объектов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    view frame info.
    run write-log in this-procedure ( input substitute( "Установка даты инкрементальной выгрузки &1 &2."
                                                      , if tg-shift = yes then "по сменам" else "по документам"
                                                      , if tg-shift = yes then string(date_from , "99/99/9999") + ' ' + string(fi-shift-num)
                                                                          else 'c ' + string(date_from , "99/99/9999") + ' по ' + string(date_to , "99/99/9999")
                                                      )
                                    ).
    for each temp-obj
    :
        run set-incr in this-procedure (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input tg-shift
            , input date_from
            , input date_to
            , input fi-shift-num
            , input v-today
        ) no-error.
        if error-status :error
        then do:
          run write-log in this-procedure ( input substitute( "&1 &2 &3&4Ошибка установки даты инкрементальной выгрузки&4Объект: &5 &6&4&7&8&9"
                                                            , vss-workfile
                                                            , vss-revision
                                                            , vss-description
                                                            , {&new-line}
                                                            , temp-obj.obj-type
                                                            , temp-obj.obj-code
                                                            , return-value
                                                            , trim(error-status :get-message(1))
                                                            , trim(error-status :get-message(2))
                                                            )
                                          ).

            message
                     vss-workfile vss-revision vss-description
                skip "Ошибка установки даты инкрементальной выгрузки"
                skip "Объект:" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                     trim(error-status :get-message(2))
                     trim(error-status :get-message(3))
            view-as alert-box error.
        end.
    end.
    run write-log-nl in this-procedure .
    hide frame info.
    { gbl/stopwork.i }
    if tg-shift = yes
    then do:
        message
            "Для выбранных объектов установлены:"
            skip (1)
            skip "Дата последней выгруженной смены: " date_from
            skip "Порядок последней выгруженной смены:" fi-shift-num
        view-as alert-box information.
    end.        /* if tg-shift = yes */
    else do:
        message
            "Дата инкрементальной выгрузки"
            skip "установлена: " v-today
            skip "для выбранных объектов"
            skip "в диапазоне дат документов"
            skip date_from "-" date_to
        view-as alert-box information.
    end.        /* NOT ( if tg-shift = yes ) */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Выход */
DO:
    APPLY "GO" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 Dialog-Frame
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame /* test */
DO:
    DEFINE VARIABLE v-shift-date    AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE v-shift-num     AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE v-par-type      AS CHARACTER  NO-UNDO.
    run fill-temphost in this-procedure (
        input rs-1
      , input ed-object :screen-value
    ) no-error.
    if error-status :error
    then do:
      message
               vss-workfile vss-revision vss-description
          skip "Ошибка создания списка объектов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
      view-as alert-box error.
      undo, return no-apply .
    end.
    for each temp-obj
    :
        run clntattr-value in this-procedure (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input {&attr-bge-incr-last-shift-date}
            , OUTPUT v-shift-date
            , OUTPUT v-par-type
        ).
        run clntattr-value in this-procedure (
              input temp-obj.obj-type
            , input temp-obj.obj-code
            , input {&attr-bge-incr-last-shift-num}
            , OUTPUT v-shift-num
            , OUTPUT v-par-type
        ).
        message
            "Объект:" temp-obj.obj-type temp-obj.obj-code
            SKIP "Смена:" v-shift-date v-shift-num
        view-as alert-box.
    END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_from
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_from Dialog-Frame
ON RETURN OF date_from IN FRAME Dialog-Frame /* Дата с */
DO:
    APPLY "ENTRY" TO date_to IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME date_to
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL date_to Dialog-Frame
ON RETURN OF date_to IN FRAME Dialog-Frame /* по */
DO:
    APPLY "ENTRY" TO btn_OK IN FRAME {&FRAME-NAME}.
    RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-1 Dialog-Frame
ON VALUE-CHANGED OF rs-1 IN FRAME Dialog-Frame
DO:
run object-select in this-procedure no-error .
if error-status :error
then do:
    undo, return no-apply.
end.
assign
    rs-1
.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME tg-shift
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL tg-shift Dialog-Frame
ON VALUE-CHANGED OF tg-shift IN FRAME Dialog-Frame /* По смене */
DO:
    assign
        tg-shift
    .
    run manage-tg-shift in this-procedure.
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
{ gbl/ed_date.i date_from }
{ gbl/ed_date.i date_to   }

run cur-time in this-procedure ( output v-today
                               , output v-time
                               ).
ASSIGN
    date_from = v-today
    date_to   = v-today
.

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get }

    run get-host-name in this-procedure ( output v-host-name ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка при определении имени фирмы"
          skip "Код фирмы:" v-cntxt-host-code-obj
          skip "Имя фирмы будет отображаться как '" + {&cmp} + string( v-host-code ) + "'"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box warning.
        assign
            v-host-name = {&cmp} + string( v-cntxt-host-code-obj )
        .
    end.
  RUN enable_UI.
  run init-fields in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clear-incr Dialog-Frame
PROCEDURE clear-incr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-obj-type   as character    no-undo.
define input parameter p-obj-code   as integer      no-undo.
define input parameter p-by-shift   as logical          no-undo.
define input parameter p-date-from  as date         no-undo.
define input parameter p-date-to    as date         no-undo.
define input parameter p-shift-num  as integer          no-undo.

    define variable v-shift-obj-on      as logical      no-undo.
    define variable v-last-shift-date   as date         no-undo.
    define variable v-last-shift-num    as integer      no-undo.
    define variable v-obj-name-str      as character    no-undo .
    define variable v-table-name-str    as character    no-undo .

    define buffer buf_c-trn-doc     for ub.c-trn-doc.
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_shift-obj     for ub.shift-obj.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_ord-doc       for ub.ord-doc.


do
for buf_c-trn-doc
  , buf_trn-doc
  , buf_shift-obj
  , buf_price-doc
  , buf_ord-doc
on error undo, return error
:
&scop obj-name v-obj-name-str
&scop table-name v-table-name-str
&scop doc-code ""

    assign
      v-obj-name-str = p-obj-type + " " + trim(string(p-obj-code , ">>>>>>>>9"))
    .
    if p-by-shift = yes
    then do:
        {&display-info}
        { gbl/objat.i
            p-obj-type
            p-obj-code
            "'shift-on=request'"
            v-shift-obj-on
            no-error
        }
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при определении типа сменный/не-сменный для объекта"
                skip "Объект" temp-obj.obj-type temp-obj.obj-code
                skip "Атрибут" 'shift-on=request':U
                skip error-status :get-message(1)
                skip return-value
            view-as alert-box error .
            undo, return error .
        end.
        if v-shift-obj-on = yes
        then do:
            find last buf_shift-obj no-lock
                where buf_shift-obj.obj-type    = p-obj-type
                  and buf_shift-obj.obj-code    = p-obj-code
                  and buf_shift-obj.shift-date  = p-date-from
                  and buf_shift-obj.shift-num   < p-shift-num
            use-index pi
            no-error.
            if not available buf_shift-obj
            then do:
                find last buf_shift-obj no-lock
                    where buf_shift-obj.obj-type    = p-obj-type
                      and buf_shift-obj.obj-code    = p-obj-code
                      and buf_shift-obj.shift-date  < p-date-from
                use-index pi
                no-error.
            end.
            if not available buf_shift-obj
            then do:
                assign
                    v-last-shift-date = p-date-from - 1
                    v-last-shift-num  = 0
                .
            end.
            else do:
                assign
                    v-last-shift-date = buf_shift-obj.shift-date
                    v-last-shift-num  = buf_shift-obj.shift-num
                .
            end.
            run clntattr-write in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input {&attr-bge-incr-last-shift-date}
                , input string( v-last-shift-date )
            ).
            run clntattr-write in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input {&attr-bge-incr-last-shift-num}
                , input string( v-last-shift-num )
            ).
            run write-log in this-procedure ( input substitute( "Для объекта &1 &2 последняя выгруженная смена &3 порядок &4."
                                                              , p-obj-type
                                                              , p-obj-code
                                                              , v-last-shift-date
                                                              , v-last-shift-num
                                                              )
                                            ).
        end.
    end.        /* if p-by-shift = yes */
    else do:
        assign
          v-table-name-str  = "trn-doc"
        .
&scop doc-code buf_trn-doc.doc-code
        for each buf_trn-doc no-lock
           where buf_trn-doc.obj-type  = p-obj-type
             and buf_trn-doc.obj-code  = p-obj-code
             and buf_trn-doc.status_   = {&fact}
             and buf_trn-doc.fact-date >= p-date-from
             and buf_trn-doc.fact-date <= p-date-to
        on error undo, return error
        :
            {&display-info}
            run bge/clrbgedt.p ( input {&table_trn-doc}
                               , input buf_trn-doc.doc-code
                               ).
        end.        /* for each buf_trn-doc */
        assign
          v-table-name-str = "c-trn-doc"
        .
&scop doc-code buf_c-trn-doc.doc-code

        for each buf_c-trn-doc no-lock
           where buf_c-trn-doc.obj-type  = p-obj-type
             and buf_c-trn-doc.obj-code  = p-obj-code
        on error undo, return error
        :
            if  buf_c-trn-doc.fact-date >= p-date-from
            and buf_c-trn-doc.fact-date <= p-date-to
            then do:
                {&display-info}
                run bge/clrbgedt.p ( input {&table_c-trn-doc}
                                   , input buf_c-trn-doc.doc-code
                                   ).
            end.
        end.        /* for each buf_c-trn-doc */

        assign
          v-table-name-str = "price-doc"
        .

&scop doc-code buf_price-doc.doc-num

        for each buf_price-doc no-lock
           where buf_price-doc.obj-type  = p-obj-type
             and buf_price-doc.obj-code  = p-obj-code
             and buf_price-doc.status_   = {&act-overvalue}
             and buf_price-doc.fact-date >= p-date-from
             and buf_price-doc.fact-date <= p-date-to
        on error undo, return error
        :
            {&display-info}
            run bge/clrbgedt.p ( input {&table_price-doc}
                               , input buf_price-doc.doc-num
                               ).
        end.        /* for each buf_trn-doc */

        assign
          v-table-name-str = "ord-doc"
        .

&scop doc-code buf_ord-doc.doc-code

        for each buf_ord-doc no-lock
          where buf_ord-doc.obj-type    = p-obj-type
            and buf_ord-doc.obj-code    = p-obj-code
            and buf_ord-doc.status_     = {&fact}
            and buf_ord-doc.fact-date  >= p-date-from
            and buf_ord-doc.fact-date  <= p-date-to
        on error undo, return error
        :
            {&display-info}
            run bge/clrbgedt.p ( input {&table_ord-doc}
                               , input buf_ord-doc.doc-code
                               ).
        end. /* for each buf_ord-doc no-lock */
        run write-log in this-procedure ( input substitute( "Снятие даты инкрементальной выгрузки по объекту &1 &2 завершено ."
                                                          , p-obj-type
                                                          , p-obj-code
                                                          )
                                        ).
    end.        /* NOT ( if p-by-shift = yes ) */
end.
END PROCEDURE. /* clear-incr */

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
  DISPLAY tg-shift date_from date_to fi-shift-num ed-object rs-1
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 Btn_OK bt-set-incr bt-clear-incr b-help tg-shift date_from
         date_to fi-shift-num rs-1 bt-sel-obj
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temphost Dialog-Frame
PROCEDURE fill-temphost :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-range      as integer      no-undo.
define input parameter p-obj-list   as character    no-undo.

    define variable v-log-string    as character      no-undo.
    define variable v-obj-counter   as integer        no-undo.

    empty temp-table temp-obj.
    RUN init-temphost.
    assign
        v-log-string = ", по всем фирмам"
    .
    case p-range:
    when 2      /* Экспорт по текущей фирме */
    then do:
        for each temp-obj
        where temp-obj.host-code <> v-cntxt-host-code-obj
        :
            delete temp-obj.
        end.
        assign
            v-log-string = ", по фирме (код фирмы " + string( v-cntxt-host-code-obj ) + ")"
        .
    end.
    when 3      /* Экспорт по списку объектов */
    then do:
        for each temp-obj
        :
            delete temp-obj.
        end.
        do v-obj-counter = 1 to num-entries ( p-obj-list )
        :
            create temp-obj.
            assign
                temp-obj.obj-type = substring( trim( entry( v-obj-counter, p-obj-list ) ), 1, 3 )
                temp-obj.obj-code = integer( substring( trim( entry( v-obj-counter, p-obj-list ) ), 4 ) )
            no-error .
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Ошибка чтения списка объектов"
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            { gbl/hostcode.i temp-obj.obj-type temp-obj.obj-code temp-obj.host-code no-error }
            if error-status :error
            then do:
                message
                vss-workfile vss-revision vss-description
                skip "Не найдена фирма для объекта" temp-obj.obj-type temp-obj.obj-code
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
        end.
        assign
            v-log-string = ", по объектам: " + p-obj-list
        .
    end.
    end case.
end.
END PROCEDURE. /* fill-temphost */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-host-name Dialog-Frame
PROCEDURE get-host-name :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-host-name as character    no-undo.

define buffer buf_clients   for ub.clients.

    find first buf_clients no-lock
         where buf_clients.obj-type = {&cmp}
           and buf_clients.obj-code = v-cntxt-host-code-obj
    no-error.
    if not available buf_clients
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Не удалось найти текущую фирму"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    else do:
        assign
            p-host-name = buf_clients.obj-name
        .
    end.
end.
END PROCEDURE. /* get-host-name */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define variable v-oper-num     as integer           no-undo.

    run bge-xml-read-config in this-procedure ( input ?
                                              , input ?
                                              ).
    assign
        rs-1 :screen-value in frame dialog-frame = "2"
        ed-object :screen-value in frame Dialog-frame = {&cmp} + string( v-host-code ) + " " + v-host-name
    .
    assign
      rs-1
      tg-shift = v-bge-xml-shift-mode
    .
    display
      tg-shift
    with frame {&frame-name}.
    run manage-tg-shift in this-procedure .
    if v-bge-xml-shift-mode = yes
    then do:
      message
        "Внимание!" skip
        "Параметр bgeshift имеет значение distinct."  skip
        "Выгрузка объектов производится посменно."
      view-as alert-box information.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE manage-tg-shift Dialog-Frame
PROCEDURE manage-tg-shift :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
with frame {&frame-name}
on error undo, return error
:
    if tg-shift = yes
    then do:
        assign
            date_from :label = "Дата смены"
        .
        hide
            date_to
        .
        view
            fi-shift-num
        .
    end.
    else do:
        assign
            date_from :label = "Дата с"
        .
        hide
            fi-shift-num
        .
        view
            date_to
        .
    end.
end.
END PROCEDURE. /* manage-tg-shift */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE object-select Dialog-Frame
PROCEDURE object-select :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

case rs-1 :screen-value in frame Dialog-frame
:
    when "1"
    then do:
        assign
            ed-object :screen-value = ""
        .
    end.
    when "2"
    then do:
        assign
            ed-object :screen-value = v-host-name
        .
    end.
    when "3"
    then do:
        for each temp_obj-list
        :
            delete temp_obj-list.
        end.
        create temp_obj-list.
        assign
            temp_obj-list.obj-type = v-cntxt-obj-type
            temp_obj-list.obj-code = v-cntxt-obj-code
            ed-object :screen-value = v-cntxt-obj-type + string( v-cntxt-obj-code )
        .
    end.
end case.

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-incr Dialog-Frame
PROCEDURE set-incr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-obj-type   as character        no-undo.
define input parameter p-obj-code   as integer          no-undo.
define input parameter p-by-shift   as logical          no-undo.
define input parameter p-date-from  as date             no-undo.
define input parameter p-date-to    as date             no-undo.
define input parameter p-shift-num  as integer          no-undo.
define input parameter p-set-date   as date             no-undo.

    define variable v-shift-obj-on    as logical      no-undo.
    define variable v-obj-name-str      as character    no-undo .
    define variable v-table-name-str    as character    no-undo .


    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_c-trn-doc     for ub.c-trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_ord-doc       for ub.ord-doc.
do
for buf_trn-doc
  , buf_c-trn-doc
  , buf_price-doc
  , buf_ord-doc
on error undo, return error
:
&scop obj-name v-obj-name-str
&scop table-name v-table-name-str
&scop doc-code ""
    assign
      v-obj-name-str = p-obj-type + " " + trim(string(p-obj-code , ">>>>>>>>9"))
    .
    if p-by-shift = yes
    then do:
        {&display-info}
        { gbl/objat.i
            p-obj-type
            p-obj-code
            "'shift-on=request'"
            v-shift-obj-on
            no-error
        }
        if error-status :error
        then do:
            message
                vss-workfile vss-revision vss-description
                skip "Ошибка при определении типа сменный/не-сменный для объекта"
                skip "Объект" temp-obj.obj-type temp-obj.obj-code
                skip "Атрибут" 'shift-on=request':U
                skip error-status :get-message(1)
                skip return-value
            view-as alert-box error .
            undo, return error .
        end.
        if v-shift-obj-on = yes
        then do:
            run clntattr-write in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input {&attr-bge-incr-last-shift-date}
                , input string( p-date-from )
            ).
            run clntattr-write in this-procedure (
                  input p-obj-type
                , input p-obj-code
                , input {&attr-bge-incr-last-shift-num}
                , input string( p-shift-num )
            ).
            run write-log in this-procedure ( input substitute( "Для объекта &1 &2 последняя выгруженная смена &3 порядок &4."
                                                              , p-obj-type
                                                              , p-obj-code
                                                              , p-date-from
                                                              , p-shift-num
                                                              )
                                            ).
        end.
    end.        /* if p-by-shift = yes */
    else do:
        assign
          v-table-name-str  = "trn-doc"
        .
&scop doc-code buf_trn-doc.doc-code

        for each buf_trn-doc no-lock
           where buf_trn-doc.obj-type  = p-obj-type
             and buf_trn-doc.obj-code  = p-obj-code
             and buf_trn-doc.status_   = {&fact}
             and buf_trn-doc.fact-date >= p-date-from
             and buf_trn-doc.fact-date <= p-date-to
        on error undo, return error
        :
            {&display-info}
            run bge/setbgedt.p ( input {&table_trn-doc}
                               , input buf_trn-doc.doc-code
                               , input p-set-date
                               ).
        end.        /* for each buf_trn-doc */

        assign
          v-table-name-str = "c-trn-doc"
        .
&scop doc-code buf_c-trn-doc.doc-code

        for each buf_c-trn-doc no-lock
           where buf_c-trn-doc.obj-type  = p-obj-type
             and buf_c-trn-doc.obj-code  = p-obj-code
        on error undo, return error
        :
            if  buf_c-trn-doc.fact-date >= p-date-from
            and buf_c-trn-doc.fact-date <= p-date-to
            then do:
                {&display-info}
                run bge/setbgedt.p ( input {&table_c-trn-doc}
                                   , input buf_c-trn-doc.doc-code
                                   , input p-set-date
                                   ).
            end.
        end.        /* for each buf_c-trn-doc */


        assign
          v-table-name-str = "price-doc"
        .
&scop doc-code buf_price-doc.doc-num

        for each buf_price-doc no-lock
           where buf_price-doc.obj-type  = p-obj-type
             and buf_price-doc.obj-code  = p-obj-code
             and buf_price-doc.status_   = {&act-overvalue}
             and buf_price-doc.fact-date >= p-date-from
             and buf_price-doc.fact-date <= p-date-to
        on error undo, return error
        :
            {&display-info}
            run bge/setbgedt.p ( input {&table_price-doc}
                               , input buf_price-doc.doc-num
                               , input p-set-date
                               ).
        end.        /* for each buf_c-trn-doc */

        assign
          v-table-name-str = "ord-doc"
        .
&scop doc-code buf_ord-doc.doc-code

        for each buf_ord-doc no-lock
          where buf_ord-doc.obj-type  = p-obj-type
            and buf_ord-doc.obj-code  = p-obj-code
            and buf_ord-doc.status_   = {&fact}
            and buf_ord-doc.fact-date >= p-date-from
            and buf_ord-doc.fact-date <= p-date-to
        on error undo, return error
        :
            {&display-info}
            run bge/setbgedt.p ( input {&table_ord-doc}
                               , input buf_ord-doc.doc-code
                               , input p-set-date
                               ).
        end. /* for each buf_ord-doc no-lock  */
        run write-log in this-procedure ( input substitute( "Установка даты инкрементальной выгрузки по объекту &1 &2 завершена ."
                                                          , p-obj-type
                                                          , p-obj-code
                                                          )
                                        ).
    end.        /* NOT ( if p-by-shift = yes ) */
end.
END PROCEDURE. /* set-incr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE test-input Dialog-Frame
PROCEDURE test-input :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    if date_from > date_to
    then do:
        message
            "Даты интервала заданы неверно. "
            skip " Нижняя дата интервала должна быть меньше верхней."
            skip(1) "Задайте интервал дат правильно или отмените экспорт."
        view-as alert-box information.
        apply "entry" to date_from in frame {&frame-name} .
        undo, return error.
    end.
end.
END PROCEDURE. /* test-input */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-incr-dates Dialog-Frame
PROCEDURE write-incr-dates :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_clients for ub.clients.
do
on error undo, return error return-value
:

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log Dialog-Frame
PROCEDURE write-log :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter p-message as character no-undo .

  define variable v-today             as date         no-undo.
  define variable v-time              as integer      no-undo.

do
on error undo, return error return-value
:
  run cur-time in this-procedure ( output v-today
                                 , output v-time
                                 ).

  output stream sout to value({&log-file}) append.
  put stream sout unformatted substitute("&1 &2 &3&4"
                                        , string(v-today , "99/99/9999")
                                        , string(v-time, "HH:MM:SS")
                                        , p-message
                                        , {&new-line}
                                        ).
  output stream sout close.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-log-nl Dialog-Frame
PROCEDURE write-log-nl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

do
on error undo, return error return-value
:

  output stream sout to value({&log-file}) append.
  put stream sout unformatted {&new-line} .
  output stream sout close.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
