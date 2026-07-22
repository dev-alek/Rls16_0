using ibs.th.skt.Adapters.LogWrite.
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME C-Win
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS C-Win

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

4GL socket server (HTTPD)

Автор: Гридчина Полина Дмитриевна
Дата создания: 10/01/07
Author: Polina Gridchina
Creation date: 10/01/07

Input:

Output:

*/

using ibs.th.skt.*.
using ibs.th.skt.Adapters.*.
using ibs.th.skt.ControlledClients.*.

/* Parameters Definitions ---                                           */
define input parameter p-param as character no-undo.
define input parameter p-hide as logical no-undo.
define input parameter p-user-login    as character no-undo .
define input parameter p-user-password as character no-undo .
/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "4GL socket server (HTTPD)".
define variable mAsyncHelper as class ibs.th.file.AsyncHelperth  no-undo.
{utl/asuncprocauto.i &starterasunc = yes}

define new shared variable g#LogStr       as character no-undo .
define shared     variable g#auto-user-id as character no-undo .
define shared     variable g#auto-user-login as character no-undo .
define shared     variable g#auto-user-password as character no-undo .

/*define variable v-header      as character no-undo.*/
/*define variable v-hd-line     as character no-undo.*/
/*define variable v-cont-length as integer   no-undo.*/
/*define variable v-cont-type   as character no-undo.*/
/*define variable v-user-agent  as character no-undo.*/
/*define variable v-querypar    as character no-undo.*/
/*define variable v-path        as character no-undo.*/
define variable mWork         as logical no-undo.

{ cmp/trg-def.i new }
{ cmp/showinf.i  }
{ gbl/cur-time.i }
{ str/defc-gds.i }
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ utl/search.i   }

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
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */


/* { adm/auto-def.i } */
define variable hServerSocket    as handle       no-undo.
define variable v-connect-param  as CHAR         no-undo.
define variable v-srv-connected  as LOG          no-undo.
define variable us-tmo           as INTEGER   INIT 60 no-undo. /*тайм-аут в сек.*/

if num-entries (p-param, ";") = 2
then do:
  v-connect-param = entry (1, p-param, ";").
  us-tmo = integer (entry (2, p-param, ";")) no-error.
  if us-tmo = ?
  then us-tmo = 60.
end.
else do:
  v-connect-param = p-param.
end.
/* v-connect-param = SUBSTITUTE('-H &1 -S &2',ENTRY(1,p-param,':':U),ENTRY(2,p-param,':':U)). */

/*DEFINE VARIABLE hDoc  AS HANDLE.    */
/*DEFINE VARIABLE hRoot AS HANDLE.    */
/*DEFINE VARIABLE hRow  AS HANDLE.    */
/*                                    */
/*DEFINE VARIABLE hDoc-out  AS HANDLE.*/
/*DEFINE VARIABLE hRoot-out AS HANDLE.*/
/*DEFINE VARIABLE hRow-out  AS HANDLE.*/


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Window
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME DEFAULT-FRAME

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-help b-exit Btn-st Btn-log auto-log
&Scoped-Define DISPLAYED-OBJECTS auto-log

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD SocketRead C-Win

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define the widget handle for the window                              */
DEFINE VAR C-Win AS WIDGET-HANDLE NO-UNDO.

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit DEFAULT
     LABEL "Вы&ход "
     SIZE 10 BY 1 TOOLTIP "Выход из автоматической системы"
     BGCOLOR 8 .

DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1 TOOLTIP "Помощь"
     BGCOLOR 8 .

DEFINE BUTTON Btn-st
     LABEL "Старт"
     SIZE 10 BY 1.

DEFINE BUTTON Btn-log
     LABEL "Вкл. расширеный лог."
     SIZE 22 BY 1.

DEFINE VARIABLE auto-log AS longchar
     VIEW-AS EDITOR SCROLLBAR-VERTICAL LARGE
     SIZE 96 BY 20 NO-UNDO.

