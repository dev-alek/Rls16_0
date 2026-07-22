block-level on error undo, throw.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter frame-title   as char                no-undo.
define input  parameter doc-num       like price-doc.doc-num no-undo.
define input  parameter e-code        like trn-doc.exch-code no-undo.
define input  parameter pardoc-code   like trn-doc.doc-code  no-undo.
define input  parameter parcli-type   like ub.trn-doc.cli-type  no-undo.
define input  parameter parcli-code   like ub.trn-doc.cli-code  no-undo.
define input  parameter parhost-code  like ub.trn-doc.host-code no-undo.
define output parameter count-upd     as int init 0          no-undo.
define output parameter counter       as int init 0          no-undo.
define output parameter count-all     as int init 0          no-undo.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: imd-art.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/imd-art.p $":U .
define variable vss-description as character no-undo initial "Драйвер импорта из внешнего текстового файла любой информации".
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
function is-numeral return logical
  (input p-string   as character ,
   input char-avail as character) :
  define variable p-replace-string as character no-undo .
  define variable log-result       as logical  no-undo .
  if p-string = ? then
    return false .
  p-replace-string = p-string.
  if lookup ("*", char-avail) > 0 then
      p-replace-string = replace (p-replace-string, '*', '9').
  if lookup ("digit", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, '0', '9')
      p-replace-string = replace (p-replace-string, '1', '9')
      p-replace-string = replace (p-replace-string, '2', '9')
      p-replace-string = replace (p-replace-string, '3', '9')
      p-replace-string = replace (p-replace-string, '4', '9')
      p-replace-string = replace (p-replace-string, '5', '9')
      p-replace-string = replace (p-replace-string, '6', '9')
      p-replace-string = replace (p-replace-string, '7', '9')
      p-replace-string = replace (p-replace-string, '8', '9')
      .
  else
     p-replace-string = replace (p-replace-string, '9', chr(15))
      .
  if lookup ("letter", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, 'A', '9')
      p-replace-string = replace (p-replace-string, 'B', '9')
      p-replace-string = replace (p-replace-string, 'C', '9')
      p-replace-string = replace (p-replace-string, 'D', '9')
      p-replace-string = replace (p-replace-string, 'E', '9')
      p-replace-string = replace (p-replace-string, 'F', '9')
      p-replace-string = replace (p-replace-string, 'G', '9')
      p-replace-string = replace (p-replace-string, 'H', '9')
      p-replace-string = replace (p-replace-string, 'I', '9')
      p-replace-string = replace (p-replace-string, 'J', '9')
      p-replace-string = replace (p-replace-string, 'K', '9')
      p-replace-string = replace (p-replace-string, 'L', '9')
      p-replace-string = replace (p-replace-string, 'M', '9')
      p-replace-string = replace (p-replace-string, 'N', '9')
      p-replace-string = replace (p-replace-string, 'O', '9')
      p-replace-string = replace (p-replace-string, 'P', '9')
      p-replace-string = replace (p-replace-string, 'Q', '9')
      p-replace-string = replace (p-replace-string, 'R', '9')
      p-replace-string = replace (p-replace-string, 'S', '9')
      p-replace-string = replace (p-replace-string, 'T', '9')
      p-replace-string = replace (p-replace-string, 'U', '9')
      p-replace-string = replace (p-replace-string, 'V', '9')
      p-replace-string = replace (p-replace-string, 'W', '9')
      p-replace-string = replace (p-replace-string, 'X', '9')
      p-replace-string = replace (p-replace-string, 'Y', '9')
      p-replace-string = replace (p-replace-string, 'Z', '9')
      p-replace-string = replace (p-replace-string, '_', '9')
      .
  return p-replace-string = fill ('9', length (p-string)).
end.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#libbcrcn as handle no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log        as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  store-type
  ,input  store-code
  ,output g#host-code
  ,output g#host-name
  )  .
