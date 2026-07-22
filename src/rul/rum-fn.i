/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с именами файлов при экспосрте-импорте через RUM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/23/08
Author: Bakhtadze Natalya
Creation date: 06/23/08

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".



FUNCTION rum-fn_get-next-file-name returns character (
                                    input p-base-file-name as character
                                  , input p-index as integer):
define variable v-loc-file-name as character no-undo .
v-loc-file-name = substitute("&1_&2.&3"
                            ,substring(p-base-file-name, 1, (if r-index(p-base-file-name, ".") > 1
                                                      then (r-index(p-base-file-name, ".") - 1)
                                                      else length(p-base-file-name)
                                                      )
                                        )
                            ,p-index
                            ,(if r-index(p-base-file-name, ".") > 1
                              then substring(p-base-file-name, r-index(p-base-file-name, ".") + 1)
                              else '')
                              )
                              .
return v-loc-file-name.

end function.
