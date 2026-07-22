
  define temp-table TempTrnDocMT no-undo serialize-name "MT_document"
    field DocName as character serialize-name "DocName"
    field DocType as character serialize-name "DocType"
    field Complete_ as logical serialize-name "Complete"
    field Status_ as character serialize-name "Status"
    field ClientID as integer serialize-name "ClientID"
    field ClientType as character serialize-name "ClientType"
    field ObjectID as integer serialize-name "ObjectID"
    field ObjectType as character serialize-name "ObjectType"
    field UserID_ as character serialize-name "UserID"
    field UserName as character serialize-name "UserName"
    field FactSum as decimal serialize-name "FactSum"
    field StartDate as datetime-tz serialize-name "StartDate"
    field Flags_ as integer serialize-name "Flags"
    index DocName DocName.
    
  define temp-table TempTrnLineMTs no-undo serialize-name "MT_lines"
    field DocName as character serialize-hidden 
    index DocName DocName.  
    
  define temp-table TempTrnLineMT no-undo serialize-name "MT_line"
     field lineid as integer serialize-name "LineID"
     field docname as character serialize-hidden
     field pos as integer serialize-name "Pos" 
     field goodsid as integer serialize-name "GoodsID"
     field goodsname as character serialize-name "GoodsName" 
     field UnitBC as character serialize-name "UnitBC" 
     field BC as character serialize-name "BC"
     field Price_ as decimal serialize-name "Price"
     field DocQnty as decimal serialize-name "DocQnty"
     field FactQnty as  decimal serialize-name "FactQnty"
     field Error as character serialize-name "AlcCode"
     field PartIDTH as character serialize-name "PartIDTH"
     field Flags_ as integer serialize-name "Flags"
  index num docname pos.
  
/*  define temp-table TempMarkLineMTs no-undo serialize-name "MT_MarkLines"*/
/*     field PartIDTH as character serialize-hidden                        */
/*  index num PartIDTH .                                                   */
     
/*  define temp-table TempMarkLineMT no-undo serialize-name "MT_MarkLine"*/
  define temp-table TempMarkLineMT no-undo serialize-name "MT_MarkLines"
     field LineId as integer serialize-name "LineId"
     field DocName as character serialize-hidden
     field MarkCode as character  serialize-name "MarkCode"
     field PartIDTH as character  serialize-name "PartIDTH"
     field Status_ as character  serialize-name "Sts"
     field MarkParent as character  serialize-name "MarkParent"
     field BoxQnty as integer  serialize-name "BoxQnty"
     field Pos as integer  serialize-name "Pos"
     field UnitBox as character  serialize-name "UnitBox"
  index mark DocName MarkCode.
  
     
  define dataset ds-doc serialize-name "MT_documents"
      for TempTrnDocMT
    , TempTrnLineMTs
    , TempTrnLineMT
/*    , TempMarkLineMTs*/
    , TempMarkLineMT
    data-relation docLines     for TempTrnDocMT, TempTrnLineMTs    relation-fields (DocName, DocName) nested
    data-relation docLine      for TempTrnLineMTs, TempTrnLineMT     relation-fields (DocName, docname) nested 
/*    data-relation docLineMarks for TempTrnLineMT, TempMarkLineMTs    relation-fields (PartIDTH, PartIDTH) nested */
/*    data-relation docLineMark  for TempMarkLineMTs, TempMarkLineMT    relation-fields (PartIDTH, PartIDTH) nested*/
    data-relation docLineMark  for TempTrnLineMT, TempMarkLineMT    relation-fields (PartIDTH, PartIDTH) nested
  .
  
  define temp-table tt-user no-undo serialize-name "TH_users"
     field user-id    as character serialize-name "userID"
     field user-login as character serialize-name "userName"
  index user-id as unique user-id.
  define dataset ds-user serialize-name "Users"
  for tt-user.
  
  define temp-table  tt-Objects no-undo serialize-name "TH_objects"
     field obj-type as character serialize-name "obj_type"
     field obj-code as integer serialize-name "obj_code"
     field obj-name as character serialize-name "Name"
  index pi as unique obj-type obj-code.
  
  define dataset ds-Objects serialize-name "Objects"
  for tt-Objects.
  
  define temp-table  tt-Clients no-undo serialize-name "TH_clients"
     field obj-type as character serialize-name "cli_type"
     field obj-code as integer serialize-name "cli_code"
     field obj-name as character serialize-name "Name"
  index pi as unique obj-type obj-code.
  
  define dataset ds-Clients serialize-name "Clients"
  for tt-Clients.
  
  define temp-table  tt-Goods no-undo serialize-name "TH_Goods"
      field gds-code as integer serialize-name "GoodsID"
      field gds-name as character  serialize-name "Name"
      field unit-base as character serialize-name "UnitBase"
/*      field priceSale as dec serialize-name "PriceBase"*/
/*      field vatPc as dec  serialize-name "VAT"  */
      field countryName  as character serialize-name "Country"
/*      field struct  as char serialize-name "Struct"*/
      field factQnty as decimal serialize-name "FactQnty" 
      field freeQnty as decimal serialize-name "FreeQnty"
  index pi as unique gds-code.
  
  define temp-table tt-barcodes no-undo serialize-name "Barcodes"
     field gds-code as integer  serialize-hidden
     index gds-code gds-code.
     
  define temp-table TempBCode no-undo serialize-name "TH_barcodes"
    field gds-code as integer serialize-name "GoodsID"
    field b-str as character serialize-name "BC"
    field priceSale as decimal serialize-name "PriceBC" 
    field unit-cli  as character serialize-name "UnitBC"
    field cliBaseRate as decimal serialize-name "UnitRate"
    field flags as integer serialize-name "Flags"
    index pi is unique primary b-str.
  
  method public handle CreateDsGoods ():
     define variable hDset as handle no-undo.
     create dataset hDset.

     hDset:set-buffers(buffer tt-goods:handle).
     hDset:serialize-name = "Goods".
     return hDset.
  end.
  
  method public handle CreateDsBarcodes ():
     define variable hDset as handle no-undo.
     buffer TempBCode:handle:BUFFER-FIELD("gds-code"):serialize-hidden = no .
     
     create dataset hDset.

     hDset:set-buffers(buffer TempBCode:handle).
     hDset:serialize-name = "Barcodes".
     return hDset.
  end.
  
  method public handle CreateDsGoodsAndBarcodes ():
     define variable hDset as handle no-undo.
     buffer TempBCode:handle:BUFFER-FIELD("gds-code"):serialize-hidden = yes .
     create dataset hDset.

     hDset:set-buffers(buffer tt-goods:handle,
                       buffer tt-barcodes:handle,
                       buffer TempBCode:handle).
     hDset:serialize-name = "Goods".
     hDset:add-relation(buffer tt-goods:handle, 
                        buffer tt-barcodes:handle,
                        "gds-code,gds-code",
                        false,
                        true).
     hDset:add-relation(buffer tt-barcodes:handle,
                        buffer TempBCode:handle,
                        "gds-code,gds-code",
                        false,
                        true).
     return hDset.
  end.
  