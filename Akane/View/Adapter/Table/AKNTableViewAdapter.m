//
// This file is part of Akane
//
// Created by JC on 05/02/15.
// For the full copyright and license information, please view the LICENSE
// file that was distributed with this source code
//

#import "AKNTableViewAdapter.h"
#import "AKNTableViewAdapter+Private.h"
#import "AKNTableViewAdapteriOS7.h"

#import "AKNViewConfigurable.h"
#import "AKNDataSource.h"
#import "AKNItemViewModelProvider.h"
#import "AKNViewCache.h"
#import "AKNItemViewModel.h"
#import "AKNTableViewCell.h"
#import "AKNViewHelper.h"
#import "AKNReusableViewHandler.h"
#import "AKNReusableViewDelegate.h"

@interface AKNTableViewAdapter () <AKNViewCache>
@property(nonatomic, strong)NSMapTable                  *itemViewModels;
@property(nonatomic, strong)NSMutableDictionary         *reusableViewsContent;
@property(nonatomic, strong)NSMutableDictionary         *reusableViewsHandler;
@property(nonatomic, weak)UITableView                   *tableView;
@property(nonatomic, strong)id<AKNReusableViewDelegate> defaultViewDelegate;
@end

@implementation AKNTableViewAdapter

- (instancetype)initCluster {
    if (!(self = [super init])) {
        return nil;
    }

    self.itemViewModels = [NSMapTable weakToStrongObjectsMapTable];
    self.reusableViewsContent = [NSMutableDictionary new];
    self.reusableViewsHandler = [NSMutableDictionary new];
    self.defaultViewDelegate = [AKNReusableViewDelegate new];

    self.viewDelegate = self.defaultViewDelegate;

    [self customInit];

    return self;
}

- (void)customInit {
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
}

- (instancetype)initWithTableView:(UITableView *)tableView {
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];

    if ([systemVersion compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
        self = [[AKNTableViewAdapteriOS7 alloc] initCluster];
    }
    else {
        self = [self initCluster];
    }

    self.tableView = tableView;

    return self;
}

- (id<AKNItemViewModel>)sectionModel:(NSInteger)section {
    id item = [self.dataSource supplementaryItemAtSection:section];
    id<AKNItemViewModel> model = [self.itemViewModels objectForKey:item];

    if (!model) {
        model = [self.itemViewModelProvider supplementaryItemViewModel:item];

        if (model) {
            [self.itemViewModels setObject:model forKey:item];
        }
    }

    return model;
}

- (id<AKNItemViewModel>)indexPathModel:(NSIndexPath *)indexPath {
    id item = [self.dataSource itemAtIndexPath:indexPath];
    id<AKNItemViewModel> model = [self.itemViewModels objectForKey:item];

    if (!model) {
        model = [self.itemViewModelProvider itemViewModel:item];

        if (model) {
            [self.itemViewModels setObject:model forKey:item];
        }
    }

    return model;
}

#pragma mark - Table delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.dataSource && self.itemViewModelProvider) ? [self.dataSource numberOfSections] : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfItemsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<AKNItemViewModel> sectionViewModel = [self sectionModel:section];
    NSString *identifier = [self identifierForViewModel:sectionViewModel inSection:section];
    identifier = [identifier stringByAppendingString:UICollectionElementKindSectionHeader];

    if (!identifier) {
        return 0;
    }

    UIView<AKNViewConfigurable> *sectionView = [self dequeueReusableSectionWithIdentifier:identifier forSection:section];
    sectionView.viewModel = sectionViewModel;

    return [sectionView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<AKNItemViewModel> viewModel = [self indexPathModel:indexPath];
    NSString *identifier = [self.itemViewModelProvider viewIdentifier:viewModel];
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    AKNReusableViewHandler *handler = [self handlerForIdentifier:identifier];

    [self.viewDelegate reuseView:cell withViewModel:viewModel atIndexPath:indexPath];
    handler.onReuse ? handler.onReuse(cell, indexPath) : nil;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<AKNItemViewModel> viewModel = [self indexPathModel:indexPath];
    if (![viewModel respondsToSelector:@selector(canSelect)]) {
        return indexPath;
    }    
    return [viewModel canSelect] ? indexPath : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<AKNItemViewModel> viewModel = [self indexPathModel:indexPath];
    if ([viewModel respondsToSelector:@selector(selectItem)]) {
        [viewModel selectItem];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id<AKNItemViewModel> sectionViewModel = [self sectionModel:section];
    NSString *identifier = [self identifierForViewModel:sectionViewModel inSection:section];
    identifier = [identifier stringByAppendingString:UICollectionElementKindSectionHeader];

    if (!identifier) {
        return nil;
    }

    UIView<AKNViewConfigurable> *sectionView = [self dequeueReusableSectionWithIdentifier:identifier forSection:section];
    sectionView.viewModel = sectionViewModel;

    return sectionView;
}

#pragma mark - Internal

- (NSString *)identifierForViewModel:(id<AKNItemViewModel>)viewModel inSection:(NSInteger)section {
    if ([self.itemViewModelProvider respondsToSelector:@selector(supplementaryViewIdentifier:)]) {
        return [self.itemViewModelProvider supplementaryViewIdentifier:viewModel];
    }

    if ([self.itemViewModelProvider respondsToSelector:@selector(supplementaryStaticViewIdentifierForSection:)]) {
        return [self.itemViewModelProvider supplementaryStaticViewIdentifierForSection:section];
    }

    return nil;
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];

    if (!cell.itemView) {
        cell.itemView = [self createReusableViewWithIdentifier:identifier];
    }

    NSAssert([cell.itemView conformsToProtocol:@protocol(AKNViewConfigurable)],
             @"Cell.itemView for identifier %@ must conform to AKNViewConfigurable protocol", identifier);

    return cell;
}

