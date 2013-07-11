//
//  CustomCell.h
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UILabel *addDateLabel;
@property (copy, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *addDate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@end
