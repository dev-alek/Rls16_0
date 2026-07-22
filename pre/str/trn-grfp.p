block-level on error undo, throw.
define input  parameter pardoc-type       like ub.trn-doc.doc-type     no-undo.
define input  parameter parext-doc-type   like ub.trn-doc.ext-doc-type no-undo.
define input  parameter parstatus-current like ub.trn-doc.status_      no-undo.
define input  parameter parflag-current   like ub.trn-doc.flag_        no-undo.
define input  parameter parinternal       like ub.trn-doc.internal     no-undo.
define input  parameter parmode           as   character               no-undo.
define input  parameter parcur-db-num     like ub.db.db-num            no-undo.
define input  parameter pardoc-db-num     like ub.trn-doc.cr-db-num    no-undo.
define input  parameter parcur-db-name    like ub.db.db-name           no-undo.
define input  parameter pardb-num         like ub.db.db-num            no-undo.
define input  parameter pardb-name        like ub.db.db-name           no-undo.
define input  parameter parobj-type       like ub.clients.obj-type     no-undo.
define input  parameter parobj-code       like ub.clients.obj-code     no-undo.
define input  parameter paractive         like ub.store.active         no-undo.
define input  parameter parhold-gen       as   logical                 no-undo.
define output parameter parstatus         like ub.trn-doc.status_      no-undo.
define output parameter parflag           like ub.trn-doc.flag_        no-undo.
define output parameter parcopystatus     like ub.trn-doc.status_      no-undo.
define output parameter parcopyflag       like ub.trn-doc.flag_        no-undo.
def var vss-revision    as character no-undo init "$Revision: 498238e333a5, 491, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Sun Feb 28 19:23:10 2016 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: trn-grfp.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/trn-grfp.p $":U .
def var vss-description as character no-undo init "Стандартный граф переходов складских документов по параметрам".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
    assign
      p-vss-parameters = substitute('&1|&2':u,substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,pardoc-type,parext-doc-type,parstatus-current,parflag-current,parinternal,parmode,parcur-db-num,pardoc-db-num),substitute('&1|&2|&3|&4|&5|&6|&7':u,parcur-db-name,pardb-num,pardb-name,parobj-type,parobj-code,paractive,parhold-gen))
    .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable varmain-for-active-remote as   logical initial no no-undo.
case parcur-db-num:
  when 0 then do:
    case pardb-num:
      when 0 then do:
        case paractive:
          when paractive = yes then do:
          end.
          otherwise do:
            return error substitute ("Объект базы данных &1 имеет признак пассивный. Объект определен неправильно.", pardb-num).
          end.
        end case.
      end.
      otherwise do:
        case paractive:
          when paractive = yes then do:
            assign varmain-for-active-remote = yes.
          end.
          otherwise do:
          end.
        end case.
      end.
    end case.
  end.
  otherwise do:
    case pardb-num:
      when 0 then do:
        case paractive:
          when paractive = yes then do:
            return error substitute ("Документ объекта базы данных &1. Появление этого документа на базе данных &2 является критической ошибкой.",
                                     pardb-num,
                                     parcur-db-num
                                     ).
          end.
          otherwise do:
            return error substitute ("Документ объекта базы данных &1. Появление этого документа на базе данных &2 является критической ошибкой.",
                                     pardb-num,
                                     parcur-db-num
                                     ).
          end.
        end case.
      end.
      otherwise do:
        case paractive:
          when paractive = yes then do:
            if pardb-num = parcur-db-num then do:
            end.
            else do:
              return error substitute ('Документ базы данных &1. Появление этого документа в базе данных &2 является критической ошибкой.',
                                       pardb-num,
                                       parcur-db-num).
            end.
          end.
          otherwise do:
            if pardb-num = parcur-db-num then do:
              return error substitute ("Объект базы данных &1 - пассивный, операции с документом невозможны.", pardb-num).
            end.
            else do:
              return error substitute ('Документ базы данных &1. Появление этого документа в базе данных &2 является критической ошибкой.',
                                       pardb-num,
                                       parcur-db-num).
            end.
          end.
        end case.
      end.
    end case.
  end.
end case.
assign
  parcopystatus = ?
  parcopyflag   = ?.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do on error undo, return error return-value :
