/*

$Revision: 43c09557cdee, 3584, rls $
$Author: DRuban $
$Date: 2023/12/28 12:56:36 $
$Workfile: KioskCommand.cls $
$Archive: ibs/th/skt/Commands/KioskCommand.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Adapters.*.
using ibs.th.skt.Commands.*.
block-level on error undo, throw.

&scop CRLF chr(13) + chr(10)
&scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)


class ibs.th.skt.Commands.KioskCommand inherits ICommand: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Обработка запросов в сокет по Kiosk" get.
  
  { cmp/str-glbl.i class}

  define public property ErrStatus as logical no-undo 
    get.
    set. 

  define public property LogMsg as character no-undo 
    get.
    set. 

  define private property ObjCode as integer no-undo
    get.
    set.
    
  define private property ObjType as character no-undo
    get.
    set.

  define private buffer buf_bar-code  for ub.bar-code.
  define private buffer buf_prod-bc   for ub.prod-bc.
  define private buffer buf_price-all for ub.price-all.
  define private buffer buf_goods     for ub.goods.
  define private buffer buf_gds-grp   for ub.gds-grp.
  define private buffer buf_clients   for ub.clients.
  define private buffer buf_place     for ub.place.
  define private buffer buf_gds-attr  for ub.goods-attr.
  define private buffer buf_gds-obj   for ub.gds-obj.
  define private buffer buf_country   for ub.country.

  define private variable hndlSocket as handle    no-undo.
  define private variable contLenght as integer   no-undo.
  define private variable content    as character no-undo.
  define private variable hRoot      as handle    no-undo.
  define private variable hDoc       as handle    no-undo.
  define private variable hRow       as handle    no-undo.
  define private variable hText      as handle    no-undo.
  define private variable i          as integer   no-undo.
  define private variable bcode      as character no-undo.

  method public override void Execute_( input req as ibs.th.skt.Commands.IRequest, resp as class IResponse):

    define variable contLength     as integer   no-undo.
    define variable priceSale      as character no-undo.
    define variable chHeader       as character no-undo.
    define variable chImage        as character no-undo.
    define variable chGallery      as character no-undo.
    define variable chCashinfo     as character no-undo.
    define variable chBullets      as character no-undo.
    define variable chSpecificaion as character no-undo.
    define variable confPar        as character no-undo.
    define variable parType        as character no-undo.
    define variable v-param-types  as character no-undo.
    define variable v-value-char   as character no-undo.
    define variable v-val-date     as date      no-undo.
    define variable v-val-decimal  as decimal   no-undo.
    define variable v-val-integer  as integer   no-undo.
    define variable v-val-logical  as logical   no-undo.
    define variable v-tthd         as handle    no-undo.
    define variable mPhotomgd      as logical     no-undo.
    
    run gbl/conf-rd.p ("gdsscrvw", "", "", 0, "", "", "", no, output confPar, output parType) no-error.
    
    create x-document hDoc.
    create x-noderef  hRoot.
    create x-noderef  hRow.
    create x-noderef  hText.
    
    hndlsocket = req:HndlSocket.

    hDoc:load("longchar",req:Content,no).
    hDoc:encoding = "UTF-8".
    hDoc:get-document-element(hRoot) .
    assign
      ObjType = if hRoot:get-attribute("obj-type") = "shop" then "маг" else "скл"
      ObjCode = integer (hRoot:get-attribute("obj-code"))
    .

    parseXML().

    run ibs/th/skt/Adapters/AdapteeProcBcrcnz.p
      ( input ObjType
      , input ObjCode
      , input bcode
      , buffer buf_bar-code
      , buffer buf_prod-bc
      , buffer buf_place
      ) 
    .
    
    if available (buf_bar-code) 
    then do:    
      find first buf_goods where buf_goods.gds-code = buf_bar-code.gds-code no-lock.
      find first buf_gds-grp where buf_gds-grp.node-code = buf_goods.grp-code no-lock.
      find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and
        buf_clients.obj-code = buf_goods.prod-code no-lock.
      find first buf_country where buf_country.alpha1 = buf_goods.alpha1 no-lock no-error.
      find first buf_gds-obj where buf_gds-obj.obj-type  = ObjType  and
                            buf_gds-obj.obj-code  = ObjCode  and
                            buf_gds-obj.artic     = buf_goods.artic     and
                            buf_gds-obj.prod-type = buf_goods.prod-type and
                            buf_gds-obj.prod-code = buf_goods.prod-code no-lock no-error.
      find last buf_price-all where
        buf_price-all.b-code          = buf_bar-code.b-code and
        buf_price-all.gds-code        = buf_goods.gds-code and
        buf_price-all.obj-code        = ObjCode and
        buf_price-all.obj-type        = ObjType and
        buf_price-all.plt-priority    = 0 and
        buf_price-all.last-pr         = true
        no-lock no-error.

      run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_shema-foto} /*p-param-code*/
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer
        ,output v-val-logical
        ,output v-param-types
        ,input-output table-handle v-tthd
        ) no-error.
      mPhotomgd = if v-val-integer = 2 then yes else no.
      
      for each buf_gds-attr where buf_gds-attr.gds-code = buf_goods.gds-code and buf_gds-attr.attr-code = {&attr-image-list} no-lock.
        chImage = if true /*search ("gds/" + entry (1, buf_gds-attr.attr-value)) <> ?*/ 
          then "" + (if mPhotomgd then string(buf_goods.gds-code) + "/":U else '':U) + entry (1, buf_gds-attr.attr-value) + ""
          else "".
        do i = 1 to num-entries (buf_gds-attr.attr-value):
          chGallery = chGallery + if true /*search ("gds/" + entry (i, buf_gds-attr.attr-value)) <> ?*/ 
            then "<img>" + (if mPhotomgd then string(buf_goods.gds-code) + "/":U else '':U) + entry (i, buf_gds-attr.attr-value) + "</img>"
            else "".
        end.
      end.
      
      assign
        priceSale = if available buf_price-all then trim (string (buf_price-all.price-sale, "->>>>>>>>>>>>>>>>>>>>>>>>>>9.99"), " ") else "0.00"
        priceSale = replace (priceSale, ".", ",")
        chCashinfo = ""
        chBullets = chBullets + substitute ( "<item>&1: &2</item>", "Артикул", buf_goods.artic )
        chBullets = chBullets + substitute ( "<item>&1: &2</item>", "Код", buf_goods.gds-code )
        chSpecificaion = chSpecificaion + if lookup ("grp-name", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Группа", buf_gds-grp.node-name) else ""
        chSpecificaion = chSpecificaion + if not buf_goods.engl-name = "" and lookup ("engl-name", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Название", buf_goods.engl-name) else ""
        chSpecificaion = chSpecificaion + if available (buf_clients) and lookup ("prod-name", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Производитель", buf_clients.obj-name) else ""
        chSpecificaion = chSpecificaion + if available (buf_country) and not buf_country.long-name = "" and lookup ("alpha1", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Страна", buf_country.long-name) else ""
        chSpecificaion = chSpecificaion + if not buf_goods.sert = "" and lookup ("sert", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Сертификат", buf_goods.sert) else ""
        chSpecificaion = chSpecificaion + if not buf_goods.destin = "" and lookup ("destin", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Назначение товара", buf_goods.destin) else ""
        chSpecificaion = chSpecificaion + if not buf_goods.user-rule = "" and lookup ("user-rule", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Правила эксплуатации", buf_goods.user-rule) else ""
        chSpecificaion = chSpecificaion + if not buf_goods.struct = "" and lookup ("struct", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Состав", buf_goods.struct) else ""
        chSpecificaion = chSpecificaion + if not buf_goods.deadline = ? and not buf_goods.deadline = 0 and lookup ("deadline", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Срок хранения", buf_goods.deadline) else ""
        chSpecificaion = chSpecificaion + if available ( buf_gds-obj ) and lookup ("fact-qnty", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Остаток ", buf_gds-obj.fact-qnty) else ""
        chSpecificaion = chSpecificaion + if available ( buf_gds-obj ) and lookup ("in-date", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Дата последнего прихода", buf_gds-obj.in-date) else ""
        chSpecificaion = chSpecificaion + if buf_goods.PS <> "" and lookup ("PS", confPar) > 0 then substitute ( "<row><key>&1</key><value>&2</value></row>", "Примечание", buf_goods.PS) else ""
      .

      content =  codepage-convert(
      substitute ('<?xml version="1.0" encoding="utf-8"?><page>
        <barcode>&1</barcode>
        <header>&2</header>
        <image>&3</image>
        <gallery>&4</gallery>
        <name>&5</name> 
        <price>&6</price>
        <cashinfo>&7</cashinfo>
        <bullets>&8</bullets>
        <specification>&9</specification>
        </page>', 
        buf_bar-code.b-code
        , " " /*buf_goods.gds-name*/
        , chImage
        , chGallery
        , buf_goods.gds-name
        , priceSale
        , chCashinfo
        , chBullets
        , chSpecificaion
        ), "utf-8" , session:charset).
      
    end.
    else do:
      
    end.

    writeSock ( "").
    LogWrite:LogStr = "Ответ отправлен".
    
  end method.
  
    /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private logical writeSock ( arg as character ):
    
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    set-size(mbuffer1) = length (content, "RAW":U) + 1.
    put-string(mbuffer1,1) = content.

      
    tempStr = substitute("HTTP/1.0 200 OK&1Server: 4GL&1Content-Type: text/csv&1Content-Length: &3&2",{&CRLF},{&HdEnd},get-size(mbuffer1) - 1 ).
    set-size(mbuffer) = length (tempStr, "RAW":U) + 1 .
    put-string(mbuffer,1) = tempstr.
    assign
      glog = hndlsocket:write(mbuffer,1,length(tempStr,'RAW':U)) no-error.
    set-size(mbuffer) = 0.
    if not glog 
      then do:
        LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.". 
        ErrStatus = true.
      end.
    assign
      glog = hndlsocket:write(mbuffer1,1,get-size(mbuffer1) - 1) no-error.
    set-size(mbuffer1) = 0.
    if not glog
      then do:
        LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.".
        ErrStatus = true.
      end.
    return true.
    
      
  end method.
  
  method private logical parseXML(  ):

    do i = 1 to hRoot:num-children:
      hRoot:get-child(hRow,i).
      case hRow:name:
        when "barcode" then
          do:
            hRow:get-child(hText,i).
            bcode = hText:node-value. 
          end.
      end case.
    end.
    
    return true.

  end method.
  
end class.