block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-tnvd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-tnvd.p $":U .
define variable vss-description as character no-undo init "Закачка кодов ТНВЭД".
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
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
  define new shared temp-table  tt-tax no-undo
field tax-code    like ub.tax.tax-code
FIELD individual  like ub.tax.individual
FIELD tax-name    like ub.tax.tax-name format "X(12)" column-label "Налог"
field rate-code   like ub.tax-rate.rate-code
FIELD rate-name   like ub.tax-rate.rate-name FORMAT "X(12)"
FIELD tax-type    like ub.tax.tax-type
field rate-value  like ub.tax-rate-value.rate-value
FIELD tax-rate-gds-rc  as recid
FIELD to-cashdesk like ub.tax.to-cashdesk
FIELD fact-date like ub.tax-rate-value.fact-date
FIELD fact-order like ub.tax-rate-value.fact-order
FIELD next-order like ub.tax-rate-value.fact-order
FIELD corr-user-name like ub.tax-rate-gds.corr-user-name
FIELD corr-user-db-num   like ub.tax-rate-gds.corr-user-db-num
FIELD corr-date like ub.tax-rate-gds.corr-date
FIELD corr-time like ub.tax-rate-gds.corr-time
index tax-code is unique primary tax-code fact-order descending rate-code.
define variable InputFileName as char                 no-undo.
define variable glog as logical no-undo .
define variable v-parameter   as character no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
if ( v-cntxt-db-num > 0 ) then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.
SYSTEM-DIALOG GET-FILE InputFileName
              TITLE   "Файл для заполнения поля ТНВЕД"
              FILTERS "Текстовый файл (*.txt)" "*.txt",
                      "Все файлы (*.*)"        "*.*"
              MUST-EXIST
              USE-FILENAME
              UPDATE glog.
if not glog then return.
InputFileName = trim (string (InputFileName)) .
glog = yes.
message
"Выберите кодировку входного файла: YES - 1251, NO - KOI8-R"
view-as alert-box question buttons YES-NO update glog.
define variable v-encoding as character no-undo .
if glog then
v-encoding = "1251".
else
v-encoding = "KOI8-R".
glog = yes.
message "Выберите режим импорта:" skip
        "YES - замена" skip
        "NO - добавление (заполняются только пустые)"
        view-as alert-box question buttons YES-NO update glog.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
assign
v-parameter =
              "tnved":U + chr(1) +
              (if glog then "replace" else 'ДОБАВЛЕНИЕ':U) + chr(4) + inputfilename + chr(4) + v-encoding +
                            chr(1) +
              v-cntxt-obj-type                                                                                    + chr(4) +
              string(v-cntxt-obj-code)                                                                            + chr(4) +
              "":U                                                                              + chr(4) +
              "":U                                                                                   + chr(4) +
              "":U                                                                                  + chr(4) +
              "":U                                                                                 + chr(4) +
              "":U                                                                                   + chr(4) +
              "":U                                                                                     + chr(4) +
              "":U                                                                                   + chr(4) +
              "":U                                                                                   + chr(4) +
              "":U                                                                                   + chr(4) +
              "":U                                                                              + chr(4) +
              "":U                                                                                  + chr(4) +
              "":U                                                                                    + chr(4) +
              "":U                                                                                    + chr(4) +
              "":U                                                                                    + chr(4) +
              "":U                                                                                    + chr(4) +
              "":U                                                                               + chr(4) +
              "":U                                                                                 + chr(4) +
              "":U                                                                               + chr(4) +
              "":U                                                                                        + chr(4) +
              "":U                                                                                   + chr(4) +
              "":U                                                                                    + chr(4) +
              "":U                                                                                + chr(4) +
              "":U                                                                                      + chr(4) +
              "":U                                                                                    + chr(4) +
              "":U                                                                                  + chr(4) +
              "":U                                                                             + chr(4) +
              "":U                                                                                      + chr(4) +
              "":U                                                                             + chr(4) +
              "":U                                                                               + chr(4) +
              "":U                                                                                     + chr(4) +
              "":U                                                                               + chr(4) +
              "":U                                                                                 + chr(4) +
              "":U                                                                              + chr(4) +
              "":U                                                                               + chr(4) +
              "":U                                                                                         + chr(4) +
              "":U                                                                   + chr(4) +
              "":U
.
v-parameter = v-parameter + chr(1).
v-parameter = v-parameter +
              "no":U                                                                                   + chr(4) +
              "no":U                                                                                  + chr(4) +
              "no":U                                                                                 + chr(4) +
              "no":U                                                                                   + chr(4) +
              "no":U                                                                                     + chr(4) +
              "no":U                                                                                   + chr(4) +
              "no":U                                                                                   + chr(4) +
              "no":U                                                                                   + chr(4) +
              "no":U                                                                              + chr(4) +
              "no":U                                                                                  + chr(4) +
              "no":U                                                                                    + chr(4) +
              "no":U                                                                                    + chr(4) +
              "no":U                                                                                    + chr(4) +
              "no":U                                                                                    + chr(4) +
              "no":U                                                                               + chr(4) +
              "no":U                                                                                 + chr(4) +
              "no":U                                                                               + chr(4) +
              "no":U                                                                                        + chr(4) +
              "no":U                                                                                   + chr(4) +
              "no":U                                                                                    + chr(4) +
              "no":U                                                                                + chr(4) +
              "no":U                                                                                      + chr(4) +
              "no":U                                                                                    + chr(4) +
              "no":U                                                                                  + chr(4) +
              "no":U                                                                             + chr(4) +
              "no":U                                                                                      + chr(4) +
              "no":U                                                                             + chr(4) +
              "no":U                                                                               + chr(4) +
              "yes":U                                                                                     + chr(4) +
              "no":U                                                                               + chr(4) +
              "no":U                                                                                 + chr(4) +
              "no":U                                                                              + chr(4) +
              "no":U                                                                               + chr(4) +
              "no":U                                                                                         + chr(4) +
              "no":U                                                                                       + chr(4) +
              "no":U
 .
  run str/diallog.w ( input parparentproc
              , input this-procedure
              , input 'utl/goods01r.p':U
              , input v-parameter
              , input no
              , input "&Стоп"
              , input 'Пакетное изменение кода ТНВЭД товара') .
