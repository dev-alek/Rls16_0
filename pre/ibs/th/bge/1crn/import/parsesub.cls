using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
using ibs.th.gbl.env.prmtrs.section from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.parsesub:
  define public event ReceivedSubject signature void (input Subject as class ibs.th.bge.1crn.subjects.isubject, input EventHndlrImpSub as class ibs.th.bge.1crn.import.iimpsubject).
  define variable countrySubjectObj                        as class country                     no-undo.
  define variable impcountryEventHndlrObj                  as class impcountry                  no-undo.
  define variable cliGrpSubjectObj                         as class cli-grps                    no-undo.
  define variable impCliGrpEventHndlrObj                   as class impcli-grps                 no-undo.
  define variable businessUnitsSubjectObj                  as class business-units              no-undo.
  define variable impbusinessUnitsEventHndlrObj            as class impbusiness-units           no-undo.
  define variable clientsSubjectObj                        as class clients                     no-undo.
  define variable clients_carriersSubjectObj               as class clients_carriers            no-undo.
  define variable clients_suppliersSubjectObj              as class clients_suppliers           no-undo.
  define variable impClientsEventHndlrObj                  as class impclients                  no-undo.
  define variable clients_carriersListSubjectObj           as class subjects                    no-undo.
  define variable clients_suppliersListSubjectObj          as class subjects                    no-undo.
  define variable contractsSubjectObj                      as class contracts                   no-undo.
  define variable impContractsEventHndlrObj                as class impcontracts                no-undo.
  define variable currencySubjectObj                       as class currency                    no-undo.
  define variable impCurrencyEventHndlrObj                 as class impcurrency                 no-undo.
  define variable firmsSubjectObj                          as class firms                       no-undo.
  define variable impFirmsEventHndlrObj                    as class impfirms                    no-undo.
  define variable goodGrpsSubjectObj                       as class good-grps                   no-undo.
  define variable impGoodGrpsEventHndlrObj                 as class impgood-grps                no-undo.
  define variable paymentTypeGroupSubjectObj               as class payment-type-group          no-undo.
  define variable impPaymentTypeGroupEventHndlrObj         as class imppayment-type-group       no-undo.
  define variable paymentTypeSubjectObj                    as class payment-type                no-undo.
  define variable impPaymentTypeEventHndlrObj              as class imppayment-type             no-undo.
  define variable shopsSubjectObj                          as class shops                       no-undo.
  define variable impShopsEventHndlrObj                    as class impshops                    no-undo.
  define variable unitsSubjectObj                          as class units                       no-undo.
  define variable impUnitsEventHndlrObj                    as class impunits                    no-undo.
  define variable goodSubjectObj                           as class goods                       no-undo.
  define variable barcodesSubjectsObj                      as class subjects                    no-undo.
  define variable good_barcodeSubjectObj                   as class goods_barcode               no-undo.
  define variable unitaddsSubjectsObj                      as class subjects                    no-undo.
  define variable good_unitaddSubjectObj                   as class unit-add-code               no-undo.
  define variable impGoodEventHndlrObj                     as class impgoods                    no-undo.
  define variable cashiersSubjectObj                       as class cashiers                    no-undo.
  define variable impcashiersEventHndlrObj                 as class impcashiers                 no-undo.
  define variable bank-accountsSubjectObj                  as class bank-accounts               no-undo.
  define variable bank-accounts_bankSubjectObj             as class bank-accounts_bank          no-undo.
  define variable impbank-accountsEventHndlrObj            as class impbank-accounts            no-undo.
  define variable contr-price-docsSubjectObj               as class contr-price-docs            no-undo.
  define variable price-listSubjectsObj                    as class subjects                    no-undo.
  define variable contr-price-listSubjectObj               as class contr-price-docs_price-list no-undo.
  define variable impcontr-price-docsEventHndlrObj         as class impcontr-price-docs         no-undo.
  define variable price-doc-impSubjectObj                  as class price-doc-imp               no-undo.
  define variable price-doc_gds-saleSubjectObj             as class price-doc_gds-sale          no-undo.
  define variable impprice-docEventHndlrObj                as class impprice-doc                no-undo.
  define variable price-doc-listSubjectsObj                as class subjects                    no-undo.
  define variable int-pointSubjectObj                      as class int-point                   no-undo.
  define variable impint-pointEventHndlrObj                as class impint-point                no-undo.
  define variable assortment-matrixSubjectObj              as class assortment-matrix           no-undo.
  define variable impassortment-matrixEventHndlrObj        as class impassortment-matrix        no-undo.
  define variable measuringSubjectObj                      as class measuring                   no-undo.
  define variable impmeasuringEventHndlrObj                as class impmeasuring                no-undo.
  define variable recipeSubjectObj                         as class recipe                      no-undo.
  define variable recipe-gdSubjectObj                      as class recipe-gd                   no-undo.
  define variable imprecipeEventHndlrObj                   as class imprecipe                   no-undo.
  define variable recipe-gd-listSubjectsObj                as class subjects                    no-undo.
  define variable transportSubjectObj                      as class transport                   no-undo.
  define variable transport_sectionSubjectObj              as class transport_section           no-undo.
  define variable transport_section_ct-lvlSubjectObj       as class transport_section_calibration-table    no-undo.
  define variable imptransportEventHndlrObj                as class imptransport                no-undo.
  define variable transport_section-listSubjectsObj        as class subjects                    no-undo.
  define variable transport_section_ct-lvl-listSubjectsObj as class subjects                    no-undo.
  define variable tank-impSubjectObj                       as class tank-imp                    no-undo.
  define variable tank-imp_cal-tblSubjectObj               as class tank-imp_cal-tbl            no-undo.
  define variable tank-imp_belt-tblSubjectObj              as class tank-imp_belt-tbl           no-undo.
  define variable imptank-impEventHndlrObj                 as class imptank-imp                 no-undo.
  define variable tank-imp_cal-tbllistSubjectsObj          as class subjects                    no-undo.
  define variable tank-imp_belt-tbllistSubjectsObj         as class subjects                    no-undo.
  define variable trn-gd-doc-inSubjectObj                  as class trn-gd-doc-in               no-undo.
  define variable trn-gdSubjectObj                         as class trn-gd                      no-undo.
  define variable trn-prtSubjectObj                        as class trn-prt                     no-undo.
  define variable trn-markSubjectObj                       as class trn-mark                    no-undo.
  define variable imptrn-gd-docEventHndlrObj               as class imptrn-gd-doc               no-undo.
  define variable trn-gd-doc-inlistSubjectsObj             as class subjects                    no-undo.
  define variable trn-prt-doc-inlistSubjectsObj            as class subjects                    no-undo.
  define variable trn-mark-doc-inlistSubjectsObj           as class subjects                    no-undo.
  define variable normlossSubjectObj                       as class normloss                    no-undo.
  define variable impnormlossEventHndlrObj                 as class impnormloss                 no-undo.
  define variable trn-fuel-doc-inSubjectObj      as class trn-fuel-doc-in no-undo.
  define variable trn-gd-fuelSubjectObj          as class trn-gd-fuel     no-undo.
  define variable imptrn-fuel-docEventHndlrObj   as class imptrn-fuel-doc no-undo.
  define variable trn-fuel-doc-inlistSubjectsObj as class subjects        no-undo.
  define variable ordrspSubjectObj                         as class ordrsp                      no-undo.
  define variable order-goodSubjectObj                     as class order-good                  no-undo.
  define variable impordrspEventHndlrObj                   as class impordrsp                   no-undo.
  define variable order-goodlistSubjectsObj                as class subjects                    no-undo.
  define variable ordanswSubjectObj                        as class ordansw                     no-undo.
  define variable impordanswEventHndlrObj                  as class impordansw                  no-undo.
  define variable promotionSubjectObj                   as class promotion               no-undo. // <promotion>
  define variable promotionSheduleObj                   as class promotion_schedule      no-undo. // promotion:schedule
  define variable promotion_shedule-lineListSubjectsObj as class subjects                no-undo. // promotion:schedule:schedule-lines
  define variable promotion_shedule-lineSubjectObj      as class promotion_schedule-line no-undo. // promotion:schedule:schedule-lines:schedule-line
  define variable promotion_thresholdListSubjectsObj    as class subjects                no-undo. // promotion:thresholds
  define variable promotion_thresholdSubjectObj         as class promotion_threshold     no-undo. // promotion:thresholds:threshold
  define variable promotion_t_giftListSubjectsObj       as class subjects                no-undo. // promotion:thresholds:threshold:gifts
  define variable promotion_t_giftSubjectObj            as class promotion_gift-gd       no-undo. // promotion:thresholds:threshold:gifts:gd
  define variable promotion_gdsListSubjectsObj          as class subjects                no-undo. // promotion:gds
  define variable promotion_gdsSubjectObj               as class promotion_gds-gd        no-undo. // promotion:gds:gd
  define variable promotion_gdListSubjectsObj           as class subjects                no-undo. // promotion:gds-addcond
  define variable promotion_gdSubjectObj                as class promotion_gd            no-undo. // promotion:gds-addcond:gd
  define variable promotionPromosetObj                  as class promotion_promoset      no-undo. // promotion:promoset
  define variable promotion_psListSubjectsObj           as class subjects                no-undo. // promotion:promoset:ps-sections
  define variable promotion_psSubjectObj                as class promotion_ps-section    no-undo. // promotion:promoset:ps-sections:ps-section
  define variable promotion_p_gdListSubjectsObj         as class subjects                no-undo. // promotion:promoset:ps-sections:ps-section:gds
  define variable promotion_p_gdSubjectObj              as class promotion_gd            no-undo. // promotion:promoset:ps-sections:ps-section:gds:gd
  define variable promotion_giftListSubjectsObj         as class subjects                no-undo. // promotion:gifts
  define variable promotion_giftSubjectObj              as class promotion_gift-gd       no-undo. // promotion:gifts:gd
  define variable imppromotionEventHndlrObj              as class imppromotion            no-undo.
  define variable payment-systems-SubjectObj             as class subjects                no-undo. // <payment-system>
  define variable payment-system-SubjectObj              as class payment-system          no-undo. // <payment-system>
  define variable bin-ranges-SubjectsObj                 as class subjects                no-undo. // payment-system:bins-range
  define variable bin-range-SubjectObj                   as class bin-range               no-undo. // payment-system:bins-range:bin-range
  define variable bins-tokens-SubjectsObj                as class subjects                no-undo. // payment-system:bins-range
  define variable bin-token-SubjectObj                   as class bin-token               no-undo. // payment-system:bins-range:bin-range
  define variable imppayment-systemEventHndlrObj        as class imppayment-system       no-undo.
  define variable kass-bookSubjectObj                   as class kass-book               no-undo. // <kass-book>
  define variable kass-book-gdListSubjectsObj           as class subjects                no-undo. // kass-book:kb-gds
  define variable kass-book-gdSubjectObj                as class kass-book-gd            no-undo. // kass-book:kb-gds:gd
  define variable impkass-bookEventHndlrObj             as class impkass-book            no-undo.
  define variable payment-agentSubjectObj               as class payment-agent           no-undo. // <payment-agent>
  define variable payment-agent-gdListSubjectsObj       as class subjects                no-undo. // payment-agent:kb-gds
  define variable payment-agent-gdSubjectObj            as class kass-book-gd            no-undo. // payment-agent:kb-gds:gd
  define variable imppayment-agentEventHndlrObj         as class imppayment-agent        no-undo.
  define variable edi-doc-SubjectObj               as class edi-doc                 no-undo. // <edi-doc>
  define variable edi-doc-gd-SubjectsObj       as class subjects                no-undo. // edi-doc:gds
  define variable edi-doc-gd-SubjectObj            as class edi-gd                  no-undo. // edi-doc:gds:gd
  define variable edi-doc-mark-SubjectsObj     as class subjects                no-undo. // edi-doc:gds:gd:marks
  define variable edi-doc-mark-SubjectObj          as class mark                    no-undo. // edi-doc:gds:gd:marks:mark
  define variable impedi-docEventHndlrObj         as class impedi-doc              no-undo.
  define variable mark-SubjectObj          as class mark                    no-undo. // edi-doc:gds:gd:marks:mark
  define variable impmarkEventHndlrObj         as class impmark              no-undo.
  define variable oks-SubjectObj          as class Oks                    no-undo.
  define variable impOKSEventHndlrObj     as class impOks                 no-undo.
  define variable emc-SubjectObj          as class Emc                    no-undo.
  define variable emc-groups-SubjectObj   as class Emc-groups             no-undo.
  define variable dt-season-SubjectObj    as class dt-season              no-undo.
  define variable cashparam-SubjectObj    as class cashparam              no-undo.
  define variable impCodeEventHndlrObj    as class impCode                no-undo.
  define variable OsnovCurrSubj                         as class osnovcorr               no-undo .
  define variable impOsnocCorr                          as class imposnovcorr            no-undo .
  define variable FuelCodeInfoSubj                         as class fuelcodeinfo               no-undo .
  define variable impFuelCodeInfo                          as class impfuelcodeinfo            no-undo .
    define variable seasonSubjectObj                      as class season                  no-undo.
  define variable impSeasonEventHndlrObj                as class impseason               no-undo.
  define variable gds-seasonSubjectObj                  as class gds-season              no-undo.
  define variable impGds-SeasonEventHndlrObj            as class impgds-season           no-undo.
  define variable Rvd-ReasonSubj                        as class rvd-reason              no-undo .
  define variable impRvd-Reason                         as class imprvd-reason           no-undo .
  define variable permissibleSubj                       as class permissible-deviations    no-undo .
  define variable imppermissible                        as class imppermissible-deviation  no-undo .
  define variable reasonSusCheckSubj                    as class reasons-suspicious-check     no-undo .
  define variable impReasonSusCheck                     as class impreasons-suspicious-check  no-undo .
  define variable Doc-ReasonSubj                        as class doc-reason              no-undo .
  define variable impDoc-Reason                         as class impdoc-reason           no-undo .
  define variable settingsSubjectObj                    as class settings                no-undo.
  define variable impSettingsEventHndlrObj              as class impsettings             no-undo.
  define variable good             as logical   no-undo.
  define variable nameChildrenCurr as character no-undo.
  define variable iNum             as integer   no-undo.
  define variable v-longchar       as longchar no-undo .
  define private variable parparentproc   as handle no-undo .
  define private variable p-parent-handle as handle no-undo .
  define private variable p-log-handle    as handle no-undo .
  define property MsgPrivate as character no-undo
    get:
      return trim (MsgPrivate, chr(10)).
    end.
    private set (inArg as char):
      MsgPrivate = MsgPrivate + chr(10) + inArg.
    end.
  define property Msg as character no-undo
    get:
      return (substitute ("Секция &1 элемент № &2: &3", nameChildrenCurr, string (iNum), MsgPrivate) ).
    end.
  define property ErrSts as logical no-undo
    get.
    set.
  constructor public parsesub (  ):
    cliGrpSubjectObj = new cli-grps ().
    impCliGrpEventHndlrObj = new impcli-grps ().
    businessUnitsSubjectObj = new business-units ().
    impbusinessUnitsEventHndlrObj = new impbusiness-units ().
    clientsSubjectObj = new clients ().
    clients_carriersSubjectObj = new clients_carriers ().
    clients_suppliersSubjectObj = new clients_suppliers ().
    clients_carriersListSubjectObj = new subjects ('nb-carriers').
    clients_suppliersListSubjectObj = new subjects ('nb-suppliers').
    impClientsEventHndlrObj = new impclients ().
    contractsSubjectObj = new contracts ().
    impContractsEventHndlrObj = new impcontracts ().
    normlossSubjectObj = new normloss ().
    impnormlossEventHndlrObj = new impnormloss ().
    currencySubjectObj = new currency ().
    impCurrencyEventHndlrObj = new impcurrency ().
    goodGrpsSubjectObj = new good-grps ().
    impGoodGrpsEventHndlrObj = new impgood-grps ().
    paymentTypeSubjectObj = new payment-type ().
    impPaymentTypeEventHndlrObj = new imppayment-type ().
    paymentTypeGroupSubjectObj = new payment-type-group ().
    impPaymentTypeGroupEventHndlrObj = new imppayment-type-group ().
    unitsSubjectObj = new units ().
    impUnitsEventHndlrObj = new impunits ().
    cashiersSubjectObj = new cashiers ().
    impcashiersEventHndlrObj = new impcashiers ().
    bank-accountsSubjectObj = new bank-accounts ().
    impbank-accountsEventHndlrObj = new impbank-accounts ().
    seasonSubjectObj = new season ().
    impSeasonEventHndlrObj = new impseason ().
    gds-seasonSubjectObj = new gds-season ().
    impGds-SeasonEventHndlrObj = new impgds-season ().
    price-doc-listSubjectsObj = new subjects("gds-sale").
    price-doc-impSubjectObj = new price-doc-imp ().
    impprice-docEventHndlrObj = new impprice-doc ().
    int-pointSubjectObj = new int-point ().
    impint-pointEventHndlrObj = new impint-point ().
    assortment-matrixSubjectObj = new assortment-matrix ().
    impassortment-matrixEventHndlrObj = new impassortment-matrix ().
    measuringSubjectObj = new measuring ().
    impmeasuringEventHndlrObj = new impmeasuring ().
    transportSubjectObj = new transport ().
    imptransportEventHndlrObj = new imptransport ().
    transport_section-listSubjectsObj = new subjects ("sections").
    transport_section_ct-lvl-listSubjectsObj = new subjects ("calibration-table").
    tank-impSubjectObj = new tank-imp ().
    imptank-impEventHndlrObj = new imptank-imp ().
    tank-imp_cal-tbllistSubjectsObj = new subjects ("cal-tbl").
    tank-imp_belt-tbllistSubjectsObj = new subjects ("belt-tbl").
    ordrspSubjectObj = new ordrsp ().
    impordrspEventHndlrObj = new impordrsp ().
    order-goodlistSubjectsObj = new subjects ("order-good").
    ordanswSubjectObj = new ordansw ().
    impordanswEventHndlrObj = new impordansw ().
    trn-prt-doc-inlistSubjectsObj = new subjects ("prts"). // - осталось не перенесённым из документов движения СТ
  end constructor.
  method public void setParent (
  input parparentproc   as handle
, input p-parent-handle as handle
, input p-log-handle    as handle
  ) :
    assign
      this-object:parparentproc   = parparentproc
      this-object:p-parent-handle = p-parent-handle
      this-object:p-log-handle    = p-log-handle
    .
  end method .
  method public logical Parse1CRNSub (input inFileName as character):
    define variable result as logical no-undo.
    define variable hDoc as handle no-undo.
    define variable hRoot as handle no-undo.
    create x-document hDoc.
    create x-noderef hRoot.
    hDoc:load("file",inFileName,false).
    hDoc:get-document-element(hRoot).
    iNum = 3.
    GetChildren(hRoot, 1).
    return result.
    finally :
       delete object hDoc  no-error.
       delete object hRoot no-error.
    end finally .
  end method.
  method public logical Parse1CRNSub (input inFileMem as memptr):
    define variable result as logical no-undo.
    define variable hDoc as handle no-undo.
    define variable hRoot as handle no-undo.
    create x-document hDoc.
    create x-noderef hRoot.
    hDoc:load("memptr",inFileMem,false).
    hDoc:get-document-element(hRoot).
    iNum = 3.
    GetChildren(hRoot, 1).
    return result.
    finally :
       delete object hDoc  no-error.
       delete object hRoot no-error.
    end finally .
  end method.
  method private void GetChildren (
    input hParent as handle,
    input level as integer):
    define variable i            as integer   no-undo.
    define variable hNoderef     as handle    no-undo.
    define variable hText        as handle    no-undo.
    define variable client       as character no-undo.
    define variable v-iSubject   as class ibs.th.bge.1crn.subjects.isubject no-undo .
    define variable v-iImpSub    as class ibs.th.bge.1crn.import.iimpsubject no-undo .
    create x-noderef hNoderef.
    create x-noderef hText .
    repeat i = 1 to hParent:num-children:
      good = hparent:get-child(hnoderef,i).
      if not good then
          leave.
      if hnoderef:subtype <> "element" then
          next.
      hnoderef:get-child(htext, 1) no-error .
      iNum = iNum + 1.
      if hnoderef:child-num = 2
      then do:
        nameChildrenCurr = hnoderef:name.
      end.
      case hNoderef:name:
        // экземпляр xxxSubjectObj создаётся перед первым импортом
        // экземпляр xxxSubjectObj очищается перед началом каждого нового объекта внутри GetChildrenSub()
        when "country":U then do:
          if not valid-object(countrySubjectObj)       then countrySubjectObj       = new country (). // <country>
          if not valid-object(impcountryEventHndlrObj) then impcountryEventHndlrObj = new impcountry () .
          v-iSubject = countrySubjectObj .
          v-iImpSub  = impcountryEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "org-unit":U then do:
          if not valid-object(firmsSubjectObj)       then firmsSubjectObj       = new firms (). // <org-unit>
          if not valid-object(impFirmsEventHndlrObj) then impFirmsEventHndlrObj = new impfirms () .
          v-iSubject = firmsSubjectObj .
          v-iImpSub  = impFirmsEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "good":U then do:
          if not valid-object(goodSubjectObj)       then goodSubjectObj         = new goods (). // <good>
          if not valid-object(impGoodEventHndlrObj) then do :
            impGoodEventHndlrObj = new impgoods () .
          end .
          v-iSubject = goodSubjectObj .
          v-iImpSub  = impGoodEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "recipe":U then do:
          if not valid-object(recipeSubjectObj)       then recipeSubjectObj       = new recipe (). // <recipe>
          if not valid-object(imprecipeEventHndlrObj) then do :
            imprecipeEventHndlrObj = new imprecipe ().
            // imprecipeEventHndlrObj:setParent (parparentproc, p-parent-handle, p-log-handle) . - пока не требуется
          end .
          v-iSubject = recipeSubjectObj .
          v-iImpSub  = imprecipeEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "azk":U then do:
          if not valid-object(shopsSubjectObj)       then shopsSubjectObj       = new shops (). // <azk>
          if not valid-object(impShopsEventHndlrObj) then do :
            impShopsEventHndlrObj = new impshops ().
            // impShopsEventHndlrObj:setParent (parparentproc, p-parent-handle, p-log-handle) . - пока не требуется
          end .
          v-iSubject = shopsSubjectObj .
          v-iImpSub  = impShopsEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "osnovcorr":U then do:
          if not valid-object(OsnovCurrSubj)       then OsnovCurrSubj       = new osnovcorr(). // <promotion>
          if not valid-object(impOsnocCorr) then do :
            impOsnocCorr = new imposnovcorr ().
          end .
          v-iSubject = OsnovCurrSubj .
          v-iImpSub  = impOsnocCorr .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "fuelcodeinfo":U then do:
          if not valid-object(fuelcodeinfoSubj)       then fuelcodeinfoSubj       = new fuelcodeinfo(). // <promotion>
          if not valid-object(impfuelcodeinfo) then do :
            impfuelcodeinfo = new impfuelcodeinfo ().
          end .
          v-iSubject = fuelcodeinfoSubj .
          v-iImpSub  = impfuelcodeinfo .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "promotion":U then do:
          if not valid-object(promotionSubjectObj)       then promotionSubjectObj       = new promotion(). // <promotion>
          if not valid-object(imppromotionEventHndlrObj) then do :
            imppromotionEventHndlrObj = new imppromotion ().
            imppromotionEventHndlrObj:setParent (parparentproc, p-parent-handle, p-log-handle) .
          end .
          v-iSubject = promotionSubjectObj .
          v-iImpSub  = imppromotionEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "payment-system":U then do:
          if level < 4 // если загрузка не из промоакций
          then do:
             if not valid-object(payment-system-SubjectObj)       then payment-system-SubjectObj       = new payment-system(). // <payment-system>
             if not valid-object(imppayment-systemEventHndlrObj) then do :
               impPayment-SystemEventHndlrObj = new impPayment-System ().
             end .
             v-iSubject = payment-system-SubjectObj .
             v-iImpSub  = imppayment-systemEventHndlrObj .
             // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
             GetChildrenSub (hNoderef, (level + 1), v-iSubject).
             ReceivedSubjectPublish(v-iSubject, v-iImpSub).
           end.
        end.
        when "edi-doc":U
     or when "edi-doc-stts" then do:
           publish "startStopGroupRec" from p-parent-handle.
           if not valid-object(edi-doc-SubjectObj)       then edi-doc-SubjectObj       = new edi-doc(). // <payment-system>
           edi-doc-SubjectObj:obj-load = hNoderef:name.
           if not valid-object(impedi-docEventHndlrObj) then do :
               impedi-docEventHndlrObj = new impedi-doc ().
           end .
           v-iSubject = edi-doc-SubjectObj .
           v-iImpSub  = impedi-docEventHndlrObj .
             // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
           GetChildrenSub (hNoderef, (level + 1), v-iSubject).
           ReceivedSubjectPublish(v-iSubject, v-iImpSub).
           publish "startStopGroupRec" from p-parent-handle.
        end.
        when "mark":U
        then do:
           if level < 3 // если загрузка не из в составе edoc
           then do:
              if not valid-object(mark-SubjectObj)       then mark-SubjectObj       = new mark(). // <payment-system>
              mark-SubjectObj:obj-load = hNoderef:name.
              if not valid-object(impmarkEventHndlrObj) then do :
                  impmarkEventHndlrObj = new impmark ().
              end .
              v-iSubject = mark-SubjectObj .
              v-iImpSub  = impmarkEventHndlrObj .
                // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
              GetChildrenSub (hNoderef, (level + 1), v-iSubject).
              ReceivedSubjectPublish(v-iSubject, v-iImpSub).
           end.
        end.
        when "Etalon-param":U
        then do:
                      if not valid-object(cashparam-SubjectObj)
           then
              cashparam-SubjectObj       = new cashparam().
           if not valid-object(impCodeEventHndlrObj)
           then do :
              impCodeEventHndlrObj = new impCode ().
           end .
           v-iSubject = cashparam-SubjectObj .
           v-iImpSub  = impCodeEventHndlrObj .
                // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
           GetChildrenSub (hNoderef, (level + 1), v-iSubject).
           ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "emc":U
        then do:
                      if not valid-object(emc-SubjectObj)
           then
              emc-SubjectObj       = new emc().
           if not valid-object(impCodeEventHndlrObj)
           then do :
              impCodeEventHndlrObj = new impCode ().
           end .
           v-iSubject = emc-SubjectObj .
           v-iImpSub  = impCodeEventHndlrObj .
                // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
           GetChildrenSub (hNoderef, (level + 1), v-iSubject).
           ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "emc-group":U
        then do:
                      if not valid-object(emc-groups-SubjectObj)
           then
              emc-groups-SubjectObj       = new emc-groups().
           if not valid-object(impCodeEventHndlrObj)
           then do :
              impCodeEventHndlrObj = new impCode ().
           end .
           v-iSubject = emc-groups-SubjectObj .
           v-iImpSub  = impCodeEventHndlrObj .
                // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
           GetChildrenSub (hNoderef, (level + 1), v-iSubject).
           ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "dt-season":U
        then do:
                      if not valid-object(dt-season-SubjectObj)
           then
              dt-season-SubjectObj       = new dt-season().
           if not valid-object(impCodeEventHndlrObj)
           then do :
              impCodeEventHndlrObj = new impCode ().
           end .
           v-iSubject = dt-season-SubjectObj .
           v-iImpSub  = impCodeEventHndlrObj .
                // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
           GetChildrenSub (hNoderef, (level + 1), v-iSubject).
           ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "ok":U
        then do:
                      if not valid-object(oks-SubjectObj)
           then
              oks-SubjectObj       = new oks().
           if not valid-object(impoksEventHndlrObj)
           then do :
              impoksEventHndlrObj = new impoks ().
           end .
           v-iSubject = oks-SubjectObj .
           v-iImpSub  = impoksEventHndlrObj .
                // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
           GetChildrenSub (hNoderef, (level + 1), v-iSubject).
           ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "contr-price-doc":U then do:
          if not valid-object(contr-price-docsSubjectObj) then contr-price-docsSubjectObj = new contr-price-docs (). // <contr-price-doc>
          if not valid-object(impcontr-price-docsEventHndlrObj) then do :
            impcontr-price-docsEventHndlrObj = new impcontr-price-docs ().
          end .
          v-iSubject = contr-price-docsSubjectObj .
          v-iImpSub  = impcontr-price-docsEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "kass-book":U then do:
          if not valid-object(kass-bookSubjectObj) then kass-bookSubjectObj = new kass-book (). // <kass-book>
          if not valid-object(impkass-bookEventHndlrObj) then do :
            impkass-bookEventHndlrObj = new impkass-book ().
          end .
          v-iSubject = kass-bookSubjectObj .
          v-iImpSub  = impkass-bookEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "payment-agent":U then do:
          if not valid-object(payment-agentSubjectObj) then payment-agentSubjectObj = new payment-agent (). // <payment-agent>
          if not valid-object(imppayment-agentEventHndlrObj) then do :
            imppayment-agentEventHndlrObj = new imppayment-agent ().
          end .
          v-iSubject = payment-agentSubjectObj .
          v-iImpSub  = imppayment-agentEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "trn-gd-doc" then do:
          if not valid-object(trn-gd-doc-inSubjectObj) then trn-gd-doc-inSubjectObj = new trn-gd-doc-in (). // <trn-gd-doc>
          if not valid-object(imptrn-gd-docEventHndlrObj) then do :
            imptrn-gd-docEventHndlrObj = new imptrn-gd-doc ().
          end .
          v-iSubject = trn-gd-doc-inSubjectObj .
          v-iImpSub  = imptrn-gd-docEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "trn-fuel-doc" then do:
          if not valid-object(trn-fuel-doc-inSubjectObj) then trn-fuel-doc-inSubjectObj = new trn-fuel-doc-in (). // <trn-fuel-doc>
          if not valid-object(imptrn-fuel-docEventHndlrObj) then do :
            imptrn-fuel-docEventHndlrObj = new imptrn-fuel-doc ().
          end .
          v-iSubject = trn-fuel-doc-inSubjectObj .
          v-iImpSub  = imptrn-fuel-docEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "rvd-reason":U then do:
          if not valid-object(Rvd-ReasonSubj)       then Rvd-ReasonSubj       = new rvd-reason(). // <rvd-reason>
          if not valid-object(impRvd-Reason) then do :
            impRvd-Reason = new imprvd-reason ().
          end .
          v-iSubject = Rvd-ReasonSubj .
          v-iImpSub  = impRvd-Reason .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "permissible-deviation":U then do:
          if not valid-object(permissibleSubj)       then permissibleSubj       = new permissible-deviations(). // <permissible-deviation>
          if not valid-object(imppermissible) then do :
            impPermissible = new imppermissible-deviation ().
          end .
          v-iSubject = permissibleSubj .
          v-iImpSub  = impPermissible .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "reasons-suspicious-check":U then do:
          if not valid-object(reasonSusCheckSubj)       then reasonSusCheckSubj       = new reasons-suspicious-check(). // <reasons-suspicious-check>
          if not valid-object(impReasonSusCheck) then do :
            impReasonSusCheck = new impreasons-suspicious-check ().
          end .
          v-iSubject = reasonSusCheckSubj .
          v-iImpSub  = impReasonSusCheck .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "doc-reason":U then do:
          if not valid-object(Doc-ReasonSubj)       then Doc-ReasonSubj       = new doc-reason(). // <doc-reason>
          if not valid-object(impDoc-Reason) then do :
            impDoc-Reason = new impdoc-reason ().
          end .
          v-iSubject = Doc-ReasonSubj .
          v-iImpSub  = impDoc-Reason .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "ordrsp" then do:
          if not valid-object(ordrspSubjectObj) then ordrspSubjectObj = new ordrsp ().
          if not valid-object(impordrspEventHndlrObj) then do :
            impordrspEventHndlrObj = new impordrsp ().
          end .
          v-iSubject = ordrspSubjectObj .
          v-iImpSub  = impordrspEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "ordansw" then do:
          if not valid-object(ordanswSubjectObj) then ordanswSubjectObj = new ordansw ().
          if not valid-object(impordanswEventHndlrObj) then do :
            impordanswEventHndlrObj = new impordansw ().
          end .
          v-iSubject = ordanswSubjectObj .
          v-iImpSub  = impordanswEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "setting" then do:
          if not valid-object(settingsSubjectObj) then settingsSubjectObj = new settings ().
          if not valid-object(impSettingsEventHndlrObj) then do :
            impSettingsEventHndlrObj = new impsettings ().
          end .
          v-iSubject = settingsSubjectObj .
          v-iImpSub  = impSettingsEventHndlrObj .
          // внести new внутрь остальных case, и потом вынести GetChildrenSub и ReceivedSubjectPublish вниз под case
          GetChildrenSub (hNoderef, (level + 1), v-iSubject).
          ReceivedSubjectPublish(v-iSubject, v-iImpSub).
        end.
        when "business-unit" then do:
          GetChildrenSub (hNoderef, (level + 1), businessUnitsSubjectObj).
          ReceivedSubjectPublish(businessUnitsSubjectObj, impbusinessUnitsEventHndlrObj).
        end.
        when "contractor-group" then do:
          GetChildrenSub (hNoderef, (level + 1), cliGrpSubjectObj).
          ReceivedSubjectPublish(cliGrpSubjectObj, impCliGrpEventHndlrObj).
        end.
        when "contractor" then do:
          GetChildrenSub (hNoderef, (level + 1), clientsSubjectObj).
          ReceivedSubjectPublish(clientsSubjectObj, impClientsEventHndlrObj).
        end.
        when "contract" then do:
          GetChildrenSub (hNoderef, (level + 1), contractsSubjectObj).
          ReceivedSubjectPublish(contractsSubjectObj, impContractsEventHndlrObj).
        end.
        when "norm-loss" then do:
          GetChildrenSub (hNoderef, (level + 1), normlossSubjectObj).
          ReceivedSubjectPublish(normlossSubjectObj, impnormlossEventHndlrObj).
        end.
        when "currency" then do:
          GetChildrenSub (hNoderef, (level + 1), currencySubjectObj).
          ReceivedSubjectPublish(currencySubjectObj, impCurrencyEventHndlrObj).
        end.
        when "good-grp" then do:
          GetChildrenSub (hNoderef, (level + 1), goodGrpsSubjectObj).
          ReceivedSubjectPublish(goodGrpsSubjectObj, impGoodGrpsEventHndlrObj).
        end.
        when "payment-type-group" then do:
          GetChildrenSub (hNoderef, (level + 1), paymentTypeGroupSubjectObj).
          ReceivedSubjectPublish(paymentTypeGroupSubjectObj, impPaymentTypeGroupEventHndlrObj).
        end.
        when "payment-type" then do:
          GetChildrenSub (hNoderef, (level + 1), paymentTypeSubjectObj).
          ReceivedSubjectPublish(paymentTypeSubjectObj, impPaymentTypeEventHndlrObj).
        end.
        when "unit" then do:
          GetChildrenSub (hNoderef, (level + 1), unitsSubjectObj).
          ReceivedSubjectPublish(unitsSubjectObj, impUnitsEventHndlrObj).
        end.
        when "cashier" then do:
          GetChildrenSub (hNoderef, (level + 1), cashiersSubjectObj).
          ReceivedSubjectPublish(cashiersSubjectObj, impcashiersEventHndlrObj).
        end.
        when "bank-account" then do:
          GetChildrenSub (hNoderef, (level + 1), bank-accountsSubjectObj).
          ReceivedSubjectPublish(bank-accountsSubjectObj, impbank-accountsEventHndlrObj).
        end.
        when "price-doc" then do:
          GetChildrenSub (hNoderef, (level + 1), price-doc-impSubjectObj).
          ReceivedSubjectPublish(price-doc-impSubjectObj, impprice-docEventHndlrObj).
        end.
        when "int-point" then do:
          GetChildrenSub (hNoderef, (level + 1), int-pointSubjectObj).
          ReceivedSubjectPublish(int-pointSubjectObj, impint-pointEventHndlrObj).
        end.
        when "assortment-matrix" then do:
          GetChildrenSub (hNoderef, (level + 1), assortment-matrixSubjectObj).
          ReceivedSubjectPublish(assortment-matrixSubjectObj, impassortment-matrixEventHndlrObj).
        end.
        when "measuring" then do:
          GetChildrenSub (hNoderef, (level + 1), measuringSubjectObj).
          ReceivedSubjectPublish(measuringSubjectObj, impmeasuringEventHndlrObj).
        end.
        when "transport" then do:
          GetChildrenSub (hNoderef, (level + 1), transportSubjectObj).
          ReceivedSubjectPublish(transportSubjectObj, imptransportEventHndlrObj).
        end.
        when "tank" then do:
          GetChildrenSub (hNoderef, (level + 1), tank-impSubjectObj).
          ReceivedSubjectPublish(tank-impSubjectObj, imptank-impEventHndlrObj).
        end.
        when "Tb-group" then do:
          GetChildrenSub (hNoderef, (level + 1), seasonSubjectObj).
          ReceivedSubjectPublish(seasonSubjectObj, impSeasonEventHndlrObj).
        end.
        when "Tb-gd" then do:
          GetChildrenSub (hNoderef, (level + 1), gds-seasonSubjectObj).
          ReceivedSubjectPublish(gds-seasonSubjectObj, impGds-SeasonEventHndlrObj).
        end.
      end case.
      // --> вставить GetChildrenSub и ReceivedSubjectPublish сюда
      // после отработки GetChildrenSub() вызывает GetChildren() и ещё раз просматривает все дочерние элементы сущности верхнего уровня
      GetChildren(hNoderef, (level + 1)).
      case hNoderef:name:
        when "marks":U
        then do:
          if level < 2 // если загрузка не из в составе edoc
          then do:
            if valid-object(impmarkEventHndlrObj) then
            do:
              impmarkEventHndlrObj:WriteDB().
              delete object impmarkEventHndlrObj.
            end.
          end.
        end.
        when "ordansws" then do:
          if valid-object(impordanswEventHndlrObj) then
          do:
            impordanswEventHndlrObj:sendNotification().
            delete object impordanswEventHndlrObj.
          end.
        end.
      end case.
    end.
    catch exAppErrors as class Progress.Lang.AppError :
      MsgPrivate = exAppErrors:ReturnValue .
      MsgPrivate = exAppErrors:GetMessage(1) .
      ErrSts = true.
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      MsgPrivate = exProErrors:GetMessage(1) .
      ErrSts = true.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      MsgPrivate = "Unexpected error occurred..." .
      ErrSts   = true.
      undo, throw exAnyErrors .
    end catch .
    finally :
      // если мы зашли внутрь пустого элемента <tag/> - его num-children = 0 и объекты hNoderef и hText не созданы
      if valid-object(hNoderef) then delete object hNoderef.
      if valid-object(hText)    then delete object hText.
    end finally .
  end method.
  method private void ReceivedSubjectPublish (
      input Subject as class ibs.th.bge.1crn.subjects.isubject, input EventHndlrImpSub as class ibs.th.bge.1crn.import.iimpsubject):
    ReceivedSubject:Publish(Subject, EventHndlrImpSub).
    ibs.th.bge.1crn.import.impmsgs:writeSec(substitute ("Секция &1 элемент № &2", nameChildrenCurr, string (iNum))).
    catch exAppErrors as class Progress.Lang.AppError :
      MsgPrivate = EventHndlrImpSub:Msg .
      MsgPrivate = exAppErrors:GetMessage(1) .
      ErrSts = true.
      return error.
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      MsgPrivate = exProErrors:GetMessage(1) .
      ErrSts = true.
      return error.
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      MsgPrivate = "Unexpected error occurred..." .
      ErrSts = true.
      return error.
    end catch .
  end method.
  method private void GetChildrenSub (
    input hParent as handle,
    input level as integer, input subjectObj as class isubject):
    define variable i            as integer   no-undo.
    define variable hNoderef     as handle    no-undo.
    define variable hText        as handle    no-undo.
    define variable v-need-parse as logical   no-undo .
    create x-noderef hNoderef.
    create x-noderef hText .
    if valid-object (subjectObj) then do:
      subjectObj:SetProp( hParent:name, "").
      case hparent:name :
        when "schedule" then do: // promotion:schedule; subjectObj = promotionSheduleObj
          // вместо тега <sch-code> могу прислать аттрибут "sch-code"
          subjectObj:SetProp( "sch-code" , hparent:get-attribute ("sch-code") ).
        end .
        otherwise .
      end case .
    end. // end_of_valid_object_subjectObj
    repeat i = 1 to hParent:num-children:
      good = hparent:get-child(hnoderef,i) no-error.
      if not good then
          leave.
      if hnoderef:subtype <> "element" then
          next.
      good = hnoderef:get-child(htext, 1) no-error .
      if not good
        then next.
      iNum = iNum + 1.
      case hnoderef:name:
        when "sections" or when "calibration-table" or
        when "cal-tbl" or when "belt-tbl" or
        when "nb-carriers" or when "nb-suppliers" or when "prts"
        then do:
          GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "barcodes" then do :
          v-need-parse = true .
          if v-need-parse and valid-object (goodSubjectObj) then do : // goods:good:barcodes
            if goodSubjectObj:IsInitSubForWrite then do:
              barcodesSubjectsObj = new subjects ("barcode") .
                 GetChildrenSub (hNoderef, (level + 1), ?).
              goodSubjectObj:SetProp (barcodesSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "barcode" then do: // goods:good:barcodes:barcode
            if not valid-object(barcodesSubjectsObj) then
              undo, throw new Progress.Lang.AppError("отсутствует секция barcodes для перечня barcode") .
            barcodesSubjectsObj:Add(  new goods_barcode()  ).
            good_barcodeSubjectObj = cast (barcodesSubjectsObj:SubjectObjCurr, goods_barcode).
            GetChildrenSub (hNoderef, (level + 1), good_barcodeSubjectObj).
        end.
        when "marks" then do :
          // _SubjectObj[]: валидный только для коллекций, чьи теги присутствуют в импортируемом сейчас пакете;
          v-need-parse = true .
          if v-need-parse and valid-object (edi-doc-gd-SubjectObj) then do: // edi-doc:gds
            if edi-doc-gd-SubjectObj:IsInitSubForWrite then do:
              edi-doc-mark-SubjectsObj = new subjects ("marks") .
               GetChildrenSub (hNoderef, (level + 1), ?).
              edi-doc-gd-SubjectObj:SetProp (edi-doc-mark-SubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (trn-gdSubjectObj) then
          do:
            if trn-gdSubjectObj:IsInitSubForWrite then
            do:
              trn-mark-doc-inlistSubjectsObj = new subjects ("marks") .
              GetChildrenSub (hNoderef, (level + 1), ?).
              trn-gdSubjectObj:SetProp (trn-mark-doc-inlistSubjectsObj).
              v-need-parse = false .
            end.
          end.
        end.
        when "gds" then do :
          // _SubjectObj[]: валидный только для коллекций, чьи теги присутствуют в импортируемом сейчас пакете;
          v-need-parse = true .
          // по убыванию уровня вложенности:
          if v-need-parse and valid-object (promotion_psSubjectObj) then do: // promotion:promoset:ps-sections:ps-section:gds
            if promotion_psSubjectObj:IsInitSubForWrite then do:
              promotion_p_gdListSubjectsObj = new subjects ("gds") .
               GetChildrenSub (hNoderef, (level + 1), ?).
              promotion_psSubjectObj:SetProp (promotion_p_gdListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (edi-doc-SubjectObj) then do: // edi-doc:gds
            if edi-doc-SubjectObj:IsInitSubForWrite then do:
              edi-doc-gd-SubjectsObj = new subjects ("gds") .
               GetChildrenSub (hNoderef, (level + 1), ?).
              edi-doc-SubjectObj:SetProp (edi-doc-gd-SubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (promotionSubjectObj) then do: // promotion:gds
            if promotionSubjectObj:IsInitSubForWrite then do:
              promotion_gdsListSubjectsObj = new subjects ("gds") .
               GetChildrenSub (hNoderef, (level + 1), ?).
              promotionSubjectObj:SetProp (promotion_gdsListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (trn-gd-doc-inSubjectObj) then do: // trn-gd-doc:gds
            if trn-gd-doc-inSubjectObj:IsInitSubForWrite then do:
              trn-gd-doc-inlistSubjectsObj = new subjects ("gds") .
              GetChildrenSub (hNoderef, (level + 1), ?).
              trn-gd-doc-inSubjectObj:SetProp (trn-gd-doc-inlistSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (trn-fuel-doc-inSubjectObj) then do: // trn-fuel-doc:gds
            if trn-fuel-doc-inSubjectObj:IsInitSubForWrite then do:
              trn-fuel-doc-inlistSubjectsObj = new subjects ("gds") .
              GetChildrenSub (hNoderef, (level + 1), ?).
              trn-fuel-doc-inSubjectObj:SetProp (trn-fuel-doc-inlistSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "gifts" then do :
          v-need-parse = true .
          if v-need-parse and valid-object (promotion_thresholdSubjectObj) then do : // promotion:thresholds:threshold:gifts
            if promotion_thresholdSubjectObj:IsInitSubForWrite then do:
              promotion_t_giftListSubjectsObj = new subjects ("gifts") .
                   GetChildrenSub (hNoderef, (level + 1), ?).
              promotion_thresholdSubjectObj:SetProp (promotion_t_giftListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (promotionSubjectObj) then do : // promotion:gifts
            if promotionSubjectObj:IsInitSubForWrite then do:
              promotion_giftListSubjectsObj = new subjects ("gifts") .
                 GetChildrenSub (hNoderef, (level + 1), ?).
              promotionSubjectObj:SetProp (promotion_giftListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "price-list" then do :
          v-need-parse = true .
          if v-need-parse and valid-object (contr-price-docsSubjectObj) then do : // contr-price-docs:price-list
            if contr-price-docsSubjectObj:IsInitSubForWrite then do:
              price-listSubjectsObj = new subjects ("price-list") .
                 GetChildrenSub (hNoderef, (level + 1), ?).
              contr-price-docsSubjectObj:SetProp (price-listSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "gds-sale" then do:
          v-need-parse = true .
          if v-need-parse and valid-object (contr-price-docsSubjectObj) then do: // contr-price-doc:price-list:gds-sale
            if contr-price-docsSubjectObj:IsInitSubForWrite then do:
              price-listSubjectsObj:Add(  new contr-price-docs_price-list()  ).
              contr-price-listSubjectObj = cast (price-listSubjectsObj:SubjectObjCurr, contr-price-docs_price-list).
              GetChildrenSub (hNoderef, (level + 1), contr-price-listSubjectObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then
          case true :
            when price-doc-impSubjectObj:IsInitSubForWrite then do:
              if not valid-object(price-doc-listSubjectsObj) then price-doc-listSubjectsObj = new subjects("gds-sale") .
              price-doc-listSubjectsObj:Add(new price-doc_gds-sale()).
              price-doc_gds-saleSubjectObj = cast (price-doc-listSubjectsObj:SubjectObjCurr, price-doc_gds-sale).
              GetChildrenSub (hNoderef, (level + 1), price-doc_gds-saleSubjectObj).
              price-doc-impSubjectObj:SetProp (price-doc-listSubjectsObj).
              v-need-parse = false .
            end.
            otherwise do:
            end.
          end case.
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "recipe-gds" then do :
          v-need-parse = true .
          if v-need-parse and valid-object (recipeSubjectObj) then do : // recipes:recipe:recipe-gds
            if recipeSubjectObj:IsInitSubForWrite then do:
              recipe-gd-listSubjectsObj = new subjects ("recipe-gds") .
                 GetChildrenSub (hNoderef, (level + 1), ?).
              recipeSubjectObj:SetProp (recipe-gd-listSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "recipe-gd" then do: // recipes:recipe:recipe-gds:recipe-gd
            if not valid-object(recipe-gd-listSubjectsObj) then
              undo, throw new Progress.Lang.AppError("отсутствует секция recipe-gds для перечня recipe-gd") .
            recipe-gd-listSubjectsObj:Add(  new recipe-gd()  ).
            recipe-gdSubjectObj = cast (recipe-gd-listSubjectsObj:SubjectObjCurr, recipe-gd).
            GetChildrenSub (hNoderef, (level + 1), recipe-gdSubjectObj).
        end.
        when "section" then do:
          case true :
            when transportSubjectObj:IsInitSubForWrite then do:
              if not valid-object(transport_section-listSubjectsObj) then transport_section-listSubjectsObj = new subjects ("sections") .
              transport_section-listSubjectsObj:Add(new transport_section()).
              transport_sectionSubjectObj = cast (transport_section-listSubjectsObj:SubjectObjCurr, transport_section).
              GetChildrenSub (hNoderef, (level + 1), transport_sectionSubjectObj).
              transportSubjectObj:SetProp (transport_section-listSubjectsObj).
            end.
            otherwise do:
               if valid-object(subjectObj)
                then do :
                  subjectObj:SetProp( hNoderef:name, hText:node-value) no-error .
                  if error-status:error
                  then do :
                    hText:node-value-to-longchar(v-longchar) .
                    subjectObj:SetProp( hNoderef:name, v-longchar) .
                  end .
                end .
            end.
          end case.
        end.
        when "ct-lvl" then do:
          case true :
            when transportSubjectObj:IsInitSubForWrite then do:
              if not valid-object(transport_section_ct-lvl-listSubjectsObj) then transport_section_ct-lvl-listSubjectsObj = new subjects ("calibration-table") .
              transport_section_ct-lvl-listSubjectsObj:Add(new transport_section_calibration-table()).
              transport_section_ct-lvlSubjectObj = cast (transport_section_ct-lvl-listSubjectsObj:SubjectObjCurr, transport_section_calibration-table).
              GetChildrenSub (hNoderef, (level + 1), transport_section_ct-lvlSubjectObj).
              transportSubjectObj:SetProp (transport_section_ct-lvl-listSubjectsObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when "bank" then do:
          if not valid-object(bank-accounts_bankSubjectObj) then bank-accounts_bankSubjectObj = new bank-accounts_bank ().  .
          GetChildrenSub (hNoderef, (level + 1), bank-accounts_bankSubjectObj).
          bank-accountsSubjectObj:SetProp (bank-accounts_bankSubjectObj).
        end.
        when "schedule" then do: // promotion:schedule
          // экземпляр promotionSheduleObj создаётся перед импортом первой промо-акции
          if not valid-object(promotionSheduleObj) then
            promotionSheduleObj = new promotion_schedule().
          // экземпляр promotionSheduleObj очищается внутри GetChildrenSub()
          GetChildrenSub (hNoderef, (level + 1), promotionSheduleObj).
          // экземпляр promotionSheduleObj постоянно перепокладывается в промо-акцию
          promotionSubjectObj:SetProp (promotionSheduleObj). // здесь promotionSubjectObj = subjectObj
        end .
        when "schedule-lines" then do : // promotion:schedule:schedule-lines
          if not valid-object(promotionSheduleObj) then
            undo, throw new Progress.Lang.AppError("отсутствует секция schedule для секции schedule-lines") .
          if promotionSheduleObj:IsInitSubForWrite then do:
            promotion_shedule-lineListSubjectsObj = new subjects ("schedule-lines").
            GetChildrenSub (hNoderef, (level + 1), ?).
            promotionSheduleObj:SetProp (promotion_shedule-lineListSubjectsObj).
          end .
        end.
        when "schedule-line" then do: // promotion:schedule:schedule-lines:schedule-line
            if not valid-object(promotion_shedule-lineListSubjectsObj) then
              undo, throw new Progress.Lang.AppError("отсутствует секция schedule-lines для перечня schedule-line") .
            promotion_shedule-lineListSubjectsObj:Add(  new promotion_schedule-line()  ).
            promotion_shedule-lineSubjectObj = cast (promotion_shedule-lineListSubjectsObj:SubjectObjCurr, promotion_schedule-line).
            GetChildrenSub (hNoderef, (level + 1), promotion_shedule-lineSubjectObj).
        end.
        when "thresholds" then do : // promotion:thresholds
          if promotionSubjectObj:IsInitSubForWrite then do:
            promotion_thresholdListSubjectsObj = new subjects ("thresholds") .
            GetChildrenSub (hNoderef, (level + 1), ?).
            promotionSubjectObj:SetProp (promotion_thresholdListSubjectsObj).
          end .
        end.
        when "threshold" then do: // promotion:thresholds:threshold
          if promotionSubjectObj:IsInitSubForWrite then do:
            promotion_thresholdListSubjectsObj:Add(  new promotion_threshold()  ).
            promotion_thresholdSubjectObj = cast (promotion_thresholdListSubjectsObj:SubjectObjCurr, promotion_threshold).
            GetChildrenSub (hNoderef, (level + 1), promotion_thresholdSubjectObj).
          end .
        end.
        when "gds-addcond" then do : // promotion:gds-addcond
          if promotionSubjectObj:IsInitSubForWrite then do:
            promotion_gdListSubjectsObj = new subjects ("gds-addcond") .
               GetChildrenSub (hNoderef, (level + 1), ?).
            promotionSubjectObj:SetProp (promotion_gdListSubjectsObj).
          end .
        end.
        when "promoset" then do: // promotion:promoset
          if not valid-object(promotionPromosetObj) then
            promotionPromosetObj = new promotion_promoset().
          GetChildrenSub (hNoderef, (level + 1), promotionPromosetObj).
          promotionSubjectObj:SetProp (promotionPromosetObj).
        end .
        when "ps-sections" then do : // promotion:promoset:ps-sections
          if promotionPromosetObj:IsInitSubForWrite then do:
            promotion_psListSubjectsObj = new subjects ("ps-sections").
            GetChildrenSub (hNoderef, (level + 1), ?).
            promotionPromosetObj:SetProp (promotion_psListSubjectsObj).
          end .
        end.
        when "ps-section" then do: // promotion:promoset:ps-sections:ps-section
          if promotionPromosetObj:IsInitSubForWrite then do :
            promotion_psListSubjectsObj:Add(  new promotion_ps-section()  ).
            promotion_psSubjectObj = cast (promotion_psListSubjectsObj:SubjectObjCurr, promotion_ps-section).
            GetChildrenSub (hNoderef, (level + 1), promotion_psSubjectObj).
          end .
        end.
        when "cal-tbl" then do:
          case true :
            when tank-impSubjectObj:IsInitSubForWrite then do:
              if not valid-object(tank-imp_cal-tbllistSubjectsObj) then tank-imp_cal-tbllistSubjectsObj = new subjects ("cal-tbl") .
              tank-imp_cal-tbllistSubjectsObj:Add(new tank-imp_cal-tbl()).
              tank-imp_cal-tblSubjectObj = cast (tank-imp_cal-tbllistSubjectsObj:SubjectObjCurr, tank-imp_cal-tbl).
              GetChildrenSub (hNoderef, (level + 1), transport_section_ct-lvlSubjectObj).
              tank-impSubjectObj:SetProp (tank-imp_cal-tbllistSubjectsObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when "cal-tbl-line" then do:
          case true :
            when tank-impSubjectObj:IsInitSubForWrite then do:
              if not valid-object(tank-imp_cal-tbllistSubjectsObj) then tank-imp_cal-tbllistSubjectsObj = new subjects ("cal-tbl") .
              tank-imp_cal-tbllistSubjectsObj:Add(new tank-imp_cal-tbl()).
              tank-imp_cal-tblSubjectObj = cast (tank-imp_cal-tbllistSubjectsObj:SubjectObjCurr, tank-imp_cal-tbl).
              GetChildrenSub (hNoderef, (level + 1), tank-imp_cal-tblSubjectObj).
              tank-impSubjectObj:SetProp (tank-imp_cal-tbllistSubjectsObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when "belt-tbl" then do:
          case true :
            when tank-impSubjectObj:IsInitSubForWrite then do:
              if not valid-object(tank-imp_belt-tbllistSubjectsObj) then tank-imp_belt-tbllistSubjectsObj = new subjects ("belt-tbl") .
              tank-imp_belt-tbllistSubjectsObj:Add(new tank-imp_belt-tbl()).
              tank-imp_belt-tblSubjectObj = cast (tank-imp_belt-tbllistSubjectsObj:SubjectObjCurr, tank-imp_belt-tbl).
              GetChildrenSub (hNoderef, (level + 1), transport_section_ct-lvlSubjectObj).
              tank-impSubjectObj:SetProp (tank-imp_belt-tbllistSubjectsObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when "belt-tbl-line" then do:
          case true :
            when tank-impSubjectObj:IsInitSubForWrite then do:
              if not valid-object(tank-imp_belt-tbllistSubjectsObj) then tank-imp_belt-tbllistSubjectsObj = new subjects ("belt-tbl") .
              tank-imp_belt-tbllistSubjectsObj:Add(new tank-imp_belt-tbl()).
              tank-imp_belt-tblSubjectObj = cast (tank-imp_belt-tbllistSubjectsObj:SubjectObjCurr, tank-imp_belt-tbl).
              GetChildrenSub (hNoderef, (level + 1), tank-imp_belt-tblSubjectObj).
              tank-impSubjectObj:SetProp (tank-imp_belt-tbllistSubjectsObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when    "bin-ranges"
        then do : // payment-system:bins-range
          v-need-parse = true .
          if     v-need-parse
             and valid-object (payment-system-SubjectObj)
             and payment-system-SubjectObj:IsInitSubForWrite
          then do: // payment-system:bins-range
              bin-ranges-SubjectsObj = new subjects ("bin-ranges" ) .
              GetChildrenSub (hNoderef, (level + 1), ?).
              payment-system-SubjectObj:SetProp (bin-ranges-SubjectsObj).
              v-need-parse = false .
          end .
        end.
        when    "bins-tokens"
        then do : // payment-system:bins-range
          v-need-parse = true .
          if     v-need-parse
             and valid-object (payment-system-SubjectObj)
             and payment-system-SubjectObj:IsInitSubForWrite
          then do: // payment-system:bins-range
              bins-tokens-SubjectsObj = new subjects ("bins-tokens" ) .
              GetChildrenSub (hNoderef, (level + 1), ?).
              payment-system-SubjectObj:SetProp (bins-tokens-SubjectsObj).
              v-need-parse = false .
          end .
        end.
        when "bin-range" then do : // payment-system:bins-range:bin-range
          v-need-parse = true .
          if v-need-parse and valid-object (payment-system-SubjectObj)
          then do: // payment-system:bins-range
            if payment-system-SubjectObj:IsInitSubForWrite
            then do:
              if v-need-parse and valid-object (bin-ranges-SubjectsObj)
              then do :
                 // payment-system:bins-range:bin-range
                 bin-ranges-SubjectsObj:Add(  new  bin-range()  ).
                 bin-range-SubjectObj = cast (bin-ranges-SubjectsObj:SubjectObjCurr, bin-range).
                 GetChildrenSub (hNoderef, (level + 1), bin-range-SubjectObj).
                 v-need-parse = false .
              end .
            end .
          end .
        end.
        when "bin-token" then do : // payment-system:bins-range:bin-range
           v-need-parse = true .
           if     v-need-parse
              and valid-object (payment-system-SubjectObj)
              and payment-system-SubjectObj:IsInitSubForWrite
           then do: // payment-system:bins-range
              if v-need-parse and valid-object (bins-tokens-SubjectsObj)
              then do :
                 payment-system-SubjectObj:validateCodeOnly = yes.
                 // payment-system:bins-range:bin-range
                 bins-tokens-SubjectsObj:Add(  new  bin-token()  ).
                 bin-token-SubjectObj = cast (bins-tokens-SubjectsObj:SubjectObjCurr, bin-token).
                 GetChildrenSub (hNoderef, (level + 1), bin-token-SubjectObj).
                 v-need-parse = false .
              end.
           end.
        end.
        when "kb-gds" then do : // kass-book:kb-gds
          v-need-parse = true .
          if v-need-parse and valid-object (kass-bookSubjectObj) then do: // kass-book:kb-gds
            if kass-bookSubjectObj:IsInitSubForWrite then do:
              kass-book-gdListSubjectsObj = new subjects ("kb-gds") .
              GetChildrenSub (hNoderef, (level + 1), ?).
              kass-bookSubjectObj:SetProp (kass-book-gdListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (payment-agentSubjectObj) then do: // payment-agent:kb-gds
            if payment-agentSubjectObj:IsInitSubForWrite then do:
              payment-agent-gdListSubjectsObj = new subjects ("kb-gds") .
              GetChildrenSub (hNoderef, (level + 1), ?).
              payment-agentSubjectObj:SetProp (payment-agent-gdListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "kb-gd" then do:
          v-need-parse = true .
          if v-need-parse and valid-object (kass-bookSubjectObj) then do: // kass-book:kb-gds:kb-gd
            if kass-bookSubjectObj:IsInitSubForWrite then do:
              kass-book-gdListSubjectsObj:Add(  new kass-book-gd()  ).
              kass-book-gdSubjectObj = cast (kass-book-gdListSubjectsObj:SubjectObjCurr, kass-book-gd).
              GetChildrenSub (hNoderef, (level + 1), kass-book-gdSubjectObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (payment-agentSubjectObj) then do: // payment-agent:kb-gds:kb-gd
            if payment-agentSubjectObj:IsInitSubForWrite then do:
              payment-agent-gdListSubjectsObj:Add(  new kass-book-gd()  ).
              payment-agent-gdSubjectObj = cast (payment-agent-gdListSubjectsObj:SubjectObjCurr, kass-book-gd).
              GetChildrenSub (hNoderef, (level + 1), payment-agent-gdSubjectObj).
              v-need-parse = false .
            end .
          end .
        end.
        when "payment-systems":U then do:
          v-need-parse = true .
          if     v-need-parse
             and valid-object (promotionSubjectObj)
             and promotionSubjectObj:IsInitSubForWrite
          then do: // все :gd, прямо или косвенно вложенные в promotion
               payment-systems-SubjectObj = new subjects ("payment-systems") .
               GetChildrenSub (hNoderef, (level + 1), ?).
               promotionSubjectObj:SetProp (payment-systems-SubjectObj).
               v-need-parse = false .
          end.
        end.
        when "payment-system":U then do:
           v-need-parse = true .
          if     v-need-parse
             and valid-object (promotionSubjectObj)
             and promotionSubjectObj:IsInitSubForWrite
          then do: // все :gd, прямо или косвенно вложенные в promotion
                payment-systems-SubjectObj:Add(  new payment-system( )  ).
                payment-system-SubjectObj = cast (payment-systems-SubjectObj:SubjectObjCurr, payment-system).
                GetChildrenSub (hNoderef, (level + 1), payment-system-SubjectObj).
                v-need-parse = false .
          end.
        end.
        when "mark" then do:
          v-need-parse = true .
          if v-need-parse and valid-object (edi-doc-SubjectObj) then
          do: // edi-doc:gds:gd
            if edi-doc-SubjectObj:IsInitSubForWrite then
            do:
              edi-doc-mark-SubjectObj = new mark().
              edi-doc-mark-SubjectsObj:Add(  edi-doc-mark-SubjectObj  ).
              edi-doc-mark-SubjectObj:obj-load = "utd-mark".
              GetChildrenSub (hNoderef, (level + 1), edi-doc-mark-SubjectObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (trn-gdSubjectObj) then
          do:
            if trn-gdSubjectObj:IsInitSubForWrite then
            do:
              trn-mark-doc-inlistSubjectsObj:Add(new trn-mark()).
              trn-markSubjectObj = cast (trn-mark-doc-inlistSubjectsObj:SubjectObjCurr, trn-mark).
              GetChildrenSub (hNoderef, (level + 1), trn-markSubjectObj).
              trn-markSubjectObj:InitProp() .
              trn-markSubjectObj:SetProp("gds-code", string(trn-gdSubjectObj:gd-code)) .
              trn-markSubjectObj:InitProp() .
              trn-gdSubjectObj:SetProp(trn-mark-doc-inlistSubjectsObj).
              v-need-parse = false .
            end.
          end.
        end.
        when "gd" then do:
          v-need-parse = true .
          if v-need-parse and valid-object (edi-doc-SubjectObj) then do: // edi-doc:gds:gd
            if edi-doc-SubjectObj:IsInitSubForWrite then do:
              edi-doc-gd-SubjectsObj:Add(  new edi-gd()  ).
              edi-doc-gd-SubjectObj = cast (edi-doc-gd-SubjectsObj:SubjectObjCurr, edi-gd).
              GetChildrenSub (hNoderef, (level + 1), edi-doc-gd-SubjectObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (trn-gd-doc-inSubjectObj) then do: // trn-gd-doc:gds:gd
            if trn-gd-doc-inSubjectObj:IsInitSubForWrite then do:
              trn-gd-doc-inlistSubjectsObj:Add(  new trn-gd()  ).
              trn-gdSubjectObj = cast (trn-gd-doc-inlistSubjectsObj:SubjectObjCurr, trn-gd).
              GetChildrenSub (hNoderef, (level + 1), trn-gdSubjectObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (trn-fuel-doc-inSubjectObj) then do: // trn-fuel-doc:gds:gd
            if trn-fuel-doc-inSubjectObj:IsInitSubForWrite then do:
              trn-fuel-doc-inlistSubjectsObj:Add(  new trn-gd-fuel()  ).
              trn-gd-fuelSubjectObj = cast (trn-fuel-doc-inlistSubjectsObj:SubjectObjCurr, trn-gd-fuel).
              GetChildrenSub (hNoderef, (level + 1), trn-gd-fuelSubjectObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse and valid-object (promotionSubjectObj) then do: // все :gd, прямо или косвенно вложенные в promotion
            if promotionSubjectObj:IsInitSubForWrite then do :
              if v-need-parse and valid-object (promotion_psSubjectObj) then do : // promotion:promoset:ps-sections:ps-section:gds:gd
                if promotion_psSubjectObj:IsInitSubForWrite then do:
                  promotion_p_gdListSubjectsObj:Add(  new promotion_gd()  ).
                  promotion_p_gdSubjectObj = cast (promotion_p_gdListSubjectsObj:SubjectObjCurr, promotion_gd).
                  GetChildrenSub (hNoderef, (level + 1), promotion_p_gdSubjectObj).
                  v-need-parse = false .
                end.
              end .
              if v-need-parse and valid-object (promotion_thresholdSubjectObj) then do : // promotion:thresholds:threshold:gifts:gd
                if promotion_thresholdSubjectObj:IsInitSubForWrite then do:
                  promotion_t_giftListSubjectsObj:Add(  new promotion_gift-gd()  ).
                  promotion_t_giftSubjectObj = cast (promotion_t_giftListSubjectsObj:SubjectObjCurr, promotion_gift-gd).
                  GetChildrenSub (hNoderef, (level + 1), promotion_t_giftSubjectObj).
                  v-need-parse = false .
                end.
              end .
              if v-need-parse then do :
                v-need-parse = false .
                case hParent:name :
                // один блок обработки на три коллекции:
                // родительский объект разложит их по местам внутри promotion:SetProp
                when "gds" then do: // promotion:gds:gd
                  promotion_gdsListSubjectsObj:Add(  new promotion_gds-gd()  ).
                  promotion_gdsSubjectObj = cast (promotion_gdsListSubjectsObj:SubjectObjCurr, promotion_gds-gd).
                  GetChildrenSub (hNoderef, (level + 1), promotion_gdsSubjectObj).
                end .
                when "gds-addcond" then do: // promotion:gds-addcond:gd
                  promotion_gdListSubjectsObj:Add(  new promotion_gd()  ).
                  promotion_gdSubjectObj = cast (promotion_gdListSubjectsObj:SubjectObjCurr, promotion_gd).
                  GetChildrenSub (hNoderef, (level + 1), promotion_gdSubjectObj).
                end .
                when "gifts" then do: // promotion:gifts:gd
                  promotion_giftListSubjectsObj:Add(  new promotion_gift-gd()  ).
                  promotion_giftSubjectObj = cast (promotion_giftListSubjectsObj:SubjectObjCurr, promotion_gift-gd).
                  GetChildrenSub (hNoderef, (level + 1), promotion_giftSubjectObj).
                end .
                otherwise v-need-parse = true .
                end case .
              end .
            end .
          end .
        end.
        when "prt" then do:
          if trn-gdSubjectObj:IsInitSubForWrite
          then do:
            if not valid-object(trn-prt-doc-inlistSubjectsObj) then trn-prt-doc-inlistSubjectsObj = new subjects ("prts") .
            trn-prt-doc-inlistSubjectsObj:Add(new trn-prt()).
            trn-prtSubjectObj = cast (trn-prt-doc-inlistSubjectsObj:SubjectObjCurr, trn-prt).
            GetChildrenSub (hNoderef, (level + 1), trn-prtSubjectObj).
            trn-prtSubjectObj:InitProp() .
            trn-prtSubjectObj:SetProp("gds-code", string(trn-gdSubjectObj:gd-code)) .
            trn-prtSubjectObj:InitProp() .
            trn-gdSubjectObj:SetProp (trn-prt-doc-inlistSubjectsObj).
          end.
          else
          if trn-gd-doc-inSubjectObj:IsInitSubForWrite
          then do:
            if not valid-object(trn-prt-doc-inlistSubjectsObj) then trn-prt-doc-inlistSubjectsObj = new subjects ("prts") .
            trn-prt-doc-inlistSubjectsObj:Add(new trn-prt()).
            trn-prtSubjectObj = cast (trn-prt-doc-inlistSubjectsObj:SubjectObjCurr, trn-prt).
            GetChildrenSub (hNoderef, (level + 1), trn-prtSubjectObj).
            trn-gd-doc-inSubjectObj:SetProp (trn-prt-doc-inlistSubjectsObj).
          end.
        end.
        when "nb-carrier" then do:
          case true :
            when clientsSubjectObj:IsInitSubForWrite then do:
              if not valid-object(clients_carriersListSubjectObj) then clients_carriersListSubjectObj = new subjects ("nb-carriers") .
              clients_carriersListSubjectObj:Add(new clients_carriers()).
              clients_carriersSubjectObj = cast (clients_carriersListSubjectObj:SubjectObjCurr, clients_carriers).
              GetChildrenSub (hNoderef, (level + 1), clients_carriersSubjectObj).
              clientsSubjectObj:SetProp (clients_carriersListSubjectObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when "nb-supplier" then do:
          case true :
            when clientsSubjectObj:IsInitSubForWrite then do:
              if not valid-object(clients_suppliersListSubjectObj) then clients_suppliersListSubjectObj = new subjects ("nb-suppliers") .
              clients_suppliersListSubjectObj:Add(new clients_suppliers()).
              clients_suppliersSubjectObj = cast (clients_suppliersListSubjectObj:SubjectObjCurr, clients_suppliers).
              GetChildrenSub (hNoderef, (level + 1), clients_suppliersSubjectObj).
              clientsSubjectObj:SetProp (clients_suppliersListSubjectObj).
            end.
            otherwise do:
            end.
          end case.
        end.
        when "unit-add-codes" then do :
          v-need-parse = true .
          if v-need-parse and valid-object (goodSubjectObj) then do : // goods:good:unit-add-codes
            if goodSubjectObj:IsInitSubForWrite then do:
              unitaddsSubjectsObj = new subjects ("unit-add-codes") .
                 GetChildrenSub (hNoderef, (level + 1), ?).
              goodSubjectObj:SetProp (unitaddsSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "unit-add-code" then do: // goods:good:unit-add-codes:unit-add-code
            if not valid-object(unitaddsSubjectsObj) then
              undo, throw new Progress.Lang.AppError("отсутствует секция unit-add-codes для перечня unit-add-code") .
            unitaddsSubjectsObj:Add(  new unit-add-code()  ).
            good_unitaddSubjectObj = cast (unitaddsSubjectsObj:SubjectObjCurr, unit-add-code).
            GetChildrenSub (hNoderef, (level + 1), good_unitaddSubjectObj).
        end.
        when "order-goods" then do :
          v-need-parse = true .
          if v-need-parse and valid-object (ordrspSubjectObj) then do:
            if ordrspSubjectObj:IsInitSubForWrite then do:
              order-goodListSubjectsObj = new subjects ("order-good") .
              GetChildrenSub (hNoderef, (level + 1), ?).
              ordrspSubjectObj:SetProp (order-goodListSubjectsObj).
              v-need-parse = false .
            end .
          end .
          if v-need-parse then GetChildrenSub (hNoderef, (level + 1), ?).
        end.
        when "order-good" then do:
          v-need-parse = true .
          if v-need-parse and valid-object (ordrspSubjectObj) then do:
            if ordrspSubjectObj:IsInitSubForWrite then do:
              order-goodListSubjectsObj:Add(  new order-good()  ).
              order-goodSubjectObj = cast (order-goodListSubjectsObj:SubjectObjCurr, order-good).
              GetChildrenSub (hNoderef, (level + 1), order-goodSubjectObj).
              v-need-parse = false .
            end .
          end .
        end.
        otherwise do:
          if valid-object(subjectObj)
          then do :
            subjectObj:SetProp( hNoderef:name, hText:node-value) no-error .
            if error-status:error
            then do :
              hText:node-value-to-longchar(v-longchar) .
              subjectObj:SetProp( hNoderef:name, v-longchar) .
            end .
          end .
        end.
      end case.
    end.
    if valid-object (subjectObj)
      then subjectObj:SetProp( hParent:name, "").
    finally :
      delete object hNoderef no-error.
       if valid-object(hText) then delete object hText.
    end finally .
  end method.
        destructor public parsesub ( ):
        end destructor.
end class.
