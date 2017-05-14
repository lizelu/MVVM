//
//  PublicWeiboViewModel.m
//  MVVMTest
//
//  Created by 李泽鲁 on 15/1/8.
//  Copyright (c) 2015年 李泽鲁. All rights reserved.
//

#import "PublicWeiboViewModel.h"
#import "PublicDetailViewController.h"

@implementation PublicWeiboViewModel

//获取公共微博
- (void) fetchPublicWeiBo {
    NSDictionary *parameter = @{TOKEN: ACCESSTOKEN,
                                COUNT: @"100"};
    [NetRequestClass NetRequestGETWithRequestURL:REQUESTPUBLICURL WithParameter:parameter WithReturnValeuBlock:^(id returnValue) {
        
        DDLog(@"%@", returnValue);
        [self fetchValueSuccessWithDic:returnValue];
        
    } WithErrorCodeBlock:^(id errorCode) {
        DDLog(@"%@", errorCode);
        [self errorCodeWithDic:errorCode];
        
    } WithFailureBlock:^{
        [self netFailure];
        DDLog(@"网络异常");
        
    }];
    
}



#pragma 获取到正确的数据，对正确的数据进行处理
-(void)fetchValueSuccessWithDic: (NSDictionary *) returnValue
{
    //对从后台获取的数据进行处理，然后传给ViewController层进行显示
    
    NSArray *statuses = returnValue[STATUSES];
    NSMutableArray *publicModelArray = [[NSMutableArray alloc] initWithCapacity:statuses.count];
    
    for (int i = 0; i < statuses.count; i ++) {
        PublicModel *publicModel = [[PublicModel alloc] init];
        
        //设置时间
        NSDateFormatter *iosDateFormater=[[NSDateFormatter alloc]init];
        iosDateFormater.dateFormat=@"EEE MMM d HH:mm:ss Z yyyy";
        
        //必须设置，否则无法解析
        iosDateFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        NSDate *date=[iosDateFormater dateFromString:statuses[i][CREATETIME]];
        
        //目的格式
        NSDateFormatter *resultFormatter=[[NSDateFormatter alloc]init];
        [resultFormatter setDateFormat:@"MM月dd日 HH:mm"];
        
        publicModel.date = [resultFormatter stringFromDate:date];
        publicModel.userName = statuses[i][USER][USERNAME];
        publicModel.text = statuses[i][WEIBOTEXT];
        publicModel.imageUrl = [NSURL URLWithString:statuses[i][USER][HEADIMAGEURL]];
        publicModel.userId = statuses[i][USER][UID];
        publicModel.weiboId = statuses[i][WEIBOID];
        publicModel.cellHeight = [self countTextHeight:publicModel.text];
        
        [publicModelArray addObject:publicModel];
        
    }
    
    self.returnBlock(publicModelArray);
}

#pragma 对ErrorCode进行处理
-(void) errorCodeWithDic: (NSDictionary *) errorDic
{
    self.errorBlock(errorDic);
}

#pragma 对网路异常进行处理
-(void) netFailure {
    self.failureBlock();
}


#pragma 跳转到详情页面，如需网路请求的，可在此方法中添加相应的网络请求
- (void)weiboDetailWithPublicModel:(PublicModel *) publicModel
                WithViewController:(UIViewController *)superController
{
    DDLog(@"%@,%@,%@",publicModel.userId,publicModel.weiboId,publicModel.text);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    PublicDetailViewController *detailController = [storyboard instantiateViewControllerWithIdentifier:@"PublicDetailViewController"];
    detailController.publicModel = publicModel;
    [superController.navigationController pushViewController:detailController animated:YES];
    
}

- (CGFloat)countTextHeight:(NSString *) text {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 0;
    UIFont *font = [UIFont systemFontOfSize:14];
    [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 80, CGFLOAT_MAX) options:options context:nil];
    return rect.size.height + 150;
}


@end
