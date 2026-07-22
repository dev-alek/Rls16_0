&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Журнал запросов Меркурий

  Author: 
    Автор: Сливенко
    Дата создания: 
    Author: Slivenko
    Creation date: 

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
using ibs.th.bge.mercury.*.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Журнал запросов Меркурий".

define variable th-journal-mercury     as handle  no-undo.
define variable bh-journal-mercury     as handle  no-undo.
define variable gh-journal-mercury     as handle  no-undo.
define variable browse-hdl-journal-mercury as handle no-undo.
define variable bcol                  as handle no-undo.
define variable bcol1                 as handle no-undo.
define variable bcol2                 as handle no-undo.
define variable bcol3                 as handle no-undo.
define variable bcol4                 as handle no-undo.
define variable bcol5                 as handle no-undo.
define variable mercury              as class mercury   no-undo.
define variable journal              as class Journal no-undo.
define variable v-db-num             as integer   no-undo .
define variable v-user-id            as character no-undo .

define variable v-apiKey              as character no-undo .
define variable v-issuerId            as character no-undo .
define variable v-login               as character no-undo .
define variable v-login_is            as character no-undo .
define variable v-password            as character no-undo .
define variable v-initiator           as character no-undo .
define variable v-type-connect        as integer   no-undo .
define variable v-server              as integer   no-undo .
define variable v-proxy-login         as character no-undo .
define variable v-proxy-pswd          as character no-undo .
define variable v-proxy-addres        as character no-undo .
define variable v-proxy-ssl           as logical   no-undo .

define variable v-appId           as character no-undo .
define variable v-status_         as character no-undo .
define variable v-Msg           as character no-undo .


define buffer buf_ext-classif       for ub.ext-classif .
define buffer buf2_ext-classif      for ub.ext-classif .
define buffer buf_ext-system        for ub.ext-system .
define buffer buf_parts             for ub.parts .
define buffer buf_vsd               for ub.vsd .
define buffer buf_clients           for ub.clients .
define buffer buf_esys-all-attr     for ub.esys-all-attr .

define variable vsdStorage as class vsdtostorage.
define variable vsdsTHObj as class ibs.th.str.mercury.vsdsubs.
define variable vsdTHObj as class ibs.th.str.mercury.vsdsub.
define variable vsdStsType as class ibs.th.str.mercury.vsdstatustype. 
define variable objThObj as clisub.
define variable objKeyRec as keyrec.

define variable v-part-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .

define variable date1 as datetime no-undo .
define variable date2 as datetime no-undo .

define variable ii as integer no-undo.

define variable glog                 as logical   no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i def }
{ ref/extclass.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-browse-journal-mercury}
    
/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel RADIO-SET-1 ~

&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-1 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Выход" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_del 
     LABEL "Удалить" 
     tooltip "Удалить из журнала."
     SIZE 15 BY 1.13.
     
DEFINE BUTTON b-request 
     LABEL "Отпр. запросы" 
     tooltip "Отправить запросы во ФГИС Меркурий"
     SIZE 15 BY 1.13.     
     
DEFINE BUTTON b-response 
     LABEL "Получить ответы" 
     tooltip "Получить ответы на отправленные запросы из ФГИС Меркурий"
     SIZE 16 BY 1.13.       

DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Все", 1,
"Новые", 2,
"Закрытые", 3
     SIZE 50 BY 1.25 NO-UNDO.
     
DEFINE BUTTON btRef 
     LABEL "Обновить" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE v-date-end AS DATE FORMAT "99/99/9999":U 
     LABEL "По" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE v-date-start AS DATE FORMAT "99/99/9999":U 
     LABEL "Дата C" 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1 NO-UNDO.
     
{ gbl/color.i }
{ cmp/library.i  }