run get-report-num  in parParentProc ( output g#report-num ).
def shared stream inp.
def shared stream err.
def shared stream wrn.
define variable source-string  as char FORMAT "x(232)"      no-undo.
define variable text-string    as char FORMAT "x(232)"      no-undo.
define variable string-type    as char                      no-undo.
define variable i-artic         like goods.artic            no-undo.
define variable i-artic-supp    like cli-gds.cli-art        no-undo.
define variable i-code          like prod-bc.b-str          no-undo.
define variable i-prod-code     like goods.prod-code        no-undo.
define variable i-scale         like gds-prt.f-name         no-undo.
define variable i-prod-bc       like prod-bc.b-str          no-undo.
define variable i-price         like doc-line.price-cli     no-undo.
define variable i-qnty          like doc-line.cli-qnty      no-undo.
define variable i-VAT           like doc-line.VAT-pc        no-undo.
define variable i-SLT           like doc-line.VAT-pc        no-undo.
define variable i-wt-brutto     like doc-line.wt-brutto     no-undo.
define variable i-num-place     like doc-line.num-place     no-undo.
define variable i-d-pcnt        like price-list.d-pcnt      no-undo.
define variable i-unit-cli      like bar-code.unit-cli      no-undo.
define variable i-cli-base-rate like bar-code.cli-base-rate no-undo.
define variable i-bc-on         as   logical                no-undo.
define variable i-cst-code      like parts.cst-code         no-undo.
define variable local-code      like goods.gds-code         no-undo.
define variable size           as dec                       no-undo.
define variable scale-level    as int                       no-undo.
define variable msg-line       as int init 0                no-undo.
define variable wrn-line       as int init 0                no-undo.
define variable v-b-code as integer   no-undo .
define variable par-bc-pfx     as char                      no-undo.
define variable par-pl-pfx     as char                      no-undo.
define variable par-bc-frmt    as char                      no-undo.
define variable par-pl-frmt    as char                      no-undo.
define variable par-dif-pdbc   as logical                   no-undo.
define variable par-dpl-off    as logical                   no-undo.
define variable varfile-scan   as logical                   no-undo.
define variable varcode-scan   as char                      no-undo.
define variable varqnty-scan   as char                      no-undo.
define variable varprice-scan  as char                      no-undo.
define variable v-host-code    like sysconf.host-code  no-undo.
define variable v-obj-type     like trn-doc.obj-type   no-undo.
define variable v-obj-code     like trn-doc.obj-code   no-undo.
define variable varresult   as character       no-undo.
define variable vartype-bc  as character       no-undo.
define variable varweight   as decimal         no-undo.
define variable par-type    as character       no-undo.
define variable vararticle-supplier as logical no-undo.
define variable v-num as integer no-undo init 2 .
define variable v-vat-pc as decimal   no-undo .
define variable v-slt-pc as decimal   no-undo .
define variable v-today  as date      no-undo .
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.
define buffer other-goods for goods.
define buffer goods-units for units.
define buffer bf_clients  for clients.
define buffer bf_cli-gds  for cli-gds.
define buffer trouble-goods for goods.
run adm/shattri.p (
    input "get":U
    ,input  '':U
    ,input  0
    ,input  'gds-ref':U
    ,input  'dif-pdbc':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-dif-pdbc
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  '':U
    ,input  0
    ,input  'gds-ref':U
    ,input  'dpl-off':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output par-dpl-off
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error.
delete object v-tth.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type4 as character no-undo.
varscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'sclspref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varscales-pref
  ,output varscales-pref-type4
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type4 as character no-undo.
varpgscales-pref  = ?.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'scpgpref':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varpgscales-pref
  ,output varpgscales-pref-type4
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
def frame a
counter   label "Закачано"
count-upd label "Изменено"
count-all label "Просмотрено"
with side-labels view-as dialog-box.
view frame a.
    on write of trn-doc override do: end.
    clear-imp:
    do transaction
      on error undo clear-imp, return error
      on stop  undo clear-imp, return error :
      find trn-doc where trn-doc.doc-code = pardoc-code no-error.
      if available trn-doc then do:
        run delete-trn-doc in this-procedure .
      end.
      create trn-doc .
      assign
        trn-doc.doc-code  = pardoc-code
        trn-doc.cr-db-num = v-cntxt-db-num
        trn-doc.doc-type  = 'при':U
        trn-doc.internal  = no
        trn-doc.exch-code = e-code
      .
      assign
          v-obj-type = store-type
          v-obj-code = store-code
      .
    end.
frame a :title = frame-title.
put stream err unformatted fill (chr(10), 2) frame a :title fill (chr(10), 3).
assign varfile-scan = ?
       vararticle-supplier = no.
file-line:
repeat on endkey undo, leave :
  disp count-upd counter count-all with frame a.
  do on endkey undo, leave:
    import stream  inp unformatted source-string no-error.
  end.
  if error-status:error then undo, leave.
  if source-string = "" then
    next file-line.
  count-all = count-all + 1.
    assign
      vararticle-supplier = yes.
    if parcli-type = ? and
       parcli-code = ? then do:
      message "Нет данных по поставщику."
      view-as alert-box error.
      return error.
    end.
    else do:
      find first bf_clients where bf_clients.obj-type = parcli-type and
                                  bf_clients.obj-code = parcli-code no-lock no-error.
      if not available bf_clients then do:
        message "Ведем импорт по артикулу поставщика." skip
                "Не найден поставщик " parcli-type parcli-code " ."
        view-as alert-box error.
        return error.
      end.
    end.
  assign
    string-type     = "ITEM"
    text-string     = source-string
    i-artic-supp    = ""
    i-artic         = ""
    i-code          = ""
    i-prod-code     = 0
    i-scale         = ""
    i-prod-bc       = ""
    i-price         = 0
    i-qnty          = 0
    i-unit-cli      = ""
    i-cli-base-rate = 1
    i-d-pcnt        = 0
    i-VAT           = 0
    i-SLT           = 0
    size            = 1
    i-bc-on         = ?
    i-cst-code      = ""
    i-wt-brutto     = 0
    i-num-place     = 0
    .
  if num-entries (text-string, ";") <> 8 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Неправильное число параметров: " string (num-entries (text-string, ";"))
                  " (должно быть 8 ) . Пропускаем." chr(10).
    if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
    next file-line.
  end.
  assign
    i-artic-supp    = trim    (entry (1, text-string, ";"))
    i-prod-bc       = trim    (entry (2, text-string, ";"))
    i-code          = trim    (entry (2, text-string, ";"))
    i-qnty          = decimal (entry (3, text-string, ";"))
    i-price         = decimal (entry (4, text-string, ";"))
    i-cst-code      =          entry (5, text-string, ";")
    i-unit-cli      =          entry (6, text-string, ";")
    i-cli-base-rate = decimal (entry (7, text-string, ";"))
    i-VAT           = decimal (entry (8, text-string, ";"))
    .
    if i-unit-cli <> "" then do:
       find first units  where units.unit-name  = i-unit-cli no-lock no-error .
       if error-status :error then do:
         if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)        substitute ("Не верная единица измерения поставщика &1 . ",i-unit-cli ) chr(10).
         wrn-line = count-all.
         i-unit-cli      = "" .
         i-cli-base-rate = 0  .
       end.
    end.
   if i-cli-base-rate = 0 then i-cli-base-rate = 1.
   assign i-bc-on = yes.
  if i-artic-supp = "" then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустой артикул поставщика. Пропускаем." chr(10).
    if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
    next file-line.
  end.
  if i-qnty = 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустое поле количество. Пропускаем." chr(10).
    if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
    next file-line.
  end.
  if i-price = 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Пустое поле цена. Пропускаем." chr(10).
    if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
    next file-line.
  end.
if decimal(i-code) <> 0 then do:
   find first bar-code no-lock where bar-code.b-code = int(i-code) no-error .
end.
define variable v-gds-code as integer   no-undo .
      find first bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
                                  bf_cli-gds.cli-code  = parcli-code  and
                                  bf_cli-gds.host-code = parhost-code and
                                  bf_cli-gds.cli-art   = i-artic-supp no-lock no-error.
      if not available bf_cli-gds then do:
         if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)        substitute ("Не найден артикул поставщика &1 по фирме &2 для поставщика &3 &4. ", i-artic-supp, parhost-code, parcli-type, parcli-code) chr(10).
         wrn-line = count-all.
         run find-goods (output v-gds-code) .
         find first goods no-lock where goods.gds-code = v-gds-code no-error .
         if not error-status :error then do:
            if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted substitute ("Прошла идентификация товара по бар-коду &1 . ", i-code) chr(10).
            run add-cli-gds no-error .
            if error-status :error then
               next file-line.
         end.
         else do:
                run gbl/d-askw.w
                (input "Вопрос"
                ,input "По артиклу поставшика <" + i-artic-supp + ">, по фирме " + string (parHost-code) + " не найдено товара." + chr(10)
                  + "Ваши действия:" + chr(10)
                ,input "|^"
                ,input "Пропустить|Выбор"
                ,input "Артикул <" + i-artic-supp + "> не будет закачен|"
                    + "Предлагается справочник товаров, в нем надо выбрать товар , к которому припишется артикул поставщика <"  + i-artic-supp + ">"
                ,input 2
                ,input 1
                ,output v-num
                ).
              if v-num = 1 then do:
                if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Не удалось определить товар. Пропускаем." chr(10).
                if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
                next file-line.
              end.
              else do:
              run new-art-supp in this-procedure  (1) no-error .
                  if error-status :error then do:
                      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Не удалось определить товар. Пропускаем." chr(10).
                      if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
                      next file-line.
                  end.
              end.
         end.
      end.
  find  bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
                         bf_cli-gds.cli-code  = parcli-code  and
                         bf_cli-gds.host-code = parhost-code and
                         bf_cli-gds.cli-art   = i-artic-supp no-lock no-error.
  if available bf_cli-gds then do:
      assign
        i-artic     = bf_cli-gds.artic
        i-prod-code = bf_cli-gds.prod-code
        .
  end.
  else do:
        if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) substitute ("По артикулу поставщика &1 по фирме &2 для поставщика &3 &4 связан с несколькими товарами .", i-artic-supp, parhost-code, parcli-type, parcli-code) chr(10).
        wrn-line = count-all.
        run gbl/d-askw.w
        (input "Вопрос"
        ,input "По артиклу поставшика <" + i-artic-supp + ">, по фирме " + string (parHost-code) + " найдено несколько товаров." + chr(10)
          + "Ваши действия:" + chr(10)
        ,input "|^"
        ,input "Пропустить|Выбор"
        ,input "Артикул <" + i-artic-supp + "> не будет закачен|"
            + "Предлагается список товаров, в нем надо выбрать товар , который будет закачен в ПН"
        ,input 2
        ,input 1
        ,output v-num
        ).
      if v-num = 1 then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Не удалось определить товар. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
        next file-line.
      end.
      else do:
      run new-art-supp in this-procedure (2) no-error .
          if error-status :error then do:
              if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Не удалось определить товар. Пропускаем." chr(10).
              if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
              next file-line.
          end.
      end.
  end.
 if i-prod-code = 0  then do:
    run find-goods in this-procedure (output v-gds-code) .
    find first goods no-lock where goods.gds-code = v-gds-code no-error .
    if not error-status :error then do:
      i-artic     = goods.artic .
      i-prod-code = goods.prod-code.
      if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
      if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .
    end.
    else do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "По бар-коду не удалось определить товар. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
        next file-line.
    end.
 end.
    find first goods no-lock where goods.artic     =   i-artic       and
                                   goods.prod-code =   i-prod-code no-error  .
      if error-status :error then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) error-status :get-message(1) + i-artic + " " + string(i-prod-code) + " . Пропускаем." chr(10).
          if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
          next file-line.
      end.
