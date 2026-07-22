/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

обьявление переменных для отчета Запасы по признаками по всем объектам

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

define variable    f-qnty{1}          as decimal no-undo .
define variable    f-cost-sum{1}      as decimal no-undo .
define variable    f-sale-sum{1}      as decimal no-undo .
define variable    f-sale-other{1}    as decimal no-undo .
define variable    p-qnty{1}          as decimal no-undo .
define variable    p-cost-sum{1}      as decimal no-undo .
define variable    p-sale-sum{1}      as decimal no-undo .
define variable    p-sale-other{1}    as decimal no-undo .
define variable    l1f-qnty{1}        as character no-undo .
define variable    l1f-cost-sum{1}    as character no-undo .
define variable    l1f-sale-sum{1}    as character no-undo .
define variable    l1f-sale-other{1}  as character no-undo .
define variable    l2f-qnty{1}          as character no-undo .
define variable    l2f-cost-sum{1}      as character no-undo .
define variable    l2f-sale-sum{1}      as character no-undo .
define variable    l2f-sale-other{1}    as character no-undo .
define variable    ff-f-qnty{1}         as decimal no-undo .
define variable    ff-f-cost-sum{1}     as decimal no-undo .
define variable    ff-f-sale-sum{1}     as decimal no-undo .
define variable    ff-f-sale-other{1}   as decimal no-undo .
define variable    tf-f-qnty{1}        as decimal no-undo .
define variable    tf-f-cost-sum{1}    as decimal no-undo .
define variable    tf-f-sale-sum{1}     as decimal no-undo .
define variable    tf-f-sale-other{1}   as decimal no-undo .

define temp-table Temp-b no-undo
field grp          as character
field obj-code     like obj-list.obj-code
field obj-TYPE     like obj-list.obj-TYPE
field b-qnty       like f-qnty
field b-cost-sum   like f-cost-sum
field b-sale-sum   like f-sale-sum
field b-sale-other like f-sale-other
index PI IS PRIMARY grp obj-code  obj-type .

define temp-table Temp-I no-undo
field obj-code     like obj-list.obj-code
field obj-type     like obj-list.obj-type
field b-qnty       like f-qnty
field b-cost-sum   like f-cost-sum
field b-sale-sum   like f-sale-sum
field b-sale-other like f-sale-other
index PI IS PRIMARY obj-code  obj-type  .
.

/* $Workfile$ e n d */