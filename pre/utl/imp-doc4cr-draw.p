block-level on error undo, throw.
define temp-table tt-imp-parts no-undo // скопировано из utl/imp-doc4.p
   field artic         as character
           field f02           as character
   field part-code     as character
   field in-code       like ub.parts.in-code
   field gds-code      as int64
   field price-rubl    like ub.parts.price-rubl
   field fact-qnty     like ub.parts.fact-qnty
           field f08           as character
           field f09           as character
           field f10           as character
   field vat-tax-value as decimal
           field f12           as character
           field f13           as character
   field name-gtd      as character
           field f15           as character
           field f16           as character
   field srok-god      as character
           field f18           as character
           field f19           as character
   field supp-code     as integer
   field supp-type     as character
   field cont-prn-code like ub.contract.contract-prn-code
           field imp-row       as character // исходая строка из файла импорта
.
define input  parameter iUtil        as class ibs.th.utl.method-for-draw-utility no-undo.
define input  parameter iosn-fname   as character no-undo.
define input  parameter iart-fname   as character no-undo.
define input  parameter iretry-fname as character no-undo.
define input  parameter table for tt-imp-parts .
 define variable v-count-err as integer no-undo .
define variable v-count-err1  as integer no-undo .
define variable v-count-err2  as integer no-undo .
  run utl/imp-doc4cr.p ( iUtil:parparentproc
                       , this-procedure // хронометраж через write-log-and-file()
                       , ""             // имя лог-файла, в который выводится хронометраж
                       , iUtil:Obj-code
                       , iUtil:Obj-type
                       , true // закрывать созданные документы
                       , iosn-fname // список соответствия поставщиков
                       , iart-fname // список соответствия товаров
                       , iretry-fname // файл для повторного импорта
                       , input table tt-imp-parts
                     , output v-count-err
                     , output v-count-err1
                     , output v-count-err2
                       ) .
procedure write-log-and-file :
define input parameter p1 as integer no-undo .
define input parameter p2 as character no-undo .
define input parameter p3 as integer no-undo .
define input parameter p-message as character no-undo .
  iutil:put-log(p-message) .
end procedure.
