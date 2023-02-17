//
//  MKRGFilterEditSectionHeaderView.m
//  MKRemoteGateway_Example
//
//  Created by aa on 2023/2/6..
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKRGFilterEditSectionHeaderView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKRGFilterEditSectionHeaderViewModel
@end

@interface MKRGFilterEditSectionHeaderView ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *addButton;

@property (nonatomic, strong)UIButton *subButton;

@end

@implementation MKRGFilterEditSectionHeaderView

+ (MKRGFilterEditSectionHeaderView *)initHeaderViewWithTableView:(UITableView *)tableView {
    MKRGFilterEditSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MKRGFilterEditSectionHeaderViewIdenty"];
    if (!headerView) {
        headerView = [[MKRGFilterEditSectionHeaderView alloc] initWithReuseIdentifier:@"MKRGFilterEditSectionHeaderViewIdenty"];
    }
    return headerView;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = RGBCOLOR(242, 242, 242);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.addButton];
        [self.contentView addSubview:self.subButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.subButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.subButton.mas_left).mas_offset(-15.f);
        make.width.mas_equalTo(30.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.addButton.mas_left).mas_offset(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
}

#pragma mark - event method
- (void)addButtonPressed {
    if ([self.delegate respondsToSelector:@selector(mk_rg_filterEditSectionHeaderView_addButtonPressed:)]) {
        [self.delegate mk_rg_filterEditSectionHeaderView_addButtonPressed:self.dataModel.index];
    }
}

- (void)subButtonPressed {
    if ([self.delegate respondsToSelector:@selector(mk_rg_filterEditSectionHeaderView_subButtonPressed:)]) {
        [self.delegate mk_rg_filterEditSectionHeaderView_subButtonPressed:self.dataModel.index];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKRGFilterEditSectionHeaderViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKRGFilterEditSectionHeaderViewModel.class]) {
        return;
    }
    self.contentView.backgroundColor = (_dataModel.contentColor ? _dataModel.contentColor : RGBCOLOR(242, 242, 242));
    self.msgLabel.text = SafeStr(_dataModel.msg);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(14.f);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _msgLabel;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:LOADICON(@"MKRemoteGateway", @"MKRGFilterEditSectionHeaderView", @"rg_addIcon.png") forState:UIControlStateNormal];
        [_addButton addTarget:self
                       action:@selector(addButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UIButton *)subButton {
    if (!_subButton) {
        _subButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subButton setImage:LOADICON(@"MKRemoteGateway", @"MKRGFilterEditSectionHeaderView", @"rg_subIcon.png") forState:UIControlStateNormal];
        [_subButton addTarget:self
                       action:@selector(subButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _subButton;
}

@end