define buffer bb_goods for goods.
  if decimal(i-code) <> 0 then do:
    find first bar-code no-lock where bar-code.b-code = int(i-code) no-error .
        run find-goods in this-procedure (output v-gds-code) .
        find first bb_goods no-lock where BB_goods.gds-code = v-gds-code no-error .
        if available bb_goods then do:
          if bb_goods.gds-code <> goods.gds-code then do:
              if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Бар-Код " + i-code + " принадлежит другому товару , с артиклом " +
              bb_goods.artic + " " + bb_goods.prod-type + string(bb_goods.prod-code) +
              ". Закачиваем товар " + goods.artic + " " + goods.prod-type + string(goods.prod-code) +
              " по базовым ед.изм." + chr(10).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
              find first bar-code where bar-code.b-code = v-b-code no-error .
          end.
        end.
        else do:
              if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Бар-Код " + i-code + " не найден в БД " + chr(10).
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
              find first bar-code where bar-code.b-code = v-b-code no-error .
        end.
  end.
   run body-proc in this-procedure (input goods.gds-code ) no-error .
   if error-status :error then   next file-line.
   run analiz-b-code in this-procedure (  i-artic-supp ,
                        goods.artic  ,
                        goods.gds-code ,
                        i-code       )
                        no-error .
   if error-status :error then
   do:
   message 124 .
   if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted  error-status :get-message(1) + return-value  + chr(10).
   next file-line.
   end.
   run body-proc in this-procedure (input goods.gds-code ) no-error .
   if error-status :error then next file-line.
  run imp-input-way-bill in this-procedure  no-error.
  if error-status:error then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted SUBSTITUTE("Ошибка при вызове внутренней процедуры imp-input-way-bill &1 &2 &3",
                                                  return-value,
                                                  error-status:get-message(1),
                                                  error-status:get-message(2))  + chr(10).
      next file-line.
    end.
END.
hide frame a .
procedure imp-prod-bc:
def buffer same-prod-bc  for prod-bc.
def buffer same-bar-code for bar-code.
def buffer same-goods    for goods.
if not available bar-code then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
  find first bar-code where bar-code.b-code = v-b-code no-error .
end.
if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted ">> Импорт доп.бар-код " + i-prod-bc  chr(10).
tr:
do on error undo tr, return error SUBSTITUTE("Ошибка при импорте доп. бар-кода &1 &2 &3 ", i-prod-bc, error-status:get-message(1), error-status:get-message(2)):
if  length (i-prod-bc) > 13  and
    not is-numeral (i-prod-bc,
                    "letter,digit") or
    length (i-prod-bc) <= 13  and
    not is-numeral (i-prod-bc,
                    "digit") then do:
  if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Доп. БК содержит пробелы или недопустимые символы. Пропускаем доп.бар-код." chr(10).
  return.
