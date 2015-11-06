/*
 Copyright (c) 2014-2015, GoBelieve
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "MessageLocationView.h"

#define kPinImageWidth 32
#define kPinImageHeight 39

#define KInComingMoveRight  8.0
#define kOuttingMoveRight   3.0


@interface MessageLocationView()
@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic) UIImageView *pinImageView;
@end

@implementation MessageLocationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
        self.imageView.userInteractionEnabled = YES;
        
        self.pinImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"imkitResource.bundle/PinGreen"];
        self.pinImageView.image = image;
        [self addSubview:self.pinImageView];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:self.indicatorView];
    }
    return self;
}

-(void)setMsg:(IMessage *)msg {
    [self.msg removeObserver:self forKeyPath:@"downloading"];
    [super setMsg:msg];
    [self.msg addObserver:self forKeyPath:@"downloading" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    UIImage *placehodler = [UIImage imageNamed:@"imkitResource.bundle/chat_location_preview"];
    if (self.msg.downloading) {
        [self.indicatorView startAnimating];
        self.imageView.image = placehodler;
        self.pinImageView.hidden = YES;
    } else {
        [self.indicatorView stopAnimating];
        self.pinImageView.hidden = NO;
        NSString *url = msg.content.snapshotURL;
        [self.imageView sd_setImageWithURL: [[NSURL alloc] initWithString:url]
                          placeholderImage:placehodler
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 }];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if([keyPath isEqualToString:@"downloading"]) {
        UIImage *placehodler = [UIImage imageNamed:@"imkitResource.bundle/chat_location_preview"];
        if (self.msg.downloading) {
            [self.indicatorView startAnimating];
            self.imageView.image = placehodler;
            self.pinImageView.hidden = YES;
        } else {
            [self.indicatorView stopAnimating];
            self.pinImageView.hidden = NO;
            NSString *url = self.msg.content.snapshotURL;
            [self.imageView sd_setImageWithURL: [[NSURL alloc] initWithString:url]
                              placeholderImage:placehodler
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     }];
        }
    }
}

#pragma mark - Drawing
- (CGRect)bubbleFrame {
    CGSize bubbleSize = CGSizeMake(kLocationWidth + kBubblePaddingRight, kLocationHeight + kPaddingTop + kPaddingBottom);
    return CGRectMake(floorf(self.type == BubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                      floorf(kMarginTop),
                      floorf(bubbleSize.width),
                      floorf(bubbleSize.height));
    
}


-(void)layoutSubviews {
    [super layoutSubviews];
    
    UIImage *image = (self.selectedToShowCopyMenu) ? [self bubbleImageHighlighted] : [self bubbleImage];
    CGRect bubbleFrame = [self bubbleFrame];
    
    if (self.imageView) {
        
        CGSize imageSize = CGSizeMake(kLocationWidth, kLocationHeight);
        CGFloat imgX = image.leftCapWidth + (self.type == BubbleMessageTypeOutgoing ? bubbleFrame.origin.x + kOuttingMoveRight: KInComingMoveRight);
        
        CGRect imageFrame = CGRectMake(imgX,
                                       kMarginTop + kPaddingTop,
                                       imageSize.width,
                                       imageSize.height);
        [self.imageView setFrame:imageFrame];
        
        [self.indicatorView setFrame:imageFrame];

        //center
        CGPoint centerPoint = CGPointMake(imageFrame.origin.x + imageFrame.size.width/2, imageFrame.origin.y + imageFrame.size.height/2);
        CGRect pinFrame = CGRectMake(centerPoint.x - 8, centerPoint.y - 36, kPinImageWidth, kPinImageHeight);
        self.pinImageView.frame = pinFrame;
    }
}

@end
