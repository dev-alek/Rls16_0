/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Чтение и запись атрибутов документов производства

Автор: Хныкин Павел Андреевич
Дата создания: 02/17/09
Author: Pavel Khnykin
Creation date: 02/17/09

Required:
    { cmp/str-glbl.i }
    { str/trdcalib.i }

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define fbrattr-type-fbr-doc 'fbr-doc':U
&global-define fbrattr-type-fbr-pln 'fbr-pln':U

/*==========================================================================
    Запись значения атрибута

    Input:
        p-doc-type          - Тип документа, для которого сохраняется значение атрибута: {&fbrattr-type-fbr-doc} или {&fbrattr-type-fbr-pln}.
        p-attr-code         - Код атрибута из  t r d c a t t r . i  (например {&trdcattr-fbroperator})
        p-doc-code          - Номер документа.
        p-fbroperator-code  - clients.obj-code при clients.obj-type = {&prs} для оператора производства.
*/
procedure fbrattr-write :
  define input parameter p-doc-type       as character        no-undo.
  define input parameter p-doc-code       as character        no-undo.
  define input parameter p-attr-code      as character        no-undo.
  define input parameter p-attr-value     as character        no-undo.

  do
  on error undo, return error
  :
    { str/tdat-wrt.i
        substitute("'&1-&2'",p-doc-type,p-doc-code)
        p-attr-code
        p-attr-value
    }
  end.
end procedure. /* fbrattr-write */


/*==========================================================================
    Чтение значения атрибута

    Input:
        p-doc-type  - Тип документа, для которого вычисляется значение атрибута: {&fbrattr-type-fbr-doc} или {&fbrattr-type-fbr-pln}.
        p-attr-code - Код атрибута из  t r d c a t t r . i  (например {&trdcattr-fbroperator})
        p-doc-code  - Номер документа.

    Output:
        p-fbroperator-code - clients.obj-code при clients.obj-type = {&prs} для оператора производства.
*/
procedure fbrattr-value :
  define  input parameter p-doc-type      as character        no-undo.
  define  input parameter p-doc-code      as character        no-undo.
  define  input parameter p-attr-code     as character        no-undo.
  define output parameter p-attr-value    as character        no-undo.

  define variable v-par-value     as character    no-undo.
  define variable v-par-type      as character    no-undo.

  define buffer buf_clients       for ub.clients.

  do
  for buf_clients
  on error undo, return error
  :
    { str/tdat-val.i
        substitute("'&1-&2'",p-doc-type,p-doc-code)
        p-attr-code
        p-attr-value
        v-par-type
    }
  end.
end procedure. /* fbrattr-value */

/* $Workfile$   E n d */