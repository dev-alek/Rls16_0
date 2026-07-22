define input parameter parparentproc as widget-handle no-undo .
define input parameter p-from-version as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Экспорт-импорт локальных таблиц УБД из старой версии TH - запуск" .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thth150-db-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth150-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth150-db-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth150-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth150-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth150-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth150-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth150-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth150-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth150-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth150-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth150-db-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure thth150-db-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.
end procedure.
procedure thth150-db-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure thth150-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth150-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure thth150-db-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'thth150-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth150-clients':U then do:     assign     p-news = no.   end.
            when 'thth150-goods':U then do:     assign     p-news = no.   end.
            when 'thth150-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth150-shop':U then do:     assign     p-news = no.   end.
            when 'thth150-contract':U then do:     assign     p-news = no.   end.
            when 'thth150-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth150-trn-doc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thth14-db-attr-code :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-type           as character no-undo .
    define output parameter p-format         as character no-undo .
    define output parameter p-label          as character no-undo .
    define output parameter p-user-can-edit  as logical   no-undo .
    define output parameter p-output-display as logical   no-undo .
    define output parameter p-other          as character no-undo .
    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-gds-grp':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие групп товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-clients':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие клиентов"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-goods':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие товаров"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-dis-card':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ ДК"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-label = "Ожидаемое кол-во ДК"     p-type = 'I':U      p-format = "999,999,999"     p-label = "Ожидаемое кол-во ДК"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-shop':U then do:     assign     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-type = 'L':U      p-format = "+/-"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-contract':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-price-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ переоценки"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
            when 'thth14-trn-doc':U then do:     assign     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-type = 'L':U      p-format = "+/-"     p-label = "ИМПОРТИРОВАНЫ приходные накладные"     p-user-can-edit  = false     p-output-display = true     p-other = '':u      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth14-db-attr-tooltip :
  do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп клиентов" .   end.
            when 'thth14-gds-grp':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие групп товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие групп товаров" .   end.
            when 'thth14-clients':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие клиентов для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие клиентов" .   end.
            when 'thth14-goods':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие товаров для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие товаров" .   end.
            when 'thth14-dis-card':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ ДК"     p-label = "ИМПОРТИРОВАНЫ ДК" .   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-tooltip = "Ожидаемое кол-во ДК"     p-label = "Ожидаемое кол-во ДК" .   end.
            when 'thth14-shop':U then do:     assign     p-tooltip = "УСТАНОВЛЕНО соответствие объeктов TH для двух систем IBS TH"     p-label = "УСТАНОВЛЕНО соответствие объeктов TH" .   end.
            when 'thth14-contract':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ договора и спецификации для двух систем IBS TH"     p-label = "ИМПОРТИРОВАНЫ договора и спецификации" .   end.
            when 'thth14-price-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ переоценки"     p-label = "ИМПОРТИРОВАНЫ переоценки" .   end.
            when 'thth14-trn-doc':U then do:     assign     p-tooltip = "ИМПОРТИРОВАНЫ приходные накладные"     p-label = "ИМПОРТИРОВАНЫ приходные накладные" .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure thth14-db-attr-value :
  do
  on error undo, return error
  :
    define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-value     like ub.db-attr.attr-value no-undo .
    define output parameter p-type      as character no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if avail buf_db-attr then do:
      assign
        p-value =  buf_db-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure thth14-db-attr-write :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define input parameter p-value     like ub.db-attr.attr-value no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if not available buf_db-attr then do:
      create buf_db-attr .
      assign
        buf_db-attr.db-num    = p-db-num
        buf_db-attr.attr-code = p-code
      .
    end.
    assign
      buf_db-attr.attr-value = p-value
    .
  end.
end procedure.
procedure thth14-db-attr-exist :
  do
  on error undo, return error
  :
    define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
    define input parameter p-code      like ub.db-attr.attr-code  no-undo .
    define output parameter p-exist    as logical  no-undo .
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr no-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error .
    if  available buf_db-attr then do:
      p-exist = yes.
    end.
  end.
