 
 /*------------------------------------------------------------------------
    File        : techlosses
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Ленкин
    Created     : Wed Jul 24 19:29:55 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.1crn.export.send1cerpsub.

block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.exp-techlosses inherits send1cerpsub: 

  define override public property InitSecTag as character no-undo init "techlosses"
  get.
   
  define override public property sendTableName as character no-undo init "trn-doc"
  get.
   
  define override public property vss-archive as character no-undo 
  get.
   

  define override public property vss-author as character no-undo 
  get.
   

  define override public property vss-date as character no-undo 
  get.
   

  define override public property vss-description as character no-undo 
  get.
   

  define override public property vss-revision as character no-undo 
  get.
   

  define override public property vss-workfile as character no-undo 
  get.
   
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public exp-techlosses (  ):
    super ().
  end constructor.

  method override public void CheckParam(  ):
    
      if not valid-handle (oldbh)
      then
         return error "Не передан старый буфер".
      if oldbh:table ne "trn-doc"
      then 
         return error "Старый буфер не trn-doc: " + oldbh:table. 
      return.

  end method.

  method override public void CrContentToSW( input hSaxWriter as handle ):
   define buffer buf_trn-doc for ub.trn-doc .
   define buffer buf_doc-line for ub.doc-line .
   define buffer buf_doc-line-attr for ub.doc-line-attr .
   define variable blowdown as decimal no-undo format "->>9.99".
   define variable fittings as decimal no-undo format "->>9.99".
   define variable emptying as decimal no-undo format "->>9.99".
   define variable refund as decimal no-undo format "->>9.99" init ?.
   define variable ctrlvalve as decimal no-undo format "->>9.99".

   
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = string(oldbh:buffer-field ("doc-code":U):buffer-value) no-error .
   if available buf_trn-doc
   then do:
     sendOldRowid = rowid(buf_trn-doc).
     for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
      find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and
      ub.goods.prod-code = buf_doc-line.prod-code and
      ub.goods.prod-type = buf_doc-line.prod-type no-error .
      if available (ub.goods) then do: 
      
      find first buf_doc-line-attr no-lock where buf_doc-line-attr.attr-code = "blowdown" and
      buf_doc-line-attr.doc-code = buf_doc-line.doc-code and
      buf_doc-line-attr.gds-code = ub.goods.gds-code no-error .
      if available (buf_doc-line-attr) then if buf_doc-line-attr.attr-value = ? then blowdown = 0 .
      else blowdown = decimal(buf_doc-line-attr.attr-value) .

      find first buf_doc-line-attr no-lock where buf_doc-line-attr.attr-code = "fittings" and
      buf_doc-line-attr.doc-code = buf_doc-line.doc-code and
      buf_doc-line-attr.gds-code = ub.goods.gds-code no-error .
      if available (buf_doc-line-attr) then if buf_doc-line-attr.attr-value = ? then fittings = 0 .
      else fittings = decimal(buf_doc-line-attr.attr-value) .

            find first buf_doc-line-attr no-lock where buf_doc-line-attr.attr-code = "emptying" and
      buf_doc-line-attr.doc-code = buf_doc-line.doc-code and
      buf_doc-line-attr.gds-code = ub.goods.gds-code no-error .
      if available (buf_doc-line-attr) then if buf_doc-line-attr.attr-value = ? then emptying = 0 .
      else emptying = decimal(buf_doc-line-attr.attr-value) .

            find first buf_doc-line-attr no-lock where buf_doc-line-attr.attr-code = "refund" and
      buf_doc-line-attr.doc-code = buf_doc-line.doc-code and
      buf_doc-line-attr.gds-code = ub.goods.gds-code no-error .
      if available (buf_doc-line-attr) then refund = decimal(buf_doc-line-attr.attr-value) .
      
            find first buf_doc-line-attr no-lock where buf_doc-line-attr.attr-code = "ctrlvalve" and
      buf_doc-line-attr.doc-code = buf_doc-line.doc-code and
      buf_doc-line-attr.gds-code = ub.goods.gds-code no-error .
      if available (buf_doc-line-attr) then if buf_doc-line-attr.attr-value = ? then ctrlvalve = 0 .
      else ctrlvalve = decimal(buf_doc-line-attr.attr-value) .

      hSaxWriter:start-element ("techlosse") .
      hSaxWriter:write-data-element (  "out-code":U,     buf_trn-doc.doc-code   ). 
      hSaxWriter:write-data-element (  "tl-blowdown":U,left-trim(string(blowdown,"->>>>>>>>9.999"))).
      hSaxWriter:write-data-element (  "tl-fittings":U,left-trim (string(fittings,"->>>>>>>>9.999"))).
      hSaxWriter:write-data-element (  "tl-emptying":U,left-trim (string(emptying,"->>>>>>>>9.999"))).
      if refund <> ? then hSaxWriter:write-data-element (  "tl-refund":U,left-trim (string(refund,"->>>>>>>>9.999"))).
      hSaxWriter:write-data-element (  "tl-ctrlvalve":U,left-trim (string(ctrlvalve,"->>>>>>>>9.999"))).
      hSaxWriter:end-element ("techlosse") .      
end.
   end.
end.
  end method.

  destructor public exp-techlosses ( ):

  end destructor.

end class.