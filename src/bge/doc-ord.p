block-level on error undo, throw.
/*

$Revision: 9b43ebeef021, 979, rls $
$Author: AAShepel $
$Date: Mon Jun 19 10:51:53 2017 +0300 $
$Workfile: doc-ord.p $
$Archive: bge/doc-ord.p $

Экспорт заказов

Автор: Хныкин Павел Андреевич
Дата создания: 02/05/09
Author: Pavel Khnykin
Creation date: 02/05/09

*/

define input parameter p-inc-export      as logical     no-undo.
define input parameter p-host-code       as integer     no-undo.
define input parameter p-obj-type        as character   no-undo.
define input parameter p-obj-code        as integer     no-undo.
define input parameter p-date-from       as date        no-undo.
define input parameter p-date-to         as date        no-undo.
define input parameter p-doc-type        as character   no-undo.
define input parameter p-status-list     as character   no-undo.
define input parameter sOutFile          as character   no-undo.
define input parameter sLogFile          as character   no-undo.
define input parameter p-parent-handle   as handle      no-undo.
define input parameter hEDT              as handle      no-undo.
define input parameter hCNT              as handle      no-undo.
define input parameter p-doc-code        as character   no-undo.

define variable vss-revision    as character no-undo init "$Revision: 9b43ebeef021, 979, rls $":U .
define variable vss-author      as character no-undo init "$Author: AAShepel $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 19 10:51:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-ord.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/doc-ord.p $":U .
define variable vss-description as character no-undo init "Экспорт заказов".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bge-xml.i  }
{ str/lib-trn.i  }

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )

define variable v-host-code         as integer   no-undo.
define variable v-base-code         as integer   no-undo.
define variable v-base-code-okv     as integer   no-undo.
define variable v-ora-exp-seq-num   as integer   no-undo.

main-block:
do
on error undo, return error return-value
:
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  run get-base-code-okv in this-procedure ( input v-base-code
                                          , output v-base-code-okv
                                          ).

  assign
    v-bge-xml-log-file-name = sLogFile
  .
  run bge-xml-read-config in this-procedure ( input ?
                                            , input ?
                                            ).
  run wp-XMLWriteCNT in this-procedure ( hCNT, "" ).
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    run export-documents in this-procedure .
  end.
end.


procedure export-documents :

  define variable v-status            as character no-undo .
  define variable v-num-status        as integer   no-undo .
  define variable v-i                 as integer   no-undo .

  define buffer buf_ord-doc for ub.ord-doc.
  define buffer sch_ord-doc for ub.ord-doc.

