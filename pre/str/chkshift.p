block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-shift-on as logical no-undo .
define input parameter p-chk-rec as recid no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define input parameter p-shift-name as character no-undo .
define input parameter p-shift-reservoir-from as int no-undo.
define input parameter p-shift-reservoir-to as int no-undo.
define input parameter p-change-fields as character no-undo .
define input parameter p-can-back-shift as logical no-undo .
define output parameter p-added as logical no-undo .
define output parameter p-changed as logical no-undo.
define variable vss-revision    as character no-undo init "$Revision: 6557e99634e7, 3192, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:28 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkshift.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkshift.p $":U .
define variable vss-description as character no-undo init "Изменение даты и или номера смены для одного чека".
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
DEFINE VARIABLE cas-shft as logical no-undo .
DEFINE VARIABLE conf-attr as character no-undo .
define variable v-is-update as logical no-undo .
define variable v-chip-num like ub.c-chk-doc.chip-num no-undo .
define variable v-shift-date as date no-undo.
define variable v-shift-num as integer no-undo.
define variable v-shift-name2 as character no-undo .
define variable v-check-shift-date as date no-undo.
define variable v-check-shift-num as integer no-undo.
define variable v-check-shift-name as character no-undo .
define buffer bf_chk-doc for ub.chk-doc .
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_place for ub.place.
define buffer bf_chk-discnt for ub.chk-discnt.
do
on error undo, return error
:
  find first bf_chk-doc where
             recid(bf_chk-doc) = p-chk-rec.
  if bf_chk-doc.out-code <> ? then return error.
  if bf_chk-doc.chk-type = 13 or bf_chk-doc.chk-type = 40 then return error .
  assign
  cas-shft = no.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type0 as character no-undo .
define variable v-value-character0 as character no-undo .
define variable v-value-date0 as date no-undo .
define variable v-value-decimal0 as decimal no-undo .
define variable v-value-integer0 as INTEGER no-undo .
define variable v-tth0 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  bf_chk-doc.obj-type
    ,input  bf_chk-doc.obj-code
    ,input  'get-chk':U
    ,input  'cas-shft':U
    ,output v-value-character0
    ,output v-value-date0
    ,output v-value-decimal0
    ,output v-value-integer0
    ,output cas-shft
    ,output v-param-type0
    ,INPUT-OUTPUT table-handle v-tth0
    )  .