- (UIView<AKNViewConfigurable> *)dequeueReusableSectionWithIdentifier:(NSString *)identifier forSection:(NSInteger)section {
    UIView<AKNViewConfigurable> *view = [self createReusableViewWithIdentifier:identifier];

    return view;
}

- (UIView<AKNViewConfigurable> *)createReusableViewWithIdentifier:(NSString *)identifier {
    id viewType = self.reusableViewsContent[identifier];

    return (UIView<AKNViewConfigurable> *)view_instantiate(viewType);
}

- (AKNReusableViewHandler *)handlerForIdentifier:(NSString *)identifier {
    return self.reusableViewsHandler[identifier];
}

#pragma mark - ViewCacher delegate

- (void)registerNibName:(NSString *)nibName withReuseIdentifier:(NSString *)identifier {
    [self registerNibName:nibName withReuseIdentifier:identifier handle:nil];
}

- (void)registerNibName:(NSString *)nibName withReuseIdentifier:(NSString *)identifier handle:(AKNReusableViewRegisterHandle)handle {
    self.reusableViewsContent[identifier] = [UINib nibWithNibName:nibName bundle:nil];
    [self.tableView registerClass:[AKNTableViewCell class] forCellReuseIdentifier:identifier];
    [self registerHandlerForReuseIdentifier:identifier onRegistered:handle];
}

- (void)registerView:(Class)viewClass withReuseIdentifier:(NSString *)identifier {
    [self registerView:viewClass withReuseIdentifier:identifier handle:nil];
}

- (void)registerView:(Class)viewClass withReuseIdentifier:(NSString *)identifier handle:(AKNReusableViewRegisterHandle)handle {
    self.reusableViewsContent[identifier] = viewClass;
    [self.tableView registerClass:[AKNTableViewCell class] forCellReuseIdentifier:identifier];
    [self registerHandlerForReuseIdentifier:identifier onRegistered:handle];
}

- (void)registerHandlerForReuseIdentifier:(NSString *)identifier onRegistered:(AKNReusableViewRegisterHandle)handle {
    AKNReusableViewHandler *handler = [AKNReusableViewHandler new];

    self.reusableViewsHandler[identifier] = handler;

    handle ? handle(handler) : nil;
}

- (void)registerNibName:(NSString *)nibName supplementaryElementKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier {
    identifier = [identifier stringByAppendingString:kind];

    self.reusableViewsContent[identifier] = [UINib nibWithNibName:nibName bundle:nil];
}

- (void)registerView:(Class)viewClass supplementaryElementKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier {
    identifier = [identifier stringByAppendingString:kind];

    self.reusableViewsContent[identifier] = viewClass;
}

#pragma mark - Setters

- (void)setTableView:(UITableView *)tableView {
    if (_tableView == tableView) {
        return;
    }

    _tableView = tableView;

    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)setItemViewModelProvider:(id<AKNItemViewModelProvider>)itemViewModelProvider {
    if (_itemViewModelProvider == itemViewModelProvider) {
        return;
    }

    _itemViewModelProvider = itemViewModelProvider;
    [self.itemViewModelProvider registerViews:self];
    [_tableView reloadData];
}

- (void)setDataSource:(id<AKNDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    
    _dataSource = dataSource;
    [_tableView reloadData];
}

@end
