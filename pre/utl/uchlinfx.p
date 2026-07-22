block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: uchlinfx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/uchlinfx.p $":U .
define variable vss-description as character no-undo init "Заполнение номеров товарных строк и строк оплат по чекам, созданному в версиях TH < 11.1".
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
define variable v-num-ok as integer no-undo label "КОличество OK".
define variable v-num-err as integer no-undo label "Количество ошибок".
define variable v-num-old as integer no-undo  label "Количество найденных старых".
define variable v-num-all as integer no-undo  label "Количество просмотренных".
define variable v-gds-num-ok as integer no-undo label "КОличество стертых ошибок".
define variable v-gds-num-err as integer no-undo label "Количество оставшихся ошибок".
define variable v-gds-num-all as integer no-undo  label "Количество ошибочн товарн строк".
define variable v-pay-num-ok as integer no-undo label "КОличество стертых ошибок".
define variable v-pay-num-err as integer no-undo label "Количество оставшихся ошибок".
define variable v-pay-num-all as integer no-undo  label "Количество ошибочн товарн строк".
define variable v-ok as logical no-undo .
define variable v-doc-code as character no-undo .
define variable v-normal as logical no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf2_chk-gds for ub.chk-gds.
define buffer buf2_chk-pay for ub.chk-pay.
define buffer buf_chk-doc for ub.chk-doc.
output to uchkinfx.txt append.
put unformatted string(today, "99/99/9999") chr(32) string(time, "HH:MM:SS") skip.
put unformatted
substitute("Заполнение номеров строк старых чеков")
skip.
output close.
define frame aa
v-num-all skip
v-num-old skip
v-num-ok skip
v-num-err
WITH CENTERED ROW 3 TITLE "Заполнение номеров строк старых чеков" USE-TEXT.
form with frame aa.
_main:
do:
  _for:
  for each buf_chk-doc no-lock,
      each buf_chk-gds no-lock where
            buf_chk-gds.doc-code = buf_chk-doc.doc-code
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on endkey undo, leave _main
  on stop undo, leave _main
  :
    if v-doc-code <> buf_chk-doc.doc-code then do:
      if v-num-all modulo 1000 = 0 then do:
        display
        v-num-all skip v-num-old skip v-num-ok skip v-num-err
        with frame aa.
      end.
      if v-num-all modulo 100 = 0 then do:
        process events.
      end.
      v-num-all = v-num-all + 1.
      v-doc-code = buf_chk-doc.doc-code.
      if buf_chk-gds.line-num = ? then do:
        if v-num-old modulo 10000 = 0 then do:
          display
          v-num-all skip v-num-old skip v-num-ok skip v-num-err
          with frame aa.
          output to uchkinfx.txt append.
          put unformatted string(today, "99/99/9999") chr(32) string(time, "HH:MM:SS") skip.
          put unformatted
          substitute("Кличество просмотренных &1, количество старых &2, количество OK &3, количество ошибок &4"
                    , v-num-all
                    , v-num-old
                    , v-num-ok
                    , v-num-err
                    )
          skip
          substitute("Номер текущего обрабатываемого чека &1", buf_chk-doc.doc-code )
          skip
          .
          output close.
        end.
        assign
        v-num-old = v-num-old + 1.
        run refill-line-num in this-procedure ( input buf_chk-doc.doc-cod, output v-ok) no-error .
        if error-status:error
        or not v-ok
        then do:
          output to uchkinfx.txt append.
          put unformatted string(today, "99/99/9999") chr(32) string(time, "HH:MM:SS") skip.
          put unformatted
          substitute("Ошибка при заполнении номеров строк по чеку &1 (&2) &3&4&5&6&5&7"
                    , buf_chk-doc.doc-code
                    , string(buf_chk-doc.chk-date, "99/99/9999")
                    , buf_chk-doc.obj-type
                    , buf_chk-doc.obj-code
                    , chr(10)
                    , error-status:get-message(1)
                    , return-value
                    )
          skip.
          output close.
          v-num-err = v-num-err + 1.
        end.
        else do:
          v-num-ok = v-num-ok + 1.
        end.
      end.
    end.
  end.
  v-normal = yes.