case parext-doc-type:
   when 'ie':U then do:
      case parstatus-current :
        when 'запрос':U then do:
           case parflag-current:
             when no then do:
                run ext-inc-inq-minus    .
             end.
             when yes then do:
                run ext-inc-inq-plus     .
             end.
             otherwise do:
               return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
             end.
           end case.
        end.
        when 'накл':U then do:
           case parflag-current:
              when no then do:
                 run ext-inc-wayb-minus   .
              end.
              when yes then do:
                 run ext-inc-wayb-plus    .
              end.
              otherwise do:
                return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
              end.
           end case.
        end.
        when 'факт':U then do:
           run ext-inc-fact         .
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when 'ee':U    or
   when 'ep':U then do:
      case parstatus-current :
        when 'запрос':U then do:
          case parflag-current:
            when no then do:
               run ext-exp-inq-minus    .
            end.
            when yes then do:
               run ext-exp-inq-plus     .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'накл':U then do:
          case parflag-current:
            when no then do:
               run ext-exp-wayb-minus   .
            end.
            when yes then do:
               run ext-exp-wayb-plus    .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'разрешен':U then do:
          case parflag-current:
            when no then do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
            when yes then do:
               run ext-exp-perm-plus    .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'факт':U then do:
           run ext-exp-fact         .
        end.
        when 'готов':U or
        when 'отказ':U then do:
           run ext-exp-fact         .
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when 'we':U then do:
      case parstatus-current :
        when 'запрос':U then do:
          case parflag-current:
            when no then do:
               run ext-wroff-inq-minus  .
            end.
            when yes then do:
               run ext-wroff-inq-plus   .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'накл':U then do:
          case parflag-current:
            when no then do:
               run ext-wroff-wayb-minus .
            end.
            when yes then do:
               run ext-wroff-wayb-plus  .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'разрешен':U then do:
          case parflag-current:
            when no then do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
            when yes then do:
               run ext-wroff-perm-plus  .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'факт':U then do:
           run ext-wroff-fact       .
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when 're':U then do:
      case parstatus-current :
        when 'запрос':U then do:
          case parflag-current:
            when no then do:
               run ext-ret-inq-minus    .
            end.
            when yes then do:
               run ext-ret-inq-plus     .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'накл':U then do:
          case parflag-current:
            when no then do:
               run ext-ret-wayb-minus   .
            end.
            when yes then do:
               run ext-ret-wayb-plus    .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'разрешен':U then do:
          case parflag-current:
            when no then do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
            when yes then do:
               run ext-ret-perm-plus    .
            end.
            otherwise do:
              return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
            end.
          end case.
        end.
        when 'факт':U then do:
           run ext-ret-fact         .
        end.
        otherwise do:
          return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
        end.
      end case.
   end.
   when 'vt':U then do:
     case parstatus-current:
       when 'накл':U then do:
         case parflag-current:
           when no then do:
              run inv-wayb-minus       .
           end.
           when yes then do:
              run inv-wayb-plus        .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'разрешен':U then do:
         case parflag-current:
           when no then do:
              run inv-perm-minus       .
           end.
           when yes then do:
              run inv-perm-plus        .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run inv-fact             .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'vp':U then do:
     case parstatus-current:
       when 'накл':U then do:
          run peresort-wayb        .
       end.
       when 'факт':U then do:
          run peresort-fact        .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'ap':U then do:
     case parstatus-current:
       when 'накл':U then do:
         case parflag-current:
           when no then do:
              run cp-wayb-minus        .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run cp-fact              .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'mp':U then do:
     case parstatus-current:
       when 'накл':U then do:
         case parflag-current:
           when no then do:
              run cmp-wayb-minus       .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run cmp-fact             .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'iv':U then do:
     case parstatus-current:
       when 'запрос':U then do:
         case parflag-current:
           when no then do:
              run int-inc-inq-minus    .
           end.
           when yes then do:
              run int-inc-inq-plus     .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'накл':U then do:
         case parflag-current:
           when no then do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
           when yes then do:
              run int-inc-wayb-plus    .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run int-inc-fact         .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'ev':U then do:
     case parstatus-current:
       when 'запрос':U then do:
         case parflag-current:
           when no then do:
              run int-exp-inq-minus    .
           end.
           when yes then do:
              run int-exp-inq-plus     .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'накл':U then do:
         case parflag-current:
           when no then do:
              run int-exp-wayb-minus   .
           end.
           when yes then do:
              run int-exp-wayb-plus    .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'разрешен':U then do:
         case parflag-current:
           when yes then do:
              run int-exp-perm-plus    .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run int-exp-fact         .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'rv':U then do:
     case parstatus-current:
       when 'накл':U then do:
         case parflag-current:
           when yes then do:
              run int-ret-wayb-plus    .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'разрешен':U then do:
         case parflag-current:
           when yes then do:
              run int-ret-perm-plus    .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run int-ret-fact         .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'eo':U then do:
     case parstatus-current:
       when 'накл':U then do:
         case parflag-current:
           when no then do:
              run obj-exp-wayb-minus   .
           end.
           when yes then do:
              run obj-exp-wayb-plus    .
           end.
           otherwise do:
             return error substitute ("Недопустимый тип-статус-флаг &1-&2-&3.", pardoc-type, parstatus-current, parflag-current).
           end.
         end case.
       end.
       when 'факт':U then do:
          run int-exp-fact         .
       end.
       otherwise do:
         return error substitute ('Недопустимый тип-статус &1-&2 или недопустимое оперирование с документом.', pardoc-type, parstatus-current).
       end.
     end case.
   end.
   when 'io':U then do:
     case parstatus-current:
       when 'накл':U then do:
          run obj-int-wayb         .
       end.
       when 'факт':U then do:
          run int-inc-fact         .
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
procedure ext-inc-inq-minus :
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Запрос открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign parstatus = 'запрос':U
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-inq-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
       return error substitute ('Нельзя открывать запрос для объекта удаленной базы данных.', parmode, pardoc-type, parstatus-current, parflag-current, (if paractive = yes then 'активного' else 'пассивного'), parobj-type, parobj-code, pardb-name + '(' + string(pardb-num) + ')', parcur-db-name + '(' + string(parcur-db-num) + ')').
    end.
    assign parstatus = 'запрос':U
           parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
       return error substitute ('Нельзя переводить запрос в накладную для объекта удаленной БД.').
    end.
    assign
      parstatus     = 'запрос':U
      parflag       = yes
      parcopystatus = 'накл':U
      parcopyflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа на факт>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ на факт для объекта удаленной БД').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  otherwise do:
     return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-wayb-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    if parcur-db-num <> 0 and
       pardoc-db-num  = 0 then do:
      return error substitute ('Нельзя открыть документ созданный в главной БД.').
    end.
    if parhold-gen = yes then do:
      return error substitute ('Нельзя открыть документ межфирменного перемещения.').
    end.
    assign parstatus = 'накл':U
           parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ на факт для объекта удаленной БД').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  otherwise do:
     return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-inc-fact:
 return error substitute ('Документ закрыт на факт.', pardoc-type, parstatus-current).
