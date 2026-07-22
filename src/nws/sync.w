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

/* Parameters Definitions ---                                           */
define input parameter parparentproc  as handle     no-undo .
define input parameter p-dbnum        as integer    no-undo .
/* Local Variable Definitions ---                                       */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Синхронизация новостей".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }
{ gbl/db-attr.i  }
{ gbl/clntattr.i }
{ bge/esysattr.i }
{ gbl/waitfram.i }

define variable p-news as logical no-undo.
define variable v-real-last-sent-pck as integer no-undo .
define variable v-real-last-rcv-pck as integer no-undo .

define variable v-curr-obj-type as character no-undo .
define variable v-curr-obj-code as integer no-undo .

define variable v-corr-date             as date         no-undo.
define variable v-corr-time             as integer      no-undo.

define variable v-cmd-proc-handle as handle no-undo .
define variable v-command as character no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-db-list as character no-undo .

define buffer buf_c-user-log for c-user-log .

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-ok v-last-rcv-pack ~
v-last-sent-pack 
&Scoped-Define DISPLAYED-OBJECTS v-last-rcv-pack v-last-sent-pack 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON b-ok AUTO-GO 
     LABEL "Синхронизация" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE v-last-rcv-pack AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Номер последнего принятого пакета в БД " 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE v-last-sent-pack AS INTEGER FORMAT ">>>>>>9":U INITIAL 0 
     LABEL "Номер последнего отправленного пакета из БД " 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-cancel AT ROW 1.24 COL 2
     b-ok AT ROW 1.24 COL 17
     v-last-rcv-pack AT ROW 3.14 COL 49 COLON-ALIGNED WIDGET-ID 2
     v-last-sent-pack AT ROW 4.33 COL 49 COLON-ALIGNED WIDGET-ID 4
     SPACE(1.79) SKIP(0.95)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Синхронизация новостей для БД " + string(p-dbnum)
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.


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
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Синхронизация новостей для БД  */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-ok Dialog-Frame
ON CHOOSE OF b-ok IN FRAME Dialog-Frame /* синхронизация */
DO:
  
  assign
    v-last-rcv-pack
    v-last-sent-pack
  .
  for each pck-sent no-lock where pck-sent.db-num = p-dbnum :
    v-real-last-sent-pck = max(v-real-last-sent-pck, pck-sent.pack-num) .
  end.
  for each pck-rcvd no-lock where pck-rcvd.db-num = p-dbnum :
    v-real-last-rcv-pck = max(v-real-last-rcv-pck, pck-rcvd.pack-num) .
  end.
  if v-last-rcv-pack > v-real-last-sent-pck
  then do :
    message "Номер последнего принятого пакета в УБД больше номера последнего отправленного пакета в ГБД!" view-as alert-box .
    return no-apply .
  end.
  if v-last-sent-pack > v-real-last-rcv-pck
  then do :
    message "Номер последнего отправленного пакета из УБД больше номера последнего принятого пакета в ГБД!" view-as alert-box .
    return no-apply .
  end.
  if v-last-rcv-pack = v-real-last-sent-pck
  and v-last-sent-pack = v-real-last-rcv-pck
  then do :
    message "Номера последних пакетов в ГБД и УБД совпадают. Синхронизация не требуется." view-as alert-box .
    return no-apply .
  end.
  
  find first ub.clients no-lock where ub.clients.obj-type = {&shop}
                                  and ub.clients.stts = 0
                                  and ub.clients.db-num = p-dbnum
                                  no-error.
  if not available ub.clients
  then do :
    message ("Не найден магазин в УБД " + string(p-dbnum)) view-as alert-box.
    return no-apply .
  end.
  
  for each pck-sent exclusive-lock where pck-sent.db-num = p-dbnum and pck-sent.pack-num > v-last-rcv-pack :
    for each route exclusive-lock where route.db-num = p-dbnum and route.last-pack = pck-sent.pack-num :
      delete route .
    end.
    delete pck-sent .
  end.
  for each pck-rcvd exclusive-lock where pck-rcvd.db-num = p-dbnum and pck-rcvd.pack-num > v-last-sent-pack :
    delete pck-rcvd .
  end. 
  
  for each route exclusive-lock where route.db-num = p-dbnum and route.last-pack = -1 :
    delete route .
  end.
  
  v-curr-obj-type = ub.clients.obj-type .
  v-curr-obj-code = ub.clients.obj-code . 
  
  run waitfram-show in this-procedure ("Формирование данных для синхронизации. Ждите...").
  
  run create-routes no-error.
  if error-status :error then do:
    run write-to-log in this-procedure ( input  return-value ) .
    run waitfram-hide in this-procedure .
    return no-apply .
  end.
  run waitfram-hide in this-procedure .
  
  run trg/userlog.p (
        input 'utl'
        , input ( ("Синхронизация новостей с УБД " + 
                string(p-dbnum) + 
                substitute("; получ_до: &1; получ_после: &2; отпр_до: &3; отпр_после: 4", v-real-last-sent-pck, v-last-rcv-pack, v-real-last-rcv-pck, v-last-sent-pack) ) +
                {&delim-key} + 
                "nws/sync.w")
        , input ?
        , input ?
        , input ""
        ) no-error.
  if error-status :error
  then do:
      message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
  end. 
  
  run write-to-log in this-procedure
  ( input  substitute ("Произведена синхронизация новостей с УБД &1.&2Идентификатор пользователя: &3&2Номер последнего принятого пакета в УБД до синхронизации: &4&2Номер последнего принятого пакета в УБД после синхронизации: &5&2Номер последнего отправленного пакета из УБД до синхронизации: &6&2Номер последнего отправленного пакета из УБД после синхронизации: &7&2",
                        string(p-dbnum),
                        {&new-line},
                        g#auto-user-id,
                        v-real-last-sent-pck,
                        v-last-rcv-pack,
                        v-real-last-rcv-pck,
                        v-last-sent-pack
                         ) ) .
  
  message "Формирование данных для синхронизации закончено. Подготовьте новые пакеты и отправьте их в УБД." view-as alert-box .
  
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
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure create-routes :
  
  find first ub.db no-lock where ub.db.db-num = p-dbnum .
  run nws/cr-route.p ( input {&send-tbl}, input {&table_db}, input (buffer ub.db:handle), input string(p-dbnum) ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  
  for each ub.db-attr no-lock where ub.db-attr.db-num = ub.db.db-num :
    run db-attr-news in this-procedure
      ( input ub.db-attr.attr-code
       ,output p-news
      ) no-error.
  
    if p-news = true then do:
      run nws/cr-route.p ( input {&send-tbl}, input {&table_db-attr}, input (buffer ub.db-attr:handle), input string(p-dbnum) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  
  find first ub.clients no-lock where ub.clients.obj-type = v-curr-obj-type
                                  and ub.clients.obj-code = v-curr-obj-code .
  run nws/cr-route.p ( input {&send-tbl}, input {&table_clients}, input (buffer ub.clients:handle), input string(p-dbnum) ) no-error. 
  if error-status :error then do:
    return error return-value.
  end.
  
  find first ub.shop no-lock where ub.shop.obj-code = ub.clients.obj-code .  
  run nws/cr-route.p ( input {&send-tbl}, input {&table_shop}, input (buffer ub.shop:handle), input string(p-dbnum) ) no-error.
  if error-status :error then do:
    return error return-value.
  end.
  
  for each ub.clients-attr no-lock where  ub.clients-attr.obj-type = ub.clients.obj-type
                                      and ub.clients-attr.obj-code = ub.clients.obj-code :
    run clntattr-news in this-procedure(input ub.clients-attr.attr-code,
                                        output p-news) no-error.
    if  p-news then do:
      run nws/cr-route.p ( input {&send-tbl}, input {&table_clients-attr}, input (buffer ub.clients-attr:handle), input string(p-dbnum) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.                                    
  end.    
  
  for each ub.ext-system no-lock where ub.ext-system.esys-db-num-exp = p-dbnum or ub.ext-system.esys-db-num-imp = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_ext-system}, input (buffer ub.ext-system:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
    
    for each ub.ext-system-attr no-lock where ub.ext-system-attr.esys-id  = ub.ext-system.esys-id
                                          and ub.ext-system-attr.db-num   = ub.ext-system.db-num :
      run ext-system-attr-news in this-procedure ( input ub.Ext-system-attr.esya-attr-code
                                                  ,output p-news). 
      if  p-news then do:                                                                                 
        run nws/cr-route.p ( input {&send-tbl}, input {&table_ext-system-attr}, input (buffer ub.ext-system-attr:handle), input string(p-dbnum) ) no-error. 
        if error-status :error then do:
          return error return-value.
        end.
      end.                                        
    end.
  end.
  
  for each ub.user-login-action-role no-lock where ub.user-login-action-role.db-num = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_user-login-action-role}, input (buffer ub.user-login-action-role:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.  
  
  for each ub.action-role no-lock where ub.action-role.db-num = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_action-role}, input (buffer ub.action-role:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end. 
  
  for each ub.action-role-item no-lock where ub.action-role-item.db-num = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_action-role-item}, input (buffer ub.action-role-item:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.      
  
  for each ub.schedule no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_schedule}, input (buffer ub.schedule:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
    
    for each ub.schedule-attr no-lock where ub.schedule-attr.cre-db-num = ub.schedule.cre-db-num 
                                        and ub.schedule-attr.task-type  = ub.schedule.task-type
                                        and ub.schedule-attr.task-num   = ub.schedule.task-num
                                        and ub.schedule-attr.task-num  <> -1 :
      run nws/cr-route.p ( input {&send-tbl}, input {&table_schedule-attr}, input (buffer ub.schedule-attr:handle), input string(p-dbnum) ) no-error. 
      if error-status :error then do:
        return error return-value.
      end.                                    
    end.                                      
  end. 
  
  for each ub.config no-lock where ub.config.db-num = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_config}, input (buffer ub.config:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.                                                  
  
  for each ub.thbj-attr no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_thbj-attr}, input (buffer ub.thbj-attr:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.clients no-lock :
    if ub.clients.obj-type = v-curr-obj-type and ub.clients.obj-code = v-curr-obj-code
    then next .
    
    run nws/cr-route.p ( input {&send-tbl}, input {&table_clients}, input (buffer ub.clients:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
    
    for each ub.clients-attr no-lock where  ub.clients-attr.obj-type = ub.clients.obj-type
                                        and ub.clients-attr.obj-code = ub.clients.obj-code :
      run clntattr-news in this-procedure(input ub.clients-attr.attr-code,
                                          output p-news) no-error.
      if  p-news then do:
        run nws/cr-route.p ( input {&send-tbl}, input {&table_clients-attr}, input (buffer ub.clients-attr:handle), input string(p-dbnum) ) no-error.
        if error-status :error then do:
          return error return-value.
        end.
      end.                                    
    end. 
  end.
  
  for each ub.pay-type no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_pay-type}, input (buffer ub.pay-type:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.cash-pay no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_cash-pay}, input (buffer ub.cash-pay:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.cash-pay-attr no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_cash-pay-attr}, input (buffer ub.cash-pay-attr:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.                                    
  end.
  
  for each ub.tax no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_tax}, input (buffer ub.tax:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.tax-rate no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_tax-rate}, input (buffer ub.tax-rate:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.tax-rate-value no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_tax-rate-value}, input (buffer ub.tax-rate-value:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.tax-units no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_tax-units}, input (buffer ub.tax-units:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.currency no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_currency}, input (buffer ub.currency:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.curr-bank no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_curr-bank}, input (buffer ub.curr-bank:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.curr-shop no-lock where ub.curr-shop.obj-type = v-curr-obj-type
                                  and ub.curr-shop.obj-code = v-curr-obj-code :
    if Year(ub.curr-shop.exch-date ) <> 9999 then do:
      run nws/cr-route.p ( input {&send-tbl}, input {&table_curr-shop}, input (buffer ub.curr-shop:handle), input string(p-dbnum) ) no-error. 
      if error-status :error then do:
        return error return-value.
      end.
    end.
  end.
  
  for each ub.country no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_country}, input (buffer ub.country:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.regions no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_regions}, input (buffer ub.regions:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.cash-desk no-lock where ub.cash-desk.db-num = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_cash-desk}, input (buffer ub.cash-desk:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.cash-desk-attr no-lock where ub.cash-desk-attr.db-num = p-dbnum :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_cash-desk-attr}, input (buffer ub.cash-desk-attr:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
/*  EXPSD-8369                                                                                                                                   */
/*  for each ub.cashbook no-lock :                                                                                                               */
/*    run nws/cr-route.p ( input {&send-tbl}, input {&table_cashbook}, input (buffer ub.cashbook:handle), input string(p-dbnum) ) no-error.      */
/*    if error-status :error then do:                                                                                                            */
/*      return error return-value.                                                                                                               */
/*    end.                                                                                                                                       */
/*    for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = {&attr-cash-book-id}                                                 */
/*                                            and ub.goods-attr.attr-value = string(ub.cashbook.id):                                             */
/*      run nws/cr-route.p ( input {&send-tbl}, input {&table_goods-attr}, input (buffer ub.goods-attr:handle), input string(p-dbnum) ) no-error.*/
/*      if error-status :error then do:                                                                                                          */
/*        return error return-value.                                                                                                             */
/*      end.                                                                                                                                     */
/*    end.                                                                                                                                       */
/*  end.                                                                                                                                         */
  
  for each ub.cashbookrule no-lock where ub.CashBookRule.Obj-type = v-curr-obj-type
                                     and ub.CashBookRule.Obj-code = v-curr-obj-code :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_cashbookrule}, input (buffer ub.cashbookrule:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.OperServ no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_OperServ}, input (buffer ub.OperServ:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
    for each ub.goods-attr exclusive-lock where ub.goods-attr.attr-code = {&attr-oper-serv-id}
                                            and ub.goods-attr.attr-value = string(ub.OperServ.id):
      run nws/cr-route.p ( input {&send-tbl}, input {&table_goods-attr}, input (buffer ub.goods-attr:handle), input string(p-dbnum) ) no-error. 
      if error-status :error then do:
        return error return-value.
      end.                                        
    end.                                          
  end.
  
  for each ub.OperServAttr no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_OperServAttr}, input (buffer ub.OperServAttr:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
  if error-status :error
  then do:
    delete procedure v-cmd-proc-handle .
    return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                        "&5&4&6"
                                        ,vss-workfile
                                        ,vss-revision
                                        ,vss-description
                                        ,{&new-line}
                                        ,error-status:get-message(1)
                                        ,return-value ).
  end.
  
  define buffer buf_rp-by-call for ub.rp-by-call.
  define buffer buf_rule-by-call for ub.rule-by-call.
  define buffer buf_rule-call-param for ub.rule-call-param.
  
  for each db no-lock
  where db.db-num > 0
  :
    assign
    v-db-list = v-db-list + {&delim-nws} + string(db.db-num).
  end.
  v-db-list = trim(v-db-list, {&delim-nws}).

  for each ub.dis-card-type no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-card-type}, input (buffer ub.dis-card-type:handle), input string(p-dbnum) ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
    assign
    v-command =  substitute("&2&1&3&1&4"
                           , {&delim-cmd}
                           , {&cmd-dct-send}
                           , ub.dis-card-type.emitent-host-code
                           , ub.dis-card-type.type
                           ).
    run begin-create-command in v-cmd-proc-handle
      (input v-command /* p-command-name */
      ,input "":U                /* p-db-list      */
      ,output v-cmd-code        /* p-command-code */
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", {&cmd-dct-send} ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      return error return-value .
    end.
    
    run send-command in v-cmd-proc-handle
      ( input v-cmd-code  /* p-command-code */
        ,input v-db-list
        ) no-error .
    if error-status:error then do:
      delete procedure v-cmd-proc-handle .
      message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при отсылке команды &1", {&cmd-dct-send} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
      return error return-value .
    end.
    
    for each buf_rp-by-call where buf_rp-by-call.call_id = ub.dis-card-type.uniq-key-rec :
      run nws/cr-route.p ( input {&send-tbl}, input {&table_rp-by-call}, input (buffer buf_rp-by-call:handle), input string(p-dbnum) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
    
    for each buf_rule-by-call where buf_rule-by-call.call_id = ub.dis-card-type.uniq-key-rec :
      run nws/cr-route.p ( input {&send-tbl}, input {&table_rule-by-call}, input (buffer buf_rule-by-call:handle), input string(p-dbnum) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
    
    for each buf_rule-call-param where buf_rule-call-param.call_id = ub.dis-card-type.uniq-key-rec :
      run nws/cr-route.p ( input {&send-tbl}, input {&table_rule-call-param}, input (buffer buf_rule-call-param:handle), input string(p-dbnum) ) no-error.
      if error-status :error then do:
        return error return-value.
      end.
    end.
    
  end.
  
  delete procedure v-cmd-proc-handle no-error .
  
  for each ub.dis-card-mask no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-card-mask}, input (buffer ub.dis-card-mask:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.dis-card no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-card}, input (buffer ub.dis-card:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
    run str/saledc.p
        (
          input parparentproc
        ,input this-procedure :handle
        ,input ? /*p-log-handle*/
        ,input {&dct-proc_one-card-add}
        ,input ?  /*p-emitent-host-code*/
        ,input '':U /*p-type*/
        ,input 0 /*p-profile-id*/
        ,input 0 /*p-codex-id*/
        ,input 0 /*p-ruleset-id*/
        ,input g#db-num
        ,input ub.dis-card.d-card
        ,input ? /*doc-date - выставим внутри*/
        ,input ? /*fact-date - выставим внутри*/
        ,input ? /*cre-pay*/
        ,input 1 /*p-sign*/
        ,input 1 /* p-direction */
        ,input yes /*p-save*/
        ) no-error .
    if error-status:error then do:
      return error return-value .
    end.
  end.
  
  for each ub.dis-host no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-host}, input (buffer ub.dis-host:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.dis-card-property no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-card-property}, input (buffer ub.dis-card-property:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.dis-rule no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-rule}, input (buffer ub.dis-rule:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.dis-gds-rule no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-gds-rule}, input (buffer ub.dis-gds-rule:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
  for each ub.dis-time-rule no-lock :
    run nws/cr-route.p ( input {&send-tbl}, input {&table_dis-time-rule}, input (buffer ub.dis-time-rule:handle), input string(p-dbnum) ) no-error. 
    if error-status :error then do:
      return error return-value.
    end.
  end.
  
end procedure .

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
  v-last-rcv-pack:label in FRAME Dialog-Frame = "Номер последнего принятого пакета в БД " + string(p-dbnum) .
  v-last-sent-pack:label in FRAME Dialog-Frame = "Номер последнего отправленного пакета из БД " + string(p-dbnum).
  DISPLAY v-last-rcv-pack v-last-sent-pack 
      WITH FRAME Dialog-Frame.
  ENABLE b-cancel b-ok v-last-rcv-pack v-last-sent-pack 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

