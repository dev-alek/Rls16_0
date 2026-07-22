/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Для load-lst.w

Автор: Демин Алексей Сергеевич
Дата создания: 04/13/06
Author: Alexey Demin
Creation date: 04/13/06

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

DO WHILE PrintCopiesCounter <> 0 :
    INPUT stream i_inp1
        FROM value ( string( session:temp-directory + InputFileName + string( g#report-num ) ) ).

    FORM with FRAME x1 .

    REPEAT on endkey undo, leave :
        DO on endkey undo, leave:
            IMPORT stream  i_inp1 UNFORMATTED text-string NO-ERROR.
        END.
        IF ERROR-STATUS:ERROR THEN
            UNDO, LEAVE.
        if integer ( asc ( substring ( text-string, 1, 1 ) ) ) = 12
           and "{1}" = "yes" then     /* = 0C (hex) = 14 (octal) */
            text-string = substring ( text-string, 2 ) .

        DISPLAY text-string no-label with width {&DOS_CW} DOWN FRAME x1 .
        DOWN WITH FRAME x1.
/*
        PUT text-string format "x(255)" SKIP .
*/
        text-string = "".
    END.
    PrintCopiesCounter = PrintCopiesCounter - 1.
    INPUT stream i_inp1 CLOSE.
END.
PrintCopiesCounter = 1.

/* $Workfile$ e n d */