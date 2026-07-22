&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases 
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

  File: reload-1C.w

  Description: Перевыгрузка не подтвержденных сообщений 1С

  Автор: Ростовцев Александр
  Дата создания: 09/07/2025
  Author: Aleksandr Rostovtsev
  Creation date: 09/07/2025
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ручной режим работы OpenXML".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ utl/tt-test-1c.i new}

define temp-table ttMess 
  field fCheck as logical init no
  field fMess  as character
  field fCount as integer
.

define temp-table ttLoaded no-undo
  field fMess as character
  field fKey as character
  index pi fMess fKey
.

output stream vProtTest to terminal.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-mess

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ttMess

/* Definitions for BROWSE BROWSE-mess                                   */
&Scoped-define FIELDS-IN-QUERY-BROWSE-mess ttMess.fCheck ttMess.fMess ttMess.fCount   
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-mess   
&Scoped-define SELF-NAME BROWSE-mess
&Scoped-define QUERY-STRING-BROWSE-mess FOR EACH ttMess
&Scoped-define OPEN-QUERY-BROWSE-mess OPEN QUERY {&SELF-NAME} FOR EACH ttMess.
&Scoped-define TABLES-IN-QUERY-BROWSE-mess ttMess
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-mess ttMess


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-mess}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-mark b-mark-all b-exit b-load BROWSE-mess 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 13 BY 1.14.

DEFINE BUTTON b-load 
     LABEL "Перевыгрузить" 
     SIZE 18 BY 1.14.

DEFINE BUTTON b-mark 
     LABEL "*" 
     SIZE 4 BY 1.19.

DEFINE BUTTON b-mark-all 
     LABEL "Все *" 
     SIZE 8 BY 1.19.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BROWSE-mess FOR 
      ttMess SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-mess
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-mess Dialog-Frame _FREEFORM
  QUERY BROWSE-mess DISPLAY
      ttMess.fCheck column-label "*" format "*/"
ttMess.fMess  column-label "Сообщение"  format "X(20)" width 40
ttMess.fCount column-label "Количество" format ">>>,>>9"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 66 BY 10.48 ROW-HEIGHT-CHARS .57 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-mark AT ROW 1.43 COL 16.8 WIDGET-ID 2
     b-mark-all AT ROW 1.43 COL 21.6 WIDGET-ID 4
     b-exit AT ROW 1.48 COL 3.2 WIDGET-ID 8
     b-load AT ROW 1.48 COL 51 WIDGET-ID 6
     BROWSE-mess AT ROW 3.38 COL 3 WIDGET-ID 200
     SPACE(2.19) SKIP(1.13)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Перевыгрузка в 1С" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB BROWSE-mess b-load Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BROWSE-mess
/* Query rebuild information for BROWSE BROWSE-mess
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH ttMess
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BROWSE-mess */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Перевыгрузка в 1С */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&Scoped-define SELF-NAME b-load
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-load Dialog-Frame
ON CHOOSE OF b-load IN FRAME Dialog-Frame /* Перевыгрузить */
DO:
  define variable vCnt  as int64     no-undo.
  define variable vMess as character no-undo.
  
  define buffer b-ttMess for ttMess.
  
  for each b-ttMess where b-ttMess.fCheck:
    vMess = substitute("&1,&2", vMess, b-ttMess.fMess).  
  end.
  
  if vMess = "" then
  do:
    message "Не выбраны сообщения для перевыгрузки." view-as alert-box.
    return no-apply.  
  end.
  vMess = substring(vMess,2).
  
  message 
    "Сейчас из не подтвержденных пакетов будут удалены сообщения " 
    vMess " и перевыгружены в 1С." skip 
    "Вы уверены?"
    view-as alert-box question buttons yes-no update vLog as logical.
  
  if not vLog then
    return no-apply.
     
  run reLoad in this-procedure (output vCnt).
  
  if vCnt > 0 then
  do:
    message "Перевыгружено" vCnt "сообщений." view-as alert-box.
    run reopen in this-procedure.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
  if available ttMess then 
  do:
    ttMess.fCheck = not ttMess.fCheck.

    reposition {&browse-name} forwards 0.
    {&browse-name}:refresh() .
    apply "entry" to {&browse-name} in frame {&frame-name}.
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark-all Dialog-Frame
ON CHOOSE OF b-mark-all IN FRAME Dialog-Frame /* Все * */
DO:
  define buffer b-ttMess for ttMess.

  if not can-find(first b-ttMess where not ttMess.fCheck) then
  do:
    /* все отмечены. снимаем */
    for each b-ttMess:
      b-ttMess.fCheck = no.
    end.
  end.
  else 
  do:
    for each b-ttMess:
      b-ttMess.fCheck = yes.
    end.
  end.
  
  {&browse-name}:refresh().
  reposition {&browse-name} to row 1.
  apply "entry" to {&browse-name} in frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME BROWSE-mess
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
  run createTT in this-procedure.
  
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CreateTT Dialog-Frame 
PROCEDURE CreateTT :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