end.
if  i-prod-bc begins par-bc-pfx and
    (length (i-prod-bc) = 13 and
    par-bc-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-bc-frmt = "EAN8") or
    (i-prod-bc begins par-pl-pfx and
    par-pl-pfx <> ? and
    par-pl-frmt <> ?) and
    (length (i-prod-bc) = 13 and
    par-pl-frmt = "EAN13" or
    length (i-prod-bc) = 8 and
    par-pl-frmt = "EAN8") then do:
  if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Доп. БК имеет префикс, зарезервированный для собственных товарных (складских мест) бар-кодов. Пропускаем доп.бар-код." chr(10).
  return.
end.
if length (i-prod-bc) < 6 then do:
  if (lookup ('топ':U, goods-units.type) > 0 and
      lookup ('дро':U, goods-units.type) > 0 or
      lookup ('вес':U, goods-units.type) > 0) and
      goods.gds-type = 'т':U then do:
    if  lookup ('топ':U, goods-units.type) > 0 and
        lookup ('дро':U, goods-units.type) > 0 then do:
      if  lookup ('топ':U, units.type) > 0 and
          lookup ('дро':U, units.type) > 0 then do:
        if length (i-prod-bc) > 2 then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Топливный код: " + i-prod-bc + " не должен быть длиннее 2 разрядов. Пропускаем доп.бар-код." chr(10).
          return.
        end.
        find first  prod-bc where
                    prod-bc.b-code = bar-code.b-code and
                    prod-bc.b-str <> i-prod-bc no-lock no-error.
        if available prod-bc then do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Товар топливный. Уже есть топливный код у этого товара: " prod-bc.b-str
                     " Он должен быть только один. Пропускаем доп.бар-код." chr(10).
          return.
        end.
      end.
      else do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Товар топливный. Можно импортировать только топливный код (с дробно-топливной единицей измерения). Пропускаем доп.бар-код." chr(10).
        return.
      end.
    end.
    if lookup ('вес':U, goods-units.type) > 0 then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Код  " + i-prod-bc + " - весовой. Весовые коды не импортируются. Пропускаем доп.бар-код." chr(10).
      return.
    end.
  end.
  else do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Код короче 6 разрядов  " + i-prod-bc + " может соответствовать только весовому или дробному топливному товару. Пропускаем доп.бар-код." chr(10).
    return.
  end.
end.
else do:
  if  lookup ('топ':U, units.type) > 0 and
      lookup ('дро':U, units.type) > 0 or
      lookup ('вес':U, units.type) > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Весовой или топливный код  " + i-prod-bc + " не может быть длиннее 5 разрядов. Пропускаем доп.бар-код." chr(10).
    return .
  end.
end.
find first  same-prod-bc where
            same-prod-bc.b-str  = i-prod-bc and
            same-prod-bc.b-code = bar-code.b-code no-lock no-error.
if available same-prod-bc then do:
  if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Доп. БК: " + i-prod-bc + " уже есть в БД. Пропускаем доп.бар-код." chr(10).
  return.
end.
find first same-prod-bc where
           same-prod-bc.b-str = i-prod-bc and
           same-prod-bc.bc-on = yes       no-lock no-error.
if available same-prod-bc then do:
  find same-bar-code where
       same-bar-code.b-code = same-prod-bc.b-code no-lock.
  find same-goods where
       same-goods.gds-code = same-bar-code.gds-code no-lock.
  if  same-goods.prod-type = goods.prod-type AND
      same-goods.prod-code = goods.prod-code AND
      par-dif-pdbc = yes  then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
               ", он включен и соответствует тому же производителю. Пропускаем в соответствии с настройкой." chr(10).
    return.
  end.
  if par-dpl-off = yes then do:
    if i-bc-on = no then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код вЫключен. Таким его и добавляем." chr(10).
    end.
    else do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код тоже включен. Добавляем его вЫключеным в соответствии с настройкой." chr(10).
      assign
        i-bc-on = no.
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Имевшийся в БД доп. БК (см. предыдущее сообщение) для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", который был включен, вЫключаем в соответствии с настройкой" chr(10).
      do transaction on error undo, return error return-value:
        find current same-prod-bc exclusive-lock.
        assign
          same-prod-bc.bc-on = no.
      end.
   end.
  end.
  else do:
    if i-bc-on = yes then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код тоже включен. ВЫключаем уже имеющийся в базе код. Добавляемый оставляем включенным." chr(10).
      do transaction on error undo, return error return-value :
        find current same-prod-bc exclusive-lock.
        assign
          same-prod-bc.bc-on = no.
      end.
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он включен. Добавляемый код вЫключен. Добавляем код без изменений." chr(10).
    end.
  end.
end.
else do:
  find first same-prod-bc where
             same-prod-bc.b-str = i-prod-bc and
             recid (same-prod-bc) <> recid (prod-bc) no-lock no-error.
  if available same-prod-bc then do:
    find  same-bar-code where
          same-bar-code.b-code = same-prod-bc.b-code no-lock.
    find same-goods where
         same-goods.gds-code = same-bar-code.gds-code no-lock.
    if  same-goods.prod-type = goods.prod-type AND
        same-goods.prod-code = goods.prod-code AND
        par-dif-pdbc = yes  then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic
                 ", он вЫключен и соответствует тому же производителю. Пропускаем  доп.бар-код в соответствии с настройкой dif-pdbc." chr(10).
      return.
    end.
    if i-bc-on = yes then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он выключен. Добавляемый код включен. Добавляем код без изменений." chr(10).
    end.
    else do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "В БД уже есть такой доп. БК для товара: арт. : " same-goods.artic ", пр-ль : " same-goods.prod-code
                 ", он выключен. Добавляемый код вЫключен. Добавляем код без изменений." chr(10).
    end.
  end.
end.
do transaction on error undo, return error return-value :
  define variable rid as recid no-undo .
  rid = ?.
  run trg/prod-bc1.p (
                      input  parparentproc
                      ,input yes
                      ,input par-dif-pdbc
                      ,input ?
                      ,input no
                      ,input ''
                      ,input ""
                      ,buffer goods
                      ,input bar-code.b-code
                      ,input-output i-prod-bc
                      ,output rid
                      ) no-error.
  if error-status :error
  then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Ошибка при импорте доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code chr(10)
                 error-status:get-message(1) chr(10) return-value  chr(10).
  end.
  else if rid = ? then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Невозможно импортировать доп. БК для товара: арт. : " goods.artic ", пр-ль : " goods.prod-code chr(10)
                 error-status:get-message(1) chr(10) return-value  chr(10).
  end.
