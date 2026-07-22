block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: usrldr15.p $
$Archive: utl/usrldr15.p $

Перенос информации о доступных объектах из таблиц usr-grpo, usr-grpa в таблицы user-host, user-obj

Автор: Перваков Михаил Сергеевич
Дата создания: 04/20/06
Author: Mikhail Pervakov
Creation date: 04/20/06

Перенос информации о группах прав и правах в таблицы action-role, action-role-item
user-login-action-role

*/

define input parameter p-install as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usrldr15.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/usrldr15.p $":U .
define variable vss-description as character no-undo init "Перенос информации о доступных объектах из таблиц usr-grpo, usr-grpa в таблицы user-host, user-obj".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }


define variable v-ok            as logical   no-undo .
define variable v-ind           as integer   no-undo .
define variable v-err-count     as integer   no-undo .
define variable v-db-num        as integer   no-undo .
define variable v-arm-code-list as character no-undo .
define variable v-obj-name      as character no-undo .
define variable v-user-menu-group-code      as integer   no-undo .
define variable v-filename           as character no-undo .

define temp-table temp-action-item no-undo
  field grp-acta-arm-code  as character
  field grp-acta-object    as character
  field grp-acta-act       as character
  field action-item-id     as character
  field action-context     as character

  index xpk is primary unique grp-acta-arm-code grp-acta-object grp-acta-act
  index ie1 action-item-id
  index ie2 action-context
  .

define temp-table temp-usr-grpa no-undo
   field user-name      as character
   field arm-code       as character
   field grp-name       as character format "X(20)"
   field host-code      as integer

   index pu is primary unique
         user-name
         host-code
         arm-code
.
define temp-table temp-usr-grpo no-undo
   field user-name      as character
   field obj-type       as character
   field obj-code       as integer
   field grp-name       as character format "X(20)"

   index pu is primary unique
         user-name
         obj-type
         obj-code
.
define temp-table temp-grpa no-undo
   field grp-name       as character format "X(20)"
   field arm-code       as character

   index pu is primary unique
         arm-code
         grp-name
.
define temp-table temp-grp-acta no-undo
   field grp-name       as character format "X(20)"
   field arm-code       as character
   field object         as character format "X(15)"
   field act            as character format "X(25)"

   index pu is primary unique
         grp-name
         arm-code
         object
         act
.

define buffer buf_user-login             for ub.user-login .
define buffer buf_user-host              for ub.user-host .
define buffer buf_user-obj               for ub.user-obj .
define buffer buf_clients                for ub.clients .
define buffer buf_action-head            for ub.action-head .
define buffer buf_action-role            for ub.action-role .
define buffer buf_action-role-item       for ub.action-role-item .
define buffer buf_user-login-action-role for ub.user-login-action-role .
define buffer buf_user-menu-group        for ub.user-menu-group .
define buffer buf_temp-action-item       for temp-action-item .

define buffer buf_grpa     for temp-grpa .
define buffer buf_usr-grpa for temp-usr-grpa .
define buffer buf_usr-grpo for temp-usr-grpo .
define buffer buf_grp-acta for temp-grp-acta .


on write of ub.user-host              override do: end.
on write of ub.user-obj               override do: end.
on write of ub.action-head            override do: end.
on write of ub.action-role            override do: end.
on write of ub.action-head            override do: end.
on write of ub.action-role            override do: end.
on write of ub.action-role-item       override do: end.
on write of ub.user-login-action-role override do: end.
on write of ub.user-menu-group        override do: end.

define stream sinp .
define stream sout .