DEFINE VARIABLE mPort AS integer FORMAT ">>>>9"
     LABEL "Порт"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME DEFAULT-FRAME
     b-help AT ROW 1.17 COL 89 WIDGET-ID 4
     b-exit AT ROW 1.25 COL 2.5 WIDGET-ID 2
     Btn-st AT ROW 1.25 COL 12.5 WIDGET-ID 6
     Btn-log AT ROW 1.25 COL 37
     mPort AT ROW 1.25 COL 24 
     auto-log AT ROW 3 COL 2.5 NO-LABEL WIDGET-ID 8
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 99 BY 22.58 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Window
   Allow: Basic,Browse,DB-Fields,Window,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
IF SESSION:DISPLAY-TYPE = "GUI":U  and not session:batch-mode THEN
  CREATE WINDOW C-Win ASSIGN
         HIDDEN             = YES
         TITLE              = "Сокет-сервер"
         HEIGHT             = 22.58
         WIDTH              = 99
         MAX-HEIGHT         = 30.04
         MAX-WIDTH          = 128
         VIRTUAL-HEIGHT     = 30.04
         VIRTUAL-WIDTH      = 128
         RESIZE             = yes
         SCROLL-BARS        = no
         STATUS-AREA        = no
         BGCOLOR            = ?
         FGCOLOR            = ?
         KEEP-FRAME-Z-ORDER = yes
         THREE-D            = yes
         MESSAGE-AREA       = no
         SENSITIVE          = yes.
ELSE {&WINDOW-NAME} = CURRENT-WINDOW.
/* END WINDOW DEFINITION                                                */
&ANALYZE-RESUME



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW C-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME DEFAULT-FRAME
   FRAME-NAME                                                           */
ASSIGN
       auto-log:READ-ONLY IN FRAME DEFAULT-FRAME        = TRUE.

IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
THEN C-Win:HIDDEN = yes.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME C-Win
if valid-handle({&self-name}) then
do:
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON END-ERROR OF C-Win /* Сокет-сервер */
OR ENDKEY OF {&WINDOW-NAME} ANYWHERE DO:
  /* This case occurs when the user presses the "Esc" key.
     In a persistently run window, just ignore this.  If we did not, the
     application would exit. */
  IF THIS-PROCEDURE:PERSISTENT THEN RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL C-Win C-Win
ON WINDOW-CLOSE OF C-Win /* Сокет-сервер */
DO:
  /* This event will close the window and terminate the procedure.  */
  APPLY "CLOSE":U TO THIS-PROCEDURE.
  mWork = no.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
end.

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit C-Win
ON CHOOSE OF b-exit IN FRAME DEFAULT-FRAME /* Выход  */
DO:

RUN proc-stop-srv.

PAUSE 2.

APPLY 'close':U TO THIS-PROCEDURE.
mWork = no.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn-st
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-st C-Win
ON CHOOSE OF Btn-st IN FRAME DEFAULT-FRAME /* Старт */
DO:
assign mPort.
IF v-srv-connected = NO THEN
  RUN proc-start-srv IN THIS-PROCEDURE NO-ERROR.
ELSE  RUN proc-stop-srv IN THIS-PROCEDURE NO-ERROR.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME Btn-log
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-log C-Win
ON CHOOSE OF Btn-log IN FRAME DEFAULT-FRAME /* Старт */
DO:
   ibs.th.skt.Adapters.LogWrite:isDebugMod = not ibs.th.skt.Adapters.LogWrite:isDebugMod.
   if ibs.th.skt.Adapters.logWrite:isDebugMod
   then
      btn-log:LABEL IN FRAME {&FRAME-NAME} = "Выкл. расширеный лог.".
   else
      btn-log:LABEL IN FRAME {&FRAME-NAME} = "Вкл. расширеный лог.".


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK C-Win


/* ***************************  Main Block  *************************** */
{ gbl/app_help.i }
/* Set CURRENT-WINDOW: this will parent dialog-boxes and frames.        */
if valid-handle({&WINDOW-NAME}) then
do:
ASSIGN CURRENT-WINDOW                = {&WINDOW-NAME}
       THIS-PROCEDURE:CURRENT-WINDOW = {&WINDOW-NAME}.
end.

/* The CLOSE event can be used from inside or outside the procedure to  */
/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
   RUN disable_UI.

/* Best default for GUI applications is...                              */
PAUSE 0 BEFORE-HIDE.

IF v-connect-param > '' 
then do:
   if (trim(v-connect-param)begins "-S")
   then do:
      mPort = int(substring (trim(v-connect-param), 3)).
   end.
   
