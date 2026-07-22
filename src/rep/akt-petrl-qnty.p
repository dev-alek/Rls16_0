/*

$Revision: 1b298784e91d, 1055, rls $
$Author: ASMorozov $
$Date: Fri Oct 06 18:33:04 2017 +0300 $
$Workfile: akt-petrl-qnty.p $
$Archive: rep/akt-petrl-qnty.p $

Акт приема нефтепродуктов по количеству

Автор: Морзов Александр Сергеевич
Дата создания: 08/07/14
Author: Alexandr Morozov
Creation date: 08/07/14

*/

using ibs.th.str.*.
block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 1b298784e91d, 1055, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Fri Oct 06 18:33:04 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: akt-petrl-qnty.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/akt-petrl-qnty.p $":U .
define variable vss-description as character no-undo init "Акт приема нефтепродуктов по количеству".
{ cmp/vssrevis.i }

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.

define stream out-stream.

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ rep/w-rep.i    }
{ rep/fmtcli.i   }
{ rep/torgconf.i }
{ str/getctxtp.i def }
{ gbl/paramls.i  }
{ ref/gds-attr.i }

define variable g#report-num    as integer      no-undo .
define variable g#quest-print   as logical      no-undo .
define variable g#log           as logical      no-undo .
{ rep/aktpq-xl.i  }

define variable is-petrolium as logical no-undo.
define variable is-pieces as logical no-undo.
define variable v-attr-value as character no-undo .
define variable v-attr-type  as character no-undo .
define variable v-nakl   as character no-undo .
define variable v-date   as character no-undo .
define variable v-t-start   as character no-undo .
define variable v-t-end   as character no-undo .
define variable ii        as integer   no-undo init 0.
define variable v-doc-code         like ub.trn-doc.doc-code   no-undo .
define variable v-gds-code         like ub.goods.gds-code     no-undo .
define variable v-autoent-obj-type as   character             no-undo .
define variable v-autoent-obj-code as   character             no-undo .
define variable v-item-pour        as   character             no-undo .
define variable v-time-income      as   character             no-undo .
define variable v-car-num          as   character             no-undo .
define variable v-time-start-min   like ub.rvs-line.real-time no-undo .
define variable v-time-end-max     like ub.rvs-line.real-time no-undo .
define variable v-date-start-min   like ub.rvs-line.real-date no-undo .
define variable v-date-end-max     like ub.rvs-line.real-date no-undo .
define variable v-fio              as   character             no-undo .
define variable v-ptbotype         as   character             no-undo .
define variable v-ptbocode         as   character             no-undo .
define variable v-gds-attr-value   as   character             no-undo .
define variable v-gds-attr-type    as   character             no-undo .
define variable v-type             as   character             no-undo .
define variable v-trndocattr       as   character             no-undo .
define variable v-list-gds-name    as   character             no-undo .
define variable v-factpl           as   character             no-undo .
define variable v-factpltype       as   character             no-undo .
define variable v-revision         as   decimal               no-undo .
define variable v-beforemeasqnty   as   decimal               no-undo .
define variable v-beforestateweight as  decimal               no-undo .
define variable v-acc_qnty         as decimal                 no-undo .
define variable v-acc_qnty_kg      as decimal                 no-undo .
define variable v-natural_loss     as decimal                 no-undo .
define variable v-diff_mass        as decimal                 no-undo .
define variable v-admittance_error_mass as decimal            no-undo .
define variable v-InfoSectionsTotal as class InfoSectionsTotal no-undo .
def var iNum as int no-undo.
def var v-sortpetrl as character no-undo.
        

&global-define month-list-for-date 'января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря':U

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer buf_doc-attr      for ub.doc-attr.
    define buffer buf_goods         for ub.goods.
    define buffer buf_rvs-line      for ub.rvs-line.
    define buffer buf_rvs-doc       for ub.rvs-doc.
    define buffer buf_clients       for ub.clients.
    define buffer buf_firm          for ub.firm.
    
do

