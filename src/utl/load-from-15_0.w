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
using Progress.Json.ObjectModel.*. 

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Загрузка данных из TH 15.0 через сокет-сервер".
define variable mUtil as class ibs.th.utl.method-for-draw-utility no-undo.
mUtil = new ibs.th.utl.method-for-draw-utility().
mutil:parparentproc = parparentproc.
subscribe   to "write-log"     anywhere run-procedure "pcall-log-file".
subscribe   to "write-log-err" anywhere run-procedure "pcall-log-file-err".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ str/placelib.i }
{ str/nzpl-spl.i }
{ trg/cplgdspm.i }
{ gbl/cd-attr.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ utl/tt301.i    }
{ gbl/getcntxa.i }

&GLOBAL-DEFINE defined_parparentproc yes

/* { str/ptrlv.i "def"}


procedure nozzleav:
define input parameter parobj-type    like ub.clients.obj-type   no-undo.
define input parameter parobj-code    like ub.clients.obj-code   no-undo.
define input parameter parnozzle-code like ub.nozzle.nozzle-code no-undo.
define buffer bf_clients for ub.clients.
define buffer bf_nozzle  for ub.nozzle.
{ str/ptrlv.i "ov+"}
/*Проверяем то, что нет еще такого пистолета*/
find first bf_nozzle where bf_nozzle.obj-type    = parobj-type    and
                           bf_nozzle.obj-code    = parobj-code    and
                           bf_nozzle.nozzle-code = parnozzle-code no-lock no-error.
if available bf_nozzle then
             return error SUBSTITUTE("Уже есть пистолет с номером &1", parnozzle-code) {&str-obj}.
create bf_nozzle.
assign bf_nozzle.obj-type    = parobj-type
       bf_nozzle.obj-code    = parobj-code
       bf_nozzle.nozzle-code = parnozzle-code.
end procedure.



{ str/ptrlv.i "undef"}
*/
/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable v-has-records as logical no-undo .
define variable glog        as logical   no-undo.

define variable v-line as character no-undo .
define variable num-rec-ok2 as integer no-undo .

define variable cmd as character no-undo .
define variable vI    as int64    no-undo.
define variable vBuff as handle   no-undo.

DEFINE VARIABLE myParser        AS ObjectModelParser    NO-UNDO.
DEFINE VARIABLE myJsonObj       AS JsonObject           NO-UNDO.
DEFINE VARIABLE results-array   AS JsonArray            NO-UNDO.
DEFINE VARIABLE myResultObj     AS JsonObject           NO-UNDO.

DEFINE VARIABLE iPage       AS INTEGER  NO-UNDO.
DEFINE VARIABLE iLimit      AS INTEGER  NO-UNDO.

DEFINE VARIABLE iCount      AS INTEGER  NO-UNDO.
DEFINE VARIABLE iLength     AS INTEGER  NO-UNDO.

DEFINE STREAM lsIN.
DEFINE STREAM lsOUT.

define stream log-stream .
define stream err-stream .

define temp-table tt-cash-desk like ub.cash-desk .
define temp-table tt-cash-desk-attr like ub.cash-desk-attr
  field attr-value as character 
.
  


define temp-table tt-place like ub.place .
define temp-table tt-place-attr like ub.place-attr .
define temp-table tt-pump like ub.pump .
define temp-table tt-nozzle like ub.nozzle .
define temp-table tt-pl-pump like ub.pl-pump .
define temp-table tt-pump-nozzle like ub.pump-nozzle .
define temp-table tt-pl-pump-nozzle like ub.pl-pump-nozzle .
define temp-table tt-pl-level like ub.pl-level .
define temp-table tt-pl-gds like ub.pl-gds .
define temp-table tt-pl-gds-pump like ub.pl-gds-pump .

define temp-table tt-gds-prod
  field gds-code as integer
  field b-str as character
  index pi as primary unique
    gds-code
.




  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-OK B-Cancel v-addr v-cashdesk v-schem ~
v-pumpdoc v-price v-file-path b-file
&Scoped-Define DISPLAYED-OBJECTS v-addr v-cashdesk v-schem v-pumpdoc v-price v-file-path

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-OK AUTO-GO 
     LABEL "ВВОД" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE v-addr AS CHARACTER FORMAT "X(256)":U 
     LABEL "Адрес сокет-сервера" 
     VIEW-AS FILL-IN tooltip "Адрес сокет-сервера в формате ip:port"
     SIZE 38 BY 1 no-undo initial "localhost:8080" .

