//
//  IDZProgressBar.m
//  Copyright (c) 2013 IDZ.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.



#import "IDZProgressBar.h"

@implementation IDZProgressBar

@synthesize currentValue, maxValue;

-(void) dealloc
{
    [progressLayer release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        maxValue = 100.0f;
    }
    return self;
}

-(id) initWithBackgroundImage:(UIImage*)_progressImg progressMask:(UIImage*)_progressMaskImg insets:(CGSize)barInset;
{
    float width,height;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        width=447;
        height=40;
    }
    else
    {
        width=193;
        height=23;
    }
    width=_progressImg.size.width;
    height=_progressImg.size.height;
    if(self = [super initWithFrame:CGRectMake(0, 0, _progressImg.size.width, _progressImg.size.height)])
   // if(self = [super initWithFrame:CGRectMake(0, 0, width, height)])
    {
    
        NSLog(@"set frame::%f h:%f",width,height);
        CALayer* maskLayer = [[CALayer alloc] init];
        maskLayer.frame = CGRectMake(barInset.width, barInset.height, width,height );
        maskLayer.contents = (id)_progressMaskImg.CGImage;
       // progessView.layer.mask = maskLayer;
        
        self.layer.mask = maskLayer;
        [maskLayer release];
        
              
        progressLayer = [[CALayer alloc] init];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            progressLayer.frame = CGRectMake(barInset.width, barInset.height - 5, width, height + 10);
        }
        else
        {
            progressLayer.frame = CGRectMake(barInset.width, barInset.height + 1, width, height );
        }
        
        progressLayer.contents = (id)_progressImg.CGImage;
        
        //[progessView.layer addSublayer:progressLayer];
        [self.layer addSublayer:progressLayer];

    }
    return self;
}


-(void) setCurrentValue:(CGFloat)val
{
    currentValue = val;
    // calculate progressLayerPosition depends on currentValue Here
    CGRect f = progressLayer.frame;
    
    f.origin.x = (f.size.width / maxValue) * currentValue - f.size.width ;
    
    progressLayer.frame = f;
}

-(void)setBarImage : (UIImage *)image
{      
    progressLayer.contents = (id)image.CGImage;

}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