:
    { gbl/working.i }

    { str/getctxtp.i get p-mainmenu-handle }

    find first buf_trn-doc no-lock
         where recid( buf_trn-doc ) = rec_id.


    v-InfoSectionsTotal = new InfoSectionsTotal().
    run cr-begin-general.
    _foreachgds:
    for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code :  

    { str/is-petrl.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      is-petrolium
      is-pieces
      no-error
      }
      if error-status :error
      then do:
        return error return-value .
      end.
      if is-petrolium then do
      :

        find first buf_goods where buf_goods.artic     = buf_doc-line.artic
                               and buf_goods.prod-code = buf_doc-line.prod-code
                               and buf_goods.prod-type = buf_doc-line.prod-type no-lock no-error.
        assign
            v-doc-code = buf_doc-line.doc-code
            v-gds-code = buf_goods.gds-code
        .
        v-InfoSectionsTotal:Initialization(v-doc-code, v-gds-code).
        v-InfoSectionsTotal:GetDBAllAttr().

        find first clients where clients.obj-code = buf_trn-doc.boss and
                                 clients.obj-type = {&prs} no-lock no-error.
        find first person where person.psn-code = buf_trn-doc.boss no-lock no-error.
        
        
        run gds-attr-value in this-procedure
          (  input buf_goods.gds-code
          ,  input {&attr-fuel-type}
          , output v-gds-attr-value
          , output v-gds-attr-type
          ) no-error .
        
        case v-gds-attr-value :
          when "petrol" then do:
            assign
              v-list-gds-name = v-list-gds-name + "," + buf_goods.gds-name
              v-sortpetrl = "бензин".
          end.
          when "diesel-sum" or when "diesel-wint" then do:
            assign
              v-list-gds-name = v-list-gds-name + "," + buf_goods.gds-name
              v-sortpetrl = buf_goods.gds-name.
          end.
          otherwise next _foreachgds.
        end case.


        if v-date-start-min = ? or datetime (v-date-start-min, v-time-start-min) > datetime (v-InfoSectionsTotal:StartRealDate, v-InfoSectionsTotal:StartRealTime) then do:
          assign
            v-date-start-min = v-InfoSectionsTotal:StartRealDate.
            v-time-start-min = v-InfoSectionsTotal:StartRealTime
            .
        end.
        
        if v-date-end-max = ? or datetime (v-date-end-max, v-time-end-max) < datetime (v-InfoSectionsTotal:EndRealDate, v-InfoSectionsTotal:EndRealTime) then do:
          assign
            v-time-end-max = v-InfoSectionsTotal:EndRealTime
            v-date-end-max = v-InfoSectionsTotal:EndRealDate
          .
        end.
        
        do iNum = 1 to v-InfoSectionsTotal:SectionNum:

          ii = ii + 1.
          if ii > 4 then do:
            run cr-end-general.
            run cr-begin-general.
            ii = 1.
            if iNum >= v-InfoSectionsTotal:SectionNum
              then v-list-gds-name = "".
          end.

          run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-gdsname} + string (ii)
              , input buf_goods.gds-name
          ).
  
          run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-sectionnum} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):SectionName
          ).
  
          run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-vol} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):CarVol
          ).        
  
         run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-temp} + string (ii)
              , input buf_doc-line.temperature
          ). 
         run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-petrlvol} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):FactQnty
          ). 
         run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-dens} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):DocDensity * 1000
          ).         
         run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-weight} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty
          ).    
         run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-mark} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):ABTarir
          ).
  
          
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-before-doc} and buf_rvs-doc.out-code = buf_trn-doc.doc-code no-error.
          
          def var v-loc1 as char no-undo.
          def var v-state-level-total as decimal no-undo.
          def var v-state-measure-qnty as decimal no-undo.
          def var v-state-measure-cli-qnty as decimal no-undo.
          def var v-state-temperature as decimal no-undo.
          def var v-availrvsline as logical no-undo.          

          assign
            v-state-level-total = 0
            v-state-measure-qnty = 0
            v-state-measure-cli-qnty = 0
            v-state-temperature = 0
            v-availrvsline = false
            v-loc1 = ""
          .

          if available (buf_rvs-doc) then do:
            for each buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and buf_rvs-line.gds-code = buf_goods.gds-code no-lock:
            
              find first ub.place where ub.place.pl-code = buf_rvs-line.pl-code no-lock no-error.
              if available (ub.place)
              then do:
                v-loc1 = if v-loc1 <> "" then v-loc1 + "," + ub.place.loc1 else ub.place.loc1.
              end.
              v-availrvsline = true.
              assign
                v-state-level-total = v-state-level-total + buf_rvs-line.state-level-total 
                v-state-measure-qnty = v-state-measure-qnty + buf_rvs-line.state-measure-qnty
                v-state-measure-cli-qnty = v-state-measure-cli-qnty + buf_rvs-line.state-measure-cli-qnty
                v-state-temperature = buf_rvs-line.state-temperature
              .
              
            end.
          end.
          
          
          if v-availrvsline then do:          
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-beforelevtotal} + string (ii)
              , input v-state-level-total
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-beforemeasqnty} + string (ii)
              , input v-state-measure-qnty
              ).
            assign
              v-beforemeasqnty = v-state-measure-qnty.
              
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-beforestatetemp} + string (ii)
              , input v-state-temperature
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-beforestatedens} + string (ii)
              , input v-state-measure-cli-qnty / v-state-measure-qnty * 1000
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-beforestateweight} + string (ii)
              , input v-state-measure-cli-qnty
              ).
            assign
              v-beforestateweight = v-state-measure-cli-qnty.
          end.

          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = {&rvs-after-doc} and buf_rvs-doc.out-code = buf_trn-doc.doc-code no-error.
          assign
            v-state-level-total = 0
            v-state-measure-qnty = 0
            v-state-measure-cli-qnty = 0
            v-state-temperature = 0
            v-availrvsline = false
            v-loc1 = ""
          .
          if available (buf_rvs-doc) then do:
            for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code and buf_rvs-line.gds-code = buf_goods.gds-code :
              find first ub.place where ub.place.pl-code = buf_rvs-line.pl-code no-lock no-error.
              if available (ub.place)
              then do:
                v-loc1 = if v-loc1 <> "" then v-loc1 + "," + ub.place.loc1 else ub.place.loc1.
              end.
              v-availrvsline = true.
              assign
                v-state-level-total = buf_rvs-line.state-level-total + v-state-level-total
                v-state-measure-qnty = v-state-measure-qnty + buf_rvs-line.state-measure-qnty
                v-state-measure-cli-qnty = v-state-measure-cli-qnty + buf_rvs-line.state-measure-cli-qnty
                v-state-temperature = buf_rvs-line.state-temperature
              .
            end.
          end.
          
          if v-availrvsline then do:
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-afterlevtotal} + string (ii)
              , input v-state-level-total
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-aftermeasqnty} + string (ii)
              , input  v-state-measure-qnty
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-afterstatetemp} + string (ii)
              , input v-state-temperature
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-afterstatedens} + string (ii)
              , input v-state-measure-cli-qnty / v-state-measure-qnty * 1000
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-afterstateweight} + string (ii)
              , input v-state-measure-cli-qnty
              ).
            assign  
              v-acc_qnty = v-state-measure-qnty - v-beforemeasqnty
              v-acc_qnty_kg = v-state-measure-cli-qnty - v-beforestateweight
            .
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-acc_qnty} + string (ii)
              , input string (v-acc_qnty)
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-acc_qnty_kg} + string (ii)
              , input string (v-acc_qnty_kg)
              ).
          end.

          run aktpq-xl-write-cell-data in this-procedure (
                input {&aktpq-xl-sortpetrl} + string (ii)
              , input v-sortpetrl
          ).
          

          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-mouth} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):Mouth
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-factvol} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankVol
            ).

          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-denspomi} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankDensityPomi * 1000
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-volpomi} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankVolPomi
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-factweight} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankWeight
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-measur_error} + string (ii)
            , input "0.65"
            ).
          assign
            v-admittance_error_mass = 0.0065 * v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankWeight no-error.
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-admittance_error_mass} + string (ii)
            , input string (v-admittance_error_mass)
            ).
          assign
            v-revision = decimal (entry (2, v-factpl, ";")) no-error.  
          if (entry (2, v-factpl, ";")) begins "revision=" 
          then do:
            assign
              v-diff_mass = v-acc_qnty_kg - v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty no-error.
          end.
          else do:
            assign
              v-diff_mass = v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankWeight - v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty no-error.
          end.
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-diff_mass} + string (ii)
            , input string (v-diff_mass)
            ).
          
          if (buf_trn-doc.fact-date = ? and 3 < month (today) and month (today) < 10)
              or (buf_trn-doc.fact-date <> ? and 3 <  month (buf_trn-doc.fact-date) and  month (buf_trn-doc.fact-date) < 10 )
          then do:
            case v-gds-attr-value:
              when "petrol" then do:
                v-natural_loss = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty * 0.0211 / 100.
              end.
              when "diesel-sum" then do:
                v-natural_loss = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty * 0.0006 / 100.
              end.
              when "diesel-wint" then do:
                v-natural_loss = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty * 0.0021 / 100.
              end.
            end case.
          end.
          else do:
            case v-gds-attr-value:
              when "petrol" then do:
                v-natural_loss = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty * 0.0134 / 100.
              end.
              when "diesel-sum" then do:
                v-natural_loss = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty * 0.0003 / 100.
              end.
              when "diesel-wint" then do:
                v-natural_loss = v-InfoSectionsTotal:GetInfoSectionProp(iNum):CliQnty * 0.0012 / 100.
              end.
            end case.
          end.
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-natural_loss} + string (ii)
            , input string (v-natural_loss)
            ).
          if v-diff_mass > 0 then do:
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-surpluse} + string (ii)
              , input if v-diff_mass - v-admittance_error_mass > 0 then v-diff_mass - v-admittance_error_mass else 0
              ).
          end.
          else do:
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-surpluse} + string (ii)
              , input if v-diff_mass + v-admittance_error_mass + v-natural_loss < 0 then v-diff_mass + v-admittance_error_mass + v-natural_loss else 0
              ).
          end.
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-accept_accod_kg} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):FactKgQnty
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-accept_accod_l} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):FactQnty
            ).

          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-coor} + string (ii)
            , input v-loc1
            ).
          
          
          if num-entries (v-InfoSectionsTotal:GetInfoSectionProp(iNum):Diameter, "/") = 2
          then do:
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-la} + string (ii)
              , input entry (1,v-InfoSectionsTotal:GetInfoSectionProp(iNum):Diameter, "/")
              ).
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-lb} + string (ii)
              , input entry (2,v-InfoSectionsTotal:GetInfoSectionProp(iNum):Diameter, "/")
              ).
          end.
          else do:
            run aktpq-xl-write-cell-data in this-procedure (
              input {&aktpq-xl-diametr} + string (ii)
              , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):Diameter
              ).
          end.
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-temp1} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankTemp
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-tempexp} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):DensTemp
            ).
          run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-densexp} + string (ii)
            , input v-InfoSectionsTotal:GetInfoSectionProp(iNum):TankDensity * 1000
            ).

        
        end.
        
      end.    /*      if is-petrolium        */
    end.    /*        for each buf_doc-line     */
    
    run cr-end-general.

    { gbl/stopwork.i }
    


