/*

$Revision: 7685cb2d18a9, 2983, rls $
$Author: SSlivenko $
$Date: Ср апр 06 16:23:43 2022 +0300 $
$Workfile: impclients.cls $
$Archive: ibs/th/bge/1crn/import/impclients.cls $

Класс ипорта данных clients (контрагенты) из 1С

Автор: Молотков Сергей
Дата создания: 02/10/17
Author: Molotkov Sergey
Creation date: 02/10/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.import.impclients implements ibs.th.bge.1crn.import.iimpsubject: 
  
  { cmp/str-glbl.i class }
  
  
  define property Msg as character no-undo
    get. 
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode               as character no-undo. /* create/update */
    define variable v-rid                as recid     no-undo.
    define variable v-retfl              as logical   no-undo .

    define variable v-firm-code          as integer   no-undo . /* like ub.firm.firm-code */
    define variable v-grp-code           as integer   no-undo . /* like ub.clients.grp-code */
    define variable v-stts               as integer   no-undo . /* like ub.clients.stts */
    define variable v-agnt               as characte  no-undo . /* like ub.firm.contact-psn */
    define variable v-e-mail             as character no-undo . /* like ub.firm.e-mail */
    define variable v-okpo               as character no-undo . /* like ub.firm.okpo */
    
    define variable v-city               as character no-undo . /* like ub.firm.city */
    define variable v-ind                as character no-undo . /* like ub.firm.ind */
    define variable v-addr1              as character no-undo . /* части адреса leg-adr для address1 */
    define variable v-addr2              as character no-undo . /* части адреса leg-adr для address2 */
    define variable v-addr3              as character no-undo . /* части адреса post-adr для post-addr1 */
    define variable v-addr4              as character no-undo . /* части адреса post-adr для post-addr2 */
    /* post-adr и leg-adr - необязательные поля */
    
    /* поля, которые не приходят из 1С: */
    define variable v-lim-kr             as decimal   decimals 2 no-undo . /* like ub.clients.lim-kr (dec-2) */
    define variable v-ps                 as character no-undo . /* like ub.clients.PS */
    define variable v-director           as character no-undo . /* like ub.firm.director */
    define variable v-fax                as character no-undo . /* like ub.firm.fax */
    define variable v-given-by           as character no-undo . /* like ub.firm.given-by */
    define variable v-is-pboul           as logical   no-undo . /* like ub.firm.is-pboul */
    define variable v-okonh              as character no-undo . /* like ub.firm.okonh */
    define variable v-passp-num          as character no-undo . /* like ub.firm.passp-num */
    define variable v-passp-ser          as character no-undo . /* like ub.firm.passp-ser */
    define variable v-phone              as character no-undo . /* like ub.firm.phone */
    define variable v-phone1-note        as character no-undo . /* like ub.firm.phone1-note */
    define variable v-post-city          as character no-undo . /* like ub.firm.post-city */
    define variable v-post-ind           as integer   no-undo . /* like ub.firm.post-ind */
    define variable v-reg-code           as integer   no-undo . /* like ub.clients.reg-code */
    define variable v-telex              as character no-undo . /* like ub.firm.telex */
    define variable v-tobj-code          as integer   no-undo . /* like ub.firm.tobj-code */
    define variable v-turnover-buyer     as logical   no-undo . /* like ub.clients.turnover-buyer */
    define variable v-turnover-buyer-gds as logical   no-undo . /* like ub.clients.turnover-buyer-gds */
    
    define buffer buf_clients      for ub.clients .
    define buffer buf_firm         for ub.firm .
    
    define buffer bf_clients       for ub.clients .
    define buffer buf_clients-attr for ub.clients-attr .

    define variable ii           as integer   no-undo .
    define variable jj           as integer   no-undo .
    define variable kk           as integer   no-undo .
    
    define variable objImp       as class     clients           no-undo.
    define variable v-carrier    as class     clients_carriers  no-undo .
    define variable v-supplier   as class     clients_suppliers no-undo .
    define variable v_carrier    as class     subjects          no-undo .
    define variable v_supplier   as class     subjects          no-undo .
    
    define variable v-attr-value as character no-undo .
    objImp = cast (subjectObj, clients).
    v_carrier = objImp:nb-carriers .
    v_supplier  = objImp:nb-suppliers .

    if objImp:del-f > 0 then 
    do:
      Msg = "физическое удаление контрагентов не предусмотрено".
      v-retfl = false .
      return false . /* уходит в finally, где перевозвращает v-retfl вместо false */
    end .
    
    assign
      v-firm-code = integer(objImp:code_)
      v-grp-code  = 3 /* "Поставщики"  - здесь импорт только юр.лиц;
                         перечень кодов групп клиентов предопределён и согласован с техносервом */
      .
    /* чтобы при изменении записи не перезатирать поля, которые не приходят из 1С, значениями по умолчанию -
       читаем их значения из исходной записи;
       чтобы при изменении записи не затирать пустыми значениями поля из необязательных тегов, которые пришли из 1С, -
       читаем их значения из исходной записи */
    find first buf_clients no-lock
      where buf_clients.obj-type = {&cmp}
      and buf_clients.obj-code = v-firm-code no-error .
    if available buf_clients then 
    do:
      if objImp:del-l > 0 and buf_clients.stts = 0 then 
      do:
        run ref/clients2.p             
          (input ?    /* parparentproc; внутри не используется, передаётся процедурам машины правил rul/999999999.p */
          ,input recid(buf_clients)
          ,input {&bef-deleted-status-int} /* p-stts: {&current-status-int} - запись видна, {&deleted-status-int} - запись как бы удалена */
          ,input true /* p-silent */
          ,input no   /* отсюда удаляем только {&cmp}, а магазины и склады - в импорте АЗС, не в импорте контрагентов или фирм */
          ,input '':U /*p-mode2*/
          ,input '':U /*p-source-type*/
          ,input '':U /*p-source-ref*/
          ) .
        v-retfl = true .
        return true . /* уходит в finally, где перевозвращает v-retfl вместо false */
      end. /* end_of objImp:del-l */
      else if (objImp:del-l = 0) and (buf_clients.stts <> {&bef-current-status-int}) then 
        do:
          run ref/clients2.p             
            (input ?    /* parparentproc; внутри не используется, передаётся процедурам машины правил rul/999999999.p */
            ,input recid(buf_clients)
            ,input {&bef-current-status-int} /* p-stts: {&current-status-int} - запись видна, {&deleted-status-int} - запись как бы удалена */
            ,input true /* p-silent */
            ,input no   /* отсюда удаляем только {&cmp}, а магазины и склады - в импорте АЗС, не в импорте контрагентов или фирм */
            ,input '':U /*p-mode2*/
            ,input '':U /*p-source-type*/
            ,input '':U /*p-source-ref*/
            ) .
        /* после логического разудаления продолжает обновление остальных полей, пришедших в протоколе */
        end. 
      
      find first buf_firm no-lock where buf_firm.firm-code = v-firm-code no-error .
      if available buf_firm then 
      do:
        
        sliceAddress
          ( input  objImp:leg-adr
          , input  buf_firm.addres1
          , input  buf_firm.addres2
          , output v-addr1
          , output v-addr2
          ) .
        sliceAddress
          ( input  objImp:post-adr
          , input  buf_firm.post-addr1
          , input  buf_firm.post-addr2
          , output v-addr3
          , output v-addr4
          ) .

        assign
          v-ind         = if objImp:ind    >= "" then objImp:ind    else string(buf_firm.ind)
          v-city        = if objImp:city   >= "" then objImp:city   else buf_firm.city
          v-agnt        = if objImp:agnt   >= "" then objImp:agnt   else buf_firm.contact-psn
          v-e-mail      = if objImp:e-mail >= "" then objImp:e-mail else buf_firm.e-mail
          v-okpo        = if objImp:okpo   >= "" then objImp:okpo   else buf_firm.okpo
          v-director    = buf_firm.director
          v-fax         = buf_firm.fax
          v-given-by    = buf_firm.given-by
          v-is-pboul    = buf_firm.is-pboul 
          v-okonh       = buf_firm.okonh
          v-passp-num   = buf_firm.passp-num
          v-passp-ser   = buf_firm.passp-ser
          v-phone       = buf_firm.phone
          v-phone1-note = buf_firm.phone1-note
          v-post-city   = buf_firm.post-city
          v-post-ind    = buf_firm.post-ind
          v-telex       = buf_firm.telex
          v-tobj-code   = buf_firm.tobj-code
          .
      end .
      else undo, throw new Progress.Lang.AppError(
          substitute("Не найдена запись ОРГАНИЗАЦИЯ - [&1] для изменения записи о клиенте [&1]", v-firm-code)
          ) .
      /* clients.stts внутри ref/firm1.p заполняется только при создании; при обновлении не изменяется */
      assign
        v-mode               = {&update}
        v-rid                = recid(buf_clients)
        v-lim-kr             = buf_clients.lim-kr
        v-ps                 = buf_clients.PS
        v-reg-code           = buf_clients.reg-code
        v-turnover-buyer     = buf_clients.turnover-buyer
        v-turnover-buyer-gds = buf_clients.turnover-buyer-gds
        .
    end. /* end_of available buf_clients */
    else 
    do:
      /* 13/IV-2018  из 1С могут присылать производителей (обрабатывается почему-то здесь), у которых изначально
                     проставлено логическое удаление. Нам надо создавать их тоже с признаком логического удаления. */
      assign
        v-mode = {&add-import}
        v-rid  = ?
      
        /* если stts пришло - установить то, которое пришло;
           иначе - считать равным 0 (создаваемая запись будет видна в справочнике) */
        v-stts = if (objImp:del-l > 0) then objImp:del-l else 0

        v-lim-kr    = 0.0
        v-ps        = ""
        v-city      = if objImp:city   > "" then objImp:city   else ""
        v-agnt      = if objImp:agnt   > "" then objImp:agnt   else ""
        v-e-mail    = if objImp:e-mail > "" then objImp:e-mail else ""
        v-ind       = if objImp:ind    > "" then objImp:ind    else ""
        v-okpo      = if objImp:okpo   > "" then objImp:okpo   else ""
        v-director  = ""
        v-fax       = ""
        v-given-by  = ""
        v-is-pboul  = false /* в блоке "Контрегенты" при импорте из 1С приходят только юр.лица */ 
        v-okonh     = ""
        v-passp-num = ""
        v-passp-ser = ""
        v-phone     = ""
        v-phone1-note = ""
        v-post-city = ""
        v-post-ind  = 0
        v-reg-code  = 0
        v-telex     = ""
        v-tobj-code = 0
        v-turnover-buyer     = false
        v-turnover-buyer-gds = false
        .
      sliceAddress
        ( input  objImp:leg-adr
        , input  ""
        , input  ""
        , output v-addr1
        , output v-addr2
        ) .
      sliceAddress
        ( input  objImp:post-adr
        , input  ""
        , input  ""
        , output v-addr3
        , output v-addr4
        ) .
    end .
    
    run ref/firm1.p (
      input ?             /* parparentproc handle, not used */
      ,input-output v-rid  /* p-rid as recid, only for output */
      ,input v-mode        /* p-mode as character */
      ,input "discards"    /* p-callpoint: if "discards" then clients.trg-param & firm.trg-param = {&trg-param-no-callnews} */
      ,input yes           /* p-silent: yes с выводом в return-value */
      ,input v-firm-code   /* p-firm-code. В оригинале использовался минусовой код; он позволяет диапазоны с code-range.stts='f' */
      ,input v-stts        /* p-stts like ub.clients.stts (int) Только при СОЗДАНИИ: 0 - запись видна, >0 - запись не видна в справочнике, как бы удалена */
      ,input objImp:name_  /* p-obj-name like ub.clients.obj-name */
      ,input v-lim-kr      /* p-lim-kr like ub.clients.lim-kr (dec-2) */
      ,input v-ps          /* p-PS like ub.clients.PS */
      ,input v-grp-code    /* p-grp-code */
      ,input v-addr1       /* p-addres1 like ub.firm.addres1 */
      ,input v-addr2       /* p-addres2 like ub.firm.addres2 */
      ,input v-city        /* p-city like ub.firm.city */
      ,input v-agnt        /* p-contact-psn like ub.firm.contact-psn */
      ,input v-director    /* p-director like ub.firm.director */
      ,input v-e-mail      /* p-e-mail like ub.firm.e-mail */
      ,input objImp:full-name /* p-engl-name like ub.firm.engl-name */ 
      ,input v-fax         /* p-fax like ub.firm.fax */
      ,INPUT v-given-by    /* p-given-by like ub.firm.given-by */
      ,input string(v-ind) /* p-ind like ub.firm.ind */
      ,input objImp:inn    /* p-inn like ub.firm.inn */
      ,INPUT yes           /* p-no-check-inn: yes пропускает проверку ИНН */
      ,INPUT v-is-pboul    /* p-is-pboul like ub.firm.is-pboul */
      ,input objImp:kpp    /* p-kpp like ub.firm.kpp */
      ,input v-okonh       /* p-okonh like ub.firm.okonh */
      ,input v-okpo        /* p-okpo like ub.firm.okpo */
      ,INPUT v-passp-num   /* p-passp-num like ub.firm.passp-num */
      ,INPUT v-passp-ser   /* p-passp-ser like ub.firm.passp-ser */
      ,input v-phone       /* p-phone like ub.firm.phone */
      ,input v-phone1-note /* p-phone1-note like ub.firm.phone1-note */
      ,input v-addr3       /* p-post-addr1 like ub.firm.post-addr1 */
      ,input v-addr4       /* p-post-addr2 like ub.firm.post-addr2 */
      ,input v-post-city   /* p-post-city like ub.firm.post-city */
      ,input v-post-ind    /* p-post-ind like ub.firm.post-ind */
      ,input v-reg-code    /* p-reg-code like ub.clients.reg-code */
      ,input v-telex       /* p-telex like ub.firm.telex */
      ,input v-tobj-code   /* p-tobj-code like ub.firm.tobj-code */
      ,input v-turnover-buyer     /* p-turnover-buyer like ub.clients.turnover-buyer */
      ,input v-turnover-buyer-gds /* p-turnover-buyer-gds like ub.clients.turnover-buyer-gds */
      ) .
    assign
      Msg     = ""
      v-retfl = true
      .
    find first bf_clients no-lock where recid(bf_clients) eq v-rid  no-error .
    if avail bf_clients 
    then do:
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-supp-np}
      exclusive-lock no-error.
      if avail clients-attr 
      then do:
         if objImp:post-np eq 1
         then
            clients-attr.attr-value = "yes".
         else 
            delete clients-attr.
      end.
      else do:
         if objImp:post-np eq 1
         then do:
            create clients-attr.
            assign 
               clients-attr.obj-type  = bf_clients.obj-type
               clients-attr.obj-code  = bf_clients.obj-code
               clients-attr.attr-code = {&attr-supp-np}
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-supp-lgas}
      exclusive-lock no-error.
      if avail clients-attr 
      then do:
         if objImp:post-sug eq 1
         then
            clients-attr.attr-value = "yes".
         else 
            delete clients-attr.
      end.
      else do:
         if objImp:post-sug eq 1
         then do:
            create clients-attr.
            assign 
               clients-attr.obj-type  = bf_clients.obj-type
               clients-attr.obj-code  = bf_clients.obj-code
               clients-attr.attr-code = {&attr-supp-lgas}
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-own-supp}
      exclusive-lock no-error.
      if avail clients-attr 
      then do:
         if objImp:own-post eq 1
         then
            clients-attr.attr-value = "yes".
         else 
            delete clients-attr.
      end.
      else do:
         if objImp:own-post eq 1
         then do:
            create clients-attr.
            assign 
               clients-attr.obj-type  = bf_clients.obj-type
               clients-attr.obj-code  = bf_clients.obj-code
               clients-attr.attr-code = {&attr-own-supp}
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-npz}
      exclusive-lock no-error.
      if avail clients-attr 
      then do:
         if objImp:post-npz eq 1
         then
            clients-attr.attr-value = "yes".
         else 
            delete clients-attr.
      end.
      else do:
         if objImp:post-npz eq 1
         then do:
            create clients-attr.
            assign 
               clients-attr.obj-type  = bf_clients.obj-type
               clients-attr.obj-code  = bf_clients.obj-code
               clients-attr.attr-code = {&attr-npz}
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-code-KSK}
      exclusive-lock no-error.
      if trim(objImp:code-KSK) > ""
      and objImp:code-KSK <> ?
      then do :
        if not available clients-attr
        then do :
          create clients-attr.
          assign 
             clients-attr.obj-type  = bf_clients.obj-type
             clients-attr.obj-code  = bf_clients.obj-code
             clients-attr.attr-code = {&attr-code-KSK}
          .
        end .
        clients-attr.attr-value = string(integer(objImp:code-KSK)) no-error .
        if error-status:error
        then 
          clients-attr.attr-value = objImp:code-KSK .
      end .
      else do :
        if available clients-attr
        then
         delete clients-attr.
      end .
      
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-code-AIS}
      exclusive-lock no-error.
      if trim(objImp:code-AIS) > ""
      and objImp:code-AIS <> ?
      then do :
        if not available clients-attr
        then do :
          create clients-attr.
          assign 
             clients-attr.obj-type  = bf_clients.obj-type
             clients-attr.obj-code  = bf_clients.obj-code
             clients-attr.attr-code = {&attr-code-AIS}
          .
        end .
        clients-attr.attr-value = string(integer(objImp:code-AIS)) no-error .
        if error-status:error
        then 
          clients-attr.attr-value = objImp:code-AIS .
      end .
      else do :
        if available clients-attr
        then
         delete clients-attr.
      end .
      
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq {&attr-owner-code}
      exclusive-lock no-error.
      if trim(objImp:org-code) > ""
      and objImp:org-code <> ?
      then do :
        if not available clients-attr
        then do :
          create clients-attr.
          assign 
             clients-attr.obj-type  = bf_clients.obj-type
             clients-attr.obj-code  = bf_clients.obj-code
             clients-attr.attr-code = {&attr-owner-code}
          .
        end .
        clients-attr.attr-value = {&cmp} + string(integer(objImp:org-code)) no-error .
        if error-status:error
        then 
          clients-attr.attr-value = {&cmp} + objImp:org-code .
      end .
      else do :
        if available clients-attr
        then
         delete clients-attr.
      end .
      
      
      
    end.
    if valid-object (v_carrier) then 
    do:
      /*удаление клиента из атрибута*/
      for each buf_clients-attr EXCLUSIVE-LOCK where LOOKUP(({&cmp} + string(v-firm-code)),buf_clients-attr.attr-value) > 0:
        do kk = 1 to NUM-ENTRIES(buf_clients-attr.attr-value,",") :
          if ENTRY (kk,buf_clients-attr.attr-value,",") <> {&cmp} + string(v-firm-code) then 
          do:
            v-attr-value = if v-attr-value = "" then ENTRY (kk,buf_clients-attr.attr-value,",") else "," + ENTRY (kk,buf_clients-attr.attr-value,",") .
          end.  
        end.  
        buf_clients-attr.attr-value = v-attr-value .
      end.

      do ii = 1 to v_carrier:Get(ii):
        v-carrier = cast(v_carrier:SubjectObjCurr, clients_carriers) .
        find first bf_clients no-lock where bf_clients.obj-code = integer(v-carrier:code_) and bf_clients.obj-type = {&cmp} no-error .
        if AVAILABLE (bf_clients) then  
        do:
          find first buf_clients-attr EXCLUSIVE-LOCK where buf_clients-attr.attr-code = {&attr-auto-tank-for} and buf_clients-attr.obj-code = bf_clients.obj-code  
            and buf_clients-attr.obj-type = bf_clients.obj-type no-error .
          if AVAILABLE (buf_clients-attr) then 
          do:
            buf_clients-attr.attr-value = if buf_clients-attr.attr-value <> "" then buf_clients-attr.attr-value + "," + {&cmp} + string(v-firm-code) else {&cmp} + string(v-firm-code) .
          end. 
          else 
          do:
            create buf_clients-attr .
            assign
              buf_clients-attr.attr-code  = {&attr-auto-tank-for}
              buf_clients-attr.obj-code   = bf_clients.obj-code
              buf_clients-attr.obj-type   = bf_clients.obj-type
              buf_clients-attr.attr-value = {&cmp} + string(v-firm-code)
              .
          end.   
        end.
        else 
        do:
          Msg = "В справочнике нет клиента с кодом:" + STRING (v-carrier:code_). 
          return error .
        end.    
      end.
    end.  

    if valid-object (v_supplier) then 
    do:
      find first buf_clients-attr EXCLUSIVE-LOCK where buf_clients-attr.attr-code = {&attr-tank-farm-for} and buf_clients-attr.obj-code = v-firm-code  
        and buf_clients-attr.obj-type = {&cmp} no-error .
      if AVAILABLE (buf_clients-attr) then 
      do:
        delete buf_clients-attr .
      end. 

      do jj = 1 to v_supplier:Get(jj):
        v-supplier = cast(v_supplier:SubjectObjCurr, clients_suppliers) .
        find first bf_clients no-lock where bf_clients.obj-code = integer(v-supplier:code_) and bf_clients.obj-type = {&cmp} no-error .
        if AVAILABLE (bf_clients) then  
        do:
          find first buf_clients-attr EXCLUSIVE-LOCK where buf_clients-attr.attr-code = {&attr-tank-farm-for} and buf_clients-attr.obj-code = v-firm-code  
            and buf_clients-attr.obj-type = {&cmp} no-error .
          if AVAILABLE (buf_clients-attr) then 
          do:
            if lookup((bf_clients.obj-type + string(bf_clients.obj-code)), buf_clients-attr.attr-value) = 0 then 
            buf_clients-attr.attr-value = buf_clients-attr.attr-value + "," + bf_clients.obj-type + string(bf_clients.obj-code) .
          end.
          else 
          do:
            create buf_clients-attr .
            assign
              buf_clients-attr.attr-code  = {&attr-tank-farm-for}
              buf_clients-attr.obj-code   = v-firm-code
              buf_clients-attr.obj-type   = {&cmp}
              buf_clients-attr.attr-value = bf_clients.obj-type + string(bf_clients.obj-code)
              .
          end.
        end.
        else 
        do:
          Msg = "В справочнике нет клиента с кодом:" + STRING (v-carrier:code_). 
          return error .
        end.    
      end.
    end.      
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . 
      else 
      do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . 
        else Msg = "AppError в контрагентах" .
      end .  
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) . 
      if Msg > "" then . 
      else Msg = "ProError в контрагентах" .
      v-retfl = false .
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в контрагентах" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
    

    
    
  end method. /* end_of Excute */


  /* распределение строки адреса по полям address1, address2 описано в
     пользовательском интерфейсе модуля ref/firmi.w:
       1 строка = address1 [1...50]
       2 строка = address2 [1...50]
       3 строка = address1 [51...100]
       4 строка = address1 [101...]
     во входной строке адреса допускаются заполненное, пустое, и неопределённое значения;
     в строках с текущим адресом допускаются только заполненное или пустое значение, неопределённое значение не допускается. */     
  method private void sliceAddress (input p-address   as character,
    input p-curraddr1 as character,
    input p-curraddr2 as character, 
    output p-addr1     as character,
    output p-addr2     as character) :
    if p-address > "" then assign
        /* первые 50 символов, и далее со 101 символа для address1 */    
        p-addr1 = substitute(  "&1&2",  substring(p-address,  1, 50),  substring(p-address, 101)  )
        /* символы с 51 по 100 для address2 */
        p-addr2 = substring(p-address, 51, 50)
        .
    else if p-address = "" then assign
          p-addr1 = ""
          p-addr2 = ""
          .
      else assign
          p-addr1 = p-curraddr1
          p-addr2 = p-curraddr2
          .
  end method .


end class.