end procedure.
procedure thth14-db-attr-delete :
  do
  on error undo, return error
  :
    define input parameter p-db-num   like ub.db-attr.db-num     no-undo .
    define input parameter p-code     like ub.db-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo.
    define buffer buf_db-attr for ub.db-attr .
    define variable v-type           as character no-undo .
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    run thth14-db-attr-code in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_db-attr exclusive-lock
      where buf_db-attr.db-num    = p-db-num
        and buf_db-attr.attr-code = p-code
      no-error NO-WAIT.
    if not available buf_db-attr then do:
      p-deleted = no.
    end.
    else do:
      delete buf_db-attr.
      p-deleted = yes.
    end.
  end.
end procedure.
procedure thth14-db-attr-news :
  do
  on error undo, return error
  :
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
            when 'thth14-cli-grp':U then do:     assign     p-news = no.   end.
            when 'thth14-gds-grp':U then do:     assign     p-news = no.   end.
            when 'thth14-clients':U then do:     assign     p-news = no.   end.
            when 'thth14-goods':U then do:     assign     p-news = no.   end.
            when 'thth14-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth14-qnty-dis-card':U then do:     assign     p-news = no.   end.
            when 'thth14-shop':U then do:     assign     p-news = no.   end.
            when 'thth14-contract':U then do:     assign     p-news = no.   end.
            when 'thth14-price-doc':U then do:     assign     p-news = no.   end.
            when 'thth14-trn-doc':U then do:     assign     p-news = no.   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут БД &1", p-code) .
      end.
    end.
  end.
end procedure.
define variable v_os-dir   AS CHAR NO-UNDO INIT "".
define variable v_os-dir-type   AS CHAR NO-UNDO INIT "".
define variable v_can-write as logical no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function corr-file-name returns character (
 input p-file-name as character)
 .
DEFINE variable v-corr-file-name as character no-undo.
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-char-name-list as character no-undo .
assign
v-corr-file-name = p-file-name
.
do ii = 1 to length('\/:*?"<>|':U):
  assign
  v-corr-file-name = replace(
                                v-corr-file-name
                               , substr('\/:*?"<>|':U, ii, 1 )
                               , entry(ii, 'b-slash,slash,colon,star,question,d-quote,d-quote,less-t,great-t,pipe':U)
                           )
  .
end.
return v-corr-file-name.
end function.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-log-gap as logical no-undo .
define variable v-user-name    as character    no-undo.
define variable v-grp-name    as character    no-undo.
define variable v-arm-code    as character    no-undo.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info5 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info5, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info5, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info5 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info5, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info5, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info5, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info5, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info5, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info5, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info5 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info5, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info5 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info5 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info5, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info5, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
DEFINE BUTTON B-dir
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-import
     LABEL "&Импорт"
     SIZE 10 BY 1.
DEFINE BUTTON B-obj
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Btn 1"
     SIZE 2.5 BY 1.
DEFINE VARIABLE dir-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 49.6 BY 1 NO-UNDO.
DEFINE VARIABLE F-cdk AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-cdrg AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-flt AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-gen AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE f-new-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Новый код фирмы"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-new-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Новый код объекта"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-old-host-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Старый код фирмы"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-old-obj-code AS INTEGER FORMAT ">>>>9":U INITIAL 0
     LABEL "Старый код объекта"
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE F-pbc AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-pet AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-rht AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-scl AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-seq AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-thb AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE F-usr AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 29.4 BY .8 NO-UNDO.
DEFINE VARIABLE Rs-new-obj-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 12.5 BY .8 NO-UNDO.
DEFINE VARIABLE Rs-old-obj-type AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Item 1", "1"
     SIZE 12.5 BY .8 NO-UNDO.
DEFINE RECTANGLE RECT-groups
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 86.8 BY 13.67.
DEFINE VARIABLE T-cdk AS LOGICAL INITIAL yes
     LABEL "Кассы"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-cdrg AS LOGICAL INITIAL no
     LABEL "Диапазоны весовых кодов"
     VIEW-AS TOGGLE-BOX
     SIZE 27 BY .8 NO-UNDO.
DEFINE VARIABLE T-flt AS LOGICAL INITIAL yes
     LABEL "Фильтры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-gen AS LOGICAL INITIAL yes
     LABEL "Настройки"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-glb AS LOGICAL INITIAL no
     LABEL "Глобальные коды"
     VIEW-AS TOGGLE-BOX
     SIZE 18 BY 1.07 NO-UNDO.