define buffer buf_esys-pck-sent   for ub.esys-pck-sent.
define buffer buf_esys-route      for ub.esys-route.
define buffer buf_esys-route-dump for ub.esys-route-dump.

for each buf_esys-pck-sent where
         buf_esys-pck-sent.esps-rcvd = no
    no-lock,
    each buf_esys-route where
         buf_esys-route.esys-id       = buf_esys-pck-sent.esys-id 
     and buf_esys-route.db-num        = buf_esys-pck-sent.db-num 
     and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
    no-lock,
    first buf_esys-route-dump where
          buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
      and buf_esys-route-dump.esrd-dump-name <> "sales-p-shifts" /* чеки по смене не показываем, они выгрузятся с shifts */
      and buf_esys-route-dump.esrd-uniq-key-rec <> ""
      and num-entries(buf_esys-route-dump.esrd-uniq-key-rec,{&delim-key}) > 1
    no-lock
    break by buf_esys-route-dump.esrd-dump-name:
  accum esys-route-dump.esrd-dump-ord (count by buf_esys-route-dump.esrd-dump-name).
  if last-of(buf_esys-route-dump.esrd-dump-name) then
  do:
    create ttMess.
    assign
      ttMess.fMess  = buf_esys-route-dump.esrd-dump-name
      ttMess.fCount = accum count by buf_esys-route-dump.esrd-dump-name esys-route-dump.esrd-dump-ord
    .
  end.
end.

END PROCEDURE.

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
  ENABLE b-mark b-mark-all b-exit b-load BROWSE-mess 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reLoad Dialog-Frame 