delete object v-tth0.
  assign
  v-check-shift-date = (if lookup("shift-date":U, p-change-fields) > 0
                        then p-shift-date
                        else bf_chk-doc.shift-date)
  v-check-shift-num = (if lookup("shift-num":U, p-change-fields) > 0
                        then p-shift-num
                        else bf_chk-doc.shift-num
                        )
  v-check-shift-name = (if lookup("shift-name":U, p-change-fields) > 0
                        then p-shift-name
                        else bf_chk-doc.shift-name
                        )
 .
  CASE cas-shft:
    when yes then do:
      if v-check-shift-date = ? then return error.
      if p-shift-on then do:
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  bf_chk-doc.obj-type
  ,input  bf_Chk-doc.obj-code
  ,output v-shift-date
  ,output v-shift-num
  ,output v-shift-name2
  ) no-error .
        if error-status:error then do:
          if p-can-back-shift = no then do:
            return error return-value .
          end.
        end.
        find first buf_shift-obj no-lock where
                  buf_shift-obj.obj-type = bf_chk-doc.obj-type
              and  buf_shift-obj.obj-code = bf_chk-doc.obj-code
              and  buf_shift-obj.shift-date = v-check-shift-date
              and  buf_shift-obj.shift-num =  v-check-shift-num
              and  buf_shift-obj.shift-name =  v-check-shift-name
              no-error.
        if not available buf_shift-obj then return error substitute('Нет смены &1(&2) от &3 для &4&5'
                                                                    ,v-check-shift-name
                                                                    ,v-check-shift-num
                                                                    ,string(v-check-shift-date, "99/99/9999")
                                                                    ,bf_chk-doc.obj-type
                                                                    ,bf_chk-doc.obj-code).
        if v-check-shift-date <> v-shift-date
        or v-check-shift-num <> v-shift-num
        or integer(v-check-shift-name) <> integer(v-shift-name2)
        then do:
          if p-can-back-shift then do:
            if available buf_shift-obj
            and not (buf_shift-obj.status_ = 'тек':U
                  or buf_shift-obj.status_ = 'ожд':U
                  or buf_shift-obj.status_ = 'зкр':U)
                  then do:
              if not available buf_shift-obj then return error substitute('Смена &1(&2) от &3 для &4&5&6" +
                                                                          "имеет статус &7'
                                                                          ,buf_shift-obj.shift-name
                                                                          ,buf_shift-obj.shift-num
                                                                          ,string(buf_shift-obj.shift-date, "99/99/9999")
                                                                          ,bf_chk-doc.obj-type
                                                                          ,bf_chk-doc.obj-code
                                                                          ,chr(10)
                                                                          ,buf_shift-obj.status_
                                                                          ).
            end.
          end.
          else do:
            if available buf_shift-obj
            and not (buf_shift-obj.status_ = 'тек':U
                  or buf_shift-obj.status_ = 'ожд':U) then do:
              if not available buf_shift-obj then return error substitute('Смена &1(&2) от &3 для &4&5&6" +
                                                                          "имеет статус &7'
                                                                          ,buf_shift-obj.shift-name
                                                                          ,buf_shift-obj.shift-num
                                                                          ,string(buf_shift-obj.shift-date, "99/99/9999")
                                                                          ,bf_chk-doc.obj-type
                                                                          ,bf_chk-doc.obj-code
                                                                          ,chr(10)
                                                                          ,buf_shift-obj.status_
                                                                          ).
            end.
          end.
        end.
        if (bf_chk-doc.shift-date <> buf_shift-obj.shift-date
        or bf_chk-doc.shift-num <> buf_shift-obj.shift-num
        or integer(bf_chk-doc.shift-name) <> integer(buf_shift-obj.shift-name)
        ) then do:
          assign
          p-added = yes.
        end.
      end.
      else do:
        if v-check-shift-num = 0 then return error.
        if v-check-shift-date > bf_chk-doc.chk-date then return error.
        if integer(v-check-shift-name) = 0 then return error.
      end.
    end.
    when no then do:
      if v-check-shift-date > bf_chk-doc.chk-date then return error.
      if v-check-shift-num <> 0 then return error.
      if integer(v-check-shift-name) <> 0 then return error.
      if bf_chk-doc.shift-date <> v-shift-date
      then do:
        assign
        p-added = yes.
      end.
    end.
  END CASE.
  run trg/chk-doch.p (
                  buffer bf_chk-doc
                , input no
                , input no
                , input no
                , input-output v-chip-num
                , output v-is-update).
  assign
  bf_chk-doc.shift-date = v-check-shift-date
  bf_chk-doc.shift-num = v-check-shift-num
  bf_chk-doc.shift-name = string(integer(v-check-shift-name))
  .
  if bf_chk-doc.shift-date    <> v-check-shift-date
    or bf_chk-doc.shift-num   <> v-check-shift-num
    or bf_chk-doc.shift-name  <> string(integer(v-check-shift-name)) then
        p-changed = true.
    for each bf_chk-discnt where bf_chk-discnt.doc-code = bf_chk-doc.doc-code:
    assign
      bf_chk-discnt.shift-date = v-check-shift-date
      bf_chk-discnt.shift-num = v-check-shift-num
      .
    release bf_chk-discnt.
    end.
  if lookup("shift-reservoir-to", p-change-fields) > 0 then
    do:
      for each buf_chk-gds
        where buf_chk-gds.doc-code = bf_chk-doc.doc-code
            and buf_chk-gds.pl-code = p-shift-reservoir-from
                :
                    find first buf_place
                        where buf_place.pl-code = p-shift-reservoir-to
                        no-error.
                    if avail buf_place then do:
                        buf_chk-gds.pl-code = buf_place.pl-code.
                        buf_chk-gds.loc1    = buf_place.loc1.
                        p-changed = true.
                    end.
      end.
    end.
  if (bf_chk-doc.shift-date = v-shift-date
  and bf_chk-doc.shift-num = v-shift-num
  and bf_chk-doc.shift-name = v-shift-name2
      )
  or (p-shift-on
      and
      bf_chk-doc.shift-date = buf_shift-obj.shift-date
      and
      bf_chk-doc.shift-num = buf_shift-obj.shift-num
      and
      bf_chk-doc.shift-name = buf_shift-obj.shift-name)
  then do:
    assign
    bf_chk-doc.office = replace(bf_chk-doc.office, 'смн-ош':U, '':U)
    bf_chk-doc.office = replace(bf_chk-doc.office, (chr(44) + chr(44)), chr(44))
    bf_chk-doc.office = trim(bf_chk-doc.office, chr(44))
    bf_chk-doc.correct = (replace(replace(replace(bf_chk-doc.office, 'т':U, '':U), 'у':U, ''), chr(44), '') = '')
    .
  end.
  run trg/chk-doch.p (
                  buffer bf_chk-doc
                , input yes
                , input no
                , input no
                , input-output v-chip-num
                , output v-is-update).
  bf_chk-doc.ps = if v-is-update
                  then (if index(bf_chk-doc.ps, "shift!") > 0
                        then bf_chk-doc.ps
                        else ("!shift!":U +  left-trim(bf_chk-doc.PS, "!":U))
                        )
                  else bf_chk-doc.ps.
end.