DEFINE VARIABLE T-pbc AS LOGICAL INITIAL yes
     LABEL "Вес,взвеш и топ.коды"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-pet AS LOGICAL INITIAL yes
     LABEL "Конфиг АЗК"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-rht AS LOGICAL INITIAL no
     LABEL "Права"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-scl AS LOGICAL INITIAL yes
     LABEL "Весы"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-seq AS LOGICAL INITIAL no
     LABEL "Счетчики"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-thb AS LOGICAL INITIAL no
     LABEL "Параметры"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE VARIABLE T-usr AS LOGICAL INITIAL yes
     LABEL "Пользователи"
     VIEW-AS TOGGLE-BOX
     SIZE 18.8 BY .8 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.1
     B-export AT ROW 1 COL 21
     B-import AT ROW 1 COL 31
     B-Help AT ROW 1 COL 82
     B-dir AT ROW 2 COL 81.3
     T-rht AT ROW 5 COL 3
     T-gen AT ROW 6 COL 3
     T-thb AT ROW 7 COL 3 WIDGET-ID 30
     T-cdrg AT ROW 8 COL 3 WIDGET-ID 22
     T-pbc AT ROW 9 COL 3
     T-glb AT ROW 9 COL 64.5 WIDGET-ID 2
     T-scl AT ROW 10 COL 3
     T-cdk AT ROW 11 COL 3 WIDGET-ID 26
     T-seq AT ROW 12 COL 3
     T-usr AT ROW 13 COL 3
     T-flt AT ROW 14 COL 3
     T-pet AT ROW 15 COL 3 WIDGET-ID 34
     B-obj AT ROW 17.27 COL 1 WIDGET-ID 38
     f-old-host-code AT ROW 17.27 COL 19.5 COLON-ALIGNED WIDGET-ID 4
     f-new-host-code AT ROW 17.27 COL 49 COLON-ALIGNED WIDGET-ID 6
     Rs-old-obj-type AT ROW 18.33 COL 21 NO-LABEL WIDGET-ID 16
     Rs-new-obj-type AT ROW 18.33 COL 51 NO-LABEL WIDGET-ID 18
     f-old-obj-code AT ROW 19.27 COL 19.5 COLON-ALIGNED WIDGET-ID 8
     f-new-obj-code AT ROW 19.27 COL 49 COLON-ALIGNED WIDGET-ID 10
     dir-name AT ROW 2 COL 28.6 COLON-ALIGNED NO-LABEL
     F-rht AT ROW 5 COL 30.5 COLON-ALIGNED NO-LABEL
     F-gen AT ROW 6 COL 30.5 COLON-ALIGNED NO-LABEL
     F-thb AT ROW 7 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 32
     F-cdrg AT ROW 8 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     F-pbc AT ROW 9 COL 30.5 COLON-ALIGNED NO-LABEL
     F-scl AT ROW 10 COL 30.5 COLON-ALIGNED NO-LABEL
     F-cdk AT ROW 11 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     F-seq AT ROW 12 COL 30.5 COLON-ALIGNED NO-LABEL
     F-usr AT ROW 13 COL 30.5 COLON-ALIGNED NO-LABEL
     F-flt AT ROW 14 COL 30.5 COLON-ALIGNED NO-LABEL
     F-pet AT ROW 15 COL 30.5 COLON-ALIGNED NO-LABEL WIDGET-ID 36
     "Группы данных" VIEW-AS TEXT
          SIZE 20.1 BY .8 AT ROW 4 COL 3.4
          FGCOLOR 4
     "Название файла экспорта-импорта" VIEW-AS TEXT
          SIZE 33.5 BY .8 AT ROW 4 COL 33.1
          FGCOLOR 4
     "ПРИ ИМПОРТЕ" VIEW-AS TEXT
          SIZE 22 BY 1.07 AT ROW 17.27 COL 65.5 WIDGET-ID 20
          FGCOLOR 4
     "Директория экспорта/импорта" VIEW-AS TEXT
          SIZE 27.9 BY 1 AT ROW 2 COL 2
          FGCOLOR 4
     RECT-groups AT ROW 3.4 COL 1.8
     SPACE(0.39) SKIP(3.85)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт-импорт локальных таблиц для РАСТЯНУТОГО upgrade"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-export:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-cdrg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-gen:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-rht:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       F-thb:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-cdrg:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-gen:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-rht:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-seq:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       T-thb:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-dir IN FRAME Dialog-Frame
