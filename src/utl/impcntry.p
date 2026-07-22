block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: impcntry.p $
$Archive: utl/impcntry.p $

Закачка в ГДБ СПРАВОЧНИКА СТРАН и его РЕДАКТИРОВАНИЕ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impcntry.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impcntry.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }  /* не убирать, иначе будет вызываться отовсюду, и СПН не сработает */
{ gbl/waitfram.i }


define variable country-path as char no-undo.
define variable rc as recid no-undo.
define variable glog as logical no-undo .
define temp-table  for-country no-undo
like ub.country .
find first ub.sys-ctrl.
if ub.sys-ctrl.db-num <> 0 then do:
  message "Данная утилита может работать только в ГБД.".
  return.
end.
glog = no.
message
"COUNTRY REFERENCE IMPORT" skip
"ARE YOU SURE ?"
view-as alert-box question buttons OK-Cancel update glog.
if glog <> true then return.

run waitfram-show in this-procedure ("COUNTRY REFERENCE IMPORT ...").


country-path = search("cmp/countris.txt").
if country-path = ? then do:
    message "Нет найден файл импорта для справочника стран countris.txt"
                    "Справочник стран не будет заполнен!"
                    view-as alert-box.

end.
else do:

input from value(country-path).

REPEAT:
    CREATE for-country.
    IMPORT for-country NO-ERROR.
    FIND FIRST ub.country where ub.country.alpha1 = for-country.alpha1 no-error.
    if not  avail ub.COUNTRY then do:
        finD first ub.COUNTRY wHERE ub.country.num-code = for-country.num-code No-ERROR.
        if not avail ub.country then do:
        create ub.country.
            ASSIGN
            ub.country.alpha1     = for-country.alpha1
            ub.country.alpha2     = for-country.alpha2
            ub.country.long-name  = for-country.long-name
            ub.country.num-code   = for-country.num-code
            ub.country.short-name = for-country.short-name
            NO-ERROR.
        end.
        else do:

        end.
    end.
    ELSE DO:
        rc = recid(country).
        IF NOT CAN-find(FIRST COUNTRY WHERE
                                              COUNTRY.NUM-CODE = FOR-COUNTRY.NUM-CODE AND
                                              recid(country) <> rc) THEN
        assign
        country.alpha2     = for-country.alpha2
        country.long-name  = for-country.long-name
        country.num-code   = for-country.num-code
        country.short-name = for-country.short-name
        .
    END.
    delete for-country.
END.

INPUT CLOSE.
FIND FIRST ub.COUNTRY WHERE ub.country.num-code = 0.
DELETE ub.COUNTRY.
end.

run waitfram-hide in this-procedure .