do for buf_ord-doc
on error undo, return error return-value
:
  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                       , input 1
                                       , input 'Выгрузка заказов...':u
                                       ).
  run wp-XMLWriteEDT in this-procedure ( hEDT, 8, "Операция заказы Объект-Поставщик" ).

  /* выгрузка по коду документа */
  if p-doc-code <> ?
  then do:

    find first buf_ord-doc no-lock
      where buf_ord-doc.doc-code = p-doc-code
    no-error .
    if available buf_ord-doc
    then do:
      if v-bge-xml-bgeflold = "oracle":u
      then do:
        /*
          для Oracle проверяем код внешнего документа? если есть то это документ из ORA не выгружаем его

        */
        if not ( buf_ord-doc.cons-code = ? or buf_ord-doc.cons-code = '' )
        then do:
          return . /* --->>>--- */
        end.
      end.
      run export-document in this-procedure ( input buf_ord-doc.doc-code , output v-ora-exp-seq-num ) no-error .
      if error-status :error
      then do:
        run wp-XMLWriteLog in this-procedure ( input sLogFile
                                              , input 1
                                              , input substitute( "Ошибка экспорта документа заказа. Номер документа: &1. &2. &3 &4 "
                                                                , buf_ord-doc.doc-code
                                                                , return-value
                                                                , trim(error-status :get-message(1))
                                                                , trim(error-status :get-message(2))
                                                                )
                                              ).
        undo, return error return-value. /* --->>>--- */
      end.
      if v-bge-xml-bgeflold = "oracle":u
      then do:
        run bge/setbgedt.p ( input {&table_ord-doc}
                          , input buf_ord-doc.doc-code
                          , input today
                          ).
      end.
      else do:
        /* Пометить выгруженные  */
        run run-callback-write-doc-code in this-procedure ( input p-parent-handle
                                                          , input {&table_ord-doc}
                                                          , input buf_ord-doc.doc-code
                                                          , input sLogFile
                                                          ).
      end.
    end.
    return . /* --->>>--- */
  end.

  assign
    v-num-status = num-entries(p-status-list)
  .

  _status-list:
  do v-i = 1 to v-num-status
  :
    assign
      v-status = entry( v-i , p-status-list )
    .
    if p-inc-export = yes
    then do:
      _export-ord-doc-incr:
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type    = p-obj-type
          and buf_ord-doc.obj-code    = p-obj-code
          and buf_ord-doc.doc-type    = p-doc-type
          and buf_ord-doc.status_     = v-status
          and buf_ord-doc.ord-date1   = ?
      on error undo, return error
      :

        find first sch_ord-doc share-lock
          where sch_ord-doc.doc-code = buf_ord-doc.doc-code
        no-wait
        no-error.
        if not available sch_ord-doc
        then do:
          next _export-ord-doc-incr.
        end.

        if v-bge-xml-bgeflold = "oracle":u
        then do:
          /*
            для Oracle проверяем код внешнего документа? если есть то это документ из ORA не выгружаем его

          */
          if not ( sch_ord-doc.cons-code = ? or sch_ord-doc.cons-code = '' )
          then do:
            next _export-ord-doc-incr.
          end.
        end.
        run export-document in this-procedure ( input sch_ord-doc.doc-code , output v-ora-exp-seq-num ) no-error .
        if error-status :error
        then do:
          run wp-XMLWriteLog in this-procedure ( input sLogFile
                                               , input 1
                                               , input substitute( "Ошибка экспорта документа заказа. Номер документа: &1. &2. &3 &4 "
                                                                 , buf_ord-doc.doc-code
                                                                 , return-value
                                                                 , trim(error-status :get-message(1))
                                                                 , trim(error-status :get-message(2))
                                                                 )
                                               ).
          if v-bge-xml-bgeflold = "oracle":u
          then do:
            undo _export-ord-doc-incr, return . /* --->>>--- */
          end.
          else do:
            undo _export-ord-doc-incr, next _export-ord-doc-incr.
          end.
        end.
        if v-bge-xml-bgeflold = "oracle":u
        then do:
          run bge/setbgedt.p ( input {&table_ord-doc}
                             , input buf_ord-doc.doc-code
                             , input today
                             ).
        end.
        else do:
          /* Пометить выгруженные  */
          run run-callback-write-doc-code in this-procedure ( input p-parent-handle
                                                            , input {&table_ord-doc}
                                                            , input buf_ord-doc.doc-code
                                                            , input sLogFile
                                                            ).
        end.
      end. /* for each buf_ord-doc no-lock */
    end. /* if p-inc-export = yes */
    else do:
      _export-ord-doc:
      for each buf_ord-doc no-lock
        where buf_ord-doc.obj-type   = p-obj-type
          and buf_ord-doc.obj-code   = p-obj-code
          and buf_ord-doc.doc-type   = p-doc-type
          and buf_ord-doc.status_    = v-status
          and buf_ord-doc.fact-date >= p-date-from
          and buf_ord-doc.fact-date <= p-date-to
      on error undo, return error
      :
        if v-bge-xml-bgeflold = "oracle":u
        then do:
          /*
            для Oracle проверяем код внешнего документа? если есть то это документ из ORA не выгружаем его

          */
          if not ( buf_ord-doc.cons-code = ? or buf_ord-doc.cons-code = '' )
          then do:
            next _export-ord-doc.
          end.
          _export-block:
          do transaction
          on error undo _export-block, return error return-value
          :
            run export-document in this-procedure ( input buf_ord-doc.doc-code , output v-ora-exp-seq-num ) no-error .
            if error-status :error
            then do:
              run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                  , input 1
                                                  , input substitute( "Ошибка экспорта документа заказа. Номер документа: &1. &2. &3 &4 "
                                                                    , buf_ord-doc.doc-code
                                                                    , return-value
                                                                    , trim(error-status :get-message(1))
                                                                    , trim(error-status :get-message(2))
                                                                    )
                                                  ).
              undo _export-block, leave _export-ord-doc.
            end.
          end.
        end.
        else do:
          run export-document in this-procedure ( input buf_ord-doc.doc-code , output v-ora-exp-seq-num ) no-error .
          if error-status :error
          then do:
            run wp-XMLWriteLog in this-procedure ( input sLogFile
                                                , input 1
                                                , input substitute( "Ошибка экспорта документа заказа. Номер документа: &1. &2. &3 &4 "
                                                                  , buf_ord-doc.doc-code
                                                                  , return-value
                                                                  , trim(error-status :get-message(1))
                                                                  , trim(error-status :get-message(2))
                                                                  )
                                                ).
            undo _export-ord-doc, next _export-ord-doc.
          end.
        end.
      end. /* for each buf_ord-doc no-lock  */
    end. /* if p-inc-export = no */
  end. /* _status-list: */