end.
assign
  counter = counter + 1.
end.
end procedure.
procedure imp-input-way-bill:
define variable n-c like gds-prt.node-code no-undo.
define buffer bf_doc-line-attr for doc-line-attr.
find doc-line where
     doc-line.doc-code  = trn-doc.doc-code and
     doc-line.artic     = goods.artic and
     doc-line.prod-code = goods.prod-code and
     doc-line.prod-type = goods.prod-type no-error.
if available doc-line then do:
  if doc-line.unit-cli      = i-unit-cli and
     doc-line.cli-base-rate = i-cli-base-rate then
    assign
      doc-line.cli-qnty      = doc-line.cli-qnty + i-qnty
      doc-line.price-cli     = i-price
      doc-line.unit-cli      = i-unit-cli
      doc-line.cli-base-rate = i-cli-base-rate
      .
  else do:
    if doc-line.cli-base-rate = i-cli-base-rate then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Единица измерения поставщика в строке ПН: " doc-line.unit-cli
                 " Не совпадает с импортируемой. Заменяем на: " i-unit-cli chr(10).
      doc-line.unit-cli = i-unit-cli.
    end.
    else do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Коэффициент в строке ПН: " doc-line.cli-base-rate
                 " Не совпадает с импортируемым. Заменяем единицу измерения поставщика на основную: " goods.unit-base
                 " и пересчитываем количества поставщика." chr(10).
      assign
        doc-line.unit-cli      = goods.unit-base
        doc-line.cli-qnty      = doc-line.cli-qnty * doc-line.cli-base-rate +
                                 i-qnty * i-cli-base-rate
        doc-line.cli-base-rate = 1
        doc-line.price-cli     = i-price / i-cli-base-rate
        .
    end.
  end.
end.
else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input trn-doc.doc-code
,input goods.artic
,input goods.prod-type
,input goods.prod-code
,input ''
,input 0
,input ''
,input ''
,input goods.prt-root
,input 0
,input 0
,input 0
) no-error
.
  if error-status:error then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted SUBSTITUTE("Ошибка при вызове процедуры crdoclin &1 &2 &3",
                            return-value,
                            error-status:get-message(1),
                            error-status:get-message(2))  + chr(10).
      return error.
  end.
  find first doc-line where doc-line.doc-code  = trn-doc.doc-code and
                            doc-line.artic     = goods.artic      and
                            doc-line.prod-type = goods.prod-type  and
                            doc-line.prod-code = goods.prod-code .
  assign
    doc-line.cli-qnty      = 0
    doc-line.doc-qnty      = 0
    doc-line.fact-qnty     = 0
    doc-line.price-cli     = i-price
    doc-line.unit-cli      = i-unit-cli
    doc-line.cli-base-rate = i-cli-base-rate
    doc-line.cli-qnty      = i-qnty
    doc-line.wt-brutto     = i-wt-brutto
    doc-line.num-place     = i-num-place
    .
end.
assign
  doc-line.VAT-pc        = v-VAT-pc
  doc-line.SLT-pc        = v-SLT-pc
  .
find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = doc-line.doc-code and
                                  bf_doc-line-attr.gds-code  = goods.gds-code    and
                                  bf_doc-line-attr.attr-code = "cst-code"        no-error.
if not available bf_doc-line-attr then do:
   create bf_doc-line-attr.
   assign
   bf_doc-line-attr.doc-code   = doc-line.doc-code
   bf_doc-line-attr.gds-code   = goods.gds-code
   bf_doc-line-attr.attr-code  = "cst-code"
   bf_doc-line-attr.attr-value = i-cst-code.
end.
if string-type = "SCALE" OR
   string-type = "CODE"  then
  n-c = gds-prt.node-code.
if string-type = "ITEM" then do:
  find first gds-prt where gds-prt.upper-code = goods.prt-root
       use-index level no-lock no-error.
  do while true:
    n-c = gds-prt.node-code.
    find first gds-prt where gds-prt.upper-code = n-c
         use-index level no-lock no-error.
    if not available gds-prt then
      leave.
  end.
end.
find gds-dtl where
     gds-dtl.doc-code  = trn-doc.doc-code and
     gds-dtl.artic     = goods.artic and
     gds-dtl.prod-code = goods.prod-code and
     gds-dtl.prod-type = goods.prod-type and
     gds-dtl.prt-code  = n-c no-error.
if not available gds-dtl then do:
  assign counter = counter + 1.
  create gds-dtl .
  assign
    gds-dtl.doc-code      = trn-doc.doc-code
    gds-dtl.artic         = goods.artic
    gds-dtl.prod-code     = goods.prod-code
    gds-dtl.prod-type     = goods.prod-type
    gds-dtl.prt-code      = n-c
  .
end.
assign
  doc-line.doc-qnty      = doc-line.doc-qnty + (i-qnty * i-cli-base-rate)
  doc-line.fact-qnty     = doc-line.doc-qnty
  doc-line.cli-base-rate = doc-line.doc-qnty / doc-line.cli-qnty
  gds-dtl.doc-qnty       = gds-dtl.doc-qnty + (i-qnty * i-cli-base-rate)
  gds-dtl.fact-qnty      = gds-dtl.doc-qnty
  count-upd              = count-upd + 1
  .
end procedure.
procedure delete-trn-doc :
  do
  on error undo, return error
  :
    for each doc-line
      where doc-line.doc-code = trn-doc.doc-code
    on error undo, return error
    :
      delete doc-line .
    end.
    for each gds-dtl
      where gds-dtl.doc-code = trn-doc.doc-code
    on error undo, return error
    :
      delete gds-dtl .
    end.
    delete trn-doc .
  end.
