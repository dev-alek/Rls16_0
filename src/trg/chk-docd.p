block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление записи chk-doc

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/20/05
Author: Bakhtadze Natalya
Creation date: 10/20/05

*/

TRIGGER PROCEDURE FOR DELETE OF ub.chk-doc.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление записи chk-doc".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
define variable v-is-update as logical no-undo .
define variable v-chip-num as integer no-undo .
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-gds-attr for ub.chk-gds-attr.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_chk-pay-attr for ub.chk-pay-attr .
define buffer buf_chk-discnt for ub.chk-discnt.
define buffer buf_chk-discnt-attr for ub.chk-discnt-attr.
define buffer buf_chk-doc-attr for ub.chk-doc-attr.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_marking-chk for ub.marking-chk.

_main:
do
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile ):


    if ub.chk-doc.out-code <> ? and not g#news then
    return error substitute("Чек &1 привязан к продаже &2 - удаление невозможно"
                            , ub.chk-doc.doc-code
                            , ub.chk-doc.out-code ).
    if ub.chk-doc.out-2-code <> ? and not g#news then
    return error substitute("Чек &1 привязан к док-ту &2 - удаление невозможно"
                            , ub.chk-doc.doc-code
                            , ub.chk-doc.out-2-code).
  /*создадим историю*/
    if not g#news then
    run trg/chk-doch.p (
                    buffer ub.chk-doc
                  ,input no /*p-validate*/
                  ,input no /*p-add*/
                  ,input yes /*p-del*/
                  ,input-output v-chip-num /*p-chip-num*/
                  ,output v-is-update
                  ).
    for each buf_chk-gds where
           buf_chk-gds.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-gds.
    end.
    
/*    for each buf_chk-gds-attr where                         */
/*          buf_chk-gds-attr.doc-code =  ub.chk-doc.doc-code :*/
/*        delete buf_chk-gds-attr.                            */
/*    end.                                                    */
    
    for each buf_marking-chk where
           buf_marking-chk.doc-code = ub.chk-doc.doc-code :
        delete buf_marking-chk.
    end.

    for each buf_chk-pay where
           buf_chk-pay.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-pay.
    end.
/*    for each buf_chk-pay-attr where                         */
/*           buf_chk-pay-attr.doc-code = ub.chk-doc.doc-code :*/
/*        delete buf_chk-pay-attr .                           */
/*    end.                                                    */
    for each buf_chk-discnt where
            buf_chk-discnt.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-discnt.
    end.
    for each buf_chk-discnt-attr where
            buf_chk-discnt-attr.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-discnt-attr.
    end.
/*    for each buf_chk-doc-attr where                          */
/*            buf_chk-doc-attr.doc-code = ub.chk-doc.doc-code :*/
/*        delete buf_chk-doc-attr.                             */
/*    end.                                                     */
    for each buf_chk-gds-pay where
            buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code :
        delete buf_chk-gds-pay.
    end.
    
    if g#oxml = yes
    then do:
      run str/calloxml.p (
            input {&nwsdochs_action_delete}
          , input {&table_chk-doc}
          , input ( buffer ub.chk-doc:handle )
      ) no-error.
      if error-status :error
      then do:
          undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                              , {&new-line}
                              , vss-workfile
                              , return-value
                              , error-status :get-message ( 1 ) ).
      end.
    end.
       run bge\send1cerp.p (?,
                    this-procedure,
                    this-procedure,
                    "delChk-doc",
                    (buffer chk-doc:handle),
                    (buffer c-chk-doc:handle),
                    ?) no-error.
       if error-status:error 
       then do:
          message return-value view-as alert-box.
       end.
  end.