end.
end procedure. /* export-documents */

/*==========================================================================*/
procedure export-document :
  define input  parameter p-doc-code        as character no-undo .
  define output parameter p-ora-exp-seq-num as integer   no-undo .

  define buffer buf_ord-doc   for ub.ord-doc.
  define buffer buf_ord-line  for ub.ord-line.

  define variable v-obj-list         as character   no-undo .
  define variable v-doc-type         as character   no-undo .
  define variable v-exp-ora-filename as character   no-undo .
  define variable v-fact-date        as date        no-undo .
  define variable v-fact-order       as decimal     no-undo .

do for  buf_ord-doc
      , buf_ord-line
on error undo, return error return-value
:
  find first buf_ord-doc no-lock
    where buf_ord-doc.doc-code = p-doc-code
  no-error .
  if not available buf_ord-doc
  then do:
    undo, return error substitute( "Не найден заказ с кодом &1" , p-doc-code ). /* --->>>--- */
  end.

  assign
    v-fact-date = buf_ord-doc.fact-date
  .
  run wp-XMLWriteCnt( hcnt, "   " + string( p-doc-code ) + " от " + string( v-fact-date ) ) .
  assign
    v-obj-list = substitute( "&1,&2" , p-obj-type , p-obj-code )
  .

  run bge-xml-ora-exp-filename in this-procedure ( input {&table_ord-doc}
                                                 , input p-doc-code
                                                 , input p-obj-code
                                                 , output v-exp-ora-filename
                                                 , output p-ora-exp-seq-num
                                                 ) .
  run convert-doc-type in this-procedure ( input p-doc-type
                                         , output v-doc-type
                                         ).
  run bge-xml-write-header in this-procedure (
        input v-exp-ora-filename
      , input v-exp-ora-filename + "xml"
      , input {&version-string}
      , input 0
      , input p-date-from
      , input 0
      , input p-date-to
      , input 0
      , input v-obj-list
      , input v-doc-type
      , input no
      , input no
      , input no
      , input no
      , input no
      , input no
      , input no
      , input no
  ).
  output stream stmxmlout to value( v-exp-ora-filename + "xm1" ) convert target "1251" append.
  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                       , input 1
                                       , input substitute( "Выгрузка документа &1 в пакет &2."
                                                         , buf_ord-doc.doc-code
                                                         , v-exp-ora-filename + "xml"
                                                         )
                                       ).
  run export-header in this-procedure ( p-doc-code ) .
  run export-doc-lines in this-procedure (p-doc-code) .
  run wp-xmltagclose in this-procedure ( 2, "operation" ).
  output stream stmxmlout close.
  run xml-bge-write-footer in this-procedure ( input v-exp-ora-filename ).
  run wp-XMLWriteLog in this-procedure ( input sLogFile
                                       , input 1
                                       , input substitute( "Выгрузка документа &1 в пакет &2 завершена."
                                                         , buf_ord-doc.doc-code
                                                         , v-exp-ora-filename + "xml"
                                                         )
                                       ).


