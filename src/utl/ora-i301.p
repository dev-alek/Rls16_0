block-level on error undo, throw.
/*

$Revision: ae105fa20a43, 3653, test $
$Author: VSpiridonov $
$Date: 2024/01/25 16:33:07 $
$Workfile: ora-i301.p $
$Archive: utl/ora-i301.p $



Автор: Чернова Светлана Александровна
Дата создания: 10/30/09
Author: Svetlana Chernova
Creation date: 10/30/09

*/
/*

$Revision: ae105fa20a43, 3653, test $
$Author: VSpiridonov $
$Date: 2024/01/25 16:33:07 $
$Workfile: ora-i301.p $
$Archive: utl/ora-i301.p $

Импорт ДНЦ из временной таблицы

Автор: Чернова Светлана Александровна
Дата создания: 01/28/09
Author: Svetlana Chernova
Creation date: 01/28/09

*/
{ utl/tt301.i    }

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-log-handle  as handle no-undo .
define input  PARAMETER TABLE FOR  temp-price-doc.
define input  PARAMETER TABLE FOR  temp-price-list.
define output parameter p-ok-doc as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: ae105fa20a43, 3653, test $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2024/01/25 16:33:07 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ora-i301.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ora-i301.p $":U .
define variable vss-description as character no-undo init "Импорт ДНЦ из временной таблицы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/getsect.i def}
{ cmp/library.i  }
{ gbl/temphsts.i }
{ trg/factord.i  }
{ str/doc-code.i }
{ gbl/getcntxt.i def }
{ ref/xobjgrp.i  }
{ str/hvrdtax.i  }
{ str/lib-trn.i  }

define buffer buf_price-doc-forming for ub.price-doc-forming  .
{ str/alt-calc.i "func"  }
{ str/alt-calc.i "proc" "''"  "''"  }
{ str/mpl-lib.i  }
{ str/mpl-lib3.i }
{ trg/check-bc.i }
{ str/lastincs.i }
{ ref/gdsoattr.i }
{ ref/obji-ad.i  }
{ ref/typl-ad.i  }
{ gbl/waitfram.i }
{ utl/ora-icli.i }

define variable v-end-message as character no-undo .
define buffer new_price-doc for ub.price-doc  .
define variable vt-obj-type as character no-undo .
define variable vt-obj-code as integer   no-undo .


run get-db-num in parparentproc (output v-cntxt-db-num ) .
run get-userid in parparentproc (output v-cntxt-userid ) .


run main_import_proc no-error .
if error-status :error then return error return-value + error-status :get-message(1) .


procedure main_import_proc :

  do
  on error undo, return error return-value
  :
define variable  v-price-doc-recid as recid                            no-undo.
define variable  v-update          as logical                          no-undo.
define variable  v-price-sale      like ub.price-list.price-sale       no-undo.
define variable  v-counter         as integer                          no-undo.
define variable  v-counter2        as integer                          no-undo.
define variable  v-counter3        as integer                          no-undo.
define variable  v-counter-gds     as integer                          no-undo.
define variable  v-host-code       as integer   no-undo .
define variable  main-b-code       as integer   no-undo .


define variable v-sec as integer   no-undo .
define buffer buf_price-doc for ub.price-doc  .
define buffer buf_bar-code  for ub.bar-code   .
define buffer buf_goods     for ub.goods      .
define buffer buf_gds-obj   for ub.gds-obj  .

define buffer main_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer bufo_clients for ub.clients  .

   for each  temp-price-doc :
       for each temp-price-list where
                temp-price-list.line-num = temp-price-doc.line-num :
           if temp-price-list.doc-num <> temp-price-doc.doc-num then do:
              assign
                  v-end-message =  substitute("Не верно указан doc-num &1 &2  товар &3" ,
                  temp-price-list.doc-num ,
                  temp-price-doc.doc-num ,
                  temp-price-list.bar-code
                  ).
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
           end.
       end.
   end.

p-ok-doc = 0 .
create-on-object:
for each temp-price-doc
:
vt-obj-type = temp-price-doc.obj-type .
vt-obj-code = temp-price-doc.obj-code .
run ver-gtpl in this-procedure (temp-price-doc.obj-type , temp-price-doc.obj-code ) no-error .
if error-status :error then do:
            v-end-message = (error-status :get-message(1) + return-value ) .
            run pcall-log-file in p-log-handle (input  v-end-message  ) .
            undo, return error v-end-message.

