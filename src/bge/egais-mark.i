/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разбор марки и определение Акогольного кода

Автор: Шкляр Елена
Дата создания: 12/24/09
Author: Shklyar Elena
Creation date: 12/24/09

*/
&scop f-l Base2Int64
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


{ gbl/std-func.i {&f-l} }
{ cmp/str-glbl.i }
{ ref/extclass.i }


/*Процедура извличения алкокода из акцизной марки и перевод в 10 систему*/
PROCEDURE ProcAlcCode :
  define input  parameter p-mark-alc as character  no-undo .
  define output parameter p-alc-code as character  no-undo initial ''.
  define output parameter p-error as logical no-undo initial no.
  define output parameter p-error-lang as logical no-undo initial no.
  define variable v-kol              as integer    no-undo .
  define variable v-alc-code as character no-undo .
  define variable v-result as character no-undo .
  define variable ii as integer no-undo .  
  DEFINE VARIABLE v_list AS CHARACTER NO-UNDO INITIAL '':U.
  ASSIGN 
    v_list = '0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,':U .

  v-alc-code = SUBSTRing (p-mark-alc, 8, 12) .
  /*проверка на русские буквы*/
  do ii = 1 to length (v-alc-code):
    if LOOKUP( SUBSTRING( v-alc-code, ii, 1 ), v_list )  < 1 then
    do:
      p-error-lang = yes .
      leave .
      
    end.
  end.
  p-alc-code = string (Base2Int64 (v-alc-code, 36) ) no-error.
  if (Base2Int64 (v-alc-code, 36) ) < 0 then 
  do:
    p-error = yes.
  end.
  else 
  do:
    if length(p-alc-code) < 20 then 
    do:
      p-alc-code = fill('0', 19 - length(p-alc-code)) + p-alc-code.
    end.  
  end.
  
    
END PROCEDURE.

/*Поиск алкокода в ТН*/
PROCEDURE ProcFindGds  :
  define input  parameter p-alc-code as character  no-undo .
  define output parameter p-gds-code as integer    no-undo .
  define buffer x_ext-classif        for ub.ext-classif .  
  
      find first X_ext-classif no-lock where X_ext-classif.classif-subject = {&table_goods} 
                                               and X_ext-classif.classif-name = {&extclass_goods_esys} 
                                               AND X_ext-classif.db-num = 0
                                               and X_ext-classif.CharKey_One = p-alc-code  
                                               no-error.
                                               
      if available x_ext-classif then p-gds-code = X_ext-classif.Key#_One. 
      
END PROCEDURE.

 

/* $Workfile$ e n d */