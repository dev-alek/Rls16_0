using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.Adapters.LogWrite.
using ibs.th.gbl.propmap.
using ibs.th.gbl.sys.objsrv.
using ibs.th.gbl.sys.objth.
using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.GisMtCDN inherits objth :
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Работа с CDN площадками ГИС МТ" get.
  define temp-table tthosts-body  no-undo serialize-name  "bodys"
   field code            as int
   field description     as char
   field avgTimeMs       as int
   .
  define temp-table tthosts no-undo
   SERIALIZE-NAME "hosts"
   field reqid        as recid serialize-hidden
   field host_adr     as char SERIALIZE-NAME "host"
   index reqidpar reqid host_adr
   .
  define temp-table tthosts-adr  no-undo serialize-name  "bodys"
   field code            as int
   field description     as char
   field avgTimeMs       as int
   .
  define temp-table tt-code no-undo like ub.code.
  define dataset gismt-host-body SERIALIZE-HIDDEN  for tthosts-body, tthosts
     PARENT-ID-RELATION FOR tthosts-body, tthosts PARENT-ID-FIELD reqid .
  define dataset gismt-host-adr SERIALIZE-HIDDEN  for tthosts-adr .
  define stream out_data.
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
 define variable gismt-AdressPort   as character no-undo.
 define variable gismt-DopParam     as character no-undo.
 define variable gismt-GisAdress    as character no-undo.
 define variable gismt-ProxyLogin   as character no-undo.
 define variable gismt-ProxyPswd    as character no-undo.
 define variable gismt-MaxTime      as integer   no-undo.
 define variable gismt-RegKey       as character no-undo.
 define variable gismt-TimeFalStart as integer   no-undo.
 define variable gismt-WaitTime     as decimal   no-undo.
 define variable gismt-WaitTimePlus as decimal   no-undo.
 define variable gismt-CrashSituat  as logical   no-undo.
 define variable gismt-BanDate      as integer   no-undo.
 define variable gismt-cdnTurnOn    as logical   no-undo.
 define variable gismt-cdnAdress    as character no-undo.
 define variable gismt-cdnRepeat    as logical   no-undo.
 define variable gismt-cdnChange    as logical   no-undo.
 define variable gismt-cdnTimeUpd   as integer   no-undo.
 define variable gismt-UpdateRequest as logical   no-undo.
 define variable gismt-OflineAdress  as character no-undo.
 define variable gismt-OflineAutoriz as character no-undo.
 define variable gismt-OflineLogin   as character no-undo.
 define variable gismt-OflinePswd    as character no-undo.
 define variable gismt-OflineDate    as date      no-undo.
method public character ConvBase64
(input iString as char):
  define variable vSize       as integer   no-undo.
  define variable vDataDc1    as memptr    no-undo.
  define variable vDataDc2    as memptr    no-undo.
  define variable vEnCode     as character no-undo.
  define variable vBase64Str  as character no-undo.
  do
  on error undo, return error return-value
  :
    if iString = ?
    then return "".
    vSize  = length(iString).
    SET-SIZE(vDataDc1 ) = vSize + 1.
    SET-SIZE(vDataDc2 ) = vSize.
    put-string(vDataDc1, 1, vSize) = iString.
    copy-lob from vDataDc1 starting at 1 for vSize to vDataDc2 no-convert.
    vEnCode =  base64-encode (vDataDc2).
    vBase64Str = substring(vEnCode,1).
    SET-SIZE(vDataDc1)  = 0 no-error.
    SET-SIZE(vDataDc2)  = 0 no-error.
  end.
  return vBase64Str.
