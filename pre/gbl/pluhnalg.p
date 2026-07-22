block-level on error undo, throw.
define input parameter p-check-number as character no-undo .
define output parameter p-long-number  as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pluhnalg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/pluhnalg.p $":U .
define variable vss-description as character no-undo init "Процедура получения по номеру карты вида NNNNNNNNN? номера с рассчитанной КЦ NNNNNNNNNC по методу Luhna".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION Luhn-algo returns integer(input p-str as character):
define variable v-length as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-c as character no-undo extent 10.
define variable v-c-int-dop as integer no-undo extent 10.
define variable v-c-int-dop2 as integer no-undo extent 10.
define variable v-c-int as integer no-undo extent 10.
define variable v-all as integer no-undo .
define variable v-all-trunc-up as integer no-undo .
assign
v-length = length(p-str).
if v-length modulo 2 <> 0 then do:
  assign
  p-str = "0" + p-str
  .
end.
do v-ii = 0 to v-length by 2:
  assign
  v-jj = integer(v-ii / 2) + 1
  v-c[v-jj] = substring(p-str, v-ii + 1, 2)
  v-c-int-dop[v-jj] = integer(substring(v-c[v-jj], 2, 1)) * 2
  v-c-int-dop2[v-jj] = TRUNCATE(v-c-int-dop[v-jj] / 10, 0)  +  v-c-int-dop[v-jj] modulo 10
  v-c-int[v-jj] = integer(substring(v-c[v-jj], 1, 1)) + v-c-int-dop2[v-jj]
  v-all = v-all +  v-c-int[v-jj]
  .
end.
assign
v-all-trunc-up =  if v-all modulo 10 <> 0
                  then (TRUNCATE(v-all / 10, 0) * 10 + 10)
                  else v-all
.
return (v-all-trunc-up - v-all).
END FUNCTION.
define variable v-dopi as integer no-undo .
define variable v-pos as integer no-undo .
define variable v-check-number as character no-undo .
do
on error undo, return error
:
  if index(p-check-number , 'C') = 0 then do:
    undo, return error substitute("в номере карты &1 не определена позиция контрольной цифры"
                                   , p-check-number ).
  end.
  if num-entries(p-check-number, 'C') > 2 then do:
    undo, return error substitute("для карты &1 определено более 1 позиции контрольной цифры&2для алгоритма Luhna это невозможно"
                                   , p-check-number
                                   , chr(10)
                                   ).
  end.
  assign
  v-pos  = index(p-check-number, 'C')
  v-check-number = p-check-number
  v-dopi = Luhn-algo(replace(p-check-number, 'C', '':U))
  no-error .
  if error-status:error then do:
    undo, return error substitute("ошибка при вычислении КЦ для карты &1:&2&3&2&4"
                                   , P-CHECK-NUMBER
                                   , chr(10)
                                   , error-status:get-message(1)
                                   , return-value ).
  end.
  assign
  p-long-number = replace(v-check-number, 'C':U, string(v-dopi))
  .
end.
