//
//  AsynSocketViewController.h
//  WIFICommunication
//
//  Created by CSX on 2017/2/23.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsynSocketViewController : UIViewController

typedef void (^udpSocketBlock)(NSDictionary* dic,NSError* err);// block用于硬件返回信息的回调
@property (nonatomic,copy) udpSocketBlock udpSocketBlock;
- (void)sendUdpBoardcast:(udpSocketBlock)block;

@end