end.
if  v-normal then do:
  v-normal = no.
  define frame bb
  v-gds-num-all skip
  v-gds-num-ok skip
  v-gds-num-err
  WITH CENTERED ROW 3 TITLE "Заполнение номеров товарных строк" USE-TEXT.
  form with frame bb.
  _gds:
  do :
    _for:
    for each buf_chk-gds no-lock where
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on endkey undo, leave _gds
    on stop undo, leave _gds
    :
      if v-gds-num-all modulo 1000 = 0 then do:
        display
        v-gds-num-all skip v-gds-num-ok skip v-gds-num-err
        with frame bb.
      end.
      if v-gds-num-all modulo 100 = 0 then do:
        process events.
      end.
      v-gds-num-all = v-gds-num-all + 1.
      if buf_chk-gds.line-num = ? then do:
        find first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = buf_chk-gds.doc-code no-error.
        if not available buf_chk-doc
        and buf_chk-gds.out-code = ? then do:
          find first buf2_chk-gds where
                    recid(buf2_chk-gds) = recid(buf_chk-gds).
          delete buf2_chk-gds.
          assign
          v-gds-num-ok = v-gds-num-ok + 1.
        end.
        else do:
          assign
          v-gds-num-err = v-gds-num-err + 1
          .
        end.
      end.
    end.
    v-normal = yes.
  end.
end.
if v-normal then do:
  v-normal = no.
  define frame cc
  v-pay-num-all skip
  v-pay-num-ok skip
  v-pay-num-err
  WITH CENTERED ROW 3 TITLE "Заполнение номеров строк оплат" USE-TEXT.
  form with frame cc.
  _pay:
  do :
    _for:
    for each buf_chk-pay no-lock where
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
    on endkey undo, leave _pay
    on stop undo, leave _pay
    :
      if v-pay-num-all modulo 1000 = 0 then do:
        display
        v-pay-num-all skip v-pay-num-ok skip v-pay-num-err
        with frame cc.
      end.
      if v-pay-num-all modulo 100 = 0 then do:
        process events.
      end.
      v-pay-num-all = v-pay-num-all + 1.
      if buf_chk-pay.line-num = ? then do:
        find first buf_chk-doc no-lock where
                  buf_chk-doc.doc-code = buf_chk-pay.doc-code no-error.
        if not available buf_chk-doc
        and buf_chk-pay.out-code = ? then do:
          find first buf2_chk-pay where
                    recid(buf2_chk-pay) = recid(buf_chk-pay).
          delete buf2_chk-pay.
          assign
          v-pay-num-ok = v-pay-num-ok + 1.
        end.
        else do:
          assign
          v-pay-num-err = v-pay-num-err + 1
          .
        end.
      end.
    end.
    v-normal = yes.
  end.
end.
message "Завершено пользователем" view-as alert-box .
output to uchkinfx.txt append.
put unformatted string(today, "99/99/9999") chr(32) string(time, "HH:MM:SS") skip.
put unformatted
substitute("Кличество просмотренных &1, количество старых &2, количество OK &3, количество ошибок &4"
          , v-num-all
          , v-num-old
          , v-num-ok
          , v-num-err
          )
skip
substitute("Кличество просмотренных ошибочных товарн. строк &1, количество удаленных &2, количество оставшихся ошибок &4"
          , v-gds-num-all
          , v-gds-num-ok
          , v-gds-num-err
          )
skip
substitute("Кличество ошибочных просмотренных строк оплат &1, количество удаленных &2, количество оставшихся ошибок &4"
          , v-pay-num-all
          , v-pay-num-ok
          , v-pay-num-err
          )
skip
substitute("Заполнение закончено")
skip
.
output close.
display
v-num-all skip v-num-old skip v-num-ok skip v-num-err
with frame aa.
procedure refill-line-num :
define input parameter p-doc-code as character no-undo .
define output parameter p-ok as logical no-undo .
define variable ii as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_chk-doc exclusive-lock where
            buf_chk-doc.doc-code = p-doc-code no-wait no-error .
  if locked buf_chk-doc then do:
    undo, return error substitute("Запись чека с №1 занята", p-doc-code).
  end.
  if not available buf_chk-doc then undo, return error substitute("Не найден чек с №1", p-doc-code).
  for each buf_chk-gds where
          buf_chk-gds.doc-code = buf_chk-doc.doc-code
    on error undo, return error
          :
    assign
    ii = ii + 1
    buf_chk-gds.line-num = ii
    .
  end.
  ii = 0.
  for each buf_chk-pay where
          buf_chk-pay.doc-code = buf_chk-doc.doc-code
    on error undo, return error
          :
    assign
    ii = ii + 1
    buf_chk-pay.line-num = ii
    .
  end.
  assign
  p-ok = yes
  .
end.
end procedure.
