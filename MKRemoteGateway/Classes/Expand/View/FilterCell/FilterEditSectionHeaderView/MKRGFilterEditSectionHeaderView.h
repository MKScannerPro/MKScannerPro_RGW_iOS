//
//  MKRGFilterEditSectionHeaderView.h
//  MKRemoteGateway_Example
//
//  Created by aa on 2023/2/6..
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKRGFilterEditSectionHeaderViewModel : NSObject

/// sectionHeader所在index
@property (nonatomic, assign)NSInteger index;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, strong)UIColor *contentColor;

@end

@protocol MKRGFilterEditSectionHeaderViewDelegate <NSObject>

/// 加号点击事件
/// @param index 所在index
- (void)mk_rg_filterEditSectionHeaderView_addButtonPressed:(NSInteger)index;

/// 减号点击事件
/// @param index 所在index
- (void)mk_rg_filterEditSectionHeaderView_subButtonPressed:(NSInteger)index;

@end

@interface MKRGFilterEditSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong)MKRGFilterEditSectionHeaderViewModel *dataModel;

@property (nonatomic, weak)id <MKRGFilterEditSectionHeaderViewDelegate>delegate;

+ (MKRGFilterEditSectionHeaderView *)initHeaderViewWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
