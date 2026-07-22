/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дефолтное поведение browse на return

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/03
Author: Bakhtadze Natalya
Creation date: 12/02/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if b-sel:sensitive in frame {&frame-name} then dO:
    if b-mark:sensitive then do:
        apply "choose" to b-mark in frame {&frame-name}.
    end.
    else do:
        apply "choose" to b-sel in frame {&frame-name}.
    end.
end.
else do:
&if "{1}" = "" &then
&scop b-lookup b-lookup
&else
&scop b-lookup {1}
&endif
    if {&b-lookup}:sensitive then
    apply "choose" to {&b-lookup} in frame {&frame-name}.
end.

/* $Workfile$ e n d */