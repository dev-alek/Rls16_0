block-level on error undo, throw.
/*

$Revision: d6a01d2b837a, 2559, rls $
$Author: SSlivenko $
$Date: Вт авг 11 18:31:46 2020 +0300 $
$Workfile: auto-merc.p $
$Archive: bge/auto-merc.p $

Работа с ФГИС меркурий

Автор: Сливенко Сергей
Дата создания: 05/28/18
Author: Slivenko Sergey
Creation date: 05/28/18

*/

using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
using ibs.th.bge.mercury.*.


define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-list-db       as character no-undo .

def var vss-revision    as character no-undo init "$Revision: d6a01d2b837a, 2559, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Вт авг 11 18:31:46 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-merc.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-merc.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС меркурий".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ adm/auto-def.i }
{ gbl/getsect.i def }
{ ref/extclass.i }

do
on error undo, return error
:
  define variable v-ind                    as integer   no-undo .
  define variable v-num-entries-db-list    as integer   no-undo .
  define variable v-db-num                 as integer   no-undo .
  define variable v-err-gen-pack           as integer   no-undo .
  define variable v-err-code               as integer   no-undo .
  define variable v-step-num               as integer   no-undo .
  define variable v-action                 as character no-undo .
  define variable v-message                as character no-undo .
  define variable v-proc-handle            as handle    no-undo .
  define variable v-main-proc-name         as character no-undo .

  define variable v-count-main-prc         as integer   no-undo .
  define variable v-pers-proc-name         as character no-undo .
  
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
  define variable v-Msg             as character no-undo .
  
  define buffer buf_ext-classif       for ub.ext-classif .
  define buffer buf2_ext-classif      for ub.ext-classif .
  define buffer buf_ext-system        for ub.ext-system .
  define buffer buf_parts             for ub.parts .
  define buffer buf_vsd               for ub.vsd .
  define buffer buf_clients           for ub.clients .
  define buffer buf_esys-all-attr     for ub.esys-all-attr .
  define buffer buf_db                for ub.db .
  
  define variable mercury       as class ibs.th.bge.mercury.mercury       no-undo.
  define variable vsdStorage    as class ibs.th.gbl.storage.vsdtostorage  no-undo.
  define variable vsdsTHObj     as class ibs.th.str.mercury.vsdsubs       no-undo.
  define variable vsdTHObj      as class ibs.th.str.mercury.vsdsub        no-undo.
  define variable vsdStsType    as class ibs.th.str.mercury.vsdstatustype no-undo. 
  define variable objThObj      as class ibs.th.str.clients.clisub        no-undo.
  define variable objKeyRec     as class ibs.th.gbl.keyrec                no-undo.
  
  define variable v-part-rowid as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  
  define variable ii as integer no-undo.

  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  if valid-handle( session :first-procedure ) then do:
    assign
      v-main-proc-name = "gbl/mainproc.p":U
      v-proc-handle    = session :first-procedure
      v-count-main-prc = 0
      v-pers-proc-name = "":U
    .
    do while valid-handle( v-proc-handle )
    :
      if v-proc-handle :file-name = v-main-proc-name then do:
        assign
          v-count-main-prc = v-count-main-prc + 1
        .
      end.
      else do:
        assign
          v-pers-proc-name = v-pers-proc-name + {&comma-char} + v-proc-handle :file-name
        .
      end.
      assign
        v-proc-handle = v-proc-handle:next-sibling no-error
      .
    end.
    if v-count-main-prc > 1
      or v-pers-proc-name <> "":U
    then do:
      message
        substitute( "&1. Вызов данной процедуры невозможен при наличии определений persistent prosedures &2"
                    + "Список недопустимых процедур: &3&2"
                    + "Исключение - единственная процедура &4&2"
                    + "Определений данной процедуры &5&2"
                    , vss-workfile
                    , {&new-line}
                    , v-pers-proc-name
                    , v-main-proc-name
                    , v-count-main-prc
                   )
        view-as alert-box error .
      return error .
    end.
  end.

  assign
    g#auto                = true
    v-num-entries-db-list = num-entries( p-list-db )
  .
  run gbl/set-gbl.p
    (input true
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  if error-status :error
  then do:
    run write-to-log( substitute("&1. Ошибка при инициализации переменных g#... &2&3&4"
                                  ,vss-workfile
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                )
                    ) .
    return error.
  end.
  assign
    g#auto = true
  .
  
  find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-mercury}) no-error.
  if not available buf_ext-system
  then do :
    run write-to-log( "Нет внешней системы с типом Меркурий." ) .
    return .
  end.
  
  SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
  
  objThObj = new clisub ().
  vsdStsType = new vsdstatustype().
  
  run write-to-log( "Получение ответов на отправленные запросы " ) .
  /*  Получение ответов   */
  ans_ :
  for each buf_esys-all-attr no-lock where buf_esys-all-attr.table-name = "esys-pck-sent"
                                      and buf_esys-all-attr.attr-code = "mercury"
                                      and buf_esys-all-attr.key3 = "Запрос отправлен" :
    find first buf_vsd no-lock where buf_vsd.UUID = buf_esys-all-attr.attr-value no-error.
    if not available buf_vsd then next ans_ .
    
    if not can-do(p-list-db, string(buf_vsd.db-num))
    then do :
      next ans_ .
    end .
    
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
    
    if g#db-num <> 0 and v-type-connect = 2
    then do :
      next ans_ .
    end.
    
    find first buf_clients no-lock where buf_clients.obj-type = buf_vsd.obj-type and buf_clients.obj-code = buf_vsd.obj-code no-error.
    if not available buf_clients
    then do :
      run write-to-log( "В ВСД с UUID " + buf_vsd.UUID + " не верно задан объект!!!") .
      next ans_ .
    end.
    
    if v-type-connect = 1 and g#db-num <> 0 and g#db-num <> buf_clients.db-num
    then do :
      next ans_ .
    end.
    
    if g#db-num = 0 and v-type-connect = 1 and buf_clients.db-num <> 0
    then do :
      next ans_ .
    end.
    
    find first buf_db no-lock where buf_db.db-num = buf_clients.db-num .
    if buf_db.stts = 2
    then do :
      run write-to-log( "БД " + string(buf_db.db-num) + " выгружается. Пропускаем." ).
      next ans_ .
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
      run write-to-log( "Фирма орг" + string (buf_clients.host-code) + " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" ) .
      next ans_ .
    end. 
      
    v-issuerId = entry(1, buf_ext-classif.charKey_Two, {&delim-cmd}) .        
    mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, buf_db.db-num).
    mercury:vsdId = buf_esys-all-attr.key1.
  
    case buf_esys-all-attr.key2 :  
      when 1
      then do :  
        find first buf_vsd no-lock where buf_vsd.UUID = buf_esys-all-attr.attr-value and buf_vsd.ID =  buf_esys-all-attr.key1 no-error.
        if not available buf_vsd then next .
        objKeyRec = new keyrec () .
        objKeyRec:GenRowKeyr(buf_vsd.part-key, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
        delete object objKeyRec no-error .
        find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error.   
        if not available  buf_parts
        then do :
          run write-to-log( "ВСД с UUID " + buf_vsd.UUID + " не привязана к партии!!!") .
          next ans_.
        end.                  
        run write-to-log( "Получение ответа на запрос ВСД по UUID " + buf_vsd.UUID ) .   
        do transaction :               
          mercury:receiveVetDoc(input buf_esys-all-attr.key7, input LC(buf_esys-all-attr.attr-value), input buf_parts.qnty, input buf_parts.fact-qnty, input (buf_vsd.status_ = vsdStsType:IsUtilized), output v-Status_, output v-Msg) . 
          delete object mercury no-error .
          find first ub.esys-all-attr exclusive-lock where rowid(ub.esys-all-attr) = rowid(buf_esys-all-attr) .
          if v-Status_ = "COMPLETED"
          then ub.esys-all-attr.key3 = "Ответ получен" .
          else do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = ""
            then do :
              v-Msg = "Нет связи со шлюзом Ветис.Api..." .
              run write-to-log( v-Msg ) .
            end.  
            else do :
              ub.esys-all-attr.key3 = "Запрос отклонён" .
              run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + v-Msg ) .
            end.  
          end.
          release ub.esys-all-attr .
        end. /* transaction */
      end.
      when 2
      then do :  
        run write-to-log( "Получение ответа на запрос на гашение ВСД с UUID " + buf_esys-all-attr.attr-value ) . 
        do transaction :
          mercury:receiveIncomingConsignmentResponse(input buf_esys-all-attr.key7, input buf_esys-all-attr.attr-value, output v-Status_, output v-Msg) . 
          delete object mercury no-error .
          find first ub.esys-all-attr exclusive-lock where rowid(ub.esys-all-attr) = rowid(buf_esys-all-attr) .
          if v-Status_ = "COMPLETED"
          then ub.esys-all-attr.key3 = "Ответ получен" .
          else do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = ""
            then do :
              v-Msg = "Нет связи со шлюзом Ветис.Api..." .
              run write-to-log( v-Msg ) .
            end.  
            else do :
              ub.esys-all-attr.key3 = "Запрос отклонён" .
              if v-Msg = "MERC14561"
              or v-Msg = "MERC14562"
              or v-Msg = "MERC14563"
              then
                run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + "Ошибка наименования продукции " + v-Msg + ". ВСД будет погашено с актом несоответсвия." ) .
              else  
              if v-Msg = "MERC14258"
              or v-Msg = "MERC14537"
              then
                run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + "Ошибка номера партии/ТТН " + v-Msg + ". ВСД будет погашено с актом несоответсвия." ) .
              else
                run write-to-log( "UUID ВСД:  " + buf_esys-all-attr.attr-value + chr(10) + v-Msg ) .
            end. 
          end.
        end. /* transaction */
      end.  
    end case.                               
  
    delete object mercury no-error .
  
  end.
  
  pause 0.2 .

  
  do v-ind = 1 to v-num-entries-db-list
  on error undo, return error
  :
    assign
      v-db-num = integer( entry( v-ind, p-list-db ) )
    .
    
    find first buf_db no-lock where buf_db.db-num = v-db-num .
    if buf_db.stts = 2
    then do :
      run write-to-log( "БД " + string(v-db-num) + " выгружается. Пропускаем." ).
      next .
    end.
    
    run write-to-log( "Работа с БД " + string(v-db-num) ) .