PROCEDURE reLoad :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  define output parameter oCnt as int64 no-undo.

  define variable vTable   as character no-undo.
  define variable vUtil    as character no-undo.
  define variable vMess    as character no-undo.
  define variable vBuf     as handle    no-undo. 
  define variable vLoad    as logical   no-undo. 

  define buffer buf_esys-pck-sent    for ub.esys-pck-sent.
  define buffer buf_esys-route       for ub.esys-route.
  define buffer buf1_esys-route      for ub.esys-route.
  define buffer buf_esys-route-dump  for ub.esys-route-dump.
  define buffer buf1_esys-route-dump for ub.esys-route-dump.
  define buffer b-ttMess for ttMess.
  
  empty temp-table ttLoaded. 
  
  for each buf_esys-pck-sent where
         buf_esys-pck-sent.esps-rcvd = no
    exclusive-lock,
    each buf_esys-route where
         buf_esys-route.esys-id       = buf_esys-pck-sent.esys-id 
     and buf_esys-route.db-num        = buf_esys-pck-sent.db-num 
     and buf_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
    exclusive-lock,
    first buf_esys-route-dump where
          buf_esys-route-dump.esrd-dump-ord = buf_esys-route.esr-dump-ord
      and buf_esys-route-dump.esrd-uniq-key-rec  <> ""
      and num-entries(buf_esys-route-dump.esrd-uniq-key-rec,{&delim-key}) > 1
    exclusive-lock:

    
    vLoad = false. 
    if can-find(first b-ttMess where 
                      b-ttMess.fMess = buf_esys-route-dump.esrd-dump-name
                  and b-ttMess.fCheck) then 
    do:
      /* проверим, что это сообщение еще не выгружалось */
      find first ttLoaded no-lock where 
                 ttLoaded.fMess = buf_esys-route-dump.esrd-dump-name
             and ttLoaded.fKey  = buf_esys-route-dump.esrd-uniq-key-rec
           no-error.
      if not avail ttLoaded then
      do:
          assign
            vTable    = entry(1,buf_esys-route-dump.esrd-uniq-key-rec,{&delim-key})
            testId = to-rowid(entry(2,buf_esys-route-dump.esrd-uniq-key-rec,{&delim-key}))
            vUtil = ""
            vMess = ""
            vLoad = true.
          .
          case buf_esys-route-dump.esrd-dump-name:
          when "trn-gd-docs" or
          when "trn-fuel-docs" or
          when "inv-gd-docs" or
          when "peres-gd-docs" then
            if vTable = "fbr-doc" then
              vUtil = "send6c.p".
            else 
              vUtil = "send1c.p".
          when "shifts" or
          when "sales-p-shifts" then
            vUtil = "send2c.p".
          when "check-fuel-docs" then
            vUtil = "send3c.p".
          when "price-docs" then
            vUtil = "send4c.p".
          when "cash" then
            vUtil = "send5c.p".
          when "edi-docs" then
            vUtil = "send7c.p".
          when "tanks" then
            vUtil = "send9c.p".
          when "shift-periods" then
            vUtil = "send10c.p".
          end case.
          
          if vUtil <> "" then 
          do:
            run value("utl/" + vUtil) no-error.
          end.
          else
          do:
            case buf_esys-route-dump.esrd-dump-name:
            when "DT-seasons" then
              vMess = "DTSeasons".
            end case.
            
            if vMess <> "" then do:
                create buffer vBuf for table vTable.
                vBuf:find-by-rowid(testId,no-lock).
                run bge\send1cerp.p (?,
                  this-procedure,
                  this-procedure,
                  vMess,
                  vBuf,
                  ?,
                  ?) no-error.
            end.
            else   
              message "Сообщение" buf_esys-route-dump.esrd-dump-name "не может быть отправлено повторно" skip
                      "Не определена процедура отправки." view-as alert-box.
          end.
      end.
      if not error-status:error then
      do:
        /* добавим выгруженное сообщение в temp-table, чтобы потом еще раз не выгружать */
        if not avail ttLoaded then
        do:
          create ttLoaded.
          assign
            ttLoaded.fMess = buf_esys-route-dump.esrd-dump-name
            ttLoaded.fKey  = buf_esys-route-dump.esrd-uniq-key-rec
          .
        end.
        if buf_esys-route-dump.esrd-dump-name = "shifts" then do:
          /* если перевыгружалась смена, то удалим из этого пакета и чеки по смене */
          for each buf1_esys-route where
                   buf1_esys-route.esys-id       = buf_esys-pck-sent.esys-id 
               and buf1_esys-route.db-num        = buf_esys-pck-sent.db-num 
               and buf1_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
              exclusive-lock,
              first buf1_esys-route-dump where
                    buf1_esys-route-dump.esrd-dump-ord = buf1_esys-route.esr-dump-ord
                and buf1_esys-route-dump.esrd-dump-name = "sales-p-shifts" 
                and buf1_esys-route-dump.esrd-uniq-key-rec = buf_esys-route-dump.esrd-uniq-key-rec
              exclusive-lock:
            oCnt = oCnt + if vLoad then 1 else 0.
            delete buf1_esys-route-dump.
            delete buf1_esys-route.
            buf_esys-pck-sent.esps-total-recs = buf_esys-pck-sent.esps-total-recs - 1. 
          end.
        end.
        oCnt = oCnt + if vLoad then 1 else 0.
        delete buf_esys-route-dump.
        delete buf_esys-route.
        assign
          /* уменьшаем кол-во сообщений в пакете и чистим дату и время формирования txt-файла, чтобы он при следующем автозапуске переформировался */
          buf_esys-pck-sent.esps-total-recs = buf_esys-pck-sent.esps-total-recs - 1
          buf_esys-pck-sent.esps-SendTxtDate = ?
          buf_esys-pck-sent.esps-SendTxtTime = ""
          buf_esys-pck-sent.esps-SendTxtTimeInt = 0
        .
        /* если в пакете не осталось сообщений, то удаляем пакет */
        if not can-find (first buf1_esys-route where
                               buf1_esys-route.esys-id       = buf_esys-pck-sent.esys-id 
                           and buf1_esys-route.db-num        = buf_esys-pck-sent.db-num 
                           and buf1_esys-route.esr-last-pack = buf_esys-pck-sent.esps-pack-num
                        ) then
        do:
          delete buf_esys-pck-sent.
        end.
      end.
      else do:
        message "Ошибка при отправке сообщения" buf_esys-route-dump.esrd-dump-name " процедурой " vUtil skip
                 error-status:get-message(1) view-as alert-box.
      end.
    end.   /* if can-find */
  end.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen Dialog-Frame 
PROCEDURE reopen :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/

close query {&browse-name}.
empty temp-table ttMess.
run createTT in this-procedure.
{&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
reposition {&browse-name} to row 1.
apply "entry" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

