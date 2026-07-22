using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impclients implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode               as character no-undo.
    define variable v-rid                as recid     no-undo.
    define variable v-retfl              as logical   no-undo .
    define variable v-firm-code          as integer   no-undo .
    define variable v-grp-code           as integer   no-undo .
    define variable v-stts               as integer   no-undo .
    define variable v-agnt               as characte  no-undo .
    define variable v-e-mail             as character no-undo .
    define variable v-okpo               as character no-undo .
    define variable v-city               as character no-undo .
    define variable v-ind                as character no-undo .
    define variable v-addr1              as character no-undo .
    define variable v-addr2              as character no-undo .
    define variable v-addr3              as character no-undo .
    define variable v-addr4              as character no-undo .
    define variable v-lim-kr             as decimal   decimals 2 no-undo .
    define variable v-ps                 as character no-undo .
    define variable v-director           as character no-undo .
    define variable v-fax                as character no-undo .
    define variable v-given-by           as character no-undo .
    define variable v-is-pboul           as logical   no-undo .
    define variable v-okonh              as character no-undo .
    define variable v-passp-num          as character no-undo .
    define variable v-passp-ser          as character no-undo .
    define variable v-phone              as character no-undo .
    define variable v-phone1-note        as character no-undo .
    define variable v-post-city          as character no-undo .
    define variable v-post-ind           as integer   no-undo .
    define variable v-reg-code           as integer   no-undo .
    define variable v-telex              as character no-undo .
    define variable v-tobj-code          as integer   no-undo .
    define variable v-turnover-buyer     as logical   no-undo .
    define variable v-turnover-buyer-gds as logical   no-undo .
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
      return false .
    end .
    assign
      v-firm-code = integer(objImp:code_)
      v-grp-code  = 3
      .
    find first buf_clients no-lock
      where buf_clients.obj-type = 'орг':U
      and buf_clients.obj-code = v-firm-code no-error .
    if available buf_clients then
    do:
      if objImp:del-l > 0 and buf_clients.stts = 0 then
      do:
        run ref/clients2.p
          (input ?
          ,input recid(buf_clients)
          ,input 1
          ,input true
          ,input no
          ,input '':U
          ,input '':U
          ,input '':U
          ) .
        v-retfl = true .
        return true .
      end.
      else if (objImp:del-l = 0) and (buf_clients.stts <> 0) then
        do:
          run ref/clients2.p
            (input ?
            ,input recid(buf_clients)
            ,input 0
            ,input true
            ,input no
            ,input '':U
            ,input '':U
            ,input '':U
            ) .
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
      assign
        v-mode               = 'ИЗМЕНЕНИЕ':U
        v-rid                = recid(buf_clients)
        v-lim-kr             = buf_clients.lim-kr
        v-ps                 = buf_clients.PS
        v-reg-code           = buf_clients.reg-code
        v-turnover-buyer     = buf_clients.turnover-buyer
        v-turnover-buyer-gds = buf_clients.turnover-buyer-gds
        .
    end.
    else
    do:
      assign
        v-mode = 'ДОБАВЛЕНИЕ-ИМПОРТ':U
        v-rid  = ?
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
        v-is-pboul  = false
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
      input ?
      ,input-output v-rid
      ,input v-mode
      ,input "discards"
      ,input yes
      ,input v-firm-code
      ,input v-stts
      ,input objImp:name_
      ,input v-lim-kr
      ,input v-ps
      ,input v-grp-code
      ,input v-addr1
      ,input v-addr2
      ,input v-city
      ,input v-agnt
      ,input v-director
      ,input v-e-mail
      ,input objImp:full-name
      ,input v-fax
      ,INPUT v-given-by
      ,input string(v-ind)
      ,input objImp:inn
      ,INPUT yes
      ,INPUT v-is-pboul
      ,input objImp:kpp
      ,input v-okonh
      ,input v-okpo
      ,INPUT v-passp-num
      ,INPUT v-passp-ser
      ,input v-phone
      ,input v-phone1-note
      ,input v-addr3
      ,input v-addr4
      ,input v-post-city
      ,input v-post-ind
      ,input v-reg-code
      ,input v-telex
      ,input v-tobj-code
      ,input v-turnover-buyer
      ,input v-turnover-buyer-gds
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
                                and clients-attr.attr-code eq 'supp-np':U
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
               clients-attr.attr-code = 'supp-np':U
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq 'supp-lgas':U
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
               clients-attr.attr-code = 'supp-lgas':U
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq 'own-supp':U
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
               clients-attr.attr-code = 'own-supp':U
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq 'NPZ':U
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
               clients-attr.attr-code = 'NPZ':U
               clients-attr.attr-value = "yes"
            .
         end.
      end.
      find first clients-attr where clients-attr.obj-type  eq bf_clients.obj-type
                                and clients-attr.obj-code  eq bf_clients.obj-code
                                and clients-attr.attr-code eq 'code-KSK':U
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
             clients-attr.attr-code = 'code-KSK':U
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
                                and clients-attr.attr-code eq 'code-AIS':U
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
             clients-attr.attr-code = 'code-AIS':U
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
                                and clients-attr.attr-code eq 'owner-code':U
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
             clients-attr.attr-code = 'owner-code':U
          .
        end .
        clients-attr.attr-value = 'орг':U + string(integer(objImp:org-code)) no-error .
        if error-status:error
        then
          clients-attr.attr-value = 'орг':U + objImp:org-code .
      end .
      else do :
        if available clients-attr
        then
         delete clients-attr.
      end .
    end.
    if valid-object (v_carrier) then
    do:
      for each buf_clients-attr EXCLUSIVE-LOCK where LOOKUP(('орг':U + string(v-firm-code)),buf_clients-attr.attr-value) > 0:
        do kk = 1 to NUM-ENTRIES(buf_clients-attr.attr-value,",") :
          if ENTRY (kk,buf_clients-attr.attr-value,",") <> 'орг':U + string(v-firm-code) then
          do:
            v-attr-value = if v-attr-value = "" then ENTRY (kk,buf_clients-attr.attr-value,",") else "," + ENTRY (kk,buf_clients-attr.attr-value,",") .
          end.
        end.
        buf_clients-attr.attr-value = v-attr-value .
      end.
      do ii = 1 to v_carrier:Get(ii):
        v-carrier = cast(v_carrier:SubjectObjCurr, clients_carriers) .
        find first bf_clients no-lock where bf_clients.obj-code = integer(v-carrier:code_) and bf_clients.obj-type = 'орг':U no-error .
        if AVAILABLE (bf_clients) then
        do:
          find first buf_clients-attr EXCLUSIVE-LOCK where buf_clients-attr.attr-code = 'auto-tank-for':U and buf_clients-attr.obj-code = bf_clients.obj-code
            and buf_clients-attr.obj-type = bf_clients.obj-type no-error .
          if AVAILABLE (buf_clients-attr) then
          do:
            buf_clients-attr.attr-value = if buf_clients-attr.attr-value <> "" then buf_clients-attr.attr-value + "," + 'орг':U + string(v-firm-code) else 'орг':U + string(v-firm-code) .
          end.
          else
          do:
            create buf_clients-attr .
            assign
              buf_clients-attr.attr-code  = 'auto-tank-for':U
              buf_clients-attr.obj-code   = bf_clients.obj-code
              buf_clients-attr.obj-type   = bf_clients.obj-type
              buf_clients-attr.attr-value = 'орг':U + string(v-firm-code)
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
      find first buf_clients-attr EXCLUSIVE-LOCK where buf_clients-attr.attr-code = 'tank-farm-for':U and buf_clients-attr.obj-code = v-firm-code
        and buf_clients-attr.obj-type = 'орг':U no-error .
      if AVAILABLE (buf_clients-attr) then
      do:
        delete buf_clients-attr .
      end.
      do jj = 1 to v_supplier:Get(jj):
        v-supplier = cast(v_supplier:SubjectObjCurr, clients_suppliers) .
        find first bf_clients no-lock where bf_clients.obj-code = integer(v-supplier:code_) and bf_clients.obj-type = 'орг':U no-error .
        if AVAILABLE (bf_clients) then
        do:
          find first buf_clients-attr EXCLUSIVE-LOCK where buf_clients-attr.attr-code = 'tank-farm-for':U and buf_clients-attr.obj-code = v-firm-code
            and buf_clients-attr.obj-type = 'орг':U no-error .
          if AVAILABLE (buf_clients-attr) then
          do:
            if lookup((bf_clients.obj-type + string(bf_clients.obj-code)), buf_clients-attr.attr-value) = 0 then
            buf_clients-attr.attr-value = buf_clients-attr.attr-value + "," + bf_clients.obj-type + string(bf_clients.obj-code) .
          end.
          else
          do:
            create buf_clients-attr .
            assign
              buf_clients-attr.attr-code  = 'tank-farm-for':U
              buf_clients-attr.obj-code   = v-firm-code
              buf_clients-attr.obj-type   = 'орг':U
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
  end method.
  method private void sliceAddress (input p-address   as character,
    input p-curraddr1 as character,
    input p-curraddr2 as character,
    output p-addr1     as character,
    output p-addr2     as character) :
    if p-address > "" then assign
        p-addr1 = substitute(  "&1&2",  substring(p-address,  1, 50),  substring(p-address, 101)  )
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
