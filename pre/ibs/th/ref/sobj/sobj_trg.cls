using Progress.Lang.*.
using ibs.th.ref.sobj.sType from propath.
block-level on error undo, throw.
class ibs.th.ref.sobj.sObj_trg:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
method private void userobjs_clear ():
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
method private void userobjs_object-count (output p-total-count as integer ):
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
method private void userobjs_append
  (p-obj-type as character,
   p-obj-code as integer):
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
method private void userobjs_object-exist (output p-object-exist as logical):
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
method private void userobjs_select-one(
parparentproc     as widget-handle,
p-db-num          as integer   ,
p-user-id         as character ,
p-host-code-obj   as integer   ,
p-obj-type        as character ,
p-obj-code        as integer   ,
output p-user-select     as logical   ,
output p-select-obj-type as character ,
output p-select-obj-code as character
):
  do
  on error undo, return error return-value
  :
    run gbl/userobjs_class.p
      (input  parparentproc
      ,input "userobjs_select-one"
      ,input-output table  userobjs_temp-user-obj  by-reference
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
method private void userobjs_select-many(
parparentproc     as widget-handle,
p-db-num          as integer   ,
p-user-id         as character ,
p-host-code-obj   as integer   ,
p-obj-type        as character ,
p-obj-code        as integer   ,
output p-user-select     as logical
):
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs_class.p
      (input  parparentproc
      ,input "userobjs_select-many"
      ,input-output table  userobjs_temp-user-obj by-reference
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
method private void thobjs(
   parparentproc     as widget-handle,
   i-bttns           as character,
   i-list-mode       as character,
   i-obj-type        as character,
   i-db-num          as integer,
   i-host-code       as integer,
   input-output  p-rid-list as character
):
run ref/thobjs_class.p
        ( input parparentproc
         ,input-output table  userobjs_temp-user-obj by-reference
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
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
         or Lookup(string(4),  Paramform:temp-param-obj) > 0
         or Lookup(string(1), Paramform:temp-param-obj) > 0  )
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
         if buf_clients.stts <> 0 then next.
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
            if buf_user-obj.obj-type = 'скл':U
            then do:
               mstr-obj# = mstr-obj#  +  " " + buf_clients.obj-name + ",".
               next.
            end.
         end.
         if    ParamForm:temp-param-obj-type = 'stock':U
            and ParamForm:all-object = false
         then do:
            if buf_user-obj.obj-type = 'маг':U
            then do:
               mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name + "," .
               next.
            end.
         end.
         define variable vselectobject as character no-undo.
         vselectobject = sType:SelectObjectchar( ObjForm:selectobject).
         case buf_user-obj.obj-type:
            when 'скл':U then do:
               find first buf_store where buf_store.obj-code = buf_user-obj.obj-code no-lock.
               if     vSelectObject = "firm":U
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
            when 'маг':U then  do:
               find first buf_shop where buf_shop.obj-code = buf_user-obj.obj-code no-lock.
               if     vselectobject = "firm":U
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
      if vselectobject = "currency":U
      then do:
         find first buf_clients no-lock where  buf_clients.obj-type = ParamObj:my-cntxt-obj-type and
                                               buf_clients.obj-code = ParamObj:my-cntxt-obj-code no-error.
         if ParamForm:verify-send-check and buf_clients.db-num <> ParamObj:my-cntxt-db-num
         then do:
            find first buf_db where buf_db.db-num = buf_clients.db-num no-lock.
            if buf_db.send-check = false
            then do:
               mstr-obj2# = mstr-obj2#  + " " + buf_clients.obj-name + ",".
               ObjForm:selectobject = stype:SelectObjectLbl( "all":U) .
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
   end.
   method public void select-objects-proc ( imy-request as logical ):
      select-objects-proc (imy-request, no ).
   end.
   method public void select-objects-proc ( imy-request as logical, ialt as logical   ):
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
         when "currency":U then do:
            verify-check ().
         end.
         when "all":U then   do:
            sss().
         end.
         when "all" then   do:
            sss().
         end.
         when "firm":U then   do:
            sss().
         end.
         when "choice":U then do:
            define variable v-object-exist as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
userobjs_object-exist
  (output v-object-exist
  )  .
            if ialt
            then do:
               if     not paramform:params-only
                  and     v-object-exist = false
               then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
   userobjs_append
  (input  ParamObj:my-cntxt-obj-type
  ,input  ParamObj:my-cntxt-obj-code
  )  .
                  v-object-exist = true .
               end.
            end.
            if    imy-request    = false
               or v-object-exist = false
            then do:
               define variable v-user-select as logical   no-undo .
               define variable v-recids      as character no-undo .
               if paramform:params-only
               then do:
                  thobjs
                    ( input ParamObj:my-handle
                    , input (if ParamObj:params-only-mode = 'ПРОСМОТР':U then "b-mark-hidden" else "b-mark,b-sel")
                    , input "all":U
                    , input ''
                    , input ?
                    , input ?
                    , input-output v-recids ) no-error .
               end.
               else do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
userobjs_select-many
  (input  ParamObj:my-handle
  ,input  ParamObj:my-cntxt-db-num
  ,input  ParamObj:my-cntxt-userid
  ,input  ParamObj:my-cntxt-host-code-obj
  ,input  ParamObj:my-cntxt-obj-type
  ,input  ParamObj:my-cntxt-obj-code
  ,output v-user-select
  )  .
               end.
            end.
            imy-request = true .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
userobjs_object-exist
  (output v-object-exist
  )  .
            if v-object-exist = false
            then do:
               if    ParamForm:temp-param-obj-type = 'shop':u
                  or ParamForm:temp-param-obj-type = 'stock':u
               then do:
                  ObjForm:selectobject = stype:SelectObjectLbl( "firm":U) .
               end.
               else do:
                  ObjForm:selectobject = stype:SelectObjectLbl( if ialt then "not":u else "currency":U)  .
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
                     if buf_userobjs_temp-user-obj.obj-type = 'скл':U
                     then do:
                        mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name  .
                        next.
                     end.
                  end.
                  if     ParamForm:temp-param-obj-type = 'stock':u
                     and ParamForm:all-object = false
                  then do:
                     if buf_userobjs_temp-user-obj.obj-type = 'маг':U
                     then do:
                        mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name  .
                        next.
                     end.
                  end.
                  case buf_userobjs_temp-user-obj.obj-type:
                     when 'скл':U
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
                           paramobj:create_obj-list(buf_userobjs_temp-user-obj.obj-type,  buf_userobjs_temp-user-obj.obj-code).
                        end.
                        else do:
                           mstr-obj# = mstr-obj#  +  " " +  buf_clients.obj-name + "," .
                        end.
                     end.
                     when 'маг':U
                     then do:
                        find first buf_shop where buf_shop.obj-code = buf_userobjs_temp-user-obj.obj-code no-lock.
                        find first buf_sysconf no-lock where buf_sysconf.host-code = buf_shop.host-code no-error.
                        find first buf_clients no-lock where
                                   buf_clients.obj-type = buf_userobjs_temp-user-obj.obj-type and
                                   buf_clients.obj-code = buf_userobjs_temp-user-obj.obj-code no-error.
                        if     buf_sysconf.base-code = base-code
                            or ParamForm:all-object = true
                        then do:
                           paramobj:create_obj-list(buf_userobjs_temp-user-obj.obj-type,  buf_userobjs_temp-user-obj.obj-code).
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
         if ObjForm:selectobject = stype:SelectObjectLbl("choice":U) then do:
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
         if paramForm:temp-param-Alon
         then do:
            if vSelectObject = "all":U           then sss().
            if vSelectObject = "firm":U      then sss().
            if vSelectObject = "currency":U  then select-objects-proc (no).
        end.
        case vSelectObject:
          when "all":U then t-str = " По всем объектам ".
          when "firm":U then t-str = " Все по фирме ".
          otherwise do:
              t-str = paramObj:get-obj-List-text().
          end.
       end case.
       paramobj:strobj = paramobj:x-text-Obj + ": " + t-str.
       if mstr-obj# <> "" then
          paramobj:strobj = paramobj:strobj  + chr(10) + "Не включены в список : " + mstr-obj# .
       if mstr-obj2# <> "" then
          paramobj:strobj = paramobj:strobj   + chr(10) +  "Нет информации о чеках на объектах : " + mstr-obj2# .
       if mstr-obj3# <> "" then do:
          if not vSelectObject = "firm":U then do:
             paramobj:strobj = paramobj:strobj   + chr(10) +  "Не текущая фирма : " + mstr-obj3# .
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
