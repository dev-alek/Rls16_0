block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: taxesi01.p $
$Archive: ref/taxesi01.p $

Сохранение изменений в карточке налога

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/18/05
Author: Bakhtadze Natalya
Creation date: 11/18/05

*/

DEFINE TEMP-TABLE tt-tax-units NO-UNDO LIKE ub.tax-units
       field is-found as logical column-label ""
       index pi is unique primary tax-code type.


define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter partax-code like ub.tax.tax-code no-undo .
define input parameter partax-name like ub.tax.tax-name no-undo .
define input parameter partax-type like ub.tax.tax-type no-undo .
define input parameter par-individual like ub.tax.individual no-undo .
define input parameter parto-cashdesk like ub.tax.to-cashdesk no-undo .
define input parameter table for tt-tax-units.


def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: taxesi01.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/taxesi01.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке налога".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
&scop num-taxes 4

DEFINE VARIABLE II AS INTEGER NO-UNDO.
define variable var-entry as character no-undo .
def var update-recid as recid no-undo.

if g#db-num > 0 then do:
  message  vss-workfile vss-revision vss-description skip
          "Вызов процедуры в УБД запрещен"
  view-as alert-box ERROR.
  return error '':U.
end.

if partax-name = "" then do:
  message "Укажите полное наименование." view-as alert-box WARNING .
  var-entry = "tax-name":U.
  return error var-entry.
end.
if partax-code = 0 or
    partax-code = ? then do:
  message "Укажите код." view-as alert-box WARNING .
  var-entry =  "tax-code":U.
  return error var-entry.
end.

if integer(partax-code) < {&num-taxes} + 1 then do:
  message "Значения кодов меньшие" ({&num-taxes} + 1) "зарезервированы," SKip
          "можно изменить только параметр отсылки на кассу"
  view-as alert-box WARNING .
end.
if par-mode = {&add-def} then do:
  if can-find( ub.tax where
               ub.tax.tax-code = integer(partax-code )) then  do:
    message "Налог с таким кодом уже есть." view-as alert-box ERROR .
    var-entry =  "tax-code":U.
    return error var-entry.
  end.
  if parto-cashdesk =  yes and
     par-individual = yes  AND
     can-find(first ub.tax No-LOCK WHERE
                    ub.tax.to-cashdesk = yes AND
                    ub.tax.individual = yes) then  do:
    message "В связи с особенностями работы POS IBM" skip
            "количество определенных в системе " skip
            "индивидуальных налогов, пересылаемых на кассу"
            "не может быть больше одного" view-as alert-box ERROR .
    var-entry =  "individual":U.
    return error var-entry.
  end.
  CREATE ub.tax.
  assign
  ub.tax.tax-code = partax-code
  ub.tax.tax-name = partax-name
  ub.tax.tax-type = if (parTAX-TYPE = {&percentive-full})
                then {&percentive}
                else {&absolute}
  ub.tax.to-cashdesk = parto-cashdesk
  ub.tax.individual = par-individual
  ub.tax.status_ = {&current-status}
  par-rid = recid( ub.tax )
  .
  for each tt-tax-units where
          tt-tax-units.tax-code = partax-code:
      if tt-tax-units.is-found then do:
        create ub.tax-units.
        assign
        ub.tax-units.tax-code = partax-code
        ub.tax-units.type = tt-tax-units.type
        .
      end.
  END.
end. /*add-def*/
if par-mode = {&update} then do:
  FIND FIRST tax where
             recid(tax) = par-rid No-ERROR.
  if error-status:error then return error '':U.
  if parto-cashdesk =  yes and
     par-individual = yes  AND
     can-find(first tax No-LOCK WHERE
                    tax.to-cashdesk = yes AND
                    tax.individual = yes AND
                    recid(tax) <> par-rid) then  do:
    message "В связи с особенностями работы POS IBM" skip
            "количество определенных в системе " skip
            "индивидуальных налогов, пересылаемых на кассу"
            "не может быть больше одного" view-as alert-box ERROR .
    var-entry =  "individual":U.
    return error var-entry.
  end.
  if  integer(partax-code) < {&num-taxes} + 1 then do:
    assign
    tax.to-cashdesk = parto-cashdesk
    par-rid = recid(tax).
  end.
  else do:
    assign
    tax.to-cashdesk = parto-cashdesk
    tax.tax-name = partax-name
    par-rid = recid(tax).
  end.
  if integer(partax-code) > {&num-taxes} + 1 then do:
    for each tt-tax-units where
            tt-tax-units.tax-code = partax-code:
      if tt-tax-units.is-found then do:
        find first ub.tax-units where
              ub.tax-units.tax-code = partax-code AND
              ub.tax-units.type= tt-tax-units.type No-ERROR.
        if not avail ub.tax-units then do:
          create ub.tax-units.
          assign
          ub.tax-units.tax-code = partax-code
          ub.tax-units.type = tt-tax-units.type
          .
        end.
      end.
      else do:
        find first ub.tax-units where
              ub.tax-units.tax-code = partax-code AND
              ub.tax-units.type= tt-tax-units.type No-ERROR.
        if avail ub.tax-units then do:
          delete ub.tax-units.
        end.
      end.
    END.
  END.
end.

return '':U.