DO:
    run gbl/dir-sel.p (output v_os-dir,
                output v_os-dir-type,
                output v_can-write) no-error.
    if error-status:error then return no-apply.
    dir-name = v_os-dir.
    display
    dir-name
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-export IN FRAME Dialog-Frame
DO:
  if NOT v_can-write then do:
    message "Данная директория доступна только для чтения"
    view-as alert-box ERROR.
    return no-apply.
  end.
  run waitfram-show in this-procedure ( input "Ждите..." ).
  run proc-b-ie in this-procedure ( input "export":U).
  run waitfram-hide in this-procedure .
END.
ON CHOOSE OF B-import IN FRAME Dialog-Frame
DO:
 DEFINE buffer buf_sysconf FOR ub.sysconf.
 DEFINE BUFFER buf_clients FOR ub.clients.
 ASSIGN
 f-old-host-code
 f-new-host-code
 rs-old-obj-type
 rs-new-obj-type
 f-old-obj-code
 f-new-obj-code
 .
 FIND FIRST buf_sysconf NO-LOCK WHERE
            buf_sysconf.host-code = f-new-host-code NO-ERROR.
 IF NOT AVAILABLE buf_sysconf THEN DO:
   MESSAGE
   substitute("Не найдена фирма с кодом (НОВОЙ) фирмы &1"
              , f-new-host-code)
   VIEW-AS ALERT-BOX ERROR.
   UNDO, RETURN NO-APPLY.
 END.
 FIND FIRST buf_clients NO-LOCK WHERE
             buf_clients.obj-type = rs-new-obj-type
        AND  buf_clients.obj-code = f-new-obj-code
     NO-ERROR.
  IF NOT AVAILABLE buf_clients THEN DO:
    MESSAGE
    substitute("Не найден объект с кодом/типом (НОВЫМ) &1&2"
               , rs-new-obj-type
               , f-new-obj-code)
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
 END.
if buf_clients.host-code <> buf_sysconf.host-code then do:
    MESSAGE
    substitute("Объект с кодом/типом (НОВЫМ) &1&2 НЕ принадлежит фирме &3"
               , rs-new-obj-type
               , f-new-obj-code
               , f-new-host-code
               )
    VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
end.
IF f-old-host-code = 0  THEN DO:
   MESSAGE
   "Не заполнен СТАРЫЙ код фирмы"
   VIEW-AS ALERT-BOX ERROR.
    UNDO, RETURN NO-APPLY.
END.
IF f-old-obj-code = 0  THEN DO:
    MESSAGE
    "Не заполнен СТАРЫЙ код объекта"
    VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN NO-APPLY.
END.
  if sys-ctrl.db-num <> 0
    and T-cdrg <> no
  then do:
    MESSAGE
    "Импортировать ДИАПАЗОНЫ ВЕСОВЫХ КОДОВ можно только в ГБД"
    VIEW-AS ALERT-BOX ERROR.
     UNDO, RETURN NO-APPLY.
  end.
  run waitfram-show in this-procedure ( input "Ждите..." ).
  run proc-b-ie in this-procedure ( input "import":U).
  run waitfram-hide in this-procedure .
END.
ON CHOOSE OF B-obj IN FRAME Dialog-Frame
DO:
  DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
  DEFINE VARIABLE v-rowid AS rowid NO-UNDO.
  DEFINE VARIABLE v-tbl-name AS CHARACTER NO-UNDO.
  DEFINE BUFFER buf_ext-classif FOR ub.ext-classif.
  DEFINE BUFFER buf_clients FOR ub.clients.
  run utl/thth-cli.w ( input parparentproc
                      ,input "b-sel"
                      ,input 'объект':U
                      ,input-output v-rid-list) no-error.
  IF v-rid-list <> '' THEN DO:
      FIND FIRST buf_ext-classif NO-LOCK WHERE
            RECID(buf_ext-classif) = INTEGER(v-rid-list) NO-ERROR.
      IF buf_ext-classif.uniq-key-rec = '' THEN DO:
         MESSAGE
         "Еще не установлено соответствие для этого объекта"
         VIEW-AS ALERT-BOX ERROR.
         RETURN NO-APPLY.
      END.
      ASSIGN
      f-old-host-code = buf_ext-classif.key#_two
      rs-old-obj-type = buf_ext-classif.charkey_one
      f-old-obj-code = buf_ext-classif.key#_one
      .
        RUN gen-row-keyr IN THIS-PROCEDURE ( INPUT buf_ext-classif.uniq-key-rec
                                      ,input ?
                                      ,INPUT "ub"
                                      ,INPUT ?
                                      ,INPUT NO-LOCK
                                      ,OUTPUT v-rowid
                                      ,OUTPUT v-tbl-name) no-error.
     FIND FIRST buf_clients NO-LOCK WHERE
                ROWID(buf_clients) = v-rowid.
     ASSIGN
     f-new-host-code = buf_clients.host-code
     rs-new-obj-type = buf_clients.obj-type
     f-new-obj-code = buf_clients.obj-code
     .
     DISPLAY
     f-old-host-code
     rs-old-obj-type
     f-old-obj-code
     f-new-host-code
     rs-new-obj-type
     f-new-obj-code
     WITH FRAME Dialog-Frame.
  END.
