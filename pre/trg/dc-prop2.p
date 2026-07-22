block-level on error undo, throw.
define input parameter p-range  as integer no-undo .
define input parameter p-d-card like ub.dis-card-property.d-card no-undo .
define input parameter p-host-code like ub.dis-card-property.host-code no-undo .
define input parameter p-obj-type like ub.dis-card-property.obj-type no-undo .
define input parameter p-obj-code like ub.dis-card-property.obj-code no-undo .
define input parameter p-dtm-code like ub.dis-card-property.dtm-code no-undo .
define input parameter p-node-code like ub.dis-card-property.node-code no-undo .
define input parameter p-dt-code like ub.dis-card-property.dt-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка валидности записи свойства ДК".
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
define buffer buf_sysconf for ub.sysconf.
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_attr-prop for ub.attr-prop.
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
define variable v-message as character no-undo .
if p-host-code > 0 then do:
  FIND FIRST buf_sysconf No-LOCK WHERE
            buf_sysconf.host-code = p-host-code No-ERROR.
  IF NOT AVAIL buf_sysconf THEN DO:
    run err-mess  in this-procedure (substitute("Не найдена фирма &1", p-host-code)).
    RETURN ERROR v-message.
  END.
end.
if p-obj-type <> "":U or
    p-obj-code <> 0 then do:
  find first buf_clients No-LOCK WHERE
             buf_clients.obj-type = p-obj-type AND
             buf_clients.obj-code = p-obj-code no-error .
  if not available buf_clients then do:
    run err-mess in this-procedure ( input substitute("Не найден объект &1&2", p-obj-type, p-obj-code)).
    RETURN ERROR v-message.
  end.
end.
else if NOT (p-obj-type = "":U and p-obj-code = 0) then do:
  run err-mess in this-procedure ( input  substitute("Неверные значения параметров p-obj-type/p-obj-code и/или p-host-code: &1&2 &3"
                          , p-obj-type
                          , p-obj-code
                          , p-host-code)).
  RETURN ERROR v-message.
end.
if p-d-card <> "":U then do:
  find first buf_dis-card No-LOCK WHERE
              buf_dis-card.d-card = p-d-card No-ERROR.
    if not avail buf_dis-card then do:
    run err-mess in this-procedure ( input  substitute("Не найдена ДК")).
    return error  v-message.
  end.
  if buf_dis-card.emitent-host-code <> 0
  and p-host-code <> buf_dis-card.emitent-host-code then do:
    run err-mess in this-procedure ( input  substitute("Для фирменной карты свойство можно ввести только с привязкой к фирме-эмитенту")).
    return error v-message.
  end.
  if buf_dis-card.emitent-host-code = 0
  and p-range = 1
  and p-host-code <> 0 then do:
    run err-mess in this-procedure ( input  substitute("Для свойство с ОБЛАСТЬЮ ДЕЙСТВИЯ СОГЛАСНО КОДУ ЭМИТЕНТА&1" +
                           "для ГЛОБАЛЬНОЙ карты можно ввести только ГЛОБАЛЬНОЕ свойство"
                            , chr(10)
                           )).
    return error v-message.
  end.
end.
 PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
  assign
  v-message =  substitute("Карта №&1: свойство &2.&3 срез &4 для фирмы &5 объект &6&7&8"
                 , p-d-card
                 , p-dtm-code
                 , p-node-code
                 , p-dt-code
                 , p-host-code
                 , p-obj-type
                 , p-obj-code
                 , chr(10)
                 )    +
               p-mess
  .
END PROCEDURE.
