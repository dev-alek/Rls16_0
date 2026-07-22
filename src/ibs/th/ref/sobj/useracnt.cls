 /*------------------------------------------------------------------------
    File        : useracnt
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : svvtm
    Created     : Mon Nov 18 13:44:18 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/
USING Progress.Lang.*.
USING ibs.th.ref.sobj.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.sobj.useracnt inherits sUserFrame:
     
  { cmp/str-glbl.i class}
  { gbl/getcntxt.i def }
  { cmp/library.i class }
  {cmp/obj-list.i local} 

define variable v-obj-code  as integer no-undo .
define variable v-obj-type  as character no-undo .
define buffer buf_c-user-log for c-user-log.

define temp-table tt-user-account no-undo
field user-id_  as character LABEL "ID"  
field user_name as character LABEL "Имя пользователя"  
field db-num    as integer   LABEL "БД "  
index pi db-num user-id_
.

define property query_user-account as handle no-undo 
  public get.
  public set.
  
constructor public useracnt ( ):

  super().
 
  create query query_user-account.                    
               query_user-account:set-buffers(buffer tt-user-account:HANDLE). 
               query_user-account:query-prepare("FOR EACH tt-user-account").
               query_user-account:query-open.
  
/*empty temp-table tt-user-account . */
 
for each user-obj where user-obj.obj-code = 1 ,
      each ub.user-account no-lock where ub.user-account.user-id = user-obj.user-id: 
      create tt-user-account .
      assign
      tt-user-account.db-num = user-obj.obj-code
      tt-user-account.user-id_ = ub.user-account.user-id
      tt-user-account.user_name = "ID: " + ub.user-account.user-id 
                              + " ФИО: " + user-account.last-name 
                              + " "      + user-account.first-name 
                              + " "      + user-account.second-name
                              .
end.       

end constructor.

END CLASS.