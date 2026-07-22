using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.gbl.keyrec inherits ibs.th.gbl.sys.objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Бибилиотека для работы с Key-Rec" get.
  define property ReturnMsg as character no-undo
    get.
    private set.
  define property Err as logical no-undo
    get.
    private set.
  define property g#news as logical no-undo
    get.
    private set.
  define variable hndl-proc-key-rec as handle.
  constructor public keyrec ():
    run gbl\key-rec.p persistent (output hndl-proc-key-rec) no-error.
    if error-status:error
    then
       message error-status:get-message(1) view-as alert-box.
  end constructor.
  method public void GenKeyRec (
    input  p-tbl-name    as character,
    input  p-bh_tbl-name as handle,
    output p-key-rec     as character ):
    run gen-key-rec in hndl-proc-key-rec ( input p-tbl-name
                                          ,input p-bh_tbl-name
                                          ,output p-key-rec) no-error.
    if error-status:error
    then do:
      ReturnMsg = return-value.
      Err = true.
    end.
  end.
  method public void GenRowKeyr (
    input p-key-rec    as character,
    input p-key-handle as handle   ,
    input p-db-name    as character,
    input p-tt-handle  as handle   ,
    input p-stts-lock  as integer  ,
    output p-tbl-row   as rowid    ,
    output p-tbl-name  as character
  ):
    run gen-row-keyr in hndl-proc-key-rec (  input p-key-rec
                                            ,input p-key-handle
                                            ,input p-db-name
                                            ,input p-tt-handle
                                            ,input p-stts-lock
                                            ,output p-tbl-row
                                            ,output p-tbl-name) no-error.
    if error-status:error
    then do:
      ReturnMsg = return-value.
      Err = true.
    end.
  end.
  method public void GenKeyFv (
    input p-key-rec     as character,
    output p-field-list as character,
    output p-value-list as character
  ):
    run gen-key-fv in hndl-proc-key-rec ( input p-key-rec
                                         ,output p-field-list
                                         ,output p-field-list) no-error.
    if error-status:error
    then do:
      ReturnMsg = return-value.
      Err = true.
    end.
  end.
   method public void GenHnKeyrTab
   (input  i-tableSerach as character,
    input  i-tablekey    as character,
    input  p-key-rec     as character,
    input  p-key-handle  as handle,
    input  p-db-name    as character,
    input  p-tt-handle  as handle,
    input  p-stts-lock  as integer,
    output o-hn         as handle )
    :
       run gen-hn-keyr-tab in hndl-proc-key-rec (
               input  i-tableSerach,
               input  i-tablekey ,
               input  p-key-rec,
               input  p-key-handle ,
               input  p-db-name  ,
               input  p-tt-handle,
               input  p-stts-lock ,
               output o-hn   ).
   end method.
   method public void GenWhereKeyrTab
   (input  i-tableSerach as character,
    input  i-tablekey    as character,
    input  p-key-rec     as character,
    input  p-key-handle  as handle,
    input  p-db-name    as character,
    input  p-tt-handle  as handle,
    output o-where      as character  )
    :
       run gen-Where-keyr-tab in hndl-proc-key-rec (
               input  i-tableSerach,
               input  i-tablekey ,
               input  p-key-rec,
               input  p-key-handle ,
               input  p-db-name  ,
               input  p-tt-handle,
               output o-where   ).
   end method.
  destructor public keyrec ():
    delete object hndl-proc-key-rec no-error.
    if error-status:error
    then do:
      ReturnMsg = return-value.
      Err = true.
    end.
  end destructor.
end class.
