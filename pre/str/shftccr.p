block-level on error undo, throw.
DEFINE INPUT PARAMETER p-obj-type   like ub.shift-cash.obj-type no-undo.
DEFINE INPUT PARAMETER p-obj-code   like ub.shift-cash.obj-code no-undo.
DEFINE INPUT PARAMETER p-cash-num   like ub.cash-desk.cash-num no-undo.
DEFINE INPUT PARAMETER p-shift-date like ub.shift-cash.shift-date no-undo.
DEFINE INPUT PARAMETER p-shift-num  like ub.shift-cash.shift-num no-undo.
DEFINE INPUT PARAMETER p-src-shift-name like ub.shift-cash.z-status no-undo.
DEFINE INPUT PARAMETER p-shift-name like ub.shift-cash.z-status no-undo.
define input parameter p-shift-open-time as integer no-undo .
DEFINE INPUT PARAMETER v-z-num      like ub.shift-cash.z-num no-undo.
DEFINE INPUT PARAMETER act-mess     as character no-undo.
DEFINE OUTPUT PARAMETER v-recid     as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision: 82660c506036, 2990, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Ср апр 06 16:23:43 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shftccr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/shftccr.p $":U .
define variable vss-description as character no-undo init "Создание записи кассовой смены".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-ranged-shift-num returns integer (input p-shift-num-list as character
                                              ,input p-status-list as character):
 if num-entries(p-shift-num-list) = 1 then return integer(p-shift-num-list).
 if index(p-status-list, '3') > 0 then return integer(entry(lookup('3', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '2') > 0 then return integer(entry(lookup('2', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '1') > 0 then return integer(entry(lookup('1', p-status-list) ,p-shift-num-list )).
 if index(p-status-list, '0') > 0 then return integer(entry(lookup('0', p-status-list) ,p-shift-num-list )).
END FUNCTION.
procedure get-shift-num :
define input parameter p-obj-type like ub.chk-doc.obj-type no-undo .
define input parameter p-obj-code like ub.chk-doc.obj-code no-undo .
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-name as character no-undo .
define output parameter p-shift-num as integer no-undo .
define variable v-shift-num-list as character no-undo .
define variable v-status-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error
  :
    for each  buf_shift-obj no-lock  where
            buf_shift-obj.obj-type    = p-obj-type
        AND  buf_shift-obj.obj-code   = p-obj-code
        AND  buf_shift-obj.shift-date = p-shift-date
        and  buf_shift-obj.shift-name = p-shift-name
        on error undo, return error return-value :
      assign
      v-shift-num-list = string(buf_shift-obj.shift-num) +
                        (if v-shift-num-list = '':U then '':U else chr(44)) + v-shift-num-list
      v-status-list    = entry(lookup(buf_shift-obj.status_, 'ожд,тек,зкр,отм':U), '2,3,1,0':U) +
                        (if v-status-list = '':U then '':U else chr(44)) + v-status-list
      .
    end.
    if v-shift-num-list = '':U then do:
      p-shift-num = 0.
    end.
    else do:
      assign
      p-shift-num = get-ranged-shift-num(v-shift-num-list, v-status-list).
    end.
  end.
end procedure.
define variable v-src-shift-name as character no-undo .
define variable v-shift-name as character no-undo .
define buffer buf_shift-cash for ub.shift-cash.
do
on error undo, return error
:
  if p-shift-num = ? THEN DO:
    IF P-SHIFT-NAME <> ? then do:
      run get-shift-num  in this-procedure (
                                            input  p-obj-type
                                            ,input  p-obj-code
                                            ,input  p-shift-date
                                            ,input  p-shift-name
                                            ,output p-shift-num ) no-error .
      if p-shift-num = 0 then return error substitute("Не удалось определить порядок смены:&1&2&3 смена от &4 № смены &5"
                                                , p-obj-type
                                                , p-obj-code
                                                , chr(10)
                                                , p-shift-date
                                                , p-shift-name) .
    end.
  END.
  FIND FIRST buf_shift-cash No-LOCK WHERE
            buf_shift-cash.obj-type = p-obj-type
        AND buf_shift-cash.obj-code = p-obj-code
        AND buf_shift-cash.cash-num = p-cash-num
        AND buf_shift-cash.shift-date = p-shift-date
        AND buf_shift-cash.shift-num = p-shift-num  No-ERROR.
  if not available buf_shift-cash
  and p-shift-name <> ?
  and p-src-shift-name = ?
  then do:
    _shift-cash:
    for each buf_shift-cash no-lock where
            buf_shift-cash.obj-type = p-obj-type
        and buf_shift-cash.obj-code = p-obj-code
        AND buf_shift-cash.cash-num = p-cash-num
        AND buf_shift-cash.shift-date = p-shift-date
        AND buf_shift-cash.shift-num = 0:
      if buf_shift-cash.status_ =  'зкр':U then NEXT _shift-cash.
      if buf_shift-cash.src-shift-name = p-shift-name
      and v-shift-name = '':U
      then do:
        LEAVE _shift-cash.
      end.
    end.
    if available buf_shift-cash then do:
      find current buf_shift-cash exclusive-lock .
      assign
      buf_shift-cash.shift-name = p-shift-name
      buf_shift-cash.shift-num = p-shift-num
      v-recid = recid(buf_shift-cash).
      .
      run process-all-check in this-procedure ( input p-shift-date
                                              , input p-shift-name
                                              , input p-shift-num) no-error.
      return.
    end.
  end.
  if act-mess                   ne 'прием-чек':U
  then
     run process-all-check in this-procedure ( input p-shift-date
                                             , input p-shift-name
                                             , input p-shift-num) no-error.
  if avail buf_shift-cash then do:
    if buf_shift-cash.status_ = 'зкр':U
    AND not act-mess = 'касса-вкл':U
    and (p-src-shift-name = ?
        or p-src-shift-name = buf_shift-cash.src-shift-name)
    then do:
        v-recid = recid(buf_shift-cash).
          return.
    end.
    else do:
      assign
      v-src-shift-name = buf_shift-cash.src-shift-name
      v-shift-name = buf_shift-cash.shift-name
      v-recid = recid(buf_shift-cash).
      if (p-shift-name <> ?
      and p-shift-name <> v-shift-name ) then do:
        find current buf_shift-cash exclusive-lock .
        assign
        v-shift-name      = (if p-shift-name <> ?
                              then p-shift-name
                              else v-shift-name)
        .
        assign
        buf_shift-cash.shift-name = v-shift-name
        buf_shift-cash.src-shift-name = v-src-shift-name
        .
        return.
      end.
    end.
  end.
  find first buf_shift-cash no-lock where
          buf_shift-cash.obj-type = p-obj-type
     and buf_shift-cash.obj-code = p-obj-code
     and buf_shift-cash.cash-num = p-cash-num
     and buf_shift-cash.z-num = v-z-num
     and buf_shift-cash.shift-date = p-shift-date
     and buf_shift-cash.shift-num = p-shift-num
     and buf_shift-cash.src-shift-name = (if p-src-shift-name <> ? then p-src-shift-name else '')
     no-error .
  if available buf_shift-cash then do:
     if p-src-shift-name <> ?
     and buf_shift-cash.opened = 'прием-чек':U
     and buf_shift-cash.shift-open-time > p-shift-open-time then do:
       assign
       v-recid = recid(buf_shift-cash).
       find current buf_shift-cash exclusive-lock .
       assign
       buf_shift-cash.shift-open-time = p-shift-open-time
       .
     end.
     return.
  end.
  return-value = '':U.
  find first buf_shift-cash no-lock where
          buf_shift-cash.obj-type = p-obj-type
      and buf_shift-cash.obj-code = p-obj-code
      and buf_shift-cash.cash-num = p-cash-num
      and buf_shift-cash.shift-date = p-shift-date
      and buf_shift-cash.shift-num = (if p-shift-num = ? then 0 else p-shift-num)
      and buf_shift-cash.src-shift-name = (if p-src-shift-name <> ? then p-src-shift-name else '') no-error .
 if not available buf_shift-cash then do:
    create buf_shift-cash.
    assign
    buf_shift-cash.obj-type = p-obj-type
    buf_shift-cash.obj-code = p-obj-code
    buf_shift-cash.cash-num = p-cash-num
    buf_shift-cash.z-num = v-z-num
    buf_shift-cash.shift-date = p-shift-date
    buf_shift-cash.shift-num = (if p-shift-num = ? then 0 else p-shift-num)
    buf_shift-cash.src-shift-name = (if p-src-shift-name <> ? then p-src-shift-name else '')
    buf_shift-cash.shift-name = (if p-shift-name <> ? then p-shift-name else '')
    buf_shift-cash.shift-open-time = (if p-shift-open-time <> ? then p-shift-open-time else buf_shift-cash.shift-open-time)
    buf_shift-cash.sale-date = buf_shift-cash.shift-date
    buf_shift-cash.status_ = 'тек':U
    buf_shift-cash.opened = act-mess
    v-recid = recid(buf_shift-cash)
    no-error
    .
    if error-status:error then do:
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
    release buf_shift-cash no-error.
    if error-status:error then do:
    v-recid = ?.
    undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1)).
    end.
  end.
  else do:
    if      buf_shift-cash.opened     ne 'прием-чек':U
       and act-mess                   eq 'прием-чек':U
    then do:
       find current buf_shift-cash exclusive-lock.
       assign
          buf_shift-cash.opened = act-mess
          buf_shift-cash.shift-open-time = (if p-shift-open-time <> ? then p-shift-open-time else buf_shift-cash.shift-open-time)
       .
    end.
    v-recid = recid(buf_shift-cash).
  end.
end.
procedure process-all-check :
define input parameter p-shift-date like ub.chk-doc.shift-date no-undo .
define input parameter p-shift-name as character no-undo .
define input parameter p-shift-num like ub.chk-doc.shift-num no-undo .
define buffer buf_chk-doc for ub.chk-doc.
  do
  on error undo, return error
  :
  _chk-doc:
  for each buf_chk-doc Exclusive-lock where
          buf_chk-doc.obj-type = p-obj-type
      and buf_chk-doc.obj-code = p-obj-code
      and buf_chk-doc.shift-date = p-shift-date
      and buf_chk-doc.shift-num = 0
      and (buf_chk-doc.out-code = ? or buf_chk-doc.out-code = '':U)
   on error undo, next _chk-doc
   on stop undo, next _chk-doc:
      if buf_chk-doc.src-shift-name = p-shift-name then do:
        assign
        buf_chk-doc.shift-num = p-shift-num
        buf_chk-doc.shift-name = p-shift-name
        buf_chk-doc.office = replace(buf_chk-doc.office, 'смн-ош':U, '':U)
        buf_chk-doc.office = replace(buf_chk-doc.office, chr(44) + chr(44), chr(44))
        buf_chk-doc.office = trim(buf_chk-doc.office, chr(44))
        buf_chk-doc.correct = (if buf_chk-doc.office = 'т':U
                               or buf_chk-doc.office = 'у':U
                               then yes
                               else no)
        .
      end.
    end.
  end.
end procedure.
