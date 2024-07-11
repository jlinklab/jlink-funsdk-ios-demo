//
//  CameraLinkHomeView.m
//   iCSee
//
//  Created by Megatron on 2023/4/15.
//  Copyright © 2023 xiongmaitech. All rights reserved.
//

#import "CameraLinkHomeView.h"
#import "ItemTableviewCell.h"

@interface CameraLinkHomeView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray *dataSource;                // 配置列表数据源

@end
@implementation CameraLinkHomeView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self addSubview:self.tbContainer];
        [self.tbContainer addSubview:self.tbFunction];
        
        [self.tbContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.tbFunction mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tbContainer);
            make.right.equalTo(self.tbContainer);
            make.top.equalTo(self.tbContainer);
            make.bottom.equalTo(self.tbContainer);
        }];
    }
    
    return self;
}

- (void)setCameraLinkEnable:(BOOL)cameraLinkEnable{
    if (_cameraLinkEnable != cameraLinkEnable){
        _cameraLinkEnable = cameraLinkEnable;
        
        [_tbFunction reloadData];
    }
}

- (void)changeCameraLinkState:(BOOL)open{
    _cameraLinkEnable = open;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeLinkSwitchState:)]){
        [self.delegate changeLinkSwitchState:open];
    }
}

//MARK: - Delegate
//MARK: UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = indexPath.section;
    ItemTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableviewCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *title = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = title;
    if ([title isEqualToString:TS("TR_Device_camera_link_switch")]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setCellType:cellTypeSwitch];
        cell.mySwitch.on = self.cameraLinkEnable;
        WeakSelf(weakSelf);
        cell.statusSwitchClicked = ^(BOOL on, int section, int row) {
            [weakSelf changeCameraLinkState:on];
        };
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    int section = indexPath.section;
    NSString *titleStr = self.dataSource[indexPath.row];

    if ([titleStr isEqualToString:TS("TR_Device_camera_link_aiming")]){
        if (self.delegate && [self.delegate respondsToSelector:@selector(goPTZLocateVC)]){
            [self.delegate goPTZLocateVC];
        }
    }
}
    
//MARK: - LazyLoad
- (UIView *)tbContainer{
    if (!_tbContainer) {
        _tbContainer = [[UIView alloc] init];
        _tbContainer.backgroundColor = [UIColor whiteColor];
    }
    
    return _tbContainer;
}

- (UITableView *)tbFunction{
    if (!_tbFunction) {
        _tbFunction = [[UITableView alloc] init];
        [_tbFunction registerClass:[ItemTableviewCell class] forCellReuseIdentifier: @"ItemTableviewCell"];
        _tbFunction.dataSource = self;
        _tbFunction.delegate = self;
    }
    
    return _tbFunction;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[TS("TR_Device_camera_link_switch"), TS("TR_Device_camera_link_aiming")];
    }
    return _dataSource;
}

@end
