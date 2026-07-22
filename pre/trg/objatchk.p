block-level on error undo, throw.
define input parameter p-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-obj-code  like ub.clients.obj-code no-undo .
define input parameter p-action    as character no-undo .
define input parameter p-new-value as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка того, что можно изменить признак объекта".
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
main-block:
do
on error undo main-block, return error
:
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  if p-new-value = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение параметра p-new-value" skip
      "Объект" p-obj-type p-obj-code skip
      view-as alert-box error .
    undo, return error .
  end.
  case p-action :
    when "doc-prt":u then do:
      if p-new-value = false then do:
        message
          "Включенные шкалы не выключаются" skip
          "Объект" p-obj-type p-obj-code skip
          view-as alert-box information .
        undo, return error.
      end.
      if p-new-value = true then do:
        if can-find( first ub.trn-doc
          where ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
            and ub.trn-doc.status_  <> 'факт':U
        ) then do:
          message
            "На объекте имеются незакрытые документы"
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
    end.
    when "shift-on":u then do:
      find first buf_clients share-lock
        where buf_clients.obj-type = p-obj-type
          and buf_clients.obj-code = p-obj-code
        .
      find first buf_db no-lock
        where buf_db.db-num = buf_clients.db-num
        .
      if p-new-value = false then do:
        if can-find( first ub.trn-doc
          where ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
        )
        or can-find( first ub.price-doc
          where ub.price-doc.obj-type = p-obj-type
            and ub.price-doc.obj-code = p-obj-code
        )
        or can-find( first ub.rvs-doc
          where ub.rvs-doc.obj-type = p-obj-type
            and ub.rvs-doc.obj-code = p-obj-code
        )
        or can-find( first ub.shift-obj
          where ub.shift-obj.obj-type = p-obj-type
            and ub.shift-obj.obj-code = p-obj-code
        )
        then do:
          message
            "На объекте существуют документы и/или смены" skip
            "Включенные смены нельзя выключить" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
      else do:
        if p-obj-type = 'скл':U then do:
          message
            "Для склада нельзя включить сменную работу" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
        if p-obj-type = 'маг':U then do:
          for each ub.cash-desk no-lock
            where ub.cash-desk.obj-code = p-obj-code
              and ub.cash-desk.db-num   = buf_db.db-num
          :
              if ub.cash-desk.pos-type <> 'IBM':U
              and ub.cash-desk.pos-type <> 'IBM-XML':U
              and ub.cash-desk.pos-type <> 'MARIA':U then do:
              message
                "У магазина имеются кассы с типом, отличным от IBM" skip
                "Нельзя включить сменную работу для магазина" skip
                "Объект" p-obj-type p-obj-code skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
        if can-find( first ub.trn-doc
          where ub.trn-doc.obj-type = p-obj-type
            and ub.trn-doc.obj-code = p-obj-code
        ) then do:
          message
            "Нельзя включить сменную работу" skip
            "На объекте имеются складские документы" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
        if can-find( first ub.price-doc
          where ub.price-doc.obj-type = p-obj-type
            and ub.price-doc.obj-code = p-obj-code
        ) then do:
          message
            "Нельзя включить сменную работу" skip
            "На объекте имеются документы переоценки" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
        if can-find( first ub.rvs-doc
          where ub.rvs-doc.obj-type = p-obj-type
            and ub.rvs-doc.obj-code = p-obj-code
        ) then do:
          message
            "Нельзя включить сменную работу" skip
            "На объекте имеются документы сверки" skip
            "Объект" p-obj-type p-obj-code skip
            view-as alert-box information .
          undo, return error.
        end.
      end.
      if buf_db.db-num > 0
        and trim( buf_db.db-key ) <> "":U
        and buf_db.db-key <> ?
      then do:
          message
            substitute( "Нельзя &1 сменную работу", (if p-new-value = true then "включать" else "выключать") )  skip
            "УБД уже существует и возможно на объекте уже созданы документы" skip
            substitute( "Объект &1 &2 для БД &3", p-obj-type, p-obj-code, buf_db.db-num ) skip
            view-as alert-box information .
          undo, return error.
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестное значение p-action" skip
        "Объект" p-obj-type p-obj-code skip
        "p-action" p-action skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end.