end.

find first bufo_clients no-lock where
           bufo_clients.obj-type  = temp-price-doc.obj-type  and
           bufo_clients.obj-code  = temp-price-doc.obj-code no-error .
    if error-status :error then do:
            assign
             v-end-message =  substitute(" Не найден объект &1 &2 &3 &4" , temp-price-doc.obj-type , temp-price-doc.obj-code , error-status :get-message(1) , return-value )
             .
            run pcall-log-file in p-log-handle (input v-end-message) .
            undo, return error v-end-message.
    end.

    for each x_obj-group : delete x_obj-group . end.
    create x_obj-group.
    buffer-copy temp-price-doc to x_obj-group .


    { gbl/hostcode.i
      temp-price-doc.obj-type
      temp-price-doc.obj-code
      v-host-code
      }
      v-cntxt-obj-code =  temp-price-doc.obj-code.
      v-cntxt-obj-type =  temp-price-doc.obj-type.
      v-cntxt-host-code-obj =  v-host-code.

    { gbl/getsect.i run temp-price-doc.obj-type temp-price-doc.obj-code {&attr-overval} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'pr-altex' then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
        if thbjattr_thbj-attr.prop-code = 'pr-sclex' then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
        if thbjattr_thbj-attr.prop-code = 'pr-notls' then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    end.

    find first temp-price-list no-lock where
               temp-price-list.doc-num = temp-price-doc.doc-num
               no-error.
    if not available temp-price-list
    then do:
        assign
            v-end-message =  string(temp-price-doc.obj-type) + string(temp-price-doc.obj-code)
            + {&tabulation} + "Нет товаров для ДНЦ"
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        next create-on-object.
        /*undo, return error v-end-message.*/
    end.

    /* substitute("Создание ДНЦ для объекта  &1&2 " , temp-price-doc.obj-type ,temp-price-doc.obj-code)) . */
    run prcreate-new-price-doc in this-procedure
        ( input v-cntxt-db-num
        , input temp-price-doc.obj-type
        , input temp-price-doc.obj-code
        , input ?
        , input ?
        , input ?
        , input ?
        , output v-price-doc-recid
        ) no-error.
    if error-status:error
    then do:
        assign
            v-end-message =  string(temp-price-doc.obj-type) + string(temp-price-doc.obj-code) +
            error-status :get-message(1)  + return-value
            + {&tabulation} + "Ошибка при создании документа"
        .
        run pcall-log-file in p-log-handle (input v-end-message) .
        /*next create-on-object.*/
        undo, return error v-end-message.
    end.
    else do:
        find first buf_price-doc exclusive-lock
             where recid( buf_price-doc ) = v-price-doc-recid
        .
        find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.plt-id     = buf_price-doc.plt-id      and
              buf_price-doc-forming.plt-db-num = buf_price-doc.plt-db-num  and
              buf_price-doc-forming.pdf-id     = buf_price-doc.pdf-id      and
              buf_price-doc-forming.pdf-db     = buf_price-doc.pdf-db      no-error .
    end.
    assign
        v-counter = 0
        v-counter-gds = 0
    .

define buffer ver_price-doc-forming-gds for ub.price-doc-forming-gds  .

    gds-list-line-create: /* ----------------------------------------------------------------------*/
    for each temp-price-list no-lock where
             temp-price-list.doc-num = temp-price-doc.doc-num :

        if temp-price-list.gds-code <> ? and temp-price-list.gds-code <> 0
        then do :   
          find first buf_goods no-lock  where
                     buf_goods.gds-code = temp-price-list.gds-code no-error .
                      if error-status :error then do:
                        v-end-message = substitute("код товара  &1 &2" , temp-price-list.gds-code,  error-status :get-message(1) ) .
                        run pcall-log-file in p-log-handle (input v-end-message) .
                        undo, return error v-end-message.
                      end.              
          find first buf_bar-code no-lock where
                     buf_bar-code.gds-code = temp-price-list.gds-code and
                     buf_bar-code.unit-cli = buf_goods.unit-base no-error .
                     if error-status :error then do:
                       v-end-message = substitute("Товар с кодом &1 &2" , temp-price-list.gds-code,  error-status :get-message(1) ) .
                       run pcall-log-file in p-log-handle (input v-end-message) .
                       undo, return error v-end-message.
                     end.     
        end.
        else do :
          find first buf_bar-code no-lock where
                     buf_bar-code.b-code = temp-price-list.bar-code no-error .
                     if error-status :error then do:
                       v-end-message = substitute("бар-код &1 &2" , temp-price-list.bar-code,  error-status :get-message(1) ) .
                       run pcall-log-file in p-log-handle (input v-end-message) .
                       undo, return error v-end-message.
                     end.
          find first buf_goods no-lock  where
                     buf_goods.gds-code = buf_bar-code.gds-code no-error .
                      if error-status :error then do:
                        v-end-message = substitute("код товара  &1 &2" , buf_bar-code.gds-code,  error-status :get-message(1) ) .
                        run pcall-log-file in p-log-handle (input v-end-message) .
                        undo, return error v-end-message.
                      end.
        end.             
        find first  ver_price-doc-forming-gds no-lock where
                    ver_price-doc-forming-gds.plt-id     = buf_price-doc.plt-id      and
                    ver_price-doc-forming-gds.plt-db-num = buf_price-doc.plt-db-num  and
                    ver_price-doc-forming-gds.pdf-id     = buf_price-doc.pdf-id      and
                    ver_price-doc-forming-gds.pdf-db     = buf_price-doc.pdf-db      and
                    ver_price-doc-forming-gds.b-code     = buf_bar-code.b-code no-error .
        if available ver_price-doc-forming-gds then do:
           next.
        end.


        if (temp-price-doc.doc-num-ES <> ? and temp-price-doc.doc-num-ES <> "")
        or (temp-price-doc.doc-id <> ? and temp-price-doc.doc-id <> "")
        then do :
        
        end.
        else do :
          run ora-ver-goods ( buf_bar-code.gds-code )  no-error .
          if error-status :error then do:
              v-end-message = substitute(" По бар-коду &1 товар &2 &3 " , temp-price-list.bar-code , buf_bar-code.gds-code , return-value ) .   .
              run pcall-log-file in p-log-handle ( input v-end-message ) .
              undo, return error v-end-message.
          end.
        end.

          

        if buf_goods.unit-base = buf_bar-code.unit-cli then do: /* ++++++++++++++++++++++ОСНОВНОЙ КОД */
         assign
            v-counter = v-counter + 1
        .
        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input temp-price-doc.obj-type
          , input temp-price-doc.obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input v-counter
          , input buf_goods.gds-code
          , input temp-price-list.price-sale
          ) no-error.
            if error-status:error
            then do:
                v-end-message = substitute("Не удалось включить в ДНЦ товар  &1 &2 &3 &4"  , buf_goods.gds-code , buf_goods.gds-name , return-value ,  error-status :get-message(1) ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                assign
                  v-counter = v-counter - 1
                .
                /*next gds-list-line-create.*/
                undo, return error v-end-message.
            end.
        end.
    v-counter-gds = v-counter-gds  + 1.
    end.

    /* в получившейся переоценке вставить неосновные коды ТОДО */
    v-counter3 = v-counter .
    code-line-create: /* ----------------------------------------------------------------------*/
    for each temp-price-list no-lock where
             temp-price-list.doc-num = temp-price-doc.doc-num :

        if temp-price-list.gds-code <> ? and temp-price-list.gds-code <> 0
        then do :  
          find first buf_goods no-lock  where
                     buf_goods.gds-code = temp-price-list.gds-code no-error .
                      if error-status :error then do:
                        v-end-message = substitute("код товара  &1 &1" , buf_bar-code.gds-code,  error-status :get-message(1) ) .
                        run pcall-log-file in p-log-handle (input v-end-message) .
                        undo, return error v-end-message.
                      end.               
          find first buf_bar-code no-lock where
                     buf_bar-code.gds-code = temp-price-list.gds-code and
                     buf_bar-code.unit-cli = buf_goods.unit-base no-error .
                     if error-status :error then do:
                       v-end-message = substitute("Товар с кодом &1 &2" , temp-price-list.gds-code,  error-status :get-message(1) ) .
                       run pcall-log-file in p-log-handle (input v-end-message) .
                       undo, return error v-end-message.
                     end.     
        end.
        else do :
          find first buf_bar-code no-lock where
                     buf_bar-code.b-code = temp-price-list.bar-code no-error .
                     if error-status :error then do:
                       v-end-message = substitute("бар-код &1 &2" , temp-price-list.bar-code,  error-status :get-message(1) ) .
                       run pcall-log-file in p-log-handle (input v-end-message) .
                       undo, return error v-end-message.
                     end.
          find first buf_goods no-lock  where
                     buf_goods.gds-code = buf_bar-code.gds-code no-error .
                      if error-status :error then do:
                        v-end-message = substitute("код товара  &1 &1" , buf_bar-code.gds-code,  error-status :get-message(1) ) .
                        run pcall-log-file in p-log-handle (input v-end-message) .
                        undo, return error v-end-message.
                      end.
        end.
          

        if buf_goods.unit-base <> buf_bar-code.unit-cli then do: /* ++++++++++++++++++++++НЕОСНОВНОЙ КОД */
         assign
            v-counter2 = v-counter2 + 1
        .

         { gbl/gdsbcode.i
           buf_goods.gds-code
           ?
           main-b-code }
        /* если нет основного */
        find first main_price-doc-forming-gds no-lock where
                    main_price-doc-forming-gds.plt-id     = buf_price-doc.plt-id      and
                    main_price-doc-forming-gds.plt-db-num = buf_price-doc.plt-db-num  and
                    main_price-doc-forming-gds.pdf-id     = buf_price-doc.pdf-id      and
                    main_price-doc-forming-gds.pdf-db     = buf_price-doc.pdf-db      and
                    main_price-doc-forming-gds.b-code     = main-b-code no-error .
        if not available main_price-doc-forming-gds then do:
        /* теперь ругаемся во всю  !!! */
                v-end-message = substitute("Нет цены с основным кодом &3 в ДНЦ товар  &1 &2 ! "  , buf_goods.artic , buf_goods.gds-name , main-b-code ) .
                assign
                  v-counter2 = v-counter2 - 1
                .
                run pcall-log-file in p-log-handle (input v-end-message) .
                undo, return error v-end-message.
        /* !!!!! */
        /*
        /* НЕДОСТИЖИМЫЙ КОД */
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = temp-price-doc.obj-type  and
                   buf_gds-obj.obj-code = temp-price-doc.obj-code  and
                   buf_gds-obj.gds-code = buf_goods.gds-code     no-error .

        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input temp-price-doc.obj-type
          , input temp-price-doc.obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input v-counter
          , input buf_goods.gds-code
          , input ( if available buf_gds-obj and buf_gds-obj.price-sale <> 0 then buf_gds-obj.price-sale else temp-price-list.price-sale / buf_bar-code.cli-base-rate )
          ) no-error.
            if error-status:error
            then do:
                v-end-message = substitute("Не удалось включить в ДНЦ товар  &1 &2 &3 &4"  , buf_goods.gds-code , buf_goods.gds-name , return-value ,  error-status :get-message(1) ) .
                run pcall-log-file in p-log-handle (input v-end-message) .
                assign
                  v-counter2 = v-counter2 - 1
                .
                /*next code-line-create.*/
                undo, return error v-end-message.
            end.
            */

        end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = temp-price-list.bar-code no-error .
        if available buf_price-doc-forming-gds then do:
           delete buf_price-doc-forming-gds .
        end.

        v-counter3 = v-counter3 + 1 .
        run create-line-pdf-mpl-lib (
             input buf_price-doc-forming.plt-db-num
            ,input buf_price-doc-forming.plt-id
            ,input buf_price-doc-forming.pdf-db
            ,input buf_price-doc-forming.pdf-id
            ,input v-counter3
            ,input temp-price-list.bar-code
            ,input buf_goods.artic
            ,input buf_goods.prod-type
            ,input buf_goods.prod-code
            ,input ""
            ,input ?
            ,input temp-price-list.price-sale
            ,input ""
            ,input 0
            ,input-output v-sec ) no-error .
            if error-status :error then do:
               v-end-message = error-status :get-message(1)  + return-value  .
               run pcall-log-file in p-log-handle (input v-end-message) .
               undo, return error v-end-message.
            end.
    end.
    end.

    if available buf_price-doc then do:
        find first buf_price-doc-forming exclusive-lock where
              buf_price-doc-forming.plt-id     = buf_price-doc.plt-id      and
              buf_price-doc-forming.plt-db-num = buf_price-doc.plt-db-num  and
              buf_price-doc-forming.pdf-id     = buf_price-doc.pdf-id      and
              buf_price-doc-forming.pdf-db     = buf_price-doc.pdf-db      no-error .
              assign
                buf_price-doc-forming.name       = substitute("№ &1 от &2 " ,temp-price-doc.doc-num, string (temp-price-doc.doc-date , "99/99/9999" ) ) .
                buf_price-doc-forming.des        = substitute(" Товаров &1" ,v-counter-gds ).
                .
              if (temp-price-doc.doc-num-ES <> ? and temp-price-doc.doc-num-ES <> "")
              or (temp-price-doc.doc-id <> ? and temp-price-doc.doc-id <> "")
              then buf_price-doc-forming.des = temp-price-doc.doc-num-ES + {&delim-par} + temp-price-doc.doc-id + {&delim-par} + string (temp-price-doc.doc-date , "99/99/9999" ) .
       buf_price-doc.PS = "temp" .
       delete  buf_price-doc.
       .
    end.
  /* возможно понадобится закрытие до приказа */
    if temp-price-doc.doc-id = "_" /* При тираже надо закрывать переоценку до Акта (utl/load-form-15_0.w)*/
    then do :
      run str/diallog.w
          ( this-procedure
          , p-log-handle
          , if (temp-price-doc.doc-num-ES <> ? and temp-price-doc.doc-num-ES <> "")
            or (temp-price-doc.doc-id <> ? and temp-price-doc.doc-id <> "")
            then ('str/pdf-clos.p':U + {&delim-par} + '1' + {&delim-par} + '2' + {&delim-par} + '1')
            else 'str/pdf-clos.p':U
          , ( string(recid(buf_price-doc-forming)) + {&delim-par} +
             'no' + {&delim-par} +
             'no' + {&delim-par} +
             '?' +  {&delim-par} +
             '?' +  {&delim-par} +
             {&fact} + {&delim-par} +
             '?' + {&delim-par} +
             'no' + {&delim-par} +
             'no' + {&delim-par} +
             'yes'  )
          , yes /*p-auto-go*/
          , '':U
          , 'Закрытие ДНЦ') no-error .
          if error-status :error then do:
              v-end-message = error-status :get-message(1)  + return-value  .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
          end.
    end.
    else do :
      run str/diallog.w
          ( this-procedure
          , p-log-handle
          , if (temp-price-doc.doc-num-ES <> ? and temp-price-doc.doc-num-ES <> "")
            or (temp-price-doc.doc-id <> ? and temp-price-doc.doc-id <> "")
            then ('str/pdf-clos.p':U + {&delim-par} + '1' + {&delim-par} + '2' + {&delim-par} + '1')
            else 'str/pdf-clos.p':U
          , ( string(recid(buf_price-doc-forming)) + {&delim-par} +
             'no' + {&delim-par} +
             'no' + {&delim-par} +
             '?' +  {&delim-par} +
             '?' +  {&delim-par} +
             {&order} + {&delim-par} +
             '?' + {&delim-par} +
             'yes' + {&delim-par} +
             'no' + {&delim-par} +
             'yes'  )
          , yes /*p-auto-go*/
          , '':U
          , 'Закрытие ДНЦ') no-error .
          if error-status :error then do:
              v-end-message = error-status :get-message(1)  + return-value  .
              run pcall-log-file in p-log-handle (input v-end-message) .
              undo, return error v-end-message.
          end.
    end.      


        find first new_price-doc exclusive-lock where
                   new_price-doc.plt-id     = buf_price-doc-forming.plt-id       and
                   new_price-doc.plt-db-num = buf_price-doc-forming.plt-db-num   and
                   new_price-doc.pdf-id     = buf_price-doc-forming.pdf-id       and
                   new_price-doc.pdf-db     = buf_price-doc-forming.pdf-db       no-error .
       if available new_price-doc then do:
          if temp-price-doc.doc-num <> ? and temp-price-doc.doc-num <> 0
          then do :
            run add-nn (new_price-doc.doc-num , temp-price-doc.doc-num  ) no-error .
            if error-status:error then do :
                v-end-message = substitute(" Ошибка записи атрибута документа &1 &2" , error-status :get-message(1)  , return-value) .
                run pcall-log-file in p-log-handle ( input v-end-message ) .
                undo, return error v-end-message.
            end.
          end.  
          assign
            v-end-message =  string(temp-price-doc.obj-type) + string(temp-price-doc.obj-code)
            + {&tabulation} + "ПЕРЕОЦЕНКА:" + string(new_price-doc.doc-num)
          .
          run pcall-log-file in p-log-handle (input v-end-message) .
          new_price-doc.doc-num-es = temp-price-doc.doc-num-ES .
          if temp-price-doc.cmnt <> ? and trim(temp-price-doc.cmnt) <> ""
          then
          new_price-doc.ps = temp-price-doc.cmnt .
       end.

    assign
        v-end-message =  string(temp-price-doc.obj-type) + string(temp-price-doc.obj-code)
        + {&tabulation} + "№ внешней системы:"  + string(temp-price-doc.doc-num)
        + {&tabulation} + "ДНЦ:" + string(buf_price-doc-forming.pdf-id) + {&tabulation} + string( v-counter-gds ) + " товаров"
    .
     run pcall-log-file in p-log-handle (input v-end-message) .
     p-ok-doc = p-ok-doc + 1.
