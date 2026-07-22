block-level on error undo, throw.
define parameter buffer buf-par_goods for ub.goods.
define parameter buffer buf-par_bar-code       for ub.bar-code.
define parameter buffer buf-par_scales-gds     for ub.scales-gds.
define input parameter p-obj-type      like ub.clients.obj-type no-undo .
define input parameter p-obj-code      like ub.clients.obj-code no-undo .
define input parameter Action          as character no-undo .
define input parameter rootnode_code   like ub.gds-prt.node-code no-undo .
define input parameter TickOnw         as logical no-undo .
define input parameter TickOnN         as logical no-undo .
define input parameter QntyType        as character no-undo .
define input parameter PriceType       as character no-undo .
define input parameter scaleprice      as decimal no-undo init 0.
define input parameter nakl-qnty like ub.gds-dtl.fact-qnty no-undo.
define input parameter list-qnty like ub.gds-dtl.fact-qnty no-undo.
define input parameter pr-doc-rubl like ub.price-list.price-sale no-undo.
define input parameter pr-doc-rb like ub.price-list.price-sale no-undo.
define input parameter pr-doc-rubl-old like ub.price-list.price-sale no-undo.
define input parameter pr-doc-rb-old like ub.price-list.price-sale no-undo.
define input parameter v-fact-order like ub.trn-doc.fact-order     no-undo.
define input parameter ListProdBc       as character no-undo .
define input parameter curr-rate        as decimal no-undo .
define input parameter TickPS           as character no-undo .
define input parameter dflt-cd          as character no-undo .
define input parameter how-pcnt-kat     as character no-undo .
define input-output parameter b-count   as integer no-undo .
define input parameter p-part-code      as character no-undo .
define input parameter p-doc-code       as character no-undo .
define input parameter p-promo-code     as character no-undo .
define input parameter p-ActionId       as int64     no-undo .
define input parameter p-db-num as integer no-undo .
define variable vss-revision    as character no-undo init "$Revision: 487c9fe350a2, 3360, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2023/05/19 13:37:11 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ticket.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/ticket.p $":U .
define variable vss-description as character no-undo init "Тело печати ценников (этикеток). Печать одного ценника (этикетки).".
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
def   shared var bc-frmt as character no-undo .
def   shared var bc-pfx  as character no-undo .
def var bc-par-type as character no-undo .
PROCEDURE gen-bc:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str0  as character no-undo.
  define variable tmp-num0  as character no-undo.
  define variable i0        as integer   no-undo.
  define variable sum0      as integer   no-undo.
  define variable len-code0 as integer   no-undo.
  define variable varcont0  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str0 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str0 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont0 = yes then do:
    if integer( substring( tmp-str0, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str0, length( bc-pfx ) + 1, length( tmp-str0 ) - length( bc-pfx ) )
        len-code0    = length( full-b-code )
      .
      define variable v-sum-char0 as character no-undo .
      assign
        sum0 = 0
      .
      do i0 = 1 to len-code0 by 2
      :
        assign
          v-sum-char0 = substr(full-b-code, len-code0 - i0 + 1, 1)
        .
        if v-sum-char0 < "0"
        or v-sum-char0 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum0 = sum0 + integer(v-sum-char0)
        .
      end.
      if varcont0 = yes then do:
        assign
          sum0 = sum0 * 3
        .
        do i0 = 2 to len-code0 by 2
        :
          assign
            v-sum-char0 = substr(full-b-code, len-code0 - i0 + 1, 1)
          .
          if v-sum-char0 < "0"
          or v-sum-char0 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum0 = sum0 + integer(v-sum-char0)
          .
        end.
        if varcont0 = yes then do:
           if sum0 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum0 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
def   shared var pl-frmt as character no-undo .
def   shared var pl-pfx  as character no-undo .
def var pl-par-type as character no-undo .
PROCEDURE gen-pl:
  def input  parameter internal-b-code like ub.bar-code.b-code no-undo .
  def output parameter full-b-code     as character init ""    no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str1  as character no-undo.
  define variable tmp-num1  as character no-undo.
  define variable i1        as integer   no-undo.
  define variable sum1      as integer   no-undo.
  define variable len-code1 as integer   no-undo.
  define variable varcont1  as logical   initial yes no-undo.
  CASE pl-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str1 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str1 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " pl-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont1 = yes then do:
    if integer( substring( tmp-str1, 1, length( pl-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = pl-pfx + substring( tmp-str1, length( pl-pfx ) + 1, length( tmp-str1 ) - length( pl-pfx ) )
        len-code1    = length( full-b-code )
      .
      define variable v-sum-char1 as character no-undo .
      assign
        sum1 = 0
      .
      do i1 = 1 to len-code1 by 2
      :
        assign
          v-sum-char1 = substr(full-b-code, len-code1 - i1 + 1, 1)
        .
        if v-sum-char1 < "0"
        or v-sum-char1 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum1 = sum1 + integer(v-sum-char1)
        .
      end.
      if varcont1 = yes then do:
        assign
          sum1 = sum1 * 3
        .
        do i1 = 2 to len-code1 by 2
        :
          assign
            v-sum-char1 = substr(full-b-code, len-code1 - i1 + 1, 1)
          .
          if v-sum-char1 < "0"
          or v-sum-char1 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum1 = sum1 + integer(v-sum-char1)
          .
        end.
        if varcont1 = yes then do:
           if sum1 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum1 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
END PROCEDURE.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure dr-katp :
define input parameter p-gds-code as integer no-undo .
define input parameter p-b-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-dflt-cd as character no-undo .
define input parameter p-base-price as decimal no-undo .
define input parameter p-how-kat-disc as character no-undo .
define input parameter p-fact-order as decimal no-undo .
define output parameter p-netto-price as decimal no-undo .
define variable v-d-value as decimal no-undo .
define variable v-type as character no-undo .
define variable v-value-type as integer no-undo .
define variable v-discnt-type as integer no-undo .
define variable v-rule-num as integer no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_Dis-rule for ub.dis-rule.
define buffer term_dis-rule for ub.dis-rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info5, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info5 )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info5 )
:
  if p-base-price = ?
  or p-base-price  <= 0
  then do:
    undo main-block, return error substitute("Неверно задана базовая цена (&1) для товара &2 на &3&4"
                                  , p-base-price
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code).
  end.
  case entry(1, how-pcnt-kat, "="):
    when 'pcnt-kat':U then do:
  find first  buf_dis-gds-rule No-LOCK  where
            buf_dis-gds-rule.gds-code = p-gds-code
        AND  buf_dis-gds-rule.obj-code = p-obj-code
        AND  buf_dis-gds-rule.obj-type = p-obj-type
        and  buf_dis-gds-rule.pos-type = p-dflt-cd
        and  buf_dis-gds-rule.discnt-role = 'pcnt-kat':U
        no-error .
      if available buf_dis-gds-rule
      and buf_dis-gds-rule.nonunique <> ''
      and buf_dis-gds-rule.nonunique <> string(p-b-code) then do:
        find first  buf_dis-gds-rule No-LOCK  where
                  buf_dis-gds-rule.gds-code = p-gds-code
              AND  buf_dis-gds-rule.obj-code = p-obj-code
              AND  buf_dis-gds-rule.obj-type = p-obj-type
              and  buf_dis-gds-rule.pos-type = p-dflt-cd
              and  buf_dis-gds-rule.discnt-role = 'pcnt-kat':U
              and  buf_dis-gds-rule.nonunique = string(p-b-code)
              no-error .
      end.
  if not available buf_Dis-gds-rule then do:
    p-netto-price = p-base-price.
    return.
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num no-error.
  if not available buf_dis-rule
  or not (buf_dis-rule.obj-type = p-obj-type
          and
          buf_dis-rule.obj-code = p-obj-code)
  then do:
     undo main-block, return error substitute("Не найдено правило категорийной скидки &1 для товара &2 на &3&4 с местом действия &5"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                  , p-dflt-cd
                                                                    ).
  end.
  if buf_dis-rule.templ-rl-root = 34
  then do:
     undo main-block, return error substitute("Нельзя найти категорийную скидку - правило категорийной скидки &1 для товара &2 на &3&4 имеет шаблон &5"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                  , buf_dis-rule.templ-rl-root
                                                                    ).
  end.
  if buf_dis-rule.is-term = no then do:
    find  term_dis-rule no-lock where
                    term_dis-rule.upper-rule-num = buf_dis-rule.rule-num no-error.
    if not available term_dis-rule
    or ambiguous term_dis-rule then do:
     undo main-block, return error substitute("Не удается однозначно определить тип и значение категорийной скидки (правило &1) для товара &2 на &3&4"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                                                    ).
    end.
    assign
    v-value-type = term_Dis-rule.value-type
    v-d-value = term_dis-rule.discnt-value
    v-discnt-type = term_dis-rule.discnt-type
    .
  end.
  else do:
    assign
    v-value-type = buf_Dis-rule.value-type
    v-d-value = buf_dis-rule.discnt-value
    v-discnt-type = buf_Dis-rule.discnt-type
    .
  end.
    if v-discnt-type <> 12 then do:
     undo main-block, return error substitute("Нельзя найти категорийную скидку - правило категорийной скидки &1 для товара &2 на &3&4 привязано к расписанию"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                                                    ).
  end.
  case v-value-type:
    when integer('2':U) then do:
      assign
      p-netto-price = p-base-price - v-d-value
      .
    end.
    when integer('1':U) then do:
      assign
      p-netto-price = p-base-price * (1 - v-d-value / 100)
      .
    end.
    when integer('3':U) then do:
      assign
      p-netto-price = v-d-value
      .
    end.
  end.
    end.
    when 'pcnt-kat-pdf':U then do:
      if num-entries(how-pcnt-kat, "=") > 1
      and integer(entry(2, how-pcnt-kat, "=")) > 0 then do:
      v-rule-num = integer(entry(2, how-pcnt-kat, "=")).
      for each buf_dis-rule no-lock where
            buf_dis-rule.rule-num = v-rule-num
        or buf_dis-rule.upper-rule-num = v-rule-num  :
        if buf_dis-rule.is-term then do:
          run mpl-tpl-auto in this-procedure ( input p-b-code
                                              ,input p-obj-type
                                              ,input p-obj-code
                                              ,input integer(entry(1, buf_dis-rule.charkey_one,"-"))
                                              ,input integer(entry(2, buf_dis-rule.charkey_one,"-"))
                                              ,input p-fact-order
                                              ,output v-disc-price-sale
                                              ,output v-pdf-id
                                              ,output v-pdf-db-num ) no-error.
          if error-status:error
          or v-disc-price-sale = 0
          or v-disc-price-sale = ?
          then do:
            p-netto-price = p-base-price.
          end.
          else do:
            p-netto-price = v-disc-price-sale.
          end.
          leave.
        end.
        end.
      end.
    end .
  end case.
end.
end procedure.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output to-day
  )  .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info19 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
function nutro_get-carbohydrate returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-carbohydrate as decimal   no-undo .
  run nutro_proc-get-carbohydrate in this-procedure ( input p-artic
                                                    , input p-prod-type
                                                    , input p-prod-code
                                                    , input p-obj-type
                                                    , input p-obj-code
                                                    , output v-carbohydrate
                                                    ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-carbohydrate = ?
    .
  end.
  return v-carbohydrate.
end function.
function nutro_get-fat returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-fat as decimal   no-undo .
  run nutro_proc-get-fat in this-procedure ( input p-artic
                                           , input p-prod-type
                                           , input p-prod-code
                                           , input p-obj-type
                                           , input p-obj-code
                                           , output v-fat
                                           ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-fat = ?
    .
  end.
  return v-fat.
end function.
function nutro_get-protein returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-protein as decimal   no-undo .
  run nutro_proc-get-protein in this-procedure ( input p-artic
                                               , input p-prod-type
                                               , input p-prod-code
                                               , input p-obj-type
                                               , input p-obj-code
                                               , output v-protein
                                               ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-protein = ?
    .
  end.
  return v-protein.
end function.
function nutro_get-calories returns decimal
  ( input p-artic     as character
  , input p-prod-type as character
  , input p-prod-code as integer
  , input p-obj-type  as character
  , input p-obj-code  as integer
  )
:
  define variable v-calories as decimal   no-undo .
  run nutro_proc-get-calories in this-procedure ( input  p-artic
                                                , input  p-prod-type
                                                , input  p-prod-code
                                                , input p-obj-type
                                                , input p-obj-code
                                                , output v-calories
                                                ) no-error .
  if error-status :error = yes
  then do:
    assign
      v-calories = ?
    .
  end.
  return v-calories.
end function.
procedure nutro_proc-get-carbohydrate :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-carbohydrate  as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value   as character no-undo .
  define variable v-attr-type    as character no-undo .
  define variable v-calories     as decimal   no-undo .
  define variable v-protein      as decimal   no-undo .
  define variable v-carbohydrate as decimal   no-undo .
  define variable v-fat          as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-carbohydrate = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-carbohydrate = v-carbohydrate
  .
end.
end procedure.
procedure nutro_proc-get-fat :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-fat           as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-fat = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-fat = v-fat
  .
end.
end procedure.
procedure nutro_proc-get-protein :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-protein       as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-protein = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-protein = v-protein
  .
end.
end procedure.
procedure nutro_proc-get-calories :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-calories      as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-calories      as decimal   no-undo .
  define variable v-protein       as decimal   no-undo .
  define variable v-carbohydrate  as decimal   no-undo .
  define variable v-fat           as decimal   no-undo .
do
on error undo, return error return-value
:
  assign
    p-calories = ?
  .
  run nutro_get-nutrition-info in this-procedure ( input  p-artic
                                                 , input  p-prod-type
                                                 , input  p-prod-code
                                                 , input  p-obj-type
                                                 , input  p-obj-code
                                                 , output v-calories
                                                 , output v-protein
                                                 , output v-carbohydrate
                                                 , output v-fat
                                                 ) no-error .
  if error-status :error = yes
  then do:
    return .
  end.
  assign
    p-calories = v-calories
  .
end.
end procedure.
procedure nutro_get-nutrition-info :
  define input  parameter p-artic         as character no-undo .
  define input  parameter p-prod-type     as character no-undo .
  define input  parameter p-prod-code     as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-calories      as decimal   no-undo .
  define output parameter p-protein       as decimal   no-undo .
  define output parameter p-carbohydrate  as decimal   no-undo .
  define output parameter p-fat           as decimal   no-undo .
  define buffer buf_goods    for ub.goods .
  define variable v-attr-value    as character no-undo .
  define variable v-attr-type     as character no-undo .
  define variable v-attr-code     as character no-undo .
  define variable v-exist         as logical   no-undo .
  define variable v-is-global     as logical   no-undo .
  define variable v-nutro-value   as decimal   no-undo .
  define buffer buf_fbr-gds-obj  for ub.fbr-gds-obj.
  define buffer buf_recipe       for ub.recipe.
do
on error undo, return error return-value
:
  assign
    p-carbohydrate  = ?
    p-fat           = ?
    p-protein       = ?
    p-calories      = ?
  .
  find first buf_goods no-lock
    where buf_goods.artic     = p-artic
      and buf_goods.prod-type = p-prod-type
      and buf_goods.prod-code = p-prod-code
  no-error .
  if not available buf_goods
  then do:
    return .
  end.
  assign
    v-is-global = yes
  .
  find first buf_fbr-gds-obj no-lock
    where buf_fbr-gds-obj.obj-type = p-obj-type
      and buf_fbr-gds-obj.obj-code = p-obj-code
      and buf_fbr-gds-obj.gds-code = buf_goods.gds-code
  no-error .
  if available buf_fbr-gds-obj
  then do:
    if  buf_fbr-gds-obj.is-semi-finished or
        buf_fbr-gds-obj.is-menu
    then do:
      assign
        v-is-global = no
      .
      find first buf_recipe no-lock
        where buf_recipe.recipe-code = buf_fbr-gds-obj.default-recipe-code
      no-error .
      if available buf_recipe
      then do:
        assign
          v-is-global = ( buf_recipe.host-code = 0    ) and
                        ( buf_recipe.obj-type  = "":U ) and
                        ( buf_recipe.obj-code  = 0    )
        .
      end.
    end.
  end.
  if v-is-global = yes
  then do:
    assign
      v-attr-code = 'calories':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-calories  = v-nutro-value
      v-attr-code = 'carbohydrate':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-carbohydrate  = v-nutro-value
      v-attr-code     = 'fat':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-fat       = v-nutro-value
      v-attr-code = 'protein':U
    .
    assign                       v-nutro-value = ?                     .                     run gds-attr-exist in this-procedure ( input  buf_goods.gds-code                                                          , input  v-attr-code                                                          , output v-exist                                                          ) no-error .                     if error-status :error = yes or                         v-exist = no                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     else do:                       run gds-attr-value in this-procedure ( input  buf_goods.gds-code                                                           , input  v-attr-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                       if error-status :error                       then do:                         assign                           v-nutro-value = ?                         .                       end.                       assign                         v-nutro-value = decimal( v-attr-value )                       no-error .                       if error-status :error = yes                       then do:                         assign                           v-nutro-value = ?                         .                       end.                     end.
    assign
      p-protein = v-nutro-value
    .
  end.
  else do:
    assign
      v-attr-code = 'calories-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-calories  = v-nutro-value
      v-attr-code = 'carbohydrate-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-carbohydrate  = v-nutro-value
      v-attr-code     = 'fat-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-fat       = v-nutro-value
      v-attr-code = 'protein-o':U
    .
    assign                      v-nutro-value = ?                    .                    run gdsoattr-exist in this-procedure ( input buf_goods.gds-code                                                         , input p-obj-type                                                         , input p-obj-code                                                         , input v-attr-code                                                         , output v-exist                                                         ) no-error .                    if error-status :error = yes or                       v-exist = no                    then do:                     assign                       v-nutro-value = ?                     .                    end.                    else do:                     run gdsoattr-value in this-procedure ( input  v-attr-code                                                           , input  buf_goods.gds-code                                                           , input  p-obj-type                                                           , input  p-obj-code                                                           , output v-attr-value                                                           , output v-attr-type                                                           ) no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                     assign                       v-nutro-value = decimal(v-attr-value)                     no-error .                     if error-status :error = yes                     then do:                       assign                         v-nutro-value = ?                       .                     end.                    end.
    assign
      p-protein = v-nutro-value
    .
  end.
end.
end procedure.
DEFINE VARIABLE gds-prt_f-name like ub.gds-prt.f-name no-undo .
DEFINE VARIABLE gds-prt_node-name like ub.gds-prt.node-name no-undo .
DEFINE VARIABLE country_name like ub.country.short-name no-undo .
DEFINE VARIABLE prod_name like ub.clients.obj-name no-undo .
DEFINE VARIABLE bar_code as character no-undo .
DEFINE VARIABLE varattr-value as character no-undo .
DEFINE VARIABLE varattr-type as character no-undo .
DEFINE VARIABLE gds-qnty like ub.gds-dtl.fact-qnty no-undo.
DEFINE VARIABLE price like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price as character no-undo.
DEFINE VARIABLE price-cd  like ub.price-list.price-sale no-undo.
DEFINE VARIABLE price-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-old as character no-undo.
DEFINE VARIABLE price-alt like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-alt as character no-undo.
DEFINE VARIABLE price-alt-one like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-alt-one as character no-undo.
DEFINE VARIABLE price-alt-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-alt-old as character no-undo.
DEFINE VARIABLE price-rb like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-rb as character no-undo.
DEFINE VARIABLE price-rb-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-rb-old as character no-undo.
DEFINE VARIABLE price-alt-rb like ub.price-list.price-sale no-undo.
DEFINE VARIABLE str-price-alt-rb as character no-undo.
DEFINE VARIABLE price-alt-rb-old like ub.price-list.price-prev no-undo.
DEFINE VARIABLE str-price-alt-rb-old as character no-undo.
DEFINE VARIABLE rt-b-code           like ub.bar-code.b-code     no-undo .
DEFINE VARIABLE rt-price-list-recid as   recid                  no-undo.
DEFINE VARIABLE rt-cli-base-rate    like ub.bar-code.cli-base-rate no-undo.
DEFINE VARIABLE v-price-list-recid  as   recid                  no-undo.
DEFINE VARIABLE v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo.
define variable v-base-code like ub.sysconf.base-code no-undo .
DEFINE buffer OurObj for ub.clients.
DEFINE buffer OurHost for ub.clients.
define buffer buf_price-list for ub.price-list.
define buffer b-root_price-list for ub.price-list.
define buffer buf_trn-doc for ub.trn-doc .
define shared Stream OutStream.
define variable v-sys-key      as character no-undo .
define variable par-type     as character no-undo .
define variable v-rb-is-base as logical no-undo .
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable v-mrtr-code as character no-undo .
define variable v-ticket-vat-pc        like ub.doc-line.vat-pc    no-undo.
define variable v-ticket-slt-pc        like ub.doc-line.slt-pc    no-undo.
define variable v-ticket-host-code     like ub.sysconf.host-code  no-undo.
define variable v-ticket-today         as date                 no-undo.
define variable v-dflt-cd as character no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
find ub.gds-grp where ub.gds-grp.node-code = buf-par_goods.grp-code no-lock.
find ub.gds-prt where ub.gds-prt.node-code = buf-par_bar-code.node-code no-lock.
if ub.gds-prt.node-code <> rootnode_code then
    assign
        gds-prt_node-name = ub.gds-prt.node-name
        gds-prt_f-name = ub.gds-prt.f-name
        .
else
    assign
        gds-prt_node-name = ""
        gds-prt_f-name = ""
        .
find first ub.country no-lock
  where ub.country.alpha1 = buf-par_goods.alpha1
  no-error.
if available ub.country then do:
  assign
    country_name = ub.country.short-name
  .
end.
else do:
  assign
    country_name = ""
  .
end.
find first ub.clients no-lock
  where ub.clients.obj-type = buf-par_goods.prod-type
    and ub.clients.obj-code = buf-par_goods.prod-code
  .
assign
  prod_name = ub.clients.obj-name
.
if available buf-par_scales-gds then do:
  find first ub.scales-gds no-lock
    where rowid( ub.scales-gds ) = rowid( buf-par_scales-gds )
    .
  release buf-par_scales-gds.
end.
else do:
  if TickOnW = true then do:
    find first ub.scales-gds no-lock
      where ub.scales-gds.b-code   = buf-par_bar-code.b-code
        and ub.scales-gds.obj-type = p-obj-type
        and ub.scales-gds.obj-code = p-obj-code
      no-error.
  end.
end.
if available ub.scales-gds then do:
  assign
      bar_code = ""
      ListProdBc = (if Action <> "PROD-BC"
                    and not (action = "LIST-bb"
                    and listprodbc <> '')
                    then "":U else ListProdBc)
      .
  FIND OurObj WHERE OurObj.obj-type = ub.scales-gds.obj-type
                AND OurObj.obj-code = ub.scales-gds.obj-code NO-LOCK.
  varattr-value = "":U.
  run gdsoattr-value in this-procedure(
                                        input 'scales-code':U
                                        ,input buf-par_bar-code.gds-code
                                        ,input OurObj.obj-type
                                        ,input OurObj.obj-code
                                        ,output varattr-value
                                        ,output varattr-type
                                        ) no-error.
  if varattr-value = "":U then do:
    message "Товар ~"" buf-par_goods.gds-name "~" (арт.: " buf-par_goods.artic " произв.:" buf-par_goods.prod-type " " buf-par_goods.prod-code ") " SKIP
            "весовой, но не имеет весового кода." SKIP
            "Ценник не может быть распечатан !"
            view-as alert-box INFORMATION TITLE "".
    NEXT.
  end.
end.
else do:
  FIND ub.units WHERE ub.units.unit-name = buf-par_bar-code.unit-cli NO-LOCK.
  if lookup('вес':U, ub.units.type) > 0
    and NOT TickOnW
  then do:
    message "Товар ~"" buf-par_goods.gds-name "~" (арт.: " buf-par_goods.artic " произв.:" buf-par_goods.prod-type " " buf-par_goods.prod-code ") "
                    "весовой." SKIP
                    "Ценник не может быть распечатан ! Воспользуйтесь справочником весов."
                    view-as alert-box INFORMATION TITLE "".
    NEXT.
  end.
  RUN gen-bc( input ( if v-sys-key = "Trg" then integer( buf-par_goods.artic ) else buf-par_bar-code.b-code ), output bar_code ).
  FIND OurObj WHERE OurObj.obj-type = p-obj-type
                AND OurObj.obj-code = p-obj-code
              NO-LOCK.
  if action <> "PROD-BC":U
  and not (action = "LIST-bb"
  and listprodbc <> '')
  then do:
    assign ListProdBc = "":U .
    _prod-bc:
    FOR EACH ub.prod-bc WHERE ub.prod-bc.b-code = buf-par_bar-code.b-code
                      AND ub.prod-bc.bc-on = TRUE
                    NO-LOCK :
      if lookup('шту':U, units.type) > 0 then do:
        l-prod-bc-pgweight = yes.
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer ub.prod-bc
  ,input  'pgweight=request':u
  ,output l-prod-bc-pgweight
  ) no-error .
        if l-prod-bc-pgweight then do:
          next _prod-bc.
        end.
      end.
        assign ListProdBc = ListProdBc + prod-bc.b-str + ",":U.
    END.
    assign
        ListProdBc = SUBSTRING( ListProdBc, 1, 200 )
        ListProdBc = RIGHT-TRIM( ListProdBc, ",":U )
        .
  end.
end.
CASE OurObj.obj-type:
    WHEN 'скл':U THEN
        do:
            FIND ub.store WHERE ub.store.obj-code = OurObj.obj-code NO-LOCK.
            FIND OurHost WHERE OurHost.obj-type = 'орг':U
                           AND OurHost.obj-code = ub.store.host-code
                         NO-LOCK.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  ub.store.host-code
  ,output v-base-code
  )  .
        end.
    WHEN 'маг':U THEN
        do:
            FIND ub.shop WHERE ub.shop.obj-code = OurObj.obj-code NO-LOCK.
            FIND OurHost WHERE OurHost.obj-type = 'орг':U
                                               AND OurHost.obj-code = ub.shop.host-code NO-LOCK.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  ub.shop.host-code
  ,output v-base-code
  )  .
        end.
END CASE.
CASE QntyType:
    WHEN "один" THEN
        assign gds-qnty = 1.
    WHEN "остаток" THEN
        do:
          assign gds-qnty = 0.
          FIND ub.prt-obj WHERE ub.prt-obj.obj-type  = OurObj.obj-type
                         AND ub.prt-obj.obj-code  = OurObj.obj-code
                         AND ub.prt-obj.artic     = buf-par_goods.artic
                         AND ub.prt-obj.prod-type = buf-par_goods.prod-type
                         AND ub.prt-obj.prod-code = buf-par_goods.prod-code
                         AND ub.prt-obj.prt-code  = buf-par_bar-code.node-code
                       NO-LOCK NO-ERROR.
          if available ub.prt-obj then
              assign gds-qnty = ub.prt-obj.fact-qnty.
        end.
    WHEN "список" THEN
        assign gds-qnty = list-qnty.
    WHEN "документ" THEN
        assign gds-qnty = nakl-qnty.
END CASE.
if gds-qnty <= 0 then
    NEXT.
assign
    price = 0
    price-old = 0
    price-alt = 0
    price-alt-old = 0
    price-rb = 0
    price-rb-old = 0
    price-alt-rb = 0
    price-alt-rb-old = 0
    .
if PriceType <> "doc" and PriceType <> "doc-pr" then do:
  assign v-fact-order = 0.
end.
run prc-base-code( input buf-par_bar-code.b-code, output rt-b-code ).
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,input  rt-b-code
  ,input  0
  ,input  v-fact-order
  ,output rt-price-list-recid
  ,output rt-cli-base-rate
  ) no-error .
if rt-price-list-recid = ? then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf-par_goods.gds-code
  ,input  ?
  ,output rt-b-code
  ) no-error .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,input  rt-b-code
  ,input  0
  ,input  v-fact-order
  ,output rt-price-list-recid
  ,output rt-cli-base-rate
  ) no-error .
