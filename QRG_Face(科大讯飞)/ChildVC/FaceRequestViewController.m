//
//  FaceRequestViewController.m
//  QRG_Face(科大讯飞)
//
//  Created by 邱荣贵 on 2018/4/15.
//  Copyright © 2018年 邱久. All rights reserved.
//

#import "FaceRequestViewController.h"
#import "tool.h"
#import <iflyMSC/IFlyFaceSDK.h>


#import "UIImage+compress.h"
#import "UIImage+Extensions.h"
#import "IFlyFaceResultKeys.h"
#import "PermissionDetector.h"

@interface FaceRequestViewController ()<IFlyFaceRequestDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *photo;

@property (weak, nonatomic) IBOutlet UILabel *gid;

@property (nonatomic,retain) CALayer *imgToUseCoverLayer;

/** <#name#>*/
@property (nonatomic,strong) UIImagePickerController   *picker;

/** <#name#>*/
@property (nonatomic,strong) IFlyFaceRequest * iFlySpFaceRequest;

@property (nonatomic,retain) NSString *resultStings;

@end

@implementation FaceRequestViewController

- (UIImagePickerController *)picker{
    if(!_picker){
        _picker = [[UIImagePickerController alloc] init];
        _picker.delegate = self;
        _picker.allowsEditing = YES;
    }
    return _picker;
}
/**
 *  从相册选择
 */
- (void)selectImageFromAlbum
{
    if([PermissionDetector isAssetsLibraryPermissionGranted]){
        if([PermissionDetector isPhotoLibraryServiceOpen]){
            self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:self.picker animated:YES completion:nil];
        }
    }
}
/**
 *   拍照
 */
- (void)selectImageFromTakePhoto
{
    if([PermissionDetector isCapturePermissionGranted]){
        
        if([PermissionDetector isCaptureDeviceServiceOpen]){
            self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.picker animated:YES completion:nil];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"在线识别";
    
    
    self.iFlySpFaceRequest=[IFlyFaceRequest sharedInstance];
    [self.iFlySpFaceRequest setDelegate:self];
    
    self.resultStings = @"";

}

/**
 识别图片

 @param sender <#sender description#>
 */
- (IBAction)discernPhoto:(id)sender {
    
    typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"图片获取" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf btnRegClicked];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"验证" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf btnVerifyClicked];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"人脸识别" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf btnDetectClicked];
    }];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"人脸关键点检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf btnAlignClicked];
    }];
    
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [alert addAction:action4];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 选择图片

 @param sender <#sender description#>
 */
- (IBAction)selectorPhoto:(id)sender {
    
    typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"图片获取" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectImageFromTakePhoto];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf selectImageFromAlbum];
    }];
    
    [alert addAction:action0];
    [alert addAction:action1];
    [alert addAction:action2];

    [self presentViewController:alert animated:YES completion:nil];
    
}

/**
 注册
 */
