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
using Progress.Lang.*.
using Progress.Json.ObjectModel.*.

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$" .
define variable vss-archive     as character no-undo init "$Archive$":U .  
define variable vss-description as character no-undo init "Толкач выгрузки на прайс-чекер".

{ cmp/vssrevis.i } 
{ gbl/getcntxt.i def }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cd-attr.i  }
{ gbl/db-attr.i }
{ gbl/windows.i  }
{ gbl/runrepid.i }
{ cmp/mrk-strf.i }
{ rep/html-conv.i }
{ cmp/r-pril.i new }
{ cmp/r-page1.i new }
/*{ cmp/r-page1.i " " cmp }*/
{ gbl/prn-lib.i }
{ gbl/waitfram.i }
{ str/placelib.i }


function f-int-to-chr returns character (input v-int as integer) :
  if v-int = 0 or v-int = ? then return "" .
  return string(v-int) .
end function .

function f-dec-to-chr returns character (input v-dec as decimal) :
  if v-dec = ? then return "" .
  return string(v-dec, "->>>>>>>9.99<<<") .
end function .

{ str/lib-rvs.i }
{ bge/socet.i}
{ bge/place-def.i}
{ str/rvsttdef.i }
{ utl/search.i}
{ str/revis.i }
if session:debug-alert
then assign
   mWriteRespFile = "asi-data.xml"
   mFileLogSocet  = "asi-data.log"
.
define temp-table tt-pids no-undo
  field pid as integer
  index pi as primary unique
    pid
.

define variable log-exit          as logical    no-undo .
define variable curl-path         as character  no-undo .
define variable v-post-file-name  as character  no-undo .
define variable v-cmd-file-name   as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-out-str         as character  no-undo .
define variable v-pid-list        as character  no-undo .
define variable v-time-str        as character  no-undo .
define variable v-del-file        as character  no-undo .
define variable v-log-file-name   as character  no-undo .

define variable v-parsesub        as character  no-undo .
define variable hDoc              as handle     no-undo .
define variable hRoot             as handle     no-undo .
define variable good              as logical    no-undo .

define variable v-temp-dir        as character  no-undo .

define variable rv                as integer    no-undo .

define variable cash-recids       as character  no-undo .
define variable ii                as integer    no-undo .

define variable rid-list          as character  no-undo .

define variable v-asi-ip  as character no-undo .
define variable v-asi-port as character no-undo .
define variable v-asi-type as character no-undo .
define variable v-attr-type as character no-undo .

define variable v-date  as date no-undo init ? .
define variable v-time  as integer no-undo .

define variable v-mode    as integer no-undo .

define variable mclose        as logical no-undo .

define variable v-status  as character view-as text label "Статус" initial "" format "X(80)".

define buffer buf_clients for ub.clients .
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_tt-place for tt-place .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-req b-print

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD f-int-to-chr Procedure
function f-int-to-chr returns character (input v-int as integer) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 10 BY 1
     BGCOLOR 8 .
     
DEFINE BUTTON b-req
     LABEL "Запрос" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print 
     LABEL "Печать" 
     SIZE 18 BY 1
     BGCOLOR 8 .



define query br-place for tt-place scrolling .

define browse br-place
  query br-place no-lock display
    tt-place.loc1
    f-int-to-chr(tt-place.pl-code)  label "Код резервуара"
    tt-place.gds-name format "x(30)"
    f-int-to-chr(tt-place.gds-code)  label "Код продукта"
    tt-place.level-total
    tt-place.level-water
    tt-place.total-vol
    tt-place.avrg-temp
    tt-place.density FORMAT ">>>9.9999"
    tt-place.mass
    tt-place.vapor-density
    tt-place.vapor-pressure
WITH NO-ROW-MARKERS SEPARATORS SIZE 143 BY 15
         TITLE "Показания АСИ" FIT-LAST-COLUMN.
    
