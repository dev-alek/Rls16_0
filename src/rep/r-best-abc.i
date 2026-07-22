/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

для работы с отчетом по бустсселерам

Автор: Шаланин Сергей
Дата создания: 02/17/09
Author: Shalanin Sergey
Creation date: 02/17/09

Required:

*/
            if v#abc > 80  and xcrit = xsort  then  
                do: 
                    if v#prev   < 80 then 
                      do:
                          v-group = "А".
                       run display-abc ( input 0, input v#prev , input v-group  ) .
                    v#abc-do = v#prev .
                    v#income = 0 .
                    end.
                     end.
                    
          if v#abc > 95 and  xcrit = xsort then  
                do: 
                    if v#prev   < 95 then 
                     do:
                         v-group = "Б".
                        run display-abc ( input v#abc-do , input v#prev, input v-group  ).
                v#abc-do = v#prev .
               v#income = 0.
            
                    end.
                end.
                
              
                
                