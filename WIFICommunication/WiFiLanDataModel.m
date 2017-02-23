//
//  WiFiLanDataModel.m
//  WIFICommunication
//
//  Created by CSX on 2017/2/23.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "WiFiLanDataModel.h"
#import "GCDAsyncUdpSocket.h"

@interface WiFiLanDataModel ()<GCDAsyncUdpSocketDelegate>
{
    NSString *ipStr;
    NSString *portStr;
    NSString *msgStr;
    NSData   *macData;
    
    int htemp;
    int filmp;
    int wtemp;
    NSString *wifiMac;
}

@property (nonatomic, strong) GCDAsyncUdpSocket *serverSocket;

@end

@implementation WiFiLanDataModel

@synthesize serverSocket;

//单例
+ (WiFiLanDataModel *)sharedWiFiLanDataModel
{
    static WiFiLanDataModel *wifiLanDataModel = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        wifiLanDataModel = [[self alloc] init];
        [wifiLanDataModel initWiFi];
    });
    
    return wifiLanDataModel;
}

-(void)initWiFi
{
    if (serverSocket == nil) {
        serverSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    portStr = @"1112";
    
    NSError *error = nil;
    if (![serverSocket bindToPort:[portStr intValue] error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return;
    }
    if (![serverSocket beginReceiving:&error])
    {
        [serverSocket close];
        NSLog(@"Error starting server (recv): %@", error);
        return;
    }
    [serverSocket localPort];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];  //wifi模块返回数据，下面为自己项目数据处理。
    if (msg) {
        /* If you want to get a display friendly version of the IPv4 or IPv6 address, you could do this:
         
         NSString *host = nil;
         uint16_t port = 0;
         [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
         */
        
        NSString *msgMac = [msg substringWithRange:NSMakeRange(0,12)];
        NSString *msgNum = [msg substringWithRange:NSMakeRange(12,4)];
        
        int temp;
        if (msg.length != 18) {
            temp = [[msg substringWithRange:NSMakeRange(16,3)] intValue] / 10;
        }
        else {
            temp = [[msg substringWithRange:NSMakeRange(16,2)] intValue] / 10;
        }
        wifiMac = msgMac;
        
        //        NSLog(@"msg==>%@", msg);
        
        if ([msgNum isEqualToString:@"open"]) {
            //            NSLog(@"open ==> %d°C", temp);
        }
        else if ([msgNum isEqualToString:@"htem"]) {
            //            NSLog(@"室温 ==> %d°C", temp);
            htemp = temp;
        }
        else if ([msgNum isEqualToString:@"film"]) {
            //            NSLog(@"膜温 ==> %d°C", temp);
            filmp = temp;
        }
        else if ([msgNum isEqualToString:@"wtem"]) {
            //            NSLog(@"设置 ==> %d°C", temp);
            wtemp = temp;
        }
        else if ([msgNum isEqualToString:@"clos"]) {
            //            NSLog(@"关闭 ==> %d°C", temp);
        }
        else {
            //            NSLog(@"msg==>%@", msgNum);
        }
        
        
    }
    else {
        NSLog(@"Error converting received data into UTF-8 String");
    }
    
    NSDictionary *dic = @{@"msg":msg,
                          @"wifiMac":wifiMac,
                          @"htem":[NSNumber numberWithInt:htemp],
                          @"film":[NSNumber numberWithInt:filmp],
                          @"wtem":[NSNumber numberWithInt:wtemp]};
//    //温度数据发送ACK
//    [[NSNotificationCenter defaultCenter] postNotificationName:kWiFiTemperatureDataTransmissionNotification object:dic];
    
    macData = address;
    NSString *msgM = [msg substringWithRange:NSMakeRange(0,12)];
    
//    [WiFiDeviceSave DatamacAddress:msgM withWifiMacData:macData];
    
}

///////////////////////////////////////////////
//设置温度
-(void)connectBtnActions:(int)temp withMac:(NSString *)wifiMacs withData:(NSData *)dataMac
{
    NSString *msg = [NSString stringWithFormat:@"%@wtem%d", wifiMacs, temp];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [serverSocket sendData:data toAddress:dataMac withTimeout:-1 tag:0];
}

//开关
-(void)connectBtnActionsOFFON:(NSString *)off withMac:(NSString *)wifiMacs withData:(NSData *)dataMac
{
    NSString *msg = [NSString stringWithFormat:@"%@%@180", wifiMacs, off];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [serverSocket sendData:data toAddress:dataMac withTimeout:-1 tag:0];
}

//取消配网
-(void)connectBtnActionsWlan:(NSString *)wifiMacs withData:(NSData *)dataMac
{
    // 5ccf7f93ec54wifi
    NSString *msg = [NSString stringWithFormat:@"%@wifi", wifiMacs];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [serverSocket sendData:data toAddress:dataMac withTimeout:-1 tag:0];
}

@end
