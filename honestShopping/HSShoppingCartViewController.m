//
//  HSShoppingCartViewController.m
//  honestShopping
//
//  Created by 张国俗 on 15-3-16.
//  Copyright (c) 2015年 张国俗. All rights reserved.
//

#import "HSShoppingCartViewController.h"
#import "HSSubmitOrderViewController.h"
#import "HSLoginInViewController.h"

#import "PKYStepper.h"
#import "HSCatrTableViewCell.h"
#import "HSDBManager.h"
#import "UIImageView+WebCache.h"
#import "HSCommodityItemDetailPicModel.h"
#import "UIView+HSLayout.h"

@interface HSShoppingCartViewController ()<UITableViewDataSource,
UITableViewDelegate>
{
    /// 记录选择的字典
    NSMutableDictionary *_seletedDic;
    
    /// 记录数量的字典
    NSMutableDictionary *_itemNumDic;
    /// 是否全选
    BOOL _isAllSelected;
    
    NSArray *_cartArray;
    
    UIView *_editBottomView;
    
    BOOL _isEditing;
    
}

@property (weak, nonatomic) IBOutlet UITableView *cartTableView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UILabel *priceTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@end

@implementation HSShoppingCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"购物车";
    [self setNavBarRightBarWithTitle:@"编辑" action:@selector(editAction)];
    [self bottomViewSetUp];
    [self editViewSetUp];

    [_cartTableView  registerNib:[UINib nibWithNibName:NSStringFromClass([HSCatrTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HSCatrTableViewCell class])];
    _cartTableView.delegate = self;
    _cartTableView.dataSource = self;
    _cartTableView.tableFooterView = [[UIView alloc] init];
    
    _seletedDic = [[NSMutableDictionary alloc] init];
    _itemNumDic = [[NSMutableDictionary alloc] init];
    _editBottomView.hidden = YES;
    _isEditing = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     _cartArray = [HSDBManager selectAllWithTableName:[HSDBManager tableNameWithUid]];
    [self initSelectDic];
    [_cartTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark 底部界面设置
- (void)bottomViewSetUp
{
    _priceTitleLabel.textColor = kAPPTintColor;
    _priceTitleLabel.text = @"应付总额:";
    _priceLabel.textColor = [UIColor redColor];
    
    _priceLabel.text = @"0.00元";
    
    [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_buyButton setBackgroundImage:[HSPublic ImageWithColor:kAppYellowColor] forState:UIControlStateNormal];
    [_buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
    _buyButton.layer.masksToBounds = YES;
    _buyButton.layer.cornerRadius = 5.0;
    
}

#pragma mark -
#pragma mark 底部界面设置
- (void)editViewSetUp
{
    _editBottomView = [[UIView alloc] init];
    [self.view addSubview:_editBottomView];
    _editBottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *sepView = [[UIView alloc] init];
    [_editBottomView addSubview:sepView];
    sepView.backgroundColor = [UIColor lightGrayColor];
    sepView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_editBottomView addSubview:deleteBtn];
    deleteBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    selectBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    [selectBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_editBottomView addSubview:selectBtn];
    selectBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *vfl1 = @"H:|[_editBottomView]|";
    NSString *vfl2 = @"V:[_editBottomView(44)]|";
    NSString *vfl3 = @"H:|[sepView]|";
    NSString *vfl4 = @"V:|[sepView(0.5)]";
    NSString *vfl5 = @"H:|-16-[deleteBtn]";
    NSDictionary *dic = NSDictionaryOfVariableBindings(_editBottomView,sepView,deleteBtn);
    NSArray *arr1 = [NSLayoutConstraint constraintsWithVisualFormat:vfl1 options:0 metrics:nil views:dic];
    NSArray *arr2 = [NSLayoutConstraint constraintsWithVisualFormat:vfl2 options:0 metrics:nil views:dic];
    NSArray *arr3 = [NSLayoutConstraint constraintsWithVisualFormat:vfl3 options:0 metrics:nil views:dic];
    NSArray *arr4 = [NSLayoutConstraint constraintsWithVisualFormat:vfl4 options:0 metrics:nil views:dic];
    NSArray *arr5 = [NSLayoutConstraint constraintsWithVisualFormat:vfl5 options:0 metrics:nil views:dic];
    
    [self.view addConstraints:arr1];
    [self.view addConstraints:arr2];
    
    [_editBottomView addConstraints:arr3];
    [_editBottomView addConstraints:arr4];
    [_editBottomView addConstraints:arr5];
    [_editBottomView HS_centerYWithSubView:deleteBtn];
    [_editBottomView HS_centerYWithSubView:selectBtn];
    [_editBottomView HS_dispacingWithFisrtView:_editBottomView fistatt:NSLayoutAttributeTrailing secondView:selectBtn secondAtt:NSLayoutAttributeTrailing constant:16];
}

- (void)deleteAction
{
    [self deleteSelectedItem];
}

- (void)selectAction:(UIButton *)senderBtn
{
    _isAllSelected = !_isAllSelected;
    if (_isAllSelected) { /// 已经全选了
        [senderBtn setTitle:@"全不选" forState:UIControlStateNormal];
    }
    else
    {
        [senderBtn setTitle:@"全选" forState:UIControlStateNormal];
    }
    
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_seletedDic setObject:[NSNumber numberWithBool:_isAllSelected] forKey:[self keyFromItemID:obj[kPostJsonid]]];
    }];
    [_cartTableView reloadData];

}

