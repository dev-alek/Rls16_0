using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.xproc.xgroupobj_trg:
   constructor public xgroupobj_trg (  ):
      super ().
   end constructor.
   destructor public xgroupobj_trg ( ):
   end destructor.
   define temp-table tt-query no-undo
      field NameQuery as character
      field hQuery    as handle
   index NameQuery NameQuery.
   define temp-table tt-groupobj no-undo like xgroupobj
      field Frecid  as recid
      field fchange as logical
   .
  define variable Parent as character no-undo.
  define variable BegParent as character no-undo init ?.
   method public handle getQuery (input iNameQuery as character ) :
      return   getQuery(iNameQuery,no).
   end.
   method public handle getQuery (input iNameQuery as character,input iNewQuery as logical ) :
      define variable hQuery   as handle  no-undo .
      define variable vfirst   as logical no-undo .
      define variable vOpen    as logical no-undo init yes.
      define variable vTblName as character no-undo .
      define variable vOpenStr as character no-undo .
      define variable vSchedId as integer no-undo .
      find first tt-Query where tt-Query.NameQuery eq iNameQuery
      no-error.
      if     available tt-Query
         and iNewQuery
      then do:
         delete object tt-Query.hQuery.
         delete tt-Query.
      end.
      if not available tt-Query
      then
      do:
          create query hQuery.
      end.
      else
         hQuery = tt-Query.hQuery.
      case iNameQuery:
         when "tt-groupobj"
         then do:
            for each tt-groupobj:
               delete tt-groupobj.
            end.
            for each xgroupobj where xgroupobj.Parent-GroupObj eq  Parent
            no-lock:
               create tt-groupobj.
               buffer-copy xgroupobj to tt-groupobj
               assign
                  tt-groupobj.Frecid = recid (xgroupobj)
               .
            end.
            hQuery:set-buffers(buffer tt-groupobj:HANDLE).
            hQuery:query-prepare("FOR EACH tt-groupobj ").
         end.
         when "xgroupobj"
         then do:
            hQuery:set-buffers(buffer xgroupobj:HANDLE).
            hQuery:query-prepare("FOR EACH xgroupobj where xgroupobj.Parent-GroupObj eq " + QUOTER(parent) +
            " no-lock").
         end.
      end case.
      if vOpen
      then do:
         hQuery:query-open.
         if vFirst
         then
            hQuery:get-first () no-error .
      end.
      if not available tt-Query
      then do:
         create tt-Query.
         assign
            tt-Query.NameQuery = iNameQuery
            tt-Query.hQuery    = hQuery
         .
      end.
      return hQuery.
   end.
   method public void addgroupobj ( ):
      define buffer xGroupObj for xGroupObj.
      create tt-GroupObj.
      tt-GroupObj.Parent-GroupObj = parent.
      frmGroupObj('ДОБАВЛЕНИЕ':U , buffer tt-GroupObj:handle).
      finally:
         delete tt-GroupObj.
      end finally.
   end method.
   method public void editgroupobj ( ):
      if available xGroupObj
      then do:
         buffer-copy xGroupObj to tt-GroupObj.
         tt-GroupObj.Frecid  = recid(xGroupObj).
         frmGroupObj('ИЗМЕНЕНИЕ':U,buffer tt-GroupObj:handle).
      end.
      finally:
         if available tt-GroupObj
         then
            delete tt-GroupObj.
      end finally.
   end method.
   method public logical delgroupobj ( ):
      if available xGroupObj
      then do:
         find current xGroupObj exclusive-lock.
         if available xGroupObj
         then do:
            delete xGroupObj no-error.
            if error-status:error
            then do:
               message return-value
               view-as alert-box.
               return no.
            end.
         end.
      end.
      return yes.
   end.
   method public void lookgroupobj ( ):
      if available  xGroupObj
      then
         frmGroupObj('ПРОСМОТР':U , buffer xGroupObj:handle).
   end method.
   method public void frmGroupObj (Imode as character ,ibuffertt as handle ):
      define variable VSave as logical no-undo.
      define variable v-frmEdit as class ibs.th.ref.xproc.xgroupobjFrm no-undo.
      if Imode eq 'ПРОСМОТР':U
      then
         v-frmEdit = new ibs.th.ref.xproc.xgroupobjfrm().
      else
         v-frmEdit = new ibs.th.ref.xproc.xgroupobjfrm(this-object).
      v-frmEdit:ShowModalDialog(ibuffertt) .
      VSave = v-frmEdit:DialogResult eq System.Windows.Forms.DialogResult:ok.
      delete object v-frmEdit.
      if VSave
      then do trans:
          if Imode eq 'ДОБАВЛЕНИЕ':U
          then
             create xGroupObj.
          else
             find current xGroupObj exclusive-lock.
          buffer-copy tt-GroupObj to xGroupObj.
      end.
   end method.
   method public void NextLevel():
      if BegParent eq ?
      then
         BegParent = parent.
      if available xgroupobj
      then
         parent = xGroupObj.GroupObj-Code.
      else if available tt-groupobj
      then
         parent = tt-GroupObj.GroupObj-Code.
      return.
   end method.
   method public logical CheckRec():
      define buffer xgroupobj for xgroupobj.
      find first xgroupobj where xGroupObj.GroupObj-Code eq tt-groupobj.GroupObj-Code
                             and recid(xGroupObj) ne tt-groupobj.Frecid
         no-lock no-error.
      if available xgroupobj
      then do:
         message "Уже есть запись с кодом " tt-groupobj.GroupObj-Code
         view-as alert-box.
         return no.
      end.
      else
         return yes.
   end.
   method public logical validNextLevel():
      return (available xGroupObj and xGroupObj.Hierarchy) or (available tt-GroupObj and tt-GroupObj.Hierarchy).
   end.
   method public logical PrevLevel():
      define buffer xGroupObj for xGroupObj.
      if BegParent eq ? or BegParent eq parent
      then
         return no.
      else do:
         find first xGroupObj where xGroupObj.GroupObj-Code eq parent
         no-lock no-error.
         if available xGroupObj
         then
            parent = xGroupObj.Parent-GroupObj.
         else
            return no.
      end.
      return yes.
   end method.
   method public void ViewMenu():
      define variable vChoice as integer no-undo.
      if    available xGroupObj
         or available tt-groupobj
      then do:
         run gbl/d-askw.w (input "Меню",
                           input "Выберите действие",
                           input "||",
                           input "Атрибуты|Статусы|Отмена",
                           input "Список атрибутов|Список статусов|",
                           input 1,
                           input 3,
                           output vchoice).
         if vChoice eq 1
         then
            run ref\xattr.p(if available xGroupObj then xGroupObj.GroupObj-Code else tt-groupobj.GroupObj-Code).
      end.
   end.
end class.