end.
  end.

end procedure. /* main_import_proc */


procedure add-nn :
define input  parameter p-doc-code as character no-undo .
define input  parameter p-doc-out as character no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.doc-attr exclusive-lock where
           ub.doc-attr.doc-code = p-doc-code and
           ub.doc-attr.attr-code = {&trdcattr-nids} no-error .
  if not available ub.doc-attr then create ub.doc-attr.
  assign
    ub.doc-attr.doc-code = p-doc-code
    ub.doc-attr.attr-code = {&trdcattr-nids}
    ub.doc-attr.attr-value = p-doc-out
  .
  end.

end procedure. /* add-nn */

procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

  do
  on error undo, return error return-value
  :
  define variable vt-host-code as integer   no-undo .

  { gbl/objdbnum.i
     vt-obj-type
     vt-obj-code
     p-cntxt-db-num-obj
     }

  { gbl/hostcode.i
     vt-obj-type
     vt-obj-code
     vt-host-code
     }

  assign
    p-cntxt-db-num          =  v-cntxt-db-num
    p-cntxt-userid          =  v-cntxt-userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  vt-obj-type
    p-cntxt-obj-code        =  vt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
end procedure. /* mainmenu_getcntxt */


procedure ver-gtpl :
 /* проверяет наличие и если надо создает ГОЦ и ГТПЛ для объекта 15ver  */
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .

define variable  v-plt-id        as integer   no-undo .
define variable  v-plt-db-num    as integer   no-undo .
define variable  v-col           as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable v-id     as integer   no-undo .
define variable v-db-num as integer   no-undo .
define variable v-curr-code as integer   no-undo .

define variable loc_calc-round-method  as character no-undo .
define variable loc_calc-round-base    as decimal   no-undo .
define variable loc_calc-increase-pc   as decimal   no-undo .
define variable loc_calc-method        as character no-undo .

define variable par-type as character no-undo .
define variable v-base-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable v-curr-abbr-bv as character no-undo .
define variable v-exch-rate as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-curr-abbr-vd as character no-undo .
define variable v-is-base as logical   no-undo .

define variable p-gop-id     as integer   no-undo .
define variable p-gop-db-num  as integer   no-undo .
define variable  p-recid as recid no-undo .


define buffer buf_obj-grp-obj-price for ub.obj-grp-obj-price  .
  do
  on error undo, return error return-value
  :
  &scop my-message substitute("Проверка наличия справочников ценообразования по объекту &1&2" ,  p-obj-type, p-obj-code )
  {&display-message}.

{ gbl/gtplobjq.i
  p-obj-type
  p-obj-code
  v-plt-id
  v-plt-db-num
  v-col
  no-error }