/* Browse definitions                                                   */
DEFINE BROWSE BROWSE-Journal-mercury
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-Journal-mercury Dialog-Frame _FREEFORM
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 135 BY 25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 1
     Btn_del AT ROW 1 COL 16.5 WIDGET-ID 6
     b-request at row 1 col 32
     b-response at row 1 col 47.5
     RADIO-SET-1 AT ROW 2.3 COL 1 NO-LABEL WIDGET-ID 2
     v-date-start at row 2.3 col 55
     v-date-end at row 2.3 col 76
     btRef at row 2.15 col 94
     BROWSE-Journal-mercury AT ROW 4 COL 1 WIDGET-ID 200
     SPACE(0.50) SKIP(0.24)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Журнал запросов Меркурий"
         CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.

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
/* BROWSE-TAB BROWSE-Journal-mercury RADIO-SET-1 Dialog-Frame */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Журнал ВСД */
DO:
    delete object journal no-error .
    delete object mercury no-error .
    delete object vsdStorage no-error .
    delete object vsdsTHObj no-error .
    delete object vsdTHObj no-error .
    delete object vsdStsType no-error .
    delete object objThObj no-error .
    delete object objKeyRec no-error .
    
    APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SET-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-1 Dialog-Frame
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-1 .
  run openBR.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btRef
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btRef Dialog-Frame
ON choose OF btRef IN FRAME Dialog-Frame
do:
  assign
    v-date-end
    v-date-start
  .
  date1 = datetime(v-date-start, 0) . 
  date2 = datetime(v-date-end, 86399999) . 
  
  bh-journal-mercury = journal:GetHndlTable(input date1, input date2).
  
  apply "value-changed" to radio-set-1 .
  
end.

&Scoped-define SELF-NAME Btn-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn-del Dialog-Frame
ON choose OF Btn_del IN FRAME Dialog-Frame
DO:

  find first ub.esys-all-attr where (table-name + string (key1) + string (key2) + string (key3) + string (key4) + string (key5) + string (key6) +
        string (key7) + string (key8) + attr-code) = bh-journal-mercury:buffer-field ('piIndex'):buffer-value () no-error.
  if available (ub.esys-all-attr)
    then delete ub.esys-all-attr.
  else return no-apply . 

  if bh-journal-mercury:available
    then bh-journal-mercury:buffer-delete ().
  
  BROWSE-Journal-mercury:refresh ().

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-request
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-request Dialog-Frame
ON choose OF B-request IN FRAME Dialog-Frame
DO:
/*  run gbl/inidebug.p .*/
  
  objThObj = new clisub ().
  vsdStsType = new vsdstatustype().
  clients_ :
  for each clients no-lock where clients.obj-type = {&shop} 
                             and clients.stts = 0 :
    
    { gbl/getsect.i run clients.obj-type clients.obj-code {&attr-mercur} }

    for each thbjattr_thbj-attr :
      case thbjattr_thbj-attr.prop-code :
        when "apikey" then v-apiKey = thbjattr_thbj-attr.property-value-character .
        when "login" then v-login = thbjattr_thbj-attr.property-value-character .
        when "login_is" then v-login_is = thbjattr_thbj-attr.property-value-character .
        when "password" then v-password = thbjattr_thbj-attr.property-value-character .
        when "type-connect" then v-type-connect = thbjattr_thbj-attr.property-value-integer .
        when "server" then v-server = thbjattr_thbj-attr.property-value-integer .
        when "proxy-addres" then v-proxy-addres = thbjattr_thbj-attr.property-value-character .
        when "proxy-login" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
            {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-login no-error}
          end.
        end. 
        when "proxy-pswd" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
            {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-pswd no-error}
          end.
        end. 
        when "proxy-ssl" then v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .
      end case.
    end.
    
    if v-type-connect = 1 and v-cntxt-db-num <> 0 and v-cntxt-db-num <> clients.db-num
    then do :
      next clients_.
    end.
    
    if v-cntxt-db-num <> 0 and v-type-connect = 2
    then do :
      next clients_.
    end.
    
    if v-cntxt-db-num = 0 and v-type-connect = 1 and clients.db-num <> 0
    then do :
      next clients_.
    end.
    
    find first buf_ext-classif no-lock 
          where buf_ext-classif.classif-subject = {&table_clients}
            and buf_ext-classif.classif-name = {&extclass_clients_esys}
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = buf_ext-system.esys-id
            and buf_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + "орг" + {&delim-key} + string (clients.host-code)
            no-error.    
    if not available buf_ext-classif
    then do :
      message "Фирма орг" string (clients.host-code) " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" view-as alert-box .
      next clients_.
    end.        
    v-issuerId = entry(1, buf_ext-classif.charKey_Two, {&delim-cmd}) .        
    mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, clients.db-num).
    
    objThObj:ObjType = clients.obj-type.
    objThObj:ObjCode = clients.obj-code.
    vsdsTHObj = new vsdsubs ().
    vsdStorage = new vsdtostorage ().
    vsdsTHObj = vsdStorage:getVSDsubs(input objThObj).