end.

end procedure. /* export-document */

/*==========================================================================*/
procedure export-header :
  define input parameter p-doc-code as character        no-undo.

  define buffer buf_ord-doc for ub.ord-doc.

  define variable v-doc-type        as character no-undo.
  define variable v-fact-date       as date      no-undo.
  define variable v-fact-time       as integer   no-undo.
  define variable v-fact-order      as decimal   no-undo.
  define variable v-sys-date        as date      no-undo.
  define variable v-sys-time        as character no-undo.
  define variable v-doc-date        as date      no-undo.
  define variable v-shift-date      as date      no-undo.
  define variable v-shift-num       as integer   no-undo.
  define variable v-shift-name      as character no-undo.
  define variable v-temp-char       as character no-undo.
  define variable v-reason-code     as integer   no-undo.
  define variable v-doc-exch-code   as integer   no-undo.
  define variable v-doc-exch-rate   as decimal   no-undo.
  define variable v-doc-exch-scale  as integer   no-undo.


do for buf_ord-doc
on error undo, return error return-value
:
  find first buf_ord-doc share-lock
    where buf_ord-doc.doc-code = p-doc-code
  no-error .
  if not available buf_ord-doc
  then do:
    undo, return error substitute( "Не найден заказ с кодом &1" , p-doc-code ). /* --->>>--- */
  end.

  run fill_bge-xml_clients in this-procedure ( input p-parent-handle
                                             , input buf_ord-doc.cli-type
                                             , input buf_ord-doc.cli-code
                                             ).

  run convert-doc-type in this-procedure ( input p-doc-type
                                         , output v-doc-type
                                         ).
  assign
    v-fact-order      = buf_ord-doc.fact-order
    v-sys-date        = buf_ord-doc.sys-date
    v-sys-time        = buf_ord-doc.sys-time
    v-doc-date        = buf_ord-doc.doc-date
    v-fact-date       = buf_ord-doc.fact-date
    v-fact-time       = buf_ord-doc.fact-time
    v-doc-exch-code   = buf_ord-doc.exch-code
    v-doc-exch-rate   = buf_ord-doc.exch-rate
    v-doc-exch-scale  = buf_ord-doc.exch-scale
  .
  { str/shiftnam.i
      buf_ord-doc.obj-type
      buf_ord-doc.obj-code
      v-shift-date
      v-shift-num
      v-shift-name
      v-temp-char
      no-error
  }
  run wp-xmltagopen in this-procedure ( 2, "operation","" ).
  run wp-xmltagput in this-procedure ( 3, "referenceNo",        string( p-doc-code                   ), 1 ).
  run wp-xmltagput in this-procedure ( 3, "codeOperation",      string( v-doc-type                   ), 1 ).
  run wp-xmltagput in this-procedure ( 3, "host",               string( p-host-code                  ), 1 ).
  run wp-xmltagput in this-procedure ( 3, "store",              p-obj-type + string( p-obj-code )     , 1 ).
  run wp-xmltagput in this-procedure ( 3, "factOrder",          string( v-fact-order )                , 1 ).
  run wp-xmltagput in this-procedure ( 3, "sysDate",            string(v-sys-date , "99.99.9999")     , 0 ).
  run wp-xmltagput in this-procedure ( 3, "sysDateXml",         bge-xml-date( v-sys-date )            , 0 ).
  run wp-xmltagput in this-procedure ( 3, "sysTime",            string( v-sys-time )                  , 1 ).
  run wp-xmltagput in this-procedure ( 3, "dateDoc",            string( v-doc-date , "99.99.9999" )   , 1 ).
  run wp-xmltagput in this-procedure ( 3, "dateDocXml",         bge-xml-date( v-doc-date )            , 1 ).
  run wp-xmltagput in this-procedure ( 3, "dateFact",           string( v-doc-date , "99.99.9999")    , 1 ).
  run wp-xmltagput in this-procedure ( 3, "dateFactXml",        bge-xml-date( v-doc-date )            , 1 ).
  run wp-xmltagput in this-procedure ( 3, "timeFact",           string( v-fact-time, "hh:mm:ss"      ), 1 ).
  run wp-xmltagput in this-procedure ( 3, "shiftDate",          string( v-shift-date , "99.99.9999")  , 0 ).
  run wp-xmltagput in this-procedure ( 3, "shiftDateXml",       bge-xml-date( v-shift-date )          , 0 ).
  run wp-xmltagput in this-procedure ( 3, "shiftNum",           string( v-shift-num                  ), 0 ).
  run wp-xmltagput in this-procedure ( 3, "shiftName",          string( v-shift-name                 ), 0 ).
  run wp-xmltagput in this-procedure ( 3, "valutCode",          string( v-base-code                  ), 1 ).
  run wp-xmltagput in this-procedure ( 3, "valutCodeOKV",       string( v-base-code-okv              ), 1 ).
  run wp-xmltagput in this-procedure ( input 3, input "exchCode" , input string( v-doc-exch-code                     ), input 1 ).
  run wp-xmltagput in this-procedure ( input 3, input "exchRate" , input string( v-doc-exch-rate                     ), input 1 ).
  run wp-xmltagput in this-procedure ( input 3, input "exchScale", input string( v-doc-exch-scale                    ), input 1 ).

  run wp-xmltagput in this-procedure ( 3, "firm",                 buf_ord-doc.cli-type + string( buf_ord-doc.cli-code ), 1 ).
  run wp-xmltagput in this-procedure ( 3, "outDate",              string( buf_ord-doc.ship-date , "99.99.9999")    , 0 ).
  run wp-xmltagput in this-procedure ( 3, "outDateXml",           bge-xml-date( buf_ord-doc.ship-date )            , 0 ).
  run wp-xmltagput in this-procedure ( 3, "paymentCode",          string( buf_ord-doc.pay-code                    ), 0 ).
  run wp-xmltagput in this-procedure ( input 3, input "reasonCode"   , input string( v-reason-code )  , input 0 ).
  run wp-xmltagput in this-procedure ( input 3, input "outCode"      , input buf_ord-doc.out-code     , input 0 ).
  run wp-xmltagput in this-procedure ( input 3, input "comment"      , input buf_ord-doc.PS           , input 1 ).
  run wp-xmltagput in this-procedure ( input 3, input "ordOutDocCode", input buf_ord-doc.cons-code    , input 1 ).

  run wp-xmltagopen in this-procedure ( 3, "docSum","" ).
  run wp-xmltagput in this-procedure ( 4, "sumr"      , string( buf_ord-doc.sum-rubl ), 1 ).