if error-status :error or v-col  >= 1 then return .
v-id = 0.
  find first buf_obj-grp-obj-price no-lock where
             buf_obj-grp-obj-price.stts = 0 and
             buf_obj-grp-obj-price.obj-type = p-obj-type and
             buf_obj-grp-obj-price.obj-code = p-obj-code no-error .
  if available buf_obj-grp-obj-price then do:
      assign
      v-id     = buf_obj-grp-obj-price.gop-id
      v-db-num = buf_obj-grp-obj-price.gop-id
    .
  end.


  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/basecode.i  v-host-code   v-base-code }
  { gbl/r-b-curr.i  v-host-code   v-curr-code  }
  { gbl/exchrate.i v-base-code TODAY v-base-rate v-base-scale v-curr-abbr-bv }
  { gbl/exchrate.i v-curr-code TODAY v-exch-rate v-exch-scale v-curr-abbr-vd }
  { gbl/getsect.i run p-obj-type p-obj-code {&attr-overval} }
  for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-incpc} then loc_calc-increase-pc = thbjattr_thbj-attr.property-value-decimal .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndmt} then loc_calc-round-method = thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = {&attr-overval_pr-rndbs} then loc_calc-round-base = thbjattr_thbj-attr.property-value-decimal .
  end.
  case loc_calc-round-method:
    when "pr-round-9end" then
      loc_calc-round-method = {&pr-round-9end}.
    when "pr-round-9-99end" then
      loc_calc-round-method = {&pr-round-9-99end}.
    when "pr-round-integer" then
      loc_calc-round-method = {&pr-round-integer}.
    when "pr-round-select" then
      loc_calc-round-method = {&pr-round-select}.
    when "pr-round-up" then
      loc_calc-round-method = {&pr-round-up}.
    when "pr-round-coef" then
      loc_calc-round-method = {&pr-round-coef}.
    when "pr-round-off" then
      loc_calc-round-method = {&pr-round-off}.
    otherwise
      loc_calc-round-method = {&pr-round-off}.
  end case.


