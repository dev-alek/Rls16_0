/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определяет различные параметры порождаемых партий для различных типов документов

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/22/00

Различные механизмы вызова:
{1} part-rsrv-free {2} trn-doc   {3} parts.fact-qnty
{1} rsrv-code      {2} trn-doc   {3} parts.fact-qnty
{1} rsrv-free      {2} parts.out-code
{1} supp-type      {2} trn-doc
{1} supp-code      {2} trn-doc

*/

&scop param-ok no
&if "{1}" = "supp-type" &then
    &scop param-ok yes
    ( if {2}doc-type = {&income} then {2}cli-type else {2}obj-type )
&endif
&if "{1}" = "supp-code" &then
    &scop param-ok yes
    ( if {2}doc-type = {&income} then {2}cli-code else {2}obj-code )
&endif
&if "{1}" = "rsrv-code" &then
    &scop param-ok yes
    ( if (lookup({2}doc-type, {&expense_write-off}) > 0 )
      or ({2}doc-type = {&inventory} and {3} < 0)
      then {&free-code}
      else {&output-code} )
&endif
&if "{1}" = "part-rsrv-free" &then
    &scop param-ok yes
    ( (lookup({2}doc-type, {&expense_write-off}) > 0 )
      or ({2}doc-type = {&inventory} and {3} < 0))
&endif
&if "{1}" = "rsrv-free" &then
    &scop param-ok yes
   (if {2} = {&free-code} then yes else no)
&endif
&if "{&param-ok}" = "no" &then
  &message Wrong usage of partsprm.i
  &message Unknown parameter ~{1~} '{1}'
&endif
/* $Workfile$ e n d */