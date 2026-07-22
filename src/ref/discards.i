/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры необходимые в справочнике ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/29/05
Author: Bakhtadze Natalya
Creation date: 10/29/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable num-chk as integer no-undo.
define variable gds-sum as decimal no-undo.
define variable disc-sum as decimal no-undo.
define variable netto-sum as decimal no-undo.
define variable pay-sum as decimal no-undo.
define variable credit-sum as decimal no-undo.
define variable saldo-sum as decimal no-undo.
define variable gds-sum-ch as char no-undo.
define variable disc-sum-ch as char no-undo.
define variable netto-sum-ch as char no-undo.
define variable pay-sum-ch as char no-undo.
define variable credit-sum-ch as char no-undo.
define variable pravo as logical no-undo.
define variable smart-pravo as logical no-undo .


FUNCTION get-cli-name RETURNS CHARACTER
  (  input p-cli-type as character, input p-cli-code as integer ) :
define buffer buf_clients for ub.clients.
find first buf_clients no-lock where buf_clients.obj-type = p-cli-type
and buf_clients.obj-code = p-cli-code no-error.
if available buf_clients then return buf_clients.obj-name.
RETURN (p-cli-type + string(p-cli-code)).   /* Function return value. */
END FUNCTION.


FUNCTION Get-num-chk RETURNS CHARACTER(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-card for ub.dis-card
                                     , input p-db-num as integer
                                     ):
DEFINE variable num-chk-ch as char no-undo.
define variable loc-smart-pravo as logical no-undo .
define buffer buf_dis-host for ub.dis-host.
define buffer buf_hist-nws-option for ub.hist-nws-option.
  if NOT p-pravo then do:
      assign
      num-chk = 0
      gds-sum-ch = ""
      disc-sum-ch = ""
      netto-sum-ch = ""
      pay-sum-ch = ""
      credit-sum-ch = ""
      .
      return "Нет прав".
  end.
  IF not avail buf_dis-card then do:
      assign
      num-chk = 0
      gds-sum-ch = ""
      disc-sum-ch = ""
      netto-sum-ch = ""
      pay-sum-ch = ""
      credit-sum-ch = ""
      .
      return "".
  end.
  assign
  num-chk = 0
  gds-sum = 0
  disc-sum = 0
  netto-sum = 0
  pay-sum = 0
  credit-sum = 0
  .
  if p-db-num > 0 then do:
    find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = {&table_dis-host}
      and buf_hist-nws-option.host-code = buf_dis-card.emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = buf_dis-card.type
      and buf_hist-nws-option.subject-group = {&table_c-dc-hist} NO-ERROR.
    if available buf_hist-nws-option
    and buf_hist-nws-option.smart-nws >= 0 then loc-smart-pravo = yes.
    if loc-smart-pravo then do:
      assign
      num-chk = ?
      gds-sum = ?
      disc-sum = ?
      netto-sum = ?
      pay-sum = ?
      credit-sum = ?
      .
      return "".
    end.
  end.

  find first buf_Dis-host no-lock where
            buf_dis-host.host-code = buf_Dis-card.emitent-host-code
        and buf_dis-host.d-card = buf_Dis-card.d-card
        and buf_Dis-host.dt-code = 0 no-error.
  if not available buf_Dis-host then return "".
  IF RS-val = {&r-b-rubl} then do:
    assign
    num-chk = buf_dis-host.num-chk
    gds-sum = buf_dis-host.gds-tot-rubl
    disc-sum = buf_dis-host.gds-dis-rubl
    netto-sum = gds-sum - disc-sum
    pay-sum = buf_dis-host.pay-tot-rubl
    credit-sum = netto-sum - pay-sum
    saldo-sum = buf_dis-card.saldo-rubl.
  end.
  else do:
    assign
    num-chk = buf_dis-host.num-chk
    gds-sum = buf_dis-host.gds-tot-base
    disc-sum = buf_dis-host.gds-dis-base
    netto-sum = gds-sum - disc-sum
    pay-sum = buf_dis-host.pay-tot-base
    credit-sum = netto-sum - pay-sum
    saldo-sum = buf_dis-card.saldo-base.
  end.
  assign
  gds-sum-ch = string(gds-sum, "->>>,>>>,>>9.99")
  disc-sum-ch = string(disc-sum, "->>>,>>>,>>9.99")
  netto-sum-ch = string(netto-sum, "->>>,>>>,>>9.99")
  pay-sum-ch = string(pay-sum, "->>>,>>>,>>9.99")
  num-chk-ch = string(num-chk, "->>>>>>>9")
  credit-sum-ch = string(credit-sum, "->>>,>>>,>>9.99")
  .
  RETURN num-chk-ch.   /* Function return value. */
