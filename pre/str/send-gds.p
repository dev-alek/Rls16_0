block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Простая пересылка товаров на кассу по списку товаров":U.
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-cntxt-db-num        as integer   no-undo .
define variable v-cntxt-userid        as character no-undo .
define variable i-obj-code like ub.clients.obj-code no-undo.
define variable p-batch as logical no-undo .
define variable action     as   character no-undo init "U".
define variable p-other    as character no-undo .
define variable onecash    as int no-undo .
assign
i-obj-code = integer(entry(1, p-parameter, chr(4)))
p-batch  = (if entry(2, p-parameter, chr(4)) = "yes"
            then yes
            else (if entry(2, p-parameter, chr(4)) = "no"
                  then no
                  else ?)
           )
p-other = (if num-entries(p-parameter, chr(4)) > 2
           then entry(3, p-parameter, chr(4))
           else "":U)
no-error
.
if error-status:error or p-batch = ? then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
if num-entries(p-parameter, chr(4)) > 3
   and entry(4, p-parameter, chr(4)) ne ""
then
   onecash = int (entry(4, p-parameter, chr(4))) no-error.
if not g#news
and not g#auto then do:
run get-userid in parparentproc ( output v-cntxt-userid) .
run get-db-num in parparentproc ( output v-cntxt-db-num) .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table gds-list no-undo like ub.goods
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
define  shared  temp-table gds-list-hist no-undo
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
define variable v-production-only as logical init false.
for each gds-list :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  gds-list.gds-code
  ,input  'production-only=request':u
  ,output v-production-only
  ) no-error .
  if error-status :error
  then do:
    assign v-production-only = no .
  end.
  if v-production-only
  then do :
    delete gds-list .
  end .
end .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def new shared var bc-frmt as character no-undo .
def new shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "",  no , output bc-frmt, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U OR not can-do ("EAN8,EAN13", bc-frmt) ) then
        do:
            message "Не задан или не верно задан ТИП собственного бар-кода!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "",  no , output bc-pfx, output bc-par-type) no-error.
    if "new" = "bc" AND ( error-status:error OR bc-par-type <> "C":U ) then
        do:
            message "Не задан или не верно задан ПРЕФИКС бар-кода складского места!"
                view-as alert-box ERROR TITLE "".
            return error.
        end.
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str4  as character no-undo.
  define variable tmp-num4  as character no-undo.
  define variable i4        as integer   no-undo.
  define variable sum4      as integer   no-undo.
  define variable len-code4 as integer   no-undo.
  define variable varcont4  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str4 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont4 = yes then do:
    if integer( substring( tmp-str4, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str4, length( bc-pfx ) + 1, length( tmp-str4 ) - length( bc-pfx ) )
        len-code4    = length( full-b-code )
      .
      define variable v-sum-char4 as character no-undo .
      assign
        sum4 = 0
      .
      do i4 = 1 to len-code4 by 2
      :
        assign
          v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
        .
        if v-sum-char4 < "0"
        or v-sum-char4 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum4 = sum4 + integer(v-sum-char4)
        .
      end.
      if varcont4 = yes then do:
        assign
          sum4 = sum4 * 3
        .
        do i4 = 2 to len-code4 by 2
        :
          assign
            v-sum-char4 = substr(full-b-code, len-code4 - i4 + 1, 1)
          .
          if v-sum-char4 < "0"
          or v-sum-char4 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum4 = sum4 + integer(v-sum-char4)
          .
        end.
        if varcont4 = yes then do:
           if sum4 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum4 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile: defc-gds.i $ $Revision: 47e5c2a27e63, 2885, rls $".
DEFINE  TEMP-TABLE cash-gds no-undo
FIELD gds-code          like ub.goods.gds-code
FIELD artic             like ub.goods.artic
FIELD producer-int      as integer
FIELD b-code            like ub.bar-code.b-code
FIELD b-str             like ub.prod-bc.b-str
FIELD bc-on              like ub.prod-bc.bc-on
FIELD gds-name          like ub.goods.gds-name
FIELD gds-namelong      like ub.goods.gds-name
FIELD gds-name1         like ub.goods.gds-name
FIELD f-name            like ub.gds-prt.f-name
FIELD unit-base         like ub.goods.unit-base
FIELD unit-cli          like ub.bar-code.unit-cli
FIELD cli-base-rate     like ub.bar-code.cli-base-rate
FIELD std-discnt-rule   as integer
FIELD temp-discnt-rule  as integer
FIELD temp-discnt-method as character
FIELD VAT-pc            like ub.doc-line.VAT-pc
FIELD vat-code          like ub.tax-rate-gds.rate-code
FIELD SLT-pc            like ub.doc-line.SLT-pc
FIELD grp-code          like ub.goods.grp-code
FIELD gds-stat          as integer FORMAT "999"
FIELD wd-rule          as integer
FIELD wgd-rule         as integer
FIELD fp               as logical
FIELD zp               as integer
FIELD pp               as integer
FIELD need-auth        as integer
FIELD is-menu          as integer
FIELD is-semi-finished as integer
FIELD is-modificator   as integer
FIELD DepartId         as integer
FIELD fbr-grp-code-0   as integer
FIELD fbr-grp-code     as integer
FIELD office           as integer
field office-type      as character
FIELD CalculationMethod      as integer
FIELD CalculationMethodRestr as integer
FIELD price-sale       like ub.price-list.price-sale
FIELD unit-type        like ub.units.type
FIELD unit-cli-type    like ub.units.type
FIELD tax-string       as char FORMAT "X(255)"
FIELD qnty-discnt-rule as integer
FIELD kat-discnt-rule  as integer
FIELD kat-discnt-method as character
FIELD date-discnt-rule as integer
FIELD abs-discnt-rule  as integer
FIELD tot-discnt-rule  as integer
FIELD fact-qnty        like ub.gds-obj.fact-qnty
FIELD free-qnty        like ub.gds-obj.free-qnty
FIELD producer         as character format "X(40)"
FIELD ingredient       as character format "X(40)"
FIELD GTD              as character format "X(31)"
FIELD alpha1           like ub.goods.alpha
FIELD node-code        like ub.bar-code.node-code
FIELD okei             like ub.units.okei
FIELD kkt              as integer
FIELD is-gas           as logical
FIELD ptrl-as-good     as logical
FIELD taracode         as character
FIELD crf              as integer
FIELD new-good         as logical
FIELD rc               as recid
FIELD obj-type         as character
FIELD obj-code         as integer
field is-main-code     as logical
field bc-on-type       as character
field main-prt-b-code  as integer
field ean-lz as character
field ean-rz as character
field code-short as  character
index pi is unique primary crf
index bc b-code
index pbc b-str
index igds gds-code
index mbc obj-type obj-code main-prt-b-code
.
define temp-table temp-dis-gds-rule no-undo
like ub.dis-gds-rule.
define temp-table cash-gds-discnt
FIELD crf              as integer
FIELD b-code            like ub.bar-code.b-code
field discnt-value as decimal
FIELD rule-num     as integer
field obj-type     as character
field obj-code     as integer
index pi is unique primary crf
index bc
b-code
obj-type
obj-code
rule-num
.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table cash-ncr-dis-kat no-undo
field cd-subject-code as character
field cd-subject-name as character
field dis-kat    like ub.dis-rule.dis-kat
field rule-num   like ub.dis-rule.rule-num
field time-rule-num like ub.dis-rule.time-rule-num
field crf as integer
field subject-code   as character
FIELD cd-disc-string    as character
field cd-other  as character
index pi is unique primary crf
index isubject cd-subject-code dis-kat
index idiskat dis-kat cd-subject-code cd-disc-string
.
define temp-table temp-dis-kat-file no-undo
field temp-file as character
field send-file as character
field to-send as logical
field dis-kat as integer
index pi is unique primary dis-kat
index isend to-send
.
define temp-table cash-ncr-save-param no-undo
field cd-line as character
field cd-other as character
field dis-kat as integer
index pi is unique primary dis-kat cd-line
.
 define variable v-found-good as log no-undo .
 define variable i-host-code as int no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table cash-txr no-undo
  field tax-code    like ub.tax.tax-code
  field rate-code   like ub.tax-rate.rate-code
  field host-code   like ub.sysconf.host-code
  field obj-type    like ub.clients.obj-type
  field obj-code    like ub.clients.obj-code
  field tax-type    like ub.tax.tax-type
  field status_     like ub.tax-rate-value.status_
  field rate-value  as decimal
  field rc          as recid
  field crf         as integer
  field news-action as logical
  index pi is unique primary tax-code host-code obj-type obj-code status_ rc
  index crf-i  crf host-code obj-type obj-code rc
.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION round-m RETURNS DECIMAL(input  mysum as decimal,
                                                                  input  orders as integer):
define variable  round-m-sum as decimal no-undo.
if orders >= 0 then
round-m-sum = round(mysum,orders).
else
round-m-sum = round(mysum / exp(10, abs(orders)), 0) * EXP(10, abs(orders)).
return round-m-sum.
END FUNCTION.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define temp-table  tt-tax no-undo
  field tax-code    like ub.tax.tax-code
  field individual  like ub.tax.individual
  field tax-name    like ub.tax.tax-name format "x(12)" column-label "Налог"
  field rate-code   like ub.tax-rate.rate-code
  field rate-name   like ub.tax-rate.rate-name format "x(12)"
  field tax-type    like ub.tax.tax-type
  field rate-value  like ub.tax-rate-value.rate-value
  field tax-rate-gds-rc  as recid
  field to-cashdesk like ub.tax.to-cashdesk
  index tax-code is unique primary tax-code
  .
procedure tax-val :
  define input  parameter       parartic      like ub.doc-line.artic     no-undo.
  define input  parameter       parprod-type  like ub.doc-line.prod-type no-undo.
  define input  parameter       parprod-code  like ub.doc-line.prod-code no-undo.
  define input  parameter       parunit-base  like ub.goods.unit-base    no-undo.
  define input  parameter       parnode-code  like ub.gds-prt.node-code  no-undo.
  define input  parameter       parunits-type like ub.units.type         no-undo.
  define input  parameter       parrec-id     as recid                   no-undo.
  define input  parameter       paris-log     as logical                 no-undo.
  define input  parameter       rdtaxcdvalue  as integer                 no-undo.
  define input  parameter       vattaxcdvalue as integer                 no-undo.
  define input  parameter       exctaxcdvalue as integer                 no-undo.
  define input  parameter       only-check    as logical                 no-undo.
  define input  parameter       parhost-code  like ub.sysconf.host-code  no-undo.
  define input  parameter       parobj-type   like ub.clients.obj-type   no-undo.
  define input  parameter       parobj-code   like ub.clients.obj-code   no-undo.
  define input  parameter       parroad-tax   like ub.doc-line.road-tax  no-undo.
  define input  parameter       parexcise     like ub.doc-line.excise    no-undo.
  define output parameter       parerr-mes    as character               no-undo.
  define input-output parameter parprice-sale like ub.price-list.price-sale no-undo.
  do
  on error undo, return error return-value
  :
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
    define buffer buf_tax          for ub.tax .
    define buffer buf_tax-rate     for ub.tax-rate .
    define buffer buf_tax-units    for ub.tax-units .
    define buffer buf_tax-rate-gds for ub.tax-rate-gds .
    define buffer buf_goods        for ub.goods .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_prod-bc      for ub.prod-bc .
    define buffer buf_units        for ub.units .
    define buffer buf_shop         for ub.shop .
    define buffer buf_store        for ub.store .
    define buffer buf_gds-prt      for ub.gds-prt .
    define buffer buf_tt-tax       for tt-tax .
    define variable varrate-value    as decimal   initial ? no-undo.
    define variable pr-list-recid    as recid     initial ? no-undo.
    define variable varmes           as character no-undo.
    define variable varfactorrtvalue as char      initial ? no-undo.
    define variable varfactorrttype  as char      initial ? no-undo.
    define variable is-petrolium     as logical no-undo.
    define variable is-pieces        as logical no-undo.
    define variable vargds-code      like ub.goods.gds-code no-undo.
    define variable pargds-code      like ub.goods.gds-code no-undo.
    define variable var-fact-order   as decimal no-undo .
    define variable currate-code     like buf_tax-rate.rate-code no-undo .
    define variable currate-name     like buf_tax-rate.rate-name no-undo .
    define variable currate-gds-rc   as recid no-undo .
    define variable v-today          as date no-undo .
    define variable v-time           as integer no-undo .
    for each buf_tt-tax:
      delete buf_tt-tax.
    end.
    run cur-time in this-procedure(output v-today, output v-time).
    run factord-end-day in this-procedure (input v-today, output var-fact-order).
    if parartic     = ?
    or parprod-type = ?
    or parprod-code = ?
    or parunit-base = ?
    then do:
      find first buf_goods no-lock
        where recid(buf_goods) = parrec-id
        no-error .
    end.
    else do:
      find first buf_goods no-lock
        where buf_goods.artic = parartic
          and buf_goods.prod-type = parprod-type
          and buf_goods.prod-code = parprod-code
        no-error .
    end.
    if not available buf_goods then do:
      assign varmes = "Ошибка при поиске товара. Программа tax-val.i" + chr(10) .
      if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
    end.
    assign
      parartic     = buf_goods.artic
      parprod-type = buf_goods.prod-type
      parprod-code = buf_goods.prod-code
      parunit-base = buf_goods.unit-base
      pargds-code  = buf_goods.gds-code
    .
    if parunits-type = ?
    then do:
      find buf_units no-lock
        where buf_units.unit-name = parunit-base
        no-error .
      if not available buf_units then do:
        assign
          varmes =  varmes + "Ошибка при поиске единицы измерения. Программа tax-val.i" + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
      assign
        parunits-type = buf_units.type
      .
    end.
    if parhost-code = ?
    or parhost-code = 0
    then do:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  abs(parobj-code)
  ,output parhost-code
  ) no-error .
      if error-status :error then do:
        assign
          varmes =  varmes + substitute("Ошибка при определении фирмы для объекта &1 &2. Программа tax-val.i"
            ,string(parobj-type)
            ,string(parobj-code)
            ) + chr(10)
        .
        if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
      end.
    end.
    assign
      vargds-code = buf_goods.gds-code
    .
    for each buf_tax-units no-lock
      where LOOKUP(buf_tax-units.type, parunits-type) > 0
    ,first buf_tax no-lock
      where buf_tax.tax-code = buf_tax-units.tax-code
    :
      find first buf_tt-tax where
                 buf_tt-tax.tax-code = buf_tax.tax-code no-error .
      if not available buf_tt-tax then do:
        create buf_tt-tax .
      end.
      assign
        buf_tt-tax.tax-code = buf_tax.tax-code
      .
      if buf_tax.individual = false then do:
        assign
          currate-gds-rc = ?
        .
        _tax-rate-gds:
        for each buf_tax-rate-gds no-lock where
                buf_tax-rate-gds.gds-code = pargds-code and
                buf_tax-rate-gds.tax-code = buf_tax.tax-code,
        first buf_tax-rate where
              buf_tax-rate.tax-code  = buf_tax-rate-gds.tax-code and
              buf_tax-rate.rate-code = buf_tax-rate-gds.rate-code no-lock
        by buf_tax-rate-gds.host-code
        by buf_tax-rate-gds.obj-type
        by buf_tax-rate-gds.obj-code
        by buf_tax-rate-gds.fact-order
        :
          if buf_tax-rate-gds.fact-order > var-fact-order then do:
            next _tax-rate-gds.
          end.
          if buf_tax-rate-gds.host-code = 0 or
            ((buf_tax-rate-gds.host-code = parhost-code) or
            (buf_tax-rate-gds.obj-type = parobj-type AND
            buf_tax-rate-gds.obj-code = parobj-code))
          then do:
            assign
            currate-code = buf_tax-rate.rate-code
            currate-name = buf_tax-rate.rate-name
            currate-gds-rc = recid(buf_tax-rate)
            .
          end.
          else do:
            next _tax-rate-gds.
          end.
        end.
        if currate-gds-rc = ? then do:
          assign varmes = "Не найдена ставка налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
      end.
      assign
        buf_tt-tax.rate-code   = currate-code
        buf_tt-tax.individual  = buf_tax.individual
        buf_tt-tax.tax-name    = buf_tax.tax-name
        buf_tt-tax.rate-name   = currate-name
        buf_tt-tax.tax-type    = buf_tax.tax-type
        buf_tt-tax.to-cashdesk = buf_tax.to-cashdesk
        buf_tt-tax.tax-rate-gds-rc  = currate-gds-rc
      .
    end.
    if parprice-sale = ?
    or parexcise     = ?
    or parroad-tax   = ?
    then do:
      if parnode-code = ? then do:
          FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
          parnode-code = buf_gds-prt.node-code.
      end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  vargds-code
  ,input  parnode-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  parobj-type
  ,input  parobj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      assign
        parprice-sale = gp-price-sale
        parexcise     = gp-excise
        parroad-tax   = gp-road-tax
      .
    end.
    if only-check then do:
      return .
    end.
    for each buf_tt-tax no-lock
    on error undo, return error
    :
      if buf_tt-tax.tax-rate-gds-rc = ? then NEXT.
      if not buf_tt-tax.individual then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  ?
  ,input  buf_tt-tax.tax-code
  ,input  buf_tt-tax.rate-code
  ,input  ?
  ,input  parhost-code
  ,input  parobj-type
  ,input  parobj-code
  ,output varrate-value
  ) no-error .
        if error-status:error or varrate-value = ? then do:
          assign varmes = "Не найдена величина ставки налога: "  + string(buf_tt-tax.tax-code) + " " + buf_tt-tax.tax-name + " " + string(buf_tt-tax.rate-code) +
                          " к товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                          " фирма: " + string(parhost-code) +
                          " объект: " + parobj-type + " " + string(parobj-code) + chr(10).
          if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
        end.
        assign
        buf_tt-tax.rate-value  = varrate-value
        .
      end.
      else do:
        if not avail buf_gds-prt then
        FIND buf_gds-prt WHERE buf_gds-prt.upper-code  = buf_goods.prt-root NO-LOCK.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
        if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U then do:
          find FIRST buf_prod-bc where
                      buf_prod-bc.b-code     = buf_goods.gds-code     and
                      buf_prod-bc.bc-on = yes no-lock no-error.
          if not available buf_prod-bc then do:
            assign varmes = "Не найден ДОП.бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        else do:
          find buf_bar-code where
                buf_bar-code.gds-code  = vargds-code     and
                buf_bar-code.node-code = buf_gds-prt.node-code and
                buf_bar-code.part-code = ""           and
                buf_bar-code.in-code   = ""           and
                buf_bar-code.unit-cli  = parunit-base  no-lock no-error.
          if not available buf_bar-code then do:
            assign varmes = "Не найден бар-код по товару: " + parartic + " " + parprod-type + " " + string(parprod-code) +
                            " " + string(buf_gds-prt.node-code) + " " + string(parunit-base) + "~n".
            if paris-log then do:                       parerr-mes = parerr-mes + varmes.                       return "error".                   end.                   else do:                         message varmes view-as alert-box error.                         return error.                   end.
          end.
        end.
        if buf_tt-tax.tax-code = rdtaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parroad-tax
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
        if buf_tt-tax.tax-code = exctaxcdvalue then do:
          ASSIGN
          buf_tt-tax.rate-code   = if (is-petrolium  and not is-pieces) and buf_goods.gds-type = 'т':U
                                then integer(buf_prod-bc.b-str)
                                else buf_bar-code.b-code
          buf_tt-tax.rate-value  = parexcise
          buf_tt-tax.tax-rate-gds-rc  = ?
          NO-ERROR.
        end.
      end.
    end.
  end.
end procedure.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdsoattr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure discfgru-check :
define input parameter p-table-name as character no-undo .
define input parameter p-templ-rl-root as integer no-undo .
define input parameter p-time-templ-rl-root as integer no-undo .
define input parameter p-pos-type as character no-undo .
define output parameter p-disnct-role as character no-undo .
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error return-value
  :
    find first buf_dis-cfg-rule no-lock where
            buf_dis-cfg-rule.table-name = p-table-name
        and buf_dis-cfg-rule.templ-rl-root = p-templ-rl-root
        and (p-time-templ-rl-root = ? or  buf_dis-cfg-rule.time-templ-rl-root = p-time-templ-rl-root)
        and buf_dis-cfg-rule.pos-type = p-pos-type no-error.
    if not available buf_dis-cfg-rule
    or p-pos-type = "":U
    then do:
       return error substitute("Для места использования типа &1 не определен тип скидки с шаблоном &2 &3"
                               ,entry (lookup (p-pos-type, 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA,-,bo,Autotank':U), 'IBM,IBM-XML,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA,Накладная,Бэкофис,Autotank':U)
                               , p-templ-rl-root
                               , (if p-time-templ-rl-root = ?
                                  then '':U
                                  else substitute("с расписанием типа &1", p-time-templ-rl-root)
                                  )
                               ).
    end.
    assign
    p-disnct-role = buf_dis-cfg-rule.discnt-role
    .
  end.
end procedure.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = 'орг':U then do:
       par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parhost-code).
       return par-region.
    end.
    if parobj-type = 'регион':U
    then do:
       par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
       return par-region.
    end.
    par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
    return par-region.
END FUNCTION.
FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0
  then do:
     par-region = "Глобально".
  end.
  else if parobj-type = 'орг':U
  then do:
     par-region = fill(chr(32), 2) + "Фирма" + chr(32) + string(parobj-code).
  end.
  else if parobj-type = 'регион':U
  then do:
     par-region = fill(chr(32), 2) + "Регион" + chr(32) + string(parobj-code).
  end.
  else
     par-region = fill(chr(32), 4) + parobj-type + chr(32) + string(parobj-code).
  return par-region.
END FUNCTION.
procedure disgdsru-name :
define buffer buf_dis-rule for ub.dis-rule.
do
  on error undo, return error
  :
  define input  parameter p-templ-rl-root  as integer no-undo .
  define output parameter p-label          as character no-undo .
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-templ-rl-root no-error.
  if available buf_dis-rule
  then do:
    if buf_dis-rule.rule-num > 0 then
    p-label = buf_dis-rule.des.
  end.
  else do:
    p-label = substitute("Неизвестный тип правила скидки &1", p-templ-rl-root).
  end.
end.
end procedure.
function disgdsru-get-disc-label returns character ( input p-templ-rl-root as integer):
define variable v-rule-label as character no-undo .
run disgdsru-name in this-procedure ( input p-templ-rl-root
                                     ,output v-rule-label) no-error.
return v-rule-label.
end function.
function disgdsru-get-disc-role-label returns character ( input p-discnt-role as character):
define variable v-rule-label as character no-undo .
return entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u).
end function.
procedure disgdsru-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type       like ub.dis-gds-rule.obj-type   no-undo .
    define input parameter p-obj-code       like ub.dis-gds-rule.obj-code   no-undo .
    define input parameter p-gds-code       like ub.dis-gds-rule.gds-code   no-undo .
    define input parameter p-pos-type       like ub.dis-gds-rule.pos-type   no-undo .
    define input parameter p-discnt-role    like ub.dis-gds-rule.discnt-role no-undo .
    define input parameter p-templ-rl-root  like ub.dis-gds-rule.templ-rl-root  no-undo .
    define input parameter p-time-templ-rl-root  like ub.dis-gds-rule.time-templ-rl-root  no-undo .
    define input parameter p-rule-num       like ub.dis-gds-rule.rule-num    no-undo .
    define input parameter p-nonunique      like ub.dis-gds-rule.nonunique   no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule .
    define buffer buf_dis-rule for ub.dis-rule.
    define buffer lock_dis-gds-rule for ub.dis-gds-rule .
    define variable v-label          as character no-undo .
    define variable v-discnt-role as character no-undo .
    run discfgru-check in this-procedure (
                                          input 'dis-gds-rule':U
                                         ,input p-templ-rl-root
                                         ,input p-time-templ-rl-root
                                         ,input p-pos-type
                                         ,output v-discnt-role
                                          ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    if p-discnt-role = ? then do:
      p-discnt-role = v-discnt-role.
    end.
    if p-discnt-role <> v-discnt-role then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не может быть по шаблону &7 и расписанию &8"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-templ-rl-root
                              ,p-rule-num).
    end.
    if p-pos-type = ? then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type23 as character no-undo .
define variable v-value-date23 as date no-undo .
define variable v-value-decimal23 as decimal no-undo .
define variable v-value-integer23 as INTEGER no-undo .
define variable v-value-logical23 AS LOGICAL no-undo .
define variable v-tth23 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output p-pos-type
    ,output v-value-date23
    ,output v-value-decimal23
    ,output v-value-integer23
    ,output v-value-logical23
    ,output v-param-type23
    ,INPUT-OUTPUT table-handle v-tth23
    )  .
delete object v-tth23 no-error.
    end.
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = p-rule-num no-error.
    if not available buf_Dis-rule then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6не найдено правило скидки &7"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if buf_dis-rule.root <> yes then do:
      undo, return error substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6правило скидки &7 - некорневое"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ,p-rule-num).
    end.
    if not (p-obj-type = buf_dis-rule.obj-type
        and p-obj-code = buf_dis-rule.obj-code)
    and not ( (p-obj-type = 'маг':U or p-obj-type = 'скл':U )
             and
             (buf_dis-rule.obj-type = 'орг':U or buf_dis-rule.obj-type = ""))
     then do:
      undo, return error (substitute("Товар &1 &2&3 место использ. &4 скидка типа &5&6"
                              ,p-gds-code
                              ,p-obj-type
                              ,p-obj-code
                              ,p-pos-type
                              ,entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                              ,chr(10)
                              ) +
                          substitute("Правило скидки &1 определено для &2&3" +
                                     "а привязка к товару для &4"
                                     ,buf_dis-rule.rule-num
                                     ,get-objregion( buf_dis-rule.obj-type, buf_Dis-rule.obj-code)
                                     ,chr(10)
                                     ,get-objregion( p-obj-type, p-obj-code)
                                     ))
                              .
    end.
    find first buf_dis-gds-rule exclusive-lock where
               buf_dis-gds-rule.gds-code  = p-gds-code
           AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
           AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
           AND buf_dis-gds-rule.pos-type  = p-pos-type
           AND buf_dis-gds-rule.discnt-role = p-discnt-role
           and buf_dis-gds-rule.nonunique = p-nonunique
           no-error .
    if not available buf_dis-gds-rule then do:
      find first buf_dis-gds-rule exclusive-lock where
                buf_dis-gds-rule.gds-code  = p-gds-code
            AND buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
            AND buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
            AND buf_dis-gds-rule.pos-type  = p-pos-type
            AND buf_dis-gds-rule.discnt-role = p-discnt-role
            no-error .
      if available buf_Dis-gds-rule then do:
        if p-nonunique = ''
        and available buf_dis-gds-rule
        then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует (детализ. &3)"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                   , p-nonunique
                                  ).
        end.
        if available buf_dis-gds-rule
        and buf_dis-gds-rule.nonunique = ''
        and p-nonunique <> ''then do:
          return error substitute("Скидка типа &1 на товар с кодом &2 &3&4 уже существует"
                                   , entry (lookup (p-discnt-role, 'std-disc,abs-disc,pcnt-tot,temp-disc,pcnt-kat,pcnt-qnty,pcnt-date,without-disc,without-gds-disc,dis-tot-flag,max-disc,bonus-qnty':u) + 1, ',' + 'Стандартная скидка,Абсолютная скидка,% скидка c суммы,Временная скидка,Категорийная скидка,Количественная скидка,Скидка по дате,Запрет на участие в бонусных программах\участие в скидке на итог,Запрет скидки на товар,Участие в итогах по ДК,Порог max скидки на товар,Начисление бонусов на кол-во товара':u)
                                   , p-gds-code
                                   , buf_Dis-rule.obj-type
                                   , buf_Dis-rule.obj-code
                                  ).
        end.
      end.
      create buf_dis-gds-rule .
      assign
      buf_dis-gds-rule.gds-code  = p-gds-code
      buf_dis-gds-rule.obj-type  = buf_dis-rule.obj-type
      buf_dis-gds-rule.obj-code  = buf_dis-rule.obj-code
      buf_dis-gds-rule.pos-type = p-pos-type
      buf_dis-gds-rule.discnt-role = v-discnt-role
      buf_dis-gds-rule.rule-num = p-rule-num
      buf_dis-gds-rule.nonunique = p-nonunique
      no-error
      .
    end.
    ASSIGN
    buf_dis-gds-rule.rule-num = p-rule-num
    buf_dis-gds-rule.rl-root = buf_Dis-rule.rl-root
    buf_dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
    buf_dis-gds-rule.templ-rl-root = p-templ-rl-root
    buf_dis-gds-rule.nonunique = p-nonunique
    no-error.
  end.
end procedure.
PROCEDURE cmp-disgdsru-write :
do
on error undo, return error
:
  define input parameter p-gds-code like ub.dis-gds-rule.gds-code   no-undo .
  define input parameter p-obj-type like ub.dis-gds-rule.obj-type   no-undo .
  define input parameter p-obj-code like ub.dis-gds-rule.obj-code   no-undo .
  define input parameter p-pos-type like ub.dis-gds-rule.pos-type   no-undo .
  define input parameter p-templ-rl-root     like ub.dis-gds-rule.templ-rl-root  no-undo .
  define input parameter p-time-templ-rl-root     like ub.dis-gds-rule.time-templ-rl-root  no-undo .
  define input parameter p-discnt-role like ub.dis-gds-rule.discnt-role no-undo .
  define input parameter p-rule-num    like ub.dis-gds-rule.rule-num no-undo .
  define input parameter p-nonunique like ub.dis-gds-rule.nonunique no-undo .
  define variable v-rule-label          as character no-undo .
  define buffer buf_tt0-dis-gds-rule for ub.dis-gds-rule .
  define buffer buf_dis-rule     for ub.dis-rule.
  run disgdsru-name in this-procedure (
                                      input  p-templ-rl-root
                                      ,output v-rule-label
                                      ) no-error .
  if error-status :error then do:
    undo, return error return-value .
  end.
  find first buf_tt0-dis-gds-rule exclusive-lock where
              buf_tt0-dis-gds-rule.gds-code  = p-gds-code
          AND buf_tt0-dis-gds-rule.obj-type  = p-obj-type
          AND buf_tt0-dis-gds-rule.obj-code  = p-obj-code
          AND buf_tt0-dis-gds-rule.pos-type  = p-pos-type
          AND buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
          AND buf_tt0-dis-gds-rule.nonunique = p-nonunique
          no-error .
  if not available buf_tt0-dis-gds-rule then do:
    create buf_tt0-dis-gds-rule .
    assign
    buf_tt0-dis-gds-rule.gds-code  = p-gds-code
    buf_tt0-dis-gds-rule.obj-type  = p-obj-type
    buf_tt0-dis-gds-rule.obj-code  = p-obj-code
    buf_tt0-dis-gds-rule.pos-type  = p-pos-type
    buf_tt0-dis-gds-rule.nonunique = p-nonunique
    buf_tt0-dis-gds-rule.discnt-role = p-discnt-role
    no-error
    .
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = p-rule-num.
  ASSIGN
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rule-num = p-rule-num
  buf_tt0-dis-gds-rule.time-templ-rl-root = p-time-templ-rl-root
  buf_tt0-dis-gds-rule.nonunique = p-nonunique
  buf_tt0-dis-gds-rule.templ-rl-root = p-templ-rl-root
  buf_tt0-dis-gds-rule.rl-root = buf_Dis-rule.rl-root
  no-error.
  release buf_tt0-dis-gds-rule no-error .
  if error-status:error then do:
    undo, return error return-value .
  end.
end.
END PROCEDURE.
define variable vss-include-info24 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-bgelib-bgefmt        as character         no-undo.
define variable v-bgelib-bgeflold      as character         no-undo.
define stream stmXMLOut.
define stream stmXMLLog.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
define variable vss-include-info26 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable v-bgelib-bgeclall           as logical      no-undo.
define variable v-bgelib-bgedict            as logical      no-undo.
define temp-table temp_ext-doc-type no-undo
    field edt-key               as integer
    field ext-doc-type          as character
    field ext-doc-type-label    as character
    index pi is primary unique
        edt-key
.
define temp-table temp_bgelib_goods no-undo
    field gds-code as integer
    index pi is primary unique
        gds-code
.
define temp-table temp_bgelib_clients no-undo
    field obj-type as character
    field obj-code as integer
    index pi is primary unique
        obj-type
        obj-code
.
define temp-table temp_bgelib_dis-card no-undo
    field d-card as character
    index pi is primary unique
        d-card
.
define temp-table temp_bgelib_trn-doc no-undo
    field doc-code as integer
.
procedure bgelib-tag-open:
do
on error undo, return error
:
define input parameter v-tag-level  as integer      no-undo.
define input parameter v-tag-name   as character    no-undo.
define input parameter v-tag-value  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill(" ", 4 * v-tag-level)
        + "<" + v-tag-name
        + ( if v-tag-value = "" or v-tag-value = ? then "" else " " )
        + v-tag-value + ">"
    .
end.
end procedure.
procedure bgelib-tag-put:
do
on error undo, return error
:
define input parameter v-tag-level      as integer      no-undo.
define input parameter v-tag-name       as character    no-undo.
define input parameter v-tag-value      as character    no-undo.
define input parameter v-empty-mode     as integer      no-undo.
    v-tag-name = trim(v-tag-name).
    if  v-empty-mode = 1
    or (v-empty-mode = 0 and (v-tag-value <> "" and v-tag-value <> ?) )
    or (v-empty-mode = 2 and (v-tag-value <> "" and v-tag-value <> ? and v-tag-value <> "0"))
    or (v-empty-mode = 3 and (v-tag-value <> "" and v-tag-value <> ? and caps(v-tag-value) <> "no"))
    then do:
        run xmlchar-encode in this-procedure (
              input v-tag-value
            , output v-tag-value
        ).
        put stream stmXMLOut unformatted
            chr(10) + fill(" ", 4 * v-tag-level)
                        + '<' + v-tag-name + '>'
                        + v-tag-value
                        + '</' + v-tag-name + '>'
        .
    end.
end.
end procedure.
procedure bgelib-tag-close:
do
on error undo, return error
:
define input parameter v-tag-level as integer      no-undo.
define input parameter v-tag-name  as character    no-undo.
    put stream stmXMLOut unformatted
        chr(10)
        + fill( " ", 4 * v-tag-level)
        + '</' + v-tag-name + '>'
    .
end.
end procedure.
procedure bgelib-write-log:
do
on error undo, return error
:
define input parameter v-filename   as character    no-undo.
define input parameter v-log-level  as integer      no-undo.
define input parameter v-out-string as character    no-undo.
    output stream stmXMLLog to value( v-filename ) append.
    put stream stmXMLLog unformatted
        chr(10)
    .
    put stream stmXMLLog unformatted
        ( if v-log-level = 0
          or v-out-string = "&DLine"
          or v-out-string = "&Line"
          then ""
          else cur-time-string-sec() + " " )
    .
    put stream stmXMLLog unformatted
        ( if v-out-string = "&Line"
          then fill( "-", 80 )
          else if v-out-string = "&DLine"
               then fill( "=", 80 )
               else v-out-string )
    .
    output stream stmXMLLog close.
end.
end procedure.
procedure bgelib-write-edt:
do
on error undo, return error
:
define input parameter v-editor-handle    as handle       no-undo.
define input parameter v-log-level        as integer      no-undo.
define input parameter v-out-string       as character    no-undo.
    if valid-handle ( v-editor-handle )
    then do:
        v-editor-handle :move-to-eof().
        v-editor-handle :insert-string( ( if v-log-level = 0
                                          or v-out-string = "&DLine"
                                          or v-out-string = "&Line"
                                          then ""
                                          else cur-time-string-sec() + " "
                                      ) ).
        v-editor-handle :insert-string( ( if v-out-string = "&Line"
                                          then fill( "-", 80 )
                                          else if v-out-string = "&DLine" then fill("=", 80)
                                          else fill( " ", v-log-level) + v-out-string
                                      ) ).
        v-editor-handle :insert-string( chr(10) ).
    end.
    process events.
    output to 'bgescn.txt' append.
        put unformatted
            chr(10)
            string( ( if v-log-level = 0
                      or v-out-string = "&DLine"
                      or v-out-string = "&Line"
                      then ""
                      else string( today ) + " " + string( time, "hh:mm:ss" ) + " "
                  ) )
            string( ( if v-out-string = "&Line"
                      then fill( "-", 80 )
                      else if v-out-string = "&DLine"
                           then fill( "=", 80 )
                           else fill( " ", v-log-level ) + v-out-string
                  ) )
        .
    output close.
end.
end procedure.
procedure bgelib-show-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :visible = true
        .
    end.
end.
end procedure.
procedure bgelib-hide-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle     as handle   no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign v-fillin-handle :visible = false.
    end.
end.
end procedure.
procedure bgelib-write-cnt:
do
on error undo, return error
:
define input parameter v-fillin-handle    as handle       no-undo.
define input parameter v-fillin-string    as character    no-undo.
    if valid-handle( v-fillin-handle )
    then do:
        assign
            v-fillin-handle :SCREEN-value = v-fillin-string
        .
    end.
end.
end procedure.
procedure bgelib-write-header:
do
on error undo, return error
:
define input parameter p-first-file     as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-file-number    as integer      no-undo.
define input parameter p-have-prev      as logical      no-undo.
define input parameter p-prev-filename  as character    no-undo.
define input parameter p-obj-list       as character    no-undo.
define input parameter p-doc-type-list  as character    no-undo.
define input parameter p-parameter-list as character    no-undo.
    define variable v-counter    as integer        no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    put stream stmXMLOut unformatted
        "<?xml version='1.0' encoding='windows-1251'?>"
    .
    run bgelib-tag-open( input 0, input "root"  , input "" ).
    run bgelib-tag-open( input 0, input "header", input "" ).
    run bgelib-tag-put( input 1, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 1, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 1, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 1, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 1, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 1, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 1
            , input entry( 2 * v-counter, p-parameter-list )
            , input entry( 2 * v-counter + 1, p-parameter-list )
            , input 0
        ).
    end.
    run bgelib-tag-close( input 0, input "header" ).
    output stream stmXMLOut close.
    output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
    if p-first-file = yes
    then do:
        put stream stmXMLOut unformatted
            "<?xml version='1.0' encoding='windows-1251'?>"
        .
        run bgelib-tag-open( input 0, input "export", input "" ).
    end.
    run bgelib-tag-open( input 1, input "file", input "" ).
    run bgelib-tag-put( input 2, input "fileName"       , input p-xml-file-name + "xml":U  , input 0 ).
    run bgelib-tag-put( input 2, input "fileNumber"     , input string( p-file-number     ), input 0 ).
    run bgelib-tag-put( input 2, input "havePrev"       , input string( p-have-prev       ), input 3 ).
    run bgelib-tag-put( input 2, input "prevFileName"   , input p-prev-filename            , input 0 ).
    run bgelib-tag-put( input 2, input "objList"        , input p-obj-list                 , input 0 ).
    run bgelib-tag-put( input 2, input "docTypeList"    , input p-doc-type-list            , input 0 ).
    do v-counter = 1 to integer( entry( 1, p-parameter-list ) )
    :
        run bgelib-tag-put(
              input 2
            , input trim(entry( 2 * v-counter, p-parameter-list ))
            , input trim(entry( 2 * v-counter + 1, p-parameter-list ))
            , input 0
        ).
    end.
    run bgelib-tag-close( input 1, input "file" ).
    output stream stmXMLOut close.
end.
end procedure.
procedure bgelib-write-footer:
do
on error undo, return error
:
define input parameter p-last-file      as logical      no-undo.
define input parameter p-xml-file-name  as character    no-undo.
define input parameter p-list-file-name as character    no-undo.
define input parameter p-have-next      as logical      no-undo.
define input parameter p-next-file-name as character    no-undo.
    define variable v-error-num     as integer           no-undo.
    output stream stmXMLOut to value( p-xml-file-name + "tmp" ) convert target "1251" append.
    if p-have-next = yes
    then do:
        run bgelib-tag-open( input 0, input "footer", "" ).
        run bgelib-tag-put( input 1, input "haveNext"       , string( p-have-next ) , 3 ).
        run bgelib-tag-put( input 1, input "nextFileName"   , p-next-file-name      , 0 ).
        run bgelib-tag-close( input 0, input "footer" ).
    end.
    run bgelib-tag-close( input 0, input "root" ).
    output stream stmXMLOut close.
    run bge/os_copy.p (
          input "M"
        , input p-xml-file-name + "tmp"
        , input p-xml-file-name + "xml"
        , output v-error-num
    ).
    if p-last-file = yes
    then do:
        output stream stmXMLOut to value( p-list-file-name + "tmp" ) convert target "1251" append.
            run bgelib-tag-close( input 0, input "export" ).
        output stream stmXMLOut close.
        run bge/os_copy.p (
              input "M"
            , input p-list-file-name + "tmp"
            , input p-list-file-name + "xml"
            , output v-error-num
        ).
    end.
end.
end procedure.
procedure bgelib-filename :
do
on error undo, return error
:
define input parameter p-prefix             as character    no-undo.
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-list-file-name    as character    no-undo.
    define variable v-home-dir  as character    no-undo.
    define variable v-error-num as integer      no-undo.
    get-key-value section "BGE" key "outdir" value v-home-dir.
    if v-home-dir = ?
    then do:
        message
          skip "Не найден параметр ini-файла, определяющий каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run gbl/dir-cre.p (
        input v-home-dir
    ) no-error.
    if error-status :error
    then do:
        message
          skip "Неверно задан каталог экспорта."
          skip(1)
          skip "Обратитесь к администратору."
        view-as alert-box error.
        undo, return error .
    end.
    run bge/genfname.p (
          input v-home-dir
        , input p-prefix
        , input ""
        , input "xml"
        , input "tmp"
        , output p-xml-file-name
    ).
    assign
        p-xml-file-name     = substring( p-xml-file-name, 1, length( p-xml-file-name ) - 3 )
        p-log-file-name     = v-home-dir + chr(92) + "actions.log"
        p-list-file-name    = v-home-dir + chr(92) + "lst":U + substring( p-xml-file-name, length( p-xml-file-name ) - 5, 5 ) + ".":U
    .
end.
end procedure.
procedure bgelib-read-config :
do
on error undo, return error
:
define variable v-par-type as character     no-undo.
  define variable v-param-type      as character  no-undo .
  define variable v-value-character as character  no-undo .
  define variable v-value-date      as date       no-undo .
  define variable v-value-decimal   as decimal    no-undo .
  define variable v-value-integer   as integer    no-undo .
  define variable v-value-logical   as logical    no-undo .
  define variable v-tth             as handle     no-undo .
    assign
        v-bgelib-bgeclall = no
        v-bgelib-bgedict  = no
    .
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeclall':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeclall = no
      .
    end.
    else do:
      assign
        v-bgelib-bgeclall = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgedict':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgedict = no
      .
    end.
    else do:
      assign
        v-bgelib-bgedict = v-value-logical
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgefmt':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgefmt  = "xml":U
      .
    end.
    else do:
      assign
        v-bgelib-bgefmt  = v-value-character
      .
    end.
    delete object v-tth.
    run adm/shattri.p ( input "get":U
                      , input  '':u
                      , input  0
                      , input  'bge-export':U
                      , input  'bgeflold':U
                      , output v-value-character
                      , output v-value-date
                      , output v-value-decimal
                      , output v-value-integer
                      , output v-value-logical
                      , output v-param-type
                      , input-output table-handle v-tth
                      ) no-error .
    if error-status :error
    then do:
      assign
        v-bgelib-bgeflold  = "old":U
      .
    end.
    else do:
      assign
        v-bgelib-bgeflold  = v-value-character
      .
    end.
    delete object v-tth.
end.
end procedure.
procedure bgelib-check-file-size :
do
on error undo, return error
:
define input parameter p-out-filename   as character    no-undo.
define output parameter p-is-big        as logical      no-undo.
    define variable v-current-position    as integer        no-undo.
    assign
        v-current-position = seek( stmXMLOut )
    .
    if v-current-position / 1024 / 1024  >= 100
    then do:
        assign
            p-is-big = yes
        .
    end.
end.
end procedure.
procedure bgelib-init-ext-doc-type :
    define variable v-counter    as integer      no-undo.
    define buffer buf_temp_ext-doc-type     for temp_ext-doc-type.
do
for buf_temp_ext-doc-type
on error undo, return error
:
    empty temp-table buf_temp_ext-doc-type.
    do v-counter = 1 to num-entries( 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
    :
        create buf_temp_ext-doc-type.
        assign
            buf_temp_ext-doc-type.edt-key               = v-counter
            buf_temp_ext-doc-type.ext-doc-type          = entry( v-counter, 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U )
            buf_temp_ext-doc-type.ext-doc-type-label    = entry( v-counter, 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U )
        .
    end.
end.
end procedure.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gdcstcod_cst-code :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-gds-code  as integer   no-undo .
  define input  parameter p-in-code   as character no-undo .
  define input  parameter p-part-code as character no-undo .
  define output parameter p-cst-code  as character no-undo .
  define buffer buf_goods for ub.goods .
  define buffer buf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    assign
      p-cst-code = ''
    .
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Не найден товар &1", p-gds-code) .
    end.
    if p-in-code = ?
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Неизвестное значение номера накладной &1", p-in-code) .
    end.
    if p-part-code = ?
    then do:
      undo, return error substitute("Ошибка задания входных параметров. Неизвестное значение номера номера партии &1", p-part-code) .
    end.
    if p-in-code = '':u
    then do:
      find first buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.status_   = false
        no-error .
      if available buf_parts
      then do:
        assign
          p-cst-code = buf_parts.cst-code
        .
      end.
    end.
    else do:
      find first buf_parts no-lock
        where buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.in-code   = p-in-code
          and buf_parts.part-code = p-part-code
        no-error .
      if available buf_parts
      then do:
        assign
          p-cst-code = buf_parts.cst-code
        .
      end.
    end.
  end.
end procedure.
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fname                        as character      no-undo .
define variable out                          as character      no-undo .
define variable out2                          as character      no-undo .
DEFINE VARIABLE in_                          as character      no-undo .
DEFINE VARIABLE spl                          as character      no-undo .
DEFINE VARIABLE sav                          as character      no-undo .
DEFINE VARIABLE v-remote                     as character      no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
define variable cr as integer no-undo.
define variable Cash-OS2                    as logical        no-undo .
define variable Cash-DOS                     as logical        no-undo .
define variable BadFlag                      as logical        no-undo .
define variable os-er                        as integer        no-undo .
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define   temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define   temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .
define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream IBMSTREAM
to value(v-file-name) append .
Put  stream IBMSTREAM unformatted
p-plu
chr(3)
p-value
skip.
output stream IBMSTREAM
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end.
end.
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, chr(4) )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.
PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0)
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring('16-42,17-43,':U, index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.
PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .
define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.
  do
  on error undo, return error
  :
     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.
end procedure.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION name-2cdf returns character
                   (  input p-name-2cd as character
                    , input p-mode as logical
                    , input p-cod-pcod as logical
                    , input p-b-code  as integer
                    , input p-gds-code as integer
                    , input p-artic   as character
                    , input p-engl-name  as character
                    , input p-in-code as character
                    , input p-part-code as character
                    , input p-obj-type as character
                    , input p-obj-code as integer
                    , input p-alpha1 as character
                    , output p-gtd as character
                    ) :
define variable v-name-2cd as character no-undo .
define variable v-dop-alt-name as character no-undo.
define variable v-type as character no-undo.
define buffer buf_parts for ub.parts.
define buffer buf_code for ub.code.
if not p-mode and p-name-2cd = "PLU":U then do:
  return "PLU кассы":U.
end.
if not p-mode then do:
  if p-name-2cd <> "GTD":U
  and  p-name-2cd <> "alpha1|gtd":U
  then do:
  assign
  p-name-2cd = p-name-2cd + "-":U + "GTD":U.
end.
end.
if p-part-code = "":U or p-cod-pcod = no then do:
  run gdsoattr-value in this-procedure (
    'dt-seasons':U,
    p-gds-code,
    p-obj-type,
    p-obj-code,
    output v-dop-alt-name,
    output v-type
  ) no-error.
  if v-dop-alt-name <> "" then do:
    find first buf_code where
               buf_code.parent = "DTSeasons"
           and buf_code.code   = v-dop-alt-name
         no-lock no-error.
    if available buf_code then
      assign
        p-engl-name = ""
        v-dop-alt-name =  buf_code.misc1
      .
  end.
  else do:
    run gdsoattr-value in this-procedure
                        ( input  'dop-alt-name-o':U
                         ,input  p-gds-code
                         ,input  p-obj-type
                         ,input  p-obj-code
                         ,output v-dop-alt-name
                         ,output v-type
                        ) no-error .
  end.
  CASE p-name-2cd:
    when "name" then do:
      if p-mode then return p-engl-name + v-dop-alt-name.
      return "Англ. название".
    end.
    when "code":U then do:
      if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
      return "Лок. код товара"  .
    end.
    when "GTD":U
    or
    when "name-GTD":U
    or
    when "code-GTD":U
    or
    when "alpha1|gtd":U
    or
    when "name-alpha1|gtd":U
    or
    when "code-alpha1|gtd":U
    then do:
      if p-mode then do:
        run gdcstcod_cst-code  in this-procedure (
                                                    input  p-obj-type
                                                    ,input  p-obj-code
                                                    ,input  p-gds-code
                                                    ,input  p-in-code
                                                    ,input  p-part-code
                                                    ,output p-gtd
                                                    ) no-error .
      end.
      if p-name-2cd = "name-gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "name-alpha1|gtd":U then do:
        if p-mode then return p-engl-name  + v-dop-alt-name.
        return "Англ. название".
      end.
      if p-name-2cd = "code-GTD":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-name-2cd = "code-alpha1|gtd":U then do:
        if p-mode then  return string( p-b-code, ">>>>>>>>>>>>>>>9" )  .
        return "Лок. код товара"  .
      end.
      if p-mode then do:
        if p-name-2cd = "GTD" then  return p-gtd.
        if p-name-2cd = "alpha1|gtd" then  return (p-alpha1 + "|" + p-gtd).
      end.
      if p-name-2cd = "GTD" then  return "Код ГТД".
      if p-name-2cd = "alpha1|gtd" then  return "Страна|Код ГТД".
    end.
  END CASE.
end.
else do:
  if p-name-2cd = "name-gtd":U
  or p-name-2cd = "code-GTD":U
  or p-name-2cd = "name-alpha1|GTD":U
  or p-name-2cd = "code-alpha1|GTD":U
  or p-name-2cd = "alpha1|GTD":U
  then do:
    if p-mode then do:
      run gdcstcod_cst-code  in this-procedure (
                                                   input  p-obj-type
                                                  ,input  p-obj-code
                                                  ,input  p-gds-code
                                                  ,input  p-in-code
                                                  ,input  p-part-code
                                                  ,output p-gtd
                                                  ) no-error .
    end.
    else do:
      if p-name-2cd = "gtd":U then
      p-gtd = "Код ГТД".
      if p-name-2cd = "alpha1|Gtd":U then
      p-gtd = "Страна|Код ГТД".
    end.
  end.
  if p-mode then  return p-part-code.
  return "Код партии".
end.
END FUNCTION.
function chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th returns character ( input p-pos-type as character
                                         ,input p-nam-2str as logical
                                         ,input p-nam-artc as logical
                                         ,input p-unit-cli-type as character
                                         ,input p-unit-base as character
                                         ,input p-unit-cli as character
                                         ,input p-cli-base-rate as decimal
                                         ,input p-artic as character
                                         ,input p-f-name as character
                                         ,input p-gds-name as character
                                         ,input p-gds-name1 as character
                                         ,output p-second-name as character):
define variable v-length as integer no-undo .
define variable nam-2str-shift as integer no-undo .
define variable chk_name as character no-undo .
assign
v-length = (if p-pos-type = 'IBM':U then 25 else 40 )
v-length = (if p-pos-type = 'MARIA':U then 24 else v-length)
v-length = (if p-pos-type = 'MARIA':U and lookup('топ':U, p-unit-cli-type) > 0
            then 5
            else v-length)
v-length = (if p-pos-type = 'IBM-XML':U then 128 else v-length )
nam-2str-shift = (if p-nam-2str then v-length else 0)
.
if p-nam-artc then do:
  assign
  chk_name = substitute("&1 &2", p-artic, p-f-name)
    .
end.
else  do:
  assign
  chk_name = replace(p-gds-name, chr(34), "":U) + p-f-name
  .
end.
if p-unit-base <> p-unit-cli then do:
  if length (chk_name) > 109 then chk_name = substring (chk_name,1,109) .
  assign
  chk_name = string(substr(chk_name
                            ,1
                            ,max(14, v-length + nam-2str-shift - 1 - length(trim(string(p-cli-base-rate), chr(32)))) +  nam-2str-shift ) +
                    "*":U +
                    trim(string(p-cli-base-rate), chr(32)), "x(":U + string(v-length + nam-2str-shift) + ")":U ).
end.
else do:
  chk_name = string(chk_name, "X(":U + string(v-length + nam-2str-shift) + ")":U).
end.
if p-nam-2str then do:
  assign
  p-second-name = chr(34) + trim(substr(chk_name, v-length)," ") + chr(34)
  chk_name = substr(chk_name, 1, v-length)
  .
end.
else do:
  assign
  p-second-name = replace(p-gds-name1, chr(39), "":U)
  p-second-name =   (chr(34) +
                    TRIM(string( replace(p-second-name, chr(34), "":U), "X(":U + string(v-length) + ")":U ))
                    + chr(34) )
  .
end.
return chk_name.
end function.
def var vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure disrules-get-interface-form :
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define output parameter p-form-name as character no-undo .
define buffer buf_temp-drt-prop for temp-drt-prop.
define buffer buf_drt-prop for ub.drt-prop.
find first buf_temp-drt-prop where
          buf_temp-drt-prop.templ-rl-root = p-templ-rl-root
      and buf_temp-drt-prop.upper-prop-code = "InputForm"
      and buf_temp-drt-prop.prop-code = "FormName" no-error.
if not available buf_temp-drt-prop then do:
  find first buf_drt-prop where
            buf_drt-prop.templ-rl-root = p-templ-rl-root
        and buf_drt-prop.upper-prop-code = "InputForm"
        and buf_drt-prop.prop-code = "FormName" no-error.
  if available buf_drt-prop then do:
    p-form-name = buf_drt-prop.property-value.
  end.
  else do:
    p-form-name = "ref/dis-ruli.w".
  end.
end.
else do:
  p-form-name = buf_temp-drt-prop.property-value.
end.
end procedure.
~
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE cd-mrkt_plu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-id as character no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-loc-ean as logical no-undo .
define input parameter p-is-petrolium as logical no-undo .
define input parameter p-extra as character no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-gds as integer no-undo .
define variable v-petrol-start as integer no-undo .
define variable v-petrol-range as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-plu-type as character no-undo .
define variable v-int as integer no-undo .
define buffer  buf_cd-plu for ub.cd-plu.
define buffer  loc_cd-plu for ub.cd-plu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Товары на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                        and p-is-petrolium
                                        then 'tot-petrol':U
                                        else 'tot-gds':U)
                                  , output v-mes).
  if v-tot-gds = ? then undo _main, return error v-mes.
  v-max-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-gds':U
                                  ,output v-mes).
  if v-max-gds = ? then undo _main, return error v-mes.
  v-petrol-range = cd-attr_get-attr-int(buffer buf_cash-desk
                                       ,input 'petrolium-range':U
                                       ,input 'petrolium-range':U
                                       ,output v-mes).
  if v-petrol-range = ? then undo _main, return error v-mes.
  if buf_cash-desk.pos-type = 'MARIA':U then do:
    assign
    v-petrol-start = 1
    v-max-gds = (if p-is-petrolium
                 then v-petrol-range
                 else v-max-gds)
    v-plu-type = (if p-is-petrolium
               then 'топ':U
               else '':U)
    .
    if p-is-petrolium then do:
      if p-id = '':U then do:
        v-mes = substitute( "Топливо с кодом &1 не привязано к складскому месту&2" +
                            "Невозможно привязать к кассе типа &3"
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
      assign
      v-int = integer(p-id)
      no-error
      .
      if error-status:error
      or v-int > v-petrol-range then do:
        v-mes = substitute( "№ резервуара &1 для топлива с кодом &1 не укладывается&3" +
                            "в диапазоны номеров резервуаров для кассы типа &4"
                            , p-id
                            , p-b-str
                            , chr(10)
                            , 'MARIA':U).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
    end.
  end.
  if buf_cash-desk.pos-type = 'MARIA':U
  and p-is-petrolium then do:
    find first loc_cd-plu where
             loc_cd-plu.obj-type = 'маг':U
         and loc_cd-plu.obj-code = buf_cash-desk.obj-code
         and loc_cd-plu.pos-type = buf_cash-desk.pos-type
         and loc_cd-plu.plu-type = 'топ':U
   no-error .
   if available loc_cd-plu then do:
     if loc_cd-plu.b-code = p-b-code
     and loc_cd-plu.b-str = p-b-str then do:
        v-mes = substitute( "№ резервуара &1 на кассе УЖЕ привязан к топливу с кодом &1,&3"
                            , p-id
                            , p-b-str
                            , chr(10)
                            ).
        if not p-silence then
        message
        v-mes
        view-as alert-box WARNING .
        return v-mes.
     end.
     else do:
        v-mes = substitute( "№ резервуара &1 на кассе привязан к топливу с кодом &1,&3" +
                            "нельзя его привязать к топливу &2&3"
                            , p-id
                            , loc_cd-plu.b-str
                            , chr(10)
                            , p-b-str).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
     end.
   end.
   ii = v-int.
  end.
  else do:
    DO ii = (if p-is-petrolium
            then v-petrol-start
            else (if buf_cash-desk.pos-type = 'MARIA':U
                 then 1
                 else (if v-petrol-start = 1
                        then (v-petrol-range + 1)
                        else 1)
                )
            )
      to v-max-gds :
      if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                    )
      then LEAVE .
    END .
  end.
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  DO ii = (if p-is-petrolium
           then v-petrol-start
           else (if v-petrol-start = 1
                 then (v-petrol-range + 1)
                 else 1)
           )
     to v-max-gds :
    if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = 'маг':U
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-gds
                , 'маг':U
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-plu.
  assign
  buf_cd-plu.b-code = p-b-code
  buf_cd-plu.b-str = p-b-str
  buf_cd-plu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                                      then buf_cash-desk.addr-path
                                      else "U":U)
  buf_cd-plu.to-send = yes
  buf_cd-plu.charkey_one = "":U
  buf_cd-plu.to-del = no
  buf_cd-plu.plu-code = ii
  buf_cd-plu.obj-type = 'маг':U
  buf_cd-plu.obj-code = buf_cash-desk.obj-code
  buf_cd-plu.pos-type = buf_cash-desk.pos-type
  buf_cd-plu.plu-type = v-plu-type
  buf_cd-plu.logkey_one = p-loc-ean
  buf_cd-plu.key#_one = integer(p-extra)
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  substitute("&1_operative", buf_cash-desk.pos-type)
                                        ,input (if buf_cash-desk.pos-type = 'MARIA':U
                                              and p-is-petrolium
                                              then 'tot-petrol':U
                                              else 'tot-gds':U)
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-gds + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество товаров на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды товаров, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-is-petrolium as logical no-undo .
define variable v-to-send as logical no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-plu as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define variable v-plu-type as character no-undo .
  do
  on error undo, return error
  :
    v-to-send = no.
    v-tot-gds = 0.
    assign
    v-plu-type = (if p-is-petrolium
                  then  'топ':U
                  else '':U
              )
    .
    FOR EACH buf_cd-plu WHERE
           buf_cd-plu.obj-type = 'маг':U
      and  buf_cd-plu.obj-code = p-obj-code
      and  buf_cd-plu.pos-type = p-pos-type
      and  buf_cd-plu.plu-type = v-plu-type
          :
      if  buf_cd-plu.to-del
      or  buf_cd-plu.to-send then do:
        assign
        v-to-send = yes.
      end.
      assign
      v-tot-gds = v-tot-gds + 1.
    end.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'tot-petrol':U
                                                     else 'tot-gds':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-tot-gds
                                            ,input no
                                                                                        ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  'MARIA_operative':U
                                            ,input  (if p-pos-type = 'MARIA':U
                                                     and p-is-petrolium
                                                     then  'petrol-to-send':U
                                                     else 'to-send':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input 0
                                            ,input v-to-send
                                            ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
    FIND LAST buf_cd-plu NO-LOCK  WHERE
             buf_cd-plu.obj-type = 'маг':U
         and buf_cd-plu.obj-code = p-obj-code
         and buf_cd-plu.pos-type = p-pos-type
         and buf_cd-plu.plu-type = v-plu-type  use-index pi no-error .
    if available buf_cd-plu then do:
      if v-max-plu < buf_cd-plu.plu-code
      then
      v-max-plu = buf_cd-plu.plu-code .
    end.
    else do:
      v-max-plu = 0.
    end.
    run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  (if p-pos-type = 'MARIA':U
                                                  and p-is-petrolium
                                                  then 'max-petrol-plu':U
                                                  else 'max-plu':U)
                                            ,input ''
                                            ,input ?
                                            ,input 0.0
                                            ,input v-max-plu
                                            ,input no
                                          ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
  end.
end procedure.
PROCEDURE cd-mrkt_clu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-cli as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define buffer  buf_cd-clu for ub.cd-clu.
define buffer  loc_cd-clu for ub.cd-clu.
define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> 'MARIA':U
  or buf_cash-desk.cash-num <> 0 then do:
    assign
    v-mes =
    substitute("Клиенты на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_operative':U
                                  ,input 'tot-cli':U
                                  ,output v-mes).
  if v-tot-cli = ? then undo _main, return error v-mes.
  v-max-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input 'MARIA_general':U
                                  ,input 'max-cli':U
                                  , output v-mes).
  if v-max-cli = ? then undo _main, return error v-mes.
  DO ii = 1
     to v-max-cli :
    if not can-find (loc_cd-clu where
                    loc_cd-clu.obj-type = 'маг':U
                and loc_cd-clu.obj-code = buf_cash-desk.obj-code
                and loc_cd-clu.pos-type = buf_cash-desk.pos-type
                and loc_cd-clu.clu-type = '':U
                and loc_cd-clu.clu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-cli then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество клиентов &1" +
                "для касс &2 &3&4"
                , chr(10)
                , v-max-cli
                , 'маг':U
                , buf_cash-desk.obj-code
                )
      view-as alert-box ERROR .
      undo, return error "max-cli":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-clu.
  assign
  buf_cd-clu.cli-code = p-obj-code
  buf_cd-clu.cli-type = p-obj-type
  buf_cd-clu.obj-type = 'маг':U
  buf_cd-clu.obj-code = buf_Cash-desk.obj-code
  buf_cd-clu.pos-type = buf_cash-desk.pos-type
  buf_cd-clu.clu-type = '':U
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = (if buf_cash-desk.pos-type = 'MARIA':U
                            then buf_cash-desk.addr-path
                            else "U":U)
  buf_cd-clu.clu-code = ii
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'tot-cli':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input  (v-tot-cli + 1)
                                        ,input no
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество клиентов на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'cli-to-send':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input yes
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды клиентов, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , 'маг':U
                       ,buf_cash-desk.obj-code
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE.
procedure cd-mrkt_update-marketer-cli :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define variable v-cli-to-send as logical no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-clu as integer no-undo .
define buffer buf_cd-clu for ub.cd-clu.
do
on error undo, return error return-value
:
  v-cli-to-send = no.
  v-tot-cli = 0.
  FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = 'маг':U
    and buf_cd-clu.obj-code =  p-obj-code
    and buf_cd-clu.pos-type =  p-pos-type
    and buf_cd-clu.clu-type =  '':U
    :
    if buf_cd-clu.to-del = yes then do:
      assign
      v-cli-to-send = yes.
    end.
    assign
    v-tot-cli = v-tot-cli + 1.
  end.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'tot-cli':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input v-tot-cli
                                          ,input no
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  'MARIA_operative':U
                                          ,input  'cli-to-send':U
                                          ,input ''
                                          ,input ?
                                          ,input 0.0
                                          ,input 0
                                          ,input v-cli-to-send
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
  FIND LAST buf_cd-clu WHERE
          buf_cd-clu.obj-type = 'маг':U
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = p-pos-type
      and buf_cd-clu.clu-type = '':U
      NO-LOCK use-index pi no-error .
  if available buf_cd-clu then do:
    if v-max-clu < buf_cd-clu.clu-code
    then
    v-max-clu = buf_cd-clu.clu-code.
  end.
  else do:
    v-max-clu = 0.
  end.
  run cd-attr-write  in this-procedure (
                                        input   p-db-num
                                        ,input  p-obj-code
                                        ,input  p-pos-type
                                        ,input  p-cash-num
                                        ,input  'MARIA_operative':U
                                        ,input  'max-clu':U
                                        ,input ''
                                        ,input ?
                                        ,input 0.0
                                        ,input v-max-clu
                                        ,input no
                                        ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.
end.
end procedure.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure bc-oattr_name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-range          as integer   no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-range
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_value :
  define input  parameter p-b-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_value in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_write :
  define input parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .
  define input parameter p-value    like ub.bar-code-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_write in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_exist :
  define input  parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_exist in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_delete :
  define input  parameter p-b-code like ub.bar-code-obj-attr.b-code   no-undo .
  define input  parameter p-code     like ub.bar-code-obj-attr.attr-code  no-undo .
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_delete in g#attr-lib
      (input  p-b-code
      ,input  p-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure bc-oattr_batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-oattr_batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fact-order-mpl :
  do
  on error undo, return error return-value
  :
define input  parameter p-doc-date as date     no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-fact-order as decimal   no-undo .
define variable v-fact-date            as date    no-undo .
define variable v-fact-time            as integer no-undo .
define variable v-fact-order           as decimal no-undo .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable l-shift-on as logical no-undo .
define variable l-date as date      no-undo .
define variable l-time as integer   no-undo .
define variable shift-date as date      no-undo .
define variable shift-num  as integer   no-undo .
define variable shift-name as character no-undo .
define variable max-fact-order as decimal   no-undo .
define buffer buf_global-state for ub.global-state  .
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
  run cur-time in this-procedure
  ( output v-fact-date ,
    output v-fact-time  ).
if p-doc-date = ? then do:
if buf_global-state.pl-use-sys-date-time  = true then do:
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  ?
        ,input  ?
        ,input  false
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
else do:
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  ) no-error .
      if error-status :error then return error "Неопределена дата на объекте " + return-value .
      if p-doc-date <> ? then do:
      end.
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error substitute(" Ошибка из factdate.p: &1 &2"  , return-value , error-status :get-message(1)   ) .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
end.
else do:
       run gbl/factdate.p
       ( input        p-obj-type  ,
         input        p-obj-code  ,
         input-output v-fact-date ,
         input-output v-fact-time ,
         input-output shift-date      ,
         input-output shift-num       ,
         input-output shift-name      ,
         input        yes
         ) no-error .
      if error-status :error then return error "Ошибка factdate.p " + return-value .
      v-fact-date = p-doc-date .
      run factord in this-procedure
        (input  v-fact-date
        ,input  v-fact-time
        ,input  v-fact-time
        ,input  shift-date
        ,input  shift-num
        ,input  l-shift-on
        ,output v-fact-order
        ,output v-shift-end-fact-order
        ,output v-day-end-fact-order
        ) no-error .
      if error-status :error
      or v-fact-order = ?
      or v-fact-order = 0 then do:
        undo, return error "Не определен факт-ордер " + return-value + error-status :get-message(1) .
      end.
      p-fact-order = v-fact-order .
end.
  end.
end procedure.
DEFINE TEMP-TABLE tt_price-all NO-UNDO LIKE ub.price-all
field sale-qnty as decimal
field sale-sum  as decimal
field sale-tnv  as decimal
field price-sale-base as decimal
field price-sale-rubl as decimal
field road-tax-base   as decimal
field road-tax-rubl   as decimal
field excise-base as decimal
field excise-rubl as decimal
field date-1 as date
field date-2 as date
field shift-1 as int
field shift-2 as int
field time-1 as int
field time-2 as int
field grp-name as char
field interv-name as char
field pay-name as char
field unit-cli as char
index pi
plt-priority DESCENDING
fact-order DESCENDING
qnty-from asc
sum-from asc
turnover-from asc
date-1 DESCENDING
time-1 DESCENDING
date-2 DESCENDING
time-2 DESCENDING
type-price DESCENDING
.
procedure mpl-autoprice :
define input  parameter p-only-b-code as logical   no-undo .
define input  parameter p-cli-type    as character no-undo .
define input  parameter p-cli-code    as integer   no-undo .
define input  parameter p-main-b-code as integer   no-undo .
define input  parameter p-b-code      as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-qnty-doc    as decimal   no-undo .
define input  parameter p-sum-doc     as decimal   no-undo .
define input  parameter p-vid-pay        as character no-undo .
define input  parameter p-cash-pay-type  as character no-undo .
define input  parameter p-fact-order  as decimal   no-undo .
define output parameter p-plt-id          as integer   no-undo .
define output parameter p-plt-db-num      as integer   no-undo .
define output parameter p-pdf-id          as integer   no-undo .
define output parameter p-pdf-db-num      as integer   no-undo .
define output parameter p-sale-price-base as decimal   no-undo .
define output parameter p-sale-price-rubl as decimal   no-undo .
define output parameter p-road-tax-base as decimal   no-undo .
define output parameter p-road-tax-rubl as decimal   no-undo .
define output parameter p-excise-base   as decimal   no-undo .
define output parameter p-excise-rubl   as decimal   no-undo .
define variable v-cli-oborot-ALL as decimal   no-undo .
define buffer buf_buyer-in-buyer-group   for ub.buyer-in-buyer-group  .
define buffer buf_turnover-buyer-main    for ub.turnover-buyer-main  .
define buffer buf1_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf2_tnv-in-turnover-group for ub.tnv-in-turnover-group  .
define buffer buf_price-all              for ub.price-all  .
define buffer buf_goods                  for ub.goods      .
define buffer buf_global-state           for ub.global-state  .
define buffer buf_buyer-group            for ub.buyer-group  .
define buffer buf_turnover-group         for ub.turnover-group  .
define buffer buf_main-code              for ub.bar-code  .
define buffer buf_bar-code               for ub.bar-code  .
define buffer buf_pay-type               for ub.pay-type  .
define buffer buf_cash-pay               for ub.cash-pay  .
define variable to-day          as date      no-undo .
define variable v-base-rate0    as decimal   no-undo .
define variable v-base-scale0   as decimal   no-undo .
define variable v-exch-rate0    as decimal   no-undo .
define variable v-exch-scale0   as decimal   no-undo .
define variable v-base-rate     as decimal   no-undo .
define variable v-base-scale    as decimal   no-undo .
define variable v-exch-rate     as decimal   no-undo .
define variable v-exch-scale    as decimal   no-undo .
define variable v-host-code     as integer   no-undo .
define variable v-curr-abbr     as character no-undo .
define variable v-grp-name      as character no-undo .
define variable v-date-1        as date      no-undo .
define variable v-date-2        as date      no-undo .
define variable v-interv        as character no-undo .
define variable v-pay-name      as character no-undo .
define variable v-cli-oborot    as decimal   no-undo .
define variable v-trn-pay-code  as integer   no-undo .
define variable v-cash-pay-curr as integer   no-undo .
define variable v-cash-pay-code as integer   no-undo .
do
on error undo, return error return-value
:
find first buf_main-code no-lock where buf_main-code.b-code = p-main-b-code .
find first buf_goods no-lock where buf_goods.gds-code = buf_main-code.gds-code.
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ).
end.
if p-vid-pay <> "" then do:
   find first buf_pay-type no-lock where  buf_pay-type.obj-code = integer(p-vid-pay) no-error .
   if available buf_pay-type
      then v-trn-pay-code = buf_pay-type.obj-code.
      else v-trn-pay-code =  0.
end.
else v-trn-pay-code = 0 .
if p-cash-pay-type <> "" then do:
   find first buf_cash-pay no-lock where  recid(buf_cash-pay) = integer(p-cash-pay-type) no-error .
   if available buf_pay-type
      then
        assign
          v-cash-pay-curr = buf_cash-pay.curr-code
          v-cash-pay-code = buf_cash-pay.cdpay-code
        .
      else
        assign
          v-cash-pay-curr = 0
          v-cash-pay-code = 0
          .
end.
else
  assign
    v-cash-pay-curr = 0
    v-cash-pay-code = 0
    .
for each tt_price-all  : delete tt_price-all . end.
assign
  p-plt-id             = ?
  p-plt-db-num         = ?
  p-pdf-id             = ?
  p-pdf-db-num         = ?
  p-sale-price-base    = ?
  p-sale-price-rubl    = ?
  v-cli-oborot         = 0
.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  to-day
  ,output v-base-rate0
  ,output v-base-scale0
  )  .
  v-cli-oborot-ALL  = 0 .
  for each buf_turnover-buyer-main no-lock  where
           buf_turnover-buyer-main.cli-type = p-cli-type  and
           buf_turnover-buyer-main.cli-code = p-cli-code
           :
           v-cli-oborot-ALL = v-cli-oborot-ALL + buf_turnover-buyer-main.sum-doc-rubl-itog .
  end.
for each buf_price-all no-lock where
         buf_price-all.obj-type = p-obj-type and
         buf_price-all.obj-code = p-obj-code and
         buf_price-all.gds-code = buf_goods.gds-code and
         buf_price-all.status_  = 'акт':U  and
       ( p-only-b-code = false   or
       ( buf_price-all.b-code = p-main-b-code or
         buf_price-all.b-code = p-b-code))    and
        ( p-only-b-code = true  or
          buf_price-all.b-code = p-b-code)
          and
          buf_price-all.fact-order-sys-from  <= p-fact-order  and
        ( buf_price-all.fact-order-sys-to = ? or
          buf_price-all.fact-order-sys-to    >= p-fact-order)
        :
         v-interv   = "" .
         v-grp-name = "" .
         v-pay-name = "" .
         if buf_price-all.fact-order = 0  and buf_price-all.plt-priority = 0  then next.
         if buf_price-all.bgr-id > 0 then do:
            find first buf_buyer-group no-lock where
                       buf_buyer-group.bgr-id     = buf_price-all.bgr-id  and
                       buf_buyer-group.bgr-db-num = buf_price-all.bgr-db-num  no-error .
            if available buf_buyer-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
               find first buf_buyer-in-buyer-group no-lock where
                          buf_buyer-in-buyer-group.stts         = 0 and
                          buf_buyer-in-buyer-group.bgr-id       = buf_buyer-group.bgr-id     and
                          buf_buyer-in-buyer-group.bgr-db-num   = buf_buyer-group.bgr-db-num  and
                          buf_buyer-in-buyer-group.bbg-obj-type = p-cli-type and
                          buf_buyer-in-buyer-group.bbg-obj-code = p-cli-code
                          no-error .
                          if not available buf_buyer-in-buyer-group then do:
                             v-grp-name = "".
                             next.
                          end.
                          v-grp-name = buf_buyer-group.name .
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.tog-id > 0 then do:
            find first buf_turnover-group no-lock where
                       buf_turnover-group.tog-id     = buf_price-all.tog-id      and
                       buf_turnover-group.tog-db-num = buf_price-all.tog-db-num  no-error .
            if available buf_turnover-group then do:
               if p-cli-type <> "" and p-cli-type <> ? then do:
                  v-cli-oborot = v-cli-oborot-all  .
                  find first buf1_tnv-in-turnover-group no-lock where
                             buf1_tnv-in-turnover-group.stts       =  0     and
                             buf1_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf1_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf1_tnv-in-turnover-group.ttg-summa  <=  v-cli-oborot no-error .
                  find first buf2_tnv-in-turnover-group no-lock where
                             buf2_tnv-in-turnover-group.stts       =  0     and
                             buf2_tnv-in-turnover-group.tog-id     =  buf_turnover-group.tog-id     and
                             buf2_tnv-in-turnover-group.tog-db-num =  buf_turnover-group.tog-db-num and
                             buf2_tnv-in-turnover-group.ttg-summa  >=  v-cli-oborot no-error .
                  if not (available buf1_tnv-in-turnover-group and
                          available buf2_tnv-in-turnover-group ) then do:
                          v-grp-name = "".
                          next .
                  end.
                  v-grp-name = buf_turnover-group.name.
               end.
            end.
            else do:
                 v-grp-name = "".
                 next.
            end.
         end.
         if buf_price-all.plt-fix-cource-crc-base = true then
            assign
              v-base-rate  = buf_price-all.pdf-base-rate
              v-base-scale = buf_price-all.pdf-base-scale
            .
            else
            assign
              v-base-rate  = v-base-rate0
              v-base-scale = v-base-scale0
            .
         if buf_price-all.plt-fix-cource-crc-doc = true then
            assign
              v-exch-rate  = buf_price-all.pdf-exch-rate
              v-exch-scale = buf_price-all.pdf-exch-scale
            .
            else do:
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf_price-all.curr-code
  ,input  to-day
  ,output v-exch-rate0
  ,output v-exch-scale0
  ,output v-curr-abbr
  )  .
            assign
              v-exch-rate  = v-exch-rate0
              v-exch-scale = v-exch-scale0
              .
           end.
           v-date-1 = date ( "" )  .
           if buf_price-all.fact-order-sys-from > 0 then do:
              if buf_price-all.start-sys-date <> ?   then  v-date-1 = buf_price-all.start-sys-date.
              if buf_price-all.start-shift-date <> ? then  v-date-1 = buf_price-all.start-shift-date.
              if buf_price-all.start-date <> ?       then  v-date-1 = buf_price-all.start-date.
           end.
           v-date-2 =  date ( "" )  .
           if buf_price-all.fact-order-sys-to > 0 then do:
              if buf_price-all.end-sys-date <> ?     then  v-date-2 = buf_price-all.end-sys-date.
              if buf_price-all.end-shift-date <> ?   then  v-date-2 = buf_price-all.end-shift-date.
              if buf_price-all.end-date <> ?         then  v-date-2 = buf_price-all.end-date.
           end.
           if buf_price-all.qnty-from <> ? then do :
              if not (
              ( p-qnty-doc  >= buf_price-all.qnty-from and buf_price-all.qnty-to = ? ) or
              ( p-qnty-doc  >= buf_price-all.qnty-from and p-qnty-doc <= buf_price-all.qnty-to and buf_price-all.qnty-to <> ?)
              ) then do:
                     v-interv = "".
                     next.
              end.
              v-interv = "К: " + string(buf_price-all.qnty-from) + " - " + ( if buf_price-all.qnty-to = ? then "и более" else string(buf_price-all.qnty-to)) .
           end.
           if buf_price-all.sum-from <> ? then do :
              if not (
              ( p-sum-doc  >= buf_price-all.sum-from and buf_price-all.sum-to = ? ) or
              ( p-sum-doc  >= buf_price-all.sum-from and p-sum-doc <= buf_price-all.sum-to and buf_price-all.sum-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "C: " +  string(buf_price-all.sum-from) + " - " + ( if buf_price-all.sum-to = ? then "и более" else string(buf_price-all.sum-to)) .
           end.
           if buf_price-all.turnover-from <> ? then do :
              if not (
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and buf_price-all.turnover-to = ? ) or
              ( v-cli-oborot-ALL  >= buf_price-all.turnover-from and v-cli-oborot-ALL <= buf_price-all.turnover-to and buf_price-all.turnover-to <> ?)
              ) then do:
                 v-interv = "".
                 next.
              end.
              v-interv = "O: " +  string(buf_price-all.turnover-from) + " - " + ( if buf_price-all.turnover-to = ? then "и более" else string(buf_price-all.turnover-to)) .
           end.
           if buf_price-all.use-pay-type = 1 then do :
              if buf_price-all.pay-code <> v-trn-pay-code then do:
                 v-pay-name = "" .
                 next.
               end.
               v-pay-name = 'Оплата':U +  ":" + string(buf_price-all.pay-code) .
           end.
           if buf_price-all.use-cash-pay = 1 then do :
              if v-cash-pay-code <> 0 and  not ( buf_price-all.curr-pay-code = v-cash-pay-curr and
                                                 buf_price-all.cdpay-code    = v-cash-pay-code ) then do:
                v-pay-name = "" .
                next.
              end.
              v-pay-name = 'Касс.платеж':U + ":" + string(buf_price-all.cdpay-code) + "_" + string(buf_price-all.curr-pay-code).
           end.
          find first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-all.b-code no-error .
          create tt_price-all .
          buffer-copy buf_price-all to tt_price-all
          assign
            tt_price-all.price-sale-rubl = buf_price-all.price-sale  * v-exch-rate / v-exch-scale
            tt_price-all.road-tax-rubl   = buf_price-all.road-tax    * v-exch-rate / v-exch-scale
            tt_price-all.excise-rubl     = buf_price-all.excise      * v-exch-rate / v-exch-scale
            tt_price-all.price-sale-base = tt_price-all.price-sale-rubl  / v-base-rate * v-base-scale
            tt_price-all.road-tax-base   = tt_price-all.road-tax-rubl    / v-base-rate * v-base-scale
            tt_price-all.excise-base     = tt_price-all.excise-rubl      / v-base-rate * v-base-scale
            tt_price-all.price-sale     = buf_price-all.price-sale
            tt_price-all.road-tax       = buf_price-all.road-tax
            tt_price-all.excise         = buf_price-all.excise
            tt_price-all.pdf-exch-rate   = v-exch-rate
            tt_price-all.pdf-exch-scale  = v-exch-scale
            tt_price-all.pdf-base-rate   = v-base-rate
            tt_price-all.pdf-base-scale  = v-base-scale
            tt_price-all.grp-name        = v-grp-name
            tt_price-all.date-1          = v-date-1
            tt_price-all.shift-1         = buf_price-all.start-shift-num
            tt_price-all.time-1          = buf_price-all.start-sys-time
            tt_price-all.date-2          = v-date-2
            tt_price-all.shift-2         = buf_price-all.end-shift-num
            tt_price-all.time-2          = buf_price-all.end-sys-time
            tt_price-all.interv-name     = v-interv
            tt_price-all.pay-name        = v-pay-name
            tt_price-all.unit-cli        = buf_bar-code.unit-cli
          .
end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = p-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = neos_price-all.price-sale-base
            p-sale-price-rubl  = neos_price-all.price-sale-rubl
            p-road-tax-base    = neos_price-all.road-tax-base
            p-road-tax-rubl    = neos_price-all.road-tax-rubl
            p-excise-base      = neos_price-all.excise-base
            p-excise-rubl      = neos_price-all.excise-rubl
            .
         end.
         else do:
              find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
              if error-status :error    then do:
                message "Не найден бар-код" p-b-code view-as alert-box error .
                return error return-value .
              end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price-base  = tt_price-all.price-sale-base
            p-sale-price-rubl  = tt_price-all.price-sale-rubl
            p-road-tax-base    = tt_price-all.road-tax-base
            p-road-tax-rubl    = tt_price-all.road-tax-rubl
            p-excise-base      = tt_price-all.excise-base
            p-excise-rubl      = tt_price-all.excise-rubl * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
end.
end procedure.
procedure mpl-tpl-auto :
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-fact-order as decimal   no-undo .
define output parameter p-sale-price as decimal   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
if p-fact-order = ? then do:
  run fact-order-mpl (
      input   today       ,
      input   p-obj-type  ,
      input   p-obj-code  ,
      output  p-fact-order ) .
end.
assign
  p-pdf-id      = ?
  p-pdf-db-num  = ?
  p-sale-price  = ?
.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
if error-status :error then return error return-value .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
if error-status :error then return error return-value .
define variable v-main-b-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
define buffer buf_price-all for ub.price-all  .
for each tt_price-all : delete tt_price-all. end.
    for each buf_price-all no-lock where
            buf_price-all.plt-id     = p-plt-id                 and
            buf_price-all.plt-db-num = p-plt-db-num             and
            buf_price-all.obj-type   = p-obj-type               and
            buf_price-all.obj-code   = p-obj-code               and
            buf_price-all.gds-code   = buf_goods.gds-code       and
          ( buf_price-all.b-code = v-main-b-code or
            buf_price-all.b-code = p-b-code)    and
            buf_price-all.status_    = 'акт':U         and
            buf_price-all.fact-order-sys-from  <= p-fact-order  and
          ( buf_price-all.fact-order-sys-to = ? or
            buf_price-all.fact-order-sys-to >=  p-fact-order)
            :
              create tt_price-all .
              buffer-copy buf_price-all to tt_price-all
              assign
                tt_price-all.price-sale  = buf_price-all.price-sale
              .
    end.
define variable vt-plt-id as integer   no-undo .
define variable vt-plt-db as integer   no-undo .
define variable vt-pdf-id as integer   no-undo .
define variable vt-pdf-db as integer   no-undo .
define buffer neos_price-all for tt_price-all  .
find first tt_price-all where tt_price-all.b-code = v-main-b-code use-index pi no-error .
    if available tt_price-all then do:
     assign
       vt-plt-id = tt_price-all.plt-id
       vt-plt-db = tt_price-all.plt-db-num
       vt-pdf-id = tt_price-all.pdf-id
       vt-pdf-db = tt_price-all.pdf-db
     .
     if tt_price-all.b-code = p-b-code then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale
            .
     end.
     else do:
       find first neos_price-all where
                  neos_price-all.b-code     = p-b-code  and
                  neos_price-all.plt-id     = vt-plt-id and
                  neos_price-all.plt-db-num = vt-plt-db and
                  neos_price-all.pdf-id     = vt-pdf-id and
                  neos_price-all.pdf-db     = vt-pdf-db
                  use-index pi no-error .
         if available neos_price-all then do:
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = neos_price-all.price-sale
            .
         end.
         else do:
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        if error-status :error    then do:
           message "Не найден бар-код" p-b-code view-as alert-box error .
           return error return-value .
        end.
          assign
            p-plt-id           = tt_price-all.plt-id
            p-plt-db-num       = tt_price-all.plt-db-num
            p-pdf-id           = tt_price-all.pdf-id
            p-pdf-db-num       = tt_price-all.pdf-db
            p-sale-price       = tt_price-all.price-sale * buf_bar-code.cli-base-rate
            .
         end.
     end.
  end.
  end.
end procedure.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable v-del-mrkt-gds               as logical        no-undo .
define variable v-send-stock-qnty            as logical        no-undo .
DEFINE VARIABLE jj                           as integer        no-undo .
DEFINE VARIABLE crgd                         as integer        no-undo .
DEFINE VARIABLE cr-txr                       as integer        no-undo .
define variable cr-ncr-dis-kat               as integer        no-undo .
DEFINE VARIABLE start-paket-txr              as logical init yes no-undo .
define variable v-count                      as integer          no-undo .
DEFINE VARIABLE var-report-num               as integer          no-undo .
DEFINE VARIABLE g#log                        as logical          no-undo .
DEFINE VARIABLE v-today                      as date             no-undo .
DEFINE VARIABLE v-time                       as integer          no-undo .
define variable v-r-b-curr-magia             as integer          no-undo .
DEFINE VARIABLE ind                          as integer          no-undo .
DEFINE VARIABLE s as character no-undo.
define variable v-index as integer no-undo .
DEFINE VARIABLE conf-attr                         as character        no-undo .
DEFINE VARIABLE conf-par                         as character        no-undo .
DEFINE VARIABLE par-type                        as character        no-undo .
DEFINE VARIABLE prichina                     as character        no-undo .
define buffer lock-batchprocess for ub.batchprocess .
define buffer request_prod-bc for ub.prod-bc.
define buffer r-gds-prt for ub.gds-prt.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define stream plucash.
define stream bar.
DEFINE VARIABLE chk_name                     as character        no-undo .
DEFINE VARIABLE bar_code                     as character        no-undo .
DEFINE VARIABLE b_code                       as character        no-undo .
DEFINE VARIABLE curr_cass                    as decimal          no-undo .
DEFINE VARIABLE dob-curr                     as character        no-undo .
DEFINE VARIABLE l-empty-scale                as logical          no-undo .
DEFINE VARIABLE for-SHOP-NAME                as character        no-undo .
DEFINE VARIABLE for-producer                 as character        no-undo .
DEFINE VARIABLE for-producer-int             as integer          no-undo .
DEFINE VARIABLE for-fact-qnty                like ub.gds-obj.fact-qnty no-undo .
DEFINE VARIABLE for-okdp                     like ub.goods.okdp  no-undo .
DEFINE VARIABLE temp-discnt-rule_            as integer          no-undo .
DEFINE VARIABLE temp-discnt-method_          as character        no-undo .
DEFINE VARIABLE temp-discnt-rule_pdf         as integer          no-undo .
DEFINE VARIABLE std-discnt-rule_             as integer          no-undo .
DEFINE VARIABLE for-wd                       as integer          no-undo .
DEFINE VARIABLE for-wgd                      as integer          no-undo .
DEFINE VARIABLE for-fp                       as logical          no-undo .
define variable for-petrol-purse             as logical          no-undo .
define variable need-auth                    as logical          no-undo .
DEFINE VARIABLE for-grp-code                 like ub.sum-grp.grp-code no-undo .
DEFINE VARIABLE main-b-code                  like ub.bar-code.b-code  no-undo .
DEFINE VARIABLE for-price                    as decimal          no-undo .
DEFINE VARIABLE for-road                     as decimal          no-undo .
DEFINE VARIABLE for-excise                   as decimal          no-undo .
DEFINE VARIABLE cashparts                    like ub.gds-obj.cash-parts no-undo .
DEFINE VARIABLE petrol-trk                   as logical          no-undo .
DEFINE VARIABLE tax-string                   as character        no-undo init "" .
DEFINE VARIABLE new-good                     as logical          no-undo init yes .
DEFINE VARIABLE IBM-good-code                as character        no-undo .
DEFINE VARIABLE qnty-discnt-rule_            as integer          no-undo init 0 .
DEFINE VARIABLE kat-discnt-rule_             as integer          no-undo init 0 .
DEFINE VARIABLE kat-discnt-method_           as character        no-undo .
DEFINE VARIABLE kat-discnt-rule_pdf          as integer          no-undo .
DEFINE VARIABLE date-discnt-rule_            as integer          no-undo init 0 .
DEFINE VARIABLE abs-discnt-rule_             as integer          no-undo init 0 .
DEFINE VARIABLE tot-discnt-rule_             as integer          no-undo init 0 .
define variable for-taracode                 as character        no-undo init "00".
define variable dflt-cd                      as character        no-undo .
DEFINE VARIABLE is-sc                        as logical          no-undo .
DEFINE VARIABLE taracode-bc                  as character        no-undo .
DEFINE VARIABLE rdtaxcd                      as INTEGER          no-undo .
DEFINE VARIABLE vattaxcd                     as INTEGER          no-undo .
DEFINE VARIABLE exctaxcd                     as INTEGER          no-undo .
define variable v-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define variable v-is-menu                    like ub.fbr-gds-obj.is-menu no-undo .
define variable v-is-semi-finished           like ub.fbr-gds-obj.is-semi-finished no-undo .
define variable v-is-modificator             like ub.fbr-gds-obj.is-modificator no-undo .
define variable v-fbr-grp-code               like ub.fbr-gds-grp.node-code no-undo .
define variable v-fbr-obj-code               like ub.fbr-gds-obj.fbr-obj-code no-undo .
DEFINE VARIABLE alllstcs                     as logical           no-undo init no .
DEFINE VARIABLE noautocs                     as logical           no-undo init no .
DEFINE VARIABLE mask_s-c                     as character         no-undo .
DEFINE VARIABLE unq-artc                     as logical           no-undo init no .
DEFINE VARIABLE nam-2str                     as logical           no-undo init no .
DEFINE VARIABLE nam-artc                     as logical           no-undo init no .
DEFINE VARIABLE name-2cd                     as character       no-undo .
DEFINE VARIABLE cod-pcod                     as logical           no-undo .
DEFINE VARIABLE tax-cass                     as logical           no-undo init no .
DEFINE VARIABLE ipcsc-pfx                    as integer           no-undo init 23 .
DEFINE VARIABLE ipcpg-pfx                    as integer           no-undo init 24 .
DEFINE VARIABLE ncrgmdsc                     as character         no-undo .
DEFINE VARIABLE ncrdsc                       as character         no-undo .
DEFINE VARIABLE ncrdrank                     as character         no-undo  init "TX":U.
DEFINE VARIABLE ncrsc-pfx                    as character         no-undo init "23":U .
DEFINE VARIABLE ncrsc-frmt                   as character         no-undo init "EAN13" .
DEFINE VARIABLE ncrpg-pfx                    as character         no-undo init "24":U .
DEFINE VARIABLE ncrpg-frmt                   as character         no-undo init "EAN13" .
define variable ncr-save-param               as character         no-undo init 'no'.
DEFINE VARIABLE txfixnum                     as INTEGER           no-undo .
DEFINE VARIABLE rnd-znak                     as integer           no-undo init 2 .
DEFINE VARIABLE amntdisc                     as integer           no-undo .
DEFINE VARIABLE how-temp-disc                as character         no-undo .
DEFINE VARIABLE how-pcnt-kat                 as character         no-undo .
DEFINE VARIABLE discnt-to-send               as character         no-undo .
define variable v-is-restaurant              as logical no-undo .
define variable cd-vat                       as integer           no-undo .
define variable cdtaxlst                     as character         no-undo .
define variable v-20-part1 as integer no-undo init 2621.
define variable v-record as character no-undo .
define variable dr-list as character no-undo .
define variable drgdsrank as character no-undo .
define buffer buf_currency for ub.currency.
define buffer buf_producer for ub.clients.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
def var vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table cash-dis-rule no-undo like ub.dis-rule.
define temp-table cash-dis-time-rule no-undo like ub.dis-time-rule.
procedure create-dis-rule :
define input parameter p-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-tree as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_dis-time-rule for ub.dis-time-rule.
define buffer term_dis-rule for ub.dis-rule.
define buffer term_dis-time-rule for ub.dis-time-rule.
define buffer root_cash-dis-rule for cash-dis-rule.
define buffer root_cash-dis-time-rule for cash-dis-time-rule.
define buffer term_cash-dis-rule for cash-dis-rule.
define buffer term_cash-dis-time-rule for cash-dis-time-rule.
  do
  on error undo, return error
  :
    find first root_cash-dis-rule no-lock where                                                         ~
              root_cash-dis-rule.rule-num = p-rule-num no-error.
    if not available root_cash-dis-rule then do:
      find first buf_dis-rule no-lock where
                buf_dis-rule.rule-num = p-rule-num no-error.
      if available buf_dis-rule then do:
        if buf_dis-rule.time-rule-num <> 0 then do:
          find first buf_dis-time-rule no-lock where
                    buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
        end.
        create root_cash-dis-rule.
        buffer-copy buf_dis-rule to root_cash-dis-rule.
        if available buf_dis-time-rule then do:
          find first root_cash-dis-time-rule no-lock where
                    root_cash-dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num no-error.
          if not available root_cash-dis-time-rule then do:
            create root_cash-dis-time-rule.
            buffer-copy buf_dis-time-rule to root_cash-dis-time-rule.
          end.
        end.
        else do:
          assign
          root_cash-dis-rule.time-rule-num = 0.
        end.
        if buf_dis-rule.uniq-field <> "":U then do:
          for each term_dis-rule no-lock where
                  term_dis-rule.upper-rule-num =  buf_dis-rule.rule-num:
            if term_dis-rule.time-rule-num <> 0 then do:
              find first term_dis-time-rule no-lock where
                        term_dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
            end.
            create term_cash-dis-rule.
            buffer-copy term_dis-rule to term_cash-dis-rule.
            if term_dis-rule.time-rule-num = 0
            or available term_dis-time-rule
            or root_cash-dis-rule.time-rule-num = 0
            then do:
              if available term_dis-time-rule then do:
                find first term_cash-dis-time-rule no-lock where
                          term_cash-dis-time-rule.time-rule-num = term_dis-rule.time-rule-num no-error.
                if not available term_cash-dis-time-rule then do:
                  create term_cash-dis-time-rule.
                  buffer-copy term_dis-time-rule to term_cash-dis-time-rule.
                end.
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end procedure.
define temp-table temp-cd-plu no-undo like ub.cd-plu .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function ncr-amnt-disc returns character (
  input p-pcnt-discnt-rule as integer, input p-price-sale as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
for each cash-dis-rule  no-lock where
      cash-dis-rule.upper-rule-num = p-pcnt-discnt-rule:
  assign
  ii = ii + 1
  v-entry[ii] = "000000":U + string(round(cash-dis-rule.doc-qnty / cash-gds.cli-base-rate, 0), "999999":U) +
                replace(string(p-price-sale * (1 - cash-dis-rule.discnt-value / 100), "999999.99"), ".":U, "":U)
  .
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.
END FUNCTION.
function ncr-date-disc returns character (
  input p-date-discnt-rule  as integer, input p-price-sale as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
for each cash-dis-rule  no-lock where
      cash-dis-rule.upper-rule-num = p-date-discnt-rule,
    first cash-dis-time-rule no-lock where cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num :
  assign
  ii = ii + 1
  v-entry[ii] =
                substring(string(year(cash-dis-time-rule.date-from), "9999":U), 3, 2)   +
                string(month(cash-dis-time-rule.date-from), "99":U) +
                string(day(cash-dis-time-rule.date-from), "99":U)  +
                substring(string(year(cash-dis-time-rule.date-to), "9999":U), 3, 2)   +
                string(month(cash-dis-time-rule.date-to), "99":U) +
                string(day(cash-dis-time-rule.date-to), "99":U) +
                replace(string(cash-gds.price-sale * (1 - cash-dis-rule.discnt-value / 100), "999999.99"), ".":U, "":U).
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.
END FUNCTION.
function ncr-temp-disc returns character (
  input p-temp-discnt-rule  as integer, input p-price-sale as decimal, p-temp-disc-dec as decimal).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
define variable v-entry as character no-undo extent 3.
define variable v-dec as decimal no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule.
find first buf_cash-dis-rule where
         buf_cash-dis-rule.rule-num = p-temp-discnt-rule no-error .
if not available buf_cash-dis-rule then return "":U.
if buf_cash-dis-rule.templ-rl-root <> 29
and buf_cash-dis-rule.templ-rl-root <> 86
then do:
  assign
  v-entry[1] =
  "000"                                                   +
  "0"                                                     +
  "0000"                                                  +
  "2359"                                                     +
   replace(string(cash-gds.price-sale * (1 + p-temp-disc-dec / 100), "999999.99"), ".":U, "":U)
   .
end.
else do:
  for each cash-dis-rule  no-lock where
        cash-dis-rule.upper-rule-num = p-temp-discnt-rule ,
      first cash-dis-time-rule no-lock where cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num :
    case cash-dis-rule.value-type:
      when integer('1':U) then do:
        v-dec = cash-gds.price-sale * (1 - cash-dis-rule.discnt-value / 100).
      end.
      when integer('12':U) then do:
        find first cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
              and cash-gds-discnt.rule-num = cash-dis-rule.rule-num
              and cash-gds-discnt.obj-type = 'маг':U
              and cash-gds-discnt.obj-code = i-obj-code
              no-error.
        if not available cash-gds-discnt then do:
          v-dec = cash-gds.price-sale.
        end.
        else do:
          assign
          v-dec = cash-gds-discnt.discnt-value
          .
        end.
      end.
      otherwise do:
        v-dec = cash-gds.price-sale.
      end.
    end case.
    assign
    ii = ii + 1
    v-entry[ii] =
                  "000"                                                   +
                  (if cash-dis-time-rule.week-day-0 then "0" else "":U)   +
                  (if cash-dis-time-rule.week-day-7 then "1" else "":U)   +
                  (if cash-dis-time-rule.week-day-1 then "2" else "":U)   +
                  (if cash-dis-time-rule.week-day-2 then "3" else "":U)   +
                  (if cash-dis-time-rule.week-day-3 then "4" else "":U)   +
                  (if cash-dis-time-rule.week-day-4 then "5" else "":U)   +
                  (if cash-dis-time-rule.week-day-5 then "6" else "":U)   +
                  (if cash-dis-time-rule.week-day-6 then "7" else "":U)   +
                  replace(string(cash-dis-time-rule.time-from, "HH:MM"), ":":U, "":U) +
                  replace(string(cash-dis-time-rule.time-to, "HH:MM"), ":":U, "":U) +
                  replace(string(v-dec, "999999.99"), ".":U, "":U)
    .
if ii = 3 then leave.
  end.
end.
if v-entry[2] = "":U then
assign
v-entry[2] = v-entry[1]
.
if v-entry[3] = "":U then
assign
v-entry[3] = v-entry[2]
.
assign
v-result = v-entry[1] + v-entry[2] + v-entry[3]
.
return v-result.
END FUNCTION.
function ncr-d-rank returns character (
  input p-d-rank as character, input p-pcnt-discnt-rule  as integer, input p-temp-discnt-rule as integer, input p-date-discnt-rule as integer).
define variable v-result as character no-undo .
define variable ii as integer no-undo .
do ii = 1 to length(p-d-rank):
  CASE substr(p-d-rank, ii, 1):
    when "X":U then do:
      if p-pcnt-discnt-rule <> 0 then v-result = "X":U.
    end.
    when "T":U then do:
      if p-temp-discnt-rule <> 0 then v-result = "T":U.
    end.
    when "D":U then do:
      if p-date-discnt-rule <> 0 then v-result = "D":U.
    end.
  END CASE.
  if v-result <> "":U then LEAVE.
end.
if v-result = "":U then v-result = chr(32).
return v-result.
END FUNCTION.
FUNCTION check-ban-sales-via-cd return logical ( input p-gds-code as integer ) :
    define variable v-upper-code as int no-undo.
    define variable v-value as character no-undo.
    define variable v-type as character no-undo.
    define buffer lc_gds-grp for ub.gds-grp.
    define buffer lc_goods for ub.goods.
   if p-gds-code <> 0 then do:
    find first lc_goods where lc_goods.gds-code = p-gds-code.
    v-upper-code = lc_goods.grp-code.
    do while v-upper-code > 0 :
        find first lc_gds-grp where lc_gds-grp.node-code = v-upper-code.
        run ggoattr-value(
          input lc_gds-grp.node-code,
          input 0,
          input "",
          input 0,
          input 'ban-sales-via-cd':U,
          output v-value,
          output v-type
        ).
       if v-value = "yes" then
          return true.
       else
       do:
          run ggoattr-value(
             input lc_gds-grp.node-code,
             input shop.host-code,
             input "",
             input 0,
             input 'ban-sales-via-cd':U,
             output v-value,
             output v-type
             ).
          if v-value = "yes" then
             return true.
          else
          do:
             run ggoattr-value(
                input lc_gds-grp.node-code,
                input shop.host-code,
                input 'маг':U,
                input i-obj-code,
                input 'ban-sales-via-cd':U,
                output v-value,
                output v-type
                ).
             if v-value = "yes" then
                return true.
             else v-upper-code = lc_gds-grp.upper-code.
          end .
       end.
      end.
    end.
end.
FUNCTION convert-tax-code returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return integer(entry(2, entry(jj, p-cdtaxlst, ";"), "-":U)).
    end.
  end.
END FUNCTION.
FUNCTION convert-maria-tax-code returns character
                                          ( input p-vat-rate-code as integer
                                           ,input p-slt-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable aa as character no-undo extent 8.
define variable v-return-value as character no-undo .
  do jj = 1 to 8:
    if jj <= num-entries(p-cdtaxlst, ";") then do:
      if entry(jj, p-cdtaxlst, ";") begins (string(p-vat-rate-code) + "-") then do:
        aa[jj] = '1'.
      end.
      if entry(jj, p-cdtaxlst, ";") begins (string(p-slt-rate-code) + "-") then do:
        aa[jj] = '1'.
      end.
    end.
    if aa[jj] = '':U then aa[jj] = '0'.
    v-return-value = aa[jj] + v-return-value.
  end.
return v-return-value.
END FUNCTION.
FUNCTION convert-maria-tax-code-2 returns integer
                                          ( input p-rate-code as integer
                                           ,input p-cdtaxlst  as character
                                          ) :
define variable jj as integer no-undo .
define variable v-return-value as integer no-undo .
  do jj = 1 to num-entries(p-cdtaxlst, ";"):
    if entry(jj, p-cdtaxlst, ";") begins (string(p-rate-code) + "-") then do:
      return jj.
    end.
  end.
return 0.
END FUNCTION.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable varscales-pref-type52 as character no-undo.
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
  ,output varscales-pref-type52
  ) no-error .
if varscales-pref = ? then do:
  assign
  varscales-pref = '21,23,25':U.
end.
define variable varpgscales-pref-type52 as character no-undo.
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
  ,output varpgscales-pref-type52
  ) no-error .
if varpgscales-pref = ? then do:
  assign
  varpgscales-pref = '24IIIIIQQ000C,28IIIIIQQQ00C':U.
end.
define variable callpoint                    as character      no-undo .
assign
v-del-mrkt-gds = lookup("del-mrkt-gds":U, p-other) > 0
v-send-stock-qnty = lookup("send-stock-qnty":U, p-other) > 0
.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE asc-gds.
DEFINE parameter buffer loc-goods for gds-list.
DEFINE parameter buffer loc-bar-code for ub.bar-code.
DEFINE parameter buffer loc-gds-prt-root for ub.gds-prt.
DEFINE parameter buffer loc-gds-obj for ub.gds-obj.
DEFINE parameter buffer loc-price-list for ub.price-list.
DEFINE parameter buffer loc-units for ub.units.
DEFINE parameter buffer loc-gds-prt-term for ub.gds-prt.
DEFINE input parameter loc-prod-bc like ub.prod-bc.b-str.
DEFINE input parameter loc-bc-on-type like ub.prod-bc.bc-on-type.
DEFINE input parameter loc-bc-units-cli-type like ub.units.type.
DEFINE input parameter loc-bc-units-okei like ub.units.okei.
define input parameter parhost-code like ub.sysconf.host-code no-undo .
define input parameter parobj-type like ub.clients.obj-type no-undo .
define input parameter parobj-code like ub.clients.obj-code no-undo .
define variable v-doc-num like ub.price-list.doc-num no-undo .
DEFINE VARIABLE vat-value like ub.doc-line.vat-pc no-undo .
DEFINE VARIABLE slt-value like ub.doc-line.slt-pc no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define variable v-oss as character no-undo.
define variable v-gtd as character no-undo .
define variable v-is-gas as character no-undo .
define variable v-ban-bonus as character no-undo .
define variable v-ptrl-as-good as character no-undo .
define variable v-type as character no-undo .
define variable disc-b-code as integer no-undo .
define variable v-main-prt-b-code as integer no-undo .
define variable IBM-good-code as character no-undo .
define variable IBM-good-code-2 as character no-undo .
define variable IBM2-short      as character no-undo .
define variable v-gds-null-price as character no-undo .
define variable iii as integer no-undo .
define variable v-mask-full as character no-undo .
define variable v-mask-short as character no-undo .
define variable vKKT as integer no-undo.
define variable attrValue as character no-undo.
define variable attrType  as character no-undo.
DEFine BUFFER BUF_BAR-CODE FOR UB.BAR-CODE.
define buffer buf_price-list for ub.price-list.
define buffer buf_price-doc-forming-gds FOR UB.PRICE-doc-forming-gds.
define buffer buf_temp-dis-gds-rule for temp-dis-gds-rule.
define buffer main-prt-bar-code  for ub.bar-code.
define buffer buf_goods-attr for goods-attr.
define buffer b-code for code.
if action = "U" then do:
  if loc-bar-code.stts = Integer('79':U) then return.
    for-price = ?.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  'маг':U
  ,input  ub.shop.obj-code
  ,input  loc-bar-code.b-code
  ,input  main-b-code
  ,input  0
  ,output v-doc-num
  ,output for-price
  ,output for-road
  ,output for-excise
  ) no-error .
    if error-status:error then do:
        if g#news
        or g#auto
        or g#esys
        then return error.
        else do:
            error-status:error = no.
            message "Ошибка при определении цены на товар "
                    loc-goods.artic loc-goods.prod-type loc-goods.prod-code
            view-as alert-box ERROR.
            return.
        end.
    end.
    if return-value = "error" then do:
        if for-price = ? then do:
          return.
        end.
        if not g#news
        and not g#auto
        and not g#esys
        then
        message prichina view-as alert-box ERROR.
        return error.
    end.
    else if (for-price = ? or for-price = 0) then do:
      if v-is-restaurant and v-is-null-price  then do:
        assign
        for-price = 0.
      end.
      else do:
        run gds-attr-value in this-procedure  ( input loc-goods.gds-code
                                               ,input 'null-price':U
                                               ,output v-gds-null-price
                                               ,output v-type) no-error.
        if (not logical(v-gds-null-price) and for-price = 0) or for-price = ? then
        return "NEXT".
      end.
    end.
  end.
  else do:
        for-price = 0.
  end.
for-price = round-m( for-price , rnd-znak ).
FIND FIRST cash-gds where cash-gds.crf = (cr + 1) No-ERROR.
start-paket = no.
if not avail cash-gds then do:
create cash-gds.
error-status:error = false.
end.
cash-gds.crf = cr + 1.
cr = cr + 1.
if loc-bar-code.in-code <> ''
or loc-bar-code.part-code <> ''
then do:
  find first main-prt-bar-code no-lock where
            main-prt-bar-code.gds-code = loc-goods.gds-code
        and main-prt-bar-code.node-code = loc-bar-code.node-code
        and main-prt-bar-code.unit-cli = loc-bar-code.unit-cli
        and main-prt-bar-code.part-code = ''
        and main-prt-bar-code.in-code = '' no-error.
  if available main-prt-bar-code then do:
    v-main-prt-b-code = main-prt-bar-code.b-code.
  end.
end.
else do:
  v-main-prt-b-code = loc-bar-code.b-code.
end.
find first tt-tax no-lock where
           tt-tax.tax-code = vattaxcd no-error .
do iii = 1 to num-entries(mask_s-c) :
  assign
    v-mask-full  = trim(entry(iii, mask_s-c))
    v-mask-short = entry(1, v-mask-full, "*")
    loc-prod-bc  = trim(loc-prod-bc)
  .
  if length(v-mask-full) = length(loc-prod-bc) and  substring(loc-prod-bc, 1, length(v-mask-short)) = v-mask-short then
    loc-prod-bc = "*" + substring(loc-prod-bc, length(v-mask-short) + 1).
end.
define variable vBc-on as logical no-undo.
if loc-prod-bc ne ?
then do:
    find first prod-bc where prod-bc.b-code eq loc-bar-code.b-code
                         and prod-bc.b-str  eq loc-prod-bc
                         no-lock no-error.
    if available prod-bc
    then
       vBc-on = prod-bc.bc-on.
    else
       vBc-on = yes.
end.
else
   vBc-on = yes.
run gdsoattr-value in this-procedure (
  'dt-seasons':U,
  loc-goods.gds-code,
  parobj-type,
  parobj-code,
  output attrValue,
  output attrType
) no-error.
if attrValue <> "" then do:
  find first b-code where
             b-code.parent = "DTSeasons"
         and b-code.code   = attrValue
       no-lock no-error.
  v-main-prt-b-code = integer(b-code.code).
end.
else release b-code.
assign
cash-gds.gds-code = loc-goods.gds-code
cash-gds.artic = loc-goods.artic
cash-gds.b-code = loc-bar-code.b-code
cash-gds.main-prt-b-code = v-main-prt-b-code
cash-gds.b-str = if loc-prod-bc = ? then "" else loc-prod-bc
cash-gds.bc-on-type = loc-bc-on-type
cash-gds.bc-on = vBc-on
cash-gds.unit-cli = loc-bar-code.unit-cli
cash-gds.cli-base-rate = loc-bar-code.cli-base-rate
cash-gds.std-discnt-rule = std-discnt-rule_
cash-gds.gds-namelong = loc-goods.gds-name
cash-gds.gds-name = IF nam-2str
                    then if available b-code then b-code.codename else loc-goods.gds-name
                    else (
                          IF nam-artc
                          then loc-goods.artic
                          else if available b-code
                               then b-code.codename
                               else (if loc-goods.chk-name <> ""
                                     then loc-goods.chk-name
                                     else loc-goods.gds-name)
                         )
cash-gds.f-name = if NOT l-empty-scale then loc-gds-prt-term.f-name else ""
cash-gds.unit-base = loc-goods.unit-base
cash-gds.grp-code = for-grp-code
cash-gds.fp = for-fp
cash-gds.ingredient = loc-goods.struct
cash-gds.producer = for-producer
cash-gds.producer-int = for-producer-int
cash-gds.alpha1     = loc-goods.alpha1.
  run gds-attr-value in this-procedure  ( input cash-gds.gds-code
                                         ,input 'office-type':U
                                         ,output v-oss
                                         ,output v-type) no-error.
cash-gds.office-type = v-oss.
  run gds-attr-value in this-procedure  ( input cash-gds.gds-code
                                         ,input 'type-method-calc':U
                                         ,output v-oss
                                         ,output v-type) no-error.
if v-oss <> "" then
  assign
    cash-gds.CalculationMethod = int(entry(1,v-oss,","))
    cash-gds.CalculationMethodRestr = if num-entries(v-oss,",") > 1 then int(entry(2,v-oss,",")) else 0
  .
else
  assign
    cash-gds.CalculationMethod = 0
    cash-gds.CalculationMethodRestr = 0
  .
assign
cash-gds.fact-qnty = for-fact-qnty
cash-gds.okei = loc-bc-units-okei
cash-gds.kat-discnt-method = kat-discnt-method_
cash-gds.temp-discnt-method = temp-discnt-method_
cash-gds.kat-discnt-rule = (if how-pcnt-kat = 'pcnt-kat-pdf':U
                             then  kat-discnt-rule_pdf
                             else  kat-discnt-rule_)
cash-gds.date-discnt-rule = date-discnt-rule_
cash-gds.abs-discnt-rule = abs-discnt-rule_
cash-gds.tot-discnt-rule = tot-discnt-rule_
cash-gds.wgd-rule = for-wgd
cash-gds.gds-stat = ( if lookup( 'вес':U, loc-bc-units-cli-type ) > 0 OR lookup('дро':U, loc-bc-units-cli-type) > 0
                        then 1
                        else 0)
cash-gds.gds-stat = (if (lookup('топ':U, loc-units.type) > 0 AND lookup('дро':U, loc-units.type) > 0)
                     or for-petrol-purse
                     then (cash-gds.gds-stat + 8)
                     else cash-gds.gds-stat)
cash-gds.gds-stat = if (loc-goods.gds-type = 'у':U and (cash-gds.gds-stat < 8 or for-petrol-purse))
                    then (cash-gds.gds-stat + 16)
                    else cash-gds.gds-stat
cash-gds.gds-stat = if cash-gds.fp
                    then (cash-gds.gds-stat + 2)
                    else cash-gds.gds-stat
cash-gds.gds-stat = if cash-gds.wgd-rule > 0
                    then (cash-gds.gds-stat + 128)
                    else cash-gds.gds-stat
cash-gds.office = if loc-goods.gds-type = 'у':U then 1 else 0
cash-gds.temp-discnt-rule = (if how-temp-disc = 'temp-disc-pdf':U
                             then temp-discnt-rule_pdf
                             else temp-discnt-rule_)
cash-gds.wd-rule = for-wd
cash-gds.pp = (if for-petrol-purse then 1 else 0)
cash-gds.need-auth = (if need-auth then 1 else 0)
cash-gds.price-sale =  for-price
cash-gds.unit-type = loc-units.type
cash-gds.unit-cli-type = loc-bc-units-cli-type
cash-gds.tax-string = tax-string
cash-gds.new-good = new-good
cash-gds.rc = recid(loc-goods)
cash-gds.qnty-discnt-rule = qnty-discnt-rule_
cash-gds.vat-pc = (if avail tt-tax
                   then tt-tax.rate-value
                   else 0)
cash-gds.vat-code = (if avail tt-tax
                     then tt-tax.rate-code
                     else ?)
cash-gds.is-menu  = (if v-is-menu then 1 else 0)
cash-gds.is-semi-finished = (if v-is-semi-finished then 1 else 0)
cash-gds.is-modificator = (if v-is-modificator then 1 else 0)
cash-gds.fbr-grp-code = v-fbr-grp-code
cash-gds.fbr-grp-code-0 = loc-goods.fbr-grp-code
cash-gds.DepartID = v-fbr-obj-code
cash-gds.zp = (if v-is-null-price then 1 else 0)
cash-gds.node-code = loc-bar-code.node-code
cash-gds.taracode = for-taracode
cash-gds.is-main-code = (if cash-gds.b-str = ""
                         and loc-bar-code.in-code = ""
                         and loc-bar-code.part-code = ""
                         and cash-gds.unit-base = cash-gds.unit-cli
                         then yes
                         else no)
cash-gds.obj-type = parobj-type
cash-gds.obj-code = parobj-code
.
assign
cash-gds.gds-name1 =   name-2cdf(
                      input name-2cd
                    , input yes
                    , input cod-pcod
                    , input cash-gds.b-code
                    , input loc-goods.gds-code
                    , input loc-goods.artic
                    , input loc-goods.engl-name
                    , input loc-bar-code.in-code
                    , input loc-bar-code.part-code
                    , input parobj-type
                    , input parobj-code
                    , input loc-goods.alpha1
                    , output v-gtd
                    )
cash-gds.gtd   = v-gtd
.
vKKT = 255.
find first b-code where
           b-code.parent  = "okei-kkt"
       and b-code.code    = string(cash-gds.okei)
       and b-code.status_ = 0
no-lock no-error.
if avail b-code then
   vKKT = integer(b-code.CodeName) no-error.
if error-status:error then vKKT = 255.
cash-gds.kkt = vKKT.
if (lookup('топ':U, loc-units.type) > 0 AND lookup('дро':U, loc-units.type) > 0) then do:
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input 'fuel-type':U
                                         ,output v-is-gas
                                         ,output v-type) no-error.
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input 'ptrl-as-good':U
                                         ,output v-ptrl-as-good
                                         ,output v-type) no-error.
   assign
   cash-gds.ptrl-as-good = logical(v-ptrl-as-good)
   no-error .
   assign
   cash-gds.is-gas = (v-is-gas = 'metan':U)
   no-error .
   if cash-gds.is-gas then do:
     cash-gds.gds-stat = cash-gds.gds-stat + 64.
   end.
end.
   run gds-attr-value in this-procedure  (
                                          input cash-gds.gds-code
                                         ,input 'ban-bonus':U
                                         ,output v-ban-bonus
                                         ,output v-type) no-error.
  assign
   cash-gds.wd = int(logical(v-ban-bonus))
   no-error .
if how-temp-disc = 'temp-disc':U then do:
  case temp-discnt-method_:
    when "" then do:
    end.
    when "bar-code.b-code" then do:
      if loc-bar-code.in-code <> ''
      or loc-bar-code.part-code <> ''
      then do:
        disc-b-code = cash-gds.main-prt-b-code.
      end.
      else do:
        disc-b-code = cash-gds.b-code.
      end.
      find first buf_temp-dis-gds-rule where
              buf_temp-dis-gds-rule.gds-code = cash-gds.gds-code
          and buf_temp-dis-gds-rule.nonunique = string( disc-b-code) no-error.
      if available buf_temp-dis-gds-rule then do:
          cash-gds.temp-discnt-rule = buf_temp-dis-gds-rule.rule-num.
      end.
    end.
    otherwise do:
      cash-gds.temp-discnt-rule = 0.
    end.
  end.
end.
assign
cash-gds.gds-name1 =   name-2cdf(
                      input name-2cd
                    , input yes
                    , input cod-pcod
                    , input cash-gds.b-code
                    , input loc-goods.gds-code
                    , input loc-goods.artic
                    , input loc-goods.engl-name
                    , input loc-bar-code.in-code
                    , input loc-bar-code.part-code
                    , input parobj-type
                    , input parobj-code
                    , input loc-goods.alpha1
                    , output v-gtd
                    )
cash-gds.gtd   = v-gtd
.
assign
cash-gds.ean-lz = ''
cash-gds.ean-rz = ''
cash-gds.code-short = ''
.
run ibm-gdsc in this-procedure (input no
                              , output cash-gds.ean-lz
                              , output cash-gds.ean-rz
                              , output cash-gds.code-short
                              ) no-error .
if new-good then new-good = not new-good.
if action = "U" then do:
  if cash-gds.kat-discnt-rule <> 0
  and how-pcnt-kat = 'pcnt-kat-pdf':U
  then do:
    for each cash-dis-rule no-lock where
          cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule
    :
      run mpl-tpl-auto in this-procedure ( input cash-gds.b-code
                                          ,input 'маг':U
                                          ,input i-obj-code
                                          ,input integer(entry(1, cash-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, cash-dis-rule.charkey_one,"-"))
                                          ,input ?
                                          ,output v-disc-price-sale
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num ) no-error.
      if error-status:error
      or v-disc-price-sale = 0
      or v-disc-price-sale = ?
      then do:
      end.
      else do:
        find first  cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = parobj-type
                and cash-gds-discnt.obj-code = parobj-code No-ERROR.
        if not available cash-gds-discnt then do:
          find first  cash-gds-discnt where
                    cash-gds-discnt.crf = (crgd + 1) No-ERROR.
          if not available cash-gds-discnt then do:
            create cash-gds-discnt.
            assign
            cash-gds-discnt.crf = crgd + 1.
          end.
          crgd = crgd + 1.
          assign
          cash-gds-discnt.b-code = cash-gds.b-code
          cash-gds-discnt.rule-num = cash-dis-rule.rule-num
          cash-gds-discnt.obj-type = parobj-type
          cash-gds-discnt.obj-code = parobj-code
          cash-gds-discnt.discnt-value = v-disc-price-sale
          .
          release cash-gds-discnt.
        end.
      end.
    end.
  end.
  if cash-gds.temp-discnt-rule <> 0
  and how-temp-disc = 'temp-disc-pdf':U
  then do:
    for each cash-dis-rule no-lock where
          (cash-dis-rule.upper-rule-num = cash-gds.temp-discnt-rule
      or cash-dis-rule.rule-num = cash-gds.temp-discnt-rule)
      and cash-dis-rule.is-term = yes
    :
      run mpl-tpl-auto in this-procedure ( input cash-gds.b-code
                                          ,input 'маг':U
                                          ,input i-obj-code
                                          ,input integer(entry(1, cash-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, cash-dis-rule.charkey_one,"-"))
                                          ,input ?
                                          ,output v-disc-price-sale
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num ) no-error.
      if error-status:error
      or v-disc-price-sale = 0
      or v-disc-price-sale = ?
      then do:
      end.
      else do:
        find first  cash-gds-discnt where
                  cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = parobj-type
                and cash-gds-discnt.obj-code = parobj-code No-ERROR.
        if not available cash-gds-discnt then do:
          find first  cash-gds-discnt where
                    cash-gds-discnt.crf = (crgd + 1) No-ERROR.
          if not available cash-gds-discnt then do:
            create cash-gds-discnt.
            assign
            cash-gds-discnt.crf = crgd + 1.
          end.
          crgd = crgd + 1.
          assign
          cash-gds-discnt.b-code = cash-gds.b-code
          cash-gds-discnt.rule-num = cash-dis-rule.rule-num
          cash-gds-discnt.obj-type = parobj-type
          cash-gds-discnt.obj-code = parobj-code
          cash-gds-discnt.discnt-value = v-disc-price-sale.
          release cash-gds-discnt.
        end.
      end.
    end.
  end.
end.
END PROCEDURE.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type55 as character no-undo .
define variable v-value-character55 as date no-undo .
define variable v-value-date55 as date no-undo .
define variable v-value-decimal55 as decimal no-undo .
define variable v-value-integer55 as INTEGER no-undo .
define variable v-value-logical55 AS LOGICAL no-undo .
define variable v-tth55 as handle no-undo .
define variable cdpcknum as integer no-undo init 200.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'cdpcknum':U
    ,output v-value-character55
    ,output v-value-date55
    ,output v-value-decimal55
    ,output cdpcknum
    ,output v-value-logical55
    ,output v-param-type55
    ,INPUT-OUTPUT table-handle v-tth55
    )  .
delete object v-tth55.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'txfixnum'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
IF not error-status:error then
txfixnum = integer(conf-par).
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl-glob':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'rnd-znk':U then rnd-znak = thbjattr_thbj-attr.property-value-integer .
end.
for each thbjattr_thbj-attr :
  delete thbjattr_thbj-attr .
end.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'gds-ref':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'unq-artc':U then unq-artc = thbjattr_thbj-attr.property-value-logical .
end.
assign
rdtaxcd  = integer('3':U)
vattaxcd = integer('1':U)
exctaxcd = integer('4':U).
assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.
FIND ub.shop WHERE ub.shop.obj-code = abs(i-obj-code) NO-LOCK .
find   FIRST ub.clients WHERE
          ub.clients.obj-type = 'маг':U AND
          ub.clients.obj-code = ub.shop.obj-code  no-error .
if available ub.clients then
assign
for-shop-name = ub.clients.obj-name.
else for-shop-name = 'маг':U + string(ub.shop.obj-code).
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'alllstcs':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then alllstcs = v-value-logical.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'noautocs':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then noautocs = v-value-logical.
delete object v-tth.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'mask_s-c':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then mask_s-c = v-value-character.
else mask_s-c = "".
delete object v-tth.
if noautocs
         and g#news
then do:
    message "Пошлите товары на кассы объекта МАГАЗИН "
    if i-obj-code > 0
    then i-obj-code
    else (- i-obj-code)
    view-as alert-box WARNING.
    return.
end.
  if (    ub.shop.cd-bc-alt
        or ub.shop.cd-bc-base
        or ub.shop.cd-loc-alt
        or ub.shop.cd-loc-base
        or ub.shop.cd-parts-all
        or ub.shop.cd-parts-not-blank
        or ub.shop.cd-parts-ser
        or ub.shop.cd-pb-alt
        or ub.shop.cd-pb-base
        or ub.shop.cd-sc-base   ) = no then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Не выбраны типы кодов для пересылки на кассы &1&2", 'маг':U, abs(i-obj-code))
                                            ).
    run finish-send in this-procedure no-error .
    return.
  end.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Пересылка на кассы &1&2 информации о товарах", 'маг':U, abs(i-obj-code))
                                          ).
  if Not g#news and i-obj-code > 0 then callpoint = "R":U.
  if g#news then callpoint = "N":U.
if i-obj-code < 0 then i-obj-code = - i-obj-code.
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run r-b-curr in g#library
  (input  ub.shop.host-code
  ,output v-r-b-curr-magia
  )  .
find first buf_currency no-lock where
           buf_currency.curr-code = v-r-b-curr-magia no-error .
if not available buf_currency or
buf_currency.okv-code = 0 then do:
  message
  "Не задан код ОКВ для валюты с кодом" buf_currency.curr-code
  view-as alert-box error .
  return error .
end.
assign
v-r-b-curr-magia = (if buf_currency.curr-code = 0 then 1 else buf_Currency.okv-code)
v-is-restaurant = ub.shop.is-catering
.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type59 as character no-undo .
define variable v-value-date59 as date no-undo .
define variable v-value-decimal59 as decimal no-undo .
define variable v-value-integer59 as INTEGER no-undo .
define variable v-value-logical59 AS LOGICAL no-undo .
define variable v-tth59 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date59
    ,output v-value-decimal59
    ,output v-value-integer59
    ,output v-value-logical59
    ,output v-param-type59
    ,INPUT-OUTPUT table-handle v-tth59
    ) no-error .
delete object v-tth59 no-error.
IF error-status:error then do:
  assign
  dflt-cd = ''.
end.
for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  i-obj-code
    ,input  'cd-inf-send':U
    ,input  '':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
if error-status:error then return error .
for each thbjattr_thbj-attr where
        thbjattr_thbj-attr.obj-type = 'маг':U
    and thbjattr_thbj-attr.obj-code = i-obj-code
    and thbjattr_thbj-attr.upper-prop-code = 'cd-inf-send':U
on error undo, return error :
  case thbjattr_thbj-attr.prop-code:
    when 'nam-artc':U then do:
      nam-artc = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'cod-pcod':U then do:
      cod-pcod = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'tax-cass':U then do:
      tax-cass = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'nam-2str':U then do:
      nam-2str = thbjattr_thbj-attr.property-value-logical.
    end.
    when 'name-2cd':U then do:
      name-2cd = thbjattr_thbj-attr.property-value-character.
    end.
    when 'amntdisc':U then do:
      amntdisc = thbjattr_thbj-attr.property-value-integer.
    end.
    when 'how-temp-disc':U then do:
      how-temp-disc = thbjattr_thbj-attr.property-value-character.
      if how-temp-disc = 'temp-disc-pdf':U then do:
        run get-thbj-rule in this-procedure ( input 'маг':U
                                             ,input i-obj-code
                                             ,input ub.shop.host-code
                                             ,input 'temp-disc-pdf':U
                                             ,input dflt-cd
                                             ,input "1,2,3"
                                             ,buffer buf_dis-thbj-rule
                                             ) no-error.
        if available buf_dis-thbj-rule then do:
          temp-discnt-rule_pdf = buf_dis-thbj-rule.rule-num.
        end.
      end.
      else do:
        temp-discnt-rule_pdf = 0.
      end.
    end.
    when 'how-pcnt-kat':U then do:
      how-pcnt-kat = thbjattr_thbj-attr.property-value-character.
      if how-pcnt-kat = 'pcnt-kat-pdf':U then do:
        run get-thbj-rule in this-procedure ( input 'маг':U
                                             ,input i-obj-code
                                             ,input ub.shop.host-code
                                             ,input 'pcnt-kat-pdf':U
                                             ,input dflt-cd
                                             ,input "1,2,3"
                                             ,buffer buf_dis-thbj-rule
                                             ) no-error.
        if available buf_dis-thbj-rule then do:
          kat-discnt-rule_pdf = buf_dis-thbj-rule.rule-num.
        end.
      end.
      else do:
        kat-discnt-rule_pdf = 0.
      end.
    end.
  end case.
end.
 run fill-temp-cd in this-procedure ( input g#db-num, input 'маг':U, input i-obj-code, input yes).
 if can-find(first temp-cd where
                  temp-cd.obj-code = i-obj-code
             AND  (temp-cd.pos-type = 'IBM-XML':U
                  or
                  temp-cd.pos-type = 'Autotank':U
                  )
             AND  temp-cd.db-num = g#db-num
             ) then do:
  if index(name-2cd,"GTD":U) = 0 then
  assign
  name-2cd = name-2cd + "-":U + "GTD":U.
end.
run adm/shattri.p (
  input "get":U
  ,input 'маг':U
  ,input ub.shop.obj-code
  ,input  'cd-type-ipc-servispl':U
  ,input  'ipcscpfx':U
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output v-param-type
  ,INPUT-OUTPUT table-handle v-tth
  ) no-error .
IF not error-status:error then
ipcsc-pfx = v-value-integer.
error-status:error = no.
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if not g#news
and not g#auto
and not (valid-handle(parparentproc)
and entry(2, parparentproc:file-name, chr(47)) = "automain.w")
then do:
  define variable v-chk-act-host-code as integer   no-undo .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  abs(i-obj-code)
  ,output v-chk-act-host-code
  )  .
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_cashdesk-goods_add-def':U
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  'маг':U
    ,input  abs(i-obj-code)
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g#log
    )  .
end.
  if NOT g#log then
      return .
end.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE term-prt.
define input parameter c-root like ub.gds-prt.prt-root no-undo.
define input parameter c-node like ub.gds-prt.node-code no-undo.
define buffer b-g-p for ub.gds-prt.
define buffer pr-bc for ub.bar-code .
define buffer b-bc for ub.bar-code .
define buffer p-bar-code for ub.bar-code .
define buffer b-units for ub.units.
define variable pusto as char init "" no-undo.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if action = "U" then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  gds-list.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
      find first buf_producer no-lock where
                 buf_producer.obj-type = gds-list.prod-type
             AND buf_producer.obj-code = gds-list.prod-code no-error .
      assign
      for-producer = (if available buf_producer
                      then buf_producer.obj-name
                      else (gds-list.prod-type + string(gds-list.prod-code)))
      for-producer-int = (if gds-list.prod-type = 'орг':U then 1000000 else 0 ) + gds-list.prod-code
      .
      run get-o-attr in this-procedure (
                                        input gds-list.gds-code
                                        ,input i-obj-code
                                        ,input 'маг':U
                                        ,output std-discnt-rule_
                                        ,output temp-discnt-rule_
                                        ,output temp-discnt-method_
                                        ,output for-wd
                                        ,output for-fp
                                        ,output for-grp-code
                                        ,output for-petrol-purse
                                        ,output need-auth
                                        ,output qnty-discnt-rule_
                                        ,output kat-discnt-rule_
                                        ,output kat-discnt-method_
                                        ,output date-discnt-rule_
                                        ,output abs-discnt-rule_
                                        ,output tot-discnt-rule_
                                        ,output for-wgd
                                        ,output for-taracode
                                      ) no-error .
      if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Ошибка при получении значений атрибутов на объекте товара &1 &2&3"
                                , gds-list.artic
                                , gds-list.prod-type
                                , gds-list.prod-code
                                )
                                  ).
        assign
        v-view-log = yes
        .
            return error .
      end.
      for-price = ?.
      if v-is-restaurant and
      v-is-null-price then do:
        assign
        for-price = 0
        .
      end.
      else do:
        run tax-val in this-procedure
          (gds-list.artic,
                      gds-list.prod-type,
                      gds-list.prod-code,
                      gds-list.unit-base,
                      c-node,
                      ub.units.type,
                      ?,
                      yes ,
                      rdtaxcd ,
                      vattaxcd,
                      exctaxcd,
                      no,
                      ub.shop.host-code,
                      'маг':U,
                      i-obj-code,
                      ?,
                      ?,
                      output prichina,
                      input-output for-price
                      ) no-error  .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при определении налогов на товар &1 &2&3: &4"
                                 , gds-list.artic
                                 , gds-list.prod-type
                                 , gds-list.prod-code
                                 , prichina
                                 )
                                    ).
          assign
          v-view-log = yes
          .
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("!!!Ошибка при определении налогов на товар &1 &2&3: &4"
                                  , gds-list.artic
                                  , gds-list.prod-type
                                  , gds-list.prod-code
                                  , prichina
                                  )
                                      ).
            assign
            v-view-log = yes
            .
            if (g#news or g#esys or g#auto) and return-value <> "error" then do:
              return error prichina.
            end.
            else if not (g#news or g#esys or g#auto) then do:
                error-status:error = no.
                return.
            end.
        end.
        if return-value = "error" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Ошибка при определении налогов на товар &1 &2&3: &4"
                                , gds-list.artic
                                , gds-list.prod-type
                                , gds-list.prod-code
                                , prichina
                                )
                                    ).
          assign
          v-view-log = yes
          .
          return "NEXT".
        end.
      end.
      define VARIABLE v-attr-val    as character no-undo .
      define VARIABLE v-attr-type   as character no-undo .
      run clntattr-value in this-procedure  ( input 'маг':U
                                            , input ub.shop.obj-code
                                            , input "envd"
                                            , output v-attr-val
                                            , output v-attr-type
                                            ) no-error.
      if tax-cass and new-good then do:
          tax-string = "".
          _tt-tax:
          FOR EACH tt-tax No-LOCK:
            if NOT tt-tax.to-cashdesk  then NEXT _tt-tax.
            if v-attr-val = "yes" then do:
                find first ub.tax-rate-attr where ub.tax-rate-attr.attr-code = "envd" no-error.
                if AVAILABLE ub.tax-rate-attr then do:
                    tax-string = tax-string + " " + (if tt-tax.individual
                                              then (if tt-tax.rate-value <> 0
                                                        then string(ub.tax-rate-attr.rate-code + txfixnum)
                                                        else "")
                                              else string(ub.tax-rate-attr.rate-code)).
                end.
                else do:
                    tax-string = tax-string + " " + (if tt-tax.individual
                                              then (if tt-tax.rate-value <> 0
                                                        then string(tt-tax.rate-code + txfixnum)
                                                        else "")
                                              else string(tt-tax.rate-code)).
                end.
            end.
            else do:
            tax-string = tax-string + " " + (if tt-tax.individual
                                              then (if tt-tax.rate-value <> 0
                                                        then string(tt-tax.rate-code + txfixnum)
                                                        else "")
                                              else string(tt-tax.rate-code)).
            end.
            if tt-tax.individual and tt-tax.rate-value <> 0 then do:
              FIND FIRST cash-txr where
                        cash-txr.tax-code = tt-tax.tax-code
                    and cash-txr.host-code = ub.shop.host-code
                    and cash-txr.obj-type = 'маг':U
                    and cash-txr.obj-code = ub.shop.obj-code
                    and cash-txr.status_  = 'тек':U
                    and cash-txr.rc = recid(gds-list) no-error.
              if not available cash-txr then do:
                FIND FIRST cash-txr where cash-txr.crf = (cr-txr + 1) No-ERROR.
                start-paket-txr = no.
                if not avail cash-txr then
                create cash-txr.
                cash-txr.crf = cr-txr + 1.
                cr-txr = cr-txr + 1.
                BUFFER-COPY tt-tax USING tax-code rate-code tax-type rate-value
                                    TO  cash-txr
                                    ASSIGN
                                    cash-txr.rc = recid(gds-list)
                                    cash-txr.host-code = ub.shop.host-code
                                    cash-txr.obj-type = 'маг':U
                                    cash-txr.obj-code = i-obj-code
                                    cash-txr.status_ = 'тек':U
                                    .
                cash-txr.rate-code = cash-txr.rate-code + txfixnum.
              end.
            end.
          END.
      end.
  end.
  if LOOKUP('топ':U, ub.units.type) > 0 and
      LOOKUP('дро':U, ub.units.type) > 0 AND
      gds-list.gds-type = 'т':U
  then do:
        petrol-trk = yes.
  end.
  else petrol-trk = no.
  _b-g-p:
   FOR EACH ub.bar-code NO-LOCK where
            ub.bar-code.gds-code = gds-list.gds-code,
      FIRST b-g-p NO-LOCK WHERE
            b-g-p.node-code = ub.bar-code.node-code
       AND  b-g-p.prt-root = c-root
       AND  b-g-p.is-term = yes
     :
     if ub.bar-code.part-code <> ""
     OR ub.bar-code.in-code <> ""
     OR ub.bar-code.unit-cli <> gds-list.unit-base then NEXT _b-g-p.
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST ub.prt-obj WHERE
        ub.prt-obj.obj-type = 'маг':U AND
        ub.prt-obj.obj-code = ub.shop.obj-code AND
        ub.prt-obj.prod-type = gds-list.prod-type AND
        ub.prt-obj.prod-code = gds-list.prod-code AND
        ub.prt-obj.artic = gds-list.artic AND
        ub.prt-obj.prt-code = b-g-p.node-code NO-LOCK NO-ERROR .
if v-is-restaurant and v-is-null-price then.
else do:
    def var l-in-ov66 as logical no-undo .
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  'маг':U
  ,input  ub.shop.obj-code
  ,input  gds-list.artic
  ,input  gds-list.prod-type
  ,input  gds-list.prod-code
  ,input  'in-ov=request'
  ,output l-in-ov66
  ) no-error .
  if error-status:error then do:
    message
      "Ошибка получения признака товара на объекте" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  if (ub.shop.in-ov and  l-in-ov66 ) then
              NEXT _b-g-p.
if (NOT ub.shop.all-prt )
    AND  gds-list.gds-type = 'т':U
    AND  NOT l-empty-scale then do:
  if not available ub.prt-obj then do:
    if ub.shop.sub-store-on then do:
      if NOT can-find( first ub.gds-dtl where
                          ub.gds-dtl.artic = gds-list.artic AND
                          ub.gds-dtl.prod-type = gds-list.prod-type AND
                          ub.gds-dtl.prod-code = gds-list.prod-code AND
                          ub.gds-dtl.prt-code = b-g-p.node-code AND
                          ub.gds-dtl.obj-type =  ub.shop.sub-store-type AND
                          ub.gds-dtl.obj-code = ub.shop.sub-store-code) then
                  NEXT _b-g-p.
    end.
    else do:
                  NEXT _b-g-p.
    end.
  end.
end.
end.
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if ((LOOKUP('сер':U, ub.units.type) = 0  and not cashparts) OR
      (LOOKUP('сер':U, ub.units.type) > 0 and NOT ub.shop.cd-parts-ser)
     )
    then do:
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = ub.bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer ub.bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = ub.bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( ub.bar-code.b-code )
          AND
          (
          (gds-list.unit-base = ub.bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = ub.bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    ub.bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND ub.bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND ub.bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer ub.bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = ub.bar-code.node-code AND
            b-bc.part-code = pusto AND
            b-bc.in-code = pusto NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
  end.
  if petrol-trk then return.
  if ub.shop.doc-prt AND b-g-p.node-name <> '_Пустая шкала':U then NEXT _b-g-p.
  if ub.shop.cd-parts-all or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          FIRST ub.parts No-LOCK WHERE
                ub.parts.obj-type  = 'маг':U
            AND ub.parts.obj-code  = ub.shop.obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
      IF p-bar-code.unit-cli <> gds-list.unit-base then next.
      IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
      end.
    end.
   end.
   else do:
      FOR EACH ub.parts NO-LOCK WHERE
                ub.parts.obj-type  = 'маг':U AND
                ub.parts.obj-code  = ub.shop.obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR EACH p-bar-code NO-LOCK WHERE
                p-bar-code.gds-code = gds-list.gds-code AND
                p-bar-code.in-code = ub.parts.in-code AND
                p-bar-code.part-code = ub.parts.part-code AND
                p-bar-code.node-code = ub.bar-code.node-code AND
                p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
    return.
  end.
  if ub.shop.cd-parts-not-blank or (cashparts AND LOOKUP('сер':U, units.type) = 0) then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = 'маг':U
            AND ub.parts.obj-code  = ub.shop.obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.part-code = "":U then NEXT.
        if p-bar-code.unit-cli <> gds-list.unit-base then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = 'маг':U AND
                ub.parts.obj-code  = ub.shop.obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then
        FOR   EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = gds-list.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        END.
      END.
    end.
  end.
  if LOOKUP('сер':U, units.type) > 0 AND ub.shop.cd-parts-ser then do:
    if action = "D":U then do:
      for each p-bar-code No-LOCK WHERE
               p-bar-code.gds-code = gds-list.gds-code
           AND p-bar-code.node-code = ub.bar-code.node-code,
          EACH ub.parts No-LOCK WHERE
               ub.parts.obj-type  = 'маг':U
            AND ub.parts.obj-code  = ub.shop.obj-code
            AND ub.parts.artic     = gds-list.artic
            AND ub.parts.prod-type = gds-list.prod-type
            AND ub.parts.prod-code = gds-list.prod-code
            AND ub.parts.in-code   = p-bar-code.in-code
            AND ub.parts.part-code =  p-bar-code.part-code
      break
      by p-bar-code.in-code
      by p-bar-code.part-code:
        if p-bar-code.unit-cli <> gds-list.unit-base then NEXT.
        if ub.parts.part-code <> "" and  ub.shop.cd-parts-not-blank then NEXT.
        IF FIRST-OF(p-bar-code.part-code) then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info80 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
        end.
      end.
    end.
    else do:
      FOR EACH ub.parts NO-LOCK  WHERE
                ub.parts.obj-type  = 'маг':U AND
                ub.parts.obj-code  = ub.shop.obj-code AND
                ub.parts.artic     = gds-list.artic AND
                ub.parts.prod-type = gds-list.prod-type AND
                ub.parts.prod-code = gds-list.prod-code AND
                ub.parts.rsrv-free = yes AND
                ub.parts.status_ = no AND
                ub.parts.part-code <> ""
      break
      by ub.parts.in-code
      by ub.parts.part-code:
        IF FIRST-OF(ub.parts.part-code) then do:
          if ub.parts.part-code <> "" and  ub.shop.cd-parts-not-blank then NEXT.
          FOR EACH p-bar-code NO-LOCK WHERE
                    p-bar-code.gds-code = gds-list.gds-code AND
                    p-bar-code.in-code = ub.parts.in-code AND
                    p-bar-code.part-code = ub.parts.part-code AND
                    p-bar-code.node-code = ub.bar-code.node-code AND
                    p-bar-code.unit-cli = gds-list.unit-base:
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FIND FIRST b-units No-LOCK WHERE
           b-units.unit-name = p-bar-code.unit-cli No-ERROR.
if (ub.shop.cd-bc-base or ub.shop.cd-loc-base) and (NOT petrol-trk
)
then do:
      run asc-gds in this-procedure (
      buffer gds-list,
      buffer p-bar-code,
      buffer ub.gds-prt,
      buffer ub.gds-obj,
      buffer ub.price-list,
      buffer ub.units,
      buffer b-g-p,
      input ?,
      input '',
      input (if avail b-units then b-units.type else ub.units.type),
      input (if avail b-units then b-units.okei else ub.units.okei),
      input ub.sysconf.host-code,
      input 'маг':U,
      input ub.shop.obj-code
      )  no-error .
     if error-status:error then return error.
end.
if ub.shop.cd-pb-base or ub.shop.cd-pb-alt or ub.shop.cd-sc-base OR petrol-trk then do:
  FOR EACH ub.prod-bc NO-LOCK WHERE
           ub.prod-bc.b-code = p-bar-code.b-code
              :
      if  ub.prod-bc.b-str = string( p-bar-code.b-code )
          AND
          (
          (gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-base) OR
          (NOT gds-list.unit-base = p-bar-code.unit-cli AND ub.shop.cd-loc-alt)
          ) AND
          (NOT petrol-trk
          )
          then NEXT.
    if ub.shop.cd-sc-base AND
    (LOOKUP('вес':U, ub.units.type) > 0
    or
    LOOKUP('топ':U, ub.units.type) > 0
    or
    ub.prod-bc.bc-on-type = 'pglc':U
    )
    and
    p-bar-code.unit-cli = gds-list.unit-base then do:
      if not ub.prod-bc.bc-on-type = 'pglc':U then do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  (if LOOKUP('вес':U, ub.units.type) > 0 then 'weight=request':U  else 'petrolium=request':U )
  ,output g#log
  ) no-error .
        if error-status:error or not g#log then NEXT.
      end.
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
      if error-status:error then return error.
      NEXT.
    end.
    if ((ub.shop.cd-pb-base AND p-bar-code.unit-cli = gds-list.unit-base
    AND LOOKUP('вес':U, units.type) = 0
    and ub.prod-bc.bc-on-type <> 'pglc':U
    ) OR
        (ub.shop.cd-pb-alt AND p-bar-code.unit-cli <> gds-list.unit-base)) then do:
      run asc-gds in this-procedure (
        buffer gds-list,
        buffer p-bar-code,
        buffer ub.gds-prt,
        buffer ub.gds-obj,
        buffer ub.price-list,
        buffer ub.units,
        buffer b-g-p,
        input ub.prod-bc.b-str,
        input ub.prod-bc.bc-on-type,
        input (if avail b-units then b-units.type else ub.units.type),
        input (if avail b-units then b-units.okei else ub.units.okei),
        input ub.sysconf.host-code,
        input 'маг':U,
        input ub.shop.obj-code
        ) no-error.
     if error-status:error then return error.
    end.
  END.
end.
if NOT petrol-trk
then do:
  FOR EACH b-bc WHERE
            b-bc.gds-code = gds-list.gds-code AND
            b-bc.node-code = p-bar-code.node-code AND
            b-bc.part-code = ub.parts.part-code AND
            b-bc.in-code = ub.parts.in-code NO-LOCK :
    if  b-bc.unit-cli <> gds-list.unit-base then do:
    FIND FIRST b-units No-LOCK WHERE
               b-units.unit-name = b-bc.unit-cli NO-ERROR.
    if ub.shop.cd-bc-alt or ub.shop.cd-loc-alt then do:
          run asc-gds in this-procedure (
            buffer gds-list,
            buffer b-bc,
            buffer ub.gds-prt,
            buffer ub.gds-obj,
            buffer ub.price-list,
            buffer ub.units,
            buffer b-g-p,
            input ?,
            input '',
            input (if avail b-units then b-units.type else ub.units.type),
            input (if avail b-units then b-units.okei else ub.units.okei),
            input ub.sysconf.host-code,
            input 'маг':U,
            input ub.shop.obj-code
            ) no-error.
     if error-status:error then return error.
     end.
     if ub.shop.cd-pb-alt then do:
       FOR EACH ub.prod-bc NO-LOCK WHERE
                ub.prod-bc.b-code = b-bc.b-code
               :
        if ub.prod-bc.b-str = string( b-bc.b-code ) AND ub.shop.cd-loc-alt then NEXT.
        run asc-gds in this-procedure (
          buffer gds-list,
          buffer b-bc,
          buffer ub.gds-prt,
          buffer ub.gds-obj,
          buffer ub.price-list,
          buffer ub.units,
          buffer b-g-p,
          input ub.prod-bc.b-str,
          input ub.prod-bc.bc-on-type,
          input (if avail b-units then b-units.type else ub.units.type),
          input (if avail b-units then b-units.okei else ub.units.okei),
          input ub.sysconf.host-code,
          input 'маг':U,
          input ub.shop.obj-code
          ) no-error.
        if error-status:error then return error.
      END.
    end.
    end.
  END.
end.
          END.
        END.
      END.
    end.
  end.
  end.
END PROCEDURE .
assign
cr = 0
crgd = 0
cr-txr = 0
cr-ncr-dis-kat = 0
.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Подготовка данных")
                                          ).
assign
  v-count = 0
.
_gds-list:
FOR EACH gds-list by order-num:
    assign
      v-count = v-count + 1
    .
    assign                 new-good = yes                 temp-discnt-rule_ = 0                 temp-discnt-method_ = ''                 petrol-trk = no                 tax-string = ""                 std-discnt-rule_ = 0                 for-wd = 0                 for-fp = no                 cashparts = no                 for-grp-code = 1                 for-petrol-purse = no                 qnty-discnt-rule_ = 0                 kat-discnt-rule_ = 0                 kat-discnt-method_ = ''                 date-discnt-rule_ = 0                 for-producer = "":U                 main-b-code = 0                 for-taracode = '00'                 abs-discnt-rule_ = 0                 for-wgd = 0                 . empty temp-table temp-dis-gds-rule. run cur-time in this-procedure(output v-today, output v-time).
    run get-prt-and-unit in this-procedure (
                                            input gds-list.prt-root
                                            ,input gds-list.unit-base
                                            ,output l-empty-scale
                                            ) .                                            .
    FIND FIRST ub.gds-obj WHERE
               ub.gds-obj.obj-type = 'маг':U AND
               ub.gds-obj.obj-code = i-obj-code AND
               ub.gds-obj.artic = gds-list.artic AND
               ub.gds-obj.prod-type = gds-list.prod-type AND
               ub.gds-obj.prod-code = gds-list.prod-code nO-LOCK NO-ERROR.
    if g#news and not avail gds-obj then NEXT.
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.obj-type = 'маг':U
             AND buf_fbr-gds-obj.obj-code = i-obj-code
             AND buf_fbr-gds-obj.gds-code = gds-list.gds-code no-error .
    if not g#news then do:
      if v-count modulo 10 = 0 then do:
        run show-counter in p-log-handle .
        run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - товар &2 &3&4"
                                           , v-count
                                           , gds-list.artic
                                           , gds-list.prod-type
                                           , gds-list.prod-code)) no-error.
      end.
    end.
run get-gds-obj-fields in this-procedure(                                                  buffer ub.gds-obj                                                 ,input no                                                 ,input gds-list.gds-code                                                 ,input i-obj-code                                                 ,input 'маг':U                                                 ,output for-fact-qnty                                                 ,output cashparts                                                 ,output v-is-null-price                                                 ,output v-is-menu                                                 ,output v-is-semi-finished                                                 ,output v-is-modificator                                                 ,output v-fbr-grp-code                                                 ,output v-fbr-obj-code                                                 ) no-error .       if error-status:error then do:         run write-log-and-file in p-log-handle (                 input 1                                                                              , input log-file-name                                                                  , input 1                                                                              , input substitute("!!!Ошибка при получении характеристик товара &1 &2&3 на объекте"                                      , ub.gds-obj.artic                                                               , ub.gds-obj.prod-type                                                           , ub.gds-obj.prod-code                                                           )                                                                                         ).                                                            assign                                                                                  v-view-log = yes                                                                        .      end.
    RUN term-prt( ub.gds-prt.prt-root, ?) no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Ошибка при обработке товара &1 &2&3"
                              , gds-list.artic
                              , gds-list.prod-type
                              , gds-list.prod-code
                              )
                                ).
      assign
      v-view-log = yes
      .
      if g#news then return error.
    end.
    if return-value = "NEXT":U then NEXT _gds-list.
    ACCUMULATE gds-list.artic (COUNT).
    if cdpcknum = 0 then cdpcknum = 1.
    if NOT alllstcs AND ( (accum count gds-list.artic)  modulo cdpcknum)  = 0 then do:
      run get-stop-state in p-log-handle (output v-stop).
      if v-stop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Процедура пересылки остановлена пользователем"
                                )
                                  ).
        leave _gds-list.
      end.
      else do:
        assign
        error-status:error = no.
        if cr > 0 then
        RUN SENDING no-error.
        if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute("&1 &2", error-status:get-message(1), return-value)                                                                      ).                                                              assign                                                                                                  v-view-log = yes                                                                                        .                                                                                                     end.
        assign
        start-paket = yes
        start-paket-txr = yes
        cr = 0
        crgd = 0
        cr-txr = 0
        cr-ncr-dis-kat = 0
        .
      end.
    end.
  if gds-list.qnty = - 1 and (callpoint = "R":U or callpoint = "N":U) then DELETE gds-list.
END .
assign error-status:error = no.
if cr > 0 and not v-stop then
RUN SENDING no-error.
if error-status:error then do:                                                                            run write-log-and-file in p-log-handle (                                                                      input 1                                                                                               , input log-file-name                                                                                   , input 1                                                                                               , input substitute("&1 &2", error-status:get-message(1), return-value)                                                                      ).                                                              assign                                                                                                  v-view-log = yes                                                                                        .                                                                                                     end.
FOR EACH cash-gds :
    delete cash-gds.
END.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Отправлены товары на кассы &1&2", 'маг':U, i-obj-code)
                                          ).
run finish-send in this-procedure no-error .
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ibm-gdsc :
define input  parameter p-zeros         as logical no-undo .
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter IBM2-short      as character no-undo .
define variable v-delim as character no-undo .
define variable v-format-str-16 as character no-undo .
  do
  on error undo, return error
  :
    if p-zeros then do:
      assign
      v-delim = '0'
      v-format-str-16 =  "9999999999999999"
      .
    end.
    else do:
      assign
      v-delim = chr(32)
      v-format-str-16 =  ">>>>>>>>>>>>>>>9"
      .
    end.
    if cash-gds.b-str = "" then do:
      assign
      b_code = string( cash-gds.b-code, v-format-str-16 ) .
      if  LOOKUP( 'вес':U, cash-gds.unit-type ) = 0
      or cash-gds.unit-base <> cash-gds.unit-cli
      or (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0  and not ub.shop.cd-sc-base)
      then
      do:
        if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          iBM2-short = bar_code.
          IBM-good-code  = string( fill( v-delim, 16 - length( trim( bar_code ) ) ) + trim( bar_code ), "9999999999999999" ) .
        END.
        if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
        end.
      end.
    end.
    else do:
      IBm-good-code =
      ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
        (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
         or
         cash-gds.bc-on-type = 'pglc':U)
      then string( decimal( cash-gds.b-str ), v-format-str-16)
      else string( fill( v-delim, 16 - length( trim( cash-gds.b-str ) ) ) + trim( cash-gds.b-str ), "9999999999999999" ) ).
    end.
  end.
end procedure.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ncr-gdsc :
define output parameter IBM-good-code as character no-undo .
define output parameter IBM-good-code-2 as character no-undo .
define output parameter is-sc as logical no-undo .
define output parameter p-taracode-bc as character no-undo .
define variable v-taracode-bc as character no-undo .
define variable v-type as character no-undo .
define variable v-bc-buf as character no-undo .
define variable iii as integer no-undo .
  do
  on error undo, return error
  :
    if cash-gds.b-str = "" then do:
      assign
      b_code = string(cash-gds.b-code,'>>>>>>>>>>>>9').
      if  LOOKUP( 'вес':U, cash-gds.unit-type ) = 0 or cash-gds.unit-base <> cash-gds.unit-cli then do:
        if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          RUN gen-bc( input cash-gds.b-code, output bar_code ).
          IBM-good-code  = fill( " ", 13 - length( trim( bar_code ) ) ) + trim( bar_code ).
        end.
        if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
            (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
          IBM-good-code-2 = b_code.
        end.
      end.
    end.
    else do:
      if cash-gds.b-str begins "*" then cash-gds.b-str = left-trim(cash-gds.b-str, "*").
      IBm-good-code = ( if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
                          (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
                           or
                           cash-gds.bc-on-type = 'pglc':U)
                        then string( integer( cash-gds.b-str ), ">>>>>>>>>>>>9" )
                        else string( fill( " ", 13 - length( trim( cash-gds.b-str ) ) ) +
                                    trim( cash-gds.b-str ), "9999999999999" ) ).
       if action <> "D":U then do:
        is-sc = no.
        find first request_prod-bc no-lock where
                  request_prod-bc.b-str = cash-gds.b-str no-error .
        if not avail request_prod-bc then do :
          if mask_s-c <> "" then do :
            iii_ :
            do iii = 1 to num-entries(mask_s-c) :
              if length(cash-gds.b-str) = (num-entries(entry(iii, mask_s-c), '*') - 1) then do :
                v-bc-buf = trim(entry(1, entry(iii, mask_s-c), '*') + cash-gds.b-str).
                find first request_prod-bc no-lock where request_prod-bc.b-str = v-bc-buf no-error .
                if available request_prod-bc then leave iii_ .
              end.
            end.
          end.
        end.
        if avail request_prod-bc then do :
          if LOOKUP( 'вес':U, cash-gds.unit-type ) > 0 then do:
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer request_prod-bc
  ,input  'scaleable=request'
  ,output is-sc
  ) no-error .
          end.
          if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
             LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
             then do:
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str86  as character no-undo.
  define variable tmp-num86  as character no-undo.
  define variable i86        as integer   no-undo.
  define variable sum86      as integer   no-undo.
  define variable len-code86 as integer   no-undo.
  define variable varcont86  as logical   initial yes no-undo.
  CASE ncrsc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str86 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str86 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrsc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont86 = yes then do:
    if integer( substring( tmp-str86, 1, length( ncrsc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        IBm-good-code = ncrsc-pfx + substring( tmp-str86, length( ncrsc-pfx ) + 1, length( tmp-str86 ) - length( ncrsc-pfx ) )
        len-code86    = length( IBm-good-code )
      .
      define variable v-sum-char86 as character no-undo .
      assign
        sum86 = 0
      .
      do i86 = 1 to len-code86 by 2
      :
        assign
          v-sum-char86 = substr(IBm-good-code, len-code86 - i86 + 1, 1)
        .
        if v-sum-char86 < "0"
        or v-sum-char86 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum86 = sum86 + integer(v-sum-char86)
        .
      end.
      if varcont86 = yes then do:
        assign
          sum86 = sum86 * 3
        .
        do i86 = 2 to len-code86 by 2
        :
          assign
            v-sum-char86 = substr(IBm-good-code, len-code86 - i86 + 1, 1)
          .
          if v-sum-char86 < "0"
          or v-sum-char86 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum86 = sum86 + integer(v-sum-char86)
          .
        end.
        if varcont86 = yes then do:
           if sum86 mod 10 = 0 then do:
             assign
               IBm-good-code = IBm-good-code + '0'
             .
           end.
           else do:
             assign
               IBm-good-code = IBm-good-code + string(10 - sum86 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
          end.
          if ( cash-gds.unit-cli = cash-gds.unit-base ) AND
             cash-gds.bc-on-type = 'pglc':U
             then do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str87  as character no-undo.
  define variable tmp-num87  as character no-undo.
  define variable i87        as integer   no-undo.
  define variable sum87      as integer   no-undo.
  define variable len-code87 as integer   no-undo.
  define variable varcont87  as logical   initial yes no-undo.
  CASE ncrpg-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str87 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str87 = string( decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrpg-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont87 = yes then do:
    if integer( substring( tmp-str87, 1, length( ncrpg-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        IBm-good-code = ncrpg-pfx + substring( tmp-str87, length( ncrpg-pfx ) + 1, length( tmp-str87 ) - length( ncrpg-pfx ) )
        len-code87    = length( IBm-good-code )
      .
      define variable v-sum-char87 as character no-undo .
      assign
        sum87 = 0
      .
      do i87 = 1 to len-code87 by 2
      :
        assign
          v-sum-char87 = substr(IBm-good-code, len-code87 - i87 + 1, 1)
        .
        if v-sum-char87 < "0"
        or v-sum-char87 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum87 = sum87 + integer(v-sum-char87)
        .
      end.
      if varcont87 = yes then do:
        assign
          sum87 = sum87 * 3
        .
        do i87 = 2 to len-code87 by 2
        :
          assign
            v-sum-char87 = substr(IBm-good-code, len-code87 - i87 + 1, 1)
          .
          if v-sum-char87 < "0"
          or v-sum-char87 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( cash-gds.b-str ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum87 = sum87 + integer(v-sum-char87)
          .
        end.
        if varcont87 = yes then do:
           if sum87 mod 10 = 0 then do:
             assign
               IBm-good-code = IBm-good-code + '0'
             .
           end.
           else do:
             assign
               IBm-good-code = IBm-good-code + string(10 - sum87 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
          end.
        end.
      end.
    end.
    if LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
    and (LOOKUP( 'дро':U, cash-gds.unit-cli-type ) > 0
          or
          LOOKUP( 'вес':U, cash-gds.unit-cli-type ) > 0)
    then do:
        run bc-oattr_value in this-procedure ( input cash-gds.b-code
                                            ,input 'taracode-bc':U
                                            ,input 'маг':U
                                            ,input i-obj-code
                                            ,output v-taracode-bc
                                            ,output v-type) no-error.
        if not error-status:error
        and v-taracode-bc <> '' then do:
          is-sc = yes.
          p-taracode-bc = v-taracode-bc.
        end.
    end.
  end.
end procedure.
procedure finish-send :
  do
  on error undo, return error
  :
    if p-batch then do:
      if v-view-log then
      run set-view-log in p-log-handle(yes).
    end.
    else do:
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if v-view-log
and not g#news
and not g#auto
then do:
  message
  '!!!При отсылке информации на кассы произошли ошибки!!!'  skip
  "!!!Внимательно прочитайте Log-file!!"
  view-as alert-box error .
     define variable v-user-action89   as character no-undo .
  define variable v-printed89       as logical   no-undo .
  run gbl/prnfilen.w
    (input  ('!!!При отсылке информации на кассы произошли ошибки!!!')
    ,input  0
    ,input  (string("./":U) + log-file-name)
    ,input  7
    ,output v-user-action89
    ,output v-printed89
    ) .
end.
if v-view-log = true
and (g#news
or g#auto)
and valid-handle(p-parent-handle) and lookup("cb_set-view-log", p-parent-handle:internal-entries) > 0
then do:
   run cb_set-view-log in p-parent-handle ( input yes).
end.
    end.
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end.
end procedure.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile: putc-gds.i $ $Revision: b8cfd3560a3b, 3573, rls $".
PROCEDURE putc-gds.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type as char no-undo.
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define variable ff  as  int     no-undo.
define variable gg  as  int     no-undo.
DEFINE VARIABLE second-name as character no-undo.
define variable nam-2str-shift as integer no-undo .
define variable v-length as integer no-undo .
DEFINE VARIABLE IBM-good-code-2 as character no-undo .
define variable std-disc-dec as decimal no-undo .
define variable std-disc-reason as integer no-undo .
define variable std-disc-lim as date no-undo .
define variable temp-disc-dec as decimal no-undo .
define variable temp-disc-reason as integer no-undo .
define variable temp-disc-start as date no-undo .
define variable temp-disc-end as date no-undo .
define variable temp-disc-time-start as integer no-undo .
define variable temp-disc-time-end as integer no-undo .
define variable temp-disc-weekday as integer no-undo .
define variable v-version-dec as decimal no-undo .
define variable v-kat-num as integer no-undo .
define variable v-kat-discnt as decimal no-undo .
define variable v-time-rule-num like ub.dis-rule.time-rule-num no-undo .
define variable IBM2-short as character no-undo .
define variable v-what-find as character no-undo .
define variable v-plu as character no-undo .
define variable v-pl-code as integer no-undo .
define variable v-marketer-action as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-b-code-to-find as logical no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-gds-rule-num as integer no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-discreteness as character no-undo .
define variable wd-option as integer no-undo .
define variable wgd-option as integer no-undo .
define variable v-type as logical   no-undo .
define variable  s as char no-undo.
define variable articul as char no-undo.
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule .
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_place for ub.place.
define buffer buf_pl-gds for ub.pl-gds.
define buffer bcash-gds for cash-gds.
define buffer buf_cash-desk-attr for cash-desk-attr.
define variable vcash-desk-stndart as logical no-undo init yes.
assign
v-version-dec = decimal(p-version)
no-error .
if buf_cash-desk.autonomy = integer('2':U)
then do:
   vcash-desk-stndart = no.
end.
  if buf_cash-desk.device-kind = 2 then vcash-desk-stndart = no.
define variable is-petrol   as logical   no-undo.
define variable is-pieces   as logical   no-undo.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cash-gds.artic
  ,  input ?
  ,  input cash-gds.gds-code
  , output is-petrol
  , output is-pieces
  ) NO-ERROR.
if     not vcash-desk-stndart
   and not is-petrol
then
   return.
if cash-gds.std-discnt-rule > 0 then do:
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num =  cash-gds.std-discnt-rule no-error .
  if available cash-dis-rule then do:
    find first cash-dis-time-rule no-lock where
              cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num no-error .
    assign
    std-disc-dec = - cash-dis-rule.discnt-value
    std-disc-reason = 0
    no-error
    .
    if available cash-dis-time-rule then do:
      assign
      std-disc-lim = cash-dis-time-rule.date-to
      .
      if std-disc-lim <> 12/31/1989 and std-disc-lim < today then
      assign
      std-disc-dec = 0
      std-disc-reason = 0
      .
      if cash-dis-time-rule.date-to <> 12/31/1989 and cash-dis-time-rule.date-from > today then
      assign
      std-disc-dec = 0
      std-disc-reason = 0
      .
    end.
  end.
end.
if cash-gds.wd > 1 then do:
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num =  cash-gds.wd-rule no-error .
  if available cash-dis-rule then  do:
    assign
    wd-option = integer(cash-dis-rule.discnt-value).
  end.
end.
if cash-gds.wd = 1 then do:
   wd-option = 1.
end.
if cash-gds.wgd > 0 then do:
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num =  cash-gds.wgd-rule no-error .
  if available cash-dis-rule then  do:
    assign
    wgd-option = integer(cash-dis-rule.discnt-value).
  end.
end.
if cash-gds.temp-discnt-rule <> 0 then do:
  assign
  temp-disc-dec = 0
  .
  find first cash-dis-rule no-lock where
            cash-dis-rule.rule-num = cash-gds.temp-discnt-rule no-error .
  if available cash-dis-rule
           and cash-dis-rule.is-term = yes then do:
    if cash-dis-rule.time-rule-num > 0 then do:
      find first cash-dis-time-rule no-lock where
                  cash-dis-time-rule.time-rule-num = cash-dis-rule.time-rule-num no-error .
      if available cash-dis-time-rule
      and cash-dis-time-rule.templ-rl-root = 50001
          or
          (
           (
            (cash-dis-time-rule.date-from < today)
            or
            (cash-dis-time-rule.date-from = 12/31/1989)
           )
          and
          (
           (cash-dis-time-rule.date-to >= today)
           or
           (cash-dis-time-rule.date-to = 12/31/1989)
          )
         ) then do:
         temp-disc-dec = ?.
      end.
      else do:
        assign
        temp-disc-dec = 0
        .
      end.
    end.
    else do:
      temp-disc-dec = ?.
    end.
    if temp-disc-dec = ? then do:
      case cash-dis-rule.value-type:
        when integer('1':U) then do:
      assign
      temp-disc-dec = - cash-dis-rule.discnt-value
      .
    end.
        when integer('11':U) then do:
          find first cash-gds-discnt where
                    cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = 'маг':U
                and cash-gds-discnt.obj-code = i-obj-code
                no-error.
          if available cash-gds-discnt then do:
            assign
            temp-disc-dec = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) / cash-gds.price-sale * 100
            .
          end.
          else do:
           assign
            temp-disc-dec = 0.
          end.
        end.
        otherwise do:
          temp-disc-dec = 0.
        end.
      end case.
    end.
  end.
end.
CASE pos-type:
  when 'MAGIA-XML':U
  then do:
    if cash-gds.b-str <> "":U then do:
      return.
    end.
    assign
    chk_name = replace(cash-gds.gds-name, chr(34), "":U) + cash-gds.f-name
    .
    if cash-gds.unit-base <> cash-gds.unit-cli then
    assign
    chk_name = string(substr(chk_name, 1, max(33, 50 - 1 - length(trim(string(cash-gds.cli-base-rate), chr(32))))) +
                      "*":U +
                      trim(string( cash-gds.cli-base-rate ), chr(32)), "x(50)":U ).
    else
    chk_name = string(chk_name, "X(50)":U).
    assign
    second-name = replace(cash-gds.gds-namelong, chr(39), "":U)
    second-name =   (chr(34) +
                      TRIM(CAPS(string( replace(second-name, chr(34), "":U), "X(40)":U )))
                      + chr(34) )
    .
    if cash-gds.unit-base <> cash-gds.unit-cli then
    assign
    second-name = string(substr(second-name, 1, max(23, 40 - 1 - length(trim(string(cash-gds.cli-base-rate), chr(32))))  ) +
                      "*":U +
                      trim(string(cash-gds.cli-base-rate), chr(32)), "x(40)":U ).
    else
    second-name = string(second-name, "X(40)":U).
    if tax-cass AND cash-gds.new-good then do:
        for each cash-txr No-LOCK WHERE
                  cash-txr.rc = cash-gds.rc AND
                  cash-txr.host-code = ub.shop.host-code AND
                  cash-txr.obj-type = 'маг':U AND
                  cash-txr.obj-code = ub.shop.obj-code:
          run putc-13(buffer buf_cash-desk
                    , input pos-type
                    , input p-cash-os
                    , input yes
                    ).
        end.
    end.
define variable vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable mi-entry as integer no-undo .
define variable v-out-code like ub.fbr-gds-grp.out-code no-undo .
define variable v-out-code-0 like ub.fbr-gds-grp.out-code no-undo .
define variable v-global-code like ub.fbr-gds-grp.global-code no-undo .
define variable v-xml-vat like ub.tax-rate-value.rate-value no-undo .
define variable v-xml-slt like ub.tax-rate-value.rate-value no-undo .
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_tax-rate for ub.tax-rate.
find first buf_fbr-gds-grp no-lock where
           buf_fbr-gds-grp.obj-type = 'маг':U
       AND buf_fbr-gds-grp.obj-code = i-obj-code
      AND buf_fbr-gds-grp.node-code = cash-gds.fbr-grp-code no-error .
if avail buf_Fbr-gds-grp then do:
  assign
  v-out-code = buf_fbr-gds-grp.out-code
  v-global-code = buf_fbr-gds-grp.global-code
  .
end.
else do:
  assign
  v-global-code = cash-gds.fbr-grp-code-0
  .
end.
if v-global-code  > 0
then do:
  find first buf_fbr-gds-grp no-lock where
            buf_fbr-gds-grp.obj-type = "":U
        AND buf_fbr-gds-grp.obj-code = 0
        AND buf_fbr-gds-grp.node-code = v-global-code no-error .
  if avail buf_Fbr-gds-grp then do:
    assign
    v-out-code-0 = buf_fbr-gds-grp.out-code
    .
  end.
  else do:
    v-out-code-0 = 0.
  end.
end.
if v-out-code = 0
and cash-gds.is-modificator = 0
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Ошибка при получении характеристик товара &1 &2 на объекте: &3"
                            , cash-gds.gds-code
                            , cash-gds.gds-name
                            , "не указана группа меню на кассе"
                            )
                              ).
    assign
    v-view-log = yes
    .
end.
if v-out-code <> 0
or v-is-modificator
then do:
  run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U":U then "ADD" else "DEL":U), OS2-time, cash-gds.b-code)).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemName"       , input trim(second-name, chr(32)), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemAltName"    , input trim(chk_name, chr(34)), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMainPrice"  , input string(0), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemPriceCurrency"  , input string(v-r-b-curr-magia), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemGroup"      , input string( if v-out-code-0 = 0 then 9998 else v-out-code-0), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemDepartId"   , input string( cash-gds.departid ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemLock"       , input (if action = "U":U then string(0) else string(1)), input 1 ).
  run bgelib-tag-open in this-procedure ( input 3, input "ItemStatus"        ,       input "" ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISNullPrice"        , input string( cash-gds.zp ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISMenu"            , input string( cash-gds.is-menu ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISSemiFinished"     , input string( cash-gds.is-semi-finished ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 4, input "ISModificator"     , input string( cash-gds.is-modificator ), input 1 ).
  run bgelib-tag-close in this-procedure ( input 3, input "ItemStatus").
  if tax-cass
  AND action = "U":U then do:
    do mi-entry = 1 to num-entries(cash-gds.tax-string, chr(32)):
      if entry(mi-entry, cash-gds.tax-string, chr(32)) <> "":U then do:
        find first buf_tax-rate no-lock where
                    buf_tax-rate.rate-code = integer(entry(mi-entry, cash-gds.tax-string, chr(32))) no-error .
        if available buf_tax-rate
        and buf_tax-rate.tax-code = vattaxcd then do:
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftaxval in g#library
  (input  recid(buf_tax-rate)
  ,input  buf_tax-rate.tax-code
  ,input  buf_tax-rate.rate-code
  ,input  v-today
  ,input  shop.host-code
  ,input  'маг':U
  ,input  shop.obj-code
  ,output v-xml-vat
  ) no-error .
          if not error-status:error  then do:
            run bgelib-tag-open in this-procedure ( input 3, input "ItemTax", input "" ).
            run bgelib-tag-put in this-procedure ( input 4, input "ITName"  , input "Vat":U, input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "ITValue"  , input string(v-xml-vat), input 1 ).
            run bgelib-tag-close in this-procedure ( input 3, input "ItemTax").
          end.
        end.
      end.
    end.
  end.
  run bgelib-tag-close in this-procedure ( input 2, input "Item").
  if v-out-code > 0 then do:
    run bgelib-tag-open in this-procedure ( input 2, input "ItemPriceList", input substitute("ctrl='&1' tms='&2' code='&3'",  (if action = "U":U then 'ADD' else "DEL":U), OS2-time, cash-gds.b-code)).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLId"  , input string( i-obj-code ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLGroup"      , input string( v-out-code ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLFlagLocalExcess", input string(1 ), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IPLLock"
                                            , input (if action = "D":U then string(1) else string(0)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLFlagLocalPrice", input string(1 ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLPrice"  , input string( cash-gds.price-sale ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "IPLPriceCurrency"  , input string(v-r-b-curr-magia), input 1 ).
    run bgelib-tag-close in this-procedure ( input 2, input "ItemPriceList").
  end.
end.
  end.
  when 'IBM':U
  or when 'IBM-XML':U
  or when 'InfoKiosk':U
  or when 'MARIA':U
  or when 'Autotank':U
  then do:
    assign
    v-length = (if pos-type = 'IBM':U or pos-type = 'IBM-XML':U then 22 else 40 )
    v-length = (if pos-type = 'MARIA':U then 24 else v-length)
    v-length = (if pos-type = 'MARIA':U and lookup('топ':U, cash-gds.unit-cli-type) > 0
                then 5
                else v-length)
    nam-2str-shift = (if nam-2str then v-length else 0)
    .
    chk_name = chk-name_ibm_maria_ibm-xml_infokiosk_ibs-th ( input pos-type
                                         ,input nam-2str
                                         ,input nam-artc
                                         ,input cash-gds.unit-cli-type
                                         ,input cash-gds.unit-base
                                         ,input cash-gds.unit-cli
                                         ,input cash-gds.cli-base-rate
                                         ,input cash-gds.artic
                                         ,input cash-gds.f-name
                                         ,input cash-gds.gds-name
                                         ,input cash-gds.gds-name1
                                         ,output second-name ).
    if pos-type = 'IBM-XML':U
    or pos-type = 'InfoKiosk':U
    or pos-type = 'Autotank':U
    then do:
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if pos-type = 'MARIA':U  then do:
assign
IBM-good-code = "":U
.
run ibm-gdsc in this-procedure (input (pos-type = 'MARIA':U )
                              , output IBM-good-code
                              , output IBM-good-code-2
                              , output IBM2-short
                              ) no-error .
end.
else do:
  assign
  IBM-good-code = cash-gds.ean-lz
  IBM-good-code-2 = cash-gds.ean-rz
  IBM2-short = cash-gds.code-short
  .
end.
if IBM-good-code = "":U then
assign
IBM-good-code= IBM-good-code-2
.
  if IBM-good-code <> "":U
  and ((cash-gds.b-str = "":U and cash-gds.b-code = cash-gds.main-prt-b-code)
       or
        LOOKUP( 'вес':U, cash-gds.unit-cli-type ) > 0
       or
       (LOOKUP( 'дро':U, cash-gds.unit-cli-type ) > 0
        and
        LOOKUP( 'топ':U, cash-gds.unit-cli-type ) > 0
       )
       or not can-find(first bcash-gds where
                             bcash-gds.main-prt-b-code = cash-gds.main-prt-b-code
                         and bcash-gds.obj-type = 'маг':U
                         and bcash-gds.obj-code = abs(i-obj-code)
                         and bcash-gds.crf < cash-gds.crf)
       )
  then do:
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable i-entry as integer no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-egais as integer no-undo .
define variable v-attr-sale-trk as character no-undo .
define variable v-attr-type as character no-undo .
define buffer buf_cash-gds for cash-gds.
define buffer buf_goods-attr for ub.goods-attr.
define buffer buf_gds-obj-attr for ub.gds-obj-attr.
define buffer buf_alc-type  for ub.alc-type.
define buffer buf_alc-type-gds for ub.alc-type-gds.
define buffer buf_bar-code for ub.bar-code .
define buffer buf_bar-code_cl for ub.bar-code .
define buffer buf_ext-classif for ub.ext-classif .
define variable v-IBCType as integer no-undo .
define variable v-mark  as logical no-undo initial no.
define variable v-attr-emrc as character no-undo.
define variable v-cli-base  as character initial "".
define variable v-i-cli     as integer no-undo .
define variable v-i-cli-qnty     as dec no-undo .
define variable v-dop-alt-name as character no-undo.
define variable vGdsTabak as logical no-undo.
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable MarkType as ibs.th.str.marking.Types no-undo.
MarkType = ObjSrv:Env:Marking:Types.
define buffer buf_prod-bc-attr for ub.prod-bc-attr .
define buffer buf_prod-bc for ub.prod-bc .
define buffer     prod-bc for ub.prod-bc .
define buffer buf_goods   for ub.goods .
define variable vaction as character no-undo.
define variable d_action as character no-undo.
vaction = action.
d_action = "".
find first buf_goods no-lock where buf_goods.gds-code = cash-gds.gds-code no-error .
if available (buf_goods) and buf_goods.stts > 0 then do:
 vaction = "D".
 d_action = "D".
end.
if check-ban-sales-via-cd(cash-gds.gds-code)
then do:
   vaction = "D".
end.
if vaction = 'U':U then do:
  run bgelib-tag-open in this-procedure ( input 2, input "Producer", input substitute("ctrl='&1' tms='&2' code='&3'", 'ADD':u, OS2-time, cash-gds.producer-int)).
  run bgelib-tag-put in this-procedure ( input 3, input "ProducerName"  , input trim(cash-gds.producer), input 1 ).
  run bgelib-tag-close in this-procedure ( input 2, input "Producer").
end.
  run bgelib-tag-open in this-procedure ( input 2, input "Item", input substitute("ctrl='&1' tms='&2' code='&3'",
                                        (if
                                        vaction = "U"
                                        then "ADD":U
                                        else "DEL":U), OS2-time, if cash-gds.ean-lz          = "*" and cash-gds.main-prt-b-code = ? then "*" else string(cash-gds.main-prt-b-code))).
if vaction = "U":U then do:
    for first ub.gds-obj-attr no-lock where ub.gds-obj-attr.attr-code = "dop-alt-name-o"
                                                   and ub.gds-obj-attr.gds-code = cash-gds.gds-code
                                                   and ub.gds-obj-attr.obj-code = cash-gds.obj-code
                                                   and ub.gds-obj-attr.obj-type = cash-gds.obj-type :
        v-dop-alt-name = ub.gds-obj-attr.attr-value .
    end.
  run bgelib-tag-put in this-procedure ( input 3, input "ItemName"       , input string(trim(chk_name, chr(32)) + v-dop-alt-name), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemAltName"    , input trim(second-name, chr(34)), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMainPrice"  , input string( cash-gds.price-sale ), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMasterCode"  , input string( cash-gds.gds-code), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemDisc"  , input string( std-disc-dec), input 1 ).
  run bgelib-tag-put in this-procedure ( input 3, input "ItemDiscReason"  , input string( std-disc-reason), input 1 ).
  if pos-type <> 'InfoKiosk':U then do:
    run bgelib-tag-put in this-procedure ( input 3, input "ItemOKEI"         , input string( cash-gds.okei), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemKKTEICode"    , input string( cash-gds.kkt), input 1 ).
  end.
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMeasure"      , input string( cash-gds.unit-cli), input 1 ).
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code
                              and buf_goods-attr.attr-code = "item-matter-mark" no-error.
  run bgelib-tag-put in this-procedure ( input 3, input "ItemMatterMark"  , if available buf_goods-attr then buf_goods-attr.attr-value else "" , input 1 ).
  define buffer bb_goods for ub.goods.
  define variable vVal as character no-undo .
  define variable vType as character no-undo .
   find FIRST buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "image-list" no-error.
        if available buf_goods-attr then do:
     vVal = entry(1,buf_goods-attr.attr-value).
        end.
  if pos-type = 'InfoKiosk':U then do:
    find first bb_goods no-lock where bb_goods.gds-code = cash-gds.gds-code.
    run bgelib-tag-put in this-procedure ( input 3, input "ItemNameLong"  , input string( bb_goods.gds-name), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemDetails"    , input string( bb_goods.Ps ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemPhoto"    , input string( entry(1,vVal)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemGroupBO"  , input string( bb_goods.grp-code ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemSizeColorCode" , input string( cash-gds.node-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemAttributes" , input string( bb_goods.attrib), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemDestination" , input string( bb_goods.destin), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemSert" , input string( bb_goods.sert), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemDeadLine" , input string( bb_goods.deadline), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemUserRules" , input string( bb_goods.user-rule), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemStructure" , input string( bb_goods.struct), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemSort" , input string( bb_goods.sort), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemUnitWeight" , input string( bb_goods.wt-cart), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemUnitVolume" , input string( bb_goods.ms-cart), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemCountry" , input string( cash-gds.alpha1), input 1 ).
  end.
  else do:
find first buf_gds-obj-attr where buf_gds-obj-attr.gds-code = cash-gds.gds-code
                              and buf_gds-obj-attr.obj-code = cash-gds.obj-code
                              and buf_gds-obj-attr.obj-type = cash-gds.obj-type
                              and buf_gds-obj-attr.attr-code = "sum-grp" no-error.
  if available buf_gds-obj-attr then do:
  v-attr-value = buf_gds-obj-attr.attr-value .
  end.
else do:
find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "sum-grp-gl" no-error.
  if available buf_goods-attr then do:
  v-attr-value = buf_goods-attr.attr-value .
  end.
end.
    run gds-attr-value in this-procedure (
                                 input cash-gds.gds-code
                                ,input 'ptrl-as-good':U
                                ,output v-attr-sale-trk
                                ,output v-attr-type) no-error.
define variable v-param-types   as character  no-undo.
define variable v-value-char    as character  no-undo.
define variable v-val-date      as date       no-undo.
define variable v-val-decimal   as decimal    no-undo.
define variable v-val-integer   as integer    no-undo.
define variable v-val-logical   as logical    no-undo.
define variable v-tthd          as handle     no-undo.
if  vVal <> "" and v-val-integer = 0 then do:
        run adm/shattri.p (
        input "get":U
        ,input  '':U
        ,input  0
        ,input  'gds-ref':U
        ,input  'shema-foto':U
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
        delete object v-tthd.
end.
    run bgelib-tag-put in this-procedure ( input 3, input "ItemGroup"      , input string( if v-attr-value = "" then string(cash-gds.grp-code) else v-attr-value ), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "ItemShop"      , input string( i-obj-code ), input 1 ).
    if v-val-integer = 1 and vVal <> "" then do:
        run bgelib-tag-put in this-procedure ( input 3, input "ItemImage"    , input string( entry(1,vVal)), input 1 ).
    end.
    if v-val-integer = 2 and vVal <> "" then do:
        run bgelib-tag-put in this-procedure ( input 3, input "ItemImage"    , input string(string(cash-gds.gds-code) + "/" + entry(1,vVal)), input 1 ).
    end.
    if cash-gds.CalculationMethod > 0 then
    do:
        run bgelib-tag-put in this-procedure ( input 3, input "ItemCalculationMethod" ,
                                              input string(cash-gds.CalculationMethod), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "ItemCalculationMethodRestr" ,
                                              input if cash-gds.CalculationMethodRestr > 0 then string(cash-gds.CalculationMethodRestr) else "", input 1 ).
    end.
    run bgelib-tag-open in this-procedure ( input 3, input "ItemStatus", input "" ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISWeight" ,
                                          input string(if LOOKUP( 'вес':U, cash-gds.unit-cli-type  ) > 0
                                                       or LOOKUP( 'дро':U, cash-gds.unit-cli-type  ) > 0
                                                       then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISFuel" ,
                                          input string(if (LOOKUP('топ':U, cash-gds.unit-cli-type) > 0
                                                        and LOOKUP('дро':U, cash-gds.unit-cli-type) > 0)
                                                        or cash-gds.pp > 0
                                                        or (v-attr-sale-trk = "yes" and LOOKUP('дро':U, cash-gds.unit-cli-type) > 0)
                                                        then 1
                                                        else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISAuthorize" ,
                                          input string(cash-gds.need-auth), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISFreePrice" ,
                                            input string(if cash-gds.fp then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISNullPrice" ,
                                            string(cash-gds.zp), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISNoTotalDisc" ,
                                          input string(if cash-gds.wd > 0 then wd-option else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISService" ,
                                          input string(cash-gds.office), input 1 ).
    find first ub.OperServ no-lock where ub.OperServ.gds-code = cash-gds.gds-code no-error .
    if available (ub.OperServ) then do:
    run bgelib-tag-put in this-procedure ( input 4, input "ISComplex" ,
                                          input string(1), input 1 ).
    end.
    else do:
    run bgelib-tag-put in this-procedure ( input 4, input "ISComplex" ,
                                          input string(0), input 1 ).
    end.
    run bgelib-tag-put in this-procedure ( input 4, input "ISActivate" ,
                                          input (if cash-gds.office-type = 'card-act':U then string(1) else string(0)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISNoDiscount" ,
                                            input string(if cash-gds.wgd > 0 then wgd-option else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISGaz" ,
                                            input string(if cash-gds.is-gas then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "ISFuelAsUnit" ,
                                            input string(if cash-gds.ptrl-as-good then 1 else 0), input 1 ).
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code
         and buf_goods-attr.attr-code = "IS18Plus"
         and buf_goods-attr.attr-value = "1"
         no-lock no-error.
  if available buf_goods-attr then do:
      run bgelib-tag-put in this-procedure ( input 4, input "IS18Plus", input 1, input 1 ).
  end.
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code
         and buf_goods-attr.attr-code = "loyalty-gift"
         and buf_goods-attr.attr-value = "1"
         no-lock no-error.
  if available buf_goods-attr then do:
      run bgelib-tag-put in this-procedure ( input 4, input "ItemLoyaltyGift", input 1, input 1 ).
  end.
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "alcohol-prod" no-lock no-error.
  if available buf_goods-attr then do:
  v-attr-egais = 1.
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "mark" no-lock no-error.
    if available buf_goods-attr and buf_goods-attr.attr-value = "no" then  do:
      run bgelib-tag-put in this-procedure ( input 4, input "ISEgaisNoPDF", input 1, input 1 ).
    end.
    if available buf_goods-attr and buf_goods-attr.attr-value = "yes" then  do:
      run bgelib-tag-put in this-procedure ( input 4, input "ISEgaisPDF"      , input 1, input 1 ).
    end.
    if not available buf_goods-attr then do:
      run bgelib-tag-put in this-procedure ( input 4, input "ISEgaisNoPDF", input 1, input 1 ).
    end.
  end.
  find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code
                              and buf_goods-attr.attr-code = "time-coock"
                              and buf_goods-attr.attr-value = "yes" no-lock no-error.
  if available buf_goods-attr then do:
      run bgelib-tag-put in this-procedure ( input 4, input "ISCookStumped", input 1, input 1 ).
  end.
      run bgelib-tag-close in this-procedure ( input 3, input "ItemStatus").
  end.
  if cash-gds.temp-discnt-rule <> 0 then do:
    find first cash-dis-rule no-lock where
              cash-dis-rule.rule-num = cash-gds.temp-discnt-rule no-error .
    if available cash-dis-rule then do:
      for each buf_cash-dis-rule no-lock where
              (cash-dis-rule.is-term = yes
              and buf_cash-dis-rule.rule-num = cash-gds.temp-discnt-rule)
            or
            buf_cash-dis-rule.upper-rule-num = cash-gds.temp-discnt-rule,
        first cash-dis-time-rule no-lock where
                  cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num:
        if buf_cash-dis-rule.is-term
        and buf_cash-dis-rule.root then do:
        end.
        else do:
          case buf_cash-dis-rule.value-type:
            when integer('1':U) then do:
              assign
              temp-disc-dec = - buf_cash-dis-rule.discnt-value
              .
            end.
            when integer('11':U) then do:
              find first cash-gds-discnt where
                        cash-gds-discnt.b-code = cash-gds.b-code
                    and  cash-gds-discnt.rule-num = buf_cash-dis-rule.rule-num
                    and cash-gds-discnt.obj-type = 'маг':U
                    and cash-gds-discnt.obj-code = i-obj-code
                    no-error.
              if available cash-gds-discnt then do:
                assign
                temp-disc-dec = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) /  cash-gds.price-sale * 100
                .
              end.
              else do:
                assign
                temp-disc-dec = 0.
              end.
            end.
            otherwise do:
              temp-disc-dec = 0.
            end.
          end case.
        end.
        assign
        temp-disc-reason = 0
        temp-disc-weekday = 0
        no-error
        .
        assign
        temp-disc-start = cash-dis-time-rule.date-from
        temp-disc-end   = cash-dis-time-rule.date-to
        temp-disc-time-start = (if cash-dis-time-rule.time-from >= 0 then cash-dis-time-rule.time-from else 0)
        temp-disc-time-end = (if cash-dis-time-rule.time-to >= 0 then cash-dis-time-rule.time-to else 0)
        temp-disc-weekday = (if cash-dis-time-rule.week-day-1 then 1 else 0) +
                            (if cash-dis-time-rule.week-day-2 then 2 else 0) +
                            (if cash-dis-time-rule.week-day-3 then 3 else 0) +
                            (if cash-dis-time-rule.week-day-4 then 4 else 0) +
                            (if cash-dis-time-rule.week-day-5 then 5 else 0) +
                            (if cash-dis-time-rule.week-day-6 then 6 else 0) +
                            (if cash-dis-time-rule.week-day-7 then 7 else 0)
        .
        if temp-disc-end <> 12/31/1989 and temp-disc-end < today then
        assign
        temp-disc-dec = 0
        temp-disc-reason = 0
        temp-disc-weekday = 0
        temp-disc-time-start = 0
        temp-disc-time-end = 0
        temp-disc-start = 12/31/1989
        temp-disc-end = 12/31/9999
        .
        run bgelib-tag-open in this-procedure ( input 3, input "ItemTimeDisc", input "" ).
        run bgelib-tag-put in this-procedure ( input 4, input "ITDEvery"     , input string(temp-disc-weekday), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "ITDValue" , input string(temp-disc-dec), input 1 ).
        if temp-disc-start <> ? then
        run bgelib-tag-put in this-procedure ( input 4, input "ITDBeg" , input Xml-CD-DateTimetoString(temp-disc-start, temp-disc-time-start), input 1 ).
        if temp-disc-end <> ? then
        run bgelib-tag-put in this-procedure ( input 4, input "ITDEnd" , input Xml-CD-DateTimetoString(temp-disc-end, temp-disc-time-end), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "ITDReason" , input string(temp-disc-reason), input 1 ).
        run bgelib-tag-close in this-procedure ( input 3, input "ItemTimeDisc").
      end.
    end.
  end.
  else do:
      run bgelib-tag-open in this-procedure ( input 3, input "ItemTimeDisc", input "" ).
      run bgelib-tag-close in this-procedure ( input 3, input "ItemTimeDisc").
  end.
  if cash-gds.qnty-discnt-rule <> 0 then do:
    for each cash-dis-rule no-lock where
            cash-dis-rule.upper-rule-num = cash-gds.qnty-discnt-rule
      :
      run bgelib-tag-open in this-procedure ( input 3, input "ItemQtyDisc", input "" ).
      run bgelib-tag-put in this-procedure ( input 4, input "IQty", input string(cash-dis-rule.doc-qnty / cash-gds.cli-base-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "IQPercent" , input string(- cash-dis-rule.discnt-value),  input 1 ).
      if v-version-dec >= 1.09 then do:
          run bgelib-tag-put in this-procedure ( input 4, input "IQType"
                                              , input string(if cash-dis-rule.value-type = integer('2':U)
                                                              then 1
                                                              else 0)
                                                , input 1 ).
          run bgelib-tag-put in this-procedure ( input 4, input "IQPayRestriction"
                                               , input string(if cash-dis-rule.templ-rl-root = 73
                                                              or cash-dis-rule.templ-rl-root = 74
                                                              then cash-dis-rule.key#_one
                                                              else 0
                                                              ),  input 1 ).
      end.
      run bgelib-tag-close in this-procedure ( input 3, input "ItemQtyDisc").
    end.
  end.
  else do:
    run bgelib-tag-open in this-procedure ( input 3, input "ItemQtyDisc", input "" ).
    run bgelib-tag-close in this-procedure ( input 3, input "ItemQtyDisc").
  end.
  if cash-gds.kat-discnt-rule <> 0  then do:
    for each cash-dis-rule no-lock where
            cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule   :
      run bgelib-tag-open in this-procedure ( input 3, input "ItemDisCat", input "" ).
      run bgelib-tag-put in this-procedure ( input 4, input "IDCCat" ,  input string(cash-dis-rule.dis-kat), input 1 ).
      if cash-dis-rule.templ-rl-root = 34 then do:
        run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(5), input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "IDCLimit", input string(- cash-dis-rule.discnt-value),  input 1 ).
        run bgelib-tag-put in this-procedure ( input 4, input "IDCFactor", input string(cash-dis-rule.tot-sum),  input 1 ).
      end.
      else do:
        case cash-dis-rule.value-type:
          when integer('2':U) then do:
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(2), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCValue", input string(- cash-dis-rule.discnt-value * cash-gds.cli-base-rate),  input 1 ).
          end.
          when integer('1':U) then do:
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(1), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCPercent", input string(- cash-dis-rule.discnt-value),  input 1 ).
          end.
          when integer('3':U) then do:
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(3), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCPrice", input string(cash-dis-rule.discnt-value),  input 1 ).
          end.
          when integer('12':U) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = cash-gds.b-code
                  and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = 'маг':U
                and cash-gds-discnt.obj-code = i-obj-code
                  no-error.
            if available cash-gds-discnt then do:
              assign
              v-kat-discnt = cash-gds-discnt.discnt-value
              .
            end.
            else do:
              v-kat-discnt = cash-gds.price-sale.
            end.
            run bgelib-tag-put in this-procedure ( input 4, input "IDCMode" , input string(3), input 1 ).
            run bgelib-tag-put in this-procedure ( input 4, input "IDCPrice", input string(v-kat-discnt),  input 1 ).
          end.
        end case.
      end.
      run bgelib-tag-close in this-procedure ( input 3, input "ItemDisCat").
    end.
  end.
  else do:
    run bgelib-tag-open in this-procedure ( input 3, input "ItemDisCat", input "" ).
    run bgelib-tag-close in this-procedure ( input 3, input "ItemDisCat").
  end.
if pos-type <> 'InfoKiosk':U then do:
      if tax-cass
      AND vaction = "U" then do:
        do i-entry = 1 to num-entries(cash-gds.tax-string, chr(32)):
          if entry(i-entry, cash-gds.tax-string, chr(32)) <> "":U then do:
            run bgelib-tag-open in this-procedure ( input 3, input "ItemTax", input "" ).
            run bgelib-tag-put in this-procedure ( input 4, input "ITCode"  , input entry(i-entry, cash-gds.tax-string, chr(32)), input 1 ).
            run bgelib-tag-close in this-procedure ( input 3, input "ItemTax").
          end.
        end.
      end.
    end.
end.
run gds-attr-value in this-procedure (
                                 input cash-gds.gds-code
                                ,input 'emrc-type':U
                                ,output v-attr-emrc
                                ,output v-attr-type) no-error.
run bgelib-tag-put in this-procedure ( input 3, input "Item_EMRC"  , input v-attr-emrc , input 1 ).
vGdsTabak = if vaction = "D" then yes else no.
find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code
              and buf_goods-attr.attr-code  = 'mark-type':U and buf_goods-attr.attr-value <> "not-type" no-error .
    if available (buf_goods-attr)
       and MarkType:GetKeyIntDB(buf_goods-attr.attr-value) > 0
    then do:
      run bgelib-tag-put in this-procedure ( input 3, input "ItemDataMatrixType"  , input string(MarkType:GetKeyIntDB(buf_goods-attr.attr-value)) , input 1 ).
      v-mark = yes .
      if buf_goods-attr.attr-value eq MarkType:tabak:NameProp
      then do:
         vGdsTabak = yes.
      end.
    end.
    else do:
      run bgelib-tag-put in this-procedure ( input 3, input "ItemDataMatrixType"  , input "0", input 1 ).
    end.
    find FIRST buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code and buf_goods-attr.attr-code = "gds-CommodityCode" no-error.
    if available buf_goods-attr then
    do:
      run bgelib-tag-put in this-procedure ( input 4, input "ItemCommodityCode" , input string( buf_goods-attr.attr-value), input 1 ).
    end.
find first buf_goods-attr where buf_goods-attr.gds-code = cash-gds.gds-code
              and buf_goods-attr.attr-code  = 'oper-serv-idd':U no-error.
  if available buf_goods-attr then do:
            run bgelib-tag-put in this-procedure ( input 3, input "ItemOSPayAgent"  , input string(buf_goods-attr.attr-value), input 1 ).
  end.
  else do:
            run bgelib-tag-put in this-procedure ( input 3, input "ItemOSPayAgent"  , input "0", input 1 ).
  end.
run bgelib-tag-close in this-procedure ( input 2, input "Item").
  if v-attr-egais = 1 then do:
        run bgelib-tag-open in this-procedure ( input 2, input "ItemMarkCode", input substitute("ctrl='&1' tms='&2' code='&3'"
                                          ,"ADD":U, OS2-time,cash-gds.b-code)).
        find first buf_alc-type-gds where buf_alc-type-gds.gds-code = cash-gds.gds-code no-lock no-error.
        find first buf_alc-type where buf_alc-type.alc-type-inner-code = buf_alc-type-gds.alc-type-inner-code no-lock no-error.
        if available buf_alc-type then do:
          run bgelib-tag-put in this-procedure ( input 3, input "IMarkCode" , input string(buf_alc-type.alc-type-code), input 1 ).
        end.
        find first bb_goods where bb_goods.gds-code = cash-gds.gds-code no-lock no-error .
        run bgelib-tag-put in this-procedure ( input 3, input "IMarkVolume" , input string(bb_goods.ms-base), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IMarkQnty" , input string(cash-gds.cli-base-rate), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IMarkAlc" ,    input string(bb_goods.proof), input 1 ).
        run bgelib-tag-close in this-procedure ( input 2, input "ItemMarkCode").
    end.
for each buf_cash-gds no-lock where
          buf_cash-gds.main-prt-b-code = cash-gds.main-prt-b-code
      AND buf_cash-gds.obj-type = 'маг':U
      AND buf_cash-gds.obj-code = abs(i-obj-code)
          :
   if LOOKUP( 'вес':U, cash-gds.unit-cli-type ) > 0 and buf_cash-gds.b-str = "" and ub.shop.cd-sc-base  then NEXT.
   if (ub.shop.cd-loc-base = no and buf_cash-gds.is-main-code = yes) then next.
   v-IBCType = 0 .
   if v-mark then do:
       find first buf_prod-bc no-lock where buf_prod-bc.b-code = buf_cash-gds.b-code and buf_prod-bc.bc-on-type = 'GTIN':U
                                        and buf_prod-bc.b-str = buf_cash-gds.b-str no-error .
       if available (buf_prod-bc) then do:
       v-IBCType = 2 .
       end.
       else do:
       find first buf_prod-bc-attr no-lock where buf_prod-bc-attr.b-code = buf_cash-gds.b-code
                              and buf_prod-bc-attr.b-str = buf_cash-gds.b-str
                              and buf_prod-bc-attr.attr-code = 'mark':U
                              no-error .
       if available (buf_prod-bc-attr) and buf_prod-bc-attr.attr-value = "yes" then
         v-IBCType = 1 .
     end.
   end.
  if v-mark and buf_cash-gds.b-str = "" then v-IBCType = 1 .
  find first ub.prod-bc no-lock where ub.prod-bc.b-str = buf_cash-gds.b-str and ub.prod-bc.b-str <> "" and ub.prod-bc.bc-on-type = 'GTIN':U
  no-error .
  define variable vBarCode1 as int no-undo.
  define variable vBarCode2 as int no-undo.
  if available (ub.prod-bc) then do:
    if cash-gds.cli-base-rate eq 1
    then do:
       v-i-cli-qnty = 999999999.
       for each buf_bar-code_cl where buf_bar-code_cl.gds-code      eq cash-gds.gds-code
                                  and buf_bar-code_cl.cli-base-rate ne cash-gds.cli-base-rate
       no-lock:
         v-i-cli-qnty = min (v-i-cli-qnty, buf_bar-code_cl.cli-base-rate).
         if v-i-cli-qnty =  buf_bar-code_cl.cli-base-rate
         then
            vBarCode1 = buf_bar-code_cl.b-code.
       end.
       if vaction = "D" and
          v-i-cli-qnty = 999999999
       then do:
          assign
             v-i-cli-qnty = cash-gds.cli-base-rate
             vBarCode1 = cash-gds.main-prt-b-code
             .
       end.
    end.
    else do:
       v-i-cli-qnty = 999999999.
       for first buf_bar-code_cl where buf_bar-code_cl.gds-code      eq cash-gds.gds-code
                                  and buf_bar-code_cl.cli-base-rate eq 1
       no-lock:
         v-i-cli-qnty = min (v-i-cli-qnty, buf_bar-code_cl.cli-base-rate).
         vBarCode2 = buf_bar-code_cl.b-code.
       end.
       if vaction = "D" and
          v-i-cli-qnty = 999999999
       then do:
          assign
             v-i-cli-qnty = cash-gds.cli-base-rate
             vBarCode2 = cash-gds.main-prt-b-code
             .
       end.
    end.
    if vGdsTabak then do:
       block-cli:
       do v-i-cli = 1 to 2:
         if (      v-i-cli-qnty eq 999999999
               and v-i-cli eq 2
               and cash-gds.cli-base-rate eq 1  )
            or (   v-i-cli-qnty eq 999999999
               and v-i-cli eq 1
               and cash-gds.cli-base-rate ne 1  )
         then
            next block-cli.
         v-cli-base = string (v-i-cli,"99").
         run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
                                             , (if vaction = "U"
                                                then (if buf_cash-gds.bc-on eq yes then "ADD":U else "DEL":U)
                                                else "DEL":U)
                                              , OS2-time
                                             , string(v-cli-base + buf_cash-gds.b-str))).
         run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
                                              , input string( if v-i-cli eq 1 and cash-gds.cli-base-rate ne 1
                                                               then vBarCode2
                                                               else if v-i-cli eq 2 and cash-gds.cli-base-rate eq 1
                                                               then vBarCode1
                                                               else cash-gds.main-prt-b-code )
                                              , input 1 ).
         if vaction = 'U':U then do:
           run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
                                               , input string(cash-gds.producer-int), input 1 ).
           run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
                                               , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).
           if cash-gds.gtd <> "":U then
           run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"
                                               , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).
           find first country no-lock where country.alpha1 = cash-gds.alpha1 no-error.
           if available country then
           run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
                                               , input country.short-name, input 1 ).
           run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
                                                , input string( if v-i-cli eq 1 and cash-gds.cli-base-rate ne 1
                                                    then cash-gds.price-sale / cash-gds.cli-base-rate
                                                    else if v-i-cli eq 2 and cash-gds.cli-base-rate eq 1
                                                         then cash-gds.price-sale * v-i-cli-qnty
                                                         else cash-gds.price-sale )
                                                , input 1 ).
           run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
                                               , input string( v-IBCType ), input 1 ).
           run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"
                                          , input  v-attr-emrc, input 1 ).
           run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"
                                          , input  string(if v-i-cli eq 1 and cash-gds.cli-base-rate ne 1
                                                          then 1
                                                          else if v-i-cli eq 2 and cash-gds.cli-base-rate eq 1
                                                          then v-i-cli-qnty
                                                          else cash-gds.cli-base-rate), input 1 ).
         end.
         run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
       end.
    end.
    else do:
      v-cli-base = if cash-gds.cli-base-rate = 1 then "01" else "02".
      run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"
                                          , (if vaction = "U"
                                             then (if buf_cash-gds.bc-on eq yes then "ADD":U else "DEL":U)
                                             else "DEL":U)
                                           , OS2-time
                                          , string(v-cli-base + buf_cash-gds.b-str))).
      run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"
                                           , input string( cash-gds.main-prt-b-code )
                                           , input 1 ).
      if vaction = 'U':U then do:
        run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"
                                            , input string(cash-gds.producer-int), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"
                                            , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).
        if cash-gds.gtd <> "":U then
        run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"
                                            , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).
        find first country no-lock where country.alpha1 = cash-gds.alpha1 no-error.
        if available country then
        run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"
                                            , input country.short-name, input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"
                                             , input string( cash-gds.price-sale )
                                             , input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IBCType"
                                            , input string( v-IBCType ), input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"
                                          , input  v-attr-emrc, input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"
                                          , input  string(cash-gds.cli-base-rate), input 1 ).
      end.
      run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode") .
    end.
  end.
  else do:
  run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"                                           , (if vaction = "U"                                              then if avail buf_cash-gds                                                   then if buf_cash-gds.bc-on eq yes then "ADD":U  else "DEL":U                                                    else if     cash-gds.bc-on eq yes then "ADD":U  else "DEL":U                                               else "DEL":U)                                             , OS2-time                                                   , (if buf_cash-gds.b-str <> "":U and buf_cash-gds.b-str <> "*"                                                   then ( if  buf_cash-gds.unit-cli = buf_cash-gds.unit-base                                                           AND  (LOOKUP( 'вес':U, buf_cash-gds.unit-type ) > 0                                                           or buf_cash-gds.bc-on-type = 'pglc':U)                                                          then (if buf_cash-gds.b-str begins "*" then left-trim(buf_cash-gds.b-str, "*")                                                                                                 else left-trim(buf_cash-gds.b-str, "0")                                                               )                                                          else (if buf_cash-gds.b-str begins "*" then left-trim(buf_cash-gds.b-str, "*")                                                                                                 else buf_cash-gds.b-str                                                               )                                                        )                                                   else (if buf_cash-gds.b-str eq "*" then buf_cash-gds.b-str else string(buf_cash-gds.b-code))))).                                                  run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"                                                                                    , input cash-gds.main-prt-b-code                                                                                      , input 1 ).                                                           if vaction = 'U':U then do:                                                                                     run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"                                                                                , input string(cash-gds.producer-int), input 1 ).                         run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"                                                                              , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).           if cash-gds.gtd <> "":U then                                                                                   run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"                                                                                     , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).                  find first ub.country no-lock where ub.country.alpha1 = cash-gds.alpha1 no-error.                                    if available ub.country then                                                                                      run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"                                                                                 , input ub.country.short-name, input 1 ).                                    run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                                                                   , input string( cash-gds.price-sale ), input 1 ).                         run bgelib-tag-put in this-procedure ( input 3, input "IBCType"                                                                                   , input string( v-IBCType ), input 1 ).                                   run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                                                                  , input  v-attr-emrc, input 1 ).                                          run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                                                             , input  string(cash-gds.cli-base-rate), input 1 ).                     end.                                                                                                          run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode").
  end.
if buf_cash-gds.b-str = ""
and buf_cash-gds.ean-rz <> buf_cash-gds.ean-lz
AND buf_cash-gds.ean-lz <> "":U
then do:
   run bgelib-tag-open in this-procedure ( input 2, input "ItemBarCode", input substitute("ctrl='&1' tms='&2' code='&3'"                                           , (if vaction = "U"                                              then if avail buf_cash-gds                                                   then if buf_cash-gds.bc-on eq yes then "ADD":U  else "DEL":U                                                    else if     cash-gds.bc-on eq yes then "ADD":U  else "DEL":U                                               else "DEL":U)                                             , OS2-time                                                   , trim(buf_cash-gds.ean-lz, chr(32) ))).                                                  run bgelib-tag-put in this-procedure ( input 3, input "IBCCode"                                                                                    , input cash-gds.main-prt-b-code                                                                                      , input 1 ).                                                           if vaction = 'U':U then do:                                                                                     run bgelib-tag-put in this-procedure ( input 3, input "IBCProducer"                                                                                , input string(cash-gds.producer-int), input 1 ).                         run bgelib-tag-put in this-procedure ( input 3, input "IBCIngredient"                                                                              , input trim(string( cash-gds.ingredient, "X(40)")), input 1 ).           if cash-gds.gtd <> "":U then                                                                                   run bgelib-tag-put in this-procedure ( input 3, input "IBCGTD"                                                                                     , input trim(string( cash-gds.gtd, "X(40)")), input 1 ).                  find first ub.country no-lock where ub.country.alpha1 = cash-gds.alpha1 no-error.                                    if available ub.country then                                                                                      run bgelib-tag-put in this-procedure ( input 3, input "IBCCountry"                                                                                 , input ub.country.short-name, input 1 ).                                    run bgelib-tag-put in this-procedure ( input 3, input "IBCPrice"                                                                                   , input string( cash-gds.price-sale ), input 1 ).                         run bgelib-tag-put in this-procedure ( input 3, input "IBCType"                                                                                   , input string( v-IBCType ), input 1 ).                                   run bgelib-tag-put in this-procedure ( input 3, input "IBC_EMRC"                                                                                  , input  v-attr-emrc, input 1 ).                                          run bgelib-tag-put in this-procedure ( input 3, input "IBCUnitFactor"                                                                             , input  string(cash-gds.cli-base-rate), input 1 ).                     end.                                                                                                          run bgelib-tag-close in this-procedure ( input 2, input "ItemBarCode").
end.
end.
  end.
    end.
    if pos-type = 'IBM':U
    or pos-type = 'MARIA':U
    then do:
define variable vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if pos-type = 'MARIA':U  then do:
assign
IBM-good-code = "":U
.
run ibm-gdsc in this-procedure (input (pos-type = 'MARIA':U )
                              , output IBM-good-code
                              , output IBM-good-code-2
                              , output IBM2-short
                              ) no-error .
end.
else do:
  assign
  IBM-good-code = cash-gds.ean-lz
  IBM-good-code-2 = cash-gds.ean-rz
  IBM2-short = cash-gds.code-short
  .
end.
if IBM-good-code = "":U then
assign
IBM-good-code= IBM-good-code-2
.
do1:
do while IBm-good-code <> "":U:
    if pos-type = 'MARIA':U
    then do:
      v-b-code-to-find = no.
      v-what-find = (if cash-gds.b-str <> "":U
                    then cash-gds.b-str
                    else (if IBM-good-code <> IBM-good-code-2
                              then IBM2-short
                              else "":U)
                    ).
      if v-what-find = "":U then do:
        if pos-type = 'MARIA':U then do:
          v-b-code-to-find = yes.
          find first buf_cd-plu EXCLUSIVE-LOCK where
                    buf_cd-plu.obj-type = 'маг':U
                and buf_cd-plu.obj-code = abs(i-obj-code)
                and buf_cd-plu.pos-type = 'MARIA':U
                and buf_cd-plu.plu-type = '':U
                AND buf_cd-plu.b-code = cash-gds.b-code
                AND buf_cd-plu.b-str  = '':U  NO-ERROR.
        end.
        if not v-b-code-to-find then do:
          if IBM-good-code = IBM-good-code-2 then do:
            leave do1.
          end.
          assign
          IBM-good-code = IBM-good-code-2
          .
          next do1.
        end.
      end.
      if not v-b-code-to-find = yes then do:
        find first buf_cd-plu EXCLUSIVE-LOCK where
                    buf_cd-plu.obj-type = 'маг':U
                and buf_cd-plu.obj-code = abs(i-obj-code)
                and buf_cd-plu.pos-type = 'MARIA':U
                and buf_cd-plu.plu-type = '':U
              AND buf_cd-plu.b-code = cash-gds.b-code
              AND buf_cd-plu.b-str  = v-what-find  NO-ERROR.
      end.
      if not available buf_cd-plu then do:
        if v-del-mrkt-gds = no then do:
          if v-what-find <> "":U then
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Бар-код &1 ДопБК/лок.EAN &2 не включен в число ТОВАРОВ НА КАССЕ &3 &4&5&6" +
                                  "пропускается...."
                                  , cash-gds.b-code
                                  , v-what-find
                                  , pos-type
                                  , 'маг':U
                                  , i-obj-code
                                  , chr(10)
                                  )
                                    ).
        end.
        if IBM-good-code = IBM-good-code-2 then do:
          leave do1.
        end.
        assign
        IBM-good-code = IBM-good-code-2
        .
        next do1.
      end.
      assign
      v-plu = TRIM(string( buf_cd-plu.plu-code), "X(40)":U ).
    end.
    if pos-type = 'MARIA':U then do:
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-plu = substring(v-plu, length(v-plu) - 4 + 1)
.
if v-marketer-action <> 'd'
and available cash-gds
and (cash-gds.grp-code > 99
or cash-gds.price-sale * 100 >  999999999.0)
then do:
    if cash-gds.grp-code > 99 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - № группы на кассе &5 > 99!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , buf_cash-desk.pos-type
                            , 'маг':U
                            , i-obj-code
                            , cash-gds.grp-code
                            , chr(10)
                            )
                              ).
    if cash-gds.price-sale * 100 >  999999999.0 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - цена &5 > 999999999!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , buf_cash-desk.pos-type
                            , 'маг':U
                            , i-obj-code
                            , cash-gds.price-sale
                            , chr(10)
                            )
                              ).
    v-view-log = yes.
end.
else do:
  if (v-marketer-action <> 'd'
  and available cash-gds
  and lookup('топ':U, cash-gds.unit-cli-type) > 0)
  or (v-marketer-action = 'd'
      and available temp-cd-plu
      and temp-cd-plu.obj-type = 'маг':U
      and temp-cd-plu.obj-code = abs(i-obj-code)
      and temp-cd-plu.pos-type = 'MARIA':U
      and temp-cd-plu.plu-type = 'топ':U
      )
  then do:
  define variable v-plu-pet96 as character no-undo .
  define buffer  bufpet_cd-plu96 for ub.cd-plu.
  for each bufpet_cd-plu96  where
          bufpet_cd-plu96.obj-type = 'маг':U
      and bufpet_cd-plu96.obj-code = abs(i-obj-code)
      and bufpet_cd-plu96.pos-type = 'MARIA':U
      and bufpet_cd-plu96.plu-type = 'топ':U
      AND bufpet_cd-plu96.b-code = (if v-marketer-action = 'd'then temp-cd-plu.b-code else buf_cd-plu.b-code)
      AND bufpet_cd-plu96.b-str  = (if v-marketer-action = 'd'then temp-cd-plu.b-str else buf_cd-plu.b-str):
    assign
    v-plu-pet96 = TRIM(string( bufpet_cd-plu96.plu-code, "X(40)":U ))
    v-plu-pet96 = substring(v-plu-pet96, length(v-plu-pet96) - 4 + 1)
    .
    run maria-put in this-procedure (
                                          buffer buf_cash-desk
                                        , input out
                                        , input fname
                                        , input yes
                                        , input 0
                                        , input no
                                        , input 13
                                        , input 1
                                        , input v-plu-pet96
                                        , input (if v-marketer-action = 'u':U
                                                then string(cash-gds.price-sale * 100, "999999999")
                                                else '000000000')
          ).
    v-maria-discnt-value = string(0, '999').
      if action <> 'D':U
      and v-marketer-action <> 'D'
      then do:
      _do:
      do v-ii = 1 to num-entries(drgdsrank):
        assign
        v-gds-rule-num = buffer cash-gds:buffer-field(entry(2, entry(v-ii, drgdsrank), chr(47))):buffer-value.
        if v-gds-rule-num = 0 then next _do.
        find first buf_dis-rule no-lock where
          buf_dis-rule.obj-type = 'маг':U
              AND buf_dis-rule.obj-code = i-obj-code
              AND buf_dis-rule.rule-num = v-gds-rule-num
              AND buf_dis-rule.sts = integer('0':U) no-error .
        if not available buf_dis-rule then do:
          next _do.
        end.
        else do:
          if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
            assign
            v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
            v-dop = substring(v-dop, 1, index(v-dop, chr(44)) - 1)
            v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
            v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
            .
          end.
        end.
        LEAVE _do.
      end.
    end.
    assign
    entry(integer(v-plu), v-record, chr(4)) = v-maria-discnt-value
    no-error
    .
    end.
  end.
  else do:
    if v-marketer-action = 'D' then do:
    run maria-put in this-procedure (
                                    buffer buf_cash-desk
                                  , input out
                                  , input fname
                                  , input 0
                                  , input no
                                  , input yes
                                  , input 6
                                  , input 5000
                                  , input v-plu
                                  , input '000').
    end.
    else do:
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 7
                                    , input 5000
                                    , input v-plu
                                    , input '001').
      define variable maria-good-code96 as character no-undo .
    assign
      maria-good-code96 = left-trim(ibm-good-code, '0')
      maria-good-code96 = fill('0', 14 - length(maria-good-code96)) + maria-good-code96
    .
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 8
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (substring(maria-good-code96, 1, 5) + chr(4) +
                                                    substring(maria-good-code96, 6, 14)
                                                  )
                                              else (fill('0', 5) + chr(4) + fill('0', 9)))
                                        ).
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 9
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = 'u':U
                                            then string(cash-gds.price-sale * 100, "999999999")
                                            else '000000000')
      ).
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 10
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (
                                                  string(cash-gds.gds-stat MODULO 2) +
                                                  string(if cash-gds.fp then 1 else 0) +
                                                  string(cash-gds.office) )
                                              else '000')
                                          ).
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 12
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then  string(cash-gds.b-code, "999999999")
                                              else "000000000")
                                          ).
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 20
                                            else 21)
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 2621
                                            else 2379)
                                    , input v-plu
                                    , input (if v-marketer-action = 'U':U
                                              then string(convert-maria-tax-code(cash-gds.vat-code, 0  , cdtaxlst), "X(8)")
                                              else '00000000':U) + chr(4) + chk_name).
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 6
                                    , input 5000
                                    , input v-plu
                                    , input (if cash-gds.grp-code = 0
                                             then '001'
                                             else string(cash-gds.grp-code, "999"))).
    end.
  end.
end.
    end.
    else do:
      put stream IBMStream unformatted
      '0 "'
      string(  action, "x(1)" )
      '" '
      IBM-good-code
      " "
      second-name      chr(32)
      string(cash-gds.grp-code, ">>9")
      ' "'
      chk_name
      '" '
      string( cash-gds.price-sale , ">>>>>>>>>9.99" )
      chr(32)
      string(std-disc-dec, "->9.99")
      chr(32)
      string( cash-gds.gds-stat, ">>9" )
      chr(32)
      (
      if p-cash-os = "LINUX":U or cd-vat = 0
      then string(cash-gds.vat-pc, ">9.99")
      else "0":U
      )
      chr(32)
      string( temp-disc-dec, "->>9.99")
      " "
      OS2-time
      chr(10) .
      if tax-cass AND action = "U" then do:
          PUT stream IBMstream unformatted
          '14 "'
          string( action, "x(1)" )
          '" '
          IBM-good-code
          ' '
          cash-gds.tax-string
          chr(10).
      end.
define variable vss-include-info97 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (v-version-dec >= 4.4 or amntdisc = 1 )
then do:
  PUT stream IBMstream unformatted
  '7' chr(32)
  (if cash-gds.qnty-discnt-rule = 0
   then '"D"':U
   else  string(action, 'x(1)')  )
   chr(32)
  IBM-good-code
  chr(32)
  .
  if cash-gds.qnty-discnt-rule <> 0 then do:
    for each cash-dis-rule no-lock where
            cash-dis-rule.upper-rule-num = cash-gds.qnty-discnt-rule
    by cash-dis-rule.doc-qnty   :
      PUT stream IBMstream unformatted
      cash-dis-rule.doc-qnty / cash-gds.cli-base-rate chr(32)
      ( - cash-dis-rule.discnt-value ) chr(32)
      .
    end.
  end.
  PUT stream IBMstream unformatted
  SKIP.
end.
  if (v-version-dec < 4.4 and amntdisc = 0)  then do:
    PUT stream IBMstream unformatted
    '7' chr(32)
    (if cash-gds.kat-discnt-rule = 0
    then '"D"':U
    else  string(action, 'x(1)')  )
    chr(32)
    IBM-good-code
    chr(32)
    .
    if cash-gds.kat-discnt-rule <> 0 then do:
      for each cash-dis-rule no-lock where
              cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule
       :
        case cash-dis-rule.value-type:
          when integer('1':U) then do:
            assign
            v-kat-discnt  = - cash-dis-rule.discnt-value
            .
          end.
          when integer('2':U) then do:
            assign
            v-kat-discnt  = - cash-dis-rule.discnt-value
            .
          end.
          when integer('11':U) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = cash-gds.b-code
                 and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = 'маг':U
                and cash-gds-discnt.obj-code = i-obj-code
                 no-error.
            if available cash-gds-discnt then do:
              assign
              v-kat-discnt = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) / cash-gds.price-sale * 100
              .
            end.
            else do:
            assign
              v-kat-discnt = 0
            .
            end.
          end.
          otherwise do:
            v-kat-discnt  = 0.
          end.
        end case.
        PUT stream IBMstream unformatted
        cash-dis-rule.dis-kat chr(32)
        (if cash-dis-rule.value-type = integer('2':U)
        then ( v-kat-discnt  * cash-gds.cli-base-rate)
        else ( v-kat-discnt ) )
        chr(32)
        .
      end.
    end.
    PUT stream IBMstream unformatted
    SKIP.
  end.
if v-version-dec >= 4.4 then do:
  if cash-gds.kat-discnt-rule = 0 then do:
      PUT stream IBMstream unformatted
      '18' chr(32)
      '"D"'chr(32)
      IBM-good-code
      skip.
  end.
  else do:
    for each cash-dis-rule where
            cash-dis-rule.upper-rule-num = cash-gds.kat-discnt-rule :
      if cash-dis-rule.templ-rl-root = 34
      and v-version-dec < 4.48 then do:
        NEXT.
      end.
      case cash-dis-rule.value-type:
        when integer('1':U) then do:
          assign
          v-kat-discnt  = - cash-dis-rule.discnt-value
          .
        end.
        when integer('2':U) then do:
          assign
          v-kat-discnt  = - cash-dis-rule.discnt-value
          .
        end.
        when integer('11':U) then do:
          find first cash-gds-discnt where
                    cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = 'маг':U
                and cash-gds-discnt.obj-code = i-obj-code
                no-error.
          if available cash-gds-discnt then do:
            assign
            v-kat-discnt = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) / cash-gds.price-sale * 100
            .
          end.
          else do:
          assign
            v-kat-discnt = 0
          .
          end.
        end.
        otherwise do:
          v-kat-discnt  = 0.
        end.
      end case.
      PUT stream IBMstream unformatted
      '18' chr(32)
      chr(34)
       string(action, 'x(1)')
      chr(34) chr(32)
      IBM-good-code chr(32)
      cash-dis-rule.dis-kat chr(32)
      string(if cash-dis-rule.templ-rl-root = 34
            then 5
            else (if cash-dis-rule.value-type = integer('2':U)
                  or cash-dis-rule.value-type = integer('13':U)
                  then 2
                  else 1), "9":U)  chr(32)
      string(0 , "9":U) chr(32)
      (if cash-dis-rule.value-type <> integer('2':U)
       and cash-dis-rule.value-type <> integer('13':U)
      then string(v-kat-discnt , "->9.99":U)
      else string(0, "->9.99":U)) chr(32)
      (if cash-dis-rule.value-type = integer('2':U)
       or cash-dis-rule.value-type = integer('13':U)
      then string(v-kat-discnt * cash-gds.cli-base-rate , "->>>>>>>9.99":U)
      else string(0, "->>>>>>>9.99":U)) chr(32)
      string(0 , ">>>>>>>9.99":U) chr(32)
      (if cash-dis-rule.templ-rl-root = 34
      then (string(cash-dis-rule.tot-sum, ">>>>>>>9.99":U) + chr(32))
      else ('0' + chr(32)) )
      OS2-time
      chr(10)
      .
    end.
  end.
end.
  end.
  if IBM-good-code = IBM-good-code-2 then leave do1.
  assign
  IBM-good-code = IBM-good-code-2
  .
end.
    end.
  end.
    when 'IPC-Servis+':U then do:
    if cash-gds.b-str = "":U
    and
    (LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
    and cash-gds.unit-base = cash-gds.unit-cli
    and ub.shop.cd-sc-base
    ) then return.
    if lookup('вес':U, cash-gds.unit-type ) > 0 and ub.shop.cd-sc-base
    then do:
      if cash-gds.unit-cli <> "КГ"
      and cash-gds.unit-cli <> "КГ."
      then return.
    end.
    assign
    articul = string( cash-gds.artic,"x(17)" ) + string( cash-gds.b-code ).
    chk_name = string( trim(replace(if nam-artc
                                    then cash-gds.artic
                                    else cash-gds.gds-name, chr(44), chr(32))), "x(15)" ) +
                                    replace(cash-gds.f-name, chr(44), chr(32)) +
                                   (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + trim(string(cash-gds.cli-base-rate)))).
    assign
    v-discreteness = (if lookup('дро':U, cash-gds.unit-cli-type ) > 0
                      then '",0.001,"':U
                      else '",1,"':U)
    .
    RUN gen-bc in this-procedure ( input cash-gds.b-code, output bar_code ).
        if num-entries(dob-curr, ";") > 1 then do:
        if lookup( string(i-obj-code) , entry(2,dob-curr,";") ) > 0
           then v-type  = true  .
           else v-type  = false .
    end.
    else do:
        v-type  = false .
    end.
if cash-gds.b-str = ""
    or lookup('вес':U, cash-gds.unit-cli-type) > 0
    then do:
        if ub.sysconf.base-code <> 0  or v-type = true  then do:
        s = '"' + articul + '","'  + chk_name + '","' +
            (if cash-gds.unit-cli = "кг."
             or cash-gds.unit-cli = "кг"
             then "КГ"
             else cash-gds.unit-cli) +
              v-discreteness +
              string(cash-gds.producer, "X(20)") + '","' +
              STRING(I-OBJ-CODE)                  + '","' +
              substring(for-shop-name , 1, 20)    + '",'  +
              '0,0,0,"NOSIZE"," "," "," "," "," ",0.00,' +
                trim(string( (if v-type = true
                            then  cash-gds.price-sale / curr_cass
                            else cash-gds.price-sale),">>>>>9.99")) +
              '," ",' + chr(34) + string(cash-gds.vat-pc) + chr(34)  + ',"1",,0,0'.
        end.
        else do:
        s = '"' + articul + '","'  + chk_name + '","' +
            (if cash-gds.unit-cli = "кг."
             or cash-gds.unit-cli = "кг"
             then "КГ"
             else cash-gds.unit-cli) +
              v-discreteness +
              string(cash-gds.producer, "X(20)") + '","'  +
              STRING(I-OBJ-CODE)                  + '","'  +
              substring(for-shop-name , 1, 20)    + '",'   +
              '0,0,0,"NOSIZE"," "," "," "," "," ",' +
              trim( string( cash-gds.price-sale ,">>>>>>>>>>9.99")) +
              ',0.00," ",'  + chr(34) + string(cash-gds.vat-pc) + chr(34)  +  ',"1",,0,0'.
        end.
        put stream plucash unformatted s skip.
        if lookup('вес':U, cash-gds.unit-cli-type) = 0
        or (lookup('вес':U, cash-gds.unit-cli-type) > 0
            and not ub.shop.cd-sc-base
            and cash-gds.unit-cli = cash-gds.unit-base)
        then do:
          if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = '"' + string( cash-gds.b-code ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
              put stream bar unformatted s skip.
          end.
          if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = '"' + trim( bar_code ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
              put stream bar unformatted s skip.
          end.
        end.
      end.
      else do:
          s = '"' + string( cash-gds.b-str ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
          put stream bar unformatted s skip.
      end.
      if lookup('вес':U, cash-gds.unit-cli-type) > 0 then do:
          s = '"' + string(ipcsc-pfx)  + string( cash-gds.b-str ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
          put stream bar unformatted s skip.
      end.
      if cash-gds.bc-on-type = 'pglc':U then do:
          s = '"' + string(ipcpg-pfx)  + string( cash-gds.b-str ) + '","' + articul + '","NOSIZE",' + string(cash-gds.cli-base-rate).
          put stream bar unformatted s skip.
      end.
    end.
  when 'pricecheck-Servis+':U then  do:
    if cash-gds.b-str = "":U  and
    (lookup( 'вес':U, cash-gds.unit-type ) > 0
    and cash-gds.unit-base = cash-gds.unit-cli
    and ub.shop.cd-sc-base
    ) then return.
    if lookup('вес':U, cash-gds.unit-type ) > 0 and ub.shop.cd-sc-base
    then do:
      if cash-gds.unit-cli <> "КГ"
      and cash-gds.unit-cli <> "КГ."
      then return.
    end.
    assign
    articul = string( cash-gds.artic,"x(17)" ) + string( cash-gds.b-code ).
    chk_name = string( trim(replace(if nam-artc
                                    then cash-gds.artic
                                    else cash-gds.gds-name, chr(44), chr(32))), "x(20)" ) +
                                    replace(cash-gds.f-name, chr(44), chr(32)) +
                                   (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + string(cash-gds.cli-base-rate))).
    assign
    v-discreteness = (if lookup('дро':U, cash-gds.unit-cli-type ) > 0
                      then ',0.001,':U
                      else ',1,':U)
    .
    RUN gen-bc( input cash-gds.b-code, output bar_code ).
    if num-entries(dob-curr, ";") > 1 then do:
        if lookup( string(i-obj-code) , entry(2,dob-curr,";") ) > 0
           then v-type  = true  .
           else v-type  = false .
    end.
    else do:
        v-type  = false .
    end.
    if cash-gds.b-str = ""
    or lookup('вес':U, cash-gds.unit-cli-type) > 0
    then do:
        if ub.sysconf.base-code <> 0  or v-type = true  then do:
          s = articul + "," + chk_name + "," +
              (if cash-gds.unit-cli = "кг."
              or cash-gds.unit-cli = "кг"
              then "КГ"
              else cash-gds.unit-cli) +
                v-discreteness +
                string(cash-gds.producer, "X(20)") +  "," +
                STRING(I-OBJ-CODE)                  + "," +
                substring(for-shop-name , 1, 20)    + ","  +
                "0,0,0,NOSIZE,,,,,,0.00," +
                trim(string( (if v-type = true
                              then  cash-gds.price-sale / curr_cass
                              else cash-gds.price-sale),">>>>>9.99")) +
                ',,' + string(cash-gds.vat-pc) + ',1,,0,0'.
        end.
        else do:
          s = articul + ","  + chk_name + "," +
              (if cash-gds.unit-cli = "кг."
              or cash-gds.unit-cli = "кг"
              then "КГ"
              else cash-gds.unit-cli) +
                v-discreteness +
                string(cash-gds.producer, "X(20)") + ","  +
                STRING(I-OBJ-CODE)                  + ","  +
                substring(for-shop-name , 1, 20)    + ","   +
                "0,0,0,NOSIZE,,,,,," +
                trim( string( cash-gds.price-sale ,">>>>>>>>>>9.99")) +
                ',0.00,,' + string(cash-gds.vat-pc) + ',1,,0,0'.
        end.
        put stream plucash unformatted s skip.
        if lookup('вес':U, cash-gds.unit-cli-type) = 0
        or (lookup('вес':U, cash-gds.unit-cli-type) > 0
            and not ub.shop.cd-sc-base
            and cash-gds.unit-cli = cash-gds.unit-base)
        then do:
          if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = string( cash-gds.b-code ) + "," + articul + ',NOSIZE,1' .
              put stream bar unformatted s skip.
          end.
          if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
              (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
              s = trim( bar_code ) + "," + articul + ',NOSIZE,1' .
              put stream bar unformatted s skip.
          end.
        end.
      end.
      else do:
          s = string( cash-gds.b-str ) + "," + articul + ',NOSIZE,1' .
          put stream bar unformatted s skip.
      end.
      if lookup('вес':U, cash-gds.unit-cli-type) > 0 then do:
        define variable v-sclspref-entry as integer no-undo .
        do v-sclspref-entry = 1 to num-entries(varscales-pref):
          s = trim(entry(v-sclspref-entry, varscales-pref))  + string( cash-gds.b-str ) + "," + articul + ',NOSIZE,1' .
          put stream bar unformatted s skip.
      end.
      end.
    end.
    when 'OMRON':U then  do:
        chk_name = string( if nam-artc then cash-gds.artic else cash-gds.gds-name, "x(15)" ) + cash-gds.f-name +
        (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + trim(string(cash-gds.cli-base-rate), chr(32)))).
        if cash-gds.b-str = "" then do:
            assign
            b_code = string(cash-gds.b-code,'>>>>>>>>>>>>>>>9').
            run gen-bc(input cash-gds.b-code, output bar_code) no-error.
            if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                put unformatted b_code '00101' caps(string(chk_name,'x(20)'))
                                      string( ( cash-gds.price-sale * 100 ) ,'99999999').
                put unformatted '0000000000000000000000000000000'
                string(action, "X(1)") '0000000000000'.
                put skip.
            end.
            if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                put unformatted (fill(" " , 16 -  length(bar_code)) + bar_code) '00101'
                                              caps(string(chk_name,'x(20)'))
                                              string(( cash-gds.price-sale * 100 ) ,'99999999') .
                put unformatted '0000000000000000000000000000000'
                string(action, "X(1)") '0000000000000'.
                put skip.
            end.
        end.
        else do:
          put unformatted ( fill(" " , 16 -  length(cash-gds.b-str)) + cash-gds.b-str )
                                    '00101' caps( string( chk_name, 'x(20)' ) )
                                  string( ( cash-gds.price-sale * 100 ) ,'99999999') .
          put unformatted '0000000000000000000000000000000'
          string(action, "X(1)") '0000000000000'.
          put skip.
        end.
      end.
      when 'OMRON-NEW':U then  do:
        assign
        v-versiond = decimal(p-version)
        no-error .
        chk_name = string( if nam-artc then cash-gds.artic else cash-gds.gds-name, "x(15)" ) + cash-gds.f-name +
        (if cash-gds.unit-cli = cash-gds.unit-base then "" else ("*" + trim(string(cash-gds.cli-base-rate), chr(32)))).
        if v-versiond >= 33.0 then do:
          if cash-gds.b-str = "" then do:
              assign
              b_code = string(cash-gds.b-code,'>>>>>>>>>>>>>>>9').
              run gen-bc(input cash-gds.b-code, output bar_code) no-error.
              if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted
                  b_code
                  '00101'
                  caps(string(chk_name,'x(20)'))
                  string( ( cash-gds.price-sale * 100 ) ,'999999999999')
                  .
                  put unformatted
                  '000000000000000000000000000'
                  string(action, "X(1)")
                  fill('0':U , 12)
                  string(v-r-b-curr-magia, "9")
                  fill('0':U , 104)
                  .
                  put skip.
              end.
              if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted
                  (fill(" " , 16 -  length(bar_code)) + bar_code)
                  '00101'
                  caps(string(chk_name,'x(20)'))
                  string(( cash-gds.price-sale * 100 ) ,'999999999999') .
                  put unformatted
                  '000000000000000000000000000'
                  string(action, "X(1)")
                  fill('0':U , 12)
                  string(v-r-b-curr-magia, "9")
                  fill('0':U , 104)
                  .
                  put skip.
              end.
          end.
          else do:
            put unformatted
            ( fill(" " , 16 -  length(cash-gds.b-str)) + cash-gds.b-str )
            '00101'
            caps( string( chk_name, 'x(20)' ) )
            string( ( cash-gds.price-sale * 100 ) ,'999999999999')
            .
            put unformatted
            '000000000000000000000000000'
            string(action, "X(1)")
            fill('0':U , 12)
            string(v-r-b-curr-magia, "9")
            fill('0':U , 104)
            .
            put skip.
          end.
        end.
        else do:
          if cash-gds.b-str = "" then do:
              assign
              b_code = string(cash-gds.b-code,'>>>>>>>>>>>>>>>9').
              run gen-bc(input cash-gds.b-code, output bar_code) no-error.
              if ((ub.shop.cd-loc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-loc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted b_code '00101' caps(string(chk_name,'x(20)'))
                                        string( ( cash-gds.price-sale * 100 ) ,'99999999').
                  put unformatted '0000000000000000000000000000000'
                  string(action, "X(1)") '0000000000000'.
                  put skip.
              end.
              if ((ub.shop.cd-bc-base and cash-gds.unit-base = cash-gds.unit-cli) OR
                  (ub.shop.cd-bc-alt and cash-gds.unit-base <> cash-gds.unit-cli)) then do:
                  put unformatted (fill(" " , 16 -  length(bar_code)) + bar_code) '00101'
                                                caps(string(chk_name,'x(20)'))
                                                string(( cash-gds.price-sale * 100 ) ,'99999999') .
                  put unformatted '0000000000000000000000000000000'
                  string(action, "X(1)") '0000000000000'.
                  put skip.
              end.
          end.
          else do:
            put unformatted ( fill(" " , 16 -  length(cash-gds.b-str)) + cash-gds.b-str )
                                      '00101' caps( string( chk_name, 'x(20)' ) )
                                    string( ( cash-gds.price-sale * 100 ) ,'99999999') .
            put unformatted '0000000000000000000000000000000'
            string(action, "X(1)") '0000000000000'.
            put skip.
          end.
        end.
      end.
    when 'NCR-GM':U
    or when 'NCR-AS@R':U
    then do:
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable ncr-disc-string as character no-undo .
if nam-artc then
chk_name = string( cash-gds.artic ) + " " + cash-gds.f-name.
else  do:
  chk_name = "" .
  DO ff = 1 TO num-entries( cash-gds.gds-name, '"' ) :
    chk_name = chk_name + entry( ff, cash-gds.gds-name, '"' ) .
  END .
  if chk_name = "" then
  chk_name = cash-gds.gds-name .
  chk_name = chk_name + cash-gds.f-name .
end.
if (cash-gds.unit-base <> cash-gds.unit-cli) and
   cash-gds.cli-base-rate <> 1 then
assign
chk_name = string(substr(chk_name, 1, 19 - length(string(cash-gds.cli-base-rate))) + "*" + string( cash-gds.cli-base-rate ), "x(20)" ).
else
chk_name = string(chk_name, "X(20)").
assign
ncrdsc = "0":U
conf-par = "":U
par-type ="":U
.
if std-disc-dec <> 0
or pos-type = 'NCR-AS@R':U
then do:
  do ff = 1 to num-entries(ncrgmdsc, ";":U):
    assign
    par-type = entry(ff, ncrgmdsc , ";":U)
    conf-par = entry(2, par-type, "=":U)
    no-error
    .
    if error-status:error then do:
      LEAVE.
    end.
    if conf-par  = string( - std-disc-dec) then do:
      ncrdsc =  entry(1, par-type, "=").
      LEAVE.
    end.
  end.
end.
assign
IBM-good-code = "":U
is-sc = no
.
run ncr-gdsc in this-procedure (output IBM-good-code
                              , output IBM-good-code-2
                              , output is-sc
                              , output taracode-bc
                              ) no-error .
if IBM-good-code = "":U then
assign
IBM-good-code= IBM-good-code-2
.
assign
conf-par =  ncr-d-rank(ncrdrank, cash-gds.qnty-discnt-rule,  cash-gds.temp-discnt-rule, cash-gds.date-discnt-rule )
.
do2:
do while IBm-good-code <> "":U:
  if action = "D":U then do:
    put stream IBMStream unformatted
    fill(chr(32), 3)
    IBM-good-code
    "-":U
    fill(chr(32), 61)
    chr(10)
    .
  end.
  else do:
    if conf-par = "T":U then do:
      ncr-disc-string = ncr-temp-disc(cash-gds.temp-discnt-rule, cash-gds.price-sale, temp-disc-dec).
    end.
    if conf-par = "D":U then do:
      ncr-disc-string = ncr-date-disc(cash-gds.date-discnt-rule, cash-gds.price-sale).
    end.
    if conf-par = "X":U then do:
       ncr-disc-string = ncr-amnt-disc(cash-gds.qnty-discnt-rule, cash-gds.price-sale).
    end.
    if ncr-disc-string = '':U then
    conf-par = chr(32) .
    put stream IBMStream unformatted
    fill(chr(32), 3)
    IBM-good-code
    string(if cash-gds.grp-code = 0 then 1 else cash-gds.grp-code , "9999":U)
    (if LOOKUP( 'вес':U, cash-gds.unit-cli-type ) > 0
    or (is-sc
    AND LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
    AND LOOKUP('дро':U, cash-gds.unit-cli-type) > 0)
    then "2":U
    else "0":U)
    (if LOOKUP('дро':U, cash-gds.unit-cli-type) > 0
     or LOOKUP('вес':U, cash-gds.unit-cli-type) > 0
     or is-sc
     then "1":U
     else "0":U)
      (if pos-type = 'NCR-GM':U or
      wd-option = 0
      then   ncrdsc
      else '0':U)
     (if cash-gds.vat-code = ? or
     cash-gds.vat-code > 7 then
     "0"
     else string(cash-gds.vat-code, "9"))
    (if (LOOKUP( 'вес':U, cash-gds.unit-cli-type ) > 0
    or (is-sc
    AND LOOKUP( 'вес':U, cash-gds.unit-type ) > 0
    AND LOOKUP('дро':U, cash-gds.unit-cli-type) > 0))
    and  (cash-gds.taracode  <> '':u
         or taracode-bc <> '')
    then (if taracode-bc <> ''
          then taracode-bc
          else cash-gds.taracode)
    else '00'
    )
    (if cash-gds.unit-cli begins "№"
     then substring(cash-gds.unit-cli, 2, 2)
     else substring(cash-gds.unit-cli, 1, 2))  format "X(2)"
    "0010":U
    "0000":U
    chk_name
    fill(chr(32), 4)
    (if pos-type = 'NCR-GM':U and wd-option > 0 then "1":U else chr(32))
    fill(chr(32), 8)
    conf-par
    replace(string( cash-gds.price-sale, "999999.99")
           , ".":U, "":U
           )
    chr(10)
    .
    if pos-type = 'NCR-AS@R':U
    and ncrdsc <> '0':U
    and wd-option > 0
    and cash-gds.std-discnt-rule > 0
    then do:
      run create-ncr-kat-discnt in this-procedure (
                                                  input string(cash-gds.gds-code)
                                                  ,input (fill(chr(32), 2) + chr(32) + IBM-good-code)
                                                  ,input chk_name
                                                  ,input (if action = 'D':U then 0 else cash-gds.std-discnt-rule)
                                                  ,input ?
                                                  ,input 'time-rule-num':U
                                                  ,input ?
                                                  ) no-error .
    end.
    ncr-disc-string = '':U.
    if conf-par = "T":U then do:
      ncr-disc-string = ncr-temp-disc(cash-gds.temp-discnt-rule, cash-gds.price-sale, temp-disc-dec).
      if ncr-disc-string <> '':U then
      PUT stream IBMstream unformatted
      chr(32)
      "T":U
      chr(32)
      IBM-good-code
      chr(32)
      chr(32)
      ncr-disc-string
      chr(10)
      .
    end.
    if conf-par = "D":U then do:
      ncr-disc-string = ncr-date-disc(cash-gds.date-discnt-rule, cash-gds.price-sale).
      if ncr-disc-string <> '':U then
      PUT stream IBMstream unformatted
      chr(32)
      "D":U
      chr(32)
      IBM-good-code
      chr(32)
      chr(32)
      ncr-disc-string
      chr(10)
      .
    end.
    if conf-par = "X":U then do:
      ncr-disc-string = ncr-amnt-disc(cash-gds.qnty-discnt-rule, cash-gds.price-sale).
      if ncr-disc-string <> '':U then
      PUT stream IBMstream unformatted
      chr(32)
      "X":U
      chr(32)
      IBm-good-code
      chr(32)
      chr(32)
      ncr-disc-string
      chr(10)
      .
    end.
  end.
  if pos-type = 'NCR-AS@R':U
  and cash-gds.kat-discnt-rule <> 0
  then do:
    case how-pcnt-kat :
      when 'pcnt-kat-pdf':U then do:
          v-kat-discnt = cash-gds.price-sale.
        end.
      otherwise do:
        v-kat-discnt = ?.
      end.
    end case.
    run create-ncr-kat-discnt in this-procedure (
                                                 input string(cash-gds.gds-code)
                                                ,input (fill(chr(32), 2) + chr(32) + IBM-good-code)
                                                ,input chk_name
                                                ,input (if action = 'D':U then 0 else cash-gds.kat-discnt-rule)
                                                ,input (if how-pcnt-kat = 'pcnt-kat-pdf':U then 89 else 33)
                                                ,input 'time-rule-num':U
                                                ,input v-kat-discnt
                                                ) no-error .
    if error-status:error then do:
    end.
  end.
  if IBM-good-code = IBM-good-code-2 then leave do2.
  assign
  IBM-good-code = IBM-good-code-2
  .
end.
    end.
  END CASE .
END PROCEDURE .
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE   for-cash-cycle:
DEFINE VARIABLE fname-list as character no-undo .
DEFINE VARIABLE out-list as character no-undo .
DEFINE VARIABLE var-file-num as integer no-undo .
DEFINE VARIABLE v-dir-remote as character no-undo .
DEFINE VARIABLE v-dir-remote-tmp as character no-undo .
define variable v-plu as character no-undo .
define variable v-pl-code as integer no-undo .
define variable ss  as character no-undo .
define variable ss0  as character no-undo .
define variable v-temp-kat-file as character no-undo .
define variable v-kat-file as character no-undo .
define variable v-kat-file-save as character no-undo .
define variable v-updated-subject-dis-kat as logical no-undo .
define variable v-next as logical no-undo .
define variable v-cd-subject-code as character no-undo .
define variable v-cd-disc-string as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-gds-rule-num as integer no-undo .
define variable v-maria-rule-num as integer no-undo .
define buffer for-cash-desk for ub.cash-desk.
define buffer buf_cd-plu for ub.cd-plu.
define buffer buf_cash-ncr-dis-kat for cash-ncr-dis-kat.
define buffer buf_cash-gds for cash-gds.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_place for ub.place.
define buffer buf_pl-gds for ub.pl-gds.
FOR EACH for-cash-desk NO-LOCK WHERE
        for-cash-desk.db-num = g#db-num AND
        for-cash-desk.pos-type = ub.cash-desk.pos-type AND
        for-cash-desk.obj-code = i-obj-code AND
 for-cash-desk.cash-on  = yes
    BREAK
    BY for-cash-desk.db-num
    BY for-cash-desk.obj-code
    BY for-cash-desk.pos-type
    BY for-cash-desk.cash-on
    BY for-cash-desk.cash-num
    :
  if LOOKUP(ub.cash-desk.pos-type,
            ('NCR-GM':U + chr(44) +
             'IBM-XML':U + chr(44) +
             'MAGIA-XML':U + chr(44) +
             'NCR-AS@R':U  + chr(44) +
             'Autotank':U
               )) > 0
  and for-cash-desk.autonomy = integer('1':U) then NEXT.
  if LOOKUP(ub.cash-desk.pos-type,
            'MARIA':U
               ) > 0 then do:
    if for-cash-desk.autonomy = integer('2':U) then do:
      assign
      v-cd-list-update = for-cash-desk.addr-path
      v-cd-list-delete = for-cash-desk.addr-path
      .
      NEXT.
    end.
    else do:
      if v-cd-list-update = '':U then nExt.
    end.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num
                        )
                                        ).
define variable vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
      or
    when 'InfoKiosk':U
      or
    when 'Autotank':U
  then do:
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("'Пересылка данных по товарам'" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).
assign
v-obj-list = 'маг':U + string(i-obj-code)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input 'data'
    , input "14.0 " + replace( vss-revision + vss-date, "$", " " )
    , input v-obj-list
    , input (
              (IF for-cash-desk.pos-type = 'IBM-XML':U
                then (if for-cash-desk.autonomy = integer('0':U)
                      then  ("маг" + string(for-cash-desk.obj-code) + "_касса" + string(for-cash-desk.cash-num))
                      else ("КМ"   )
                      )
                else ("маг" + string(for-cash-desk.obj-code) +  "_касса" + string(for-cash-desk.cash-num))
                )
            )
    , input (if for-cash-desk.autonomy = integer('0':U) then no else yes)
).
output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").
  end.
  when 'MAGIA-XML':U then do:
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run xml-cd-filename in this-procedure (
      input out
    , output v-xml-file-name
    , output v-xml-file-name-path
    , output v-log-file-name
    , output v-locked
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( ("'Пересылка данных по товарам'" + " &1")
                            , replace( v-xml-file-name-path, "/", "\" ) + "xm1"
                      )
                                      ).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "................с параметрами: ... магазин: &1", i-obj-code )
                                      ).
assign
v-obj-list = 'маг':U + string(i-obj-code)
.
run xml-cd-write-header in this-procedure (
      input v-xml-file-name
    , input v-xml-file-name-path
    , input 'data'
    , input "14.0 " + replace( vss-revision + vss-date, "$", " " )
    , input v-obj-list
    , input (
              (IF for-cash-desk.pos-type = 'IBM-XML':U
                then (if for-cash-desk.autonomy = integer('0':U)
                      then  ("маг" + string(for-cash-desk.obj-code) + "_касса" + string(for-cash-desk.cash-num))
                      else ("КМ"   )
                      )
                else ("маг" + string(for-cash-desk.obj-code) +  "_касса" + string(for-cash-desk.cash-num))
                )
            )
    , input (if for-cash-desk.autonomy = integer('0':U) then no else yes)
).
output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.
OS2-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9").
  end.
  when 'IBM':U
  then do:
define variable vss-include-info103 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if for-cash-desk.cash-os = ""
AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
then NEXT.
assign
Cash-OS2 = (for-cash-desk.cash-os = "OS/2":U) OR (for-cash-desk.cash-os = "LINUX":U)
            AND for-cash-desk.pos-type <> 'Emulator-NKT-IBM':U
Cash-DOS = NOT CASH-OS2
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 )
v-dir-remote-tmp = v-remote + "tmp":U
v-dir-remote = v-remote + "out":U + string(for-cash-desk.obj-code, "99999") + "-" + string(for-cash-desk.cash-num, "999")
.
if for-cash-desk.remote = 1 then do:
  run gbl/dir-cre.p ( input v-dir-remote-tmp) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote-tmp
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
  end.
  run gbl/dir-cre.p ( input v-dir-remote ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Каталог &1  для отсылки запроса на удаленную кассу &2 не найден&3" +
                            "и/или попытка его создания не удалась"
                            ,v-dir-remote
                            ,for-cash-desk.cash-num
                            ,chr(10)
                            )
                                            ).
      NEXT.
    end.
end.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.dat' ) convert target "ibm866".
OS2-time =       ( if Cash-OS2 then
                                    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
                      else "" )
.
  end.
  when 'OMRON-NEW':U then do:
define variable vss-include-info104 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-versiond = decimal(for-cash-desk.version)
no-error .
if error-status:error
or v-versiond < 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input  substitute("Неверное значение поля <ВЕРСИЯ> &1 для кассы типа &2 № &3 в справочнике касс&4" +
              "Значение версии может быть только десятичным числом > 0"
              ,for-cash-desk.version
              ,for-cash-desk.pos-type
              ,for-cash-desk.cash-num
              ,chr(10)
              ) ).
  return error .
end.
  assign
  out = (for-cash-desk.addr-path + "out\" )
  fname = 'plu'.
  output to value( out + fname + '.dat' ) convert target "ibm866".
  end.
  when 'IPC-Servis+':U then do:
define variable vss-include-info105 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  assign
  out = for-cash-desk.addr-path + "in\"
  fname = string(year(today) modulo 10) + string(month(today),"99") +
                string(day(today),"99") + string(next-value(s-file-num, ub),"999") .
  output stream plucash to value(
  string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu'
                                                    )
  convert target "ibm866".
  output stream bar to value(
  string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar'
                                                    )
  convert target "ibm866".
  end.
  when 'pricecheck-Servis+':U then do:
  output stream plucash to value(
  string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu')  convert target "1251".
  output stream bar to value(
  string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' )  convert target "1251".
  end.
  when 'NCR-GM':U then do:
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
  output stream IBMStream
  to value( out + fname + '.dat' ) convert target "ibm866".
  .
  end.
  when 'NCR-AS@R':U then do:
define variable vss-include-info107 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
  output stream IBMStream
  to value( out + fname + '.dat' ) convert target "ibm866".
  .
  end.
  when 'MARIA':U then do:
define variable vss-include-info108 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
    v-record = fill( chr(63) + chr(4), 7).
  end.
END CASE.
  FOR EACH cash-gds WHERE cash-gds.crf <= cr No-LOCK :
      RUN putc-gds( buffer for-cash-desk, input for-cash-desk.pos-type, input for-cash-desk.version, input for-cash-desk.cash-os ).
  END .
define variable vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case for-cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
      or
     when 'InfoKiosk':U
      or
     when 'Autotank':U
  then do:
define variable vss-include-info110 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'data'
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
    run str/waitpxml.w ( replace( v-xml-file-name-path, "/", "\" ) + "xml",
                (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml"),
                ( if action = 'U'
                  then ('Ждите - ' + 'добавление товаров')
                  else ('Ждите - ' + 'удаление товаров') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num),
                  ' Подождите 15 сек ',
                  'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                  'Подождите: касса обрабатывает запрос',
                  15 ) no-error.
    if error-status:error then do:
      os-delete value( replace( v-xml-file-name-path, "/", "\" ) + "xml" ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'send'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'добавление товаров')
                  else ('Ждите - ' + 'удаление товаров') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  not (g#news or g#esys)
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input "data":U
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
  when 'MAGIA-XML':U then do:
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream stmxmlout close.
run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path
    , input 'data'
).
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
if (
not (g#news or g#auto or g#esys )
or
(
for-cash-desk.pos-type = 'MAGIA-XML':U
or
  (for-cash-desk.pos-type = 'IBM-XML':U
or (for-cash-desk.pos-type = 'Autotank':U
  and
  for-cash-desk.autonomy = integer('2':U))
  )))
then do:
  if for-cash-desk.pos-type = 'MAGIA-XML':U then do:
    run str/waitpxml.w ( replace( v-xml-file-name-path, "/", "\" ) + "xml",
                (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml"),
                ( if action = 'U'
                  then ('Ждите - ' + 'добавление товаров')
                  else ('Ждите - ' + 'удаление товаров') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num),
                  ' Подождите 15 сек ',
                  'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                  'Подождите: касса обрабатывает запрос',
                  15 ) no-error.
    if error-status:error then do:
      os-delete value( replace( v-xml-file-name-path, "/", "\" ) + "xml" ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
  end.
  if (for-cash-desk.pos-type = 'IBM-XML':U
  and for-cash-desk.autonomy = integer('0':U))
  or (for-cash-desk.pos-type = 'Autotank':U
  and for-cash-desk.autonomy = integer('2':U))
  then do:
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
      ,input 'send'
      ,input log-file-name
      ,input (entry(1, for-cash-desk.addr-path, chr(4)) + '://' + entry(2, for-cash-desk.addr-path, chr(4)))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + 'добавление товаров')
                  else ('Ждите - ' + 'удаление товаров') ) +
                  substitute("Маг&1 касса&2", for-cash-desk.obj-code, for-cash-desk.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                                , chr(10)
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  if
  not (g#news or g#esys)
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input 'маг':U
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = 'IBM-XML':U
                          and for-cash-desk.autonomy = integer('0':U))
                          or (for-cash-desk.pos-type = 'Autotank':U
                          and for-cash-desk.autonomy = integer('2':U))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
                  ,input "data":U
                  ,input v-xml-file-name
                  ,input-output v-view-log
                  ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                ,for-cash-desk.obj-code
                                ,for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
    end.
  end.
end.
if g#news
or g#auto
or g#esys
and for-cash-desk.pos-type = 'MAGIA-XML':U
then do:
end.
  end.
  when 'IBM':U
  then do:
define variable vss-include-info112 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
output stream IBMStream
to value( (if for-cash-desk.remote = 1
            then (v-dir-remote-tmp + chr(47) + "fl":U)
            else out) + fname + '.ad0' ) convert target "ibm866".
put stream IBMStream ' ' skip(1).
 put stream IBMStream unformatted '  ' for-cash-desk.addr-path ' plu' skip.
output stream IBMStream close.
OS-RENAME
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote-tmp + chr(47) + "fl":U)
        else out) + fname + '.ad0')
VALUE((if for-cash-desk.remote = 1
        then (v-dir-remote + chr(47) + "fl":U)
        else out) + fname + '.adr').
os-er = OS-ERROR.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1, файл адреса &2"
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.dat')
                        , ((if for-cash-desk.remote = 1
                            then (v-dir-remote + chr(47) + "fl":U)
                            else out) + fname + '.adr')
                        )
                                       ).
if os-er <> 0 then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                            for-cash-desk.cash-num
                        )
                                        ).
      assign
      v-view-log = yes
      .
      return "error":U.
end.
if for-cash-desk.remote = 1 then do:
  OS-RENAME
  VALUE(v-dir-remote-tmp + chr(47) + "fl":U + fname + '.dat')
  VALUE(v-dir-remote  + chr(47) + "fl":U + fname + '.dat').
  os-er = OS-ERROR.
  if os-er <> 0 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибки в работе локальной сети или нарушение прав доступа при обмене информацией с кассой &1",
                                for-cash-desk.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Данные выгружены в файл &1",
                            (v-dir-remote  + chr(47) + "fl":U + fname + '.dat')
                        )
                                        ).
end.
else do:
  if not g#news
  and not g#auto
  and not g#esys
  then do:
  end.
end.
  end.
  when 'OMRON-NEW':U then do:
define variable vss-include-info113 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  output close.
  output to value(out  + 'plu.adr') convert target "ibm866".
  if v-versiond >= 33.0 then do:
    put unformatted "OK" skip.
  end.
  output close.
  run str/waitp.w (out + 'plu.adr',
                        (if action = 'U'
                          then 'Ждите - идет добавление товаров на кассу '
                          else 'Ждите - идет удаление товаров с кассы ' ) + out,
                        ' Подождите 15 сек ',
                        'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                        15 ) no-error.
  if error-status:error then return error.
  end.
  when 'IPC-Servis+':U then do:
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  output stream plucash close.
  output stream bar close.
  assign
  out-list = out-list + (if out-list = '':U then '':U else chr(44)) + out
  fname-list = fname-list + (if fname-list = '':U then '':U else chr(44)) + fname
  .
  os-copy
  value( string( session:temp-directory + "plu" + string( var-report-num ) ) + '.plu' )
  value( out + fname + '.upc').
  os-copy
  value( string( session:temp-directory + "bar" + string( var-report-num ) ) + '.bar' )
  value( out + fname + '.ubr').
  if not g#news
  and not g#auto
  then do:
    if LAST-OF(for-cash-desk.cash-on) then do:
      DO var-file-num = 1 to num-entries(fname-list):
        run str/waitp.w (
                      INPUT (entry(var-file-num, out-list) + entry(var-file-num, fname-list) +  '.ubr')
                    ,INPUT ('Передача товаров на кассу ' + entry(var-file-num, out-list))
                    ,INPUT (' Подождите 15 сек ')
                    ,INPUT ('Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!')
                    ,INPUT 15
                      ) no-error .
        if error-status:error then do:
            return error.
        end.
      END.
    END .
  end.
  end.
  when 'pricecheck-Servis+':U
  then do:
      output stream plucash close.
      output stream bar close.
      run str/clo-prcp.p
      ( input out ,
        input var-report-num ) no-error .
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input return-value ).
  end.
  end.
  when 'NCR-GM':U
  then do:
define variable vss-include-info115 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  output stream IBMStream close.
  end.
  when 'NCR-AS@R':U
  then do:
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output stream IBMStream close.
define variable v-kat-file-number as integer no-undo .
if action = 'D':U then do:
  do v-kat-file-number = 0 to 99:
    if v-kat-file-number > 0
    and v-kat-file-number < 10 then NEXt.
    assign                                                                                 v-temp-kat-file = out + fname + '.' + string(v-kat-file-number)                     v-kat-file = (if v-kat-file-number  > 0                                                          then (entry(1, out2, chr(4))   + 'group_':U  + string(v-kat-file-number))                   else (entry(2, out2, chr(4))   + 's_plurbt':U ))                               + '.dat':u                                                                v-updated-subject-dis-kat = no.                                                        if ncr-save-param <> 'no' then do:                                                       v-kat-file-save = if ncr-save-param = 'NCR'                                                              then replace(v-kat-file, '.dat', '.sav')                                                else search((if v-kat-file-number  > 0                                                          then ('group_':U  + string(v-kat-file-number))                                      else 's_plurbt':U) + '.sav':U).                         end.
    V-NEXT = NO.
    if search(v-kat-file) = ? then do:
      next .
    end.
    if ncr-save-param <> 'no':U then do:                                                     if search(v-kat-file-save) <> ? then do:                                               input stream bar from value(v-kat-file-save) convert source "ibm866" .                 repeat:                                                                                  import stream bar unformatted ss.                                                      find first cash-ncr-save-param where                                                            cash-ncr-save-param.dis-kat = v-kat-file-number                                 AND cash-ncr-save-param.cd-line = substring(ss, 1, 24) no-error.                  if not available cash-ncr-save-param then do:                                            create cash-ncr-save-param.                                                            assign                                                                                 cash-ncr-save-param.dis-kat = v-kat-file-number                                     cash-ncr-save-param.cd-line = substring(ss, 1, 24)                                     cash-ncr-save-param.cd-other = substring(ss, 25)                                       .                                                                                    end.                                                                                 end.                                                                                   input stream bar close .                                                               end.                                                                                   else do:                                                                               end.                                                                                 end.
    input stream bar from value(v-kat-file) convert source "ibm866" .
    output stream plucash to value(v-temp-kat-file) convert target "ibm866".
    _rr:
    repeat:
      import stream bar unformatted ss.
      if not ss begins fill(chr(32), 2 )
      or can-find(first cash-ncr-save-param no-lock where
                       cash-ncr-save-param.dis-kat = v-kat-file-number
                   AND cash-ncr-save-param.cd-line = substring(ss, 1, 24))
      then do:
        put stream plucash unformatted
        ss skip.
        next _rr.
      end.
      find first buf_cash-ncr-dis-kat no-lock where
                buf_cash-ncr-dis-kat.dis-kat = - 1
            AND buf_cash-ncr-dis-kat.cd-subject-code = substring(ss, 1, 16) no-error.
      if not available buf_cash-ncr-dis-kat then do:
        put stream plucash unformatted
        ss skip.
      end.
      ELSE DO:
        ASSIGN
        V-NEXT = YES.
      END.
    end.
    input stream bar close.
    output stream plucash close.
    find first temp-dis-kat-file no-lock where                                                       temp-dis-kat-file.dis-kat = v-kat-file-number no-error.                   if not available temp-dis-kat-file then                                                create temp-dis-kat-file.                                                              assign                                                                                 temp-dis-kat-file.dis-kat   = v-kat-file-number                                     .                                                                                      assign                                                                                 temp-dis-kat-file.temp-file = v-temp-kat-file                                          temp-dis-kat-file.send-file = v-kat-file                                               temp-dis-kat-file.to-send   = yes.
  end.
end.
if action = 'U':U then do:
  FOR EACH cash-ncr-dis-kat No-LOCK WHERE
          cash-ncr-dis-kat.crf <= cr-ncr-dis-kat
  break
  by cash-ncr-dis-kat.dis-kat
  :
      if first-of(cash-ncr-dis-kat.dis-kat) then do:
      assign                                                                                 v-temp-kat-file = out + fname + '.' + string(cash-ncr-dis-kat.dis-kat)                     v-kat-file = (if cash-ncr-dis-kat.dis-kat  > 0                                                          then (entry(1, out2, chr(4))   + 'group_':U  + string(cash-ncr-dis-kat.dis-kat))                   else (entry(2, out2, chr(4))   + 's_plurbt':U ))                               + '.dat':u                                                                v-updated-subject-dis-kat = no.                                                        if ncr-save-param <> 'no' then do:                                                       v-kat-file-save = if ncr-save-param = 'NCR'                                                              then replace(v-kat-file, '.dat', '.sav')                                                else search((if cash-ncr-dis-kat.dis-kat  > 0                                                          then ('group_':U  + string(cash-ncr-dis-kat.dis-kat))                                      else 's_plurbt':U) + '.sav':U).                         end.
      if search(v-kat-file) = ? then do:
        output stream bar to value(v-kat-file) convert target "ibm866" .
        put stream bar unformatted skip.
        output stream bar close.
      end.
      else do:
       if ncr-save-param <> 'no':U then do:                                                     if search(v-kat-file-save) <> ? then do:                                               input stream bar from value(v-kat-file-save) convert source "ibm866" .                 repeat:                                                                                  import stream bar unformatted ss.                                                      find first cash-ncr-save-param where                                                            cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat                                 AND cash-ncr-save-param.cd-line = substring(ss, 1, 24) no-error.                  if not available cash-ncr-save-param then do:                                            create cash-ncr-save-param.                                                            assign                                                                                 cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat                                     cash-ncr-save-param.cd-line = substring(ss, 1, 24)                                     cash-ncr-save-param.cd-other = substring(ss, 25)                                       .                                                                                    end.                                                                                 end.                                                                                   input stream bar close .                                                               end.                                                                                   else do:                                                                               end.                                                                                 end.
      end.
      input stream bar from value(v-kat-file) convert source "ibm866" .
      assign
      ss0 = ''
      ss = '':U
      v-cd-subject-code = '':U
      v-cd-disc-string  = '':U
      v-next = no
      v-updated-subject-dis-kat = no
      .
      output stream plucash to value(v-temp-kat-file) convert target "ibm866".
      _rr2:
      repeat:
        import stream bar unformatted ss.
        assign
        v-next = no
        v-updated-subject-dis-kat = no
        v-cd-subject-code = substring(ss, 1, 16)
        v-cd-disc-string =  substring(ss, 17, 7)
        .
        if not ss begins fill(chr(32), 2 )
        then do:
          if substring(ss0, 1, 3) = substring(v-cd-subject-code, 1, 3) then do:
            put stream plucash unformatted
            ss skip.
            ss0 = v-cd-subject-code.
            NEXT _rr2.
          end.
          v-next = yes.
        end.
        _for_rr2:
        for each  buf_cash-ncr-dis-kat no-lock where
                  buf_cash-ncr-dis-kat.dis-kat = cash-ncr-dis-kat.dis-kat
              AND buf_cash-ncr-dis-kat.cd-subject-code <= v-cd-subject-code
              AND buf_cash-ncr-dis-kat.cd-subject-code > ss0
              and crf <= cr-ncr-dis-kat
        by buf_cash-ncr-dis-kat.cd-subject-code
        by buf_cash-ncr-dis-kat.cd-disc-string
        :
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1, 7) > v-cd-disc-string then do:
            leave  _for_rr2.
          end.
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code then do:
            v-updated-subject-dis-kat = yes.
          end.
          find first  cash-ncr-save-param no-lock where
                          cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat
                      AND cash-ncr-save-param.cd-line = (buf_cash-ncr-dis-kat.cd-subject-code +
                                                        substring(buf_cash-ncr-dis-kat.cd-disc-string , 1, 2)) no-error.
          if available cash-ncr-save-param then do:
            put stream plucash unformatted
            cash-ncr-save-param.cd-line
            cash-ncr-save-param.cd-other
            skip.
            v-cd-disc-string = substring(cash-ncr-save-param.cd-line , 17, 7)
                               .
            NEXT _for_rr2.
          end.
          put stream plucash unformatted                                                                               buf_cash-ncr-dis-kat.cd-subject-code                                                                         buf_cash-ncr-dis-kat.cd-disc-string                                                                          buf_cash-ncr-dis-kat.cd-subject-name                                                                         buf_cash-ncr-dis-kat.cd-other                                                                                skip.
        end.
        if v-next then do:
          ss0 = v-cd-subject-code.
          put stream plucash unformatted
          ss skip.
          NEXT _rr2.
        end.
        if not v-updated-subject-dis-kat then do:
          find first buf_cash-ncr-dis-kat no-lock where
                    buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
                AND buf_cash-ncr-dis-kat.crf <= cr-ncr-dis-kat no-error.
          if not available buf_cash-ncr-dis-kat then do:
            put stream plucash unformatted
            ss skip.
          end.
        end.
        ss0 = v-cd-subject-code.
      end.
      input stream bar close.
      _for_rr3:
      for each  buf_cash-ncr-dis-kat no-lock where
                buf_cash-ncr-dis-kat.dis-kat = cash-ncr-dis-kat.dis-kat
            AND buf_cash-ncr-dis-kat.cd-subject-code >= v-cd-subject-code
            and crf <= cr-ncr-dis-kat
      by buf_cash-ncr-dis-kat.cd-subject-code
      by buf_cash-ncr-dis-kat.cd-disc-string
      :
          if buf_cash-ncr-dis-kat.cd-subject-code = v-cd-subject-code
          and SUBSTRING(buf_cash-ncr-dis-kat.cd-disc-string, 1, 7) <= v-cd-disc-string then do:
            next  _for_rr3.
          end.
        find first  cash-ncr-save-param no-lock where
                      cash-ncr-save-param.dis-kat = cash-ncr-dis-kat.dis-kat
                  AND cash-ncr-save-param.cd-line = (buf_cash-ncr-dis-kat.cd-subject-code +
                                                    substring(buf_cash-ncr-dis-kat.cd-disc-string , 1, 2)) no-error.
        if available cash-ncr-save-param then do:
          put stream plucash unformatted
          cash-ncr-save-param.cd-line
          cash-ncr-save-param.cd-other
          skip.
          v-cd-disc-string = substring(cash-ncr-save-param.cd-line , 17, 7) .
        end.
        else do:
          put stream plucash unformatted                                                                               buf_cash-ncr-dis-kat.cd-subject-code                                                                         buf_cash-ncr-dis-kat.cd-disc-string                                                                          buf_cash-ncr-dis-kat.cd-subject-name                                                                         buf_cash-ncr-dis-kat.cd-other                                                                                skip.
        end.
      end.
      output stream plucash close.
      find first temp-dis-kat-file no-lock where                                                       temp-dis-kat-file.dis-kat = cash-ncr-dis-kat.dis-kat no-error.                   if not available temp-dis-kat-file then                                                create temp-dis-kat-file.                                                              assign                                                                                 temp-dis-kat-file.dis-kat   = cash-ncr-dis-kat.dis-kat                                     .                                                                                      assign                                                                                 temp-dis-kat-file.temp-file = v-temp-kat-file                                          temp-dis-kat-file.send-file = v-kat-file                                               temp-dis-kat-file.to-send   = yes.
    end.
  END.
end.
  end.
  when 'MARIA':U then do:
define variable vss-include-info117 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found117 as logical no-undo .
define variable v-is-script117 as logical no-undo.
define variable v-fields-shift117 as integer no-undo .
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 6 )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 13 )
   then do:
     v-fields-shift117 = - 1.
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift117
                                  , input yes
                                  , input 24
                                  , input 1
                                  , input string(1)
                                  , input v-record
                                    ).
   end.
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found117 = yes.
end.
if v-found117 = yes then do:
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script117 = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found117 = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script117 = yes.
  end.
  delete temp-tekka-tsk.
end.
output stream IBMStream
close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файлы &1(..),&2файл задания &3"
                        , (out + fname)
                        , chr(10)
                        , (out + fname + '.tsk')
                        )
                                       ).
run str/runtekka.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input out
                    ,input out
                    ,input fname
                    ,input v-remote
                    ,input v-is-script117
                    ) no-error .
if error-status:error then do:
  for each temp-tekka-tsk:
    os-delete value( temp-tekka-tsk.filename) .
    delete temp-tekka-tsk.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Прерван обмен информацией с кассой &1,&2&3&2на кассе осталась устаревшая информация"
                           ,for-cash-desk.cash-num
                           ,chr(10)
                           ,return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
    for each temp-cd-plu:
      delete temp-cd-plu.
    end.
  return "error":U.
end.
else do:
  for each temp-cd-plu,
      first buf_cd-plu where
                  buf_cd-plu.obj-type = temp-cd-plu.obj-type
              and buf_cd-plu.obj-code = temp-cd-plu.obj-code
              and buf_cd-plu.pos-type = temp-cd-plu.pos-type
              and buf_cd-plu.plu-type = temp-cd-plu.plu-type
              and buf_cd-plu.plu-code = temp-cd-plu.plu-code:
    if temp-cd-plu.to-del = yes
    and v-del-mrkt-gds
    then do:
      if lookup(string(for-cash-desk.cash-num), buf_cd-plu.charkey_one) > 0 then do:
        entry(lookup(string(for-cash-desk.cash-num), buf_cd-plu.charkey_one)  ,  buf_cd-plu.charkey_one) = '':U.
        assign
        buf_cd-plu.charkey_one = replace(buf_cd-plu.charkey_one, chr(44) + chr(44), chr(44))
        buf_cd-plu.to-del = (buf_cd-plu.charkey_one <> '':U)
        .
      end.
      if buf_cd-plu.charkey_one = '':U then do:
        delete buf_cd-plu.
        NEXT.
      end.
    end.
    if temp-cd-plu.charkey_two = "":U
    then
    assign
    buf_cd-plu.charkey_two = "":U
    buf_cd-plu.to-send = no
    .
    delete temp-cd-plu.
  end.
end.
end.
run cd-mrkt_update-marketer in this-procedure (
                                                input for-cash-desk.db-num
                                                ,input for-cash-desk.obj-code
                                                ,input for-cash-desk.pos-type
                                                ,input for-cash-desk.cash-num
                                                ,input no
                                              )  .
    if
v-del-mrkt-gds
    then do:
define variable vss-include-info118 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info119 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
    v-record = fill( chr(63) + chr(4), 7).
define variable v-marketer-action as character no-undo .
FOR EACH buf_cd-plu where
        buf_cd-plu.obj-type = 'маг':U
    and buf_cd-plu.obj-code = abs(i-obj-code)
    and buf_cd-plu.pos-type = 'MARIA':U
    and buf_cd-plu.plu-type = '':U :
  if buf_cd-plu.to-del then do:
    create temp-cd-plu.
    buffer-copy buf_cd-plu
    to temp-cd-plu
    .
    assign
    v-plu = TRIM(string( buf_cd-plu.plu-code, "X(40)":U ))
    v-marketer-action = 'd'
    .
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-plu = substring(v-plu, length(v-plu) - 4 + 1)
.
if v-marketer-action <> 'd'
and available cash-gds
and (cash-gds.grp-code > 99
or cash-gds.price-sale * 100 >  999999999.0)
then do:
    if cash-gds.grp-code > 99 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - № группы на кассе &5 > 99!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , for-cash-desk.pos-type
                            , 'маг':U
                            , i-obj-code
                            , cash-gds.grp-code
                            , chr(10)
                            )
                              ).
    if cash-gds.price-sale * 100 >  999999999.0 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - цена &5 > 999999999!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , for-cash-desk.pos-type
                            , 'маг':U
                            , i-obj-code
                            , cash-gds.price-sale
                            , chr(10)
                            )
                              ).
    v-view-log = yes.
end.
else do:
  if (v-marketer-action <> 'd'
  and available cash-gds
  and lookup('топ':U, cash-gds.unit-cli-type) > 0)
  or (v-marketer-action = 'd'
      and available temp-cd-plu
      and temp-cd-plu.obj-type = 'маг':U
      and temp-cd-plu.obj-code = abs(i-obj-code)
      and temp-cd-plu.pos-type = 'MARIA':U
      and temp-cd-plu.plu-type = 'топ':U
      )
  then do:
  define variable v-plu-pet120 as character no-undo .
  define buffer  bufpet_cd-plu120 for ub.cd-plu.
  for each bufpet_cd-plu120  where
          bufpet_cd-plu120.obj-type = 'маг':U
      and bufpet_cd-plu120.obj-code = abs(i-obj-code)
      and bufpet_cd-plu120.pos-type = 'MARIA':U
      and bufpet_cd-plu120.plu-type = 'топ':U
      AND bufpet_cd-plu120.b-code = (if v-marketer-action = 'd'then temp-cd-plu.b-code else buf_cd-plu.b-code)
      AND bufpet_cd-plu120.b-str  = (if v-marketer-action = 'd'then temp-cd-plu.b-str else buf_cd-plu.b-str):
    assign
    v-plu-pet120 = TRIM(string( bufpet_cd-plu120.plu-code, "X(40)":U ))
    v-plu-pet120 = substring(v-plu-pet120, length(v-plu-pet120) - 4 + 1)
    .
    run maria-put in this-procedure (
                                          buffer for-cash-desk
                                        , input out
                                        , input fname
                                        , input yes
                                        , input 0
                                        , input no
                                        , input 13
                                        , input 1
                                        , input v-plu-pet120
                                        , input (if v-marketer-action = 'u':U
                                                then string(cash-gds.price-sale * 100, "999999999")
                                                else '000000000')
          ).
    v-maria-discnt-value = string(0, '999').
      if action <> 'D':U
      and v-marketer-action <> 'D'
      then do:
      _do:
      do v-ii = 1 to num-entries(drgdsrank):
        assign
        v-gds-rule-num = buffer cash-gds:buffer-field(entry(2, entry(v-ii, drgdsrank), chr(47))):buffer-value.
        if v-gds-rule-num = 0 then next _do.
        find first buf_dis-rule no-lock where
          buf_dis-rule.obj-type = 'маг':U
              AND buf_dis-rule.obj-code = i-obj-code
              AND buf_dis-rule.rule-num = v-gds-rule-num
              AND buf_dis-rule.sts = integer('0':U) no-error .
        if not available buf_dis-rule then do:
          next _do.
        end.
        else do:
          if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
            assign
            v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
            v-dop = substring(v-dop, 1, index(v-dop, chr(44)) - 1)
            v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
            v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
            .
          end.
        end.
        LEAVE _do.
      end.
    end.
    assign
    entry(integer(v-plu), v-record, chr(4)) = v-maria-discnt-value
    no-error
    .
    end.
  end.
  else do:
    if v-marketer-action = 'D' then do:
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input 0
                                  , input no
                                  , input yes
                                  , input 6
                                  , input 5000
                                  , input v-plu
                                  , input '000').
    end.
    else do:
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 7
                                    , input 5000
                                    , input v-plu
                                    , input '001').
      define variable maria-good-code120 as character no-undo .
    assign
      maria-good-code120 = left-trim(ibm-good-code, '0')
      maria-good-code120 = fill('0', 14 - length(maria-good-code120)) + maria-good-code120
    .
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 8
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (substring(maria-good-code120, 1, 5) + chr(4) +
                                                    substring(maria-good-code120, 6, 14)
                                                  )
                                              else (fill('0', 5) + chr(4) + fill('0', 9)))
                                        ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 9
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = 'u':U
                                            then string(cash-gds.price-sale * 100, "999999999")
                                            else '000000000')
      ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 10
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (
                                                  string(cash-gds.gds-stat MODULO 2) +
                                                  string(if cash-gds.fp then 1 else 0) +
                                                  string(cash-gds.office) )
                                              else '000')
                                          ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 12
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then  string(cash-gds.b-code, "999999999")
                                              else "000000000")
                                          ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 20
                                            else 21)
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 2621
                                            else 2379)
                                    , input v-plu
                                    , input (if v-marketer-action = 'U':U
                                              then string(convert-maria-tax-code(cash-gds.vat-code, 0  , cdtaxlst), "X(8)")
                                              else '00000000':U) + chr(4) + chk_name).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 6
                                    , input 5000
                                    , input v-plu
                                    , input (if cash-gds.grp-code = 0
                                             then '001'
                                             else string(cash-gds.grp-code, "999"))).
    end.
  end.
end.
  end.
END .
FOR EACH buf_cd-plu where
        buf_cd-plu.obj-type = 'маг':U
    and buf_cd-plu.obj-code = abs(i-obj-code)
    and buf_cd-plu.pos-type = 'MARIA':U
    and buf_cd-plu.plu-type = 'топ':U:
  if buf_cd-plu.to-del then do:
    create temp-cd-plu.
    buffer-copy buf_cd-plu
    to temp-cd-plu
    .
    assign
    v-plu = TRIM(string( buf_cd-plu.plu-code, "X(40)":U ))
    v-marketer-action = 'd'
    .
define variable vss-include-info121 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
assign
v-plu = substring(v-plu, length(v-plu) - 4 + 1)
.
if v-marketer-action <> 'd'
and available cash-gds
and (cash-gds.grp-code > 99
or cash-gds.price-sale * 100 >  999999999.0)
then do:
    if cash-gds.grp-code > 99 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - № группы на кассе &5 > 99!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , for-cash-desk.pos-type
                            , 'маг':U
                            , i-obj-code
                            , cash-gds.grp-code
                            , chr(10)
                            )
                              ).
    if cash-gds.price-sale * 100 >  999999999.0 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - цена &5 > 999999999!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , for-cash-desk.pos-type
                            , 'маг':U
                            , i-obj-code
                            , cash-gds.price-sale
                            , chr(10)
                            )
                              ).
    v-view-log = yes.
end.
else do:
  if (v-marketer-action <> 'd'
  and available cash-gds
  and lookup('топ':U, cash-gds.unit-cli-type) > 0)
  or (v-marketer-action = 'd'
      and available temp-cd-plu
      and temp-cd-plu.obj-type = 'маг':U
      and temp-cd-plu.obj-code = abs(i-obj-code)
      and temp-cd-plu.pos-type = 'MARIA':U
      and temp-cd-plu.plu-type = 'топ':U
      )
  then do:
  define variable v-plu-pet121 as character no-undo .
  define buffer  bufpet_cd-plu121 for ub.cd-plu.
  for each bufpet_cd-plu121  where
          bufpet_cd-plu121.obj-type = 'маг':U
      and bufpet_cd-plu121.obj-code = abs(i-obj-code)
      and bufpet_cd-plu121.pos-type = 'MARIA':U
      and bufpet_cd-plu121.plu-type = 'топ':U
      AND bufpet_cd-plu121.b-code = (if v-marketer-action = 'd'then temp-cd-plu.b-code else buf_cd-plu.b-code)
      AND bufpet_cd-plu121.b-str  = (if v-marketer-action = 'd'then temp-cd-plu.b-str else buf_cd-plu.b-str):
    assign
    v-plu-pet121 = TRIM(string( bufpet_cd-plu121.plu-code, "X(40)":U ))
    v-plu-pet121 = substring(v-plu-pet121, length(v-plu-pet121) - 4 + 1)
    .
    run maria-put in this-procedure (
                                          buffer for-cash-desk
                                        , input out
                                        , input fname
                                        , input yes
                                        , input 0
                                        , input no
                                        , input 13
                                        , input 1
                                        , input v-plu-pet121
                                        , input (if v-marketer-action = 'u':U
                                                then string(cash-gds.price-sale * 100, "999999999")
                                                else '000000000')
          ).
    v-maria-discnt-value = string(0, '999').
      if action <> 'D':U
      and v-marketer-action <> 'D'
      then do:
      _do:
      do v-ii = 1 to num-entries(drgdsrank):
        assign
        v-gds-rule-num = buffer cash-gds:buffer-field(entry(2, entry(v-ii, drgdsrank), chr(47))):buffer-value.
        if v-gds-rule-num = 0 then next _do.
        find first buf_dis-rule no-lock where
          buf_dis-rule.obj-type = 'маг':U
              AND buf_dis-rule.obj-code = i-obj-code
              AND buf_dis-rule.rule-num = v-gds-rule-num
              AND buf_dis-rule.sts = integer('0':U) no-error .
        if not available buf_dis-rule then do:
          next _do.
        end.
        else do:
          if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
            assign
            v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
            v-dop = substring(v-dop, 1, index(v-dop, chr(44)) - 1)
            v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
            v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
            .
          end.
        end.
        LEAVE _do.
      end.
    end.
    assign
    entry(integer(v-plu), v-record, chr(4)) = v-maria-discnt-value
    no-error
    .
    end.
  end.
  else do:
    if v-marketer-action = 'D' then do:
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input 0
                                  , input no
                                  , input yes
                                  , input 6
                                  , input 5000
                                  , input v-plu
                                  , input '000').
    end.
    else do:
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 7
                                    , input 5000
                                    , input v-plu
                                    , input '001').
      define variable maria-good-code121 as character no-undo .
    assign
      maria-good-code121 = left-trim(ibm-good-code, '0')
      maria-good-code121 = fill('0', 14 - length(maria-good-code121)) + maria-good-code121
    .
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 8
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (substring(maria-good-code121, 1, 5) + chr(4) +
                                                    substring(maria-good-code121, 6, 14)
                                                  )
                                              else (fill('0', 5) + chr(4) + fill('0', 9)))
                                        ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 9
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = 'u':U
                                            then string(cash-gds.price-sale * 100, "999999999")
                                            else '000000000')
      ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 10
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (
                                                  string(cash-gds.gds-stat MODULO 2) +
                                                  string(if cash-gds.fp then 1 else 0) +
                                                  string(cash-gds.office) )
                                              else '000')
                                          ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 12
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then  string(cash-gds.b-code, "999999999")
                                              else "000000000")
                                          ).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 20
                                            else 21)
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 2621
                                            else 2379)
                                    , input v-plu
                                    , input (if v-marketer-action = 'U':U
                                              then string(convert-maria-tax-code(cash-gds.vat-code, 0  , cdtaxlst), "X(8)")
                                              else '00000000':U) + chr(4) + chk_name).
      run maria-put in this-procedure (
                                      buffer for-cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input 6
                                    , input 5000
                                    , input v-plu
                                    , input (if cash-gds.grp-code = 0
                                             then '001'
                                             else string(cash-gds.grp-code, "999"))).
    end.
  end.
end.
  end.
END .
define variable vss-include-info122 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-found122 as logical no-undo .
define variable v-is-script122 as logical no-undo.
define variable v-fields-shift122 as integer no-undo .
   if can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 6 )
   or can-find(temp-tekka-tsk where temp-tekka-tsk.task-num = fname and temp-tekka-tsk.obj-num = 13 )
   then do:
     v-fields-shift122 = - 1.
if v-record <> '':U then
    run maria-put in this-procedure (
                                    buffer for-cash-desk
                                  , input out
                                  , input fname
                                  , input yes
                                  , input v-fields-shift122
                                  , input yes
                                  , input 24
                                  , input 1
                                  , input string(1)
                                  , input v-record
                                    ).
   end.
find first temp-tekka-tsk no-error.
if available temp-tekka-tsk then do:
   v-found122 = yes.
end.
if v-found122 = yes then do:
output stream IBmSTREAM to VALUE(out + fname + '.tsk').
v-is-script122 = no.
for each temp-tekka-tsk:
  if (temp-tekka-tsk.num-rec > 0
  or temp-tekka-tsk.send-get = 'task')
  and temp-tekka-tsk.task-num = fname then do:
    export stream IBmSTREAM temp-tekka-tsk.
    v-found122 = yes.
  end.
  if temp-tekka-tsk.is-script then do:
    v-is-script122 = yes.
  end.
  delete temp-tekka-tsk.
end.
output stream IBMStream
close.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файлы &1(..),&2файл задания &3"
                        , (out + fname)
                        , chr(10)
                        , (out + fname + '.tsk')
                        )
                                       ).
run str/runtekka.p (
                     input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input out
                    ,input out
                    ,input fname
                    ,input v-remote
                    ,input v-is-script122
                    ) no-error .
if error-status:error then do:
  for each temp-tekka-tsk:
    os-delete value( temp-tekka-tsk.filename) .
    delete temp-tekka-tsk.
  end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Прерван обмен информацией с кассой &1,&2&3&2на кассе осталась устаревшая информация"
                           ,for-cash-desk.cash-num
                           ,chr(10)
                           ,return-value
                        )
                                        ).
  assign
  v-view-log = yes
  .
    for each temp-cd-plu:
      delete temp-cd-plu.
    end.
  return "error":U.
end.
else do:
  for each temp-cd-plu,
      first buf_cd-plu where
                  buf_cd-plu.obj-type = temp-cd-plu.obj-type
              and buf_cd-plu.obj-code = temp-cd-plu.obj-code
              and buf_cd-plu.pos-type = temp-cd-plu.pos-type
              and buf_cd-plu.plu-type = temp-cd-plu.plu-type
              and buf_cd-plu.plu-code = temp-cd-plu.plu-code:
    if temp-cd-plu.to-del = yes
    and v-del-mrkt-gds
    then do:
      if lookup(string(for-cash-desk.cash-num), buf_cd-plu.charkey_one) > 0 then do:
        entry(lookup(string(for-cash-desk.cash-num), buf_cd-plu.charkey_one)  ,  buf_cd-plu.charkey_one) = '':U.
        assign
        buf_cd-plu.charkey_one = replace(buf_cd-plu.charkey_one, chr(44) + chr(44), chr(44))
        buf_cd-plu.to-del = (buf_cd-plu.charkey_one <> '':U)
        .
      end.
      if buf_cd-plu.charkey_one = '':U then do:
        delete buf_cd-plu.
        NEXT.
      end.
    end.
    if temp-cd-plu.charkey_two = "":U
    then
    assign
    buf_cd-plu.charkey_two = "":U
    buf_cd-plu.to-send = no
    .
    delete temp-cd-plu.
  end.
end.
end.
run cd-mrkt_update-marketer in this-procedure (
                                                input for-cash-desk.db-num
                                                ,input for-cash-desk.obj-code
                                                ,input for-cash-desk.pos-type
                                                ,input for-cash-desk.cash-num
                                                ,input no
                                              )  .
    end.
  end.
END CASE.
END .
END PROCEDURE.
define variable vss-include-info123 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE SENDING:
DEFINE VARIABLE fq as integer no-undo .
define variable glog as logical no-undo .
define variable vdr-26 as integer no-undo .
define variable vc-obj-type like ub.clients.obj-type no-undo .
define variable vc-obj-code like ub.clients.obj-code no-undo .
define variable vc-host-code like ub.sysconf.host-code no-undo .
define variable vc-region as character no-undo .
_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num AND
         ub.cash-desk.obj-code = i-obj-code AND
        ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    if lookup('InfoKiosk':U + '-only', p-other) > 0
    and ub.cash-desk.pos-type <> 'InfoKiosk':U then do:
      next _cash-desk.
    end.
    if lookup('pricecheck-Servis+':U , p-other) > 0
    and ub.cash-desk.pos-type <> 'pricecheck-Servis+':U then do:
      next _cash-desk.
    end.
define variable vss-include-info124 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable dflt-cd124 as character no-undo .
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type125 as character no-undo .
define variable v-value-date125 as date no-undo .
define variable v-value-decimal125 as decimal no-undo .
define variable v-value-integer125 as INTEGER no-undo .
define variable v-value-logical125 AS LOGICAL no-undo .
define variable v-tth125 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd124
    ,output v-value-date125
    ,output v-value-decimal125
    ,output v-value-integer125
    ,output v-value-logical125
    ,output v-param-type125
    ,INPUT-OUTPUT table-handle v-tth125
    ) no-error .
delete object v-tth125 no-error.
case ub.cash-desk.pos-type:
    when 'IBM-XML':U or when 'Autotank':U
      or
    when 'MAGIA-XML':U
      or
    when 'InfoKiosk':U
      or
    when 'Autotank':U
  then do:
define variable vss-include-info126 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
if ub.cash-desk.pos-type = 'IBM-XML':U
or ub.cash-desk.pos-type = 'Autotank':U
then do:
  file-info:file-name = (out  + "undelivered").
  if file-info:FULL-PATHNAME <> ? then do:
    run str/rsndxibm.p ( input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input out  + "undelivered" ) no-error.
  end.
end.
   if ub.cash-desk.pos-type = 'IBM-XML':U then do:
    run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-IBM-XML':U
        ,input  'cdtaxlst':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF not error-status:error then do:
      cdtaxlst = v-value-character.
    end.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-IBM-XML':U
        ,input  'cd-vat':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
    IF not error-status:error then do:
     cd-vat = v-value-integer.
    end.
    delete object v-tth.
  end.
  end.
  when 'IBM':U
  then do:
define variable vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-type-ibm':U
    ,input  'cdtaxlst':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then cdtaxlst = v-value-character.
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  ub.cash-desk.obj-code
    ,input  'cd-type-ibm':U
    ,input  'cd-vat':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then cd-vat = v-value-integer.
  end.
  when 'OMRON-NEW':U then do:
define variable vss-include-info128 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  end.
  when 'IPC-Servis+':U then do:
define variable vss-include-info129 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-ipc-servispl':U
        ,input  'ipcsdobc':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error
  then dob-curr = v-value-character.
  else do:
    return error substitute("Ошибки при проверке параметра КОДЫ ДОПОЛН ВАЛЮТ ДЛЯ КАССЫ &1 для &2&3"
                              , 'IPC-Servis+':U
                              , 'маг':U
                              , abs(i-obj-code)).
  end.
  if index(dob-curr, ";":U) > 0  and can-do(entry(2,dob-curr,";"),string(i-obj-code)) then do:
    FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-code = i-obj-code
                            and ub.curr-shop.obj-type = 'маг':U
                            and ub.curr-shop.curr-code = int(entry(1,dob-curr,";"))
                            use-index pi NO-ERROR.
    if available ub.curr-shop then curr_cass = ub.curr-shop.exch-rate / curr-shop.exch-scale.
    else do:
      if not g#news then do:
        return error
        substitute("Не найден курс дополнительной валюты &1 в &2&3", entry(1,dob-curr,";"), 'маг':U, i-obj-code).
      end.
    end.
  end.
  end.
  when  'pricecheck-Servis+':U then do:
  run adm/shattri.p (
          input "get":U
          ,input  'маг':U
          ,input  ub.cash-desk.obj-code
          ,input  'cd-type-ipc-servispl':U
          ,input  'ipcsdobc':U
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
  IF not error-status:error then do:
    delete object v-tth.
    dob-curr = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error substitute("Ошибки при проверке параметра КОДЫ ДОПОЛН ВАЛЮТ ДЛЯ КАССЫ &1 для &2&3"
                              , 'IPC-Servis+':U
                              , 'маг':U
                              , abs(i-obj-code)).
  end.
  if index(dob-curr, ";":U) > 0  and can-do(entry(2,dob-curr,";"),string(i-obj-code)) then do:
    FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-code = i-obj-code
                            and ub.curr-shop.obj-type = 'маг':U
                            and ub.curr-shop.curr-code = int(entry(1,dob-curr,";"))
                            use-index pi NO-ERROR.
    if available ub.curr-shop then curr_cass = ub.curr-shop.exch-rate / curr-shop.exch-scale.
    else do:
      if not g#news then do:
        return error
        substitute("Не найден курс дополнительной валюты &1 в &2&3", entry(1,dob-curr,";"), 'маг':U, i-obj-code).
      end.
    end.
  end.
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
else do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Директория для выгрузки для &1 для маг&2: &3"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , out )).
end.
  end.
  when 'NCR-GM':U then do:
define variable vss-include-info130 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
_do26:
do vdr-26 = 1 to 3:
  CASE vdr-26:
    when 1 then do:
      assign
      vc-obj-code = ub.shop.obj-code
      vc-obj-type = 'маг':U
      vc-host-code = ub.shop.host-code
      vc-region    = substitute("&1&2", vc-obj-type, vc-obj-code)
      .
    end.
    when 2 then do:
      assign
      vc-obj-code = 0
      vc-obj-type = '':U
      vc-host-code = ub.shop.host-code
      vc-region    = substitute("Фирма &1&2", vc-host-code)
      .
    end.
    when 3 then do:
      assign
      vc-obj-code = 0
      vc-obj-type = '':U
      vc-host-code = 0
      vc-region    = "Глобально"
      .
    end.
  END CASE.
  find ub.dis-rule no-lock where
                ub.dis-rule.upper-rule-num = 26
            and ub.dis-rule.host-code = vc-host-code
            AND ub.dis-rule.obj-type = vc-obj-type
            AND ub.dis-rule.obj-code = vc-obj-code no-error .
  if available ub.dis-rule then LEAVE _do26.
end.
if available ub.dis-rule then do:
  for each buf_dis-rule no-lock where
          buf_dis-rule.upper-rule-num = ub.dis-rule.rule-num :
    assign
    ncrgmdsc = ncrgmdsc + (if ncrgmdsc = "":U then "":U else ";") +
                string(buf_dis-rule.dis-kat) + "=":U +
                string(buf_dis-rule.discnt-value).
  end.
end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'ncrdrank':U
                else 'ncrdrank':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
  ncrdrank = v-value-character.
end.
delete object v-tth.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'ncrscpfx':U
                else 'ncrscpfx':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then
ncrsc-pfx = string(v-value-integer).
delete object v-tth.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'ncrpgpfx':U
                else 'ncrpgpfx':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then
ncrpg-pfx = string(v-value-integer).
delete object v-tth.
  if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'save-param':U
                else 'save-param':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error then
  ncr-save-param = v-value-character.
  delete object v-tth.
end.
  end.
  when 'NCR-AS@R':U then do:
define variable vss-include-info131 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
_do26:
do vdr-26 = 1 to 3:
  CASE vdr-26:
    when 1 then do:
      assign
      vc-obj-code = ub.shop.obj-code
      vc-obj-type = 'маг':U
      vc-host-code = ub.shop.host-code
      vc-region    = substitute("&1&2", vc-obj-type, vc-obj-code)
      .
    end.
    when 2 then do:
      assign
      vc-obj-code = 0
      vc-obj-type = '':U
      vc-host-code = ub.shop.host-code
      vc-region    = substitute("Фирма &1&2", vc-host-code)
      .
    end.
    when 3 then do:
      assign
      vc-obj-code = 0
      vc-obj-type = '':U
      vc-host-code = 0
      vc-region    = "Глобально"
      .
    end.
  END CASE.
  find ub.dis-rule no-lock where
                ub.dis-rule.upper-rule-num = 26
            and ub.dis-rule.host-code = vc-host-code
            AND ub.dis-rule.obj-type = vc-obj-type
            AND ub.dis-rule.obj-code = vc-obj-code no-error .
  if available ub.dis-rule then LEAVE _do26.
end.
if available ub.dis-rule then do:
  for each buf_dis-rule no-lock where
          buf_dis-rule.upper-rule-num = ub.dis-rule.rule-num :
    assign
    ncrgmdsc = ncrgmdsc + (if ncrgmdsc = "":U then "":U else ";") +
                string(buf_dis-rule.dis-kat) + "=":U +
                string(buf_dis-rule.discnt-value).
  end.
end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'ncrdrank':U
                else 'ncrdrank':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
  ncrdrank = v-value-character.
end.
delete object v-tth.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'ncrscpfx':U
                else 'ncrscpfx':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then
ncrsc-pfx = string(v-value-integer).
delete object v-tth.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'ncrpgpfx':U
                else 'ncrpgpfx':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then
ncrpg-pfx = string(v-value-integer).
delete object v-tth.
  if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U then 'cd-type-NCR-GM':U else 'cd-type-NCR-AS-R':U)
        ,input  (if ub.cash-desk.pos-type = 'NCR-GM':U
                then 'save-param':U
                else 'save-param':U)
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
  IF not error-status:error then
  ncr-save-param = v-value-character.
  delete object v-tth.
end.
  end.
  when 'MARIA':U then do:
define variable vss-include-info132 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-maria':U
        ,input  'cdtaxlst':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
 cdtaxlst = v-value-character.
 delete object v-tth.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-maria':U
        ,input  'dr-list':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
  delete object v-tth.
  dr-list = v-value-character.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
run adm/shattri.p (
        input "get":U
        ,input  'маг':U
        ,input  ub.cash-desk.obj-code
        ,input  'cd-type-maria':U
        ,input  'drgdsrank':U
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .
IF not error-status:error then do:
  delete object v-tth.
  drgdsrank = v-value-character.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
  end.
END CASE.
    RUN for-cash-cycle no-error.
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("&1 &2", error-status:get-message(1), return-value)
                                              ).
      assign
      v-view-log = yes
      .
    end.
  END.
  IF LAST-OF(ub.cash-desk.pos-type) then do:
    if lookup('InfoKiosk':U + '-only', p-other) > 0
    and ub.cash-desk.pos-type <> 'InfoKiosk':U then do:
      next _cash-desk.
    end.
    if lookup('pricecheck-Servis+':U , p-other ) > 0
    and ub.cash-desk.pos-type <> 'pricecheck-Servis+':U then do:
      next _cash-desk.
    end.
define variable vss-include-info133 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
case ub.cash-desk.pos-type:
  when 'IPC-Servis+':U then do:
define variable vss-include-info134 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  os-delete
  value( string( session:temp-directory + "plu" +
  string( var-report-num ) ) + '.plu' ) .
  os-delete
  value( string( session:temp-directory + "bar" +
  string( var-report-num ) ) + '.bar' ) .
  end.
  when  'pricecheck-Servis+':U then do:
  run adm/shattri.p (
          input "get":U
          ,input  'маг':U
          ,input  ub.cash-desk.obj-code
          ,input  'cd-type-ipc-servispl':U
          ,input  'ipcsdobc':U
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-param-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
  IF not error-status:error then do:
    delete object v-tth.
    dob-curr = v-value-character.
  end.
  else do:
    delete object v-tth.
    return error substitute("Ошибки при проверке параметра КОДЫ ДОПОЛН ВАЛЮТ ДЛЯ КАССЫ &1 для &2&3"
                              , 'IPC-Servis+':U
                              , 'маг':U
                              , abs(i-obj-code)).
  end.
  if index(dob-curr, ";":U) > 0  and can-do(entry(2,dob-curr,";"),string(i-obj-code)) then do:
    FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-code = i-obj-code
                            and ub.curr-shop.obj-type = 'маг':U
                            and ub.curr-shop.curr-code = int(entry(1,dob-curr,";"))
                            use-index pi NO-ERROR.
    if available ub.curr-shop then curr_cass = ub.curr-shop.exch-rate / curr-shop.exch-scale.
    else do:
      if not g#news then do:
        return error
        substitute("Не найден курс дополнительной валюты &1 в &2&3", entry(1,dob-curr,";"), 'маг':U, i-obj-code).
      end.
    end.
  end.
run str/get-inis.p (
                input 'маг':U
              , input ub.cash-desk.obj-code
              , input ub.cash-desk.pos-type
              , input cash-desk.remote
              , input "send":U
              , output out
              , output out2
              , output in_
              , output spl
              , output sav
              , output v-remote
              )  no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value )).
  assign
  v-view-log = yes.
  return error.
end.
else do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Директория для выгрузки для &1 для маг&2: &3"
                          , ub.cash-desk.pos-type
                          , ub.cash-desk.obj-code
                          , out )).
end.
  end.
  when 'NCR-GM':U
  then do:
define variable vss-include-info135 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _lock-gds:
  DO while ind < 100 :
    run gbl/lock-prc.p (
         input 'pncr':U
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input 'маг':U
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + 'Передача товаров')
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if not error-status:error then do:
      leave _lock-gds.
    end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end.
    OS-append
    value( out + fname + '.dat':U )
    value( out + "gmrecmnt.dat":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
      output stream ibmstream to value( out + "gmrecmnt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.
       v-found-good = no .
define variable vss-include-info136 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output i-host-code
  )  .
       for each cash-gds no-lock,
           first ub.bar-code no-lock where ub.bar-code.b-code = cash-gds.b-code :
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = ""
                        and ub.dis-gds-rule-attr.obj-code = 0
                        and ub.dis-gds-rule-attr.pos-type = 'NCR-AS@R':U) then
          do:
             v-found-good = yes.
             leave.
          end.
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = 'орг':U
                        and ub.dis-gds-rule-attr.obj-code = i-host-code
                        and ub.dis-gds-rule-attr.pos-type = 'NCR-AS@R':U) then
          do:
             v-found-good = yes.
             leave.
          end.
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = 'маг':U
                        and ub.dis-gds-rule-attr.obj-code = i-obj-code
                        and ub.dis-gds-rule-attr.pos-type = 'NCR-AS@R':U) then
          do:
             v-found-good = yes.
             leave.
          end.
       end.
       if v-found-good then
       do:
         run output-ncr-bonus in this-procedure ( input i-host-code,
                                                      input i-obj-code,
                                                      input out,
                                                      output fname) .
         OS-append
           value( out + fname + '.dat':U )
           value( out + fname + ".pmt":U).
        if search(out + 'debug.flg') = ? then do:
          OS-delete value( out + fname + '.dat':U ).
        end.
        output stream ibmstream to value( out +  "pmt.ctl":U).
        put unformatted skip.
        output stream ibmstream close.
       end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                            ,( out + "gmrecmnt.dat":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление товаров')
                            else ('Ждите - ' + 'удаление товаров') )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление товаров')
                            else ('Ждите - ' + 'удаление товаров') )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + "gmrecmnt.dat":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.
  for each temp-dis-kat-file where
            temp-dis-kat-file.to-send = yes:
    OS-copy
    value(temp-dis-kat-file.temp-file)
    value(temp-dis-kat-file.send-file).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value(temp-dis-kat-file.temp-file).
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные по скидкам выгружены в файл &1"
                            , temp-dis-kat-file.send-file
                          )
                                          ).
  end.
  end.
  when 'NCR-AS@R':U
  then do:
define variable vss-include-info137 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  _lock-gds:
  DO while ind < 100 :
    run gbl/lock-prc.p (
         input 'pncr':U
        ,input i-obj-code
        ,input 0
        ,input 0
        ,input 'маг':U
        ,input "":U
        ,input "":U
        ,input ("Код объекта" + ",,,":U +
                "Тип объекта" +  ",,,":U + 'Передача товаров')
        ,input no
        ,buffer lock-batchprocess
        ) no-error .
    if not error-status:error then do:
      leave _lock-gds.
    end.
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end.
    OS-append
    value( out + fname + '.dat':U )
    value( out + "gmrecmnt.dat":U).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value( out + fname + '.dat':U ).
    end.
    if ub.cash-desk.pos-type = 'NCR-AS@R':U then do:
      output stream ibmstream to value( out + "gmrecmnt.ctl":U).
      put unformatted skip.
      output stream ibmstream close.
       v-found-good = no .
define variable vss-include-info138 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output i-host-code
  )  .
       for each cash-gds no-lock,
           first ub.bar-code no-lock where ub.bar-code.b-code = cash-gds.b-code :
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = ""
                        and ub.dis-gds-rule-attr.obj-code = 0
                        and ub.dis-gds-rule-attr.pos-type = 'NCR-AS@R':U) then
          do:
             v-found-good = yes.
             leave.
          end.
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = 'орг':U
                        and ub.dis-gds-rule-attr.obj-code = i-host-code
                        and ub.dis-gds-rule-attr.pos-type = 'NCR-AS@R':U) then
          do:
             v-found-good = yes.
             leave.
          end.
          if can-find(first ub.dis-gds-rule-attr where
                            ub.dis-gds-rule-attr.gds-code = ub.bar-code.gds-code
                        and ub.dis-gds-rule-attr.obj-type = 'маг':U
                        and ub.dis-gds-rule-attr.obj-code = i-obj-code
                        and ub.dis-gds-rule-attr.pos-type = 'NCR-AS@R':U) then
          do:
             v-found-good = yes.
             leave.
          end.
       end.
       if v-found-good then
       do:
         run output-ncr-bonus in this-procedure ( input i-host-code,
                                                      input i-obj-code,
                                                      input out,
                                                      output fname) .
         OS-append
           value( out + fname + '.dat':U )
           value( out + fname + ".pmt":U).
        if search(out + 'debug.flg') = ? then do:
          OS-delete value( out + fname + '.dat':U ).
        end.
        output stream ibmstream to value( out +  "pmt.ctl":U).
        put unformatted skip.
        output stream ibmstream close.
       end.
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                            ,( out + "gmrecmnt.dat":U)
                          )
                                         ).
    if g#news
    or g#auto
    or g#esys
    then do:
      run str/waitpn.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление товаров')
                            else ('Ждите - ' + 'удаление товаров') )
                  ,input ' Подождите 15 сек '
                  ,input 15
                  ) no-error.
    end.
    else do:
      run str/waitp.w (
                   input (out + "gmrecmnt.dat":U)
                  ,input ( if action = 'U'
                            then ('Ждите - ' + 'добавление товаров')
                            else ('Ждите - ' + 'удаление товаров') )
                  ,input ' Подождите 15 сек '
                  ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                  ,input 15
                  )
                  no-error.
    end.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Прерван обмен информацией с кассой, на кассе осталась устаревшая информация"
                              )
                                              ).
        os-delete value( out + "gmrecmnt.dat":U).
        assign
        v-view-log = yes
        .
        return "error":U.
    end.
  for each temp-dis-kat-file where
            temp-dis-kat-file.to-send = yes:
    OS-copy
    value(temp-dis-kat-file.temp-file)
    value(temp-dis-kat-file.send-file).
    if search(out + 'debug.flg') = ? then do:
      OS-delete value(temp-dis-kat-file.temp-file).
    end.
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Данные по скидкам выгружены в файл &1"
                            , temp-dis-kat-file.send-file
                          )
                                          ).
  end.
  end.
END CASE.
  END.
END.
END PROCEDURE.
define variable vss-include-info139 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE putc-13.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type as char no-undo.
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-call-from-goods as logical no-undo .
define variable ii as integer no-undo .
define variable v-rate-code like ub.tax-rate.rate-code no-undo .
define variable v-envd as LOGICAL no-undo .
define variable v-plu as integer no-undo .
define buffer buf_tax-rate for ub.tax-rate.
define buffer buf_tax-rate-attr for ub.tax-rate-attr.
if cash-txr.rate-value = ?
and not (cash-txr.news-action OR cash-txr.status_ <> 'тек':U)
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Для маг &1 ставка налога &2 НЕ ОПРЕДЕЛЕНА"
                            ,buf_cash-desk.obj-code
                            ,cash-txr.rate-code
                          )
                                          ).
    v-view-log = yes.
    return '':U .
end.
CASE pos-type:
  when 'IBM':U then do:
   if cd-vat = 0 or p-cash-os = "LINUX":U then do:
      PUT stream IBMstream unformatted
      '13 "'
      if cash-txr.news-action OR cash-txr.status_ <> 'тек':U
      then "D"
      else string( action, "x(1)" )
      '" '
      cash-txr.tax-code format "9"
      ' '
      cash-txr.rate-code
      ' '
      (if cash-txr.tax-type = '%':U then 2 else 1) format "9"
      (if cash-txr.rate-value = ?
        then 0
        else cash-txr.rate-value) format ">>>>>>>>>9.99"
      chr(10).
    end.
    else do:
      _do:
      do ii = 1 to num-entries(cdtaxlst, ";":U):
        assign
        v-rate-code = integer(entry(1, entry(ii, cdtaxlst, ";":U), "-":U))
        no-error .
        if error-status:error then do:
          message
          "Неверное значение настроечного параметра cdtaxlst" cdtaxlst
          view-as alert-box error .
          return error .
        end.
        find first buf_tax-rate no-lock where
                  buf_tax-rate.rate-code = v-rate-code no-error .
        if not available buf_tax-rate then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Для маг &1 ставка налога &2 не входит в число действующих на кассе &2"
                                  ,buf_cash-desk.obj-code
                                  ,v-rate-code
                                  ,buf_Cash-desk.pos-type
                                )
                                                ).
          v-view-log = yes.
          return error .
        end.
        if buf_tax-rate.rate-code = cash-txr.rate-code then do:
          PUT stream IBMstream unformatted
          '13 "'
          if cash-txr.news-action OR cash-txr.status_ <> 'тек':U
          then "D"
          else string( action, "x(1)" )
          '" '
          convert-tax-code(buf_tax-rate.rate-code, cdtaxlst)  format "9"
          ' '
          cash-txr.rate-code
          ' '
          (if cash-txr.tax-type = '%':U then 2 else 1) format "9"
          (if cash-txr.rate-value = ?
          then 0
          else cash-txr.rate-value) format ">>>>>>>>>9.99"
          chr(10).
        end.
      end.
    end.
  end.
  when 'IBM-XML':U then do:
      find first buf_tax-rate-attr where buf_tax-rate-attr.rate-code = cash-txr.rate-code
                                     and buf_tax-rate-attr.tax-code = cash-txr.tax-code
                                     and buf_tax-rate-attr.attr-code = "envd" no-error .
       if AVAILABLE buf_tax-rate-attr then do:
           v-envd = yes .
       end.
       else v-envd = no .
    run bgelib-tag-open in this-procedure ( input 3, input "TaxCodes"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "TCCode"
                                          , input string(cash-txr.rate-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCType"
                                          , input string((if cash-txr.tax-type = '%':U then 2 else 1)), input 1 ).
    if v-envd then do:
    run bgelib-tag-put in this-procedure ( input 4, input "TCValue"
                                          , input string(-1), input 1 ).
    end.
    else do:
    run bgelib-tag-put in this-procedure ( input 4, input "TCValue"
                                          , input string(if cash-txr.rate-value = ?
                                                         then 0
                                                         else cash-txr.rate-value), input 1 ).
    end.
    run bgelib-tag-put in this-procedure ( input 4, input "TCInclude"
                                          , input string(1), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "TaxCodes").
  end.
  when 'MAGIA-XML':U then do:
    run bgelib-tag-open in this-procedure ( input 3, input "TaxCodes"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "TCCode"
                                          , input string(cash-txr.rate-code), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCType"
                                          , input string((if cash-txr.tax-type = '%':U then 2 else 1)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCValue"
                                          , input string(if cash-txr.rate-value = ?
                                                         then 0
                                                         else cash-txr.rate-value), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCInclude"
                                          , input string(1), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "TCLock"
                                          , input string(if cash-txr.news-action
                                                         OR cash-txr.status_ <> 'тек':U
                                                         then 1
                                                         else 0), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "TaxCodes").
  end.
  when 'MARIA':U then do:
  end.
END CASE .
END PROCEDURE .
procedure get-o-attr :
define input parameter par-gds-code like ub.goods.gds-code no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define output parameter par-std-discnt-rule as integer no-undo .
define output parameter par-temp-disc-rule as integer no-undo .
define output parameter par-temp-disc-method as character no-undo .
define output parameter par-wd-rule as integer no-undo .
define output parameter par-fp as logical no-undo .
define output parameter par-grp-code as integer no-undo init 1.
define output parameter par-petrol-purse as logical no-undo .
define output parameter par-need-auth as logical no-undo .
define output parameter par-qnty-discnt-rule as integer no-undo .
define output parameter par-kat-discnt-rule as integer no-undo .
define output parameter par-kat-discnt-method as character no-undo .
define output parameter par-date-discnt-rule as integer no-undo .
define output parameter par-abs-discnt-rule as integer no-undo .
define output parameter par-tot-discnt-rule as integer no-undo .
define output parameter par-wgd-rule as integer no-undo .
define output parameter par-taracode as character no-undo .
define buffer loc-gds-obj-attr for ub.gds-obj-attr.
define buffer loc-dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_temp-dis-gds-rule for temp-dis-gds-rule.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
  do
  on error undo, return error
  :
    for each  loc-gds-obj-attr No-LOCK  where
              loc-gds-obj-attr.gds-code = par-gds-code AND
              loc-gds-obj-attr.obj-code = par-obj-code AND
              loc-gds-obj-attr.obj-type = par-obj-type :
      CASE loc-gds-obj-attr.attr-code:
        when 'free-price':U  then do:
          assign
          par-fp =  if loc-gds-obj-attr.attr-value = "yes"
                    then yes
                    else no
          .
        end.
        when 'sum-grp':U then do:
          assign
          par-grp-code =  integer(loc-gds-obj-attr.attr-value) no-error
          .
        end.
        when 'petrol-purse':U then do:
          assign
          par-petrol-purse =  if loc-gds-obj-attr.attr-value = "yes"
                              then yes
                              else no
          .
        end.
        when 'need-auth':U then do:
          assign
          par-need-auth =  if loc-gds-obj-attr.attr-value = "yes"
                              then yes
                              else no
          .
        end.
        when 'taracode':U  then do:
          assign
          par-taracode = loc-gds-obj-attr.attr-value no-error
          .
        end.
      END CASE.
    end.
    define variable v-par-log as logical no-undo .
   find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = ''
          and loc-dis-gds-rule.obj-code = 0
          and loc-dis-gds-rule.discnt-role = 'without-gds-disc':U no-error.
    if available loc-dis-gds-rule then do:
      par-wgd-rule = loc-dis-gds-rule.rule-num.
    end.
    find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = ''
          and loc-dis-gds-rule.obj-code = 0
          and loc-dis-gds-rule.discnt-role = 'without-disc':U no-error.
    if available loc-dis-gds-rule then do:
      par-wd-rule = loc-dis-gds-rule.rule-num.
    end.
    define variable loc-host-code as integer no-undo .
define variable vss-include-info140 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  par-obj-type
  ,input  par-obj-code
  ,output loc-host-code
  )  .
    find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = 'орг':U
          and loc-dis-gds-rule.obj-code = loc-host-code
          and loc-dis-gds-rule.discnt-role = 'without-gds-disc':U no-error.
    if available loc-dis-gds-rule then do:
      par-wgd-rule = loc-dis-gds-rule.rule-num.
    end.
    find first loc-dis-gds-rule where
              loc-dis-gds-rule.gds-code = par-gds-code
          and loc-dis-gds-rule.pos-type = dflt-cd
          and loc-dis-gds-rule.obj-type = 'орг':U
          and loc-dis-gds-rule.obj-code = loc-host-code
          and loc-dis-gds-rule.discnt-role = 'without-disc':U no-error.
    if available loc-dis-gds-rule then do:
      par-wd-rule = loc-dis-gds-rule.rule-num.
    end.
    if par-wd-rule > 0 then do:
      find first buf_dis-rule no-lock where
                buf_Dis-rule.rule-num = par-wd-rule no-error.
      if available buf_dis-rule then do:
        run create-dis-rule in this-procedure ( input buf_dis-rule.rule-num
                                               , (buf_Dis-rule.time-rule-num >= 0)) no-error .
      end.
    end.
    if par-wgd-rule > 0 then do:
      find first buf_dis-rule no-lock where
                buf_Dis-rule.rule-num = par-wgd-rule no-error.
      if available buf_dis-rule then do:
        run create-dis-rule in this-procedure ( input buf_dis-rule.rule-num
                                               , (buf_Dis-rule.time-rule-num >= 0)) no-error .
      end.
    end.
    for each  loc-dis-gds-rule No-LOCK  where
              loc-dis-gds-rule.gds-code = par-gds-code
         AND  loc-dis-gds-rule.obj-code = par-obj-code
         AND  loc-dis-gds-rule.obj-type = par-obj-type
         and  loc-dis-gds-rule.pos-type = dflt-cd :
      CASE loc-dis-gds-rule.discnt-role:
        when 'std-disc':U then do:
          assign
          par-std-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when 'temp-disc':U then do:
          if loc-dis-gds-rule.nonunique = ''
          then do:
          assign
          par-temp-disc-rule = loc-dis-gds-rule.rule-num
          .
        end.
          else do:
            if par-temp-disc-method = '' then do:
              find first buf_dis-cfg-rule no-lock where
                        buf_dis-cfg-rule.table-name = 'dis-gds-rule':U
                    and buf_dis-cfg-rule.pos-type = dflt-cd
                    and buf_dis-cfg-rule.templ-rl-root = loc-dis-gds-rule.templ-rl-root no-error.
              assign
              par-temp-disc-method = (if available buf_dis-cfg-rule
                                      then buf_dis-cfg-rule.nonunique
                                      else chr(63))
              .
            end.
            create buf_temp-dis-gds-rule.
            buffer-copy
            loc-dis-gds-rule
            to
            buf_temp-dis-gds-rule
            .
            release buf_temp-dis-gds-rule.
          end.
        end.
        when 'pcnt-kat':U then do:
          if loc-dis-gds-rule.nonunique = ''
          then do:
            assign
            par-kat-discnt-rule = loc-dis-gds-rule.rule-num
            .
          end.
          else do:
            if par-kat-discnt-method = '' then do:
              find first buf_dis-cfg-rule no-lock where
                        buf_dis-cfg-rule.table-name = 'dis-gds-rule':U
                    and buf_dis-cfg-rule.pos-type = dflt-cd
                    and buf_dis-cfg-rule.templ-rl-root = loc-dis-gds-rule.templ-rl-root no-error.
              assign
              par-kat-discnt-method = (if available buf_dis-cfg-rule
                                      then buf_dis-cfg-rule.nonunique
                                      else chr(63))
              .
            end.
            create buf_temp-dis-gds-rule.
            buffer-copy
            loc-dis-gds-rule
            to
            buf_temp-dis-gds-rule
            .
            release buf_temp-dis-gds-rule.
          end.
        end.
        when 'pcnt-date':U then do:
          assign
          par-date-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when 'without-disc':U then do:
          assign
          par-wd-rule =  loc-dis-gds-rule.rule-num
          .
        end.
        when 'without-gds-disc':U then do:
          assign
          par-wgd-rule =  loc-dis-gds-rule.rule-num
          .
        end.
        when 'pcnt-qnty':U then do:
          assign
          par-qnty-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when 'pcnt-kat':U  then do:
          assign
          par-kat-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when 'abs-disc':U  then do:
          assign
          par-abs-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
        when 'pcnt-tot':U  then do:
          assign
          par-tot-discnt-rule = loc-dis-gds-rule.rule-num
          .
        end.
      END CASE.
      find first buf_dis-rule no-lock where
                buf_Dis-rule.rule-num = loc-dis-gds-rule.templ-rl-root no-error.
      if available buf_dis-rule then do:
        run create-dis-rule in this-procedure ( input loc-dis-gds-rule.rule-num
                                               , (buf_Dis-rule.time-rule-num >= 0)) no-error .
      end.
    end.
  end.
end procedure.
procedure get-gds-obj-fields :
define parameter buffer buf_gds-obj for ub.gds-obj .
define input parameter par-find-buffer as logical no-undo .
define input parameter par-gds-code like ub.goods.gds-code no-undo .
define input parameter par-obj-code like ub.clients.obj-code no-undo .
define input parameter par-obj-type like ub.clients.obj-type no-undo .
define output parameter par-fact-qnty like ub.gds-obj.fact-qnty no-undo .
define output parameter par-cash-parts as logical no-undo .
define output parameter p-is-null-price              like ub.fbr-gds-obj.is-null-price  no-undo .
define output parameter p-is-menu                    like ub.fbr-gds-obj.is-menu no-undo .
define output parameter p-is-semi-finished           like ub.fbr-gds-obj.is-semi-finished no-undo .
define output parameter p-is-modificator             like ub.fbr-gds-obj.is-semi-finished no-undo .
define output parameter p-fbr-grp-code               like ub.fbr-gds-grp.node-code no-undo .
define output parameter p-fbr-obj-code               like ub.fbr-gds-obj.fbr-obj-code no-undo .
  do
  on error undo, return error
  :
    if par-find-buffer then do:
      find first buf_gds-obj no-lock where
                buf_gds-obj.gds-code = par-gds-code AND
                buf_gds-obj.obj-type = par-obj-type AND
                buf_gds-obj.obj-code = par-obj-code no-error .
    end.
    if not avail buf_gds-obj
    and ub.shop.is-catering = no
    then do:
      return.
    end.
    assign
    par-fact-qnty = (if available buf_gds-obj
                     then buf_gds-obj.fact-qnty
                     else 0)
    .
    assign
    par-cash-parts = (if available buf_gds-obj
                      then buf_gds-obj.cash-parts
                      else no)
    .
    if available buf_fbr-gds-obj then do:
      assign
      p-is-null-price     =  buf_fbr-gds-obj.is-null-price
      p-is-menu           =  buf_fbr-gds-obj.is-menu
      p-is-semi-finished  =  buf_fbr-gds-obj.is-semi-finished
      p-is-modificator    =  buf_fbr-gds-obj.is-modificator
      p-fbr-grp-code      =  buf_fbr-gds-obj.fbr-grp-code
      p-fbr-obj-code      =  buf_fbr-gds-obj.fbr-obj-code
      .
    end.
  end.
end procedure.
procedure get-prt-and-unit :
define input parameter par-prt-root like ub.goods.prt-root no-undo .
define input parameter par-unit-base like ub.goods.unit-base no-undo .
define output parameter par-empty-scale as logical no-undo .
  do
  on error undo, return error
  :
    FIND FIRST ub.gds-prt where
               ub.gds-prt.upper-code = par-prt-root NO-LOCK .
    assign
    par-empty-scale = NOT (ub.shop.doc-prt AND ( ub.gds-prt.node-name <> '_Пустая шкала':U))
    .
    FIND FIRST ub.units WHERE
               ub.units.unit-name = par-unit-base NO-LOCK .
  end.
end procedure.
define variable vss-include-info141 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure create-ncr-kat-discnt :
define input parameter p-subject-code as character no-undo .
define input parameter p-cd-subject-code as character no-undo .
define input parameter p-subject-name as character no-undo .
define input parameter p-dis-rule-num like ub.dis-rule.rule-num no-undo .
define input parameter p-templ-rl-root like ub.dis-rule.templ-rl-root no-undo .
define input parameter p-tree as character no-undo .
define input parameter p-discnt as decimal no-undo .
define variable v-dis-rule-num as integer no-undo .
define variable v-tree as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-dis-kat as integer   no-undo .
define buffer buf_cash-dis-rule for cash-dis-rule.
define buffer buf_cash-dis-time-rule for cash-dis-time-rule.
define buffer slave_cash-dis-rule for cash-dis-rule.
  do
  on error undo, return error
  :
    v-discnt = p-discnt.
    if p-dis-rule-num > 0 then do:
      find first buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.rule-num = p-dis-rule-num no-error.
      if not available buf_cash-dis-rule
      or (buf_cash-dis-rule.templ-rl-root <> p-templ-rl-root
         and
         p-templ-rl-root <> ?)
      then do:
        return error .
      end.
      if p-templ-rl-root = ? then do:
        p-templ-rl-root = buf_cash-dis-rule.templ-rl-root.
      end.
      if buf_cash-dis-rule.uniq-field = ''
      or buf_cash-dis-rule.is-term
      then do:
        v-tree = no.
        v-dis-rule-num = buf_cash-dis-rule.upper-rule-num.
      end.
      if buf_cash-dis-rule.time-rule-num > 0 then do:
        find first buf_cash-dis-time-rule no-lock where
                buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
        if not available buf_cash-dis-time-rule then do:
          return error .
        end.
        release buf_cash-dis-time-rule.
      end.
        _buf-cash-dis-rule:
        for each buf_cash-dis-rule no-lock where
                buf_cash-dis-rule.upper-rule-num = (if v-tree then p-dis-rule-num else v-dis-rule-num):
          if not v-tree then do:
            find first slave_cash-dis-rule no-lock where
                slave_cash-dis-rule.rule-num = v-dis-rule-num .
            assign v-dis-kat = slave_cash-dis-rule.dis-kat .
            if buf_cash-dis-rule.rule-num <> p-dis-rule-num then next _buf-cash-dis-rule.
          end.
          else
           do:
             assign v-dis-kat = buf_cash-dis-rule.dis-kat .
           end .
          if buf_cash-dis-rule.time-rule-num > 0 then do:
            find first buf_cash-dis-time-rule no-lock where
                      buf_cash-dis-time-rule.time-rule-num = buf_cash-dis-rule.time-rule-num no-error.
            if not available buf_cash-dis-time-rule then next _buf-cash-dis-rule.
          end.
          FIND FIRST cash-ncr-dis-kat where
                  cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
          if not avail cash-ncr-dis-kat then do:
            create cash-ncr-dis-kat.
            error-status:error = false.
          end.
          cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
          cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
          if buf_cash-dis-rule.value-type = integer('12':U) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = integer(p-subject-code)
                  and  cash-gds-discnt.rule-num = buf_cash-dis-rule.rule-num
                  and cash-gds-discnt.obj-type = 'маг':U
                  and cash-gds-discnt.obj-code = i-obj-code
                  no-error.
            if available cash-gds-discnt then do:
              assign
              v-discnt = cash-gds-discnt.discnt-value
              .
            end.
            else do:
              v-discnt = p-discnt.
            end.
          end.
          assign
          cash-ncr-dis-kat.subject-code  =  p-subject-code
          cash-ncr-dis-kat.cd-subject-code  =  p-cd-subject-code
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20)
          cash-ncr-dis-kat.cd-subject-name  =  SUBSTRING(p-subject-name, 1, 20) +
                                             ( if length(p-subject-name) < 20 then fill( chr(32) , 20 - length(p-subject-name) ) else '' )
          cash-ncr-dis-kat.dis-kat =  (if v-dis-kat < 0 then 0 else v-dis-kat)
          cash-ncr-dis-kat.rule-num = buf_cash-dis-rule.rule-num
          cash-ncr-dis-kat.time-rule-num = buf_cash-dis-rule.time-rule-num
          cash-ncr-dis-kat.cd-disc-string   = "****":U  +
                                          (if buf_cash-dis-rule.templ-rl-root = 89
                                           then '80'
                                           else (if buf_cash-dis-rule.discnt-value > 0
                                                 then '80':U
                                                 else '00':U)
                                           )
          .
          if p-tree = 'time-rule-num':U then do:
            if available buf_cash-dis-time-rule
            and buf_cash-dis-time-rule.value-type <> '0':U
            then do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
                                            (if buf_cash-dis-time-rule.value-type = '2':U
                                              then
                                              ("D":U + substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-from, "99/99/9999"), 1, 2) +
                                                      "-":U +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 9, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 4, 2) +
                                                      substring(string(buf_cash-dis-time-rule.date-to, "99/99/9999"), 1, 2)
                                              )
                                              else
                                              ("T00":U +
                                                        (if buf_cash-dis-time-rule.week-day-0  then "0" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-1  then "2" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-2  then "3" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-3  then "4" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-4  then "5" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-5  then "6" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-6  then "7" else "":U) +
                                                        (if buf_cash-dis-time-rule.week-day-7  then "1" else "":U) +
                                                      chr(47) +
                                                      replace(string(buf_cash-dis-time-rule.time-from, "HH:MM"), ':':U, '':U) + "-":U +
                                                      replace(string(buf_cash-dis-time-rule.time-to, "HH:MM"), ':':U, '':U)
                                              )
                                            )
              .
            end.
            else do:
              assign
              cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string + "D000101-991231":U
              .
            end.
          end.
          if p-tree = 'tot-sum':U then do:
            assign
            cash-ncr-dis-kat.cd-disc-string = cash-ncr-dis-kat.cd-disc-string +
            '>' + replace(string(round(buf_cash-dis-rule.tot-sum, 2), '99999999999.99'), '.':u , '':U)
            .
          end.
          assign
          cash-ncr-dis-kat.cd-other =   fill(chr(32), 10) +  "xx ":U +
                                        (if buf_cash-dis-rule.value-type = integer('12':U)
                                         or buf_cash-dis-rule.value-type = integer('3':U)
                                        then "=":U
                                        else "%":U) +
                                        replace(string(abs(if v-discnt <> ? then v-discnt else buf_cash-dis-rule.discnt-value),"9999999.9"), '.':U, '':U)
          .
        end.
    end.
    else do:
      FIND FIRST cash-ncr-dis-kat where
              cash-ncr-dis-kat.crf = (cr-ncr-dis-kat + 1) No-ERROR.
      if not avail cash-ncr-dis-kat then do:
      create cash-ncr-dis-kat.
      error-status:error = false.
      end.
      cash-ncr-dis-kat.crf = cr-ncr-dis-kat + 1.
      cr-ncr-dis-kat = cr-ncr-dis-kat + 1.
      assign
      cash-ncr-dis-kat.subject-code  = p-subject-code
      cash-ncr-dis-kat.cd-subject-code  = p-cd-subject-code
      cash-ncr-dis-kat.cd-subject-name  = p-subject-name
      cash-ncr-dis-kat.dis-kat =  - 1
      cash-ncr-dis-kat.rule-num = 0
      cash-ncr-dis-kat.time-rule-num = 0
      .
    end.
  end.
end procedure.
procedure output-ncr-bonus:
define input parameter i-host-code as integer no-undo .
define input parameter i-obj-code  as integer no-undo .
define input parameter out         as character no-undo .
define output parameter fname      as character no-undo .
def var v-found as log no-undo .
def var v-upd   as char no-undo .
def var v-ver   as char no-undo .
def var v-char-delim-1  as char initial ',' no-undo .
def var v-char-delim-2  as char initial ';' no-undo .
def var v-char-1        as char no-undo .
def var v-char-2        as char no-undo .
def var v-char-21       as char no-undo .
def var v-char-3        as char no-undo .
def var v-char-4        as char no-undo .
def var v-char-41       as char no-undo .
def var v-char-42       as char no-undo .
def var v-char-5        as char no-undo .
def var v-char-6        as char no-undo .
def var v-char-61       as char no-undo .
def var v-char-62       as char no-undo .
def var v-char-8        as char no-undo .
def var v-char-9        as char no-undo .
def var v-char-7        as char no-undo .
def var v-char-71       as char no-undo .
def var v-char-72       as char no-undo .
def var v-cassa         as char no-undo .
def var v-is-weight     as log  no-undo init false .
def var v-ean13         as char no-undo .
def var v-tmpchar       as char no-undo .
def var v-today         as date no-undo .
def buffer buf_dis-gds-rule-attr for ub.dis-gds-rule-attr.
def buffer buf_dis-gds-rule      for ub.dis-gds-rule .
def buffer chk_dis-gds-rule      for ub.dis-gds-rule .
def buffer buf_dis-thbj-rule     for ub.dis-thbj-rule .
def buffer buf_dis-rule          for ub.dis-rule .
def buffer buf_dis-time-rule     for ub.dis-time-rule .
def buffer buf_prod-bc           for ub.prod-bc .
def buffer buf_bar-code          for ub.bar-code .
def buffer buf_units             for ub.units .
def buffer buf_goods             for ub.goods .
def buffer buf_gds-obj           for ub.gds-obj .
assign
    fname = substring( string( next-value( s-spool, ub ), '99999999999999999999'), 13, 8 ).
assign
 v-ver = "2.02.00"
 v-char-1 = "0,0,0,,,,,0,1,0,0,1,;,0,0,1,0,0,"
 v-char-2 = "0,0,0,0,0,0,"
 v-char-21 = "0,0,0,"
 v-char-3 = "0,0,0,"
 v-char-4 =
 ",;,,;,;,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
 v-char-41 =
 ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,0,0,6,0,0,"
 v-char-42 =
 ",,,,,,0,0,2,0,0,0,0,0,0,4,0,0,127,0,2359,,,,,,,0,0,3,0,1,0,1,0,21,0,0,"
 v-char-5 =
 "0,0,1,1,0,4,1,"
 v-char-6 =
 ",;,;,;,;,;,0;+                                       ;"
 v-char-61 =
 ",;,;,;,;,;,1;+                                       ;"
 v-char-62 =
 ",;,;,;,;,;,1;Message                                 ;"
 v-char-7 =
 "006;00;000;               ;          ;,0,0"
 v-char-71 =
 "006;04;000;               ;          ;,0,0"
 v-char-72 =
 "021;00;000;               ;          ;Выдать марок$FinalPointsBalance$ шт.,0,0,4,0,1,0,1,0,22,0,0,0,0,0,1,1,0,4,1,"
 v-char-8 =
 ";,;,;,;,;,;,1;" + fill(" ",40) + ";022;06;000;"
 v-char-9 =
 "               ;          ;________________________MAPOK=$FinalPointsBalance$,0,0"
.
define variable vss-include-info142 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  'маг':U
  ,input  i-obj-code
  ,output v-today
  )  .
 output stream IBMStream to value(out + fname + ".dat") convert target "utf-8"  .
 _buf_dis-gds-rule:
 for each buf_dis-gds-rule no-lock
 where buf_dis-gds-rule.templ-rl-root = 91
   and buf_dis-gds-rule.pos-type = 'NCR-AS@R':U
   ,
   first buf_dis-rule no-lock
   where buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
     and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
    and buf_dis-time-rule.date-to >= v-today
      :
       if buf_dis-gds-rule.obj-type = "" and buf_dis-gds-rule.obj-code = 0 then do:
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
              (( chk_dis-gds-rule.obj-type = 'орг':U  and chk_dis-gds-rule.obj-code = i-host-code ) or
               ( chk_dis-gds-rule.obj-type = 'маг':U and chk_dis-gds-rule.obj-code = i-obj-code  )) no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       if buf_dis-gds-rule.obj-type = 'орг':U and buf_dis-gds-rule.obj-code = i-host-code then do:
           find first chk_dis-gds-rule no-lock
           where chk_dis-gds-rule.gds-code = buf_dis-gds-rule.gds-code and
                 chk_dis-gds-rule.templ-rl-root = buf_dis-gds-rule.templ-rl-root and
                 chk_dis-gds-rule.pos-type = buf_dis-gds-rule.pos-type and
                 chk_dis-gds-rule.obj-type = 'маг':U and
                 chk_dis-gds-rule.obj-code = i-obj-code no-error .
           if avail chk_dis-gds-rule then next _buf_dis-gds-rule .
       end.
       find first buf_gds-obj no-lock
       where buf_gds-obj.gds-code = buf_dis-gds-rule.gds-code
         and buf_gds-obj.obj-type = 'маг':U
         and buf_gds-obj.obj-code = i-obj-code
       no-error.
       if avail buf_gds-obj and
         (( buf_dis-gds-rule.obj-type = ""      and buf_dis-gds-rule.obj-code = 0) or
          ( buf_dis-gds-rule.obj-type = 'орг':U  and buf_dis-gds-rule.obj-code = i-host-code) or
          ( buf_dis-gds-rule.obj-type = 'маг':U and buf_dis-gds-rule.obj-code = i-obj-code))
       then do:
          assign
            v-char-2 = "0,0,0,0,0,0,"
            v-is-weight = false
          .
          find buf_goods where buf_goods.gds-code = buf_dis-gds-rule.gds-code no-lock no-error.
          if avail buf_goods then do:
              find buf_units where buf_units.unit-name = buf_goods.unit-base no-lock no-error.
              if avail buf_units then do:
                  if lookup ('вес':U, buf_units.type) > 0 then do:
                      assign
                        v-char-2    = "0,0,0,2,0,0,"
                        v-is-weight = true
                      .
                  end.
              end.
          end.
          _bdr-attr:
    for each  buf_dis-gds-rule-attr WHERE
             buf_dis-gds-rule-attr.gds-code = buf_dis-gds-rule.gds-code
         AND buf_dis-gds-rule-attr.obj-type = buf_dis-gds-rule.obj-type
         AND buf_dis-gds-rule-attr.obj-code = buf_dis-gds-rule.obj-code
         AND buf_dis-gds-rule-attr.pos-type = buf_dis-gds-rule.pos-type
         AND buf_dis-gds-rule-attr.discnt-role = buf_dis-gds-rule.discnt-role
         and buf_dis-gds-rule-attr.nonunique = buf_dis-gds-rule.nonunique
                  :
           assign
     v-upd = entry(2,buf_dis-gds-rule-attr.attr-value,",")
             v-ean13 = entry(1,buf_dis-gds-rule-attr.attr-value,",")
     .
           if v-is-weight and length(v-ean13) = 5 then do:
               def var ncrsc-pfx as char no-undo init "23":U .
               def var ncrsc-frmt as char no-undo init "EAN13" .
               assign v-tmpchar = "" .
define variable vss-include-info143 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str143  as character no-undo.
  define variable tmp-num143  as character no-undo.
  define variable i143        as integer   no-undo.
  define variable sum143      as integer   no-undo.
  define variable len-code143 as integer   no-undo.
  define variable varcont143  as logical   initial yes no-undo.
  CASE ncrsc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str143 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str143 = string( decimal(string(integer( v-ean13 ), '99999':U) + '00000':U), "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " ncrsc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont143 = yes then do:
    if integer( substring( tmp-str143, 1, length( ncrsc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U)
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        v-tmpchar = ncrsc-pfx + substring( tmp-str143, length( ncrsc-pfx ) + 1, length( tmp-str143 ) - length( ncrsc-pfx ) )
        len-code143    = length( v-tmpchar )
      .
      define variable v-sum-char143 as character no-undo .
      assign
        sum143 = 0
      .
      do i143 = 1 to len-code143 by 2
      :
        assign
          v-sum-char143 = substr(v-tmpchar, len-code143 - i143 + 1, 1)
        .
        if v-sum-char143 < "0"
        or v-sum-char143 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum143 = sum143 + integer(v-sum-char143)
        .
      end.
      if varcont143 = yes then do:
        assign
          sum143 = sum143 * 3
        .
        do i143 = 2 to len-code143 by 2
        :
          assign
            v-sum-char143 = substr(v-tmpchar, len-code143 - i143 + 1, 1)
          .
          if v-sum-char143 < "0"
          or v-sum-char143 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " decimal(string(integer( v-ean13 ), '99999':U) + '00000':U) skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum143 = sum143 + integer(v-sum-char143)
          .
        end.
        if varcont143 = yes then do:
           if sum143 mod 10 = 0 then do:
             assign
               v-tmpchar = v-tmpchar + '0'
             .
           end.
           else do:
             assign
               v-tmpchar = v-tmpchar + string(10 - sum143 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
               if not v-tmpchar = "":U then assign v-ean13 = v-tmpchar .
           end.
           if v-ean13 begins "20" and length(v-ean13) = 13 then next _bdr-attr .
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-gds-rule-attr.attr-code v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-2
      trim(string(buf_dis-rule.doc-qnty,'>>>>9')) v-char-delim-1
      v-char-3
            v-ean13 v-char-delim-2
      v-char-4
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
            v-ean13 v-char-delim-2
      v-char-6 v-char-7 skip.
    end.
   end.
 end.
 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 90
                   and buf_dis-thbj-rule.pos-type = 'NCR-AS@R':U,
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = 'орг':U and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = 'маг':U and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "3,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "9,0,0,"
      trim(string(buf_dis-rule.tot-sum * 100,">>>>>>>>>9")) v-char-delim-1
      v-char-3
      v-char-41
      trim(string(buf_dis-rule.discnt-value,">>>9")) v-char-delim-1
      v-char-5
       v-char-delim-2
      v-char-61 v-char-71 skip.
   end.
 end.
 for each buf_dis-thbj-rule no-lock where buf_dis-thbj-rule.templ-rl-root = 92
                   and buf_dis-thbj-rule.pos-type = 'NCR-AS@R':U,
    first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = buf_dis-thbj-rule.rule-num
    and buf_dis-rule.sts = integer('0':U),
    first buf_dis-time-rule no-lock
      where buf_dis-time-rule.time-rule-num = buf_dis-rule.time-rule-num
        and buf_dis-time-rule.date-to >= v-today
      :
   if (buf_dis-thbj-rule.obj-type = "" and
       buf_dis-thbj-rule.obj-code = 0) or
      (buf_dis-thbj-rule.obj-type = 'орг':U and
       buf_dis-thbj-rule.obj-code = i-host-code) or
      (buf_dis-thbj-rule.obj-type = 'маг':U and
       buf_dis-thbj-rule.obj-code = i-obj-code)
   then
   do:
     put stream IBMStream unformatted v-ver v-char-delim-1 v-upd v-char-delim-1
      buf_dis-rule.key#_one v-char-delim-1
      "4,MAPKA,"
      entry(1,iso-date(buf_dis-time-rule.date-from),"-") + entry(2,iso-date(buf_dis-time-rule.date-from),"-") + entry(3,iso-date(buf_dis-time-rule.date-from),"-") v-char-delim-1
      "0" v-char-delim-1
      entry(1,iso-date(buf_dis-time-rule.date-to),"-") + entry(2,iso-date(buf_dis-time-rule.date-to),"-") + entry(3,iso-date(buf_dis-time-rule.date-to),"-") v-char-delim-1
      "0" v-char-delim-1
      v-char-1
      v-char-21
      "4,1,0,"
      "1" v-char-delim-1
      v-char-3
      v-char-42
      "0" v-char-delim-1
      v-char-5
       v-char-delim-2
      v-char-62 v-char-72 v-char-8 v-char-9 skip.
   end.
 end.
 output stream IBMStream close .
end procedure .
procedure get-thbj-rule :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer no-undo .
define input  parameter p-host-code as integer no-undo .
define input  parameter p-discnt-role as character no-undo .
define input  parameter p-pos-type as character   no-undo .
define input  parameter p-reg-list as character no-undo .
define parameter buffer  buf_dis-thbj-rule for ub.dis-thbj-rule.
define variable v-region-type as character no-undo .
define variable v-region-code as integer   no-undo .
define variable v-region-host as integer   no-undo .
define variable v-region-ii as integer   no-undo .
_v-region-ii:
do v-region-ii = 1 to 3:
  if lookup(string(v-region-ii), p-reg-list) = 0 then next _v-region-ii.
  case v-region-ii:
    when 1 then do:
      assign
      v-region-type = p-obj-type
      v-region-code = p-obj-code
      v-region-host = p-host-code
      .
    end.
    when 2 then do:
      assign
      v-region-type = ''
      v-region-code = 0
      v-region-host = p-host-code
      .
    end.
    when 3 then do:
      assign
      v-region-type = ''
      v-region-code = 0
      v-region-host = 0
      .
    end.
  end case.
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = v-region-type
        and buf_dis-thbj-rule.obj-code = v-region-code
        and buf_dis-thbj-rule.host-code = v-region-host
        and buf_dis-thbj-rule.discnt-role = p-discnt-role
        and buf_dis-thbj-rule.pos-type = p-pos-type no-error.
  if available buf_dis-thbj-rule then do:
    find first buf_dis-rule no-lock where
              buf_Dis-rule.rule-num = buf_dis-thbj-rule.templ-rl-root no-error.
    if available buf_dis-rule then do:
      run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num
                                            , (buf_Dis-rule.time-rule-num >= 0)) no-error .
    end.
    leave _v-region-ii.
  end.
end.
END PROCEDURE.
