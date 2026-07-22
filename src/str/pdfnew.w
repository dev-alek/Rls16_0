&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
DEFINE BUFFER buf_price-doc FOR ub.price-doc.
DEFINE BUFFER buf_price-doc-forming FOR ub.price-doc-forming.
DEFINE NEW SHARED BUFFER buf_price-list-type FOR ub.price-list-type.



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список новых  ДНЦ по Объекту по главному ПЛ (для ПЕРЕОЦЕНОК)

Автор: Чернова Светлана Александровна
Дата создания: 11/10/05
Author: Svetlana Chernova
Creation date: 11/10/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter parParentProc as handle no-undo .
define input  parameter p-mode  as character no-undo . /* all ; pl-type  */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-plt-id as int no-undo .
define input  parameter p-plt-db-num as int no-undo .
define input  parameter p-bttns as character no-undo .
define input-output parameter  p-rec-list as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Список новых  ДНЦ по Объекту по главному ПЛ (для ПЕРЕОЦЕНОК)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/waitfram.i }
{ ref/xobjgrp.i  }
{ str/dfpl-ad.i  }
{ ref/grpobj.i   }
{ ref/gdsoattr.i }

/* Local Variable Definitions ---                                       */

define variable v-rec-list-cli as character no-undo .
define variable g-log          as logical   no-undo .
define variable br-handle      as handle no-undo.
define variable buffer-handle  as handle no-undo.
define variable next-prev      as logical no-undo .
define variable v-rec-list     as character no-undo .
define variable ref-rec        as recid no-undo.
define variable loc_gop-db-num as integer no-undo.
define variable loc_gop-id     as integer no-undo.
define variable var-paket      as logical   no-undo init false .
function mark-string returns character
  ( buffer loc-table for ub.price-doc-forming, input mark-list as character  ) :
  return ( if lookup( string( recid( loc-table ) ), mark-list ) > 0 then "*" else "":U ).
end function.

function stts-string returns character
  ( buffer loc-table for ub.price-doc-forming   ) :
 case loc-table.stts :
    when 0 then return {&g___new} .
    when 1 then return {&deleted-status} .
    when 3 then return {&fact} .
 end case.
end function.

function activ-pr returns character
  ( buffer loc-table for ub.price-doc-forming  ) :

define buffer buf_price-all for ub.price-all  .
define buffer buf2_price-all for ub.price-all  .

  find first buf_price-all no-lock where
             buf_price-all.pdf-db = loc-table.pdf-db  and
             buf_price-all.pdf-id = loc-table.pdf-id  and
             buf_price-all.plt-db-num = loc-table.plt-db-num and
             buf_price-all.plt-id     = loc-table.plt-id and
             buf_price-all.status_    = {&act-overvalue}
             no-error .
   if available buf_price-all then do:
            find first buf2_price-all no-lock where
                      buf2_price-all.pdf-db = loc-table.pdf-db  and
                      buf2_price-all.pdf-id = loc-table.pdf-id  and
                      buf2_price-all.plt-db-num = loc-table.plt-db-num and
                      buf2_price-all.plt-id     = loc-table.plt-id and
                      buf2_price-all.status_    <> {&act-overvalue}
                      no-error .
             if available buf2_price-all then return "не все" .
             else return "все +" .
      end.

   else do: /*  нет */
      return "".
   end.
end function.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-1grp

/* External Tables                                                      */
&Scoped-define EXTERNAL-TABLES buf_price-list-type
&Scoped-define FIRST-EXTERNAL-TABLE buf_price-list-type


/* Need to scope the external tables to this procedure                  */
DEFINE QUERY external_tables FOR buf_price-list-type.
/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES buf_price-doc-forming buf_price-list-type ~
x_grp-obj-price

