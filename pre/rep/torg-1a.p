using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter Invers               as logical          no-undo.
define stream out-stream.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: torg-1a.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/torg-1a.p $":U .
define variable vss-description as character no-undo init "Документ Технологическая - 3 ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable g#report-num    as integer      no-undo.
define variable v-org-name              as character no-undo.
define variable v-obj-name              as character no-undo.
define variable v-reason-num            as character no-undo.
define variable v-reason-date           as date      no-undo.
define variable v-reason-num2           as character no-undo.
define variable v-doc-code              as character no-undo.
define variable v-fact-date             as date      no-undo.
define variable v-consignee             as character no-undo.
define variable v-schet-factura-num     as character no-undo.
define variable v-schet-factura-date    as character no-undo.
define variable v-schet-factura-num-date as character no-undo.
define variable v-shipper               as character no-undo.
define variable v-supplier              as character no-undo.
define variable v-contract              as character no-undo.
define temp-table tt-line no-undo
    field gds-name as character
    field gds-code as integer
    field unit-name as character
    field unit-okei as character
    field price-no-vat as decimal format "->>,>>9.99"
    field qnty-supp as decimal
    field sum-supp as decimal
    field qnty-fact as decimal
    field sum-fact as decimal
    field sum-fact-vat as decimal
    field vat as decimal
    field vat-sum as decimal
    field qnty-delta as decimal
    field sum-delta as decimal
    field sertif as character
    index pi as primary unique gds-code
.
define variable v-price         as decimal      no-undo.
define variable v-qnty-supp     as decimal      no-undo.
define variable v-qnty-fact     as decimal      no-undo.
define variable v-sum-PlaceAmountSupp   as decimal      no-undo.
define variable v-sum-SumSupp           as decimal      no-undo.
define variable v-sum-PlaceAmountFact   as decimal      no-undo.
define variable v-sum-SumFact           as decimal      no-undo.
define variable v-sum-sum               as decimal      no-undo.
define variable v-sum-VATsum            as decimal      no-undo.
define variable v-sum-PlaceAmountDelt   as decimal      no-undo.
define variable v-sum-SumDelt           as decimal      no-undo.
define variable v-sert                  as character    no-undo.
define variable v-bar-code              as integer      no-undo.
define variable v-attorney-num          as character no-undo.
define variable v-attorney-date         as character no-undo.
define variable v-attorney-who          as character no-undo.
define variable v-position              as character no-undo.
define variable v-position1             as character no-undo.
define variable v-position2             as character no-undo.
define variable v-storekeeper           as character no-undo.
define buffer buf_doc-line      for doc-line.
define buffer buf_parts         for parts.
define buffer buf_goods         for goods.
define buffer buf_units         for units.
define buffer buf_sert-join     for sert-join.
define buffer buf_sert          for sert.
run main no-error.
if error-status:error then
    message return-value
    view-as alert-box.
procedure main:
    find first ub.trn-doc no-lock where recid(ub.trn-doc) = rec_id.
    if ub.trn-doc.obj-type <> 'маг':U then
    return error subst("Объект &1 не является магазином", ub.trn-doc.obj-code).
    define variable v-file-name as character no-undo.
    run prepare-header no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
    run prepare-lines no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
    run prepare-footer no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
    run create-rep(output v-file-name) no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
    if v-file-name = ? then
        return error "файл созданного от чета не найден".
    else
        run open-ie(v-file-name) no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
