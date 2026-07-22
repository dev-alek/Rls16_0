/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на CREATE wth-doc

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

/*
{1} - имя буфера
{2} - тип документа
{3} - yes -  внутриобъектный          no - другой объект или другая фирма
{4} - внешний ли
{5} - если непусто то кладем в doc-code

*/
&scop seq {&sequence}
define variable l-in-ov{&seq} as logical no-undo .

define variable v-date{&seq} as date no-undo .
define variable v-time{&seq} as integer no-undo .

&SCOP First-Part  TRIM( STRING( NEXT-VALUE( s-wth-doc, {&db-name_schema}), ">>>>>>>>>9":U ) ) + "-"
&scop Second-Part + TRIM( STRING( parobj-code, ">>>>>>>>9":U ) ) + ~
                  SUBSTR( parobj-type, ( IF g#language = "RUS" THEN 1 ELSE 2 ), 1 )
&SCOP doc-code    {&First-Part} {&Second-Part}
run cur-time in this-procedure(output v-date{&seq}, output v-time{&seq}).

CREATE {1}.
ASSIGN
  {1}.host-code = parhost-code
&if "{5}" <> "" &then
  {1}.doc-code  = {5}
&else
  {1}.doc-code  = {&doc-code}
&endif
&IF "{2}" <> " " &THEN
   {1}.doc-type  = {2}
&ENDIF
&IF "{7}" <> " " &THEN
  {1}.ext-doc-type  = {7}
  {1}.inter_    = if  lookup({1}.ext-doc-type,{&WDEDT_Obj}) > 0 then yes else no
  {1}.exter_    = if  lookup({1}.ext-doc-type,{&WDEDT_List-external}) > 0 then yes else no
&ELSE
  {1}.inter_    = {3}
  {1}.exter_    = {4}
&ENDIF
  {1}.status_   = {&wayb}
  {1}.obj-type  = parobj-type
  {1}.obj-code  = parobj-code
  {1}.creid     = {6}
  {1}.credate   = v-date{&seq}
.
/*message    {1}.inter_  {1}.exter_  view-as alert-box.   */
if {1}.doc-type = {&inventory} or lookup({1}.ext-doc-type, {&WDEDT_List-write-off}) > 0
   or {1}.doc-type = {&declaration} then do:
  assign
    {1}.cli-type  = {&cmp}
    {1}.cli-code  = parhost-code
    .
end.
else if {1}.ext-doc-type = {&WDEDT_Put_Sale} then do: /*погашение за реализованное топливо*/
/*    find first ub.sysconf no-lock
          where ub.sysconf.host-code = parhost-code  .
    assign
    {1}.cli-type = ub.sysconf.sale-type
    {1}.cli-code = ub.sysconf.sale-code
    .  */
  assign
  {1}.cli-type  = parobj-type
  {1}.cli-code  = parobj-code
  .

end.
else if {1}.inter_  = yes
then do:
  assign
  {1}.cli-type  = parobj-type
  {1}.cli-code  = parobj-code
  .
end.
else if {1}.exter_  = yes
then do:
  assign
  {1}.cli-type  =  (if parcli-type <> "" then parcli-type else {&cmp})
  {1}.cli-code  =  (if parcli-code <> 0 then parcli-code else 0)
  .
end.
else assign
    {1}.cli-type  = parobj-type
    {1}.cli-code  = 0
.

/* $Workfile$ E n d */