/*    Отправка запросов    */
    clients_ :
    for each clients no-lock where clients.obj-type = {&shop} 
                               and clients.db-num = v-db-num
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
      
      if v-type-connect = 1 and g#db-num <> 0 and g#db-num <> clients.db-num
      then do :
        next clients_.
      end.
      
      if g#db-num <> 0 and v-type-connect = 2
      then do :
        next clients_.
      end.
      
      if g#db-num = 0 and v-type-connect = 1 and clients.db-num <> 0
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
        run write-to-log( "Фирма орг" + string (clients.host-code) + " не синхронизирована с ФГИС Меркурий (Нет GUID'а ХЗ)" ) .
        next clients_.
      end.    
      v-issuerId = entry(1, buf_ext-classif.charKey_Two, {&delim-cmd}) .        
      mercury = new mercury(v-apiKey, v-issuerId, v-login, v-password, v-login_is, buf_ext-system.esys-id, v-server, v-proxy-addres, v-proxy-login, v-proxy-pswd, v-proxy-ssl, buf_db.db-num).
      
      objThObj:ObjType = clients.obj-type.
      objThObj:ObjCode = clients.obj-code.
      vsdsTHObj = new vsdsubs ().
      vsdsTHObj:IsDelChildObj = yes .
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
      
      run write-to-log( "Отправка запросов по объекту " + clients.obj-type + string(clients.obj-code) ) .
  
      vsds_ :
      do ii = 1 to vsdsTHObj:GetItem (ii):
        
        if ii = 1 and not available buf_ext-classif
        then do :
          run write-to-log( "Объект маг" + string (clients.obj-code) + " не синхронизирован с ФГИС Меркурий (Нет GUID'а предприятия)" ) .
          delete object vsdsTHObj no-error .
          delete object vsdStorage no-error .
          next clients_.
        end.  
        
        if date(vsdsTHObj:VsdObjCurr:FactDatetime) < (today - 14) then next vsds_ .
        
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
            do transaction :
              vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
            end. /* transaction */
            run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Контрагент-поставщик не синхронизирован с ФГИС Меркурий. Запрос не отправлен." ) .
            next vsds_.
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
                    do transaction :
                      vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
                    end. /* transaction */  
                    run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Не заполнены GUID предприятия поставщика. Запрос не отправлен." ) .
                    next vsds_.
                  end.
                end.
                else do :
                  vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
                  vsdsTHObj:VsdObjCurr:MsgErr = "Не заполнены GUID'ы хоз. субъекта поставщика и/или предприятия поставщика." .
                  do transaction :
                    vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
                  end. /* transaction */ 
                  run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Не заполнены GUID'ы хоз. субъекта поставщика и/или предприятия поставщика. Запрос не отправлен." ) .
                  next vsds_.
                end.
              end .
            end.
            else do :
              vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsErrCheck .
              vsdsTHObj:VsdObjCurr:MsgErr = "Не верный формат связки поставщика с ФГИС Меркурий" .
              vsdStorage:updateDB(vsdsTHObj:VsdObjCurr) .
              run write-to-log( "UUID ВСД: " + vsdsTHObj:VsdObjCurr:UUID + " .   Не верный формат связки поставщика с ФГИС Меркурий. Запрос не отправлен." ) .
              next vsds_.
            end.
          end.   
            
          find first buf_esys-all-attr no-lock where buf_esys-all-attr.table-name = "esys-pck-sent"
                                                and buf_esys-all-attr.attr-code = "mercury"
                                                and buf_esys-all-attr.attr-value = vsdsTHObj:VsdObjCurr:UUID
                                                and buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID
                                                and buf_esys-all-attr.key2 = 1
                                                and buf_esys-all-attr.key3 = "Запрос отправлен"
                                                no-error .
          if available buf_esys-all-attr then next vsds_ .
          run write-to-log( "Отправка запроса на получение ВСД по UUID " + vsdsTHObj:VsdObjCurr:UUID ) .
          mercury:GetVetDocumentByUuid(LC(vsdsTHObj:VsdObjCurr:UUID), entry(2, buf_ext-classif.charKey_Two, {&delim-cmd}), v-appId, v-status_, v-Msg) .
          if v-status_ <> "ACCEPTED"
          then do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = "" then v-Msg = "Нет связи со шлюзом Ветис.Api..." .
            run write-to-log( v-Msg ) .
            next  vsds_.
          end .
          do transaction :
            create buf_esys-all-attr .
            assign
              buf_esys-all-attr.table-name = "esys-pck-sent"
              buf_esys-all-attr.attr-code = "mercury"
              buf_esys-all-attr.key3 = "Запрос отправлен"
              buf_esys-all-attr.key4 = string(now)
              buf_esys-all-attr.key7 = v-appId
              buf_esys-all-attr.key2 = 1
              buf_esys-all-attr.key8 = g#auto-user-id
            .
            buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID .
            buf_esys-all-attr.attr-value = LC(vsdsTHObj:VsdObjCurr:UUID) .
          end. /* transaction */ 
        end.
        
        if vsdsTHObj:VsdObjCurr:Status_ = vsdStsType:IsNeedUtilized /* К гашению */
        then do :
          if vsdsTHObj:VsdObjCurr:UUID = "" or vsdsTHObj:VsdObjCurr:UUID = ? or vsdsTHObj:VsdObjCurr:FactDatetime = ? then next .
        
          find first buf_esys-all-attr no-lock where buf_esys-all-attr.table-name = "esys-pck-sent"
                                                and buf_esys-all-attr.attr-code = "mercury"
                                                and buf_esys-all-attr.attr-value = vsdsTHObj:VsdObjCurr:UUID
                                                and buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID
                                                and buf_esys-all-attr.key2 = 2
                                                and buf_esys-all-attr.key3 = "Запрос отправлен"
                                                no-error .
          if available buf_esys-all-attr then next  vsds_.
          
          objKeyRec = new keyrec () .
          objKeyRec:GenRowKeyr(vsdsTHObj:VsdObjCurr:PartKey, ?, "ub", ?, ?, v-part-rowid, v-tbl-name) .
          delete object objKeyRec no-error .
          find first buf_parts no-lock where rowid (buf_parts) = v-part-rowid no-error.
          if not available  buf_parts
          then do :
            run write-to-log( "ВСД с UUID " + vsdsTHObj:VsdObjCurr:UUID + " не привязана к партии!!!") .
            next vsds_.
          end. 
          run write-to-log( "Отправка запроса на гашение ВСД с UUID " + vsdsTHObj:VsdObjCurr:UUID ) .
          mercury:processIncomingConsignment(vsdsTHObj, buf_parts.qnty, buf_parts.fact-qnty, v-appId, v-status_, v-Msg) .
          if v-status_ <> "ACCEPTED"
          then do :
            v-Msg = trim(trim(v-Msg, chr(10))) .
            if v-Msg = "" then v-Msg = "Нет связи со шлюзом Ветис.Api..." .
            run write-to-log( v-Msg ) .
            next vsds_ .
          end .
          do transaction :
            create buf_esys-all-attr .
            assign
              buf_esys-all-attr.table-name = "esys-pck-sent"
              buf_esys-all-attr.attr-code = "mercury"
              buf_esys-all-attr.key3 = "Запрос отправлен"
              buf_esys-all-attr.key4 = string(now)
              buf_esys-all-attr.key7 = v-appId
              buf_esys-all-attr.key2 = 2
              buf_esys-all-attr.key8 = g#auto-user-id
            .
            buf_esys-all-attr.key1 = vsdsTHObj:VsdObjCurr:ID .
            buf_esys-all-attr.attr-value = LC(vsdsTHObj:VsdObjCurr:UUID) .
          end. /* transaction */ 
        end.
      
      end.
      
      delete object vsdsTHObj .
      delete object vsdStorage .
      
      
      delete object mercury no-error .
      
    end.
    
    run write-to-log( "Закончена работа с БД " + string(v-db-num) ) .
    
    pause 0.2 .
    
  end.

  delete object objThObj no-error . 
  delete object vsdStsType no-error . 
  
end.

/* $Workfile: auto-merc.p $ end */