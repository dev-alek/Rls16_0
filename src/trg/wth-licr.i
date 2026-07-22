/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на CREATE wth-line

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/26/06
Author: Bakhtadze Natalya
Creation date: 01/26/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

CREATE {1}.
ASSIGN
  {1}.doc-code     = {2}.doc-code
&IF "{3}" = "doc" &THEN
  {1}.w-p-code     = {4}
&if "{5}" <> "" &then
  {1}.out-code     = {5}
&endif

&ENDIF
  {1}.obj-type     = {2}.obj-type
  {1}.obj-code     = {2}.obj-code
  /*{1}.fact-date    = {2}.fact-date*/
  {1}.shift-date   = {2}.shift-date
  {1}.shift-num    = {2}.shift-num
  {1}.shift-name   = {2}.shift-name
  {1}.creid        = g#userid
  {1}.credate      = {6}
.

/* $Workfile$ E n d */