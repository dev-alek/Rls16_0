using Progress.Lang.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.clients.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.vsdtostorage:
  define property Msg as character no-undo
    get.
    private set.
  define buffer buf_vsd for ub.vsd.
  method private void exception( arg as handle, invsdObj as class vsdsub, t-h as handle ):
    invsdObj:setMsg(arg:get-message (1)).
    invsdObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.
  end method.
  method private void exception( arg as char ):
    Msg = arg.
    return.
  end method.
  method public void insertDB( input vsdsubObj as vsdsub  ):
    def buffer bf_vsd_chk for ub.vsd.
    create buf_vsd.
    find first ub.sys-ctrl no-lock.
    assign
      buf_vsd.id     = next-value (s-vsd-id, ub)
      buf_vsd.db-num = ub.sys-ctrl.db-num
    no-error.
    if error-status:error
    then do:
      find last bf_vsd_chk no-lock where bf_vsd_chk.db-num = ub.sys-ctrl.db-num use-index pi.
      current-value (s-vsd-id, ub) = bf_vsd_chk.id.
      assign
        buf_vsd.id     = next-value (s-vsd-id, ub)
        buf_vsd.db-num = ub.sys-ctrl.db-num
      no-error.
      if error-status:error
      then do:
        exception(error-status, vsdsubObj, buffer buf_vsd:handle).
        return.
      end.
    end.
    setDataStorage(input vsdsubObj, buffer buf_vsd).
    return.
  end method.
  method public void updateDB( input vsdsubObj as vsdsub  ):
    find first buf_vsd where
      buf_vsd.id     = vsdsubObj:ID and
      buf_vsd.db-num = vsdsubObj:DBNum no-error.
    if not available (buf_vsd)
    then do:
      exception(error-status, vsdsubObj, buffer buf_vsd:handle).
      return.
    end.
    setDataStorage(input vsdsubObj, buffer buf_vsd).
    release buf_vsd.
    return.
  end method.
  method public void deleteDB( input vsdsubObj as vsdsub  ):
    define buffer buf_vsd-attr for ub.vsd-attr .
    find first buf_vsd where
      buf_vsd.id     = vsdsubObj:ID and
      buf_vsd.db-num = vsdsubObj:DBNum no-error.
    if not available (buf_vsd)
    then do:
      exception(error-status, vsdsubObj, buffer buf_vsd:handle).
      return.
    end.
    for each buf_vsd-attr exclusive-lock where buf_vsd-attr.ID     = buf_vsd.ID
                                           and buf_vsd-attr.db-num = buf_vsd.db-num :
      delete buf_vsd-attr .
    end.
    delete buf_vsd.
    return.
  end method.
  method public class vsdsubs getVSDsubs ( buffer buf_parts for ub.parts ):
    define variable keyrecObj as class keyrec no-undo.
    define variable keyrec as character no-undo.
    keyrecObj = new keyrec ().
    keyrecObj:GenKeyRec('parts':U, buffer buf_parts:handle, output keyrec).
    delete object keyrecObj.
    return getVSDsubs (input "part-key", input keyrec).
  end.
  method public class vsdsubs getVSDsubs (input inFieldName as character, input inValue as character ):
    define variable vsdsubsObj as class vsdsubs no-undo.
    vsdsubsObj = new vsdsubs ().
    case inFieldName:
    when "part-key" then do:
      for each buf_vsd no-lock where buf_vsd.part-key = inValue by buf_vsd.vsd-type:
        vsdsubsObj:AddItem(getDataStorage (buffer buf_vsd)).
      end.
    end.
    when "UUID" then do:
      for each buf_vsd no-lock where buf_vsd.UUID = inValue by buf_vsd.vsd-type:
        vsdsubsObj:AddItem(getDataStorage (buffer buf_vsd)).
      end.
    end.
    otherwise do:
      exception( substitute ("Нет обработки для поля - &1", inFieldName) ).
    end.
    end case.
    return vsdsubsObj.
  end method.
  method public class vsdsubs getVSDsubs (input inObjType    as character,
                                          input  inObjCode    as int64 ,
                                          input  inStatusList as character ):
      define variable vsdsubsObj as class vsdsubs no-undo .
      vsdsubsObj = new vsdsubs ().
      for each buf_vsd where buf_vsd.obj-type eq inObjType
                         and buf_vsd.obj-code eq inObjCode
                         and can-do(inStatusList,string (buf_vsd.status_))
      no-lock by buf_vsd.fact-datetime :
          vsdsubsObj:AddItem(getDataStorage (BUFFER buf_vsd)).
      end.
      return vsdsubsObj.
  end method.
    method public class vsdsubs getVSDsubs ( buffer buf_vsd for ub.vsd ):
    define variable vsdsubsObj as class vsdsubs no-undo .
    vsdsubsObj = new vsdsubs ().
    vsdsubsObj:AddItem(getDataStorage (buffer buf_vsd)).
    return vsdsubsObj.
  end.
  method public class vsdsubs getVSDsubs ( objTHObj as class clisub, vsdStatusType as integer ):
    define variable vsdsubsObj as class vsdsubs no-undo .
    vsdsubsObj = new vsdsubs ().
    for each buf_vsd no-lock where buf_vsd.obj-code = objTHObj:ObjCode and buf_vsd.obj-type = objTHObj:ObjType
      and buf_vsd.status_ =  vsdStatusType:
      vsdsubsObj:AddItem(getDataStorage (buffer buf_vsd)).
    end.
    return vsdsubsObj.
  end method.
  method public class vsdsubs getVSDsubs (input objTHObj as class clisub ):
    define variable vsdsubsObj as class vsdsubs no-undo .
    vsdsubsObj = new vsdsubs ().
    for each buf_vsd no-lock where buf_vsd.obj-code = objTHObj:ObjCode and buf_vsd.obj-type = objTHObj:ObjType :
      vsdsubsObj:AddItem(getDataStorage (buffer buf_vsd)).
    end.
    return vsdsubsObj.
  end method.
    method public class vsdsubs getVSDsubs ( iId as integer , idb-num as integer ):
        define variable vsdsubsObj as class vsdsubs no-undo .
        vsdsubsObj = new vsdsubs ().
        for first buf_vsd no-lock where buf_vsd.id = iId and buf_vsd.db-num = idb-num:
          vsdsubsObj:AddItem(getDataStorage (buffer buf_vsd)).
        end.
        return vsdsubsObj.
    end.
    method public class vsdsub getVSDsub ( iId as integer , idb-num as integer ):
        define variable vsdsubObj as class vsdsub no-undo .
        for first buf_vsd no-lock where buf_vsd.id = iId and buf_vsd.db-num = idb-num:
           vsdsubObj = getDataStorage (buffer buf_vsd).
        end.
        return vsdsubObj.
    end method.
    method public handle getVSDQuery (input inObjType    as character,
                                            input  inObjCode    as int64 ,
                                            input inStatusList as character,
                                            input ibegdate as date,
                                            input ienddate as date  ):
      define variable vsdsubsObj as class vsdsubs no-undo .
      define variable vbegdate         as datetime-tz no-undo.
      define variable venddate         as datetime-tz no-undo.
      define variable vliststatusquery as character no-undo.
      define variable hQuery           as handle  no-undo .
      define variable vi               as integer no-undo.
      define variable vsdSts as class ibs.th.str.mercury.vsdstatustype no-undo.
      vsdSts     = new ibs.th.str.mercury.vsdstatustype ().
      vsdsubsObj = new vsdsubs ().
      assign
         vbegdate = datetime-tz (ibegdate)
         venddate = datetime-tz (ienddate + 1) - 1
      .
      define variable vHb as handle no-undo.
      define variable v-inform as character no-undo.
      define variable v-ind as integer no-undo.
      vHb = buffer buf_vsd:HANDLE.
      v-inform = vHb:INDEX-INFORMATION(1).
      do while v-inform <> ? and not v-inform begins "objstst,"
    on error undo, return error
    :
      assign
        v-ind    = v-ind + 1
        v-inform = vHb:index-information( v-ind )
      .
    end.
      create query hQuery.
      hQuery:set-buffers(buffer buf_vsd:HANDLE).
      define variable mstrquery as character no-undo.
      if v-inform begins "objstst,"
      then
      do:
         mstrquery = "FOR EACH buf_vsd where " .
         do vi = 1 to num-entries(inStatusList):
            if vi ne 1 then mstrquery = mstrquery + " or ".
            mstrquery = mstrquery  + " (                buf_vsd.obj-type eq " + QUOTER(inObjType) +
                                                  " and buf_vsd.obj-code eq " + QUOTER(string (inObjCode)) +
                                                  " and buf_vsd.status_ eq " + entry(vi,inStatusList) +
                                                  (  (
                                                    " and  buf_vsd.fact-datetime >= " + QUOTER(string (vbegdate)) +
                                                    " and buf_vsd.fact-datetime <= " + QUOTER(string (venddate)) + " "
                                                  ))
                                                  + ")".
         end.
      end.
      else do:
         mstrquery = "FOR EACH buf_vsd where                buf_vsd.obj-type eq " + QUOTER(inObjType) +
                                                      " and buf_vsd.obj-code eq " + QUOTER(string (inObjCode)) +
                                                      " and can-do(" + QUOTER(inStatusList) + ",string (buf_vsd.status_))" +
                                                      " and (( buf_vsd.fact-datetime >= " + QUOTER(string (vbegdate)) +
                                                      " and buf_vsd.fact-datetime <= " + QUOTER(string (venddate)) + ") "
                                                      + vliststatusquery + ")".
      end.
      hQuery:query-prepare(mstrquery).
      hQuery:query-open.
      hQuery:get-first().
      return hquery.
  end method.
    method public class vsdsubs getVSDsubsForVsdSub (input inVsdSub    as class vsdsub ):
        define variable vsdsubsObj as class vsdsubs no-undo .
        vsdsubsObj = new vsdsubs ().
        vsdsubsObj:AddItem(inVsdSub).
        return vsdsubsObj.
  end method.
  method private void setDataStorage (input invsdObj as class vsdsub, buffer inbf_vsd for ub.vsd ):
    inbf_vsd.UUID            = invsdObj:UUID.
    inbf_vsd.economic-sub    = invsdObj:EconomicSub.
    inbf_vsd.date-cr         = invsdObj:DateCr.
    inbf_vsd.date-out        = invsdObj:DateOut.
    inbf_vsd.type-prod       = invsdObj:TypeProd.
    inbf_vsd.expiry-date-2   = invsdObj:ExpiryDate2.
    inbf_vsd.qnty            = invsdObj:Qnty.
    inbf_vsd.expiry-out-date = invsdObj:ExpiryOutDate.
    inbf_vsd.num-part        = invsdObj:NumPart.
    inbf_vsd.note            = invsdObj:Note.
    inbf_vsd.msg-err         = invsdObj:MsgErr.
    inbf_vsd.vsd-num         = invsdObj:VsdNum.
    inbf_vsd.expiry-date     = invsdObj:ExpiryDate.
    inbf_vsd.vsd-type        = invsdObj:VSDType.
    inbf_vsd.part-key        = invsdObj:PartKey.
    inbf_vsd.status_         = invsdObj:Status_.
    inbf_vsd.gds-code        = invsdObj:GdsCode.
    inbf_vsd.fact-datetime   = invsdObj:FactDatetime.
    inbf_vsd.obj-type        = invsdObj:ObjType.
    inbf_vsd.obj-code        = invsdObj:ObjCode.
    inbf_vsd.cli-type        = invsdObj:CliType.
    inbf_vsd.cli-code        = invsdObj:CliCode.
    inbf_vsd.gds-guid        = invsdObj:GdsGuid.
    inbf_vsd.gds-name-merc   = invsdObj:GdsName.
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TransportType",invsdObj:TransportType).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"Transport",invsdObj:Transport).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"CarNum",invsdObj:CarNum).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"ContainerNum",invsdObj:ContainerNum).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TrailerNum",invsdObj:TrailerNum).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"OrigCountryGuid",invsdObj:OrigCountryGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"ProducerGuid",invsdObj:ProducerGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"ProducerRole",invsdObj:ProducerRole).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"ProductGuid",invsdObj:ProductGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"SubProductGuid",invsdObj:SubProductGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"UnitGuid",invsdObj:UnitGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"Perishable",invsdObj:Perishable).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"CLiBeGuid",invsdObj:CLiBeGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"CLiEntGuid",invsdObj:CLiEntGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TTNissueSeries",invsdObj:TTNissueSeries).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TTNissueNumber",invsdObj:TTNissueNumber).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TTNissueDate",invsdObj:TTNissueDate).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TTNtype",invsdObj:TTNtype).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"TTNrelationshipType",invsdObj:TTNrelationshipType).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"PurposeGuid",invsdObj:PurposeGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"CargoInspected",invsdObj:CargoInspected).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"CargoExpertized",invsdObj:CargoExpertized).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"LocationProsperity",invsdObj:LocationProsperity).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"BrokerGuid",invsdObj:BrokerGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"PackageLevel",invsdObj:PackageLevel).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"PackageGuid",invsdObj:PackageGuid).
    setAttr(inbf_vsd.ID,inbf_vsd.db-num,"PackageQnty",invsdObj:PackageQnty).
    release inbf_vsd.
  end.
  method private class vsdsub getDataStorage ( buffer inbf_vsd for ub.vsd ):
    define variable vsdsubObj  as class vsdsub  no-undo .
    vsdsubObj = new vsdsub ().
    assign
      vsdsubObj:ID            = inbf_vsd.id
      vsdsubObj:DBNum         = inbf_vsd.db-num
      vsdsubObj:UUID          = trim (inbf_vsd.UUID)
      vsdsubObj:EconomicSub   = inbf_vsd.economic-sub
      vsdsubObj:DateCr        = inbf_vsd.date-cr
      vsdsubObj:DateOut       = inbf_vsd.date-out
      vsdsubObj:TypeProd      = inbf_vsd.type-prod
      vsdsubObj:ExpiryDate2   = inbf_vsd.expiry-date-2
      vsdsubObj:Qnty          = inbf_vsd.qnty
      vsdsubObj:ExpiryOutDate = inbf_vsd.expiry-out-date
      vsdsubObj:NumPart       = inbf_vsd.num-part
      vsdsubObj:Note          = inbf_vsd.note
      vsdsubObj:MsgErr        = inbf_vsd.msg-err
      vsdsubObj:VsdNum        = inbf_vsd.vsd-num
      vsdsubObj:ExpiryDate    = inbf_vsd.expiry-date
      vsdsubObj:PartKey       = inbf_vsd.part-key
      vsdsubObj:Status_       = inbf_vsd.status_
      vsdsubObj:GdsCode       = inbf_vsd.gds-code
      vsdsubObj:FactDatetime  = inbf_vsd.fact-datetime
      vsdsubObj:ObjType       = inbf_vsd.obj-type
      vsdsubObj:ObjCode       = inbf_vsd.obj-code
      vsdsubObj:VSDType       = inbf_vsd.vsd-type
      vsdsubObj:CliType       = inbf_vsd.cli-type
      vsdsubObj:CliCode       = inbf_vsd.cli-code
      vsdsubObj:GdsGuid       = inbf_vsd.gds-guid
      vsdsubObj:GdsName       = inbf_vsd.gds-name-merc
      vsdsubObj:VsdRecid      = recid (inbf_vsd).
    .
    return vsdsubObj.
  end.
  method public character  GetAttr (iID as integer, idb-num as integer ,iattrcode as character ):
     define buffer buf_vsd-attr for ub.vsd-attr.
     find first buf_vsd-attr where buf_vsd-attr.ID        = iID
                               and buf_vsd-attr.db-num    = idb-num
                               and buf_vsd-attr.attr-code = iAttrCode
     no-lock no-error.
     return if not available buf_vsd-attr then "" else buf_vsd-attr.attr-value.
  end.
  method public void  setAttr (iID as integer, idb-num as integer ,iattrcode as character,iattrvalue as character  ):
    define buffer buf_vsd-attr for ub.vsd-attr.
    find first buf_vsd-attr exclusive-lock where buf_vsd-attr.ID        = iID
                                             and buf_vsd-attr.db-num    = idb-num
                                             and buf_vsd-attr.attr-code = iattrcode
                                             no-error .
    if not available buf_vsd-attr
    then do :
      if  iattrvalue > ""
      then do:
          create buf_vsd-attr.
          assign
            buf_vsd-attr.ID        = iID
            buf_vsd-attr.db-num    = idb-num
            buf_vsd-attr.attr-code = iattrcode
            buf_vsd-attr.attr-value = iattrvalue
          .
       end.
    end.
    else do:
      if  iattrvalue > ""
      then
         buf_vsd-attr.attr-value = iattrvalue.
      else
         delete buf_vsd-attr.
    end.
  end.
  method public logical exsistuuid (inVsdSubObj as class vsdsub):
    define variable trnDoc as character no-undo.
    define variable isExsistTRN as logical no-undo.
    return exsistuuid(inVsdSubObj, output isExsistTRN ).
  end.
  method public logical exsistuuidwithtrn (inVsdSubObj as class vsdsub):
    define variable trnDoc as character no-undo.
    define variable isExsistTRN as logical no-undo.
    if exsistuuid(inVsdSubObj, output isExsistTRN )
    then
      if isExsistTRN
        then return true.
    return false.
  end.
  method private logical exsistuuid (inVsdSubObj as class vsdsub, output isExsistTRN as log):
    define variable trnDoc as character no-undo.
    find first buf_vsd no-lock where recid (buf_vsd) <> inVsdSubObj:VsdRecid and buf_vsd.UUID = inVsdSubObj:UUID no-error.
    if available (buf_vsd)
    then do:
      trnDoc = entry (8,buf_vsd.part-key, chr(3)) no-error.
      if can-find (first ub.trn-doc no-lock where ub.trn-doc.doc-code = trnDoc)
        then isExsistTRN = true.
        else isExsistTRN = false.
      Msg = substitute ("ВСД UUID &1 уже заведен в системе. Документ - &2. Товар - &3.", buf_vsd.UUID, trnDoc, buf_vsd.gds-code ).
      inVsdSubObj:setStatusErr(true).
      inVsdSubObj:MsgErr = Msg.
      release buf_vsd.
      return true.
    end.
    return false.
  end.
  method public logical exsistvsd (buffer inbf_dl for ub.doc-line):
    define variable keyrecObj as class keyrec no-undo.
    define variable keyrec as character no-undo.
    define variable vOk       as logical no-undo.
    define buffer buf_parts for ub.parts.
    keyrecObj = new keyrec ().
    block-part:
    for each buf_parts no-lock where buf_parts.out-code = inbf_dl.doc-code
                                 and buf_parts.obj-type  = inbf_dl.obj-type
                                 and buf_parts.obj-code  = inbf_dl.obj-code
                                 and buf_parts.artic = inbf_dl.artic
                                 and buf_parts.prod-type = inbf_dl.prod-type
                                 and buf_parts.prod-code = inbf_dl.prod-code
    :
      if buf_parts.fact-qnty <= 0
      and inbf_dl.fact-qnty > 0
      then next block-part .
      keyrecObj:GenKeyRec('parts':U, buffer buf_parts:handle, output keyrec).
      vok = can-find (first buf_vsd where buf_vsd.part-key = keyrec and buf_vsd.UUID <> "" and buf_vsd.UUID <> ?) .
      if not vok then leave block-part.
    end.
    delete object keyrecObj.
    return vok.
  end.
  method public logical exsistvsd (buffer inbf_gd-dtl for ub.gds-dtl):
    define variable keyrecObj as class keyrec no-undo.
    define variable keyrec as character no-undo.
    define variable vOk       as logical no-undo.
    define buffer buf_parts for ub.parts.
    keyrecObj = new keyrec ().
    block-part:
    for each buf_parts no-lock where buf_parts.out-code = inbf_gd-dtl.doc-code
                                 and buf_parts.obj-type  = inbf_gd-dtl.obj-type
                                 and buf_parts.obj-code  = inbf_gd-dtl.obj-code
                                 and buf_parts.artic = inbf_gd-dtl.artic
                                 and buf_parts.prod-type = inbf_gd-dtl.prod-type
                                 and buf_parts.prod-code = inbf_gd-dtl.prod-code
    :
      if buf_parts.fact-qnty <= 0
      and inbf_gd-dtl.fact-qnty > 0
      then next block-part .
      keyrecObj:GenKeyRec('parts':U, buffer buf_parts:handle, output keyrec).
      vok = can-find ( first buf_vsd where buf_vsd.part-key = keyrec and buf_vsd.UUID <> "" and buf_vsd.UUID <> ?) .
      if not vok then leave block-part.
    end.
    delete object keyrecObj.
    return vok.
  end.
end class.
