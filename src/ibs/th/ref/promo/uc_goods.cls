 
/*------------------------------------------------------------------------
   File        : uc_Goods
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : mshavlov
   Created     : Tue Jul 31 13:00:01 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Windows.UserControl.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ibs.th.ref.promo.uc_Goods INHERITS UserControl: 
  { cmp/str-glbl.i class }     
  define private variable bccodeDataGridViewTextBoxColumn  as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
    define private variable button7 as System.Windows.Forms.Button no-undo.
  define private variable Chang                            as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
  define private variable changDataGridViewCheckBoxColumn  as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
  define private variable bindGoods                        as Progress.Data.BindingSource                     no-undo.
  DEFINE PRIVATE VARIABLE button2                          AS System.Windows.Forms.Button                     NO-UNDO.
  DEFINE PRIVATE VARIABLE button1                          AS System.Windows.Forms.Button                     NO-UNDO.
  define private variable button3                          as System.Windows.Forms.Button                     no-undo.
  define private variable button6                          as System.Windows.Forms.Button                     no-undo.
  define private variable button5                          as System.Windows.Forms.Button                     no-undo.
  DEFINE PRIVATE VARIABLE components                       AS System.ComponentModel.IContainer                NO-UNDO.
  DEFINE PRIVATE VARIABLE dataGridView1                    AS System.Windows.Forms.DataGridView               NO-UNDO.
  define private variable gdscodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
  define private variable gdsName                          as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
  define private variable gdsNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
  define private variable qntyDataGridViewTextBoxColumn    as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
  define private variable priceDataGridViewTextBoxColumn   as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
  define private variable nameSetDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn  no-undo.
    define private variable splitContainer1 as System.Windows.Forms.SplitContainer no-undo.
  DEFINE PRIVATE VARIABLE tableLayoutPanel1                AS System.Windows.Forms.TableLayoutPanel           NO-UNDO.
  DEFINE PRIVATE VARIABLE label1                           AS System.Windows.Forms.Label                      NO-UNDO.
  define         variable mCrit                            as logical                                         no-undo.
  define         variable PromoSet                         as logical                                         no-undo.
  define         variable PromoSetFix                      as logical                                         no-undo.
  define         variable PromoSetGoods                    as logical                                         no-undo.
  define         variable Promovisa                        as logical                                         no-undo.
  define         variable PromoBarCode                     as logical                                         no-undo .
  define         variable PromoBarCodeFix                  as logical                                         no-undo .
  define         variable PromoGoodsApplFix                as logical                                         no-undo .
  define         variable PromoGoodsFix                    as logical                                         no-undo .
  
  define property pCrit as logical no-undo
    private get.

    set(input iCrit as logical):
      mCrit = iCrit.
      this-object:PromoSet = no.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      this-object:PromoBarCodeFix = no.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.
  define property pPromoSet as logical no-undo
    private get.
    set(input iPromoSet as logical):
      this-object:mCrit = no.
      PromoSet = iPromoSet.
      this-object:PromoSetFix = no.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      this-object:PromoBarCodeFix = no.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.
  define property pPromoSetFix as logical no-undo
    private get.
    set(input iPromoSetFix as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      PromoSetFix = iPromoSetFix.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      this-object:PromoBarCodeFix = no.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.    
  define property pPromoSetGoods as logical no-undo
    private get.
    set(input iPromoSetGoods as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      this-object:PromoSetFix = no.
      PromoSetGoods = iPromoSetGoods.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      this-object:PromoBarCodeFix = no.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.
  define property pPromovisa as logical no-undo
    private get.
    set(input iPromovisa as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      this-object:PromoSetFix = no.
      this-object:PromoSetGoods = no.
      Promovisa = iPromovisa.
      this-object:PromoBarCodeFix = no.
      this-object:PromoBarCode = no.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.
  define property pPromoBarCode as logical no-undo
    private get.
    set(input iPromobarcode as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      this-object:PromoSetFix = no.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCodeFix = no.
      PromoBarCode = iPromobarcode.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.     
  define property pPromoBarCodeFix as logical no-undo
    private get.
    set(input iPromobarcodeFix as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      this-object:PromoSetFix = no.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      PromoBarCodeFix = iPromobarcodeFix.
      this-object:PromoGoodsApplFix = no .
      this-object:PromoGoodsFix = no .
    end.     
  define property pPromoGoodsApplFix as logical no-undo
    private get.
    set(input iPromoGoodsApplFix as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      this-object:PromoSetFix = no.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      this-object:PromoBarCodeFix = no.
      PromoGoodsApplFix = iPromoGoodsApplFix.
      this-object:PromoGoodsFix = no .
    end.      
  define property pPromoGoodsFix as logical no-undo
    private get.
    set(input iPromoGoodsFix as logical):
      this-object:mCrit = no.
      this-object:PromoSet = no.
      this-object:PromoSetFix = no.
      this-object:PromoSetGoods = no.
      this-object:Promovisa = no.
      this-object:PromoBarCode = no.
      this-object:PromoBarCodeFix = no.
      PromoGoodsFix = iPromoGoodsFix.
      this-object:PromoGoodsApplFix = no .
    end.  
  define private variable mBind as character no-undo.
    
  {ibs/th/ref/promo/promo_trg_heder.i }  
      
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void button1_Click( input sender as System.Object, input e as System.EventArgs ):
    bindGoods:Assign(). 
    m-promo-trg:addgds(mBind).
    bindGoods:handle:query-open.
    bindGoods:RefreshAll().
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void button2_Click( input sender as System.Object, input e as System.EventArgs ):
    m-promo-trg:delgds(mBind).
    bindGoods:handle:query-open.
    bindGoods:RefreshAll().
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void button6_Click( input sender as System.Object, input e as System.EventArgs ):

    m-promo-trg:printgds(mBind).
    if mBind = "PromoBarCode" then bindGoods:RefreshAll().
    if mBind = "PromoGoodsFix" then bindGoods:RefreshAll().
    return.

  end method.





	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void click_button7( input sender as System.Object, input e as System.EventArgs ):
     define variable vPos as integer no-undo.
      vPos = bindGoods:position.
        m-promo-trg:changeRowAll(yes).
        bindGoods:Refreshall().
        bindGoods:position = vPos.		
		return.

	end method.




  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void dataGridView1_CellContentClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellEventArgs ):

    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void dataGridView1_CellMouseClick( input sender as System.Object, input e as System.Windows.Forms.DataGridViewCellMouseEventArgs ):
    bindGoods:Assign().
    if promoset or promosetfix
      then
      m-promo-trg:PublicEventForForm("changePromoset", "").
    if PromoBarCode or PromoBarCodeFix then 
    do:
      m-promo-trg:ChangBarCode(no).
	
    end.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void dataGridView1_RowsAdded( input sender as System.Object, input e as System.Windows.Forms.DataGridViewRowsAddedEventArgs ):
    /*if PromoSet 
    then
        m-promo-trg:addPromoSet().*/ 
    return.

  end method.

  method Public VOID SetBind( ):
    define variable vLable as character no-undo.
    if mCrit 
      then assign
        mBind  = "PromoGoodsCrit"
        vLable = "Независимые условия"
        .
    else if PromoSet 
        then assign
          mBind  = "PromoSet"
          vLable = "Промо набор"
          .
      else if PromoSetFix 
          then assign
            mBind  = "PromoSet"
            vLable = "Промо набор"
            .
        else if PromoSetgoods 
            then assign
              mBind  = "PromoSetgoods"
              vLable = "Товары"
              .
          else if Promovisa
              then  assign
                mBind  = "PromoCardsBin"
                vLable = "Карты Visa"
                .
            else if PromoBarCode
                then assign
                  mBind  = "PromoBarCode"
                  vLable = "Штрих коды"        
                  .
              else if PromoBarCodeFix
                  then assign
                    mBind  = "PromoBarCode"
                    vLable = "Штрих коды"        
                    .        
                else if PromoGoodsApplFix
                    then assign
                      mBind  = "PromoGoodsApplFix"
                      vLable = "Товары"        
                      . 
                  else if PromoGoodsFix
                  then assign
                  mBind = "PromoGoodsFix"
                  vLable = "Товары"
                  .    
                  else assign
                      mBind  = "PromoGoodsAppl"
                      vLable = "Товары"
                      .
 
    SetBind(no).
    label1:text = vLable.

    if PromoSet 
      then assign
        THIS-OBJECT:dataGridView1:Columns[0]:Visible = no
        THIS-OBJECT:dataGridView1:Columns[1]:Visible = no
        THIS-OBJECT:dataGridView1:Columns[2]:Visible = no
        THIS-OBJECT:dataGridView1:Columns[3]:Visible = yes
        THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
        THIS-OBJECT:dataGridView1:Columns[5]:Visible = yes
        THIS-OBJECT:dataGridView1:Columns[4]:HeaderText = "Скидка, %"
        THIS-OBJECT:dataGridView1:Columns[5]:HeaderText = "Количество"
        THIS-OBJECT:dataGridView1:Columns[6]:Visible = no
        this-object:splitContainer1:Panel1Collapsed  = yes
        this-object:button7:Visible                  = no
        /* this-object:button1:Visible = no
        this-object:button2:Visible = no */
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
        .
    else if PromoSetFix 
        then assign
          THIS-OBJECT:dataGridView1:Columns[0]:Visible    = no
          THIS-OBJECT:dataGridView1:Columns[1]:Visible    = no
          THIS-OBJECT:dataGridView1:Columns[2]:Visible    = no
          THIS-OBJECT:dataGridView1:Columns[3]:Visible    = yes
          THIS-OBJECT:dataGridView1:Columns[4]:Visible    = no
          THIS-OBJECT:dataGridView1:Columns[5]:HeaderText = "Количество"
          THIS-OBJECT:dataGridView1:Columns[5]:Visible    = yes
          THIS-OBJECT:dataGridView1:Columns[6]:Visible    = no
          this-object:splitContainer1:Panel1Collapsed  = yes
          this-object:button7:Visible                  = no
          /* this-object:button1:Visible = no
          this-object:button2:Visible = no */
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
          .        
      else if Promovisa then assign
            THIS-OBJECT:dataGridView1:Columns[0]:Visible    = no
            THIS-OBJECT:dataGridView1:Columns[1]:Visible    = no
            THIS-OBJECT:dataGridView1:Columns[2]:Visible    = no
            THIS-OBJECT:dataGridView1:Columns[3]:Visible    = yes
            THIS-OBJECT:dataGridView1:Columns[3]:HeaderText = "Бины карт"
            THIS-OBJECT:dataGridView1:Columns[4]:Visible    = no
            THIS-OBJECT:dataGridView1:Columns[5]:Visible    = no
            THIS-OBJECT:dataGridView1:Columns[6]:Visible    = no
            this-object:button7:Visible                  = no
                        
            this-object:splitContainer1:Panel1Collapsed  = yes
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
            .
        else if PromoBarCode then
            assign
              THIS-OBJECT:dataGridView1:Columns[0]:Visible = yes
              THIS-OBJECT:dataGridView1:Columns[1]:Visible = yes
              THIS-OBJECT:dataGridView1:Columns[2]:Visible = yes
              THIS-OBJECT:dataGridView1:Columns[3]:Visible = no
              THIS-OBJECT:dataGridView1:Columns[4]:Visible = no
              THIS-OBJECT:dataGridView1:Columns[5]:Visible = no
              THIS-OBJECT:dataGridView1:Columns[6]:Visible = yes
            
              this-object:button3:Visible                  = no
            
              this-object:button5:Visible                  = yes
              this-object:button6:Visible                  = yes
              this-object:splitContainer1:Panel1Collapsed  = yes
              this-object:button7:Visible                  = no
            
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
              .        
          else if PromoBarCodeFix then
              assign
                THIS-OBJECT:dataGridView1:Columns[0]:Visible = yes
                THIS-OBJECT:dataGridView1:Columns[1]:Visible = yes
                THIS-OBJECT:dataGridView1:Columns[2]:Visible = yes
                THIS-OBJECT:dataGridView1:Columns[3]:Visible = no
                THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
                THIS-OBJECT:dataGridView1:Columns[5]:Visible = no
                THIS-OBJECT:dataGridView1:Columns[6]:Visible = yes
            
                this-object:button3:Visible                  = no
                this-object:button5:Visible                  = yes
                this-object:button6:Visible                  = yes
                this-object:splitContainer1:Panel1Collapsed  = yes
                this-object:button7:Visible                  = no
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
                . 
            else if PromoGoodsApplFix then  
                assign
                  THIS-OBJECT:dataGridView1:Columns[0]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[1]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[2]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[3]:Visible = no
                  THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[5]:Visible = no
                  THIS-OBJECT:dataGridView1:Columns[6]:Visible = no
            
                  this-object:button3:Visible                  = no
                  this-object:button5:Visible                  = no
                  this-object:button6:Visible                  = no
                  this-object:splitContainer1:Panel1Collapsed  = yes
                  this-object:button7:Visible                  = no
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
                  . 
            else if PromoGoodsFix then  
                assign
                  THIS-OBJECT:dataGridView1:Columns[0]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[1]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[2]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[3]:Visible = no
                  THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
                  THIS-OBJECT:dataGridView1:Columns[5]:Visible = no
                  THIS-OBJECT:dataGridView1:Columns[6]:Visible = no
            
                  this-object:button3:Visible                  = no
                  this-object:button5:Visible                  = no
                  this-object:button6:Visible                  = yes
                  this-object:splitContainer1:Panel1Collapsed  = no
                  this-object:button7:Visible                  = yes
           // THIS-OBJECT:dataGridView1:Columns[4]:Visible = yes
                  . 
                 
  end.
  method Public VOID SetBind(input iflag as logical ):
    bindGoods:handle = m-promo-trg:getQuery(mBind,iflag).
    setDisable(m-promo-trg:modeVIEW). 
    if iflag 
      then
      bindGoods:RefreshAll().
            
  end method.
  method Public VOID LocalEvent(input iEvent as character, input iEventParam as character  ):
    if iEvent eq "changePromoSet" and promosetgoods
      then
      SetBind(yes).
    else if iEvent eq "showDiscontForset" and promoset
        then assign 
          THIS-OBJECT:dataGridView1:Columns[5]:HeaderText = "Скидка, %"
          THIS-OBJECT:dataGridView1:Columns[5]:Visible    = yes .
      else if iEvent eq "showPrice" and not promoset and not mCrit and not promosetgoods
          then assign 
            THIS-OBJECT:dataGridView1:Columns[5]:HeaderText = "Цена, руб"
            THIS-OBJECT:dataGridView1:Columns[5]:Visible    = yes .
  end.
  method public VOID setDisable(input iModeView as logical  ):
    assign
      button1:enabled                               = not iModeview 
      button2:enabled                               = not iModeview
      button3:enabled                               = not iModeview

      button5:enabled                               = not iModeview
      THIS-OBJECT:dataGridView1:Columns[3]:ReadOnly = iModeview
      THIS-OBJECT:dataGridView1:Columns[4]:ReadOnly = iModeview
      THIS-OBJECT:dataGridView1:Columns[5]:ReadOnly = iModeview
            
         //   THIS-OBJECT:dataGridView1:Columns[6]:ReadOnly = pMode
      .
  end.
  
         
  CONSTRUCTOR PUBLIC uc_Goods (  ):
        
        
    SUPER().
    InitializeComponent().
    THIS-OBJECT:ComponentsCollection:ADD(THIS-OBJECT:components).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.

  END CONSTRUCTOR.

  METHOD PRIVATE VOID InitializeComponent(  ):
        
    /* NOTE: The following method is automatically generated.
        
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
        
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
        this-object:components = new System.ComponentModel.Container().
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable tableDesc2 as Progress.Data.TableDesc no-undo.
        tableDesc2 = new Progress.Data.TableDesc("tt-PromoGoods").
        @VisualDesigner.FormMember (NeedsInitialize="true").
        define variable resources as Progress.Util.ResourceManager no-undo.
        resources = new Progress.Util.ResourceManager("ibs.th.ref.promo.uc_Goods").
        this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
        this-object:dataGridView1 = new System.Windows.Forms.DataGridView().
        this-object:changDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
        this-object:gdscodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:gdsNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:nameSetDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:priceDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:qntyDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:bccodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:bindGoods = new Progress.Data.BindingSource(this-object:components).
        this-object:splitContainer1 = new System.Windows.Forms.SplitContainer().
        this-object:button7 = new System.Windows.Forms.Button().
        this-object:button5 = new System.Windows.Forms.Button().
        this-object:button6 = new System.Windows.Forms.Button().
        this-object:button3 = new System.Windows.Forms.Button().
        this-object:button1 = new System.Windows.Forms.Button().
        this-object:button2 = new System.Windows.Forms.Button().
        this-object:label1 = new System.Windows.Forms.Label().
        this-object:gdsName = new System.Windows.Forms.DataGridViewTextBoxColumn().
        this-object:tableLayoutPanel1:SuspendLayout().
        cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:bindGoods, System.ComponentModel.ISupportInitialize):BeginInit().
        cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):BeginInit().
        this-object:splitContainer1:Panel1:SuspendLayout().
        this-object:splitContainer1:Panel2:SuspendLayout().
        this-object:splitContainer1:SuspendLayout().
        this-object:SuspendLayout().
        /*  */
        /* tableLayoutPanel1 */
        /*  */
        this-object:tableLayoutPanel1:ColumnCount = 1.
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
        this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
        this-object:tableLayoutPanel1:Controls:Add(this-object:dataGridView1, 0, 2).
        this-object:tableLayoutPanel1:Controls:Add(this-object:splitContainer1, 0, 1).
        this-object:tableLayoutPanel1:Controls:Add(this-object:label1, 0, 0).
        this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
        this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
        this-object:tableLayoutPanel1:RowCount = 3.
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(25))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
        this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
        this-object:tableLayoutPanel1:Size = new System.Drawing.Size(500, 400).
        this-object:tableLayoutPanel1:TabIndex = 4.
        /*  */
        /* dataGridView1 */
        /*  */
        this-object:dataGridView1:AllowUserToAddRows = false.
        this-object:dataGridView1:AllowUserToDeleteRows = false.
        this-object:dataGridView1:AutoGenerateColumns = false.
        this-object:dataGridView1:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:Fill.
        this-object:dataGridView1:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 7 no-undo.
        arrayvar0[1] = this-object:changDataGridViewCheckBoxColumn.
        arrayvar0[2] = this-object:gdscodeDataGridViewTextBoxColumn.
        arrayvar0[3] = this-object:gdsNameDataGridViewTextBoxColumn.
        arrayvar0[4] = this-object:nameSetDataGridViewTextBoxColumn.
        arrayvar0[5] = this-object:priceDataGridViewTextBoxColumn.
        arrayvar0[6] = this-object:qntyDataGridViewTextBoxColumn.
        arrayvar0[7] = this-object:bccodeDataGridViewTextBoxColumn.
        this-object:dataGridView1:Columns:AddRange(arrayvar0).
        this-object:dataGridView1:DataSource = this-object:bindGoods.
        this-object:dataGridView1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:dataGridView1:Location = new System.Drawing.Point(3, 53).
        this-object:dataGridView1:Name = "dataGridView1".
        this-object:dataGridView1:RowHeadersVisible = false.
        this-object:dataGridView1:Size = new System.Drawing.Size(494, 344).
        this-object:dataGridView1:TabIndex = 0.
        this-object:dataGridView1:CellContentClick:Subscribe(this-object:dataGridView1_CellContentClick).
        this-object:dataGridView1:CellMouseClick:Subscribe(this-object:dataGridView1_CellMouseClick).
        this-object:dataGridView1:RowsAdded:Subscribe(this-object:dataGridView1_RowsAdded).
        /*  */
        /* changDataGridViewCheckBoxColumn */
        /*  */
        this-object:changDataGridViewCheckBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:None.
        this-object:changDataGridViewCheckBoxColumn:DataPropertyName = "Chang".
        this-object:changDataGridViewCheckBoxColumn:HeaderText = "".
        this-object:changDataGridViewCheckBoxColumn:Name = "changDataGridViewCheckBoxColumn".
        this-object:changDataGridViewCheckBoxColumn:Visible = false.
        this-object:changDataGridViewCheckBoxColumn:Width = 20.
        /*  */
        /* gdscodeDataGridViewTextBoxColumn */
        /*  */
        this-object:gdscodeDataGridViewTextBoxColumn:DataPropertyName = "gds-code".
        this-object:gdscodeDataGridViewTextBoxColumn:HeaderText = "Код товара".
        this-object:gdscodeDataGridViewTextBoxColumn:Name = "gdscodeDataGridViewTextBoxColumn".
        /*  */
        /* gdsNameDataGridViewTextBoxColumn */
        /*  */
        this-object:gdsNameDataGridViewTextBoxColumn:DataPropertyName = "gdsName".
        this-object:gdsNameDataGridViewTextBoxColumn:HeaderText = "Номенклатура".
        this-object:gdsNameDataGridViewTextBoxColumn:Name = "gdsNameDataGridViewTextBoxColumn".
        /*  */
        /* nameSetDataGridViewTextBoxColumn */
        /*  */
        this-object:nameSetDataGridViewTextBoxColumn:DataPropertyName = "NameSet".
        this-object:nameSetDataGridViewTextBoxColumn:HeaderText = "Наименование промо набора".
        this-object:nameSetDataGridViewTextBoxColumn:Name = "nameSetDataGridViewTextBoxColumn".
        this-object:nameSetDataGridViewTextBoxColumn:Visible = false.
        /*  */
        /* priceDataGridViewTextBoxColumn */
        /*  */
        this-object:priceDataGridViewTextBoxColumn:DataPropertyName = "price".
        this-object:priceDataGridViewTextBoxColumn:HeaderText = "Цена".
        this-object:priceDataGridViewTextBoxColumn:Name = "priceDataGridViewTextBoxColumn".
        this-object:priceDataGridViewTextBoxColumn:Visible = false.
        /*  */
        /* qntyDataGridViewTextBoxColumn */
        /*  */
        this-object:qntyDataGridViewTextBoxColumn:DataPropertyName = "qnty".
        this-object:qntyDataGridViewTextBoxColumn:HeaderText = "Количество".
        this-object:qntyDataGridViewTextBoxColumn:Name = "qntyDataGridViewTextBoxColumn".
        this-object:qntyDataGridViewTextBoxColumn:Visible = false.
        /*  */
        /* bccodeDataGridViewTextBoxColumn */
        /*  */
        this-object:bccodeDataGridViewTextBoxColumn:DataPropertyName = "bc-code".
        this-object:bccodeDataGridViewTextBoxColumn:HeaderText = "ШК".
        this-object:bccodeDataGridViewTextBoxColumn:Name = "bccodeDataGridViewTextBoxColumn".
        this-object:bccodeDataGridViewTextBoxColumn:Visible = false.
        /*  */
        /* bindGoods */
        /*  */
        this-object:bindGoods:AutoUpdate = true.
        this-object:bindGoods:MaxDataGuess = 0.
        this-object:bindGoods:NoLOBs = false.
        this-object:bindGoods:Position = 0.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
        arrayvar1 = new "Progress.Data.TableDesc[]"(0).
        tableDesc2:ChildTables = arrayvar1.
        @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
        define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 7 no-undo.
        arrayvar2[1] = new Progress.Data.ColumnPropDesc("Chang", "", Progress.Data.DataType:LOGICAL).
        arrayvar2[2] = new Progress.Data.ColumnPropDesc("gdsName", "Номенклатура", Progress.Data.DataType:CHARACTER).
        arrayvar2[3] = new Progress.Data.ColumnPropDesc("gds-code", "gds-code", Progress.Data.DataType:INTEGER).
        arrayvar2[4] = new Progress.Data.ColumnPropDesc("NameSet", "Наименование промо набора", Progress.Data.DataType:CHARACTER).
        arrayvar2[5] = new Progress.Data.ColumnPropDesc("price", "Цена", Progress.Data.DataType:DECIMAL).
        arrayvar2[6] = new Progress.Data.ColumnPropDesc("qnty", "Количество", Progress.Data.DataType:DECIMAL).
        arrayvar2[7] = new Progress.Data.ColumnPropDesc("bc-code", "ШК", Progress.Data.DataType:CHARACTER).
        tableDesc2:Columns = arrayvar2.
        this-object:bindGoods:TableSchema = tableDesc2.
        /*  */
        /* splitContainer1 */
        /*  */
        define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar0 = cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
        this-object:splitContainer1:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:splitContainer1:Location = new System.Drawing.Point(3, 25).
        this-object:splitContainer1:Margin = new System.Windows.Forms.Padding(3, 0, 0, 3).
        this-object:splitContainer1:Name = "splitContainer1".
        /*  */
        /* splitContainer1.Panel1 */
        /*  */
        this-object:splitContainer1:Panel1:Controls:Add(this-object:button7).
        this-object:splitContainer1:Panel1Collapsed = true.
        this-object:splitContainer1:Panel1MinSize = 22.
        /*  */
        /* splitContainer1.Panel2 */
        /*  */
        this-object:splitContainer1:Panel2:Controls:Add(this-object:button5).
        this-object:splitContainer1:Panel2:Controls:Add(this-object:button6).
        this-object:splitContainer1:Panel2:Controls:Add(this-object:button3).
        this-object:splitContainer1:Panel2:Controls:Add(this-object:button1).
        this-object:splitContainer1:Panel2:Controls:Add(this-object:button2).
        this-object:splitContainer1:Size = new System.Drawing.Size(497, 22).
        this-object:splitContainer1:SplitterDistance = 22.
        this-object:splitContainer1:TabIndex = 5.
        /*  */
        /* button7 */
        /*  */
        this-object:button7:Location = new System.Drawing.Point(0, 0).
        this-object:button7:Margin = new System.Windows.Forms.Padding(0).
        this-object:button7:Name = "button7".
        this-object:button7:Size = new System.Drawing.Size(22, 22).
        this-object:button7:TabIndex = 10.
        this-object:button7:Text = "*".
        this-object:button7:TextAlign = System.Drawing.ContentAlignment:BottomCenter.
        this-object:button7:UseCompatibleTextRendering = true.
        this-object:button7:UseVisualStyleBackColor = true.
        this-object:button7:Click:Subscribe(this-object:click_button7).
        /*  */
        /* button5 */
        /*  */
        define variable nestedvar1 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar1 = System.Windows.Forms.AnchorStyles:Top.
        this-object:button5:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:button5:Location = new System.Drawing.Point(382, 0).
        this-object:button5:Margin = new System.Windows.Forms.Padding(0).
        this-object:button5:Name = "button5".
        this-object:button5:Size = new System.Drawing.Size(80, 22).
        this-object:button5:TabIndex = 5.
        this-object:button5:Text = "Удалить ШК".
        this-object:button5:UseCompatibleTextRendering = true.
        this-object:button5:UseVisualStyleBackColor = true.
        this-object:button5:Visible = false.
        /*  */
        /* button6 */
        /*  */
        define variable nestedvar2 as System.Windows.Forms.AnchorStyles no-undo.
        nestedvar2 = System.Windows.Forms.AnchorStyles:Top.
        this-object:button6:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar2, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
        this-object:button6:Image = cast(resources:GetObject("button6.Image"), System.Drawing.Image).
        this-object:button6:Location = new System.Drawing.Point(462, -2).
        this-object:button6:Margin = new System.Windows.Forms.Padding(0).
        this-object:button6:Name = "button6".
        this-object:button6:Size = new System.Drawing.Size(35, 25).
        this-object:button6:TabIndex = 6.
        this-object:button6:TextImageRelation = System.Windows.Forms.TextImageRelation:ImageAboveText.
        this-object:button6:UseCompatibleTextRendering = true.
        this-object:button6:UseVisualStyleBackColor = true.
        this-object:button6:Visible = false.
        this-object:button6:Click:Subscribe(this-object:button6_Click).
        /*  */
        /* button3 */
        /*  */
        this-object:button3:Location = new System.Drawing.Point(160, 0).
        this-object:button3:Margin = new System.Windows.Forms.Padding(0).
        this-object:button3:Name = "button3".
        this-object:button3:Size = new System.Drawing.Size(100, 22).
        this-object:button3:TabIndex = 2.
        this-object:button3:Text = "Добавить по отбору".
        this-object:button3:UseCompatibleTextRendering = true.
        this-object:button3:UseVisualStyleBackColor = true.
        this-object:button3:Visible = false.
        /*  */
        /* button1 */
        /*  */
        this-object:button1:Location = new System.Drawing.Point(0, 0).
        this-object:button1:Margin = new System.Windows.Forms.Padding(0).
        this-object:button1:Name = "button1".
        this-object:button1:Size = new System.Drawing.Size(80, 22).
        this-object:button1:TabIndex = 0.
        this-object:button1:Text = "Добавить".
        this-object:button1:UseCompatibleTextRendering = true.
        this-object:button1:UseVisualStyleBackColor = true.
        this-object:button1:Click:Subscribe(this-object:button1_Click).
        /*  */
        /* button2 */
        /*  */
        this-object:button2:Location = new System.Drawing.Point(80, 0).
        this-object:button2:Margin = new System.Windows.Forms.Padding(0).
        this-object:button2:Name = "button2".
        this-object:button2:Size = new System.Drawing.Size(80, 22).
        this-object:button2:TabIndex = 1.
        this-object:button2:Text = "Удалить".
        this-object:button2:UseCompatibleTextRendering = true.
        this-object:button2:UseVisualStyleBackColor = true.
        this-object:button2:Click:Subscribe(this-object:button2_Click).
        /*  */
        /* label1 */
        /*  */
        this-object:label1:Dock = System.Windows.Forms.DockStyle:Fill.
        this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
        this-object:label1:Location = new System.Drawing.Point(3, 0).
        this-object:label1:Name = "label1".
        this-object:label1:Size = new System.Drawing.Size(494, 25).
        this-object:label1:TabIndex = 4.
        this-object:label1:Text = "Товар".
        this-object:label1:UseCompatibleTextRendering = true.
        /*  */
        /* gdsName */
        /*  */
        this-object:gdsName:DataPropertyName = "gds-code".
        this-object:gdsName:FillWeight = Progress.Util.CastUtil:ToSingle(55.8375626).
        this-object:gdsName:HeaderText = "Код товара".
        this-object:gdsName:Name = "gdsName".
        this-object:gdsName:ReadOnly = true.
        this-object:gdsName:Width = 176.
        /*  */
        /* uc_Goods */
        /*  */
        this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
        this-object:Controls:Add(this-object:tableLayoutPanel1).
        this-object:Margin = new System.Windows.Forms.Padding(0).
        this-object:Name = "uc_Goods".
        this-object:Size = new System.Drawing.Size(500, 400).
        this-object:tableLayoutPanel1:ResumeLayout(false).
        cast(this-object:dataGridView1, System.ComponentModel.ISupportInitialize):EndInit().
        cast(this-object:bindGoods, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:splitContainer1:Panel1:ResumeLayout(false).
        this-object:splitContainer1:Panel2:ResumeLayout(false).
        cast(this-object:splitContainer1, System.ComponentModel.ISupportInitialize):EndInit().
        this-object:splitContainer1:ResumeLayout(false).
        this-object:ResumeLayout(false).
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
  END METHOD.


  DESTRUCTOR PUBLIC uc_Goods ( ):
    if valid-handle(bindGoods:handle)
    then
       bindGoods:Assign().
    bindGoods:Dispose().
  END DESTRUCTOR.

END CLASS.