END.
ON VALUE-CHANGED OF T-usr IN FRAME Dialog-Frame
DO:
  ASSIGN
  t-usr.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    file-info:file-name = ".".
    assign
    dir-name = file-info:full-pathname
    v_os-dir-type = file-info :file-type
    v_can-write = (index(v_os-dir-type, "W") > 0)
   .
  FIND FIRST sys-ctrl No-LOCK.
  FIND FIRST db no-LOCK where
             db.db-num = sys-ctrl.db-num.
  assign
    f-rht  = corr-file-name(db.db-key) + ".":U +   "rht"
    F-flt  = corr-file-name(db.db-key) + ".":U +   "flt"
    F-thb  = corr-file-name(db.db-key) + ".":U +   "thb"
    F-pbc  = corr-file-name(db.db-key) + ".":U +   "pbc"
    F-scl  = corr-file-name(db.db-key) + ".":U +   "scl"
    F-usr  = corr-file-name(db.db-key) + ".":U +   "usr"
    F-gen  = corr-file-name(db.db-key) + ".":U +   "gen"
    F-seq  = corr-file-name(db.db-key) + ".":U +   "seq"
    F-cdrg = corr-file-name(db.db-key) + ".":U +   "cdr"
    F-cdk  = corr-file-name(db.db-key) + ".":U +   "cdk"
    F-pet  = corr-file-name(db.db-key) + ".":U +   "pet"
    .
  rs-old-obj-type:RADIO-BUTTONS IN FRAME Dialog-Frame =
      'маг':U + chr(44) + 'маг':U + chr(44) +
      'скл':U + chr(44) + 'скл':U
      .
  rs-new-obj-type:RADIO-BUTTONS IN FRAME Dialog-Frame =
      'маг':U + chr(44) + 'маг':U + chr(44) +
'скл':U + chr(44) + 'скл':U .
  rs-old-obj-type = 'маг':U.
  rs-new-obj-type = 'маг':U.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE check-iefile :
DEFINE INPUT PARAMETER p-dir-name as character no-undo.
DEFINE INPUT PARAMETER p-file-extension as character no-undo.
DEFINE INPUT PARAMETER p-mode as character no-undo.
define output parameter p-ok as logical no-undo.
define variable full_name as character no-undo.
FIND FIRST sys-ctrl No-LOCK.
FIND FIRST db no-LOCK where
            db.db-num = sys-ctrl.db-num.
if not avail db then do:
    message "Отсутствует информация в таблице db"
    view-as alert-box ERROR.
    return error.
end.
full_name = dir-name + "\":U + corr-file-name(db.db-key) + "." + p-file-extension.
if p-mode = "import":U then do:
    if search(full_name) = ? then do:
    message "Не найден файл данных" full_name  skip
                        "для импорта"
        view-as alert-box ERROR.
        p-ok = no.
        return.
    end.
    p-ok = yes.
    return.
end.
if p-mode = "export":U then do:
    if search(full_name) <> ? then do:
    message "Уже имеется в выбранной директории файл с именем" full_name  skip
            "совпадающим с именем одного из файлов экспорта" skip
            "Перезаписывать?"
    view-as alert-box QUESTION buttons YES-NO update p-ok.
    return.
  end.
  p-ok = yes.
  return.
