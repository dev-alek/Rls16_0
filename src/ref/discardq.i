/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/07/06
Author: Bakhtadze Natalya
Creation date: 08/07/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION get-d-pcnt RETURNS CHARACTER  ( buffer loc-dis-card for ub.dis-card,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-d-pcnt as decimal)
map to get-d-pcnt in p-parent-handle.
FUNCTION get-cash-d-pcnt RETURNS CHARACTER ( buffer loc-dis-card for ub.dis-card,
    input parhost-code as integer,
    input parobj-type as character,
    input parobj-code as integer,
    input p-discnt-role as character,
    output loc-cash-d-pcnt as decimal)
map to get-cash-d-pcnt in p-parent-handle.
FUNCTION Get-num-chk-l RETURNS integer(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-host for ub.dis-host)
map to get-num-chk-l in p-parent-handle.
FUNCTION Get-gds-sum-l RETURNS decimal(input rs-val as character
                                    , input p-pravo as logical
                                    , buffer buf_dis-host for ub.dis-host)
map to get-gds-sum-l in p-parent-handle.
FUNCTION Get-disc-sum-l RETURNS decimal(input rs-val as character
                       , input p-pravo as logical
                       , buffer buf_dis-host for ub.dis-host)
map to get-disc-sum-l in p-parent-handle.
FUNCTION Get-credit-sum-l RETURNS decimal(input rs-val as character
                      , input p-pravo as logical
                      , buffer buf_dis-host for ub.dis-host)
map to get-credit-sum-l in p-parent-handle.
FUNCTION Get-netto-sum-l RETURNS decimal(input rs-val as character
                                     , input p-pravo as logical
                                     , buffer buf_dis-host for ub.dis-host)
map to get-netto-sum-l in p-parent-handle.


/* $Workfile$ e n d */