- (void)btnRegClicked{
   
    self.resultStings = @"";

    [self set_ImgToUseCoverLayer];
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_REG] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:@"auth_id"];
    [self.iFlySpFaceRequest setParameter:@"del" forKey:@"property"];
    //  压缩图片大小
    NSData* imgData=[self.photo.image compressedData];
    NSLog(@"reg image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

/**
 验证
 */
- (void)btnVerifyClicked{
    
    self.resultStings = @"";

    [self set_ImgToUseCoverLayer];
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_VERIFY] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:@"auth_id"];
    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
    NSString* gid=[userDefaults objectForKey:KCIFlyFaceResultGID];
    if(!gid){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:@"请先注册，或在设置中输入已注册的gid" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self.iFlySpFaceRequest setParameter:gid forKey:[IFlySpeechConstant FACE_GID]];
    [self.iFlySpFaceRequest setParameter:@"2000" forKey:@"wait_time"];
    //  压缩图片大小
    NSData* imgData=[self.photo.image compressedData];
    NSLog(@"verify image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

/**
 人脸识别
 */
- (void)btnDetectClicked{
    
    self.resultStings = @"";

    [self set_ImgToUseCoverLayer];
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_DETECT] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    //  压缩图片大小
    NSData* imgData=[self.photo.image compressedData];
    NSLog(@"detect image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];
}

/**
 人脸关键点检测

 @param sender <#sender description#>
 */
- (void)btnAlignClicked{
    
    self.resultStings = @"";

    [self set_ImgToUseCoverLayer];
    
    [self.iFlySpFaceRequest setParameter:[IFlySpeechConstant FACE_ALIGN] forKey:[IFlySpeechConstant FACE_SST]];
    [self.iFlySpFaceRequest setParameter:USER_APPID forKey:[IFlySpeechConstant APPID]];
    //  压缩图片大小
    NSData* imgData=[self.photo.image compressedData];
    NSLog(@"align image data length: %lu",(unsigned long)[imgData length]);
    [self.iFlySpFaceRequest sendRequest:imgData];
    
}

#pragma mark - Data Parser

/**
 注册 result
 @param result <#result description#>
 */
-(void)praseRegResult:(NSString*)result{
    
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //注册
            if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"注册错误\n错误码：%@",ret];
                }else{
                    if(rst && [rst isEqualToString:KCIFlyFaceResultSuccess]){
                        NSString* gid=[dic objectForKey:KCIFlyFaceResultGID];
                        resultInfo=[resultInfo stringByAppendingString:@"检测到人脸\n注册成功！"];
                        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                        [defaults setObject:gid forKey:KCIFlyFaceResultGID];
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"gid:%@",gid];
                    }else{
                        resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸\n注册失败！"];
                    }
                }
            }
            self.gid.text=resultInfoForLabel;
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
}

/**
 验证 result
 @param result <#result description#>
 */
-(void)praseVerifyResult:(NSString*)result{
    
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            if([strSessionType isEqualToString:KCIFlyFaceResultVerify]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"验证错误\n错误码：%@",ret];
                }else{
                    
                    if([rst isEqualToString:KCIFlyFaceResultSuccess]){
                        resultInfo=[resultInfo stringByAppendingString:@"检测到人脸\n"];
                    }else{
                        resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸\n"];
                    }
                    NSString* verf=[dic objectForKey:KCIFlyFaceResultVerf];
                    NSString* score=[dic objectForKey:KCIFlyFaceResultScore];
                    if([verf boolValue]){
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"score:%@\n",score];
                        resultInfo=[resultInfo stringByAppendingString:@"验证结果:验证成功!"];
                    }else{
                        NSUserDefaults* defaults=[NSUserDefaults standardUserDefaults];
                        NSString* gid=[defaults objectForKey:KCIFlyFaceResultGID];
                        resultInfoForLabel=[resultInfoForLabel stringByAppendingFormat:@"last reg gid:%@\n",gid];
                        resultInfo=[resultInfo stringByAppendingString:@"验证结果:验证失败!"];
                    }
                }
                
            }
            
            self.gid.text=resultInfoForLabel;
            if([resultInfo length]<1){
                resultInfo=@"结果异常";
            }
            
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
        
    }
    
}

