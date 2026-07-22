/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Контейнер для передачи данных по клиентам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/17/08
Author: Bakhtadze Natalya
Creation date: 12/17/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


define {1} temp-table clients-01 no-undo
field obj-type as character
field obj-code as integer
field grp-code as integer
field grp-name as character
field obj-name as character
field PS as character
field reg-code as integer
field src-obj-type as character
field src-obj-code as integer
field src-grp-code as integer
index pi is unique primary
src-obj-type
src-obj-code
.
define {1} temp-table firm-01 no-undo
field firm-code as integer
field src-firm-code as integer
field addres1 as character
field addres2 as character
field city as character
field contact-psn  as character
field director as character
field e-mail  as character
field engl-name  as character
field fax  as character
field gen-acct as character
field given-by  as character
field head-position as character
field ind as integer
field inn as character
field is-pboul as logical
field kpp   as character
field okonh as character
field okpo as character
field passp-num as character
field passp-ser as character
field phone1-note as character
field phone as character
field post-addr1 as character
field post-addr2 as character
field telex as character
field tobj-code as integer
index pi as unique primary
src-firm-code
.

define {1} temp-table person-01 no-undo
field psn-code as integer
field src-psn-code as integer
field address as character
field city as character
field date-birth as date
field e-mail as character
field fax as character
field firm-code as integer
field firm-name as character
field gender  as logical
field given-by as character
field ind as integer
field inn as character
field is-pboul as logical
field kpp as character
field name1 as character
field name2 as character
field okonh as character
field okpo as character
field passp-num as character
field passp-ser as character
field phone1-note as character
field phone1 as character
field position  as character
field post-box as character
index pi is unique primary
src-psn-code.

/* $Workfile$ e n d */