end.
if mPort eq 0 
then do:
  RUN write-to-log-event('Не указаны параметры подключения!').
  RUN write-to-log-event('Параметры задаются -param "Sock:-S <Port>" или -param "M:<h+>Sock:<Port>" ').
  mPort = 8080.
  RUN write-to-log-event('Задаем порт по умочанию 8080').
  
  
END.
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   if not p-hide then do:
      if valid-handle({&WINDOW-NAME}) then
        C-Win:HIDDEN = no.
      RUN enable_UI.
  end.
  define variable sktserv  as class SktServer no-undo.
  define variable logWrite as class LogWrite  no-undo.
  if ibs.th.skt.Adapters.logWrite:isDebugMod
   then
      btn-log:LABEL IN FRAME {&FRAME-NAME} = "Выкл. расширеный лог.".
   else
      btn-log:LABEL IN FRAME {&FRAME-NAME} = "Вкл. расширеный лог.".
  
  { gbl/curdbnum.i
      g#db-num
    }
  g#language = 'RUS'.
  run gbl/set-gbl.p
    (input true
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  run gbl/get-gbl.p no-error.
  if error-status:error
  then do:
    message "Ошибка получения глобальный переменных." view-as alert-box.
    return error.
  end.

  logWrite = new LogWrite().          
  sktserv  = new SktServer(this-procedure,us-tmo).
  apply 'choose':U to Btn-st.
  mWork = yes.
  subscribe "write-to-log" anywhere run-procedure "write-to-log-event".
  subscribe "write-to-log-codepage" anywhere run-procedure "write-to-log-event-codepage".
  subscribe "runCDn" anywhere.
  subscribe "runLmStatus" anywhere.
  
  define variable CheckUpd      as class ibs.th.adm.upd.CheckUpd no-undo.
  CheckUpd = new ibs.th.adm.upd.CheckUpd ().
  mAsyncHelper = new ibs.th.file.AsyncHelperth().
  mAsyncHelper:mProcPublish = this-procedure.
  mAsyncHelper:setCurrentUserPasswd().
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:WritelogInter = 5.
  mAsyncHelper:MyBachMode = yes.
  mAsyncHelper:maxproc    = 1.
  run runCDN (1).
  run runLmStatus.
  IF NOT THIS-PROCEDURE:PERSISTENT THEN 
  do while mWork:
     /*  */

     if valid-object(sktserv)
     then
        if sktserv:checkEnd()
           or mAsyncHelper:isWorkShed()
        then do:
           wait-for close of this-procedure pause 0.001.
           mAsyncHelper:WaitForOne(?).	
        end.
        else do:
           if  CheckUpd:isStopWork or CheckUpd:isNeedUpd 
           then do:
              RUN proc-stop-srv.
              mWork = no.
           end.
           else do:
                if valid-handle({&WINDOW-NAME}) then
                  wait-for connect of hServerSocket or choose of Btn-st or close of this-procedure pause 60.
                else
                  wait-for connect of hServerSocket or close of this-procedure pause 60.
           end.
        end.
     else
       wait-for choose of Btn-st or close of this-procedure.
     
  end.
  delete object mAsyncHelper no-error.
  unsubscribe "write-to-log".
  unsubscribe "write-to-log-codePage".
  unsubscribe "runCDN".
  unsubscribe "runLmStatus".  
END.
delete object logWrite.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE connproc C-Win
PROCEDURE connproc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input parameter hSocket as handle no-undo.
  sktserv:connproc(hSocket).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI C-Win  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Delete the WINDOW we created */
  IF SESSION:DISPLAY-TYPE = "GUI":U AND VALID-HANDLE(C-Win)
  THEN DELETE WIDGET C-Win.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI C-Win  _DEFAULT-ENABLE
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
  DISPLAY auto-log mport
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  ENABLE b-help b-exit Btn-st Btn-log auto-log mport
      WITH FRAME DEFAULT-FRAME IN WINDOW C-Win.
  {&OPEN-BROWSERS-IN-QUERY-DEFAULT-FRAME}
  VIEW C-Win.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-start-srv C-Win
PROCEDURE proc-start-srv :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  /*Инициализация сокет-сервера*/
DEF VAR vl-cnt AS LOG NO-UNDO.

CREATE SERVER-SOCKET hServerSocket.

hServerSocket:SET-CONNECT-PROCEDURE ("connProc":U).
vl-cnt = hServerSocket:ENABLE-CONNECTIONS("-S " + string(mPort)) NO-ERROR.
if vl-cnt = NO THEN do:
  RUN write-to-log-event(substitute('Ошибка запуска сервера &1!',error-status:get-message(1) )).
  return.
end.
v-srv-connected = YES.
/* IF VALID-HANDLE(hServerSocket) AND hServerSocket:CONNECTED() THEN */
RUN write-to-log-event(substitute('Запущен сокет-сервер с параметрами: -S &1 ', mPort)).
RUN write-to-log-event(substitute ("http://localhost:&1/help - описание запросов",mPort)).
mport:sensitive  in FRAME DEFAULT-FRAME = false.
btn-st:LABEL IN FRAME {&FRAME-NAME} = 'Стоп'.
sktserv  = new SktServer(this-procedure, us-tmo).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-stop-srv C-Win
PROCEDURE proc-stop-srv :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEF VAR vl-dis AS LOG NO-UNDO.
mport:sensitive  in FRAME DEFAULT-FRAME = true.
vl-dis = hServerSocket:disable-CONNECTIONS() NO-ERROR.
IF NOT vl-dis THEN DO:
  RUN write-to-log-event(substitute('Ошибка остановки сервера &1!',error-status:get-message(1) )).
  return.
END.
DELETE OBJECT sktserv no-error.
DELETE OBJECT hServerSocket no-error.
IF NOT valid-handle(hServerSocket) THEN
RUN write-to-log-event(substitute('Остановлен сокет-сервер (&1)',v-connect-param)).
ELSE RETURN.
v-srv-connected = NO.
btn-st:LABEL IN FRAME {&FRAME-NAME} = 'Старт'.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log-event C-Win
PROCEDURE write-to-log-event :
   DEFINE INPUT PARAMETER itext       AS character NO-UNDO.
   run write-to-log-event-codepage(itext, ?).
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log-event-codepage C-Win
PROCEDURE write-to-log-event-codepage :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER itext       AS character NO-UNDO.
define input parameter iSourcePage as character no-undo.

define variable str as char no-undo.

auto-log:move-to-eof( ) IN FRAME {&FRAME-NAME} NO-ERROR.
if objExists(itext,"F") eq ?
then do:
   str = cur-time-string-msec() + {&tabulation} + itext + {&new-line}.

   auto-log:insert-string( str ) NO-ERROR.
   RUN write-to-log-file(str).
end.
else do:
   def var varfile-str as longchar no-undo.
   
   if  itext ne "filewrireLog.txt"
   then do:
      str = cur-time-string-sec() + {&tabulation} + "Файл: " +  itext + {&new-line}.
      auto-log:insert-string(str) NO-ERROR.
      auto-log:insert-file(search(itext)) no-error.
   end.
   else do:
      str = cur-time-string-sec() + {&new-line}.
      auto-log:insert-string(str) NO-ERROR.
      
      auto-log:insert-file(search(itext)) no-error.
   end.
   if    iSourcePage eq ""
      or iSourcePage eq ?
   then
      copy-lob
         file itext
         to object varfile-str
      no-error.
   else
      copy-lob
         file itext
         to object varfile-str convert source codepage iSourcePage
      no-error.
   RUN write-to-log-file(varfile-str + {&new-line}).
end.

END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log-file C-Win
PROCEDURE write-to-log-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER str-long AS longchar NO-UNDO.
define variable vFileName as character no-undo.
str-long = cur-time-string-msec() + {&tabulation} + str-long + {&new-line} .
vFileName = "sktsrv-" + replace(string(today),"/","-") + ".log".
copy-lob
from object str-long
to file vFileName append
no-error
.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _Procedure RunCdn C-Win
procedure runCdn:
   define input param iTypeUpd as integer no-undo. /* 1 - обновить все площадки, 2 - обновить только время заблокированной более 15 мин */
    
   run utl/runproc-cdn.p ("CDN",this-procedure,iTypeUpd).
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _Procedure runLMStatus C-Win
procedure runLMStatus:
       
   run utl/runproc-lmsts.p ("LM-STATUS",this-procedure).
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
   