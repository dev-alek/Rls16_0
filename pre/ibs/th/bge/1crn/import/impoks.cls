using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.oks.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impoks inherits ibs.th.gbl.sys.objth implements ibs.th.bge.1crn.import.iimpsubject :
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Импорт okei-kkt" get.
  define property Msg as character no-undo
    get.
    set.
   method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
      define variable objImp as class ibs.th.bge.1crn.subjects.oks no-undo.
      define buffer code for code.
      define variable v-retfl as logical no-undo.
      objImp = cast (subjectObj, oks).
      find first Code where Code.parent eq "okei-kkt"
                        and Code.code   eq objImp:Code_ok
      exclusive-lock no-error.
      if available code
      then do:
         if objImp:del-f > 0
         then do:
            delete code.
         end.
         else do:
            assign
               code.CodeName  = objImp:Code_ei_kkt
               code.misc1     = objImp:Code_pf_kkt
               Code.CodeValue = objImp:notation
               code.status_   = if objImp:del-l > 0
                                then 1
                                else 0
            .
         end.
      end.
      else do:
         if objImp:del-f > 0
         then do:
         end.
         else if objImp:del-l > 0
         then
            undo, throw new Progress.Lang.AppError(substitute("Нельзя пометить запись &1 в собщение &2 так как ее нет в системе.",objImp:Code_ok, objImp:InitTag)) .
         else do:
            create code.
            assign
               Code.parent = "okei-kkt"
               Code.code   = objImp:Code_ok
               code.CodeName  = objImp:Code_ei_kkt
               code.misc1     = objImp:Code_pf_kkt
               Code.CodeValue = objImp:notation
               code.status_  = if objImp:del-l > 0
                               then 1
                               else 0
            .
         end.
      end.
      v-retfl = true .
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + chr(10) + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = substitute ("AppError в &1",objImp:InitTag) .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + chr(10) + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . else Msg = substitute ("ProError в &1",objImp:InitTag) .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = substitute ("Unexpected error в &1",objImp:InitTag) .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method.
end class.
