/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка валидности изменения типа ед изм

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  assign
    old-type  = (if lookup ({&pieces}, {2}.type)     = 0 then "0" else "1")
              + (if lookup ({&divisional}, {2}.type) = 0 then "0" else "1")
              + (if lookup ({&serial}, {2}.type)     = 0 then "0" else "1")
              + (if lookup ({&weight}, {2}.type)     = 0 then "0" else "1")
              + (if lookup ({&petrolium}, {2}.type)  = 0 then "0" else "1")
              + (if lookup ({&twounit}, {2}.type)    = 0 then "0" else "1")
              + (if lookup ({&altunit}, {2}.type)    = 0 then "0" else "1")
              + (if lookup ({&bottle}, {2}.type)     = 0 then "0" else "1")
    new-type  = (if lookup ({&pieces}, {1}.type)     = 0 then "0" else "1")
              + (if lookup ({&divisional}, {1}.type) = 0 then "0" else "1")
              + (if lookup ({&serial}, {1}.type)     = 0 then "0" else "1")
              + (if lookup ({&weight}, {1}.type)     = 0 then "0" else "1")
              + (if lookup ({&petrolium}, {1}.type)  = 0 then "0" else "1")
              + (if lookup ({&twounit}, {1}.type)    = 0 then "0" else "1")
              + (if lookup ({&altunit}, {1}.type)    = 0 then "0" else "1")
              + (if lookup ({&bottle}, {1}.type)     = 0 then "0" else "1")
  .

  if lookup (new-type, "10000000,01000000,00100000,00010000,10001000,01001000,01000100,10000010,10000001") = 0 then do:
    /* недопустимый тип единицы измерения */
    if g#esys then do:
              undo, return error substitute( "&2&1Недопустимый тип единицы измерения&1
                                              Единица измерения &3&1
                                              Тип единицы измерения &4&1
                                              Характеристика типа &5&1 
                                              &6&1&7"
                             , {&new-line}
                             , vss-workfile
                             , {1}.unit-name
                             , {1}.type
                             , new-type
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    else do:  
    message
      vss-workfile vss-revision vss-description skip
      "Недопустимый тип единицы измерения" skip
      "Единица измерения" {1}.unit-name skip
      "Тип единицы измерения" {1}.type skip
      "Характеристика типа" new-type skip
      view-as alert-box error .
    undo main-block, return error .
    end.
  end.




  if old-type <> new-type then do:
    /* проверяем допустимость замены на соответствие списку возможных замен */
    if lookup ((old-type + "-" + new-type),
      /* ВНИМАНИЕ! Должны быть перечислены все допустимые переходы, в т.ч. кросс-переходы
          Это нужно для СПН. Например, если перечислены переходы А-Б,Б-В, то обязательно нужен и А-В
         может быть после введения twounit можно разрешить еще и "100000-010001,010000-010001" ?
          */
      "10000000-01000000,10001000-01001000,00001000-10001000,00001000-01001000,10000000-10000010,10000010-10000000") = 0 and
      old-type <> "00000000" then do:
        if g#esys then do:
                        undo, return error substitute( "&2&1Недопустимая замена типа единицы измерения&1
                                              Единица измерения &3&1
                                              Тип единицы измерения &4&1
                                              Характеристика типа &5&1 
                                              &6&1&7"
                             , {&new-line}
                             , vss-workfile
                             , {1}.unit-name
                             , {1}.type
                             , new-type
                             , return-value
                             , error-status :get-message ( 1 ) ).
        end.
        else do:  
      message
        vss-workfile vss-revision vss-description skip
        "Недопустимая замена типа единицы измерения" skip
        "Единица измерения" {1}.unit-name skip
        "Изменение типа:" {2}.type "->" {1}.type skip
        "Изменение характеристики типа:" old-type "->" new-type skip
        view-as alert-box error .
      undo main-block, return error .
      end.
    end.
  end.

/* $Workfile$ e n d */