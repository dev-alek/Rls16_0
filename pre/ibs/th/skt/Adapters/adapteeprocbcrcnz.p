block-level on error undo, throw.
define input parameter objType as character no-undo.
define input parameter objCode as integer no-undo.
define input parameter barCode as character no-undo.
define parameter buffer buf_bar-code  for ub.bar-code.
define parameter buffer buf_prod-bc   for ub.prod-bc.
define parameter buffer buf_place     for ub.place.
define variable parresult  as character no-undo.
define variable partype-bc as character no-undo.
define variable parweight  as decimal   no-undo.
define new global shared variable g#libbcrcn as handle no-undo .
if (valid-handle(g#libbcrcn) <> true) then do:   run str/libbcrcn.p persistent no-error .   if error-status :error or (valid-handle(g#libbcrcn) <> true) then do:     message       "Error starting libbcrcn.p" skip       g#libbcrcn skip       g#libbcrcn :type skip       g#libbcrcn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run libbcrcn_bc-rcnz in g#libbcrcn
(
 input  ?
,input  barCode
,input  ?
,input  objType
,input  objCode
,input  no
,input  no
,input  ?
,input  ?
,output parresult
,output partype-bc
,output parweight
,buffer buf_bar-code
,buffer buf_prod-bc
,buffer buf_place
) no-error.
