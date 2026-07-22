block-level on error undo, throw.
define input  parameter parparentproc as handle  no-undo.
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable mDisableNwsFortable as character no-undo.
procedure DisableNws:
   define input  parameter iTable  as character no-undo.
   define output parameter oNotNWS as logical no-undo.
   if      mDisableNwsFortable ne ?
       and can-do(mDisableNwsFortable,iTable)
   then
      oNotNWS = yes.
end.
procedure SetNwsTable:
   define input  parameter iTable  as character no-undo.
   mDisableNwsFortable = iTable.
end.
procedure RunProcAny:
   define input  parameter iProc  as character no-undo.
   define input  parameter iParam as character no-undo.
   define output parameter oOk    as logical   no-undo.
   run value(iproc) (parparentproc, iparam, output oOk) no-error.
   if error-status:error
   then
      return substitute ("&1 &2", return-value, error-status:get-message(1)).
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define buffer buf_db for ub.db.
find first buf_db no-lock where buf_db.db-num = v-cntxt-db-num no-error.
define variable updschmObj      as class ibs.th.adm.upd.CheckUpd no-undo.
updschmObj = new ibs.th.adm.upd.CheckUpd (no).
updschmObj:updChceck().
if     buf_db.reserve1-char begins "updto:"
    or updschmObj:CurrDBShm ne int(buf_db.reserve1-char)
then do trans:
   find first buf_db exclusive-lock where buf_db.db-num = v-cntxt-db-num no-error.
   buf_db.reserve1-char = string(updschmObj:CurrDBShm).
end.
delete object updschmObj no-error.
define variable mfile as character no-undo.
define variable mfilemd5 as character no-undo.
define variable v-md5-signature  as character no-undo.
define variable vimport as class ibs.th.bge.xmlimpexp no-undo.
define variable mTxt as character no-undo.
define variable mfilever as char no-undo init ?.
define variable m-type as character no-undo.
define variable mdbver as integer no-undo.
define variable mdbver_old as integer no-undo.
define variable f_load as logical no-undo init no.
define variable mRunTransaction as logical no-undo.
define stream md5in.
run db-attr-value in this-procedure
           (input ibs.th.gbl.gbl-var:g#db-num
           ,input 'ver-met':U
           ,output mTxt
           ,output m-type
           ) no-error .
mdbver_old = int(mtxt) no-error.
if mdbver_old eq ?
then
   mdbver_old = 0.
