using Progress.Lang.*.
using ibs.th.gbl.sys.objsrv.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.env.
using ibs.th.gbl.logger.
using ibs.th.gbl.logger.putout.
using ibs.th.gbl.sys.env.ini.
using ibs.th.gbl.lib.
using ibs.th.gbl.systemsetting.
using ibs.th.gbl.sys.SystemAux.
block-level on error undo, throw.
class ibs.th.gbl.sys.objsrv:
      define temp-table tt-objth no-undo
    field iNum       as integer
    field objhndl    as class Progress.Lang.Object
    field propname   as character
    field label_     as character
    field objname    as character
    field objparent  as character
    field procparent as character
index pparent objparent propname
index objname objname
.
  define public property upd as integer no-undo
    get.
    private set.
  define public property Env as class env no-undo
    get.
    private set.
  define public property Lib as class lib no-undo
    get.
    private set.
  define public property SystemSetting as class systemsetting no-undo
    get.
    private set.
  define public property SysLog as class logger no-undo
    get.
    private set.
  define private variable out as class putout no-undo.
  define property SysINI as class ini no-undo
    get.
    private set.
  define property SystemAux as class systemaux no-undo
    get.
    private set.
  constructor public objsrv (  ):
    super ().
    SysLog = new logger (out).
    SysLog:EventHndlr("Родился objsrv").
  end constructor.
  method public void Initialization(  ):
    session:error-stack-trace = session:debug-alert.
SystemAux = new SystemAux ().
    Regobj(SystemAux,
"SystemAux"
).
SysINI = new ini ().
    Regobj(SysINI,
"SysINI"
).
out = new putout (SysINI:SystemLogFileName:Value_).
    Regobj(out,
"out"
).
Env = new env ().
    Regobj(Env,
"Env"
).
Lib = new lib ().
    Regobj(Lib,
"Lib"
).
 .
    define variable vtext as character no-undo.
    vtext = "blgiNoabkbkcWiii"
 .
SystemSetting = new systemsetting (vtext).
    Regobj(SystemSetting,
"SystemSetting"
).
 .
    return.
    define variable v-err-msg as character no-undo .
  end method.
  define variable count as integer no-undo.
  method private void Regobj(iparantProc as character, iobjparen as objth, iobj as objth, propname as char ):
    define variable IdObj as character  no-undo.
    if valid-object (iobj)
    then do:
       IdObj = iobj:ToString().
       find first tt-objth where tt-objth.objname eq IdObj no-error.
       if not available tt-objth
       then do:
          count = count + 1.
          create tt-objth.
          assign
             tt-objth.inum      = count
             tt-objth.objname   = IdObj
             tt-objth.objhndl   = iobj
          .
       end.
       else
          iobj:RefrashObject().
       tt-objth.propname  = propname.
       objparent = if valid-object(iobjparen) then iobjparen:ToString() else this-object:ToString().
       tt-objth.procparent = iparantProc.
       SysLog:EventHndlr("Зарегистрирован - " + IdObj).
    end.
    return.
  end method.
  method public void Regobj(iobjparen as objth, iobj as objth, propname as char ):
     Regobj(program-name(3),iobjparen, iobj, propname ).
  end.
  method public void Regobj(iobjparen as objth, iobj as objth ):
     Regobj(program-name(3),iobjparen, iobj, "" ).
  end.
  method public void Regobj( iobj as objth, propname as char ):
     Regobj(program-name(2),?,iobj,propname).
  end method.
  method public void Regobj( iobj as objth ):
     Regobj(program-name(4),?,iobj,"").
  end method.
  method public void Delobj( obj as Progress.Lang.Object ):
    if not valid-object (obj)
      then do:
        SysLog:EventHndlr("Че то объекта нет").
        return.
      end.
    DelobjChild(obj:ToString()).
    find first tt-objth where tt-objth.objname = obj:ToString() no-error.
    if not available (tt-objth)
    then do:
      SysLog:EventHndlr("Че то не то - " + obj:ToString()).
    end.
    else do:
       SysLog:EventHndlr("Разрегистрирован - " + obj:ToString()).
       delete tt-objth.
    end.
    return.
  end method.
  method public void DelobjChild( iParent as character  ):
    define buffer tt-objth for tt-objth.
    find first tt-objth where tt-objth.objparent = iParent no-error.
    do while  available  tt-objth:
       DelobjChild(tt-objth.objname).
       delete object tt-objth.objhndl no-error.
       if avail tt-objth then delete tt-objth.
       find first tt-objth where tt-objth.objparent = iParent no-error.
    end.
    return.
  end method.
  method public void view_(  ):
    for each tt-objth:
    end.
    return.
  end method.
  destructor public objsrv ( ):
    def var hndl as handle no-undo.
    SysLog:EventHndlr("Умирает objsrv").
    delobj(this-object).
    for each tt-objth where tt-objth.objname ne SysLog:ToString() :
       SysLog:EventHndlr("Забыли удалить " + tt-objth.objname) .
       delete tt-objth.
    end.
    delete object SysLog no-error.
  end destructor.
  method public logical RefrashObject(iUpd as integer ):
     upd = iUpd.
     for each tt-objth:
        cast (tt-objth.objhndl, objth):RefrashObject().
     end.
  end method.
  method public void GetTableObjTh(output table for tt-objth):
    for each tt-objth:
       tt-objth.label_ = cast (tt-objth.objhndl, objth):getLable().
    end.
  end method.
end class.
