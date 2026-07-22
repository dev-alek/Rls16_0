block-level on error undo, throw.
define input parameter p-parent-handle as handle no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-host-code as integer no-undo .
define input parameter count-str as character no-undo .
define input parameter p-buffer-names as character no-undo .
define input parameter p-buffer-export as character no-undo .
define input parameter p-where-phrase as character no-undo .
define input parameter p-if-phrase as character no-undo .
define input parameter p-if-buffer-num as integer no-undo .
define input parameter p-dump-point as character no-undo .
define input parameter p-hn as logical no-undo .
define input parameter p-run-or-check as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cred-tbl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/cred-tbl.p $":U .
define variable vss-description as character no-undo init "Динамическая выгрузка по query".
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
define variable v_bh as handle no-undo extent 6.
define variable v_qh as handle no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-num-buffers as integer no-undo .
define variable v-buffer-name as character no-undo .
define variable glog as logical no-undo .
define variable v-restore as logical no-undo .
define variable v-prepare-phrase as character no-undo .
define variable v-dump-point-phrase as character no-undo .
define variable v-dop-e as character no-undo .
define variable v-dop-e-log as logical no-undo .
define temp-table temp-buffers no-undo
field ub-tbl-name as character
field dst-tbl-name as character
field ub-buf-name as character
field dst-buf-name as character
field ub-handle as handle
field dst-handle as handle
field num-buffer as integer
field to-export as logical
index pi is unique primary num-buffer
.
define buffer if_temp-buffers for temp-buffers.
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
  define variable fl    as character no-undo .
  define variable v-ind as integer no-undo.
  define variable v-ind-rest as integer no-undo .
  define new shared frame ddd
    count-str  label "":U format "X(50)"
    fl         label "Таблица" format "X(50)"
    v-ind      label "Записей просм."
    v-ind-rest label "Записей перекач."
    with view-as dialog-box side-labels 1 columns three-d title "Перекачка данных".
  if transaction = true
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Активна транзакция" skip
      substitute( "Выгрузка таблицы &1 невозможна", fl) skip
      view-as alert-box error .
    undo, return error substitute( "Выгрузка таблицы &1 невозможна", fl) .
  end.
  if current-window:window-state = 2 then do:
      current-window:window-state = 3.
  end.
  view frame ddd.
  _ii:
  do v-ii = 1 to num-entries(p-buffer-names)
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    assign
    v-dop = entry(v-ii, p-buffer-names)
    v-dop-e = entry(v-ii, p-buffer-export)
    .
    if v-dop = '':U then do:
      leave _ii.
    end.
    assign
    v-dop = if v-dop begins "ub."
            then substring(v-dop, 4)
            else v-dop
    v-dop-e-log  = logical(v-dop-e)
    .
    create temp-buffers.
    assign
    temp-buffers.ub-tbl-name = "ub." + (if v-dop begins "buf_"
                                        then entry(2, v-dop, "_")
                                        else entry(1, v-dop, "_"))
    temp-buffers.dst-tbl-name = "dst." + (if v-dop begins "buf_"
                                          then entry(2, v-dop, "_")
                                          else entry(1, v-dop, "_")
                                          )
    temp-buffers.ub-buf-name =
                                v-dop
    temp-buffers.dst-buf-name = (if v-dop begins "buf_"
                                then ("dst_" + v-dop)
                                else v-dop)
    temp-buffers.to-export = v-dop-e-log
    temp-buffers.num-buffer = v-ii
    .
    create buffer temp-buffers.ub-handle for table entry(1, temp-buffers.ub-tbl-name, "_")  buffer-name temp-buffers.ub-buf-name .
    create buffer temp-buffers.dst-handle for table entry(1, temp-buffers.dst-tbl-name, "_")  buffer-name temp-buffers.dst-buf-name .
    v_bh[v-ii] = temp-buffers.ub-handle.
    release temp-buffers.
  end.
  v-num-buffers = v-ii - 1.
  CREATE QUERY v_qh.
  if v-num-buffers = 1 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  if v-num-buffers = 2 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  if v-num-buffers = 3 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  if v-num-buffers = 4 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3], v_bh[4]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  if v-num-buffers = 5 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3], v_bh[4], v_bh[5]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  if v-num-buffers = 6 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3], v_bh[4], v_bh[5], v_bh[6]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  find first temp-buffers.
  assign
  fl = ub-tbl-name.
  case p-dump-point:
    when "obj"
    or
    when "xobj"
    then do:
      assign
      v-dump-point-phrase = substitute(p-where-phrase, p-obj-type, p-obj-code).
    end.
    when "host-obj"
    then do:
      assign
      v-dump-point-phrase = substitute(p-where-phrase, p-obj-type, p-obj-code, p-host-code).
    end.
    when "firm-db"
    then do:
      assign
      v-dump-point-phrase = substitute(p-where-phrase, p-host-code).
    end.
    otherwise do:
      assign
      v-dump-point-phrase = p-where-phrase.
    end.
  end case.
  if v-dump-point-phrase <> '':U then do:
    v-prepare-phrase = substitute("for each &1 where &2"
                                , temp-buffers.ub-buf-name
                                , v-dump-point-phrase).
  end.
  else do:
    v-prepare-phrase = substitute("for each &1", temp-buffers.ub-buf-name).
  end.
  assign
  glog = v_qh:QUERY-PREPARE(v-prepare-phrase) no-error .
  if not glog then do:
    run delete-objects in this-procedure .
     return error substitute( "&1. &2&3&4&5&6"
                                          , vss-workfile
                                          , return-value
                                          , chr(10)
                                          , error-status :get-message (1)
                                          , chr(4)
                                          , v-prepare-phrase
                                          ).
  end.
  if not p-run-or-check then do:
    run delete-objects in this-procedure .
    return.
  end.
  glog = v_qh:QUERY-OPEN.
  if not glog then do:
    run delete-objects in this-procedure .
    return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
  end.
  _repeat:
  REPEAT
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    v_qh:GET-NEXT(no-lock).
    IF v_qh:QUERY-OFF-END THEN LEAVE.
    v-ind = v-ind + 1.
    if not p-hn then do:
      if temp-buffers.ub-handle::corr-user-db-num <> p-db-num then next.
    end.
    if p-if-phrase <> ''
    and p-if-buffer-num <> 1 then do:
      find first if_temp-buffers where
                if_temp-buffers.num-buffer = p-if-buffer-num.
      CASE p-if-phrase:
        when "ha" then do:
        end.
        otherwise do:
          case p-if-phrase:             when 'if-simple' then do:               if if_temp-buffers.ub-handle::corr-user-name <> (chr(4) +  'СПН':U) or if_temp-buffers.ub-handle::corr-user-db-num = p-db-num then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-self' then do:               if if_temp-buffers.ub-handle::corr-user-db-num = p-db-num then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-simple-and-global' then do:               if (if_temp-buffers.ub-handle::corr-user-name <> (chr(4) +  'СПН':U) or if_temp-buffers.ub-handle::corr-user-db-num = p-db-num)               and (if_temp-buffers.ub-handle::host-code = 0                   or                     (if_temp-buffers.ub-handle::obj-type = '':U                     and                     if_temp-buffers.ub-handle::obj-code = 0)                   )                   then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-global' then do:               if  (if_temp-buffers.ub-handle::host-code = 0                   or                     (if_temp-buffers.ub-handle::obj-type = '':U                     and                     if_temp-buffers.ub-handle::obj-code = 0)                   )                   then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-db-num-1' then do:               if if_temp-buffers.ub-handle::db-num = -1 then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.           end.           end case.
          if v-restore = no then do:
            next _repeat.
          end.
        end.
      end case.
    end.
    _temp:
    for each temp-buffers
    on error undo _temp, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    :
      if temp-buffers.num-buffer = 1
      and p-if-buffer-num = 1
      and p-if-phrase <> '':U then do:
        CASE p-if-phrase:
          when "ha" then do:
          end.
          otherwise do:
          case p-if-phrase:             when 'if-simple' then do:               if temp-buffers.ub-handle::corr-user-name <> (chr(4) +  'СПН':U) or temp-buffers.ub-handle::corr-user-db-num = p-db-num then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-self' then do:               if temp-buffers.ub-handle::corr-user-db-num = p-db-num then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-simple-and-global' then do:               if (temp-buffers.ub-handle::corr-user-name <> (chr(4) +  'СПН':U) or temp-buffers.ub-handle::corr-user-db-num = p-db-num)               and (temp-buffers.ub-handle::host-code = 0                   or                     (temp-buffers.ub-handle::obj-type = '':U                     and                     temp-buffers.ub-handle::obj-code = 0)                   )                   then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-global' then do:               if  (temp-buffers.ub-handle::host-code = 0                   or                     (temp-buffers.ub-handle::obj-type = '':U                     and                     temp-buffers.ub-handle::obj-code = 0)                   )                   then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.             end.             when 'if-db-num-1' then do:               if temp-buffers.ub-handle::db-num = -1 then do:                 v-restore = yes.               end.               else do:                 v-restore = no.               end.           end.           end case.
            if v-restore = no then do:
              next _repeat.
            end.
          end.
        end case.
      end.
      DO TRANSACTION:
        if temp-buffers.to-export
        and temp-buffers.ub-handle:available
        then do:
          glog = temp-buffers.dst-handle:buffer-create.
          glog = temp-buffers.dst-handle:buffer-copy (temp-buffers.ub-handle).
          assign
          v-ind-rest = v-ind-rest + 1.
          if v-ind-rest modulo 1000 = 0 then
          display
          count-str
          fl
          v-ind
          v-ind-rest
          with frame ddd side-labels.
          pause 0.
        end.
      end.
    end.
  END.
  v_qh:QUERY-CLOSE().
  run delete-objects in this-procedure .
end.
procedure delete-objects :
  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  :
    DELETE OBJECT v_qh.
    for each temp-buffers:
     delete object temp-buffers.ub-handle.
     delete object temp-buffers.dst-handle .
     delete temp-buffers.
    end.
  end.
end procedure.