end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY T-pbc T-glb T-scl T-cdk T-usr T-flt T-pet f-old-host-code
          f-new-host-code Rs-old-obj-type Rs-new-obj-type f-old-obj-code
          f-new-obj-code dir-name F-pbc F-scl F-cdk F-usr F-flt F-pet
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-import B-Help RECT-groups B-dir T-pbc T-glb T-scl T-cdk T-usr
         T-flt T-pet B-obj dir-name F-pbc F-scl F-cdk F-usr F-flt F-pet
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-ie :
define input parameter p-mode as character no-undo.
 define variable ii as integer no-undo.
 define variable loc#log as logical no-undo.
 define variable file-extensions as char format "X(3)" no-undo init "rht,gen,flt,pbc,scl,usr,seq,cdr,cdk,thb,pet":U.
 define variable t-vals as logical no-undo extent 11.
 define variable v-proc-name as character no-undo .
 define variable v-proc-title as character no-undo .
 define variable v-param as character no-undo .
 define variable v-choice as integer no-undo .
 define variable glog as logical no-undo .
 assign
 dir-name
 frame Dialog-Frame
 T-flt
 t-pbc
 T-scl
 T-usr
 T-seq  = no
 t-glb
 t-cdk
 t-thb
 t-pet
 .
 if (t-cdk
 or t-pet
 or t-thb)
 and p-mode = "export"  then do:
   message
   "Данные о кассах и/или конфигурации АЗК и/или ПАРАМЕТРАХ доступны только для ИМПОРТА"
   view-as alert-box error .
   run waitfram-hide in this-procedure .
   undo, return error .
 end.
 assign
 t-vals[2]  = no
 t-vals[3]  = t-flt
 t-vals[1]  = no
 t-vals[4]  = t-pbc
 t-vals[5]  = t-scl
 t-vals[6]  = t-usr
 t-vals[7]  = t-seq
 t-vals[8] = no
 t-vals[9]  = t-cdk
 t-vals[10]  = t-thb
 t-vals[11]  = t-pet
 .
 if dir-name = "" then do:
    message "Не задана директория для файлов экспорта/импорат"
    view-as alert-box ERROR.
    return error.
 end.
 DO ii = 1 to num-entries(file-extensions):
    if t-vals[ii] then do:
        run check-iefile in this-procedure (
                                           input dir-name
                                           ,input entry(ii, file-extensions)
                                           ,input p-mode
                                           ,output loc#log).
        if not loc#log then  return no-apply.
    end.
  end.
  assign
  v-param = string(T-vals[1])  + chr(4) +
            string(T-vals[2])  + chr(4) +
            string(T-vals[3])  + chr(4) +
            string(T-vals[4])  + chr(4) +
            string(T-vals[5])  + chr(4) +
            string(T-vals[6])  + chr(4) +
            string(T-vals[7])  + chr(4) +
            string(T-vals[8]) + chr(4) +
            string(T-vals[9]) + chr(4) +
            string(T-vals[10]) + chr(4) +
            (if p-mode = "import"
            then (string(T-vals[11]) + chr(4))
            else '') +
            corr-file-name(db.db-key)  + chr(4) +
            dir-name                   + chr(4) +
            string(T-glb)
            .
  if p-mode = "export":U then do:
    assign
    v-proc-name = "utl/impxexpe.p"
    v-proc-title = "Экспорт локальных таблиц БД"
    .
  end.
  else do:
    MESSAGE
    "ПРОВЕРЬТЕ ЕЩЕ РАЗ ЗНАЧЕНИЯ СТАРЫХ И НОВЫХ КОДОВ ФИРМ И ОБЪЕКТОВ!" SKIP
    "ПРОДОЛЖИТЬ?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE glog.
    IF NOT glog  THEN RETURN.
    assign
    v-param = v-param + chr(4) +
            replace(p-from-version, "v", "") + chr(4) +
            STRING(f-old-host-code) + chr(4) +
            STRING(f-new-host-code) + chr(4) +
            rs-old-obj-type + chr(4) +
            rs-new-obj-type + chr(4) +
            STRING(f-old-obj-code) + chr(4) +
            STRING(f-new-obj-code) + chr(4) +
            p-from-version
    v-proc-name = "utl/impxexpi.p"
    v-proc-title = "Импорт локальных таблиц БД"
    .
  end.
  run str/diallog.w (
          input parparentproc
        , input this-procedure
        , input v-proc-name
        , input v-param
        , input no
        , input "":U
        , input v-proc-title
    ) no-error.
  if error-status:error then do:
    message
    error-status:get-message(1) skip
    return-value
    view-as alert-box error.
  end.
END PROCEDURE.
