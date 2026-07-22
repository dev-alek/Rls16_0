 
 /*------------------------------------------------------------------------
    File        : HeadHttp
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Fri Jan 12 13:59:50 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.map.ParamColection.

block-level on error undo, throw.

class ibs.th.skt.HeadHttp inherits objth: 

   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Заголовок НТТP запроса" get.
   
   define public property queryPar as character no-undo get.
   set.
   define public property queryAdr as character no-undo get.
   set.
   
   define public property queryReq as character no-undo get.
   set (arg as character ):
      queryReq = arg.
      define variable vPosPar as integer no-undo.
      vPosPar = index(arg,"?").
      if vPosPar eq 0
      then
         assign 
            queryPar = ""
            queryAdr = trim(arg,"/")
         .
      else
         assign
            queryAdr = trim(substring (arg, 1, vPosPar - 1), "/")
            queryPar =      substring (arg,    vPosPar + 1).
   end.
   
   define public property contentLength as int64     no-undo get. set.
   
   define public property userAgent     as character no-undo get. set.
   
   define public property contentType   as character no-undo get. set.
    
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define variable paramCol as ParamColection no-undo.
   define variable queryParamCol as ParamColection no-undo.
   constructor public HeadHttp (  ):
      super ().
      paramCol      = new ParamColection().
      
   end constructor.
   
   constructor public HeadHttp (iHeader as character):
      this-object().
      parshead(iHeader).
   end constructor.
      
   &scop CRLF chr(13) + chr(10)
   &scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)
   method public void parshead (iHeader as character) :
      define variable idxQuerypar as integer no-undo.
      queryReq = entry(2,iHeader, " ") no-error.
      define variable i as integer no-undo.
      define variable v-hd-line as character no-undo.
      iHeader = replace (iHeader,";",{&CRLF}).
      do i = 2 to num-entries(iHeader,{&CRLF}):
         v-hd-line = trim(entry(i,iHeader,{&CRLF})).
         if num-entries (v-hd-line,":") eq 2
         then do:
            if  v-hd-line  begins "Content-Length"  then  do:
                contentLength = INT(trim(substring(v-hd-line,16,length(v-hd-line)))).
            end.
            else if  v-hd-line  begins "content-type:"  then  do:
               contentType = trim(substring(v-hd-line,14,length(v-hd-line))).
            end.
            else if  v-hd-line  begins "user-agent:"  then  do:
               userAgent = trim(substring(v-hd-line,13,length(v-hd-line))).
            end.
            else do:
               paramCol:setParam(entry(1,v-hd-line,":"), trim (entry(2,v-hd-line,":")," ")).
            end.
         end.
      end.
   end.
   
   method public character getValue(iParam as char):
      return paramCol:getValue(iParam).
   end method.
    
   method public void setParam(iParam as char, iValue as char):
      paramCol:setParam(iParam, iValue).
   end method.
   
   method public character getQueryParam(iParam as char):
      define variable vi as integer no-undo.
      define variable par as character no-undo.
      define variable val as character no-undo.
      define variable str as character no-undo.
      if not valid-object (queryParamCol)
      then do:
         queryParamCol = new ParamColection().
         do vi = 1 to num-entries (QueryPar,"&"):
            assign
              str = entry (vi, QueryPar, "&")
              par = entry (1, str, "=")
              val = if num-entries (str,"=") > 1 then entry (2, str, "=") else ""
            no-error.
            queryParamCol:setParam(par, Val).
         end.
      end.
      return queryParamCol:getValue(iParam).
   end method.
    
   method private void setQueryParam(iParam as char, iValue as char):
      queryParamCol:setParam(iParam, iValue).
   end method.
   
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public HeadHttp ( ):
      delete object paramCol no-error.
	end destructor.


end class.