output stream out-stream to value( string( session:temp-directory +
                                     "rpt" + string( g#report-num ) ) )
                                     page-size  value(43) .
    put stream out-stream unformatted
          chr(10)
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + chr(10)
    .
    output stream out-stream close.
end.
procedure prepare-header:
    define variable v-character as character no-undo.
    define variable v-integer as integer no-undo.
    define variable v-type as character no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostname in g#library
  (input  ub.trn-doc.obj-type
  ,input  ub.trn-doc.obj-code
  ,output v-integer
  ,output v-org-name
  )  .
    find first ub.clients no-lock
        where ub.clients.obj-type = ub.trn-doc.obj-type
        and ub.clients.obj-code = ub.trn-doc.obj-code.
    v-obj-name = ub.clients.obj-name.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'nids':U ,
                       output v-reason-num ,
                       output v-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'dids':U ,
                       output v-reason-date ,
                       output v-type )  .
    v-reason-num2 = string(v-reason-num) + string(v-reason-date).
    v-doc-code = ub.trn-doc.doc-code.
    v-fact-date = ub.trn-doc.fact-date.
    find first ub.clients no-lock
        where ub.clients.obj-type = ub.trn-doc.obj-type
        and ub.clients.obj-code = ub.trn-doc.obj-code.
    find first ub.shop no-lock
        where ub.shop.obj-code = ub.trn-doc.obj-code.
    v-consignee = trim(subst("&1, &2 &3", ub.clients.obj-name, ub.shop.addres1, ub.shop.addres2)).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'nsf':U ,
                       output v-schet-factura-num ,
                       output v-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'dsf':U ,
                       output v-schet-factura-date ,
                       output v-type )  .
    if v-schet-factura-num = "" and v-schet-factura-date = "" then v-schet-factura-num-date = "".
         else v-schet-factura-num-date =" счёт-фактура № " + v-schet-factura-num + " от " + v-schet-factura-date.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'Shipper':U ,
                       output v-shipper ,
                       output v-type )  .
     find first ub.clients no-lock where ub.clients.obj-type = substring(v-shipper, 1, 3)
                                        and
                                        ub.clients.obj-code = integer(substring(v-shipper, 4)) no-error.
     if available ub.clients then
     do:
     v-shipper = ub.clients.obj-name.
         if ub.clients.obj-type = 'чел':U then
            do:
            find first ub.person no-lock where ub.person.psn-code = ub.clients.obj-code no-error.
            if available ub.person then
                  v-shipper = v-shipper + " " + ub.person.address.
        end.
        else
            do:
            find first ub.firm no-lock where ub.firm.firm-code = ub.clients.obj-code no-error.
            if available ub.firm then
            do:
                 v-shipper =  v-shipper + " " + ub.firm.addres1 + ub.firm.addres2.
            end.
        end.
       end.
    if v-shipper = "" or v-shipper = ? then
         do:
         find first ub.clients no-lock where ub.clients.obj-type = ub.trn-doc.cli-type
                                           and
                                           ub.clients.obj-code = ub.trn-doc.cli-code no-error.
         if available ub.clients then
                  v-shipper = ub.clients.obj-name.
         if trn-doc.cli-type = 'чел':U then
            do:
            find first ub.person no-lock where ub.person.psn-code = ub.trn-doc.cli-code no-error.
            if available ub.person then
                  v-shipper = v-shipper .
           end.
         else
            do:
            find first ub.firm no-lock where ub.firm.firm-code = ub.trn-doc.cli-code no-error.
            if available ub.firm then
                 v-shipper =  v-shipper + " " + ub.firm.post-addr1 + ub.firm.post-addr2 .
            end.
         end.
       find first ub.clients no-lock where ub.clients.obj-type = ub.trn-doc.cli-type
                                           and
                                           ub.clients.obj-code = ub.trn-doc.cli-code no-error.
            if available ub.clients then
                  v-supplier = ub.clients.obj-name.
    if trn-doc.cli-type = 'чел':U then
            do:
            find first ub.person no-lock where ub.person.psn-code = ub.trn-doc.cli-code no-error.
            if available ub.person then
                  v-supplier = v-supplier + " " + ub.person.address.
           end.
     else
            do:
            find first ub.firm no-lock where ub.firm.firm-code = ub.trn-doc.cli-code no-error.
            if available ub.firm then
                 v-supplier =  v-supplier + " " + ub.firm.addres1 .
            end.
            find first ub.contract no-lock where ub.contract.host-code = ub.trn-doc.host-code
                                           and   ub.contract.contract-code = ub.trn-doc.contract-code
             no-error.
            if available ub.contract then
            v-contract = string( ub.contract.contract-prn-code ) + " от " + string( ub.contract.contract-date, "99/99/9999" ).
