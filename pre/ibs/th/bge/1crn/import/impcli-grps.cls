using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impcli-grps implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp       as class cli-grps no-undo.
    define variable v-mode       as character no-undo.
    define variable v-doc-rec    as recid no-undo.
    define variable v-node-code  as integer no-undo .
    define variable v-upper-code as integer no-undo .
    define variable v-retfl      as logical no-undo .
    define buffer buf_cli-grp for ub.cli-grp .
    objImp = cast (subjectObj, cli-grps).
    assign
      v-node-code  = integer(objImp:code_)
      v-upper-code = integer(objImp:upper-code)
      Msg = ""
    .
    if objImp:del-f > 0 then do:
      run ref/cligrp03.p ( input v-node-code ) .
      v-retfl = true .
    end .
    else if objImp:del-l > 0 then do:
      run ref/cligrp01.p
      (input 'ИЗМЕНЕНИЕ':U
      ,input true
      ,input true
      ,input-output v-node-code
      ,input-output v-upper-code
      ,input "УДАЛЕНО " + objImp:name_
      ,output v-doc-rec
      ) .
      v-retfl = true .
    end.
    else do:
      assign
         v-mode   = if can-find (first buf_cli-grp where buf_cli-grp.node-code = v-node-code) then 'ИЗМЕНЕНИЕ':U else 'ДОБАВЛЕНИЕ':U
      .
      run ref/cligrp01.p
      (input v-mode
      ,input true
      ,input true
      ,input-output v-node-code
      ,input-output v-upper-code
      ,input objImp:name_
      ,output v-doc-rec
      ) .
      v-retfl = true .
    end .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        Msg = exAppErrors:GetMessage(1) .
        if Msg > "" then . else Msg = "AppError в группах клиентов" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      if Msg > "" then . else Msg = "ProError в группах клиентов" .
      v-retfl = false .
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в группах клиентов" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method.
end class.