do
on error undo, return error return-value
:
  if p-install = false
  then do:
    message
      vss-description skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return . /* --->>>--- */
    end.
  end.

  if "{&language}" = "rus":U
  then do:
    assign
      v-arm-code-list = 'офи':U
                      + {&comma-char} + 'скл':U
                      + {&comma-char} + 'маг':U
                      + {&comma-char} + 'рес':U
                      + {&comma-char} + 'фин':U
                      + {&comma-char} + 'бгх':U
                      + {&comma-char} + 'бух':U
                      + {&comma-char} + 'осн':U
                      + {&comma-char} + 'адм':U
      v-obj-name      = 'объ':U
    .
  end.
  else do:
    assign
      v-arm-code-list = 'off':U
                      + {&comma-char} + 'str':U
                      + {&comma-char} + 'shp':U
                      + {&comma-char} + 'res':U
                      + {&comma-char} + 'fin':U
                      + {&comma-char} + 'eac':U
                      + {&comma-char} + 'acc':U
                      + {&comma-char} + 'fas':U
                      + {&comma-char} + 'adm':U
      v-obj-name      = 'object':U
    .
  end.

  run fill-temp-table in this-procedure .

  assign
    v-db-num = v-cntxt-db-num
  .

  /* load buf_usr-grpa */
  assign
     v-filename = search('usr-grpa.142':U)
  .
  if v-filename = ?
  or v-filename = '':U
  then do:
    undo, return error substitute("Не найден файл с правами пользователей &1"
                                 ,'usr-gpra.142':U
                                 ) .
  end.
    for each buf_usr-grpa
    on error undo, return error return-value
    :
      delete buf_usr-grpa .
    end.

  input stream sinp from value(v-filename) .
  repeat
  :
    create buf_usr-grpa .
    import stream sinp buf_usr-grpa .
  end.
  input stream sinp close .

  /* load buf_usr-grpo */
  assign
     v-filename = search('usr-grpo.142':U)
  .
  if v-filename = ?
  or v-filename = '':U
  then do:
    undo, return error substitute("Не найден файл с правами пользователей &1"
                                 ,'usr-grpo.142':U
                                 ) .
  end.
    for each buf_usr-grpo
    on error undo, return error return-value
    :
      delete buf_usr-grpo .
    end.

  input stream sinp from value(v-filename) .
  repeat
  :
    create buf_usr-grpo .
    import stream sinp buf_usr-grpo .
  end.
  input stream sinp close .

  /* load buf_grpa */
  assign
     v-filename = search('grpa.142':U)
  .
  if v-filename = ?
  or v-filename = '':U
  then do:
    undo, return error substitute("Не найден файл с правами пользователей &1"
                                 ,'grpa.142':U
                                 ) .
  end.
    for each buf_grpa
    on error undo, return error return-value
    :
      delete buf_grpa .
    end.

  input stream sinp from value(v-filename) .
  repeat
  :
    create buf_grpa .
    import stream sinp buf_grpa .
  end.
  input stream sinp close .

  /* load buf_grp-acta */
  assign
     v-filename = search('grp-acta.142':U)
  .
  if v-filename = ?
  or v-filename = '':U
  then do:
    undo, return error substitute("Не найден файл с правами пользователей &1"
                                 ,'grp-acta.142':U
                                 ) .
  end.
    for each buf_grp-acta
    on error undo, return error return-value
    :
      delete buf_grp-acta .
    end.

  input stream sinp from value(v-filename) .
  repeat
  :
    create buf_grp-acta .
    import stream sinp buf_grp-acta .
  end.
  input stream sinp close .



  for each buf_user-login no-lock
    where buf_user-login.db-num = v-db-num
  on error undo, return error return-value
  :
    assign
      v-ind = v-ind + 1
    .

    for each buf_usr-grpa no-lock
      where buf_usr-grpa.user-name = buf_user-login.user-login
    on error undo, return error return-value
    :
      find first buf_user-menu-group
        where buf_user-menu-group.db-num          = v-db-num
          and buf_user-menu-group.user-id         = buf_user-login.user-id
          and buf_user-menu-group.menu-code       = {&menu-code-main}
          and buf_user-menu-group.menu-group-id = buf_usr-grpa.arm-code
          and buf_user-menu-group.menu-group-context         = {&cntxt-firm}
          and buf_user-menu-group.host-code       = buf_usr-grpa.host-code
        no-error .
      if not available buf_user-menu-group then do:
         ASSIGN
            v-user-menu-group-code = next-value(s-user-menu-group)
         .
         create buf_user-menu-group.
         assign
            buf_user-menu-group.db-num        = v-db-num
            buf_user-menu-group.user-id       = buf_user-login.user-id
            buf_user-menu-group.menu-code     = {&menu-code-main}
            buf_user-menu-group.menu-group-id = buf_usr-grpa.arm-code
            buf_user-menu-group.menu-group-context       = {&cntxt-firm}
            buf_user-menu-group.user-menu-group-code      = v-user-menu-group-code
            buf_user-menu-group.host-code     = buf_usr-grpa.host-code
            buf_user-menu-group.obj-type      = "":U
            buf_user-menu-group.obj-code      = 0
         .
      end.

      find first buf_user-host
        where buf_user-host.db-num    = v-db-num
          and buf_user-host.user-id   = buf_user-login.user-id
          and buf_user-host.host-code = buf_usr-grpa.host-code
        no-error .
      if not available buf_user-host
      then do:
        create buf_user-host .
        assign
          buf_user-host.db-num    = v-db-num
          buf_user-host.user-id   = buf_user-login.user-id
          buf_user-host.host-code = buf_usr-grpa.host-code
        .
      end.
    end.

    for each buf_usr-grpo no-lock
      where buf_usr-grpo.user-name = buf_user-login.user-login
    on error undo, return error return-value
    :
      find first buf_user-obj
        where buf_user-obj.db-num    = v-db-num
          and buf_user-obj.user-id   = buf_user-login.user-id
          and buf_user-obj.obj-type  = buf_usr-grpo.obj-type
          and buf_user-obj.obj-code  = buf_usr-grpo.obj-code
        no-error .
      if not available buf_user-obj
      then do:
        find first buf_clients no-lock
          where buf_clients.obj-type = buf_usr-grpo.obj-type
            and buf_clients.obj-code = buf_usr-grpo.obj-code
          no-error .
        if not available buf_clients
        then do:
          assign
            v-err-count = v-err-count + 1
          .

          output stream sout to value('06012350.err':U) append .
          export stream sout buf_usr-grpo .
          output stream sout close .
        end.
        else do:
          create buf_user-obj .
          assign
            buf_user-obj.db-num    = v-db-num
            buf_user-obj.user-id   = buf_user-login.user-id
            buf_user-obj.obj-type  = buf_usr-grpo.obj-type
            buf_user-obj.obj-code  = buf_usr-grpo.obj-code
            buf_user-obj.host-code = buf_clients.host-code
          .
        end.
      end.
    end.
  end.

  create buf_action-head .
  assign
    buf_action-head.action-head-code           = {&action-head-code-main}
    buf_action-head.action-head-name           = "Система прав IBS Trade House"
    buf_action-head.action-head-control-number = ""
  .

  define variable v-action-role-code      as integer   no-undo .
  define variable v-action-role-item-code as integer   no-undo .
  define variable v-user-login-role-code  as integer   no-undo .

  assign
    v-action-role-code      = 0
    v-action-role-item-code = 0
    v-user-login-role-code  = 0
  .

  define variable v-global-action-role-code as integer   no-undo .
  define variable v-firm-action-role-code   as integer   no-undo .
  define variable v-object-action-role-code as integer   no-undo .

  for each buf_grpa no-lock
  on error undo, return error return-value
  :

    assign
      v-global-action-role-code = 0
      v-firm-action-role-code   = 0
      v-object-action-role-code = 0
    .

    for each buf_grp-acta no-lock
      where buf_grp-acta.grp-name = buf_grpa.grp-name
        and buf_grp-acta.arm-code = buf_grpa.arm-code
    on error undo, return error return-value
    :
      find first buf_temp-action-item
        where buf_temp-action-item.grp-acta-arm-code = buf_grp-acta.arm-code
          and buf_temp-action-item.grp-acta-object   = buf_grp-acta.object
          and buf_temp-action-item.grp-acta-act      = buf_grp-acta.act
        no-error .
      if not available buf_temp-action-item
      then do:
        output stream sout to value('06012351.err':U) append .
        export stream sout "unknown_action" buf_grp-acta.arm-code buf_grp-acta.object buf_grp-acta.act .
        export stream sout "grp-acta" .
        export stream sout buf_grp-acta .
        output stream sout close .
      end.
      else do:
        case buf_temp-action-item.action-context
        :
          when {&right-type-global}
          then do:
            if v-global-action-role-code = 0
            then do:
              assign
                v-action-role-code = NEXT-VALUE(s-action-role)
              .
              create buf_action-role .
              assign
                buf_action-role.db-num              = v-db-num
                buf_action-role.action-head-code    = {&action-head-code-main}
                buf_action-role.action-role-code    = v-action-role-code
                buf_action-role.action-role-context = buf_temp-action-item.action-context
                buf_action-role.action-role-name    = buf_grpa.arm-code + ' ':U + buf_grpa.grp-name
              .
              assign
                v-global-action-role-code = v-action-role-code
              .
            end.

            assign
              v-action-role-item-code = NEXT-VALUE(s-action-role-item)
            .
            create buf_action-role-item .
            assign
              buf_action-role-item.db-num                = v-db-num
              buf_action-role-item.action-head-code      = {&action-head-code-main}
              buf_action-role-item.action-role-code      = v-global-action-role-code
              buf_action-role-item.action-role-item-code = v-action-role-item-code
              buf_action-role-item.action-item-id        = buf_temp-action-item.action-item-id
            .
          end.
          when {&right-type-firm}
          then do:
            if v-firm-action-role-code = 0
            then do:
              assign
                v-action-role-code = NEXT-VALUE(s-action-role)
              .
              create buf_action-role .
              assign
                buf_action-role.db-num              = v-db-num
                buf_action-role.action-head-code    = {&action-head-code-main}
                buf_action-role.action-role-code    = v-action-role-code
                buf_action-role.action-role-context = buf_temp-action-item.action-context
                buf_action-role.action-role-name    = buf_grpa.arm-code + ' ':U + buf_grpa.grp-name
              .
              assign
                v-firm-action-role-code = v-action-role-code
              .
            end.

            assign
              v-action-role-item-code = NEXT-VALUE(s-action-role-item)
            .
            create buf_action-role-item .
            assign
              buf_action-role-item.db-num                = v-db-num
              buf_action-role-item.action-head-code      = {&action-head-code-main}
              buf_action-role-item.action-role-code      = v-firm-action-role-code
              buf_action-role-item.action-role-item-code = v-action-role-item-code
              buf_action-role-item.action-item-id        = buf_temp-action-item.action-item-id
            .
          end.
          when {&right-type-object}
          then do:
            if v-object-action-role-code = 0
            then do:
              assign
                v-action-role-code = NEXT-VALUE(s-action-role)
              .
              create buf_action-role .
              assign
                buf_action-role.db-num              = v-db-num
                buf_action-role.action-head-code    = {&action-head-code-main}
                buf_action-role.action-role-code    = v-action-role-code
                buf_action-role.action-role-context = buf_temp-action-item.action-context
                buf_action-role.action-role-name    = buf_grpa.arm-code + ' ':U + buf_grpa.grp-name
              .
              assign
                v-object-action-role-code = v-action-role-code
              .
            end.

            assign
              v-action-role-item-code = NEXT-VALUE(s-action-role-item)
            .
            create buf_action-role-item .
            assign
              buf_action-role-item.db-num                = v-db-num
              buf_action-role-item.action-head-code      = {&action-head-code-main}
              buf_action-role-item.action-role-code      = v-object-action-role-code
              buf_action-role-item.action-role-item-code = v-action-role-item-code
              buf_action-role-item.action-item-id        = buf_temp-action-item.action-item-id
            .
          end.
          otherwise do:
            output stream sout to value('06012351.err':U) append .
            export stream sout "unknown_action-context" buf_temp-action-item.action-context .
            export stream sout "temp-action-item.action-context" .
            export stream sout buf_temp-action-item .
            output stream sout close .
          end.
        end.
      end.
    end.

    if buf_grpa.arm-code = v-obj-name
    then do:
      for each buf_usr-grpo no-lock
        where buf_usr-grpo.grp-name = buf_grpa.grp-name
      on error undo, return error return-value
      :
        find first buf_user-login no-lock
          where buf_user-login.db-num     = v-db-num
            and buf_user-login.user-login = buf_usr-grpo.user-name
          no-error .
        if not available buf_user-login
        then do:
          output stream sout to value('06012351.err':U) append .
          export stream sout "unknown_user-name" buf_usr-grpo.user-name .
          export stream sout "usr-grpo" .
          export stream sout buf_usr-grpo .
          output stream sout close .
        end.
        else do:
          find first buf_clients no-lock
            where buf_clients.obj-type = buf_usr-grpo.obj-type
              and buf_clients.obj-code = buf_usr-grpo.obj-code
            no-error .
          if not available buf_clients
          then do:
            output stream sout to value('06012351.err':U) append .
            export stream sout "unknown_obj-type_obj-code" buf_usr-grpo.obj-type buf_usr-grpo.obj-code .
            export stream sout "usr-grpo" .
            export stream sout buf_usr-grpo .
            output stream sout close .
          end.
          else do:
            if v-global-action-role-code <> 0
            then do:
              assign
                v-user-login-role-code = NEXT-VALUE(s-user-login-action-role)
              .
              create buf_user-login-action-role .
              assign
                buf_user-login-action-role.db-num               = v-db-num
                buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                buf_user-login-action-role.user-id              = buf_user-login.user-id
                buf_user-login-action-role.action-role-code     = v-global-action-role-code
                buf_user-login-action-role.action-role-context  = {&right-type-global}
                buf_user-login-action-role.host-code            = 0
                buf_user-login-action-role.obj-type             = '':U
                buf_user-login-action-role.obj-code             = 0
                buf_user-login-action-role.gds-grp-code         = ?
                buf_user-login-action-role.gds-code             = ?
                buf_user-login-action-role.cli-grp-code         = ?
              .
            end.

            if v-firm-action-role-code <> 0
            then do:
              assign
                v-user-login-role-code = NEXT-VALUE(s-user-login-action-role)
              .
              create buf_user-login-action-role .
              assign
                buf_user-login-action-role.db-num               = v-db-num
                buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                buf_user-login-action-role.user-id              = buf_user-login.user-id
                buf_user-login-action-role.action-role-code     = v-firm-action-role-code
                buf_user-login-action-role.action-role-context  = {&right-type-firm}
                buf_user-login-action-role.host-code            = buf_clients.host-code
                buf_user-login-action-role.obj-type             = '':U
                buf_user-login-action-role.obj-code             = 0
                buf_user-login-action-role.gds-grp-code         = ?
                buf_user-login-action-role.gds-code             = ?
                buf_user-login-action-role.cli-grp-code         = ?
              .
            end.

            if v-object-action-role-code <> 0
            then do:
              assign
                v-user-login-role-code = NEXT-VALUE(s-user-login-action-role)
              .
              create buf_user-login-action-role .
              assign
                buf_user-login-action-role.db-num               = v-db-num
                buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                buf_user-login-action-role.user-id              = buf_user-login.user-id
                buf_user-login-action-role.action-role-code     = v-object-action-role-code
                buf_user-login-action-role.action-role-context  = {&right-type-object}
                buf_user-login-action-role.host-code            = buf_clients.host-code
                buf_user-login-action-role.obj-type             = buf_clients.obj-type
                buf_user-login-action-role.obj-code             = buf_clients.obj-code
                buf_user-login-action-role.gds-grp-code         = ?
                buf_user-login-action-role.gds-code             = ?
                buf_user-login-action-role.cli-grp-code         = ?
              .
            end.
          end.
        end.

      end.
    end.
    else do:
      for each buf_usr-grpa no-lock
        where buf_usr-grpa.grp-name = buf_grpa.grp-name
          and buf_usr-grpa.arm-code = buf_grpa.arm-code
      on error undo, return error return-value
      :
        find first buf_user-login no-lock
          where buf_user-login.db-num     = v-db-num
            and buf_user-login.user-login = buf_usr-grpa.user-name
          no-error .
        if not available buf_user-login
        then do:
          output stream sout to value('06012351.err':U) append .
          export stream sout "unknown_user-name" buf_usr-grpa.user-name .
          export stream sout "usr-grpa" .
          export stream sout buf_usr-grpa .
          output stream sout close .
        end.
        else do:
          find first buf_clients no-lock
            where buf_clients.obj-type = {&cmp}
              and buf_clients.obj-code = buf_usr-grpa.host-code
            no-error .
          if not available buf_clients
          then do:
            output stream sout to value('06012351.err':U) append .
            export stream sout "unknown_host-code" buf_usr-grpa.host-code .
            export stream sout "usr-grpa" .
            export stream sout buf_usr-grpa .
            output stream sout close .
          end.
          else do:
            if v-global-action-role-code <> 0
            then do:

              assign
                v-user-login-role-code = NEXT-VALUE(s-user-login-action-role)
              .
              create buf_user-login-action-role .
              assign
                buf_user-login-action-role.db-num               = v-db-num
                buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                buf_user-login-action-role.user-id              = buf_user-login.user-id
                buf_user-login-action-role.action-role-code     = v-global-action-role-code
                buf_user-login-action-role.action-role-context  = {&right-type-global}
                buf_user-login-action-role.host-code            = 0
                buf_user-login-action-role.obj-type             = '':U
                buf_user-login-action-role.obj-code             = 0
                buf_user-login-action-role.gds-grp-code         = ?
                buf_user-login-action-role.gds-code             = ?
                buf_user-login-action-role.cli-grp-code         = ?
              .
            end.
            if v-firm-action-role-code <> 0
            then do:
              assign
                v-user-login-role-code = NEXT-VALUE(s-user-login-action-role)
              .
              create buf_user-login-action-role .
              assign
                buf_user-login-action-role.db-num               = v-db-num
                buf_user-login-action-role.action-head-code     = {&action-head-code-main}
                buf_user-login-action-role.user-login-role-code = v-user-login-role-code
                buf_user-login-action-role.user-id              = buf_user-login.user-id
                buf_user-login-action-role.action-role-code     = v-firm-action-role-code
                buf_user-login-action-role.action-role-context  = {&right-type-firm}
                buf_user-login-action-role.host-code            = buf_clients.obj-code
                buf_user-login-action-role.obj-type             = '':U
                buf_user-login-action-role.obj-code             = 0
                buf_user-login-action-role.gds-grp-code         = ?
                buf_user-login-action-role.gds-code             = ?
                buf_user-login-action-role.cli-grp-code         = ?
              .
            end.
          end.
        end.
      end.
    end.
  end.

  return substitute("Обработано записей &1. Ошибок &2"
                   ,v-ind
                   ,v-err-count
                   ) .
