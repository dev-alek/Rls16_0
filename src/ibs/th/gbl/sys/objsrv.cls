/*
  $Revision:$
  $Author:$
  $Date:$
  $Workfile:$
  $Archive:$
  
  Автор: Рубан Дмитрий Андреевич 
  Дата создания: 9 янв. 2023 г.
  Author:  Ruban Dmitriy Andreevich
  Creation date: 9 янв. 2023 г.
  
  */

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
  &glob GlobObjSrvClass yes
    { utl/objregtt.i }

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
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/


  constructor public objsrv (  ):
    super ().
    SysLog = new logger (out). 
    SysLog:EventHndlr("Родился objsrv").
  end constructor.
  

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void Initialization(  ):
    session:error-stack-trace = session:debug-alert.
    {utl\objreg.i SystemAux SystemAux}
    {utl\objreg.i SysINI ini}
    {utl\objreg.i out putout "SysINI:SystemLogFileName:Value_" }
    {utl\objreg.i Env env }
    {utl\objreg.i Lib lib}.
    define variable vtext as character no-undo.
    vtext = {utlcomp/keypub.i}.
    {utl\objreg.i SystemSetting systemsetting vtext}.
    
    return.
    define variable v-err-msg as character no-undo .  
/*  catch exAppErrors as class Progress.Lang.AppError :                                  */
/*    v-err-msg = exAppErrors:ReturnValue .                                              */
/*    if v-err-msg > "" then . else do :                                                 */
/*      v-err-msg = exAppErrors:GetMessage(1) .                                          */
/*      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .     */
/*    end .                                                                              */
/*    message v-err-msg  view-as alert-box.                                              */
/*  end catch .                                                                          */
/*  catch exProErrors as class Progress.Lang.ProError :                                  */
/*    v-err-msg = exProErrors:GetMessage(1) .                                            */
/*    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .       */
/*    message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box. */
/*  end catch .                                                                          */
/*  catch exAnyErrors as class Progress.Lang.Error:                                      */
/*    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1). */
/*    message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.*/
/*  end catch .                                                                          */
/*                                                                                       */
  end method.

  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
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
          iobj:RefrashObject(). /* если клас создается через utl\objreg.i то вызовен метот обновления после отработки конструктора, При содание записи регистрация произошло в objth и контекст не был еще установлен в конструкторе*/
       tt-objth.propname  = propname.
       objparent = if valid-object(iobjparen) then iobjparen:ToString() else this-object:ToString().
       tt-objth.procparent = iparantProc.
       SysLog:EventHndlr("Зарегистрирован - " + IdObj).
    end.

    return.

  end method.
 
  method public void Regobj(iobjparen as objth, iobj as objth, propname as char ): /* Регистрируем объект наследник objth или TypeMap в оъекте objth*/
     Regobj(program-name(3),iobjparen, iobj, propname ).
  end.
   
  method public void Regobj(iobjparen as objth, iobj as objth ):
     Regobj(program-name(3),iobjparen, iobj, "" ).
     
  end.
  
  method public void Regobj( iobj as objth, propname as char ): /* Регистрируем в ObjSrv */
     Regobj(program-name(2),?,iobj,propname).
  end method.
    
  method public void Regobj( iobj as objth ): /* Регистрируем объект наследник objth */
     Regobj(program-name(4),?,iobj,"").
  end method.
    
  method public void Delobj( obj as Progress.Lang.Object ):
    
    /*    find first tt-objth exclusive-lock where tt-objth.objhndl = integer(obj).*/
    /*    delete tt-objth.                                                         */
    /*    message "Разрегистрация" view-as alert-box.*/
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
    /*    find first tt-objth exclusive-lock where tt-objth.objhndl = integer(obj).*/
    /*    delete tt-objth.                                                         */
    /*    message "Разрегистрация" view-as alert-box.*/
    find first tt-objth where tt-objth.objparent = iParent no-error.
    do while  available  tt-objth:
       DelobjChild(tt-objth.objname).
       delete object tt-objth.objhndl no-error.
       if avail tt-objth then delete tt-objth. /* если не УДАЛИМ В В DELOBJ */
       find first tt-objth where tt-objth.objparent = iParent no-error.
    
    end.    
    return.

  end method.
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void view_(  ):
    for each tt-objth:
    /*      message valid-object (tt-objth.objhndl) tt-objth.objhndl view-as alert-box.*/
    end.
    return.

  end method.
  
  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/

  /*  method public void GetBufTTCol(input-output buffer bf_tt-objth for tt-objth ):*/
  /*    for each tt-objth:                                                               */
  /*/*      message valid-object (tt-objth.objhndl) tt-objth.objhndl view-as alert-box.*/*/
  /*    end.                                                                             */
  /*    return.                                                                          */

  /*  end method.*/

   /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  destructor public objsrv ( ):
    def var hndl as handle no-undo.
    /*    for each tt-objth:                        */
    /*      delete object handle (tt-objth.objhndl).*/
    /*    end.                                      */
    SysLog:EventHndlr("Умирает objsrv").
    delobj(this-object).
    
    /* удалим все ссылки на объекты, а то при отключении от базы будет беда */
    for each tt-objth where tt-objth.objname ne SysLog:ToString() :
       SysLog:EventHndlr("Забыли удалить " + tt-objth.objname) .
/*       message "Забыли удалить " + tt-objth.objname       view-as alert-box.*/
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
