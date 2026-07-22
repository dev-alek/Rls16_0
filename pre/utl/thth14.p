block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: 1f78fe327cdf, 1091, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:52 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: thth14.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/thth14.p $":U .
define variable vss-description as character no-undo init "Запуск пакета утилита THTH - 16.0 и 14".
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
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-operations as character no-undo .
define variable v-operation-codes as character no-undo .
define variable v-selected-operation as character no-undo .
define variable v-operation-name as character no-undo .
define variable v-run-file-name as character no-undo .
define variable v-can-init as logical no-undo .
define variable v-rid-list as character no-undo .
define variable v-ok as logical no-undo .
define variable v-is-debug as logical no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-mess as character no-undo .
define variable v-log as logical no-undo .
define variable v-attr-query-list as character no-undo .
define variable v-value-list as character no-undo .
define variable v-jj as integer no-undo .
define variable v-exist as logical no-undo .
v-is-debug = no.
assign
v-operations = "":U
v-operation-codes = "":U
v-selected-operation = "start"
.
assign
v-operations =
              "Инициация переноса объекта" + chr(4) +
              "Соответствие клиентов" + chr(4) +
              "Соответствие товаров" + chr(4) +
              "Соответствие объектов" + chr(4) +
              "Импорт переоценок" + chr(4) +
              "Закрытие ДНЦ" + chr(4) +
              "Импорт приходных накладных" + chr(4) +
              "Импорт лок. данных - ЗАПУСКАЕТСЯ В УБД - если объект принадлежит УБД" + chr(4) +
              "Отчет"
v-operation-codes  =  "ini" + chr(4) +
                      'clients':U + chr(4) +
                      'goods':U + chr(4) +
                      'shop':U + chr(4) +
                      'price-doc':U + chr(4) +
                      "close-pdf" + chr(4) +
                      'trn-doc':U + chr(4) +
                      "impxexpi" + chr(4) +
                      "rep"
