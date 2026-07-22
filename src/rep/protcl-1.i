/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок туловища r-protcl.p

Автор: Демин Алексей Сергеевич
Дата создания: 04/13/06
Author: Alexey Demin
Creation date: 04/13/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

do:
    DISPLAY STREAM Out_Stream
                                    sym1 sym2
                                    goods.artic
                                    goods.gds-name
                                    sym9 sym7 sym8 with FRAME {1} .
    DOWN STREAM Out_Stream 1 with FRAME {1} .
end.

/* $Workfile$ e n d */