/*  run wp-xmltagput in this-procedure ( 4, "VATr"      , string( abs( buf_ot-tot.vat-rubl       ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "SLTr"      , string( abs( buf_ot-tot.slt-rubl       ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "roadTaxr"  , string( abs( buf_ot-tot.road-tax-rubl  ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "transportr", string( abs( buf_ot-tot.transport-rubl ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "otherr"    , string( abs( buf_ot-tot.other-rubl     ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "exciser"   , string( abs( buf_ot-tot.excise-rubl    ) ), 2 ).*/
  run wp-xmltagput in this-procedure ( 4, "sumb"      , string( buf_ord-doc.sum-base ), 1 ).
/*  run wp-xmltagput in this-procedure ( 4, "VATb"      , string( abs( buf_ot-tot.vat-base       ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "SLTb"      , string( abs( buf_ot-tot.slt-base       ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "roadTaxb"  , string( abs( buf_ot-tot.road-tax-base  ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "transportb", string( abs( buf_ot-tot.transport-base ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "otherb"    , string( abs( buf_ot-tot.other-base     ) ), 2 ).*/
/*  run wp-xmltagput in this-procedure ( 4, "exciseb"   , string( abs( buf_ot-tot.excise-base    ) ), 2 ).*/
  run wp-xmltagclose in this-procedure ( 3, "docSum" ).
end.

end procedure. /* export-header */

/*==========================================================================*/
procedure export-doc-lines :
  define input  parameter p-doc-code as character no-undo .

  define buffer buf_ord-line for ub.ord-line.
