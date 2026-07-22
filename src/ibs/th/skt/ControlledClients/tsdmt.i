define temp-table TempTrnLineMT no-undo
  field lineid    as integer 
  field docname   as character   
  field pos       as integer
  field goodsid   as integer 
  field goodsname as character
  field UnitBC    as character
  field BC        as character
  field Price_    as character
  field DocQnty   as character
  field FactQnty  as character
  field AlcCode   as character
  field PartIDTH  as character
  field NotDict   as logical
index pi docname lineid.
  
define temp-table TempMarkLineMT no-undo
  field LineId   as integer
  field DocName  as character
  field MarkCode as character
  field PartIDTH as character
  field Sts      as character
  field MarkParent as character
index pi DocName MarkCode.
  
  
define temp-table TempTrnDocMT no-undo
  field DocName    as character
  field DocType    as character
  field Complete_  as logical
  field Status_    as character
  field ClientID   as integer
  field ClientType as character
  field ObjectID   as integer
  field ObjectType as character
  field UserID_    as character
  field UserName   as character
  field FactSum    as decimal
  field StartDate  as character
  field Flags_     as integer
index pi DocName.