define stream OutStr-html.
define stream MyWatch-strm. /* задать в области определения переменных */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.24 COL 2
     b-req at row 1.24 col 12.1
     b-print AT ROW 1.24 COL 93 WIDGET-ID 10
     br-place at row 3 col 2
     v-status at row 18 col 2
     SPACE(1) 
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Показания АСИ"
         CANCEL-BUTTON b-exit WIDGET-ID 100.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* <insert dialog title> */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-req
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-req Dialog-Frame
ON CHOOSE OF b-req IN FRAME Dialog-Frame 
DO:
  run getreqAsi.
  
  open query br-place for each tt-place indexed-reposition .
  display v-status with frame {&frame-name} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame 
DO:
/*  run getreqAsi.*/
  if v-date = ?
  then do :
    message "Нет данных для печати!" view-as alert-box .
    return no-apply .
  end .
  
  run My-Rep.
  
  run waitfram-hide in this-procedure no-error .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  
  for each tt-place no-lock :
    v-del-file = v-temp-dir + "\asiresp_" + string(tt-place.loc1) + ".xml" .
    v-del-file = search(v-del-file) .
    if v-del-file = ? or trim(v-del-file) = ""
    then next .
                   
    os-delete value(v-del-file) . 
    
    v-del-file = v-temp-dir + "\asireq_" + string(tt-place.loc1) + ".bat" . 
    v-del-file = search(v-del-file) .
    if v-del-file = ? or trim(v-del-file) = ""
    then next .
                   
    os-delete value(v-del-file) .             
  end.
  run sleep (1000) .
  os-delete value (search(v-temp-dir)) recursive .
  
  assign
    log-exit = true
    mclose   = yes
  .
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on row-display OF br-place IN FRAME Dialog-Frame
do:
  if  tt-place.level-total    = ? then tt-place.level-total:fgcolor in browse br-place = 15 . 
  if  tt-place.level-water    = ? then tt-place.level-water:fgcolor in browse br-place = 15 .  
  if  tt-place.total-vol      = ? then tt-place.total-vol:fgcolor in browse br-place = 15 . 
  if  tt-place.avrg-temp      = ? then tt-place.avrg-temp:fgcolor in browse br-place = 15 .  
  if  tt-place.density        = ? then tt-place.density:fgcolor in browse br-place = 15 . 
  if  tt-place.mass           = ? then tt-place.mass:fgcolor in browse br-place = 15 .
  if  tt-place.vapor-density  = ? then tt-place.vapor-density:fgcolor in browse br-place = 15 .
  if  tt-place.vapor-pressure = ? then tt-place.vapor-pressure:fgcolor in browse br-place = 15 .
end.

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
  
  v-log-file-name = substitute('&1rvs.log', ibs.th.gbl.gbl-inipar:logDir) .
  v-temp-dir = "ASI_temp-cmd" .
  os-delete value (v-temp-dir) recursive no-error .
  os-create-dir value(v-temp-dir) .
  
  run db-attr-value(v-cntxt-db-num,"AsiIp",output v-asi-ip,output v-attr-type).
  run db-attr-value(v-cntxt-db-num,"AsiPort",output v-asi-port,output v-attr-type).
  run db-attr-value(v-cntxt-db-num,"AsiType",output v-asi-type,output v-attr-type).
  
  if trim(v-asi-ip) <> ''
  and trim(v-asi-port) <> ''
  and trim(v-asi-type) <> ''
  then do :
    case v-asi-type :
      when "1"
      then do :
        v-mode = 2 .
      end .
      when "2"
      then do :
        v-mode = 3 .
      end .
    end case .
  end . 
  else do :
    v-mode = 1 .
  end . 
  
  empty temp-table tt-pids .
  
  assign
    curl-path = search("exe/curl.exe")
  .
  
  run init-tt .
  
  RUN enable_UI.
  run getreqAsi.
  open query br-place for each tt-place indexed-reposition .
  
  if not mclose
  then
     WAIT-FOR GO OF FRAME {&FRAME-NAME}.
   
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure getreqAsi:
  run waitfram-show in this-procedure ("Получаем данные с АСИ ...").
  
  case v-mode :
    when 1
    then do :
      run get-from-struna (v-log-file-name, v-cntxt-obj-code )no-error.
      if error-status:error
      then do :
        v-status = return-value .
        message v-status
        view-as alert-box.
      end .
      else do:
         run  checkttPlace no-error.
         if error-status:error
         then do :
           v-status = return-value .
           message v-status
           view-as alert-box.
         end .
         else do :
           v-status = "Данные получены " + string(NOW).
           v-date = date(now) .
           v-time = time .
         end.
      end.
    end .
    when 2
    then do :
      run waitfram-hide in this-procedure no-error .
      display v-status with frame {&frame-name} .
      run asi-send-cmd no-error .
  
      if error-status:error
      then do :
        v-status = return-value .
        message v-status
           view-as alert-box.
        display v-status with frame {&frame-name} .
	
      end .
      
    end .
    when 3
    then do :
      run get-from-ifsf (v-log-file-name,v-asi-ip,v-asi-port )no-error.
      if error-status:error
      then do :
        v-status = return-value .
        message v-status
           view-as alert-box.
      end .
      else do:
         run  checkttPlace no-error.
         if error-status:error
         then do :
           v-status = return-value .
           message v-status
           view-as alert-box.
         end .
         else do :
           v-status = "Данные получены " + string(NOW) .
           v-date = date(now) .
           v-time = time .
         end.
       end.
    end .
  end case .
  run waitfram-hide in this-procedure no-error .
  display v-status with frame {&frame-name} .
