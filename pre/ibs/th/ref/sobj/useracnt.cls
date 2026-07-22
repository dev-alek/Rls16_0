USING Progress.Lang.*.
USING ibs.th.ref.sobj.*.
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.ref.sobj.useracnt inherits sUserFrame:
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
