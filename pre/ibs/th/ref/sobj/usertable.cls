USING Progress.Lang.*.
using ibs.th.ref.sobj.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.sobj.usertable :
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
method public void empty-obj-list ():
   for each obj-list :
      delete obj-list.
   end.
end.
method public logical can-find-obj-list ():
   return can-find (first obj-list no-lock).
end.
method public void get-obj-list (output table obj-list bind):
end.
method public void set-obj-list (input table obj-list bind):
end.
method public void create_obj-list (p-obj-type as char, p-obj-code as integer ):
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
 define temp-table tt-user-account no-undo
field user-id_  as character LABEL "ID"
field user_name as character LABEL "Имя пользователя"
field db-num    as integer   LABEL "БД "
field flg       as logical   LABEL "*" format "*/"
field flg2      as logical
index pi db-num user-id_
.
define temp-table tt-objects  no-undo
field name_ as character
field table_ as character
field flg    as logical  LABEL "*" format "*/"
field flg2   as int
.
define temp-table tt-user-account2 no-undo
field user-id_  as character LABEL "ID"
field user_name as character LABEL "Имя пользователя"
field db-num    as integer   LABEL "БД "
field flg       as logical   LABEL "*" format "*/"
field flg2      as logical
index pi db-num user-id_
.
define temp-table tt-objects2  no-undo
field name_ as character
field table_ as character
field flg    as logical  LABEL "*" format "*/"
field flg2   as int
.
define variable v-user-table-name as character no-undo .
define variable v-user-table      as character no-undo .
define variable v-table           as character no-undo .
define buffer buf_tt-user-account2 for tt-user-account2  .
DEFINE VARIABLE mform  AS CLASS ibs.th.ref.sobj.userhist no-undo.
define property query_user-table as handle no-undo
  public get.
  public set.
define property query_user-account as handle no-undo
  public get.
  public set.
constructor public usertable (iform as class ibs.th.ref.sobj.userhist ):
super().
mform = iform.
  create query query_user-table.
               query_user-table:set-buffers(buffer tt-objects:HANDLE).
               query_user-table:query-prepare("FOR EACH tt-objects BY tt-objects.name_ ").
               query_user-table:query-open.
  create query query_user-account.
               query_user-account:set-buffers(buffer tt-user-account:HANDLE).
               query_user-account:query-prepare("FOR EACH tt-user-account BY tt-user-account.user_name ").
               query_user-account:query-open.
end constructor.
METHOD public void init_tt():
mform:ParamObj:get-obj-list(output table obj-list).
for each user-obj  ,
      each ub.user-account no-lock where ub.user-account.user-id = user-obj.user-id:
         find first tt-user-account where tt-user-account.user-id_ = ub.user-account.user-id and tt-user-account.flg2 = yes  no-error.
            if  not AVAILABLE tt-user-account then do:
            create tt-user-account .
            assign
            tt-user-account.db-num    = user-obj.db-num
            tt-user-account.user-id_  = ub.user-account.user-id
            tt-user-account.user_name =
                              user-account.last-name
                              + " "      + user-account.first-name
                              + " "      + user-account.second-name
            tt-user-account.flg2 = yes
            .
         end.
end.
if mform:ParamObj:x-SelectObject <> "firm" then do:
 for each tt-user-account  :
    find first obj-list where tt-user-account.db-num = obj-list.db-num no-error.
      if not AVAILABLE obj-list then
         do:
            delete tt-user-account .
         end.
END.
END.
 EMPTY TEMP-TABLE tt-objects.
for each c-user-log no-lock
    where c-user-log.corr-date >= mform:ParamObj:x-Date-Start and c-user-log.corr-date <= mform:ParamObj:x-Date-End
    by c-user-log.head-table :
    v-table = c-user-log.head-table .
    if v-table begins "c-" and v-table <> 'c-usr-hist':U and v-table <> 'c-plc-hist':U
     then  do:
         v-user-table = replace(v-table,"c-","").
     end.
     else v-user-table = v-table .
     find first tt-objects where tt-objects.table_ = v-user-table and tt-objects.flg2 =  1 no-error .
     if not AVAILABLE (tt-objects) then
        do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run tblnmusr in ibs.th.gbl.gbl-hndllib:g#library
  (input  v-user-table
  ,output v-user-table-name
  )  .
        create tt-objects .
            assign
            tt-objects.table_ = v-user-table
            tt-objects.name_  = v-user-table-name
            tt-objects.flg2 =  1
            .
     end.
end.
for each tt-objects  :
    find first tt-objects2 where tt-objects2.table_ = tt-objects.table_ and tt-objects2.flg = yes no-error .
    if AVAILABLE (tt-objects2) then
    do:
            assign
            tt-objects.flg =  yes
            .
     end.
end.
 empty TEMP-TABLE tt-objects2.
for each tt-objects  :
     create tt-objects2 .
     buffer-copy tt-objects to tt-objects2 .
end.
END METHOD.
METHOD public void mark_user():
    tt-user-account.flg = not tt-user-account.flg .
END METHOD.
METHOD public void mark_user_all():
      for each tt-user-account  :
            tt-user-account.flg = yes .
      end.
END METHOD.
METHOD public void mark_table():
    tt-objects.flg = not tt-objects.flg .
    for each tt-objects2 where tt-objects.table_ =  tt-objects2.table_ :
    tt-objects2.flg = not tt-objects2.flg .
    end.
END METHOD.
METHOD public void mark_table_all():
    for each tt-objects  :
    tt-objects.flg = yes.
    end.
    for each tt-objects2  :
    tt-objects2.flg = yes .
    end.
END METHOD.
METHOD public void my_report():
empty TEMP-TABLE tt-user-account2.
for each tt-user-account  :
     create tt-user-account2 .
     buffer-copy tt-user-account to tt-user-account2 .
end.
find first tt-user-account where tt-user-account.flg = yes no-error.
if AVAILABLE tt-user-account then do:
  for each tt-user-account  :
      if   tt-user-account.flg = no then delete tt-user-account .
  end.
end.
empty TEMP-TABLE tt-objects2.
for each tt-objects  :
     create tt-objects2 .
     buffer-copy tt-objects to tt-objects2 .
end.
find first tt-objects where tt-objects.flg = yes no-error.
if AVAILABLE tt-objects then do:
   for each tt-objects  :
     if   tt-objects.flg = no then delete tt-objects .
   end.
end.
run rep/r-hist-sysadm.p
         (input mform:ParamObj:my-handle,
          input mform:ParamObj:x-Date-Start,
          input mform:ParamObj:x-Date-End,
          input table tt-user-account BY-REFERENCE,
          input table tt-objects      BY-REFERENCE ) .
empty TEMP-TABLE tt-user-account.
for each tt-user-account2:
     create tt-user-account .
     buffer-copy tt-user-account2 to tt-user-account .
end.
empty TEMP-TABLE tt-objects.
for each tt-objects2:
     create tt-objects.
     buffer-copy tt-objects2 to tt-objects .
end.
END METHOD.
END CLASS.
