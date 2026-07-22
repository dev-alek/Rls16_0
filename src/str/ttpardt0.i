/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение tt для работы с номиналами МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/12/06
Author: Bakhtadze Natalya
Creation date: 04/12/06

закоментареная первая строчка для синхронизаиции c UIB

НЕ ВЫНОСИТЬ ИЗ КОММЕНТАРИЯ - РАБОТАТЬ НЕ БУДЕТ

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

*/


/*define temp-table tt-par-dtl  no-undo like ub.wth-par*/
&if "{1}" = "" &then
FIELD q-ty-doc     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во по!документу"
FIELD q-ty-fact    AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Количество!факт"
FIELD doc-sum      like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по!документу"
FIELD fact-sum     like ub.wth-line.doc-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма!факт"
FIELD sum-gds-rubl like ub.wth-line.sum-gds-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам ({&abbr_rubl})"
FIELD sum-gds-base like ub.wth-line.sum-gds-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма по связ.!товарам (баз.вал.)"
FIELD price-rubl   like ub.wth-line.price-rubl  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!({&abbr_rubl})"
FIELD price-base   like ub.wth-line.price-base  FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Цена товара!(баз.вал.)"
FIELD w-p-code     like ub.wth-dtl.w-p-code
FIELD doc-code     like ub.wth-dtl.doc-code
FIELD gds-code     like ub.wth-gds.gds-code
INDEX tt-pi    IS   PRIMARY UNIQUE par-code  w-p-code doc-code  wth-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        doc-sum  q-ty-doc

&else

FIELD q-ty-bef     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во план"
FIELD q-ty-aft     AS   DEC FORM     ">,>>>,>>>,>>>":U    COLUMN-LABEL "Кол-во факт"
FIELD sum-bef  like ub.wth-line.bef-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма план"
FIELD sum-aft  like ub.wth-line.aft-sum FORM ">,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Сумма факт"
FIELD sum-fact  like ub.wth-line.fact-sum FORM "->,>>>,>>>,>>>,>>>.<<":U COLUMN-LABEL "Расхождение"
INDEX tt-pi    IS   PRIMARY UNIQUE par-code
INDEX tt-i1                        par-feat par-unit par-val
INDEX tt-i2                        sum-bef  q-ty-bef

&endif

/* $Workfile$ e n d */