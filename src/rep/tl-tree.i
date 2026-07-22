/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дерево признаков для tl_tree.p и r-protcl.p

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".


def  {1}  shared    work-table  tl-tree     no-undo
    field   upper-code              like    gds-prt.upper-code
    field   node-code               like    gds-prt.node-code
    field   node-name              like    gds-prt.node-name
    field   uppernode-name     like    gds-prt.node-name
    field   price-base               like    gds-dtl.price-base
    field   price-rubl                 like    gds-dtl.price-rubl
    field   discnt-base              like    gds-dtl.discnt-base
    field   discnt-rubl               like    gds-dtl.discnt-rubl
    field   b-code                     as       char
    field   gds-amount             as      integer
    field   level-number           as      integer      /* мой номер уровня */
    field   prt-num                   like    gds-prt.prt-num
    field   gds-name                like    goods.gds-name
    field   gds-artic                  like    goods.artic
    field   LastLevel                as      logical     init    no
    .

/* $Workfile$ e n d */