end.



PROCEDURE loc-doc-get-attr :

  &scop loc-find-doc-attr ~
  find first buf_doc-attr ~
    where buf_doc-attr.doc-code  = v-doc-code ~
      and buf_doc-attr.attr-code = "~{&attr-name~}" ~
    no-error.
  
  &scop loc-get-doc-attr ~
    if available buf_doc-attr then do: ~
      assign ~
        v-~{&attr-name~} = buf_doc-attr.attr-value ~
      . ~
    end.

  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :

      &scop attr-name {&bef-trdcattr-car-num}
      {&loc-find-doc-attr}
      {&loc-get-doc-attr}
  
      &scop attr-name {&bef-trdcattr-autoent}
      {&loc-find-doc-attr}
      &scop attr-name autoent-obj-type
      assign
        v-{&attr-name} = entry (1, buf_doc-attr.attr-value, ";")
      no-error.
  
      &scop attr-name {&bef-trdcattr-autoent}
      {&loc-find-doc-attr}
      &scop attr-name autoent-obj-code
      assign
        v-{&attr-name} = entry (2, buf_doc-attr.attr-value, ";")
      no-error.
  
      &scop attr-name {&bef-trdcattr-ptb-item-pour}
      {&loc-find-doc-attr}
      &scop attr-name item-pour
      {&loc-get-doc-attr}
  
      &scop attr-name {&bef-trdcattr-fio-driver}
      {&loc-find-doc-attr}
      &scop attr-name fio
      {&loc-get-doc-attr}
  
      &scop attr-name {&bef-trdcattr-ptbobj}
      {&loc-find-doc-attr}
      &scop attr-name ptbotype
      assign
        v-{&attr-name} = entry (1, buf_doc-attr.attr-value, ";")
      no-error.
  
      &scop attr-name {&bef-trdcattr-ptbobj}
      {&loc-find-doc-attr}
      &scop attr-name ptbocode
      assign
        v-{&attr-name} = entry (2, buf_doc-attr.attr-value, ";")
      no-error.
  
      &scop attr-name {&bef-trdcattr-time-income}
      {&loc-find-doc-attr}
      {&loc-get-doc-attr}

  end.
