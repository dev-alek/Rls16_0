block-level on error undo, throw.
/*

$Revision: 1eba0946c2d7, 3078, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:25 2022 +0300 $
$Workfile: auto-motp.p $
$Archive: bge/auto-motp.p $

Работа с ФГИС меркурий

Автор: Сливенко Сергей
Дата создания: 05/28/18
Author: Slivenko Sergey
Creation date: 05/28/18

*/

using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.gbl.*.
using ibs.th.gbl.sys.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
using ibs.th.str.utd.*.
using ibs.th.str.utd.sts.*.
using ibs.th.bge.is_motp.*.


define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-list-db       as character no-undo .
define input  parameter p-debug         as logical   no-undo .

def var vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-motp.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-motp.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС меркурий".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ adm/auto-def.i }
{ gbl/getsect.i def }
{ ref/extclass.i }
{ utl/gtin.i  }

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
  
  define variable vToken            as character no-undo .
  define variable vNewToken         as character no-undo .
  
  define variable vSignature        as character no-undo .
  define variable vUUID             as character no-undo .
  
  define buffer buf_ext-classif       for ub.ext-classif .
  define buffer buf2_ext-classif      for ub.ext-classif .
  define buffer buf_ext-system        for ub.ext-system .
  define buffer buf_ext-system-attr   for ub.ext-system-attr .
  define buffer buf_parts             for ub.parts .
  define buffer buf_vsd               for ub.vsd .
  define buffer buf_clients           for ub.clients .
  define buffer buf_esys-all-attr     for ub.esys-all-attr .
  define buffer buf_db                for ub.db .
  define buffer buf_utd               for ub.utd .
  define buffer buf_utd-attr          for ub.utd-attr .
  define buffer buf_utd-err           for ub.utd-err .
  define buffer upd_utd               for ub.utd .
  define buffer locked_utd            for ub.utd .
  define buffer buf_marking           for ub.marking .
  define buffer buf_utd-marking-lines for ub.utd-marking-lines .
  define buffer buf_utd-lines         for ub.utd-lines .
  
  define variable v-part-rowid as rowid no-undo .
  define variable v-tbl-name as character no-undo .
  define variable oMotp as class is_motp no-undo .
  define variable v-ok as logical no-undo .
  define variable v-found as logical no-undo .
  
  define variable ii as integer no-undo.

  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  
  assign
    g#auto                = true
    g#esys                = true
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
    g#esys = true
  .
{ str/utd-err.i }  
/*  run gbl/getobjsrvhndl.p (input-output ObjSrv).*/
  
  SECURITY-POLICY:SYMMETRIC-ENCRYPTION-KEY = GENERATE-PBE-KEY("sysadm").
  
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
    

/*    Отправка запросов  */ 
    clients_ :
    for each clients no-lock where clients.obj-type = {&shop} 
                               and clients.db-num = v-db-num
                               and clients.stts = 0
                               break by clients.host-code :
        
        run write-to-log( "... Объект " + clients.obj-type + string(clients.obj-code) + "  " + clients.obj-name ) .
