//
//  ViewController.m
//  QRG_Face(科大讯飞)
//
//  Created by 邱荣贵 on 2018/4/15.
//  Copyright © 2018年 邱久. All rights reserved.
//

#import "ViewController.h"

#import "FaceRequestViewController.h"

#import "FaceDetectorViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *table;

/** <#name#>*/
@property (nonatomic,strong) NSMutableArray  *data;

@end

@implementation ViewController

- (NSMutableArray *)data{
    if(!_data){
        
        NSArray *array = @[@"在线人脸识别",@"离线图片检测"];
        _data = [NSMutableArray arrayWithArray:array];
        
    }
    return _data;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"讯飞人脸识别";
    self.navigationItem.title = @"讯飞人脸识别";
    self.table.tableFooterView = [UIView new];
    
  NSLog(@"脸脸脸脸脸");
  NSLog(@"脸脸脸脸脸");
  NSLog(@"脸脸脸脸脸");
  NSLog(@"脸脸脸脸脸");

  
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *Cell = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell];
    }
    
    cell.textLabel.text = self.data[indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        FaceRequestViewController *vc = [[FaceRequestViewController alloc] initWithNibName:@"FaceRequestViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else
    {
        FaceDetectorViewController *vc = [[FaceDetectorViewController alloc] initWithNibName:@"FaceDetectorViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
