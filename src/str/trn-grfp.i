/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд по вариациям документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do on error undo, return error return-value :
case parext-doc-type:
   when {&TDEDT_Pri_Vnesh} then do:
      case parstatus-current :
        when {&inquiry} then do:
           case parflag-current:
             when no then do:
               &if (defined(ext-inc-inq-minus) = 0) &then
                  &message "Не задан параметр ext-inc-inq-minus"
               &endif
               {&ext-inc-inq-minus}
             end.
             when yes then do:
               &if (defined(ext-inc-inq-plus) = 0) &then
                  &message "Не задан параметр ext-inc-inq-plus"
               &endif
               {&ext-inc-inq-plus}
             end.
             otherwise do:
               return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
             end.
           end case.
        end.
        when {&wayb} then do:
           case parflag-current:
              when no then do:
                &if (defined(ext-inc-wayb-minus) = 0) &then
                   &message "Не задан параметр ext-inc-wayb-minus"
                &endif
                {&ext-inc-wayb-minus}
              end.
              when yes then do:
                &if (defined(ext-inc-wayb-plus) = 0) &then
                   &message "Не задан параметр ext-inc-wayb-plus"
                &endif
                {&ext-inc-wayb-plus}
              end.
              otherwise do:
                return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
              end.
           end case.
        end.
        when {&fact} then do:
          &if (defined(ext-inc-fact) = 0) &then
             &message "Не задан параметр ext-inc-fact"
          &endif
          {&ext-inc-fact}
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when {&TDEDT_Ras_Vnesh}    or
   when {&TDEDT_Ras_Vnesh_VP} then do:
      case parstatus-current :
        when {&inquiry} then do:
          case parflag-current:
            when no then do:
              &if (defined(ext-exp-inq-minus) = 0) &then
                 &message "Не задан параметр ext-exp-inq-minus"
              &endif
              {&ext-exp-inq-minus}
            end.
            when yes then do:
              &if (defined(ext-exp-inq-plus) = 0) &then
                 &message "Не задан параметр ext-exp-inq-plus"
              &endif
              {&ext-exp-inq-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&wayb} then do:
          case parflag-current:
            when no then do:
              &if (defined(ext-exp-wayb-minus) = 0) &then
                 &message "Не задан параметр ext-exp-wayb-minus"
              &endif
              {&ext-exp-wayb-minus}
            end.
            when yes then do:
              &if (defined(ext-exp-wayb-plus) = 0) &then
                 &message "Не задан параметр ext-exp-wayb-plus"
              &endif
              {&ext-exp-wayb-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&permitted} then do:
          case parflag-current:
            when no then do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
            when yes then do:
              &if (defined(ext-exp-perm-plus) = 0) &then
                 &message "Не задан параметр ext-exp-perm-plus"
              &endif
              {&ext-exp-perm-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&fact} then do:
          &if (defined(ext-exp-fact) = 0) &then
             &message "Не задан параметр ext-exp-fact"
          &endif
          {&ext-exp-fact}
        end.
        when {&ready} or
        when {&rejected} then do:
          &if (defined(ext-exp-fact) = 0) &then
             &message "Не задан параметр ext-exp-fact"
          &endif
          {&ext-exp-fact}
        end.

        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when {&TDEDT_Spi_Vnesh} then do:
      case parstatus-current :
        when {&inquiry} then do:
          case parflag-current:
            when no then do:
              &if (defined(ext-wroff-inq-minus) = 0) &then
                 &message "Не задан параметр ext-wroff-inq-minus"
              &endif
              {&ext-wroff-inq-minus}
            end.
            when yes then do:
              &if (defined(ext-wroff-inq-plus) = 0) &then
                 &message "Не задан параметр ext-wroff-inq-plus"
              &endif
              {&ext-wroff-inq-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&wayb} then do:
          case parflag-current:
            when no then do:
              &if (defined(ext-wroff-wayb-minus) = 0) &then
                 &message "Не задан параметр ext-wroff-wayb-minus"
              &endif
              {&ext-wroff-wayb-minus}
            end.
            when yes then do:
              &if (defined(ext-wroff-wayb-plus) = 0) &then
                 &message "Не задан параметр ext-wroff-wayb-plus"
              &endif
              {&ext-wroff-wayb-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&permitted} then do:
          case parflag-current:
            when no then do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
            when yes then do:
              &if (defined(ext-wroff-perm-plus) = 0) &then
                 &message "Не задан параметр ext-wroff-perm-plus"
              &endif
              {&ext-wroff-perm-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&fact} then do:
          &if (defined(ext-wroff-fact) = 0) &then
             &message "Не задан параметр ext-wroff-fact"
          &endif
          {&ext-wroff-fact}
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when {&TDEDT_Vozvrat_Vnesh} then do:
      case parstatus-current :
        when {&inquiry} then do:
          case parflag-current:
            when no then do:
              &if (defined(ext-ret-inq-minus) = 0) &then
                 &message "Не задан параметр ext-ret-inq-minus"
              &endif
              {&ext-ret-inq-minus}
            end.
            when yes then do:
              &if (defined(ext-ret-inq-plus) = 0) &then
                 &message "Не задан параметр ext-ret-inq-plus"
              &endif
              {&ext-ret-inq-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&wayb} then do:
          case parflag-current:
            when no then do:
              &if (defined(ext-ret-wayb-minus) = 0) &then
                 &message "Не задан параметр ext-ret-wayb-minus"
              &endif
              {&ext-ret-wayb-minus}
            end.
            when yes then do:
              &if (defined(ext-ret-wayb-plus) = 0) &then
                 &message "Не задан параметр ext-ret-wayb-plus"
              &endif
              {&ext-ret-wayb-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&permitted} then do:
          case parflag-current:
            when no then do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
            when yes then do:
              &if (defined(ext-ret-perm-plus) = 0) &then
                 &message "Не задан параметр ext-ret-perm-plus"
              &endif
              {&ext-ret-perm-plus}
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when {&fact} then do:
          &if (defined(ext-ret-fact) = 0) &then
             &message "Не задан параметр ext-ret-fact"
          &endif
          {&ext-ret-fact}
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when {&TDEDT_Inv} then do:
     case parstatus-current:
       when {&wayb} then do:
         case parflag-current:
           when no then do:
             &if (defined(inv-wayb-minus) = 0) &then
                &message "Не задан параметр inv-wayb-minus"
             &endif
             {&inv-wayb-minus}
           end.
           when yes then do:
             &if (defined(inv-wayb-plus) = 0) &then
                &message "Не задан параметр inv-wayb-plus"
             &endif
             {&inv-wayb-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&permitted} then do:
         case parflag-current:
           when no then do:
             &if (defined(inv-perm-minus) = 0) &then
                &message "Не задан параметр inv-perm-minus"
             &endif
             {&inv-perm-minus}
           end.
           when yes then do:
             &if (defined(inv-perm-plus) = 0) &then
                &message "Не задан параметр inv-perm-plus"
             &endif
             {&inv-perm-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&fact} then do:
         &if (defined(inv-fact) = 0) &then
            &message "Не задан параметр inv-fact"
         &endif
         {&inv-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Peresort} then do:
     case parstatus-current:
       when {&wayb} then do:
         &if (defined(peresort-wayb) = 0) &then
            &message "Не задан параметр peresort-perm"
         &endif
         {&peresort-wayb}
       end.
       when {&fact} then do:
         &if (defined(peresort-fact) = 0) &then
            &message "Не задан параметр peresort-fact"
         &endif
         {&peresort-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Corr_Acc_Price} then do:
     case parstatus-current:
       when {&wayb} then do:
         case parflag-current:
           when no then do:
             &if (defined(cp-wayb-minus) = 0) &then
                &message "Не задан параметр cp-wayb-minus"
             &endif
             {&cp-wayb-minus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&fact} then do:
         &if (defined(cp-fact) = 0) &then
            &message "Не задан параметр cp-fact"
         &endif
         {&cp-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Corr_Minus_Parts} then do:
     case parstatus-current:
       when {&wayb} then do:
         case parflag-current:
           when no then do:
             &if (defined(cmp-wayb-minus) = 0) &then
                &message "Не задан параметр cmp-wayb-minus"
             &endif
             {&cmp-wayb-minus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&fact} then do:
         &if (defined(cmp-fact) = 0) &then
            &message "Не задан параметр cmp-fact"
         &endif
         {&cmp-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Pri_Perem} then do:
     case parstatus-current:
       when {&inquiry} then do:
         case parflag-current:
           when no then do:
             &if (defined(int-inc-inq-minus) = 0) &then
                &message "Не задан параметр int-inc-inq-minus"
             &endif
             {&int-inc-inq-minus}
           end.
           when yes then do:
             &if (defined(int-inc-inq-plus) = 0) &then
                &message "Не задан параметр int-inc-inq-plus"
             &endif
             {&int-inc-inq-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&wayb} then do:
         case parflag-current:
           when no then do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
           when yes then do:
             &if (defined(int-inc-wayb-plus) = 0) &then
                &message "Не задан параметр int-inc-wayb-plus"
             &endif
             {&int-inc-wayb-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&fact} then do:
         &if (defined(int-inc-fact) = 0) &then
            &message "Не задан параметр int-inc-fact"
         &endif
         {&int-inc-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Ras_Perem} then do:
     case parstatus-current:
       when {&inquiry} then do:
         case parflag-current:
           when no then do:
             &if (defined(int-exp-inq-minus) = 0) &then
                &message "Не задан параметр int-exp-inq-minus"
             &endif
             {&int-exp-inq-minus}
           end.
           when yes then do:
             &if (defined(int-exp-inq-plus) = 0) &then
                &message "Не задан параметр int-exp-inq-plus"
             &endif
             {&int-exp-inq-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&wayb} then do:
         case parflag-current:
           when no then do:
             &if (defined(int-exp-wayb-minus) = 0) &then
                &message "Не задан параметр int-exp-wayb-minus"
             &endif
             {&int-exp-wayb-minus}
           end.
           when yes then do:
             &if (defined(int-exp-wayb-plus) = 0) &then
                &message "Не задан параметр int-exp-wayb-plus"
             &endif
             {&int-exp-wayb-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&permitted} then do:
         case parflag-current:
           when yes then do:
             &if (defined(int-exp-perm-plus) = 0) &then
                &message "Не задан параметр int-exp-perm-plus"
             &endif
             {&int-exp-perm-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&fact} then do:
         &if (defined(int-exp-fact) = 0) &then
            &message "Не задан параметр int-exp-fact"
         &endif
         {&int-exp-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Vozvrat_Perem} then do:
     case parstatus-current:
       when {&wayb} then do:
         case parflag-current:
           when yes then do:
             &if (defined(int-ret-wayb-plus) = 0) &then
                &message "Не задан параметр int-ret-wayb-plus"
             &endif
             {&int-ret-wayb-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&permitted} then do:
         case parflag-current:
           when yes then do:
             &if (defined(int-ret-perm-plus) = 0) &then
                &message "Не задан параметр int-ret-perm-plus"
             &endif
             {&int-ret-perm-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when {&fact} then do:
         &if (defined(int-ret-fact) = 0) &then
            &message "Не задан параметр int-ret-fact"
         &endif
         {&int-ret-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Ras_Object} then do:
     case parstatus-current:
       when {&wayb} then do:
         case parflag-current:
           when no then do:
             &if (defined(obj-exp-wayb-minus) = 0) &then
                &message "Не задан параметр obj-exp-wayb-minus"
             &endif
             {&obj-exp-wayb-minus}
           end.
           when yes then do:
             &if (defined(obj-exp-wayb-plus) = 0) &then
                &message "Не задан параметр obj-exp-wayb-plus"
             &endif
             {&obj-exp-wayb-plus}
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.  
       end.
       when {&fact} then do:
         &if (defined(int-exp-fact) = 0) &then
            &message "Не задан параметр int-exp-fact"
         &endif
         {&int-exp-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when {&TDEDT_Pri_Object} then do:
     case parstatus-current:
       when {&wayb} then do:
         &if (defined(obj-int-wayb) = 0) &then
            &message "Не задан параметр obj-int-wayb"
         &endif
         {&obj-int-wayb} 
       end.  
       when {&fact} then do:
         &if (defined(int-inc-fact) = 0) &then
            &message "Не задан параметр int-inc-fact"
         &endif
         {&int-inc-fact}
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   otherwise do:
     return error substitute ("Недопустимый расширеный тип &1.", parext-doc-type).
   end.
end case.
end.

/*e n d of trn-grp.i*/