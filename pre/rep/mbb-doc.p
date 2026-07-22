block-level on error undo, throw.
define input  parameter parparentproc   as handle no-undo.
define input  parameter p-recid         as recid no-undo .
define input  parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: mbb-doc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/mbb-doc.p $":U .
define variable vss-description as character no-undo init "Вывод в список кодов по документу".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def  new shared  temp-table scnblist no-undo like ub.goods
  field b-code as integer
  field b-str  as character
  field f-name like ub.gds-prt.f-name
  field bc-cli-base-rate like ub.bar-code.cli-base-rate
  field bc-cr-db-num     like ub.bar-code.cr-db-num
  field in-code       like ub.bar-code.in-code
  field node-code     like ub.bar-code.node-code
  field part-code     like ub.bar-code.part-code
  field stts_         like ub.bar-code.stts_
  field bc-unit-cli      like ub.bar-code.unit-cli
  field bc-on-type    like ub.prod-bc.bc-on-type
  field bc-on         like ub.prod-bc.bc-on
  field pbc-cr-db-num     like ub.prod-bc.cr-db-num
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field loc-ean as logical
  index pi  is primary unique b-code b-str
  index art artic prod-type prod-code
  index code gds-code
  index oi order-num
  index ibc-on-type bc-on-type
  index iprt
  gds-code
  node-code
  part-code
  in-code
  unit-cli
  b-str
  index iprt2
  gds-code
  node-code
  unit-cli
  part-code
  in-code
  b-str
  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   new shared   temp-table scnblist-hist no-undo
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str2  as character no-undo.
  define variable tmp-num2  as character no-undo.
  define variable i2        as integer   no-undo.
  define variable sum2      as integer   no-undo.
  define variable len-code2 as integer   no-undo.
  define variable varcont2  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str2 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont2 = yes then do:
    if integer( substring( tmp-str2, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str2, length( bc-pfx ) + 1, length( tmp-str2 ) - length( bc-pfx ) )
        len-code2    = length( full-b-code )
      .
      define variable v-sum-char2 as character no-undo .
      assign
        sum2 = 0
      .
      do i2 = 1 to len-code2 by 2
      :
        assign
          v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
        .
        if v-sum-char2 < "0"
        or v-sum-char2 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum2 = sum2 + integer(v-sum-char2)
        .
      end.
      if varcont2 = yes then do:
        assign
          sum2 = sum2 * 3
        .
        do i2 = 2 to len-code2 by 2
        :
          assign
            v-sum-char2 = substr(full-b-code, len-code2 - i2 + 1, 1)
          .
          if v-sum-char2 < "0"
          or v-sum-char2 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum2 = sum2 + integer(v-sum-char2)
          .
        end.
        if varcont2 = yes then do:
           if sum2 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum2 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define buffer buf_trn-doc for ub.trn-doc  .
define variable v-obj-type  as character no-undo .
define variable v-obj-code  as integer   no-undo .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_gds-obj  for ub.gds-obj  .
define buffer buf_parts for ub.parts  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_prod-bc for ub.prod-bc  .
define buffer buf_goods for ub.goods  .
define buffer buf_gds-dtl for ub.gds-dtl  .
define variable  lns-cnt as integer   no-undo .
define variable  line-rec as recid no-undo .
define variable v-ean as character no-undo .
define variable v-root-node as integer   no-undo .
define variable is-prt as logical   no-undo .
define variable v-value as character no-undo .
define variable v-type  as character no-undo .
define variable v-new-qnty as logical   no-undo .
define variable v-new-qnty1 as integer   no-undo .
do
on error undo, return error return-value
:
 find first buf_trn-doc no-lock where recid(buf_trn-doc)  = p-recid .
  empty temp-table scnblist.
  v-obj-type = buf_trn-doc.obj-type.
  v-obj-code = buf_trn-doc.obj-code.
  for each buf_doc-line no-lock where
            buf_doc-line.doc-code = buf_trn-doc.doc-code,
            first buf_gds-obj no-lock where
                  buf_gds-obj.artic     =  buf_doc-line.artic and
                  buf_gds-obj.prod-type =  buf_doc-line.prod-type and
                  buf_gds-obj.prod-code =  buf_doc-line.prod-code and
                  buf_gds-obj.obj-type  =  buf_trn-doc.obj-type and
                  buf_gds-obj.obj-code  =  buf_trn-doc.obj-code ,
            first buf_goods no-lock where
                  buf_goods.artic     =  buf_doc-line.artic and
                  buf_goods.prod-type =  buf_doc-line.prod-type and
                  buf_goods.prod-code =  buf_doc-line.prod-code
                  :
          run  gdsoattr-value in this-procedure
            ( input 'doc-tickets':U ,
              input buf_goods.gds-code    ,
              input buf_gds-obj.obj-type  ,
              input buf_gds-obj.obj-code  ,
              output v-value       ,
              output v-type
              ) no-error .
           v-new-qnty = true  .
           if v-value = "fact-qnty"  or
              v-value = ""  or
              v-value = ?
           then do:
             v-new-qnty = false .
           end.
           else do:
              if v-value begins "val" then v-value = substring(v-value,4).
              v-new-qnty1 = int(v-value) no-error .
              if v-value begins "quest" then v-new-qnty1 = ?.
           end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  )  .
      find first ub.gds-prt where ub.gds-prt.node-code = v-root-node no-error .
      if ub.gds-prt.node-name <> '_Пустая шкала':U  then is-prt  = true .
      else is-prt = false   .
     if buf_gds-obj.cash-parts then do:
        for each buf_parts no-lock where
                 buf_parts.out-code  =  buf_trn-doc.doc-code and
                 buf_parts.artic     =  buf_doc-line.artic and
                 buf_parts.prod-type =  buf_doc-line.prod-type and
                 buf_parts.prod-code =  buf_doc-line.prod-code and
                 buf_parts.obj-type  =  buf_trn-doc.obj-type and
                 buf_parts.obj-code  =  buf_trn-doc.obj-code :
                 find first buf_bar-code no-lock where
                            buf_bar-code.gds-code  = buf_goods.gds-code  and
                            buf_bar-code.part-code = buf_parts.part-code and
                            buf_bar-code.in-code   = buf_parts.in-code and
                            buf_bar-code.unit-cli   = buf_goods.unit-base
                            no-error .
                  if error-status :error then return error "Бар-код не создан. Закройте документ!" .
                 run gen-bc in this-procedure (input buf_bar-code.b-code , output v-ean) no-error .
                 find first buf_prod-bc no-lock where
                            buf_prod-bc.b-code = buf_bar-code.b-code  no-error .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first scnblist
  where scnblist.gds-code = buf_bar-code.gds-code
    and scnblist.b-code   = buf_bar-code.b-code
    and scnblist.b-str    = v-ean
  no-error .