/* Definitions for BROWSE BROWSE-1grp                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-1grp mark-string ( buffer buf_price-doc-forming, p-rec-list ) stts-string ( buffer buf_price-doc-forming ) buf_price-doc-forming.pdf-id buf_price-doc-forming.sys-date buf_price-doc-forming.sys-time-chr buf_price-doc-forming.name buf_price-list-type.plt-id buf_price-list-type.main buf_price-doc-forming.db-num-chg buf_price-doc-forming.pdf-db buf_price-list-type.plt-db-num buf_price-doc-forming.out-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-1grp buf_price-doc-forming.name
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-1grp buf_price-doc-forming
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-1grp buf_price-doc-forming
&Scoped-define SELF-NAME BROWSE-1grp
&Scoped-define QUERY-STRING-BROWSE-1grp FOR     EACH buf_price-doc-forming WHERE        buf_price-doc-forming.stts = 0  , ~
           FIRST buf_price-list-type  WHERE           buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id AND           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num , ~
           FIRST x_grp-obj-price WHERE           x_grp-obj-price.gop-id     = buf_price-list-type.gop-id   AND           x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num
&Scoped-define OPEN-QUERY-BROWSE-1grp OPEN QUERY {&SELF-NAME} FOR     EACH buf_price-doc-forming WHERE        buf_price-doc-forming.stts = 0     , ~
           FIRST buf_price-list-type  WHERE           buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id AND           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num , ~
           FIRST x_grp-obj-price WHERE           x_grp-obj-price.gop-id     = buf_price-list-type.gop-id   AND           x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num .
&Scoped-define TABLES-IN-QUERY-BROWSE-1grp buf_price-doc-forming ~
buf_price-list-type x_grp-obj-price
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-1grp buf_price-doc-forming
&Scoped-define SECOND-TABLE-IN-QUERY-BROWSE-1grp buf_price-list-type
&Scoped-define THIRD-TABLE-IN-QUERY-BROWSE-1grp x_grp-obj-price


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-1grp}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-Cancel B-mark B-sel B-add B-lkp B-chg ~
B-del B-close B-history B-Help B-print loc-pdf-id T-paket BROWSE-1grp ~
FILL-IN-6 v-user-name
&Scoped-Define DISPLAYED-OBJECTS loc-pdf-id T-paket FILL-IN-6 v-user-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-add
     LABEL "Добавить"
     SIZE 10 BY 1 TOOLTIP "Добавить новый ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 10 BY 1 TOOLTIP "Выход из режима"
     BGCOLOR 8 .

DEFINE BUTTON B-chg
     LABEL "Изменить"
     SIZE 10 BY 1 TOOLTIP "Изменение ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-close
     LABEL "Закрыть"
     SIZE 10 BY 1 TOOLTIP "Закрыть ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-del
     LABEL "Удалить"
     SIZE 10 BY 1 TOOLTIP "Удалить ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-history
     LABEL "История"
     SIZE 3 BY 1 TOOLTIP "История изменения документа"
     BGCOLOR 8 .

DEFINE BUTTON B-lkp
     LABEL "Просмотр"
     SIZE 10 BY 1 TOOLTIP "Просмотр ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-mark
     LABEL "*"
     SIZE 3.25 BY 1 TOOLTIP "Отметить строки"
     BGCOLOR 8 .

DEFINE BUTTON B-print
     LABEL "Печать"
     SIZE 3 BY 1 TOOLTIP "Печать ДНЦ"
     BGCOLOR 8 .

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Выбор"
     SIZE 10 BY 1 TOOLTIP "Выбрать ДНЦ"
     BGCOLOR 8 .

DEFINE VARIABLE FILL-IN-6 AS CHARACTER FORMAT "X(256)":U INITIAL "№ ДНЦ:"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE loc-pdf-id AS INTEGER FORMAT ">>>>>>>>>>":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 14 BY 1 TOOLTIP "Поиск по коду документа НЦ" NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Опер"
      VIEW-AS TEXT
     SIZE 20 BY .67 TOOLTIP "Кто изменял"
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE T-paket AS LOGICAL INITIAL no
     LABEL "пакетный режим"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY .83 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-1grp FOR
      buf_price-doc-forming,
      buf_price-list-type,
      x_grp-obj-price SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-1grp Dialog-Frame _FREEFORM
  QUERY BROWSE-1grp NO-LOCK DISPLAY
      mark-string ( buffer buf_price-doc-forming, p-rec-list ) COLUMN-LABEL "*! " FORMAT "x(1)":U
      stts-string ( buffer buf_price-doc-forming )             COLUMN-LABEL "Ста-!тус" FORMAT "x(4)":U
      buf_price-doc-forming.pdf-id   COLUMN-LABEL "Код ДНЦ! " FORMAT ">>>>>>>>>9":U
      buf_price-doc-forming.sys-date         COLUMN-LABEL "Дата!изм"  FORMAT "99/99/99":U
      buf_price-doc-forming.sys-time-chr     COLUMN-LABEL "Время!изм" FORMAT "X(5)":U
      buf_price-doc-forming.name   COLUMN-LABEL "Название документа! " FORMAT "X(100)":U WIDTH 30
      buf_price-list-type.plt-id   COLUMN-LABEL "Код!типа" FORMAT ">>>>>9":U
      buf_price-list-type.main     COLUMN-LABEL "Г! " FORMAT "+/ ":U
      buf_price-list-type.name               COLUMN-LABEL "Тип прайс-листа! " FORMAT "X(100)":U WIDTH 30
      buf_price-doc-forming.db-num-chg       COLUMN-LABEL "БД!изм"    FORMAT ">>>>9":U
      buf_price-doc-forming.pdf-db           COLUMN-LABEL "БД!док" FORMAT ">>>>9":U
      buf_price-list-type.plt-db-num         COLUMN-LABEL "БД!ТПЛ" FORMAT ">>>>9":U
      buf_price-doc-forming.out-code         COLUMN-LABEL "№!накл" FORMAT "X(16)":U
  ENABLE
      buf_price-doc-forming.name
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98.63 BY 18.5 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-Cancel AT ROW 1 COL 1
     B-mark AT ROW 1 COL 11
     B-sel AT ROW 1 COL 14.25
     B-add AT ROW 1 COL 24.25
     B-lkp AT ROW 1 COL 34.25
     B-chg AT ROW 1 COL 44.25
     B-del AT ROW 1 COL 54.25
     B-close AT ROW 1 COL 64.25
     B-history AT ROW 1 COL 89.5
     B-Help AT ROW 1 COL 93
     B-print AT ROW 1 COL 96.5
     loc-pdf-id AT ROW 2 COL 15.5 COLON-ALIGNED NO-LABEL
     T-paket AT ROW 2 COL 82.5 WIDGET-ID 4
     BROWSE-1grp AT ROW 3.25 COL 1.38
     FILL-IN-6 AT ROW 2.21 COL 11 NO-LABEL
     v-user-name AT ROW 22 COL 77 COLON-ALIGNED WIDGET-ID 2
     SPACE(1.38) SKIP(0.46)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Список ДНЦ по ГПЛ (для ПЕРЕОЦЕНОК)"
         DEFAULT-BUTTON B-sel CANCEL-BUTTON B-Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   External Tables: Temp-Tables.buf_price-list-type
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_price-doc B "?" ? ub price-doc
      TABLE: buf_price-doc-forming B "?" ? ub price-doc-forming
      TABLE: buf_price-list-type B "NEW SHARED" ? ub price-list-type
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-1grp T-paket Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN FILL-IN-6 IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-1grp
/* Query rebuild information for BROWSE BROWSE-1grp
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR
    EACH buf_price-doc-forming WHERE
       buf_price-doc-forming.stts = 0
     ,
    FIRST buf_price-list-type  WHERE
          buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id AND
          buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num ,
    FIRST x_grp-obj-price WHERE
          x_grp-obj-price.gop-id     = buf_price-list-type.gop-id   AND
          x_grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num .
     _END_FREEFORM
     _Options          = "NO-LOCK"
     _Query            is OPENED
*/  /* BROWSE BROWSE-1grp */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Список ДНЦ по ГПЛ (для ПЕРЕОЦЕНОК) */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-add Dialog-Frame
ON CHOOSE OF B-add IN FRAME Dialog-Frame /* Добавить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_update':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

  define variable v-rec-id as recid no-undo .
  define variable v-recid as character no-undo .
  define buffer buf1_price-list-type for ub.price-list-type  .
  define variable v-only-main as logical   no-undo .
  define variable v-plt-id     as integer   no-undo .
  define variable v-plt-db-num as integer   no-undo .
  next-prev = false .
  { gbl/glstmain.i v-only-main }
      /* только ГТПЛ - простой случай для текущего объекта */
      { gbl/gtplobj.i
        parParentProc
        v-cntxt-obj-type
        v-cntxt-obj-code
        no
        v-plt-id
        v-plt-db-num
        no-error }
     find first buf1_price-list-type no-lock where
                buf1_price-list-type.plt-id = v-plt-id and
                buf1_price-list-type.plt-db-num = v-plt-db-num
                no-error .

  if available buf1_price-list-type then do:
      if buf1_price-list-type.stts <> integer({&pdf-new}) then do:
         message "ДНЦ можно создать только с текущим типом прайс-листов !" view-as alert-box information  .
         return .
      end.

      if buf1_price-list-type.under-type-list <> 0 then do:
         message "Нельзя выбирать подчиненный прайс-лист !" view-as alert-box information  .
         return .
      end.
      if buf1_price-list-type.gop-id = 0 then do:
         message "Этот тип прайс-листа действует на ВСЕ объекты системы ."
                 "Вы действительно хотите создать одинаковые цены на ВСЕХ объектах ? " view-as alert-box question
                 buttons yes-no
                 update v-okk as logical
                 .
         if v-okk = false then return .
      end.


      run str/df-price.w
        ( input parparentproc,
          input {&add-def} ,
          input buf1_price-list-type.plt-id,
          input buf1_price-list-type.plt-db-num ,
          input ? ,
          output v-rec-list ,
          input-output v-rec-id ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .

      run openbr in this-procedure .
      reposition BROWSE-1grp to recid v-rec-id no-error .
      apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
    end.
    else do:
      message "Не выбран ТПЛ !!!" view-as alert-box .
      return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-chg
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-chg Dialog-Frame
ON CHOOSE OF B-chg IN FRAME Dialog-Frame /* Изменить */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_update':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

  next-prev = false .
  if not available buf_price-doc-forming then return .
  if buf_price-doc-forming.stts <> integer({&pdf-new}) then do:
   message "Закрытые или удаленные ДНЦ корректировать нельзя! "
         view-as alert-box information .
   return .
   end.
  define variable v-rec-id as recid no-undo .
  define variable v-recid as character no-undo .

  if available buf_price-doc-forming then do:
      v-rec-id = recid (buf_price-doc-forming) .

      run str/df-price.w
      ( input parparentproc,
        input {&update} ,
        input buf_price-doc-forming.plt-id,
        input buf_price-doc-forming.plt-db-num ,
        input ? ,
        output v-rec-list ,
        input-output v-rec-id ,
        input-output br-handle ,
        input-output buffer-handle ,
        input-output next-prev

        ) .
      run openbr in this-procedure .
      reposition BROWSE-1grp to recid v-rec-id no-error .
      apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
    end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-close
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-close Dialog-Frame
ON CHOOSE OF B-close IN FRAME Dialog-Frame /* Закрыть */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_close':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

define variable v-rec-id as recid no-undo .
define variable v-mode as character no-undo .
define variable v-ask-pr as logical   no-undo .

 if var-paket = false then do:
  if not available buf_price-doc-forming then return .
  if buf_price-doc-forming.stts <> integer({&pdf-new}) then do:
   message "Закрытые или удаленные ДНЦ закрывать нельзя! "
            view-as alert-box information .
   return .
   end.
  v-rec-id = recid(buf_price-doc-forming) .
  if buf_price-list-type.main = true  then do:
     run str/pdf-cask.w ( input parparentproc , input recid( buf_price-doc-forming ) , output v-mode , output v-ask-pr ) .
     if v-mode = "" or  v-ask-pr = ? then return no-apply.
  end.
  else do:
  message "Закрывать ДНЦ" buf_price-doc-forming.pdf-id "?"
      view-as alert-box question
      buttons yes-no
      update var-ok as logical
      .
  if var-ok =  false then return .
  end.
    run str/diallog.w
        (parparentproc
        , this-procedure
        , 'str/pdf-clos.p':U
        , ( string(v-rec-id) + {&delim-par} +
           'no' + {&delim-par} +
           'no' + {&delim-par} +
           '?' + {&delim-par} +
           '?' + {&delim-par} +
           string(v-mode) + {&delim-par} +
           '?' + {&delim-par} +
           string(v-ask-pr)  )
        , yes /*p-auto-go*/
        , '':U
        , 'Закрытие ДНЦ') no-error .

    if error-status :error then
    message
      error-status :get-message(1) skip
      return-value skip
      "Ошибка закрытия ДНЦ"
      view-as alert-box error
    .
  end.
  else do:
      define variable nn as integer   no-undo .
      define variable v-recid as recid no-undo .
      define buffer cl_price-doc-forming for ub.price-doc-forming  .
      define buffer cl_price-list-type for ub.price-list-type  .
      define variable i as integer   no-undo .
      nn = num-entries(p-rec-list) .
          if nn = 0 then do:
              message "Не выбрано ни одной строки для закрытия! "  view-as alert-box information .
              return .
          end.
          message substitute("Закрыть &1 отмеченных ДНЦ ?  " , nn)
            view-as alert-box question
            buttons yes-no
            update v-ok as logical.
          if v-ok then do:
            repeat i = 1 to nn :
                v-recid = int(entry( i , p-rec-list )) .
                find first cl_price-doc-forming no-lock where
                    recid(cl_price-doc-forming) = v-recid no-error .
                    if available cl_price-doc-forming then do:
                        find first cl_price-list-type no-lock where
                                  cl_price-list-type.plt-id = cl_price-doc-forming.plt-id and
                                  cl_price-list-type.plt-db-num = cl_price-doc-forming.plt-db-num
                                  no-error .
                             if cl_price-doc-forming.stts <> integer({&pdf-new})   then do:
                                message substitute("ДНЦ &1 закрыть уже нельзя !" , cl_price-doc-forming.pdf-id) view-as alert-box information .
                              end.
                              else do:
                                  if cl_price-list-type.main = true  then do:
                                      if v-mode = "" or  v-ask-pr = ? then
                                      run str/pdf-cask.w ( input parparentproc , input recid(cl_price-doc-forming ) , output v-mode , output v-ask-pr ) .
                                          if v-mode = "" or  v-ask-pr = ? then do:
                                              next.
                                          end.
                                  end.
                                    run str/diallog.w
                                        (parparentproc
                                        , this-procedure
                                        , 'str/pdf-clos.p':U
                                        , ( string(recid(cl_price-doc-forming )) + {&delim-par} +
                                          'no' + {&delim-par} +
                                          'no' + {&delim-par} +
                                          '?' + {&delim-par} +
                                          '?' + {&delim-par} +
                                          string(v-mode) + {&delim-par} +
                                          '?' + {&delim-par} +
                                          string(v-ask-pr)  )
                                        , yes /*p-auto-go*/
                                        , '':U
                                        , 'Закрытие ДНЦ') no-error .
                          end.
                    end.
            end.
          end.
  end.

  run openbr in this-procedure .
  reposition BROWSE-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
DO:

if not available buf_price-doc-forming then return .
   define variable g#log as logical   no-undo .
   if buf_price-doc-forming.stts = integer({&pdf-fact}) then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_delete-fact':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }

   end.
   else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_delete':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  end.
  if not g#log then return .

if var-paket = false  then do:
  if not available buf_price-doc-forming then return .
  if buf_price-list-type.main = true  and
     buf_price-doc-forming.stts = integer({&pdf-fact})
     then do:
      message "ДНЦ :" buf_price-doc-forming.name skip
              "№" buf_price-doc-forming.pdf-id
              "главного типа  - удалять нельзя !!!"
              view-as alert-box error
              title "Внимание !" .
              return.
  end.
  message "Удалять ДНЦ : " buf_price-doc-forming.name skip
          "№" buf_price-doc-forming.pdf-id "?"
          view-as alert-box question
          buttons yes-no update g-ok as log.
  if not g-ok then return .

  run price-doc-forming-delete (
      buf_price-doc-forming.plt-db-num ,
      buf_price-doc-forming.plt-id     ,
      buf_price-doc-forming.pdf-db     ,
      buf_price-doc-forming.pdf-id     ,
      v-cntxt-db-num                   ,
      v-cntxt-userid                   )
      no-error .
 end.
 else do:
 define variable nn as integer   no-undo .
 define variable v-recid as recid no-undo .
 define buffer del_price-doc-forming for ub.price-doc-forming  .
 define buffer del_price-list-type for ub.price-list-type  .
 define variable i as integer   no-undo .
 nn = num-entries(p-rec-list) .
    if nn = 0 then do:
        message "Не выбрано ни одной строки для удаления! "  view-as alert-box information .
        return .
    end.
    message substitute("Удалить &1 отмеченных ДНЦ ?  " , nn)
      view-as alert-box question
      buttons yes-no
      update v-ok as logical.
    if v-ok then do:
       repeat i = 1 to nn :
          v-recid = int(entry( i , p-rec-list )) .
          find first del_price-doc-forming no-lock where
               recid(del_price-doc-forming) = v-recid no-error .
               if available del_price-doc-forming then do:
                  find first del_price-list-type no-lock where
                             del_price-list-type.plt-id = del_price-doc-forming.plt-id and
                             del_price-list-type.plt-db-num = del_price-doc-forming.plt-db-num
                             no-error .
                    if  del_price-list-type.main = true  and
                        del_price-doc-forming.stts = integer({&pdf-fact})   then do:
                          message substitute("Удалять ДНЦ &1 нельзя !" , del_price-doc-forming.pdf-id) view-as alert-box information .
                        end.
                        else do:
                        run price-doc-forming-delete (
                            del_price-doc-forming.plt-db-num ,
                            del_price-doc-forming.plt-id     ,
                            del_price-doc-forming.pdf-db     ,
                            del_price-doc-forming.pdf-id     ,
                            v-cntxt-db-num                   ,
                            v-cntxt-userid                   )
                            no-error .
                    end.
               end.
       end.
    end.
 end.
 p-rec-list = "" .
 if error-status :error then return no-apply .
 run openbr in this-procedure .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-history
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-history Dialog-Frame
ON CHOOSE OF B-history IN FRAME Dialog-Frame /* История */
DO:
  if not available buf_price-doc-forming then return .
  run ref/cpr-form.w ( parParentProc ,
        buf_price-doc-forming.plt-id    ,
        buf_price-doc-forming.plt-db-num ,
        buf_price-doc-forming.pdf-id    ,
        buf_price-doc-forming.pdf-db      ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-lkp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-lkp Dialog-Frame
ON CHOOSE OF B-lkp IN FRAME Dialog-Frame /* Просмотр */
DO:
   define variable g#log as logical   no-undo .
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_pdf_lookup':U
    {&cntxt-global}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return .

if not available buf_price-doc-forming then return .

define variable v-rec-id as recid no-undo .
define variable v-recid as character no-undo .

  assign
    v-rec-id      = recid (buf_price-doc-forming)
    next-prev     = yes
    br-handle     = BROWSE-1grp:handle
    buffer-handle = buffer buf_price-doc-forming :handle .
    .
  do while next-prev = yes :
      if not available buf_price-doc-forming then do:
        message "Неправильно выбран документ ДНЦ." view-as alert-box error.
        return no-apply.
      end.
      run str/df-price.w
        ( input parparentproc,
          input {&lookup} ,
          input buf_price-doc-forming.plt-id ,
          input buf_price-doc-forming.plt-db-num ,
          input ? ,
          output v-rec-list  ,
          input-output v-rec-id  ,
          input-output br-handle ,
          input-output buffer-handle ,
          input-output next-prev
          ) .
  end.

  run openbr in this-procedure .
  reposition browse-1grp to recid v-rec-id no-error .
  apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-mark Dialog-Frame
ON CHOOSE OF B-mark IN FRAME Dialog-Frame /* * */
DO:

    if available buf_price-doc-forming then do:
      { gbl/markstrn.i buf_price-doc-forming p-rec-list }
        g-log = browse-1grp:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
          g-log = browse-1grp:select-next-row ().
          apply "VALUE-CHANGED" to browse-1grp in frame {&frame-name}.
      end.
    end.

    apply "display" to browse-1grp in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-print Dialog-Frame
ON CHOOSE OF B-print IN FRAME Dialog-Frame /* Печать */
DO:
  run rep/g-dfc.p
     ( parParentProc,
       recid(buf_price-doc-forming)
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  if ( available buf_price-doc-forming ) AND ( p-rec-list = "" ) THEN
                  p-rec-list = string( recid ( buf_price-doc-forming )) .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-1grp
&Scoped-define SELF-NAME BROWSE-1grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  apply  "CHOOSE":U to b-lkp.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-1grp Dialog-Frame
ON VALUE-CHANGED OF BROWSE-1grp IN FRAME Dialog-Frame
DO:
  {&OPEN-QUERY-BROWSE-2-pr}
  if available buf_price-doc-forming then do:
  { gbl/usrfulnm.i
  buf_price-doc-forming.who
  v-user-name
  }
  end.
  display  v-user-name with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME loc-pdf-id
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL loc-pdf-id Dialog-Frame
ON LEAVE OF loc-pdf-id IN FRAME Dialog-Frame
DO:

END.

ON CTRL-J OF loc-pdf-id IN FRAME {&frame-name}
DO:
  assign loc-pdf-id .
  run seach-pdf-id in this-procedure ( loc-pdf-id , true  ) no-error .
  if error-status:error then return no-apply.
END.

ON RETURN OF loc-pdf-id IN FRAME {&frame-name}
DO:
assign loc-pdf-id no-error .
  if error-status:error then return no-apply.
  run seach-pdf-id in this-procedure ( loc-pdf-id , false  ) no-error .
  return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME T-paket
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL T-paket Dialog-Frame
ON VALUE-CHANGED OF T-paket IN FRAME Dialog-Frame /* пакетный режим */
DO:
   assign T-paket .
   var-paket = t-paket .
   if T-paket then do:
      enable  b-close b-del b-mark with frame {&frame-name} .
      disable b-add b-chg   with frame {&frame-name} .
   end.
   else do:
      if LOOKUP ("b-add":U,    p-bttns) <> 0 then
         enable  b-add with frame {&frame-name} .
      if LOOKUP ("b-chg":U,    p-bttns) <> 0 then
         enable  b-chg with frame {&frame-name} .
      if LOOKUP ("b-mark":U,    p-bttns) = 0 then
         disable  b-mark with frame {&frame-name} .


   end.
  /* 777 */
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

{ gbl/brwrefre.i  "run openbr in this-procedure . "}

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  buf_price-list-type.name:resizable in browse {&browse-name}   = true .
  buf_price-doc-forming.name:resizable in browse {&browse-name}   = true .
  buf_price-doc-forming.name:read-only in browse {&browse-name}   = true .

  frame {&frame-name}:TITLE = ( if p-mode = "pl-type":U  then ("ДНЦ по ТИПУ прайс-листа № " + string( p-plt-id) + " БД " + string( p-plt-db-num))
                                                        else "Список ДНЦ по ГПЛ (для ПЕРЕОЦЕНОК)" ) +
                                                        " Объект "  + p-obj-type + string(p-obj-code)
                                                         .
  run init-proc in this-procedure .
  run enable_ui in this-procedure .
  apply "VALUE-CHANGED" to BROWSE-1grp IN FRAME {&frame-name} .
  disable
     B-sel      when LOOKUP ("b-sel":U,    p-bttns) = 0
     B-add      when LOOKUP ("b-add":U,    p-bttns) = 0
     B-chg      when LOOKUP ("b-chg":U,    p-bttns) = 0
     B-del      when LOOKUP ("b-del":U,    p-bttns) = 0
     B-mark     when LOOKUP ("b-mark":U,   p-bttns) = 0
    with frame {&frame-name} .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

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
  DISPLAY loc-pdf-id T-paket FILL-IN-6 v-user-name
      WITH FRAME Dialog-Frame.
  ENABLE B-Cancel B-mark B-sel B-add B-lkp B-chg B-del B-close B-history B-Help
         B-print loc-pdf-id T-paket BROWSE-1grp FILL-IN-6 v-user-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
/* заполнить временную таблицу значениями групп объектов ценообразования*/
run metod-obj-in-gop in this-procedure (
    v-cntxt-db-num ,
    p-obj-type    ,
    p-obj-code
    ).
 /* результат помещается в таблицу x_grp-obj-price*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE openbr Dialog-Frame
PROCEDURE openbr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  {&OPEN-QUERY-BROWSE-1grp}
  {&OPEN-QUERY-BROWSE-2-pr}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE seach-pdf-id Dialog-Frame
PROCEDURE seach-pdf-id :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-id as INTEGER no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming no-lock where
      buf_price-doc-forming.pdf-id     = p-id no-error .
      if not available buf_price-doc-forming then do:
        message "Еще запись не найдена ! " view-as alert-box information .
        return .
      end.
end.
else do:
  find first buf_price-doc-forming no-lock where
             buf_price-doc-forming.pdf-id     = p-id
 no-error .
              if not available buf_price-doc-forming then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition {&browse-name} to rowid rowid(buf_price-doc-forming) no-error .
apply "value-changed" to {&browse-name} in frame {&frame-name}.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME