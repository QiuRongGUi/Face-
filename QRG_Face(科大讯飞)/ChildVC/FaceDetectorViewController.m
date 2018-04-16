//
//  FaceDetectorViewController.m
//  QRG_Face(科大讯飞)
//
//  Created by 邱荣贵 on 2018/4/15.
//  Copyright © 2018年 邱久. All rights reserved.
//

#import "FaceDetectorViewController.h"

#import "UIImage+Extensions.h"
#import "UIImage+compress.h"
#import "iflyMSC/IFlyFaceSDK.h"
#import "IFlyFaceResultKeys.h"

#import "PermissionDetector.h"

@interface FaceDetectorViewController ()<IFlyFaceRequestDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *gid;

@property (nonatomic,retain) IFlyFaceDetector         * faceDetector;

@property (nonatomic,retain) CALayer                  * imgToUseCoverLayer;

/** <#name#>*/
@property (nonatomic,strong) UIImagePickerController   *picker;

@end

@implementation FaceDetectorViewController

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
    
    self.navigationItem.title=@"离线图片检测示例";
    
    self.faceDetector=[IFlyFaceDetector sharedInstance];

}

/**
 识别图片
 
 @param sender <#sender description#>
 */
- (IBAction)discernPhoto:(id)sender {

    NSString* strResult=[self.faceDetector detectARGB:[_photo image]];
    NSLog(@"result:%@",strResult);
    [self praseDetectResult:strResult];
}

#pragma mark - Data Parser

-(void)praseDetectResult:(NSString*)result{
    
    NSString *resultInfo = @"";
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        
        if(dic){
            NSNumber* ret=[dic objectForKey:KCIFlyFaceResultRet];
            NSArray* faceArray=[dic objectForKey:KCIFlyFaceResultFace];
            //检测
            if(ret && [ret intValue]==0 && faceArray &&[faceArray count]>0){
                resultInfo=[resultInfo stringByAppendingFormat:@"检测到人脸轮廓"];
            }else{
                resultInfo=[resultInfo stringByAppendingString:@"未检测到人脸轮廓"];
            }
            
            
            //绘图
            if(_imgToUseCoverLayer){
                _imgToUseCoverLayer.sublayers=nil;
                [_imgToUseCoverLayer removeFromSuperlayer];
                _imgToUseCoverLayer=nil;
            }
            _imgToUseCoverLayer = [[CALayer alloc] init];
            
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
                    
                    NSDictionary* position=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                    if(position){
                        CGFloat bottom =[[position objectForKey:KCIFlyFaceResultBottom] floatValue];
                        CGFloat top=[[position objectForKey:KCIFlyFaceResultTop] floatValue];
                        CGFloat left=[[position objectForKey:KCIFlyFaceResultLeft] floatValue];
                        CGFloat right=[[position objectForKey:KCIFlyFaceResultRight] floatValue];
                        
                        float x = left;
                        float y = top;
                        float width = right- left;
                        float height = bottom- top;
                        
                        CGRect innerRect = CGRectMake( resize_scale*x+image_x, resize_scale*y+image_y, resize_scale*width, resize_scale*height);
                        
                        [layer setFrame:innerRect];
                        layer.borderColor = [[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] CGColor];
                    }
                }
                
                [_imgToUseCoverLayer addSublayer:layer];
                layer=nil;
                
            }
            self.photo.layer.sublayers=nil;
            [self.photo.layer addSublayer:_imgToUseCoverLayer];
            _imgToUseCoverLayer=nil;
            
        }
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"结果" message:resultInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        alert=nil;
        
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
    
}

/**
 选择图片
 
 @param sender sender description
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* image=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    self.photo.image = image;
}

@end
