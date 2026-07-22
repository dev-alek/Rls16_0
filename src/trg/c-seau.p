block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на изменение сезона

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 08/19/04 11:22

*/
TRIGGER PROCEDURE FOR WRITE OF ub.c-season.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на изменение сезона".
{ cmp/vssrevis.i "substitute('&1|&2|&3', ub.season.sea-code, ub.season.db-num , ub.season.sea-name) "}
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
main-block :
do transaction
on error undo main-block, return error
:
/*  if not g#news  or  ( g#news and g#db-num = 0 ) then do: */
/*    run str/callnews.p                                    */
/*      (input "c-season"                                   */
/*      ,input (buffer ub.c-season:handle)                  */
/*      ) no-error .                                        */
/*        if error-status:error then do:                    */
/*          message                                         */
/*            vss-workfile vss-revision vss-description skip*/
/*            "Ошибка при передаче в новости c-Сезона" skip */
/*            error-status :get-message(1) skip             */
/*            return-value skip                             */
/*            view-as alert-box error .                     */
/*            return error.                                 */
/*        end.                                              */
/*  end.                                                    */
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-season}
        , input ( buffer ub.c-season:handle )
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