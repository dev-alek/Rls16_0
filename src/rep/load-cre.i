/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Демин Алексей Сергеевич
Дата создания: 09/08/05
Author: Alexey Demin
Creation date: 09/08/05

*/
                FIND LAST doc-recids NO-ERROR .
                CREATE doc-recids.
                assign
                    doc-recids.DocRecid = recid( b-trn-doc )
                    doc-recids.doc-code = b-trn-doc.doc-code .
                ACCUMULATE b-trn-doc.doc-code ( COUNT )
                                        b-trn-doc.doc-qnty ( TOTAL ) .
                DISPLAY stream RepStr
                    sym0 ( ACCUM COUNT b-trn-doc.doc-code ) @ ind
                    sym1 b-trn-doc.fact-date @ trn-doc.fact-date
                    sym2 b-trn-doc.doc-code @ trn-doc.doc-code
                    sym3 b-trn-doc.cli-name @ trn-doc.cli-name
                    sym4 b-trn-doc.doc-qnty @ trn-doc.doc-qnty
                    sym5 with frame DocsList .
                DOWN stream RepStr 1 with frame DocsList .