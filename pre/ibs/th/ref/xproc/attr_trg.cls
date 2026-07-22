using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.ref.xproc.attr_trg:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
   define temp-table tt-query no-undo
      field NameQuery as character
      field hQuery    as handle
   index NameQuery NameQuery.
   define temp-table tt-attr
      field rowidf     as rowid
      field attr-code  as character
      field attr-name  as character
      field attr-value as character
      field mandatoryf as logical
      index attr-code attr-code
      index rowidf rowidf
      index mandatoryf mandatoryf
   .
   define public variable mbuffPar as handle  no-undo.
   define public variable mAll     as logical no-undo .
   define variable mKeyRec as class ibs.th.gbl.keyrec no-undo.
   define variable mGroupObj as character no-undo.
   define variable mWhere    as character no-undo.
   constructor public attr_trg (  ):
      super ().
      mKeyRec = new ibs.th.gbl.keyrec().
   end constructor.
   destructor public attr_trg ( ):
      delete object mKeyRec.
   end destructor.
   method public handle getQuery (input iNameQuery as character) :
      return getQuery(iNameQuery,no).
   end.
   method public handle getQuery (input iNameQuery as character,input iNewQuery as logical ) :
      define variable hQuery   as handle  no-undo .
      define variable vfirst   as logical no-undo .
      define variable vOpen    as logical no-undo init yes.
      define variable vTblName as character no-undo .
      define variable vOpenStr as character no-undo .
      define variable vSchedId as integer no-undo .
      define buffer xattr for xattr.
      define buffer tt-attr-new for tt-attr.
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
         when "tt-attr"
         then do:
            for each tt-attr:
               delete tt-attr.
            end.
            define variable vTables as character no-undo.
            define variable vTablesAttr as character no-undo.
            define variable vBhTbl as handle no-undo.
            define variable vAttrCode as character no-undo.
            define variable vWhere as character no-undo.
            vTables = mbuffPar:table.
            vTablesAttr = vTables + "-attr".
            mkeyrec:GenWhereKeyrTab(vTables + "-attr", vTables, vTables + "-attr", mbuffPar, "ub", ?,  output mWhere).
            create buffer vBhTbl for table vTablesAttr .
            mGroupObj = mbuffPar:buffer-field ("GroupObj"):buffer-value ()no-error.
            if error-status:error
            then do:
               .
               vBhTbl:find-first( substitute("&1 and &2.attr-code eq 'GroupObj'",mwhere,vTablesAttr), no-lock ) no-error .
               mGroupObj = if vBhTbl:available then vBhTbl:buffer-field ("attr-value"):buffer-value () else vTables.
            end.
            vWhere = substitute("FOR EACH &1 &2 ",vTables + "-attr",mWhere).
            create query hQuery.
            hQuery:set-buffers(vBhTbl).
            hQuery:query-prepare(vWhere + " No-lock") no-error.
            hQuery:query-open().
            hQuery:get-first().
            do while not hQuery:query-off-end:
               vAttrCode = vBhTbl:buffer-field("attr-code"):buffer-value.
               find first xattr where Xattr.GroupObj-code eq  mGroupObj
                                  and Xattr.Xattr-Code    eq  vAttrCode
               no-lock no-error.
               if   (     available xattr
                     and  not Xattr.Hidden)
                  or not available xattr
               then do:
                  create tt-attr-new.
                  tt-attr-new.rowidf     = vBhTbl:rowid.
                  tt-attr-new.attr-code  = vAttrCode.
                  if available xattr then do:
                     tt-attr-new.attr-name  = Xattr.Name.
                     tt-attr-new.attr-value = formatVulue(vBhTbl:buffer-field("attr-value"):buffer-value,Xattr.Data-Type,Xattr.Data-Format).
                     tt-attr-new.mandatoryf = Xattr.Mandatory.
                  end.
                  else do:
                     tt-attr-new.attr-name  = vAttrCode.
                     tt-attr-new.attr-value = vBhTbl:buffer-field("attr-value"):buffer-value.
                  end.
               end.
               hQuery:get-next().
            end.
            delete object vBhTbl.
            for each xattr where Xattr.GroupObj-code eq  mGroupObj
                             and not Xattr.Hidden
                             and not Xattr.Progress-Field
                             and (   Xattr.Mandatory or mAll)
            no-lock:
               find first tt-attr where tt-attr.attr-code eq Xattr.Xattr-Code
               no-lock no-error.
               if not available tt-attr
               then do:
                  create tt-attr-new.
                  assign
                     tt-attr-new.attr-code  = Xattr.Xattr-Code
                     tt-attr-new.attr-name  = Xattr.Name
                     tt-attr-new.mandatoryf = Xattr.Mandatory
                  .
                  release tt-attr-new.
               end.
            end.
            hQuery:set-buffers(buffer tt-attr:HANDLE).
            hQuery:query-prepare("FOR EACH tt-attr ").
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
   method public void brwAttr():
      define variable VBrw as class ibs.th.ref.xproc.attr no-undo.
      vBrw = new ibs.th.ref.xproc.attr (this-object).
      vBrw:ShowModalDialog().
      delete object vbrw.
   end method.
   method public character formatVulue(ivalue as character ,
                                       iType  as character ,
                                       iFormat as character):
      return trim(
                if iType eq 'decimal':U
                then string(decimal (ivalue), iFormat)
                else if iType eq 'date':U
                then string(date    (ivalue), iFormat)
                else if iType eq 'integer':U
                then string(integer (ivalue), iFormat)
                else if iType eq 'logical':U
                then string(logical (ivalue), iFormat)
                else string(         ivalue , iFormat)
                ).
   end method.
   method public void editform():
      define variable vFrmTrg as class ibs.th.ref.xproc.attrfrm_trg no-undo.
      define variable vresult as character no-undo.
      if available tt-attr
      then do:
         vFrmTrg = new ibs.th.ref.xproc.attrfrm_trg().
         vFrmTrg:GroupObj = mGroupObj.
         vFrmTrg:AttrCode = tt-attr.attr-code.
         if vFrmTrg:FrmAttr(if tt-attr.rowidf eq ? then ? else tt-attr.attr-value)
         then do:
            vresult = vFrmTrg:resultValue.
                        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run attr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib
                 (mbuffPar,
                  tt-attr.attr-code,
                  vresult)no-error.
            if error-status:error
            then do:
               message return-value
               view-as alert-box.
            end.
            else do:
               define variable vBhTbl as handle no-undo.
               define variable vTablesAttr as character no-undo.
               vTablesAttr = mbuffPar:table + "-attr".
               create buffer vBhTbl for table vTablesAttr .
               vBhTbl:find-first( substitute("&1 and &2.attr-code eq '&3'",mwhere,vTablesAttr,tt-attr.attr-cod), no-lock ) no-error .
               if vBhTbl:available
               then do:
                  find first xattr where Xattr.GroupObj-code  eq mGroupObj
                                     and Xattr.Xattr-Code     eq tt-attr.attr-code
                  no-lock no-error.
                     tt-attr.attr-value = if available xattr
                                          then formatVulue(vresult,Xattr.Data-Type,Xattr.Data-Format)
                                          else vresult.
                     tt-attr.rowidf = vBhTbl:rowid.
               end.
               else
                  message "Беда"
                  view-as alert-box.
            end.
         end.
         delete object vFrmTrg.
      end.
   end method.
end class.
