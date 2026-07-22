block-level on error undo, throw.
define input parameter p-mode                   as character        no-undo.
define input parameter p-db-num                 as integer          no-undo.
define input parameter p-user-id-in             as character        no-undo.
define input parameter p-last-name              as character        no-undo.
define input parameter p-first-name             as character        no-undo.
define input parameter p-second-name            as character        no-undo.
define input parameter p-nik                    as character        no-undo.
define input parameter p-phone-number           as character        no-undo.
define input parameter p-mobile-phone-number    as character        no-undo.
define input parameter p-company                as character        no-undo.
define input parameter p-department             as character        no-undo.
define input parameter p-position               as character        no-undo.
define input parameter p-room                   as character        no-undo.
define input parameter p-e-mail                 as character        no-undo.
define input parameter p-internal-phone-number  as character        no-undo.
define input parameter p-PS                     as character        no-undo.
define input parameter p-psn-code               as integer          no-undo.
define input parameter i-superadm               as logical          no-undo.
define output parameter p-user-id-out           as character        no-undo.
define variable vss-revision    as character no-undo init "$Revision: 9a33157616be, 3491, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usracc01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usracc01.p $":U .
define variable vss-description as character no-undo init "Создание или редактирование записи user-acccount".
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
define variable v-next-user-id as character no-undo .
define buffer buf_user-account for ub.user-account .
define buffer buf_user-account-attr for ub.user-account-attr .
do
on error undo, return error return-value
:
    case p-mode
    :
        when 'ДОБАВЛЕНИЕ':U
        then do:
            assign
                v-next-user-id  = substitute( "&1-&2":U
                                        , p-db-num
                                        , next-value( s-user-id ) )
            .
            find first buf_user-account exclusive-lock
                 where buf_user-account.user-id = v-next-user-id
            no-error.
            if available buf_user-account
            then do:
                undo, return error substitute( "Ошибка при создании пользователя (user-account).&1Попытка создания записи с существующим кодом.&1.Код записи: &2"
                                                    , chr(10)
                                                    , v-next-user-id  ).
            end.
            create buf_user-account .
            assign
                buf_user-account.user-id               = v-next-user-id
                buf_user-account.status_               = 0
            .
            assign
                p-user-id-out   = v-next-user-id
            .
        end.
        when 'ИЗМЕНЕНИЕ':U
        then do:
            assign
                p-user-id-out   = p-user-id-in
            .
            find first buf_user-account exclusive-lock
                 where buf_user-account.user-id = p-user-id-in
            no-error.
            if not available buf_user-account
            then do:
                undo, return error substitute( "Ошибка при создании пользователя (user-account).&1Не найдена запись для изменения.&1.Код записи: &2"
                                                    , chr(10)
                                                    , p-user-id-in  ).
            end.
        end.
        otherwise do:
        undo, return error substitute( "Ошибка неизвестный режим &1"
                                                    , p-mode  ).
        end.
    end case.
    assign
       buf_user-account.last-name             = p-last-name
       buf_user-account.first-name            = p-first-name
       buf_user-account.second-name           = p-second-name
       buf_user-account.nik                   = p-nik
       buf_user-account.phone-number          = p-phone-number
       buf_user-account.mobile-phone-number   = p-mobile-phone-number
       buf_user-account.company               = p-company
       buf_user-account.department            = p-department
       buf_user-account.position              = p-position
       buf_user-account.room                  = p-room
       buf_user-account.e-mail                = p-e-mail
       buf_user-account.psn-code              = p-psn-code
       buf_user-account.internal-phone-number = p-internal-phone-number
       buf_user-account.PS                    = p-PS
    .
    release buf_user-account.
    find first buf_user-account-attr exclusive-lock
         where buf_user-account-attr.user-id = p-user-id-out
           and buf_user-account-attr.attr-code = "psn-code"
    no-error.
    if not available buf_user-account-attr
    then do :
       create buf_user-account-attr .
       assign
          buf_user-account-attr.user-id = p-user-id-out
          buf_user-account-attr.attr-code = "psn-code"
       .
    end .
    assign
       buf_user-account-attr.attr-value = string(p-psn-code)
    .
    release buf_user-account-attr.
    find first user-account-attr where user-account-attr.user-id    eq p-user-id-out
                                   and user-account-attr.attr-code  eq "superadm"
    no-lock no-error.
    if i-superadm
    then do:
       if not available user-account-attr
       then do:
          create user-account-attr.
          assign
             user-account-attr.user-id    = p-user-id-out
             user-account-attr.attr-code = "superadm"
          .
       end.
       else find current user-account-attr exclusive-lock.
       if not available user-account-attr
       then
          undo, return error substitute( "Ошибка изменения учетной записи попробуйте позже" ).
       user-account-attr.attr-value = "yes".
       release buf_user-account-attr.
    end.
    else if     not i-superadm
            and available user-account-attr
    then do:
       find current user-account-attr exclusive-lock no-error.
       if available user-account-attr
       then
          delete user-account-attr.
    end.
end.