/*      if first-of(clients.host-code)*/
/*      then do :                     */
        for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = {&attr-esys-obj}
                                               and buf_ext-system-attr.esya-attr-value  = clients.obj-type + string(clients.obj-code)
                                              /* and buf_ext-system-attr.db-num           = buf_db.db-num */
                                               :
          find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-is_motp})
                                              and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id 
                                              no-error .
          if available buf_ext-system then leave .
        end .
        if not available buf_ext-system
        then
        for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = {&attr-esys-host-code}
                                               and buf_ext-system-attr.esya-attr-value  = string(clients.host-code)
                                              /* and buf_ext-system-attr.db-num           = buf_db.db-num */
                                               :
          find first buf_ext-system no-lock where buf_ext-system.esys-type = integer({&openxml-type-is_motp})
                                              and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id 
                                              no-error .
          if available buf_ext-system then leave .
        end .                                      
        if not available buf_ext-system
        then do :
          run write-to-log( "Нет внешней системы с типом ИС МОТП, привязанной к фирме Орг" + string(clients.host-code) ) .
          next clients_ .
        end.
        
        assign
          g#esys-source-esys = buf_ext-system.esys-id
        .
        
        assign
          vToken = ""
          vNewToken = ""
        .
        find first buf_ext-system-attr no-lock where buf_ext-system-attr.db-num   = buf_ext-system.db-num
                                                 and buf_ext-system-attr.esys-id  = buf_ext-system.esys-id
                                                 and buf_ext-system-attr.esya-attr-code = {&attr-esys-AuthToken}
                                                 no-error .
        if available buf_ext-system-attr
        then do :
          assign vToken = trim(buf_ext-system-attr.esya-attr-value) .
        end .
        
        oMotp = new is_motp(buf_ext-system.db-num, buf_ext-system.esys-id, v-db-num) .
        oMotp:isDebug = p-debug .
        
        if vToken > ""
        then do :
          if oMotp:needTokenUpd()
          then do :
            run write-to-log( "Со времени получения токена прошло более 6 часов. Пробуем обновить токен..." ) .
            vNewToken = oMotp:updateToken(vToken) .
            if oMotp:HttpStatus = 502
            then do :
              run write-to-log( oMotp:Msg ) .
            end .
            if oMotp:StatusErr
            then do :
              run write-to-log( oMotp:Msg ) .
            end .
            else do :
              vToken = vNewToken .
              run write-to-log( "Токен успешно обновлён" ) .
            end .
          end .
          if not oMotp:authTest(vToken)
          then do :
            run write-to-log( oMotp:Msg ) .
            if not oMotp:Msg begins "Нет ответа от ИС МОТП"
            then do transaction :
              find first buf_ext-system-attr no-lock where buf_ext-system-attr.db-num   = buf_ext-system.db-num
                                                       and buf_ext-system-attr.esys-id  = buf_ext-system.esys-id
                                                       and buf_ext-system-attr.esya-attr-code = {&attr-esys-AuthToken-send}
                                                       no-error .
              if available buf_ext-system-attr
              then do :
                if buf_ext-system-attr.esya-attr-value = ?
                or buf_ext-system-attr.esya-attr-value = ""
                or buf_ext-system-attr.esya-attr-value <> vToken
                then do :
                  oMotp:sendEMail(substitute("В БД &1 фирме орг&2 токен для авторизации в ИС МОТП просрочен", string(v-db-num), string(clients.host-code))) .
                end .
                find current buf_ext-system-attr exclusive-lock .
                assign buf_ext-system-attr.esya-attr-value = vToken .
              end . 
              assign vToken = "" .
              find first buf_ext-system-attr exclusive-lock where buf_ext-system-attr.db-num   = buf_ext-system.db-num
                                                              and buf_ext-system-attr.esys-id  = buf_ext-system.esys-id
                                                              and buf_ext-system-attr.esya-attr-code = {&attr-esys-AuthTokenDT}
                                                              no-error .
              if available buf_ext-system-attr
              then do :
                assign buf_ext-system-attr.esya-attr-value = "" .
              end .
            end . /* trans */
          end .
          else do :
            if oMotp:HttpStatus = 502
            then do :
              run write-to-log( oMotp:Msg ) .
            end .
          end .
        end .
        else do transaction :
          run write-to-log( "Отсутствует токен для авторизации в ИС МОТП." ) .
          find first buf_ext-system-attr no-lock where buf_ext-system-attr.db-num   = buf_ext-system.db-num
                                                   and buf_ext-system-attr.esys-id  = buf_ext-system.esys-id
                                                   and buf_ext-system-attr.esya-attr-code = {&attr-esys-AuthToken-send}
                                                   no-error .
          if available buf_ext-system-attr
          then do :
            if buf_ext-system-attr.esya-attr-value = ?
            or buf_ext-system-attr.esya-attr-value = ""
            or buf_ext-system-attr.esya-attr-value <> "empty"
            then do :
              oMotp:sendEMail(substitute("В БД &1 фирме орг&2 отсутствует токен для авторизации в ИС МОТП", string(v-db-num), string(clients.host-code))) .
            end .
            find current buf_ext-system-attr exclusive-lock .
            assign buf_ext-system-attr.esya-attr-value = "empty" .
          end . 
          find first buf_ext-system-attr exclusive-lock where buf_ext-system-attr.db-num   = buf_ext-system.db-num
                                                          and buf_ext-system-attr.esys-id  = buf_ext-system.esys-id
                                                          and buf_ext-system-attr.esya-attr-code = {&attr-esys-AuthTokenDT}
                                                          no-error .
          if available buf_ext-system-attr
          then do :
            assign buf_ext-system-attr.esya-attr-value = "" .
          end .
        end . /* trans */