if available scnblist then do:
  assign
    scnblist.to-del = no
  .
end.
else do:
  define variable v-last5 as integer no-undo .
  find last scnblist use-index oi no-error.
  if available scnblist then do:
    v-last5 = scnblist.order-num .
  end.
  else do:
    v-last5 = 0 .
  end.
  create scnblist .
  buffer-copy buf_goods to scnblist
  assign
    scnblist.to-del = no
    scnblist.order-num = v-last5 + 1
    scnblist.b-code = buf_bar-code.b-code
    scnblist.bc-cli-base-rate = buf_bar-code.cli-base-rate
    scnblist.bc-cr-db-num     = buf_bar-code.cr-db-num
    scnblist.in-code       = buf_bar-code.in-code
    scnblist.node-code     = buf_bar-code.node-code
    scnblist.part-code     = buf_bar-code.part-code
    scnblist.stts_         = buf_bar-code.stts_
    scnblist.bc-unit-cli   = buf_bar-code.unit-cli
    scnblist.b-str         = v-ean
    scnblist.f-name        = ''
    scnblist.loc-ean       = true
    .
    if available buf_prod-bc
    then
    assign
    scnblist.bc-on-type    = buf_prod-bc.bc-on-type
    scnblist.bc-on         = buf_prod-bc.bc-on
    scnblist.pbc-cr-db-num = buf_prod-bc.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (scnblist)
  .
end.
                scnblist.qnty = buf_parts.fact-qnty .
                if v-new-qnty then scnblist.qnty = v-new-qnty1 .
        end.
     end.
     else do:
        if is-prt = true then do:
           for each buf_gds-dtl no-lock where
                 buf_gds-dtl.doc-code  =  buf_trn-doc.doc-code and
                 buf_gds-dtl.artic     =  buf_doc-line.artic and
                 buf_gds-dtl.prod-type =  buf_doc-line.prod-type and
                 buf_gds-dtl.prod-code =  buf_doc-line.prod-code :
                 find first buf_bar-code no-lock where
                            buf_bar-code.gds-code  = buf_goods.gds-code  and
                            buf_bar-code.node-code = buf_gds-dtl.prt-code and
                            buf_bar-code.part-code = "" and
                            buf_bar-code.in-code   = "" and
                            buf_bar-code.unit-cli   = buf_goods.unit-base
                            no-error .
                 if error-status :error then return error "Бар-код не создан. Закройте документ!" .
                 run gen-bc in this-procedure (input buf_bar-code.b-code , output v-ean) no-error .
                 find first buf_prod-bc no-lock where
                            buf_prod-bc.b-code = buf_bar-code.b-code  no-error .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first scnblist
  where scnblist.gds-code = buf_bar-code.gds-code
    and scnblist.b-code   = buf_bar-code.b-code
    and scnblist.b-str    = v-ean
  no-error .
