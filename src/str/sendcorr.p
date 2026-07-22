block-level on error undo, throw.
/*

$Revision: 0207c01b556f, 2214, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:59 2019 +0300 $
$Workfile: sendcorr.p $
$Archive: str/sendcorr.p $

Отсылка данных по справочнику оснований чеков коррекции

Автор: Морозов Александр Сергеевич
Дата создания: 02/14/14
Author: Alexandr Morozov
Creation date: 02/14/14

Input:

Output:

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: 0207c01b556f, 2214, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:23:59 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendcorr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendcorr.p $":U .
define variable vss-description as character no-undo init "Отсылка данных по справочнику оснований чеков коррекции".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }


define variable p-obj-type as character no-undo .
define variable i-obj-code like ub.cash-desk.obj-code no-undo .
define variable action     as character no-undo init 'U':U.

assign
p-obj-type = entry(1, p-parameter, {&delim-par})
i-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action     = entry(3, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).

{ str/cdsnddef.i }
{ bge/bgelib.i }
{ str/cd-xml.i }

FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num AND
           (ub.cash-desk.pos-type = {&cd-type-IBM}
            AND
            ub.cash-desk.obj-code = i-obj-code)
           OR
           (ub.cash-desk.pos-type = {&cd-type-IBM-XML}
           AND
           ub.cash-desk.obj-code = i-obj-code)
            No-error.
IF not avail(cash-desk) then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!&1 справочника оснований чеков коррекций реализуется только для касс &2 &3 "
                          , (if action = "U" then "Передача" else "Удаление")
                          , {&cd-type-ibm}
                          , {&cd-type-ibm-xml}
                        )
                                        ).
  return.
end.

{ str/putc-corr.i }

/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycorr.i }

/*PROCEDURE SENDING.*/
{ str/cd-secorr.i }

RUN SENDING no-error.

if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при отсылке справочника оснований чеков коррекций на кассы &1&2"
                         , p-obj-type, i-obj-code
                        )
                                        ).
end.