end procedure.
procedure ext-exp-inq-minus:
case parmode:
  when '<открытие документа>':U then do:
      return error substitute("Документ открыт.").
  end.
  when '<закрытие документа>':U then do:
     assign parstatus = 'запрос':U
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-inq-plus:
case parmode:
  when '<открытие документа>':U then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя открывать запрос для объекта удаленной БД.').
     end.
     assign parstatus = 'запрос':U
            parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя переводить запрос в накладную для объекта удаленной БД.').
    end.
    assign
      parstatus = 'накл':U
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
       return error substitute ('Нельзя закрывать накладную для объекта удаленной БД.', parmode, pardoc-type, parstatus-current, parflag-current, (if paractive = yes then 'активного' else 'пассивного'), parobj-type, parobj-code, pardb-name + '(' + string(pardb-num) + ')', parcur-db-name + '(' + string(parcur-db-num) + ')').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа на факт>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ на факт для объекта удаленной БД').
    end.
    assign parstatus = 'факт':U
           parflag   = true .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-wayb-plus:
case parmode:
 when '<открытие документа>':U then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя открыть документ для объекта удаленной БД.').
   end.
   assign parstatus = 'накл':U
          parflag   = no.
 end.
 when '<закрытие документа>':U then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя закрыть документ для объекта удаленной БД.').
   end.
   assign parstatus = 'разрешен':U
          parflag   = yes.
 end.
 otherwise do:
   return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
 end.
end case.
end procedure.
procedure ext-exp-perm-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ для объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ для объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-exp-fact:
 return error substitute ('Документ закрыт на &2.', pardoc-type, parstatus-current).
end procedure.
procedure ext-wroff-inq-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Запрос открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign parstatus = 'запрос':U
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-inq-plus:
case parmode:
  when '<открытие документа>':U then do:
     if varmain-for-active-remote then do:
        return error substitute ('Нельзя открыть запрос для объекта удаленной БД.').
     end.
     assign parstatus = 'запрос':U
            parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя перевести запрос в накладную для документа объекта удаленной БД').
    end.
    assign
      parstatus = 'накл':U
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-wayb-plus:
case parmode:
 when '<открытие документа>':U then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя открыть документ удаленной БД.').
   end.
   assign parstatus = 'накл':U
          parflag   = no.
 end.
 when '<закрытие документа>':U then do:
   if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
   end.
   assign parstatus = 'разрешен':U
          parflag   = yes.
 end.
 otherwise do:
   return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
 end.