end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,input  buf-par_bar-code.b-code
  ,input  0
  ,input  v-fact-order
  ,output v-price-list-recid
  ,output v-cli-base-rate
  ) no-error .
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-rb-is-base
  )  .
if PriceType = "doc" then do:
  assign
    price = pr-doc-rubl * ScalePrice
    price-rb = pr-doc-rb * ScalePrice
    price-old = pr-doc-rubl-old * ScalePrice
    price-rb-old = pr-doc-rb-old * ScalePrice
    .
  if v-price-list-recid <> ? then do:
    find buf_price-list where recid( buf_price-list ) = v-price-list-recid no-lock.
    assign
      price-alt-one    = round( pr-doc-rubl * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt        = round( buf-par_bar-code.cli-base-rate * pr-doc-rubl * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt-rb     = round( buf-par_bar-code.cli-base-rate * pr-doc-rb * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt-old    = round( buf-par_bar-code.cli-base-rate * pr-doc-rubl-old * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      price-alt-rb-old = round( buf-par_bar-code.cli-base-rate * pr-doc-rb-old * ( 1 - buf_price-list.d-pcnt / 100 ), 2 ) * ScalePrice
      .
  end.
end.
else do:
  if v-price-list-recid = ? and rt-price-list-recid = ? then do:
    if not TickOnN then do:
      NEXT.
    end.
  end.
  else do:
    if rt-price-list-recid <> ? then do:
      find b-root_price-list where recid( b-root_price-list ) = rt-price-list-recid no-lock.
      assign
        price = b-root_price-list.price-sale * ScalePrice
        price-rb = price
      .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  b-root_price-list.obj-type
  ,input  b-root_price-list.obj-code
  ,input  b-root_price-list.b-code
  ,input  0
  ,input  b-root_price-list.fact-order
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
      assign
        price-old = cur-pr * ScalePrice
        price-rb-old = price-old
      .
    end.
    if v-price-list-recid <> ? then do:
      find buf_price-list where recid( buf_price-list ) = v-price-list-recid no-lock.
      assign
        price-alt-one = buf_price-list.price-sale * ScalePrice / (if buf_price-list.b-code = buf-par_bar-code.b-code then buf-par_bar-code.cli-base-rate else 1 )
        price-alt     = buf_price-list.price-sale * ScalePrice * (if buf_price-list.b-code <> buf-par_bar-code.b-code then buf-par_bar-code.cli-base-rate else 1 )
        price-alt-rb  = price-alt
      .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_price-list.obj-type
  ,input  buf_price-list.obj-code
  ,input  buf_price-list.b-code
  ,input  0
  ,input  buf_price-list.fact-order
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
      assign
        price-alt-old = cur-pr
                        * (if buf_price-list.b-code <> buf-par_bar-code.b-code then buf-par_bar-code.cli-base-rate else 1 )
                        * ScalePrice
        price-alt-rb-old = price-alt-old
        .
    end.
    if v-rb-is-base = true
      and v-base-code <> 0
    then do:
      assign
        price         = price         * curr-rate
        price-old     = price-old     * curr-rate
        price-alt-one = price-alt-one * curr-rate
        price-alt     = price-alt     * curr-rate
        price-alt-old = price-alt-old * curr-rate
      .
    end.
  end.
end.
assign
  str-price = trim( substitute( "&1 &2 &3 &4":U
                         ,substring( string( price , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                         ,"руб":U
                         ,substring( string( price , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                         ,"коп":U
                         )
            )
  .
assign
  str-price-old = trim( substitute( "&1 &2 &3 &4":U
                         ,substring( string( price-old , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                         ,"руб":U
                         ,substring( string( price-old , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                         ,"коп":U
                         )
            )
  .
assign
  str-price-alt-one = trim( substitute( "&1 &2 &3 &4":U
                         ,substring( string( price-alt-one , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                         ,"руб":U
                         ,substring( string( price-alt-one , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                         ,"коп":U
                         )
            )
  .
assign
  str-price-alt = trim( substitute( "&1 &2 &3 &4":U
                         ,substring( string( price-alt , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                         ,"руб":U
                         ,substring( string( price-alt , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                         ,"коп":U
                         )
            )
  .
assign
  str-price-alt-old = trim( substitute( "&1 &2 &3 &4":U
                         ,substring( string( price-alt-old , ">>>>>>>>>>>9.99":U ) , 1 , 12 )
                         ,"руб":U
                         ,substring( string( price-alt-old , ">>>>>>>>>>>9.99":U ) , 14 , 15 )
                         ,"коп":U
                         )
            )
  .
assign
  str-price-rb = trim( string( price-rb, ">>>>>>>>>>>>9.99" ) )
  str-price-rb-old = trim( string( price-rb-old, ">>>>>>>>>>>>9.99" ) )
  str-price-alt-rb = trim( string( price-alt-rb, ">>>>>>>>>>>>9.99" ) )
  str-price-alt-rb-old = trim( string( price-alt-rb-old, ">>>>>>>>>>>>9.99" ) )
  .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,output v-ticket-host-code
  )  .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-par_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-ticket-host-code
  ,input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,output v-ticket-vat-pc
  ) no-error .
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-par_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-ticket-host-code
  ,input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,output v-ticket-slt-pc
  ) no-error .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  OurObj.obj-type
  ,input  OurObj.obj-code
  ,output v-ticket-today
  )  .
define variable v-bc-check-price  as character no-undo .
define variable v-doc-num         as character no-undo .
define variable v-price-sale      as decimal   no-undo .
define variable v-road-tax        as decimal   no-undo .
define variable v-excise          as decimal   no-undo .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf-par_bar-code.b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
if v-price-sale <> ?
then do:
  assign
    v-bc-check-price = substitute('&1/&2', buf-par_bar-code.b-code, v-price-sale)
  .
end.
else do:
  assign
    v-bc-check-price = ""
  .
end.
assign
  ListProdBc = replace( ListProdBc, "|":U, "/":U )
.
define variable v-rt-bar_code          as character no-undo .
define variable price-rt               as decimal   no-undo .
define variable str-price-rt           as character no-undo .
define variable str-price-novat-rt     as character no-undo .
define variable v-first-pbc-rt         as character no-undo .
define variable v-rt-alt-bar_code      as character no-undo .
define variable v-rt-alt_unit-cli      as character no-undo .
define variable price-alt-rt           as decimal   no-undo .
define variable str-price-alt-rt       as character no-undo .
define variable str-price-alt-novat-rt as character no-undo .
define variable v-first-pbc-alt-rt     as character no-undo .
define buffer buf-alt-rt_bar-code for ub.bar-code .
define buffer buf-rt_bar-code     for ub.bar-code .
define buffer buf_prod-bc         for ub.prod-bc .
if rt-price-list-recid <> ? then do:
  find first buf_prod-bc no-lock
    where buf_prod-bc.b-code = rt-b-code
      and buf_prod-bc.bc-on  = true
    no-error .
  find b-root_price-list no-lock
    where recid( b-root_price-list ) = rt-price-list-recid
  .
  assign
    price-rt           = b-root_price-list.price-sale * ScalePrice
    str-price-rt       = trim( string( price-rt, ">>>>>>>>>>>>9.99":U ) )
    str-price-novat-rt = trim( string( price-rt * 100 / ( 100 + v-ticket-vat-pc ), ">>>>>>>>>>>>9.99":U ) )
    v-first-pbc-rt     = (if available buf_prod-bc then buf_prod-bc.b-str else "":U )
  .
  run gen-bc in this-procedure
    ( input rt-b-code
     ,output v-rt-bar_code
    ).
end.
find first buf-rt_bar-code no-lock
  where buf-rt_bar-code.b-code = rt-b-code
  .
if buf-par_goods.qnty-cart <> 1
  and buf-par_goods.qnty-cart <> 0
  and buf-par_goods.qnty-cart <> ?
then do:
  find first buf-alt-rt_bar-code no-lock
    where buf-alt-rt_bar-code.gds-code      = buf-par_goods.gds-code
      and buf-alt-rt_bar-code.node-code     = buf-rt_bar-code.node-code
      and buf-alt-rt_bar-code.cli-base-rate = buf-par_goods.qnty-cart
    no-error .
  if available buf-alt-rt_bar-code then do:
    find first buf_prod-bc no-lock
      where buf_prod-bc.b-code = buf-alt-rt_bar-code.b-code
        and buf_prod-bc.bc-on  = true
      no-error .
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf-alt-rt_bar-code.b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
    assign
      price-alt-rt           = v-price-sale * ScalePrice
      str-price-alt-rt       = trim( string( price-alt-rt, ">>>>>>>>>>>>9.99":U ) )
      str-price-alt-novat-rt = trim( string( price-alt-rt * 100 / ( 100 + v-ticket-vat-pc ), ">>>>>>>>>>>>9.99":U ) )
      v-first-pbc-alt-rt     = (if available buf_prod-bc then buf_prod-bc.b-str else "":U )
      v-rt-alt_unit-cli      = buf-alt-rt_bar-code.unit-cli
    .
    run gen-bc in this-procedure
      ( input buf-alt-rt_bar-code.b-code
      ,output v-rt-alt-bar_code
      ).
  end.
end.
define buffer buf-t_doc-line for ub.doc-line.
define buffer buf-t_trn-doc for ub.trn-doc.
define buffer buf-t_price-list for ub.price-list.
define buffer buf-t_price-doc for ub.price-doc.
define variable v-last-doc-date as date      no-undo .
assign
  v-last-doc-date = ?
.
find last buf-t_doc-line no-lock
  where buf-t_doc-line.obj-type     = p-obj-type
    and buf-t_doc-line.obj-code     = p-obj-code
    and buf-t_doc-line.prod-type    = buf-par_goods.prod-type
    and buf-t_doc-line.prod-code    = buf-par_goods.prod-code
    and buf-t_doc-line.artic        = buf-par_goods.artic
    and buf-t_doc-line.ext-doc-type = 'ie':U
    and buf-t_doc-line.status_      = 'факт':U
  use-index dt-fo
  no-error.
if available buf-t_doc-line then do:
  find first buf-t_trn-doc no-lock
    where buf-t_trn-doc.doc-code = buf-t_doc-line.doc-code
  .
  if v-last-doc-date = ?
     or ( v-last-doc-date <> ?
          and buf-t_trn-doc.fact-date > v-last-doc-date
        )
  then do:
    assign
      v-last-doc-date = buf-t_trn-doc.fact-date
    .
  end.
end.
find last buf-t_price-list no-lock
  where buf-t_price-list.obj-type   = p-obj-type
    and buf-t_price-list.obj-code   = p-obj-code
    and buf-t_price-list.b-code     = rt-b-code
    and buf-t_price-list.price-type = ""
  use-index fact-close
  no-error.
if available buf-t_price-list then do:
  find first buf-t_price-doc no-lock
    where buf-t_price-doc.doc-num = buf-t_price-list.doc-num
  .
  if v-last-doc-date = ?
     or ( v-last-doc-date <> ?
          and buf-t_price-doc.fact-date > v-last-doc-date
        )
  then do:
    assign
      v-last-doc-date = buf-t_price-doc.fact-date
    .
  end.
end.
if v-last-doc-date = ? then do:
  assign
    v-last-doc-date = v-ticket-today
  .
end.
price-cd = price.
run dr-katp in this-procedure
  ( input buf-par_goods.gds-code
   ,input buf-par_bar-code.b-code
   ,input p-obj-type
   ,input p-obj-code
   ,input dflt-cd
   ,input price
   ,input how-pcnt-kat
   ,input (if v-fact-order = 0 then ? else v-fact-order)
   ,output price-cd
  ) no-error.
if error-status:error then do:
end.
define variable v-calories      as decimal   no-undo .
define variable v-protein       as decimal   no-undo .
define variable v-carbohydrate  as decimal   no-undo .
define variable v-fat           as decimal   no-undo .
run nutro_get-nutrition-info
  ( input  buf-par_goods.artic
  , input  buf-par_goods.prod-type
  , input  buf-par_goods.prod-code
  , input  p-obj-type
  , input  p-obj-code
  , output v-calories
  , output v-protein
  , output v-carbohydrate
  , output v-fat
  ) .
define variable v-last-pri-doc as character no-undo .
define buffer buf_parts for ub.parts .
define variable v-cash-parts as logical no-undo .
find first gds-obj no-lock
     where gds-obj.artic     = buf-par_goods.artic
       and gds-obj.prod-type = buf-par_goods.prod-type
       and gds-obj.prod-code = buf-par_goods.prod-code
       and gds-obj.obj-code  = p-obj-code
       and gds-obj.obj-type  = p-obj-type no-error.
if available gds-obj then assign v-cash-parts = gds-obj.cash-parts .
assign
  v-last-pri-doc = ""
.
if v-cash-parts then do :
 for each buf-t_doc-line no-lock
    where buf-t_doc-line.obj-type     = p-obj-type
      and buf-t_doc-line.obj-code     = p-obj-code
      and buf-t_doc-line.prod-type    = buf-par_goods.prod-type
      and buf-t_doc-line.prod-code    = buf-par_goods.prod-code
      and buf-t_doc-line.artic        = buf-par_goods.artic
      and (buf-t_doc-line.ext-doc-type = 'ie':U
      or buf-t_doc-line.ext-doc-type = 'iv':U)
      and buf-t_doc-line.status_      = 'факт':U
      by buf-t_doc-line.fact-order descending
      :
     if buf-par_bar-code.part-code <> "" then do :
       find first buf_parts no-lock
           where buf_parts.part-code = buf-par_bar-code.part-code
             and buf_parts.artic = buf-par_goods.artic
             and buf_parts.prod-type = buf-par_goods.prod-type
             and buf_parts.prod-code = buf-par_goods.prod-code
             and buf_parts.obj-code = p-obj-code
             and buf_parts.obj-type = p-obj-type
             and buf_parts.out-code = buf-t_doc-line.doc-code
             no-error.
       if available buf_parts then do :
       v-last-pri-doc = buf_parts.out-code.
       leave.
       end.
     end.
     else do :
       find first buf_parts no-lock
            where buf_parts.artic = buf-par_goods.artic
              and buf_parts.prod-type = buf-par_goods.prod-type
              and buf_parts.prod-code = buf-par_goods.prod-code
              and buf_parts.obj-code = p-obj-code
              and buf_parts.obj-type = p-obj-type
              and buf_parts.out-code = buf-t_doc-line.doc-code
              no-error.
        if available buf_parts then do :
          v-last-pri-doc = buf_parts.out-code.
          leave.
        end.
     end.
 end.
end.
else do:
  for last buf-t_doc-line no-lock
    where buf-t_doc-line.obj-type     = p-obj-type
      and buf-t_doc-line.obj-code     = p-obj-code
      and buf-t_doc-line.prod-type    = buf-par_goods.prod-type
      and buf-t_doc-line.prod-code    = buf-par_goods.prod-code
      and buf-t_doc-line.artic        = buf-par_goods.artic
      and (buf-t_doc-line.ext-doc-type = 'ie':U
      or  buf-t_doc-line.ext-doc-type = 'iv':U)
      and buf-t_doc-line.status_      = 'факт':U
    by buf-t_doc-line.fact-order descending
    :
    v-last-pri-doc = buf-t_doc-line.doc-code.
  end.
end.
define variable v-doc-date         as character initial "":U no-undo .
define variable v-short-doc-code   as character no-undo .
define variable v-ser_on_pack      as character no-undo .
define variable v-ser_on_pack-type as character no-undo .
if p-doc-code <> "":U then do:
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if available buf_trn-doc then do:
    assign
      v-doc-date       = string( buf_trn-doc.fact-date, "99/99/9999" )
      v-short-doc-code = string( get-doc-code-int64( p-doc-code ) )
    .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'ser_on_pack':U ,
                       output v-ser_on_pack ,
                       output v-ser_on_pack-type )  .
  end.
end.
define variable v-promo-name      as character no-undo .
define variable v-type-sale-promo as character no-undo .
define variable v-sale-promo      as character   no-undo .
define variable v-promo-price     as decimal   no-undo .
if p-ActionId <> 0 and p-ActionId <> ? then
do:
   find first ub.PromoAction no-lock where ub.PromoAction.id = p-ActionId and
      ub.PromoAction.db-num = p-db-num no-error .
   if available (ub.PromoAction) then
   do:
      v-promo-name = ub.PromoAction.nameAction .
      find first ub.PromoGoods no-lock where ub.PromoGoods.db-num = ub.PromoAction.db-num and
         ub.PromoGoods.idAction = ub.PromoAction.id and
         ub.PromoGoods.gds-code = buf-par_goods.gds-code
         no-error .
         find first ub.PromoCriterion no-lock where ub.PromoCriterion.db-num = ub.PromoAction.db-num and
              ub.PromoCriterion.idAction = ub.PromoAction.id no-error .
      case ub.PromoAction.methodCalc:
         when 2 then
            do:
               v-type-sale-promo = " руб." .
               if available (ub.PromoCriterion) then
               do:
                  v-sale-promo = string(ub.PromoCriterion.discont) + v-type-sale-promo .
                  v-promo-price = price - ub.PromoCriterion.discont .
               end.
            end.
         when 1 then
            do:
               v-type-sale-promo = "%" .
               if available (ub.PromoCriterion) then
               do:
                  v-sale-promo = string(ub.PromoCriterion.discont) + v-type-sale-promo .
                  v-promo-price = price - price * (ub.PromoCriterion.discont / 100) .
               end.
            end.
         when 5 then
            do:
               v-type-sale-promo = " руб." .
               if available (ub.PromoGoods) then
               do:
                  v-sale-promo = string(ub.PromoGoods.price) + v-type-sale-promo .
                  v-promo-price = ub.PromoGoods.price .
               end.
            end.
      end case.
   end.
end.
PUT STREAM OutStream UNFORMATTED
   (if buf-par_bar-code.unit-cli <> buf-par_goods.unit-base
          and ((qntytype = "список" and action = "list")
                     or
                     (qntytype = "документ" and action = "document"))
                then integer(round(gds-qnty / buf-par_bar-code.cli-base-rate, 0))
                else gds-qnty) "|"
      replace( OurHost.obj-name, "|":U, "/":U )  "|":U
      replace( OurObj.obj-name, "|":U, "/":U ) "|":U
      replace( buf-par_goods.artic, "|":U, "/":U ) "|":U
      replace( buf-par_goods.gds-name, "|":U, "/":U ) "|":U
      replace( buf-par_goods.engl-name, "|":U, "/":U ) "|":U
      (if available ub.scales-gds then "" else bar_code ) "|":U
      replace( gds-prt_node-name, "|":U, "/":U ) "|":U
      replace( country_name, "|":U, "/":U ) "|":U
      replace( prod_name, "|":U, "/":U ) "|":U
      str-price "|":U
      "Цена за " replace( buf-par_goods.unit-base, "|":U, "/":U ) ":" "|":U
      string( v-ticket-today,"99/99/9999" ) "|":U
      (if available ub.scales-gds then string(ub.scales-gds.PLU-code) else "" ) "|":U
      (if available ub.scales-gds then string("(" + string(ub.scales-gds.scales-num) + ")") else "" ) "|":U
      "Цена за " replace( trim(buf-par_bar-code.unit-cli), "|":U, "/":U ) " (" buf-par_bar-code.cli-base-rate " " replace( buf-par_goods.unit-base, "|":U, "/":U ) "):" "|":U
      str-price-alt "|":U
      replace( buf-par_goods.destin, "|":U, "/":U ) "|":U
      replace( buf-par_goods.attrib, "|":U, "/":U ) "|":U
      replace( buf-par_goods.user-rule, "|":U, "/":U ) "|":U
      replace( buf-par_goods.sert, "|":U, "/":U ) "|":U
      replace( replace(buf-par_goods.struct, chr(10), chr(32)), "|":U, "/":U ) "|":U
      buf-par_goods.deadline "|":U
      replace( buf-par_goods.sort, "|":U, "/":U )  "|":U
      (if available ub.scales-gds then varattr-value else bar_code )  "|":U
      ListProdBc "|":U
      replace( buf-par_goods.grp-name, "|":U, "/":U ) "|":U
      replace( gds-grp.node-name, "|":U, "/":U ) "|":U
      replace( buf-par_goods.PS, "|":U, "/":U ) "|":U
      replace( gds-prt_f-name, "|":U, "/":U ) "|":U
      str-price-rb "|":U
      str-price-alt-rb "|":U
      (if buf-par_bar-code.cli-base-rate = 1 then buf-par_goods.qnty-cart else buf-par_bar-code.cli-base-rate) " " buf-par_goods.unit-base "|":U
      buf-par_bar-code.b-code "|":U
      replace( buf-par_goods.prod-type, "|":U, "/":U ) "|":U
      buf-par_goods.prod-code "|":U
      replace( buf-par_goods.unit-cli, "|":U, "/":U )  "|":U
      buf-par_goods.cli-base-rate "|":U
      replace( TickPS, "|":U, "/":U ) "|":U
      buf-par_goods.increase-pc "|":U
      buf-par_goods.wt-cart "|":U
      buf-par_goods.ms-cart "|":U
      buf-par_goods.gds-type "|":U
      v-ticket-vat-pc "|":U
      replace( buf-par_goods.okdp, "|":U, "/":U ) "|":U
      buf-par_goods.negative-rest "|":U
      replace( buf-par_goods.cost-calc, "|":U, "/":U ) "|":U
      v-ticket-slt-pc "|":U
      replace( buf-par_goods.unit-cst, "|":U, "/":U ) "|":U
      buf-par_goods.cst-base-rate "|":U
      replace( buf-par_goods.TNVED, "|":U, "/":U ) format "x(10)" "|":U
      buf-par_goods.min-stock "|":U
      replace( buf-par_goods.nationality, "|":U, "/":U ) "|":U
      replace( buf-par_goods.label-name, "|":U, "/":U ) "|":U
      str-price-old "|":U
      str-price-alt-old "|":U
      str-price-rb-old "|":U
      str-price-alt-rb-old "|":U
      v-mrtr-code "|":U
      v-bc-check-price "|":U
      entry( 1, ListProdBc, ",":U ) "|":U
      replace( v-rt-bar_code, "|":U, "/":U ) "|":U
      replace( buf-rt_bar-code.unit-cli, "|":U, "/":U ) "|":U
      replace( v-first-pbc-rt, "|":U, "/":U ) "|":U
      str-price-rt "|":U
      str-price-novat-rt "|":U
      replace( v-rt-alt-bar_code, "|":U, "/":U ) "|":U
      replace( v-rt-alt_unit-cli, "|":U, "/":U ) "|":U
      replace( v-first-pbc-alt-rt, "|":U, "/":U ) "|":U
      str-price-alt-rt "|":U
      str-price-alt-novat-rt "|":U
      replace( string( v-last-doc-date, "99/99/9999") , "|":U, "/":U ) "|":U
      str-price-alt-one "|":U
      trim( string( price-cd, ">>>>>>>>>>>>9.99" ) ) "|":U
      trim( string( v-calories, ">>>>>>>>>>>>9.<<" ) ) "|":U
      trim( string( v-protein, ">>>>>>>>>>>>9.<<" ) ) "|":U
      trim( string( v-carbohydrate, ">>>>>>>>>>>>9.<<" ) ) "|":U
      trim( string( v-fat, ">>>>>>>>>>>>9.<<" ) ) "|":U
      trim( p-part-code ) "|":U
      trim( p-doc-code ) "|":U
      trim( v-doc-date ) "|":U
      trim( v-short-doc-code ) "|":U
      trim( v-ser_on_pack ) "|":U
      v-last-pri-doc "|":U
      p-promo-code "|":U
      v-promo-name "|":U
      v-type-sale-promo "|":U
      v-sale-promo "|":U
      string(v-promo-price,">>>>>>>>>>>>9.99")
            SKIP.
assign b-count = b-count + 1.