-(void)praseDetectResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //检测
            if([strSessionType isEqualToString:KCIFlyFaceResultDetect]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"检测人脸错误\n错误码：%@",ret];
                }else{
                    resultInfo=[resultInfo stringByAppendingString:[rst isEqualToString:KCIFlyFaceResultSuccess]?@"检测到人脸轮廓":@"未检测到人脸轮廓"];
                }
                
                
                //绘图
                [self set_ImgToUseCoverLayer];

                _imgToUseCoverLayer = [[CALayer alloc] init];
                
                NSArray* faceArray=[dic objectForKey:KCIFlyFaceResultFace];
                
                for(id faceInArr in faceArray){
                    
                    CALayer* layer= [[CALayer alloc] init];
                    layer.borderWidth = 2.0f;
                    [layer setCornerRadius:2.0f];
                    
                    float image_x, image_y, image_width, image_height;
                    if(_photo.image.size.width/_photo.image.size.height > _photo.frame.size.width/_photo.frame.size.height){
                        image_width = _photo.frame.size.width;
                        image_height = image_width/_photo.image.size.width * _photo.image.size.height;
                        image_x = 0;
                        image_y = (_photo.frame.size.height - image_height)/2;
                        
                    }else if(_photo.image.size.width/_photo.image.size.height < _photo.frame.size.width/_photo.frame.size.height)
                    {
                        image_height = _photo.frame.size.height;
                        image_width = image_height/_photo.image.size.height * _photo.image.size.width;
                        image_y = 0;
                        image_x = (_photo.frame.size.width - image_width)/2;
                        
                    }else{
                        image_x = 0;
                        image_y = 0;
                        image_width = _photo.frame.size.width;
                        image_height = _photo.frame.size.height;
                    }
                    
                    CGFloat resize_scale = image_width/_photo.image.size.width;
                    //
                    if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                        
                        id posDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                        if([posDic isKindOfClass:[NSDictionary class]]){
                            CGFloat bottom =[[posDic objectForKey:KCIFlyFaceResultBottom] floatValue];
                            CGFloat top=[[posDic objectForKey:KCIFlyFaceResultTop] floatValue];
                            CGFloat left=[[posDic objectForKey:KCIFlyFaceResultLeft] floatValue];
                            CGFloat right=[[posDic objectForKey:KCIFlyFaceResultRight] floatValue];
                            
                            float x = left;
                            float y = top;
                            float width = right- left;
                            float height = bottom- top;
                            
                            CGRect innerRect = CGRectMake( resize_scale*x+image_x, resize_scale*y+image_y, resize_scale*width, resize_scale*height);
                            
                            [layer setFrame:innerRect];
                            layer.borderColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                            
                        }
                        
                        id attrDic=[faceInArr objectForKey:KCIFlyFaceResultAttribute];
                        if([attrDic isKindOfClass:[NSDictionary class]]){
                            id poseDic=[attrDic objectForKey:KCIFlyFaceResultPose];
                            id pit=[poseDic objectForKey:KCIFlyFaceResultPitch];
                            
                            CATextLayer *label = [[CATextLayer alloc] init];
                            [label setFontSize:14];
                            [label setString:[@"" stringByAppendingFormat:@"%@", pit]];
                            [label setAlignmentMode:kCAAlignmentCenter];
                            [label setForegroundColor:layer.borderColor];
                            [label setFrame:CGRectMake(0, layer.frame.size.height, layer.frame.size.width, 25)];
                            
                            [layer addSublayer:label];
                        }
                    }
                    [_imgToUseCoverLayer addSublayer:layer];
                    
                }
                
                [self.photo.layer addSublayer:_imgToUseCoverLayer];
            }
            
            self.gid.text = resultInfoForLabel;
            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

