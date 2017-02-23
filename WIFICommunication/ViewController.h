//
//  ViewController.h
//  WIFICommunication
//
//  Created by CSX on 2017/2/23.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void (^udpSocketBlock)(NSDictionary *dic,NSError *error);//block用于硬件返回信息的回调
@interface ViewController : UIViewController
@property(nonatomic,copy) udpSocketBlock udpScoketBlock;
- (void)sendUdpBoardcast:(udpSocketBlock)block;

@end

