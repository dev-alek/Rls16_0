block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Процедура отслыки QR-кода кассиров

Автор: Шкляр Елена
Дата создания: 08.04.2024
Author:  Shklyar Elena
Creation date: 08.04.2024

*/
define variable vss-revision as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Отправка на кассу QR-код кассира".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
&Scoped-define source "1"
define variable mdb-num   as integer   no-undo.
define variable mObjType  as character no-undo.
define variable mObjCode  as integer   no-undo.
define variable mPostType as character no-undo.
define variable mCashNum  as integer   no-undo.
define stream finp.

procedure putc :
  define input  parameter iSAXWriter as handle no-undo .
  define input  parameter i-action   as character  no-undo .
  define input  parameter i-value    as character  no-undo .
  define output parameter oOK       as logical no-undo.

  define variable ii             as integer   no-undo .
  define VARIABLE name-cash      as character no-undo.
  define VARIABLE name-cash1     as character no-undo.
  define VARIABLE name-cash2     as character no-undo.
  define variable enc-passwd     as character no-undo.
  define variable ufo-passwd as character no-undo.
  define variable ufo-enc20  as character format "x(20)" no-undo.
  define variable v-shadow-fname as character no-undo .
  define buffer buf_clients for ub.clients .

  do ii = 0 to num-entries(i-value,{&comma-char}):
    FIND FIRST ub.staff-attr No-LOCK WHERE
      recid(ub.staff-attr) = integer(entry(ii,i-value,{&comma-char})) No-ERROR.
    IF avail ub.staff-attr then
    do:
      v-shadow-fname = substitute( "pass&1.dat" , string(random(1, 80000), "99999") ) .
      find first ub.staff no-lock where ub.staff.staff-code = ub.staff-attr.staff-code and
        ub.staff.role-level = ub.staff-attr.role-level and
        ub.staff.role = ub.staff-attr.role no-error .
      find first ub.person where ub.person.psn-code = ub.staff.psn-code no-error.

      iSAXWriter:start-element ("Cashier").
      iSAXWriter:insert-attribute("ctrl",  "ADD") .
      iSAXWriter:insert-attribute("tms", string(time)) .
      iSAXWriter:insert-attribute("code", string (ub.staff.psn-code)) .


      if available ub.person
        then 
      do:                       
        find FIRST buf_clients no-lock WHERE
          buf_clients.obj-type = {&prs}
          AND buf_clients.obj-code = ub.person.psn-code no-error .                                                            
        name-cash1 = if ub.person.name1 <> "" then (substring(ub.person.name1,1,1) + '.') else ''.
        name-cash2 = if ub.person.name2 <> "" then (substring(ub.person.name2,1,1) + '.') else ''.
        name-cash = buf_clients.obj-name + ' ' + name-cash1 + ' ' + name-cash2 .
      end.
      
      enc-passwd = "".
      ufo-passwd = search('exe/ufo_passwd.exe':u).
      if ufo-passwd > "" then 
      do:
        os-command silent value(ufo-passwd) value(ub.staff.password) > value(v-shadow-fname) .
        input stream finp from value(v-shadow-fname) .
        repeat:
          import stream finp unformatted ufo-enc20 no-error.
          enc-passwd = enc-passwd + ufo-enc20.
        end.
        input stream finp close.
        os-delete value(v-shadow-fname).
      end.

      iSAXWriter:write-data-element ( "CashierName", name-cash ).
      iSAXWriter:write-data-element ( "CashierParol", ub.staff.password ).
      iSAXWriter:write-data-element ( "CashierLock",  if staff.date-end < today then "1" else "0").
      iSAXWriter:write-data-element ( "CashierINN", if available person then string(person.inn) else "").
      iSAXWriter:write-data-element ( "CashierShadow", enc-passwd).
      iSAXWriter:write-data-element ( "CashierQRCode", ub.staff-attr.attr-value).
      iSAXWriter:end-element ( "Cashier").
    END.
  END.
  oOk = true .
end procedure .


 