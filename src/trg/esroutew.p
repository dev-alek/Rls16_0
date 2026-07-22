block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись маршрутизации во внешней системы.

Автор: Хныкин Павел Андреевич
Дата создания: 02/21/07
Author: Pavel Khnykin
Creation date: 02/21/07

Input:

Output:

*/

TRIGGER PROCEDURE FOR WRITE OF ub.esys-route OLD BUFFER old-esys-route .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись маршрутизации во внешней системы.".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/esallatr.i }
{ gbl/key-rec.i  }

define variable v-news as logical no-undo .
define buffer buf_esys-all-attr for ub.esys-all-attr.
define buffer buf_esys-route-dump for ub.esys-route-dump.

main-block:
do
on error  undo main-block, return error substitute("&1. error &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey")
on stop   undo main-block, return error substitute("&1. stop")
:

  if g#news and g#db-num = 0
  then do :
    assign ub.esys-route.esr-tbl-ord = next-value( s-news-ord, {&db-name_schema} ) . 
  end.    

  if false /*ub.esys-route.db-num = 0 and not g#news and not g#db-num  = 0*/
  then do:

    for each buf_esys-all-attr exclusive-lock where
            buf_esys-all-attr.table-name =  {&table_esys-route}
        and buf_esys-all-attr.key1 = ub.esys-route.esr-dump-ord
        and buf_esys-all-attr.key2 = ub.esys-route.esys-id
        and buf_esys-all-attr.key5 = ub.esys-route.db-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :



      buf_esys-all-attr.key6 = ub.esys-route.db-num.
      run str/callnews.p
        (input {&table_esys-all-attr}
        ,input (buffer buf_esys-all-attr:handle)
        ) no-error .
      if error-status:error then do:
        undo main-block, return error substitute( '&1. Ошибка при маршрутизации записи "&2" в СПН. &3&4&3&5'
                                                  ,vss-workfile
                                                  ,{&table_esys-all-attr}
                                                  ,{&new-line}
                                                  ,return-value
                                                  ,error-status :get-message ( 1 )
                                                ).

      end.
    end.
    
    for each buf_esys-route-dump exclusive-lock where
        buf_esys-route-dump.esrd-dump-ord = ub.esys-route.esr-dump-ord
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :


      buf_esys-route-dump.esrd-cr-db-num = ub.esys-route.db-num.

    end.
    
    
    
    ub.esys-route.esr-cr-db-num = ub.esys-route.db-num.
    
    run str/callnews.p
      ( input {&table_esys-route}
      , input (buffer ub.esys-route:handle)
      ) no-error .
    if error-status:error then do:
      undo main-block, return error substitute( '&1. Ошибка при маршрутизации записи "&2" в СПН. &3&4&3&5'
                                                ,vss-workfile
                                                ,{&table_esys-route}
                                                ,{&new-line}
                                                ,return-value
                                                ,error-status :get-message ( 1 )
                                              ).
    end.
    
   
  end.
  /*
  убрали хождение в ГБД рутов во внешнюю систему,
  т.к. при настроенном DATAKRAT при закрытии продаж, в новости уходили изменения остатков
  и все умирало.

  define variable v-key-rec   as character no-undo .
  define variable v-need-send as logical   no-undo .
  define variable v-compare   as logical   no-undo .

  if g#db-num > 0
    and g#news = false
  then do:
    assign
      v-need-send = true
    .

    for each buf_esys-all-attr exclusive-lock where
            buf_esys-all-attr.attr-code =  {&table_esys-route}
        and buf_esys-all-attr.key1 = ub.esys-route.esr-dump-ord
        and buf_esys-all-attr.key2 = ub.esys-route.esys-id
        and buf_esys-all-attr.key5 = ub.esys-route.db-num
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :

      run esallatr-news in this-procedure
        ( input buf_esys-all-attr.attr-code
        , output v-news
        ) .
      if v-news then do:
        run str/callnews.p
          (input {&table_esys-all-attr}
          ,input (buffer ub.esys-all-attr:handle)
          ) no-error .
        if error-status:error then do:
          undo main-block, return error substitute( '&1. Ошибка при маршрутизации записи "&2" в СПН. &3&4&3&5'
                                                    ,vss-workfile
                                                    ,{&table_esys-all-attr}
                                                    ,{&new-line}
                                                    ,return-value
                                                    ,error-status :get-message ( 1 )
                                                  ).
        end.
      end.
    end.

    if not new( ub.esys-route ) then do:
      if old-esys-route.esr-last-pack <> ub.esys-route.esr-last-pack then do:
        run gen-key-rec in this-procedure
          ( input {&table_esys-route}
          , input (buffer old-esys-route :handle)
          , output v-key-rec
          ) no-error .
        if error-status :error then do:
          undo main-block, return error substitute( "&1. Ошибка при генерации уникального ключа по таблице &2. &3&4&3&5"
                                                    ,vss-workfile
                                                    ,{&table_esys-route}
                                                    ,{&new-line}
                                                    ,return-value
                                                    ,error-status :get-message ( 1 )
                                                  ).
        end.

        run nws/cr-route.p
          ( input {&send-cmd}
          , input substitute( "command&1rename-last-pack-for-esys&1&2&1&3", {&delim-nws}, v-key-rec, ub.esys-route.esr-last-pack)
          , input ?
          , input "0":U
          ) no-error .
        if error-status:error then do:
          undo main-block, return error substitute( "&1. Ошибка при маршрутизации команды на изменение первичного ключа записи &2. &3&4&3&5"
                                                    ,vss-workfile
                                                    ,v-key-rec
                                                    ,{&new-line}
                                                    ,return-value
                                                    ,error-status :get-message ( 1 )
                                                  ).
        end.
      end.

      buffer-compare ub.esys-route except esr-last-pack to old-esys-route save result in v-compare .
      if v-compare = true then do:
        assign
          v-need-send = false
        .
      end.
    end.


    if v-need-send = true then do:
      run str/callnews.p
        ( input {&table_esys-route}
        , input ( buffer ub.esys-route:handle )
        ) no-error.
      if error-status:error then do:
        undo main-block, return error substitute( '&1. Ошибка при маршрутизации записи "&2" в СПН. &3&4&3&5'
                                                  ,vss-workfile
                                                  ,{&table_esys-route}
                                                  , {&new-line}
                                                  , return-value
                                                  ,error-status :get-message ( 1 )
                                                ).
      end.
    end.
  end.
  */

  /*а вот это непонятно зачем надо !!! - NVB*/
  /* это наверняка не надо!!! Если вдруг понадобится, то убрать коментарий */
/*  if g#oxml = yes*/
/*  then do:*/
/*    run str/calloxml.p (*/
/*          input {&nwsdochs_action_update}*/
/*        , input {&table_esys-route}*/
/*        , input ( buffer ub.esys-route:handle )*/
/*    ) no-error.*/
/*    if error-status :error*/
/*    then do:*/
/*        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"*/
/*                             , {&new-line}*/
/*                             , vss-workfile*/
/*                             , return-value*/
/*                             , error-status :get-message ( 1 ) ).*/
/*    end.*/
/*  end.*/
  return .
end.