end procedure. 

define variable mFlagRes as logical no-undo.
procedure asi-send-cmd :
  define variable bat-file              as character    no-undo .
  define variable cmd                   as character    no-undo .
  define variable v-pid                 as integer      no-undo .
  define variable v-addr                as character    no-undo .
      
  mWaitProcEvent = false.
  run SendReqSocet (v-asi-ip,v-asi-port,"getmeas/?loclist=all","","xml","getResponseMy").
  
  if oErrMsg ne ""
  then do:
     v-status = oErrMsg.
     return.
  end.
  define variable mTimeOut as decimal no-undo init 180.
  if     mTimeOut ne ? 
     and mTimeOut ne 0
  then 
     v-status = substitute("Запрос отправлен &1 ожидаем ответ &2 секунд...", string(NOW), mTimeOut).
  else
     v-status = "Запрос отправлен " + string(NOW) + " ожидаем ответ..." .
  mFlagRes = no.
   
  display v-status with frame {&frame-name} .
  etime(yes).
  b-req:sensitive = no.
  WAIT-FOR CHOOSE OF b-exit IN FRAME Dialog-Frame or read-response of mHSocket pause mTimeOut.
  b-req:sensitive = yes.
 
  if mHSocket:connected() 
  then do:
     mHSocket:disconnect() no-error.
     
  end.
  delete object mHSocket no-error. 
  if not mFlagRes
  then do:
     if     mTimeOut ne ? 
        and mTimeOut ne 0 
        and etime / 1000 > mTimeOut - 0.1 /* вычтем 0.1 так как при тайм ауте 30 сек  по etime проходит всего 29.997 сек */ 
     then
        v-status = "Данные не получены. Вышло вмремя ожидания ответа".
     else
        v-status = "Данные не получены. Операция прервана пользователем".
  end.
  if mclose
  then
     APPLY "GO" TO FRAME {&FRAME-NAME}.     
end procedure .

procedure getResponseMy:
   mFlagRes = yes.
   run getResponse.
   run asi-read-sts no-error .
   if error-status:error
   then do :
     v-status = return-value .
     message v-status
     view-as alert-box.
   end .
   else do :
     v-status = "Данные получены " + string(NOW) .
     v-date = date(now) .
     v-time = time .
   end.
end. 
procedure asi-read-sts :
  define variable v-file    as character no-undo .
  define variable err-msg as character no-undo .
  
  if length(mWebResp) = 0
  then do :
    return error "Пустой ответ от агента АСИ".
  end.
  
  run parse-xml (input mWebResp) .
  
  find first buf_tt-place no-error .
  if available buf_tt-place
  then
  br-place:refresh () in frame Dialog-Frame no-error . 
  run  checkttPlace no-error.
  if error-status:error
  then
     return error return-value.


end procedure .