if available scnblist then do:
  assign
    scnblist.to-del = no
  .
end.
else do:
  define variable v-last6 as integer no-undo .
  find last scnblist use-index oi no-error.
  if available scnblist then do:
    v-last6 = scnblist.order-num .
  end.
  else do:
    v-last6 = 0 .
  end.
  create scnblist .
  buffer-copy buf_goods to scnblist
  assign
    scnblist.to-del = no
    scnblist.order-num = v-last6 + 1
    scnblist.b-code = buf_bar-code.b-code
    scnblist.bc-cli-base-rate = buf_bar-code.cli-base-rate
    scnblist.bc-cr-db-num     = buf_bar-code.cr-db-num
    scnblist.in-code       = buf_bar-code.in-code
    scnblist.node-code     = buf_bar-code.node-code
    scnblist.part-code     = buf_bar-code.part-code
    scnblist.stts_         = buf_bar-code.stts_
    scnblist.bc-unit-cli   = buf_bar-code.unit-cli
    scnblist.b-str         = v-ean
    scnblist.f-name        = ''
    scnblist.loc-ean       = true
    .
    if available buf_prod-bc
    then
    assign
    scnblist.bc-on-type    = buf_prod-bc.bc-on-type
    scnblist.bc-on         = buf_prod-bc.bc-on
    scnblist.pbc-cr-db-num = buf_prod-bc.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (scnblist)
  .
end.
              scnblist.qnty = buf_gds-dtl.fact-qnty.
              if v-new-qnty then scnblist.qnty = v-new-qnty1 .
            end.
        end.
         else do:
                 find first buf_bar-code no-lock where
                            buf_bar-code.gds-code  = buf_goods.gds-code  and
                            buf_bar-code.part-code = "" and
                            buf_bar-code.in-code   = "" and
                            buf_bar-code.unit-cli   = buf_goods.unit-base
                            no-error .
                 if error-status :error then return error "Бар-код не создан. Закройте документ!" .
                 run gen-bc in this-procedure (input buf_bar-code.b-code , output v-ean) no-error .
                 find first buf_prod-bc no-lock where
                            buf_prod-bc.b-code = buf_bar-code.b-code  no-error .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find first scnblist
  where scnblist.gds-code = buf_bar-code.gds-code
    and scnblist.b-code   = buf_bar-code.b-code
    and scnblist.b-str    = v-ean
  no-error .
if available scnblist then do:
  assign
    scnblist.to-del = no
  .
end.
else do:
  define variable v-last7 as integer no-undo .
  find last scnblist use-index oi no-error.
  if available scnblist then do:
    v-last7 = scnblist.order-num .
  end.
  else do:
    v-last7 = 0 .
  end.
  create scnblist .
  buffer-copy buf_goods to scnblist
  assign
    scnblist.to-del = no
    scnblist.order-num = v-last7 + 1
    scnblist.b-code = buf_bar-code.b-code
    scnblist.bc-cli-base-rate = buf_bar-code.cli-base-rate
    scnblist.bc-cr-db-num     = buf_bar-code.cr-db-num
    scnblist.in-code       = buf_bar-code.in-code
    scnblist.node-code     = buf_bar-code.node-code
    scnblist.part-code     = buf_bar-code.part-code
    scnblist.stts_         = buf_bar-code.stts_
    scnblist.bc-unit-cli   = buf_bar-code.unit-cli
    scnblist.b-str         = v-ean
    scnblist.f-name        = ''
    scnblist.loc-ean       = true
    .
    if available buf_prod-bc
    then
    assign
    scnblist.bc-on-type    = buf_prod-bc.bc-on-type
    scnblist.bc-on         = buf_prod-bc.bc-on
    scnblist.pbc-cr-db-num = buf_prod-bc.cr-db-num
    .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (scnblist)
  .
end.
              scnblist.qnty = buf_doc-line.fact-qnty.
              if v-new-qnty then scnblist.qnty = v-new-qnty1 .
           end.
     end.
    end.
    run str/scnblist.w (
         input parparentproc
        ,input v-obj-type
        ,input v-obj-code
        ,input ''
        ).
end.
