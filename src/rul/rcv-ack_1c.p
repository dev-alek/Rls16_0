block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : rcv-ack_1c.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Tue Nov 28 02:22:53 AST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
define input parameter p-pack-data  as memptr no-undo . // с 26/IX-2018 xml-файл читается из memptr, а не из файла 
define input parameter p-esys-id    as integer no-undo .
define output parameter p-status_   as integer no-undo .
define output parameter p-error     as character no-undo .

{ cmp/trg-def.i }
{ gbl/cur-time.i }

define variable v-num   as integer no-undo .
define variable v-sender-id as character no-undo .
define variable v-receiver-id as character no-undo .

define variable hDoc as handle no-undo.
define variable hRoot as handle no-undo.

define variable log_         as logical   no-undo.
define variable v-today            as date      no-undo .
define variable v-time             as integer   no-undo .

define buffer buf_sent for ub.esys-pck-sent .
define buffer buf_route for ub.esys-route .
define buffer buf_dump for ub.esys-route-dump .


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

v-num = ? .
p-status_ = ? .

create x-document hDoc.
create x-noderef hRoot.

hDoc:load("MEMPTR", p-pack-data, false).

hDoc:get-document-element(hRoot).

run GetChildren(hRoot, 1).

delete object hDoc.
delete object hRoot.

if v-num <> ? and p-status_ = 0 
then do :
    find first buf_sent exclusive-lock where buf_sent.db-num = 0
                                         and buf_sent.esys-id = p-esys-id
                                         and buf_sent.esps-cr-db-num = g#db-num
                                         and buf_sent.esps-pack-num = v-num
                                         no-error.
    if not available buf_sent
    then do :
        
    end.
    else do :
      run cur-time in this-procedure
          ( output v-today
           ,output v-time
          ) no-error .
      assign
        buf_sent.esps-rcvd = yes
        buf_sent.esps-rcvdDate = v-today
        buf_sent.esps-rcvdtime = string(v-time, "HH:MM:SS")
        buf_sent.esps-rcvdtimeint = v-time
      .
      for each buf_route exclusive-lock where buf_route.esys-id = buf_sent.esys-id
                                          and buf_route.db-num = buf_sent.db-num
                                          and buf_route.esr-last-pack = buf_sent.esps-pack-num :
        for each buf_dump where buf_dump.esrd-dump-ord = buf_route.esr-dump-ord:
          delete buf_dump no-error .
        end.
        delete buf_route .
      end.
    end.                                     
end.


procedure GetChildren :
  define input parameter hParent as handle .
  define input parameter level as integer .
  
  define variable i            as integer   no-undo.
  define variable hNoderef     as handle    no-undo.
  define variable hText        as handle    no-undo.

  create x-noderef hNoderef.
  create x-noderef hText .

  repeat i = 1 to hParent:num-children:
      log_ = hparent:get-child(hnoderef,i).
      if not log_ then
          leave.
      if hnoderef:subtype <> "element" then
          next.
      hnoderef:get-child(htext, 1) no-error .

      if hNoderef:name = "num" then v-num = integer(hText:node-value) no-error .
      if hNoderef:name = "sender-id" then v-sender-id = hText:node-value no-error .
      if hNoderef:name = "receiver-id" then v-receiver-id = hText:node-value no-error .
      if hNoderef:name = "status" then p-status_ = integer(hText:node-value) no-error .
      if hNoderef:name = "error" then p-error = hText:node-value no-error .

      run GetChildren (hNoderef, (level + 1)).
  end.

  DELETE OBJECT hNoderef.
  DELETE OBJECT hText.
end procedure .