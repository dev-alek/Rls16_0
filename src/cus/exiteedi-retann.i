/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

временные таблицы для заполнения retann

Автор: Харитонов Владимир Александрович
Дата создания: 03/04/2013
Author: Kharitonov Vladimir
Creation date: 03/04/2013

*/

define temp-table tt-RETANN no-undo XML-NODE-NAME "RETANN"
    field NUMBER as character
    field DATE as character
    field INFO as character
    
    index pi as PRIMARY UNIQUE NUMBER
.

define temp-table tt-HEAD no-undo XML-NODE-NAME "HEAD"
    field NUMBER as character
    field SUPPLIER as character
    field BUYER as character
    field DELIVERYPLACE as character
    field SENDER as character
    field RECIPIENT as character
    
    index pi as PRIMARY UNIQUE NUMBER
.

define temp-table tt-POSITION no-undo XML-NODE-NAME "POSITION"
    field NUMBER as character
    field POSITIONNUMBER as integer
    field PRODUCT as character
    field PRODUCTIDSUPPLIER as character
    field PRODUCTIDBUYER as character
    field RETURNQUANTITY as decimal
    field RETURNQUANTITYUNIT as character
    field PRICE as decimal
    field AMOUNT as decimal
    
    index pi as PRIMARY UNIQUE NUMBER POSITIONNUMBER
.

define dataset RETANN_ for tt-RETANN, tt-HEAD, tt-POSITION
    DATA-RELATION r1 for tt-RETANN, tt-HEAD RELATION-FIELDS ( NUMBER, NUMBER ) NESTED
    DATA-RELATION r2 for tt-HEAD, tt-POSITION RELATION-FIELDS ( NUMBER, NUMBER ) NESTED 
.

/* end exiteedi-retann.i */