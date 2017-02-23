//
//  AsynSocketViewController.m
//  WIFICommunication
//
//  Created by CSX on 2017/2/23.
//  Copyright © 2017年 宗盛商业. All rights reserved.
//

#import "AsynSocketViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface AsynSocketViewController ()<GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic,strong) GCDAsyncSocket *socket;
@end

@implementation AsynSocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}
- (void)sendUdpBoardcast:(udpSocketBlock)block{
    self.udpSocketBlock = block;
    if(!_udpSocket)_udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSData *data = [NSData data];// 此处data是根据硬件要求传参数
    UInt16 port = 34343;// 此处具体指需询问硬件工程师
    [self.udpSocket enableBroadcast:YES error:NULL];
    [_udpSocket sendData:data toHost:@"255.255.255.255" port:port withTimeout:-1 tag:0];// 因为不知道具体的ip地址，所以host采用受限广播地址
}
- (BOOL)onUdpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    // data 接收到的外部设备返回的数据
    id result = [self unpackageMessage:data]; // 对数据进行处理，此处调用的 - (id)unpackageMessage:(NSData *)data ;是根据与硬件方面协商的数据格式进行的数据处理
    if ([[result valueForJSONKey:@"typeid"] isEqualToString:@"xxxx"]) {
        self.udpSocketBlock([result valueForJSONKey:@"data"],nil);
    } // 判断的到的数据是否为我们需要的数据
    return YES; // 发现设备后，则关闭发现通道
    return NO; // 不关闭发现通道，一直处于发现状态
}
#pragma mark - udpSocket
-(void)onUdpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
}

//通过调用该方法，可以得到外部设备返还的WiFi信息：
//[self sendUdpBoardcast:^(NSDictionary *dic, NSError *err) {
//    // dic为硬件返回的参数
//}];

//获取硬件参数之后，需要确认手机是否已于硬件连接，直接调用方法
//- (BOOL)isConnected;


//若未连接，则需建立手机和硬件之间的socket连接：
- (BOOL)connectToHost:(NSString*)hostname onPort:(UInt16)port error:(NSError **)errPtr{
    
}
// hostname、port均为硬件返回的




//数据的写入和读取
//// 数据的写入
//- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;
//// 数据的读取
//- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//十六进制字符串转NSData
-(NSData *)converHexStrToData:(NSString *)hexString {
    NSMutableData *data = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    if (hexString.length%2) {
        //防止丢失半个byte
        hexString = [@"0" stringByAppendingString:hexString];
    }
    int i;
    for (i = 0; i < [hexString length]/2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i * 2];
        byte_chars[1] = [hexString characterAtIndex:i * 2 + 1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

//NSData转十六进制字符串
-(NSString *) converDataToHexString:(NSData *)data
{
    if (data == nil) {
        return nil;
    }
    NSMutableString* hexString = [NSMutableString string];
    const unsigned char *p = [data bytes];
    for (int i=0; i < [data length]; i++) {
        [hexString appendFormat:@"%02x", *p++];
    }
    return hexString;
}


//十六进制字符串转普通字符串
-(NSString *)stringFromHexString:(NSString *)hexString {
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    return unicodeString;
}












/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
