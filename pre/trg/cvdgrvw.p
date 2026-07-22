block-level on error undo, throw.
TRIGGER PROCEDURE FOR WRITE OF ub.c-var-deliv-gr-per-val.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись в таблице ИСТОРИЯ ВАРИАНТОВ ДОСТАВКИ ПО ГРУППАМ СРОКОВ ГОДНОСТИ".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7', ub.c-var-deliv-gr-per-val.deliv-type-code,
                                                ub.c-var-deliv-gr-per-val.deliv-subj-code,
                                              ub.c-var-deliv-gr-per-val.obj-type,
                                              ub.c-var-deliv-gr-per-val.obj-code,
                                              ub.c-var-deliv-gr-per-val.gr-per-val-code,
                                              ub.c-var-deliv-gr-per-val.corr-user-db-num,
                                              ub.c-var-deliv-gr-per-val.chip-num
                                              )
    .
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
define buffer buf_delivery-type for ub.delivery-type.
define buffer buf_delivery-subject for ub.delivery-subject.
define buffer buf_group-period-validity for ub.group-period-validity.
define buffer buf_clients for ub.clients.
define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if not g#news then do:
    find first buf_delivery-type no-lock where
               buf_delivery-type.deliv-type-code = c-var-deliv-gr-per-val.deliv-type-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ТИП ДОСТАВКИ" skip
      "код" c-var-deliv-gr-per-val.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_delivery-subject no-lock where
               buf_delivery-subject.deliv-subj-code = c-var-deliv-gr-per-val.deliv-subj-code  no-error .
    if not available buf_delivery-subject then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ" skip
      "код" c-var-deliv-gr-per-val.deliv-subj-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_group-period-validity no-lock where
               buf_group-period-validity.gr-per-val-code = c-var-deliv-gr-per-val.gr-per-val-code  no-error .
    if not available buf_delivery-type then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ГРУППУ СРОКОВ ГОДНОСТИ" skip
      "код" c-var-deliv-gr-per-val.deliv-type-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_clients no-lock where
               buf_clients.obj-type = c-var-deliv-gr-per-val.obj-type
           AND buf_clients.obj-code = c-var-deliv-gr-per-val.obj-code
               no-error .
    if not available buf_clients then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ" skip
      "тип" c-var-deliv-gr-per-val.obj-type    skip
      "код" c-var-deliv-gr-per-val.obj-code   skip
       view-as alert-box error .
      undo main-block, return error.
    end.
    find first buf_var-deliv-gr-per-val no-lock where
               buf_var-deliv-gr-per-val.deliv-type-code = c-var-deliv-gr-per-val.deliv-type-code
           AND buf_var-deliv-gr-per-val.deliv-subj-code = c-var-deliv-gr-per-val.deliv-subj-code
               no-error .
    if not available buf_var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неправильная ссылка на ВАРИАНТ ДОСТАВКИ" skip
      "код типа доставки" c-var-deliv-gr-per-val.deliv-type-code skip
      "код субъекта доставки" c-var-deliv-gr-per-val.deliv-subj-code skip
      "тип объекта доставки" c-var-deliv-gr-per-val.obj-type    skip
      "код объекта доставки" c-var-deliv-gr-per-val.obj-code   skip
      "код группы сроков годности" c-var-deliv-gr-per-val.gr-per-val-code skip
       view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории ВАРИАНТА ДОСТАВКИ ПО СРОКАМ ГОДНОСТИ в УБД" skip
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  run str/callnews.p
    (input "c-var-deliv-gr-per-val"
    ,input (buffer ub.c-var-deliv-gr-per-val:handle)
    ).
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input 'update':U
        , input 'c-var-deliv-gr-per-val':U
        , input ( buffer ub.c-var-deliv-gr-per-val:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , chr(10)
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.
