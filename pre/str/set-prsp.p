block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: set-prsp.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/set-prsp.p $":U .
def var vss-description as character no-undo init "Установка специальной цены продаже по партиям".
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
define input  parameter pardoc-code          like trn-doc.doc-code      no-undo.
define input  parameter parobj-type          like trn-doc.obj-type      no-undo.
define input  parameter parobj-code          like trn-doc.obj-code      no-undo.
define input  parameter parartic             like doc-line.artic        no-undo.
define input  parameter parprod-type         like doc-line.prod-type    no-undo.
define input  parameter parprod-code         like doc-line.prod-code    no-undo.
define output parameter parsaleparts         as   logical               no-undo.
define output parameter parsp-sum-price-sale like price-list.price-sale no-undo.
define output parameter parsp-sum-road-tax   like price-list.road-tax   no-undo.
define output parameter parsp-sum-excise     like price-list.excise     no-undo.
define output parameter parsp-prc-price-sale like price-list.price-sale no-undo.
define output parameter parsp-prc-road-tax   like price-list.road-tax   no-undo.
define output parameter parsp-prc-excise     like price-list.excise     no-undo.
define variable         vardoc-num           like price-list.doc-num    no-undo.
define variable         varprice-sale        like price-list.price-sale no-undo.
define variable         varroad-tax          like price-list.road-tax   no-undo.
define variable         varexcise            like price-list.excise     no-undo.
define variable         varparts-b-code      like bar-code.b-code       no-undo.
define variable         varfact-qnty         like parts.fact-qnty       no-undo.
find first goods where goods.artic     = parartic     and
                       goods.prod-type = parprod-type and
                       goods.prod-code = parprod-code no-lock.
find first units where units.unit-name = goods.unit-base no-lock.
if cross-list(units.type, 'прп':U, ",") then do:
   for each parts where parts.out-code  = pardoc-code  and
                        parts.obj-type  = parobj-type  and
                        parts.obj-code  = parobj-code  and
                        parts.artic     = parartic     and
                        parts.prod-type = parprod-type and
                        parts.prod-code = parprod-code no-lock :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer parts
  ,output varparts-b-code
  ) no-error .
       if error-status:error then do:
          return error "Не найдена бар-код партии "                    +
                       " Документ "          + string(parts.out-code)  +
                       " Тип объекта "       + string(parts.obj-type)  +
                       " Код объекта "       + string(parts.obj-code)  +
                       " Артикул "           + string(parts.artic)     +
                       " Тип производителя " + string(parts.prod-type) +
                       " Код производителя " + string(parts.prod-code) +
                       " Код партии "        + string(parts.part-code) +
                       " Прих.накл "         + string(parts.in-code)   .
       end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  parts.obj-type
  ,input  parts.obj-code
  ,input  varparts-b-code
  ,input  0
  ,input  0
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ) no-error .
      if varprice-sale = ? then
         return error "Не найдена цена товара на партию "       +
                      " Документ "          + string(parts.out-code)  +
                      " Тип объекта "       + string(parts.obj-type)  +
                      " Код объекта "       + string(parts.obj-code)  +
                      " Артикул "           + string(parts.artic)     +
                      " Тип производителя " + string(parts.prod-type) +
                      " Код производителя " + string(parts.prod-code) +
                      " Бар-код "           + string(varparts-b-code) +
                      " Код партии "        + string(parts.part-code) +
                      " Прих.накл "         + string(parts.in-code).
      assign parsp-sum-price-sale = parsp-sum-price-sale + varprice-sale * parts.fact-qnty
             parsp-sum-road-tax   = parsp-sum-road-tax   + varroad-tax   * parts.fact-qnty
             parsp-sum-excise     = parsp-sum-excise     + varexcise     * parts.fact-qnty
             varfact-qnty         = varfact-qnty         +                 parts.fact-qnty.
   end.
   assign
   parsp-prc-price-sale = parsp-sum-price-sale / varfact-qnty
   parsp-prc-road-tax   = parsp-sum-road-tax   / varfact-qnty
   parsp-prc-excise     = parsp-sum-excise     / varfact-qnty.
end.
else assign parsaleparts = no.
