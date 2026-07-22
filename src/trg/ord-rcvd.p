block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление поставки

Автор: Чернова Светлана Александровна
Дата создания: 03/20/06
Author: Svetlana Chernova
Creation date: 03/20/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.ORD-doc-rcv .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление поставки".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }

main-block :
do transaction
on error undo main-block, return error
:

    define variable v-message as character no-undo .
    { gbl/rum-runa.i
      ?
      this-procedure:handle
      ?
        {&edoc-proc_event_rcv}
      " buffer ub.ord-doc-rcv:handle "
      ?
      ''
      ''
      no-error
      }
    if error-status:error
    then do:
      v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                              ,vss-workfile
                              ,vss-revision
                              ,vss-description
                              ,{&new-line}
                              , error-status:get-message(1)
                              , return-value ).
      if not g#news then do:
        message
        v-message
        view-as alert-box error .
      end.
      undo main-block,  return error v-message.
    end.

  /* удаление всех строк документа */
  for each ub.ord-line-rcv
    where ub.ord-line-rcv.doc-code = ub.ord-doc-rcv.doc-code and
          ub.ord-line-rcv.rcv-code = ub.ord-doc-rcv.rcv-code
  on error undo main-block, return error
  :
    delete ub.ord-line-rcv .
  end.

  /* Удаление связок от с поставками */

  for each ub.ord-chain
    where ub.ord-chain.doc-code = ub.ord-doc-rcv.rcv-code and
          ub.ord-chain.doc-type = 'rcv'
  on error undo main-block, return error
  :

    delete ub.ord-chain .
  end.

  for each ub.ord-chain
    where ub.ord-chain.rel-doc-code = ub.ord-doc-rcv.rcv-code and
          ub.ord-chain.rel-doc-type = 'rcv'
  on error undo main-block, return error
  :

    delete ub.ord-chain.
  end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_ORD-doc-rcv}
        , input ( buffer ub.ORD-doc-rcv:handle )
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
end.