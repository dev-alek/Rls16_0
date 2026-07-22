 
 /*------------------------------------------------------------------------
    File        : sObj_trg
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : druban
    Created     : Fri Oct 16 09:56:35 MSK 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.ref.sobj.sType from propath.

block-level on error undo, throw.

class ibs.th.ref.sobj.sObj_trg: 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   {cmp\str-glbl.i class}
   {cmp\r-page-pre.i}
   {gbl/userobjs.i class}
   define property ParamObj as class ibs.th.ref.sobj.sParamObj no-undo
   get.
   set.
   
   define property ParamForm as class ibs.th.ref.sobj.sParamForm no-undo
   get.
   set.
   
   define property ObjForm as class ibs.th.ref.sobj.sobj no-undo
   get.
   set.
   
   define public property stype as class ibs.th.ref.sobj.stype no-undo
   get.
   set.
   
   method public void VALUE-CHANGED_SelectObject(iSelectObject as char):
      new-state ("SELECTOBJECT="  + iSelectObject).
   end.
   
   define variable mstr-obj# as character no-undo.
   define variable mstr-obj2# as character no-undo.
   define variable mstr-obj3# as character no-undo.
 
   method public void  sss ():
      define buffer buf_clients  for ub.clients .
      define buffer cli-obj      for ub.clients .
      define buffer buf_user-obj for ub.user-obj .
      define buffer buf_db       for ub.db .
      define buffer buf_store    for ub.store .
      define buffer buf_shop     for ub.shop .
      define buffer buf_sysconf  for ub.sysconf .

      if    not (Paramform:temp-param-obj = '*'
         or Lookup(string({&o-all}),  Paramform:temp-param-obj) > 0
         or Lookup(string({&o-firm}), Paramform:temp-param-obj) > 0  ) 
      then do:
         message "Выполнить невозможно, смените текущий объект !" view-as alert-box error .
         return error.
      end.
      ParamObj:empty-obj-list().
      assign
         mstr-obj#  = ''
         mstr-obj2# = ''
         mstr-obj3# = ''
      .

      for each buf_user-obj no-lock
         where buf_user-obj.db-num  = ParamObj:my-cntxt-db-num
           and buf_user-obj.user-id = ParamObj:my-cntxt-userid ,
      each cli-obj no-lock
         where cli-obj.obj-type = buf_user-obj.obj-type
           and cli-obj.obj-code = buf_user-obj.obj-code
           and (   cli-obj.db-num           = ParamObj:my-cntxt-db-num  
                or ParamObj:my-cntxt-db-num = 0 )
      :
         find first buf_clients no-lock
              where buf_clients.obj-type = buf_user-obj.obj-type
                and buf_clients.obj-code = buf_user-obj.obj-code
         .
         if buf_clients.stts <> 0 then next. /* удаленным здесь не место */

         if     ParamForm:verify-send-check 
            and buf_clients.db-num <> ParamObj:my-cntxt-db-num  
            and ParamForm:all-object = false  
         then do:
            find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
            if buf_db.send-check = false 
            then do:
               mstr-obj2# = mstr-obj2#  + " " + buf_clients.obj-name + ",".
               next.
            end.
         end.

         if     ParamForm:temp-param-obj-type = 'shop':U 
            and ParamForm:all-object = false  
         then do:
            if buf_user-obj.obj-type = {&stock} 
            then do:
               mstr-obj# = mstr-obj#  +  " " + buf_clients.obj-name + ",".
               next.
            end.
         end.

         if    ParamForm:temp-param-obj-type = 'stock':U 
            and ParamForm:all-object = false 
         then do:
            if buf_user-obj.obj-type = {&shop} 
            then do:
               mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name + "," .
               next.
            end.
         end.
         define variable vselectobject as character no-undo.
         vselectobject = sType:SelectObjectchar( ObjForm:selectobject).
         case buf_user-obj.obj-type:
            when {&stock} then do:
               find first buf_store where buf_store.obj-code = buf_user-obj.obj-code no-lock.
               if     vSelectObject = {&obj-firm} 
                  and ParamForm:all-object = false 
               then do:
                  if buf_store.host-code <> ParamObj:my-cntxt-host-code-obj 
                  then do:
                     mstr-obj3# = mstr-obj3#  + " " + buf_clients.obj-name + ",".
                     next.
                  end.
               end.

               find first buf_sysconf no-lock where buf_sysconf.host-code = buf_store.host-code no-error.
               find first buf_clients no-lock where
                          buf_clients.obj-type = buf_user-obj.obj-type and
                          buf_clients.obj-code = buf_user-obj.obj-code no-error.

               if buf_sysconf.base-code = ParamObj:my-base-code 
               then do:
                  ParamObj:create_obj-list(buf_user-obj.obj-type, buf_user-obj.obj-code).
               end.
               else do :
                  if ParamForm:all-object = false 
                  then  
                     mstr-obj# = mstr-obj#  +  " "  +  buf_clients.obj-name +  "," .
                  else do:
                     ParamObj:create_obj-list(buf_user-obj.obj-type, buf_user-obj.obj-code).
                  end.
               end.
            end.
            when {&shop} then  do:
               find first buf_shop where buf_shop.obj-code = buf_user-obj.obj-code no-lock.
               if     vselectobject = {&obj-firm} 
                  and ParamForm:all-object = false 
               then do:
                  if buf_shop.host-code <> ParamObj:my-cntxt-host-code-obj 
                  then do:
                     mstr-obj3# = mstr-obj3#  + " " + buf_clients.obj-name + "," .
                     next.
                  end.
               end.
               find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
               find first buf_clients no-lock where
                          buf_clients.obj-type = buf_user-obj.obj-type and
                          buf_clients.obj-code = buf_user-obj.obj-code no-error.
               if buf_sysconf.base-code = ParamObj:my-base-code 
               then do:
                  ParamObj:create_obj-list(buf_user-obj.obj-type, buf_user-obj.obj-code).
               end.
               else do:
                  if ParamForm:all-object = false 
                  then   
                     mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name +  "," .
                  else do:
                     ParamObj:create_obj-list(buf_user-obj.obj-type, buf_user-obj.obj-code).
                  end.
               end.
            end.
         end case.
      end.
   end.

 
   method public void verify-check-currency ():
      define buffer buf_clients for ub.clients .
      define buffer buf_db for ub.db .
      define variable vselectobject as character no-undo.
      vselectobject = sType:SelectObjectchar( ObjForm:selectobject).
      if vselectobject = {&obj-currency} 
      then do:
         find first buf_clients no-lock where  buf_clients.obj-type = ParamObj:my-cntxt-obj-type and
                                               buf_clients.obj-code = ParamObj:my-cntxt-obj-code no-error.
         if ParamForm:verify-send-check and buf_clients.db-num <> ParamObj:my-cntxt-db-num  
         then do:
            find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
            if buf_db.send-check = false 
            then do:
               mstr-obj2# = mstr-obj2#  + " " + buf_clients.obj-name + ",".
               ObjForm:selectobject = stype:SelectObjectLbl( {&obj-all}) .
               ObjForm:BtnObj:Enabled = false. 
               sss () .
               return error.
            end.
         end.
      end.
   end.

   method public void verify-check ():
      define buffer buf_clients for ub.clients .
      define buffer buf_db for ub.db .
      /*--проверка чеков на текущем ----------------------------------------------------------------------------------------- */
      find first buf_clients no-lock where
                 buf_clients.obj-type = ParamObj:my-cntxt-obj-TYPE and
                 buf_clients.obj-code = ParamObj:my-cntxt-obj-CODE 
      no-error.
      if     ParamForm:Verify-send-check 
         and buf_Clients.db-num <> ParamObj:my-cntxt-db-num  
      then do:
         find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
         if buf_db.send-check = false 
         then do:
            message 'Нельзя выбрать текущий объект !' view-as alert-box error.
            verify-check-currency ().
         end.
         else do:
            ParamObj:create_obj-list(buf_clients.obj-type, buf_clients.obj-code).
         end.
      end.
      else do:
         ParamObj:create_obj-list(buf_clients.obj-type, buf_clients.obj-code).
      end.
      /*---------------------------------------------------------------------------------------------------------------*/
   end.
   method public void select-objects-proc ( imy-request as logical ):
      select-objects-proc (imy-request, no ).
   end.
   
   method public void select-objects-proc ( imy-request as logical, ialt as logical  /* {1} eq "alt-" */ ):
      define variable v-ii as integer   no-undo .
      def buffer cli-obj  for ub.clients .

      ParamObj:empty-obj-list().
  
      assign
         mstr-obj#  = "" 
         mstr-obj2# = "" 
         mstr-obj3# = "" 
      .
      define variable vselectobject as character no-undo.
      vselectobject = sType:SelectObjectchar( ObjForm:selectobject). 
      case vselectobject :
         when {&obj-currency} then do:
            verify-check ().
         end.
         when {&obj-all} then   do:
            sss().
         end.
         when "all" then   do:
            sss().
         end.
         when {&obj-firm} then   do:
            sss().
         end.
         when {&obj-choice} then do:
            define variable v-object-exist as logical   no-undo .
            { gbl/uobjexst.i
                class
                v-object-exist
            }
            if ialt
            then do:
               if     not paramform:params-only 
                  and     v-object-exist = false 
               then do:
                  { gbl/uobjapnd.i
                        class
                        ParamObj:my-cntxt-obj-type
                        ParamObj:my-cntxt-obj-code
                  }
                  v-object-exist = true .
               end.
            end.

            if    imy-request    = false
               or v-object-exist = false
            then do:
               define variable v-user-select as logical   no-undo .
               define variable v-recids      as character no-undo .
                /*
                for each userobjs_temp-user-obj :
                    message userobjs_temp-user-obj.obj-code .
                end.
                */
               if paramform:params-only 
               then do:
                  thobjs
                    ( input ParamObj:my-handle
                    , input (if ParamObj:params-only-mode = {&lookup} then "b-mark-hidden" else "b-mark,b-sel")
                    , input {&obj-all}
                    , input '' /*p-obj-type*/
                    , input ? /*p-db-num*/
                    , input ? /*p-host-code*/
                    , input-output v-recids ) no-error .
               end.
               else do:
                 { gbl/uobjsman.i 
                   class
                   ParamObj:my-handle
                   ParamObj:my-cntxt-db-num
                   ParamObj:my-cntxt-userid
                   ParamObj:my-cntxt-host-code-obj
                   ParamObj:my-cntxt-obj-type
                   ParamObj:my-cntxt-obj-code
                   v-user-select
                 }
               end.
            end.
            imy-request = true .

            { gbl/uobjexst.i
               class
               v-object-exist
            }
            if v-object-exist = false
            then do:
               if    ParamForm:temp-param-obj-type = 'shop':u 
                  or ParamForm:temp-param-obj-type = 'stock':u 
               then do:
                  ObjForm:selectobject = stype:SelectObjectLbl( {&obj-firm}) .
               end.
               else do:
                  ObjForm:selectobject = stype:SelectObjectLbl( if ialt then "not":u else {&obj-currency})  .
               end.

               ObjForm:BtnObj:Enabled = false.

               find cli-obj where cli-obj.obj-type = ParamObj:my-cntxt-obj-type and
                                  cli-obj.obj-code = ParamObj:my-cntxt-obj-code no-lock .
               if    ParamForm:temp-param-obj-type = 'shop':u 
                  or ParamForm:temp-param-obj-type = 'stock':u
               then do:
                  sss().
               end.
               else do:
                  if ialt then do:
                     verify-check().
                  end.
               end.
            end.
            else do:
               define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
               define buffer buf_clients for ub.clients .
               define buffer buf_db for ub.db .
               define buffer buf_shop for ub.shop .
               define buffer buf_store for ub.store .
               define buffer buf_sysconf for ub.sysconf .

               for each buf_userobjs_temp-user-obj
               :
                  find first buf_clients no-lock
                       where buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type
                         and buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
                  .
                  if     ParamForm:verify-send-check  
                     and buf_clients.db-num <> paramObj:my-cntxt-db-num  
                     and ParamForm:all-object = false 
                  then do:
                     find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
                     if buf_db.send-check = false 
                     then do:
                        mstr-obj2# = mstr-obj2#  + " " + buf_clients.obj-name + ",".
                        next.
                     end.
                  end.

                  if     ParamForm:temp-param-obj-type = 'shop':u 
                     and ParamForm:all-object = false 
                  then do:
                     if buf_userobjs_temp-user-obj.obj-type = {&stock} 
                     then do:
                        mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name  .
                        next.
                     end.
                  end.

                  if     ParamForm:temp-param-obj-type = 'stock':u 
                     and ParamForm:all-object = false 
                  then do:
                     if buf_userobjs_temp-user-obj.obj-type = {&shop} 
                     then do:
                        mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name  .
                        next.
                     end.
                  end.

                  case buf_userobjs_temp-user-obj.obj-type:
                     when {&stock} 
                     then do:
                        find buf_store where buf_store.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                        find first buf_sysconf no-lock where buf_sysconf.host-code = buf_store.host-code no-error.
                        find first buf_clients no-lock where
                                   buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                   buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code
                        .

                        if    buf_sysconf.base-code = base-code 
                           or ParamForm:all-object = true
                        then do:
                           /*&if "{1}" = ""  &then */
                           paramobj:create_obj-list(buf_userobjs_temp-user-obj.obj-type,  buf_userobjs_temp-user-obj.obj-code).