/*      end .*/
                                 
      /* По всем УТД/еДокам в статусе "Получен от поставщика" И статус ЕДО не равен Запрос аннуляции */
      if vToken > ""
      then do :
        utd_ :
        for each buf_utd no-lock where buf_utd.obj-type = clients.obj-type
                                   and buf_utd.obj-code = clients.obj-code
                                   and (buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or buf_utd.EDocType = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB)
                                   and buf_utd.sts = objSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
                                   and buf_utd.sts-edi <> objSrv:Env:Utd:Sts:EDI:RevocationIsRequestedByMe:KeyIntDB :
              /* Запрос информации по маркам */
          do transaction :
            find first locked_utd exclusive-lock where rowid(locked_utd) = rowid(buf_utd) no-wait no-error .
            if not available locked_utd
            then do :
              next utd_ .
            end .
                
            run write-to-log( "Запрос информации по маркам. УПД " + string(buf_utd.DocumentNumber) ) .
               
            v-found = false .
            for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num
                                               and buf_utd-marking-lines.doc-id = buf_utd.doc-id,
            first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                                        and buf_marking.unit-ext = "LEVEL2" :
              v-found = true .
              leave .                                   
            end .
            if v-found
            then do :
              oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, true, output v-ok) .
              if not v-ok
              then do :
                run write-to-log( oMotp:Msg ) .
                next utd_ .
              end .
            end .
            oMotp:lastLineCisInfo = 0 .   
            oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
            if not v-ok
            then do :
              run write-to-log( oMotp:Msg ) .
              next utd_ .
            end .     
            do while oMotp:lastLineCisInfo <> 0 :
              oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
              if not v-ok
              then do :
                run write-to-log( oMotp:Msg ) .
                next utd_ .
              end .
            end . 
             
            if oMotp:foundLevel2
            then do :
              oMotp:lastLineCisInfo = 0 .   
              oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
              if not v-ok
              then do :
                run write-to-log( oMotp:Msg ) .
                next utd_ .
              end .     
              do while oMotp:lastLineCisInfo <> 0 :
                oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
                if not v-ok
                then do :
                  run write-to-log( oMotp:Msg ) .
                  next utd_ .
                end .
              end .
            end .                 
               
            if oMotp:needCheckUnit
            then do :
              oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
              if not v-ok
              then do :
                run write-to-log( oMotp:Msg ) .
                next utd_ .
              end . 
            end .
            /* Смена статуса документа на основании статусов марок */   
                
            v-found = false .
            lines_ :
            for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num
                                             and buf_utd-lines.doc-id = buf_utd.doc-id:
              if CheckErrForLineType(buffer buf_utd-lines:handle, "LoadUtd") 
              then next lines_ .                                
              for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                                                       and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                                                       and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum:
                if not isMark(buf_utd-marking-lines.mark)
                then do:
                  v-found = true .
                  leave lines_.                                   
                end.
                find first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                                                 and buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB 
                no-error.
                if available buf_marking
                then do: 
                  v-found = true .
                  leave lines_.
                end.                                   
              end .
            end .
                
            if not v-found
            then do :
              locked_utd.sts = objSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB .
            end .
            else do :
              locked_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
            end .
                
            release locked_utd no-error .
        /*        for first ub.utd exclusive-lock where rowid(ub.utd) = rowid(buf_utd) :*/
        /*          ub.utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .    */
        /*        end .                                                                 */
        /*        v-ok = oMotp:CheckStatus(buf_utd.db-num, buf_utd.doc-id) .  */
        /*        if not v-ok                                                 */
        /*        then do :                                                   */
        /*          run write-to-log( "Не получена полная информация по КМ") .*/
        /*          next .                                                    */
        /*        end .                                                       */
          end . /* transaction */
        end .
      end.
      
      /* По всем УТД/еДокам в статусе "Пройдена проверка МОТП" */ 
      for each buf_utd no-lock where buf_utd.obj-type = clients.obj-type
                                 and buf_utd.obj-code = clients.obj-code
                                 and (buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or buf_utd.EDocType = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB)
                                 and buf_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB :
        /* Проверка по спецификации */ 
        do transaction :
          find first locked_utd exclusive-lock where rowid(locked_utd) = rowid(buf_utd) no-wait no-error .
          if not available locked_utd
          then do :
            next .
          end .
          run write-to-log( "Проверка по спецификации. УПД " + string(buf_utd.DocumentNumber) ) .
          oMotp:CheckSpec(buf_utd.db-num, buf_utd.doc-id) .
          release locked_utd no-error .
        end . /* transaction */
      end .
      
      if vToken > ""
      then do :
        /* По всем УТД/еДокам в статусе "Ожидает подтверждения МОТП" */ 
        for each buf_utd no-lock where buf_utd.obj-type = clients.obj-type
                                   and buf_utd.obj-code = clients.obj-code
                                   and (buf_utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB or buf_utd.EDocType = objSrv:Env:Utd:EDocType:EDoc:KeyIntDB)
                                   and buf_utd.sts = objSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB :
          /* Проверка по спецификации */ 
          do transaction :
            find first locked_utd exclusive-lock where rowid(locked_utd) = rowid(buf_utd) no-wait no-error .
            if not available locked_utd
            then do :
              next .
            end .
            
            run write-to-log( "Проверка документа в ИС МОТП. УПД " + string(buf_utd.DocumentNumber) ) .
  /*          oMotp:checkUtd(vToken, buf_utd.db-num, buf_utd.doc-id) .*/
            oMotp:checkINN = true .
            oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
            oMotp:checkINN = false .
            release locked_utd no-error .
          end . /* transaction */
          if not v-ok
          then do :
            run write-to-log( oMotp:Msg ) .
            next .
          end .
        end .
      
      
        /* По всем УТД с типом "Первоначальный ввод" в статусе "Ожидает подтверждения МОТП" */
        for each buf_utd no-lock where buf_utd.obj-type = clients.obj-type
                                   and buf_utd.obj-code = clients.obj-code
                                   and buf_utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
                                   and buf_utd.sts = objSrv:Env:Utd:Sts:TH:AwaitingConfirmation:KeyIntDB :
          /* Запрос информации по маркам */
          do transaction :
            find first locked_utd exclusive-lock where rowid(locked_utd) = rowid(buf_utd) no-wait no-error .
            if not available locked_utd
            then do :
              next .
            end .
            
            run write-to-log( "Запрос информации по маркам. Первоначальный ввод " + string(buf_utd.DocumentNumber) ) .
            oMotp:isFirstEnter = true .
            oMotp:cisesInfo(vToken, buf_utd.db-num, buf_utd.doc-id, false, output v-ok) .
            oMotp:isFirstEnter = false .        
            if not v-ok
            then do :
              run write-to-log( oMotp:Msg ) .
              next .
            end .   
            for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd.db-num
                                                     and buf_utd-marking-lines.doc-id = buf_utd.doc-id,
            first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                                        and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB :
              v-ok = false .
              leave .                                   
            end .
            if not v-ok
            then do :
              run write-to-log( "Не получена полная информация по КМ") .
              next .
            end .
            locked_utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB .
            release locked_utd no-error .
    /*        for first upd_utd exclusive-lock where rowid(upd_utd) = rowid(buf_utd) :*/
    /*          upd_utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB .              */
    /*        end .                                                                   */
          end . /* transaction */
        end .
        
        /* По всем документам Вывода из оборота (ОСУ) в статусе "Подписанные и ожидающие отправки в ГИС МТ" */
        for each buf_utd no-lock where buf_utd.obj-type = clients.obj-type
                                   and buf_utd.obj-code = clients.obj-code
                                   and buf_utd.EDocType = objSrv:Env:Utd:EDocType:LK_RECEIPT:KeyIntDB
                                   and buf_utd.sts = objSrv:Env:Utd:Sts:TH:LK_RECEIPT_Signed:KeyIntDB :
        
          do transaction :
            run write-to-log( "Отправка в ГИС МТ документа Вывода из оборота (ОСУ) " + buf_utd.DocumentNumber ) .
            vUUID = oMotp:SendDoc_LK_RECEIPT(vToken, buf_utd.db-num, buf_utd.doc-id, ?, ?) .
            if vUUID = ?
            then do :
              run write-to-log( oMotp:Msg ) .
            end .
          end .
        end .
        
        /* По всем документам Вывода из оборота (ОСУ) в статусе "Отправленные и ожидающие обработки ГИС МТ" */
        for each buf_utd no-lock where buf_utd.obj-type = clients.obj-type
                                   and buf_utd.obj-code = clients.obj-code
                                   and buf_utd.EDocType = objSrv:Env:Utd:EDocType:LK_RECEIPT:KeyIntDB
                                   and buf_utd.sts = objSrv:Env:Utd:Sts:TH:LK_RECEIPT_Sent:KeyIntDB :
        
          do transaction :
            run write-to-log( "Получение информации из ГИС МТ по документу Вывода из оборота (ОСУ) " + buf_utd.DocumentNumber ) .
            oMotp:checkUtd(vToken, buf_utd.db-num, buf_utd.doc-id) .
          end .
        end .
      end .
/*      if last-of (clients.host-code)*/
/*      then do :                     */
      delete object oMotp no-error .
/*      end .*/
      
    end . /* clients */
    
    run write-to-log( "Закончена работа с БД " + string(v-db-num) ) .
    
    pause 0.2 .
    
  end.

  
end.

/* $Workfile: auto-motp.p $ end */