do for buf_ord-line
on error undo, return error return-value
:
  for each buf_ord-line no-lock
    where buf_ord-line.doc-code = p-doc-code
  on error undo, return error return-value
  :
    run wp-xmltagopen( 3, "linedoc", "" ).
    run export-doc-line in this-procedure ( input buf_ord-line.doc-code
                                          , input buf_ord-line.artic
                                          , input buf_ord-line.prod-type
                                          , input buf_ord-line.prod-code
                                          ) .
    run wp-xmltagclose( 3, "linedoc" ).
  end. /* for each buf_ord-line no-lock  */
end.

end procedure. /* export-doc-lines */

/*==========================================================================*/
procedure export-doc-line :
  define input  parameter p-doc-code  as character no-undo .
  define input  parameter p-artic     as character no-undo .
  define input  parameter p-prod-type as character no-undo .
  define input  parameter p-prod-code as integer   no-undo .

  define buffer buf_ord-doc  for ub.ord-doc .
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_goods    for ub.goods.
  define buffer buf_units    for ub.units.

  define variable v-is-envd  as logical   no-undo.
  define variable v-r-b      as character no-undo .
  define variable v-rate     as decimal   no-undo .
  define variable v-VATr     as decimal   no-undo .
  define variable v-SLTr     as decimal   no-undo .
  define variable v-roadTaxr as decimal   no-undo .
  define variable v-VATb     as decimal   no-undo .
  define variable v-SLTb     as decimal   no-undo .
  define variable v-roadTaxb as decimal   no-undo .

  { gbl/curr-r-b.i v-r-b }

do for  buf_ord-doc
      , buf_ord-line
      , buf_goods
      , buf_units