DEFINE VARIABLE v-cashdesk AS LOGICAL INITIAL no 
     LABEL "Кассы" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE v-pumpdoc AS LOGICAL INITIAL no 
     LABEL "Инвентаризация счетчиков ТРК" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.

DEFINE VARIABLE v-schem AS LOGICAL INITIAL no 
     LABEL "Топология" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.
     
DEFINE VARIABLE v-price AS LOGICAL INITIAL no 
     LABEL "Цены" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.
     
define variable v-file-path as character FORMAT "X(256)":U 
     LABEL "Файл соответствий" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 no-undo.     
     
define button b-file  DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     SIZE 2.5 BY 1.08.     

DEFINE VARIABLE v-rest AS LOGICAL INITIAL no 
     LABEL "Остатки" 
     VIEW-AS TOGGLE-BOX
     SIZE 60 BY 1 NO-UNDO.

define variable v-osn-fname as character FORMAT "X(256)":U 
     LABEL "Файл соответствия поставщиков" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 no-undo.     
     
define button b-osn-file  DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     SIZE 2.5 BY 1.08.     

define variable v-art-fname as character FORMAT "X(256)":U 
     LABEL "Файл соответствия товаров" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 no-undo.     
     
define button b-art-file  DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     SIZE 2.5 BY 1.08.     

define variable v-retry-fname as character FORMAT "X(256)":U 
     LABEL "Файл повторной загрузки" 
     VIEW-AS FILL-IN 
     SIZE 38 BY 1 no-undo.     
     
define button b-retry-file  DEFAULT
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     SIZE 2.5 BY 1.08.     

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-OK AT ROW 1.2 COL 2
     B-Cancel AT ROW 1.2 COL 12
     v-addr AT ROW 2.4 COL 2 WIDGET-ID 2
     v-cashdesk AT ROW 3.6 COL 3 WIDGET-ID 4
     v-schem AT ROW 4.8 COL 3 WIDGET-ID 6
     v-pumpdoc AT ROW 6 COL 3 WIDGET-ID 8
     v-price AT ROW 7.2 COL 3 WIDGET-ID 10
     v-file-path at row 8.4 col 2 WIDGET-ID 12
     b-file at row 8.4 col 60
     v-rest AT ROW 9.6 COL 3 WIDGET-ID 14
     v-osn-fname at row 10.8 col 34 colon-aligned WIDGET-ID 16
     b-osn-file at row 10.8 col 75
     v-art-fname at row 12 col 34 colon-aligned WIDGET-ID 18
     b-art-file at row 12 col 75
     v-retry-fname at row 13.2 col 34 colon-aligned WIDGET-ID 20
     b-retry-file at row 13.2 col 75
     SPACE(2) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Загрузка данных из TH v15.0"
         DEFAULT-BUTTON B-OK CANCEL-BUTTON B-Cancel WIDGET-ID 100.


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

/* SETTINGS FOR FILL-IN v-addr IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Загрузка данных из TH v15.0 */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON value-changed of v-price in FRAME Dialog-Frame /* Загрузка данных из TH v15.0 */
DO:
  assign v-price.
  assign v-schem.
  if v-price or v-schem
  then do :
    enable v-file-path b-file with frame Dialog-Frame.
  end.
  else do :
    disable v-file-path b-file with frame Dialog-Frame.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON value-changed of v-schem in FRAME Dialog-Frame /* Загрузка данных из TH v15.0 */
DO:
  assign v-schem.
  assign v-price.
  if v-price or v-schem
  then do :
    enable v-file-path b-file with frame Dialog-Frame.
  end.
  else do :
    disable v-file-path b-file with frame Dialog-Frame.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON value-changed of v-rest in FRAME Dialog-Frame /* Загрузка данных из TH v15.0 */
DO:
  assign v-rest.
  if v-rest then enable
    v-osn-fname b-osn-file
    v-art-fname b-art-file
    v-retry-fname b-retry-file
  with frame Dialog-Frame.
  else disable
    v-osn-fname b-osn-file
    v-art-fname b-art-file
    v-retry-fname b-retry-file
  with frame Dialog-Frame.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame /* ВВОД */
DO:
  system-dialog get-file v-file-path
    filters "Текстовые файлы (*.txt)" "*.txt",
            "Все файлы (*.*)" "*.*"
    title "Выберите файл соответсвий кодов товаров"
    update glog
  .
  if glog
  then do :
    v-file-path:screen-value = v-file-path .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-osn-file Dialog-Frame