procedure checkttPlace :
  define variable err-msg as character no-undo.
  
  find first buf_tt-place where buf_tt-place.locint eq ? no-error .
  if available buf_tt-place
  then do :
    for each buf_tt-place:
      if buf_tt-place.locint eq ?
      then
         buf_tt-place.locint = integer (buf_tt-place.loc1) no-error.
    end .
  end .
  find first buf_tt-place where buf_tt-place.is-error no-error .
  if available buf_tt-place
  then do :
    err-msg = "Ошибка при получении данных с резервуаров " .
    for each buf_tt-place where buf_tt-place.is-error :
      err-msg = err-msg + buf_tt-place.loc1 + ", " .
    end .
    err-msg = trim(err-msg) .
    err-msg = trim(err-msg, ",") .

       v-date = date(now) .
       v-time = time .   
    return error err-msg .
  end .
end.
procedure init-tt :
  define variable pl-twice-code as character no-undo initial "" .
  define variable v-value       as character no-undo .
  define variable v-ok          as logical   no-undo .
  define buffer buf_tt-place for tt-place .
  
  for each buf_place no-lock where buf_place.obj-type = v-cntxt-obj-type
                               and buf_place.obj-code = v-cntxt-obj-code
                               and buf_place.is-meas 
                               and buf_place.status_ = ""  :
    find first tt-place where tt-place.loc1 = buf_place.loc1 no-error.
    if not available tt-place
    then do :
      create tt-place .
      assign
        tt-place.loc1     = buf_place.loc1
        tt-place.pl-code  = buf_place.pl-code
        tt-place.locint   = int(buf_place.loc1) 
      no-error.
      assign
        tt-place.t1             = ?
        tt-place.t2             = ?
        tt-place.t3             = ?
        tt-place.level-total    = ?   
        tt-place.level-water    = ?   
        tt-place.total-vol      = ? 
        tt-place.avrg-temp      = ?  
        tt-place.density        = ? 
        tt-place.mass           = ?
        tt-place.vapor-density  = ?
        tt-place.vapor-pressure = ?
      .
      find first buf_pl-gds no-lock where buf_pl-gds.pl-code = buf_place.pl-code no-error .
      if available (buf_pl-gds) then 
      do:
        tt-place.gds-code = buf_pl-gds.gds-code .
        find first goods no-lock where goods.gds-code = tt-place.gds-code .
        if available (goods)
        then tt-place.gds-name = goods.gds-name .
      end.
    end.  
    run placelib_get-attr  ( input {&place-twice-code}
                      ,input v-cntxt-obj-code
                      ,input v-cntxt-obj-type
                      ,input buf_place.pl-code
                      ,output v-value
                      ,output v-ok      ) no-error.   
    if v-ok then pl-twice-code = v-value . 
    if trim(pl-twice-code) > ""
    then do :
      if num-entries(pl-twice-code) > 1
      then do :
        do ii = 1 to num-entries(pl-twice-code) :
          find first buf_tt-place where buf_tt-place.loc1 = trim( entry( ii, pl-twice-code ) ) no-error.
          if not available buf_tt-place
          then do :
            create buf_tt-place .
          end.
          assign
            buf_tt-place.loc1 = trim( entry( ii, pl-twice-code ) )
            buf_tt-place.locint   = int(buf_tt-place.loc1) 
          no-error.
          assign  
            buf_tt-place.gds-code = tt-place.gds-code
            buf_tt-place.gds-name = tt-place.gds-name
          .
          assign
            buf_tt-place.t1             = ?
            buf_tt-place.t2             = ?
            buf_tt-place.t3             = ?
            buf_tt-place.level-total    = ?   
            buf_tt-place.level-water    = ?   
            buf_tt-place.total-vol      = ? 
            buf_tt-place.avrg-temp      = ?  
            buf_tt-place.density        = ? 
            buf_tt-place.mass           = ?
            buf_tt-place.vapor-density  = ?
            buf_tt-place.vapor-pressure = ?
          .
        end.
      end.
      else do :
        find first buf_tt-place where buf_tt-place.loc1 = pl-twice-code no-error .
        if not available buf_tt-place
        then do :
          create buf_tt-place .
        end.
        assign
          buf_tt-place.loc1     = pl-twice-code
          buf_tt-place.locint   = int(buf_tt-place.loc1) 
        no-error.
        .
        assign  
          buf_tt-place.gds-code = tt-place.gds-code
          buf_tt-place.gds-name = tt-place.gds-name
        .
        assign
          buf_tt-place.t1             = ?
          buf_tt-place.t2             = ?
          buf_tt-place.t3             = ?
          buf_tt-place.level-total    = ?   
          buf_tt-place.level-water    = ?   
          buf_tt-place.total-vol      = ? 
          buf_tt-place.avrg-temp      = ?  
          buf_tt-place.density        = ? 
          buf_tt-place.mass           = ?
          buf_tt-place.vapor-density  = ?
          buf_tt-place.vapor-pressure = ?
        .
      end.
    end.
    pl-twice-code = "" .                          
  end.
  
