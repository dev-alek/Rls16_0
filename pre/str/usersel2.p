block-level on error undo, throw.
define input parameter parparentproc            as handle           no-undo.
define input parameter p-old-user-id            as character        no-undo.
define input parameter p-mode                   as integer          no-undo.
define output parameter p-new-user-id           as character        no-undo.
define output parameter p-new-parent-user-id    as character        no-undo.
define output parameter p-accepted              as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: 79a9852ece24, 1698, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 11 11:54:14 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usersel2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usersel2.p $":U .
define variable vss-description as character no-undo init "Диалог выбора пользователя".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_onewin_items no-undo
    field itm-key       as integer
    field itmExtKey     as character
    field itmName       as character
    field itmDesc       as character
    field itmSelected   as logical
    index pi is primary unique
        itm-key
    index ie
        itmExtKey
.
define temp-table temp_onewin_itemsSelected no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character
    index pi is primary unique
        its-key
    index im
        itm-key
.
define variable v-onewin0-itm-key    as integer      no-undo.
procedure onewin_clear :
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    empty temp-table buf_temp_onewin_items.
end.
end procedure.
procedure onewin_add-item :
define input parameter p-ext-key   as character        no-undo.
define input parameter p-item-name as character        no-undo.
define input parameter p-item-desc as character        no-undo.
define input parameter p-selected  as logical          no-undo.
    define buffer buf_temp_onewin_items        for temp_onewin_items.
do
for buf_temp_onewin_items
on error undo, return error
:
    find last buf_temp_onewin_items no-error.
    if available buf_temp_onewin_items then do:
      v-onewin0-itm-key = buf_temp_onewin_items.itm-key.
    end.
    else do:
      v-onewin0-itm-key = 0.
    end.
    assign
        v-onewin0-itm-key = v-onewin0-itm-key + 1
    .
    create buf_temp_onewin_items.
    assign
    buf_temp_onewin_items.itm-key      = v-onewin0-itm-key
    buf_temp_onewin_items.itmExtKey    = p-ext-key
    buf_temp_onewin_items.itmName      = p-item-name
    buf_temp_onewin_items.itmDesc      = p-item-desc
    buf_temp_onewin_items.itmSelected  = p-selected
    .
end.
end procedure.
procedure onewin_create-selection :
define input parameter p-itm-key as integer no-undo .
define input parameter p-itmextkey as character no-undo .
define variable v-counter as integer no-undo .
define buffer buf_temp_onewin_itemsSelected for temp_onewin_itemsSelected .
do
on error undo, return error
:
  find last buf_temp_onewin_itemsSelected use-index pi no-error.
  if available buf_temp_onewin_itemsSelected then do:
    v-counter = buf_temp_onewin_itemsSelected.its-key.
  end.
  find first buf_temp_onewin_itemsSelected where
       buf_temp_onewin_itemsSelected.itm-key = p-itm-key no-error.
  if not available buf_temp_onewin_itemsSelected then do:
    create buf_temp_onewin_itemsSelected.
    assign
    buf_temp_onewin_itemsSelected.its-key   = v-counter + 1
    v-counter = v-counter + 1
    buf_temp_onewin_itemsSelected.itm-key   = p-itm-key
    buf_temp_onewin_itemsSelected.itmExtKey = p-itmExtKey
    .
  end.
end.
end procedure.
procedure onewin_check-item :
define input parameter p-ext-key   as character        no-undo.
define output parameter p-exists as logical no-undo .
define buffer buf_temp_onewin_items for temp_onewin_items.
find first buf_temp_onewin_items where
buf_temp_onewin_items.itmExtKey    = p-ext-key no-error.
if available buf_temp_onewin_items then do:
  p-exists = yes.
end.
end procedure.
    define variable v-cur-ext-key   as character    no-undo.
    define variable v-login-string  as character    no-undo.
    define variable v-cntxt-userid as character no-undo .
    define variable v-cntxt-db-num as integer no-undo .
    define variable vI             as integer no-undo .
    define buffer buf_user-account      for user-account.
    define buffer buf_user-login        for user-login.
do
for buf_user-account
  , buf_user-login
on error undo, return error
:
    run get-userid in parparentproc ( output v-cntxt-userid).
    run get-db-num in parparentproc ( output v-cntxt-db-num).
    assign
        p-new-user-id = p-old-user-id
    .
    run onewin_clear in this-procedure.
    empty temp-table temp_onewin_itemsSelected.
    for each buf_user-account no-lock
    on error undo, return error
    :
        assign
            v-login-string = "":U
        .
        for each buf_user-login no-lock
           where buf_user-login.user-id = buf_user-account.user-id
             and buf_user-login.db-num = 0
        :
            assign
                v-login-string = substitute( "&1&2БД &3: &4"
                                            , v-login-string
                                            , ( if v-login-string = "":U then "":U else ", ":U )
                                            , buf_user-login.db-num
                                            , buf_user-login.user-login
                                            )
            .
        end.
        if v-login-string ne "":U
        then
        run onewin_add-item in this-procedure (
              input buf_user-account.user-id
            , input buf_user-account.nik
            , input substitute( "Фамилия, Имя, Отчество:   &2&1Уникальный идентификатор: &4&1Логины:             &5"
                                , chr(10)
                                , trim( substitute( "&1 &2 &3", buf_user-account.last-name, buf_user-account.first-name, buf_user-account.second-name ) )
                                , v-cntxt-db-num
                                , buf_user-account.user-id
                                , v-login-string
                                )
            , input ( buf_user-account.user-id = v-cntxt-userid )
        ).
    end.
    run gbl/onewin.w (
          input parparentproc
        , input p-mode
        , input "Список псевдонимов пользователей"
        , input "":U
        , input "":U
        , input table temp_onewin_items
        , output table temp_onewin_itemsSelected
        , output v-cur-ext-key
        , output p-accepted
    ).
    if p-accepted = yes
    then do:
         if p-mode = 1 then
         do:
            for each temp_onewin_itemsSelected:
               p-new-user-id = substitute("&1,&2",
                                          p-new-user-id,
                                          temp_onewin_itemsSelected.itmExtKey).
            end.
            p-new-user-id = trim(p-new-user-id,",").
         end.
         else
         do:
            p-new-user-id = v-cur-ext-key.
            find first buf_user-account no-lock
                 where buf_user-account.user-id = p-new-user-id
            no-error.
            if available buf_user-account then
               p-new-parent-user-id = buf_user-account.parent-user-id.
         end.
    end.
    else do:
        assign
            p-new-user-id           = "":U
            p-new-parent-user-id    = "":U
        .
    end.
end.
