/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 08/28/07
Author: Svetlana Chernova
Creation date: 08/28/07


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function autorvs return char
    ( input p-rec as recid  ) :
    define variable p-autorvs as char no-undo.
        
    define buffer Buf_doc-attr for doc-attr.
    define buffer r-d          for rvs-doc.

    find first r-d no-lock where recid(r-d) = p-rec no-error.
        
    find first buf_doc-attr no-lock where r-d.rvs-code = buf_doc-attr.doc-code and buf_doc-attr.attr-code = "rvs-auto" and buf_doc-attr.attr-value = "Yes" no-error. 
    
    
    if available buf_doc-attr then 
    do :
        p-autorvs = 'а'.
    end.
    else 
    do: 
        if r-d.is-full = yes then 
        do: 
            p-autorvs =  "п" .
        end.
        else 
        do : 
            p-autorvs = " ".
        end.
    end.
    return ( p-autorvs ).
end function.


