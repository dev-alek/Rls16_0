 
 /*------------------------------------------------------------------------
    File        : xatrr_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Sun Nov 08 11:25:17 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class ibs.th.ref.xproc.xattr_trg: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   {cmp\str-glbl.i class}
   define temp-table tt-query no-undo
      field NameQuery as character 
      field hQuery    as handle
   index NameQuery NameQuery.
  
   define temp-table tt-attr no-undo like xattr 
      field Frecid  as recid
      field fchange as logical  
   .   
   constructor public xattr_trg (  ):
      super ().
      
   end constructor.

   destructor public xattr_trg ( ):

   end destructor.
   
   
   define public variable GroupObjCode as character no-undo.
  
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
          /*setFieldBrw(num-entries(Parent,{&delim-par})).*/
      case iNameQuery:
         when "tt-attr"
         then do:
            for each tt-attr:
               delete tt-attr.
            end.
            for each xattr where Xattr.GroupObj-code eq  GroupObjCode 
            no-lock:
               create tt-attr. 
               buffer-copy xattr to tt-attr
               assign
                  tt-attr.Frecid = recid (xgroupobj)
               .
            end.
            hQuery:set-buffers(buffer tt-attr:HANDLE). 
            hQuery:query-prepare("FOR EACH tt-attr ").
         end.
         when "xattr" 
         then do:
            hQuery:set-buffers(buffer xattr:HANDLE). 
            hQuery:query-prepare("FOR EACH xattr where xattr.GroupObj-code eq " + QUOTER(GroupObjCode) +
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
     /* else
         hQuery = tt-Query.hQuery.*/
      return hQuery.
   end.
   
   method public void brwAttr():
      define variable VBrw as class ibs.th.ref.xproc.xattr no-undo.
      vBrw = new ibs.th.ref.xproc.Xattr (this-object).
      vBrw:ShowModalDialog().
      delete object vbrw.
   end.
   
   method public void addXattr ( ):
      define buffer Xattr for Xattr.
      create tt-attr.
      tt-attr.GroupObj-code = GroupObjCode.
      tt-attr.sign-inherit  = GroupObjCode.
      frmAttr({&add-def} , buffer tt-attr:handle).
      finally:
         delete tt-Attr.
      end finally.
   end method.
    
   method public void editXattr ( ):
/*      define buffer xGroupObj for xGroupObj.*/
      if available Xattr 
      then do:
         buffer-copy Xattr to tt-attr.
         tt-attr.Frecid  = recid(Xattr).
         frmAttr({&update},buffer tt-Attr:handle).
      end.
      finally:
         if available tt-attr
         then
            delete tt-attr.
      end finally.
   end method.
    
   method public logical delXAttr ( ):
      if available Xattr 
      then do:
         find current Xattr exclusive-lock.
         if available Xattr
         then do:
            delete Xattr no-error.
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
   
   method public void lookXattr ( ):
      if available  Xattr
      then
         frmattr({&lookup} , buffer Xattr:handle).
      
   end method.
   
   method public void frmAttr (Imode as character ,ibuffertt as handle ):
      define variable VSave as logical no-undo.
      define variable v-frmEdit as class ibs.th.ref.xproc.xattrFrm no-undo.
      if Imode eq {&lookup}
      then
         v-frmEdit = new ibs.th.ref.xproc.xattrfrm().
      else
         v-frmEdit = new ibs.th.ref.xproc.xattrfrm(this-object).
      v-frmEdit:ShowModalDialog(ibuffertt) .
      VSave = v-frmEdit:DialogResult eq System.Windows.Forms.DialogResult:ok.
      delete object v-frmEdit.
      if VSave  
      then do trans:
          if Imode eq {&add-def}
          then
             create xAttr.
          else
             find current xattr exclusive-lock.
          buffer-copy tt-attr to xattr.
      end.
      
      
   end method.

end class.