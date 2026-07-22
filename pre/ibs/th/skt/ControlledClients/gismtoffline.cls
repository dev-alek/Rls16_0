using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.Adapters.LogWrite.
using ibs.th.gbl.propmap.
using ibs.th.gbl.sys.objsrv.
using ibs.th.gbl.sys.objth.
using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.GisMtOffline inherits objth :
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Работа с офлайн модулем ГИС МТ" get.
  define temp-table ttstatus-body  no-undo
  xml-node-name "body"
   field f_version        as character XML-NODE-NAME "version"
   field f_status         as character XML-NODE-NAME "status"
   field operationMode    as character
   field name             as character
   field lastSync         as character
   field inst             as character
   field errorcode        as character
   field reason           as character
   field lastUpdate       as character
   field vers             as character XML-NODE-NAME "dbVersion"
   field reqid            as recid     serialize-hidden
   index reqidpar reqid
   .
  define temp-table ttstatus no-undo
  xml-node-name "dbState"
   field reqid        as recid serialize-hidden
   field cis     as char
   field blocked_series     as char
   field blocked_gtin as char
   field blocked_cis as char
   index reqidpar reqid
   .
  define temp-table ttcis no-undo
  xml-node-name "cis"
   field s-reqid        as recid serialize-hidden
   field timeLag as char
   field localDocCount as char
   index reqidpar s-reqid
   .
  define temp-table ttblocked_series no-undo
  xml-node-name "blocked_series"
   field s-reqid        as recid serialize-hidden
   field timeLag as char
   field localDocCount as char
   index reqidpar s-reqid
   .
  define temp-table ttblocked_gtin no-undo
  xml-node-name "blocked_gtin"
   field s-reqid        as recid serialize-hidden
   field timeLag as char
   field localDocCount as char
   index reqidpar s-reqid
   .
  define temp-table ttblocked_cis no-undo
  xml-node-name "blocked_cis"
   field s-reqid        as recid serialize-hidden
   field timeLag as char
   field localDocCount as char
   index reqidpar s-reqid
   .
  define dataset gismt-mark-body  xml-node-name "bodys" for ttstatus-body, ttstatus, ttcis, ttblocked_series, ttblocked_gtin, ttblocked_cis
  data-relation gismt-mark-cis for ttstatus-body, ttstatus relation-fields (reqid,reqid) nested
  .
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
   method public character GetParam ():
     define variable vRetProp as character no-undo.
     define buffer buf_sys-ctrl for ub.sys-ctrl .
     find first buf_sys-ctrl no-lock no-error.
     if available buf_sys-ctrl and buf_sys-ctrl.db-num <> 0
     then do:
         vRetProp = get-gismt-prop ('БД':U,
                                    buf_sys-ctrl.db-num) no-error.
     end.
     return "".
   end method.
   method public void ChkStsOffline ():
       RunChkStsAndInit(yes, yes).
       EmptyTempTable().
   end method.
   method public character GetChkStsOffline (
       output oVersion as character,
       output oTimeLag as character,
       output olastUpdate as character,
       output oLastSync as character,
       output oInst as character,
       output odbVersion as character
       ):
       define variable vStatus as character no-undo.
       define variable vTimeLag as int64   no-undo.
       define variable vTimeDec as decimal no-undo.
       define variable vSync as int64 no-undo.
       define variable vTimeSync as datetime-tz no-undo.
       define variable vTz as integer no-undo.
       vTimeLag = 0.
       RunChkStsAndInit(yes, no).
       find first ttstatus-body no-error.
       if avail ttstatus-body and
          ttstatus-body.errorcode > ""
       then do:
           assign
             vStatus     = ttstatus-body.reason
             oVersion    = "Не определена"
             oInst       = "Не определена"
             odbVersion  = "Не определена"
             olastUpdate = "0"
             oLastSync   = "0"
             .
       end.
       else if avail ttstatus-body
       then do:
           assign
             vStatus     = ttstatus-body.f_status
             oVersion    = ttstatus-body.f_version
             oInst       = ttstatus-body.inst
             odbVersion  = ttstatus-body.vers
             olastUpdate = ttstatus-body.lastUpdate
             oLastSync   = ttstatus-body.lastSync
             .
           vSync = int64(ttstatus-body.lastSync) no-error.
           if not error-status:error
              and vSync <> 0
           then do:
               vTz = TIMEZONE (now).
               vTimeSync = DateTime("01/01/1970") + vSync + vTz * 60000.
               vTimeDec = (now - vTimeSync) / 3600000 no-error.
               if vTimeDec <> 0 and vTimeDec <> ? then do:
                  vTimeLag  = Round(vTimeDec, 0).
                  if  vTimeLag < vTimeDec then vTimeLag = vTimeLag + 1.
               end.
           end.
       end.
       else
          assign
             vStatus     = "Нет связи с ЛМ ЧЗ"
             oVersion    = "Не определена"
             oInst       = "Не определена"
             odbVersion  = "Не определена"
             olastUpdate = "0"
             oLastSync   = "0"
             .
       if vTimeLag <> ?
       then oTimeLag = string(vTimeLag).
       else oTimeLag = "0".
       if oInst = "" then
          oInst = "Не определена".
       if odbVersion = "" then
          odbVersion  = "Не определена".
       EmptyTempTable().
       return vStatus.
   end method.
   method public void RunChkStsAndInit (
     iStartInit as log,
     iWriteLog as log
     ):
     define variable vTimeStart   as datetime-tz no-undo.
     define variable vlongJson    as longchar no-undo.
     define variable vlongJsonCh  as longchar no-undo.
     define variable hDS          as handle no-undo.
     define variable vRetOk       as logical no-undo.
     define variable cmd          as character   no-undo.
     define variable vFileResult  as character   no-undo.
     define variable vFileResXml  as character   no-undo.
     define variable vFileErr     as character   no-undo.
     define variable vFileCmd     as character   no-undo.
     define variable vParam       as character no-undo.
     define variable vReqSts      as logical no-undo.
     vParam = GetParam().
     assign
        vlongJson = ""
        vTimeStart = now
        vReqSts = no
        .
     EmptyTempTable().
     run gbl/_tmpfile.p ( "StsOffGisMTRes", ".txt", output vFileResult ) .
     run gbl/_tmpfile.p ( "StsOffGisMTErr", ".txt", output vFileErr ) .
     run gbl/_tmpfile.p ( "StsOffGisMTResXml", ".xml", output vFileResXml ) .
     if session:debug-alert then run gbl/_tmpfile.p ( "StsOfflineCmd", ".txt", output vFileCmd ) .
     do transaction
     on error undo, return error:
         cmd = substitute ('&1 --connect-timeout &6 --max-time &6 -X GET -H "Accept: application/json" -H &2 &3 >&4 --stderr &5',
                          search ("exe/curl.exe"),
                          quoter("Authorization: Basic " + gismt-OflineAutoriz),
                          quoter(gismt-OflineAdress + "/status"),
                          vFileResult,
                          vFileErr,
                          trim(replace(string(gismt-WaitTime, "zzzz9.99999"),".",","),"")).
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
               vlongJsonCh = REPLACE(vlongJson, 'null', '"unknown"').
               vlongJsonCh = REPLACE(vlongJsonCh, '"replicationStatus":~{}', '"replicationStatus":""') no-error.
               vlongJsonCh = REPLACE(vlongJsonCh, '"dbState":~{}', '"dbState":""') no-error.
               copy-lob from vlongJsonCh to file vFileResult no-error.
               cmd = substitute ('&1 -file=&2 >&3',
                                      search("exe/json2xml.exe"),
                                      vFileResult,
                                      vFileResXml).
               os-command silent value (cmd).
               copy-lob from file vFileResXml to vlongJson no-error.
               vRetOk = dataset gismt-mark-body:read-xml("FILE":U, vFileResXml, "EMPTY":U, ?, ?) no-error.
               find first ttstatus-body no-error.
               if avail ttstatus-body  and
                  ttstatus-body.f_status = "not_configured" and
                  iStartInit
               then do:
                  RunInitOffline() no-error.
                  vReqSts = yes.
               end.
            end.
         end.
     end.
     if iWriteLog then WriteLogOffLine(vlongJson, vReqSts) no-error.
     if not session:debug-alert
     then do:
         os-delete silent value(vFileResult)     no-error.
         os-delete silent value(vFileErr)        no-error.
         os-delete silent value(vFileResXml)     no-error.
     end.
   end method.
   method public void RunInitOffline():
        define variable vlongJson as longchar no-undo.
        define variable hDS as handle no-undo.
        define variable vRetOk as logical no-undo.
        define variable vCdnAdr as character no-undo.
        define variable cmd as character   no-undo.
        define variable vFileResult    as character   no-undo.
        define variable vFileErr as character   no-undo.
        define variable vTimeCur as datetime-tz no-undo.
        def var vReqTime as int64 no-undo.
        define variable vFlagOk as log no-undo.
        define variable vTokenFile as char no-undo.
        define variable vFileCmd as char no-undo.
        assign
           vlongJson = ""
           vFlagOk = no
           .
        run gbl/_tmpfile.p ( "InitOfflineGisMTRes", ".txt", output vFileResult ) .
        run gbl/_tmpfile.p ( "InitOfflineGisMTErr", ".txt", output vFileErr ) .
        run gbl/_tmpfile.p ( "InitOfflineToken", ".txt", output vTokenFile ) .
        if session:debug-alert then run gbl/_tmpfile.p ( "InitOfflineCmd", ".txt", output vFileCmd ) .
        OUTPUT STREAM out_data TO value(vTokenFile).
        PUT STREAM out_data UNFORMATTED
          '~{"token":"' gismt-RegKey '"~}' .
        OUTPUT STREAM out_data CLOSE.
        cmd = substitute ('&1 --connect-timeout &6 --max-time &6 -X POST -H "Accept: application/json" -H &2 --data @&7 &3 >&4 --stderr &5',
                          search ("exe/curl.exe"),
                          quoter("Authorization: Basic " + gismt-OflineAutoriz),
                          quoter(gismt-OflineAdress + "/init"),
                          vFileResult,
                          vFileErr,
                          trim(replace(string(gismt-WaitTime, "zzzz9.99999"),".",","),""),
                          searchfile(vTokenFile)
                          ).
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
            if file-info:file-size = 0 then vFlagOk = yes.
         end.
         if not session:debug-alert
         then do:
             os-delete silent value(vFileResult)     no-error.
             os-delete silent value(vFileErr)        no-error.
             os-delete silent value(vTokenFile)      no-error.
         end.
   end method.
   method  private void WriteLogOffLine
       (iResultJson as longchar,
        iFlagOk as logical):
        define variable vFileName as character no-undo.
        define variable vCh as character no-undo.
        define variable vFullCh as character no-undo.
        define variable vWork as character no-undo.
        define variable vNum as integer no-undo.
        define variable vStrLong as longchar no-undo.
        define variable vStatus as character no-undo.
        define variable vTimeLag as datetime-tz no-undo.
        vFileName = "GisMtOffLine-" + replace(string(today),"/","-") +  ".log".
        assign
           vWork = ""
           vCh = "param.txt"
           .
        vFullCh = searchfile(vCh).
        if vFullCh <> ? and vFullCh <> ""
        then vNum = index(vFullCh,"\pid_").
        if vNum <> 0 then vWork = substring(vFullCh, 1, vNum).
        vFileName =  vWork + vFileName.
        find first ttstatus-body
           no-lock no-error.
        if avail ttstatus-body then
        do:
           vTimeLag = GetStatusTime(ttstatus-body.lastSync).
           vStatus =  substitute("Статус модуля ЛМ ЧЗ:&1&2&1Дата и время синхронизации:&1&3",
                                 chr(9),
                                 ttstatus-body.f_status,
                                 vTimeLag).
        end.
        else vStatus =  "Ошибка получения статуса ЛМ ЧЗ".
        if iResultJson = "" then vStatus = "Не получен ответ от ЛМ ЧЗ.".
        vCh = "".
        if searchfile(vFileName) <> ?
        then do:
           file-info:file-name = searchfile(vFileName).
           if file-info:file-size <> 0 then vCh = " ".
        end.
        OUTPUT STREAM out_data TO value(vFileName) APPEND.
        PUT STREAM out_data UNFORMATTED
          vCh skip now chr(9) vStatus skip .
        OUTPUT STREAM out_data CLOSE.
        copy-lob from iResultJson to file vFileName append no-error.
        if iFlagOk then do:
            OUTPUT STREAM out_data TO value(vFileName) APPEND.
            PUT STREAM out_data UNFORMATTED
              skip "Запущена инициализация модуля ЛМ ЧЗ".
            OUTPUT STREAM out_data CLOSE.
        end.
   end method.
   method  private datetime-tz GetStatusTime
       (iLastSync as char):
       define variable vSync as int64 no-undo.
       define variable vTimeSync as datetime-tz no-undo.
       define variable vTz as integer no-undo.
       vSync = int64(iLastSync).
       vTz = TIMEZONE (now).
       vTimeSync = DateTime("01/01/1970") + vSync + vTz * 60000.
       return vTimeSync.
   end method.
   method public void ProcInit ():
     define variable vParam       as character no-undo.
     define variable vReqSts      as logical no-undo.
     vParam = GetParam().
     RunInitOffline() no-error.
   end method.
   method  private void EmptyTempTable ():
      empty temp-table ttstatus-body.
      empty temp-table ttstatus.
      empty temp-table ttblocked_series.
      empty temp-table ttblocked_gtin.
      empty temp-table ttblocked_cis.
   end method.
   constructor public GisMtOffline (  ):
      super ().
   end constructor.
   destructor public GisMtOffline ( ):
   end destructor.
end class.
