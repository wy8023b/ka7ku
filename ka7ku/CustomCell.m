//
//  CustomCell.m
//  tabbarNav
//
//  Created by wangye on 13-4-22.
//  Copyright (c) 2013年 wangye. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell
@synthesize image;
@synthesize title;
@synthesize addDate;
@synthesize content;
@synthesize imageView;
@synthesize titleLabel;
@synthesize contentLabel;
@synthesize addDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImage:(UIImage *)img
{
    if (![img isEqual:image]) {
        image=[img copy];
        self.imageView.image = image;
    }
}

- (void)setAddDate:(NSString *)add
{
    if (![add isEqual:addDate]) {
        addDate = [add copy];
        self.addDateLabel.text = addDate;
    }
}

- (void)setTitle:(NSString *)tit
{
    if (![tit isEqual:title]) {
        title = [tit copy];
        self.titleLabel.text = title;
    }
}

- (void)setContent:(NSString *)con
{
    if (![con isEqual:content]) {
        content = [con copy];
        self.contentLabel.text = content;
    }
}
@end
