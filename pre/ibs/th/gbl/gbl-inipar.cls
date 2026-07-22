block-level on error undo, throw.
class ibs.th.gbl.gbl-inipar:
    define static property conPar as character no-undo
    get.
    private set.
  define static property conParKeyName as character no-undo
    initial "секция REP-SETS параметр ConPar в .ini файле"
    get.
  define static property conParFlt as character no-undo
    get.
    private set.
  define static property conParFltKeyName as character no-undo
    initial "секция REP-SETS параметр ConParFlt в .ini файле"
    get.
  define static property logDir as character no-undo
    get.
    private set.
  define static property logDirKeyName as character no-undo
    initial "секция REP-SETS параметр logDir в .ini файле"
    get.
    define static property comstr as character no-undo
    get.
    private set.
  define static property comstrKeyName as character no-undo
    initial "секция revision параметр comstr в .ini файле"
    get.
  define static property dirflrvs as character no-undo
    get.
    private set.
  define static property dirflrvsKeyName as character no-undo
    initial "секция revision параметр dirflrvs в .ini файле"
    get.
  define static property dirflpmp as character no-undo
    get.
    private set.
  define static property dirflpmpKeyName as character no-undo
    initial "секция revision параметр dirflpmp в .ini файле"
    get.
    define static property dirfrgAcc as character no-undo initial ?
    get.
    private set.
  define static property dirfrgAccKeyName as character no-undo
    initial "секция BGE параметр Dirfrg-acc в .ini файле"
    get.
    define static property oxmlDir as character no-undo // значение для переменной oxml-heap-dir
    get.
    private set.
  define static property oxmlDirKeyName as character no-undo
    initial "секция OXML параметр oxml-dir в .ini файле"
    get.
  define static property oxmlExchDir as character no-undo // значение для переменной oxml-exch-dir
    get.
    private set.
  define static property oxmlExchDirKeyName as character no-undo
    initial "секция OXML параметр oxml-exch-dir в .ini файле"
    get.
  define static property cntxt-report-num as integer no-undo initial 0  // значение для переменной oxml-exch-dir
  get():
    if  cntxt-report-num = 0
    then
       cntxt-report-num = dynamic-next-value( "next-report":U, "ubflt":U ).
    return cntxt-report-num.
  end.
  private set.
    // для формирования имени файла отчетов - обеспечивает уникальность имён временных файлов между сессиями
  method public static void Setcntxt-report-num ():
  end.
  constructor static gbl-inipar():
    ibs.th.gbl.gbl-inipar:InitPar ( ) .
  end constructor.
  method public static void InitPar ( ) :
    get-key-value section "rep-sets" key "ConPar"    value conPar .
    get-key-value section "rep-sets" key "ConParFlt" value conParFlt .
    get-key-value section "rep-sets" key "logDir"    value logDir .
    if logDir = ?
    then do :
      logDir = ".\" .
    end .
    else do :
      logDir = right-trim(logDir, "\") .
      logDir = right-trim(logDir, "/") .
      logDir = logDir + "\" .
    end.
    get-key-value section "revision" key "comstr"    value comstr .
    get-key-value section "revision" key "dirflrvs"  value dirflrvs .
    get-key-value section "revision" key "dirflpmp"  value dirflpmp .
        get-key-value section "BGE" key "dirfrg-acc"     value dirfrgAcc .
    get-key-value section "oxml" key "oxml-dir"      value oxmlDir .
    get-key-value section "oxml" key "oxml-exch-dir" value oxmlExchDir .
  end method. // end_of InitPar
  method public static character PutKeyValue (input p-section as character,
                                              input p-key     as character,
                                              input p-value   as character ) :
  define variable v-message  as character no-undo .
  define variable v-par-name as character no-undo .
    case p-section :
      when "REP-SETS" then do :
        case p-key :
          when "ConPar"    then v-par-name = conParKeyName .
          when "ConParFlt" then v-par-name = conParFltKeyName .
          when "logDir"    then v-par-name = logDirKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      when "revision" then do :
        case p-key :
          when "comstr"   then v-par-name = comstrKeyName .
          when "dirflrvs" then v-par-name = dirflrvsKeyName .
          when "dirflpmp" then v-par-name = dirflpmpKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      when "BGE" then do :
        case p-key :
          when "dirfrg-acc" then v-par-name = dirfrgAccKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      when "OXML" then do :
        case p-key :
          when "oxml-dir"      then v-par-name = oxmlDirKeyName .
          when "oxml-exch-dir" then v-par-name = oxmlExchDirKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      otherwise v-par-name = "" .
    end case .
    if v-par-name = "" then do :
      v-message = substitute("Ошибка сохранения параметра: секция &1 параметр &2 в .ini файле вне статичного контекста."
                            , p-section, p-key) .
    end .
    else do :
      put-key-value section p-section key p-key value p-value no-error.
      if error-status:num-messages > 0 then
        v-message = substitute("Ошибка сохранения параметра: &1: &2"
                              , v-par-name, error-status:get-message (error-status:num-messages)
                              ) .
      else if error-status:error then
        v-message = substitute("Ошибка сохранения параметра: &1", v-par-name) .
      else do :
        v-message = "" .
        case p-section :
          when "REP-SETS" then do :
            case p-key :
              when "ConPar"    then conPar    = p-value .
              when "ConParFlt" then conParFlt = p-value .
              when "logDir"    then logDir    = p-value .
            end case .
          end .
          when "revision" then do :
            case p-key :
              when "comstr"   then comstr   = p-value .
              when "dirflrvs" then dirflrvs = p-value .
              when "dirflpmp" then dirflpmp = p-value .
            end case .
          end .
          when "BGE" then do :
            case p-key :
              when "dirfrg-acc" then dirfrgAcc = p-value .
            end case .
          end .
          when "OXML" then do :
            case p-key :
              when "oxml-dir"      then oxmlDir     = p-value .
              when "oxml-exch-dir" then oxmlExchDir = p-value .
            end case .
          end .
        end case .
      end .
    end .
    return v-message .
  end method. // end_of PutKeyValue
  method public static character prn-lib-get-report-name ( ) :
  define variable v-report-name as character no-undo .
    v-report-name = prn-lib-get-report-name ("rpt") .
    return v-report-name .
  end method.
  method public static character prn-lib-get-report-name (input p-df-name as character) :
  define variable v-report-name as character no-undo .
    v-report-name = substitute("&1&2&3", session:temp-directory, p-df-name, cntxt-report-num ) .
    return v-report-name .
  end method.
  method public static void prn-lib-reportviewer-report-name (input p-report-name-html as character) :
     define variable v-full-path-RepView as character no-undo.
     define variable ii                  as integer no-undo .
     define variable v-report-name       as character no-undo .
     if search("exe\ReportViewer\reportviewer.exe") <> ? then
     do:
       v-full-path-RepView = search("exe\ReportViewer\reportviewer.exe").
     end.
     else
     do:
       message "Не найдена программа просмотра отчёта!" view-as alert-box error.
     end.
     do ii = 1 to NUM-ENTRIES (p-report-name-html).
       v-report-name = ENTRY (ii,p-report-name-html," ").
       if search(v-report-name) = ? then
       do:
         message "Не найден файл отчёта: " v-report-name view-as alert-box error.
         return error.
       end.
     end.
     os-command no-wait value(v-full-path-RepView + " true " + p-report-name-html).
  end method.
  method public static void prn-lib-reportviewer (input p-report-name-html as character,
  input p-param as character) :
   define variable ii                  as integer   no-undo .
   define variable jj                  as integer   no-undo .
   define variable v-report-name       as character no-undo .
   define variable v-fill-path-RepView as character no-undo.
   define variable v-param             as character no-undo .
   define variable v-GUI               as character no-undo init 'TRUE' .
   define variable v-password          as character no-undo init 'FALSE'.
   define variable v-par               as character no-undo .
   define variable v-path              as character no-undo .
   define variable v-os                as character no-undo .
   define variable v-command           as character no-undo .
   define variable v-excel             as character no-undo init 'TRUE' .
   define variable v-silent            as character no-undo init 'FALSE' .
   do ii = 1 to NUM-ENTRIES (p-report-name-html):
      v-report-name = ENTRY (ii,p-report-name-html," ").
      if search(v-report-name) = ? then
      do:
         return error "Не найден файл отчёта: " + v-report-name.
      end.
   end.
   do jj = 1 to NUM-ENTRIES (p-param,chr(4)):
      v-par = entry (jj,p-param,chr(4)) .
      if num-entries(v-par,':') <> 2 then return error 'Не правильно переданы параметры'.
      case entry(1,v-par,':':U):
         when 'GUI' then
            v-GUI = entry(2,v-par,':').
         when 'Password' then
            v-password = entry(2,v-par,':').
         when 'OS' then
            v-os = entry(2,v-par,':').
         when 'EXCEL' then
            v-excel = entry(2,v-par,':').
      end case.
   end.
   v-path = "exe\ReportViewer\reportviewer.exe" .
   if search(v-path) <> ? then
   do:
      v-fill-path-RepView = search(v-path).
   end.
   else
   do:
      return error "Не найдена программа просмотра отчёта!" .
   end.
   v-command = substitute('&1 &2 &3 &4 &5 ',v-fill-path-RepView,v-GUI,v-password,v-excel,p-report-name-html).
   if v-GUI = 'False'
   then
      os-command SILENT value(v-command).
   else
      os-command no-wait value(v-command).
end method.
end class.