- (IBAction)buyAction:(id)sender {
    
    if (![HSPublic isLoginInStatus]) {
        [self showHudWithText:@"请先登录"];
        [self pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
        return ;
    }
    
    if ([self selectedItems].count == 0) {
         [self showHudWithText:@"没有选择任何商品"];
        return;
    }
    
    //[self pushViewControllerWithIdentifer:NSStringFromClass([HSLoginInViewController class])];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HSSubmitOrderViewController *submitVC = [storyBoard instantiateViewControllerWithIdentifier:NSStringFromClass([HSSubmitOrderViewController class])];
    submitVC.itemNumDic = [self selectedItemNum];
    submitVC.itemsDataArray = [self selectedItems];
    submitVC.title = @"确认订单";
    submitVC.hidesBottomBarWhenPushed = YES;
    submitVC.userInfoModel = [[HSUserInfoModel alloc] initWithDictionary:[HSPublic userInfoFromPlist] error:nil];
    [self.navigationController pushViewController:submitVC animated:YES];

    
}
#pragma mark -
#pragma mark 获取购物车数据
- (void)cartRequest
{
    
}

#pragma mark -
#pragma mark 初始化全选择
- (void)initSelectDic
{
    if (_seletedDic.allKeys.count > 0) {
        return;
    }
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_seletedDic setObject:[NSNumber numberWithBool:YES] forKey:[self keyFromItemID:obj[kPostJsonid]]];
    }];
   
    
}


#pragma mark -
#pragma mark 编辑action
- (void)editAction
{
    BOOL isEditing = _isEditing;
    
    if (!isEditing && _cartArray.count == 0) { // 不在编辑状态 且内容为空了
        [self showHudWithText:@"没有内容可以编辑"];
        return;
    }
    
    NSString *title = @"";
    if (isEditing) {
        title = @"编辑";
//        self.navigationItem.leftBarButtonItem = nil;
    }
    else
    {
        title = @"完成";
//        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStylePlain target:self action:@selector(multipleSelected)];
//        self.navigationItem.leftBarButtonItem = item;
        _isAllSelected = NO;
    }
    self.navigationItem.rightBarButtonItem.title = title;
//    [_cartTableView setEditing:!isEditing animated:YES];
    _isEditing = !isEditing;
    _editBottomView.hidden = isEditing;
    
    if (_cartArray.count == 0) { /// 编辑完成时 若数组为空了 就直接隐藏
        _bottomView.hidden = YES;
    }
    else
    {
        _bottomView.hidden = !_editBottomView.isHidden;
    }
    
}