END PROCEDURE.

procedure cr-begin-general:
  
    run get-report-num in p-mainmenu-handle (
        output g#report-num
    ).

    run get-quest-print in p-mainmenu-handle (
        output g#quest-print
    ).


    { str/tdat-val.i buf_trn-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
    if v-attr-value > "" then do :
      assign v-nakl = v-attr-value .
    end .
    else do :
      assign v-nakl = buf_trn-doc.doc-code .
    end.

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
    run aktpq-xl-init in this-procedure .
    put stream out-stream unformatted
        {&new-line}
      + "Печатная форма предназначена только для вывода в Microsoft Excel."
      + {&new-line}
    .
    output stream out-stream close.
            
    assign
      v-doc-code = buf_trn-doc.doc-code.
    .
    
    run loc-doc-get-attr in this-procedure no-error .
    
    find first buf_clients where buf_clients.obj-code = buf_trn-doc.obj-code and buf_clients.obj-type = buf_trn-doc.obj-type no-error.
    if available buf_clients then do:
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-objname}
          , input buf_clients.obj-name
      ).
      find first ub.clients where ub.clients.obj-code = buf_clients.host-code and ub.clients.obj-type = {&cmp} no-error.
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-firmname}
          , input clients.obj-name
      ).
    end.

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-object}
        , input buf_trn-doc.obj-code
    ).
    
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-factday}
        , input day (buf_trn-doc.fact-date)
    ).

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-factmonth}
        , input entry( month( buf_trn-doc.fact-date ) , {&month-list-for-date} ) 
    ).        

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-factyear}
        , input year (buf_trn-doc.fact-date)
    ).
    
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-doc-code}
        , input v-nakl
    ).


    find first buf_clients where buf_clients.obj-code = buf_trn-doc.wrkr and buf_clients.obj-type = {&prs} no-error.
    if available buf_clients then do:
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-oper}
          , input buf_clients.obj-name
      ).
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-oper1}
          , input buf_clients.obj-name
      ).
    end.
    
    find first buf_clients where buf_clients.obj-code = buf_trn-doc.boss and buf_clients.obj-type = {&prs} no-error.
    if available buf_clients then do:
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-chiefoper}
          , input buf_clients.obj-name
      ).
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-chiefoper1}
          , input buf_clients.obj-name
      ).
    end.

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-dr_name}
        , input v-fio
    ).
    
    find first buf_clients where buf_clients.obj-code = integer (v-autoent-obj-code) and buf_clients.obj-type = v-autoent-obj-type no-error.
    if available buf_clients then do:
      find first buf_firm where buf_firm.firm-code = buf_clients.obj-code no-error.
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-autoentname}
          , input buf_clients.obj-name
      ).
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-autoentinfo}
          , input buf_clients.obj-name + "," + buf_firm.addres1 + " " + buf_firm.addres2
      ).
    end.

    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-ndov}
      v-trndocattr
      v-type
    }  
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-ndov}
        , input v-trndocattr
    ).  

    /* доверенность номер */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-ndov}
      v-trndocattr
      v-type
    }  
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-ndov}
        , input v-trndocattr
    ). 
    v-trndocattr = "".
    
    /* доверенность дата */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-ddov}
      v-trndocattr
      v-type
    } 
    if v-trndocattr <> "" then do:
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-ddovday}
          , input day (date (v-trndocattr))
      ).
  
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-ddovmonth}
          , input entry( month( date(v-trndocattr) ) , {&month-list-for-date} ) 
      ).        
  
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-ddovyear}
          , input year (date(v-trndocattr))
      ).
    end.
    v-trndocattr = "".

    find first buf_clients where buf_clients.obj-code = integer (v-ptbocode) and buf_clients.obj-type = v-ptbotype no-error.
    if available buf_clients then do:
      find first buf_firm where buf_firm.firm-code = buf_clients.obj-code no-error.
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-ptbname}
          , input buf_clients.obj-name
      ).
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-ptbinfo}
          , input buf_clients.obj-name + "," + buf_firm.addres1 + " " + buf_firm.addres2
      ).
    end.

    find first buf_clients where buf_clients.obj-code = buf_trn-doc.cli-code and buf_clients.obj-type = buf_trn-doc.cli-type no-error.
    if available buf_clients then do:
      find first buf_firm where buf_firm.firm-code = buf_clients.obj-code no-error.
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-contractorinfo}
          , input buf_clients.obj-name + "," + buf_firm.addres1 + " " + buf_firm.addres2
      ).
    end.

    /* техническое состояние автоцистерны */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-condition}
      v-trndocattr
      v-type
    } 
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-condition}
        , input v-trndocattr
    ).
    v-trndocattr = "".
    
    /* пломбы и их состояние */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-seals-condition}
      v-trndocattr
      v-type
    } 
    v-trndocattr = replace (v-trndocattr, {&delim-par}, ",").
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-sealscondition}
        , input v-trndocattr
    ).
    v-trndocattr = "".
    
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-carnum}
        , input v-car-num
    ).

    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-incomehour}
        , input substring (v-time-income,1,2)
    ).
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-incomemin}
        , input substring (v-time-income,4,2)
    ).
    
    
    /* номер накладной поставщика */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-nids}
      v-trndocattr
      v-type
    } 
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-trnnum}
        , input v-trndocattr
    ).
    v-trndocattr = "".
    
    /* дата накладной поставщика */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-dids}
      v-trndocattr
      v-type
    } 
    if v-trndocattr <> "" then do:
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-trnday}
          , input day (date (v-trndocattr))
      ).
  
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-trnmonth}
          , input entry( month( date(v-trndocattr) ) , {&month-list-for-date} ) 
      ).        
  
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-trnyear}
          , input year (date(v-trndocattr))
      ).
    end.
    v-trndocattr = "".
    
    
    /* номер счет фактуры */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-nsf}
      v-trndocattr
      v-type
    } 
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-invoicenum}
        , input v-trndocattr
    ).
    v-trndocattr = "".
    
    /* дата счет фактуры */
    { str/tdat-val.i
      buf_trn-doc.doc-code
      {&trdcattr-dsf}
      v-trndocattr
      v-type
    } 
    if v-trndocattr <> "" then do:
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-invoiceday}
          , input day (date (v-trndocattr))
      ).
  
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-invoicemonth}
          , input entry( month( date(v-trndocattr) ) , {&month-list-for-date} ) 
      ).        
  
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-invoiceyear}
          , input year (date(v-trndocattr))
      ).
    end.
    v-trndocattr = "".

    { gbl/conf-rd.i "'stfactpl'" "''" "''" 0 "''" "''" "''" no v-factpl v-factpltype no-error }

  
  
end.

procedure cr-end-general:
  
    run aktpq-xl-write-cell-data in this-procedure (
          input {&aktpq-xl-listgdsname}
        , input trim (v-list-gds-name, ",")
    ).

    if v-time-start-min <> 0 and v-time-start-min <> ? then do:
      assign
        v-time-start-min = v-time-start-min / 60 
      .
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-acceptbeginmin}
          , input v-time-start-min mod 60
      ).
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-acceptbeginhour}
          , input (v-time-start-min - v-time-start-min mod 60) / 60
      ).
    end.
    
    if v-time-end-max <> 0 and v-time-end-max <> ? then do:
      assign
        v-time-end-max = v-time-end-max / 60 
      .
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-acceptendmin}
          , input v-time-end-max mod 60
      ).
      run aktpq-xl-write-cell-data in this-procedure (
            input {&aktpq-xl-acceptendhour}
          , input (v-time-end-max - v-time-end-max mod 60) / 60
      ).
    end.
    
    run aktpq-xl-close in this-procedure .
    { rep/q-print.i 4 }  
  
end.
