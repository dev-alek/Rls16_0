/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт списка документов в формате EXCEL и обычном формате

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/06/06
Author: Bakhtadze Natalya
Creation date: 01/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR EACH {1} No-LOCK
    BREAK
    BY {1}.doc-code :
    for-cli-type = get-client({1}.doc-code, {1}.doc-type).
  assign
  accum-count = accum-count + 1
  .
  { rep/dincol.i di 1 for-doc-code
                {1}.doc-code }

  { rep/dincol.i di 2 for-doc-type
                 {1}.doc-type }


  { rep/dincol.i di 3 for-obj-type
                 {1}.obj-type }

  { rep/dincol.i di 4 for-obj-code
                 {1}.obj-code }

  { rep/dincol.i di 5 for-cli-type
                 for-cli-type }

  { rep/dincol.i di 6 for-cli-code
                 for-cli-code }

  { rep/dincol.i di 7 for-cli-name
                 for-cli-name }


  {&DISPLAY-FRAME}

  {&PutExcel}
  { rep/dincol.i dix 1 for-doc-code {1}.doc-code }
  { rep/dincol.i dix 2 for-doc-type {1}.doc-type }
  { rep/dincol.i dix 3 for-obj-type {1}.obj-type }
  { rep/dincol.i dix 4 for-obj-code {1}.obj-code }
  { rep/dincol.i dix 5 for-cli-type for-cli-type }
  { rep/dincol.i dix 6 for-cli-code for-cli-code }
  { rep/dincol.i dix 7 for-cli-name for-cli-name }
  skip.


  IF LAST({1}.doc-code) then do:

    {&UNDERLINE-FRAME}

    { rep/dincol.i di 6 for-cli-code
                   accum-count }

    { rep/dincol.i di 7 for-cli-name
                   " 'документов в спискe' " }

    {&DISPLAY-FRAME}

  end.

END. /*for each {1} */




/* $Workfile$ e n d */