end procedure.




procedure My-Rep:

define variable v-full-path-RepView as character no-undo.   /* Полный путь к файлу Просмотровщика (отчётов) */
define variable v-file-name-rep-htm as character no-undo.   /* Полный путь к файлу отчёта */
define variable g#report-num as integer no-undo.            /* Номер отчёта (получим стандартной процедурой ТН) */
define variable v-report-name as character no-undo.
define variable Lines_Counter as integer no-undo .

  run get-full-path-RepViewer(output v-full-path-RepView).    /* Перед работой с "Просмотровщиком отчёта" (main.exe) - убедимся, что он существует и получим полный путь к нему. */

  run get-report-num in parParentProc(output g#report-num).   /* Получим СТАНДАРТНЫМ МЕТОДОМ ТН номер файла отчёта. */

  run define-full-path-Report(input g#report-num, output v-file-name-rep-htm).   /* Сформируем стандартизованное в ТН имя файла отчёта. */

  run create-file(v-file-name-rep-htm).   /* Создадим на диске пустой файл со сформированным по стандарту именем файла. */


  run waitfram-show in this-procedure ("Подождите ...").
  

  Lines_Counter = 0 .

    
&scoped-define css_page1tit      text-align:center; font-weight:bold;
&scoped-define css_align_righit  text-align:right; padding-right:4px;
&scoped-define css_align_center  text-align:center;
&scoped-define css_table_border  border-style:solid; border-width:thin;
&scoped-define css_cell_border   border: 1px solid black; 
&scoped-define css_border_bottom border-bottom: 1px solid black;  

  output stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
  
  
  /* Системная шапка HTML */
  put stream OutStr-html unformatted
  
{rep/htmlhead.i}
    .
  put stream OutStr-html unformatted
    '<body>' skip
    '<TABLE name="1"  fit_to_page="true" orientation="portrait" CELLSPACING="0" BORDER="0">'skip
    '<thead>' skip
  .
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 120px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '<td style="width: 60px;"></td>' skip
    '</tr>' skip
  .
                        
 
  put stream OutStr-html unformatted
    '<tr>' skip
    '<td colspan="15" style="text-align: center; font-weight:bold;">Оперативный отчет по показаниям АСИ</td>' skip
    '</tr>' skip   
    '<tr>' skip
    '<td colspan="7" style="text-align: left; font-weight:bold;">Дата: ' + string(v-date) + '</td>' skip
    '</tr>' skip  
    '<tr>' skip
    '<td colspan="7" style="text-align: left; font-weight:bold;">Время: ' + string(v-time, 'HH:MM:SS') + '</td>' skip
    '</tr>' skip 
    '<tr>' skip
    '<td colspan="7" style="text-align: left; font-weight:bold;"><br></td>' skip
    '</tr>' skip
    '</thead>' skip
  .  
    
  put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 50px">№ резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код резервуара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">НАИМЕНОВАНИЕ ПРОДУКТА</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код продукта</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Общий уровень (см)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Уровень воды (см)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Общий объем (л)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Средняя Т (°С)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Т1 (°С)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Т2 (°С)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Т3 (°С)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Плотность (кг/л)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Масса (кг)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Плотность СУГ ПФ (кг/л)</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Давление СУГ (мПа)</th>' skip
      '       </tr>' skip
      '       <tr>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.1</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.2</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.3</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.4</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.5</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.6</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.7</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.8</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.9</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.10</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.11</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.12</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.13</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.14</th>' skip
      '         <th num="" style="text-align: center;  font-weight:bold; background-color: silver;">1.15</th>' skip
      '       </tr>' skip
  . /* Точка для закрытия Put */
  
  for each tt-place no-lock :
    put stream OutStr-html unformatted
      '       <tr>' skip
      '         <th style="text-align: center;">' + tt-place.loc1 + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.pl-code > 0 then string(tt-place.pl-code, ">>>>>>>>>>9") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + tt-place.gds-name + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.gds-code > 0 then string(tt-place.gds-code) else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.level-total <> ? then string(tt-place.level-total, ">>>>>9.9<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.level-water <> ? then string(tt-place.level-water, ">>>>>9.9<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.total-vol <> ? then string(tt-place.total-vol,   ">>>>>9.9<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.avrg-temp <> ? then string(tt-place.avrg-temp,  "->>>>>9.9<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.t1 <> ? then string(tt-place.t1,  "->>>>>9.9<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.t2 <> ? then string(tt-place.t2,  "->>>>>9.9<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.t3 <> ? then string(tt-place.t3,  "->>>>>9.9<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.density <> ? then string(tt-place.density,   ">>>>>>>>>9.9<<<<<<<<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.mass <> ? then string(tt-place.mass,        ">>>>>9.9<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.vapor-density <> ? then string(tt-place.vapor-density, ">>>>>>>>>9.9<<<<<<<<<") else " ") + '</th>' skip
      '         <th style="text-align: center;">' + (if tt-place.vapor-pressure <> ? then string(tt-place.vapor-pressure, ">>>>>9.99999") else " ") + '</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */
  end.
  
  put stream OutStr-html unformatted
                '     </tbody>' skip
                '   </table>' skip
                '  </body>' skip
                ' </html>' skip
 . /* Точка для закрытия Put */
  output stream OutStr-html close.

  output stream OutStr-html close.
  
  
  run prn-lib-reportviewer-report-name in this-procedure (
  input THIS-PROCEDURE
  ,input v-file-name-rep-htm
  ).


/* **************************************** */

end procedure. /* My-Rep */

procedure get-full-path-RepViewer:
/* Получение полного пути к exe-файлу просмотровщика отчётов */
    define output parameter p-fill-path-RepView as character no-undo.

    if search("exe\ReportViewer\reportviewer.exe") <> ? then
    do:
        p-fill-path-RepView = search("exe\ReportViewer\reportviewer.exe").
    end.
    else
    do:
        message "Не найдена программа просмотра отчёта!" view-as alert-box error.
    end.
end procedure.

procedure define-full-path-Report:
/* Получение полного пути к отчёту html */
    define input parameter p-rep-num as integer no-undo.
    define output parameter p-file-name-rep-htm as character no-undo.

    p-file-name-rep-htm = session:temp-directory + {&DF_Name} + string(p-rep-num) + ".html".

end procedure.

procedure search-full-path-Report:
/* Поиск файла */
    define input parameter p-file-name as character no-undo.

    if search(p-file-name) = ? then
        do:
            message "Не найден файл отчёта: " p-file-name view-as alert-box error.
        end.
    else
        do:
            p-file-name = search(p-file-name).
        end.

end procedure.

procedure Report-Viewer:
/* Запуск программы "Просмотровщик Отчётов" - ReportViewer. */
    define input parameter p-full-path-RepView as character no-undo.
    define input parameter p-file-name-rep-htm as character no-undo.

os-command no-wait value(p-full-path-RepView + " " + search(p-file-name-rep-htm)).

end procedure.

procedure create-file:
/* Создание пустого файла (во входном параметре: полный путь и имя файла) */
    define input parameter p-file-name as character no-undo.
    output to value(string(p-file-name)).
    output close.

end procedure.

                                                                                                                                                                                                       

function fnc-DD-MM-YYYY returns character 
(input p-dat-date as date):
/* Преобразование даты в формат: "01.01.2014" */

    define variable result as character no-undo.
    define variable p-str-date as character no-undo.

    p-str-date = replace(string(p-dat-date,'99.99.9999'), "/", ".").

        return p-str-date.

end function.

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
  ENABLE b-exit b-req b-print br-place v-status
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

PROCEDURE Sleep EXTERNAL "kernel32.DLL":
  DEFINE INPUT PARAMETER intMilliseconds AS LONG.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

