/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание статусов EDI

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/02/05
*/

&if defined(cr-edist_i) = 0 &then

&glob cr-edist_i



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/cur-time.i }
{ cus/ordlnatt.i }

&glob edist_pack-num 'pack-num':U
&glob edist_pack-num-full 'Пакет'
&glob edist_route 'route':U
&glob edist_route-full 'Рут':U
&glob edist_ediinterchangeid 'ediiterchangeid':U
&glob edist_ediinterchangeid-full 'ediiterchangeid':U
&glob edist_price-up 'price-up':U
&glob edist_price-up-full 'Цена':U
&glob edist_price-down 'price-down':U
&glob edist_price-down-full 'Цена':U
&glob edist_vat-change 'vat-change':U
&glob edist_vat-change-full 'НДС':U
&glob edist_qnty-up 'qnty-up':U
&glob edist_qnty-up-full 'Кол-во':U
&glob edist_qnty-down 'qnty-down':U
&glob edist_qnty-down-full 'Кол-во':U
&glob edist_bstr-change 'bstr-change':U
&glob edist_bstr-change-full 'Штрихкод:':U
&glob edist_ps 'ps':U
&glob edist_info 'info':U
&glob edist_info-full 'Инф:':U
&glob edist_ps-full ' ':U
&glob edist_shipdate-change 'shipdate-change':U
&glob edist_shipdate-change-full 'Дата отгрузки:':U
&glob edist_clioutdoc-change 'clioutdoc-change':U
&glob edist_clioutdoc-change-full '№ заказа по пост-ку:':U





&if "{1}" = "tt" &then
define temp-table temp-edi-status no-undo
like ub.edi-status.
&endif


