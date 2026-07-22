using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
using ibs.th.bge.mercury.*.
define input parameter parparentproc as widget-handle no-undo .
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
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
DEFINE BROWSE BROWSE-Journal-mercury
    WITH NO-ROW-MARKERS SEPARATORS SIZE 135 BY 25.
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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
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
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
  assign RADIO-SET-1 .
  run openBR.
END.
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
ON choose OF B-request IN FRAME Dialog-Frame
DO:
  objThObj = new clisub ().
  vsdStsType = new vsdstatustype().
  clients_ :
  for each clients no-lock where clients.obj-type = 'маг':U
                             and clients.stts = 0 :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input clients.obj-type
  ,input clients.obj-code
  ,input 'mercur':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
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
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-login
  ) no-error .
          end.
        end.
        when "proxy-pswd" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-pswd
  ) no-error .
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
          where buf_ext-classif.classif-subject = 'clients':U
            and buf_ext-classif.classif-name = 'clients-esys':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = buf_ext-system.esys-id
            and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + "орг" + chr(3) + string (clients.host-code)
            no-error.
    if not available buf_ext-classif
    then do :
      message "Фирма орг" string (clients.host-code) " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" view-as alert-box .
      next clients_.
    end.
    v-issuerId = entry(1, buf_ext-classif.charKey_Two, chr(6)) .
    mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, clients.db-num).
    objThObj:ObjType = clients.obj-type.
    objThObj:ObjCode = clients.obj-code.
    vsdsTHObj = new vsdsubs ().
    vsdStorage = new vsdtostorage ().
    vsdsTHObj = vsdStorage:getVSDsubs(input objThObj).
    find first buf_ext-classif no-lock
        where buf_ext-classif.classif-subject = 'clients':U
          and buf_ext-classif.classif-name = 'clients-esys':U
          and buf_ext-classif.db-num = 0
          and buf_ext-classif.key#_one = buf_ext-system.esys-id
          and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + clients.obj-type + chr(3) + string (clients.obj-code)
          no-error.
    vsd_ :
    do ii = 1 to vsdsTHObj:GetItem (ii):
      if ii = 1 and not available buf_ext-classif
      then do :
        message "Объект маг" string (clients.obj-code) " не синхронизирован с ФГИС Меркурий (Нет GUID'а предприятия)" view-as alert-box .
        next clients_.
      end.
      if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedCheck
      or vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck
      or vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrUtilized
      then do :
        if vsdsTHObj:VsdObjCurr:UUID = "" or vsdsTHObj:VsdObjCurr:UUID = ? or vsdsTHObj:VsdObjCurr:FactDatetime = ? then next .
        find first buf2_ext-classif no-lock
            where buf2_ext-classif.classif-subject = 'clients':U
              and buf2_ext-classif.classif-name = 'clients-esys':U
              and buf2_ext-classif.db-num = 0
              and buf2_ext-classif.key#_one = buf_ext-system.esys-id
              and buf2_ext-classif.uniq-key-rec = 'clients':U + chr(3) + vsdsTHObj:VsdObjCurr:CliType + chr(3) + string (vsdsTHObj:VsdObjCurr:CliCode)
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
          if num-entries(buf2_ext-classif.charKey_Two, chr(6)) = 2
          then do :
            if entry(1, buf2_ext-classif.charKey_Two, chr(6)) = ""
            or entry(2, buf2_ext-classif.charKey_Two, chr(6)) = ""
            then do :
              if vsdsTHObj:VsdObjCurr:CliType = 'маг'
              then do :
                if entry(2, buf2_ext-classif.charKey_Two, chr(6)) = ""
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
        mercury:GetVetDocumentByUuid(LC(vsdsTHObj:VsdObjCurr:UUID), entry(2, buf_ext-classif.charKey_Two, chr(6)), v-appId, v-status_, v-Msg) .
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
      if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedUtilized
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
ON choose OF b-response IN FRAME Dialog-Frame
DO:
  for each ub.esys-all-attr exclusive-lock where ub.esys-all-attr.table-name = "esys-pck-sent"
                                              and ub.esys-all-attr.attr-code = "mercury"
                                              and ub.esys-all-attr.key3 = "Запрос отправлен" :
    find first buf_vsd no-lock where buf_vsd.UUID = ub.esys-all-attr.attr-value no-error.
    if not available buf_vsd then next .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input buf_vsd.obj-type
  ,input buf_vsd.obj-code
  ,input 'mercur':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
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
define variable vss-include-info10 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-login
  ) no-error .
          end.
        end.
        when "proxy-pswd" then do:
          if thbjattr_thbj-attr.property-value-character <> ""
          then do :
define variable vss-include-info11 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pdecrypt in g#library2
  (input  thbjattr_thbj-attr.property-value-character
  ,output v-proxy-pswd
  ) no-error .
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
          where buf_ext-classif.classif-subject = 'clients':U
            and buf_ext-classif.classif-name = 'clients-esys':U
            and buf_ext-classif.db-num = 0
            and buf_ext-classif.key#_one = buf_ext-system.esys-id
            and buf_ext-classif.uniq-key-rec = 'clients':U + chr(3) + "орг" + chr(3) + string (buf_clients.host-code)
            no-error.
    if not available buf_ext-classif
    then do :
      message "Фирма орг" string (buf_clients.host-code) " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" view-as alert-box .
      next.
    end.
    v-issuerId = entry(1, buf_ext-classif.charKey_Two, chr(6)) .
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-db-num
  ,output v-user-id
  ) no-error .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse BROWSE-Journal-mercury :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
  run diasize_init in this-procedure .
  find first buf_ext-system no-lock where buf_ext-system.esys-type = integer('10':U) no-error.
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
  on row-display of browse-journal-mercury IN FRAME Dialog-Frame
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
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY RADIO-SET-1 v-date-end v-date-start
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_del RADIO-SET-1 b-request b-response btRef v-date-end v-date-start
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  ENABLE BROWSE-journal-mercury
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
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