end procedure.
procedure body-proc :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code as integer   no-undo .
      FIND first goods WHERE
                 goods.gds-code = p-gds-code no-lock no-error.
      if available goods then do:
      end.
      else do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Товар с данными артикулом и кодом производителя (подразумевается организация) в БД отсутствует. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
        return error .
      end.
    if i-prod-code <> 0 then do:
        if goods.artic <> i-artic then do:
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Несоответствие доп.бар-кода и артикула поставщика. Взят по доб.бар-коду." + goods.artic chr(10).
        end.
    end.
    assign
     i-artic     = goods.artic
     i-prod-code = goods.prod-code
    .
      if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
      if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .
    if i-unit-cli = "" then do:
      if available bar-code then do:
          assign
            i-cli-base-rate = bar-code.cli-base-rate
            i-unit-cli      = bar-code.unit-cli
            .
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   " Бар-код : "                    bar-code.b-code   " Единица измерения Бар-кода : " bar-code.unit-cli   " коэффициент Бар-кода : "        bar-code.cli-base-rate   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Не указаны единица измерения и коэффициент. Берем из собственного кода." chr(10).
       end.
       else do:
          assign
            i-cli-base-rate = 1
            i-unit-cli      = goods.unit-base
            .
          if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Не указаны единица измерения и коэффициент. Берем из товара базовые ед.изм." chr(10).
       end.
    end.
    if available bar-code and decimal(i-code) > 0 then do:
      find first gds-prt where gds-prt.node-code = bar-code.node-code no-lock.
      if gds-prt.is-term <> yes       then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Код " i-code " не является кодом терминального признака. Пропускаем." chr(10).
        if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.
        return error .
      end.
      else do:
            if gds-prt.node-name <> '_Пустая шкала':U then do:
                assign
                  string-type = "SCALE"
                  i-scale     = gds-prt.f-name .
                .
            end.
            else do:
                assign
                  string-type  = "ITEM"
                  i-scale      = ""
                .
            end.
      end.
    end.
   if i-scale <> ""  then do:
      find first  gds-prt where
                  gds-prt.prt-root = goods.prt-root and
                  gds-prt.is-term  = yes            and
                  gds-prt.f-name   = i-scale        no-lock no-error.
      if not available gds-prt then do:
        define variable varqnty-slash as integer no-undo.
        define variable varnum-symb   as integer no-undo.
        define variable vari-scale    like i-scale no-undo.
        assign varqnty-slash = 0.
        do varnum-symb = 1 to length(i-scale):
          if substring (i-scale, varnum-symb , 1) = "/" then do:
            assign
              varqnty-slash = varqnty-slash + 1.
          end.
        end.
        if varqnty-slash = 1 then do:
          assign
            vari-scale = substring (i-scale, r-index (i-scale, "/") + 1).
          find first  gds-prt where
                  gds-prt.prt-root = goods.prt-root and
                  gds-prt.is-term  = yes            and
                  gds-prt.f-name   = vari-scale        no-lock no-error.
          if not available gds-prt then do:
            if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Узел шкалы " i-scale " не найден. Пропускаем." chr(10).
            return error .
          end.
          else do:
            if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Узел шкалы не найден. Но НАЙДЕН для одноуровневой шкалы по нижнему уровню. Пропускаем." chr(10).
            return error .
          end.
        end.
        else do:
          if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Узел шкалы не найден. Пропускаем." chr(10).
          return error .
        end.
      end.
   end.
  find goods-units where
       goods-units.unit-name = goods.unit-base no-lock.
  if i-unit-cli = "" then
    assign
      i-unit-cli = goods.unit-base
      i-cli-base-rate = 1
      .
  if v-obj-type = ? or
     v-obj-code = ? then do:
     assign
       v-obj-type = store-type
       v-obj-code = store-code.
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-today
  )  .
  assign
    v-vat-pc = ?
    v-slt-pc = ?
  .
  define variable v-inout-price as logical   no-undo .
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop .
  case v-obj-type :
    when 'скл':U
    then do:
      find buf_store no-lock
        where buf_store.obj-code = v-obj-code
        no-error .
      if not available buf_store
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден склад." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_store.inout-price
      .
    end.
    when 'маг':U
    then do:
      find buf_shop no-lock
        where buf_shop.obj-code = v-obj-code
        no-error .
      if not available buf_shop
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найден магазин." skip
          v-obj-type v-obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-inout-price = buf_shop.inout-price
      .
    end.
  end.
  if v-inout-price = true
  then do:
    if i-VAT = 0
    then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-vat-pc
  ) no-error .
    end.
    else do:
      assign
        v-vat-pc = i-VAT
      .
    end.
  end.
  else do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  '1':U
  ,input  i-VAT
  ,input  v-today
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-vat-pc
  ) no-error .
    if v-vat-pc = ? then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-vat-pc
  ) no-error .
    end.
  end.
  if v-inout-price = true
  then do:
    if i-SLT = 0
    then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-slt-pc
  ) no-error .
    end.
    else do:
      assign
        v-slt-pc = i-SLT
      .
    end.
  end.
  else do:
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  '2':U
  ,input  i-SLT
  ,input  v-today
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-slt-pc
  ) no-error .
    if v-slt-pc = ? then do:
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  v-obj-type
  ,input  v-obj-code
  ,output v-slt-pc
  ) no-error .
    end.
  end.
  if v-vat-pc = ?
  then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted substitute("Получено неопреледенное значение НДС. Код ставки НДС &1. Пропускаем.", i-vat) chr(10).
    return error .
  end.
  if v-slt-pc = ?
  then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted substitute("Получено неопреледенное значение НП. Код ставки НП &1. Пропускаем.", i-slt) chr(10).
    return error .
  end.
  if lookup ('шту':U, goods-units.type) > 0 and
     i-cli-base-rate <> truncate (i-cli-base-rate, 0) then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Для штучного товара коэффициент должен быть целым числом. Пропускаем." chr(10).
    return error .
  end.
  if lookup ('вес':U, goods-units.type)  > 0 and
     not lookup (string-type, "ITEM,PART") > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Товар весовой : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." chr(10).
    return error .
  end.
  if lookup ('сер':U, goods-units.type) > 0 and
     not lookup (string-type, "ITEM,PART") > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Товар серийный : Тип строки должен быть ITEM, PART, либо CODE для товара. Пропускаем." chr(10).
    return error .
  end.
  if lookup ('топ':U, goods-units.type) > 0 and
     lookup ('дро':U, goods-units.type) > 0 and
     goods.gds-type = 'т':U then do:
    if not lookup (string-type, "ITEM") > 0 then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Товар топливный : Тип строки должен быть ITEM, либо CODE для товара. Пропускаем." chr(10).
      return error .
    end.
    if i-unit-cli <> goods.unit-base then do:
      if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Товар топливный : Единица измерения должна совпадать с основной. Пропускаем." chr(10).
      return error .
    end.
  end.
  find units where units.unit-name = i-unit-cli no-lock no-error.
  if not available units then do:
    if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Единица измерения =  '" i-unit-cli "' отсутствует в справочнике."   chr(10).
     find units where units.unit-name = goods.unit-base no-lock no-error.
     if not available units then do:
        if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Единица измерения отсутствует в справочнике. Пропускаем." chr(10).
        return error .
     end.
     else
     if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Единица измерения  взята базовая. " units.unit-name  chr(10).
  end.
  if i-cli-base-rate <= 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Коэффициент должен быть больше 0. Пропускаем." chr(10).
    return error .
  end.
  if i-cli-base-rate = ? then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Коэффициент не должен иметь неопределенное значение. Пропускаем." chr(10).
    return error .
  end.
  if i-unit-cli <> goods.unit-base and
     i-cli-base-rate = 1 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Единица измерения не совпадает с основной - а коэффициент 1! Пропускаем. " chr(10).
    return error .
  end.
  if i-unit-cli = goods.unit-base and
     i-cli-base-rate <> 1 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Единица измерения совпадает с основной. Коэффициент должен быть равен 1. Пропускаем." chr(10).
    return error .
  end.
  if  i-cli-base-rate = 1 and
      i-d-pcnt <> 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Коэффициент равен 1. Скидка должна быть равна 0. Пропускаем." chr(10).
    return error .
  end.
  if i-cli-base-rate > 1 and
      i-d-pcnt < 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Коэффициент больше 1. Скидка должна быть больше или равна 0. Пропускаем." chr(10).
    return error .
  end.
  if i-cli-base-rate < 1 and
      i-d-pcnt > 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Коэффициент меньше 1. Скидка должна быть меньше или равна 0. Пропускаем." chr(10).
    return error .
  end.
  if  i-price < 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Цена неправильная. Пропускаем." chr(10).
    return error .
  end.
  if i-price = ? or
      i-price = 0 then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Цена неправильная. Пропускаем." chr(10).
    return error .
  end.
  end.