ON CHOOSE OF B-osn-file IN FRAME Dialog-Frame /* ВВОД */
DO:
  system-dialog get-file v-osn-fname
    filters "Текстовые файлы (*.txt)" "*.txt",
            "Все файлы (*.*)" "*.*"
    title "Выберите файл соответствия кодов поставщиков"
    update glog
  .
  if glog then v-osn-fname:screen-value = v-osn-fname .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-art-file Dialog-Frame
ON CHOOSE OF B-art-file IN FRAME Dialog-Frame /* ВВОД */
DO:
  system-dialog get-file v-art-fname
    filters "Текстовые файлы (*.txt)" "*.txt",
            "Все файлы (*.*)" "*.*"
    title "Выберите файл соответствия кодов товаров"
    update glog
  .
  if glog then v-art-fname:screen-value = v-art-fname .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-retry-file Dialog-Frame
ON CHOOSE OF B-retry-file IN FRAME Dialog-Frame /* ВВОД */
DO:
  system-dialog get-file v-retry-fname
    filters "Текстовые файлы (*.txt)" "*.txt",
            "Все файлы (*.*)" "*.*"
    title "Имя файла для повторной загрузки ошибочных строк"
    update glog
  .
  if glog then v-retry-fname:screen-value = v-retry-fname .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-OK Dialog-Frame
