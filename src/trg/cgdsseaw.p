block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории gds-season

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/06/04
Author: Bakhtadze Natalya
Creation date: 11/06/04

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-gds-season OLD old-c-gds-season .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории СЕЗОНА ДЛЯ ТОВАРА".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5'
                        , ub.c-gds-season.gds-code
                        , ub.c-gds-season.sea-code
                        , ub.c-gds-season.db-num
                        , ub.c-gds-season.corr-user-db-num
                        , ub.c-gds-season.chip-num
                        ) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
/*  if                                                                                    */
/*  not g#news   /*пересылаем записи  измененные ПОЛЬЗОВАТЕЛЕМ а не СПН */                */
/*  OR (g#news                                                                            */
/*      and g#db-num = 0                                                                  */
/*      and ub.c-gds-season.corr-user-name <> {&nts-user}                                 */
/*      ) /*транзит из УБД1 через ГБД в УБД2*/                                            */
/*      /*здесь надо отсечь данные которые родились в СПН в УБД и ВОЗВРАЩАЮТСЯ в ГБД!!!!*/*/
/*  or (g#news                                                                            */
/*      and ( g#db-num > 0 )                                                              */
/*      and ub.c-gds-season.corr-user-name = {&nts-user}                                  */
/*      )   /*из УБД - записи рожденные СПН*/                                             */
/*  then do:                                                                              */
/*    if not (ub.c-gds-season.gds-code = 0 or ub.c-gds-season.gds-code = ?) then do:      */
/*        run str/callnews.p                                                              */
/*                      (input {&table_c-gds-season}                                      */
/*                      ,input (buffer ub.c-gds-season:handle)                            */
/*                        ) no-error .                                                    */
/*        if error-status:error then do:                                                  */
/*          message                                                                       */
/*            vss-workfile vss-revision vss-description skip                              */
/*            "Ошибка при передаче в новости товара по c-gds-season" skip                 */
/*            error-status :get-message(1) skip                                           */
/*            return-value skip                                                           */
/*            view-as alert-box error .                                                   */
/*            undo main-block, return error.                                              */
/*        end.                                                                            */
/*    end.                                                                                */
/*  end.                                                                                  */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-gds-season}
        , input ( buffer ub.c-gds-season:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
end.