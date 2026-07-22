/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Подстановка фильтров для oxmlext.w

Автор: Мазуров Виталий Александрович
Дата создания: 11/07/11
Author: Vitaliy Mazurov
Creation date: 11/07/11

*/

(if not filt-1 = '' then
     if filt-radio = 1 then buf_init_ext-system.esys-id = int(filt-1)
     else if filt-radio = 2 then buf_init_ext-system.esys-name begins filt-1
     else if filt-radio = 3 then buf_init_ext-system.esys-db-num-imp = int(filt-1)
     else if filt-radio = 4 then buf_init_ext-system.esys-db-num-exp = int(filt-1)
     else true
 else true)

/* $Workfile$ e n d */