#pragma mark -
#pragma mark 多选控制
- (void)multipleSelected
{
    _isAllSelected = !_isAllSelected;
    if (_isAllSelected) { /// 已经全选了
        self.navigationItem.leftBarButtonItem.title = @"全不选";
    }
    else
    {
         self.navigationItem.leftBarButtonItem.title = @"全选";
    }
    
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [_seletedDic setObject:[NSNumber numberWithBool:_isAllSelected] forKey:[self keyFromItemID:obj[kPostJsonid]]];
    }];
    [_cartTableView reloadData];
    

}

#pragma mark - 
#pragma mark 删除选中的内容
- (void)deleteSelectedItem
{
    NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:_cartArray];
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        
        NSNumber *isSelect = [_seletedDic objectForKey:[self keyFromItemID:obj[kPostJsonid]]];
        if ([isSelect boolValue]) { /// 选中状态的删除
            [tmp removeObject:obj];
            
            HSCommodityItemDetailPicModel *picModel = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:obj error:nil];
            [HSDBManager deleteItemWithTableName:[HSDBManager tableNameWithUid] keyID:picModel.id];
        }
    }];
    _cartArray = tmp;
    [_cartTableView reloadData];
    
}

#pragma mark -
#pragma mark 计算总价格
- (void)totalPrice
{
    __block float totle = 0.0;
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        HSCommodityItemDetailPicModel *model = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:obj error:nil];
        NSNumber *num = [_itemNumDic objectForKey:[self keyFromItemID:model.id]];
        int count = num == nil ? 1 : [num intValue];
        float price = [model.price floatValue];
        NSNumber *suc = [_seletedDic objectForKey:[self keyFromItemID:obj[kPostJsonid]]];
        BOOL isSuc = suc == nil ? NO :[suc boolValue];
        if (isSuc) {
             totle += (float)price * count;
        }
       
        
    }];
    
    _priceLabel.text = [NSString stringWithFormat:@"%.2f元",totle];
    
}

#pragma mark - 
#pragma mark 拼接用于提交订单的数据
- (NSArray *)selectedItems
{
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        HSCommodityItemDetailPicModel *model = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:obj error:nil];
        NSNumber *suc = [_seletedDic objectForKey:[self keyFromItemID:obj[kPostJsonid]]];
        BOOL isSuc = suc == nil ? NO :[suc boolValue];
        if (isSuc) {
            [tmp addObject:model];
        }
        
    }];
    
    return tmp;
}

- (NSDictionary *)selectedItemNum
{
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
    [_cartArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        HSCommodityItemDetailPicModel *model = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:obj error:nil];
        NSNumber *num = [_itemNumDic objectForKey:[self keyFromItemID:model.id]];
        int count = num == nil ? 1 : [num intValue];
        NSNumber *suc = [_seletedDic objectForKey:[self keyFromItemID:obj[kPostJsonid]]];
        BOOL isSuc = suc == nil ? NO :[suc boolValue];
        if (isSuc) {
            [tmp setObject:[NSNumber numberWithInt:count] forKey:[HSPublic controlNullString:model.id]];
        }
        
        
    }];
    
    return tmp;

}


