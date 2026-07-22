block-level on error undo, throw.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pr-listv.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/pr-listv.p $":U .
def var vss-description as character no-undo init " фильтрует методы переоценки   ".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define input  parameter i-list   as character no-undo .
define input  parameter init-val as character no-undo .
define output parameter o-list   as character no-undo .
define variable i           as integer   no-undo .
define variable par-pr-list as character no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'overval':U
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
      if thbjattr_thbj-attr.prop-code = 'pr-list':U then par-pr-list = thbjattr_thbj-attr.property-value-character .
  end.
 if par-pr-list = ? then par-pr-list = ""   .
 if par-pr-list = ""  then  do:
    o-list = i-list .
    return .
 end.
define variable v-nn as integer   no-undo .
v-nn =  num-entries ( par-pr-list )  .
do i = 1 to v-nn :
   if lookup(caps(entry(i,par-pr-list)) , caps('Товар,Учетная,Учет-объект,Учет-резерв,Приходная,Прих-объект,Старая,Новая,Объект,Накладная,Переоценка,Накл-безНДС,Учет-безНДС,Стар-безНДС,Единая,НсП,НсП+накл,Откат_цен,Отсутствует,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) + "," + caps('Учетная,Группа,Учет-резерв,Накладная,Накл-безНДС,Учет-безНДС,Учет+накл,Уч+накл-НДС,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U)  + "," + caps('Товар,УчетнаяS,Учет-рзрвS,ПриходнаяS,Старая,Новая,Объект,Накладная,Переоценка,ДокФормЦены,Накл-безНДС,Учет-НДСS,Стар-безНДС,Единая,Отсутствует,Откат_цен,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U) ) = 0
     then do:
     if caps(entry(i,par-pr-list)) = "" then
      message "Неправильное значение метода расчета переоценки - есть пробел или лишняя запятая" skip
      "Фильтр игнорируется !" skip
      "Проверьте параметр системы pr-list! " skip
      par-pr-list
      .
     else
      message "Неправильное значение метода расчета переоценки - " entry(i,par-pr-list) skip
      "Фильтр игнорируется !" skip
      "Проверьте параметр системы pr-list! ".
      o-list = i-list .
      return.
      end.
end.
o-list = "" .
define variable v-1 as integer   no-undo .
v-1 = num-entries ( i-list ) .
do i = 1 to v-1 :
   if lookup(caps(entry(i,i-list)) , caps(par-pr-list)) > 0
      or caps(entry(i,i-list)) = caps('Отсутствует':U)
      or caps(entry(i,i-list)) = caps('Не-считать':U)
      or caps(entry(i,i-list)) = caps(init-val)
      then do:
      assign
        o-list = o-list
         + ( if o-list = "" then "" else "," )
         + entry( i , i-list ) .
      end.
end.
return .
