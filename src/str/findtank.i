/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение танка из которого налили данное топливо с данной ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/23/08
Author: Dmitry Ukhanov
Creation date: 06/23/08

Author1: Bakhtadze Natalya
Creation date1: 10/10/00

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(findtank_i) = 0 &then

&glob findtank_i


procedure findtank:
  define input  parameter p-obj-type     as character no-undo.
  define input  parameter p-obj-code     as integer   no-undo.
  define input  parameter p-pump-code    as integer   no-undo.
  define input  parameter p-nozzle-code  as integer   no-undo .
  define input  parameter p-from-pl-code as integer   no-undo .
  define input  parameter p-gds-code     as integer   no-undo.
  define output parameter p-pl-code      as integer   no-undo .

  define variable v-pl-code            like ub.place.pl-code no-undo .
  define variable v-dopstr             as character no-undo .

  define buffer buf_place for ub.place.
  define buffer buf_pl-gds-pump for ub.pl-gds-pump.
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
  define buffer buf_pl-gds for ub.pl-gds.

  do
  on error undo, return error return-value
  :

    assign
      v-pl-code = 0
      p-pl-code = ?
    .

    if p-from-pl-code <> ?
      and p-from-pl-code <> 0
    then do:
      find first buf_pl-gds no-lock
        where buf_pl-gds.obj-type  = p-obj-type
          and buf_pl-gds.obj-code  = p-obj-code
          and buf_pl-gds.pl-code   = p-from-pl-code
          and buf_pl-gds.gds-code  = p-gds-code
        no-error.
      if available buf_pl-gds then do:
        assign
          v-pl-code = buf_pl-gds.pl-code
        .
      end.
    end.

    if v-pl-code <> 0
      and p-nozzle-code <> ?
      and p-nozzle-code <> 0
    then do:
      find first buf_pl-pump-nozzle no-lock
        where buf_pl-pump-nozzle.obj-type    = p-obj-type
          and buf_pl-pump-nozzle.obj-code    = p-obj-code
          and buf_pl-pump-nozzle.pl-code     = v-pl-code
          and buf_pl-pump-nozzle.pump-code   = p-pump-code
          and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
/*          and buf_pl-pump-nozzle.status_     = {&current-status} поле не заполняется*/
        no-error .
      if not available buf_pl-pump-nozzle then do:
        return.
      end.
    end.

    if v-pl-code = 0 then do:
      if p-nozzle-code = 0 then do:
        find first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = {&current-status}
          no-error.
        if available buf_pl-gds-pump then do:
          assign
            v-pl-code = buf_pl-gds-pump.pl-code
          .
        end.
      end.
      else do:
        _ppnz:
        for each buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
/*            and buf_pl-pump-nozzle.status_ = {&current-status} поле не заполняется*/
          ,first buf_pl-gds-pump no-lock
          where buf_pl-gds-pump.obj-type  = p-obj-type
            and buf_pl-gds-pump.obj-code  = p-obj-code
            and buf_pl-gds-pump.pump-code = p-pump-code
            and buf_pl-gds-pump.gds-code  = p-gds-code
            and buf_pl-gds-pump.status_   = {&current-status}
            and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
        on error undo, return error return-value
        :
          assign
            v-pl-code = buf_pl-pump-nozzle.pl-code
          .
          leave _ppnz.
        end.
      end.
    end.

    if v-pl-code <> 0 then do:
      assign
        p-pl-code = v-pl-code
      .
    end.

  end. /*doe*/
end procedure.

procedure find-nzl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define input  parameter p-pl-code    as integer no-undo .
define output parameter p-nozzle-code    as integer   no-undo.

define variable v-nozzle-code        like ub.nozzle.nozzle-code no-undo .
define variable v-pl-code            like ub.place.pl-code no-undo .
define variable v-pump-code          like ub.pump.pump-code no-undo .
define variable v-loc1-code          like ub.place.loc1 no-undo .
define variable v-dopstr             as character no-undo .

define buffer buf_place for ub.place.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
define buffer buf_pl-gds for ub.pl-gds.

do on error undo, return error return-value :
  v-pump-code = p-pump-code.
  find first buf_pl-pump-nozzle no-lock where
                buf_pl-pump-nozzle.obj-type = p-obj-type
            and buf_pl-pump-nozzle.obj-code = p-obj-code
            and buf_pl-pump-nozzle.pump-code = p-pump-code
            and buf_pl-pump-nozzle.pl-code = p-pl-code no-error.
  if not available buf_pl-pump-nozzle then do:
    assign
    p-nozzle-code = ?.
    return .
  end.
  assign
  p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
  return.
  .
end. /*doe*/
end procedure.


procedure find-nzl-without-pl:
define input  parameter p-obj-type   as character no-undo.
define input  parameter p-obj-code   as integer   no-undo.
define input  parameter p-pump-code  as integer   no-undo.
define input  parameter p-gds-code   as integer   no-undo.
define output parameter p-nozzle-code    as integer   no-undo.
define buffer buf_pl-gds-pump for ub.pl-gds-pump.
define buffer buf_pl-gds for ub.pl-gds.
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.

do on error undo, return error return-value :
  for each buf_pl-gds-pump no-lock where
            buf_pl-gds-pump.obj-type  = p-obj-type
        and buf_pl-gds-pump.obj-code  = p-obj-code
        and buf_pl-gds-pump.pump-code = p-pump-code
        and buf_pl-gds-pump.gds-code  = p-gds-code
        and buf_pl-gds-pump.status_   = {&current-status},
      first buf_pl-gds no-lock where
                buf_pl-gds.obj-type = p-obj-type
            AND buf_pl-gds.obj-code = p-obj-code
            AND buf_pl-gds.pl-code = buf_pl-gds-pump.pl-code
            AND buf_pl-gds.gds-code = p-gds-code
            AND buf_pl-gds.status_ = {&current-status},
     first buf_pl-pump-nozzle no-lock where
              buf_pl-pump-nozzle.obj-type = p-obj-type
          and buf_pl-pump-nozzle.obj-code = p-obj-code
          and buf_pl-pump-nozzle.pl-code = buf_pl-gds.pl-code
          and buf_pl-pump-nozzle.pump-code = p-pump-code:

    assign
    p-nozzle-code = buf_pl-pump-nozzle.nozzle-code.
    return .
  end.
  assign
  p-nozzle-code = ?.
  return.
  .
end. /*doe*/
end procedure.





&endif

/* $Workfile$ e n d */