end.
procedure prepare-lines:
for each buf_doc-line no-lock
where buf_doc-line.doc-code = trn-doc.doc-code
:
        find first buf_goods no-lock
             where buf_goods.artic      = buf_doc-line.artic
               and buf_goods.prod-type  = buf_doc-line.prod-type
               and buf_goods.prod-code  = buf_doc-line.prod-code
        .
        find first buf_units no-lock
              where buf_units.unit-name = buf_goods.unit-base
        .
        for each buf_parts no-lock
           where buf_parts.out-code   = trn-doc.doc-code
             and buf_parts.obj-type   = trn-doc.obj-type
             and buf_parts.obj-code   = trn-doc.obj-code
             and buf_parts.prod-type  = buf_doc-line.prod-type
             and buf_parts.prod-code  = buf_doc-line.prod-code
             and buf_parts.artic      = buf_doc-line.artic:
         v-price = buf_parts.price-rubl.
         v-qnty-supp = buf_parts.qnty.
         v-qnty-fact = buf_parts.fact-qnty.
         create tt-line.
         assign
            tt-line.gds-name =  buf_goods.gds-name
            tt-line.gds-code =  buf_goods.gds-code
            tt-line.unit-name = buf_units.unit-name
            tt-line.unit-okei = string(buf_units.OKEI)
            tt-line.price-no-vat = v-price - v-price * buf_parts.VAT-pc / ( 100 + buf_parts.VAT-pc ).
            tt-line.qnty-supp =  v-qnty-supp.
            tt-line.sum-supp = tt-line.price-no-vat * tt-line.qnty-supp.
            tt-line.qnty-fact =  v-qnty-fact.
            tt-line.sum-fact-vat = v-price * tt-line.qnty-fact.
            tt-line.vat = buf_parts.VAT-pc.
            tt-line.vat-sum = tt-line.vat / 100 * v-qnty-fact * tt-line.price-no-vat.
            v-sum-PlaceAmountSupp = v-sum-PlaceAmountSupp + v-qnty-supp.
            v-sum-SumSupp         = v-sum-SumSupp         + ( v-qnty-supp  *  tt-line.price-no-vat ).
            v-sum-PlaceAmountFact = v-sum-PlaceAmountFact + v-qnty-fact.
            v-sum-SumFact         = v-sum-SumFact         + ( v-qnty-fact * tt-line.price-no-vat ).
            v-sum-sum             = v-sum-sum             + ( v-qnty-fact * v-price ).
            v-sum-VATsum          = v-sum-VATsum          + ( buf_parts.VAT-pc / 100 * v-qnty-fact * tt-line.price-no-vat ) .
            v-sum-PlaceAmountDelt = v-sum-PlaceAmountDelt + ( v-qnty-fact - v-qnty-supp ).
            v-sum-SumDelt         = v-sum-SumDelt         + ( ( v-qnty-fact - v-qnty-supp ) * tt-line.price-no-vat ).
            assign
                v-sert = "":U
            .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-bar-code
  ) no-error .
 .
            for each buf_sert-join no-lock
               where buf_sert-join.cli-type   = buf_goods.prod-type
                 and buf_sert-join.cli-code   = buf_goods.prod-code
                 and buf_sert-join.b-code     = v-bar-code
            :
                for each buf_sert no-lock
                   where buf_sert.sert-code = buf_sert-join.sert-code
                :
                    if  trn-doc.fact-date <= buf_sert.last-date
                    and trn-doc.fact-date >= buf_sert.first-date
                    then do:
                        assign
                            v-sert = v-sert
                                    + ( if trim( v-sert ) = "":U
                                        then "":U
                                        else ", ":U )
                                    + string( buf_sert-join.sert-code )
                        .
                    end.
                end.
            end.
            tt-line.sertif = v-sert.
        end.
end.
end.
procedure prepare-footer:
    define variable v-type as character no-undo.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'ndov':U ,
                       output v-attorney-num ,
                       output v-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'ddov':U ,
                       output v-attorney-date ,
                       output v-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 'ndovwho':U ,
                       output v-attorney-who ,
                       output v-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 't_pass-fname':U ,
                       output v-position1 ,
                       output v-type )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input ub.trn-doc.doc-code ,
                        input 't_pass-position':U ,
                       output v-position2 ,
                       output v-type )  .
    v-position = v-position2 .
    find first ub.clients no-lock
    where ub.clients.obj-code = ub.trn-doc.wrkr
    and ub.clients.obj-type = 'чел':U no-error.
    if available ub.clients then v-storekeeper = ub.clients.obj-name.
end.
procedure create-rep:
    define output parameter p-filename as character no-undo.
    define variable v-rls-file as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file as character no-undo.
    define variable v-tmp-file as character no-undo.
    define variable hw as handle no-undo.
    define variable rep-out as class Rep-Out no-undo.
    assign
        v-xsl-file = search("exe/torg1a.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html".
    .
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    run write-data(hw) no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).
    os-delete value(v-rls-file).
    delete object rep-out.
    p-filename = v-tmp-file.