on error undo, return error return-value
:
  find first buf_ord-doc no-lock
    where buf_ord-doc.doc-code   = p-doc-code
  no-error .
  if available buf_ord-doc
  then do:
    find first buf_ord-line no-lock
      where buf_ord-line.doc-code   = p-doc-code
        and buf_ord-line.artic      = p-artic
        and buf_ord-line.prod-type  = p-prod-type
        and buf_ord-line.prod-code  = p-prod-code
    no-error .
    if available buf_ord-line
    then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
      no-error .
      if available buf_goods
      then do:
        run wp-xmltagput in this-procedure ( 4, "good",      string( buf_goods.gds-code ), 1 ).
        run wp-xmltagput in this-procedure ( 4, "artic",     string( buf_goods.artic    ), 1 ).
        run wp-xmltagput in this-procedure ( 4, "prodtype",  string( buf_goods.prod-type), 1 ).
        run wp-xmltagput in this-procedure ( 4, "prodcode",  string( buf_goods.prod-code), 1 ).
        run wp-xmltagput in this-procedure ( 4, "type",      string( buf_goods.gds-type ), 1 ).
        run fill_bge-xml_goods in this-procedure ( input p-parent-handle
                                                , input buf_goods.gds-code
                                                ).
      end. /* if available buf_goods */
      else do:
          run wp-xmltagput in this-procedure ( 4, "good",      "", 1 ).
          run wp-xmltagput in this-procedure ( 4, "artic",     "", 1 ).
          run wp-xmltagput in this-procedure ( 4, "prodtype",  "", 1 ).
          run wp-xmltagput in this-procedure ( 4, "prodcode",  "", 1 ).
          run wp-xmltagput in this-procedure ( 4, "type",      "", 1 ).
      end.      /* NOT available buf_goods  */

      find first buf_units no-lock
        where buf_units.unit-name  = buf_goods.unit-base
      no-error.
      if available buf_units
      then do:
        run wp-xmltagput in this-procedure ( 4, "unitType",    string( buf_units.type ), 1 ).
      end.      /* available units */
      else do:
        run wp-xmltagput in this-procedure ( 4, "unitType",   "",   1 ).
      end.      /* NOT available units */

      run wp-xmltagput( 4, "priceCli"     , string( buf_ord-line.price-cli        ), 1 ).
      run wp-xmltagput( 4, "cliBaseRate"  , string( buf_ord-line.cli-base-rate    ), 1 ).

      /***
      if v-bge-xml-shift-mode = yes
      then do:
          run get-goods-envd in this-procedure ( input p-obj-type
                                              , input p-obj-code
                                              , input buf_goods.gds-code
                                              , output v-is-envd
                                              ).
          run wp-xmltagput in this-procedure ( 4, "ENVD":U, string( v-is-envd ), 1 ).
      end.        /* if v-bge-xml-shift-mode = yes */
      ***/


      run wp-xmltagput in this-procedure ( 4, "quantity" , string( buf_ord-line.qnty ), 1 ).
      run wp-xmltagput in this-procedure ( 4, "comment"  , string( buf_goods.ps )     , 1 ).

      assign
        v-rate = buf_ord-doc.base-rate / buf_ord-doc.base-scale
      .
      if v-r-b = {&r-b-rubl} then do:
        assign
          v-VATr     = buf_ord-line.sum-vat      * buf_ord-line.qnty
          v-SLTr     = buf_ord-line.sum-slt      * buf_ord-line.qnty
          v-roadTaxr = buf_ord-line.sum-road-tax * buf_ord-line.qnty
          v-VATb     = v-VATr     / v-rate
          v-SLTb     = v-SLTr     / v-rate
          v-roadTaxb = v-roadTaxr / v-rate
        .
      end.
      else do:
        assign
          v-VATb     = buf_ord-line.sum-vat      * buf_ord-line.qnty
          v-SLTb     = buf_ord-line.sum-slt      * buf_ord-line.qnty
          v-roadTaxb = buf_ord-line.sum-road-tax * buf_ord-line.qnty
          v-VATr     = v-VATb     * v-rate
          v-SLTr     = v-SLTb     * v-rate
          v-roadTaxr = v-roadTaxb * v-rate
        .
      end.
      run wp-xmltagopen in this-procedure ( 4, "docSum", "" ).
      run wp-xmltagput in this-procedure ( 5, "rateVAT",    trim( string( buf_ord-line.vat-pc , ">99" )), 1 ).
      run wp-xmltagput in this-procedure ( 5, "rateSLT",    trim( string( buf_ord-line.slt-pc , ">99" )), 1 ).
      /* пошли по рублям */
      run wp-xmltagput in this-procedure ( 5, "sumr",       string( buf_ord-line.sum-rubl             ) , 1 ).
      run wp-xmltagput in this-procedure ( 5, "VATr",       string( v-VATr     )                        , 1 ).
      run wp-xmltagput in this-procedure ( 5, "SLTr",       string( v-SLTr     )                        , 1 ).
      run wp-xmltagput in this-procedure ( 5, "roadTaxr",   string( v-roadTaxr )                        , 1 ).
      run wp-xmltagput in this-procedure ( 5, "transportr", string( (buf_ord-line.sum-transport-rubl * buf_ord-line.qnty  ) ), 1 ).
      run wp-xmltagput in this-procedure ( 5, "otherr",     string( (buf_ord-line.sum-other-rubl     * buf_ord-line.qnty  ) ), 1 ).
      run wp-xmltagput in this-procedure ( 5, "exciser",    string( buf_ord-line.sum-excise           ) , 1 ).
      /* пошли по базовой валюте */
      run wp-xmltagput in this-procedure ( 5, "sumb",       string( buf_ord-line.sum-base             ) , 1 ).
      run wp-xmltagput in this-procedure ( 5, "VATb",       string( v-VATb     ) , 1 ).
      run wp-xmltagput in this-procedure ( 5, "SLTb",       string( v-SLTb     ) , 1 ).
      run wp-xmltagput in this-procedure ( 5, "roadTaxb",   string( v-roadTaxb ) , 1 ).
      run wp-xmltagput in this-procedure ( 5, "transportb", string( (buf_ord-line.sum-transport-base * buf_ord-line.qnty ) ) , 1 ).
      run wp-xmltagput in this-procedure ( 5, "otherb",     string( (buf_ord-line.sum-other-base     * buf_ord-line.qnty ) ) , 1 ).
  /*    run wp-xmltagput in this-procedure ( 5, "exciseb",    string( buf_ord-line.excise-base      ), 2 ).*/
      run wp-xmltagclose in this-procedure ( 4, "docSum" ).

    end. /* if available buf_ord-line */
    else do:
      undo, return error substitute( "*** ERR *** Не найдена строка документа &1. Товар &2 &3 &4."
                                  , p-doc-code
                                  , p-artic
                                  , p-prod-type
                                  , p-prod-code
                                  ) . /* --->>>--- */
    end.
  end.
  else do:
    undo, return error substitute( "*** ERR *** Не найден документ &1."
                                , p-doc-code
                                ) . /* --->>>--- */
  end.