end procedure.
procedure analiz-b-code :
  do
  on error undo, return error return-value
  :
 define input  parameter p-artic-supp as character no-undo .
 define input  parameter p-artic as character no-undo .
 define input  parameter p-gds-code as integer   no-undo .
 define input  parameter p-b-code as character no-undo .
 define buffer buf_goods for goods .
 define buffer buf2_goods for goods .
 find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
 if p-b-code = "" or p-b-code = ? then do:
    run make-doc-line-base in this-procedure (p-gds-code) .
    return .
  end.
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parParentProc
,input  p-b-code
,input  ?
,input  store-type
,input  store-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer bar-code
,buffer prod-bc
,buffer place
) no-error.
    if not available bar-code then do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Код " + p-b-code + " для поиска в БД отсутствует. "  chr(10).
      run get-bar-code in this-procedure no-error.
      if error-status:error then return error return-value .
      run make-new-bar-code in this-procedure no-error .
      if error-status :error then return error return-value .
    return .
    end.
    if buf_goods.gds-code = bar-code.gds-code then do:
        run make-doc-line-bar-code in this-procedure  no-error .
        if error-status :error then return error return-value .
        return .
    end.
    if buf_goods.gds-code <> bar-code.gds-code then do:
       find first buf2_goods no-lock where buf2_goods.gds-code = bar-code.gds-code no-error .
        if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Бар-Код " +  p-b-code + " принадлежит другому товару , с артиклом " +
                       buf2_goods.artic + " " + buf2_goods.prod-type + string(buf2_goods.prod-code) +
                       "." + chr(10).
        run make-doc-line-base in this-procedure (p-gds-code) no-error .
        if error-status :error then return error return-value .
        return .
    end.
  end.
end procedure.
procedure make-doc-line-bar-code :
  do
  on error undo, return error return-value
  :
    if i-cli-base-rate <> 0  then i-cli-base-rate = bar-code.cli-base-rate .
    if i-unit-cli      <> "" then  i-unit-cli      = bar-code.unit-cli     .
  end.
end procedure.
procedure make-doc-line-base :
  do
  on error undo, return error return-value
  :
define input  parameter p-gds-code as integer   no-undo .
find first goods no-lock where goods.gds-code = p-gds-code no-error .
  if i-unit-cli = ""     then  i-unit-cli      = goods.unit-cli      .
  if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  goods.gds-code
  ,input  ?
  ,output v-b-code
  )  .
find first bar-code where bar-code.b-code = v-b-code no-error .
  end.
end procedure.
procedure make-new-bar-code :
  do
  on error undo, return error return-value
  :
run imp-prod-bc in this-procedure .
  end.
end procedure.
procedure find-goods :
do
on error undo, return error return-value
:
define output parameter p-gds-code as integer   no-undo .
define buffer bb_bar-code  for bar-code .
define buffer bb_prod-bc   for prod-bc  .
define buffer bb_place     for place    .
p-gds-code = ? .
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  parParentProc
,input  i-code
,input  ?
,input  store-type
,input  store-code
,input  yes
,input  no
,input  varscales-pref
,input  varpgscales-pref
,output varresult
,output vartype-bc
,output varweight
,buffer bb_bar-code
,buffer bb_prod-bc
,buffer bb_place
) no-error.
    if available bb_bar-code then do:
       p-gds-code = bb_bar-code.gds-code.
    end.
end.
end procedure.
procedure new-art-supp :
  do
  on error undo, return error return-value
  :
define input  parameter v-mode as integer   no-undo .
define variable var-gds-code as integer   no-undo .
define variable v-stat as character no-undo init ?.
define variable v-list as character no-undo init ?.
define variable v-prod-type like ub.clients.obj-type no-undo .
define variable v-prod-code like ub.clients.obj-code no-undo .
define variable new-ref-list as character no-undo init "" .
define variable i as integer   no-undo .
if v-mode = 1 then do:
    run ref/gds-ref.p
    (   parParentProc
      , "b-sel,b-add"
      , 'текущие':U
      , 'все':U
      , 'все':U
      , ?
      , ?
      , ?
      , ?
      , store-type
      , store-code
      , ?
      , output new-ref-list).
      find first goods no-lock where recid(goods) = integer (new-ref-list) no-error .
      if error-status :error then return error return-value .
      run add-cli-gds in this-procedure  no-error .
      if error-status :error then return error return-value .
