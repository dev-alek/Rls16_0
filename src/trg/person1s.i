/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Call-back процедура для обеспечения вызова person1.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/19/06
Author: Bakhtadze Natalya
Creation date: 05/19/06

вставляется в процедуру вызывающую  person1.p
{1} буфер времееной таблицы like rcs-country

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */

PROCEDURE request-proc-save-staff :
DEFINE INPUT PARAMETER p-child-handle AS HANDLE NO-UNDO.
define input parameter p-mode as character no-undo .
define input parameter p-callpoint as character no-undo .
define buffer buf_tt-staff for {1}.

IF p-mode <> {&add-def}
OR LOOKUP(p-callpoint , {&role-list}) = 0 THEN RETURN.
for each buf_tt-staff :
    RUN proc-save-staff IN p-child-handle (

                                           INPUT buf_tt-staff.role
                                          ,INPUT buf_tt-staff.staff-code
                                          ,INPUT buf_tt-staff.role-level
                                          ,INPUT buf_tt-staff.db-num
                                          ,INPUT buf_tt-staff.host-code
                                          ,INPUT buf_tt-staff.obj-type
                                          ,INPUT buf_tt-staff.obj-code
                                          ,INPUT buf_tt-staff.password
                                          ,input buf_tt-staff.date-start
                                          ,input buf_tt-staff.date-end
                                          ,input buf_tt-staff.work-place
                                            ) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      UNDO, RETURN ERROR RETURN-VALUE.
    END.
END. /*for each tt-rcs-country*/
END PROCEDURE.

/* $Workfile$ e n d */