ON CHOOSE OF B-OK IN FRAME Dialog-Frame /* ВВОД */
DO:
  
  ASSIGN
    v-addr
    v-cashdesk
    v-pumpdoc
    v-schem
    v-price
    v-file-path
    v-rest
    v-osn-fname
    v-art-fname
    v-retry-fname
  .
  if v-price and trim(v-file-path) = ""
  then do :
    message "Для загрузки цен необходимо выбрать файл с соответствиями кодов товаров." view-as alert-box.
    apply "entry" to v-file-path .
    return no-apply .
  end.
  if v-schem and trim(v-file-path) = ""
  then do :
    message "Для загрузки топологии необходимо выбрать файл с соответствиями кодов товаров!" view-as alert-box.
    return no-apply .
  end.
  if v-rest and trim(v-osn-fname) = ""
  then do :
    message "Для загрузки остатков необходимо выбрать файл с соответствиями кодов поставщиков." view-as alert-box.
    apply "entry" to v-osn-fname . 
    return no-apply .
  end.
  if v-rest and trim(v-art-fname) = ""
  then do :
    message "Для загрузки остатков необходимо выбрать файл с соответствиями кодов товаров." view-as alert-box.
    apply "entry" to v-art-fname . 
    return no-apply .
  end.
  if v-rest and trim(v-retry-fname) = ""
  then do :
    message "Для загрузки остатков необходимо указать имя файла для выгрузки строк с ошибками, пригодного для повторной загрузки." view-as alert-box.
    apply "entry" to v-retry-fname . 
    return no-apply .
  end.



  if trim(v-file-path) <> ""
  then do :
    if search(v-file-path) = ?
    then do :
      message "Файл соответствий не найден!" view-as alert-box.
      return no-apply .
    end.  
    file-info:file-name = v-file-path .
    if file-info:file-size = 0
    then do :
      message "Файл соответствий пустой!" view-as alert-box.
      return no-apply .
    end. 
  end. 
  mutil:mAddr = v-addr.
  
  v-has-records = false.
  if v-cashdesk then do :
    v-has-records = mutil:chek_cash_desk().
    if v-has-records
    then do :
      message "Справочник касс и/или их атрибутов не пустой!" view-as alert-box.
      return no-apply .
    end.
  end.
  if v-schem then do :
    v-has-records = mUtil:Chek_Shem().
    if v-has-records
    then do :
      message "Топология не пустая!" view-as alert-box.
      return no-apply .
    end.
  end.
  if v-pumpdoc then do :
    v-has-records = mutil:chek_pumpdoc().
    if v-has-records
    then do :
      message "На объекте есть инвентаризации счетчиков ТРК!" view-as alert-box.
      return no-apply .
    end.
  end.
  if v-price then do :
    v-has-records = mutil:chek_price(). 
    if v-has-records
    then do :
      message "На объекте есть переоценки!" view-as alert-box.
      return no-apply .
    end.                                 
  end.
  if v-rest then do :
    // 1. ?? запрещать повторную загрузку документов ??
    if can-find (first ub.trn-doc where ub.trn-doc.obj-type = v-cntxt-obj-type
                                    and ub.trn-doc.obj-code = v-cntxt-obj-code) then do :
      v-has-records = true .
    end.
    if v-has-records
    then do :
      message "На объекте есть остатки!" view-as alert-box.
      return no-apply .
    end.                                 
  end .
  
  output stream log-stream to value("load-from-15_0.log") append .
  output stream err-stream to value("load-from-15_0.err") append .
  if v-cashdesk
  then do trans:
    run waitfram-show in this-procedure ( INPUT "Обработка: Кассы..." ).
    mutil:load_cashdesk (). 
    if error-status:error
    then do :
      run waitfram-hide in this-procedure .
      message ("Ошибка при загрузке Касс: " + return-value + {&new-line} + "Продолжить работу?") view-as alert-box question buttons yes-no update glog .
      if not glog then undo, return no-apply .
      undo .
    end.
  end.
  output stream log-stream close .
  output stream err-stream close .
  
  output stream log-stream to value("load-from-15_0.log") append .
  output stream err-stream to value("load-from-15_0.err") append .
  if v-schem
  then do trans:
    run waitfram-show in this-procedure ( INPUT "Обработка: Топология..." ).
    mUtil:load_schem(v-file-path) no-error .
    if error-status:error
    then do :
      run waitfram-hide in this-procedure .
      message ("Ошибка при загрузке Топологии: " + return-value + {&new-line} + "Продолжить работу?") view-as alert-box question buttons yes-no update glog .
      if not glog then undo, return no-apply .
      undo .
    end.
  end.
  output stream log-stream close .
  output stream err-stream close .
  
  output stream log-stream to value("load-from-15_0.log") append .
  output stream err-stream to value("load-from-15_0.err") append .
  if v-pumpdoc
  then do trans:
    run waitfram-show in this-procedure ( INPUT "Обработка: Инвентаризация счетчиков ТРК" ).
    mutil:load_pumpdoc (v-file-path) no-error .
    if error-status:error
    then do :
      run waitfram-hide in this-procedure .
      message ("Ошибка при загрузке Инвентаризации счетчиков ТРК: " + return-value + {&new-line} + "Продолжить работу?") view-as alert-box question buttons yes-no update glog .
      if not glog then undo, return no-apply .
      undo .
    end.
  end.  
  output stream log-stream close .
  output stream err-stream close .
  
  output stream log-stream to value("load-from-15_0.log") append .
  output stream err-stream to value("load-from-15_0.err") append .
  if v-price
  then do trans:
    run waitfram-show in this-procedure ( INPUT "Обработка: Цены" ).
    
    mutil:load_price(v-file-path) no-error .
    if error-status:error
    then do :
      run waitfram-hide in this-procedure .
      message ("Ошибка при загрузке цен: " + return-value + {&new-line} + "Продолжить работу?") view-as alert-box question buttons yes-no update glog .
      if not glog then undo, return no-apply .
      undo .
    end.
  end.
  output stream log-stream close .
  output stream err-stream close .
  
  output stream log-stream to value("load-from-15_0.log") append .
  output stream err-stream to value("load-from-15_0.err") append .
  if v-rest
  then do trans:
    run waitfram-show in this-procedure ( INPUT "Обработка: Остатки" ).
    mutil:load_rest ( v-osn-fname  ,  // список соответствия поставщиков
                      v-art-fname  , // список соответствия товаров
                      v-retry-fname).
    if error-status:error
    then do :
      run waitfram-hide in this-procedure .
      message ("Ошибка при загрузке остатков: " + return-value + {&new-line} + "Продолжить работу?") view-as alert-box question buttons yes-no update glog .
      if not glog then undo, return no-apply .
      undo .
    end.
  end.
  output stream log-stream close .
  output stream err-stream close .
  
  run waitfram-hide in this-procedure .
  message "ГОТОВО!" view-as alert-box.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  RUN enable_UI.
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
  DISPLAY v-addr v-cashdesk v-schem v-pumpdoc 
      WITH FRAME Dialog-Frame.
  ENABLE B-OK B-Cancel v-addr v-cashdesk v-schem v-pumpdoc v-price v-file-path b-file
    v-rest v-osn-fname b-osn-file v-art-fname b-art-file v-retry-fname b-retry-file
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  apply "value-changed" to v-price in frame Dialog-Frame .
  apply "value-changed" to v-rest in frame Dialog-Frame .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




procedure pcall-log-file :
define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    put stream log-stream unformatted p-message skip .

  end.

end procedure. /* pcall-log-file */

procedure pcall-log-file-err :
define input  parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    put stream err-stream unformatted p-message skip .

  end.

end procedure. /* pcall-log-file */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
finally:
unsubscribe   to "write-log"     .
unsubscribe   to "write-log-err" .
delete object mutil no-error.
end finally. 