#pragma mark -
#pragma mark tableview dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_cartArray.count == 0) {
       [self placeViewWithImgName:@"search_no_content" text:@"购物车空空如也"];
       
    }
    else
    {
        [self removePlaceView];
    }
    if (!_isEditing) {
        _bottomView.hidden = _cartArray.count == 0 ? YES : NO;
    }
    else if ( _cartArray.count == 0)
    {
        _bottomView.hidden = YES;
    }
    [self totalPrice];
    return _cartArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSCatrTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HSCatrTableViewCell class]) forIndexPath:indexPath];
    NSDictionary *dic = _cartArray[indexPath.row];
    HSCommodityItemDetailPicModel *itemModel = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:dic error:nil];
    cell.titlelabel.text = itemModel.title;
    cell.priceLabel.text = itemModel.price;
    cell.stepper.maximum = [itemModel.maxbuy floatValue];
    [cell.itemImageView sd_setImageWithURL:[NSURL URLWithString:[self commodityIntroImgFullUrl:itemModel.img]] placeholderImage:kPlaceholderImage];
    
    NSNumber *num = [_itemNumDic objectForKey:[self keyFromItemID:dic[kPostJsonid]]];
    int buyCount = 0;
    if (num == nil) {
        [_itemNumDic setObject:@1 forKey:[self keyFromItemID:dic[kPostJsonid]]];
        buyCount = 1;
    }
    else
    {
        buyCount = [num intValue];
    }
    __weak typeof(self) wself = self;
    [cell.stepper setValueChangedCallback:^(PKYStepper *stepper, float newValue){
        __strong typeof(wself) swself = wself;
         stepper.countLabel.text = [NSString stringWithFormat:@"%d",(int)newValue];
        [swself->_itemNumDic setObject:[NSNumber numberWithInt:(int)newValue] forKey:[swself keyFromItemID:dic[kPostJsonid]]];
        [swself totalPrice];
        
    }];
    cell.stepper.value = buyCount;
    
    __weak typeof(cell) wcell = cell;
    cell.selectBlock = ^{
        __strong typeof(wself) swself = wself;
        NSDictionary *obj = swself->_cartArray[indexPath.row];
        NSNumber *suc = [swself->_seletedDic objectForKey:[swself keyFromItemID:obj[kPostJsonid]]];
        BOOL isSuc = suc == nil ? NO :[suc boolValue];
        
        [swself->_seletedDic setObject:[NSNumber numberWithBool:!isSuc] forKey:[swself keyFromItemID:obj[kPostJsonid]]];
        
        wcell.selectButton.selected = !isSuc;
        [swself totalPrice];
    };
    
    NSDictionary *obj = _cartArray[indexPath.row];
    NSNumber *suc = [_seletedDic objectForKey:[self keyFromItemID:obj[kPostJsonid]]];
    BOOL isSuc = suc == nil ? NO :[suc boolValue];
    cell.selectButton.selected = isSuc;

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 指定哪一行可以编辑 哪行不能编辑
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 设置 哪一行的编辑按钮 状态 指定编辑样式
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
;
}

// 判断点击按钮的样式 来去做添加 或删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除的操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *dic = _cartArray[indexPath.row];
        NSArray *indexPaths = @[indexPath]; // 构建 索引处的行数 的数组
        // 删除 索引的方法 后面是动画样式
        NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:_cartArray];
        [tmp removeObjectAtIndex:indexPath.row];
        _cartArray = tmp;
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationLeft)];
        
        HSCommodityItemDetailPicModel *picModel = [[HSCommodityItemDetailPicModel alloc] initWithDictionary:dic error:nil];
        [HSDBManager deleteItemWithTableName:[HSDBManager tableNameWithUid] keyID:picModel.id];
        
    }
    
    // 添加的操作
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) { /// 不在编辑状态
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        NSDictionary *obj = _cartArray[indexPath.row];
        NSNumber *suc = [_seletedDic objectForKey:[self keyFromItemID:obj[kPostJsonid]]];
        BOOL isSuc = suc == nil ? NO :[suc boolValue];
        
        [_seletedDic setObject:[NSNumber numberWithBool:!isSuc] forKey:[self keyFromItemID:obj[kPostJsonid]]];
    }
}

#pragma mark -
#pragma mark 字典的key 可以为商品id
- (NSString *)keyFromItemID:(NSString *)itemID
{
    NSString *result = [NSString stringWithFormat:@"key%@",itemID];
    return result;
}


@end