end.
procedure write-data:
    define input parameter hw as handle no-undo.
    hw:start-document ().
    hw:start-element ("rep").
    hw:start-element ("card").
    hw:insert-attribute ("name", if v-org-name = ? then "" else v-org-name ).
    hw:insert-attribute ("obj_name", if v-obj-name = ? then "" else v-obj-name).
    hw:insert-attribute ("reason-num", if v-reason-num = ? then "" else v-reason-num).
    hw:insert-attribute ("reason-date1", if v-reason-date = ? then "" else string( day(v-reason-date))).
    hw:insert-attribute ("reason-date2", if v-reason-date = ? then "" else string( month(v-reason-date), "99")).
    hw:insert-attribute ("reason-date3", if v-reason-date = ? then "" else string( year(v-reason-date))).
    hw:insert-attribute ("doc-code", if v-doc-code = ? then "" else v-doc-code ).
    hw:insert-attribute ("fact-date", if v-fact-date = ? then "Не указана" else string(v-fact-date, "99/99/9999")).
    hw:insert-attribute ("consignee", if v-consignee = ? then "" else v-consignee).
    hw:insert-attribute ("schet-factura", if v-schet-factura-num-date = ? then "" else v-schet-factura-num-date).
    hw:insert-attribute ("shipper", if v-shipper = ? then "" else v-shipper ).
    hw:insert-attribute ("supplier", if v-supplier = ? then "" else v-supplier).
    hw:insert-attribute ("contract", if v-contract = ? then "" else v-contract).
    hw:insert-attribute ("attorney-num", if v-attorney-num = ? then "" else v-attorney-num).
    hw:insert-attribute ("attorney-date", if v-attorney-date = ? then "" else v-attorney-date).
    hw:insert-attribute ("attorney-who", if v-attorney-who = ? then "" else v-attorney-who).
    hw:insert-attribute ("position", if v-position = ? then "" else v-position).
    hw:insert-attribute ("storekeeper", if v-storekeeper = ? then "" else v-storekeeper).
    hw:insert-attribute ("v-sum-PlaceAmountSupp",if v-sum-PlaceAmountSupp = ? then string(0) else string(v-sum-PlaceAmountSupp,"->>,>>9.99") ).
    hw:insert-attribute ("v-sum-SumSupp",if v-sum-SumSupp = ? then string(0) else string(v-sum-SumSupp,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-PlaceAmountFact",if v-sum-PlaceAmountFact = ? then string(0) else string(v-sum-PlaceAmountFact,"->>,>>9.99") ).
    hw:insert-attribute ("v-sum-SumFact",if v-sum-SumFact = ? then string(0) else string(v-sum-SumFact,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-sum",if v-sum-sum = ? then string(0) else string(v-sum-sum,"->>,>>9.99") ).
    hw:insert-attribute ("v-sum-VATsum",if v-sum-VATsum = ? then string(0) else string(v-sum-VATsum,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-PlaceAmountDelt",if v-sum-PlaceAmountDelt = ? then string(0) else string(v-sum-PlaceAmountDelt,"->>,>>9.99")  ).
    hw:insert-attribute ("v-sum-SumDelt",if v-sum-SumDelt = ? then string(0) else string(v-sum-SumDelt,"->>,>>9.99")  ).
    for each tt-line no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("gds-name", tt-line.gds-name).
        hw:insert-attribute ("gds-code", string(tt-line.gds-code)).
        hw:insert-attribute ("unit-name", tt-line.unit-name).
        hw:insert-attribute ("unit-okei", tt-line.unit-okei).
        hw:insert-attribute ("price-no-vat", string(tt-line.price-no-vat,"->>,>>9.99")).
        hw:insert-attribute ("AmountInPlSupp", string(1.00,"->>,>>9.99") ).
        hw:insert-attribute ("PlaceAmountSupp", string(tt-line.qnty-supp,"->>,>>9.99")).
        hw:insert-attribute ("MassSupp", string(0.00,"->>,>>9.99") ).
        hw:insert-attribute ("SumSupp", string(tt-line.sum-supp,"->>,>>9.99") ).
        hw:insert-attribute ("AmountInPlFact", string(1.00,"->>,>>9.99") ).
        hw:insert-attribute ("PlaceAmountFact", string(tt-line.qnty-fact,"->>,>>9.99")).
        hw:insert-attribute ("MassFact", string(0.00,"->>,>>9.99") ).
        hw:insert-attribute ("SumFact", string(tt-line.price-no-vat * tt-line.qnty-fact,"->>,>>9.99") ).
        hw:insert-attribute ("Sum", string(tt-line.sum-fact-vat,"->>,>>9.99") ).
        hw:insert-attribute ("VATpc", string(tt-line.vat,"->>,>>9.99") ).
        hw:insert-attribute ("VATsum", string(tt-line.vat-sum,"->>,>>9.99") ).
        hw:insert-attribute ("AmountInPlDelt", string(1.00,"->>,>>9.99") ).
        hw:insert-attribute ("PlaceAmountDelt", string(tt-line.qnty-fact - tt-line.qnty-supp,"->>,>>9.99") ).
        hw:insert-attribute ("MassDelt", string(0.00,"->>,>>9.99") ).
        hw:insert-attribute ("SumDelt", string((tt-line.qnty-fact - tt-line.qnty-supp) * tt-line.price-no-vat,"->>,>>9.99") ).
        hw:insert-attribute ("sertif", if tt-line.sertif = ?  then "" else tt-line.sertif).
        hw:end-element ("line").
    end.
    hw:end-element ("card").
    hw:end-element ("rep").
    hw:end-document ().
end.
procedure open-ie:
    define input parameter p-filename as character no-undo.
    define variable o-IE as com-handle no-undo.
    create "InternetExplorer.Application" o-IE.
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.
end.
