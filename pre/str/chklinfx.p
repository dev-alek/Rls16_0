block-level on error undo, throw.
define parameter buffer buf_chk-doc for ub.chk-doc.
define input parameter p-chk-doc-code  like ub.chk-doc.doc-code no-undo .
define input parameter p-with-question as logical no-undo .
define output parameter p-ok as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chklinfx.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chklinfx.p $":U .
define variable vss-description as character no-undo init "Заполнение номеров товарных строк и строк оплат по чеку, созданному в версиях TH < 11.1".
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
      p-vss-parameters = substitute('&1', (if avail buf_chk-doc then buf_chk-doc.doc-code else p-chk-doc-code))
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
define variable choice as integer no-undo .
define variable ii as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
do
on error undo, return error
:
  find first buf_chk-gds no-lock where
            buf_chk-gds.doc-code = p-chk-doc-code no-error.
  if available buf_chk-gds
  and buf_chk-gds.line-num = ?  then do:
    if p-with-question then do:
      run gbl/d-askw.w (input "Внимание",
                            input  ("Чек создан в предыдущих версиях TH,"
                                    + chr(10)
                                    + "Для корректного просмотра необходимо заполнить номера товарных строк и строк оплаты,"
                                    + chr(10)
                                    +  "причем номера строк НЕ БУДУТ СОВПАДАТЬ с номерами строк в ОРИГИНАЛЕ ЧЕКА НА КАССЕ!"
                                    + chr(10)
                                    + "(По СПН изменения не передаются!)"
                                    ),
                            input "|",
                            input "Заполнить|Отменить просмотр чека",
                            input "|",
                            input 1,
                            input 2,
                            output choice).
      if choice = 2 then do:
        return.
      end.
    end.
    if not available buf_chk-doc then do:
      find first buf_chk-doc exclusive-lock where
                buf_chk-doc.doc-code = p-chk-doc-code no-wait no-error .
      if locked buf_chk-doc then do:
         if p-with-question then do:
            undo, return error substitute("Запись чека с №1 занята", p-chk-doc-code).
         end.
      end.
      if not available buf_chk-doc then undo, return error substitute("Не найден чек с №1 занята", p-chk-doc-code).
    end.
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
  else do:
    assign
    p-ok = yes
    .
  end.
end.