end.
method public character get-thbj-attr-prop
(input p-obj-type as char,
 input p-obj-code as int,
 input p-upper-prop-code as char,
 input p-prop-code as char
 ):
    define buffer buf_thbj-attr for ub.thbj-attr.
    define variable v-reg-code as integer no-undo.
    find first buf_thbj-attr no-lock where
               buf_thbj-attr.obj-type = p-obj-type
           and buf_thbj-attr.obj-code = p-obj-code
           and buf_thbj-attr.upper-prop-code = p-upper-prop-code
           and buf_thbj-attr.prop-code = p-prop-code
    no-error.
    if not available buf_thbj-attr and p-obj-type = 'БД':U then
    do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run regcode in ibs.th.gbl.gbl-hndllib:g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-reg-code
  )  .
       if v-reg-code <> ? and v-reg-code <> 0 then do:
           find first buf_thbj-attr no-lock where
                      buf_thbj-attr.obj-type = 'регион':U
                  and buf_thbj-attr.obj-code = v-reg-code
                  and buf_thbj-attr.upper-prop-code = p-upper-prop-code
                  and buf_thbj-attr.prop-code = p-prop-code
           no-error.
       end.
    end.
    if not available buf_thbj-attr and p-obj-type <> ""
    then do:
       find first buf_thbj-attr no-lock where
                  buf_thbj-attr.obj-type = ""
              and buf_thbj-attr.obj-code = 0
              and buf_thbj-attr.upper-prop-code = p-upper-prop-code
              and buf_thbj-attr.prop-code = p-prop-code
       no-error.
    end.
    if avail buf_thbj-attr then do:
        case buf_thbj-attr.prop-value-type:
            when "character"
               then return buf_thbj-attr.property-value-character.
            when "integer"
               then return string(buf_thbj-attr.property-value-integer).
            when "decimal"
               then return string(buf_thbj-attr.property-value-decimal).
            when "logical"
               then return string(buf_thbj-attr.property-value-logical).
        end case.
    end.
    return "".
end.
method public character get-gismt-prop
(input p-obj-type as char,
 input p-obj-code as int):
    define buffer buf_code for ub.code.
    define buffer buf_thbj-attr for ub.thbj-attr.
    assign
       gismt-AdressPort = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'adressPort':U)
       gismt-DopParam   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'dopParam':U)
       gismt-GisAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'gisAdress':U)
       gismt-ProxyLogin = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'proxyLogin':U)
       gismt-ProxyPswd  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'proxyPswd':U)
       gismt-MaxTime    = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'maxTime':U))
       gismt-RegKey     = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'regKey':U)
       gismt-TimeFalStart = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'timeFalStart':U))
       gismt-WaitTime    = decimal(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'waitTime':U))
       gismt-CrashSituat = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'crashSituat':U))
       gismt-BanDate     = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'banDate':U))
       gismt-cdnTurnOn   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnTurnOn':U))
       gismt-cdnAdress   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnAdress':U)
       gismt-cdnRepeat   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnRepeat':U))
       gismt-cdnChange   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnChange':U))
       gismt-cdnTimeUpd  = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnTimeUpdate':U))
       gismt-UpdateRequest = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'UpdateRequest':U))
       gismt-OflineAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflineAdress':U)
       gismt-OflineLogin   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflineLogin':U)
       gismt-OflinePswd    = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflinePswd':U)
       .
    if gismt-OflineLogin <> "" and gismt-OflinePswd <> ""
    then gismt-OflineAutoriz = ConvBase64(gismt-OflineLogin + ":" + gismt-OflinePswd).
    find first buf_code no-lock where
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq string(p-obj-code)
       no-error.
    if not avail buf_code then
    find first buf_code no-lock where
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq "0"
       no-error.
    if avail buf_code then  gismt-OflineDate = date(buf_code.CodeValue) no-error.
    else gismt-OflineDate = today.
  return "".
