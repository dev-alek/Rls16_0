&glob abc-analysis_primary_key abc-id db-num 
&glob abc-analysis-attr_primary_key abc-id db-num abca-attr-code 
&glob abc-analysis-cli_primary_key abc-id db-num cli-type cli-code 
&glob abc-analysis-cli-attr_primary_key abc-id db-num cli-type cli-code attr-code 
&glob abc-analysis-doc_primary_key abc-id db-num abcd-ext-doc-type 
&glob abc-analysis-doc-attr_primary_key abc-id db-num abcd-ext-doc-type attr-code 
&glob abc-analysis-gds-obj_primary_key abc-id db-num gds-code obj-type obj-code 
&glob abc-analysis-gds-obj-attr_primary_key abc-id db-num gds-code obj-type obj-code aaog-attr-code 
&glob abc-analysis-goods_primary_key abc-id db-num gds-code 
&glob abc-analysis-goods-attr_primary_key abc-id db-num gds-code abag-attr-code 
&glob abc-analysis-grp_primary_key abc-id db-num grp-code 
&glob abc-analysis-grp-attr_primary_key abc-id db-num grp-code attr-code 
&glob abc-analysis-obj_primary_key abc-id db-num obj-type obj-code 
&glob abc-analysis-obj-attr_primary_key abc-id db-num obj-type obj-code attr-code 
&glob abc-analysis-period_primary_key abc-id db-num abcp-start abcp-end 
&glob abc-analysis-period-attr_primary_key abc-id db-num abcp-start abcp-end attr-code 
&glob abc-analysis-prod_primary_key abc-id db-num prod-type prod-code 
&glob abc-analysis-prod-attr_primary_key abc-id db-num prod-type prod-code attr-code 
&glob abcxyz-analysis_primary_key abcx-id db-num 
&glob abcxyz-analysis-attr_primary_key abcx-id db-num axa-attr-code 
&glob abcxyz-analysis-goods_primary_key abcx-id db-num gds-code 
&glob abcxyz-analysis-goods-attr_primary_key abcx-id db-num gds-code agda-attr-code 
&glob action-group_primary_key action-head-code action-group-code 
&glob action-group-attr_primary_key action-head-code action-group-code attr-code 
&glob action-head_primary_key action-head-code 
&glob action-head-attr_primary_key action-head-code attr-code 
&glob action-item_primary_key action-head-code action-item-code 
&glob action-item-attr_primary_key action-head-code action-item-code attr-code 
&glob action-post_primary_key db-num action-head-code action-post-code 
&glob action-post-attr_primary_key db-num action-head-code action-post-code attr-code 
&glob action-post-host_primary_key db-num action-head-code action-post-code host-code 
&glob action-post-host-attr_primary_key db-num action-head-code action-post-code host-code attr-code 
&glob action-post-menu-group_primary_key db-num action-head-code action-post-code action-post-menu-group-code 
&glob action-post-menu-group-attr_primary_key db-num action-head-code action-post-code action-post-menu-group-code attr-code 
&glob action-post-obj_primary_key db-num action-head-code action-post-code obj-type obj-code 
&glob action-post-obj-attr_primary_key db-num action-head-code action-post-code obj-type obj-code attr-code 
&glob action-post-role_primary_key db-num action-head-code action-post-role-code 
&glob action-post-role-attr_primary_key db-num action-head-code action-post-role-code attr-code 
&glob action-post-user-login_primary_key db-num action-head-code action-post-code user-id 
&glob action-post-user-login-attr_primary_key db-num action-head-code action-post-code user-id attr-code 
&glob action-role_primary_key db-num action-head-code action-role-code 
&glob action-role-attr_primary_key db-num action-head-code action-role-code attr-code 
&glob action-role-item_primary_key db-num action-head-code action-role-code action-role-item-code 
&glob action-role-item-attr_primary_key db-num action-head-code action-role-code action-role-item-code attr-code 
&glob action-role-item-gds_primary_key db-num action-head-code action-role-code action-role-item-code gds-code 
&glob action-role-item-gds-grp_primary_key db-num action-head-code action-role-code action-role-item-code gds-grp-code 
&glob add-doc_primary_key doc-code 
&glob add-line_primary_key doc-code gds-code cli-type cli-code host-code contract-code 
&glob add-trn_primary_key doc-code trn-doc-code 
&glob add-trn-attr_primary_key doc-code trn-doc-code attr-code 
&glob aht-doc_primary_key doc-code 
&glob aht-doc-attr_primary_key doc-code attr-code 
&glob aht-gds_primary_key aht-time-code gds-code sum-type 
&glob aht-gds-attr_primary_key aht-time-code gds-code sum-type attr-code 
&glob aht-ot-line_primary_key doc-code gds-code sum-type 
&glob aht-ot-line-attr_primary_key doc-code gds-code sum-type attr-code 
&glob aht-ot-tot_primary_key doc-code sum-type 
&glob aht-ot-tot-attr_primary_key doc-code sum-type attr-code 
&glob aht-stk_primary_key obj-type obj-code stk-type fact-order 
&glob aht-stk-attr_primary_key obj-type obj-code stk-type fact-order attr-code 
&glob aht-stk-line_primary_key obj-type obj-code gds-code fact-order sum-type 
&glob aht-stk-line-attr_primary_key obj-type obj-code gds-code fact-order sum-type attr-code 
&glob aht-stk-tot_primary_key obj-type obj-code fact-order sum-type 
&glob aht-stk-tot-attr_primary_key obj-type obj-code fact-order sum-type attr-code 
&glob aht-time_primary_key aht-time-code 
&glob aht-time-attr_primary_key aht-time-code attr-code 
&glob alc-sale-lic_primary_key alc-sale-lic-code create-user-db-num 
&glob alc-sale-lic-attr_primary_key alc-sale-lic-code create-user-db-num attr-code 
&glob alc-sale-lic-type_primary_key alc-sale-lic-code create-user-db-num alc-type-inner-code create-alc-type-user-db-num 
&glob alc-sale-lic-type-attr_primary_key alc-sale-lic-code create-user-db-num alc-type-inner-code create-alc-type-user-db-num attr-code 
&glob alc-supp-lic_primary_key alc-supp-lic-code create-user-db-num 
&glob alc-supp-lic-attr_primary_key alc-supp-lic-code create-user-db-num attr-code 
&glob alc-supp-lic-type_primary_key alc-supp-lic-code create-user-db-num alc-type-inner-code create-alc-type-user-db-num 
&glob alc-supp-lic-type-attr_primary_key alc-supp-lic-code create-user-db-num alc-type-inner-code create-alc-type-user-db-num attr-code 
&glob alc-type_primary_key alc-type-inner-code create-user-db-num 
&glob alc-type-attr_primary_key alc-type-inner-code create-user-db-num attr-code 
&glob alc-type-gds_primary_key alc-type-inner-code create-user-db-num gds-code 
&glob alc-type-gds-attr_primary_key alc-type-inner-code create-user-db-num gds-code attr-code 
&glob archive-history_primary_key obj-type obj-code archive-type chip-num 
&glob archive-history-attr_primary_key obj-type obj-code archive-type chip-num attr-code 
&glob arh-fin-doc-an_primary_key host-code cli-type cli-code code-schet fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order 
&glob arh-fin-doc-an-attr_primary_key host-code cli-type cli-code code-schet fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-an-nal_primary_key host-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order 
&glob arh-fin-doc-an-nal-attr_primary_key host-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-an-nal-obj_primary_key host-code obj-type obj-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order 
&glob arh-fin-doc-an-nal-obj-attr_primary_key host-code obj-type obj-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-an-obj_primary_key host-code obj-type obj-code cli-type cli-code code-schet fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order 
&glob arh-fin-doc-an-obj-attr_primary_key host-code obj-type obj-code cli-type cli-code code-schet fin-ext-doc-type fin-code-an-uchet fin-code-cel-nazn fin-code-cor-acc calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-c-s-tax-nal-obj_primary_key host-code obj-type obj-code contract-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-c-schet-tax-nal_primary_key host-code contract-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-contr-s-nal-obj_primary_key host-code obj-type obj-code contract-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-contr-s-tax-obj_primary_key host-code obj-type obj-code contract-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-contr-schet_primary_key host-code contract-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-contr-schet-attr_primary_key host-code contract-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-contr-schet-nal_primary_key host-code contract-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-contr-schet-obj_primary_key host-code obj-type obj-code contract-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-contr-schet-tax_primary_key host-code contract-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-s-tax-nal-obj_primary_key host-code obj-type obj-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-schet_primary_key host-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-schet-attr_primary_key host-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-schet-nal_primary_key host-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-schet-nal-attr_primary_key host-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-schet-nal-obj_primary_key host-code obj-type obj-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-schet-obj_primary_key host-code obj-type obj-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-doc-schet-obj-attr_primary_key host-code obj-type obj-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-doc-schet-tax_primary_key host-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-schet-tax-attr_primary_key host-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order attr-code 
&glob arh-fin-doc-schet-tax-nal_primary_key host-code cli-type cli-code fin-code-acc curr-code fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-doc-schet-tax-obj_primary_key host-code obj-type obj-code cli-type cli-code code-schet fin-ext-doc-type calc-curr-code VAT-pc SLT-pc with-vat with-slt sum-type fact-order 
&glob arh-fin-ob-contr_primary_key host-code contract-code cli-type cli-code fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-ob-contr-attr_primary_key host-code contract-code cli-type cli-code fin-ext-doc-type calc-curr-code sum-type fact-order attr-code 
&glob arh-fin-ob-contr-obj_primary_key host-code obj-type obj-code contract-code cli-type cli-code fin-ext-doc-type calc-curr-code sum-type fact-order 
&glob arh-fin-ob-contr-obj-attr_primary_key host-code obj-type obj-code contract-code cli-type cli-code fin-ext-doc-type calc-curr-code sum-type fact-order attr-code 
&glob arh-trn-doc-contract_primary_key host-code contract-code cli-type cli-code obj-type obj-code ext-doc-type sum-type fact-order 
&glob arh-trn-doc-contract-attr_primary_key host-code contract-code cli-type cli-code obj-type obj-code ext-doc-type sum-type fact-order attr-code 
&glob arh-wth-cli_primary_key cli-type cli-code ext-doc-type wth-code par-code ser-code db-num gds-code obj-type obj-code sum-type fact-order 
&glob arh-wth-cli-attr_primary_key cli-type cli-code ext-doc-type wth-code par-code ser-code db-num gds-code obj-type obj-code sum-type fact-order attr-code 
&glob arh-wth-cli-doc_primary_key cli-type cli-code wth-code par-code host-code contract-code gds-code obj-type obj-code w-p-code ext-doc-type sum-type fact-order 
&glob arh-wth-cli-doc-attr_primary_key cli-type cli-code wth-code par-code host-code contract-code gds-code obj-type obj-code w-p-code ext-doc-type sum-type fact-order attr-code 
&glob arh-wth-cli-tot_primary_key cli-type cli-code obj-type obj-code ext-doc-type sum-type fact-order 
&glob arh-wth-cli-tot-attr_primary_key cli-type cli-code obj-type obj-code ext-doc-type sum-type fact-order attr-code 
&glob arh-wth-tot_primary_key obj-type obj-code wth-code par-code ext-doc-type sum-type fact-order 
&glob arh-wth-tot-attr_primary_key obj-type obj-code wth-code par-code ext-doc-type sum-type fact-order attr-code 
&glob arh-wth-w-p_primary_key obj-type obj-code w-p-code wth-code par-code out-code sum-type fact-order 
&glob arh-wth-w-p-attr_primary_key obj-type obj-code w-p-code wth-code par-code out-code sum-type fact-order attr-code 
&glob assortment-matrix_primary_key asmt-id db-num 
&glob assortment-matrix-attr_primary_key asmt-id db-num attr-code 
&glob assortment-matrix-goods_primary_key asmt-id db-num gds-code 
&glob assortment-matrix-goods-attr_primary_key asmt-id db-num gds-code attr-code 
&glob attr-prop_primary_key table-name templ-rl-root node-code 
&glob auto-section_primary_key auto-num section-num 
&glob auto-section-attr_primary_key auto-num section-num attr-code 
&glob auto-section-table_primary_key auto-num section-num error 
&glob auto-tank_primary_key auto-num 
&glob auto-tank-attr_primary_key auto-num attr-code 
&glob auto-tank-meas_primary_key auto-num meas-label 
&glob auto-tank-meas-attr_primary_key auto-num meas-label attr-code 
&glob bar-code_primary_key b-code 
&glob bar-code-attr_primary_key b-code attr-code 
&glob bar-code-obj-attr_primary_key obj-type obj-code b-code attr-code 
&glob BatchProcess_primary_key BatchProcess# 
&glob blob-bind_primary_key uniq-key-rec field-name_ part-num 
&glob blob-data_primary_key db-num int64-id 
&glob buyer-group_primary_key bgr-id bgr-db-num 
&glob buyer-group-attr_primary_key bgr-id bgr-db-num attr-code 
&glob buyer-in-buyer-group_primary_key bgr-id bgr-db-num bbg-obj-type bbg-obj-code 
&glob buyer-in-buyer-group-attr_primary_key bgr-id bgr-db-num bbg-obj-type bbg-obj-code attr-code 
&glob c-action-role_primary_key db-num action-head-code action-role-code corr-user-db-num chip-num 
&glob c-action-role-item_primary_key db-num action-head-code action-role-code action-role-item-code corr-user-db-num chip-num 
&glob c-add-doc_primary_key doc-code corr-user-db-num chip-num 
&glob c-add-line_primary_key doc-code gds-code cli-type cli-code host-code contract-code corr-user-db-num chip-num 
&glob c-alc-sale-lic_primary_key alc-sale-lic-code create-user-db-num corr-user-db-num chip-num 
&glob c-alc-sale-lic-attr_primary_key alc-sale-lic-code create-user-db-num attr-code corr-user-db-num chip-num 
&glob c-alc-sale-lic-type_primary_key alc-sale-lic-code create-user-db-num alc-type-inner-code create-alc-type-user-db-num corr-user-db-num chip-num 
&glob c-alc-supp-lic_primary_key alc-supp-lic-code create-user-db-num corr-user-db-num chip-num 
&glob c-alc-supp-lic-attr_primary_key alc-supp-lic-code create-user-db-num attr-code corr-user-db-num chip-num 
&glob c-alc-supp-lic-type_primary_key alc-supp-lic-code create-user-db-num alc-type-inner-code create-alc-type-user-db-num corr-user-db-num chip-num 
&glob c-alc-type_primary_key alc-type-inner-code create-user-db-num corr-user-db-num chip-num 
&glob c-alc-type-attr_primary_key alc-type-inner-code create-user-db-num attr-code corr-user-db-num chip-num 
&glob c-alc-type-gds_primary_key alc-type-inner-code create-user-db-num gds-code corr-user-db-num chip-num 
&glob c-assortment-matrix_primary_key asmt-id db-num corr-user-db-num chip-num 
&glob c-assortment-matrix-goods_primary_key asmt-id db-num gds-code corr-user-db-num chip-num 
&glob c-auto-section_primary_key auto-num section-num corr-user-db-num chip-num 
&glob c-auto-section-attr_primary_key auto-num section-num attr-code corr-user-db-num chip-num 
&glob c-auto-section-table_primary_key auto-num section-num error corr-user-db-num chip-num 
&glob c-auto-tank_primary_key auto-num corr-user-db-num chip-num 
&glob c-auto-tank-attr_primary_key auto-num attr-code corr-user-db-num chip-num 
&glob c-auto-tank-meas-attr_primary_key auto-num meas-label attr-code corr-user-db-num chip-num 
&glob c-bar-code_primary_key b-code corr-user-db-num chip-num 
&glob c-bar-code-attr_primary_key b-code attr-code corr-user-db-num chip-num 
&glob c-bar-code-obj-attr_primary_key obj-type obj-code b-code attr-code corr-user-db-num chip-num 
&glob c-buyer-group_primary_key bgr-id bgr-db-num corr-user-db-num chip-num 
&glob c-buyer-in-buyer-group_primary_key bgr-id bgr-db-num bbg-obj-type bbg-obj-code corr-user-db-num chip-num 
&glob c-cash-desk_primary_key db-num obj-code pos-type cash-num corr-user-db-num chip-num 
&glob c-cash-desk-attr_primary_key db-num obj-code pos-type cash-num upper-attr-code attr-code corr-user-db-num chip-num 
&glob c-cash-pay_primary_key cdpay-code curr-code corr-user-db-num chip-num 
&glob c-cash-pay-attr_primary_key cdpay-code curr-code host-code obj-type obj-code attr-code corr-user-db-num chip-num 
&glob c-CashBook_primary_key id corr-user-db-num chip-num 
&glob c-cashbook-head_primary_key id corr-user-db-num chip-num subject 
&glob c-CashBookAttr_primary_key id attr-code corr-user-db-num chip-num 
&glob c-CashBookRule_primary_key CashBookID Obj-type Obj-code Code corr-user-db-num chip-num 
&glob c-CashBookRuleAttr_primary_key cashbookid obj-type obj-code code attr-code corr-user-db-num chip-num 
&glob c-cbr-bank_primary_key bic corr-user-db-num chip-num 
&glob c-cbr-bank-attr_primary_key bic attr-code corr-user-db-num chip-num 
&glob c-cd-clu_primary_key obj-type obj-code pos-type clu-type CLU-code corr-user-db-num chip-num 
&glob c-cd-dlu_primary_key obj-type obj-code pos-type dlu-type DLU-code corr-user-db-num chip-num 
&glob c-cd-doc_primary_key obj-type obj-code pos-type doc-type doc-code corr-user-db-num chip-num 
&glob c-cd-doc-line_primary_key obj-type obj-code pos-type doc-type doc-code line-num corr-user-db-num chip-num 
&glob c-cd-grp_primary_key obj-type obj-code pos-type grp-type grp-code corr-user-db-num chip-num 
&glob c-cd-plu_primary_key obj-type obj-code pos-type plu-type PLU-code corr-user-db-num chip-num 
&glob c-chk-discnt_primary_key doc-code record-type line-num discnt-id object-line-num corr-user-db-num chip-num 
&glob c-chk-doc_primary_key doc-code corr-user-db-num chip-num 
&glob c-chk-doc-attr_primary_key doc-code attr-code corr-user-db-num chip-num 
&glob c-chk-gds_primary_key doc-code line-num corr-user-db-num chip-num 
&glob c-chk-pay_primary_key doc-code line-num corr-user-db-num chip-num 
&glob c-cli-grp_primary_key node-code corr-user-db-num chip-num 
&glob c-cli-grp-attr_primary_key node-code attr-code corr-user-db-num chip-num 
&glob c-cli-hist_primary_key obj-type obj-code corr-user-db-num chip-num host-code subject 
&glob c-clients_primary_key obj-type obj-code corr-user-db-num chip-num 
&glob c-clients-attr_primary_key obj-type obj-code attr-code corr-user-db-num chip-num 
&glob c-Code_primary_key parent code corr-user-db-num chip-num 
&glob c-condition-keeping_primary_key cond-keep-code corr-user-db-num chip-num 
&glob c-condition-keeping-attr_primary_key cond-keep-code attr-code corr-user-db-num chip-num 
&glob c-config_primary_key param-code host-code obj-type obj-code beg-date end-date db-num corr-user-db-num chip-num 
&glob c-contract_primary_key host-code contract-code corr-user-db-num chip-num 
&glob c-contract-line_primary_key host-code contract-num line-num sub-line-num corr-user-db-num chip-num 
&glob c-contract-specif_primary_key host-code contract-num gds-code corr-user-db-num chip-num 
&glob c-contract-specif-attr_primary_key host-code contract-num gds-code attr-code corr-user-db-num chip-num 
&glob c-counter_primary_key db file-name key code corr-user-db-num chip-num 
&glob c-country_primary_key num-code corr-user-db-num chip-num 
&glob c-country-attr_primary_key num-code attr-code corr-user-db-num chip-num 
&glob c-curr-accnt_primary_key curr-code exch-date corr-user-db-num chip-num 
&glob c-curr-bank_primary_key curr-code exch-date corr-user-db-num chip-num 
&glob c-currency_primary_key curr-code corr-user-db-num chip-num 
&glob c-currency-attr_primary_key curr-code attr-code corr-user-db-num chip-num 
&glob c-db_primary_key db-num corr-user-db-num chip-num 
&glob c-db-grp-obj-price_primary_key gop-id gop-db-num dgo-db-num corr-user-db-num chip-num 
&glob c-dc-hist_primary_key d-card corr-user-db-num chip-num host-code obj-type obj-code subject 
&glob c-deliv-type-cond-keep_primary_key deliv-type-code cond-keep-code corr-user-db-num chip-num 
&glob c-deliv-type-cond-keep-attr_primary_key deliv-type-code cond-keep-code attr-code corr-user-db-num chip-num 
&glob c-delivery-subject_primary_key deliv-subj-code corr-user-db-num chip-num 
&glob c-delivery-subject-attr_primary_key deliv-subj-code attr-code corr-user-db-num chip-num 
&glob c-delivery-type_primary_key deliv-type-code corr-user-db-num chip-num 
&glob c-delivery-type-attr_primary_key deliv-type-code attr-code corr-user-db-num chip-num 
&glob c-delivery-type-subject_primary_key deliv-type-code deliv-subj-code corr-user-db-num chip-num 
&glob c-delivery-type-subject-attr_primary_key deliv-type-code deliv-subj-code attr-code corr-user-db-num chip-num 
&glob c-dis-card_primary_key d-card corr-user-db-num chip-num 
&glob c-dis-card-long_primary_key d-card card-media long-d-card corr-user-db-num chip-num 
&glob c-dis-card-long-attr_primary_key d-card card-media long-d-card attr-code corr-user-db-num chip-num 
&glob c-dis-card-mask_primary_key mask-num corr-user-db-num chip-num 
&glob c-dis-card-mask-attr_primary_key mask-num attr-code corr-user-db-num chip-num 
&glob c-dis-card-property_primary_key d-card dt-code node-code host-code obj-type obj-code corr-user-db-num chip-num 
&glob c-dis-card-type_primary_key emitent-host-code type host-code obj-type obj-code corr-user-db-num chip-num 
&glob c-dis-card-type-attr_primary_key emitent-host-code type host-code obj-type obj-code attr-code corr-user-db-num chip-num 
&glob c-dis-cfg-rule_primary_key table-name pos-type templ-rl-root time-templ-rl-root self-nonunique corr-user-db-num chip-num 
&glob c-dis-cp-rule_primary_key cdpay-code curr-code host-code obj-type obj-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-dc-rule_primary_key d-card host-code obj-type obj-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-dct-rule_primary_key emitent-host-code type host-code obj-type obj-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-gds-rule_primary_key obj-type obj-code gds-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-grp-rule_primary_key classif-type node-code host-code obj-type obj-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-host_primary_key d-card dt-code host-code corr-user-db-num chip-num 
&glob c-dis-obj_primary_key d-card dt-code obj-type obj-code corr-user-db-num chip-num 
&glob c-dis-rule_primary_key rule-num corr-user-db-num chip-num 
&glob c-dis-rule-attr_primary_key rule-num attr-code corr-user-db-num chip-num 
&glob c-dis-some-rule_primary_key classif-type resource#_id host-code obj-type obj-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-thbj-rule_primary_key host-code obj-type obj-code pos-type discnt-role nonunique corr-user-db-num chip-num 
&glob c-dis-time-rule_primary_key time-rule-num corr-user-db-num chip-num 
&glob c-doc-attr_primary_key doc-code attr-code corr-user-db-num chip-num 
&glob c-doc-fbr-gds_primary_key obj-type obj-code fbr-obj-type fbr-obj-code out-code gds-code corr-user-db-num chip-num 
&glob c-doc-line_primary_key doc-code artic prod-type prod-code line-num corr-user-db-num chip-num 
&glob c-doc-line-attr_primary_key doc-code gds-code attr-code corr-user-db-num chip-num 
&glob c-doc-line-sum_primary_key doc-code gds-code sum-type corr-user-db-num chip-num 
&glob c-doc-pl_primary_key obj-type obj-code pl-code out-code gds-code corr-user-db-num chip-num 
&glob c-doc-pl-pump_primary_key obj-type obj-code pl-code pump-code out-code gds-code corr-user-db-num chip-num 
&glob c-doc-prts_primary_key out-code b-code corr-user-db-num chip-num 
&glob c-drt-prop_primary_key templ-rl-root node-code corr-user-db-num chip-num 
&glob c-egais-clients_primary_key supp-id corr-user-db-num chip-num 
&glob c-egais-gds_primary_key alpr-id corr-user-db-num chip-num 
&glob c-esys-datatype-exp_primary_key esys-id db-num dte-id corr-user-db-num chip-num 
&glob c-esys-datatype-imp_primary_key esys-id db-num tdi-id corr-user-db-num chip-num 
&glob c-ex-mark_primary_key db-num mark-code corr-user-db-num chip-num 
&glob c-ext-artic_primary_key cli-type cli-code gds-code corr-user-db-num chip-num 
&glob c-ext-artic-attr_primary_key cli-type cli-code gds-code attr-code corr-user-db-num chip-num 
&glob c-ext-classif_primary_key classif-subject classif-name db-num Key#_One Key#_Two Key#_Three CharKey_One CharKey_Two CharKey_Three nonunique corr-user-db-num chip-num 
&glob c-ext-system_primary_key esys-id db-num corr-user-db-num chip-num 
&glob c-fbr-doc_primary_key doc-code corr-user-db-num chip-num 
&glob c-fbr-gds-grp_primary_key obj-type obj-code node-code corr-user-db-num chip-num 
&glob c-fbr-gds-grp-attr_primary_key obj-type obj-code node-code attr-code corr-user-db-num chip-num 
&glob c-fbr-gds-grp-hist_primary_key obj-type obj-code node-code corr-user-db-num chip-num subject 
&glob c-fbr-gds-obj_primary_key obj-type obj-code gds-code corr-user-db-num chip-num 
&glob c-fbr-gds-obj-attr_primary_key obj-type obj-code gds-code attr-code corr-user-db-num chip-num 
&glob c-fbr-line_primary_key doc-code trn-type recipe-code artic prod-type prod-code corr-user-db-num chip-num 
&glob c-fbr-pln_primary_key doc-code corr-user-db-num chip-num 
&glob c-fbr-pln-line_primary_key doc-code fbr-obj-type fbr-obj-code gds-code recipe-code corr-user-db-num chip-num 
&glob c-fbr-prn_primary_key db-num prn-num corr-user-db-num chip-num 
&glob c-fbr-prn-gds_primary_key db-num prn-num obj-type obj-code gds-code corr-user-db-num chip-num 
&glob c-fbr-prn-grp_primary_key db-num prn-num obj-type obj-code node-code corr-user-db-num chip-num 
&glob c-fin-bank_primary_key host-code code-bank corr-user-db-num chip-num 
&glob c-fin-bank-attr_primary_key host-code code-bank attr-code corr-user-db-num chip-num 
&glob c-fin-code-an-uchet_primary_key host-code fin-code corr-user-db-num chip-num 
&glob c-fin-code-cel-nazn_primary_key host-code fin-code corr-user-db-num chip-num 
&glob c-fin-code-cor-acc_primary_key host-code fin-code corr-user-db-num chip-num 
&glob c-fin-connect_primary_key host-code connect-code corr-user-db-num chip-num 
&glob c-fin-doc_primary_key host-code fin-doc-code corr-user-db-num chip-num 
&glob c-fin-doc-attr_primary_key host-code fin-doc-code attr-code corr-user-db-num chip-num 
&glob c-fin-doc-tax_primary_key host-code fin-doc-code line-num corr-user-db-num chip-num 
&glob c-fin-gds-part_primary_key host-code fin-ob-code obj-type obj-code gds-code in-code out-code part-code prt-code doc-type corr-user-db-num chip-num 
&glob c-fin-ob_primary_key host-code doc-code corr-user-db-num chip-num 
&glob c-fin-ob-attr_primary_key host-code doc-code attr-code corr-user-db-num chip-num 
&glob c-fin-ob-tax_primary_key host-code doc-code line-num corr-user-db-num chip-num 
&glob c-fin-schet_primary_key host-code code-schet corr-user-db-num chip-num 
&glob c-fin-schet-attr_primary_key host-code code-schet attr-code corr-user-db-num chip-num 
&glob c-fin-statement_primary_key host-code sttm-code corr-user-db-num chip-num 
&glob c-fin-statement-attr_primary_key host-code sttm-code attr-code corr-user-db-num chip-num 
&glob c-fin-statement-line_primary_key host-code sttm-code line-num corr-user-db-num chip-num 
&glob c-firm_primary_key firm-code corr-user-db-num chip-num 
&glob c-gds-add-charges_primary_key gds-code corr-user-db-num chip-num 
&glob c-gds-add-charges-attr_primary_key gds-code attr-code corr-user-db-num chip-num 
&glob c-gds-dtl_primary_key doc-code artic prod-code prod-type prt-code corr-user-db-num chip-num 
&glob c-gds-dtl-attr_primary_key doc-code artic prod-code prod-type prt-code attr-code corr-user-db-num chip-num 
&glob c-gds-grp_primary_key node-code corr-user-db-num chip-num 
&glob c-gds-grp-attr_primary_key node-code attr-code host-code obj-type obj-code corr-user-db-num chip-num 
&glob c-gds-grp-hist_primary_key node-code corr-user-db-num chip-num host-code obj-type obj-code subject 
&glob c-gds-grp-obj_primary_key node-code host-code obj-type obj-code corr-user-db-num chip-num 
&glob c-gds-hist_primary_key gds-code corr-user-db-num chip-num host-code obj-type obj-code subject 
&glob c-gds-host-attr_primary_key host-code gds-code attr-code corr-user-db-num chip-num 
&glob c-gds-mercury_primary_key ID db-num corr-user-db-num chip-num 
&glob c-gds-obj_primary_key obj-type obj-code gds-code chip-num 
&glob c-gds-obj-attr_primary_key obj-type obj-code gds-code attr-code corr-user-db-num chip-num 
&glob c-gds-obj-prop_primary_key obj-type obj-code gds-code corr-user-db-num chip-num 
&glob c-gds-obj-ref_primary_key obj-type obj-code gds-code corr-user-db-num chip-num 
&glob c-gds-prt_primary_key node-code corr-user-db-num chip-num 
&glob c-gds-prt-attr_primary_key node-code attr-code corr-user-db-num chip-num 
&glob c-gds-season_primary_key sea-code db-num gds-code corr-user-db-num chip-num 
&glob c-global-state_primary_key gls-id corr-user-db-num chip-num 
&glob c-global-state-attr_primary_key gls-id attr-code corr-user-db-num chip-num 
&glob c-goods_primary_key gds-code corr-user-db-num chip-num 
&glob c-goods-attr_primary_key gds-code attr-code corr-user-db-num chip-num 
&glob c-goods-attr-any_primary_key Bush gds-code attr-code corr-user-db-num chip-num 
&glob c-group-period-validity_primary_key gr-per-val-code corr-user-db-num chip-num 
&glob c-group-period-validity-attr_primary_key gr-per-val-code attr-code corr-user-db-num chip-num 
&glob c-grp-obj-price_primary_key gop-id gop-db-num corr-user-db-num chip-num 
&glob c-hist-nws-option_primary_key db-num hn-id corr-user-db-num chip-num 
&glob c-hist-nws-option-attr_primary_key db-num hn-id attr-code corr-user-db-num chip-num 
&glob c-host-grp-obj-price_primary_key gop-id gop-db-num host-code corr-user-db-num chip-num 
&glob c-inkas_primary_key inkas-code corr-user-db-num chip-num 
&glob c-inkas-pay_primary_key inkas-code pay-code curr-code corr-user-db-num chip-num 
&glob c-inkas-pay-desk_primary_key inkas-code pay-code curr-code pay-desk doc-type cashier corr-user-db-num chip-num 
&glob c-inkas-pay-wth_primary_key inkas-code pay-code curr-code wth-code par-code pay-desk chk-type cashier corr-user-db-num chip-num 
&glob c-inv-line_primary_key doc-code artic prod-type prod-code corr-user-db-num chip-num 
&glob c-layout_primary_key layout-id corr-user-db-num chip-num 
&glob c-layout-attr_primary_key layout-id attr-code corr-user-db-num chip-num 
&glob c-layout-elem_primary_key layout-type device-type mode-id widget-id corr-user-db-num chip-num 
&glob c-layout-elem-attr_primary_key layout-type device-type mode-id widget-id attr-code corr-user-db-num chip-num 
&glob c-layout-elem-rule_primary_key layout-id mode-id widget-id corr-user-db-num chip-num 
&glob c-layout-elem-rule-attr_primary_key layout-id mode-id widget-id attr-code corr-user-db-num chip-num 
&glob c-norm-loss_primary_key id corr-user-db-num chip-num 
&glob c-marking_primary_key mark corr-user-db-num chip-num 
&glob c-nozzle_primary_key obj-type obj-code nozzle-code corr-user-db-num chip-num 
&glob c-nozzle-attr_primary_key obj-type obj-code nozzle-code attr-code corr-user-db-num chip-num 
&glob c-nzl-hist_primary_key obj-type obj-code nozzle-code corr-user-db-num chip-num subject 
&glob c-obj-grp-obj-price_primary_key gop-id gop-db-num obj-type obj-code corr-user-db-num chip-num 
&glob c-OperServ_primary_key id corr-user-db-num chip-num 
&glob c-operServAttr_primary_key id attr-code corr-user-db-num chip-num 
&glob c-ord-doc_primary_key doc-code corr-user-db-num chip-num 
&glob c-ord-doc-attr_primary_key doc-code attr-code corr-user-db-num chip-num 
&glob c-ord-dtl_primary_key doc-code artic prod-type prod-code node-code corr-user-db-num chip-num 
&glob c-ord-line_primary_key doc-code artic prod-type prod-code corr-user-db-num chip-num 
&glob c-ord-line-attr_primary_key doc-code gds-code attr-code corr-user-db-num chip-num 
&glob c-order-doc_primary_key db-num doc-code corr-user-db-num chip-num 
&glob c-order-doc-attr_primary_key db-num doc-code attr-code corr-user-db-num chip-num 
&glob c-order-head_primary_key db-num doc-code corr-user-db-num chip-num subject 
&glob c-order-line_primary_key db-num doc-code line-num corr-user-db-num chip-num 
&glob c-order-line-attr_primary_key db-num doc-code line-num attr-code corr-user-db-num chip-num 
&glob c-parts_primary_key obj-type obj-code artic prod-type prod-code in-code out-code part-code prt-code corr-user-db-num chip-num 
&glob c-parts-add_primary_key in-code gds-code part-code prt-code add-doc-code add-gds-code cli-type cli-code host-code contract-code corr-user-db-num chip-num 
&glob c-parts-attr_primary_key in-code gds-code part-code prt-code corr-user-db-num chip-num 
&glob c-parts-obj-attr_primary_key obj-type obj-code gds-code in-code out-code part-code prt-code attr-code corr-user-db-num chip-num 
&glob c-parts-root_primary_key doc-code orig-in-code orig-gds-code orig-part-code orig-prt-code in-code gds-code part-code prt-code corr-user-db-num chip-num 
&glob c-pay-type_primary_key obj-code corr-user-db-num chip-num 
&glob c-pay-type-attr_primary_key obj-code attr-code corr-user-db-num chip-num 
&glob c-payment-attr_primary_key pmnt-code attr-code corr-user-db-num chip-num 
&glob c-person_primary_key psn-code corr-user-db-num chip-num 
&glob c-pl-gds_primary_key obj-type obj-code pl-code gds-code corr-user-db-num chip-num 
&glob c-pl-gds-attr_primary_key obj-type obj-code pl-code gds-code attr-code corr-user-db-num chip-num 
&glob c-pl-gds-obj_primary_key obj-type obj-code pl-code gds-code chip-num 
&glob c-pl-gds-pump_primary_key obj-type obj-code gds-code pump-code pl-code corr-user-db-num chip-num 
&glob c-pl-gds-pump-attr_primary_key obj-type obj-code gds-code pump-code pl-code attr-code corr-user-db-num chip-num 
&glob c-pl-level_primary_key obj-type obj-code pl-code pl-level corr-user-db-num chip-num 
&glob c-pl-level-attr_primary_key obj-type obj-code pl-code pl-level attr-code corr-user-db-num chip-num 
&glob c-pl-pump_primary_key obj-type obj-code pl-code pump-code corr-user-db-num chip-num 
&glob c-pl-pump-attr_primary_key obj-type obj-code pl-code pump-code attr-code corr-user-db-num chip-num 
&glob c-pl-pump-nozzle_primary_key obj-type obj-code pl-code pump-code nozzle-code corr-user-db-num chip-num 
&glob c-pl-pump-nozzle-attr_primary_key obj-type obj-code pl-code pump-code nozzle-code attr-code corr-user-db-num chip-num 
&glob c-place_primary_key obj-type obj-code pl-code corr-user-db-num chip-num 
&glob c-place-attr_primary_key obj-type obj-code pl-code attr-code corr-user-db-num chip-num 
&glob c-place-io_primary_key place-io-code obj-type obj-code corr-user-db-num chip-num 
&glob c-plc-hist_primary_key obj-type obj-code pl-code corr-user-db-num chip-num subject 
&glob c-pmp-hist_primary_key obj-type obj-code pump-code corr-user-db-num chip-num subject 
&glob c-point-io_primary_key point-code db-num corr-user-db-num chip-num 
&glob c-point-place-rel_primary_key place-io-code obj-type obj-code point-code db-num cli-type cli-code corr-user-db-num chip-num 
&glob c-point-point-rel_primary_key from-point-code from-db-num to-point-code to-db-num deliv-type-code cond-keep-code corr-user-db-num chip-num 
&glob c-price-doc_primary_key doc-num corr-user-db-num chip-num 
&glob c-price-doc-forming_primary_key plt-id plt-db-num pdf-id pdf-db corr-user-db-num chip-num 
&glob c-price-doc-forming-attr_primary_key plt-id plt-db-num pdf-id pdf-db attr-code corr-user-db-num chip-num 
&glob c-price-doc-forming-gds_primary_key plt-id plt-db-num pdf-id pdf-db b-code corr-user-db-num chip-num 
&glob c-price-doc-forming-gds-qnty_primary_key plt-id plt-db-num pdf-id pdf-db b-code qgr-id qgr-db-num ggr-qnty corr-user-db-num chip-num 
&glob c-price-doc-forming-gds-sum_primary_key plt-id plt-db-num pdf-id pdf-db b-code sgr-id sgr-db-num ssg-summa corr-user-db-num chip-num 
&glob c-price-doc-forming-gds-tnv_primary_key plt-id plt-db-num pdf-id pdf-db b-code tog-id tog-db-num ttg-summa corr-user-db-num chip-num 
&glob c-price-doc-forming-gdsattr_primary_key pdf-id pdf-db plt-id plt-db-num b-code attr-code corr-user-db-num chip-num 
&glob c-price-list_primary_key doc-num price-type b-code corr-user-db-num chip-num 
&glob c-price-list-attr_primary_key doc-num price-type b-code attr-code corr-user-db-num chip-num 
&glob c-price-list-type_primary_key plt-id plt-db-num corr-user-db-num chip-num 
&glob c-price-list-type-attr_primary_key plt-id plt-db-num attr-code corr-user-db-num chip-num 
&glob c-price-list-type-cash-pay_primary_key plt-id plt-db-num curr-code cdpay-code corr-user-db-num chip-num 
&glob c-price-list-type-cassa_primary_key plt-id plt-db-num obj-code pos-type cash-num db-num corr-user-db-num chip-num 
&glob c-price-list-type-gds-grp_primary_key plt-id plt-db-num node-code corr-user-db-num chip-num 
&glob c-price-list-type-pay-type_primary_key plt-id plt-db-num pay-code corr-user-db-num chip-num 
&glob c-prod-bc_primary_key b-code b-str corr-user-db-num chip-num 
&glob c-prod-bc-attr_primary_key b-code b-str attr-code corr-user-db-num chip-num 
&glob c-prod-bc-db-attr_primary_key b-code b-str db-num attr-code corr-user-db-num chip-num 
&glob c-profile-by-profile_primary_key profile_id child-profile_id corr-user-db-num chip-num 
&glob c-promo-head_primary_key subject id Corr-user-db-num Chip-num 
&glob c-promo-schedule_primary_key id db-num corr-user-db-num chip-num 
&glob c-promo-schedule-week_primary_key id db-num corr-user-db-num chip-num 
&glob c-PromoAction_primary_key id db-num corr-user-db-num chip-num 
&glob c-PromoAttr_primary_key tablename p-key corr-user-db-num chip-num 
&glob c-PromoCriterion_primary_key id db-num corr-user-db-num chip-num 
&glob c-PromoGift_primary_key id db-num corr-user-db-num chip-num 
&glob c-PromoGoods_primary_key id db-num corr-user-db-num chip-num 
&glob c-PromoObject_primary_key id db-num corr-user-db-num chip-num 
&glob c-prop-head_primary_key dtm-code corr-user-db-num chip-num 
&glob c-prop-ref_primary_key dt-code corr-user-db-num chip-num 
&glob c-prop-ruleset_primary_key codex_id ruleset_id dtm-code corr-user-db-num chip-num 
&glob c-prop-script_primary_key dtm-code language script-name revis_id corr-user-db-num chip-num 
&glob c-pscript-ruleset_primary_key codex_id ruleset_id dtm-code language script-name revis_id corr-user-db-num chip-num 
&glob c-pump_primary_key obj-type obj-code pump-code corr-user-db-num chip-num 
&glob c-pump-attr_primary_key obj-type obj-code pump-code attr-code corr-user-db-num chip-num 
&glob c-pump-nozzle_primary_key obj-type obj-code pump-code nozzle-code corr-user-db-num chip-num 
&glob c-pump-nozzle-attr_primary_key obj-type obj-code pump-code nozzle-code attr-code corr-user-db-num chip-num 
&glob c-qnty-group_primary_key qgr-id qgr-db-num corr-user-db-num chip-num 
&glob c-qnty-in-qnty-group_primary_key qgr-id qgr-db-num ggr-qnty corr-user-db-num chip-num 
&glob c-recipe_primary_key recipe-code corr-user-db-num chip-num 
&glob c-recipe-develop_primary_key recipe-code doc-code gds-code corr-user-db-num chip-num 
&glob c-recipe-gds_primary_key recipe-code prod-type prod-code artic corr-user-db-num chip-num 
&glob c-recipe-hist_primary_key corr-user-db-num chip-num 
&glob c-regions_primary_key reg-code corr-user-db-num chip-num 
&glob c-rp-by-call_primary_key call#_id profile_id once-more corr-user-db-num chip-num 
&glob c-rp-rule-param_primary_key profile_id codex_id ruleset_id rp_order_id rule_id rule-param-name corr-user-db-num chip-num 
&glob c-rule_primary_key rule_id corr-user-db-num chip-num 
&glob c-rule-by-call_primary_key call#_id codex_id ruleset_id order_id corr-user-db-num chip-num 
&glob c-rule-by-profile_primary_key profile_id codex_id ruleset_id rp_order_id rule_id corr-user-db-num chip-num 
&glob c-rule-by-set_primary_key codex_id ruleset_id rule_id corr-user-db-num chip-num 
&glob c-rule-call-param_primary_key call#_id codex_id ruleset_id order_id param-name p-index corr-user-db-num chip-num 
&glob c-rule-process_primary_key pchain-type pchain-id start-from link-id corr-user-db-num chip-num 
&glob c-rule-profile_primary_key profile_id corr-user-db-num chip-num 
&glob c-ruledict_primary_key entry-id corr-user-db-num chip-num 
&glob c-ruledict-param_primary_key entry-id param-num corr-user-db-num chip-num 
&glob c-ruleset_primary_key codex_id ruleset_id corr-user-db-num chip-num 
&glob c-rvs-doc_primary_key rvs-code corr-user-db-num chip-num 
&glob c-rvs-line_primary_key rvs-code obj-type obj-code pl-code gds-code corr-user-db-num chip-num 
&glob c-rvs-line-pump_primary_key rvs-code obj-type obj-code pl-code gds-code pump-code nozzle-code corr-user-db-num chip-num 
&glob c-s-coeff_primary_key gds-code host-code obj-type obj-code s-date corr-user-db-num chip-num 
&glob c-sale-doc_primary_key inkas-code storage doc-code corr-user-db-num chip-num 
&glob c-scales_primary_key db-num scales-num corr-user-db-num chip-num 
&glob c-scales-attr_primary_key db-num scales-num attr-code corr-user-db-num chip-num 
&glob c-scales-gds_primary_key db-num scales-num PLU-code corr-user-db-num chip-num 
&glob c-scales-grp_primary_key db-num node-code scales-num corr-user-db-num chip-num 
&glob c-schet-fact-doc_primary_key db-num doc-code corr-user-db-num chip-num 
&glob c-schet-fact-line_primary_key doc-code db-num line-num corr-user-db-num chip-num 
&glob c-season_primary_key sea-code db-num corr-user-db-num chip-num 
&glob c-sert_primary_key cli-type cli-code sert-code corr-user-db-num chip-num 
&glob c-shift-attr_primary_key obj-type obj-code shift-date shift-num attr-code corr-user-db-num chip-num 
&glob c-shift-obj_primary_key obj-type obj-code shift-date shift-num corr-user-db-num chip-num 
&glob c-shift-staff_primary_key obj-type obj-code shift-date shift-num next-shift psn-num corr-user-db-num chip-num 
&glob c-shop_primary_key obj-code corr-user-db-num chip-num 
&glob c-sht-hist_primary_key obj-type obj-code shift-date shift-num corr-user-db-num chip-num subject 
&glob c-sr-izmerenia_primary_key node-code corr-user-db-num chip-num 
&glob c-sr-izmerenia-attr_primary_key node-code attr-code corr-user-db-num chip-num 
&glob c-staff_primary_key role role-level work-place staff-code date-start corr-user-db-num chip-num 
&glob c-stop-list_primary_key classif-type stop-list-code corr-user-db-num chip-num 
&glob c-stop-list-line_primary_key classif-type stop-list-code line-num corr-user-db-num chip-num 
&glob c-store_primary_key obj-code corr-user-db-num chip-num 
&glob c-sum-group_primary_key sgr-id sgr-db-num corr-user-db-num chip-num 
&glob c-sum-grp_primary_key grp-code corr-user-db-num chip-num 
&glob c-sum-grp-obj_primary_key obj-type obj-code grp-code corr-user-db-num chip-num 
&glob c-sum-in-sum-group_primary_key sgr-id sgr-db-num ssg-summa corr-user-db-num chip-num 
&glob c-sysconf_primary_key host-code corr-user-db-num chip-num 
&glob c-table-bind_primary_key corr-user-db-num tbl-name-src chip-num-src tbl-name-rec 
&glob c-tare_primary_key tare-code corr-user-db-num chip-num 
&glob c-tax_primary_key tax-code corr-user-db-num chip-num 
&glob c-tax-hist_primary_key tax-code rate-code corr-user-db-num chip-num host-code obj-type obj-code subject 
&glob c-tax-rate_primary_key tax-code rate-code corr-user-db-num chip-num 
&glob c-tax-rate-gds-grp_primary_key node-code tax-code host-code obj-type obj-code corr-user-db-num chip-num 
&glob c-tax-units_primary_key type tax-code corr-user-db-num chip-num 
&glob c-tech-prol-pwd_primary_key id corr-user-db-num chip-num 
&glob c-thbj-attr_primary_key obj-type obj-code upper-prop-code prop-code corr-user-db-num chip-num 
&glob c-tnv-in-turnover-group_primary_key tog-id tog-db-num ttg-summa corr-user-db-num chip-num 
&glob c-trn-doc_primary_key doc-code corr-user-db-num chip-num 
&glob c-trn-doc-sum_primary_key doc-code sum-type corr-user-db-num chip-num 
&glob c-trn-reason_primary_key reason-code corr-user-db-num chip-num 
&glob c-trn-reason-host_primary_key host-code ext-doc-type hold-doc corr-user-db-num chip-num 
&glob c-trn-reason-obj_primary_key obj-type obj-code ext-doc-type hold-doc corr-user-db-num chip-num 
&glob c-trn-rsn-attr_primary_key reason-code attr-code corr-user-db-num chip-num 
&glob c-turnover-group_primary_key tog-id tog-db-num corr-user-db-num chip-num 
&glob c-units_primary_key unit-name corr-user-db-num chip-num 
&glob c-user-account_primary_key user-id corr-user-db-num chip-num 
&glob c-user-log_primary_key corr-user-db-num cusr-id 
&glob c-user-login_primary_key db-num user-id corr-user-db-num chip-num 
&glob c-usr-hist_primary_key user-id corr-user-db-num chip-num 
&glob c-utd_primary_key db-num doc-id corr-user-db-num chip-num 
&glob c-utd-attr_primary_key db-num doc-id attr-code corr-user-db-num chip-num 
&glob c-utd-err_primary_key db-num doc-id CheckType CodeErr CheckObj reckey corr-user-db-num chip-num 
&glob c-utd-err-attr_primary_key db-num doc-id CheckType CodeErr CheckObj reckey attr-code corr-user-db-num chip-num 
&glob c-utd-head_primary_key db-num doc-id LineNum mark CheckType CodeErr CheckObj reckey attr-code corr-user-db-num chip-num subject 
&glob c-utd-lines_primary_key db-num doc-id LineNum corr-user-db-num chip-num 
&glob c-utd-lines-attr_primary_key db-num doc-id LineNum attr-code corr-user-db-num chip-num 
&glob c-utd-marking-lines_primary_key db-num doc-id LineNum mark corr-user-db-num chip-num 
&glob c-utd-marking-lines-attr_primary_key db-num doc-id LineNum mark attr-code corr-user-db-num chip-num 
&glob c-var-deliv-gr-per-val_primary_key deliv-type-code deliv-subj-code obj-type obj-code gr-per-val-code corr-user-db-num chip-num 
&glob c-variant-delivery_primary_key deliv-type-code deliv-subj-code obj-type obj-code corr-user-db-num chip-num 
&glob c-varianty-delivery-gds-obj_primary_key gds-code obj-type obj-code deliv-type-code deliv-subj-code corr-user-db-num chip-num 
&glob c-vsd_primary_key ID db-num corr-user-db-num chip-num 
&glob c-wealth_primary_key wth-code corr-user-db-num chip-num 
&glob c-wi-mode_primary_key mode-type mode-id corr-user-db-num chip-num 
&glob c-wi-mode-attr_primary_key mode-type mode-id attr-code corr-user-db-num chip-num 
&glob c-wth-doc_primary_key doc-code corr-user-db-num chip-num 
&glob c-wth-dtl_primary_key doc-code wth-code w-p-code par-code corr-user-db-num chip-num 
&glob c-wth-gds_primary_key wth-code gds-code corr-user-db-num chip-num 
&glob c-wth-gds-attr_primary_key wth-code gds-code attr-code corr-user-db-num chip-num 
&glob c-wth-hist_primary_key wth-code corr-user-db-num chip-num host-code obj-type obj-code subject 
&glob c-wth-line_primary_key doc-code wth-code w-p-code corr-user-db-num chip-num 
&glob c-wth-obj_primary_key obj-type obj-code wth-code corr-user-db-num chip-num 
&glob c-wth-par_primary_key wth-code par-code corr-user-db-num chip-num 
&glob c-wth-parts_primary_key obj-type obj-code w-p-code wth-code par-code in-code out-code ser-code db-num fact-rangeFrom fact-rangeTo corr-user-db-num chip-num 
&glob c-wth-place_primary_key host-code obj-type obj-code w-p-code corr-user-db-num chip-num 
&glob c-wth-pobj_primary_key obj-type obj-code w-p-code wth-code corr-user-db-num chip-num 
&glob c-wth-ser_primary_key ser-code db-num corr-user-db-num chip-num 
&glob c-wth-ser-attr_primary_key ser-code db-num attr-code corr-user-db-num chip-num 
&glob cash-desk_primary_key db-num obj-code pos-type cash-num 
&glob cash-desk-attr_primary_key db-num obj-code pos-type cash-num upper-attr-code attr-code 
&glob Cash-param-hist_primary_key obj-type obj-code cash-num param_section param_group param_name 
&glob cash-pay_primary_key cdpay-code curr-code 
&glob cash-pay-attr_primary_key cdpay-code curr-code host-code obj-type obj-code attr-code 
&glob CashBook_primary_key id 
&glob CashBookAttr_primary_key id attr-code 
&glob CashBookRule_primary_key CashBookID Obj-type Obj-code Code 
&glob CashBookRuleAttr_primary_key cashbookid obj-type obj-code code attr-code 
&glob cbr-bank_primary_key bic 
&glob cbr-bank-attr_primary_key bic attr-code 
&glob cd-clu_primary_key obj-type obj-code pos-type clu-type CLU-code 
&glob cd-clu-attr_primary_key obj-type obj-code pos-type clu-type CLU-code attr-code 
&glob cd-dlu_primary_key obj-type obj-code pos-type dlu-type DLU-code 
&glob cd-dlu-attr_primary_key obj-type obj-code pos-type dlu-type DLU-code attr-code 
&glob cd-doc_primary_key obj-type obj-code pos-type doc-type doc-code 
&glob cd-doc-attr_primary_key obj-type obj-code pos-type doc-type doc-code attr-code 
&glob cd-doc-line_primary_key obj-type obj-code pos-type doc-type doc-code line-num 
&glob cd-doc-line-attr_primary_key obj-type obj-code pos-type doc-type doc-code line-num attr-code 
&glob cd-event-log_primary_key db-num trans-id 
&glob cd-event-log-attr_primary_key db-num trans-id attr-code 
&glob cd-events_primary_key version event-id 
&glob cd-events-attr_primary_key event-id attr-code 
&glob cd-grp_primary_key obj-type obj-code pos-type grp-type grp-code 
&glob cd-grp-attr_primary_key obj-type obj-code pos-type grp-type grp-code attr-code 
&glob cd-plu_primary_key obj-type obj-code pos-type plu-type PLU-code 
&glob cd-plu-attr_primary_key obj-type obj-code pos-type plu-type PLU-code attr-code 
&glob cd-trans_primary_key db-num trans-id 
&glob cd-trans-attr_primary_key db-num trans-id attr-code 
&glob cd-video-link_primary_key video-id event-id video-event-id 
&glob cd-video-link-attr_primary_key video-id event-id video-event-id attr-code 
&glob chk-discnt_primary_key doc-code record-type line-num discnt-id object-line-num 
&glob chk-discnt-attr_primary_key doc-code record-type line-num discnt-id object-line-num attr-code 
&glob chk-doc_primary_key doc-code 
&glob chk-doc-attr_primary_key doc-code attr-code 
&glob chk-gds_primary_key doc-code line-num 
&glob chk-gds-attr_primary_key doc-code line-num attr-code 
&glob chk-gds-pay_primary_key doc-code algo-num line-num cpline-num 
&glob chk-pay_primary_key doc-code line-num 
&glob chk-pay-attr_primary_key doc-code line-num attr-code 
&glob cli-art_primary_key cli-type cli-code artic prod-type prod-code cli-art 
&glob cli-art-attr_primary_key cli-type cli-code artic prod-type prod-code cli-art attr-code 
&glob cli-gds_primary_key cli-type cli-code host-code artic prod-type prod-code 
&glob cli-gds-attr_primary_key cli-type cli-code host-code artic prod-type prod-code attr-code 
&glob cli-grp_primary_key node-code 
&glob cli-grp-attr_primary_key node-code attr-code 
&glob clients_primary_key obj-type obj-code 
&glob clients-attr_primary_key obj-type obj-code attr-code 
&glob clob-bind_primary_key uniq-key-rec field-name_ part-num 
&glob clob-data_primary_key db-num int64-id 
&glob Code_primary_key parent code 
&glob code-range_primary_key range-type first-code 
&glob condition-keeping_primary_key cond-keep-code 
&glob condition-keeping-attr_primary_key cond-keep-code attr-code 
&glob config_primary_key param-code host-code obj-type obj-code beg-date end-date db-num 
&glob contract_primary_key host-code contract-code 
&glob contract-attr_primary_key host-code contract-code attr-code 
&glob contract-line_primary_key host-code contract-num line-num sub-line-num 
&glob contract-line-attr_primary_key host-code contract-num line-num sub-line-num attr-code 
&glob contract-specif_primary_key host-code contract-num gds-code 
&glob contract-specif-attr_primary_key host-code contract-num gds-code attr-code 
&glob counter_primary_key db file-name key code 
&glob country_primary_key num-code 
&glob country-attr_primary_key num-code attr-code 
&glob criterion-analysis_primary_key cral-id 
&glob criterion-analysis-attr_primary_key cral-id attr-code 
&glob cshr-month_primary_key cashier-psn-code cshr-code obj-type obj-code year_ month_ 
&glob cshr-month-attr_primary_key cashier-psn-code cshr-code obj-type obj-code year_ month_ attr-code 
&glob curr-accnt_primary_key curr-code exch-date 
&glob curr-accnt-attr_primary_key curr-code exch-date attr-code 
&glob curr-bank_primary_key curr-code exch-date 
&glob curr-bank-attr_primary_key curr-code exch-date attr-code 
&glob curr-shop_primary_key obj-type obj-code curr-code exch-date exch-time 
&glob curr-shop-attr_primary_key obj-type obj-code curr-code exch-date exch-time attr-code 
&glob currency_primary_key curr-code 
&glob currency-attr_primary_key curr-code attr-code 
&glob custom-labels_primary_key tbl-name fld-name call-type call-point language 
&glob datatype-exp_primary_key dte-id 
&glob datatype-exp-attr_primary_key dte-id dea-attr-code 
&glob datatype-imp_primary_key dti-id 
&glob datatype-imp-attr_primary_key dti-id dia-attr-code 
&glob datatype-table_primary_key dtt-name 
&glob datatype-table-exp_primary_key dtt-name dte-id 
&glob datatype-table-field_primary_key dtt-name dtf-name 
&glob datatype-table-field-exp_primary_key dte-id dtt-name dtf-name 
&glob datatype-table-field-imp_primary_key dti-id dtt-name dtf-name 
&glob datatype-table-imp_primary_key dtt-name dti-id 
&glob db_primary_key db-num 
&glob db-attr_primary_key db-num attr-code 
&glob db-filter_primary_key db-num call-point naim 
&glob db-filter-attr_primary_key db-num call-point naim attr-code 
&glob db-grp-obj-price_primary_key gop-id gop-db-num dgo-db-num 
&glob db-grp-obj-price-attr_primary_key gop-id gop-db-num dgo-db-num attr-code 
&glob db-info_primary_key db-num date-info time-info area-ID volume-num 
&glob db-rec-attr_primary_key db-num uniq-key-rec attr-code 
&glob db-status_primary_key db-num 
&glob db-status-attr_primary_key db-num attr-code 
&glob db-usr-flt_primary_key user-db-num user-name call-point 
&glob db-usr-flt-attr_primary_key user-db-num user-name call-point attr-code 
&glob deliv-type-cond-keep_primary_key deliv-type-code cond-keep-code 
&glob deliv-type-cond-keep-attr_primary_key deliv-type-code cond-keep-code attr-code 
&glob delivery-subject_primary_key deliv-subj-code 
&glob delivery-subject-attr_primary_key deliv-subj-code attr-code 
&glob delivery-type_primary_key deliv-type-code 
&glob delivery-type-attr_primary_key deliv-type-code attr-code 
&glob delivery-type-subject_primary_key deliv-type-code deliv-subj-code 
&glob delivery-type-subject-attr_primary_key deliv-type-code deliv-subj-code attr-code 
&glob devisPC_primary_key DB-num id 
&glob devisPC-attr_primary_key db-num id attr-code date time_ 
&glob dis-card_primary_key d-card 
&glob dis-card-long_primary_key d-card card-media long-d-card 
&glob dis-card-long-attr_primary_key d-card card-media long-d-card attr-code 
&glob dis-card-mask_primary_key mask-num 
&glob dis-card-mask-attr_primary_key mask-num attr-code 
&glob dis-card-property_primary_key d-card dt-code node-code host-code obj-type obj-code 
&glob dis-card-type_primary_key emitent-host-code type host-code obj-type obj-code 
&glob dis-card-type-attr_primary_key emitent-host-code type host-code obj-type obj-code attr-code 
&glob dis-cfg-rule_primary_key table-name pos-type templ-rl-root time-templ-rl-root self-nonunique 
&glob dis-cfg-rule-attr_primary_key table-name pos-type templ-rl-root time-templ-rl-root self-nonunique attr-code 
&glob dis-cp-rule_primary_key cdpay-code curr-code host-code obj-type obj-code pos-type discnt-role nonunique 
&glob dis-cp-rule-attr_primary_key cdpay-code curr-code host-code obj-type obj-code pos-type discnt-role nonunique attr-code 
&glob dis-dc-rule_primary_key d-card host-code obj-type obj-code pos-type discnt-role nonunique 
&glob dis-dc-rule-attr_primary_key d-card host-code obj-type obj-code pos-type discnt-role nonunique attr-code 
&glob dis-dct-rule_primary_key emitent-host-code type host-code obj-type obj-code pos-type discnt-role nonunique 
&glob dis-dct-rule-attr_primary_key emitent-host-code type host-code obj-type obj-code pos-type discnt-role nonunique attr-code 
&glob dis-gds-rule_primary_key obj-type obj-code gds-code pos-type discnt-role nonunique 
&glob dis-gds-rule-attr_primary_key obj-type obj-code gds-code pos-type discnt-role nonunique attr-code 
&glob dis-grp-rule_primary_key classif-type node-code host-code obj-type obj-code pos-type discnt-role nonunique 
&glob dis-grp-rule-attr_primary_key classif-type node-code host-code obj-type obj-code pos-type discnt-role nonunique attr-code 
&glob dis-host_primary_key d-card dt-code host-code 
&glob dis-obj_primary_key d-card dt-code obj-type obj-code 
&glob dis-rule_primary_key rule-num 
&glob dis-rule-attr_primary_key rule-num attr-code 
&glob dis-some-rule_primary_key classif-type resource#_id host-code obj-type obj-code pos-type discnt-role nonunique 
&glob dis-some-rule-attr_primary_key classif-type resource#_id host-code obj-type obj-code pos-type discnt-role nonunique attr-code 
&glob dis-thbj-rule_primary_key host-code obj-type obj-code pos-type discnt-role nonunique 
&glob dis-thbj-rule-attr_primary_key host-code obj-type obj-code pos-type discnt-role nonunique attr-code 
&glob dis-time-rule_primary_key time-rule-num 
&glob dis-time-rule-attr_primary_key time-rule-num attr-code 
&glob dish-grp_primary_key node-code 
&glob dish-grp-attr_primary_key node-code attr-code 
&glob doc-abc-def_primary_key doad-id db-num 
&glob doc-abc-def-attr_primary_key doad-id db-num attr-code 
&glob doc-abc-def-doc_primary_key doad-id db-num dadd-ext-doc-type 
&glob doc-abc-def-doc-attr_primary_key doad-id db-num dadd-ext-doc-type attr-code 
&glob doc-abc-def-obj_primary_key doad-id db-num obj-type obj-code 
&glob doc-abc-def-obj-attr_primary_key doad-id db-num obj-type obj-code attr-code 
&glob doc-attr_primary_key doc-code attr-code 
&glob doc-fact-num_primary_key obj-type obj-code fact-num 
&glob doc-fact-num-attr_primary_key obj-type obj-code fact-num attr-code 
&glob doc-fbr-gds_primary_key obj-type obj-code fbr-obj-type fbr-obj-code out-code gds-code 
&glob doc-fbr-gds-attr_primary_key obj-type obj-code fbr-obj-type fbr-obj-code out-code gds-code attr-code 
&glob doc-filter_primary_key filter-code doc-code 
&glob doc-filter-attr_primary_key filter-code doc-code attr-code 
&glob doc-filter-head_primary_key filter-code 
&glob doc-filter-head-attr_primary_key filter-code attr-code 
&glob doc-line_primary_key doc-code artic prod-code prod-type line-num 
&glob doc-line-attr_primary_key doc-code gds-code attr-code 
&glob doc-line-sum_primary_key doc-code gds-code sum-type 
&glob doc-pl_primary_key obj-type obj-code pl-code out-code gds-code 
&glob doc-pl-attr_primary_key obj-type obj-code pl-code out-code gds-code attr-code 
&glob doc-pl-pump_primary_key obj-type obj-code pl-code pump-code out-code gds-code 
&glob doc-pl-pump-attr_primary_key obj-type obj-code pl-code pump-code out-code gds-code attr-code 
&glob doc-prts_primary_key out-code b-code 
&glob doc-prts-attr_primary_key out-code b-code attr-code 
&glob doc-xyz-def_primary_key doxd-id db-num 
&glob doc-xyz-def-attr_primary_key doxd-id db-num attr-code 
&glob doc-xyz-def-doc_primary_key doxd-id db-num dxdd-ext-doc-type 
&glob doc-xyz-def-doc-attr_primary_key doxd-id db-num dxdd-ext-doc-type attr-code 
&glob doc-xyz-def-obj_primary_key doxd-id db-num obj-type obj-code 
&glob doc-xyz-def-obj-attr_primary_key doxd-id db-num obj-type obj-code attr-code 
&glob drt-prop_primary_key templ-rl-root node-code 
&glob edi-status_primary_key tbl-name doc-code date-status time-status 
&glob egais-clients_primary_key supp-id 
&glob egais-gds_primary_key alpr-id 
&glob esys-all-attr_primary_key table-name key1 key2 key3 key4 key5 key6 key7 key8 attr-code 
&glob esys-datatype-exp_primary_key esys-id db-num dte-id 
&glob esys-datatype-imp_primary_key esys-id db-num tdi-id 
&glob esys-pck-keys_primary_key esys-id db-num espr-cr-db-num espr-pack-num espr-uniq-key 
&glob esys-pck-rcvd_primary_key esys-id db-num espr-cr-db-num espr-pack-num 
&glob esys-pck-sent_primary_key esys-id db-num esps-cr-db-num esps-pack-num 
&glob esys-route_primary_key esys-id db-num esr-cr-db-num esr-last-pack esr-tbl-ord 
&glob esys-route-dump_primary_key esrd-dump-ord esrd-rec-ord esrd-cr-db-num 
&glob ex-mark_primary_key db-num mark-code 
&glob ex-mark-attr_primary_key db-num mark-code attr-code 
&glob ext-artic_primary_key cli-type cli-code gds-code 
&glob ext-artic-attr_primary_key cli-type cli-code gds-code attr-code 
&glob ext-artic-db_primary_key cli-type cli-code gds-code db-num 
&glob ext-artic-db-attr_primary_key cli-type cli-code gds-code db-num attr-code 
&glob ext-artic-host_primary_key cli-type cli-code gds-code host-code 
&glob ext-artic-host-attr_primary_key cli-type cli-code gds-code host-code attr-code 
&glob ext-artic-obj_primary_key cli-type cli-code gds-code obj-type obj-code 
&glob ext-artic-obj-attr_primary_key cli-type cli-code gds-code obj-type obj-code attr-code 
&glob ext-classif_primary_key classif-subject classif-name db-num Key#_One Key#_Two Key#_Three CharKey_One CharKey_Two CharKey_Three nonunique 
&glob ext-classif-attr_primary_key classif-subject classif-name db-num Key#_One Key#_Two Key#_Three CharKey_One CharKey_Two CharKey_Three nonunique attr-code 
&glob ext-file_primary_key db-num from-db-num file-num 
&glob ext-file-attr_primary_key db-num from-db-num file-num attr-code 
&glob ext-file-line_primary_key db-num from-db-num file-num line-num sub-line-num 
&glob ext-file-line-attr_primary_key db-num from-db-num file-num line-num sub-line-num attr-code 
&glob ext-file-par_primary_key db-num from-db-num file-num param-num 
&glob ext-file-par-attr_primary_key db-num from-db-num file-num param-num attr-code 
&glob ext-system_primary_key esys-id db-num 
&glob ext-system-attr_primary_key esys-id db-num esya-attr-code 
&glob factur-connect_primary_key db-num connect-code 
&glob factur-connect-attr_primary_key db-num connect-code attr-code 
&glob factur-connect-line_primary_key connect-code db-num line-num in-code part-code prt-code 
&glob factur-connect-line-attr_primary_key connect-code db-num line-num in-code part-code prt-code attr-code 
&glob fbr-doc_primary_key doc-code 
&glob fbr-gds-grp_primary_key obj-type obj-code node-code 
&glob fbr-gds-grp-attr_primary_key obj-type obj-code node-code attr-code 
&glob fbr-gds-obj_primary_key obj-type obj-code gds-code 
&glob fbr-gds-obj-attr_primary_key obj-type obj-code gds-code attr-code 
&glob fbr-history_primary_key obj-type obj-code hst-code 
&glob fbr-line_primary_key doc-code trn-type recipe-code artic prod-type prod-code 
&glob fbr-pln_primary_key doc-code 
&glob fbr-pln-line_primary_key doc-code fbr-obj-type fbr-obj-code gds-code recipe-code 
&glob fbr-prn_primary_key db-num prn-num 
&glob fbr-prn-attr_primary_key db-num prn-num attr-code 
&glob fbr-prn-gds_primary_key db-num prn-num obj-type obj-code gds-code 
&glob fbr-prn-gds-attr_primary_key db-num prn-num obj-type obj-code gds-code attr-code 
&glob fbr-prn-grp_primary_key db-num prn-num obj-type obj-code node-code 
&glob fbr-prn-grp-attr_primary_key db-num prn-num obj-type obj-code node-code attr-code 
&glob fbr-recipe_primary_key doc-code recipe-code 
&glob fbr-recipe-gds_primary_key doc-code recipe-code prod-type prod-code artic 
&glob feature_primary_key scale-code feature-code 
&glob feature-attr_primary_key scale-code feature-code attr-code 
&glob feature-scale_primary_key scale-code 
&glob feature-scale-attr_primary_key scale-code attr-code 
&glob Filter_primary_key call-point Naim 
&glob Filter-attr_primary_key call-point Naim attr-code 
&glob fin-bank_primary_key host-code code-bank 
&glob fin-bank-attr_primary_key host-code code-bank attr-code 
&glob fin-code-an-uchet_primary_key host-code fin-code 
&glob fin-code-an-uchet-attr_primary_key host-code fin-code attr-code 
&glob fin-code-cel-nazn_primary_key host-code fin-code 
&glob fin-code-cel-nazn-attr_primary_key host-code fin-code attr-code 
&glob fin-code-cor-acc_primary_key host-code fin-code 
&glob fin-code-cor-acc-attr_primary_key host-code fin-code attr-code 
&glob fin-connect_primary_key host-code connect-code 
&glob fin-connect-attr_primary_key host-code connect-code attr-code 
&glob fin-doc_primary_key host-code fin-doc-code 
&glob fin-doc-attr_primary_key host-code fin-doc-code attr-code 
&glob fin-doc-cor-acc-lk_primary_key host-code fin-code 
&glob fin-doc-cor-acc-lk-attr_primary_key host-code fin-code attr-code 
&glob fin-doc-obj_primary_key host-code obj-type obj-code fin-doc-code 
&glob fin-doc-obj-attr_primary_key host-code obj-type obj-code fin-doc-code attr-code 
&glob fin-doc-schet-lk_primary_key host-code code-schet 
&glob fin-doc-schet-lk-attr_primary_key host-code code-schet attr-code 
&glob fin-doc-tax_primary_key host-code fin-doc-code line-num 
&glob fin-doc-tax-attr_primary_key host-code fin-doc-code line-num attr-code 
&glob fin-gds-part_primary_key host-code fin-ob-code obj-type obj-code gds-code in-code out-code part-code prt-code doc-type 
&glob fin-gds-part-attr_primary_key host-code fin-ob-code obj-type obj-code gds-code in-code out-code part-code prt-code doc-type attr-code 
&glob fin-ob_primary_key host-code doc-code 
&glob fin-ob-attr_primary_key host-code doc-code attr-code 
&glob fin-ob-before_primary_key host-code before-code 
&glob fin-ob-cor-acc-lk_primary_key host-code fin-code 
&glob fin-ob-cor-acc-lk-attr_primary_key host-code fin-code attr-code 
&glob fin-ob-schet-lk_primary_key host-code code-schet 
&glob fin-ob-schet-lk-attr_primary_key host-code code-schet attr-code 
&glob fin-ob-tax_primary_key host-code doc-code line-num 
&glob fin-ob-tax-attr_primary_key host-code doc-code line-num attr-code 
&glob fin-ob-tax-before_primary_key host-code before-code line-num 
&glob fin-ob-trn_primary_key host-code doc-code doc-type trn-doc-code id corr-user-db-num 
&glob fin-ob-trn-attr_primary_key host-code doc-code doc-type trn-doc-code id corr-user-db-num attr-code 
&glob fin-schet_primary_key host-code code-schet 
&glob fin-schet-attr_primary_key host-code code-schet attr-code 
&glob fin-statement_primary_key host-code sttm-code 
&glob fin-statement-attr_primary_key host-code sttm-code attr-code 
&glob fin-statement-line_primary_key host-code sttm-code line-num 
&glob fin-statement-line-attr_primary_key host-code sttm-code line-num attr-code 
&glob firm_primary_key firm-code 
&glob gds-add-charges_primary_key gds-code 
&glob gds-add-charges-attr_primary_key gds-code attr-code 
&glob gds-dtl_primary_key doc-code artic prod-code prod-type prt-code line-num 
&glob gds-dtl-attr_primary_key doc-code artic prod-code prod-type prt-code attr-code 
&glob gds-grp_primary_key node-code 
&glob gds-grp-attr_primary_key node-code attr-code host-code obj-type obj-code 
&glob gds-grp-obj_primary_key node-code host-code obj-type obj-code 
&glob gds-grp-obj-attr_primary_key node-code host-code obj-type obj-code attr-code 
&glob gds-host-attr_primary_key host-code gds-code attr-code 
&glob gds-mercury_primary_key ID db-num 
&glob gds-mercury-attr_primary_key ID db-num attr-code 
&glob gds-obj_primary_key obj-type obj-code artic prod-type prod-code 
&glob gds-obj-attr_primary_key obj-type obj-code gds-code attr-code 
&glob gds-obj-flag_primary_key obj-type obj-code gds-code 
&glob gds-obj-flag-attr_primary_key obj-type obj-code gds-code attr-code 
&glob gds-obj-prop_primary_key obj-type obj-code gds-code 
&glob gds-obj-prop-attr_primary_key obj-type obj-code gds-code attr-code 
&glob gds-prt_primary_key node-code 
&glob gds-prt-attr_primary_key node-code attr-code 
&glob gds-season_primary_key sea-code db-num gds-code 
&glob gds-season-attr_primary_key sea-code db-num gds-code attr-code 
&glob gen-attr_primary_key table-name p-key attr-code 
&glob global-state_primary_key gls-id 
&glob global-state-attr_primary_key gls-id attr-code 
&glob goods_primary_key gds-code 
&glob goods-attr_primary_key gds-code attr-code 
&glob group-period-validity_primary_key gr-per-val-code 
&glob group-period-validity-attr_primary_key gr-per-val-code attr-code 
&glob grp-obj-price_primary_key gop-id gop-db-num 
&glob grp-obj-price-attr_primary_key gop-id gop-db-num attr-code 
&glob h-route_primary_key db-num last-pack tbl-ord 
&glob h-route-dump_primary_key dump-ord rec-ord 
&glob hist-nws-option_primary_key db-num hn-id 
&glob hist-nws-option-attr_primary_key db-num hn-id attr-code 
&glob hold-attr_primary_key cat-code attr-code 
&glob hold-gds-grp_primary_key cat-code time-code node-code 
&glob hold-gds-grp-attr_primary_key cat-code time-code node-code attr-code 
&glob hold-goods_primary_key cat-code time-code gds-code 
&glob hold-goods-attr_primary_key cat-code time-code gds-code attr-code 
&glob hold-purch_primary_key cat-code time-code gds-code 
&glob hold-purch-attr_primary_key cat-code time-code gds-code attr-code 
&glob hold-purch-grp_primary_key cat-code time-code node-code 
&glob hold-purch-grp-attr_primary_key cat-code time-code node-code attr-code 
&glob hold-purch-supp_primary_key cat-code time-code cli-type cli-code 
&glob hold-purch-supp-attr_primary_key cat-code time-code cli-type cli-code attr-code 
&glob hold-purch-supp-gds_primary_key cat-code time-code cli-type cli-code gds-code 
&glob hold-purch-supp-gds-attr_primary_key cat-code time-code cli-type cli-code gds-code attr-code 
&glob hold-sale_primary_key cat-code time-code gds-code 
&glob hold-sale-attr_primary_key cat-code time-code gds-code attr-code 
&glob hold-sale-grp_primary_key cat-code time-code node-code 
&glob hold-sale-grp-attr_primary_key cat-code time-code node-code attr-code 
&glob hold-time_primary_key cat-code time-code 
&glob hold-time-attr_primary_key cat-code time-code 
&glob hold-trn_primary_key cat-code time-code doc-code 
&glob hold-trn-attr_primary_key cat-code time-code doc-code attr-code 
&glob host-grp-obj-price_primary_key gop-id gop-db-num host-code 
&glob host-grp-obj-price-attr_primary_key gop-id gop-db-num host-code attr-code 
&glob host-lk_primary_key host-code lk-type 
&glob host-lk-attr_primary_key host-code lk-type attr-code 
&glob icnt-doc_primary_key doc-code 
&glob icnt-line_primary_key doc-code obj-type obj-code pump-code nozzle-code 
&glob inkas_primary_key inkas-code 
&glob inkas-pay_primary_key inkas-code pay-code curr-code 
&glob inkas-pay-attr_primary_key inkas-code pay-code curr-code attr-code 
&glob inkas-pay-desk_primary_key inkas-code pay-code curr-code pay-desk doc-type cashier 
&glob inkas-pay-desk-attr_primary_key inkas-code pay-code curr-code pay-desk doc-type cashier attr-code 
&glob inkas-pay-wth_primary_key inkas-code pay-code curr-code wth-code par-code pay-desk chk-type cashier 
&glob inv-doc_primary_key doc-code 
&glob inv-doc-attr_primary_key doc-code attr-code 
&glob inv-line_primary_key doc-code artic prod-type prod-code 
&glob inv-line-attr_primary_key doc-code artic prod-type prod-code attr-code 
&glob lang_primary_key lang-code 
&glob lang-attr_primary_key lang-code attr-code 
&glob layout_primary_key layout-id 
&glob layout-attr_primary_key layout-id attr-code 
&glob layout-elem_primary_key layout-type device-type mode-id widget-id 
&glob layout-elem-attr_primary_key layout-type device-type mode-id widget-id attr-code 
&glob layout-elem-rule_primary_key layout-id mode-id widget-id 
&glob layout-elem-rule-attr_primary_key layout-id mode-id widget-id attr-code 
&glob lvl-name_primary_key upper-code level 
&glob lvl-name-attr_primary_key upper-code level attr-code 
&glob marking_primary_key mark 
&glob marking-attr_primary_key mark attr-code 
&glob marking-chk_primary_key mark doc-code line-num 
&glob marking-lines_primary_key mark obj-type obj-code gds-code in-code out-code part-code prt-code 
&glob menu-group_primary_key menu-code menu-group-code 
&glob menu-group-attr_primary_key menu-code menu-group-code attr-code 
&glob menu-head_primary_key menu-code 
&glob menu-head-attr_primary_key menu-code attr-code 
&glob menu-item_primary_key menu-code item-code 
&glob menu-item-attr_primary_key menu-code item-code attr-code 
&glob menu-item-group_primary_key menu-code item-code item-context menu-group-code 
&glob menu-item-group-attr_primary_key menu-code item-code item-context menu-group-code attr-code 
&glob menu-user_primary_key db-num user-id menu-user-code 
&glob menu-user-attr_primary_key db-num user-id menu-user-code attr-code 
&glob menu-user-call_primary_key db-num menu-user-call-id 
&glob menu-user-call-attr_primary_key db-num menu-user-call-id attr-code 
&glob norm-loss_primary_key id 
&glob nozzle_primary_key obj-type obj-code nozzle-code 
&glob nozzle-attr_primary_key obj-type obj-code nozzle-code attr-code 
&glob nws-doc-hist_primary_key db-num ord-num 
&glob nws-doc-hist-attr_primary_key db-num ord-num attr-code 
&glob nws-last-rec_primary_key uniq-key-rec 
&glob nws-last-rec-attr_primary_key uniq-key-rec attr-code 
&glob nws-outline_primary_key no-id 
&glob obj-date_primary_key obj-type obj-code sys-date 
&glob obj-grp-obj-price_primary_key gop-id gop-db-num obj-type obj-code 
&glob obj-grp-obj-price-attr_primary_key gop-id gop-db-num obj-type obj-code attr-code 
&glob OperServ_primary_key id 
&glob OperServAttr_primary_key id attr-code 
&glob ord-blank_primary_key cli-type cli-code blank-name 
&glob ord-blank-attr_primary_key cli-type cli-code blank-name attr-code 
&glob ord-chain_primary_key db-num rel-id 
&glob ord-chain-attr_primary_key db-num rel-id attr-code 
&glob ord-cons_primary_key cons-code 
&glob ord-cons-attr_primary_key cons-code attr-code 
&glob ord-cons-line-attr_primary_key cons-code gds-code attr-code 
&glob ord-doc_primary_key doc-code 
&glob ord-doc-attr_primary_key doc-code attr-code 
&glob ord-doc-rcv_primary_key doc-code rcv-code 
&glob ord-dtl_primary_key doc-code artic prod-type prod-code node-code 
&glob ord-dtl-attr_primary_key doc-code artic prod-type prod-code node-code attr-code 
&glob ord-dtl-cons_primary_key cons-code artic prod-type prod-code node-code 
&glob ord-dtl-rcv_primary_key doc-code rcv-code artic prod-type prod-code node-code 
&glob ord-gds-cons_primary_key cons-code artic prod-type prod-code 
&glob ord-line_primary_key doc-code artic prod-type prod-code 
&glob ord-line-attr_primary_key doc-code gds-code attr-code 
&glob ord-line-rcv_primary_key doc-code rcv-code artic prod-type prod-code 
&glob ord-rcv-attr_primary_key doc-code rcv-code attr-code 
&glob ord-rcv-line-attr_primary_key doc-code rcv-code gds-code attr-code 
&glob order-doc_primary_key db-num doc-code 
&glob order-doc-attr_primary_key db-num doc-code attr-code 
&glob order-line_primary_key db-num doc-code line-num 
&glob order-line-attr_primary_key db-num doc-code line-num attr-code 
&glob ot-line_primary_key doc-code artic prod-type prod-code sum-type cat-id 
&glob ot-line-attr_primary_key doc-code artic prod-type prod-code sum-type cat-id attr-code 
&glob ot-supp-line_primary_key doc-code cli-type cli-code artic prod-type prod-code sum-type cat-id 
&glob ot-supp-line-attr_primary_key doc-code cli-type cli-code artic prod-type prod-code sum-type cat-id attr-code 
&glob ot-supp-tot_primary_key doc-code cli-type cli-code sum-type cat-id 
&glob ot-supp-tot-attr_primary_key doc-code cli-type cli-code sum-type cat-id attr-code 
&glob ot-tot_primary_key doc-code sum-type cat-id 
&glob ot-tot-attr_primary_key doc-code sum-type cat-id attr-code 
&glob parts_primary_key obj-type obj-code artic prod-type prod-code in-code out-code part-code prt-code 
&glob parts-add_primary_key in-code gds-code part-code prt-code add-doc-code add-gds-code cli-type cli-code host-code contract-code 
&glob parts-add-attr_primary_key in-code gds-code part-code prt-code add-doc-code add-gds-code cli-type cli-code host-code contract-code attr-code 
&glob parts-attr_primary_key in-code gds-code part-code prt-code 
&glob parts-obj-attr_primary_key obj-type obj-code gds-code in-code out-code part-code prt-code attr-code 
&glob parts-root_primary_key doc-code orig-in-code orig-gds-code orig-part-code orig-prt-code in-code gds-code part-code prt-code 
&glob parts-root-attr_primary_key doc-code orig-in-code orig-gds-code orig-part-code orig-prt-code in-code gds-code part-code prt-code attr-code 
&glob parts-supp_primary_key in-code artic prod-type prod-code part-code prt-code 
&glob parts-supp-attr_primary_key in-code artic prod-type prod-code part-code prt-code attr-code 
&glob pay-type_primary_key obj-code 
&glob pay-type-attr_primary_key obj-code attr-code 
&glob payment_primary_key pmnt-code 
&glob payment-attr_primary_key pmnt-code attr-code 
&glob pck-keys_primary_key db-num pack-num uniq-key 
&glob pck-rcvd_primary_key db-num pack-num 
&glob pck-rcvd-attr_primary_key db-num pack-num attr-code 
&glob pck-sent_primary_key db-num pack-num 
&glob pck-sent-attr_primary_key db-num pack-num attr-code 
&glob person_primary_key psn-code 
&glob pl-gds_primary_key obj-type obj-code pl-code gds-code 
&glob pl-gds-attr_primary_key obj-type obj-code pl-code gds-code attr-code 
&glob pl-gds-pump_primary_key obj-type obj-code gds-code pump-code pl-code 
&glob pl-gds-pump-attr_primary_key obj-type obj-code gds-code pump-code pl-code attr-code 
&glob pl-level_primary_key obj-type obj-code pl-code pl-level 
&glob pl-level-attr_primary_key obj-type obj-code pl-code pl-level attr-code 
&glob pl-level-mm_primary_key obj-type obj-code pl-code zone level
&glob pl-pump_primary_key obj-type obj-code pl-code pump-code 
&glob pl-pump-attr_primary_key obj-type obj-code pl-code pump-code attr-code 
&glob pl-pump-nozzle_primary_key obj-type obj-code pl-code pump-code nozzle-code 
&glob pl-pump-nozzle-attr_primary_key obj-type obj-code pl-code pump-code nozzle-code attr-code 
&glob place_primary_key obj-type obj-code pl-code 
&glob place-attr_primary_key obj-type obj-code pl-code attr-code 
&glob place-io_primary_key place-io-code obj-type obj-code 
&glob place-io-attr_primary_key place-io-code obj-type obj-code attr-code 
&glob point-io_primary_key point-code db-num 
&glob point-io-attr_primary_key point-code db-num attr-code 
&glob point-place-rel_primary_key place-io-code obj-type obj-code point-code db-num cli-type cli-code 
&glob point-point-rel_primary_key from-point-code from-db-num to-point-code to-db-num deliv-type-code cond-keep-code 
&glob price-all_primary_key pal-p pal-id pal-db-num 
&glob price-all-attr_primary_key pal-p pal-id pal-db-num attr-code 
&glob price-doc_primary_key doc-num 
&glob price-doc-forming_primary_key plt-id plt-db-num pdf-id pdf-db 
&glob price-doc-forming-attr_primary_key plt-id plt-db-num pdf-id pdf-db attr-code 
&glob price-doc-forming-gds_primary_key plt-id plt-db-num pdf-id pdf-db b-code 
&glob price-doc-forming-gds-qnty_primary_key plt-id plt-db-num pdf-id pdf-db b-code qgr-id qgr-db-num ggr-qnty 
&glob price-doc-forming-gds-sum_primary_key plt-id plt-db-num pdf-id pdf-db b-code sgr-id sgr-db-num ssg-summa 
&glob price-doc-forming-gds-tnv_primary_key plt-id plt-db-num pdf-id pdf-db b-code tog-id tog-db-num ttg-summa 
&glob price-doc-forming-gdsattr_primary_key pdf-id pdf-db plt-id plt-db-num b-code attr-code 
&glob price-list_primary_key doc-num price-type b-code 
&glob price-list-attr_primary_key doc-num price-type b-code attr-code 
&glob price-list-type_primary_key plt-id plt-db-num 
&glob price-list-type-attr_primary_key plt-id plt-db-num attr-code 
&glob price-list-type-cash-pay_primary_key plt-id plt-db-num curr-code cdpay-code 
&glob price-list-type-cassa_primary_key plt-id plt-db-num obj-code pos-type cash-num db-num 
&glob price-list-type-cassa-attr_primary_key plt-id plt-db-num obj-code pos-type cash-num db-num attr-code 
&glob price-list-type-gds-grp_primary_key plt-id plt-db-num node-code 
&glob price-list-type-gds-grp-attr_primary_key plt-id plt-db-num node-code attr-code 
&glob price-list-type-pay-type_primary_key plt-id plt-db-num pay-code 
&glob prod-bc_primary_key b-code b-str 
&glob prod-bc-attr_primary_key b-code b-str attr-code 
&glob prod-bc-db_primary_key b-code b-str db-num 
&glob prod-bc-db-attr_primary_key b-code b-str db-num attr-code 
&glob profile-by-profile_primary_key profile_id child-profile_id 
&glob prog-message_primary_key msg-code 
&glob prog-message-attr_primary_key msg-code attr-code 
&glob prog-message-lang_primary_key msg-code lang-code 
&glob prog-message-lang-attr_primary_key msg-code lang-code attr-code 
&glob promo-schedule_primary_key id db-num 
&glob promo-schedule-week_primary_key id db-num 
&glob PromoAction_primary_key id db-num 
&glob PromoAttr_primary_key tablename p-key 
&glob PromoCriterion_primary_key id db-num 
&glob PromoGift_primary_key id db-num 
&glob PromoGoods_primary_key id db-num 
&glob PromoObject_primary_key id db-num 
&glob prop-head_primary_key dtm-code 
&glob prop-head-attr_primary_key dtm-code attr-code 
&glob prop-map_primary_key dtm-code node-code 
&glob prop-map-attr_primary_key dtm-code node-code attr-code 
&glob prop-ref_primary_key dt-code 
&glob prop-ref-attr_primary_key dt-code attr-code 
&glob prop-ref-call_primary_key call#_id dt-code 
&glob prop-ref-call-attr_primary_key call#_id dt-code attr-code 
&glob prop-ruleset_primary_key codex_id ruleset_id dtm-code 
&glob prop-ruleset-attr_primary_key codex_id ruleset_id dtm-code attr-code 
&glob prop-script_primary_key dtm-code language script-name revis_id 
&glob prop-script-attr_primary_key dtm-code language script-name revis_id attr-code 
&glob prt-obj_primary_key obj-type obj-code prod-type prod-code artic prt-code 
&glob prt-obj-attr_primary_key obj-type obj-code prod-type prod-code artic prt-code attr-code 
&glob pscript-ruleset_primary_key codex_id ruleset_id dtm-code language script-name revis_id 
&glob pscript-ruleset-attr_primary_key codex_id ruleset_id dtm-code language script-name revis_id attr-code 
&glob pump_primary_key obj-type obj-code pump-code 
&glob pump-attr_primary_key obj-type obj-code pump-code attr-code 
&glob pump-nozzle_primary_key obj-type obj-code pump-code nozzle-code 
&glob pump-nozzle-attr_primary_key obj-type obj-code pump-code nozzle-code attr-code 
&glob qnty-group_primary_key qgr-id qgr-db-num 
&glob qnty-group-attr_primary_key qgr-id qgr-db-num attr-code 
&glob qnty-in-qnty-group_primary_key qgr-id qgr-db-num ggr-qnty 
&glob qnty-in-qnty-group-attr_primary_key qgr-id qgr-db-num ggr-qnty attr-code 
&glob rang-abc-def_primary_key raad-id db-num 
&glob rang-abc-def-attr_primary_key raad-id db-num attr-code 
&glob rang-abc-def-obj_primary_key raad-id db-num obj-type obj-code 
&glob rang-abc-def-obj-attr_primary_key raad-id db-num obj-type obj-code attr-code 
&glob rang-xyz-def_primary_key raxd-id db-num 
&glob rang-xyz-def-attr_primary_key raxd-id db-num attr-code 
&glob rang-xyz-def-obj_primary_key raxd-id db-num obj-type obj-code 
&glob rang-xyz-def-obj-attr_primary_key raxd-id db-num obj-type obj-code attr-code 
&glob rcs-attr_primary_key retail_attr_type 
&glob rcs-chkbody_primary_key chk_id tov 
&glob rcs-chkhead_primary_key id 
&glob rcs-city_primary_key id 
&glob rcs-clients_primary_key id 
&glob rcs-country_primary_key id 
&glob rcs-destn_primary_key destination_rowid 
&glob rcs-docbody_primary_key doc_head_id tov 
&glob rcs-dochead_primary_key id 
&glob rcs-mark_primary_key id 
&glob rcs-pack_primary_key id 
&glob rcs-place_primary_key id 
&glob rcs-retail1action_primary_key action_id 
&glob rcs-retail1attr_primary_key id 
&glob rcs-retail1bank_primary_key id 
&glob rcs-retail1barcode_primary_key id 
&glob rcs-retail1bill_primary_key id 
&glob rcs-retail1billitem_primary_key bill_id product_id 
&glob rcs-retail1convolution_primary_key site_id docdate tov 
&glob rcs-retail1delete_primary_key name id 
&glob rcs-retail1fortuneproduct_primary_key action_id retail_product_id 
&glob rcs-retail1price_primary_key price_id 
&glob rcs-retail1priceitem_primary_key price_id id 
&glob rcs-retail1product_primary_key id 
&glob rcs-retail1subject_primary_key id 
&glob rcs-shops_primary_key id 
&glob recipe_primary_key recipe-code 
&glob recipe-develop_primary_key recipe-code doc-code gds-code 
&glob recipe-gds_primary_key recipe-code prod-type prod-code artic 
&glob regions_primary_key reg-code 
&glob regions-attr_primary_key reg-code attr-code 
&glob rename-fld_primary_key rename-key old-value rename-ord 
&glob rename-fld-attr_primary_key rename-key old-value rename-ord attr-code 
&glob rep_primary_key rep-num 
&glob rep-line_primary_key rep-num code1 
&glob res-lang_primary_key res-type res-code res-sub-code lang-code 
&glob res-lang-attr_primary_key res-type res-code res-sub-code lang-code attr-code 
&glob resource_primary_key res-type res-code res-sub-code 
&glob resource-attr_primary_key res-type res-code res-sub-code attr-code 
&glob route_primary_key db-num last-pack tbl-ord 
&glob route-attr_primary_key db-num last-pack tbl-ord attr-code 
&glob route-dump_primary_key dump-ord rec-ord 
&glob route-dump-attr_primary_key dump-ord rec-ord attr-code 
&glob route-dump-link_primary_key dump-ord rec-ord uniq-key-rec 
&glob rp-by-call_primary_key call#_id profile_id once-more 
&glob rp-by-call-attr_primary_key call#_id profile_id once-more attr-code 
&glob rp-rule-param_primary_key profile_id codex_id ruleset_id rp_order_id rule_id rule-param-name 
&glob rp-rule-param-attr_primary_key profile_id codex_id ruleset_id rp_order_id rule_id rule-param-name attr-code 
&glob rpt-option_primary_key rpt-name rpt-code user-db-num user-id 
&glob rpt-option-attr_primary_key rpt-name rpt-code user-db-num user-id attr-code 
&glob rule_primary_key rule_id 
&glob rule-attr_primary_key rule_id attr-code 
&glob rule-by-call_primary_key call#_id codex_id ruleset_id order_id 
&glob rule-by-call-attr_primary_key call#_id codex_id ruleset_id order_id attr-code 
&glob rule-by-profile_primary_key profile_id codex_id ruleset_id rp_order_id rule_id 
&glob rule-by-profile-attr_primary_key profile_id codex_id ruleset_id rp_order_id rule_id attr-code 
&glob rule-by-set_primary_key codex_id ruleset_id rule_id 
&glob rule-by-set-attr_primary_key codex_id ruleset_id rule_id attr-code 
&glob rule-call-param_primary_key call#_id codex_id ruleset_id order_id param-name p-index 
&glob rule-call-param-attr_primary_key call#_id codex_id ruleset_id order_id param-name p-index attr-code 
&glob rule-i-script_primary_key root_rule_id i-script-name script_id 
&glob rule-i-script-attr_primary_key root_rule_id i-script-name script_id attr-code 
&glob rule-process_primary_key pchain-type pchain-id start-from link-id 
&glob rule-profile_primary_key profile_id 
&glob rule-profile-attr_primary_key profile_id attr-code 
&glob rule-script_primary_key script_id language 
&glob rule-script-attr_primary_key script_id language attr-code 
&glob rule-trans-memo_primary_key call#_id codex_id ruleset_id order_id instance#_id trans_num 
&glob rule-trans-memo-attr_primary_key call#_id codex_id ruleset_id order_id instance#_id trans_num attr-code 
&glob ruledict_primary_key entry-id 
&glob ruledict-attr_primary_key entry-id attr-code 
&glob ruledict-param_primary_key entry-id param-num 
&glob ruledict-param-attr_primary_key entry-id param-num attr-code 
&glob ruleset_primary_key codex_id ruleset_id 
&glob ruleset-attr_primary_key codex_id ruleset_id attr-code 
&glob rvs-doc_primary_key rvs-code 
&glob rvs-doc-attr_primary_key rvs-code attr-code 
&glob rvs-line_primary_key rvs-code obj-type obj-code pl-code gds-code 
&glob rvs-line-attr_primary_key rvs-code obj-type obj-code pl-code gds-code attr-code 
&glob rvs-line-pump_primary_key rvs-code obj-type obj-code pl-code gds-code pump-code nozzle-code 
&glob rvs-line-pump-attr_primary_key rvs-code obj-type obj-code pl-code gds-code pump-code nozzle-code attr-code 
&glob rvs-pump_primary_key rvs-code obj-type obj-code pump-code nozzle-code 
&glob rvs-pump-attr_primary_key rvs-code obj-type obj-code pump-code nozzle-code attr-code 
&glob s-coeff_primary_key gds-code host-code obj-type obj-code s-date 
&glob s-coeff-attr_primary_key gds-code host-code obj-type obj-code s-date attr-code 
&glob sale-doc_primary_key inkas-code storage doc-code 
&glob sale-doc-attr_primary_key inkas-code storage doc-code attr-code 
&glob scales_primary_key db-num scales-num 
&glob scales-attr_primary_key db-num scales-num attr-code 
&glob scales-gds_primary_key db-num scales-num PLU-code 
&glob scales-gds-attr_primary_key db-num scales-num PLU-code attr-code 
&glob scales-grp_primary_key db-num node-code scales-num 
&glob scales-grp-attr_primary_key db-num node-code scales-num attr-code 
&glob schedule_primary_key cre-db-num task-type task-num 
&glob schedule-attr_primary_key cre-db-num task-type task-num attr-code 
&glob schet-fact-doc_primary_key db-num doc-code 
&glob schet-fact-doc-attr_primary_key db-num doc-code attr-code 
&glob schet-fact-line_primary_key doc-code db-num line-num 
&glob schet-fact-line-attr_primary_key doc-code db-num line-num attr-code 
&glob season_primary_key sea-code db-num 
&glob season-attr_primary_key sea-code db-num attr-code 
&glob sert_primary_key cli-type cli-code sert-code 
&glob sert-attr_primary_key cli-type cli-code sert-code attr-code 
&glob sert-join_primary_key cli-type cli-code sert-code b-code 
&glob sert-join-attr_primary_key cli-type cli-code sert-code b-code attr-code 
&glob shift-attr_primary_key obj-type obj-code shift-date shift-num attr-code 
&glob shift-cash_primary_key obj-type obj-code cash-num shift-date shift-num src-shift-name 
&glob shift-cash-attr_primary_key obj-type obj-code cash-num shift-date shift-num src-shift-name attr-code 
&glob shift-obj_primary_key obj-type obj-code shift-date shift-num 
&glob shift-obj-attr_primary_key obj-type obj-code shift-date shift-num attr-code 
&glob shift-period_primary_key obj-type obj-code shift-date shift-num period-num pl-code gds-code
&glob shift-staff_primary_key obj-type obj-code shift-date shift-num next-shift psn-num 
&glob shift-staff-attr_primary_key obj-type obj-code shift-date shift-num next-shift psn-num attr-code 
&glob shop_primary_key obj-code 
&glob some-lk_primary_key resource#_id lk-type 
&glob some-lk-attr_primary_key resource#_id lk-type attr-code 
&glob sr-izmerenia_primary_key node-code 
&glob sr-izmerenia-attr_primary_key node-code attr-code 
&glob staff_primary_key role role-level work-place staff-code date-start 
&glob staff-attr_primary_key role role-level work-place staff-code date-start attr-code 
&glob stk-line_primary_key obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id 
&glob stk-line-attr_primary_key obj-type obj-code artic prod-type prod-code fact-order sum-type cat-id attr-code 
&glob stk-supp-line_primary_key obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id 
&glob stk-supp-line-attr_primary_key obj-type obj-code cli-type cli-code artic prod-type prod-code fact-order sum-type cat-id attr-code 
&glob stk-supp-tot_primary_key obj-type obj-code cli-type cli-code fact-order sum-type cat-id 
&glob stk-supp-tot-attr_primary_key obj-type obj-code cli-type cli-code fact-order sum-type cat-id attr-code 
&glob stk-tot_primary_key obj-type obj-code fact-order sum-type cat-id 
&glob stk-tot-attr_primary_key obj-type obj-code fact-order sum-type cat-id attr-code 
&glob stop-list_primary_key classif-type stop-list-code 
&glob stop-list-attr_primary_key classif-type stop-list-code attr-code 
&glob stop-list-line_primary_key classif-type stop-list-code line-num 
&glob stop-list-line-attr_primary_key classif-type stop-list-code line-num attr-code 
&glob store_primary_key obj-code 
&glob sum-group_primary_key sgr-id sgr-db-num 
&glob sum-group-attr_primary_key sgr-id sgr-db-num attr-code 
&glob sum-grp_primary_key grp-code 
&glob sum-grp-attr_primary_key grp-code attr-code 
&glob sum-grp-obj_primary_key obj-type obj-code grp-code 
&glob sum-grp-obj-attr_primary_key obj-type obj-code grp-code attr-code 
&glob sum-in-sum-group_primary_key sgr-id sgr-db-num ssg-summa 
&glob sum-in-sum-group-attr_primary_key sgr-id sgr-db-num ssg-summa attr-code 
&glob sys-ctrl_primary_key db-num 
&glob sys-ctrl-attr_primary_key db-num attr-code 
&glob sysconf_primary_key host-code 
&glob sysconf-attr_primary_key host-code attr-code 
&glob tare_primary_key tare-code 
&glob tax_primary_key tax-code 
&glob tax-attr_primary_key tax-code attr-code 
&glob tax-rate_primary_key tax-code rate-code 
&glob tax-rate-attr_primary_key tax-code rate-code attr-code 
&glob tax-rate-gds_primary_key gds-code tax-code host-code obj-type obj-code fact-order 
&glob tax-rate-gds-attr_primary_key gds-code tax-code host-code obj-type obj-code fact-order attr-code 
&glob tax-rate-gds-grp_primary_key node-code tax-code host-code obj-type obj-code 
&glob tax-rate-gds-grp-attr_primary_key node-code tax-code host-code obj-type obj-code attr-code 
&glob tax-rate-value_primary_key tax-code rate-code host-code obj-type obj-code fact-order 
&glob tax-rate-value-attr_primary_key tax-code rate-code host-code obj-type obj-code fact-order attr-code 
&glob tax-units_primary_key type tax-code 
&glob tax-units-attr_primary_key type tax-code attr-code 
&glob tech-prol-pwd_primary_key id 
&glob thbj-attr_primary_key obj-type obj-code upper-prop-code prop-code 
&glob tmp-sale_primary_key tmp-code 
&glob tmp-sale-attr_primary_key tmp-code attr-code 
&glob tmp-sale-dtl_primary_key tmp-code artic prod-type prod-code node-code 
&glob tmp-sale-dtl-attr_primary_key tmp-code artic prod-type prod-code node-code attr-code 
&glob tmp-sale-gds_primary_key tmp-code artic prod-type prod-code 
&glob tmp-sale-gds-attr_primary_key tmp-code artic prod-type prod-code attr-code 
&glob tnv-in-turnover-group_primary_key tog-id tog-db-num ttg-summa 
&glob tnv-in-turnover-group-attr_primary_key tog-id tog-db-num ttg-summa attr-code 
&glob tnved-head_primary_key tnved-code 
&glob tnved-head-attr_primary_key tnved-code attr-code 
&glob tnved-item_primary_key tnved-code tnved-item-code 
&glob tnved-item-attr_primary_key tnved-code tnved-item-code attr-code 
&glob tran-fuel_primary_key db-num uuid uuid-cheq 
&glob trn-doc_primary_key doc-code 
&glob trn-doc-sum_primary_key doc-code sum-type 
&glob trn-reason_primary_key reason-code 
&glob trn-reason-host_primary_key host-code ext-doc-type hold-doc 
&glob trn-reason-obj_primary_key obj-type obj-code ext-doc-type hold-doc 
&glob trn-rsn-attr_primary_key reason-code attr-code 
&glob turnover-buyer_primary_key obj-type obj-code cli-type cli-code ext-doc-type sum-type fact-order 
&glob turnover-buyer-attr_primary_key obj-type obj-code cli-type cli-code ext-doc-type sum-type fact-order attr-code 
&glob turnover-buyer-gds_primary_key obj-type obj-code cli-type cli-code ext-doc-type sum-type gds-code fact-order 
&glob turnover-buyer-gds-attr_primary_key obj-type obj-code cli-type cli-code ext-doc-type sum-type fact-order gds-code attr-code 
&glob turnover-buyer-main_primary_key cli-type cli-code obj-type obj-code 
&glob turnover-buyer-main-attr_primary_key cli-type cli-code obj-type obj-code attr-code 
&glob turnover-group_primary_key tog-id tog-db-num 
&glob turnover-group-attr_primary_key tog-id tog-db-num attr-code 
&glob units_primary_key unit-name 
&glob units-attr_primary_key unit-name attr-code 
&glob upgrade_primary_key db-num version-num 
&glob upgrade-attr_primary_key db-num version-num attr-code 
&glob user-account_primary_key user-id 
&glob user-account-attr_primary_key user-id attr-code 
&glob user-conn_primary_key connection_id 
&glob user-conn-attr_primary_key connection_id attr-code 
&glob user-context-history_primary_key db-num user-id user-context-history-id 
&glob user-context-history-attr_primary_key db-num user-id user-context-history-id attr-code 
&glob user-host_primary_key db-num user-id host-code 
&glob user-host-attr_primary_key db-num user-id host-code attr-code 
&glob user-login_primary_key db-num user-id 
&glob user-login-action-item_primary_key db-num action-head-code user-login-item-code 
&glob user-login-action-item-attr_primary_key db-num action-head-code user-login-item-code attr-code 
&glob user-login-action-role_primary_key db-num action-head-code user-login-role-code 
&glob user-login-action-role-attr_primary_key db-num action-head-code user-login-role-code attr-code 
&glob user-login-attr_primary_key db-num user-id attr-code 
&glob user-menu-group_primary_key db-num user-id user-menu-group-code 
&glob user-menu-group-attr_primary_key db-num user-id user-menu-group-code attr-code 
&glob user-obj_primary_key db-num user-id obj-type obj-code 
&glob user-obj-attr_primary_key db-num user-id obj-type obj-code attr-code 
&glob user-window-attr_primary_key db-num user-id user-window-name attr-code 
&glob usr-flt_primary_key user-name call-point 
&glob usr-flt-attr_primary_key user-name call-point attr-code 
&glob usr-stko_primary_key user-name obj-type obj-code 
&glob usr-stko-attr_primary_key user-name obj-type obj-code attr-code 
&glob utd_primary_key db-num doc-id 
&glob utd-attr_primary_key db-num doc-id attr-code 
&glob utd-err_primary_key db-num doc-id CheckType CodeErr CheckObj reckey 
&glob utd-err-attr_primary_key db-num doc-id CheckType CodeErr CheckObj reckey attr-code 
&glob utd-lines_primary_key db-num doc-id LineNum 
&glob utd-lines-attr_primary_key db-num doc-id LineNum attr-code 
&glob utd-marking-lines_primary_key db-num doc-id LineNum mark 
&glob utd-marking-lines-attr_primary_key db-num doc-id LineNum mark attr-code 
&glob var-deliv-gr-per-val_primary_key deliv-type-code deliv-subj-code obj-type obj-code gr-per-val-code 
&glob var-deliv-gr-per-val-attr_primary_key deliv-type-code deliv-subj-code obj-type obj-code gr-per-val-code attr-code 
&glob variant-delivery_primary_key deliv-type-code deliv-subj-code obj-type obj-code 
&glob variant-delivery-attr_primary_key deliv-type-code deliv-subj-code obj-type obj-code attr-code 
&glob varianty-delivery-gds-obj_primary_key gds-code obj-type obj-code deliv-type-code deliv-subj-code 
&glob vsd_primary_key ID db-num 
&glob vsd-attr_primary_key ID db-num attr-code 
&glob wealth_primary_key wth-code 
&glob wealth-attr_primary_key wth-code attr-code 
&glob who-lk_primary_key resource#_id lk-type corr-user-db-num chip-num 
&glob who-lk-attr_primary_key resource#_id lk-type corr-user-db-num chip-num attr-code 
&glob whole-send-news_primary_key db-num-cr uniq-key-rec send-db-num 
&glob wi-mode_primary_key mode-type mode-id 
&glob wi-mode-attr_primary_key mode-type mode-id attr-code 
&glob wth-doc_primary_key doc-code 
&glob wth-doc-attr_primary_key doc-code attr-code 
&glob wth-dtl_primary_key doc-code wth-code w-p-code par-code 
&glob wth-dtl-attr_primary_key doc-code wth-code w-p-code par-code attr-code 
&glob wth-gds_primary_key wth-code gds-code 
&glob wth-gds-attr_primary_key wth-code gds-code attr-code 
&glob wth-line_primary_key doc-code wth-code w-p-code 
&glob wth-line-attr_primary_key doc-code wth-code w-p-code attr-code 
&glob wth-obj_primary_key obj-type obj-code wth-code 
&glob wth-obj-attr_primary_key obj-type obj-code wth-code attr-code 
&glob wth-par_primary_key wth-code par-code 
&glob wth-par-attr_primary_key wth-code par-code attr-code 
&glob wth-parts_primary_key obj-type obj-code w-p-code wth-code par-code in-code out-code ser-code db-num fact-rangeFrom fact-rangeTo 
&glob wth-parts-attr_primary_key obj-type obj-code w-p-code wth-code par-code in-code out-code ser-code db-num fact-rangeFrom fact-rangeTo attr-code 
&glob wth-place_primary_key host-code obj-type obj-code w-p-code 
&glob wth-place-attr_primary_key host-code obj-type obj-code w-p-code attr-code 
&glob wth-pobj_primary_key obj-type obj-code w-p-code wth-code 
&glob wth-pobj-attr_primary_key obj-type obj-code w-p-code wth-code attr-code 
&glob wth-ser_primary_key ser-code db-num 
&glob wth-ser-attr_primary_key ser-code db-num attr-code 
&glob Xattr_primary_key GroupObj-code Xattr-Code 
&glob xGroupObj_primary_key GroupObj-Code 
&glob xstatus_primary_key GroupObj-code status-code 
&glob xyz-analysis_primary_key xyz-id db-num 
&glob xyz-analysis-attr_primary_key xyz-id db-num xyza-attr-code 
&glob xyz-analysis-cli_primary_key xyz-id db-num cli-type cli-code 
&glob xyz-analysis-cli-attr_primary_key xyz-id db-num cli-type cli-code 
&glob xyz-analysis-doc_primary_key xyz-id db-num xyzd-ext-doc-type 
&glob xyz-analysis-doc-attr_primary_key xyz-id db-num xyzd-ext-doc-type attr-code 
&glob xyz-analysis-gds-obj_primary_key xyz-id db-num gds-code obj-type obj-code 
&glob xyz-analysis-gds-obj-attr_primary_key xyz-id db-num gds-code obj-type obj-code xaog-attr-code 
&glob xyz-analysis-goods_primary_key xyz-id db-num gds-code 
&glob xyz-analysis-goods-attr_primary_key xyz-id db-num gds-code xyag-attr-code 
&glob xyz-analysis-grp_primary_key xyz-id db-num grp-code 
&glob xyz-analysis-grp-attr_primary_key xyz-id db-num grp-code xyag-attr-code 
&glob xyz-analysis-obj_primary_key xyz-id db-num obj-type obj-code 
&glob xyz-analysis-obj-attr_primary_key xyz-id db-num obj-type obj-code attr-code 
&glob xyz-analysis-period_primary_key xyz-id db-num xyzp-start xyzp-end 
&glob xyz-analysis-period-attr_primary_key xyz-id db-num xyzp-start xyzp-end attr-code 
&glob xyz-analysis-prod_primary_key xyz-id db-num prod-type prod-code 
&glob xyz-analysis-prod-attr_primary_key xyz-id db-num prod-type xyag-attr-code 
