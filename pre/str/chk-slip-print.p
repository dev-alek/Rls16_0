block-level on error undo, throw.
define input parameter p-db-num as integer no-undo .
define input parameter p-ID as character no-undo .
define input parameter p-CheckId as character no-undo .
define input parameter p-RRN as character no-undo .
define input parameter p-print-type as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 495342954825, 3030, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пт апр 29 17:03:44 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-slip-print.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chk-slip-print.p $":U .
define variable vss-description as character no-undo init "Печать слипов чека".
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
define variable v-slip-txt as character no-undo .
define variable v-slip-txt-list as character no-undo .
define variable cmd as character no-undo .
define stream out-slip .
define buffer chk-slip-head for ub.chk-slip-head .
define buffer chk-slip-string for ub.chk-slip-string .
define variable v-file-name as character no-undo.
define variable vok as logical no-undo.
define variable ii as integer no-undo .
SYSTEM-DIALOG GET-FILE v-file-name
    TITLE "Сохранить как"
    FILTERS
      " Файл PDF(*.pdf) " "*.pdf",
      " Все файлы (*.*) " "*.*"
    ask-overwrite
    save-as
    use-filename
    update vok
    default-extension "pdf"
    .
if not vok THEN do:
  return .
end.
case p-print-type :
  when "one"
  then do :
    v-slip-txt = "slip_" + p-ID .
    output stream out-slip to value(v-slip-txt) convert target "UTF-8" .
      for each chk-slip-string no-lock where chk-slip-string.db-num = p-db-num
                                         and chk-slip-string.ID = p-ID
                                         and chk-slip-string.CheckID = p-CheckId
                                         and chk-slip-string.RRN = p-RRN
                                         and chk-slip-string.str-num < 10000
                                         by chk-slip-string.str-num
                                         :
        put stream out-slip unformatted chk-slip-string.str-value skip .
      end .
    output stream out-slip close .
    cmd = substitute('&1 -n="&2" -o="&3"', search("exe/slip2pdf.exe"), search(v-slip-txt), v-file-name) .
  end .
  when "all"
  then do :
    v-slip-txt-list = "" .
    for each chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                     and chk-slip-head.CheckID = p-CheckId
                                     :
      v-slip-txt = "slip_" + chk-slip-head.ID .
      output stream out-slip to value(v-slip-txt) convert target "UTF-8" .
        for each chk-slip-string no-lock where chk-slip-string.db-num = chk-slip-head.db-num
                                           and chk-slip-string.ID = chk-slip-head.ID
                                           and chk-slip-string.CheckID = chk-slip-head.CheckId
                                           and chk-slip-string.RRN = chk-slip-head.RRN
                                           and chk-slip-string.str-num < 10000
                                           by chk-slip-string.str-num
                                           :
          put stream out-slip unformatted chk-slip-string.str-value skip .
        end .
      output stream out-slip close .
      v-slip-txt-list = v-slip-txt-list + search(v-slip-txt) + "," .
    end .
    v-slip-txt-list = trim(v-slip-txt-list, ",") .
    cmd = substitute('&1 -n="&2" -o="&3"', search("exe/slip2pdf.exe"), v-slip-txt-list, v-file-name) .
  end .
  when "all_pay"
  then do :
    v-slip-txt-list = "" .
    for each chk-slip-head no-lock where chk-slip-head.db-num = p-db-num
                                     and chk-slip-head.CheckID = p-CheckId
                                     and chk-slip-head.RRN = p-RRN
                                     :
      v-slip-txt = "slip_" + chk-slip-head.ID .
      output stream out-slip to value(v-slip-txt) convert target "UTF-8" .
        for each chk-slip-string no-lock where chk-slip-string.db-num = chk-slip-head.db-num
                                           and chk-slip-string.ID = chk-slip-head.ID
                                           and chk-slip-string.CheckID = chk-slip-head.CheckId
                                           and chk-slip-string.RRN = chk-slip-head.RRN
                                           and chk-slip-string.str-num < 10000
                                           by chk-slip-string.str-num
                                           :
          put stream out-slip unformatted chk-slip-string.str-value skip .
        end .
      output stream out-slip close .
      v-slip-txt-list = v-slip-txt-list + search(v-slip-txt) + "," .
    end .
    v-slip-txt-list = trim(v-slip-txt-list, ",") .
    cmd = substitute('&1 -n="&2" -o="&3"', search("exe/slip2pdf.exe"), v-slip-txt-list, v-file-name) .
  end .
end case .
os-command silent value(cmd) .
if p-print-type = "one"
then do :
  os-delete value(v-slip-txt) no-error .
end .
else do :
  do ii = 1 to num-entries(v-slip-txt-list) :
    v-slip-txt = entry(ii, v-slip-txt-list) .
    os-delete value(v-slip-txt) no-error .
  end .
end .
