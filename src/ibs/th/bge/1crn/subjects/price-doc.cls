 
 /*------------------------------------------------------------------------
    File        : price-doc
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Wed Nov 01 15:17:35 AST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.price-doc implements iexpsubject: 
    
  { cmp/str-glbl.i class }
  
  define buffer buf_price-doc for ub.price-doc .
  define buffer buf_price-list for ub.price-list .
  define buffer buf_bar-code for ub.bar-code .

  define property Msg as character no-undo
    get.
    private set.
  
  define property InitSecTag as character no-undo init "price-docs"
    get.
    private set.
      
  define public property sendTableName as character no-undo init "price-doc"
    get.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define property DocNum as character no-undo
    get.
    set. 
  
  define property ToDel as logical no-undo
    get.
    set.
    
  define property pr-doc-hndl as handle no-undo
    get.
    set.   
    
    
  define variable sw               as handle    no-undo.  
  
  method public void CrContentToSW (insw as handle):

    sendOldRowid  = pr-doc-hndl:rowid.
    sw = insw .
    
    if ToDel
    then do :
          
/*        sw:start-element ("price-docs") .*/
          sw:start-element ("price-doc") .
          
          
          if pr-doc-hndl::uid-es <> ? and string(pr-doc-hndl::uid-es) <> ""
          then
            sw:write-data-element ("doc-id", string(pr-doc-hndl::uid-es)). 
            
          if pr-doc-hndl::doc-num-es <> ? and string(pr-doc-hndl::doc-num-es) <> ""
          then
            sw:write-data-element ("doc-num", string(pr-doc-hndl::doc-num-es)). 
            
            sw:write-data-element ("doc-code", string(pr-doc-hndl::doc-num)).
            sw:write-data-element ("doc-num-gs", string(pr-doc-hndl::doc-num)).
            sw:write-data-element ("doc-date", if pr-doc-hndl::doc-date = ? then "" else iso-date(pr-doc-hndl::doc-date) ).  
            
         
            sw:write-data-element ("doc-status", "4").
            sw:write-data-element ("status-date", (iso-date(TODAY) + "T" + string(TIME, "HH:MM:SS") ) ).
          
      
          sw:end-element ("price-doc") .
/*        sw:end-element ("price-docs") .*/
    end.    
    else do :
        find first buf_price-doc no-lock where buf_price-doc.doc-num = DocNum no-error.
        if not available (buf_price-doc)
          then return.
          
/*        sw:start-element ("price-docs") .*/
          sw:start-element ("price-doc") .
          
          if buf_price-doc.uid-es <> ? and buf_price-doc.uid-es <> ""
          then
            sw:write-data-element ("doc-id", buf_price-doc.uid-es). 
            
          if buf_price-doc.doc-num-es <> ? and buf_price-doc.doc-num-es <> ""
          then
            sw:write-data-element ("doc-num", buf_price-doc.doc-num-es). 
            
            sw:write-data-element ("doc-code", buf_price-doc.doc-num).
            sw:write-data-element ("doc-num-gs", buf_price-doc.doc-num).
            sw:write-data-element ("doc-date", if buf_price-doc.doc-date = ? then "" else iso-date(buf_price-doc.doc-date) ).  
            
          if buf_price-doc.status_ = {&order}
          then do :
            sw:write-data-element ("doc-status", "2").
            sw:write-data-element ("status-date", (iso-date(TODAY) + "T" + string(TIME, "HH:MM:SS") ) ).
          end.  
          if buf_price-doc.status_ = {&act-overvalue}
          then do :
            sw:write-data-element ("doc-status", "3").
            sw:write-data-element ("status-date", (iso-date(buf_price-doc.fact-date) + "T" + string(buf_price-doc.fact-time, "HH:MM:SS") ) ).
          end.
          if   (buf_price-doc.doc-num-es = ? or trim(buf_price-doc.doc-num-es) = "")
          and  (buf_price-doc.uid-es = ? or trim(buf_price-doc.uid-es) = "")
          then do :
            sw:write-data-element ("cr-gs", string(1)).
          end.
          else do :
            sw:write-data-element ("cr-gs", string(0)).
          end.
          if   (buf_price-doc.doc-num-es = ? or trim(buf_price-doc.doc-num-es) = "")
          and  (buf_price-doc.uid-es = ? or trim(buf_price-doc.uid-es) = "")
          or buf_price-doc.status_ = {&act-overvalue}
          then do :
            sw:start-element ("price-list") .
            for each buf_price-list no-lock where buf_price-list.doc-num = buf_price-doc.doc-num
                                              and buf_price-list.price-type = '',
              first buf_bar-code no-lock where buf_bar-code.b-code = buf_price-list.b-code :
              sw:start-element ("gds-sale") .
                sw:write-data-element ("gds-code", string(buf_bar-code.gds-code)).
                sw:write-data-element ("price-sale", string(buf_price-list.price-sale)).
                if buf_price-list.price-prev <> ?
                then sw:write-data-element ("price-sale-old", string(buf_price-list.price-prev)).
                if buf_price-list.doc-qnty <> ?
                then sw:write-data-element ("qnty", string(buf_price-list.doc-qnty)).
              sw:end-element ("gds-sale")  .  
            end.
            sw:end-element ("price-list") .
          end.
      
          sw:end-element ("price-doc") .
/*        sw:end-element ("price-docs") .*/
    end.
  
  end.
            

end class.