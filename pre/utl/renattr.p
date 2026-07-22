block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: renattr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/renattr.p $":U .
define variable vss-description as character no-undo init "".
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
define temp-table temp-clients no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary obj-type obj-code
.
define temp-table temp-attr no-undo
  field obj-type   as character
  field obj-code   as integer
  field attr-code  as character
  field attr-value as character
  index xpk is primary unique obj-type obj-code attr-code
.
define temp-table temp-new-attr no-undo
  field obj-type   as character
  field obj-code   as integer
  field attr-code  as character
  field attr-value as character
  index xpk is primary unique obj-type obj-code attr-code
.
define stream sout .
on write of ub.clients-attr override do: end.
on delete of ub.clients-attr override do: end.
do
on error undo, return error return-value
:
  define variable v-ok as logical   no-undo .
  message
    "Переименование атрибутов архивов" skip
    "Эту процедуру следует запустить один раз непосредственно после первой установки" skip
    "обновления версии 12_3 с датой компиляции 1 января 2004 года." skip
    "Данную процедуру обязательно необходимо запустить до первого расчета архивов." skip
    "" skip
    "Продолжить?" skip
    view-as alert-box question buttons yes-no update v-ok .
  if v-ok <> true
  then do:
    return .
  end.
  do transaction
  on error undo, return error return-value
  :
    define variable v-old-attr-list             as character no-undo .
    define variable v-new-attr-list             as character no-undo .
    define variable v-new-find-attr-list        as character no-undo .
    define variable v-num-entries-new-attr-list as integer   no-undo .
    assign
      v-old-attr-list =
                  'cut-date':u
        + ',':u + 'ah-start-date':u
        + ',':u + 'aht-start-date':u
        + ',':u + 'ah-del-crash':u
        + ',':u + 'aht-del-crash':u
        + ',':u + 'arhcalc':u
        + ',':u + 'ahtcalc':u
        + ',':u + 'ahspcalc':u
        + ',':u + 'arh-recalc':u
        + ',':u + 'aht-recalc':u
        + ',':u + 'ahsp-recalc':u
    .
    assign
      v-new-attr-list =
                  'arh-calc':u
        + ',':u + 'arh-del':u
        + ',':u + 'arh-start':u
        + ',':u + 'arh-detail':u
        + ',':u + 'arh-recalc':u
        + ',':u + 'ahsp-calc':u
        + ',':u + 'ahsp-del':u
        + ',':u + 'ahsp-start':u
        + ',':u + 'ahsp-detail':u
        + ',':u + 'ahsp-recalc':u
        + ',':u + 'aht-calc':u
        + ',':u + 'aht-del':u
        + ',':u + 'aht-start':u
        + ',':u + 'aht-detail':u
        + ',':u + 'aht-recalc':u
    .
    assign
      v-new-find-attr-list =
                  'arhcalc':u
        + ',':u + 'ah-del-crash':u
        + ',':u + 'ah-start-date':u
        + ',':u + 'cut-date':u
        + ',':u + 'arh-recalc':u
        + ',':u + 'ahspcalc':u
        + ',':u + 'ah-del-crash':u
        + ',':u + 'ah-start-date':u
        + ',':u + 'cut-date':u
        + ',':u + 'ahsp-recalc':u
        + ',':u + 'ahtcalc':u
        + ',':u + 'aht-del-crash':u
        + ',':u + 'aht-start-date':u
        + ',':u + 'aht-start-date':u
        + ',':u + 'aht-recalc':u
    .
    define buffer buf_db            for ub.db .
    define buffer buf_clients       for ub.clients .
    define buffer buf_clients-attr  for ub.clients-attr .
    define buffer buf_temp-clients  for temp-clients .
    define buffer buf_temp-attr     for temp-attr .
    define buffer buf_temp-new-attr for temp-new-attr .
    for each buf_db no-lock
    on error undo, return error return-value
    :
      for each buf_clients no-lock
        where buf_clients.db-num = buf_db.db-num
      on error undo, return error return-value
      :
        create buf_temp-clients .
        assign
          buf_temp-clients.obj-type = buf_clients.obj-type
          buf_temp-clients.obj-code = buf_clients.obj-code
        .
        for each buf_clients-attr no-lock
          where buf_clients-attr.obj-type = buf_clients.obj-type
            and buf_clients-attr.obj-code = buf_clients.obj-code
        on error undo, return error return-value
        :
          if lookup(buf_clients-attr.attr-code, v-old-attr-list) > 0
          then do:
            create buf_temp-attr .
            assign
              buf_temp-attr.obj-type   = buf_clients-attr.obj-type
              buf_temp-attr.obj-code   = buf_clients-attr.obj-code
              buf_temp-attr.attr-code  = buf_clients-attr.attr-code
              buf_temp-attr.attr-value = buf_clients-attr.attr-value
            .
          end.
        end.
      end.
    end.
    for each buf_temp-clients
    :
      assign
        v-num-entries-new-attr-list = num-entries(v-new-attr-list)
      .
      define variable v-ind           as integer   no-undo .
      define variable v-new-attr-code as character no-undo .
      define variable v-old-attr-code as character no-undo .
      do v-ind = 1 to v-num-entries-new-attr-list
      :
        assign
          v-new-attr-code = entry(v-ind,v-new-attr-list)
          v-old-attr-code = entry(v-ind,v-new-find-attr-list)
        .
        find first buf_temp-attr
          where buf_temp-attr.obj-type  = buf_temp-clients.obj-type
            and buf_temp-attr.obj-code  = buf_temp-clients.obj-code
            and buf_temp-attr.attr-code = v-old-attr-code
          no-error .
        if available buf_temp-attr
        then do:
          create buf_temp-new-attr .
          assign
            buf_temp-new-attr.obj-type   = buf_temp-attr.obj-type
            buf_temp-new-attr.obj-code   = buf_temp-attr.obj-code
            buf_temp-new-attr.attr-code  = v-new-attr-code
            buf_temp-new-attr.attr-value = buf_temp-attr.attr-value
          .
        end.
        else do:
          if v-old-attr-code = 'ah-start-date':u
          then do:
            find first buf_temp-attr
              where buf_temp-attr.obj-type  = buf_temp-clients.obj-type
                and buf_temp-attr.obj-code  = buf_temp-clients.obj-code
                and buf_temp-attr.attr-code = 'cut-date':u
              no-error .
            if available buf_temp-attr
            then do:
              create buf_temp-new-attr .
              assign
                buf_temp-new-attr.obj-type   = buf_temp-attr.obj-type
                buf_temp-new-attr.obj-code   = buf_temp-attr.obj-code
                buf_temp-new-attr.attr-code  = v-new-attr-code
                buf_temp-new-attr.attr-value = buf_temp-attr.attr-value
              .
            end.
          end.
        end.
      end.
    end.
    output stream sout to renattr.txt .
    export stream sout 'rename_archive_attributes':u string(today, '99/99/9999':U) string(time, 'HH:MM:SS':U) .
    export stream sout 'old_attr_delete':u .
    for each buf_temp-attr
    on error undo, return error return-value
    :
      export stream sout buf_temp-attr .
    end.
    export stream sout 'new_attr_create':u .
    for each buf_temp-new-attr
    on error undo, return error return-value
    :
      export stream sout buf_temp-new-attr .
    end.
    output stream sout close .
    for each buf_temp-attr
    on error undo, return error return-value
    :
      find first buf_clients-attr exclusive-lock
        where buf_clients-attr.obj-type = buf_temp-attr.obj-type
          and buf_clients-attr.obj-code = buf_temp-attr.obj-code
          and buf_clients-attr.attr-code = buf_temp-attr.attr-code
          and buf_clients-attr.attr-value = buf_temp-attr.attr-value
        no-error .
      if not available buf_clients-attr
      then do:
        undo, return error "Ошибка при удалении записи атрибут клиента" .
      end.
      delete buf_clients-attr .
    end.
    for each buf_temp-new-attr
    on error undo, return error return-value
    :
      find first buf_clients-attr exclusive-lock
        where buf_clients-attr.obj-type = buf_temp-new-attr.obj-type
          and buf_clients-attr.obj-code = buf_temp-new-attr.obj-code
          and buf_clients-attr.attr-code = buf_temp-new-attr.attr-code
          and buf_clients-attr.attr-value = buf_temp-new-attr.attr-value
        no-error .
      if available buf_clients-attr
      then do:
        undo, return error "Ошибка при создании записи атрибут клиента" .
      end.
      create buf_clients-attr .
      assign
        buf_clients-attr.obj-type   = buf_temp-new-attr.obj-type
        buf_clients-attr.obj-code   = buf_temp-new-attr.obj-code
        buf_clients-attr.attr-code  = buf_temp-new-attr.attr-code
        buf_clients-attr.attr-value = buf_temp-new-attr.attr-value
      .
    end.
  end.
  message
    "Переименование атрибутов успешно завершено" skip
    "Сохраните файл renattr.txt" skip
    view-as alert-box information .
end.
