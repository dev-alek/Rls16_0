/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Статический класс со значениями параметров из ini-файла

Автор: Молотков Сергей
Дата создания: 14/02/18
Author: Molotkov Sergey
Creation date: 14/02/18

*/
/* 03/VIII-2018 Временно добавлены переменные для печати, чтобы исключить использование prn-lib.i.
                Из ini-файла не берутся.
                Когда их здесь наберётся достаточно много - подумаем, куда их вынести.
*/   
block-level on error undo, throw.
&scoped-define txt-sec секция
&scoped-define txt-key параметр
&scoped-define txt-ini в .ini файле
&scoped-define sec-rep-sets REP-SETS
&scoped-define sec-revision revision
&scoped-define sec-bge      BGE
&scoped-define sec-oxml     OXML

&global-define delim-par chr(4)

class ibs.th.gbl.gbl-inipar: 
/*  { cmp/str-glbl.i class }*/
  /* REP-SETS */
  &scoped-define section-name {&sec-rep-sets}
  define static property conPar as character no-undo
    get.
    private set.
  define static property conParKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} ConPar {&txt-ini}"
    get.
    
  define static property conParFlt as character no-undo
    get.
    private set.
  define static property conParFltKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} ConParFlt {&txt-ini}"
    get.
    
  define static property logDir as character no-undo
    get.
    private set.
  define static property logDirKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} logDir {&txt-ini}"
    get.
  &undefine section-name
    
  /* revision */
  &scoped-define section-name {&sec-revision}
  define static property comstr as character no-undo
    get.
    private set.
  define static property comstrKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} comstr {&txt-ini}"
    get.

  define static property dirflrvs as character no-undo
    get.
    private set.
  define static property dirflrvsKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} dirflrvs {&txt-ini}"
    get.

  define static property dirflpmp as character no-undo
    get.
    private set.
  define static property dirflpmpKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} dirflpmp {&txt-ini}"
    get.
  &undefine section-name

  /* BGE */
  &scoped-define section-name {&sec-bge}
  define static property dirfrgAcc as character no-undo initial ?
    get.
    private set.
  define static property dirfrgAccKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} Dirfrg-acc {&txt-ini}"
    get.
  &undefine section-name

  /* OXML */
  &scoped-define section-name {&sec-oxml}
  define static property oxmlDir as character no-undo // значение для переменной oxml-heap-dir
    get.
    private set.
  define static property oxmlDirKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} oxml-dir {&txt-ini}"
    get.

  define static property oxmlExchDir as character no-undo // значение для переменной oxml-exch-dir
    get.
    private set.
  define static property oxmlExchDirKeyName as character no-undo
    initial "{&txt-sec} {&section-name} {&txt-key} oxml-exch-dir {&txt-ini}"
    get.
  &undefine section-name
/* 29/VIII-2018  параметры настройки ЭЦП перенесены из ini-файла в настройки внешней системы
  define static property certSign as logical no-undo
    get.
    private set.
  define static property certSignKeyName as character no-undo
    initial "{&txt-sec} OXML {&txt-key} cert-sign {&txt-ini}"
    get.

  define static property certSignSubject as character no-undo
    get.
    private set.
  define static property certSignSubjectKeyName as character no-undo
    initial "{&txt-sec} OXML {&txt-key} cert-sign-subject {&txt-ini}"
    get.

  define static property certSignIssuer as character no-undo
    get.
    private set.
  define static property certSignIssuerKeyName as character no-undo
    initial "{&txt-sec} OXML {&txt-key} cert-sign-issuer {&txt-ini}"
    get.

  define static property certFileExt as character no-undo // расширение для файлов с цифровой подписью
    get.
    private set.
  define static property certFileExtKeyName as character no-undo
    initial "{&txt-sec} OXML {&txt-key} cert-file-ext {&txt-ini}"
    get.
*/

  /* ----- переменные для печати ----- */
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
  /* ----- end_of переменные для печати ----- */   
    
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
    
    &scoped-define section-name "{&sec-bge}"
    get-key-value section {&section-name} key "dirfrg-acc"     value dirfrgAcc .
    &undefine section-name
    
    get-key-value section "oxml" key "oxml-dir"      value oxmlDir .
    get-key-value section "oxml" key "oxml-exch-dir" value oxmlExchDir .