-(void)praseAlignResult:(NSString*)result{
    NSString *resultInfo = @"";
    NSString *resultInfoForLabel = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
            
            //关键点
            if([strSessionType isEqualToString:KCIFlyFaceResultAlign]){
                NSString* rst=[dic objectForKey:KCIFlyFaceResultRST];
                NSString* ret=[dic objectForKey:KCIFlyFaceResultRet];
                if([ret integerValue]!=0){
                    resultInfo=[resultInfo stringByAppendingFormat:@"检测关键点错误\n错误码：%@",ret];
                }else{
                    resultInfo=[resultInfo stringByAppendingString:[rst isEqualToString:@"success"]?@"检测到人脸关键点":@"未检测到人脸关键点"];
                }
                
                //绘图
                [self set_ImgToUseCoverLayer];
                
                _imgToUseCoverLayer = [[CALayer alloc] init];
                
                float image_x, image_y, image_width, image_height;
                if(_photo.image.size.width/_photo.image.size.height > _photo.frame.size.width/_photo.frame.size.height){
                    image_width = _photo.frame.size.width;
                    image_height = image_width/_photo.image.size.width * _photo.image.size.height;
                    image_x = 0;
                    image_y = (_photo.frame.size.height - image_height)/2;
                    
                }else if(_photo.image.size.width/_photo.image.size.height < _photo.frame.size.width/_photo.frame.size.height)
                {
                    image_height = _photo.frame.size.height;
                    image_width = image_height/_photo.image.size.height * _photo.image.size.width;
                    image_y = 0;
                    image_x = (_photo.frame.size.width - image_width)/2;
                    
                }else{
                    image_x = 0;
                    image_y = 0;
                    image_width = _photo.frame.size.width;
                    image_height = _photo.frame.size.height;
                }
                
                CGFloat resize_scale = image_width/_photo.image.size.width;
                
                NSArray* resultArray=[dic objectForKey:KCIFlyFaceResultResult];
                for (id anRst in resultArray) {
                    if(anRst && [anRst isKindOfClass:[NSDictionary class]]){
                        NSDictionary* landMarkDic=[anRst objectForKey:KCIFlyFaceResultLandmark];
                        NSEnumerator* keys=[landMarkDic keyEnumerator];
                        for(id key in keys){
                            id attr=[landMarkDic objectForKey:key];
                            if(attr && [attr isKindOfClass:[NSDictionary class]]){
                                id attr=[landMarkDic objectForKey:key];
                                CGFloat x=[[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
                                CGFloat y=[[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
                                
                                CALayer* layer= [[CALayer alloc] init];
                                NSLog(@"resize_scale:%f",resize_scale);
                                CGFloat radius=5.0f*resize_scale;
                                //关键点大小限制
                                if(radius>10){
                                    radius=10;
                                }
                                [layer setCornerRadius:radius];
                                CGRect innerRect = CGRectMake( resize_scale*x+image_x-radius/2, resize_scale*y+image_y-radius/2, radius, radius);
                                [layer setFrame:innerRect];
                                layer.backgroundColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                                
                                [_imgToUseCoverLayer addSublayer:layer];
                                
                                
                            }
                        }
                    }
                }
                
                [self.photo.layer addSublayer:_imgToUseCoverLayer];
                
            }
            self.gid.text = resultInfoForLabel;

            [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:resultInfo waitUntilDone:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
        
    }
    
}

#pragma mark - Perform results On UI

-(void)updateFaceImage:(NSString*)result{
    
    NSError* error;
    NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
    
    if(dic){
        NSString* strSessionType=[dic objectForKey:KCIFlyFaceResultSST];
        
        //注册
        if([strSessionType isEqualToString:KCIFlyFaceResultReg]){
            [self praseRegResult:result];
        }
        
        //验证
        if([strSessionType isEqualToString:KCIFlyFaceResultVerify]){
            [self praseVerifyResult:result];
        }
        
        //检测
        if([strSessionType isEqualToString:KCIFlyFaceResultDetect]){
            [self praseDetectResult:result];
        }
        
        //关键点
        if([strSessionType isEqualToString:KCIFlyFaceResultAlign]){
            [self praseAlignResult:result];
        }
        
    }
}

-(void)showResultInfo:(NSString*)resultInfo{
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:resultInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    alert=nil;
}

#pragma mark - IFlyFaceRequestDelegate
/**
 * 消息回调
 * @param eventType 消息类型
 * @param params 消息数据对象
 */
- (void) onEvent:(int) eventType WithBundle:(NSString*) params{
    NSLog(@"onEvent | params:%@",params);
}

/**
 * 数据回调，可能调用多次，也可能一次不调用
 * @param buffer 服务端返回的二进制数据
 */
- (void) onData:(NSData* )data{
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"result:%@",result);
    
    if (result) {
        self.resultStings=[self.resultStings stringByAppendingString:result];
    }
    
}

/**
 * 结束回调，没有错误时，error为null
 * @param error 错误类型
 */
- (void) onCompleted:(IFlySpeechError*) error{
   
    NSLog(@"onCompleted | error:%@",[error errorDesc]);
    NSString* errorInfo=[NSString stringWithFormat:@"错误码：%d\n 错误描述：%@",[error errorCode],[error errorDesc]];
    if(0!=[error errorCode]){
        [self performSelectorOnMainThread:@selector(showResultInfo:) withObject:errorInfo waitUntilDone:NO];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateFaceImage:self.resultStings];
        });
    }
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    self.photo.image = image;
}

/**
 _imgToUseCoverLayer 多次设定
 */
- (void)set_ImgToUseCoverLayer{
    
    if(_imgToUseCoverLayer){
        _imgToUseCoverLayer.sublayers=nil;
        [_imgToUseCoverLayer removeFromSuperlayer];
        _imgToUseCoverLayer=nil;
    }
}
- (void)dealloc{
    
    self.iFlySpFaceRequest = nil;
    self.imgToUseCoverLayer = nil;
    self.resultStings=nil;
}
@end