end.


procedure fill-temp-table :

  define variable v-grp-acta-arm-code  as character no-undo .
  define variable v-grp-acta-object    as character no-undo .
  define variable v-grp-acta-act       as character no-undo .
  define variable v-action-item-id     as character no-undo .
  define variable v-action-context     as character no-undo .

  define buffer buf_temp-action-item for temp-action-item .

  do
  on error undo, return error return-value
  :
    input stream sinp from value('right142.txt':U).

    repeat
    :
      assign
        v-grp-acta-arm-code  = '':U
        v-grp-acta-object    = '':U
        v-grp-acta-act       = '':U
        v-action-item-id     = '':U
        v-action-context     = '':U
      .

      import stream sinp
        v-grp-acta-arm-code
        v-grp-acta-object
        v-grp-acta-act
        v-action-item-id
        v-action-context
        .

      create buf_temp-action-item .
      assign
        buf_temp-action-item.grp-acta-arm-code  = v-grp-acta-arm-code
        buf_temp-action-item.grp-acta-object    = v-grp-acta-object
        buf_temp-action-item.grp-acta-act       = v-grp-acta-act
        buf_temp-action-item.action-item-id     = v-action-item-id
        buf_temp-action-item.action-context     = v-action-context
      .
    end.

    input stream sinp close .

  end.

end procedure. /* fill-temp-table */