end.

end procedure. /* export-doc-line */

/*==========================================================================*/
procedure convert-doc-type :
  /*
    Лирическое отступление:
    перевод типа сделан для Oracle Retail из 'o-p' в 'op'
  */
  define input  parameter p-input-doc-type  as character no-undo .
  define output parameter p-output-doc-type as character no-undo .

  define variable v-doc-type  as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-output-doc-type = ?
  .
  if v-bge-xml-bgeflold = "oracle":u
  then do:
    case p-input-doc-type :
      when {&o-p}
      then do:
        assign
          v-doc-type = "op"
        .
      end.
      otherwise do:
        assign
          v-doc-type = ?
        .
      end.
    end case.
    assign
      p-output-doc-type = v-doc-type
    .
  end.
end.

end procedure. /* convert-doc-type */

/*==========================================================================*/
procedure get-base-code-okv :
define input parameter p-base-code          as integer          no-undo.
define output parameter p-base-code-okv     as integer          no-undo.

    define buffer buf_currency      for ub.currency.
do
for buf_currency
on error undo, return error
:
    find first buf_currency no-lock
         where buf_currency.curr-code = p-base-code
    .
    assign
        p-base-code-okv = buf_currency.okv-code
    .
end.
end procedure. /* get-base-code-okv */

/*==========================================================================*/
procedure fill_bge-xml_goods :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-gds-code       as integer          no-undo.

do
on error undo, return error
:
  if p-parent-handle :get-signature( "cb-fill_bge-xml_goods" ) <> "":U
  then do:
    run cb-fill_bge-xml_goods in p-parent-handle ( input p-gds-code ).
  end.
end.
end procedure. /* fill_bge-xml_goods */

/*==========================================================================*/
procedure fill_bge-xml_clients :
define input parameter p-parent-handle  as handle           no-undo.
define input parameter p-obj-type       as character        no-undo.
define input parameter p-obj-code       as integer          no-undo.

do
on error undo, return error
:
  if p-parent-handle :get-signature( "cb-fill_bge-xml_clients" ) <> "":U
  then do:
    run cb-fill_bge-xml_clients in p-parent-handle ( input p-obj-type
                                                   , input p-obj-code
                                                   ).
  end.
end.
end procedure. /* fill_bge-xml_clients */

/*==========================================================================*/
procedure run-callback-write-doc-code :
  define input parameter p-handle         as handle       no-undo.
  define input parameter p-type           as character    no-undo.
  define input parameter p-doc-code       as character    no-undo.
  define input parameter p-log-file       as character    no-undo.

  define variable v-procedure-name    as char no-undo.
do
on error undo, return error
:
  case p-type
  :
    when {&table_ord-doc}
    then do:
      assign
        v-procedure-name = "fill-temp-ord-doc-code":U
      .
    end. /* when {&table-ord-doc} */
  end case.       /* case p-type */

  if lookup( v-procedure-name, p-handle :internal-entries ) > 0
  then do:
    run value( v-procedure-name ) in p-handle ( input p-doc-code ) no-error.
    if error-status :error
    then do:
      run wp-XMLWriteLog in this-procedure ( input p-log-file
                                           , input 1
                                           , input substitute( "Ошибка при вызове callback - процедуры &1.", v-procedure-name )
                                           ).
    end.
  end.
  else do:                           /* нет такой процедуры */
    run wp-XMLWriteLog in this-procedure ( input p-log-file
                                         , input 1
                                         , input substitute( "Не найдена callback - процедура &1.", v-procedure-name )
                                         ).
  end.
end.
end procedure. /* run-callback-write-doc-code */