/*    delete object objThObj no-error .*/

    find first buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = {&table_clients}
          and buf_ext-classif.classif-name = {&extclass_clients_esys}
          and buf_ext-classif.db-num = 0
          and buf_ext-classif.key#_one = buf_ext-system.esys-id
          and buf_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + clients.obj-type + {&delim-key} + string (clients.obj-code)
          no-error.

    vsd_ :
    do ii = 1 to vsdsTHObj:GetItem (ii):
      
      if ii = 1 and not available buf_ext-classif
      then do :
        message "Объект маг" string (clients.obj-code) " не синхронизирован с ФГИС Меркурий (Нет GUID'а предприятия)" view-as alert-box .
        next clients_.
      end.
      
      if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedCheck /* Требует проверки */
      or vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck /* Ошибка проверки */
      or vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrUtilized /* Ошибка гашения */
      then do :
        
        if vsdsTHObj:VsdObjCurr:UUID = "" or vsdsTHObj:VsdObjCurr:UUID = ? or vsdsTHObj:VsdObjCurr:FactDatetime = ? then next .
        find first buf2_ext-classif no-lock
            where buf2_ext-classif.classif-subject = {&table_clients}
              and buf2_ext-classif.classif-name = {&extclass_clients_esys}
              and buf2_ext-classif.db-num = 0
              and buf2_ext-classif.key#_one = buf_ext-system.esys-id
              and buf2_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + vsdsTHObj:VsdObjCurr:CliType + {&delim-key} + string (vsdsTHObj:VsdObjCurr:CliCode)
              no-error. 
        if not available buf2_ext-classif
        then do :
          vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
          vsdsTHObj:VsdObjCurr:MsgErr = "Контрагент-поставщик не синхронизирован с ФГИС Меркурий." .
          vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
          message "UUID ВСД: " vsdsTHObj:VsdObjCurr:UUID skip "Контрагент-поставщик не синхронизирован с ФГИС Меркурий." skip "Запрос не отправлен." view-as alert-box .
          next vsd_.
        end. 
        else do :
          if num-entries(buf2_ext-classif.charKey_Two, {&delim-cmd}) = 2
          then do :
            if entry(1, buf2_ext-classif.charKey_Two, {&delim-cmd}) = ""
            or entry(2, buf2_ext-classif.charKey_Two, {&delim-cmd}) = ""
            then do :
              if vsdsTHObj:VsdObjCurr:CliType = 'маг'
              then do :
                if entry(2, buf2_ext-classif.charKey_Two, {&delim-cmd}) = ""
                then do :
                  vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
                  vsdsTHObj:VsdObjCurr:MsgErr = "Не заполнен GUID предприятия поставщика." .
                  vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
                  message "UUID ВСД: " vsdsTHObj:VsdObjCurr:UUID skip "Не заполнены GUID предприятия поставщика." skip "Запрос не отправлен." view-as alert-box .
                  next vsd_.
                end.
              end.
              else do :
                vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
                vsdsTHObj:VsdObjCurr:MsgErr = "Не заполнены GUID'ы хоз. субъекта поставщика и/или предприятия поставщика." .
                vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
                message "UUID ВСД: " vsdsTHObj:VsdObjCurr:UUID skip "Не заполнены GUID'ы хоз. субъекта поставщика и/или предприятия поставщика." skip "Запрос не отправлен." view-as alert-box .
                next vsd_.
              end.
            end .
          end.
          else do :
            vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
            vsdsTHObj:VsdObjCurr:MsgErr = "Не верный формат связки поставщика с ФГИС Меркурий" .
            vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
            message "UUID ВСД: " vsdsTHObj:VsdObjCurr:UUID skip "Не верный формат связки поставщика с ФГИС Меркурий" skip "Запрос не отправлен." view-as alert-box .
            next vsd_.
          end.
        end.   
          
        find first ub.esys-all-attr no-lock where ub.esys-all-attr.table-name = "esys-pck-sent"
                                              and ub.esys-all-attr.attr-code = "mercury"
                                              and ub.esys-all-attr.attr-value = vsdsTHObj:VsdObjCurr:UUID
                                              and ub.esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID
                                              and ub.esys-all-attr.key2 = 1
                                              and ub.esys-all-attr.key3 = "Запрос отправлен"
                                              no-error .
        if available ub.esys-all-attr then next vsd_ .
        
        mercury:GetVetDocumentByUuid(LC(vsdsTHObj:VsdObjCurr:UUID), entry(2, buf_ext-classif.charKey_Two, {&delim-cmd}), v-appId, v-status_, v-Msg) .
        if v-status_ <> "ACCEPTED"
        then do :
          v-Msg = trim(trim(v-Msg, chr(10))) .
          if v-Msg = "" then v-Msg = "Нет связи со шлюзом Ветис.Api. Попробуйте повторить позже..." .
          message v-Msg view-as alert-box .
          next vsd_ .
        end .
        create ub.esys-all-attr .
        assign
          ub.esys-all-attr.table-name = "esys-pck-sent"
          ub.esys-all-attr.attr-code = "mercury"
          ub.esys-all-attr.key3 = "Запрос отправлен"
          ub.esys-all-attr.key4 = string(now)
          ub.esys-all-attr.key7 = v-appId
          ub.esys-all-attr.key2 = 1
          ub.esys-all-attr.key8 = v-cntxt-userid
        .
        ub.esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID .
        ub.esys-all-attr.attr-value = LC(vsdsTHObj:VsdObjCurr:UUID) .
        
      end.
      
      if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedUtilized /* К гашению */
      then do :
        if vsdsTHObj:VsdObjCurr:UUID = "" or vsdsTHObj:VsdObjCurr:UUID = ? or vsdsTHObj:VsdObjCurr:FactDatetime = ? then next .
      
        find first ub.esys-all-attr no-lock where ub.esys-all-attr.table-name = "esys-pck-sent"
                                              and ub.esys-all-attr.attr-code = "mercury"
                                              and ub.esys-all-attr.attr-value = vsdsTHObj:VsdObjCurr:UUID
                                              and ub.esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID
                                              and ub.esys-all-attr.key2 = 2
                                              and ub.esys-all-attr.key3 = "Запрос отправлен"
                                              no-error .
        if available ub.esys-all-attr then next vsd_ .
        
        objKeyRec = new keyrec () .
        objKeyRec:GenRowKeyr(vsdsTHObj:VsdObjCurr:PartKey, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
        delete object objKeyRec no-error .
        find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error. 
        if not available buf_parts
        then do :
          message "ВСД с UUID "  vsdsTHObj:VsdObjCurr:UUID  " не привязана к партии!!!" view-as alert-box.
          next vsd_.
        end. 
        mercury:processIncomingConsignment(vsdsTHObj, buf_parts.qnty, buf_parts.fact-qnty, v-appId, v-status_, v-Msg) .
        if v-status_ <> "ACCEPTED"
        then do :
          v-Msg = trim(trim(v-Msg, chr(10))) .
          if v-Msg = "" then v-Msg = "Нет связи со шлюзом Ветис.Api. Попробуйте повторить позже..." .
          message v-Msg view-as alert-box .
          next vsd_ .
        end .
        create ub.esys-all-attr .
        assign
          ub.esys-all-attr.table-name = "esys-pck-sent"
          ub.esys-all-attr.attr-code = "mercury"
          ub.esys-all-attr.key3 = "Запрос отправлен"
          ub.esys-all-attr.key4 = string(now)
          ub.esys-all-attr.key7 = v-appId
          ub.esys-all-attr.key2 = 2
          ub.esys-all-attr.key8 = v-cntxt-userid
        .
        ub.esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID .
        ub.esys-all-attr.attr-value = LC(vsdsTHObj:VsdObjCurr:UUID) .
      end.
    end.
    
    delete object vsdsTHObj .
    delete object vsdStorage .
    
    
    delete object mercury no-error .
    
  end.
  
  delete object objThObj no-error . 
  delete object vsdStsType no-error . 
  
  assign
    v-date-end
    v-date-start
  .
  date1 = datetime(v-date-start, 0) . 
  date2 = datetime(v-date-end, 86399999) .
  
  bh-journal-mercury = journal:GetHndlTable(input date1, input date2).
  RUN openBR.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME B-response
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-response Dialog-Frame
ON choose OF b-response IN FRAME Dialog-Frame
DO:
/*  run gbl/inidebug.p .*/
  for each ub.esys-all-attr exclusive-lock where ub.esys-all-attr.table-name = "esys-pck-sent"
                                              and ub.esys-all-attr.attr-code = "mercury"
                                              and ub.esys-all-attr.key3 = "Запрос отправлен" :
    find first buf_vsd no-lock where buf_vsd.UUID = ub.esys-all-attr.attr-value no-error.
    if not available buf_vsd then next .
    
    { gbl/getsect.i run buf_vsd.obj-type buf_vsd.obj-code {&attr-mercur} }

    for each thbjattr_thbj-attr :
      case thbjattr_thbj-attr.prop-code :
        when "apikey" then v-apiKey = thbjattr_thbj-attr.property-value-character .
        when "login" then v-login = thbjattr_thbj-attr.property-value-character .
        when "login_is" then v-login_is = thbjattr_thbj-attr.property-value-character .
        when "password" then v-password = thbjattr_thbj-attr.property-value-character .
        when "type-connect" then v-type-connect = thbjattr_thbj-attr.property-value-integer .
        when "server" then v-server = thbjattr_thbj-attr.property-value-integer .
        when "proxy-addres" then v-proxy-addres = thbjattr_thbj-attr.property-value-character .
        when "proxy-login" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
            {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-login no-error}
          end.
        end. 
        when "proxy-pswd" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
            {gbl/pdecrypt.i thbjattr_thbj-attr.property-value-character v-proxy-pswd no-error}
          end.
        end. 
        when "proxy-ssl" then v-proxy-ssl = thbjattr_thbj-attr.property-value-logical .
      end case.
    end.
    
    if v-cntxt-db-num <> 0 and v-type-connect = 2
    then do :
      next.
    end.
    
    find first buf_clients no-lock where buf_clients.obj-type = buf_vsd.obj-type and buf_clients.obj-code = buf_vsd.obj-code .
    
    if v-type-connect = 1 and v-cntxt-db-num <> 0 and v-cntxt-db-num <> buf_clients.db-num
    then do :
      next.
    end.
    
    if v-cntxt-db-num = 0 and v-type-connect = 1 and buf_clients.db-num <> 0
    then do :
      next.
    end.
    
    find first buf_ext-classif no-lock 
          where buf_ext-classif.classif-subject = {&table_clients}
            and buf_ext-classif.classif-name = {&extclass_clients_esys}
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = buf_ext-system.esys-id
            and buf_ext-classif.uniq-key-rec = {&table_clients} + {&delim-key} + "орг" + {&delim-key} + string (buf_clients.host-code)
            no-error.  
    if not available buf_ext-classif
    then do :
      message "Фирма орг" string (buf_clients.host-code) " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" view-as alert-box .
      next.
    end. 
      
    v-issuerId = entry(1, buf_ext-classif.charKey_Two, {&delim-cmd}) .        
    mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, buf_clients.db-num).
    mercury:vsdId = ub.esys-all-attr.key1.  
  
    case ub.esys-all-attr.key2 :  
      when 1
      then do :  
        objKeyRec = new keyrec () .
        find first buf_vsd no-lock where buf_vsd.UUID = ub.esys-all-attr.attr-value and buf_vsd.ID =  ub.esys-all-attr.key1 no-error.
        if not available buf_vsd then next .
        objKeyRec:GenRowKeyr(buf_vsd.part-key, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
        delete object objKeyRec no-error .
        find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error. 
        if not available buf_parts
        then do :
          objKeyRec = new keyrec () .
          true_vsd_:
          for each buf_vsd no-lock where buf_vsd.UUID = ub.esys-all-attr.attr-value and buf_vsd.ID =  ub.esys-all-attr.key1 :
            objKeyRec:GenRowKeyr(buf_vsd.part-key, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
            find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error.
            if available buf_parts
            then do :
              leave true_vsd_ .
            end.
          end.
          delete object objKeyRec no-error .
        end.
        if not available buf_parts
        then do :
          message "ВСД с UUID "  ub.esys-all-attr.attr-value  " не привязана к партии!!!" view-as alert-box.
          next.
        end.   
        if not valid-object(vsdStsType) then vsdStsType = new vsdstatustype () .      
        mercury:receiveVetDoc(input ub.esys-all-attr.key7, input LC(ub.esys-all-attr.attr-value), input buf_parts.qnty, input buf_parts.fact-qnty, input (buf_vsd.status_ = vsdStsType:IsUtilized), output v-Status_, output v-Msg) . 
        if v-Status_ = "COMPLETED"
        then ub.esys-all-attr.key3 = "Ответ получен" .
        else do :
          v-Msg = trim(trim(v-Msg, chr(10))) .
          if v-Msg = ""
          then do :
            v-Msg = "Нет связи со шлюзом Ветис.Api. Попробуйте повторить позже..." .
            message v-Msg view-as alert-box .
          end.  
          else do :
            ub.esys-all-attr.key3 = "Запрос отклонён" .
            message "UUID ВСД:  " ub.esys-all-attr.attr-value skip v-Msg view-as alert-box.
          end.  
        end.
      end.
      when 2
      then do :   
        mercury:receiveIncomingConsignmentResponse(input ub.esys-all-attr.key7, input ub.esys-all-attr.attr-value, output v-Status_, output v-Msg) . 
        if v-Status_ = "COMPLETED"
        then ub.esys-all-attr.key3 = "Ответ получен" .
        else do :
          v-Msg = trim(trim(v-Msg, chr(10))) .
          if v-Msg = ""
          then do :
            v-Msg = "Нет связи со шлюзом Ветис.Api. Попробуйте повторить позже..." .
            message v-Msg view-as alert-box .
          end.  
          else do :
            ub.esys-all-attr.key3 = "Запрос отклонён" .
            if v-Msg = "MERC14561"
            or v-Msg = "MERC14562"
            or v-Msg = "MERC14563"
            then
              message "UUID ВСД:  " ub.esys-all-attr.attr-value skip "Ошибка наименования продукции " v-Msg ". ВСД будет погашено с актом несоответсвия." view-as alert-box.
            else
            if v-Msg = "MERC14258"
            or v-Msg = "MERC14537"
            then
              message "UUID ВСД:  " ub.esys-all-attr.attr-value skip "Ошибка номера партии/ТТН " v-Msg ". ВСД будет погашено с актом несоответсвия." view-as alert-box.
            else  
              message "UUID ВСД:  " ub.esys-all-attr.attr-value skip v-Msg view-as alert-box.
          end. 
        end.
      end.  
    end case.                               
  
    delete object mercury no-error .
  
  end.
  
  delete object vsdStsType no-error .
  
  assign
    v-date-end
    v-date-start
  .
  date1 = datetime(v-date-start, 0) . 
  date2 = datetime(v-date-end, 86399999) .
  
  bh-journal-mercury = journal:GetHndlTable(input date1, input date2).
  RUN openBR.
  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define BROWSE-NAME BROWSE-Journal-mercury
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
      { gbl/getcurus.i
        v-db-num
        v-user-id
        no-error
      }
      

  { gbl/diasize.i &browse-name=BROWSE-Journal-mercury }
  run diasize_init in this-procedure .

  
  find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-mercury}) no-error.
  if not available buf_ext-system
  then do :
    message "Нет внешней системы с типом Меркурий." view-as alert-box .
    return .
  end.
  
  assign
    v-date-end = today
    v-date-start = today
  .
  
  date1 = datetime(v-date-start, 0) . 
  date2 = datetime(v-date-end, 86399999) .
  
  SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").

  journal = new Journal().
  
  
  bh-journal-mercury = journal:GetHndlTable(input date1, input date2).


  create query gh-journal-mercury.


  gh-journal-mercury:SET-BUFFERS (bh-journal-mercury ).
  BROWSE-Journal-mercury:QUERY = gh-journal-mercury.


  do ii = 1 to bh-journal-mercury:num-fields - 1:
     bcol = browse-journal-mercury:add-like-column('tt_journal-merc' + '.' + bh-journal-mercury:buffer-field (ii):name, 0, 'FILL-IN').
  end.  
          bcol1 = browse-journal-mercury:get-browse-column(1).
          
          bcol2 = browse-journal-mercury:get-browse-column(2).
          
          bcol3 = browse-journal-mercury:get-browse-column(3).

          bcol4 = browse-journal-mercury:get-browse-column(4).
          
          bcol5 = browse-journal-mercury:get-browse-column(5).
          
  on row-display of browse-journal-mercury IN FRAME Dialog-Frame  /* - */
  DO:
    if bh-journal-mercury:buffer-field ("jou-status"):buffer-value  = "Запрос отправлен" then do:
        bcol1:bgcolor = YELLOW_COLOR.
        bcol2:bgcolor = YELLOW_COLOR.
        bcol3:bgcolor = YELLOW_COLOR.
        bcol4:bgcolor = YELLOW_COLOR.
        bcol:bgcolor  = YELLOW_COLOR .
        bcol5:bgcolor = YELLOW_COLOR .  
    end.
    if bh-journal-mercury:buffer-field ("jou-status"):buffer-value  = "Запрос отклонён" then do:
        bcol1:bgcolor = RED_COLOR.
        bcol2:bgcolor = RED_COLOR.
        bcol3:bgcolor = RED_COLOR.
        bcol4:bgcolor = RED_COLOR.
        bcol:bgcolor  = RED_COLOR .
        bcol5:bgcolor = RED_COLOR .  
    end.
  end.   


  RUN enable_UI.  
  
  run openBr .

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
  DISPLAY RADIO-SET-1 v-date-end v-date-start
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_del RADIO-SET-1 b-request b-response btRef v-date-end v-date-start
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  ENABLE BROWSE-journal-mercury 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure openBr :
  
  case RADIO-SET-1 :
    when 1  then do:
          gh-journal-mercury:SET-BUFFERS (bh-journal-mercury).
          gh-journal-mercury:query-prepare ("for each tt_journal-merc by tt_journal-merc.jou-time desc").
          gh-journal-mercury:QUERY-OPEN.
    end.
    when 2  then do:
          gh-journal-mercury:SET-BUFFERS (bh-journal-mercury).
          gh-journal-mercury:query-prepare ("for each tt_journal-merc where tt_journal-merc.jou-status = 'Запрос отправлен'  by tt_journal-merc.jou-time desc").
          gh-journal-mercury:QUERY-OPEN.
    end.
    when 3 then do:
          gh-journal-mercury:SET-BUFFERS (bh-journal-mercury).
          gh-journal-mercury:query-prepare ("for each tt_journal-merc where tt_journal-merc.jou-status = 'Ответ получен'  by tt_journal-merc.jou-time desc").
          gh-journal-mercury:QUERY-OPEN.
    end.
  end.
  
end procedure .