END FUNCTION.

FUNCTION Get-num-chk-l RETURNS integer(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-num-chk as integer
                                     , input p-type as character
                                     , input p-emitent-host-code as integer
                                     , input p-db-num as integer
                                     ):
define buffer buf_hist-nws-option for ub.hist-nws-option.
  smart-pravo = no.
  if NOT p-pravo then do:
    return 0.
  end.
  if p-db-num > 0 then do:
    find first buf_HIST-NWS-OPTION WHERE
      buf_HIST-NWS-OPTION.db-num = 0
      and buf_hist-nws-option.table-name = {&table_dis-host}
      and buf_hist-nws-option.host-code = p-emitent-host-code
      and buf_hist-nws-option.obj-type = '':U
      and buf_hist-nws-option.obj-code = 0
      and buf_hist-nws-option.key#_one = 1
      and buf_hist-nws-option.charkey_one = p-type
      and buf_hist-nws-option.subject-group = {&table_c-dc-hist} NO-ERROR.
    if available buf_hist-nws-option
    and buf_hist-nws-option.smart-nws >= 0 then smart-pravo = yes.
    else smart-pravo = no.
  end.
  if smart-pravo then return ?.
  return p-num-chk.
end FUNCTION.

FUNCTION Get-gds-sum-l RETURNS decimal(
                                       input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = {&r-b-rubl} then
  return p-gds-tot-rubl.
  else
  return p-gds-tot-base.
end FUNCTION.

FUNCTION Get-disc-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = {&r-b-rubl} then
  return p-gds-dis-rubl.
  else
  return p-gds-dis-base.
end FUNCTION.

FUNCTION Get-netto-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal):

  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = {&r-b-rubl} then
  return (p-gds-tot-rubl - p-gds-dis-rubl).
  else
  return (p-gds-tot-base - p-gds-dis-base).
end FUNCTION.

FUNCTION Get-pay-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-host for ub.dis-host):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = {&r-b-rubl} then
  return buf_dis-host.pay-tot-rubl.
  else
  return buf_dis-host.pay-tot-base.
end FUNCTION.


FUNCTION Get-credit-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , input p-gds-tot-rubl as decimal
                                     , input p-gds-tot-base as decimal
                                     , input p-gds-dis-rubl as decimal
                                     , input p-gds-dis-base as decimal
                                     , input p-pay-tot-rubl as decimal
                                     , input p-pay-tot-base as decimal):



  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = {&r-b-rubl} then
  return (p-gds-tot-rubl - p-gds-dis-rubl - p-pay-tot-rubl).
  else
  return (p-gds-tot-base - p-gds-dis-base - p-pay-tot-base).
end FUNCTION.

FUNCTION Get-saldo-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-card for ub.dis-card):
  if NOT p-pravo then do:
    return 0.0.
  end.
  if smart-pravo then return ?.
  if rs-val = {&r-b-rubl} then
  return buf_dis-card.saldo-rubl.
  else
  return buf_dis-card.saldo-base.
end FUNCTION.




/* $Workfile$ e n d */