{ gbl/rbisbase.i v-is-base }
loc_calc-method = {&pr-calc-no}.

do transaction :

if p-gop-id = 0 then do: /* если нет группы объектов */
    assign
      p-gop-id = next-value ( s-gop , {&db-name_schema} )
      p-gop-db-num =  v-cntxt-db-num
      .

    create ub.grp-obj-price.
    assign
      ub.grp-obj-price.gop-db-num   = p-gop-db-num
      ub.grp-obj-price.gop-id       = p-gop-id
      ub.grp-obj-price.db-num-chg   = v-cntxt-db-num
      ub.grp-obj-price.stts         = 0
      ub.grp-obj-price.sys-date     = today
      ub.grp-obj-price.sys-time     = time
      ub.grp-obj-price.sys-time-chr = string(ub.grp-obj-price.sys-time,"hh:mm")
      ub.grp-obj-price.who          = v-cntxt-userid
      ub.grp-obj-price.name-group   = "По объекту " + p-obj-type + string ( p-obj-code )
      .
      run  objo-ADD (
        input  p-gop-db-num  ,
        input  p-gop-id            ,
        input  p-obj-type  ,
        input  p-obj-code  ,
        input  0               ,
        input  v-cntxt-db-num  ,
        input  v-cntxt-userid  ,
        output p-recid ) .