end.
  method public character GetParamProxy ():
     define variable vParamProxy as character no-undo.
     define variable vRetProp as character no-undo.
     define buffer buf_sys-ctrl for ub.sys-ctrl .
     find first buf_sys-ctrl no-lock no-error.
     if available buf_sys-ctrl and buf_sys-ctrl.db-num <> 0
     then do:
         vRetProp = get-gismt-prop ('БД':U,
                                    buf_sys-ctrl.db-num) no-error.
     end.
     if gismt-AdressPort <> "" and gismt-ProxyLogin <> "" and gismt-ProxyPswd <> ""
        then vParamProxy = substitute ('-x &1 -U &2:&3',gismt-AdressPort,gismt-ProxyLogin,gismt-ProxyPswd).
     else if gismt-AdressPort <> "" then vParamProxy = substitute ('-x &1',gismt-AdressPort).
     else vParamProxy = "".
     return vParamProxy.
  end method.
   method public void GetListCdn ():
     def variable vTimeStart as datetime-tz no-undo.
     define variable vlongJson as longchar no-undo.
     define variable hDS as handle no-undo.
     define variable vRetOk as logical no-undo.
     define variable vCdnAdr as character no-undo.
     define variable cmd as character   no-undo.
     define variable vFileResult    as character   no-undo.
     define variable vFileResJson    as character   no-undo.
     define variable vFileErr as character   no-undo.
     define variable vParamProxy as character no-undo.
     define variable vReqSDN as logical no-undo.
     define variable vFileCmd as char no-undo.
     vParamProxy = GetParamProxy().
     if not gismt-cdnTurnOn then return .
     vlongJson = "".
     vTimeStart = now.
     for each tthosts-body:
         delete tthosts-body.
     end.
     for each tthosts:
         delete tthosts.
     end.
     for each tt-code:
         delete tt-code.
     end.
     do transaction
     on error undo, return error:
         vRetOk = SetCdnUpd(vTimeStart).
         run gbl/_tmpfile.p ( "CdnListGisMTRes", ".txt", output vFileResult ) .
         run gbl/_tmpfile.p ( "CdnListGisMTErr", ".txt", output vFileErr ) .
         run gbl/_tmpfile.p ( "CdnListGisMTRes", ".json", output vFileResJson ) .
         if session:debug-alert then run gbl/_tmpfile.p ( "CdnListGisMTCmd", ".txt", output vFileCmd ) .
         cmd = substitute ('&1 --connect-timeout &8 --max-time &8 &7 -X GET &3 -H "Content-Type: application/json" -H &4 &5 >&2 --stderr &6',
                          search ("exe/curl.exe"),
                          vFileResult,
                          quoter(gismt-cdnAdress),
                          quoter("X-api-Key: " + gismt-RegKey),
                          vParamProxy,
                          vFileErr,
                          gismt-DopParam,
                          trim(replace(string(gismt-WaitTime * 2, "zzzz9.99999"),".",","),"")).
         if session:debug-alert then
         do:
             OUTPUT STREAM out_data TO value(vFileCmd).
             PUT STREAM out_data UNFORMATTED
              cmd .
             OUTPUT STREAM out_data CLOSE.
         end.
         os-command silent value(cmd).
         if searchFile(vfileresult) <> ? then do:
            file-info:file-name = searchFile(vfileresult).
            if file-info:file-size <> 0 then do:
                copy-lob from file vFileResult to vlongJson no-error.
                vlongJson = '~{"bodys":[' + vlongJson + "]}" .
                hDS = dataset gismt-host-body:handle.
                vRetOk  = hDS:read-json("longchar":U, vlongJson) no-error.
                dataset gismt-host-body:write-json("FILE":U, vFileResJson) no-error.
                find first tthosts-body no-error.
                if avail tthosts-body  and tthosts-body.code = 0 then
                do:
                    for each tthosts:
                       vReqSDN = yes.
                       ReqHost(tthosts.host_adr, vParamProxy, vTimeStart).
                    end.
                    UpdCdNAdrFormTT().
                end.
            end.
         end.
         DelOldCdn(vTimeStart).
         DelCdnUpd().
         WriteLogCdn(vReqSDN).
         if not session:debug-alert
         then do:
             os-delete silent value(vFileResult)     no-error.
             os-delete silent value(vFileErr)        no-error.
             os-delete silent value(vFileResJson)     no-error.
         end.
     end.
   end method.
   method public void UpdTimetCdn ():
     define variable vTimeStart  as datetime-tz no-undo.
     define variable vTimeUnbl   as datetime-tz no-undo.
     define variable vParamProxy as character   no-undo.
     define variable vRetOk      as logical     no-undo.
     define variable vFileName   as character   no-undo.
     define buffer buf_code for ub.code.
     vParamProxy = GetParamProxy().
     if not gismt-cdnTurnOn then return .
     vTimeStart = now.
     empty temp-table tthosts-body.
     empty temp-table tthosts.
     empty temp-table tt-code.
     do transaction
     on error undo, return error:
         vRetOk = SetCdnUpd(vTimeStart).
         for each buf_code no-lock where
                  buf_code.parent = "CDN_GisMt"
              and buf_code.misc2 <> "":
            vTimeUnbl = datetime-tz(buf_code.misc2) no-error.
            if vTimeUnbl < vTimeStart then do:
               ReqHost(buf_code.code, vParamProxy, vTimeStart).
            end.
         end.
         UpdCdNAdrFormTT().
         DelCdnUpd().
         vFileName = GetLogName().
         OUTPUT STREAM out_data TO value(vFileName) APPEND.
         PUT STREAM out_data UNFORMATTED
           now  chr(9) "Установлено новое время доступа к ранее заблокированным площадкам:" skip.
         OUTPUT STREAM out_data CLOSE.
         for each tt-code,
            first buf_code no-lock where
                  buf_code.parent = tt-code.parent
              and buf_code.code = tt-code.code:
            OUTPUT STREAM out_data TO value(vFileName) APPEND.
            PUT STREAM out_data UNFORMATTED
                buf_code.misc1 chr(9) buf_code.code chr(9) buf_code.codeval chr(9) buf_code.misc2 chr(9) skip.
            OUTPUT STREAM out_data CLOSE.
         end.
         empty temp-table tt-code.
     end.
   end method.
   method public void ReqHost
       (iHostAdr as char,
        iParamProxy as char,
        iTimeStart as datetime-tz):
        def var vHostAdress as char no-undo.
        define variable vlongJson as longchar no-undo.
        define variable hDS as handle no-undo.
        define variable vRetOk as logical no-undo.
        define variable vCdnAdr as character no-undo.
        define variable cmd as character   no-undo.
        define variable vFileResult    as character   no-undo.
        define variable vFileErr as character   no-undo.
        define variable vFileResJson    as character   no-undo.
        define variable vTimeCur as datetime-tz no-undo.
        def var vReqTime as int64 no-undo.
        define variable vFlagOk as log no-undo.
        vHostAdress = iHostAdr + "/api/v4/true-api/cdn/health/check".
        vlongJson = "".
        vFlagOk = no.
        for each tthosts-adr:
            delete tthosts-adr.
        end.
        run gbl/_tmpfile.p ( "CdnGisMTRes", ".txt", output vFileResult ) .
        run gbl/_tmpfile.p ( "CdnGisMTErr", ".txt", output vFileErr ) .
        run gbl/_tmpfile.p ( "CdnListGisMTRes", ".json", output vFileResJson ) .
        cmd = substitute ('&1  --connect-timeout &8 --max-time &8 &7 -X GET &3 -H "Content-Type: application/json" -H &4 &5 >&2 --stderr &6',
                          search ("exe/curl.exe"),
                          vFileResult,
                          quoter(vHostAdress),
                          quoter("X-api-Key: " + gismt-RegKey),
                          iParamProxy,
                          vFileErr,
                          gismt-DopParam,
                          trim(replace(string(gismt-WaitTime, "zzzz9.99999"),".",","),"")).
         vTimeCur = now.
         os-command silent value(cmd).
         vReqTime = now -  vTimeCur.
         if searchFile(vfileresult) <> ? then do:
            file-info:file-name = searchFile(vfileresult).
            if file-info:file-size <> 0 then do:
                copy-lob from file vFileResult to vlongJson no-error.
                vlongJson = '~{"bodys":[' + vlongJson + "]}" .
                hDS = dataset gismt-host-adr:handle.
                vRetOk  = hDS:read-json("longchar":U, vlongJson) no-error.
                dataset gismt-host-adr:write-json("FILE":U, vFileResJson) no-error.
                find first tthosts-adr no-error.
                if avail tthosts-adr  and
                   tthosts-adr.code = 0 then
                do:
                    UpdCdNAdr(iHostAdr, iTimeStart, vReqTime, tthosts-adr.avgTimeMs).
                    vFlagOk = yes.
                end.
            end.
         end.
         if not vFlagOk
         then do:
            vReqTime = 5 * 3600 * 1000.
            UpdCdNAdr(iHostAdr, iTimeStart, vReqTime, -1).
         end.
         if not session:debug-alert
         then do:
             os-delete silent value(vFileResult)     no-error.
             os-delete silent value(vFileErr)        no-error.
             os-delete silent value(vFileResJson)     no-error.
         end.
   end method.
   method public logical CheckCdnUpd ():
       def buffer buf_code for ub.code.
       def var vCheck as logical no-undo.
       find first buf_code where
                  buf_code.parent = "CDN_GisMt"
              and buf_code.code = "CDN_Upd"
           no-lock no-error.
       if not avail buf_code then vCheck = yes.
       return vCheck.
   end method.
   method public logical CheckCdnUpdTime (iTimeStart as datetime-tz):
      def buffer buf_code for ub.code.
      def var vCheck as logical no-undo.
      def var vTimeUpd as datetime-tz no-undo.
      vCheck = no.
      find first buf_code where
                 buf_code.parent = "CDN_GisMt"
         no-lock no-error.
      if avail buf_code then vTimeUpd = datetime-tz(buf_code.misc1) no-error.
      if (not avail buf_code) or
         vTimeUpd = ? or
         (vTimeUpd <> ? and
          datetime-tz(vTimeUpd) < iTimeStart and
          (iTimeStart - datetime-tz(vTimeUpd)) >= gismt-cdnTimeUpd * 3600 * 1000)
      then vCheck = yes.
      return vCheck.
   end.
   method public logical SetCdnUpd (iTimeStart as datetime-tz):
       def buffer buf_code for ub.code.
       def var vCheck as logical no-undo.
       find first buf_code where
                  buf_code.parent = "CDN_GisMt"
              and buf_code.code = "CDN_Upd"
           no-lock no-error.
       if not avail buf_code then do:
           create buf_code.
           assign
              buf_code.parent = "CDN_GisMt"
              buf_code.code = "CDN_Upd"
              buf_code.codename = "Запущен процесс обновления площадок ГИС МТ"
              buf_code.codeval = string(iTimeStart)
              .
           vCheck = yes.
       end.
       return vCheck.
   end method.
   method public void DelCdnUpd ():
       def buffer buf_code for ub.code.
       for each buf_code where
                buf_code.parent = "CDN_GisMt"
            and buf_code.code = "CDN_Upd"
           exclusive-lock:
          delete buf_code.
       end.
   end method.
   method public void UpdCdNAdr
       (iCdnAdr as char,
        iTimeStart as datetime-tz,
        iReqTime as int64,
        iavgTimeMs as int):
        find first tt-code where
                   tt-code.parent = "CDN_GisMt"
               and tt-code.code = iCdnAdr
            no-error.
        if not avail tt-code then do:
           create tt-code.
        end.
        assign
           tt-code.parent = "CDN_GisMt"
           tt-code.code = iCdnAdr
           tt-code.codename = "Адрес площадки ГИС МТ"
           tt-code.codeval = string(iReqTime)
           tt-code.misc1 = String(iTimeStart)
           tt-code.misc2 = if iavgTimeMs = -1 then string(now + 15000 * 60) else  ""
           .
   end method.
   method public void UpdCdNAdrFormTT ():
        def buffer buf_code for ub.code.
        for each tt-code:
            find first buf_code where
                       buf_code.parent = tt-code.parent
                   and buf_code.code = tt-code.code
               exclusive-lock no-wait no-error.
            if not avail buf_code then do:
              if locked buf_code then do:
              end.
              else do:
                 create buf_code.
              end.
            end.
            if avail buf_code then do:
               buffer-copy tt-code to buf_code.
            end.
        end.
   end method.
   method public void DelOldCdn
        (iTimeStart as datetime-tz):
        def buffer buf_code for ub.code.
        def buffer chg_code for ub.code.
        if can-find(first buf_code no-lock where
                     buf_code.parent = "CDN_GisMt"
                 and buf_code.misc1 = String(iTimeStart)
                 ) then
        do:
            for each buf_code no-lock where
                     buf_code.parent = "CDN_GisMt"
               :
               if  buf_code.misc1 <> String(iTimeStart)
               and buf_code.code <> "CDN_Upd" then
               do:
                   find first chg_code where rowid(chg_code) = rowid(buf_code)
                      exclusive-lock no-wait no-error.
                   if avail chg_code then
                      delete chg_code.
               end.
            end.
        end.
        else do:
            for each buf_code no-lock where
                     buf_code.parent = "CDN_GisMt"
               :
               find first chg_code where rowid(chg_code) = rowid(buf_code)
                  exclusive-lock no-wait no-error.
               if avail chg_code then
                  chg_code.misc2 = "".
            end.
        end.
   end method.
   method private character GetLogName ():
        define variable vFileName as character no-undo.
        define variable vCh as character no-undo.
        define variable vFullCh as character no-undo.
        define variable vWork as character no-undo.
        define variable vNum as int no-undo.
        vFileName = "GisMtCDN-" + replace(string(today),"/","-") +  ".log".
        assign
           vWork = ""
           vCh = "param.txt"
           .
        vFullCh = searchfile(vCh).
        if vFullCh <> ? and vFullCh <> ""
        then vNum = index(vFullCh,"\pid_").
        if vNum <> 0 then vWork = substring(vFullCh, 1, vNum).
        vFileName =  vWork + vFileName.
        return vFileName.
   end method.
   method  private void WriteLogCdn
       (iFlagOk as logical):
        def buffer buf_code for ub.code.
        define variable vFileName as character no-undo.
        define variable vCh as character no-undo.
        define variable vFullCh as character no-undo.
        define variable vWork as character no-undo.
        define variable vNum as int no-undo.
        define variable vStrLong as longchar no-undo.
        define variable vTimeUnBlock as character no-undo.
        vFileName = GetLogName().
        if not iFlagOk then do:
            OUTPUT STREAM out_data TO value(vFileName) APPEND.
            PUT STREAM out_data UNFORMATTED
              now chr(9) "Не удалось обновить CDN площадки. Текущие площадки:" skip.
            OUTPUT STREAM out_data CLOSE.
        end.
        else do:
            OUTPUT STREAM out_data TO value(vFileName) APPEND.
            PUT STREAM out_data UNFORMATTED
              now chr(9) "CDN площадки обновлены:" skip.
            OUTPUT STREAM out_data CLOSE.
        end.
        for each buf_code no-lock where
                 buf_code.parent = "CDN_GisMt":
           vTimeUnBlock = if buf_code.misc2 = "" then "null" else buf_code.misc2.
           OUTPUT STREAM out_data TO value(vFileName) APPEND.
           PUT STREAM out_data UNFORMATTED
             buf_code.misc1 chr(9) buf_code.code chr(9) buf_code.codeval chr(9) vTimeUnBlock chr(9) skip.
           OUTPUT STREAM out_data CLOSE.
        end.
   end method.
   constructor public GisMtCDN (  ):
      super ().
   end constructor.
   destructor public GisMtCDN ( ):
   end destructor.
end class.