/* 29/VIII-2018  параметры настройки ЭЦП перенесены из ini-файла в настройки внешней системы
    define variable v-cert-sign as character no-undo .
    get-key-value section "oxml" key "cert-sign"         value v-cert-sign .
    certSign = logical (v-cert-sign) no-error .
    get-key-value section "oxml" key "cert-sign-subject" value certSignSubject .
    get-key-value section "oxml" key "cert-sign-issuer"  value certSignIssuer .
    get-key-value section "oxml" key "cert-file-ext"     value certFileExt .
    if certFileExt = ?
    then do :
      certFileExt = "p7s" .
    end .
*/    
  end method. // end_of InitPar

  method public static character PutKeyValue (input p-section as character,
                                              input p-key     as character,
                                              input p-value   as character ) :
  define variable v-message  as character no-undo .
  define variable v-par-name as character no-undo .
  
    /* найти параметр среди обслуживаемых */
    case p-section :
      when "{&sec-rep-sets}" then do :
        case p-key :
          when "ConPar"    then v-par-name = conParKeyName .
          when "ConParFlt" then v-par-name = conParFltKeyName .
          when "logDir"    then v-par-name = logDirKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      when "{&sec-revision}" then do :
        case p-key :
          when "comstr"   then v-par-name = comstrKeyName .
          when "dirflrvs" then v-par-name = dirflrvsKeyName .
          when "dirflpmp" then v-par-name = dirflpmpKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      when "{&sec-bge}" then do :
        case p-key :
          when "dirfrg-acc" then v-par-name = dirfrgAccKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      when "{&sec-oxml}" then do :
        case p-key :
          when "oxml-dir"      then v-par-name = oxmlDirKeyName .
          when "oxml-exch-dir" then v-par-name = oxmlExchDirKeyName .
          otherwise v-par-name = "" .
        end case .
      end .
      otherwise v-par-name = "" .
    end case .
    
    if v-par-name = "" then do :
      v-message = substitute("Ошибка сохранения параметра: {&txt-sec} &1 {&txt-key} &2 {&txt-ini} вне статичного контекста."
                            , p-section, p-key) .
    end .
    else do :
      /* сохранить значение параметра и обновить поле в классе */
      /* @FUTU  добавить проверку, что новое значение отличается от текущего */
      put-key-value section p-section key p-key value p-value no-error.
      if error-status:num-messages > 0 then
        v-message = substitute("Ошибка сохранения параметра: &1: &2"
                              , v-par-name, error-status:get-message (error-status:num-messages)
                              ) .
      else if error-status:error then
        v-message = substitute("Ошибка сохранения параметра: &1", v-par-name) .
      else do :
        v-message = "" .
        /* ещё раз найти параметр среди обслуживаемых и обновить его поле в классе */
        case p-section :
          when "{&sec-rep-sets}" then do :
            case p-key :
              when "ConPar"    then conPar    = p-value .
              when "ConParFlt" then conParFlt = p-value .
              when "logDir"    then logDir    = p-value .
            end case .
          end .
          when "{&sec-revision}" then do :
            case p-key :
              when "comstr"   then comstr   = p-value .
              when "dirflrvs" then dirflrvs = p-value .
              when "dirflpmp" then dirflpmp = p-value .
            end case .
          end .
          when "{&sec-bge}" then do :
            case p-key :
              when "dirfrg-acc" then dirfrgAcc = p-value .
            end case .
          end .
          when "{&sec-oxml}" then do :
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


  /* ----- переменные для печати ----- */
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
  
    /* Получение полного пути к исполняемому файлу просмотровщика отчётов RV.exe */
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
   
     
/*                                                                        */
/*      GET-KEY-VALUE section "REP-SETS" key "rep_excel" value v-excel .  */
/*      if v-excel eq ?                                                   */
/*         then                                                           */
/*         v-excel = "".                                                  */
/*      else                                                              */
/*      do:                                                               */
/*         case v-excel:                                                  */
/*            when 'TRUE' then                                            */
/*               v-excel = 'TRUE' .                                       */
/*            when 'YES'  then                                            */
/*               v-excel = 'TRUE' .                                       */
/*            otherwise                                                   */
/*            v-excel = 'FALSE' .                                         */
/*         end case .                                                     */
/*      end.                                                              */
/*      GET-KEY-VALUE section "REP-SETS" key "Password" value v-password .*/
/*      if v-password = ? then v-password = "FALSE" .                     */
/*      else                                                              */
/*      do:                                                               */
/*         case v-password:                                               */
/*            when 'TRUE' then                                            */
/*               v-password = 'TRUE' .                                    */
/*            when 'YES'  then                                            */
/*               v-password = 'TRUE' .                                    */
/*            otherwise                                                   */
/*            v-password = 'FALSE' .                                      */
/*         end case .                                                     */
/*      end.                                                              */

   do jj = 1 to NUM-ENTRIES (p-param,{&delim-par}):
      v-par = entry (jj,p-param,{&delim-par}) .
      if num-entries(v-par,':') <> 2 then return error 'Не правильно переданы параметры'.
      case entry(1,v-par,':':U):
         when 'GUI' then 
            v-GUI = entry(2,v-par,':'). /*открывать репорт или нет*/
         when 'Password' then 
            v-password = entry(2,v-par,':'). /*требовать пароль*/
         when 'OS' then 
            v-os = entry(2,v-par,':'). /*версия*/
         when 'EXCEL' then 
            v-excel = entry(2,v-par,':'). /*при нажатии печать печатает через excel*/
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
  /* ----- end_of переменные для печати ----- */   
  
end class.