end.
if v-mode = 2 then do:
define variable v-ret as character no-undo .
define variable vattr-codes as character no-undo .
define variable vattr-labels as character no-undo .
define buffer bb_cli-gds for cli-gds.
define buffer bb_goods for goods.
for each bb_cli-gds no-lock where
      bb_cli-gds.cli-type  = parcli-type  and
      bb_cli-gds.cli-code  = parcli-code  and
      bb_cli-gds.host-code = parhost-code and
      bb_cli-gds.cli-art   = i-artic-supp ,
   first bb_goods no-lock where
      bb_goods.artic      = bb_cli-gds.artic and
      bb_goods.prod-type  = bb_cli-gds.prod-type and
      bb_goods.prod-code  = bb_cli-gds.prod-code :
      vattr-codes  = vattr-codes  + chr(1) + string (bb_goods.gds-code) .
      vattr-labels = vattr-labels + chr(1) +  string(bb_goods.artic,"x(16)") + " " + bb_goods.gds-name.
end.
run gbl/d-list.w
(    INPUT "b-sel":U
    ,INPUT "К артиклу поставщика <" + i-artic-supp +  "> прикреплены"
    ,INPUT vattr-codes
    ,INPUT vattr-labels
    ,INPUT chr(1)
    ,INPUT "":U
    ,output v-ret ) .
      find first goods no-lock where goods.gds-code = integer (v-ret) no-error .
      if error-status :error then return error return-value .
      i-artic     = goods.artic .
      i-prod-code = goods.prod-code.
      if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
      if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .
end.
  end.
end procedure.
procedure add-cli-gds :
  do
  on error undo, return error return-value
  :
  i-artic     = goods.artic .
  i-prod-code = goods.prod-code.
  if i-unit-cli = ""    then  i-unit-cli  = goods.unit-base .
  if i-cli-base-rate = 0 then i-cli-base-rate = goods.cli-base-rate .
  find first bf_cli-gds where bf_cli-gds.cli-type  = parcli-type  and
             bf_cli-gds.cli-code  = parcli-code  and
             bf_cli-gds.host-code = parhost-code and
             bf_cli-gds.artic     = goods.artic and
             bf_cli-gds.prod-code = goods.prod-code and
             bf_cli-gds.prod-type = goods.prod-type
             exclusive-lock no-error.
    if not available bf_cli-gds then do:
        create cli-gds.
        assign
        cli-gds.cli-type  = parcli-type
        cli-gds.cli-code  = parcli-code
        cli-gds.host-code = parhost-code
        cli-gds.cli-art   = i-artic-supp
        cli-gds.artic     = goods.artic
        cli-gds.prod-code = goods.prod-code
        cli-gds.prod-type = goods.prod-type
        .
       if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted substitute ("артикул поставщика &1 по фирме &2 для поставщика &3 &4. Добавлен по товару &5 &6.", i-artic-supp, parhost-code, parcli-type, parcli-code, goods.artic ,goods.gds-name) chr(10).
    end.
    else do:
      if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "У товара найденого по бар-коду артикул поставщика = < " + bf_cli-gds.cli-art + " >" chr(10).
          if  bf_cli-gds.cli-art   = "" then bf_cli-gds.cli-art   = i-artic-supp .
          else do:
              if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "У товара найденого по бар-коду уже есть артикул , не равный артикул поставщика "  bf_cli-gds.cli-art  ". Пропускаем." chr(10) skip.
              return error return-value .
          end.
    end.
  end.
end procedure.
procedure get-bar-code:
define variable s-in-code   like parts.in-code   no-undo.
define variable s-part-code like parts.part-code no-undo.
define variable new-bar-code as log              no-undo.
define variable n-c like gds-prt.node-code no-undo.
  assign
    s-in-code   = ""
    s-part-code = ""
    .
find-create-bc:
do transaction
on error undo find-create-bc, return error
on stop  undo find-create-bc, return error :
  find first gds-prt where gds-prt.upper-code = goods.prt-root
       use-index level no-lock no-error.
  do while true:
    n-c = gds-prt.node-code.
    find first gds-prt where gds-prt.upper-code = n-c
         use-index level no-lock no-error.
    if not available gds-prt then  leave.
  end.
 if not available gds-prt then do:
    find first  gds-prt where
          gds-prt.prt-root = goods.prt-root and
          gds-prt.is-term  = yes
          no-lock no-error.
  end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  goods.gds-code
  ,input  gds-prt.node-code
  ,input  s-part-code
  ,input  s-in-code
  ,input  i-unit-cli
  ,input  i-cli-base-rate
  ,output new-bar-code
  ,buffer bar-code
  ) no-error .
  if error-status:error then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10) "Ошибка при поиске / создании собственного кода " + error-status :get-message(1) + ". Пропускаем." chr(10).
    undo find-create-bc, return error.
  end.
  if new-bar-code then do:
    if wrn-line <> count-all then     put stream wrn unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   " Бар-код : "                    bar-code.b-code   " Единица измерения Бар-кода : " bar-code.unit-cli   " коэффициент Бар-кода : "        bar-code.cli-base-rate   chr(10).   if wrn-line <> count-all then do:     put stream wrn unformatted     source-string     chr(10).     wrn-line = count-all.   end.   put stream wrn unformatted "Создан собственный код с единицей измерения из входного файла." chr(10).
  end.
  if bar-code.cli-base-rate <> i-cli-base-rate then do:
    if msg-line <> count-all then     put stream err unformatted     "------------------------------------------------------------------------------------" chr(10)     "Строка №: " count-all chr(10)   " Артикул : "                      goods.artic   " Производитель : "                goods.prod-type   " "                                goods.prod-code   " Код товара : "                   goods.gds-code   " Основная единица измерения : "   goods.unit-base chr(10)   " Бар-код : "                     bar-code.b-code   " Единица измерения Бар-кода : " bar-code.unit-cli   " коэффициент Бар-кода : "        bar-code.cli-base-rate   chr(10).   if msg-line <> count-all then do:     put stream err unformatted     source-string     chr(10).        end.   put stream err unformatted "Коэффициент в собственном коде не совпадает с указанным в файле. Пропускаем." chr(10).
    undo find-create-bc, return error.
  end.
end.
end procedure.
