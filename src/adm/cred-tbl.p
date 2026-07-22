block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cred-tbl.p $
$Archive: adm/cred-tbl.p $

Динамический dump по query

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/10/07
Author: Bakhtadze Natalya
Creation date: 05/10/07

*/

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
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

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

&scop if-work ~
          case p-if-phrase: ~
            when 'if-simple' then do: ~
              if ~{&p-bh~}::corr-user-name <> {&nts-user} or ~{&p-bh~}::corr-user-db-num = p-db-num then do: ~
                v-restore = yes. ~
              end. ~
              else do: ~
                v-restore = no. ~
              end. ~
            end. ~
            when 'if-self' then do: ~
              if ~{&p-bh~}::corr-user-db-num = p-db-num then do: ~
                v-restore = yes. ~
              end. ~
              else do: ~
                v-restore = no. ~
              end. ~
            end. ~
            when 'if-simple-and-global' then do: ~
              if (~{&p-bh~}::corr-user-name <> {&nts-user} or ~{&p-bh~}::corr-user-db-num = p-db-num) ~
              and (~{&p-bh~}::host-code = 0 ~
                  or ~
                    (~{&p-bh~}::obj-type = '':U ~
                    and ~
                    ~{&p-bh~}::obj-code = 0) ~
                  ) ~
                  then do: ~
                v-restore = yes. ~
              end. ~
              else do: ~
                v-restore = no. ~
              end. ~
            end. ~
            when 'if-global' then do: ~
              if  (~{&p-bh~}::host-code = 0 ~
                  or ~
                    (~{&p-bh~}::obj-type = '':U ~
                    and ~
                    ~{&p-bh~}::obj-code = 0) ~
                  ) ~
                  then do: ~
                v-restore = yes. ~
              end. ~
              else do: ~
                v-restore = no. ~
              end. ~
            end. ~
            when 'if-db-num-1' then do: ~
              if ~{&p-bh~}::db-num = -1 then do: ~
                v-restore = yes. ~
              end. ~
              else do: ~
                v-restore = no. ~
              end. ~
          end. ~
          end case


do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  /*
   if p-buffer-names begins "dis-card,c-dis-obj" then do:
     p-hn = yes.
     return.
   end.
  */
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
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
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
    temp-buffers.ub-buf-name = /*(if v-dop begins "buf_"
                                then ("ub_" + v-dop)
                                else v-dop)
                                */
                                v-dop
    temp-buffers.dst-buf-name = (if v-dop begins "buf_"
                                then ("dst_" + v-dop)
                                else v-dop)
    temp-buffers.to-export = v-dop-e-log
    temp-buffers.num-buffer = v-ii
    .
    create buffer temp-buffers.ub-handle for table entry(1, temp-buffers.ub-tbl-name, "_")  buffer-name temp-buffers.ub-buf-name .
    create buffer temp-buffers.dst-handle for table entry(1, temp-buffers.dst-tbl-name, "_")  buffer-name temp-buffers.dst-buf-name .
/*    glog = temp-buffers.dst-handle:DISABLE-LOAD-TRIGGERS (yes).*/
    v_bh[v-ii] = temp-buffers.ub-handle.
    release temp-buffers.
  end.
  v-num-buffers = v-ii - 1.
  CREATE QUERY v_qh.
  if v-num-buffers = 1 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  if v-num-buffers = 2 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  if v-num-buffers = 3 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  if v-num-buffers = 4 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3], v_bh[4]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  if v-num-buffers = 5 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3], v_bh[4], v_bh[5]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  if v-num-buffers = 6 then do:
    glog = v_qh:SET-BUFFERS(v_bh[1], v_bh[2], v_bh[3], v_bh[4], v_bh[5], v_bh[6]).
    if not glog then return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
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
                                          , {&new-line}
                                          , error-status :get-message (1)
                                          , {&delim-par}
                                          , v-prepare-phrase
                                          ).
  end.
  if not p-run-or-check then do:
    run delete-objects in this-procedure .
    return.
  end.
  glog = v_qh:QUERY-OPEN.
  /*qh:GET-first(no-lock).*/
  if not glog then do:
    run delete-objects in this-procedure .
    return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  _repeat:
  REPEAT
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
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
&scop p-bh if_temp-buffers.ub-handle
          {&if-work}.
          if v-restore = no then do:
            next _repeat.
          end.
        end.
      end case.
    end.
    _temp:
    for each temp-buffers
    on error undo _temp, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    :
      if temp-buffers.num-buffer = 1
      and p-if-buffer-num = 1
      and p-if-phrase <> '':U then do:
        CASE p-if-phrase:
          when "ha" then do:
          end.
          otherwise do:
&scop p-bh temp-buffers.ub-handle
          {&if-work}.
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
end. /*doe*/

procedure delete-objects :

  do
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    DELETE OBJECT v_qh.
    for each temp-buffers:
     delete object temp-buffers.ub-handle.
     delete object temp-buffers.dst-handle .
     delete temp-buffers.
    end.
  end.

end procedure. /* delete-objects */