end case.
end procedure.
procedure ext-wroff-perm-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-wroff-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure ext-ret-inq-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Запрос открыт.').
  end.
  when '<закрытие документа>':U then do:
     assign parstatus = 'запрос':U
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-inq-plus:
case parmode:
  when '<открытие документа>':U then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя открыть запрос объекта удаленной БД.').
     end.
     assign parstatus = 'запрос':U
            parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя перевести запрос в накладную для документа объекта удаленной БД.').
    end.
    assign
      parstatus = 'накл':U
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-wayb-plus:
case parmode:
 when '<открытие документа>':U then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя открыть документ объекта удаленной БД.').
   end.
   if parhold-gen = yes then do:
      return error substitute ('Нельзя открыть документ межфирменного перемещения.').
   end.
   assign parstatus = 'накл':U
          parflag   = no.
 end.
 when '<закрытие документа>':U then do:
   if varmain-for-active-remote then do:
     return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
   end.
   assign parstatus = 'разрешен':U
          parflag   = yes.
 end.
 otherwise do:
   return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
 end.
end case.
end procedure.
procedure ext-ret-perm-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').  end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure ext-ret-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure inv-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-wayb-plus:
case parmode:
  when '<открытие документа>':U   then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = no.
  end.
  when '<закрытие документа>':U  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'разрешен':U
           parflag   = yes.
  end.
  when '<резервирование по документу>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя сделать пересортицу для документа объекта удаленной БД.', parmode, pardoc-type, parstatus-current, parflag-current, (if paractive = yes then 'активного' else 'пассивного'), parobj-type, parobj-code, pardb-name + '(' + string(pardb-num) + ')', parcur-db-name + '(' + string(parcur-db-num) + ')').
    end.
    assign parstatus = 'разрешен':U
           parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-perm-minus:
case parmode:
  when '<открытие документа>':U   then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя открыть документ объекта удаленной БД.').
     end.
     assign parstatus = 'накл':U
            parflag   = yes.
  end.
  when '<закрытие документа>':U  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  when '<резервирование по документу>':U then do:
     if varmain-for-active-remote then do:
       return error substitute ('Нельзя делать резервирование по документу объекта удаленной БД.').
     end.
     assign parstatus = 'разрешен':U
            parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-perm-plus:
case parmode:
  when '<открытие документа>':U   then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа>':U  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  when '<резервирование по документу>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя делать пересортицу для документа объекта удаленной БД.').
    end.
    assign parstatus = 'разрешен':U
           parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure inv-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure cmp-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'факт':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure cmp-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure cp-wayb-minus:
case parmode:
  when '<открытие документа>':U   then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U  then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure cp-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure int-inc-inq-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Запрос открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'запрос':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-inc-inq-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть запрос объекта удаленной базы данных.').
    end.
    assign parstatus = 'запрос':U
           parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    return error substitute ('Нельзя переводить внутренний приходный запрос в накладную.').
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-inc-wayb-plus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Нельзя открыть внутреннюю приходную накладную.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-inc-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure int-exp-inq-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Запрос открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'запрос':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-inq-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть запрос объекта удаленной БД.').
    end.
    assign parstatus = 'запрос':U
           parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть запрос объекта удаленной БД.').
    end.
    assign
      parstatus = 'накл':U
      parflag   = no.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД').
    end.
    assign parstatus = 'накл':U
           parflag = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-wayb-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'разрешен':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-perm-plus:
case parmode:
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-exp-fact:
  return error substitute ('Документ закрыт.', pardoc-type, parstatus-current).
end procedure.
procedure int-ret-wayb-plus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Нельзя открыть внутреннюю возвратную накладную.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'разрешен':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-ret-perm-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = yes.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = ?.
  end.
    otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure int-ret-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure peresort-wayb:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    assign parstatus = 'факт':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure peresort-fact:
  return error substitute ('Документ закрыт.').
end procedure.
procedure obj-exp-wayb-minus:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД').
    end.
    assign parstatus = 'накл':U
           parflag = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure obj-exp-wayb-plus:
case parmode:
  when '<открытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя открыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'накл':U
           parflag   = no.
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
procedure obj-int-wayb:
case parmode:
  when '<открытие документа>':U then do:
    return error substitute ('Документ открыт.').
  end.
  when '<закрытие документа>':U then do:
    if varmain-for-active-remote then do:
      return error substitute ('Нельзя закрыть документ объекта удаленной БД.').
    end.
    assign parstatus = 'факт':U
           parflag   = yes.
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для документа с атрибутами тип-статус-флаг &2-&3-&4.', parmode, pardoc-type, parstatus-current, parflag-current).
  end.
end case.
end procedure.