/*                           { cmp/cr-objls.i  buf_userobjs_temp-user-obj.obj-type  buf_userobjs_temp-user-obj.obj-code  }*/
                          /*       &else
                                 create {1}obj-list.
                                 assign
                                     {1}obj-list.obj-name = buf_clients.obj-name
                                     {1}obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                                     {1}obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code.
                                 &endif */
                        end.
                        else do:
                           mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name + "," .
                        end.
   
                     end.
                     when {&shop} 
                     then do:
                        find first buf_shop where buf_shop.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                        find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                        find first buf_clients no-lock where
                                   buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                   buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
      
                        if     buf_sysconf.base-code = base-code 
                            or ParamForm:all-object = true
                        then do:
      /*                              &if "{1}" = ""  &then*/
                           paramobj:create_obj-list(buf_userobjs_temp-user-obj.obj-type,  buf_userobjs_temp-user-obj.obj-code).
/*                           { cmp/cr-objls.i class buf_userobjs_temp-user-obj.obj-type  buf_userobjs_temp-user-obj.obj-code  }*/
                                 /* &else
                                    create {1}obj-list.
                                    assign
                                        {1}obj-list.obj-name = buf_clients.obj-name
                                        {1}obj-list.obj-type = buf_userobjs_temp-user-obj.obj-type
                                        {1}obj-list.obj-code = buf_userobjs_temp-user-obj.obj-code.
                                    &endif */
                        end.
                        else do:
                           mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name + "," .
                        end.
                     end.
                  end case.
               end.
            end.
         end.
      end case.
   end.
   
   method private void new-state(istate as character ):
   end.
   
    
   method public void verify-obj ():

      if ParamForm:temp-param-obj <> "" 
      then do:
         if ObjForm:selectobject = stype:SelectObjectLbl({&obj-choice}) then do:
/*      my-request =  true.*/
            select-objects-proc(true,no).
         end.
         if not paramObj:can-find-obj-list() 
         then do:
            message "Не выбран объект !" skip
               "Объекты не включенные в список" mstr-obj#    skip
               mstr-obj2#   skip
               mstr-obj3#   skip
               view-as alert-box error.
            return error.
         end.
      end.
   end.
   
   method public logical set_SelectObject (iSelectObject as character ):
      paramobj:x-SelectObject = stype:SelectObjectChar(iSelectObject).
   end method.
   
   method public logical set_TextLb (itext as character ):
      paramobj:x-text-Obj = itext.
   end method.
   
   method public character  Assign-frame(iSelectObject as character):
      define variable vSelectObject as character no-undo.
      define variable t-str as character no-undo.
      paramobj:CheckAndUpNameObjList().
      if ParamForm:temp-param-obj = ""   
      then ParamObj:strobj = ''.
      else do:
         vSelectObject = stype:SelectObjectChar(iSelectObject).
         t-str= '' .
        /* снова формируем если 1 закладка */
         if paramForm:temp-param-Alon 
         then do:
            if vSelectObject = {&obj-all}           then sss().
            if vSelectObject = {&obj-firm}      then sss().
            if vSelectObject = {&obj-currency}  then select-objects-proc (no).
        end.

        case vSelectObject:
          when {&obj-all} then t-str = " По всем объектам ".
          when {&obj-firm} then t-str = " Все по фирме ".
          otherwise do:
              t-str = paramObj:get-obj-List-text().
          end.
       end case.
       paramobj:strobj = paramobj:x-text-Obj + ": " + t-str.        /*объекты*/
       if mstr-obj# <> "" then
          paramobj:strobj = paramobj:strobj  + {&new-line} + "Не включены в список : " + mstr-obj# .        /*объекты которые не попали*/
       if mstr-obj2# <> "" then
          paramobj:strobj = paramobj:strobj   + {&new-line} +  "Нет информации о чеках на объектах : " + mstr-obj2# .        /*объекты которые не попали*/
       if mstr-obj3# <> "" then do:
          if not vSelectObject = {&obj-firm} then do:
             paramobj:strobj = paramobj:strobj   + {&new-line} +  "Не текущая фирма : " + mstr-obj3# .        /*объекты которые не попали*/
          end.
       end.
     end.
     return paramobj:strobj.
   end.

   constructor public sObj_trg (  ):
      super ().
      
   end constructor.

   destructor public sObj_trg ( ):

   end destructor.

end class.