end.
/* ГТПЛ */
find first ub.price-list-type no-lock where
           ub.price-list-type.main = true and
           ub.price-list-type.gop-id = p-gop-id and
           ub.price-list-type.gop-db-num = p-gop-db-num and
           ub.price-list-type.stts       = 0 and
           ub.price-list-type.only-gbd = integer ( true ) and
           ub.price-list-type.plt-db-num = v-cntxt-db-num no-error .
    if available ub.price-list-type then do:
       v-plt-id = ub.price-list-type.plt-id .
    end.
    else do:
    v-plt-id = next-value (s-plt, {&db-name_schema})  .
        run type-price-list-ADD (
            v-cntxt-db-num                                    /*p-db-num                       */
          , v-plt-id                                          /*p-id                           */
          , "ГТПЛ по объекту " + p-obj-type + string (p-obj-code) /*p-name                         */
          , 0                                                 /*p-ban-discnt                   */
          , loc_calc-round-method                             /*p-calc-round-method            */
          , loc_calc-round-base                               /*p-calc-round-base              */
          , loc_calc-increase-pc                              /*p-calc-increase-pc             */
          , loc_calc-method                                   /*p-calc-method                  */
          , int ( true )                                      /*p-create-price-doc             */
          , false                                             /*p-fix-cource-crc-base          */
          , false                                             /*p-fix-cource-crc-doc           */
          , int ( false )                                     /*p-have-rs-qnty-group           */
          , false                                             /*p-have-rs-sum-group            */
          , true                                              /*p-main                         */
          , int ( true  )                                     /*p-only-gbd                     */
          , v-cntxt-db-num                                    /*p-plt-main-db-num              */
          ,  ?                                                /*p-plt-main-id                  */
          ,  0                                                /*p-priority                     */
          ,  0                                                /*p-rs-buyer                     */
          ,  true                                             /*p-send-cassa                   */
          ,  int  ( true  )                                   /*p-under-hand-corr              */
          ,  ?                                                /*p-under-round-method           */
          ,  ?                                                /*p-under-perc                   */
          ,  int ( false )                                    /*p-under-type-list              */
          ,  0                                                /*p-use-cassa                    */
          ,  int ( false )                                    /*p-use-gds-group                */
          ,  2                                                /*p-use-obj                      */
          ,  0                                                /*p-work-date                    */
          ,  v-cntxt-db-num                                   /*p-bgr-db-num                   */
          ,  ?                                                /*p-bgr-id                       */
          ,  v-curr-code                                      /*p-curr-code                    */
          ,  p-gop-db-num                                     /*p-gop-db-num                   */
          ,  v-cntxt-db-num                                   /*p-gop-db-num-for-calc-turnover */
          ,  p-gop-id                                         /*p-gop-id                       */
          ,  ?                                                /*p-gop-id-for-calc-turnover     */
          ,  v-cntxt-db-num                                   /*p-qgr-db-num                   */
          ,  ?                                                /*p-qgr-id                       */
          ,  v-cntxt-db-num                                   /*p-sgr-db-num                   */
          ,  ?                                                /*p-sgr-id                       */
          ,  v-cntxt-db-num                                   /*p-tog-db-num                   */
          ,  ?                                                /*p-tog-id                       */
          ,  ?                                                /*p-obj-turnover                 */
          ,  v-cntxt-db-num                                   /*p-ttg-summa                    */
          ,  v-cntxt-userid                                   /*p-userid                       */
          ,  v-cntxt-db-num                                   /*p-db-num-usr                   */
          ,  int( false )                                     /*p-have-rs-turn-group           */
          ,  0                                                /*p-have-tog-db-num              */
          ,  ?                                                /*p-have-tog-id                  */
          ,  int( false  )                                    /*p-use-cash-pay                 */
          ,  int( false  )                                    /*p-use-pay-type                 */
          ,  output p-recid                                   /*p-recid                        */
          ,  input table TT_cassa                             /*table for tt_cassa .*/
          ,  input table TT_grp                               /*table for tt_grp   .*/
          ,  input table TT_pay-type                          /*table for tt_pay-type .*/
          ,  input table TT_cash-pay                          /*table for tt_cash-pay .*/
          ) no-error .
          find first ub.price-list-type no-lock where recid(ub.price-list-type) =  p-recid no-error .
          &scop my-message substitute("Создан  &3 (№ &4 ) &1 &2" , error-status :get-message(1) , return-value , ub.price-list-type.name , ub.price-list-type.plt-id)
          {&display-message}.
     end.
end.
end.
end procedure.

procedure get-userid :
define output parameter v-cntxt-userid  as character no-undo .

  do
  on error undo, return error return-value
  :
     run get-userid in parparentproc (output v-cntxt-userid ) .
  end.

end procedure. /* get-userid */

procedure get-db-num :
define output parameter v-cntxt-db-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
   run get-db-num in parparentproc (output v-cntxt-db-num ) .
  end.

end procedure. /* get-db-num */