&if "{1}" <> "tt" &then
FUNCTION cr-edist_get-mess-mean returns character ( input p-mess as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to num-entries(p-mess, {&delim-par} ):
  v-dop = entry(v-ii, p-mess, {&delim-par} ).
  case entry(1, v-dop, "="):
    when {&edist_pack-num} then do:
      v-dop1 =  substitute("&1 &2", {&edist_pack-num-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_route} then do:
      v-dop1 =  substitute("&1 &2", {&edist_route-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_ediinterchangeid} then do:
      v-dop1 =  substitute("&1 &2", {&edist_ediinterchangeid-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_price-up} then do:
      v-dop1 =  substitute("&1 &2", {&edist_price-up-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_price-down} then do:
      v-dop1 =  substitute("&1 &2", {&edist_price-up-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_vat-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_vat-change-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_ps} then do:
      v-dop1 =  substitute("&1 &2", {&edist_ps-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_info} then do:
      v-dop1 =  substitute("&1 &2", {&edist_info-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_qnty-up} then do:
      v-dop1 =  substitute("&1 &2", {&edist_qnty-up-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_qnty-down} then do:
      v-dop1 =  substitute("&1 &2", {&edist_qnty-down-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_bstr-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_bstr-change-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_shipdate-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_shipdate-change-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_clioutdoc-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_clioutdoc-change-full}, entry(2, v-dop, "=")).
    end.
  end case. /*case entry(1, v-dop, "="):*/
  v-mess  = v-mess + (if v-mess = '' then '' else {&space-char}) + v-dop1.
end. /*do v-ii = 1 to num-entries(p-mess, {&delim-par} ):*/
return v-mess.
end function.

FUNCTION cr-edist_get-error-mean returns character ( input p-mess as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-mess as character no-undo .
do v-ii = 1 to num-entries(p-mess, {&delim-par} ):
  v-dop = entry(v-ii, p-mess, {&delim-par} ).
  case entry(1, v-dop, "="):
    when {&edist_pack-num} then do:
      v-dop1 =  substitute("&1 &2", {&edist_pack-num-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_route} then do:
      v-dop1 =  substitute("&1 &2", {&edist_route-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_ediinterchangeid} then do:
      v-dop1 =  substitute("&1 &2", {&edist_ediinterchangeid-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_price-up} then do:
      v-dop1 =  substitute("&1 &2", {&edist_price-up-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_price-down} then do:
      v-dop1 =  substitute("&1 &2", {&edist_price-up-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_vat-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_vat-change-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_ps} then do:
      v-dop1 =  substitute("&1 &2", {&edist_ps-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_info} then do:
      v-dop1 =  substitute("&1 &2", {&edist_info-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_qnty-up} then do:
      v-dop1 =  substitute("&1 &2", {&edist_qnty-up-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_qnty-down} then do:
      v-dop1 =  substitute("&1 &2", {&edist_qnty-down-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_bstr-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_bstr-change-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_shipdate-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_shipdate-change-full}, entry(2, v-dop, "=")).
    end.
    when {&edist_clioutdoc-change} then do:
      v-dop1 =  substitute("&1 &2", {&edist_clioutdoc-change-full}, entry(2, v-dop, "=")).
    end.
  end case. /*case entry(1, v-dop, "="):*/
  v-mess  = v-mess + (if v-mess = '' then '' else {&delim-par}) + v-dop1.
end. /*do v-ii = 1 to num-entries(p-mess, {&delim-par} ):*/
return v-mess.
end function.

FUNCTION cr-edist_get-mess-key-value returns character ( input p-mess as character, input p-key as character):
define variable v-ii as integer   no-undo .
define variable v-dop as character no-undo .
define variable v-dop1 as character no-undo .
define variable v-value as character no-undo .
do v-ii = 1 to num-entries(p-mess, {&delim-par} ):
  v-dop = entry(v-ii, p-mess, {&delim-par} ).
  if entry(1, v-dop, "=") = p-key then do:
    return entry(2, v-dop, "=").
  end.
end. /*do v-ii = 1 to num-entries(p-mess, {&delim-par} ):*/
return v-value.
end function.

FUNCTION cr-edist_add-edist-mess returns character ( input p-mess as character
                                                     ,input p-key as character
                                                     ,input p-value as character):
define variable v-dop as character no-undo .
define variable v-modificator as character no-undo .
assign
v-modificator = entry(2, p-key, "-") no-error .
case v-modificator:
  when "up" then do:
    v-dop = substitute("&1=&2<&3", p-key, entry(1, p-value, {&delim-par}) , entry(2, p-value, {&delim-par})).
  end.
  when "down" then do:
    v-dop = substitute("&1=&2>&3", p-key, entry(1, p-value, {&delim-par}) , entry(2, p-value, {&delim-par})).
  end.
  when "change" then do:
    v-dop = substitute("&1=&2 ->&3", p-key, entry(1, p-value, {&delim-par}) , entry(2, p-value, {&delim-par})).
  end.
  otherwise do:
    v-dop = substitute("&1=&2", p-key, p-value).
  end.
end case.
if p-mess = ''
or p-mess = ? then do:
  return v-dop .
end.
else do:
  return substitute("&1&2&3", p-mess, {&delim-par}, v-dop).
end.

end function.
&endif /*&if "{1}" <> "tt" &then*/


&if "{1}" = "tt" &then
define variable cr-edist_full-mess as longchar  no-undo .

&endif
procedure create-edi-state{1} :
define input  parameter p-tbl-name   as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-cli-type   as character no-undo .
define input  parameter p-cli-code   as integer   no-undo .
define input  parameter p-act        as character no-undo .
define input  parameter p-state      as character no-undo .
define input  parameter p-err        as integer   no-undo .
define input  parameter p-des        as character no-undo .
define input  parameter p-mess       as character no-undo .
define input  parameter p-dm         as integer  no-undo .
&if "{1}" <> "tt" &then
define input-output parameter p-date       as date no-undo .
define input-output parameter p-time       as integer no-undo .
&endif

&if "{1}" = "tt" &then
define buffer buf_EDI-status for temp-EDI-status  .
&else
define buffer buf_EDI-status for ub.EDI-status  .
&endif

define variable v-time as integer   no-undo .
define variable v-date as date   no-undo .

do
on error undo, return error return-value
:

  &if "{1}" <> "tt" &then
  if p-date = ? then do:
    run cur-time in this-procedure ( output v-date, output v-time).
  end.
  else do:
    assign
    v-date = p-date
    v-time = p-time
    .
  end.
  &endif

  find first buf_edi-status exclusive-lock where
              buf_edi-status.date-status = v-date
          and buf_edi-status.time-status = v-time
          and buf_edi-status.tbl-name    = p-tbl-name
          and buf_edi-status.doc-code    = p-doc-code no-error .
  if not available buf_edi-status  then do:
    create buf_edi-status.
  end.
  assign
  buf_edi-status.act         = p-act        .
  buf_edi-status.cli-type    = p-cli-type   .
  buf_edi-status.cli-code    = p-cli-code   .
  buf_edi-status.des-err     = buf_edi-status.des-err + (if buf_edi-status.des-err = '' then '' else {&delim-par}) + p-des        .
  buf_edi-status.doc-code    = p-doc-code   .
  buf_edi-status.err-code    = p-err        .
  buf_edi-status.mess-id     = buf_edi-status.mess-id + (if buf_edi-status.mess-id = '' then '' else {&delim-par}) + p-mess       .
  buf_edi-status.state       = p-state      .
  buf_edi-status.tbl-name    = p-tbl-name   .
  buf_edi-status.date-status = v-date       .
  buf_edi-status.time-status = v-time       .
  buf_edi-status.whole-send-news = p-dm     .
  buf_edi-status.user-name   = (if g#news then {&nts-user}
                                    else (if g#esys
                                          then {&esys-user}
                                          else g#userid)
                                    )       .
&if "{1}" <> "tt" &then
  assign
  p-date = buf_edi-status.date-status
  p-time = buf_edi-status.time-status
  .
  &else
  assign
  cr-edist_full-mess = cr-edist_full-mess +
                        (if cr-edist_full-mess = ''
                        then ''
                        else ({&carriage-return} + {&new-line})) +
                        (if num-entries(p-doc-code, {&delim-par}) > 1
                        then substitute("Товар с кодом &1: ", entry(2, p-doc-code, {&delim-par}))
                        else '') +
                        cr-edist_get-mess-mean (p-des)
  .
  &endif
end.

end procedure. /* create-edi-state */

procedure update-edi-state-light{1} :
define input  parameter p-tbl-name   as character no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-date-status as date no-undo .
define input  parameter p-time-status as integer no-undo .
define input  parameter p-state      as character no-undo .
define input  parameter p-err        as integer   no-undo .
define input  parameter p-des        as character no-undo .
define input  parameter p-mess       as character no-undo .

define buffer buf_edi-status for ub.edi-status.

do
on error undo, return error
:
  find first buf_edi-status exclusive-lock where
              buf_edi-status.date-status = p-date-status
          and buf_edi-status.time-status = p-time-status
          and buf_edi-status.tbl-name    = p-tbl-name
          and buf_edi-status.doc-code    = p-doc-code no-error .
  if available buf_edi-status  then do:
    assign
    buf_edi-status.des-err     = p-des        .
    buf_edi-status.err-code    = p-err        .
    buf_edi-status.mess-id     = p-mess       .
    buf_edi-status.state       = p-state      .
  end.
end.

end procedure. /* update-edi-state */


&endif


/* $Workfile$ e n d */