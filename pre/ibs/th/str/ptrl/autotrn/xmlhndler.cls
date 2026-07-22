using progress.lang.*.
block-level on error undo, throw.
class ibs.th.str.ptrl.autotrn.xmlhndler :
  define public property WherePhrase as character no-undo
    get.
    protected set.
  define public property ErrMsg as character no-undo
    get.
    protected set.
  define public property ErrSys as character no-undo
    get.
    protected set.
  define public property ErrNum as integer no-undo init 0
    get.
    protected set.
  define public property ErrExcuteMethodName as character no-undo
    get.
    protected set.
  define public property LastExcuteMethodName as character no-undo
    get.
    protected set.
  define public property TrnDataDS as handle no-undo
    get.
    protected set.
  define public property vQR as handle no-undo
    get.
    protected set.
  define public property vbf as handle no-undo
    get.
    protected set.
  define variable lretok as logical no-undo.
  method public void FillDataset(input inXMLFile as char):
    LastExcuteMethodName = "FillDataset".
    define variable csourcetype             as character no-undo.
    define variable creadmode               as character no-undo.
    define variable loverridedefaultmapping as logical   no-undo.
    define variable cfile                   as character no-undo.
    define variable cschemalocation         as character no-undo.
    define variable cfieldtypemapping       as character no-undo.
    define variable cverifyschemamode       as character no-undo.
    delete object TrnDataDS no-error.
    delete object vQR no-error.
    delete object vbf no-error.
    file-info:file-name = search(inXMLFile) .
    if file-info:file-size = 0
    then do :
      ErrMsg = SetErrMsg(LastExcuteMethodName, "Ïףסעמי פאיכ xml", 1).
      undo, return error.
    end .
    assign
      csourcetype             = "file"
      cfile                   =  search (inXMLFile)
      creadmode               = "empty"
      //cschemalocation         = "qr.xsd"
      loverridedefaultmapping = ?
      cfieldtypemapping       = ?
      cverifyschemamode       = ?.
    create dataset TrnDataDS.
    lretok = TrnDataDS:read-xml(csourcetype, cfile, creadmode, cschemalocation,
      loverridedefaultmapping, cfieldtypemapping, cverifyschemamode) no-error.
    if not lretok or error-status:error
    then do:
      ErrMsg = SetErrMsg(LastExcuteMethodName, error-status:get-message (1), 2).
      undo, return error.
    end.
    create query vQR.
    return.
  end method.
  method public logical GetFirst( inTableName as char):
    lretok = GetFirst(inTableName, "") no-error.
    if error-status:error
      then undo, return error.
    return lretok.
  end.
  method public logical GetFirst ( inTableName as char, inWherePhrase as char):
    LastExcuteMethodName = "GetFirstRow".
    WherePhrase = inWherePhrase.
    vbf = TrnDataDS:get-buffer-handle(inTableName).
    lretok = vQR:set-buffers(vbf) no-error.
    if not lretok
    then do:
      ErrMsg = SetErrMsg(LastExcuteMethodName, error-status:get-message (1), 1).
      undo, return error.
    end.
    lretok = vQR:query-prepare("for each " + inTableName + " " + WherePhrase) no-error.
    if not lretok
    then do:
      ErrMsg = SetErrMsg(LastExcuteMethodName, error-status:get-message (1), 2).
      undo, return error.
    end.
    lretok = vQR:query-open( ) no-error.
    if not lretok
    then do:
      ErrMsg = SetErrMsg(LastExcuteMethodName, error-status:get-message (1), 3).
      undo, return error.
    end.
    lretok = vQR:get-first( ) no-error.
    return lretok.
  end method.
  method public logical GetNext():
    LastExcuteMethodName = "GetNext".
    lretok = vQR:get-next( ) no-error.
    if not lretok
    then do:
      return false.
    end.
    return true.
  end method.
  method public void SetWherePhrase( inWhereFrase as char ):
    WherePhrase = inWhereFrase.
    return.
  end method.
  method protected char SetErrMsg (inMethodName as char, inErrSys as char, inErrNum as int ):
      return SetErrMsg (inMethodName, "", inErrSys, inErrNum).
  end method.
  method protected char SetErrMsg (inMethodName as char, inErrMsg as char, inErrSys as char, inErrNum as int ):
    ErrNum =  inErrNum.
    ErrSys = if inErrSys <> ? and inErrSys <> "" then inErrSys else "".
    return substitute ("Class Name: &1. Method Name: &2. Error Code: &3. &4 &5", "xmlhndler", LastExcuteMethodName, string(inErrNum), inErrMsg, inErrSys).
  end method.
end class.