.
_leave:
do while v-selected-operation <> ""
on error undo, leave _leave
on stop undo, leave _leave
on end-key undo, leave _leave
:
  run gbl/d-list.w (
                INPUT "b-sel":U
                ,INPUT "Выберите операцию по сведению систем 16.0 и 14"
                ,INPUT v-operation-codes
                ,INPUT v-operations
                ,INPUT chr(4)
                ,INPUT "":U
                ,output v-selected-operation).
  IF v-selected-operation = "":u THEN do:
    leave _leave.
  end.
  assign
  v-operation-name = entry(lookup(v-selected-operation, v-operation-codes, chr(4)) , v-operations, chr(4))
  .
  case v-selected-operation:
    when "" then do:
      leave _leave.
    end.
    when "ini" then do:
      assign
      v-value-list = ''
      v-attr-query-list = 'thth14-clients':U + chr(4) + 'thth14-goods':U + chr(4) + 'thth14-shop':U
      .
      do v-jj = 1 to num-entries(v-attr-query-list, chr(4) ):
        v-exist = no.
        v-value = string(yes).
        run thth14-db-attr-exist in this-procedure ( input 0
                                                 ,input entry(v-jj, v-attr-query-list, chr(4) )
                                                 ,output v-exist).
        if v-exist then do:
          run thth14-db-attr-value in this-procedure ( input 0
                                                    ,input entry(v-jj, v-attr-query-list, chr(4))
                                                    ,output v-value
                                                    ,output v-type) no-error.
        end.
        v-value-list = v-value-list + (if v-value-list = '' then '' else chr(4) ) + v-value.
      end.
      if lookup(string(no), v-value-list, chr(4) ) > 0 then do:
        message
        "Начат но не закончен этап сведения v14 и v16.0"
        view-as alert-box error .
      end.
      else do:
        do v-jj = 1 to num-entries(v-attr-query-list, chr(4) ):
          run thth14-db-attr-write in this-procedure ( input 0
                                                    ,input entry(v-jj, v-attr-query-list, chr(4))
                                                    ,input string(no)
                                                    ) no-error.
        end.
      end.
    end.
    when 'goods':U then do:
      assign
      v-attr-query-list = 'thth14-clients':U
      v-value-list = "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД"
      .
      do v-jj = 1 to num-entries(v-attr-query-list, chr(4)):         v-value = ''.         run thth14-db-attr-value in this-procedure ( input 0                                                   ,input entry(v-jj, v-attr-query-list, chr(4))                                                   ,output v-value                                                   ,output v-type) no-error.         assign         v-log = logical(v-value)         no-error .         if v-log = logical(entry(v-jj, v-value-list, chr(4))) then do:           if v-is-debug then do:             message             entry(v-jj, v-mess, chr(4) )             view-as alert-box warning.           end.           else do:             message              v-mess                 view-as alert-box error.             next _leave.           end.                    end.       end.
      run utl/thth-gds.w ( input parparentproc
                           ,input (if g#db-num = 0 then "b-add" else "")
                           ,input 'v14_0':U
                           ,input ''
                           ,input-output v-rid-list) no-error.
    end.
    when 'clients':U then do:
      run utl/thth-cli.w ( input parparentproc
                           ,input (if g#db-num = 0 then "b-add" else "")
                           ,input 'v14_0':U
                           ,input ''
                           ,input-output v-rid-list) no-error.
    end.
    when "impxexpi" then do:
      assign
      v-attr-query-list = 'thth14-shop':U + chr(4) +
                          'thth14-clients':U + chr(4) +
                          'thth14-goods':U
      v-value-list = "no" + chr(4) +
                     "no" + chr(4) +
                     "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ОБЪЕКТАМИ В РАЗНЫХ БД" + chr(4) +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД" + chr(4)  +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ТОВАРАМИ В РАЗНЫХ БД"
      .
      do v-jj = 1 to num-entries(v-attr-query-list, chr(4)):         v-value = ''.         run thth14-db-attr-value in this-procedure ( input 0                                                   ,input entry(v-jj, v-attr-query-list, chr(4))                                                   ,output v-value                                                   ,output v-type) no-error.         assign         v-log = logical(v-value)         no-error .         if v-log = logical(entry(v-jj, v-value-list, chr(4))) then do:           if v-is-debug then do:             message             entry(v-jj, v-mess, chr(4) )             view-as alert-box warning.           end.           else do:             message              v-mess                 view-as alert-box error.             next _leave.           end.                    end.       end.
      run utl/expximp.w ( input parparentproc) no-error.
    end.
    when 'shop':U then do:
      run utl/thth-cli.w ( input parparentproc
                      ,input (if g#db-num = 0 then "b-add" else "")
                      ,input 'v14_0':U
                      ,input 'объект':U
                      ,input-output v-rid-list) no-error.
    end.
    when 'price-doc':U then do:
      assign
      v-attr-query-list = 'thth14-shop':U + chr(4) +
                          'thth14-clients':U + chr(4) +
                          'thth14-goods':U
      v-value-list = "no" + chr(4) +
                     "no" + chr(4) +
                     "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ОБЪЕКТАМИ В РАЗНЫХ БД" + chr(4) +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД" + chr(4)  +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ТОВАРАМИ В РАЗНЫХ БД"
      .
      do v-jj = 1 to num-entries(v-attr-query-list, chr(4)):         v-value = ''.         run thth14-db-attr-value in this-procedure ( input 0                                                   ,input entry(v-jj, v-attr-query-list, chr(4))                                                   ,output v-value                                                   ,output v-type) no-error.         assign         v-log = logical(v-value)         no-error .         if v-log = logical(entry(v-jj, v-value-list, chr(4))) then do:           if v-is-debug then do:             message             entry(v-jj, v-mess, chr(4) )             view-as alert-box warning.           end.           else do:             message              v-mess                 view-as alert-box error.             next _leave.           end.                    end.       end.
      run cmp/ththovr1.w ( input parparentproc ) no-error .
    end.
    when "close-pdf" then do:
      run utl/ththovr3.p ( input parparentproc ) no-error .
    end.
    when 'trn-doc':U then do:
      assign
      v-attr-query-list = 'thth14-shop':U + chr(4) +
                          'thth14-clients':U + chr(4) +
                          'thth14-goods':U
      v-value-list = "no" + chr(4) +
                     "no" + chr(4) +
                     "no"
      v-mess = "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ОБЪЕКТАМИ В РАЗНЫХ БД" + chr(4) +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ КЛИЕНТАМИ В РАЗНЫХ БД" + chr(4)  +
               "ЕЩЕ НЕ УСТАНОВЛЕНО СООТВЕТСТВИЕ МЕЖДУ ТОВАРАМИ В РАЗНЫХ БД"
      .
      do v-jj = 1 to num-entries(v-attr-query-list, chr(4)):         v-value = ''.         run thth14-db-attr-value in this-procedure ( input 0                                                   ,input entry(v-jj, v-attr-query-list, chr(4))                                                   ,output v-value                                                   ,output v-type) no-error.         assign         v-log = logical(v-value)         no-error .         if v-log = logical(entry(v-jj, v-value-list, chr(4))) then do:           if v-is-debug then do:             message             entry(v-jj, v-mess, chr(4) )             view-as alert-box warning.           end.           else do:             message              v-mess                 view-as alert-box error.             next _leave.           end.                    end.       end.
      run cmp/ththpri1.w ( input parparentproc ) no-error .
    end.
    when "rep" then do:
      run utl/ththrepr.p ( input parparentproc ) no-error.
    end.
    otherwise do:
      message
      "НЕВЕРНОЕ ЗНАЧЕНИЕ ВЫБОРА"
      view-as alert-box .
    end.
  end case.
  if error-status:error
  or return-value = "error"
  then do:
    message
    substitute("Ошибки при выполнении операции &1:&2" +
                "&3&2&4"
                , v-operation-name
                , chr(10)
                , error-status:get-message(1)
                , return-value )
    view-as alert-box error .
  end.
end.
if connected ("src") then do:
  disconnect src.
end.
procedure cb_close-without-verify :
define output parameter p-no-ver as logical   no-undo .
  do
  on error undo, return error return-value
  :
   p-no-ver = true .
  end.
end procedure.