subscribe "RunProcXmlImp" anywhere run-procedure "RunProcAny".
subscribe "NotSendNwsForTable" anywhere run-procedure "DisableNws".
subscribe "DisableNwsTable" anywhere run-procedure "SetNwsTable".
vimport= new ibs.th.bge.xmlimpexp().
block-upd:
do mdbver = mdbver_old + 1 to 999999999:
   mfile    = search(substitute("upd/&1.xml",string(mdbver,"999999999"))).
   mfilemd5 = search(substitute("upd/&1.md5",string(mdbver,"999999999"))).
   if    mfile    eq ?
      or mfilemd5 eq ?
   then
      leave block-upd.
   input  stream md5in from value (mfilemd5).
   import stream md5in mtxt no-error.
   input  stream md5in close.
   run gbl/md5.p (
          input  mfile
         ,output v-md5-signature
         ) .
   if mtxt eq encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
   then do:
      vimport:xmldom-load-ver  ( mfile,? ) no-error.
      mRunTransaction = vimport:mTransaction.
      if error-status:error
      then
         return error return-value.
      if mRunTransaction then
      do:
        UPD_TBL:
        do transaction on error undo UPD_TBL, leave UPD_TBL:
          vimport:updatetablefordb(this-procedure) no-error.
          if error-status:error
            then return error return-value.
        end.
      end.
      else do:
         vimport:updatetablefordb(this-procedure) no-error.
         if error-status:error
           then return error return-value.
      end.
       CODE_UPD:
       do transaction on error undo CODE_UPD, leave CODE_UPD:
       create code  no-error.
         assign
         code.parent    = substitute("XML_UPD&1 &2",chr(4),string(ibs.th.gbl.gbl-var:g#db-num))
         code.code      = string(now)
         code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
         code.misc1     = v-md5-signature
         code.misc2     = string(mdbver)
         code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
         code.nwsgbd    = yes.
         code.nwsubd    = yes.
         .
       f_load = yes.
       end.
      return-value = "".
      vimport:xmldom-clear().
   end.
   else
      return error substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
end.
mdbver = mdbver - 1.
if mdbver gt mdbver_old
then
   run db-attr-write in this-procedure ( input ibs.th.gbl.gbl-var:g#db-num
                                       , input 'ver-met':U
                                       , input string (mdbver)
                                       )  .
mfile    = search("upd/code.xml").
mfilemd5 = search("upd/code.md5").
if mfile ne ? and mfilemd5 ne ?
then do:
   input  stream md5in from value (mfilemd5).
   import stream md5in mtxt no-error.
   input  stream md5in close.
   run gbl/md5.p (
          input  mfile
         ,output v-md5-signature
         ) .
   if mtxt ne encode(v-md5-signature + "sysadm" ) + string(index(encode(string(v-md5-signature)), "k"))
   then
      return error substitute("Файл &1 имеет не правильную сигнатуру md5.", mfile).
   mfilever = vimport:xmldom-load-ver  ( mfile,? ) no-error.
   if error-status:error
   then
      return error return-value.
   IMP_CODE:
   do transaction on error undo IMP_CODE, leave IMP_CODE:
       vimport:updatetablefordb(this-procedure) no-error.
       if error-status:error
       then
          return error return-value + " " + error-status:get-message(1).
       else
          run db-attr-write in this-procedure ( input ibs.th.gbl.gbl-var:g#db-num
                                              , input 'ver-code':U
                                              , input mfilever
                                              ) no-error .
   end.
   CODE_UPD2:
   do transaction on error undo CODE_UPD2, leave CODE_UPD2:
   find last code no-lock where code.CodeValue = "code.xml" no-error.
   if available code and code.misc1 <> v-md5-signature
         then do:
         create code no-error.
            assign
            code.parent    = substitute("XML_UPD&1 &2",chr(4),string(ibs.th.gbl.gbl-var:g#db-num))
            code.code      = string(now)
            code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
            code.misc1     = v-md5-signature
            code.misc2     = string(mdbver)
            code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
            code.nwsgbd    = yes.
            code.nwsubd    = yes.
            .
   f_load = yes.
   end.
   if not available code
         then do:
         create code  no-error.
            assign
            code.parent    = substitute("XML_UPD&1 &2",chr(4),string(ibs.th.gbl.gbl-var:g#db-num))
            code.code      = string(now)
            code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
            code.misc1     = v-md5-signature
            code.misc2     = string(mdbver)
            code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
            code.nwsgbd    = yes.
            code.nwsubd    = yes.
            .
   f_load = yes.
   end.
   end.
   return-value = "".
   vimport:xmldom-clear().
end.
if f_load = no
        then do:
   CODE_UPD3:
   do transaction on error undo CODE_UPD3, leave CODE_UPD3:
        find last code no-lock where code.parent BEGINS "XML_UPD" no-error.
        mfile    = search(substitute("upd/&1.xml", string(mdbver_old, "999999999"))).
        mfilemd5 = search(substitute("upd/&1.md5", string(mdbver_old, "999999999"))).
        if mfile ne ? and mfilemd5 ne ? then do:
                input stream md5in from value(mfilemd5).
                import stream md5in mTxt no-error.
                input stream md5in close.
                run gbl/md5.p (input  mfile, output v-md5-signature) no-error.
                if available code and code.misc1 ne v-md5-signature then do:
                        create code no-error.
                        assign
                        code.parent    = substitute("XML_UPD&1 &2",chr(4),string(ibs.th.gbl.gbl-var:g#db-num))
                        code.code      = string(now)
                        code.CodeValue = entry(num-entries(mfile, "\") , mfile, "\")
                        code.misc1     = v-md5-signature
                        code.misc2     = string(mdbver)
                        code.misc3     = string(ibs.th.gbl.gbl-var:g#db-num)
                        code.nwsgbd    = yes.
                        code.nwsubd    = yes.
                        .
                end.
        end.
   end.
end.
define variable v-err-msg as character no-undo .
catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
       v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > ""
      then v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\code-upd.p" + v-err-msg.
      else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\code-upd.p" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) .
    if v-err-msg > ""
    then v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\code-upd.p" + v-err-msg.
    else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\code-upd.p" .
    return error v-err-msg.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\gbl\code-upd.p " + exAnyErrors:GetMessage(1).
    return error v-err-msg.
  end catch .
finally:
   if valid-object(vimport)
   then
      delete object vimport.
unsubscribe "NotSendNwsForTable".
unsubscribe "DisableNwsTable".
unsubscribe "RunProcXmlImp".
end finally.
