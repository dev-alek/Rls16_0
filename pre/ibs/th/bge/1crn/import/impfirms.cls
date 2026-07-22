using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impfirms implements ibs.th.bge.1crn.import.iimpsubject:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-mode       as character no-undo .
    define variable v-rid        as recid no-undo .
    define variable v-is-deploy  as logical no-undo .
    define variable v-host-code  as integer no-undo .
    define variable v-retfl      as logical no-undo .
    define buffer buf_sysconf for ub.sysconf .
    define buffer buf_firm    for ub.firm .
    define buffer buf_clients for ub.clients .
    define variable v-avrg-price    as logical no-undo .
    define variable v-artic-disable as logical no-undo .
    define variable v-base-code     as integer no-undo .
    define variable v-branch        as character no-undo .
    define variable v-cash-pay      as integer no-undo .
    define variable v-cashier       as character no-undo .
    define variable v-cons-vat-pc   as decimal decimals 10 no-undo .
    define variable v-credit-pay    as integer no-undo .
    define variable v-firm-db-num   as integer no-undo .
    define variable v-head-position as character no-undo .
    define variable v-KOPF          as character no-undo .
    define variable v-negative-rest as logical no-undo .
    define variable v-ord-prt       as logical no-undo .
    define variable v-osn-base      as logical no-undo .
    define variable v-property      as character no-undo .
    define variable v-purch-code    as integer no-undo .
    define variable v-ret-credit-pay as integer no-undo .
    define variable v-sale-type     as character no-undo .
    define variable v-sale-code     as integer no-undo .
    define variable v-snr-accnt     as character no-undo .
    define variable v-SOEI          as character no-undo .
    define variable v-transport-cli-type as character no-undo .
    define variable v-transport-cli-code as integer no-undo .
    define variable v-transport-host     as integer no-undo .
    define variable v-transport-contract as integer no-undo .
    define variable v-transport-uslov    as integer no-undo .
    define variable v-transport-value    as decimal decimals 2 no-undo .
    define variable v-main-obj-type      as character no-undo .
    define variable v-main-obj-code      as integer no-undo .
    define variable v-als-gds            as logical no-undo .
    define variable varals-gds-str       as character no-undo .
    define variable varals-gds-str-type  as character no-undo .
    define variable v-egrip-date         as date no-undo .
    define variable v-egrip-date-str     as character no-undo .
    define variable var-type             as character no-undo .
    define variable v-egrip-num          as character no-undo .
    define variable v-gen-s-f-office     as logical no-undo .
    define variable v-cli-grp-name       as character no-undo .
    define variable obj-cli-grp as class cli-grps no-undo .
    define variable imp-cli-grp as class ibs.th.bge.1crn.import.impcli-grps no-undo .
    define variable obj-clients as class clients no-undo .
    define variable imp-clients as class ibs.th.bge.1crn.import.impclients no-undo .
    define variable objImp as class firms no-undo.
    objImp = cast (subjectObj, firms).
    if objImp:del-f > 0 then do:
      Msg = "физическое удаление фирм не предусмотрено".
      v-retfl = false .
      return false.
    end.
    assign
      v-host-code = integer(objImp:code_)
      Msg = ""
    .
    if v-host-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код фирмы") .
    find first buf_sysconf no-lock where buf_sysconf.host-code = v-host-code no-error .
    if objImp:del-l > 0 then do:
      find first buf_clients no-lock
           where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = v-host-code no-error .
      if not available buf_clients then undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи СВОЯ ФИРМА с кодом [&1]", v-host-code)
      ) .
      if buf_clients.stts = 0 then do:
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
      end.
    end.
    else if (available buf_sysconf) and (objImp:del-l = 0) then do:
      find first buf_clients no-lock
           where buf_clients.obj-type = 'орг':U
             and buf_clients.obj-code = v-host-code no-error .
      if not available buf_clients then undo, throw new Progress.Lang.AppError(
        substitute("Не найдена запись КЛИЕНТ для записи СВОЯ ФИРМА с кодом [&1]", v-host-code)
      ) .
      if buf_clients.stts <> 0 then do:
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
    end .
    if available buf_sysconf then do:
        find first buf_firm no-lock where buf_firm.firm-code = v-host-code no-error .
        if not available buf_firm then undo, throw new Progress.Lang.AppError(
          substitute("Не найдена запись ФИРМА для записи СВОЯ ФИРМА с кодом [&1]", v-host-code)
        ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
        (input  'орг':U
        ,input  v-host-code
        ,input  'als-gds':U
        ,output varals-gds-str
        ,output varals-gds-str-type
        ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
        (input  'орг':U
        ,input  v-host-code
        ,input  'egrip-date':U
        ,output v-egrip-date-str
        ,output var-type
        ) .
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run clntattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
        (input  'орг':U
        ,input  v-host-code
        ,input  'egrip-num':U
        ,output v-egrip-num
        ,output var-type
        ) .
        assign
          v-mode      = 'ИЗМЕНЕНИЕ':U
          v-is-deploy = false
          v-rid       = recid(buf_sysconf)
          v-avrg-price    = buf_sysconf.avrg-price
          v-artic-disable = buf_sysconf.artic-disable
          v-base-code     = buf_sysconf.base-code
          v-branch        = buf_sysconf.branch
          v-cash-pay      = buf_sysconf.cash-pay
          v-cashier       = buf_sysconf.cashier
          v-cons-vat-pc   = buf_sysconf.cons-vat-pc
          v-credit-pay    = buf_sysconf.credit-pay
          v-firm-db-num   = buf_sysconf.firm-db-num
          v-head-position = buf_sysconf.head-position
          v-KOPF          = buf_sysconf.KOPF
          v-negative-rest = buf_sysconf.negative-rest
          v-ord-prt       = buf_sysconf.ord-prt
          v-osn-base      = buf_sysconf.osn-base
          v-property      = buf_sysconf.property
          v-purch-code    = buf_sysconf.purch-code
          v-ret-credit-pay = buf_sysconf.ret-credit-pay
          v-sale-type     = buf_sysconf.sale-type
          v-sale-code     = buf_sysconf.sale-code
          v-snr-accnt     = buf_sysconf.snr-accnt
          v-SOEI          = buf_sysconf.SOEI
          v-transport-cli-type = buf_sysconf.transport-cli-type
          v-transport-cli-code = buf_sysconf.transport-cli-code
          v-transport-host     = buf_sysconf.transport-host
          v-transport-contract = buf_sysconf.transport-contract
          v-transport-uslov    = buf_sysconf.transport-uslov
          v-transport-value    = buf_sysconf.transport-value
          v-main-obj-type = buf_firm.main-obj-type
          v-main-obj-code = buf_firm.main-obj-code
          v-als-gds       = (varals-gds-str = "yes")
          v-egrip-date    = date( v-egrip-date-str )
          v-gen-s-f-office = buf_sysconf.gen-s-f-office
        .
    end.
    else do:
        assign
          v-cli-grp-name = replace ( objImp:name_  , '/', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '\', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, ':', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '*', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '?', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '"', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '<', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '>', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '|', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '«', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '»', '' )
          v-cli-grp-name = replace ( v-cli-grp-name, '·', '' )
        .
        obj-cli-grp = new cli-grps ().
        obj-cli-grp:SetProp(obj-cli-grp:InitTag, "").
        obj-cli-grp:SetProp("code",       string(v-host-code)).
        obj-cli-grp:SetProp("upper-code", "2").
        obj-cli-grp:SetProp("del-l",      "0").
        obj-cli-grp:SetProp("del-f",      "0").
        obj-cli-grp:SetProp("name",       v-cli-grp-name).
        obj-cli-grp:SetProp(obj-cli-grp:InitTag, "").
        imp-cli-grp = new ibs.th.bge.1crn.import.impcli-grps ().
        v-retfl = imp-cli-grp:Excute(obj-cli-grp).
        if not v-retfl then
          undo, throw new Progress.Lang.AppError(imp-cli-grp:Msg) .
        assign
          v-mode      = 'ДОБАВЛЕНИЕ':U
          v-is-deploy = true
          v-rid       = ?
          v-avrg-price    = no
          v-artic-disable = no
          v-base-code     = 0
          v-branch        = ""
          v-cash-pay      = 0
          v-cashier       = ""
          v-cons-vat-pc   = 0.0
          v-credit-pay    = 0
          v-firm-db-num   = 0
          v-head-position = ""
          v-KOPF          = ""
          v-negative-rest = no
          v-ord-prt       = no
          v-osn-base      = no
          v-property      = ""
          v-purch-code    = 1
          v-ret-credit-pay = 0
          v-sale-type     = 'орг':U
          v-sale-code     = 800000001
          v-snr-accnt     = ""
          v-SOEI          = ""
          v-transport-cli-type = ""
          v-transport-cli-code = 0
          v-transport-host     = 0
          v-transport-contract = 0
          v-transport-uslov    = 0
          v-transport-value    = 0.0
          v-main-obj-type = ""
          v-main-obj-code = 0
          v-als-gds       = no
          v-egrip-date    = ?
          v-egrip-num     = ""
          v-gen-s-f-office = yes
        .
    end.
      obj-clients = new clients ().
      obj-clients:SetProp(obj-clients:InitTag, "").
      obj-clients:SetProp("code",         objImp:code_).
      obj-clients:SetProp("del-l", string(objImp:del-l)).
      obj-clients:SetProp("del-f", string(objImp:del-f)).
      obj-clients:SetProp("name",         objImp:name_).
      obj-clients:SetProp("full-name",    objImp:name_).
      obj-clients:SetProp("city",      objImp:city).
      obj-clients:SetProp("ind",       objImp:ind).
      obj-clients:SetProp("inn",       objImp:inn).
      obj-clients:SetProp("kpp",       objImp:kpp).
      obj-clients:SetProp("agnt",      objImp:agnt).
      obj-clients:SetProp("post-adr",  objImp:post-adr).
      obj-clients:SetProp("e-mail",    objImp:e-mail).
      obj-clients:SetProp("leg-adr",   objImp:leg-adr).
      obj-clients:SetProp("okpo",      objImp:okpo).
      obj-clients:SetProp(obj-clients:InitTag, "").
      imp-clients = new ibs.th.bge.1crn.import.impclients ().
      v-retfl = imp-clients:Excute(obj-clients).
      if not v-retfl then undo, throw new Progress.Lang.AppError(imp-clients:Msg) .
      run adm/sysconf1.p
      (input-output v-rid
      ,input v-mode
      ,input yes
      ,input v-is-deploy
      ,input v-host-code
      ,input v-host-code
      ,input objImp:name_
      ,input v-avrg-price
      ,input v-artic-disable
      ,input v-base-code
      ,input v-branch
      ,input v-cash-pay
      ,input v-cashier
      ,input v-cons-vat-pc
      ,input v-credit-pay
      ,input v-firm-db-num
      ,input v-head-position
      ,input v-KOPF
      ,input v-negative-rest
      ,input v-ord-prt
      ,input v-osn-base
      ,input v-property
      ,input v-purch-code
      ,input v-ret-credit-pay
      ,input v-sale-type
      ,input v-sale-code
      ,input v-snr-accnt
      ,input v-SOEI
      ,input v-transport-cli-type
      ,input v-transport-cli-code
      ,input v-transport-host
      ,input v-transport-contract
      ,input v-transport-uslov
      ,input v-transport-value
      ,input v-main-obj-type
      ,input v-main-obj-code
      ,input v-als-gds
      ,input v-egrip-date
      ,input v-egrip-num
      ,input yes
      ) .
      v-retfl = true .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в фирмах" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      if Msg > "" then . else Msg = "ProError в фирмах" .
      v-retfl = false .
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в фирмах" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      if valid-object(imp-clients) then delete object imp-clients .
      if valid-object(obj-clients) then delete object obj-clients .
      if valid-object(imp-cli-grp) then delete object imp-cli-grp .
      if valid-object(obj-cli-grp) then delete object obj-cli-grp .
      return v-retfl .
    end finally .
  end method.
end class.
